/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class TestJUC1 {

    private static string SUFFIX_NAME = 'TestJUC1';


    static testMethod void rejectOrderGroupTest() {
        Account newAcc = new Account(Name = 'test Acc') ;
        insert newAcc ;
        Opportunity newOpp = new Opportunity(Name='test Opp', StageName = 'Paused', CloseDate = Date.Today(), AccountId = newAcc.id);
        newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule
        insert newOpp;
        Order_Group__c newOG = new Order_Group__c(Opportunity__c = newOpp.id, Order_Group_Status__c = 'In progress') ;
        insert newOG ;
        Order__c newOrder = new Order__c (Opportunity__c = newOpp.id, Order_Group__c = newOG.id, Account__c = newAcc.id, Order_Status__c = '', Order_Status_Reason__c = '') ;
        insert newOrder ;

        newOG.Order_Group_Status__c = 'Rejected' ;
        update newOG ;

        Opportunity Opp = [Select id, StageName from Opportunity where id = :newOpp.id] ;

        System.assertEquals('Rejected', newOG.Order_Group_Status__c) ;
        System.assertEquals('Decision', Opp.StageName) ;
        System.debug('***********>>>>>>newOrder.Order_Status__c:'+newOrder.Order_Status__c);
        //System.assertEquals('Not Provisioned', newOrder.Order_Status__c) ;
        //System.assertEquals('Rejected by Contract Admin', newOrder.Order_Status_Reason__c) ;
    }

    static testMethod void allCustomerApprovalTriggersTest() {
        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
        newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule
        insert newOpp;
        //
        // -----------
        // - Create a product
        Product2 newproduct = new Product2(Name = 'New Product', isActive = true);
        insert newProduct;
        // - Get the Standard Price Book
        PriceBook2 standardPriceBook = [select Id from PriceBook2 where Name = 'Standard Price Book' limit 1];
        // - Create price book entry
        PricebookEntry newPricebookEntry = new PricebookEntry(Product2Id = newproduct.Id,
                                                              PriceBook2Id = standardPriceBook.Id,
                                                              UnitPrice = 4000.00,
                                                              isActive = true);
        insert newPricebookEntry;
        // -----------
        // - Create opportunity Main line item
        OpportunityLineItem newOppMainLineItem = new OpportunityLineItem(OpportunityId = newOpp.Id,
                                                                     PriceBookEntryId = newPricebookEntry.Id,
                                                                     Quantity = 1.0,
                                                                     TotalPrice = 4000.00);
        insert newOppMainLineItem;
        // - Create opportunity Main line item
        OpportunityLineItem newOppLineItem = new OpportunityLineItem(OpportunityId = newOpp.Id,
                                                                     PriceBookEntryId = newPricebookEntry.Id,
                                                                     Quantity = 1.0,
                                                                     TotalPrice = 4000.00);
        insert newOppLineItem;
        // - A backup Main line item
        OpportunityLineItem newBackUpOppLineItem = new OpportunityLineItem(OpportunityId = newOpp.Id,
                                                                           PriceBookEntryId = newPricebookEntry.Id,
                                                                           Quantity = 1.0,
                                                                           TotalPrice = 4000.00);
        insert newBackUpOppLineItem;
        // -----------
        // Create a contact role
        OpportunityContactRole newOppContactRole = new OpportunityContactRole(OpportunityId = newOpp.Id,
                                                                              ContactId = newContact.Id,
                                                                              IsPrimary = true,
                                                                              Role = 'Technical Buyer');
        insert newOppContactRole;
        // -----------
        // Create a quote
        Pricebook2 priceBook = [Select p.Name, p.Id From Pricebook2 p where p.Name = 'Standard Price Book' limit 1];
        //
        Quote newQuote = new Quote();
        newQuote.Name = 'test';
        newQuote.Pricebook2Id = priceBook.Id;
        newQuote.OpportunityId = newOpp.Id;
        insert newQuote;
        // -----------
        // update the opportunity to Closed Won
        newOpp.SyncedQuoteId = newQuote.Id;
        update newOpp;
        //
        cscfgc__Product_Bundle__c bun = new cscfgc__Product_Bundle__c();
        bun.cscfgc__Opportunity__c = newOpp.Id;
        bun.cscfgc__Bundle_Status__c = 'Valid';
        insert bun;
        String strBunId = bun.Id;
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
        cscfgc__Attribute_Definition__c[] attdefs = attDefList;
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
                    att.cscfgc__line_item_Description__c = 'test1';
                    att.cscfgc__Value__c = '1';
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Price__c = 25;
                }
                else if (attdefs[i].Name=='Monthly Tariff') {
                    att.cscfgc__line_item_Description__c = 'test2';
                    att.cscfgc__Value__c = '25.00';
                    att.cscfgc__Display_Value__c = '£25.00';
                }
                else if (attdefs[i].Name=='Contract Term') {
                    att.cscfgc__line_item_Description__c = 'test3';
                    att.cscfgc__Value__c = '24';
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Display_Value__c = '24 Months';
                    att.cscfgc__Price__c = 0;
                }
                else if (attdefs[i].Name=='Provide Type') {
                    att.cscfgc__line_item_Description__c = 'test4';
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
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(bun);
        ProductBundleController bundleController = new ProductBundleController(standardCtrl);
        //synchronise the bundle with the opportunity
        bundleController.syncWithOpportunity();
        // -----------
        // Create a customer approval record
        CSCAP__Customer_Approval__c custApproval = new CSCAP__Customer_Approval__c(CSCAP__Opportunity__c = newOpp.Id);
        insert custApproval;
        //
        custApproval.CSCAP__Approved_By_Customer__c = true;
        custApproval.CSCAP__Rejected_By_Customer__c = false;
        update custApproval;
        //
        custApproval.CSCAP__Approved_By_Customer__c = false;
        custApproval.CSCAP__Rejected_By_Customer__c = true;
        update custApproval;
        // --------------

        // -----------
        PageReference page = new PageReference('/apex/O2ContractPDF');
        Test.setCurrentPage(page);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(newQuote);
        O2QuoteController ctrl = new O2QuoteController(stdController);
        ctrl.getAccount();
        ctrl.getAllProductConfigurations();
        ctrl.getbundleTotal();
        ctrl.getContractTerm();
        ctrl.getIsBB();
        ctrl.getIsCallsOnly();
        ctrl.getIsIsdn2();
        ctrl.getIsIsdn30();
        ctrl.getIsLandline();
        ctrl.getIsMinuteBoltOns();
        ctrl.getIsTeleMarketing();
        ctrl.getOpportunityOwner();
        ctrl.getOpportunity();
        ctrl.getOwner();
        ctrl.getQuote();
        ctrl.getNumberLandline();
        ctrl.getNumberCallsOnly();
        ctrl.getNumberIsdn2();
        ctrl.getNumberIsdn30();
        ctrl.getNumberBB();
        ctrl.getNumberTeleMarketing();

    }

/*
    static testMethod void allOrderTriggersTest() {
        // Create a RecordType
        RecordType accRecordType = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Account' and r.DeveloperName = 'BE_Account'];

        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
         newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule
         insert newOpp;

        newAcc.RecordTypeId = accRecordType.Id;
        update newAcc;

        // -----------
        // Create an Order
        Order__c newOrder1 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Order_Status_Reason__c = 'Down-grade (Same product)');
        insert newOrder1;
        //
        Order__c newOrder2 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Related_Parent_Order__c = newOrder1.Id, Order_Status_Reason__c = 'New Business');
        insert newOrder2;
        //
        newOrder2.Order_Status__c = 'Active';
        update newOrder2;
        OrderHelper.ceaseParentOrder(newOrder1.Id, 'Up-grade (Same product)', date.today());
        OrderHelper.ceaseParentOrder(newOrder1.Id, 'Price Change / Contract Renewal', date.today());
        OrderHelper.ceaseParentOrder(newOrder1.Id, 'Price Change / Contract Amendment', date.today());
        OrderHelper.updateRelatedParentOrder(newOrder1.Id, 'Price Change / Contract Amendment');
        //
        Order_Group__c newOG = new Order_Group__c(Opportunity__c = newOpp.id, Order_Group_Status__c = 'In progress') ;
        insert newOG ;
        Order__c newOrder = new Order__c (Opportunity__c = newOpp.id, Order_Group__c = newOG.id, Account__c = newAcc.id, Order_Status__c = '', Order_Status_Reason__c = '') ;
        insert newOrder ;
        delete newOrder;
    }
*/

    static testMethod void allOrderTriggersTest1() {
        // Create a RecordType
        RecordType accRecordType = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Account' and r.DeveloperName = 'BE_Account'];

        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
         newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule
         insert newOpp;

        newAcc.RecordTypeId = accRecordType.Id;
        update newAcc;

        // -----------
        // Create an Order
        Order__c newOrder1 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Order_Status_Reason__c = 'Down-grade (Same product)');
        insert newOrder1;
        //
        Order__c newOrder2 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Related_Parent_Order__c = newOrder1.Id, Order_Status_Reason__c = 'New Business');
        insert newOrder2;
        //
        newOrder2.Order_Status__c = 'Active';
        update newOrder2;

        OrderHelper.ceaseParentOrder(newOrder1.Id, 'Up-grade (Same product)', date.today());
    }


    static testMethod void allOrderTriggersTest2() {
        // Create a RecordType
        RecordType accRecordType = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Account' and r.DeveloperName = 'BE_Account'];

        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
         newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule
         insert newOpp;

        newAcc.RecordTypeId = accRecordType.Id;
        update newAcc;

        // -----------
        // Create an Order
        Order__c newOrder1 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Order_Status_Reason__c = 'Down-grade (Same product)');
        insert newOrder1;
        //
        Order__c newOrder2 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Related_Parent_Order__c = newOrder1.Id, Order_Status_Reason__c = 'New Business');
        insert newOrder2;
        //
        newOrder2.Order_Status__c = 'Active';
        update newOrder2;

        OrderHelper.ceaseParentOrder(newOrder1.Id, 'Price Change / Contract Renewal', date.today());
    }


    static testMethod void allOrderTriggersTest3() {
        // Create a RecordType
        RecordType accRecordType = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Account' and r.DeveloperName = 'BE_Account'];

        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
         newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule
         insert newOpp;

        newAcc.RecordTypeId = accRecordType.Id;
        update newAcc;

        // -----------
        // Create an Order
        Order__c newOrder1 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Order_Status_Reason__c = 'Down-grade (Same product)');
        insert newOrder1;
        //
        Order__c newOrder2 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Related_Parent_Order__c = newOrder1.Id, Order_Status_Reason__c = 'New Business');
        insert newOrder2;
        //
        newOrder2.Order_Status__c = 'Active';
        update newOrder2;
        OrderHelper.ceaseParentOrder(newOrder1.Id, 'Price Change / Contract Amendment', date.today());
    }

    static testMethod void allOrderTriggersTest4() {
        // Create a RecordType
        RecordType accRecordType = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Account' and r.DeveloperName = 'BE_Account'];

        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
         newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule
         insert newOpp;

        newAcc.RecordTypeId = accRecordType.Id;
        update newAcc;

        // -----------
        // Create an Order
        Order__c newOrder1 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Order_Status_Reason__c = 'Down-grade (Same product)');
        insert newOrder1;
        //
        Order__c newOrder2 = new Order__c(Name = 'Test Order', Opportunity__c = newOpp.Id, Account__c = newAcc.Id, Main_contact__c = newContact.Id,
                                         Related_Parent_Order__c = newOrder1.Id, Order_Status_Reason__c = 'New Business');
        insert newOrder2;
        //
        newOrder2.Order_Status__c = 'Active';
        update newOrder2;
        OrderHelper.updateRelatedParentOrder(newOrder1.Id, 'Price Change / Contract Amendment');
        //
        Order_Group__c newOG = new Order_Group__c(Opportunity__c = newOpp.id, Order_Group_Status__c = 'In progress') ;
        insert newOG ;
        Order__c newOrder = new Order__c (Opportunity__c = newOpp.id, Order_Group__c = newOG.id, Account__c = newAcc.id, Order_Status__c = '', Order_Status_Reason__c = '') ;
        insert newOrder ;
        delete newOrder;

    }


    static testMethod void allOrchestrationStepTriggersTest() {

        // Create a product template for the ADSL Homeworker product
        Product_Template__c pTemplate = new Product_Template__c(Name= 'SMB Landline',
                                                                Product_Type__c = 'PSTN');
        insert pTemplate;
        //
        // Create product asset template for this product template
        Map<String,Boolean> assetMap = new Map<String,Boolean> {'PSTN' => False};
        List<Asset_Template_Line__c> assetTemplateList = new List<Asset_Template_Line__c>();
        for (String elem : assetMap.keySet()) {
            assetTemplateList.add(new Asset_Template_Line__c(Name = elem,
                                                             Type__c = elem,
                                                             Product_Template__c = pTemplate.Id));
        }
        insert assetTemplateList;
        // Create a map of Assets and Ids
        Map<String,String> assetTplMap = new Map<String,String>();
        for (Asset_Template_Line__c asset : assetTemplateList) {
            assetTplMap.put(asset.type__c, asset.Id);
        }
        //
        // Create product asset config template for this product template
        List<Map<String,String>> configList = new List<Map<String,String>> {
            new Map<String,String>{'Name' => 'Telephone Number', 'Type__c' => 'Telephone Number', 'Related_Service_Field_Name__c' => '', 'Asset_Type__c' => 'PSTN'},
            new Map<String,String>{'Name' => 'Contract End Date', 'Type__c' => 'Contract End Date', 'Related_Service_Field_Name__c' => '', 'Asset_Type__c' => 'PSTN'},
            new Map<String,String>{'Name' => 'Installation Date', 'Type__c' => 'Installation Date', 'Related_Service_Field_Name__c' => '', 'Asset_Type__c' => 'PSTN'}
        };
        List<Asset_Config_Template_Line__c> assetConfigTemplateList = new List<Asset_Config_Template_Line__c>();
        for (Map<String,String> ConfigTemplateMap : configList) {
            assetConfigTemplateList.add(
                new Asset_Config_Template_Line__c(Name = ConfigTemplateMap.get('Name'),
                                                  Type__c = ConfigTemplateMap.get('Type__c'),
                                                  Asset_Type__c = ConfigTemplateMap.get('Asset_Type__c'),
                                                  Product_Template__c = pTemplate.Id)
            );
        }
        insert assetConfigTemplateList;
        //
        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
        newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule

        insert newOpp;
        // -----------
        // Create an Order
        Order_Group__c newOG = new Order_Group__c(Opportunity__c = newOpp.id, Order_Group_Status__c = 'In progress') ;
        insert newOG ;
        Order__c newOrder = new Order__c (Opportunity__c = newOpp.id, Main_Contact__c = newContact.Id, Product_Type__c = 'SMB Landline', Order_Group__c = newOG.id, Account__c = newAcc.id, Order_Status__c = 'In Provisioning', Order_Status_Reason__c = 'New Business') ;
        insert newOrder ;
        // -----------
        // Create a process

        Id templateId = [select Id from CSPOFA__Orchestration_Process_Template__c
        where  CSPOFA__Process_Type__c = 'New Provide'
        and Name = 'Process for PSTN'].Id;


        CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c(Name='Process for PSTN', CSPOFA__Process_Type__c = 'New Provide', Order__c = newOrder.Id, CSPOFA__Orchestration_Process_Template__c = templateId);
        insert newProcess;
        //-----------
        // Create process steps
        CSPOFA__Orchestration_Step__c newStep = new CSPOFA__Orchestration_Step__c(
                    name                                = 'Email1',
                    CSPOFA__Type__c                     = 'Send Email',
                    CSPOFA__Orchestration_Process__c    = newProcess.id,
                    CSPOFA__progress__c                 = 'New',
                    CSPOFA__Status__c                   = 'Initializing',
                    CSPOFA__email_template_name__c      = 'test',
                    CSPOFA__Send_Email_To__c            = 'Main Contact'
            );
        try {
            insert newStep;
        } catch(Exception ex) {

        }
        //
        CSPOFA__Orchestration_Step__c newStep1 = new CSPOFA__Orchestration_Step__c(
                    name                                = 'Task1',
                    CSPOFA__Type__c                     = 'Create Task',
                    CSPOFA__Orchestration_Process__c    = newProcess.id,
                    CSPOFA__progress__c                 = 'New',
                    CSPOFA__Status__c                   = 'Initializing',
                    CSPOFA__Task_Subject__c             = 'test task',
                    CSPOFA__Task_Assigned_To__c         = 'Order Owner',
                    CSPOFA__Task_Description__c         = 'test',
                    CSPOFA__Task_Status__c              = 'Not started',
                    CSPOFA__Task_Priority__c            = 'High',
                    CSPOFA__Task_Linked_To__c           = 'Step',
                    CSPOFA__Task_Type__c                = 'test'
            );
        insert newStep1;
        //
        CSPOFA__Orchestration_Step__c newStep2 = new CSPOFA__Orchestration_Step__c(
                    name                                = 'Case1',
                    CSPOFA__Type__c                     = 'Create Case',
                    CSPOFA__Orchestration_Process__c    = newProcess.id,
                    CSPOFA__progress__c                 = 'New',
                    CSPOFA__Status__c                   = 'Initializing',
                    CSPOFA__Case_Subject__c             = 'test',
                    CSPOFA__Case_Assigned_To__c         = 'Order Owner',
                    CSPOFA__Case_Description__c         = 'test',
                    CSPOFA__Case_Type__c                = 'test',
                    CSPOFA__Case_Reason__c              = 'test'
            );
        insert newStep2;
        //
        CSPOFA__Orchestration_Step__c newStep3 = new CSPOFA__Orchestration_Step__c(
                    name                                = 'Waiting Number Of Days1',
                    CSPOFA__Type__c                     = 'Waiting Number Of Days',
                    CSPOFA__Orchestration_Process__c    = newProcess.id,
                    CSPOFA__progress__c                 = 'New',
                    CSPOFA__Status__c                   = 'Initializing',
                    CSPOFA__Task_Due_Date__c            = date.today()
            );
        insert newStep3;
        //
        CSPOFA__Orchestration_Step__c newStep4 = new CSPOFA__Orchestration_Step__c(
                    name                                = 'MonitorField1',
                    CSPOFA__Type__c                     = 'Monitor Field',
                    CSPOFA__Orchestration_Process__c    = newProcess.id,
                    CSPOFA__progress__c                 = 'New',
                    CSPOFA__Status__c                   = 'Initializing',
                    CSPOFA__Field_Name__c               = 'Order__r.Order_Status__c',
                    CSPOFA__Field_Value__c              = 'Active',
                    CSPOFA__Field_Type__c               = 'String',
                    CSPOFA__Field_Monitor_Operator__c   = 'Equal'
            );
        insert newStep4;
        //
        CSPOFA__Orchestration_Step__c newStep5 = new CSPOFA__Orchestration_Step__c(
                    name                                = 'MonitorField1',
                    CSPOFA__Type__c                     = 'Monitor Field',
                    CSPOFA__Orchestration_Process__c    = newProcess.id,
                    CSPOFA__progress__c                 = 'New',
                    CSPOFA__Status__c                   = 'Initializing',
                    CSPOFA__Field_Name__c               = 'Order__r.Order_Status__c',
                    CSPOFA__Field_Value__c              = 'Active',
                    CSPOFA__Field_Type__c               = 'String'
            );
        insert newStep5;
        //
        newStep.CSPOFA__Status__c = 'Ready';
        try {
            update newStep;
        } catch(Exception ex) {

        }
        newStep1.CSPOFA__Status__c = 'Ready';
        update newStep1;
        newStep2.CSPOFA__Status__c = 'Ready';
//      update newStep2;
        newStep3.CSPOFA__Status__c = 'Ready';
        update newStep3;
        newStep4.CSPOFA__Status__c = 'Ready';
        update newStep4;
        newStep5.CSPOFA__Status__c = 'Ready';
        update newStep5;
    }

    static testMethod void productBundleBuilderControllerTest() {
        TestDataForJUC1.createRecordTypeForAccount();
        Account newAcc = TestDataForJUC1.createAccount('TestAccount'+SUFFIX_NAME);

        //Contact newContatct = TestDataForJUC1.createContact(newAcc.Id, 'Jack', 'Jones', 'jack.jones@junkmail.yahoo.com.uk');

        TestDataForJUC1.createRecordTypeForOpportunity();
        Opportunity newOpp = TestDataForJUC1.createOpportunity(newAcc.Id, 'TestOpportunity'+SUFFIX_NAME, 'Awareness of Needs');

        //create a product bundle for the above opportunity

        cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();
        bundle.cscfgc__Opportunity__c = newOpp.Id;
        bundle.cscfgc__Bundle_Status__c = 'Valid';
        insert bundle;

         //Set the page reference to product bundle builder page
         PageReference page = new PageReference('/apex/productBundleBuilder');
         Test.setCurrentPage(page);

         //Create controller
         ApexPages.StandardController stdController = new ApexPages.StandardController(bundle);
         productBundleBuilderController controller = new productBundleBuilderController(stdController);

         controller.addNewConfigurationRequest();

         //List<Configuration_Request__c> configReqList = new List<Configuration_Request__c>();
         Configuration_Request__c configRequest1= new Configuration_Request__c(
                                                        product_bundle__c = bundle.Id,
                                                        product_category__c = 'SMB Fixed Line',
                                                        Product_Name__c = 'SMB Landline',
                                                        Directory_Number__c = '02012323434',
                                                        Post_Code__c = 'LS10 1RD');

         //Configuration_Request__c configRequest2 = new Configuration_Request__c(product_bundle__c = bundle.Id, product_category__c = 'SMB Fixed Line', Product_Name__c = 'SMB Calls Only');
         //Configuration_Request__c configRequest3 = new Configuration_Request__c(product_bundle__c = bundle.Id, product_category__c = 'SMB Fixed Line', Product_Name__c = 'SMB ISDN2');
         //configReqList.add(configRequest1);
         //configReqList.add(configRequest2);
         //configReqList.add(configRequest3);

         //insert configReqList;
         insert configRequest1;

         controller.configRequestId = configRequest1.Id;
         controller.addTimePlan();
         controller.getHours();
         controller.getMinutes();
         controller.createConfigurations();
         controller.queryConfigurationRequests();
         controller.setDetailFlagFalse();
         controller.setDetailFlagTrue();
         controller.submitRows();

         //controller.configRequestId = configRequest2.Id;
        // controller.createConfigurations();

    }


     /* static testMethod void productBundleBuilderControllerTest() {

        //
        Account newAcc = new Account(Name = 'test Acc') ;
        insert newAcc ;
        Opportunity newOpp = new Opportunity(Name='test Opp', StageName = 'Achievement of Results', CloseDate = Date.Today(), AccountId = newAcc.id);
        insert newOpp;
        //
        cscfgc__Product_Bundle__c bun = new cscfgc__Product_Bundle__c();
        bun.cscfgc__Opportunity__c = newOpp.Id;
        bun.cscfgc__Bundle_Status__c = 'Valid';
        insert bun;
        // -----------
        PageReference page = new PageReference('/apex/productBundleBuilder');
        Test.setCurrentPage(page);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(bun);
        productBundleBuilderController ctrl = new productBundleBuilderController(stdController);
        ctrl.addNewConfigurationRequest();
        Configuration_Request__c configRequest= new Configuration_Request__c(product_bundle__c = bun.Id, product_category__c = 'SMB Fixed Line', Product_Name__c = 'SMB Landline');
        insert configRequest;
        ctrl.configRequestId = configRequest.Id;
        ctrl.addTimePlan();
        ctrl.getHours();
        ctrl.getMinutes();
        ctrl.cloneConfigurationRequests();
        ctrl.createConfigurations();
        ctrl.queryConfigurationRequests();
        ctrl.setDetailFlagFalse();
        ctrl.setDetailFlagTrue();
        ctrl.submitRows();

        //configRequest = new Configuration_Request__c(product_bundle__c = bun.Id, product_category__c = 'SMB Fixed Line', Product_Name__c = 'SMB Calls Only');
        //insert configRequest;
        //ctrl.configRequestId = configRequest.Id;
        //ctrl.createConfigurations();

        //configRequest = new Configuration_Request__c(product_bundle__c = bun.Id, product_category__c = 'SMB Fixed Line', Product_Name__c = 'SMB ISDN2');
        //insert configRequest;
        //ctrl.configRequestId = configRequest.Id;
        //ctrl.createConfigurations();

    }


   static testMethod void productBundleBuilderControllerTest1() {
        //
        Account newAcc = new Account(Name = 'test Acc') ;
        insert newAcc ;
        Opportunity newOpp = new Opportunity(Name='test Opp', StageName = 'Achievement of Results', CloseDate = Date.Today(), AccountId = newAcc.id);
        insert newOpp;
        //
        cscfgc__Product_Bundle__c bun = new cscfgc__Product_Bundle__c();
        bun.cscfgc__Opportunity__c = newOpp.Id;
        bun.cscfgc__Bundle_Status__c = 'Valid';
        insert bun;
        // -----------
        PageReference page = new PageReference('/apex/productBundleBuilder');
        Test.setCurrentPage(page);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(bun);
        productBundleBuilderController ctrl = new productBundleBuilderController(stdController);
        ctrl.addNewConfigurationRequest();
        Configuration_Request__c configRequest= new Configuration_Request__c(product_bundle__c = bun.Id, product_category__c = 'SMB Fixed Line', Product_Name__c = 'SMB Landline');
        insert configRequest;
        ctrl.configRequestId = configRequest.Id;
        ctrl.addTimePlan();
        ctrl.getHours();
        ctrl.getMinutes();
        ctrl.cloneConfigurationRequests();
        ctrl.createConfigurations();
        ctrl.queryConfigurationRequests();
        ctrl.setDetailFlagFalse();
        ctrl.setDetailFlagTrue();
        ctrl.submitRows();

        //configRequest = new Configuration_Request__c(product_bundle__c = bun.Id, product_category__c = 'SMB Telemarketing', Product_Name__c = 'SMB Telemarketing Divert Plan');
        //insert configRequest;
        //ctrl.configRequestId = configRequest.Id;
        //ctrl.createConfigurations();

    }

 static testMethod void productBundleBuilderControllerTest2() {
        //
        Account newAcc = new Account(Name = 'test Acc') ;
        insert newAcc ;
        Opportunity newOpp = new Opportunity(Name='test Opp', StageName = 'Achievement of Results', CloseDate = Date.Today(), AccountId = newAcc.id);
        insert newOpp;
        //
        cscfgc__Product_Bundle__c bun = new cscfgc__Product_Bundle__c();
        bun.cscfgc__Opportunity__c = newOpp.Id;
        bun.cscfgc__Bundle_Status__c = 'Valid';
        insert bun;
        // -----------
        PageReference page = new PageReference('/apex/productBundleBuilder');
        Test.setCurrentPage(page);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(bun);
        productBundleBuilderController ctrl = new productBundleBuilderController(stdController);
        ctrl.addNewConfigurationRequest();
        Configuration_Request__c configRequest= new Configuration_Request__c(product_bundle__c = bun.Id, product_category__c = 'SMB Fixed Line', Product_Name__c = 'SMB ISDN30 ETSI');
        insert configRequest;
        ctrl.configRequestId = configRequest.Id;
        ctrl.addTimePlan();
        ctrl.getHours();
        ctrl.getMinutes();
        ctrl.cloneConfigurationRequests();
        ctrl.createConfigurations();
        ctrl.queryConfigurationRequests();
        ctrl.setDetailFlagFalse();
        ctrl.setDetailFlagTrue();
        ctrl.submitRows();

        //configRequest = new Configuration_Request__c(product_bundle__c = bun.Id, product_category__c = 'SMB Fixed Line', Product_Name__c = 'SMB ISDN30 DASS');
        //insert configRequest;
        //ctrl.configRequestId = configRequest.Id;
        //ctrl.createConfigurations();

    }  */


    static testMethod void testCreateAssetConfigTplLineController() {
        // -----------
        //
        // Create a product template for the ADSL Homeworker product
        Product_Template__c pTemplate = new Product_Template__c(Name= 'Homeworker ADSL Test',
                                                                Product_Type__c = 'Homeworker ADSL Test');
        insert pTemplate;
        //
        Asset_Template_Line__c assetTpl = new Asset_Template_Line__c(Name = 'Test', Type__c = 'test', Product_Template__c = pTemplate.Id);
        insert assetTpl;
        //
        Asset_Config_Template_Line__c configTpl = new Asset_Config_Template_Line__c(Name = 'test',
                                                                                    Type__c = 'test',
                                                                                    Asset_Type__c = 'test',
                                                                                    Product_Template__c = pTemplate.Id);

        //
        // -----------
        PageReference page = new PageReference('/apex/CreateAssetConfigTplLine');
        Test.setCurrentPage(page);
        page.getParameters().put('AssetId', assetTpl.Id);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(configTpl);
        CreateAssetConfigTplLineController ctrl = new CreateAssetConfigTplLineController(stdController);
        ctrl.save();
    }

    static testMethod void testCreateAssetConfigTplLineController2() {
        // -----------
        //
        // Create a product template for the ADSL Homeworker product
        Product_Template__c pTemplate = new Product_Template__c(Name= 'Homeworker ADSL Test',
                                                                Product_Type__c = 'Homeworker ADSL Test');
        insert pTemplate;
        //
        Asset_Template_Line__c assetTpl = new Asset_Template_Line__c(Name = 'Test', Type__c = 'test', Product_Template__c = pTemplate.Id);
        insert assetTpl;
        //
        Asset_Config_Template_Line__c configTpl = new Asset_Config_Template_Line__c(Name = 'test',
                                                                                    Type__c = 'test',
                                                                                    Asset_Type__c = 'test',
                                                                                    Product_Template__c = pTemplate.Id);
        insert configTpl;
        //
        // -----------
        PageReference page = new PageReference('/apex/CreateAssetConfigTplLine');
        Test.setCurrentPage(page);
        page.getParameters().put('AssetId', assetTpl.Id);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(configTpl);
        CreateAssetConfigTplLineController ctrl = new CreateAssetConfigTplLineController(stdController);
        ctrl.save();
    }

    static testMethod void testCreateAssetTemplateLineController() {
        // -----------
        //
        // Create a product template for the ADSL Homeworker product
        Product_Template__c pTemplate = new Product_Template__c(Name= 'Homeworker ADSL Test',
                                                                Product_Type__c = 'Homeworker ADSL Test');
        insert pTemplate;
        //
        Asset_Template_Line__c assetTpl = new Asset_Template_Line__c(Name = 'Test', Type__c = 'test', Product_Template__c = pTemplate.Id);
        //
        // -----------
        PageReference page = new PageReference('/apex/CreateAssetTemplateLine');
        Test.setCurrentPage(page);
        page.getParameters().put('productId', pTemplate.Id);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(assetTpl);
        CreateAssetTemplateLineController ctrl = new CreateAssetTemplateLineController(stdController);
        ctrl.save();
        ctrl.cancel();
    }

    static  testMethod void OpportunityHelperTest() {

        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
        newOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule

        insert newOpp;
        //
        // -----------
        // - Create a product
        Product2 newproduct = new Product2(Name = 'New Product', isActive = true);
        insert newProduct;
        // - Get the Standard Price Book
        PriceBook2 standardPriceBook = [select Id from PriceBook2 where Name = 'Standard Price Book' limit 1];
        // - Create price book entry
        PricebookEntry newPricebookEntry = new PricebookEntry(Product2Id = newproduct.Id,
                                                              PriceBook2Id = standardPriceBook.Id,
                                                              UnitPrice = 4000.00,
                                                              isActive = true);
        insert newPricebookEntry;
        // -----------
        // - Create opportunity Main line item
        OpportunityLineItem newOppMainLineItem = new OpportunityLineItem(OpportunityId = newOpp.Id,
                                                                     PriceBookEntryId = newPricebookEntry.Id,
                                                                     Quantity = 1.0,
                                                                     TotalPrice = 4000.00);
        insert newOppMainLineItem;
        // - Create opportunity Main line item
        OpportunityLineItem newOppLineItem = new OpportunityLineItem(OpportunityId = newOpp.Id,
                                                                     PriceBookEntryId = newPricebookEntry.Id,
                                                                     Quantity = 1.0,
                                                                     TotalPrice = 4000.00);
        insert newOppLineItem;
        // - A backup Main line item
        OpportunityLineItem newBackUpOppLineItem = new OpportunityLineItem(OpportunityId = newOpp.Id,
                                                                           PriceBookEntryId = newPricebookEntry.Id,
                                                                           Quantity = 1.0,
                                                                           TotalPrice = 4000.00);
        insert newBackUpOppLineItem;
        // -----------
        // Create a contact role
        OpportunityContactRole newOppContactRole = new OpportunityContactRole(OpportunityId = newOpp.Id,
                                                                              ContactId = newContact.Id,
                                                                              IsPrimary = true,
                                                                              Role = 'Technical Buyer');
        insert newOppContactRole;
        // -----------
        // Create a quote
        Pricebook2 priceBook = [Select p.Name, p.Id From Pricebook2 p where p.Name = 'Standard Price Book' limit 1];
        //
        Quote newQuote = new Quote();
        newQuote.Name = 'test';
        newQuote.Pricebook2Id = priceBook.Id;
        newQuote.OpportunityId = newOpp.Id;
        insert newQuote;
        // -----------
        // update the opportunity to Closed Won
        newOpp.SyncedQuoteId = newQuote.Id;
        update newOpp;
        //
        cscfgc__Product_Bundle__c bun = new cscfgc__Product_Bundle__c();
        bun.cscfgc__Opportunity__c = newOpp.Id;
        bun.cscfgc__Bundle_Status__c = 'Valid';
        insert bun;
        String strBunId = bun.Id;
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
        cscfgc__Attribute_Definition__c[] attdefs = attDefList;
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
                    att.cscfgc__line_item_Description__c = 'test1';
                    att.cscfgc__Value__c = '1';
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Price__c = 25;
                }
                else if (attdefs[i].Name=='Monthly Tariff') {
                    att.cscfgc__line_item_Description__c = 'test2';
                    att.cscfgc__Value__c = '25.00';
                    att.cscfgc__Display_Value__c = '£25.00';
                }
                else if (attdefs[i].Name=='Contract Term') {
                    att.cscfgc__line_item_Description__c = 'test3';
                    att.cscfgc__Value__c = '24';
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Display_Value__c = '24 Months';
                    att.cscfgc__Price__c = 0;
                }
                else if (attdefs[i].Name=='Provide Type') {
                    att.cscfgc__line_item_Description__c = 'test4';
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
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(bun);
        ProductBundleController bundleController = new ProductBundleController(standardCtrl);
        //synchronise the bundle with the opportunity
        bundleController.syncWithOpportunity();
        //
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpp);
        Map<ID,Opportunity> oppMap = OpportunityHelper.getMapOfWonOpportunities(oppList);
        OpportunityHelper.createServicesFromOpportunity(oppList, oppMap);
    }

    static testMethod void CreateMacOpportunityControllerTest() {
        //
        Account newAcc = new Account(Name = 'test Acc');
        insert newAcc;
        //
        Opportunity newOpp = new Opportunity(Name='test Opp', StageName = 'Achievement of Results', CloseDate = Date.Today(), AccountId = newAcc.id);
        insert newOpp;
        //create a test Configurator Product record
        cscfgc__Product_Bundle__c bun = new cscfgc__Product_Bundle__c();
        bun.cscfgc__Opportunity__c = newOpp.Id;
        bun.cscfgc__Bundle_Status__c = 'Valid';
        insert bun;
        String strBunId = bun.Id;
        //get product definition for new configuration
        cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(Name='SMB Landline', cscfgc__Description__c = 'SMB Landline');
        insert def;
        List<cscfgc__Attribute_Definition__c> attDefList = new List<cscfgc__Attribute_Definition__c>();
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Number of Lines', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Monthly Tariff', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Contract Term', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Provide Type', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
        insert attDefList;
        String strDefId = def.Id;
        cscfgc__Attribute_Definition__c[] attdefs = attDefList;
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
                    att.cscfgc__line_item_Description__c = 'test1';
                    att.cscfgc__Value__c = '1';
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Price__c = 25;
                }
                else if (attdefs[i].Name=='Monthly Tariff') {
                    att.cscfgc__line_item_Description__c = 'test2';
                    att.cscfgc__Value__c = '25.00';
                    att.cscfgc__Display_Value__c = '£25.00';
                }
                else if (attdefs[i].Name=='Contract Term') {
                    att.cscfgc__line_item_Description__c = 'test3';
                    att.cscfgc__Value__c = '24';
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Display_Value__c = '24 Months';
                    att.cscfgc__Price__c = 0;
                }
                else if (attdefs[i].Name=='Provide Type') {
                    att.cscfgc__line_item_Description__c = 'test4';
                    att.cscfgc__Value__c = 'New Provide';
                    att.cscfgc__Price__c = 25*12;
                    att.cscfgc__Display_Value__c = 'New Provide';
                }
                att.cscfgc__is_Active__c = true;
                attribs.add(att);
            }
        }
        insert attribs;
        //
        Order_Group__c newOG = new Order_Group__c(Opportunity__c = newOpp.id, Order_Group_Status__c = 'In progress');
        insert newOG;
        Order__c newOrder = new Order__c (Opportunity__c = newOpp.id, Product_configuration__c = config.Id, Order_Group__c = newOG.id, Account__c = newAcc.id, Order_Status__c = '', Order_Status_Reason__c = '');
        insert newOrder;
        //
        // -----------
        PageReference page = new PageReference('/apex/CreateMacOpportunity');
        Test.setCurrentPage(page);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(newOrder);
        CreateMacOpportunityController ctrl = new CreateMacOpportunityController(stdController);
        ctrl.createRenewalOpportunity();
    }
