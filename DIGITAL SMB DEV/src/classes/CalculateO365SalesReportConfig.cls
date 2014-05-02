global class CalculateO365SalesReportConfig implements Database.Batchable<SObject>,Schedulable, Database.Stateful 
{
    public string mainsqlquery='';
    map<string,string> mapAttributeField = new map<string,string>();
    
    
    public CalculateO365SalesReportConfig()
    {
        mainsqlquery='select Id, cscfgc__Product_Bundle__c, cscfgc__Product_Bundle__r.cscfgc__Opportunity__c, cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name, cscfgc__Product_Definition__r.cscfgc__Product_Category__c from cscfgc__Product_Configuration__c';
        mainsqlquery+=' where cscfgc__Product_Definition__r.Name LIKE \'Office 365%\' and cscfgc__Product_Bundle__r.cscfgc__Opportunity__c!=null';
        //mainsqlquery+=' and cscfgc__Product_Bundle__r.cscfgc__Opportunity__c=\'006W0000004OYejIAG\'';
        //multiple attributes from "blank", 2...10
        mapAttributeField.put('Number of Seats','Quantity__c');
        mapAttributeField.put('Number of Seats 2','Quantity__c');
        mapAttributeField.put('Number of Seats 3','Quantity__c');
        mapAttributeField.put('Number of Seats 4','Quantity__c');
        mapAttributeField.put('Number of Seats 5','Quantity__c');
        mapAttributeField.put('Number of Seats 6','Quantity__c');
        mapAttributeField.put('Number of Seats 7','Quantity__c');
        mapAttributeField.put('Number of Seats 8','Quantity__c');
        mapAttributeField.put('Number of Seats 9','Quantity__c');
        mapAttributeField.put('Number of Seats 10','Quantity__c');
        
        mapAttributeField.put('Display Name','Display_Name__c');
        mapAttributeField.put('Display Name 2','Display_Name__c');
        mapAttributeField.put('Display Name 3','Display_Name__c');
        mapAttributeField.put('Display Name 4','Display_Name__c');
        mapAttributeField.put('Display Name 5','Display_Name__c');
        mapAttributeField.put('Display Name 6','Display_Name__c');
        mapAttributeField.put('Display Name 7','Display_Name__c');
        mapAttributeField.put('Display Name 8','Display_Name__c');
        mapAttributeField.put('Display Name 9','Display_Name__c');
        mapAttributeField.put('Display Name 10','Display_Name__c');
        
        //singular attributes
        mapAttributeField.put('POA Account ID','POA_Account_ID__c');
        mapAttributeField.put('DISE Account Number','DISE_Account_Number__c');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('***mainsqlquery=' + mainsqlquery);
        return Database.getQueryLocator(mainsqlquery);  

    }
    
    
    global void execute(Database.BatchableContext BC, List<SObject> lstsObjectProductConfiguration)
    {
        
        set<string> setOppId = new set<string>();
        set<string> setPCId = new set<string>();
        set<string> setProductCategoryId = new set<string>();
        
        map<string,map<string,cscfgc__Product_Configuration__c>> mapOppIdmapPC = new map<string,map<string,cscfgc__Product_Configuration__c>>(); 
        
        for(SObject s : lstsObjectProductConfiguration)
        {
            cscfgc__Product_Configuration__c PC = (cscfgc__Product_Configuration__c) s;
            setOppId.add(PC.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c);
            setPCId.add(PC.Id);
            setProductCategoryId.add(PC.cscfgc__Product_Definition__r.cscfgc__Product_Category__c);
            
            if (mapOppIdmapPC.containsKey(PC.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c))
            {
                map<string,cscfgc__Product_Configuration__c> mapPC = mapOppIdmapPC.get(PC.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c);
                if (!mapPC.containsKey(PC.Id))
                {
                    mapPC.put(PC.Id,PC);
                }
            }
            else
            { 
                map<string,cscfgc__Product_Configuration__c> mapPC = new map<string,cscfgc__Product_Configuration__c>();
                mapPC.put(PC.Id,PC);
                mapOppIdmapPC.put(PC.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c,mapPC);
            }
        }
        
        map<Id,cscfgc__Product_Category__c> mapProductCategory = new map<Id,cscfgc__Product_Category__c>([select Id, Name 
            from cscfgc__Product_Category__c where Id in : setProductCategoryId]);
        
        map<Id,Order__c> mapOrder = new map<Id,Order__c>([select Id, Opportunity__c,Product_Configuration__c from Order__c
            where Opportunity__c in : setOppId]);
        
        map<Id,Order_Line_Item__c> mapOrderLineItem = new map<Id,Order_Line_Item__c>([select Id,Order__c, Order__r.Opportunity__c, Attribute__c, 
            Attribute__r.cscfgc__Product_Configuration__c
            from Order_Line_Item__c
            where Order__r.Opportunity__c in : setOppId]);
    
        List<cscfgc__Attribute__c> lstAttribute = [select cscfgc__Display_Value__c, cscfgc__Value__c, Id, 
            Name, cscfgc__Product_Configuration__c 
            from cscfgc__Attribute__c 
            where Name in : mapAttributeField.keySet() and cscfgc__Product_Configuration__c in : setPCId]; 
    
        map<Id,Opportunity> mapOpportunity = new map<Id,Opportunity>([select Id,AccountId from Opportunity where Id in : setOppId]); 
        
        
        map<string,Order__c> mapPCIdOrder = new map<string,Order__c>();
        
        for (Order__c tmpOrder : mapOrder.values())
        {
            if (!mapPCIdOrder.containsKey(tmpOrder.Product_Configuration__c))
            {
                mapPCIdOrder.put(tmpOrder.Product_Configuration__c,tmpOrder);
            }
        }
        
        
        map<string,List<Order_Line_Item__c>> mapOrderIdlstOrderLineItem = new map<string,List<Order_Line_Item__c>>();
        map<string,string> mapAttributeIdOrderLineId = new map<string,string>(); 
                
        for (Order_Line_Item__c tmpOrderLineItem : mapOrderLineItem.values())
        {
            if (mapOrderIdlstOrderLineItem.containsKey(tmpOrderLineItem.Order__c))
            {
                List<Order_Line_Item__c> lstOrderLineItem=mapOrderIdlstOrderLineItem.get(tmpOrderLineItem.Order__c);
                lstOrderLineItem.add(tmpOrderLineItem);
            }
            else
            {
                List<Order_Line_Item__c> lstOrderLineItem=new List<Order_Line_Item__c>();
                lstOrderLineItem.add(tmpOrderLineItem);
                mapOrderIdlstOrderLineItem.put(tmpOrderLineItem.Order__c,lstOrderLineItem);
            }
                        
            if (!mapAttributeIdOrderLineId.containsKey(tmpOrderLineItem.Attribute__c))
            {
                mapAttributeIdOrderLineId.put(tmpOrderLineItem.Attribute__c,tmpOrderLineItem.Id);
            }                                   
        }
        
        
        map<string,map<string,cscfgc__Attribute__c>> mapPCIdmapAttributes = new map<string,map<string,cscfgc__Attribute__c>>();
        
        for (cscfgc__Attribute__c tmpAttribute : lstAttribute)
        {
            string PCId=tmpAttribute.cscfgc__Product_Configuration__c;
            if (mapPCIdmapAttributes.containsKey(PCId))
            {
                map<string,cscfgc__Attribute__c> mapAttributes = mapPCIdmapAttributes.get(PCId);
                if (!mapAttributes.containsKey(tmpAttribute.Name))
                {
                    mapAttributes.put(tmpAttribute.Name,tmpAttribute);
                }
            }
            else
            {
                map<string,cscfgc__Attribute__c> mapAttributes = new map<string,cscfgc__Attribute__c>();
                mapAttributes.put(tmpAttribute.Name,tmpAttribute);
                mapPCIdmapAttributes.put(PCId,mapAttributes);
            }
        }
        
        
        system.debug('***setOppId=' + setOppId);
        system.debug('***mapOpportunity=' + mapOpportunity);
        system.debug('***mapOppIdmapPC=' + mapOppIdmapPC);
        
        boolean Pass;
        string NumberOfSeatsName;
        string DisplayName;     
        
        list<Sales_Report_O365__c> lstSalesReport = new list<Sales_Report_O365__c>();
        
        for (Opportunity tmpOpportunity : mapOpportunity.values())
        {
            if (mapOppIdmapPC.containsKey(tmpOpportunity.Id))
            {
                map<string,cscfgc__Product_Configuration__c> mapPC = mapOppIdmapPC.get(tmpOpportunity.Id);
                for (cscfgc__Product_Configuration__c tmpPC : mapPC.values())
                {
                    if (mapPCIdmapAttributes.containsKey(tmpPC.Id))
                    {
                        map<string,cscfgc__Attribute__c> mapAttributes = mapPCIdmapAttributes.get(tmpPC.Id);
                    
                        for (integer i=1;i<=10;i++)
                        {
                            Pass=false;
                            if (i==1)
                            {
                                NumberOfSeatsName='Number of Seats';
                                DisplayName='Display Name';                         
                            }                   
                            else
                            {
                                NumberOfSeatsName='Number of Seats' + ' ' + string.valueof(i);
                                DisplayName='Display Name' + ' ' + string.valueof(i);
                            }    
                            
                            if (mapAttributes.containsKey(NumberOfSeatsName))
                                if (!string.isblank(mapAttributes.get(NumberOfSeatsName).cscfgc__Value__c))
                                    if (mapAttributes.get(NumberOfSeatsName).cscfgc__Value__c.isNumeric()) Pass=true;
                            
                            string AttributeDisplayNameId;
                        
                            if (Pass)
                            {
                                Sales_Report_O365__c tmpSalesReport = new Sales_Report_O365__c();
                                tmpSalesReport.Account__c=tmpOpportunity.AccountId;
                                tmpSalesReport.Opportunity__c=tmpOpportunity.Id;
                                tmpSalesReport.Opportunity_Type__c='Configurator';
                                
                                //map<string,cscfgc__Attribute__c> mapAttribute = mapPCIdmapAttributes.get(tmpPC.Id);
                                if (mapAttributes.containsKey(NumberOfSeatsName))
                                {
                                    if ((mapAttributes.get(NumberOfSeatsName).cscfgc__Value__c!='') && (mapAttributes.get(NumberOfSeatsName).cscfgc__Value__c!=null))
                                    { 
                                        string tmpValue = mapAttributes.get(NumberOfSeatsName).cscfgc__Value__c;
                                        if (tmpValue.isNumeric())
                                            tmpSalesReport.Quantity__c=integer.valueOf(mapAttributes.get(NumberOfSeatsName).cscfgc__Value__c);
                                        else
                                            tmpSalesReport.Quantity__c=0;
                                    }
                                }
                                AttributeDisplayNameId='';
                                if (mapAttributes.containsKey(DisplayName))
                                {
                                    tmpSalesReport.Display_Name__c=mapAttributes.get(DisplayName).cscfgc__Value__c;
                                    AttributeDisplayNameId=mapAttributes.get(DisplayName).Id;
                                }
                                if (mapAttributes.containsKey('POA Account ID'))
                                    tmpSalesReport.POA_Account_Id__c=mapAttributes.get('POA Account ID').cscfgc__Value__c;      
                            
                                if (mapAttributes.containsKey('DISE Account Number')) 
                                    tmpSalesReport.DISE_Account_Number__c=mapAttributes.get('DISE Account Number').cscfgc__Value__c;        
                                
                                                            
                                tmpSalesReport.Product_Definition_Name__c=tmpPC.cscfgc__Product_Definition__r.Name;
                                tmpSalesReport.Product_Category__c=mapProductCategory.get(tmpPC.cscfgc__Product_Definition__r.cscfgc__Product_Category__c).Name;
                                
                                if (mapPCIdOrder.containsKey(tmpPC.Id))
                                {
                                    Order__c tmpOrder = mapPCIdOrder.get(tmpPC.Id);
                                    tmpSalesReport.Order__c=tmpOrder.Id;
                                    /*
                                    if (mapOrderIdlstOrderLineItem.containsKey(tmpOrder.Id))
                                    {
                                        List<Order_Line_Item__c> lstOrderLineItem=mapOrderIdlstOrderLineItem.get(tmpOrder.Id);
                                        if (lstOrderLineItem.size()>0) tmpSalesReport.Order_Line_Item__c=lstOrderLineItem[0].Id;
                                    }
                                    */
                                }
                                
                                if (AttributeDisplayNameId!='')
                                {
                                    tmpSalesReport.Order_Line_Item__c=mapAttributeIdOrderLineId.get(AttributeDisplayNameId);
                                }
                                                            
                                lstSalesReport.add(tmpSalesReport);
                            }
                        }
                        
                    }
                }
            }
            else
            {
                Sales_Report_O365__c tmpSalesReport = new Sales_Report_O365__c();
                tmpSalesReport.Account__c=tmpOpportunity.AccountId;
                tmpSalesReport.Opportunity__c=tmpOpportunity.Id;
                tmpSalesReport.Opportunity_Type__c='Configurator';
                
                lstSalesReport.add(tmpSalesReport);
            }
            
        }
        
        if (lstSalesReport.size()>0) insert lstSalesReport;
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =
        :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {a.CreatedBy.Email};
        //String[] toAddresses = new String[]{};
        //toAddresses.add('davor.dubokovic@cloudsensesolutions.com');

        List<String> toAddresses = new List<String>();
        BatchSize__c BatchSize = BatchSize__c.getInstance(UserInfo.getUserId());

        if (BatchSize==null)
        {
            toAddresses.add('davor.dubokovic@cloudsense.com');
        }
        else
        {
            if (BatchSize.Admin_emails__c=='' || BatchSize.Admin_emails__c==null)
            {
                toAddresses.add('davor.dubokovic@cloudsense.com');
            }
            else
            {
                toAddresses = BatchSize.Admin_emails__c.split(',');
            }
        }


        mail.setToAddresses(toAddresses);
        mail.setSubject('CalculateO365SalesReportConfig - ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }
    
    global void execute(SchedulableContext SC)
    {
        BatchSize__c batchSize = BatchSize__c.getInstance(UserInfo.getUserId());
        integer BatchSizeNo=50;

        if (batchSize!=null) BatchSizeNo=integer.valueOf(batchSize.CalculateO365SalesReportConfig__c);


        CalculateO365SalesReportConfig tmpBatch = new CalculateO365SalesReportConfig();
        database.executebatch(tmpBatch, BatchSizeNo);       
    }
}