/**
*   Batch class used for mass creation of Orders
*   @since   25/10/2012
*   @author  lukasz.skrodzki@cloudsensesolutions.com, ivan.tadic@cloudsensesolutions.com
*/
global class UnifyCreateOrdersBatch implements Database.Batchable<sObject>,  Database.AllowsCallouts{
    /**
    *   Id of Opporunity for which we are creating Orders
    */
    global Id oppId;
    /**
    *   Id of Order Group for which we are creating Orders
    */
    global Id orderGroupId;
    /**
    *   SessionId of user who initiates batch. We are using it later on to create Orchestration processes instance through PartnerAPI WSDL
    */
    global String sessionId;
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query =  'SELECT ' +
                            'Id, Name, cscfgc__Parent_Configuration__c, cscfgc__Product_Bundle__c, cscfgc__Product_Definition__r.Name,' +
                            'cscfgc__Product_Basket__c, cscfgc__Product_Definition__c, Line_Availability_Check_Result__c, Unify_Site__c, ' +
                            'Unify_Solution__c, Unify_Site__r.Name,' +
                            '(SELECT ' +
                                'Id, Name, cscfgc__Attribute_Definition__r.cscfgc__Type__c, cscfgc__Attribute_Definition__r.Name,' +
                                'cscfgc__is_Line_Item__c, cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c, cscfgc__Recurring__c,' +
                                'cscfgc__Line_Item_Description__c, cscfgc__Line_Item_Sequence__c, cscfgc__Price__c, cscfgc__Value__c,' +
                                'cscfgc__Display_Value__c, cscfgc__Product_Configuration__c ' +
                            'FROM ' +
                                'cscfgc__Attributes__r ' +
                            'ORDER BY ' +
                                'cscfgc__Line_Item_Sequence__c) ' +
                        'FROM ' +
                            'cscfgc__Product_Configuration__c ' +
                        'WHERE ' +
                            'cscfgc__Product_Bundle__r.cscfgc__Opportunity__c = \'' + oppId + '\' AND ' +
                            'cscfgc__Product_Bundle__r.cscfgc__Synchronised_with_Opportunity__c = true';
        System.debug('##### query ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Opportunity opp = [Select Id, Name, AccountId, Type, Order_To_Be_Replaced__c from Opportunity where Id = :oppId];

        Map<String,list<cscfgc__Product_Configuration__c>> parentProductConfigMap = new Map<String,list<cscfgc__Product_Configuration__c>>();
        Map<String,list<cscfgc__Product_Configuration__c>> childProductConfigMap = new Map<String,list<cscfgc__Product_Configuration__c>>();
        Map<String,set<String>> orderTypesBundleIdMap = new Map<String,set<String>>();
        Map<String,list<String>> orderTypeAndParentCfgConfigIdMap = new Map<String,list<String>>();

        //Product Configuration ID's
        Set<Id> productConfigIds = new Set<Id>();
        for(sObject product : scope){
            productConfigIds.add(((cscfgc__Product_Configuration__c)product).Id);
        }

        //Opportunity Products / Line Items
        OpportunityLineItem[] oppLineItems = [SELECT
                                                PricebookEntryId,CreatedById,LastModifiedDate,Id,UnitPrice,IsDeleted,Quantity,cscfgc__Attribute__c,
                                                OpportunityId,SystemModstamp,Product_Name__c,NRR__c,TotalPrice,ServiceDate,ListPrice,CreatedDate,SortOrder,
                                                LastModifiedById, PriceBookEntry.Name,PriceBookEntry.ProductCode
                                              FROM
                                                OpportunityLineItem
                                              WHERE
                                                cscfgc__Attribute__r.cscfgc__Product_Configuration__c in :productConfigIds];

        //Map - Attribute Id to Opportunity Product
        Map<String,OpportunityLineItem> oppLineItemMap = new Map<String,OpportunityLineItem>();
        for (OpportunityLineItem oli : oppLineItems) {
            oppLineItemMap.put(oli.cscfgc__Attribute__c, oli);
        }




        List<Order__c> orderList = new List<Order__c>();
        for (sObject product : scope) {
            cscfgc__Product_Configuration__c productConfig = (cscfgc__Product_Configuration__c)product;

            sObject newOrder = new Order__c();

            newOrder.put('Order_Group__c', orderGroupId);
            newOrder.put('product_bundle__c',productConfig.cscfgc__Product_Bundle__c);
            newOrder.put('product_Configuration__c',productConfig.Id);
            newOrder.put('Line_Availability_Check_Result__c',productConfig.Line_Availability_Check_Result__c);
            newOrder.put('order_category__c','Primary');
            newOrder.put('Product_Type__c',productConfig.cscfgc__Product_Definition__r.Name);
            //newOrder.put('Unify_Site__c',productConfig.Unify_Site__c);
            Unify_Site__c site = UnifyBatchConfigUpload.prepareSiteObjectBasedOnSiteName(oppId, productConfig.Unify_Site__r.Name, productConfig.Unify_Solution__c, productConfig.cscfgc__Product_Bundle__c);
            newOrder.put('Unify_Site__c', site.Id);
            newOrder.put('RecordTypeId', Cache.RecordTypeId('Order__c.Unify'));
            Map<String,cscfgc__Attribute__c> configAttributeMap = CreateServiceHelper.getConfigAttributeMap(productConfig);
            newOrder.put('Name',productConfig.Name);
            CreateServiceHelper.fillOrderWithOppDetails(newOrder,opp);
            CreateServiceHelper.fillOrderWithAttributeDetails(newOrder,productConfig.cscfgc__Attributes__r);

            orderList.add((Order__c)newOrder);
        }
        if(orderList.size() > 0){
            insert orderList;

            //check if this Order Group has already obtain supplier and customer PO tasks completed, if yes, create them again
            Task[] completedTasks = [Select WhatId, Subject, RecordTypeId, Type, OwnerId
                From Task
                where WhatId = :orderGroupId and Subject in ('Obtain Supplier PO','Obtain Customer PO') and Status = 'Completed' ];

            Task[] notCompletedTasks = [Select WhatId, Subject, RecordTypeId, Type, OwnerId
                From Task
                where WhatId = :orderGroupId and Subject in ('Obtain Supplier PO','Obtain Customer PO') and Status != 'Completed' ];
            List<Task> tasksToInsert = new List<Task>();

            for(Task t : completedTasks){
                boolean createTask = true;
                //check if this task has been already created and is not yet done, if yes, dont create
                for(Task ct : notCompletedTasks){
                    if(ct.Type == t.Type){
                        createTask = false;
                    }
                }
                if(createTask){
                    Task newTask = t.clone();
                    newTask.Status = 'Not Started';
                    newTask.Description = 'New Orders has been added to Order Group. You may need to obtain new Purchase Order';
                    newTask.ActivityDate = System.today().addDays(5);
                    tasksToInsert.add(newTask);
                }
            }
            if(tasksToInsert.size() > 0){
                insert tasksToInsert;
            }
        }

        Map<String,String> parentOrderConfigMap = CreateServiceHelper.getOrderConfigMap(orderList);

    }

   global void finish(Database.BatchableContext BC){
      /*  //List of Orchestration processes to be inserted
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();

        //Select Opportunity
        Opportunity opp = [SELECT
                                Id, OwnerId
                           FROM
                                Opportunity
                           WHERE
                                Id = :oppId];

        //Select Orders
        List<Order__c> orders = [SELECT
                                    Id, Product_Configuration__r.Unify_Order_Type__c, Product_Configuration__r.cscfgc__Product_Definition__r.Name, Account__c, Unify_Site__c,
                                    (SELECT Id FROM Orchestration_Processes__r)
                                 FROM
                                    Order__c
                                 WHERE
                                    Order_Group__c = :orderGroupId];
        if(Test.isRunningTest()){
            CSPOFA__Orchestration_Process_Template__c pt = new CSPOFA__Orchestration_Process_Template__c(Name = 'UNIFY Process for Order - Connectivity', CSPOFA__Process_Type__c = 'New Provide');
            insert pt;
        }

        //Select Order Process Templates and save it in the Map(process template name, proces template id)
        List<CSPOFA__Orchestration_Process_Template__c> orderProcTemplates = [SELECT
                                                                                Id, Name
                                                                             FROM
                                                                                CSPOFA__Orchestration_Process_Template__c
                                                                             WHERE
                                                                                Name LIKE 'UNIFY Process for Order - %'];

        Map<string, Id> orderProcTemplatesMap = new Map<string, Id>();
        for(CSPOFA__Orchestration_Process_Template__c temp : orderProcTemplates){
            orderProcTemplatesMap.put(temp.Name, temp.Id);
        }

        if(Test.isRunningTest()){
            CSPOFA__Orchestration_Process_Template__c pt = new CSPOFA__Orchestration_Process_Template__c(Name = 'UNIFY Process for Site', CSPOFA__Process_Type__c = 'New Provide');
            insert pt;
        }

        //Select Site Process template
        CSPOFA__Orchestration_Process_Template__c siteProcTemplate =  [SELECT
                                                                            Id, Name
                                                                       FROM
                                                                            CSPOFA__Orchestration_Process_Template__c
                                                                       WHERE
                                                                            Name = 'UNIFY Process for Site'
                                                                       LIMIT 1];

        Map<Id,Id> sitewithAccountIds = new Map<Id,Id>();
        for(Order__c ord : orders){
            //Create Order Orchestration Processes
            //Don't create Orchestration process for Configuration which are marked as existing
            //Ignore orders which already have Process
            if(ord.Product_Configuration__r.Unify_Order_Type__c != 'Existing' && ord.Orchestration_Processes__r.size() == 0){
                sitewithAccountIds.put(ord.Unify_Site__c, ord.Account__c);
                string procName = 'UNIFY Process for Order - ' + ord.Product_Configuration__r.cscfgc__Product_Definition__r.Name;
                id templateId = orderProcTemplatesMap.get(procName);
                CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c(Name = procName,
                                                                                                    CSPOFA__Process_Type__c = 'New Provide',
                                                                                                    CSPOFA__Orchestration_Process_Template__c = templateId,
                                                                                                    Order__c = ord.Id,
                                                                                                    CSPOFA__Account__c = ord.Account__c,
                                                                                                    OwnerId = opp.OwnerId);
                processList.add(orchProcess);
            }
        }
        for(Id siteId : sitewithAccountIds.keySet()){
            CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c(Name = 'UNIFY Process for Site',
                                                                                                CSPOFA__Process_Type__c = 'New Provide',
                                                                                                CSPOFA__Orchestration_Process_Template__c = siteProcTemplate.Id,
                                                                                                Site__c = siteId,
                                                                                                CSPOFA__Account__c = sitewithAccountIds.get(siteId),
                                                                                                OwnerId = opp.OwnerId);
            processList.add(orchProcess);
        }

        //Insert Processes
        if(!Test.isRunningTest()){
            //Divide it into smaller packages to not exceed 200 object in insert call limit
            List<CSPOFA__Orchestration_Process__c> processesToInsert = new List<CSPOFA__Orchestration_Process__c>();
            for(CSPOFA__Orchestration_Process__c proc : processList){
                processesToInsert.add(proc);
                if(processesToInsert.size() >= 200){
                    try{

                    }catch(Exception e){
                        System.debug(e);
                    }
                    processesToInsert.clear();
                }
            }
            if(processesToInsert.size() > 0){
                try{
                    insert processesToInsert;
                }catch(Exception e){
                    System.debug(e);
                }
            }
            CreateServiceHelper.linkOrderGroupToSites(new Set<Id>{orderGroupId});
        }*/
        CreateServiceHelper.linkOrderGroupToSites(new Set<Id>{orderGroupId});
    }

}