/*
    static testMethod void ProductBundleControllerTest() {

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
            cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(Name='test Product', cscfgc__Description__c = 'test');
            insert def;
            List<cscfgc__Attribute_Definition__c> attDefList = new List<cscfgc__Attribute_Definition__c>();
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Number of Lines', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Monthly Tariff', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Contract Term', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Provide Type', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            insert attDefList;
            String strDefId = def.Id;
            cscfgc__Attribute_Definition__c[] attdefs = attDefList;
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
                        att.cscfgc__line_item_Description__c = 'test1';
                        att.cscfgc__Value__c = '1';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Price__c = 25;
                    }
                    else if (attdefs[i].Name=='Monthly Tariff') {
                        att.cscfgc__line_item_Description__c = 'test2';
                        att.cscfgc__Value__c = '25.00';
                        att.cscfgc__Display_Value__c = '£25.00';
                    }
                    else if (attdefs[i].Name=='Contract Term') {
                        att.cscfgc__line_item_Description__c = 'test3';
                        att.cscfgc__Value__c = '24';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Display_Value__c = '24 Months';
                        att.cscfgc__Price__c = 0;
                    }
                    else if (attdefs[i].Name=='Provide Type') {
                        att.cscfgc__line_item_Description__c = 'test4';
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
            ApexPages.StandardController standardCtrl = new ApexPages.StandardController(bun);
            ProductBundleController bundleController = new ProductBundleController(standardCtrl);
            //synchronise the bundle with the opportunity
            bundleController.syncWithOpportunity();
            bundleController.addNewConfiguration();
            bundleController.deleteConfiguration();
            bundleController.editConfiguration();
            bundleController.getAllLineItems();
            bundleController.getAllProductConfigurations();
            bundleController.getBundle();
            bundleController.getConfigurations();
            bundleController.getHasLinkedQuotes();
            bundleController.getLinkedQuotes();
            bundleController.viewConfiguration();
            ProductBundleController.stringToDate('10/03/2010');
            ProductBundleController.getProductConfigurationMap(strBunId);
            //-----------------------------------------
            //create a test Configurator Product record
            cscfgc__Product_Bundle__c bun1 = new cscfgc__Product_Bundle__c();
            bun1.cscfgc__Opportunity__c = strOpptyId;
            bun1.cscfgc__Bundle_Status__c = 'Valid';
            insert bun1;
            strBunId = bun1.Id;
            //create new configuration
            cscfgc__Product_Configuration__c config1 = new cscfgc__Product_Configuration__c();
            config1.cscfgc__Product_Bundle__c = strBunId;
            config1.cscfgc__Product_Definition__c = strDefId;
            config1.cscfgc__Configuration_Status__c = 'Valid';
            config1.cscfgc__Unit_Price__c = 10;
            config1.cscfgc__Quantity__c = 1;
            config1.cscfgc__Recurrence_Frequency__c = 12;
            insert config1;
            String strConfigId1 = config1.Id;
            //create associated attributes
            cscfgc__Attribute__c[] attribs1 = new cscfgc__Attribute__c[0];
            for (integer i=0; i<attdefs.size(); i++) {
                if (attdefs[i].cscfgc__is_Line_Item__c || attdefs[i].cscfgc__Required__c) {
                    cscfgc__Attribute__c att = new cscfgc__Attribute__c();
                    att.cscfgc__Product_Configuration__c = strConfigId1;
                    att.cscfgc__Attribute_Definition__c = attdefs[i].Id;
                    att.Name = attdefs[i].Name;
                    att.cscfgc__is_Line_Item__c = attdefs[i].cscfgc__is_Line_Item__c;
                    if (attdefs[i].Name=='Number of Lines') {
                        att.cscfgc__line_item_Description__c = 'test1';
                        att.cscfgc__Value__c = '1';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Price__c = 25;
                    }
                    else if (attdefs[i].Name=='Monthly Tariff') {
                        att.cscfgc__line_item_Description__c = 'test2';
                        att.cscfgc__Value__c = '25.00';
                        att.cscfgc__Display_Value__c = '£25.00';
                    }
                    else if (attdefs[i].Name=='Contract Term') {
                        att.cscfgc__line_item_Description__c = 'test3';
                        att.cscfgc__Value__c = '24';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Display_Value__c = '24 Months';
                        att.cscfgc__Price__c = 0;
                    }
                    else if (attdefs[i].Name=='Provide Type') {
                        att.cscfgc__line_item_Description__c = 'test4';
                        att.cscfgc__Value__c = 'New Provide';
                        att.cscfgc__Price__c = 25*12;
                        att.cscfgc__Display_Value__c = 'New Provide';
                    }
                    att.cscfgc__is_Active__c = true;
                    attribs1.add(att);
                }
            }
            insert attribs1;
            //retrieve a fresh list of the product configurations to check output in debug
            cscfgc__Product_Configuration__c[] prd1 = [SELECT Id, Name, cscfgc__description__c, cscfgc__serial_number__c, cscfgc__attribute_name__c,
                    cscfgc__index__c, cscfgc__unit_price__c, cscfgc__quantity__c, cscfgc__total_price__c, cscfgc__recurrence_frequency__c, cscfgc__parent_configuration__c,
                    cscfgc__product_bundle__c, cscfgc__product_definition__c, cscfgc__product_definition__r.cscfgc__description__c, cscfgc__configuration_status__c,
                    Monthly_Recurring_Charge__c, One_off_Charge__c,
                            (select name, cscfgc__attribute_definition__c, cscfgc__value__c, cscfgc__cascade_value__c, cscfgc__display_value__c,
                            cscfgc__is_active__c, cscfgc__is_line_item__c, cscfgc__line_item_description__c, cscfgc__line_item_sequence__c, cscfgc__price__c, cscfgc__recurring__c
                            from cscfgc__Attributes__r order by cscfgc__line_item_sequence__c)
                    FROM cscfgc__Product_Configuration__c WHERE cscfgc__Product_Bundle__c = :strBunId];            //ApexPages.StandardController prdcontroller = new ApexPages.StandardController(prd);
            for (integer i=0; i<prd1.size(); i++) {
                System.debug('### OUTPUT >>>>> prd:'+prd[i]);
                System.debug('### OUTPUT >>>>> atts:'+prd[i].cscfgc__Attributes__r);
            }

            //### move to the Bundle Controller page
            PageReference pgBundleDetail1 = new PageReference('apex/ConfigurationBundleDetail?id='+strBunId);
            Test.setCurrentPage(pgBundleDetail1);
            ApexPages.StandardController standardCtrl1 = new ApexPages.StandardController(bun1);
            ProductBundleController bundleController1 = new ProductBundleController(standardCtrl);
            //synchronise the bundle with the opportunity
            bundleController1.syncWithOpportunity();
            bundleController1.addNewConfiguration();
            bundleController1.deleteConfiguration();
            bundleController1.editConfiguration();
            bundleController1.getAllLineItems();
            bundleController1.getAllProductConfigurations();
            bundleController1.getBundle();
            bundleController1.getConfigurations();
            bundleController1.getHasLinkedQuotes();
            bundleController1.getLinkedQuotes();
            bundleController1.viewConfiguration();
            //------------------------
            ProductBundleManager.getConfigurationsForBundle(bun);
            ProductBundleManager.getBundleStatusForNewConfig(bun,null);

            ProductBundleManager.getBundleStatusForNewConfig(bun,new cscfgc.ProductConfiguration(config1));

            cscfgc__Product_Bundle__c newBundle = new cscfgc__Product_Bundle__c();
            ProductBundleManager.getBundleStatusForNewConfig(newBundle,new cscfgc.ProductConfiguration(config1));

            ProductBundleManager.copyBundleToOpportunity(strBunId,opp.Id,'test bundle');
/*          ProductBundleManager.copyConfigAndChildrenToBunlde(config1.Id,strBunId);
            ProductBundleManager.copyConfigurationToBundle(config1.Id,strBunId);
            List<String> configIdList = new List<String>();
            configIdList.add(config1.Id);
            ProductBundleManager.getProductConfigurationSObjectsByIdList(configIdList);
*/
/*            List<Id> ids = new List<Id>();
            ProductBundleManager.getProductConfigurationsByIdList(ids);
            //
        Test.StopTest();
    }
*/
    static testMethod void ProductBundleControllerTest1() {

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
            cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(Name='test Product', cscfgc__Description__c = 'test');
            insert def;
            List<cscfgc__Attribute_Definition__c> attDefList = new List<cscfgc__Attribute_Definition__c>();
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Number of Lines', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Monthly Tariff', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Contract Term', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Provide Type', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            insert attDefList;
            String strDefId = def.Id;
            cscfgc__Attribute_Definition__c[] attdefs = attDefList;
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
                        att.cscfgc__line_item_Description__c = 'test1';
                        att.cscfgc__Value__c = '1';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Price__c = 25;
                    }
                    else if (attdefs[i].Name=='Monthly Tariff') {
                        att.cscfgc__line_item_Description__c = 'test2';
                        att.cscfgc__Value__c = '25.00';
                        att.cscfgc__Display_Value__c = '£25.00';
                    }
                    else if (attdefs[i].Name=='Contract Term') {
                        att.cscfgc__line_item_Description__c = 'test3';
                        att.cscfgc__Value__c = '24';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Display_Value__c = '24 Months';
                        att.cscfgc__Price__c = 0;
                    }
                    else if (attdefs[i].Name=='Provide Type') {
                        att.cscfgc__line_item_Description__c = 'test4';
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
                            (SELECT name, cscfgc__attribute_definition__c, cscfgc__value__c, cscfgc__cascade_value__c, cscfgc__display_value__c,
                            cscfgc__is_active__c, cscfgc__is_line_item__c, cscfgc__line_item_description__c, cscfgc__line_item_sequence__c, cscfgc__price__c, cscfgc__recurring__c
                            FROM cscfgc__Attributes__r ORDER BY cscfgc__line_item_sequence__c)
                    FROM cscfgc__Product_Configuration__c WHERE cscfgc__Product_Bundle__c = :strBunId];            //ApexPages.StandardController prdcontroller = new ApexPages.StandardController(prd);
            for (integer i=0; i<prd.size(); i++) {
                System.debug('### OUTPUT >>>>> prd:'+prd[i]);
                System.debug('### OUTPUT >>>>> atts:'+prd[i].cscfgc__Attributes__r);
            }

            //### move to the Bundle Controller page
            PageReference pgBundleDetail = new PageReference('apex/ConfigurationBundleDetail?id='+strBunId);
            Test.setCurrentPage(pgBundleDetail);
            ApexPages.StandardController standardCtrl = new ApexPages.StandardController(bun);
            ProductBundleController bundleController = new ProductBundleController(standardCtrl);
            //synchronise the bundle with the opportunity
            bundleController.syncWithOpportunity();
            bundleController.addNewConfiguration();
            bundleController.deleteConfiguration();
            bundleController.editConfiguration();
            bundleController.getAllLineItems();
            bundleController.getAllProductConfigurations();
            bundleController.getBundle();
            bundleController.getConfigurations();
            bundleController.getHasLinkedQuotes();
            bundleController.getLinkedQuotes();
            bundleController.viewConfiguration();
            ProductBundleController.stringToDate('10/03/2010');
            ProductBundleController.getProductConfigurationMap(strBunId);
            //-----------------------------------------
            //create a test Configurator Product record
            cscfgc__Product_Bundle__c bun1 = new cscfgc__Product_Bundle__c();
            bun1.cscfgc__Opportunity__c = strOpptyId;
            bun1.cscfgc__Bundle_Status__c = 'Valid';
            insert bun1;
            strBunId = bun1.Id;
            //create new configuration
            cscfgc__Product_Configuration__c config1 = new cscfgc__Product_Configuration__c();
            config1.cscfgc__Product_Bundle__c = strBunId;
            config1.cscfgc__Product_Definition__c = strDefId;
            config1.cscfgc__Configuration_Status__c = 'Valid';
            config1.cscfgc__Unit_Price__c = 10;
            config1.cscfgc__Quantity__c = 1;
            config1.cscfgc__Recurrence_Frequency__c = 12;
            insert config1;
            String strConfigId1 = config1.Id;
            //create associated attributes
            cscfgc__Attribute__c[] attribs1 = new cscfgc__Attribute__c[0];
            for (integer i=0; i<attdefs.size(); i++) {
                if (attdefs[i].cscfgc__is_Line_Item__c || attdefs[i].cscfgc__Required__c) {
                    cscfgc__Attribute__c att = new cscfgc__Attribute__c();
                    att.cscfgc__Product_Configuration__c = strConfigId1;
                    att.cscfgc__Attribute_Definition__c = attdefs[i].Id;
                    att.Name = attdefs[i].Name;
                    att.cscfgc__is_Line_Item__c = attdefs[i].cscfgc__is_Line_Item__c;
                    if (attdefs[i].Name=='Number of Lines') {
                        att.cscfgc__line_item_Description__c = 'test1';
                        att.cscfgc__Value__c = '1';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Price__c = 25;
                    }
                    else if (attdefs[i].Name=='Monthly Tariff') {
                        att.cscfgc__line_item_Description__c = 'test2';
                        att.cscfgc__Value__c = '25.00';
                        att.cscfgc__Display_Value__c = '£25.00';
                    }
                    else if (attdefs[i].Name=='Contract Term') {
                        att.cscfgc__line_item_Description__c = 'test3';
                        att.cscfgc__Value__c = '24';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Display_Value__c = '24 Months';
                        att.cscfgc__Price__c = 0;
                    }
                    else if (attdefs[i].Name=='Provide Type') {
                        att.cscfgc__line_item_Description__c = 'test4';
                        att.cscfgc__Value__c = 'New Provide';
                        att.cscfgc__Price__c = 25*12;
                        att.cscfgc__Display_Value__c = 'New Provide';
                    }
                    att.cscfgc__is_Active__c = true;
                    attribs1.add(att);
                }
            }
            insert attribs1;
            //retrieve a fresh list of the product configurations to check output in debug
            cscfgc__Product_Configuration__c[] prd1 = [SELECT Id, Name, cscfgc__description__c, cscfgc__serial_number__c, cscfgc__attribute_name__c,
                    cscfgc__index__c, cscfgc__unit_price__c, cscfgc__quantity__c, cscfgc__total_price__c, cscfgc__recurrence_frequency__c, cscfgc__parent_configuration__c,
                    cscfgc__product_bundle__c, cscfgc__product_definition__c, cscfgc__product_definition__r.cscfgc__description__c, cscfgc__configuration_status__c,
                    Monthly_Recurring_Charge__c, One_off_Charge__c,
                            (select name, cscfgc__attribute_definition__c, cscfgc__value__c, cscfgc__cascade_value__c, cscfgc__display_value__c,
                            cscfgc__is_active__c, cscfgc__is_line_item__c, cscfgc__line_item_description__c, cscfgc__line_item_sequence__c, cscfgc__price__c, cscfgc__recurring__c
                            from cscfgc__Attributes__r order by cscfgc__line_item_sequence__c)
                    FROM cscfgc__Product_Configuration__c WHERE cscfgc__Product_Bundle__c = :strBunId];            //ApexPages.StandardController prdcontroller = new ApexPages.StandardController(prd);
            for (integer i=0; i<prd1.size(); i++) {
                System.debug('### OUTPUT >>>>> prd:'+prd[i]);
                System.debug('### OUTPUT >>>>> atts:'+prd[i].cscfgc__Attributes__r);
            }

            //### move to the Bundle Controller page
            PageReference pgBundleDetail1 = new PageReference('apex/ConfigurationBundleDetail?id='+strBunId);
            Test.setCurrentPage(pgBundleDetail1);
            ApexPages.StandardController standardCtrl1 = new ApexPages.StandardController(bun1);
            ProductBundleController bundleController1 = new ProductBundleController(standardCtrl);
            //synchronise the bundle with the opportunity
            bundleController1.syncWithOpportunity();
            bundleController1.addNewConfiguration();
            bundleController1.deleteConfiguration();
            bundleController1.editConfiguration();
            bundleController1.getAllLineItems();
            bundleController1.getAllProductConfigurations();
            bundleController1.getBundle();
            bundleController1.getConfigurations();
            bundleController1.getHasLinkedQuotes();
            bundleController1.getLinkedQuotes();
            bundleController1.viewConfiguration();
            //------------------------
            bun.cscfgc__Bundle_Status__c = 'Incomplete';
            update bun;
