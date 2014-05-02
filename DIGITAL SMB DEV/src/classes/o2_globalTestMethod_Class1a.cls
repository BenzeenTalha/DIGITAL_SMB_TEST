public with sharing class o2_globalTestMethod_Class1a 
{
    
    
    //==================================================
    static testMethod void O2_linkage_Reg_From_Acc_CE() 
    //================================================== 
    {
        Account acc = new Account(name = 'test');
        insert acc;
        acc.DISE_Group_Code_Account_No_1__c = '4321';
        acc.Register_Requested__c = true;
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        O2_linkage_Reg_From_Acc_CE link_reg = new O2_linkage_Reg_From_Acc_CE(sc);
        link_reg.checkOARRegistered();
        acc.Register_Requested__c = false;
        link_reg.checkOARRegistered();
        acc.OAR_Account_Reference_1__c = '1234';
        link_reg.checkOARRegistered();
        link_reg.getRegisteredStatus();
        acc.Register_Requested__c = false;
        link_reg.getRegisteredStatus();
    }
    
    //==================================================
    static testMethod void O2_linkage_billing_code() 
    //==================================================
    {
        O2_linkage_billing_code rec = new O2_linkage_billing_code('accGrpCode','resp','status',DateTime.now(), 'ref');
    }
    
    //==================================================
    static testMethod void O2_linkage_ru() 
    //==================================================
    {
        O2_linkage_run_once.validationRunning = true;
    }
    
    //==================================================
    static testMethod void MobilisationSpec() 
    //==================================================
    {
        MobilisationSpec mobspec = new MobilisationSpec();
        mobspec.setSelected(true);
        mobspec.getSelected();
    }
    
    //==================================================
    static testMethod void Accept_Reject_Controller() 
    //==================================================    
    {
        O2_linkage_configuration.TESTING = true;
        Account a = new Account(Name = 'acc name', OwnerId = UserInfo.getUserId());
        insert a;
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        Accept_Reject_Controller arc = new Accept_Reject_Controller(sc);
        arc.accept();
        arc.cancelSearch();
        arc.getNotValidAccount();
        arc.getValidAccount();
        arc.reject();
    } // end test1

    //==================================================
    static testMethod void Application_Sale_Controller() 
    //==================================================    
    {
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;
                
        // Create an account validation entry so that we can create an account with valid billing code
        List<Account_Validation_Table__c> validEntries = new List<Account_Validation_Table__c>();
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY1',
                                                            Full_Account__c = 'TUKKY1',
                                                            Account__c = 'TUKKY1'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY2',
                                                            Full_Account__c = 'TUKKY2',
                                                            Account__c = 'TUKKY2'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY3',
                                                            Full_Account__c = 'TUKKY3',
                                                            Account__c = 'TUKKY3'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY4',
                                                            Full_Account__c = 'TUKKY4',
                                                            Account__c = 'TUKKY4'));                                                                                                                                                                                    

        insert validEntries;    
            
        // Create an account with the correct fields for a register
        Account registeringAccount = new Account(   DISE_Group_Code_Account_No_1__c = 'TUKKY1',
                                                    DISE_Group_Code_Account_No_2__c = 'TUKKY2',
                                                    DISE_Group_Code_Account_No_3__c = 'TUKKY3',
                                                    DISE_Group_Code_Account_No_4__c = 'TUKKY4',
                                                    Name = 'TUKKY1_TEST',
                                                    // START - Added Darren Sabey 5/1/2011
                                                    Contract_End_Date__c = System.today().addDays(365),
                                                    // END - Added Darren Sabey 5/1/2011
                                                    Status__c = 'Customer',
                                                    Contract_Start_Date__c = Date.Today(),
                                                    Contract_Duration__c = '4',
                                                    Date_Effective_From__c = Date.Today(),
                                                    BillingStreet = '5 Hamilton Street',
                                                    BillingCity = 'Exeter',
                                                    BillingPostalCode = 'EX1 1AA',
                                                    BillingState='Devon');
                                                    
        insert registeringAccount;
        
        // Now create an opportunity for this account and register via the opportunity
        Opportunity registeringOpp = new Opportunity(AccountId = registeringAccount.Id,
                                                        Name = 'TUKKY1_TEST_OPP',
                                                        Type = 'Existing Business',
                                                        StageName = 'Avareness of Needs',
                                                        CloseDate = Date.Today(),
                                                        LeadSource = 'LBM',
                                                        Use_of_CCV__c = 'CCV Not Used',
                                                        TotalOpportunityQuantity = 1.0,
                                                        CCV_Not_used_reason__c = 'Run Rate',
                                                        CCV_Not_used_comments__c = 'This is the comment'
                                                        );
        insert registeringOpp;
        
        // Put the opp id as the page parameter
        ApexPages.currentPage().getParameters().put('id',registeringOpp.Id);
        
        // Create a standard set controller
        List<O2_Product_Detail__c> productDetailLines = new List<O2_Product_Detail__c>();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(productDetailLines);
        Application_Sale_Controller apSaleCont = new Application_Sale_Controller(stdSetController);

        apSaleCont.getNoApplicationSalesExist();
        apSaleCont.getApplicationSalesExist();
        apSaleCont.cancelList();
        apSaleCont.step1();
        apSaleCont.step2();
        apSaleCont.step3();
        //TODO - commented out as it is broken
        //apSaleCont.step4(); 
        apSaleCont.getMobSpecs();
        apSaleCont.getNoMobSpecsExist();
        apSaleCont.getMobSpecsExist();
        apSaleCont.getSelectedId();
        apSaleCont.getMobSpecSelectedId();
        apSaleCont.getSelectedName();
        apSaleCont.getMobSpecSelectedName();
    } // end test1
    
    //==================================================
    static testMethod void getAppSalesTest() 
    //==================================================
    {
        
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;
        
        // Make system think we are on sandbox to go down sandbox branches
        // First get the current system - this will force configuration initialisers to run
        O2_linkage_configuration.getCurrentSystem();
        
        // Override the value for sandbox
        O2_linkage_configuration.setCurrentSystem(Label.Sandbox_String);
            
        appSalesO2CoUkChoice.getApplicationSales();
        
        // Override the value for production
        O2_linkage_configuration.setCurrentSystem(Label.Production_String);     
        appSalesO2CoUkChoice.getApplicationSales();
           
    } // getAppSalesTest

    //==================================================
    static testMethod void createSaleTest() 
    //==================================================
    {    
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;
        
        // Make system think we are on sandbox to go down sandbox branches
        // First get the current system - this will force configuration initialisers to run
        O2_linkage_configuration.getCurrentSystem();
        
        // Override the value for sandbox
        O2_linkage_configuration.setCurrentSystem(Label.Sandbox_String);
        
        // Create an account validation entry so that we can create an account with valid billing code
        List<Account_Validation_Table__c> validEntries = new List<Account_Validation_Table__c>();
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY1',
                                                            Full_Account__c = 'TUKKY1',
                                                            Account__c = 'TUKKY1'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY2',
                                                            Full_Account__c = 'TUKKY2',
                                                            Account__c = 'TUKKY2'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY3',
                                                            Full_Account__c = 'TUKKY3',
                                                            Account__c = 'TUKKY3'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY4',
                                                            Full_Account__c = 'TUKKY4',
                                                            Account__c = 'TUKKY4'));                                                                                                                                                                                    

        insert validEntries;
                                                                                            
        // Create an account with the correct fields for a register
        Account registeringAccount = new Account(   DISE_Group_Code_Account_No_1__c = 'TUKKY1',
                                                    DISE_Group_Code_Account_No_2__c = 'TUKKY2',
                                                    DISE_Group_Code_Account_No_3__c = 'TUKKY3',
                                                    DISE_Group_Code_Account_No_4__c = 'TUKKY4',
                                                    Name = 'TUKKY1_TEST',
                                                    // START - Added Darren Sabey 5/1/2011
                                                    Contract_End_Date__c = System.today().addDays(365),
                                                    // END - Added Darren Sabey 5/1/2011
                                                    Status__c = 'Customer',
                                                    Contract_Start_Date__c = Date.Today(),
                                                    Contract_Duration__c = '4',
                                                    Date_Effective_From__c = Date.Today(),
                                                    BillingStreet = '5 Hamilton Street',
                                                    BillingCity = 'Exeter',
                                                    BillingPostalCode = 'EX1 1AA',
                                                    BillingState='Devon');
                                                    
        insert registeringAccount;
        
        // Now create an opportunity for this account and register via the opportunity
        Opportunity registeringOpp = new Opportunity(AccountId = registeringAccount.Id,
                                                        Name = 'TUKKY1_TEST_OPP',
                                                        Type = 'Existing Business',
                                                        StageName = 'Avareness of Needs',
                                                        CloseDate = Date.Today(),
                                                        LeadSource = 'LBM',
                                                        Use_of_CCV__c = 'CCV Not Used',
                                                        TotalOpportunityQuantity = 1.0,
                                                        CCV_Not_used_reason__c = 'Run Rate',
                                                        CCV_Not_used_comments__c = 'This is the comment');
        insert registeringOpp;
        
        // Make it go down the COP check
        Contact registeringCon = new Contact(   Salutation = 'Mr',
                                                Firstname = 'Paul',
                                                Lastname = 'Tarpey',
                                                Buying_Role__c = 'COP',
                                                MailingStreet = '1 High Street',
                                                MailingState = 'Wiltshire',
                                                MailingPostalCode = 'SN1 1AA',
                                                MailingCity = 'Bristol',
                                                MailingCountry = 'UK',
                                                Phone = '01793121212',
                                                MobilePhone = '07981221212',
                                                AccountId = registeringAccount.Id,
                                                Email = 'a@b.com',
                                                Title = 'Manager',
                                                CLCMagazine__c = true,
                                                CLCMicrosite__c = true,
                                                CLCeNews__c = true,
                                                CLCDirectMail__c = true,
                                                CLCEvents__c = true,
                                                CLCWhitePapers__c = true,
                                                CLCProductWorkshop__c = true,
                                                CLCResearchForums__c = true,
                                                CLCEndUser__c = true,
                                                CSIOptOut__c = true);
                                                
        insert registeringCon;                                                  
        
        appSalesO2CoUkChoice.createSale(registeringOpp.Id, '1234', Date.today(), 10.0, 'fred', registeringCon.Id, '36', 'my notes', registeringAccount.Id);

        // Override the value for production
        O2_linkage_configuration.setCurrentSystem(Label.Production_String);
        appSalesO2CoUkChoice.createSale(registeringOpp.Id, '1234', Date.today(), 10.0, 'fred', registeringCon.Id, '36', 'my notes', registeringAccount.Id);
    } // end createSaleTest

    //==================================================
    static testMethod void mobSpecTest() 
    //==================================================
    
    { 
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;
        
        // Make system think we are on sandbox to go down sandbox branches
        // First get the current system - this will force configuration initialisers to run
        O2_linkage_configuration.getCurrentSystem();
        
        // Override the value for sandbox
        O2_linkage_configuration.setCurrentSystem(Label.Sandbox_String);
        appSalesO2CoUkChoice.getMobilisationSpecialists();
        
        // Override the value for production
        O2_linkage_configuration.setCurrentSystem(Label.Sandbox_String);        
        appSalesO2CoUkChoice.getMobilisationSpecialists();
    } // end mobSpecTest
    
    //==================================================
    static testMethod void TriggerAndInsert1() 
    //==================================================
    {   
      boolean debugit = true;
      Integer HierarchyCount;
      //Company_Hierarchy__c PC, UPC;
      String               sParentID, sParentCompany, sUPID, sUPCompany;
      //
        Company_Hierarchy__c[] CompaniesToClearDown = [select id from Company_Hierarchy__c where Name like 'SWPS000142%'];
        //
        if (CompaniesToClearDown.size() > 0)
        {
           delete CompaniesToClearDown;
        }   
        HierarchyCount = [Select Count() from Company_Hierarchy__c Where Name like 'SWPS000142%'];
         System.assertEquals(0, HierarchyCount);
        //  
        //setupCompany (pName, pCompanyNumber, pParentCompany, pParentCompanyID, pUltimateParentCompany, pUltimateParentCompanyID, pLevel)
        // 
        // Scenario 157 - Add a record to the company hierarchy without linking it to a parent with a hierarchy level of 0
        if (debugit){system.debug('=== Scenario 157 ');}
        Company_Hierarchy__c Company_s157 = TestUtilities.setupCompany('SWPS000142_s157','s157','',null,'',null,0);
        HierarchyCount = [Select Count() from Company_Hierarchy__c Where Name like 'SWPS000142%'];
        System.assertEquals(1, HierarchyCount);
        //
        // Scenario 158 - Add a record to the company hierarchy without linking it to a parent with a hierarchy level of 1
        if (debugit){system.debug('=== Scenario 158 ');}
        Company_Hierarchy__c Company_s158 = TestUtilities.setupCompany('SWPS000142_s158','s158','',null,'',null,1);
        HierarchyCount = [Select Count() from Company_Hierarchy__c Where Name like 'SWPS000142%'];
        System.assertEquals(2, HierarchyCount);
        //
        //setupCompany (pName, pCompanyNumber, pParentCompany, pParentCompanyID, pUltimateParentCompany, pUltimateParentCompanyID, pLevel)
        // 
        // Scenario 160 - Add a record with parent ID but no parent company number.Check Parent Number gets added to s160
        if (debugit){system.debug('=== Scenario 160 ');}        
        // Get ID of Parent - use s157 in this case
        Company_Hierarchy__c[] s157ID = [select ID from Company_Hierarchy__c Where Company_Number__c = 's157' limit 1];
        // Create company 160. Set the Parent ID to the ID of s157 
        Company_Hierarchy__c Company_s160 = TestUtilities.setupCompany('SWPS000142_s160','s160','', s157ID[0].ID,'',null,0);
        // Check we now have 3 records for this user story
        HierarchyCount = [Select Count() from Company_Hierarchy__c Where Name like 'SWPS000142%'];
        System.assertEquals(3, HierarchyCount);
        // Read the s160 record using the Parent Id and make sure that the Parent Company field got updated even tho we didn't specify it
        Company_Hierarchy__c[] s160ID = [Select Parent_Company__c from Company_Hierarchy__c Where Company_Number__c = 's160' limit 1];
        System.assertEquals(s160ID[0].Parent_Company__c, 's157');
        //
        //setupCompany (pName, pCompanyNumber, pParentCompany, pParentCompanyID, pUltimateParentCompany, pUltimateParentCompanyID, pLevel)
        // 
        // Scenario 161 - Add a record with a valid parent Company Number (s157), but with no Parent ID. Verify that the Parent ID gets added.
        if (debugit){system.debug('=== Scenario 161 ');}
        Company_Hierarchy__c Company_s161 = TestUtilities.setupCompany('SWPS000142_s161','s161','s157', null,'',null,0);
        // check we have the correct number of records
        HierarchyCount = [Select Count() from Company_Hierarchy__c Where Name like 'SWPS000142%'];
        System.assertEquals(4, HierarchyCount);
        // Read the record back to get the Parent Company Id and check it is the Id of s157 even tho we didn't specify it
        Company_Hierarchy__c[] s161ID = [Select Parent_Company_Id__c from Company_Hierarchy__c Where Company_Number__c = 's161' limit 1];
        System.assertEquals(s157ID[0].ID, s161ID[0].Parent_Company_Id__c);
        //
        //setupCompany (pName, pCompanyNumber, pParentCompany, pParentCompanyID, pUltimateParentCompany, pUltimateParentCompanyID, pLevel)
        // 
        // Scenario 162 - Add a record with a parent ID & Parent Company No. but no ultimate parent - use s157 in this case
        if (debugit){system.debug('=== Scenario 162 ');}        
        Company_Hierarchy__c Company_s162 = TestUtilities.setupCompany('SWPS000142_s162','s162','s157',s157ID[0].ID,'',null,2);
        // check we have the correct number of records
        HierarchyCount = [Select Count() from Company_Hierarchy__c Where Company_Number__c = 's162' and Parent_Company__c = 's157' and Parent_Company_ID__c = :s157ID[0].ID];
        System.assertEquals(1, HierarchyCount);
        // Read the record back to get the Ultimate Parent Company Id and check it is the Id of s157 even tho we didn't specify it
        Company_Hierarchy__c[] s162ID = [Select ID, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c from Company_Hierarchy__c Where Company_Number__c = 's162' limit 1];
        System.assertEquals(s157ID[0].ID, s162ID[0].Ultimate_Parent_Company_Id__c);
        System.assertEquals('s157', s162ID[0].Ultimate_Parent_Company__c);
        //
        // Scenarion s163 - Add a record with a valid Parent Company Number and a corresponding, valid ultimate parent company number. Check Id's get added even tho not specified
        if (debugit){system.debug('=== Scenario 163 ');}        
        // Make s157 --> s162 --> s163
        // We already know s157's ID and s162's ID from Scenarion 162 above === ORDER DEPENDENT ===
        // Company_Hierarchy__c[] s162ID = [select ID, Company_Number__c, Parent_Company_Id__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_ID__c from Company_Hierarchy__c Where Company_Number__c = 's162' limit 1];
        Company_Hierarchy__c Company_s163 = TestUtilities.setupCompany('SWPS000142_s163','s163','s162', null,'s157',null,0);
        Company_Hierarchy__c[] s163 = [Select ID, Parent_Company_Id__c, Parent_Company__c, Ultimate_Parent_Company_Id__c, Ultimate_Parent_Company__c from Company_Hierarchy__c Where Company_Number__c = 's163' limit 1];
        System.assertEquals(s163[0].Parent_Company_Id__c, s162ID[0].ID);
        System.assertEquals(s163[0].Ultimate_Parent_Company_Id__c, s157ID[0].ID);
        //
        // Scenarion s164 - Add a record with a valid Parent Company ID and a valid ultimate Parent ID - Then check the company number & UP Number got added even tho not specified
        if (debugit){system.debug('=== Scenario 164 ');}        
        // Make s157 --> s162 --> s164 
        Company_Hierarchy__c Company_s164 = TestUtilities.setupCompany('SWPS000142_s164','s164','',s162ID[0].ID,'',s157ID[0].ID, 0);
        Company_Hierarchy__c[] s164ID = [Select ID, Parent_Company__c, Ultimate_Parent_Company__c from Company_Hierarchy__c Where Company_Number__c = 's164' limit 1];
        System.assertEquals(s164ID[0].Parent_Company__c, 's162');
        System.assertEquals(s164ID[0].Ultimate_Parent_Company__c, 's157');
        //
        // Scenarion s165 - Add a record which references itself as the parent using the parent company field.
        if (debugit){system.debug('=== Scenario 165 ');}        
        // Set s165 up with the same parent as itself
        Company_Hierarchy__c Company_s165 = TestUtilities.setupCompany('SWPS000142_s165','s165','s165',null,'s165',null,0);
        Company_Hierarchy__c[] s165ID = [Select ID, Company_Number__c, Parent_Company__c, Parent_Company_Id__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c from Company_Hierarchy__c Where Company_Number__c = 's165' limit 1];
        System.assertEquals(s165ID[0].Parent_Company__c, s165ID[0].Company_Number__c);
        System.assertEquals(s165ID[0].Ultimate_Parent_Company__c, s165ID[0].Company_Number__c);
        System.assertEquals(s165ID[0].Parent_Company_Id__c, null);
        System.assertEquals(s165ID[0].Ultimate_Parent_Company_Id__c, null);


        //setupCompany (pName, pCompanyNumber, pParentCompany, pParentCompanyID, pUltimateParentCompany, pUltimateParentCompanyID, pLevel)
        // 
        // Scenarion s166 - Move a parent record to a different hierarchy with a different ultimate parent.
        if (debugit){system.debug('=== Scenario 166 ');}        
        // Set up s157 --> s160 --> s166 Then change s160 to have parent s158. Check s160 has new parent and s166 & has new UP      Company_Hierarchy__c Company_s165 = TestUtilities.setupCompany('SWPS000142_s165','s165','s165',null,'s165',null,0);
        Company_Hierarchy__c Company_s166 = TestUtilities.setupCompany('SWPS000142_s166','s166','s160',null,'s157',null,0);
        Company_Hierarchy__c[] s160UPD = [Select ID, Company_Number__c, Parent_Company__c, Parent_Company_Id__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c from Company_Hierarchy__c Where Company_Number__c = 's160' limit 1];
        s160UPD[0].Parent_Company__c = 's158';
        s160UPD[0].Parent_Company_Id__c = null;
        s160UPD[0].Ultimate_Parent_Company__c = '';
        s160UPD[0].Ultimate_Parent_Company_Id__c = null;
        update s160UPD; 
        
        Company_Hierarchy__c[] s160New = [Select ID, Company_Number__c, Parent_Company__c, Parent_Company_Id__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c, Level__c from Company_Hierarchy__c Where Company_Number__c = 's160' limit 1];
        Company_Hierarchy__c[] s158ID  = [Select ID from Company_Hierarchy__c Where Company_Number__c = 's158' limit 1];
        System.assertEquals(s160New[0].Parent_Company__c, 's158');
        System.assertEquals(s160New[0].Parent_Company_Id__c, s158ID[0].ID);
        System.assertEquals(s160New[0].Ultimate_Parent_Company__c, 's158');
        System.assertEquals(s160New[0].Ultimate_Parent_Company_Id__c, s158ID[0].ID);
        System.assertEquals(S160New[0].Level__c, 2);

        Company_Hierarchy__c[] s166New = [Select ID, Company_Number__c, Parent_Company__c, Parent_Company_Id__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c, Level__c from Company_Hierarchy__c Where Company_Number__c = 's166' limit 1];
        System.assertEquals(s166New[0].Parent_Company__c, 's160');
        System.assertEquals(s166New[0].Parent_Company_Id__c, s160ID[0].ID);
        System.assertEquals(s166New[0].Ultimate_Parent_Company__c, 's158');
        System.assertEquals(s166New[0].Ultimate_Parent_Company_Id__c, s158ID[0].ID);        
        System.assertEquals(S166New[0].Level__c, 3);


        ///Company_Hierarchy__c c = new Company_Hierarchy__c(Company_Number__c = pCompanyNumber, Parent_Company__c = pParentCompany, Parent_Company_ID__c = pParentCompanyID,Ultimate_Parent_company__c = pUltimateParentCompany, Ultimate_Parent_company_ID__c = pUltimateParentCompanyID, Name = pName, Level__c = pLevel, Employees__c = 0, Employees_Indicator__c = 'Actual');
        //s166ID[0].Parent_Company__c = 

        System.assertEquals(s165ID[0].Parent_Company__c, s165ID[0].Company_Number__c);
        System.assertEquals(s165ID[0].Ultimate_Parent_Company__c, s165ID[0].Company_Number__c);
        System.assertEquals(s165ID[0].Parent_Company_Id__c, null);
        System.assertEquals(s165ID[0].Ultimate_Parent_Company_Id__c, null);
   }
    
    //==================================================
    static testMethod void TriggerAndInsert2() 
    //==================================================
    {
      boolean debugit = false;
      Integer HierarchyCount;
      string  sParentID;
      //
      Company_Hierarchy__c[] CompaniesToClearDown = [select id, name from Company_Hierarchy__c where Ultimate_Parent_Company__c = '0001'];
      //
      if (CompaniesToClearDown.size() > 0)
      {
         delete CompaniesToClearDown;
      }   
      HierarchyCount = [Select Count() from Company_Hierarchy__c Where Ultimate_Parent_Company__c = '0001' or Company_Number__c = '0001'];
      System.assertEquals(0, HierarchyCount);
      // 
      //setupCompany (pName, pCompanyNumber, pParentCompany, pParentCompanyID, pUltimateParentCompany, pUltimateParentCompanyID, pLevel)
      // 
      // Scenario 166 - Delete a Parent Company from the hierarchy. The parent and all subsidiary companies will be deleted.
      // set up s166 --> s167 --> s168. Delete s167. Verify that s167 and s168 have been deleted 
      if (debugit){system.debug('=== Scenario 166 ');}
         Company_Hierarchy__c Company_s166 = TestUtilities.setupCompany('SWPS000142_s166','s166','',null,'',null,0);
         HierarchyCount = [Select Count() from Company_Hierarchy__c Where Company_Number__c = 's166'];
         System.assertEquals(1, HierarchyCount);
         //
         Company_Hierarchy__c Company_s167 = TestUtilities.setupCompany('SWPS000142_s167','s167','s166',null,'',null,0);
         HierarchyCount = [Select Count() from Company_Hierarchy__c Where Company_Number__c = 's167'];
         System.assertEquals(1, HierarchyCount);
         //
         Company_Hierarchy__c Company_s168 = TestUtilities.setupCompany('SWPS000142_s168','s168','s167',null,'',null,0);
         HierarchyCount = [Select Count() from Company_Hierarchy__c Where Company_Number__c = 's168'];
         System.assertEquals(1, HierarchyCount);
         //
         delete Company_s167;
         //
         HierarchyCount = [Select Count() from Company_Hierarchy__c Where Company_Number__c = 's167'];
         System.assertEquals(0, HierarchyCount);
         //
         HierarchyCount = [Select Count() from Company_Hierarchy__c Where Company_Number__c = 's168'];
         System.assertEquals(0, HierarchyCount);
         //
         HierarchyCount = [Select Count() from Company_Hierarchy__c Where Company_Number__c = 's166'];
         System.assertEquals(1, HierarchyCount);
      }
      
      
    //==================================================
    static testMethod void TriggerAndInsert3() 
    //==================================================
   {
      integer CFLCount; 
      Lead Lead169 = new Lead(LastName = 'XXX_Lead169', Company = 'XXX Lead 169 Company', Status = 'New', LeadSource = 'MNC' );
      insert Lead169;
      Lead Lead169ID = [select ID from Lead where LastName = 'XXX_Lead169'];   //Company = 'XXX Lead 168 Company'];   
      Contacts_for_Leads__c CFL169a = new Contacts_for_Leads__c(Last_Name__c = 'XXX Smith s169a', Lead__c = Lead169ID.ID);
      insert CFL169a;
      Contacts_for_Leads__c CFL169b = new Contacts_for_Leads__c(Last_Name__c = 'XXX Smith s169b', Lead__c = Lead169ID.ID);
      insert CFL169b;
      Contacts_for_Leads__c CFL169c = new Contacts_for_Leads__c(Last_Name__c = 'XXX Smith s169c', Lead__c = Lead169ID.ID);
      insert CFL169c;
      //
      CFLCount = [Select Count() from Contacts_for_Leads__c where Lead__c = :Lead169ID.ID];
      System.assertEquals(3, CFLCount);
      //
      try {
         delete Lead169ID;
      }
      catch (exception e) {
         system.debug('*** Exception ' + e.getMessage());
      }   
      CFLCount = [Select Count() from Contacts_for_Leads__c where Lead__c = :Lead169ID.ID];
      System.assertEquals(0, CFLCount);
      //
      CFLCount = [Select Count() from Lead where ID = :Lead169ID.ID];
      System.assertEquals(0, CFLCount);
      
      // exception
      
      Lead Lead169ex = new Lead(LastName = 'XXX_Lead169ex', Company = 'XXX Lead 169 Company', Status = 'New', LeadSource = 'MNC' );
      insert Lead169ex;
      
      Lead Lead169exID = [select ID from Lead where LastName = 'XXX_Lead169ex'];   //Company = 'XXX Lead 168 Company'];
      
      delete Lead169exID;
      //
      // Read a non-existent Lead to generate an exception
      //Lead Lead169IDx = [select ID from Lead where LastName = 'XXX_Lead169'];  
   }
   
    //==================================================
    static testMethod void TriggerAndInsert4() 
    //==================================================
   {
      // s170 Link a Contacts for Lead record with a Lead
      integer CFLCount; 
      Lead Lead170 = new Lead(LastName = 'XXX_Lead170', Company = 'XXX Lead 170 Company', Tree_Org_Reg_no__c = 'SWPS000142_s170', Status = 'New', LeadSource = 'MNC' );
      insert Lead170;
      //
      Lead Lead170ID = [select ID from Lead where Tree_Org_Reg_no__c = :Lead170.Tree_Org_Reg_no__c];
      //    
      Contacts_for_Leads__c CFL170a = new Contacts_for_Leads__c(Last_Name__c = 'XXX Smith s170a', Tree_Organisation_ID__c = 'SWPS000142_s170');
      insert CFL170a;
      //
      Contacts_for_Leads__c CFL170aID = [select Lead__c from Contacts_for_Leads__c where Tree_Organisation_ID__c = 'SWPS000142_s170'];
      //    
      System.assertEquals(CFL170aID.Lead__c, CFL170aID.Lead__c);
      //
      
      // try the exception
      Contacts_for_Leads__c CFL170b = new Contacts_for_Leads__c(Last_Name__c = 'XXX Smith s170a', Tree_Organisation_ID__c = 'SWPS000142_s170_xx');
      insert CFL170b;
    }
   
    //==================================================
    static testMethod void TriggerAndInsert5() 
    //==================================================
   {  
      // s171 - Create a Lead that has a parent lead linked via the Tree_Parent_Org_Reg_No__c field. Verify the ID of the Parent is linked to the child via the Tree_Parent_Id__c field 
      Lead Lead171p = new Lead(LastName = 'XXX_Lead171p Parent', Company = 'XXX Lead 171p Company', Status = 'New', LeadSource = 'MNC', Tree_Org_Reg_no__c = 'XXX171p');
      insert Lead171p;
      Lead Lead171pID = [select ID from Lead where Tree_Org_Reg_no__c = 'XXX171p'];       
      //
      Lead Lead171c = new Lead(LastName = 'XXX_Lead171c Child', Company = 'XXX Lead 171c Company', Status = 'New', LeadSource = 'MNC', Tree_Org_Reg_no__c = 'XXX171c', Tree_Parent_Org_Reg_No__c = 'XXX171p');
      insert Lead171c;
      Lead Lead171cID = [select ID, Tree_Parent_Id__c from Lead where Tree_Org_Reg_no__c = 'XXX171c'];    
      //
      //system.assertEquals(Lead171cID.Tree_Parent_Id__c, Lead171pID.ID); 
      //
      // s172 - Add a Lead and link it to a company via the external key Related_Company. Verify that the Company Id is added to the Lead in the Related_Company_Id field.
      //
      // setupCompany (pName, pCompanyNumber, pParentCompany, pParentCompanyID, pUltimateParentCompany, pUltimateParentCompanyID, pLevel)
      // Add a record to the company hierarchy without linking it to a parent with a hierarchy level of 0
      Company_Hierarchy__c Company_172 = TestUtilities.setupCompany('SWPS000142_s172','s172','',null,'',null,0);
      Company_Hierarchy__c[] s172ID = [Select ID from Company_Hierarchy__c Where Company_Number__c = 's172' limit 1];
      //
      Lead Lead172 = new Lead(LastName = 'XXX_Lead172', Company = 'XXX Lead 172 Company', Status = 'New', LeadSource = 'MNC', Tree_Org_Reg_no__c = 'XXX172', Tree_Parent_Org_Reg_No__c = 'XXX171p', Related_Company__c = 's172');
      insert Lead172;
      Lead Lead172ID = [select ID, Tree_Parent_Id__c, Related_Company_Id__c from Lead where Tree_Org_Reg_no__c = 'XXX172']; 
      //
      //system.assertEquals(Lead172ID.Related_Company_Id__c, s172ID[0].ID); 
      // 
   }
   
    //==================================================
    static testMethod void UpdateController1() 
    //==================================================
    {
        Account acc = new Account(name = 'test',OAR_Account_Reference_1__c = '1234', BillingState='Devon');
        insert acc;
        Contact con = new Contact(MailingCity = 'swindon',recordUpdated__c = true, AccountId = acc.Id, LastName = 'smith',OAR_Registered_Date__c = Datetime.now());
        insert con;
        con.account = acc;
        ApexPages.StandardController ase = new ApexPages.StandardController(con);
        Contact_Update_Controller cuc = new Contact_Update_Controller(ase);
        cuc.checkUpdateStatus();
    }
    
    //==================================================
    static testMethod void UpdateController2() 
    //==================================================
    {
        Account acc = new Account(name = 'test',OAR_Account_Reference_1__c = '1234', BillingState='Devon');
        insert acc;
        Contact con = new Contact(MailingCity = 'swindon',recordUpdated__c = true, AccountId = acc.Id, LastName = 'smith');
        insert con;
        con.account = acc;
        ApexPages.StandardController ase = new ApexPages.StandardController(con);
        Contact_Update_Controller cuc = new Contact_Update_Controller(ase);
        cuc.checkUpdateStatus();
    }   
    
    //==================================================
    static testMethod void UpdateController3() 
    //================================================== 
    {
        Account acc = new Account(name = 'test', BillingState='Devon');
        insert acc;
        Contact con = new Contact(MailingCity = 'swindon',recordUpdated__c = true, AccountId = acc.Id, LastName = 'smith');
        insert con;
        con.account = acc;
        ApexPages.StandardController ase = new ApexPages.StandardController(con);
        Contact_Update_Controller cuc = new Contact_Update_Controller(ase);
        cuc.checkUpdateStatus();
    }
    
    
  /*  //==================================================
    static testMethod void testInvalidRecord() 
    //==================================================   
    {
        List<Account_Validation_Table__c> testEntries = new List<Account_Validation_Table__c>();
        testEntries.add(new Account_Validation_Table__c (Account__c = 'ATEST0001', Group_Code__c = 'GTEST0001'));
        testEntries.add(new Account_Validation_Table__c (Account__c = 'ATEST0002', Group_Code__c = 'GTEST0001'));
        testEntries.add(new Account_Validation_Table__c (Account__c = 'ATEST0003', Group_Code__c = 'GTEST0001'));
        testEntries.add(new Account_Validation_Table__c (Account__c = 'ATEST0004', Group_Code__c = 'GTEST0002'));
        testEntries.add(new Account_Validation_Table__c (Account__c = 'ATEST0005', Group_Code__c = 'GTEST0002'));
        insert testEntries;

        // Get the record type for a customer account
        RecordType recordType = [Select Id From RecordType Where SobjectType = 'Account' And Name = 'Customer Account' Limit 1];

        try {
            insert new Account (Name = 'TEST0001', RecordTypeId = recordType.Id, Contract_Start_Date__c = Date.today(), Contract_Duration__c = '1', DISE_Group_Code_Account_No_4__c = 'ATEST0004', DISE_Group_Code_Account_No_1__c = 'INVALID');
        }
        catch (DmlException  e) {
            System.assertEquals(Label.NOT_VALID_ACC_GROUP,e.getDmlMessage(0));
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }
*/
    //==================================================
    static testMethod void test_linkage_config() 
    //==================================================  
    {
        // Ensure there is a current system entry
        List<O2_OAR_Linkage_Parameter__c> sysNames = [Select Value__c From O2_OAR_Linkage_Parameter__c Where Name = 'CURRENT_SYSTEM' Limit 1];
        if (sysNames.size() == 0) {
            O2_OAR_Linkage_Parameter__c cur_sys = new O2_OAR_Linkage_Parameter__c(Name = 'CURRENT_SYSTEM', value__c = 'LIVE');
            insert cur_sys;
        }
        
        // Access the class that will force the initialiser to run
        O2_linkage_configuration.getParam('CURRENT_SYSTEM');
        O2_linkage_configuration.getCurrentSystem();
    }    

    //==================================================
    static testMethod void convertToTextMonth() 
    //================================================== 
    {
        O2_linkage_utils.convertToTextMonth(12);
    } // convertToTextMonth

    //==================================================
    static testMethod void testGetOARLink() 
    //================================================== 
    {
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;
        
        // Make system think we are on sandbox to go down sandbox branches
        // First get the current system - this will force configuration initialisers to run
        O2_linkage_configuration.getCurrentSystem();
        
        // Override the value for sandbox
        O2_linkage_configuration.setCurrentSystem(Label.Sandbox_String);
            
        
        O2_OAR_Deep_URL__c deepURL = new O2_OAR_Deep_URL__c(Deep_URL__c = '/my/deep/url',
                                                            Applicable_Servers__c = 'All');
        insert deepURL;   
        O2_OAR_Deep_URL__c insertedDeepURL = [Select Name From O2_OAR_Deep_URL__c Where Id = :deepURL.Id] ;                                                     
        // TODO - Broken test needs fixing
        //O2_linkage_utils.getOARLink(insertedDeepURL.Name);
    }

    //==================================================
    static testMethod void registerAndUpdateAccountTest() 
    //==================================================  
    {
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;
        
        // Create an account validation entry so that we can create an account with valid billing code
        Account_Validation_Table__c validEntry = new Account_Validation_Table__c(   Group_Code__c = 'TUKKY1',
                                                                                    Full_Account__c = 'TUKKY1',
                                                                                    Account__c = 'TUKKY1');
        insert validEntry;
                                                                                            
        // Create an account with the correct fields for a register
        Account registeringAccount = new Account(DISE_Group_Code_Account_No_1__c = 'TUKKY1',
                                                    Name = 'TUKKY1_TEST',
                                                    // START - Added Darren Sabey 5/1/2011
                                                    Contract_End_Date__c = System.today().addDays(365),
                                                    // END - Added Darren Sabey 5/1/2011
                                                    Status__c = 'Customer',
                                                    Contract_Start_Date__c = Date.Today(),
                                                    Contract_Duration__c = '4',
                                                    Date_Effective_From__c = Date.Today(),
                                                    BillingStreet = '5 Hamilton Street',
                                                    BillingCity = 'Exeter',
                                                    BillingPostalCode = 'EX1 1AA',
                                                    BillingState='Devon');
                                                    
        insert registeringAccount;
        
        /* TODO - Broken test - needs fixing
        // Now register the account
        O2_linkage_utils.registerAccount(null,registeringAccount.Id);   
        
        // Now update it
        O2_linkage_utils.updateAccount(registeringAccount.Id);
        
        // Attempt to hand it over
        O2_linkage_utils.handoverAccount(registeringAccount.Id,'OAR user id','message',Date.today());       
        */
    } // end registerAndUpdateAccountTest      

    //==================================================
    static testMethod void getUserListTest() 
    //==================================================  
    {
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;        
        O2_linkage_utils.getOARUserList('tarpey');
    } // end getUserListTest

    
    //==================================================
    static testMethod void updateAccountContactTest() 
    //================================================== 
    {   
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;    
        
        Account acc = new Account(  
                                    Name = 'TUKKY1_TEST',
                                    Status__c = 'Prospect',
                                    Contract_Start_Date__c = Date.Today(),
                                    Contract_Duration__c = '4',
                                    Date_Effective_From__c = Date.Today(),
                                    BillingStreet = '5 Hamilton Street',
                                    BillingCity = 'Exeter',
                                    BillingPostalCode = 'EX1 1AA',
                                    BillingState='Devon'); 
        insert acc;                                         
        Contact con = new Contact(  Salutation = 'Mr',
                                    Firstname = 'Paul',
                                    Lastname = 'Tarpey',
                                    Buying_Role__c = 'COP',
                                    MailingStreet = '1 High Street',
                                    MailingState = 'Wiltshire',
                                    MailingPostalCode = 'SN1 1AA',
                                    MailingCity = 'Bristol',
                                    MailingCountry = 'UK',
                                    Phone = '01793121212',
                                    MobilePhone = '07981221212',
                                    AccountId = acc.Id,
                                    Email = 'a@b.com',
                                    Title = 'Manager',
                                    CLCMagazine__c = true,
                                    CLCMicrosite__c = true,
                                    CLCeNews__c = true,
                                    CLCDirectMail__c = true,
                                    CLCEvents__c = true,
                                    CLCWhitePapers__c = true,
                                    CLCProductWorkshop__c = true,
                                    CLCResearchForums__c = true,
                                    CLCEndUser__c = true,
                                    CSIOptOut__c = true);
        insert con;
        O2_linkage_utils.updateAccount(acc.id);
        O2_linkage_utils.updateContact(con.id);
                    
    } // end updateAccountContactTest
    
        static testMethod void test1() {
        Account_Validation_Table__c valid = new Account_Validation_Table__c(Group_Code__c = '2323');
        insert valid;
        // START - Added Darren Sabey 5/1/2011
        Account acc = new Account(name = 'test',Contract_End_Date__c = System.today().addDays(365),DISE_Group_Code_Account_No_1__c = '2323', status__c = 'customer', billingcity = 'london', billingstreet = 'baker street', billingpostalcode = '21073', BillingState='Devon', Contract_Start_Date__c = Date.Today(), Contract_Duration__c = '4', Date_Effective_From__c = Date.Today());
        // END - Added Darren Sabey 5/1/2011
        //Account acc = new Account(name = 'test',DISE_Group_Code_Account_No_1__c = '2323', status__c = 'customer', billingcity = 'london', billingstreet = 'baker street', billingpostalcode = '21073', Contract_Start_Date__c = Date.Today(), Contract_Duration__c = '4', Date_Effective_From__c = Date.Today());
        insert acc;
        Opportunity opp = new Opportunity(Close_Comment__c = 'the close comment', StageName = 'Decision',CloseDate = Date.today(), TotalOpportunityQuantity = 3, name = 'oppname', AccountId = acc.Id, Register_Acc_on_OAR__c = 'Yes');
        insert opp;
        ApexPages.StandardController stdcont = new ApexPages.StandardController(opp);
        OARRegistrationController rc = new OARRegistrationController(stdcont);
        /* TODO - Broken test - needs fixing
        rc.checkOARRegistered();
        opp.Register_Acc_on_OAR__c = 'No';
        rc.checkOARRegistered();
        opp.Register_Acc_on_OAR__c = 'Yes';
        acc.DISE_Group_Code_Account_No_1__c = null;
        rc.checkOARRegistered();
        */
    }
    
    

                                                                
    // TODO - Broken test - needs fixing                                                                                    
    
    //==================================================
    static testMethod void TestingCall() 
    //================================================== 
    {
    	/*
        salesO2CoUkChoice                               x_service0          =   new salesO2CoUkChoice();
        x_service0.TestingCall(true);
        //O2_linkage_configuration.TESTING                                  =   true;
        o2_salesO2CoUk_soapserver.AccountSoap           x_service           =   new o2_salesO2CoUk_soapserver.AccountSoap();
        Account tmp_acc                                                     =   [Select     Id, 
                                                                                        OwnerId,
                                                                                        Name, 
                                                                                        Company_Reg_No__c,
                                                                                        BURN__c,
                                                                                        MinimumTerm__c,
                                                                                        Minimum_Holding__c,
                                                                                        Tree_Organisation_ID__c,
                                                                                        Contract_End_Date__c,
                                                                                        BillingStreet,
                                                                                        BillingState,
                                                                                        BillingCity,
                                                                                        BillingCountry,
                                                                                        BillingPostalCode,
                                                                                        DISE_Group_Code_Account_No_4__c, 
                                                                                        DISE_Group_Code_Account_No_3__c,
                                                                                        DISE_Group_Code_Account_No_2__c,
                                                                                        DISE_Group_Code_Account_No_1__c,
                                                                                        DISE_4_GROUP__c, 
                                                                                        DISE_3_GROUP__c,
                                                                                        DISE_2_GROUP__c,
                                                                                        DISE_1_GROUP__c,
                                                                                        NumberOfEmployees,
                                                                                        O2_Sector__c,
                                                                                        Business_Text_Code__c,
                                                                                        PH_Site_ID__c,
                                                                                        Desktop_Text_code__c,
                                                                                        Managed_Text_Code__c,
                                                                                        Mobile_Marketer_Code__c,
                                                                                        OAR_Account_Reference_1__c,
                                                                                        OAR_Account_Reference_2__c,
                                                                                        OAR_Account_Reference_3__c,
                                                                                        OAR_Account_Reference_4__c,
                                                                                        Contract_Start_Date__c,
                                                                                        Contract_Duration__c,
                                                                                        Date_Effective_From__c                                      
                                                                                        From Account LIMIT 1];
                                                    
        
        Contact tmp_con                                                 =   [SELECT Id,
                                                                                        AccountId,
                                                                                        Salutation,
                                                                                        FirstName,
                                                                                        LastName,
                                                                                        Buying_Role__c,
                                                                                        Title,
                                                                                        Phone,
                                                                                        Email,
                                                                                        MailingStreet,
                                                                                        MailingState,
                                                                                        MailingCity,
                                                                                        MailingCountry,
                                                                                        MailingPostalCode,
                                                                                        OAR_Registered_Date__c,
                                                                                        CSIOptOut__c,
                                                                                        CSIOptOutReason__c,
                                                                                        CSIFurtherInformation__c,
                                                                                        CLCeNews__c,
                                                                                        CLCWhitePapers__c,
                                                                                        CLCResearchForums__c,
                                                                                        CLCProductWorkshop__c,
                                                                                        CLCMicrosite__c, 
                                                                                        CLCMagazine__c,
                                                                                        CLCEvents__c,
                                                                                        CLCEndUser__c,
                                                                                        CLCDirectMail__c,
                                                                                        Account.OwnerId,
                                                                                        OwnerId
                                                                
                                                                                        FROM Contact WHERE AccountId = :tmp_acc.Id LIMIT 1];
                                                                                        
        x_service.OARAuthenticationHeader                               =   new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
        x_service.OARAuthenticationHeader.Username                      =   O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
        x_service.OARAuthenticationHeader.Password                      =   O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');   
        o2_salesO2CoUk_soapserver.ArrayOfContact tmp_contactCallList    =   new o2_salesO2CoUk_soapserver.ArrayOfContact();
        o2_salesO2CoUk_soapserver.ArrayOfString tmp_response            =   new o2_salesO2CoUk_soapserver.ArrayOfString();

        String minimumTerm      =   tmp_acc.MinimumTerm__c      == null ? '0' : '' + tmp_acc.MinimumTerm__c.intValue();
        String minimumHolding   =   tmp_acc.Minimum_Holding__c  == null ? '0' : tmp_acc.Minimum_Holding__c.intValue() + '';
        String noEmployees      =   tmp_acc.NumberOfEmployees   == null ? '0' : tmp_acc.NumberOfEmployees + '';
        
        String contractStartDateString;
        
        if (tmp_acc.Contract_Start_Date__c != null) 
        {
            contractStartDateString = tmp_acc.Contract_Start_Date__c.day() + O2_linkage_utils.convertToTextMonth(tmp_acc.Contract_Start_Date__c.month()) + tmp_acc.Contract_Start_Date__c.year();
        }

                                                            
        x_service.RegisterAccount(                          tmp_acc.Id,
                                                            tmp_acc.Tree_Organisation_ID__c, // treeAccountIdentifier,
                                                            tmp_acc.Name, // customerName,
                                                            tmp_acc.Company_Reg_No__c,// companyRegistrationNumber
                                                            tmp_acc.BURN__c,// businessUniqueReferenceNumber,
                                                            tmp_acc.PH_Site_ID__c,// experianNumber
                                                            contractStartDateString,// contractStartDate??
                                                            tmp_acc.Contract_Duration__c, // duration ??
                                                            minimumTerm,
                                                            minimumHolding,
                                                            tmp_acc.BillingStreet,
                                                            tmp_acc.BillingCity,                                                                
                                                            tmp_acc.BillingState,
                                                            tmp_acc.BillingCountry,
                                                            ' ', // address 5
                                                            ' ', // address 6
                                                            tmp_acc.BillingPostalCode,
                                                            ' ', //DISE_Group_Code,
                                                            ' ', //DISE_Account_No,
                                                            tmp_acc.Business_Text_Code__c,
                                                            tmp_acc.Desktop_Text_code__c,
                                                            tmp_acc.Managed_Text_Code__c,
                                                            tmp_acc.Mobile_Marketer_Code__c,
                                                            '10-22-09', //effectiveFromDateString, //dateEffectiveFrom
                                                            noEmployees,
                                                            tmp_acc.O2_Sector__c,
                                                            UserInfo.getUserName());




        o2_salesO2CoUk_soapserver.Contact           tmp_contact         =   new o2_salesO2CoUk_soapserver.Contact();
        List<o2_salesO2CoUk_soapserver.Contact>     tmp_contactList     =   new List<o2_salesO2CoUk_soapserver.Contact>();  
        if (tmp_con.Salutation == null) {tmp_con.Salutation = 'Mr.';}
        String salutation = tmp_con.Salutation.replace('.','');
                                                        
        tmp_contact.SalesForceAccountIdentifier     =   tmp_acc.Id;
        tmp_contact.SalesForceContactIdentifier     =   tmp_con.Id;
        tmp_contact.Title                           =   salutation;
        tmp_contact.FirstName                       =   tmp_con.FirstName;
        tmp_contact.LastName                        =   tmp_con.LastName;
        tmp_contact.Role                            =   'Mr'; //tmp_con.Title;
        tmp_contact.Telephone                       =   tmp_con.Phone;
        tmp_contact.IsCOP                           =   tmp_con.Buying_Role__c == 'COP' ? 'true' : 'false';
        tmp_contact.IsCOD                           =   tmp_con.Buying_Role__c == 'COD' ? 'true' : 'false';
        tmp_contact.IsCOR                           =   tmp_con.Buying_Role__c == 'COR' ? 'true' : 'false';
        tmp_contact.Email                           =   tmp_con.Email;
        tmp_contact.Address1                        =   tmp_con.MailingStreet;
        tmp_contact.Address2                        =   tmp_con.MailingCity;
        tmp_contact.Address3                        =   tmp_con.MailingState;
        tmp_contact.Address4                        =   tmp_con.MailingCountry;
        tmp_contact.Address5                        =   ' '; // address 5
        tmp_contact.Address6                        =   ' '; // address 6
        tmp_contact.Postcode                        =   tmp_con.MailingPostalCode;
        tmp_contact.CLCMagazine                     =   tmp_con.CLCMagazine__c ? 'true' : 'false';// CLCMagazine
        tmp_contact.CLCMicrosite                    =   tmp_con.CLCMicrosite__c ? 'true' : 'false';// CLCMicrosite
        tmp_contact.CLCeNews                        =   tmp_con.CLCeNews__c ? 'true' : 'false';// CLCeNews
        tmp_contact.CLCDirectMail                   =   tmp_con.CLCDirectMail__c ? 'true' : 'false';// CLCDirectMail
        tmp_contact.CLCEvents                       =   tmp_con.CLCEvents__c ? 'true' : 'false';// CLCEvents
        tmp_contact.CLCWhitePapers                  =   tmp_con.CLCWhitePapers__c ? 'true' : 'false';// CLCWhitePapers
        tmp_contact.CLCProductWorkshop              =   tmp_con.CLCProductWorkshop__c ? 'true' : 'false';// CLCProductWorkshop
        tmp_contact.CLCResearchForums               =   tmp_con.CLCResearchForums__c ? 'true' : 'false';// CLCResearchForums
        tmp_contact.CLCEndUser                      =   tmp_con.CLCEndUser__c ? 'true' : 'false';// CLCEndUser
        tmp_contact.CSIOptOut                       =   tmp_con.CSIOptOut__c ? 'true' : 'false';// CSIOptOut
        tmp_contact.CSIOptOutReason                 =   tmp_con.CSIOptOutReason__c;// CSIOptOutReason
        tmp_contact.CSIFurtherInformation           =   tmp_con.CSIFurtherInformation__c;//  CSIFurtherInformation                                                                                              
                                                        
                                                        
                                                        
        
        tmp_contactList.add(tmp_contact);
        tmp_contactCallList.Contact                                     =   tmp_contactList;    
        
        tmp_response = x_service.CreateContacts(tmp_contactCallList);
        System.debug('### TESTING : ' + tmp_response);
    */
    }

    //==================================================
    static testMethod void updateOARAccount() 
    //==================================================
    {
    	List<Account_Validation_Table__c> validEntries = new List<Account_Validation_Table__c>();
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TEST111',
                                                            Full_Account__c = 'TEST111',
                                                            Account__c = 'TEST111'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TEST222',
                                                            Full_Account__c = 'TEST222',
                                                            Account__c = 'TEST222'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TEST333',
                                                            Full_Account__c = 'TEST333',
                                                            Account__c = 'TEST333'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TEST444',
                                                            Full_Account__c = 'TEST444',
                                                            Account__c = 'TEST444'));                                                                                                                                                                                    
    	insert validEntries;
    	
    	Account pUpdatedAccount = new Account(   DISE_Group_Code_Account_No_1__c = 'TEST111',
                                                    DISE_Group_Code_Account_No_2__c = 'TEST222',
                                                    DISE_Group_Code_Account_No_3__c = 'TEST333',
                                                    DISE_Group_Code_Account_No_4__c = 'TEST444',
                                                    OAR_Account_Reference_1__c = '1234',
                                                    Name = 'TEST123',
                                                    // START - Added Darren Sabey 5/1/2011
                                                    Contract_End_Date__c = System.today().addDays(365),
                                                    // END - Added Darren Sabey 5/1/2011
                                                    Status__c = 'Customer',
                                                    Contract_Start_Date__c = Date.Today(),
                                                    Contract_Duration__c = '4',
                                                    Date_Effective_From__c = Date.Today(),
                                                    BillingStreet = '5 Hamilton Street',
                                                    BillingCity = 'Exeter',
                                                    BillingPostalCode = 'EX1 1AA',
                                                    BillingState='Devon');
                                                    
        insert pUpdatedAccount;
        
        //Account pUpdatedAccount = [SELECT id, name FROM Account Limit 1];
        o2_salesO2CoUk_soapserver.AccountSoap   pAccountStub    = new   o2_salesO2CoUk_soapserver.AccountSoap();    
        O2_linkage_configuration.TESTING = false;
        System.debug('About to call updateAccount');
        saleso2CoUkChoice.updateAccount(pUpdatedAccount.id);
    }
    
    //==================================================
    static testMethod void o2_salesO2CoUk_soapserver() 
    //==================================================
    {
        o2_salesO2CoUk_soapserver.AccountSoap   test_service    =   new o2_salesO2CoUk_soapserver.AccountSoap();
        test_service.isTest = true;
        test_service.CreateContact(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        test_service.CreateContacts(NULL);
        test_service.ForceHandOverAccount(NULL, NULL, NULL, NULL);
        test_service.HandOverAccount(NULL, NULL, NULL, NULL, NULL);
        test_service.RegisterAccount(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        test_service.UpdateAccount(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        test_service.UpdateContact(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        test_service.UpdateContacts(NULL);
        test_service.UserSearch(NULL, NULL);    
    }   
    
    

}