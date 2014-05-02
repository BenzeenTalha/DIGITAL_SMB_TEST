@isTest
class OpportunityProductAutomationTests {
    /***********************************************************************************************
     * Author: Sam Wadhwani
     * Company: cDecisions Ltd.
     * Date: 08/04/2011
     * Description: test class to validate and test the O2 Product Detail to OpportunityProduct
     *            (CopyProdDetailToShadow) trigger and the Product Bundle Configuration Attributes
     *            to OpportunityProduct (CopyProdConfigurationToShadow) trigger.
     * Modifications: [ENTER MODS HERE]
     * Colin Kenworthy 13 April 2012 - account NumberOfEmployees and O2_Product_Detail__c.Total_Contract_Value__c
     *                                 now mandatory via Validation Rules
     ***********************************************************************************************/
     
    static TestMethod void testCopyO2ProductDetail() {
        //### RETRIEVE REFERENCE DATA TO BE USED IN THE TESTS ###
        RecordType[] lsOpptyRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity'];
        Map<String, Id> opptyRecTypes = new Map<String, Id>();
        for (RecordType r: lsOpptyRecTypes) {opptyRecTypes.put(r.Name, r.Id);}
        RecordType[] lsAccRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account'];
        Map<String, Id> accRecTypes = new Map<String, Id>();
        for (RecordType r: lsAccRecTypes) {accRecTypes.put(r.Name, r.Id);}
        //### CREATE TEST SALES DATA ###
        //create a test account record
        Account acc = new Account();
        acc.Name = 'APEXTESTACC001';
        acc.RecordTypeId = accRecTypes.get('Customer Account');
        acc.NumberOfEmployees = 1;
        insert acc;
        String strAccId = acc.Id;
        //create a test opportunity record
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = opptyRecTypes.get('Default');
        opp.Name = 'APEXTESTOPPTY001';
        opp.Type = 'New Business';
        opp.AccountId = strAccId;
        opp.StageName = 'Awareness of Needs';
        opp.CloseDate = Date.today()+1;
        opp.LeadSource = 'Self Generated';
        opp.Use_of_CCV__c = 'CCV Not Used';
        opp.CCV_Not_used_reason__c = 'Other';
        opp.CCV_Not_used_comments__c = 'APEXTESTOPPTY001_CCV_NOT_USED_COMMENTS';
        opp.TotalOpportunityQuantity = 10;
        insert opp;
        String strOpptyId = opp.Id;
        //create a test O2 product detail record
        O2_Product_Detail__c prod = new O2_Product_Detail__c();
        prod.Opportunity__c = strOpptyId;
        prod.Product_Category__c = 'Landline & Mobile';
        prod.Product__c = 'Landline';
        prod.Quantity__c = 10;
        prod.Length_of_Contract__c = '12 Months';
        prod.Revenue_per_Month__c = 25;
        prod.Contribution_Against_Product__c = 30;
        prod.Total_Contract_Value__c = 100;
        // start test cases
        Test.StartTest();
            //test O2 Product Detail record insertion
            insert prod;
            String strProdId = prod.Id;
            //create tester record variable
            String strExtId = strOpptyId + '_' + strProdId;
            OpportunityProduct__c[] testOpptyProd;
            //ASSERT: record inserted into shadow object
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Automation_UID__c = :strExtId];
            System.assertEquals(1, testOpptyProd.size());
            //test O2 Product Detail update
            prod.Revenue_per_Month__c = 35;
            update prod;
            //ASSERT: record updated in shadow object
            testOpptyProd = [SELECT Id, Name, Automation_UID__c, MRR__c FROM OpportunityProduct__c WHERE Automation_UID__c = :strExtId];
            System.assertEquals(35, testOpptyProd[0].MRR__c);
            //test O2 Product Detail deletion
            delete prod;
            //ASSERT: record in shadow object also deleted
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Automation_UID__c = :strExtId];
            System.assertEquals(0, testOpptyProd.size());
        Test.StopTest();
    }
    
    static TestMethod void testCopyMultipleO2Products() {
        //### RETRIEVE REFERENCE DATA TO BE USED IN THE TESTS ###
        RecordType[] lsOpptyRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity'];
        Map<String, Id> opptyRecTypes = new Map<String, Id>();
        for (RecordType r: lsOpptyRecTypes) {opptyRecTypes.put(r.Name, r.Id);}
        RecordType[] lsAccRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account'];
        Map<String, Id> accRecTypes = new Map<String, Id>();
        for (RecordType r: lsAccRecTypes) {accRecTypes.put(r.Name, r.Id);}
        //### CREATE TEST SALES DATA ###
        //create a test account record
        Account acc = new Account();
        acc.Name = 'APEXTESTACC002';
        acc.RecordTypeId = accRecTypes.get('Customer Account');
        acc.NumberOfEmployees = 1;
        insert acc;
        String strAccId = acc.Id;
        //create a test opportunity record
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = opptyRecTypes.get('Default');
        opp.Name = 'APEXTESTOPPTY002';
        opp.Type = 'New Business';
        opp.AccountId = strAccId;
        opp.StageName = 'Awareness of Needs';
        opp.CloseDate = Date.today()+1;
        opp.LeadSource = 'Self Generated';
        opp.Use_of_CCV__c = 'CCV Not Used';
        opp.CCV_Not_used_reason__c = 'Other';
        opp.CCV_Not_used_comments__c = 'APEXTESTOPPTY002_CCV_NOT_USED_COMMENTS';
        opp.TotalOpportunityQuantity = 10;
        insert opp;
        String strOpptyId = opp.Id;
        //create multiple test O2 product detail records associated to the Opportunity
        O2_Product_Detail__c[] lsProds = new O2_Product_Detail__c[0];
        for (Integer i=0;i<5;i++) {
            O2_Product_Detail__c prod = new O2_Product_Detail__c();
            prod.Opportunity__c = strOpptyId;
            prod.Product_Category__c = 'Landline & Mobile';
            prod.Product__c = 'Landline';
            prod.Quantity__c = (i+1)*10;
            prod.Length_of_Contract__c = '12 Months';
            prod.Revenue_per_Month__c = (i+1)*5;
            prod.Contribution_Against_Product__c = 30;
            prod.Total_Contract_Value__c = 100;
            lsProds.add(prod);
        }
        Test.StartTest();
            //test O2 Product Detail record insertion
            insert lsProds;
            //create tester record variable
            String strExtId = strOpptyId + '_';
            OpportunityProduct__c[] testOpptyProd;
            //ASSERT: record inserted into shadow object
            //testOpptyProd = null;
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Automation_UID__c LIKE :strExtId+'%'];
            System.assertEquals(5, testOpptyProd.size());
            //test O2 Product Detail update
            for (Integer i=0; i<5; i++) {lsProds[i].Length_of_Contract__c = '18 Months';}
            update lsProds;
            //ASSERT: record updated in shadow object
            //testOpptyProd = null;
            testOpptyProd = [SELECT Id, Name, Automation_UID__c, MRR__c FROM OpportunityProduct__c WHERE Automation_UID__c LIKE :strExtId+'%' AND Length_of_Contract__c = '18 Months'];
            System.assertEquals(5, testOpptyProd.size());
            //test O2 Product Detail deletion
            System.debug('### OUTPUT >>>>> testOpptyProd:'+testOpptyProd);
            delete lsProds;
            //ASSERT: record in shadow object also deleted
            //testOpptyProd = null;
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Automation_UID__c LIKE :strExtId+'%'];
            System.assertEquals(0, testOpptyProd.size());    //can we test this when the records have not been committed?!
        Test.StopTest();
     }
     
     static TestMethod void testCopyConfigProduct() {
        RecordType[] lsOpptyRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity'];
        Map<String, Id> opptyRecTypes = new Map<String, Id>();
        for (RecordType r: lsOpptyRecTypes) {opptyRecTypes.put(r.Name, r.Id);}
        RecordType[] lsAccRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account'];
        Map<String, Id> accRecTypes = new Map<String, Id>();
        for (RecordType r: lsAccRecTypes) {accRecTypes.put(r.Name, r.Id);}
        //### CREATE TEST SALES DATA ###
        //create a test account record
        Account acc = new Account();
        acc.Name = 'APEXTESTACC003';
        acc.RecordTypeId = accRecTypes.get('Customer Account');
        insert acc;
        String strAccId = acc.Id;
        //create a test opportunity record
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = opptyRecTypes.get('Configurator');
        opp.Name = 'APEXTESTOPPTY003';
        opp.Type = 'New Business';
        opp.AccountId = strAccId;
        opp.StageName = 'Awareness of Needs';
        opp.CloseDate = Date.today()+1;
        opp.LeadSource = 'Self Generated';
        insert opp;
        String strOpptyId = opp.Id;
        //create a test Configurator Product record
        cscfgc__Product_Bundle__c bun = new cscfgc__Product_Bundle__c();
        bun.cscfgc__Opportunity__c = strOpptyId;
        bun.cscfgc__Bundle_Status__c = 'Valid';
        insert bun;
        String strBunId = bun.Id;
        Test.StartTest();
            //get product definition for new configuration
            /*********
            cscfgc__Product_Definition__c def = [SELECT Id, Name, cscfgc__Product_Category__r.Name,
                (SELECT Id, Name, cscfgc__is_Line_Item__c, cscfgc__Required__c FROM cscfgc__Attribute_Definitions__r)
            FROM cscfgc__Product_Definition__c WHERE Name = 'SMB Landline' LIMIT 1];
            **********/
            //get product definition for new configuration
            cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(Name='test Product', cscfgc__Description__c = 'test');
            insert def;
            List<cscfgc__Attribute_Definition__c> attDefList = new List<cscfgc__Attribute_Definition__c>();
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Number of Lines', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Monthly Tariff', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Contract Term', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Provide Type', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            insert attDefList;
            String strDefId = def.Id;
            cscfgc__Attribute_Definition__c[] attdefs = attDefList; //def.cscfgc__Attribute_Definitions__r;
            //create new configuration
            cscfgc__Product_Configuration__c config = new cscfgc__Product_Configuration__c();
            config.cscfgc__Product_Bundle__c = strBunId;
            config.cscfgc__Product_Definition__c = strDefId;
            config.cscfgc__Configuration_Status__c = 'Valid';
            config.cscfgc__Unit_Price__c = 10;
            config.cscfgc__Quantity__c = 1;
            config.cscfgc__Recurrence_Frequency__c = 12;
            insert config;
            String strConfigId = config.Id;
            //create associated attributes
            cscfgc__Attribute__c[] attribs = new cscfgc__Attribute__c[0];
            for (integer i=0; i<attdefs.size(); i++) {
                if (attdefs[i].cscfgc__is_Line_Item__c || attdefs[i].cscfgc__Required__c) {
                    cscfgc__Attribute__c att = new cscfgc__Attribute__c();
                    att.cscfgc__Product_Configuration__c = strConfigId;
                    att.cscfgc__Attribute_Definition__c = attdefs[i].Id;
                    att.Name = attdefs[i].Name;
                    att.cscfgc__is_Line_Item__c = attdefs[i].cscfgc__is_Line_Item__c;
                    if (attdefs[i].Name=='Number of Lines') {
                        att.cscfgc__Value__c = '1'; 
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Price__c = 25;
                    }
                    else if (attdefs[i].Name=='Monthly Tariff') {
                        att.cscfgc__Value__c = '25.00'; 
                        att.cscfgc__Display_Value__c = '£25.00';
                    }
                    else if (attdefs[i].Name=='Contract Term') {
                        att.cscfgc__Value__c = '24';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Display_Value__c = '24 Months';
                        att.cscfgc__Price__c = 0;
                    }
                    else if (attdefs[i].Name=='Provide Type') {
                        att.cscfgc__Value__c = 'New Provide';
                        att.cscfgc__Price__c = 25*12;
                        att.cscfgc__Display_Value__c = 'New Provide';                        
                    }
                    att.cscfgc__is_Active__c = true;
                    attribs.add(att);
                }
            }
            insert attribs;
            //retrieve a fresh list of the product configurations to check output in debug
            cscfgc__Product_Configuration__c[] prd = [SELECT Id, Name, cscfgc__description__c, cscfgc__serial_number__c, cscfgc__attribute_name__c, 
                    cscfgc__index__c, cscfgc__unit_price__c, cscfgc__quantity__c, cscfgc__total_price__c, cscfgc__recurrence_frequency__c, cscfgc__parent_configuration__c,
                    cscfgc__product_bundle__c, cscfgc__product_definition__c, cscfgc__product_definition__r.cscfgc__description__c, cscfgc__configuration_status__c,
                    Monthly_Recurring_Charge__c, One_off_Charge__c, 
                            (select name, cscfgc__attribute_definition__c, cscfgc__value__c, cscfgc__cascade_value__c, cscfgc__display_value__c, 
                            cscfgc__is_active__c, cscfgc__is_line_item__c, cscfgc__line_item_description__c, cscfgc__line_item_sequence__c, cscfgc__price__c, cscfgc__recurring__c
                            from cscfgc__Attributes__r order by cscfgc__line_item_sequence__c)        
                    FROM cscfgc__Product_Configuration__c WHERE cscfgc__Product_Bundle__c = :strBunId];            //ApexPages.StandardController prdcontroller = new ApexPages.StandardController(prd);
            for (integer i=0; i<prd.size(); i++) {
                System.debug('### OUTPUT >>>>> prd:'+prd[i]);
                System.debug('### OUTPUT >>>>> atts:'+prd[i].cscfgc__Attributes__r);
            }
            
            //### move to the Bundle Controller page
            PageReference pgBundleDetail = new PageReference('apex/ConfigurationBundleDetail?id='+strBunId);
            Test.setCurrentPage(pgBundleDetail);
            ApexPages.StandardController buncontroller = new ApexPages.StandardController(bun);
            ProductBundleController synccontroller = new ProductBundleController(buncontroller);
            //synchronise the bundle with the opportunity
            System.debug('### TEST OUTPUT >>>>> pageref:'+synccontroller.syncWithOpportunity());
            OpportunityLineItem[] testList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :strOpptyId];
            System.debug('### TEST OUTPUT >>>>> line items:'+testList);
            //check that the shadow record has been created
            String strCheckUID;
            strCheckUID = strOpptyId + '_' + strConfigId;
            OpportunityProduct__c[] testOpptyProd;
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Automation_UID__c = :strCheckUID];
            System.assertEquals(1, testOpptyProd.size());
            //check that the bundle is now synchronised
            cscfgc__Product_Bundle__c testBundle;
            testBundle = [SELECT Id, cscfgc__Synchronised_with_Opportunity__c FROM cscfgc__Product_Bundle__c WHERE Id=:strBunId];
            System.assertEquals(true, testBundle.cscfgc__Synchronised_with_Opportunity__c);

            //### TEST unsynchronising the bundle by creating another bundle and product config and synchronising with the Oppty
            cscfgc__Product_Bundle__c testBunSync = new cscfgc__Product_Bundle__c();
            testBunSync.cscfgc__Opportunity__c = strOpptyId;
            testBunSync.cscfgc__Bundle_Status__c = 'Valid';
            insert testBunSync;
            String strTestBunId = testBunSync.Id;
            cscfgc__Product_Configuration__c testConfig = new cscfgc__Product_Configuration__c();
            testConfig.cscfgc__Product_Bundle__c = strTestBunId;
            testConfig.cscfgc__Product_Definition__c = strDefId;
            testConfig.cscfgc__Configuration_Status__c = 'Valid';
            testConfig.cscfgc__Unit_Price__c = 20;
            testConfig.cscfgc__Quantity__c = 1;
            testConfig.cscfgc__Recurrence_Frequency__c = 12;
            insert testConfig;
            String strTestConfigId = testConfig.Id;
            ApexPages.StandardController testbuncontroller = new ApexPages.StandardController(testBunSync);
            ProductBundleController testsynccontroller = new ProductBundleController(testbuncontroller);
            //synchronise the bundle with the opportunity
            testsynccontroller.syncWithOpportunity();
            //check that the original bundle is now unsynchronised and the OpportunityProduct__c record has been removed
            testBundle = [SELECT Id, cscfgc__Synchronised_with_Opportunity__c FROM cscfgc__Product_Bundle__c WHERE Id=:strBunId];
            System.assertEquals(false, testBundle.cscfgc__Synchronised_with_Opportunity__c);
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Automation_UID__c = :strCheckUID];
            System.assertEquals(0, testOpptyProd.size());
            
            //### TEST deleting a bundle
            strCheckUID = strOpptyId + '_' + strTestConfigId;
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Automation_UID__c = :strCheckUID];
            System.assertEquals(1, testOpptyProd.size());
            delete testBunSync;
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Automation_UID__c = :strCheckUID];
            System.assertEquals(0, testOpptyProd.size());
        Test.StopTest();
     }
     
     static TestMethod void testCopyMultipleConfigProducts() {
        RecordType[] lsOpptyRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity'];
        Map<String, Id> opptyRecTypes = new Map<String, Id>();
        for (RecordType r: lsOpptyRecTypes) {opptyRecTypes.put(r.Name, r.Id);}
        RecordType[] lsAccRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account'];
        Map<String, Id> accRecTypes = new Map<String, Id>();
        for (RecordType r: lsAccRecTypes) {accRecTypes.put(r.Name, r.Id);}
        //### CREATE TEST SALES DATA ###
        //create a test account record
        Account acc = new Account();
        acc.Name = 'APEXTESTACC004';
        acc.RecordTypeId = accRecTypes.get('Customer Account');
        insert acc;
        String strAccId = acc.Id;
        //create a test opportunity record
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = opptyRecTypes.get('Configurator');
        opp.Name = 'APEXTESTOPPTY004';
        opp.Type = 'New Business';
        opp.AccountId = strAccId;
        opp.StageName = 'Awareness of Needs';
        opp.CloseDate = Date.today()+1;
        opp.LeadSource = 'Self Generated';
        insert opp;
        String strOpptyId = opp.Id;
        //create a test Configurator Product record
        cscfgc__Product_Bundle__c[] bundles = new cscfgc__Product_Bundle__c[0];
        for (integer i=0; i<50;i++) {
            cscfgc__Product_Bundle__c bun = new cscfgc__Product_Bundle__c();
            bun.cscfgc__Opportunity__c = strOpptyId;
            bun.cscfgc__Bundle_Status__c = 'Valid';
            bundles.add(bun);
        }
        insert bundles;
        /*****
        cscfgc__Product_Definition__c def = [SELECT Id, Name, cscfgc__Product_Category__r.Name,
            (SELECT Id, Name, cscfgc__is_Line_Item__c, cscfgc__Required__c FROM cscfgc__Attribute_Definitions__r)
        FROM cscfgc__Product_Definition__c WHERE Name = 'SMB Landline' LIMIT 1];
        *******/
        //get product definition for new configuration
        cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(Name='test Product', cscfgc__Description__c = 'test');
        insert def;
        List<cscfgc__Attribute_Definition__c> attDefList = new List<cscfgc__Attribute_Definition__c>();
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Number of Lines', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Monthly Tariff', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Contract Term', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Provide Type', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
        insert attDefList;
        String strDefId = def.Id;
        cscfgc__Attribute_Definition__c[] attdefs = attDefList; //def.cscfgc__Attribute_Definitions__r;

        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
        for (integer i=0;i<bundles.size();i++) {
            cscfgc__Product_Configuration__c cfg = new cscfgc__Product_Configuration__c();
            cfg.cscfgc__Product_Bundle__c = bundles[i].Id;
            cfg.cscfgc__Product_Definition__c = strDefId;
            cfg.cscfgc__Configuration_Status__c = 'Valid';
            cfg.cscfgc__Unit_Price__c = (i+1)*10;
            cfg.cscfgc__Quantity__c = 1;
            cfg.cscfgc__Recurrence_Frequency__c = 12;
            configs.add(cfg);
        }
        insert configs;
        
        cscfgc__Attribute__c[] attribs = new cscfgc__Attribute__c[0];
        for (integer j=0;j<configs.size(); j++) {
            for (integer k=0; k<attdefs.size(); k++) {
                if (attdefs[k].cscfgc__is_Line_Item__c || attdefs[k].cscfgc__Required__c) {
                    cscfgc__Attribute__c att = new cscfgc__Attribute__c();
                    att.cscfgc__Product_Configuration__c = configs[j].Id;
                    att.cscfgc__Attribute_Definition__c = attdefs[k].Id;
                    att.Name = attdefs[k].Name;
                    att.cscfgc__is_Line_Item__c = attdefs[k].cscfgc__is_Line_Item__c;
                    if (attdefs[k].Name=='Number of Lines') {
                        att.cscfgc__Value__c = '1'; 
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Price__c = (j+1)*5;
                    }
                    else if (attdefs[k].Name=='Monthly Tariff') {
                        att.cscfgc__Value__c = String.valueOf((j+1)*5); 
                        att.cscfgc__Display_Value__c = '£'+String.valueOf((j+1)*5);
                    }
                    else if (attdefs[k].Name=='Contract Term') {
                        att.cscfgc__Value__c = '24';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Display_Value__c = '24 Months';
                        att.cscfgc__Price__c = 0;
                    }
                    else if (attdefs[k].Name=='Provide Type') {
                        att.cscfgc__Value__c = 'New Provide';
                        att.cscfgc__Price__c = ((j+1)*5)*12;
                        att.cscfgc__Display_Value__c = 'New Provide';                        
                    }
                    att.cscfgc__is_Active__c = true;
                    attribs.add(att);
                }
            }
        }
        insert attribs;
        
        Test.StartTest();
            OpportunityProduct__c[] testOpptyProd;
            for (cscfgc__Product_Bundle__c bun: bundles) {bun.cscfgc__Synchronised_with_Opportunity__c = true;}
            update bundles;
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Opportunity__c = :strOpptyId];
            System.assertEquals(50, testOpptyProd.size());

            //test bulk delete
            delete bundles;
            testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Opportunity__c = :strOpptyId];
            System.assertEquals(0, testOpptyProd.size());
            
        Test.StopTest();
     
     }
}