/*
            ProductBundleManager.getConfigurationsForBundle(bun);
            ProductBundleManager.getBundleStatusForNewConfig(bun, new cscfgc.ProductConfiguration(config1));
            ProductBundleManager.copyBundleToOpportunity(strBunId,opp.Id,'test bundle');
            ProductBundleManager.copyConfigAndChildrenToBunlde(config1.Id,strBunId);
            ProductBundleManager.copyConfigurationToBundle(config1.Id,strBunId);
            List<String> configIdList1 = new List<String>();
            configIdList1.add(config1.Id);
            ProductBundleManager.getProductConfigurationSObjectsByIdList(configIdList1);
*/
            //
        Test.StopTest();
    }

    static testMethod void ProductBundleControllerTest2() {

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

        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = acc.Id);
        insert newContact;
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
            cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(Name='test Product', cscfgc__Description__c = 'test');
            insert def;
            List<cscfgc__Attribute_Definition__c> attDefList = new List<cscfgc__Attribute_Definition__c>();
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Number of Lines', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Monthly Tariff', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Contract Term', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            attDefList.add(new cscfgc__Attribute_Definition__c(Name='Provide Type', cscfgc__Product_Definition__c = def.Id, cscfgc__is_Line_Item__c = true));
            insert attDefList;
            String strDefId = def.Id;
            cscfgc__Attribute_Definition__c[] attdefs = attDefList;
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
                        att.cscfgc__line_item_Description__c = 'test1';
                        att.cscfgc__Value__c = '1';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Price__c = 25;
                    }
                    else if (attdefs[i].Name=='Monthly Tariff') {
                        att.cscfgc__line_item_Description__c = 'test2';
                        att.cscfgc__Value__c = '25.00';
                        att.cscfgc__Display_Value__c = '£25.00';
                    }
                    else if (attdefs[i].Name=='Contract Term') {
                        att.cscfgc__line_item_Description__c = 'test3';
                        att.cscfgc__Value__c = '24';
                        att.cscfgc__Recurring__c = true;
                        att.cscfgc__Display_Value__c = '24 Months';
                        att.cscfgc__Price__c = 0;
                    }
                    else if (attdefs[i].Name=='Provide Type') {
                        att.cscfgc__line_item_Description__c = 'test4';
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
            ApexPages.StandardController standardCtrl = new ApexPages.StandardController(bun);
            ProductBundleController bundleController = new ProductBundleController(standardCtrl);
            //synchronise the bundle with the opportunity
            bundleController.syncWithOpportunity();
            bundleController.addNewConfiguration();
            bundleController.deleteConfiguration();
            bundleController.editConfiguration();
            bundleController.getAllLineItems();
            bundleController.getAllProductConfigurations();
            bundleController.getBundle();
            bundleController.getConfigurations();
            bundleController.getHasLinkedQuotes();
            bundleController.getLinkedQuotes();
            bundleController.viewConfiguration();
            ProductBundleController.stringToDate('10/03/2010');
            ProductBundleController.getProductConfigurationMap(strBunId);
            //-----------------------------------------
            // Create a contact role
            OpportunityContactRole newOppContactRole = new OpportunityContactRole(OpportunityId = opp.Id,
                                                                                  ContactId = newContact.Id,
                                                                                  IsPrimary = true,
                                                                                  Role = 'Billing');
            insert newOppContactRole;
            // -----------
            // Close win the Opportunity
            opp.StageName = 'Achievement of Results';
            update opp;
        Test.StopTest();
    }
}