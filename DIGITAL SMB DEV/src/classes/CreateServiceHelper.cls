public without sharing class CreateServiceHelper {
    public class CreateServiceHelperException extends Exception {}
    public static Boolean createOrders = true;
    //@future
    public static void createOrdersFromOpportunity(List<String> wonOppIdList) {
        List<Opportunity> wonOppList = getListOfWonOpportunities(wonOppIdList);
        //
        // ---------
        // Check if we should call the new or old order creation method
        // THIS SEEMS NOT TO BE USED
        Boolean oldOrderCreationMethod = False;
        for (Opportunity opp : wonOppList) {
            if (opp.cscfgc__Product_Bundles__r.isEmpty()) {
                oldOrderCreationMethod = True;
            } else if(opp.RecordType.Name == 'Unify' && (opp.UNIFY_Opportunity_Size__c == 'Medium' || opp.UNIFY_Opportunity_Size__c == 'Large')){
                //Check if there are no Unify Product Bundles to which Commercial has not been approved (used only for MEDIUM and LARGE ooportunities)
                for(cscfgc__Product_Bundle__c pb1 : opp.cscfgc__Product_Bundles__r){
                    if(!pb1.Unify_Commercial_Approved__c){
                        throw new CreateServiceHelperException('Order can not be created for the Product Bundle configurations without Commercial Approved.');
                    }
                }
            }
        }
        // System.debug('oldOrderCreationMethod='+oldOrderCreationMethod);
        //
        // Create orders based on the won opportunities, their line items and product bundles
        //
        // ---------
        // Get a Map of all the won opportunities and their children
        Map<ID,Opportunity> oppMap = getMapOfWonOpportunities(wonOppIdList);
        system.debug('oppMap: '+oppMap);
        //
        // ---------
        // Create a list of bundle IDs
        List<String> productBundleIdList = getProductBundleIdList(oppMap);
        system.debug('productBundleIdList: '+productBundleIdList);
        //
        // ---------
        // Get a map of all oportunities keyed by bundle Id
        Map<String,Opportunity> oppBundleIdMap = getBundleIdOppMap(oppMap);
        system.debug('oppBundleIdMap: '+oppBundleIdMap);
        //
        // ---------
        // Get a Map of Configurations and their attributes keyed on their correspondiong bundle IDs
        Map<String,list<cscfgc__Product_Configuration__c>> parentProductConfigMap = new Map<String,list<cscfgc__Product_Configuration__c>>();
        Map<String,list<cscfgc__Product_Configuration__c>> childProductConfigMap = new Map<String,list<cscfgc__Product_Configuration__c>>();
        Map<String,set<String>> orderTypesBundleIdMap = new Map<String,set<String>>();
        Map<String,list<String>> orderTypeAndParentCfgConfigIdMap = new Map<String,list<String>>();
        system.debug('***>> before - productBundleIdList: '+productBundleIdList);
        system.debug('***>> before - parentProductConfigMap: '+parentProductConfigMap);
        system.debug('***>> before - childProductConfigMap: '+childProductConfigMap);
        system.debug('***>> before - orderTypesBundleIdMap: '+orderTypesBundleIdMap);
        system.debug('***>> before - orderTypeAndParentCfgConfigIdMap: '+orderTypeAndParentCfgConfigIdMap);
        getProductConfigurationMap(productBundleIdList,parentProductConfigMap,childProductConfigMap,orderTypesBundleIdMap,orderTypeAndParentCfgConfigIdMap);
        system.debug('***>> after - productBundleIdList: '+productBundleIdList);
        system.debug('***>> after - parentProductConfigMap: '+parentProductConfigMap);
        system.debug('***>> after - childProductConfigMap: '+childProductConfigMap);
        system.debug('***>> after - orderTypesBundleIdMap: '+orderTypesBundleIdMap);
        system.debug('***>> after - orderTypeAndParentCfgConfigIdMap: '+orderTypeAndParentCfgConfigIdMap);
        //
        // ---------
        // Get a Map of Opportunity Line Items keyed by attribute Id
        Map<String,OpportunityLineItem> oppLineItemMap = getOpportunityLineItemMap(oppMap);
        //system.debug('oppLineItemMap: '+oppLineItemMap);
        //
        // ---------
        // Get a Map of the Order Group record type ids keyed by Name
        // The Record Type Names should match the Solution attribute values in the product definitions
        Map<String,String> orderGroupRecordTypeMap = getOrderGroupRecordTypeMap();
        //system.debug('orderGroupRecordTypeMap: '+orderGroupRecordTypeMap);
        //
        //system.debug('***>>> - oppBundleIdMap: '+oppBundleIdMap);
        //system.debug('***>>> - orderTypesBundleIdMap: '+orderTypesBundleIdMap);
        //system.debug('***>>> - orderGroupRecordTypeMap: '+orderGroupRecordTypeMap);
        Map<String,list<String>> orderGroupOppIdMap = getOrderGroupOppIdMap(oppBundleIdMap,orderTypesBundleIdMap,orderGroupRecordTypeMap);
        //system.debug('orderGroupOppIdMap: '+orderGroupOppIdMap);
        //
        // ---------
        // Create the parent orders
        List<Order__c> parentOrderList = createOrderList(parentProductConfigMap, oppBundleIdMap,false, null,orderGroupOppIdMap,orderTypeAndParentCfgConfigIdMap,orderGroupRecordTypeMap);
        insert parentOrderList;
        //system.debug('@@@parentOrderList size: '+parentOrderList.size());
        //
        // ---------
        // Get a Map of parent order IDs keyed by the corrsponding configuration ID
        Map<String,String> parentOrderConfigMap = getOrderConfigMap(parentOrderList);
        //system.debug('parentOrderConfigMap: '+parentOrderConfigMap);
        //
        // ---------
        // Get a Map of TariffCodes keyed by the corrsponding configuration ID
        Map<String,String> parentTariffCodeConfigMap = getTariffCodeConfigMap(parentOrderList);
        //system.debug('parentTariffCodeConfigMap: '+parentTariffCodeConfigMap);
        //
        // ---------
        // Create a list of order line items: This will be based on the associated opportunity line items
        List<Order_Line_Item__c> parentOrderLineItemList = createOrderLineItems(oppLineItemMap,parentProductConfigMap,parentOrderConfigMap,parentTariffCodeConfigMap);
        insert parentOrderLineItemList;
        //system.debug('@@@parentOrderLineItemList size: '+parentOrderLineItemList.size());
        //
        // ---------
        // Check if we need to create child orders
        if (!childProductConfigMap.isEmpty()) {
            //
            // ---------
            // Create the child orders
            List<Order__c> childOrderList = createOrderList(childProductConfigMap, oppBundleIdMap,true, parentOrderConfigMap, orderGroupOppIdMap,orderTypeAndParentCfgConfigIdMap,orderGroupRecordTypeMap);
            insert childOrderList;
            //system.debug('childOrderList: '+childOrderList);
            //
            // ---------
            // Get a Map of child order IDs keyed by the corrsponding configuration ID
            Map<String,String> childOrderConfigMap = getOrderConfigMap(childOrderList);
            //system.debug('childOrderConfigMap: '+childOrderConfigMap);
            //
            // ---------
            // Get a Map of TariffCodes keyed by the corrsponding configuration ID
            Map<String,String> childTariffCodeConfigMap = getTariffCodeConfigMap(childOrderList);
            //system.debug('childTariffCodeConfigMap: '+childTariffCodeConfigMap);
            //
            // ---------
            // Create a list of order line items: This will be based on the associated opportunity line items
            List<Order_Line_Item__c> childOrderLineItemList = createOrderLineItems(oppLineItemMap,childProductConfigMap,childOrderConfigMap,childTariffCodeConfigMap);
            insert childOrderLineItemList;
            //system.debug('childOrderLineItemList: '+childOrderLineItemList);
        }
        // Get the order group rec ids into a list. They are stored every other string.
        list<String> orderGroupIdsList = new list<String>();
        for (list<String> orderGroupIdSolutionList : orderGroupOppIdMap.values()) {
            for (integer i=0 ; i<orderGroupIdSolutionList.size() ; i=i+2) {
                orderGroupIdsList.add(orderGroupIdSolutionList[i]);
            }
        }
        Set<Id> orderGroupIds = new Set<Id>();

        for(List<String> ogs : orderGroupOppIdMap.values()){
            for(Integer i = 0; i < ogs.size(); i=i+2){
                orderGroupIds.add(ogs[i]);
            }
        }

        System.debug('### OUTPUT >>>>> CreateServiceHelper: createOrdersFromOpportunity: orderGroupOppIdMap: '+orderGroupOppIdMap);
        System.debug('### OUTPUT >>>>> CreateServiceHelper: createOrdersFromOpportunity: orderGroupIdsList: '+orderGroupIdsList);
        if(!orderGroupIdsList.isEmpty()) { // Fix to stop sending empty items to Batch Apex
            DiseMappingBatchAsync rs = new DiseMappingBatchAsync();
            rs.query = 'SELECT Id, Name, Product_Configuration__c, Tariff_Code__c, Product_Category__c, (select Id, Name, Attribute__c, Attribute__r.cscfgc__Attribute_Definition__r.cscfgc__lookup_Query__c, Attribute__r.cscfgc__Attribute_Definition__r.Name from Order_Line_Items__r) '+
                   'FROM Order__c where Order_Group__c in '+Utility.convertListToString(orderGroupIdsList);
            System.debug('### OUTPUT >>>>> CreateServiceHelper: createOrdersFromOpportunity: rs.query: '+rs.query);
            Database.executeBatch(rs, 1);
        }
        //
        createOrders = false;
    }

    // -----------
    // Create order line items
    public static List<Order_Line_Item__c> createOrderLineItems(Map<String,OpportunityLineItem> oppLineItemMap,
                                                                    Map<String,list<cscfgc__Product_Configuration__c>> productConfigMap,
                                                                    Map<String,String> orderConfigMap,
                                                                    Map<String,String> tariffCodeConfigMap) {
        List<Order_Line_Item__c> orderLineItemList =  new List<Order_Line_Item__c>();
        //
        // ---------
        // First get a list of attribute IDs
        List<String> lineItemAttributeIdList = new List<String>();
        //
        // ---------
        // Loop through the bundles
        for (String bundleId : productConfigMap.keySet()) {
            //
            // ---------
            // Loop through the configs within this bundle
            for (cscfgc__Product_Configuration__c config : productConfigMap.get(bundleId)) {
                //
                // ---------
                // Loop through the attributes within this config
                for (cscfgc__Attribute__c attribute : config.cscfgc__Attributes__r) {
                    lineItemAttributeIdList.add(attribute.id);
                }
            }
        }
        //
        // ---------
        // Get a Map of the line item attributes and all their attribute fields
        List<cscfgc__Attribute__c> attributeList = [select Id, Name, (select Id, Name, cscfgc__Value__c from cscfgc__Attribute_Fields__r)
                                                    from cscfgc__Attribute__c where id in :lineItemAttributeIdList];
        /*system.debug('********------attributeList.size():'+attributeList.size());
        system.debug('********------attributeList:'+attributeList);*/
        Map<String,String> attributePackageCodeMap = new Map<String,String>();
        Map<String,String> attributeServiceCodeMap = new Map<String,String>();
        for (cscfgc__Attribute__c attrib : attributeList) {
            system.debug('********>>>>Attribute Name:'+attrib.Name+':Attribute Id'+attrib.id);
            system.debug('********------attrib.cscfgc__Attribute_Fields__r.size():'+attrib.cscfgc__Attribute_Fields__r.size());
            for (cscfgc__Attribute_Field__c field : attrib.cscfgc__Attribute_Fields__r) {
                system.debug('********>>>>field.Name:'+field.Name);
                system.debug('********>>>>field.cscfgc__Value__c:'+field.cscfgc__Value__c);
                if (field.Name == 'Package_Code') {
                    attributePackageCodeMap.put(attrib.Id,field.cscfgc__Value__c);
                } else if (field.Name == 'Service_Code') {
                    attributeServiceCodeMap.put(attrib.Id,field.cscfgc__Value__c);
                }
            }
        }
        /*system.debug('********------attributeIncomeCodeMap:'+attributeIncomeCodeMap);
        system.debug('********------attributeCostCodeMap:'+attributeCostCodeMap);
        system.debug('********------attributeProductTypeMap:'+attributeProductTypeMap);*/
        //
        // Create the order line items
        //
        // ---------
        // Loop through the bundles
        for (String bundleId : productConfigMap.keySet()) {
            //system.debug('********-->>--bundleId:'+bundleId);
            //
            // ---------
            // Loop through the configs within this bundle
            for (cscfgc__Product_Configuration__c config : productConfigMap.get(bundleId)) {
                //system.debug('********-->>--config:'+config.Id);
                //
                // ---------
                // Loop through the attributes within this config
                for (cscfgc__Attribute__c attribute : config.cscfgc__Attributes__r) {
                    //system.debug('********-->>--attribute:'+attribute.Id+':'+attribute.cscfgc__Is_Line_Item__c);
                    Order_Line_Item__c newOrderLineItem = new Order_Line_Item__c();
                    //
                    // ---------
                    // Only look at attributes that are line items
                    if (attribute.cscfgc__Is_Line_Item__c) {
                        //system.debug('********-->>--attribute:'+attribute.Id+':'+attribute.cscfgc__Is_Line_Item__c);
                        if (oppLineItemMap.containsKey(attribute.id)) {
                            //system.debug('********-->><<--attribute:'+attribute.Id+':'+attribute.cscfgc__Is_Line_Item__c);
                            OpportunityLineItem currentOppLineItem = oppLineItemMap.get(attribute.id);
                            //
                            // ---------
                            // Copy the current opp line item details and add them to the order line item to be created
                            newOrderLineItem.List_price__c               = currentOppLineItem.ListPrice;
                            String lineName = currentOppLineItem.PriceBookEntry.Name;
                            if (currentOppLineItem.PriceBookEntry.Name.length() > 80)
                                lineName = lineName.subString(0,79);
                            newOrderLineItem.Name                        = lineName;
                            newOrderLineItem.Line_Description__c         = currentOppLineItem.Description;
                            newOrderLineItem.Quantity__c                 = currentOppLineItem.Quantity;
                            newOrderLineItem.MRR__c                      = currentOppLineItem.MRR__c;
                            newOrderLineItem.NRR__c                      = currentOppLineItem.NRR__c;
                            newOrderLineItem.Sales_Price__c              = currentOppLineItem.UnitPrice;
                            newOrderLineItem.Total_Price__c              = currentOppLineItem.TotalPrice;
                            newOrderLineItem.order__c                    = orderConfigMap.get(config.Id);
                            newOrderLineItem.tariff_code__c              = tariffCodeConfigMap.get(config.Id);
                            newOrderLineItem.Attribute__c                = attribute.Id;
                            //
                            if (attributePackageCodeMap.containsKey(attribute.id))
                                newOrderLineItem.Package_Code__c             = attributePackageCodeMap.get(attribute.id);
                            //
                            //System.debug('****************>>> tariff code '+tariffCodeConfigMap.get(config.Id));
                            if (attributeServiceCodeMap.containsKey(attribute.id)){
                                //System.debug('************>>> attribute name '+attribute.Name);
                                //System.debug('************>>> service code '+attributeServiceCodeMap.get(attribute.id));
                                newOrderLineItem.Service_Code__c             = attributeServiceCodeMap.get(attribute.id);
                            }
                            //
                            if (attribute.cscfgc__Recurring__c) {
                                newOrderLineItem.Payment_Frequency__c = 'Recurring';
                            } else {
                                newOrderLineItem.Payment_Frequency__c = 'One-Off';
                            }
                            //
                            // ---------
                            // Add the order line item to the list
                            orderLineItemList.add(newOrderLineItem);
                        }
                    }
                }
            }
        }
        //system.debug('********------orderLineItemList.size():'+orderLineItemList.size());
        //
        // ---------
        // return the order name
        return orderLineItemList;
    }

    // -----------
    // Get a Map of parent order IDs keyed by the corrsponding configuration ID
    public static Map<String,String> getOrderConfigMap(List<Order__c> orderList) {
        Map<String,String> orderConfigMap = new Map<String,String>();
        for (Order__c order : orderList) {
            orderConfigMap.put(order.product_Configuration__c,order.Id);
        }
        return orderConfigMap;
    }

    // -----------
    // Get a Map of tariffCodes keyed by the corrsponding configuration ID
    public static Map<String,String> getTariffCodeConfigMap(List<Order__c> orderList) {
        Map<String,String> tariffCodeConfigMap = new Map<String,String>();
        for (Order__c order : orderList) {
            System.debug('************>>>> order.product_Configuration__c'+order.product_Configuration__c);
            System.debug('************>>>> order.Tariff_Code__c'+order.Tariff_Code__c);
            tariffCodeConfigMap.put(order.product_Configuration__c,order.Tariff_Code__c);
        }
        return tariffCodeConfigMap;
    }

    // -----------
    // Get a Map of OrderGroups keyed by the corrsponding Opportunity ID
    public static Map<String,list<String>> getOrderGroupOppIdMap(Map<String,Opportunity> oppBundleIdMap,
                                                           Map<String,set<String>> orderTypesBundleIdMap,
                                                           Map<String,String> orderGroupRecordTypeMap) {

        List<Order_Group__c> orderGroupList = new List<Order_Group__c>();
        //
        for (String key : oppBundleIdMap.keySet()) {
            //
            // ---------
            // Get the opportunity that this bundle belongs to
            Opportunity opp = oppBundleIdMap.get(key);
            //
            // ---------
            // Get the Order Group record types needed for this bundle
            set<String> solutions = new set<String>();
            if (orderTypesBundleIdMap.containsKey(key))
                solutions = orderTypesBundleIdMap.get(key);
            set<String> allowedSolutions = new set<String>();
            // for any Solution the user is not allowed access to the record type, replace it with 'Master'
            for (String solution : solutions) {
                if (orderGroupRecordTypeMap.containsKey(solution)) {
                    allowedSolutions.add(solution);
                } else {
                    allowedSolutions.add('Master');
                }
            }
            if(opp.RecordType.Name == 'Unify'){
                orderGroupList.add(new Order_Group__c(Name = opp.Name,
                                                              RecordTypeId = orderGroupRecordTypeMap.get('Unify'),
                                                              Solution__c = opp.Unify_Solution__c,
                                                              Opportunity__c = opp.Id));
            }else{
                for (String solution : allowedSolutions) {
                    if (solution=='Master') {
                        // the default record type will be used
                        orderGroupList.add(new Order_Group__c(Name = opp.Name,
                                                              Opportunity__c = opp.Id));
                    } else {
                        orderGroupList.add(new Order_Group__c(Name = opp.Name,
                                                              RecordTypeId = orderGroupRecordTypeMap.get(solution),
                                                              Solution__c = solution,
                                                              Opportunity__c = opp.Id));
                    }
                }
            }
        }
        insert orderGroupList;
        //
        Map<String,list<String>> orderGroupOppIdMap = new Map<String,list<String>>();
        String orderGroupSolution;
        for (Order_Group__c orderGroup : orderGroupList) {
            if (orderGroup.Solution__c==null || orderGroup.Solution__c=='') {
                orderGroupSolution = 'Master';
            } else {
                orderGroupSolution = orderGroup.Solution__c;
            }
            if (orderGroupOppIdMap.get(orderGroup.Opportunity__c)==null) {
                orderGroupOppIdMap.put(orderGroup.Opportunity__c, new list<String>{orderGroup.id,orderGroupSolution});
            } else {
                list<String> orderGroupSolutionList = orderGroupOppIdMap.get(orderGroup.Opportunity__c);
                orderGroupSolutionList.add(orderGroup.id);
                orderGroupSolutionList.add(orderGroupSolution);
            }
        }
        return orderGroupOppIdMap;
    }

    // Get a Map of Order_Group__c record type ids keyed by Name
    public static Map<String,String> getOrderGroupRecordTypeMap() {
        Map<String,String> recordTypeMap = new Map<String,String>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Order_Group__c;
        List<Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfos();
        for (Schema.RecordTypeInfo rti : rtMapById) {
            if (rti.isAvailable()) {
                recordTypeMap.put(rti.getName(),rti.getRecordTypeId());
            }
        }
        return recordTypeMap;
    }

    // -----------
    // Get a list of newly created parent orders
    public static List<Order__c> createOrderList(Map<String,list<cscfgc__Product_Configuration__c>> productConfigMap,
                                                     Map<String,Opportunity> oppBundleIdMap,
                                                     Boolean isChild,
                                                     Map<String,String> ProductConfigParentOrderMap,
                                                     Map<String,list<String>> orderGroupOppIdMap,
                                                     Map<String,list<String>> orderTypeAndParentCfgConfigIdMap,
                                                     Map<String,String> orderGroupRecordTypeMap) {
        //
        System.debug('  isChild='+isChild);
        //System.debug('@@@ RAC @@@ : createOrderList: configMap.size='+productConfigMap.size());
        System.debug(' oppBundleIdMap.size='+oppBundleIdMap);
        if (productConfigParentOrderMap != null) System.debug('  productConfigParentOrderMap.size='+productConfigParentOrderMap.size());
        System.debug(' orderGroupOppIdMap.size='+orderGroupOppIdMap.size());
        //
        Map<String, Id> profileMap = new Map<String, Id>();
        Profile[] p = [Select p.UserType, p.UserLicenseId, p.Name, p.Id From Profile p where p.Name = 'BE User' or p.Name = 'Head of Be' or p.Name = 'BE Partner Portal Profile'];
        for(Profile prof : p)
        {
            profileMap.put(prof.Name, prof.Id);
        }

        //sales account number from the user SOS code for the current user
        User u = [SELECT Id, Name, UserType, ProfileId, Rep_Code_SOS_Code__c FROM User WHERE Id = :userinfo.getUserId()][0];

        //
        List<Order__c> orderList = new List<Order__c>();
        //
        for (String key : oppBundleIdMap.keySet()) {
            //
            // ---------
            // Get the opportunity that this bundle belongs to
            Opportunity opp = oppBundleIdMap.get(key);
            //
            // ---------
            // Get the Main and Billing Contacts to populate against the created orders
            String mainContactId = getMaincontactId(opp);
            String billingContactId = '';
            if (u.ProfileId != profileMap.get('BE User') && u.ProfileId != profileMap.get('Head of Be') &&
                u.ProfileId != profileMap.get('BE Partner Portal Profile')) {
                billingContactId = getBillingcontactId(opp);
            }
            //
            // ---------
            // Get the list of configurations belonging to the current bundle
            list<cscfgc__Product_Configuration__c> productConfigList = new list<cscfgc__Product_Configuration__c>();
            if (productConfigMap.containsKey(key))
                productConfigList = productConfigMap.get(key);
            //
            // ---------
            // Loop through the configurations and create the corresponding order
            for (cscfgc__Product_Configuration__c productConfig : productConfigList) {
                //
                // ---------
                // Instantiate a new order
                sObject newOrder = new Order__c();
                //
                // ---------
                // get the parent config id and solution relating to this config. Keep going till you reach the config without a parent, you should then have the 'Solution' string.
                list<String> solutionAndParentConfig = orderTypeAndParentCfgConfigIdMap.get(productConfig.Id);
                while (solutionAndParentConfig[1]!=null) {
                    solutionAndParentConfig = orderTypeAndParentCfgConfigIdMap.get(solutionAndParentConfig[1]);
                }
                String solution = solutionAndParentConfig[0];
                if ( ! orderGroupRecordTypeMap.containsKey(solution)) {
                    solution = 'Master';
                }
                //system.debug('####### Creating an order for solution '+solution);
                //
                // Get the order group id for this opp and solution
                list<String> orderGroupSolutions = orderGroupOppIdMap.get(opp.Id);
                //system.debug('####### Params for order group '+orderGroupSolutions);
                // loop through every other string matching on the solution, the id and solution are in pairs
                String orderGroupId;
                for (integer i=1 ; i<orderGroupSolutions.size() ; i=i+2) {
                    if (orderGroupSolutions[i]==solution) {
                        orderGroupId = ordergroupSolutions[i-1];
                        break;
                    }
                }
                if(orderGroupId == null && opp.Unify_Solution__c != null && opp.Unify_Solution__c != '' && orderGroupSolutions != null && orderGroupSolutions.size() == 2){
                    orderGroupId = orderGroupSolutions[0];
                }
                newOrder.put('Order_Group__c', orderGroupId);
                //system.debug('####### Setting the orders Order Group to '+orderGroupId);
                //
                // ---------
                if (isChild) {
                    newOrder.put('Primary_Order__c', ProductConfigParentOrderMap.get(productConfig.cscfgc__Parent_Configuration__c));
                }
                //
                // ---------
                // Set the product bundle and product configuration record IDs on the order
                newOrder.put('product_bundle__c',productConfig.cscfgc__Product_Bundle__c);
                newOrder.put('product_Configuration__c',productConfig.Id);
                newOrder.put('Line_Availability_Check_Result__c',productConfig.Line_Availability_Check_Result__c);
                //
                // ---------
                // Set the main and billing contacts on the order
                newOrder.put('Main_Contact__c',mainContactId);
                newOrder.put('Billing_Contact__c',billingContactId);
                //
                // ---------
                // Set the order category to primary as this is a parent order
                if (isChild) {
                    newOrder.put('order_category__c','Secondary');
                } else {
                    newOrder.put('order_category__c','Primary');
                }
                newOrder.put('Product_Type__c',productConfig.cscfgc__Product_Definition__r.Name);
                newOrder.put('Unify_Site__c',productConfig.Unify_Site__c);
                //
                // ---------
                // Get a map configuration attributes keyed on attribute name
                Map<String,cscfgc__Attribute__c> configAttributeMap = getConfigAttributeMap(productConfig);
                //
                // ---------
                // Get the order name
                newOrder.put('Name',getOrderName(productConfig,configAttributeMap,opp));
                //
                // ---------
                // Fill the order with details from the opportunity
                fillOrderWithOppDetails(newOrder,opp);
                //
                // ---------
                // Fill the order with details from the Config attributes
                fillOrderWithAttributeDetails(newOrder,productConfig.cscfgc__Attributes__r);
                //
                // ---------
                // Fill the order with details needed for DISE provisioning
                fillOrderWithDiseDetails(newOrder, u);
                //
                // ---------
                // Get the new order to the parentOrderList
                orderList.add((Order__c)newOrder);
            }
        }
        //
        return orderList;
    }

    // -----------
    // Fill the order with details from the Config attributes
    public static void fillOrderWithAttributeDetails(sObject order,
                                                       List<cscfgc__Attribute__c> attributeList) {
        for (cscfgc__Attribute__c attribute : attributeList) {
            try {
                if (attribute.cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c != null) {
                    if (attribute.cscfgc__Attribute_Definition__r.cscfgc__Type__c == 'Select List') {
                        order.put(attribute.cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c,attribute.cscfgc__Display_value__c);
                    } else if (attribute.cscfgc__Attribute_Definition__r.cscfgc__Type__c == 'Date') {
                        order.put(attribute.cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c,stringToDate(attribute.cscfgc__value__c));
                    // Was checking for 'Boolean', changed to 'Checkbox'
                    } else if (attribute.cscfgc__Attribute_Definition__r.cscfgc__Type__c == 'Checkbox') {
                        order.put(attribute.cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c,attribute.cscfgc__value__c == 'Yes' ? True : False);
                    } else {
                        order.put(attribute.cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c,attribute.cscfgc__value__c);
                    }
                }
            } catch (Exception ex) {
                // The field was not found - go to next attribute.
                // Note this is a workaround as sObject does not
                // support the containsKey method
                system.debug('********** fillOrderWithAttributeDetails ---------->>>>>>>>'+attribute.cscfgc__value__c+'>>>>'+ex);
            }
        }
    }

    // -----------
    // Fill the order with details from the opportunity
    public static void fillOrderWithOppDetails(sObject order,
                                                 Opportunity opp) {
        //
        // ---------
        // Get the account and opportunity IDs
        order.put('account__c',opp.AccountId);
        order.put('Opportunity__c',opp.Id);
        //
        // ---------
        // Set the Order Status Reason based on the opportunity business type
        If (opp.Type == 'New Business') {
            order.put('Order_Status_Reason__c','New Business');
        } else {
            order.put('Order_Status_Reason__c',opp.Type);
        }
        //
        // ---------
        // If this is a replacement order (ie. a regrade) - make sure we get the replaced order ID
        // and set it as the related parent order
        if (opp.Order_To_Be_Replaced__c != null) {
            order.put('Related_Parent_Order__c',opp.Order_To_Be_Replaced__c);
        }
    }

    // -----------
    // Fill the order with details for mobile provisioning
    public static void fillOrderWithDiseDetails(sObject order, User usr) {
        // Start of code changes for DISE - extra fields required to enter orders into DISE.
        // ---------
        // order type comes in from product attributes
        // payment method comes in from product attributes


        order.put('Sales_Account_Number__c',usr.Rep_Code_SOS_Code__c);
        // porting indicator comes in from product attributes
        // mobile porting number comes in from product attributes
        // contract duration/term comes in from product attributes
        // contract start date is filled in automatically by sfdc config - today()+1
        // imei number is filled in automatically by sfdc config - left blank
        // sim serial number is filled in automatically by sfdc config - left blank
        // ---------
        // End of code changes for DISE - extra fields required to enter orders into DISE.
    }

    // -----------
    // Get the order name
    public static String getOrderName(cscfgc__Product_Configuration__c productConfiguration,
                                        Map<String,cscfgc__Attribute__c> configAttributeMap,
                                        Opportunity opp) {
        //
        // ---------
        // Intsantiate the order name
        String orderName = '';
        //
        // ---------
        // Build the order name
        if (configAttributeMap.containsKey('Postcode') && configAttributeMap.get('Postcode').cscfgc__value__c != null &&
            configAttributeMap.containsKey('Provide Type') && configAttributeMap.get('Provide Type').cscfgc__value__c != null) {
            orderName = configAttributeMap.get('Postcode').cscfgc__value__c+ '-'+productConfiguration.cscfgc__Product_Definition__r.Name+'-'+configAttributeMap.get('Provide Type').cscfgc__value__c;
        } else {
            orderName = productConfiguration.cscfgc__Product_Definition__r.Name;
        }

        //
        // ---------
        // return the order name
        return orderName;
    }

    // -----------
    // Get the main contact Id
    public static String getMaincontactId(Opportunity opp) {
        //
        // ---------
        // Get the Main Contact to populate against the created orders
        String mainContactId = null;
        if (opp.OpportunityContactRoles.size() != 0) {
            for (OpportunityContactRole oppContactRole : opp.OpportunityContactRoles) {
                if (oppContactRole.Role == 'Technical Buyer') {
                    if (mainContactId == null)
                        mainContactId = oppContactRole.contactId;
                }
                //
                if (oppContactRole.IsPrimary){
                    if (mainContactId == null)
                        mainContactId = oppContactRole.contactId;
                }
            }
            if (mainContactId == null) {
                throw new ContactRoleException('The Opportunity does not have a Primary contact. Add a primary contact first');
            }
        } else {
            throw new ContactRoleException('The Opportunity does not have a Primary contact. Add a primary contact first');
        }
        //
        // ---------
        // return the Main contact Id
        return mainContactId;
    }

    // -----------
    // Get the main contact Id
    public static String getBillingContactId(Opportunity opp) {
        //
        // ---------
        // Get the Billing Contact to populate against the created orders
        String BillingContactId = null;
        if (opp.OpportunityContactRoles.size() != 0) {
            for (OpportunityContactRole oppContactRole : opp.OpportunityContactRoles) {
                if (oppContactRole.Role == 'Billing') {
                    if (BillingContactId == null)
                        BillingContactId = oppContactRole.contactId;
                }
            }
            if (BillingContactId == null) {
                throw new ContactRoleException('The Opportunity does not have a Billing contact. Add a billing contact first');
            }
        } else {
            throw new ContactRoleException('The Opportunity does not have a Billing contact. Add a billing contact first');
        }
        //
        // ---------
        // return the Billing contact Id
        return BillingContactId;
    }

    // -----------
    // Get a map configuration attributes keyed on attribute name
    public static Map<String,cscfgc__Attribute__c> getConfigAttributeMap(cscfgc__Product_Configuration__c productConfiguration) {
        //
        // ---------
        // Create the Attribute Map for this configuration
        Map<String,cscfgc__Attribute__c> configAttributeMap = new Map<String,cscfgc__Attribute__c>();
        //
        // ---------
        // Loop through the configuration attributes and populate the map
        for (cscfgc__Attribute__c attribute : productConfiguration.cscfgc__Attributes__r) {
            configAttributeMap.put(attribute.cscfgc__Attribute_Definition__r.Name,attribute);
        }
        //
        // ---------
        // Return the map
        return configAttributeMap;
    }

    // -----------
    // Get parent and child product configuration maps
    public static void getProductConfigurationMap(List<String> productBundleIdList,
                                                  Map<String,list<cscfgc__Product_Configuration__c>> parentProductConfigMap,
                                                  Map<String,list<cscfgc__Product_Configuration__c>> childProductConfigMap,
                                                  Map<String,set<String>> orderTypesBundleIdMap,
                                                  Map<String,list<String>> orderTypeAndParentCfgConfigIdMap) {
        //
        // ---------
        // Get a list of all bundle Configs
        system.debug('getProductConfigurationMap: productBundleIdList: '+productBundleIdList);
        List<cscfgc__Product_Configuration__c> prodConfigList = [select Id, Name, cscfgc__Parent_Configuration__c, cscfgc__Product_Bundle__c, cscfgc__Product_Definition__r.Name,
                                                     cscfgc__Product_Basket__c, cscfgc__Product_Definition__c, Line_Availability_Check_Result__c, Unify_Site__c,
                                                     (select Id, Name, cscfgc__Attribute_Definition__r.cscfgc__Type__c, cscfgc__Attribute_Definition__r.Name,
                                                      cscfgc__is_Line_Item__c, cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c, cscfgc__Recurring__c,
                                                      cscfgc__Line_Item_Description__c, cscfgc__Line_Item_Sequence__c, cscfgc__Price__c, cscfgc__Value__c,
                                                      cscfgc__Display_Value__c, cscfgc__Product_Configuration__c from cscfgc__Attributes__r
                                                      order by cscfgc__Line_Item_Sequence__c) from cscfgc__Product_Configuration__c
                                                      where cscfgc__Product_bundle__c in :productBundleIdList];
        //
        // ---------
        // Get a Map of all parent product configs keyed on bundle
        List<cscfgc__Product_Configuration__c> parentProductConfigList;
        List<cscfgc__Product_Configuration__c> childProductConfigList;
        set<String> orderTypesBundleIdSet;
        String configSolution;
        System.debug('at-1');
        for (cscfgc__Product_Configuration__c prodConfig : prodConfigList) {
        system.debug('<<<<prodConfigList>>>>'+prodConfig.Id+':--:'+prodConfig.cscfgc__Parent_Configuration__c);
        System.debug('at0');
            if (prodConfig.cscfgc__Parent_Configuration__c == null) {
                if (parentProductConfigMap.containsKey(prodConfig.cscfgc__Product_Bundle__c)) {
                    parentProductConfigList = parentProductConfigMap.get(prodConfig.cscfgc__Product_Bundle__c);
                    parentProductConfigList.add(prodConfig);
                    parentProductConfigMap.put(prodConfig.cscfgc__Product_Bundle__c,parentProductConfigList);
                } else {
                    parentProductConfigList = new List<cscfgc__Product_Configuration__c>();
                    parentProductConfigList.add(prodConfig);
                    parentProductConfigMap.put(prodConfig.cscfgc__Product_Bundle__c,parentProductConfigList);
                }
            } else {
                if (childProductConfigMap.containsKey(prodConfig.cscfgc__Product_Bundle__c)) {
                    childProductConfigList = childProductConfigMap.get(prodConfig.cscfgc__Product_Bundle__c);
                    childProductConfigList.add(prodConfig);
                    childProductConfigMap.put(prodConfig.cscfgc__Product_Bundle__c,childProductConfigList);
                } else {
                    childProductConfigList = new List<cscfgc__Product_Configuration__c>();
                    childProductConfigList.add(prodConfig);
                    childProductConfigMap.put(prodConfig.cscfgc__Product_Bundle__c,childProductConfigList);
                }
            }

            // check for different Solutions (Order Group record types) keyed on bundle
            configSolution = null;
            boolean solutionMissing = true;
            for (cscfgc__Attribute__c attribute : prodConfig.cscfgc__Attributes__r) {
                if (attribute.Name=='Solution' && attribute.cscfgc__Value__c!=null) {
                    if (orderTypesBundleIdMap.containsKey(prodConfig.cscfgc__Product_Bundle__c)) {
                        orderTypesBundleIdSet = orderTypesBundleIdMap.get(prodConfig.cscfgc__Product_Bundle__c);
                        orderTypesBundleIdSet.add(attribute.cscfgc__Value__c);
                        orderTypesBundleIdMap.put(prodConfig.cscfgc__Product_Bundle__c,orderTypesBundleIdSet);
                    } else {
                        orderTypesBundleIdSet = new set<String>();
                        orderTypesBundleIdSet.add(attribute.cscfgc__Value__c);
                        orderTypesBundleIdMap.put(prodConfig.cscfgc__Product_Bundle__c,orderTypesBundleIdSet);
                    }
                    configSolution = attribute.cscfgc__Value__c;
                    solutionMissing = false;
                    break;
                }
            }
            // default 'Fixed' if nothing found and it's a top level config (ie no parent config)
            if (solutionMissing && prodConfig.cscfgc__Parent_Configuration__c==null) {
                configSolution = 'Fixed';
                if (orderTypesBundleIdMap.containsKey(prodConfig.cscfgc__Product_Bundle__c)) {
                    orderTypesBundleIdSet = orderTypesBundleIdMap.get(prodConfig.cscfgc__Product_Bundle__c);
                    orderTypesBundleIdSet.add('Fixed');
                    orderTypesBundleIdMap.put(prodConfig.cscfgc__Product_Bundle__c,orderTypesBundleIdSet);
                } else {
                    orderTypesBundleIdSet = new set<String>();
                    orderTypesBundleIdSet.add('Fixed');
                    orderTypesBundleIdMap.put(prodConfig.cscfgc__Product_Bundle__c,orderTypesBundleIdSet);
                }
            }
            // map the config id to - its parent config id and solution (only one will have a value)
            orderTypeAndParentCfgConfigIdMap.put(prodConfig.Id, new list<String>{configSolution,prodConfig.cscfgc__Parent_Configuration__c});

        }
        system.debug('<<<<prodConfigList>>>>'+prodConfigList);
        system.debug('<<<<parentProductConfigList>>>>'+parentProductConfigList);
        system.debug('<<<<childProductConfigList>>>>'+childProductConfigList);
        system.debug('<<<<orderTypeAndParentCfgConfigIdMap>>>>'+orderTypeAndParentCfgConfigIdMap);
    }

    // -----------
    // Get a Map of all Opportunity Line Items keyed on Attribute Id
    public static Map<String,OpportunityLineItem> getOpportunityLineItemMap(Map<ID,Opportunity> oppMap) {
        system.debug('>> getOpportunityLineItemMap for ' + oppMap);
        if (oppMap == null || oppMap.keyset().size() == 0) {
            return new Map<String,OpportunityLineItem>();
        }

        /*
        string query = 'select ' + Utility.getSobjectFields('OpportunityLineItem') +
                ', PriceBookEntry.Name,PriceBookEntry.ProductCode from OpportunityLineItem where OpportunityId in (';
                */
        String query = 'select PricebookEntryId,'+
                        'CreatedById,LastModifiedDate,Id,'+
                        'UnitPrice,Description,MRR__c,IsDeleted,Quantity,cscfgc__Attribute__c,'+
                        'OpportunityId,SystemModstamp,Product_Name__c,NRR__c,TotalPrice,ServiceDate,ListPrice,CreatedDate,SortOrder,'+
                        'LastModifiedById, PriceBookEntry.Name,PriceBookEntry.ProductCode from OpportunityLineItem where OpportunityId in (';
        for (id oppId : oppMap.keyset()) {
            query += '\'' + oppId + '\',';
        }
        query = query.substring(0, query.length() - 1) + ')';
        system.debug('>> getOpportunityLineItemMap query: ' + query);

        OpportunityLineItem[] oppLineItems = Database.query(query);

        Map<String,OpportunityLineItem> oppLineItemMap = new Map<String,OpportunityLineItem>();
        for (OpportunityLineItem oli : oppLineItems) {
            oppLineItemMap.put(oli.cscfgc__Attribute__c, oli);
        }

        return oppLineItemMap;
    }

    // -----------
    // Get a list of all Product bundle Ids
    public static List<String> getProductBundleIdList(Map<ID,Opportunity> oppMap) {
        List<String> oppBundleIdList = new List<String>();
        // Loop through all the won opportunities
        System.debug('@@@oppMap size is '+oppMap.size());
        for (String key : oppMap.keySet()) {
            // Get a list of all Product bundle Ids
            System.debug('@@@oppMap bundles size='+oppMap.get(key).cscfgc__Product_Bundles__r.size());
            for (cscfgc__Product_Bundle__c bundle : oppMap.get(key).cscfgc__Product_Bundles__r) {
                oppBundleIdList.add(bundle.Id);
            }
        }

        System.debug('@@@oppBundleIdList size is '+oppBundleIdList);
        //
        return oppBundleIdList;
    }

    // -----------
    // Get a map of all oportunity IDs keyed by bundle Id
    public static Map<String,Opportunity> getBundleIdOppMap(Map<ID,Opportunity> oppMap) {
        Map<String,Opportunity> oppBundleIdMap = new Map<String,Opportunity>();
        // Loop through all the won opportunities
        for (String key : oppMap.keySet()) {
            // Get a list of all Product bundle Ids
            for (cscfgc__Product_Bundle__c bundle : oppMap.get(key).cscfgc__Product_Bundles__r) {
                oppBundleIdMap.put(bundle.Id,oppMap.get(key));
            }
        }
        //
        return oppBundleIdMap;
    }

    // -----------
    // Get a Map of all the won opportunities and their children
    public static Map<ID,Opportunity> getMapOfWonOpportunities(List<String> wonOppIdList) {
        // Get a Map of the won Opportunities and their corresponding Line Items, and primary contact
        //
        String queryString = null;
        /*
        queryString = 'select '+Utility.getSobjectFields('Opportunity')+', (select '+Utility.getSobjectFields('OpportunityLineItem')+
            ', PriceBookEntry.Name,PriceBookEntry.ProductCode from OpportunityLineItems), (select contactId,IsPrimary,Role from OpportunityContactRoles '+
            ' where IsPrimary = true or Role = \'Technical Buyer\' or Role = \'Billing\'), (select '+Utility.getSobjectFields('cscfgc__Product_Bundle__c')+
            ' from cscfgc__Product_Bundles__r where cscfgc__Synchronised_with_Opportunity__c = True) from Opportunity where ID in '+
            Utility.convertListToString(wonOppIdList);
            */
         queryString = 'select FiscalQuarter,Legal_Approval__c,IsDeleted,Comments12__c,Landlines__c,'+
                        'Assistance_Required_from_Bid_Management__c,Estimated_Qty_Landline__c,Fixed_IT_Services__c,Revenue_Ocotober__c,Net_Annual_Value__c,'+
                        'O2_Unify_Opportunity__c,Contract_Signed_Implementation_Started__c,Comments7__c,MNC_Opportunity_Type__c,Owner_profile__c,'+
                        'MNC_Voice_Lines_Acquisition__c,Landline_Number_Being_Transferred__c,LastModifiedById,Existing_Customer__c,'+
                        'Date_Signed_Contract_Returned__c,Wireless_e_mail_Lines_Acquisitio__c,Credit_Ref_Status__c,Opportunity_Description__c,International__c,'+
                        'Live__c,Referred_Customer_Email__c,Cross_Sell_Opportunities__c,Satisfied_Eliminated_4_Areas_of_Risk__c,Register_Acc_on_OAR__c,'+
                        'Revenue_February__c,Appt_Date__c,CCV_Not_used_comments__c,MNC_Implementation_Date__c,Date_ISF_Sent__c,Advisor_Area__c,'+
                        'Contract_End_Date_Data__c,X3rd_Party_Involvement__c,Referred_Customer_Account_Number__c,Voice_Service_Needed__c,TLC_Appointment_Type__c,'+
                        'No_of_Migratable_Customers__c,Annual_Value__c,Data_Voice_Solution_Type__c,MNC_Opportunity_Description__c,Inclusive_Minutes_Landline_Only__c,'+
                        'SRM_Collaborating__c,iPhone__c,End_To_End_Customer_Experience__c,New_Install_Or_Landline_Transfer__c,'+
                        'Referred_By_SRM__c,O2_Retail_Store_Tel__c,O2_Media_Category__c,Data_Approved__c,MNC_UK_Contract_Value_m__c,Product_Details_Complete__c,'+
                        'Status__c,Fiscal,MNC_Headquarter_Name__c,MNC_Probability_Formula__c,Owner_profile_2__c,SyncedQuoteId,All_COD_s_COR_s_COP_Identified__c,'+
                        'LastActivityDate,Bid_Size_Value__c,M2M_Assistance_Required__c,Description,Type_of_Response_to_Brief__c,MNC_Comments__c,FAF_Uploaded__c,'+
                        'Local_Opportunity_ID__c,Blackberrys__c,Account_Payment_Method__c,Comments6__c,Partner_Sign_off_Contact__c,'+
                        'What_Is_The_Call_To_Action__c,Comments4__c,Qty_Run_Rate__c,Confirmation_Email_Address__c,Other__c,Date_Contract_Sent__c,'+
                        'Minutes_Texts_Share_Needed__c,Comments1__c,Requirements__c,MNC_Start_Date__c,Bid_Capability_To_Deliver__c,Name,Sweet_Spot_Exists__c,'+
                        'Bid_Manager_Comments_Internal__c,Data_Usage__c,ForecastCategoryName,Did_You_Use_CCV_in__c,Lead_Organisation__c,'+
                        'Revenue_March__c,Trial_Associated__c,Bid_Manager_Start_Date__c,Agency_Account__c,Detection_Date__c,'+
                        'Copy_briefed__c,Appt_Time__c,Region__c,Existing_Recurring_Charge__c,Contact_No_of_Referee__c,Revenue_Growth__c,'+
                        'MNCs_Opportunity_ID__c,Comments8__c,Renewal__c,Product_URL__c,Product_Total__c,MNCs_Opportunity_ID_New__c,LeadSource,'+
                        'Your_Business_Contact_No__c,Campaign_Live__c,Comments2__c,Campaign_Type__c,SME_Less_Than_200_Employees__c,Contract_End_Date_Wireless_e_mail__c,'+
                        'Mobile_Value__c,BE_Value_Count__c,Date_Introduction_Email_Sent__c,Collaborating_With__c,QTD_Blackberry__c,Sucess_Rate__c,USB_Modems_Required__c,'+
                        'Recurrent_Charge_Increase_in__c,Mobile_Data__c,OwnerId,X2008_Year_End__c,ARPU__c,USB_Modems__c,CSCAP__PO_Number__c,Secondary_Owner__c,IP_Address__c,'+
                        'Target_Audience__c,Type_of_Deal_Share__c,Bid_Qualification__c,Assistant_Manager_1_Name__c,Length_Of_Contract__c,MNC_Voice_Lines_Retention__c,FiscalYear,'+
                        'Success_Metrics__c,Fixed_Data_Internet__c,Value_Hypothesis_Complete__c,Partner_Sign_off_Date__c,'+
                        'Qty_Closed__c,O2_Media_Product_Detail__c,Priority__c,Core_Business_Ref_No__c,Referred_By_Email__c,Your_Business_Company_Name__c,'+
                        'QTD_Business_Post_Pay__c,Pricebook2Id,Reporting_Delivered__c,MNC_Assistance_Required__c,Probability,No_of_Employees__c,Cause__c,'+
                        'Secondary_Owner_Share__c,Bank_Account_Number__c,Date_Contract_Signed_by_Be__c,Value_Criteria_Ranked_Understood__c,QTD_JUC__c,'+
                        'Fixed_International_Services__c,Bespoke_Requirements__c,MNC_Synergy_Type__c,Date_Training_Complete__c,You_Are_Here__c,Voice_Usage__c,Case_Studies__c,'+
                        'Revenue_October__c,Qty_Decision__c,Approval_Status__c,StageName,Analytics_Briefed__c,QEO_JUC__c,Sales_Type__c,Estimated_Qty__c,'+
                        'MNC_Green_Lights__c,Conference_Calls_Needed__c,Net_Annual_Value_in__c,Broadband__c,Requested_Discount__c,Value_Communicated_Back_To_Customer__c,'+
                        'Our_Solution_Can_Meet_The_Need__c,International_Calls__c,Type,Retention_Grand_Total_in__c,'+
                        'Be_Contract_Uploaded__c,Post_Campaign_Analytics__c,QTD_MBB__c,Close_Month__c,Contract_Number__c,Bid_Product_Set__c,'+
                        'Comments9__c,Brand__c,Control__c,Store_Person_Email__c,Analytics_Delivered__c,Standard_Phones__c,Larger_Media_Mix__c,When_are_Budgets_Determined__c,'+
                        'Bid_Manager__c,Calculated_Contribution__c,What_Is_The_Offer__c,Contract_End_Date_VOICE__c,Conversion_rate_James_Allen__c,Revenue_January__c,'+
                        'Originating_BE_Opportunity_ID__c,Email_Internet_Needed__c,Account_Details_Confirmed__c,Comments5__c,Website__c,Controllable_Contribution__c,'+
                        'MNC_Collaboration_with_Telecom_Italia__c,O2_Media__c,MNC_Probability__c,Qty_Assessment_of_Alternatives__c,Cost_Per_Response__c,Referral_Relationship__c,'+
                        'HasOpportunityLineItem,DMU_Name__c,Retail_or_Franchise__c,Id,International_Calling_Needed__c,O2_Sector__c,Mobiles__c,Close_Reason__c,ForecastCategory,'+
                        'I_Phone__c,Audience_Insight__c,Corporate_More_Than_200_Employees__c,App_Build__c,O2_Media_Close_Reason__c,What_Is_The_Brief__c,MNC_Countries__c,'+
                        'Product_Count__c,Customer_Interested_In_Fixed_Line__c,Revenue_July__c,Mobile_Website__c,IsWon,Laptops_Required__c,I_O_Received__c,BE_Pro_Count__c,'+
                        'Date_ISF_Returned__c,MNC_Originating_Source__c,Bank_or_Building_Society__c,Bid__c,Qty_Lost__c,Invoiced__c,Channel_Marketing_Funded__c,'+
                        'Palm_Pre_Required__c,Assistant_Manager_2_Name__c,RecordTypeId,Order_Request_Number__c,Draft_Value_Proposal_ROI_Identified__c,Cost_Per_Thousand__c,'+
                        'How_Will_This_Be_Measured__c,MNC_Global_Regional_AM__c,SystemModstamp,Qty_Awareness_of_Needs__c,Approval_Sent__c,MNC_Lead_Country__c,Email__c,'+
                        'Formal_Proposal_Date_del__c,Qty_No_Opportunity__c,What_Worked_What_Didnt__c,Revenue_November__c,Referred_Customer_Busines_Company_Name__c,MNC_Product_Mix__c,'+
                        'CCV_Not_used_reason__c,Revenue_April__c,RFB_Date__c,Referred_By_Name__c,Comments13__c,Existing_re_curring_charge__c,Comments3__c,Data_briefed__c,'+
                        'Date_Welcome_Email_Guide_Sent__c,Bid_Outcome__c,Full_Contract_Value__c,Wireless_e_mail_Lines__c,Retention_Grand_Total__c,'+
                        'Bid_Describe_Existing_Engagement__c,Is_There_A_Mobile_Strategy__c,Need_Uncovered_Created__c,Value_Criteria_Action_Plan_Complete__c,Comments16__c,'+
                        'Implementation_Date__c,TotalOpportunityQuantity,ARD_Sales_Person__c,MNC_Stage__c,SMS__c,No_Of_Connections__c,Opportunity_Prodcut_Total__c,'+
                        'Mobile_Broadband__c,Revenue_May__c,Comments10__c,Comments15__c,Total_No_Customers__c,OGC_Framework_Customer__c,Other_Activities_Additional_Info__c,'+
                        'Amount,Upfront_Billing_O2_Advance_Required__c,Is_This_A_Test__c,MNC_Term__c,O2_Media_Product__c,Enterprise_Booking__c,Actual_Connections__c,'+
                        'MNC_Competitor_or_Existing_Supplier__c,Referred_By_EIN__c,Blackberry__c,Approval_Status_List__c,O2_Media_Budget__c,'+
                        'New_Recurring_Charge__c,Enterprise_Booking_Comment__c,Weighted_FCV_MNC_Full_Contract_Value__c,Other_Special_Requirements__c,'+
                        'Acquisition_Grand_Total_in__c,Implementation_Impact_Date__c,Target_Connections__c,Referred_From_Branch_Code__c,Potential_For_Additional_Budget__c,'+
                        'Contract_End_Date__c,COF_Uploaded__c,CampaignId,Your_Referring_Customers_Name__c,MNC_Opportunity_Current_Status__c,'+
                        'Landline__c,I_O_Number__c,Qty_Achievement_of_Results__c,Max_Budget__c,Revenue_August__c,Qty_Won__c,What_Are_The_Objectives__c,'+
                        'LastModifiedDate,Manager_Name__c,Internal_Calls__c,Which_CCV_Tool_Added_Most_Value__c,Phase__c,Not_Recurring_Charge__c,Parent_Brand__c,AccountId,'+
                        'Implemented__c,I_O_Confirmed__c,Close_Month_Date_Changed__c,Annual_Value_in__c,Branch_Manager_EIN__c,Key_Competitor__c,Qty_Alleviation_of_Risk__c,'+
                        'Split_End_Date__c,TLC_Reference__c,Amount_12__c,Mobile_Landline_Needed__c,Rep_Code_SOS_Code__c,Referred_Customer_O2_Business_No__c,'+
                        'Credit_Ref_Date__c,Data_Voice_Lines_Acquisition__c,Bespoke_Requirements_Justification__c,New_to_O2__c,CreatedById,Delivery__c,'+
                        'Primary_Owner_Share__c,Close_Comment__c,Order_To_Be_Replaced__c,Partner_Referral_Account__c,Revenue_Growth_in__c,MNC_Red_Lights__c,'+
                        'Approved_Discount__c,Wireless_e_mail_Solution_Type__c,Not_Recurring_Charge_in__c,Re_current_charge_increase__c,CloseDate,Status_Detail__c,'+
                        'Bank_Account_Name__c,CreatedDate,BE_Unlimited_Count__c,Acquisition_Grand_Total__c,MNC_Account_Type__c,Length_of_Contract_value__c,CBM__c,'+
                        'Response_To_Brief__c,Data_Only__c,Retail_Area_No__c,MNC_Full_Contract_Value_Inc_UK_in__c,'+
                        'Data_Lines_Acquisition__c,Revenue_September__c,In_Office_Calls__c,PO_Received__c,Terms_and_Conditions_Agreement__c,Revenue_December__c,'+
                        'New_Recurring_Charge_in__c,Weighted_FCV__c,Revenue_June__c,Data_Lines_Retention__c,Cost_Per_Message__c,Formal_Proposal_Date__c,Incumbent__c,'+
                        'Existing_Recurring_Charge_in__c,Validated_Value_Proposal_Agreed_by_COP__c,QEO_Post_Pay__c,Wireless_e_mail__c,Mobile_Email_Support_Needed__c,'+
                        'Full_Contract_Value_in__c,No_of_phone_connections_sme__c,XDA__c,Landline_Services_Needed__c,Value_Map_Created__c,Campaign_End_Date__c,'+
                        'Use_of_CCV__c,Fixed_Voice__c,SRM_Leading__c,Budget__c,QTD_Disconnections__c,CSCAP__Authoriser_Email_Address__c,Bank_Sort_Code__c,'+
                        'Click_Approve_Stamp__c,Bid_Work_Type__c,O2_Media_Sub_Category__c,Discount__c,COR_COD_Receptive_to_approach__c,QEO_MBB__c,'+
                        'Alleviation_of_Risk_Complete__c,Appt_Description__c,Date_Bid_Management_Support_Required__c,'+
                        'Be_Contract_End_Date__c,Credit_Ref_Number__c,Off_Site_Calls__c,Partner_Type__c,Current_Spend__c,Date_Portal_Setup__c,QEO_Blackberry__c,'+
                        'Global_Opportunity_Name__c,Interactive_Team_Assistance_Required__c,Bid_Outline_Competitor_Threats__c,Upgrade_FOC_Landline_Only__c,IsClosed,'+
                        'MMS__c,NextStep,Agency_Group_Account__c,Bid_Outline_Buying_Criteria__c,Responded_to_Brief__c,Online_Order_Confirmed__c,'+
                        'Comments14__c,Campaign_Start_Date__c,Comments11__c,Assigned_to__c,Account_wide_Ethernet_Discount__c,Data_Solution_Type__c,Migration__c,Bid_Type__c,'+
                        'Simplicity_Required__c,Bid_Submission_Date__c,Data_Voice_Lines_Retention__c,Data_Plan_Needed__c,Customer_Services_Briefed__c,CSCAP__VAT_Number__c,'+
                        'QEO_Disconnections__c,I_O_Complete__c,Operator_Consecutive__c, RecordType.Name, Unify_Solution__c, (select PricebookEntryId,'+
                        'CreatedById,LastModifiedDate,'+
                        'Id,UnitPrice,Description,MRR__c,IsDeleted,Quantity,cscfgc__Attribute__c,'+
                        'OpportunityId,SystemModstamp,Product_Name__c,NRR__c,TotalPrice,ServiceDate,ListPrice,CreatedDate,'+
                        'SortOrder,LastModifiedById, PriceBookEntry.Name,PriceBookEntry.ProductCode from OpportunityLineItems), '+
                        '(select contactId,IsPrimary,Role from OpportunityContactRoles  where IsPrimary = true or Role = \'Technical Buyer\' or Role = \'Billing\'), '+
                        '(select Unify_Commercial_Approved__c, cscfgc__Synchronised_with_Opportunity__c,cscfgc__Total_Price__c,cscfgc__Shared_Context_Configuration__c,CreatedDate,cscfgc__Bundle_Status__c,'+
                        'CreatedById,LastModifiedDate,Id,IsDeleted,Name,cscfgc__Opportunity__c,SystemModstamp,LastModifiedById from cscfgc__Product_Bundles__r '+
                        'where cscfgc__Synchronised_with_Opportunity__c = True) from Opportunity where ID in '+
                        Utility.convertListToString(wonOppIdList);
        //
        List<Opportunity> OppList = Database.query(queryString);
        Map <ID,Opportunity> wonOppMap = new Map <ID,Opportunity> ();
        for (Opportunity opp : OppList) {
            wonOppMap.put(opp.Id,opp);
        }
        return wonOppMap;
    }
//@future
    public static Set<Id> linkOrderGroupToSites(Set<Id> orderGroupId){
        List<Order_Group__c> orderGroupList = [Select Id,
                (Select Id, Unify_Site__c
                from Orders__r),
                (Select Id, Site__c
                from Unify_Order_Group_Sites__r)
            from Order_Group__c
            where Id IN :orderGroupId];
        List<Unify_Order_Group_Site__c> orderGroupSitesToInsert = new List<Unify_Order_Group_Site__c>();
        Set<Unify_Site__c> sitesToUpdate = new Set<Unify_Site__c>();
        Set<Id> allSiteIds = new Set<Id>();
        for(Order_Group__c orderGroup : orderGroupList){
            Set<Id> siteIds = new Set<Id>();
            for(Order__c order : orderGroup.Orders__r){
                siteIds.add(order.Unify_Site__c);
                allSiteIds.add(order.Unify_Site__c);
                sitesToUpdate.add(new Unify_Site__c(Id = order.Unify_Site__c, Order_Group__c = orderGroup.Id));
            }
            for(Id idik : siteIds){
                boolean relationExists = false;
                for(Unify_Order_Group_Site__c ogs : orderGroup.Unify_Order_Group_Sites__r){
                    if(ogs.Site__c == idik){
                        relationExists = true;
                        break;
                    }
                }
                if(!relationExists){
                    orderGroupSitesToInsert.add(new Unify_Order_Group_Site__c(Order_Group__c = orderGroup.Id, Site__c = idik));
                }
            }
        }
        List<Unify_Site__c> sites = new List<Unify_Site__c>();
        sites.addAll(sitesToUpdate);
        if(sites.size() > 0){
            update sites;
        }
        if(orderGroupSitesToInsert.size() > 0){
            insert orderGroupSitesToInsert;
        }

        return allSiteIds;
    }
    // -----------
    // Get a Map of all the won opportunities and their children
    public static List<Opportunity> getListOfWonOpportunities(List<String> wonOppIdList) {
        // Get a Map of the won Opportunities and their corresponding Line Items, and primary contact
        //
        String queryString = null;
        /*
        queryString = 'select '+Utility.getSobjectFields('Opportunity')+', (select '+Utility.getSobjectFields('OpportunityLineItem')+
            ', PriceBookEntry.Name,PriceBookEntry.ProductCode from OpportunityLineItems), (select contactId,IsPrimary,Role from OpportunityContactRoles '+
            ' where IsPrimary = true or Role = \'Technical Buyer\' or Role = \'Billing\'), (select '+Utility.getSobjectFields('cscfgc__Product_Bundle__c')+
            ' from cscfgc__Product_Bundles__r where cscfgc__Synchronised_with_Opportunity__c = True) from Opportunity where ID in '+
            Utility.convertListToString(wonOppIdList);
            */
         queryString = 'select FiscalQuarter,Legal_Approval__c,IsDeleted,Comments12__c,Landlines__c,'+
                        'Assistance_Required_from_Bid_Management__c,Estimated_Qty_Landline__c,Fixed_IT_Services__c,Revenue_Ocotober__c,Net_Annual_Value__c,'+
                        'O2_Unify_Opportunity__c,Contract_Signed_Implementation_Started__c,Comments7__c,MNC_Opportunity_Type__c,Owner_profile__c,'+
                        'MNC_Voice_Lines_Acquisition__c,Landline_Number_Being_Transferred__c,LastModifiedById,Existing_Customer__c,'+
                        'Date_Signed_Contract_Returned__c,Wireless_e_mail_Lines_Acquisitio__c,Credit_Ref_Status__c,Opportunity_Description__c,International__c,'+
                        'Live__c,Referred_Customer_Email__c,Cross_Sell_Opportunities__c,Satisfied_Eliminated_4_Areas_of_Risk__c,Register_Acc_on_OAR__c,'+
                        'Revenue_February__c,Appt_Date__c,CCV_Not_used_comments__c,MNC_Implementation_Date__c,Date_ISF_Sent__c,Advisor_Area__c,'+
                        'Contract_End_Date_Data__c,X3rd_Party_Involvement__c,Referred_Customer_Account_Number__c,Voice_Service_Needed__c,TLC_Appointment_Type__c,'+
                        'No_of_Migratable_Customers__c,Annual_Value__c,Data_Voice_Solution_Type__c,MNC_Opportunity_Description__c,Inclusive_Minutes_Landline_Only__c,'+
                        'SRM_Collaborating__c,iPhone__c,End_To_End_Customer_Experience__c,New_Install_Or_Landline_Transfer__c,'+
                        'Referred_By_SRM__c,O2_Retail_Store_Tel__c,O2_Media_Category__c,Data_Approved__c,MNC_UK_Contract_Value_m__c,Product_Details_Complete__c,'+
                        'Status__c,Fiscal,MNC_Headquarter_Name__c,MNC_Probability_Formula__c,Owner_profile_2__c,SyncedQuoteId,All_COD_s_COR_s_COP_Identified__c,'+
                        'LastActivityDate,Bid_Size_Value__c,M2M_Assistance_Required__c,Description,Type_of_Response_to_Brief__c,MNC_Comments__c,FAF_Uploaded__c,'+
                        'Local_Opportunity_ID__c,Blackberrys__c,Account_Payment_Method__c,Comments6__c,Partner_Sign_off_Contact__c,'+
                        'What_Is_The_Call_To_Action__c,Comments4__c,Qty_Run_Rate__c,Confirmation_Email_Address__c,Other__c,Date_Contract_Sent__c,'+
                        'Minutes_Texts_Share_Needed__c,Comments1__c,Requirements__c,MNC_Start_Date__c,Bid_Capability_To_Deliver__c,Name,Sweet_Spot_Exists__c,'+
                        'Bid_Manager_Comments_Internal__c,Data_Usage__c,ForecastCategoryName,Did_You_Use_CCV_in__c,Lead_Organisation__c,'+
                        'Revenue_March__c,Trial_Associated__c,Bid_Manager_Start_Date__c,Agency_Account__c,Detection_Date__c,'+
                        'Copy_briefed__c,Appt_Time__c,Region__c,Existing_Recurring_Charge__c,Contact_No_of_Referee__c,Revenue_Growth__c,'+
                        'MNCs_Opportunity_ID__c,Comments8__c,Renewal__c,Product_URL__c,Product_Total__c,MNCs_Opportunity_ID_New__c,LeadSource,'+
                        'Your_Business_Contact_No__c,Campaign_Live__c,Comments2__c,Campaign_Type__c,SME_Less_Than_200_Employees__c,Contract_End_Date_Wireless_e_mail__c,'+
                        'Mobile_Value__c,BE_Value_Count__c,Date_Introduction_Email_Sent__c,Collaborating_With__c,QTD_Blackberry__c,Sucess_Rate__c,USB_Modems_Required__c,'+
                        'Recurrent_Charge_Increase_in__c,Mobile_Data__c,OwnerId,X2008_Year_End__c,ARPU__c,USB_Modems__c,CSCAP__PO_Number__c,Secondary_Owner__c,IP_Address__c,'+
                        'Target_Audience__c,Type_of_Deal_Share__c,Bid_Qualification__c,Assistant_Manager_1_Name__c,Length_Of_Contract__c,MNC_Voice_Lines_Retention__c,FiscalYear,'+
                        'Success_Metrics__c,Fixed_Data_Internet__c,Value_Hypothesis_Complete__c,Partner_Sign_off_Date__c,'+
                        'Qty_Closed__c,O2_Media_Product_Detail__c,Priority__c,Core_Business_Ref_No__c,Referred_By_Email__c,Your_Business_Company_Name__c,'+
                        'QTD_Business_Post_Pay__c,Pricebook2Id,Reporting_Delivered__c,MNC_Assistance_Required__c,Probability,No_of_Employees__c,Cause__c,'+
                        'Secondary_Owner_Share__c,Bank_Account_Number__c,Date_Contract_Signed_by_Be__c,Value_Criteria_Ranked_Understood__c,QTD_JUC__c, UNIFY_Opportunity_Size__c,'+
                        'Fixed_International_Services__c,Bespoke_Requirements__c,MNC_Synergy_Type__c,Date_Training_Complete__c,You_Are_Here__c,Voice_Usage__c,Case_Studies__c,'+
                        'Revenue_October__c,Qty_Decision__c,Approval_Status__c,StageName,Analytics_Briefed__c,QEO_JUC__c,Sales_Type__c,Estimated_Qty__c,'+
                        'MNC_Green_Lights__c,Conference_Calls_Needed__c,Net_Annual_Value_in__c,Broadband__c,Requested_Discount__c,Value_Communicated_Back_To_Customer__c,'+
                        'Our_Solution_Can_Meet_The_Need__c,International_Calls__c,Type,Retention_Grand_Total_in__c,'+
                        'Be_Contract_Uploaded__c,Post_Campaign_Analytics__c,QTD_MBB__c,Close_Month__c,Contract_Number__c,Bid_Product_Set__c,'+
                        'Comments9__c,Brand__c,Control__c,Store_Person_Email__c,Analytics_Delivered__c,Standard_Phones__c,Larger_Media_Mix__c,When_are_Budgets_Determined__c,'+
                        'Bid_Manager__c,Calculated_Contribution__c,What_Is_The_Offer__c,Contract_End_Date_VOICE__c,Conversion_rate_James_Allen__c,Revenue_January__c,'+
                        'Originating_BE_Opportunity_ID__c,Email_Internet_Needed__c,Account_Details_Confirmed__c,Comments5__c,Website__c,Controllable_Contribution__c,'+
                        'MNC_Collaboration_with_Telecom_Italia__c,O2_Media__c,MNC_Probability__c,Qty_Assessment_of_Alternatives__c,Cost_Per_Response__c,Referral_Relationship__c,'+
                        'HasOpportunityLineItem,DMU_Name__c,Retail_or_Franchise__c,Id,International_Calling_Needed__c,O2_Sector__c,Mobiles__c,Close_Reason__c,ForecastCategory,'+
                        'I_Phone__c,Audience_Insight__c,Corporate_More_Than_200_Employees__c,App_Build__c,O2_Media_Close_Reason__c,What_Is_The_Brief__c,MNC_Countries__c,'+
                        'Product_Count__c,Customer_Interested_In_Fixed_Line__c,Revenue_July__c,Mobile_Website__c,IsWon,Laptops_Required__c,I_O_Received__c,BE_Pro_Count__c,'+
                        'Date_ISF_Returned__c,MNC_Originating_Source__c,Bank_or_Building_Society__c,Bid__c,Qty_Lost__c,Invoiced__c,Channel_Marketing_Funded__c,'+
                        'Palm_Pre_Required__c,Assistant_Manager_2_Name__c,RecordTypeId,Order_Request_Number__c,Draft_Value_Proposal_ROI_Identified__c,Cost_Per_Thousand__c,'+
                        'How_Will_This_Be_Measured__c,MNC_Global_Regional_AM__c,SystemModstamp,Qty_Awareness_of_Needs__c,Approval_Sent__c,MNC_Lead_Country__c,Email__c,'+
                        'Formal_Proposal_Date_del__c,Qty_No_Opportunity__c,What_Worked_What_Didnt__c,Revenue_November__c,Referred_Customer_Busines_Company_Name__c,MNC_Product_Mix__c,'+
                        'CCV_Not_used_reason__c,Revenue_April__c,RFB_Date__c,Referred_By_Name__c,Comments13__c,Existing_re_curring_charge__c,Comments3__c,Data_briefed__c,'+
                        'Date_Welcome_Email_Guide_Sent__c,Bid_Outcome__c,Full_Contract_Value__c,Wireless_e_mail_Lines__c,Retention_Grand_Total__c,'+
                        'Bid_Describe_Existing_Engagement__c,Is_There_A_Mobile_Strategy__c,Need_Uncovered_Created__c,Value_Criteria_Action_Plan_Complete__c,Comments16__c,'+
                        'Implementation_Date__c,TotalOpportunityQuantity,ARD_Sales_Person__c,MNC_Stage__c,SMS__c,No_Of_Connections__c,Opportunity_Prodcut_Total__c,'+
                        'Mobile_Broadband__c,Revenue_May__c,Comments10__c,Comments15__c,Total_No_Customers__c,OGC_Framework_Customer__c,Other_Activities_Additional_Info__c,'+
                        'Amount,Upfront_Billing_O2_Advance_Required__c,Is_This_A_Test__c,MNC_Term__c,O2_Media_Product__c,Enterprise_Booking__c,Actual_Connections__c,'+
                        'MNC_Competitor_or_Existing_Supplier__c,Referred_By_EIN__c,Blackberry__c,Approval_Status_List__c,O2_Media_Budget__c,'+
                        'New_Recurring_Charge__c,Enterprise_Booking_Comment__c,Weighted_FCV_MNC_Full_Contract_Value__c,Other_Special_Requirements__c,'+
                        'Acquisition_Grand_Total_in__c,Implementation_Impact_Date__c,Target_Connections__c,Referred_From_Branch_Code__c,Potential_For_Additional_Budget__c,'+
                        'Contract_End_Date__c,COF_Uploaded__c,CampaignId,Your_Referring_Customers_Name__c,MNC_Opportunity_Current_Status__c,'+
                        'Landline__c,I_O_Number__c,Qty_Achievement_of_Results__c,Max_Budget__c,Revenue_August__c,Qty_Won__c,What_Are_The_Objectives__c,'+
                        'LastModifiedDate,Manager_Name__c,Internal_Calls__c,Which_CCV_Tool_Added_Most_Value__c,Phase__c,Not_Recurring_Charge__c,Parent_Brand__c,AccountId,'+
                        'Implemented__c,I_O_Confirmed__c,Close_Month_Date_Changed__c,Annual_Value_in__c,Branch_Manager_EIN__c,Key_Competitor__c,Qty_Alleviation_of_Risk__c,'+
                        'Split_End_Date__c,TLC_Reference__c,Amount_12__c,Mobile_Landline_Needed__c,Rep_Code_SOS_Code__c,Referred_Customer_O2_Business_No__c,'+
                        'Credit_Ref_Date__c,Data_Voice_Lines_Acquisition__c,Bespoke_Requirements_Justification__c,New_to_O2__c,CreatedById,Delivery__c,'+
                        'Primary_Owner_Share__c,Close_Comment__c,Order_To_Be_Replaced__c,Partner_Referral_Account__c,Revenue_Growth_in__c,MNC_Red_Lights__c,'+
                        'Approved_Discount__c,Wireless_e_mail_Solution_Type__c,Not_Recurring_Charge_in__c,Re_current_charge_increase__c,CloseDate,Status_Detail__c,'+
                        'Bank_Account_Name__c,CreatedDate,BE_Unlimited_Count__c,Acquisition_Grand_Total__c,MNC_Account_Type__c,Length_of_Contract_value__c,CBM__c,'+
                        'Response_To_Brief__c,Data_Only__c,Retail_Area_No__c,MNC_Full_Contract_Value_Inc_UK_in__c,'+
                        'Data_Lines_Acquisition__c,Revenue_September__c,In_Office_Calls__c,PO_Received__c,Terms_and_Conditions_Agreement__c,Revenue_December__c,'+
                        'New_Recurring_Charge_in__c,Weighted_FCV__c,Revenue_June__c,Data_Lines_Retention__c,Cost_Per_Message__c,Formal_Proposal_Date__c,Incumbent__c,'+
                        'Existing_Recurring_Charge_in__c,Validated_Value_Proposal_Agreed_by_COP__c,QEO_Post_Pay__c,Wireless_e_mail__c,Mobile_Email_Support_Needed__c,'+
                        'Full_Contract_Value_in__c,No_of_phone_connections_sme__c,XDA__c,Landline_Services_Needed__c,Value_Map_Created__c,Campaign_End_Date__c,'+
                        'Use_of_CCV__c,Fixed_Voice__c,SRM_Leading__c,Budget__c,QTD_Disconnections__c,CSCAP__Authoriser_Email_Address__c,Bank_Sort_Code__c,'+
                        'Click_Approve_Stamp__c,Bid_Work_Type__c,O2_Media_Sub_Category__c,Discount__c,COR_COD_Receptive_to_approach__c,QEO_MBB__c,'+
                        'Alleviation_of_Risk_Complete__c,Appt_Description__c,Date_Bid_Management_Support_Required__c,'+
                        'Be_Contract_End_Date__c,Credit_Ref_Number__c,Off_Site_Calls__c,Partner_Type__c,Current_Spend__c,Date_Portal_Setup__c,QEO_Blackberry__c,'+
                        'Global_Opportunity_Name__c,Interactive_Team_Assistance_Required__c,Bid_Outline_Competitor_Threats__c,Upgrade_FOC_Landline_Only__c,IsClosed,'+
                        'MMS__c,NextStep,Agency_Group_Account__c,Bid_Outline_Buying_Criteria__c,Responded_to_Brief__c,Online_Order_Confirmed__c,'+
                        'Comments14__c,Campaign_Start_Date__c,Comments11__c,Assigned_to__c,Account_wide_Ethernet_Discount__c,Data_Solution_Type__c,Migration__c,Bid_Type__c,'+
                        'Simplicity_Required__c,Bid_Submission_Date__c,Data_Voice_Lines_Retention__c,Data_Plan_Needed__c,Customer_Services_Briefed__c,CSCAP__VAT_Number__c,'+
                        'QEO_Disconnections__c,I_O_Complete__c,Operator_Consecutive__c, Unify_Solution__c, RecordType.Name ,(select PricebookEntryId,'+
                        'CreatedById,LastModifiedDate,'+
                        'Id,UnitPrice,Description,MRR__c,IsDeleted,Quantity,cscfgc__Attribute__c,'+
                        'OpportunityId,SystemModstamp,Product_Name__c,NRR__c,TotalPrice,ServiceDate,ListPrice,CreatedDate,'+
                        'SortOrder,LastModifiedById, PriceBookEntry.Name,PriceBookEntry.ProductCode from OpportunityLineItems), '+
                        '(select contactId,IsPrimary,Role from OpportunityContactRoles  where IsPrimary = true or Role = \'Technical Buyer\' or Role = \'Billing\'), '+
                        '(select Unify_Commercial_Approved__c, cscfgc__Synchronised_with_Opportunity__c,cscfgc__Total_Price__c,cscfgc__Shared_Context_Configuration__c,CreatedDate,cscfgc__Bundle_Status__c,'+
                        'CreatedById,LastModifiedDate,Id,IsDeleted,Name,cscfgc__Opportunity__c,SystemModstamp,LastModifiedById from cscfgc__Product_Bundles__r '+
                        'where cscfgc__Synchronised_with_Opportunity__c = True) from Opportunity where ID in '+
                        Utility.convertListToString(wonOppIdList);
        //
        system.debug('**********>>>getListOfWonOpportunities - queryString:'+queryString);
        //
        List<Opportunity> oppList = new List<Opportunity>();
        if (!wonOppIdList.isEmpty())
            oppList = Database.query(queryString);
        return oppList;
    }

    // -----------
    // Convert date string to date
    public static Date stringToDate(String s){
        if (s != null) {
          //Date String is in the format dd/mm/yyyy
          String[] stringDate = s.split('/');
          if (stringDate.size() == 3) {
            Integer d =  Integer.valueOf(stringDate[0]);
            Integer m = Integer.valueOf(stringDate[1]);
            Integer y = Integer.valueOf(stringDate[2]);
            // Correct a problem introduced by webcom sending back 2 digit years
            if (y < 2000) y += 2000;
            return date.newInstance(y,m,d);
          } else {
            return null;
          }
        } else {
            return null;
        }
    }
}