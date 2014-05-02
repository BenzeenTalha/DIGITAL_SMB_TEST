/*
* Lead Assignment Module 2 – Existing Account Matching.
* - check AccountValidationTable and Account objects for a matching account.
* 
* Revision history
* June 2010 Colin Kenworthy (Radius Technology) - initial version
*/
public class AP01TestModule2 {
    
    static String THIS_TEST = 'Existing';
    
    
    
    public static void RunTest(AP01Lead.wrapperLead thisWrapperLead) {
        // check AccountValidationTable then Account objects.
        
        Boolean matched = false;
        Integer matchedCount = 0;
        Account_Validation_Table__c matchedAcctValidationTable = null;
        Account matchedAcct = null;
        
        // AccountValidationTable: try matching on codes
        for (Account_Validation_Table__c aVT : AP01Lead.MATCHING_DISE_ACCOUNTS) {
            if (     thisWrapperLead.le.DISE_Account_No__c == aVT.Account__c
                  || thisWrapperLead.le.DISE_Account_No__c == aVT.Full_Account__c
                  || thisWrapperLead.le.DISE_Group_Code__c == aVT.Group_Code__c
               ) {
                //found match
                matched = true;
                matchedCount = 1;
                matchedAcctValidationTable = aVT;
                break;
            }
        }
        // AccountValidationTable: try matching on name and address
        if ( ! matched) {
            for (Account_Validation_Table__c aVT : AP01Lead.MATCHING_DISE_ACCOUNTS) {
                if (    thisWrapperLead.le.Company == aVT.Account_Description__c
                     && thisWrapperLead.le.PostalCode == aVT.Post_Code__c
                   ) {
                    matched = true;
                    matchedCount = 1;
                    matchedAcctValidationTable = aVT;
                    break;
                }
            }
        }
        if (matched) {
            // process the matched
            AVTMatchedLead(matchedAcctValidationTable, thisWrapperLead);
        } else {
            // check in SF Account object for matching name and postcode

            // AP01Lead.MATCHING_SF_ACCOUNTS
            for (Account acc : AP01Lead.MATCHING_SF_ACCOUNTS) {
                if (    thisWrapperLead.le.Company == acc.Name
                     && thisWrapperLead.le.PostalCode == acc.Postcode__c
                   ) {
                    matched = true;
                    matchedCount++;
                    matchedAcct = acc;
                }
            }
            if (matched && matchedCount==1) {
                // process the matched
                SFAccountMatchedLead(matchedAcct, thisWrapperLead);
            }
        }
    
    }
    
    
    
    public static void AVTMatchedLead(Account_Validation_Table__c aVT, AP01Lead.wrapperLead thisWrapperLead) {
        String lookup;
        if (aVT.Flag__c == 'O2 Direct') {
            // lead is direct if the AVT has flag 'O2 Direct'
            // lead owner is Direct Emp or Manager
            lookup = 'Direct Managed';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerId=aVT.SF_Owner_ID__c;
            System.Debug('##### AP01TestModule2 ##### Setting owner id to '+thisWrapperLead.newOwnerId+'. No postcode lookup needed for '+thisWrapperLead.halfPostcode);
            // in case no Lead Id was pulled back then output meaningful error
            if (thisWrapperLead.newOwnerId == null) {
                System.Debug('##### AP01TestModule2 ##### Could not assign to '+lookup+' for Account Validation Table '+aVT.Full_Account__c+'.');
            }
        } else
        if (aVT.Flag__c == 'O2 Indirect') {
            // Lead is partner managed if the AVT has flag 'O2 Indirect'
            // The AVT SF-User-Id will be populated with the Partner for CoE and the CBM for non-CoE. Therefore no need to check CoE/Non-CoE.
            lookup = 'Partner Managed';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerId=aVT.SF_Owner_ID__c;
            System.Debug('##### AP01TestModule2 ##### Setting owner id to '+thisWrapperLead.newOwnerId+'. No postcode lookup needed for '+thisWrapperLead.halfPostcode);
            // in case no Lead Id was pulled back then output meaningful error
            if (thisWrapperLead.newOwnerId == null) {
                System.Debug('##### AP01TestModule2 ##### Could not assign to '+lookup+' for Account Validation Table '+aVT.Full_Account__c+'.');
            }
////            if (CoE) {
////                // lead owner is Partner from AVT
////            } else {
////            if (non-CoE) {
////                // lead owner is Channel Business Manager from AVT
////            }}
        } else
        if (aVT.Flag__c == null || aVT.Flag__c == '') {
            // Lead is unmanaged if the AVT has flag ''
            if (thisWrapperLead.le.NumberOfEmployees >= thisWrapperLead.le.f_Corporate_Employees_Start_Point__c) {
                // lead owner is corporate queue
                lookup = 'Corporate';
                thisWrapperLead.processed=TRUE;
                thisWrapperLead.matchedRule=THIS_TEST;
                thisWrapperLead.newOwnerName=AP01Lead.GetCorporateNameForPostcode(thisWrapperLead.halfPostcode);
                System.Debug('##### AP01TestModule2 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Corporate postcode lookup for '+thisWrapperLead.halfPostcode);
            } else
            if (thisWrapperLead.le.No_of_Connections__c > thisWrapperLead.le.f_DMU_Max_MPN__c) {
                // lead owner is Aquisition
                lookup = 'Aquisition';
                thisWrapperLead.processed=TRUE;
                thisWrapperLead.matchedRule=THIS_TEST;
                thisWrapperLead.newOwnerName=AP01Lead.GetAquisitionNameForPostcode(thisWrapperLead.halfPostcode);
                System.Debug('##### AP01TestModule2 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Aquisition postcode lookup for '+thisWrapperLead.halfPostcode);
            } else {
                // lead owner is DMU
                lookup = 'DMU';
                thisWrapperLead.processed=TRUE;
                thisWrapperLead.matchedRule=THIS_TEST;
                thisWrapperLead.newOwnerName=AP01Lead.GetDMUNameForPostcode(thisWrapperLead.halfPostcode);
                System.Debug('##### AP01TestModule2 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. DMU postcode lookup for '+thisWrapperLead.halfPostcode);
            }
            // in case no Lead Owner was pulled back then output meaningful error
            if (thisWrapperLead.newOwnerName == null || thisWrapperLead.newOwnerName == '') {
                System.Debug('##### AP01TestModule2 ##### Could not assign to '+lookup+' for post code '+thisWrapperLead.halfPostcode+'.');
            }
        }
    }
    
    public static void SFAccountMatchedLead(Account acc, AP01Lead.wrapperLead thisWrapperLead) {
        // change owner to Account Owner
        thisWrapperLead.processed=TRUE;
        thisWrapperLead.matchedRule=THIS_TEST;
        thisWrapperLead.newOwnerId=acc.OwnerId;
        System.Debug('##### AP01TestModule2 ##### Setting owner id to '+thisWrapperLead.newOwnerId+'. No postcode lookup needed for '+thisWrapperLead.halfPostcode);
    }
    

//**********************************************************************************************
//*
//*     TEST METHODS
//*
//**********************************************************************************************
    public static testMethod void Test02() {
    // DISE GROUP CODE MATCH - O2 DIRECT
        Lead_Auto_Assignment_Parameter__c fixedParam = new Lead_Auto_Assignment_Parameter__c( Lead_Source__c = 'O2 Sandbox Existing02',
                                                                                              Test_Entry__c = 'Fixed|Existing|Online'
                                                                                             );
        // START - Added by Darren Sabey to avoid problem with inactive user 5/1/2011 
        Account_Validation_Table__c avc = new Account_Validation_Table__c();
        avc.MPN_s__c = 10;
        avc.Account_Description__c = 'Test Description';
        avc.Account__c = '999888777';
        avc.Full_Account__c = '999888777';
        avc.Group_Code__c = 'SAMEASLEAD'; 
        avc.Post_Code__c = 'LS12 0XX';
        avc.SF_Owner_ID__c = UserInfo.getUserId();
        avc.Flag__c = 'O2 Indirect';

        insert avc;
        // END - Added by Darren Sabey to avoid problem with inactive user 5/1/2011
        
        insert fixedParam;
        
        // START - Added by Darren Sabey to avoid problem with inactive user 5/1/2011 
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule202',
                                    DISE_Group_Code__c = 'SAMEASLEAD',
                                    Postalcode = 'LS12 0XX',
                                    LeadSource = 'O2 Sandbox Existing02',
                                    No_of_Connections__c = 5,
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
                                   );
        // END - Added by Darren Sabey to avoid problem with inactive user 5/1/2011 
        
        /*                           
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule203',
                                    Company = 'Trigoldcrystal Ltd',
                                    Postalcode = 'LS12 0XX',
                                    LeadSource = 'O2 Sandbox Existing03',
                                    No_of_Connections__c = 5,
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
                                   );
        */
        
        insert fixedLead;
        
        List<Lead> fixedLeads = [SELECT Id, OwnerId, Owner.Name FROM LEAD where Id=:fixedLead.Id];
        
        // Removed by Darren Sabey to avoid problem with inactive user 5/1/2011 
        //List<Account_Validation_Table__c> avtAccounts = [SELECT Id, Name, MPN_s__c, Account_Description__c, Account__c, Full_Account__c,Group_Code__c, Post_Code__c, SF_Owner_ID__c, Flag__c
        //                                                   FROM Account_Validation_Table__c
        //                                                  WHERE Group_Code__c = 'TRICRY' AND Post_Code__c = 'SW3 3JW' AND Post_Code__c != null];
        System.AssertEquals(1, fixedLeads.size());
        
        // Removed by Darren Sabey to avoid problem with inactive user 5/1/2011 
        //System.AssertEquals(1, avtAccounts.size());
        //System.AssertEquals(avtAccounts[0].SF_Owner_ID__c, fixedLeads[0].OwnerId);
        
        System.AssertEquals(avc.SF_Owner_ID__c, fixedLeads[0].OwnerId);
    }

    public static testMethod void Test03() {
    // AVT NAME AND ADDRESS MATCH - O2 DIRECT
        Lead_Auto_Assignment_Parameter__c fixedParam = new Lead_Auto_Assignment_Parameter__c( Lead_Source__c = 'O2 Sandbox Existing03',
                                                                                              Test_Entry__c = 'Fixed|Existing|Online'
                                                                                             );

        // START - Added by Darren Sabey to avoid problem with inactive user 5/1/2011
        Account_Validation_Table__c avc = new Account_Validation_Table__c();
        avc.MPN_s__c = 10;
        avc.Account_Description__c = 'Test Description';
        avc.Account__c = '999888777';
        avc.Full_Account__c = '999888777';
        avc.Post_Code__c = 'LS12 0XX';
        avc.SF_Owner_ID__c = UserInfo.getUserId();
        avc.Flag__c = 'O2 Direct';

        insert avc;
        // END - Added by Darren Sabey to avoid problem with inactive user 5/1/2011
        
        insert fixedParam;
        
        // START - Added by Darren Sabey to avoid problem with inactive user 5/1/2011
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule203',
                                    Company = 'Test Description',
                                    Postalcode = 'LS12 0XX',
                                    LeadSource = 'O2 Sandbox Existing03',
                                    No_of_Connections__c = 5,
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
                                   );
        // END - Added by Darren Sabey to avoid problem with inactive user 5/1/2011
        
        /*                           
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule203',
                                    Company = 'Trigoldcrystal Ltd',
                                    Postalcode = 'LS12 0XX',
                                    LeadSource = 'O2 Sandbox Existing03',
                                    No_of_Connections__c = 5,
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
          
                                 );
        */
        
        insert fixedLead;
        
        List<Lead> fixedLeads = [SELECT Id, OwnerId, Owner.Name FROM LEAD where Id=:fixedLead.Id];
        
        // Removed by Darren Sabey to avoid problem with inactive user 5/1/2011
        //List<Account_Validation_Table__c> avtAccounts = [SELECT Id, Name, MPN_s__c, Account_Description__c, Account__c, Full_Account__c,Group_Code__c, Post_Code__c, SF_Owner_ID__c, Flag__c
        //                                                   FROM Account_Validation_Table__c
        //                                                  WHERE Account_Description__c = 'Trigoldcrystal Ltd' AND Post_Code__c = 'SW3 3JW' AND Post_Code__c != null];
        System.AssertEquals(1, fixedLeads.size());
        
        // Removed by Darren Sabey to avoid problem with inactive user 5/1/2011
        //System.AssertEquals(1, avtAccounts.size());
        //System.AssertEquals(avtAccounts[0].SF_Owner_ID__c, fixedLeads[0].OwnerId);
        System.AssertEquals(avc.SF_Owner_ID__c, fixedLeads[0].OwnerId);
    }

    public static testMethod void Test13() {
    // AVT NAME AND ADDRESS MATCH - O2 INDIRECT
        Lead_Auto_Assignment_Parameter__c fixedParam = new Lead_Auto_Assignment_Parameter__c( Lead_Source__c = 'O2 Sandbox Existing13',
                                                                                              Test_Entry__c = 'Fixed|Existing|Online'
                                                                                             );
        insert fixedParam;
        
        // START - Added by Colin Kenworthy to avoid problem with inactive user 30/3/2012
        Account_Validation_Table__c avt = new Account_Validation_Table__c();
        avt.MPN_s__c = 10;
        avt.Account_Description__c = 'Test Description';
        avt.Account__c = '999888777';
        avt.Full_Account__c = '999888777';
        avt.Post_Code__c = 'LS12 0XX';
        avt.SF_Owner_ID__c = UserInfo.getUserId();
        avt.Flag__c = 'O2 Indirect';

        insert avt;
        // END - Added by Colin Kenworthy to avoid problem with inactive user 30/3/2012

        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule213',
                                    Company = 'Test Description',
                                    Postalcode = 'LS12 0XX',
                                    LeadSource = 'O2 Sandbox Existing13',
                                    No_of_Connections__c = 5,
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
                                   );
        insert fixedLead;
        
        List<Lead> fixedLeads = [SELECT Id, OwnerId, Owner.Name FROM LEAD where Id=:fixedLead.Id];
        // Removed by Colin Kenworthy to avoid problem with inactive user 30/3/2012
        //List<Account_Validation_Table__c> avtAccounts = [SELECT Id, Name, MPN_s__c, Account_Description__c, Account__c, Full_Account__c,Group_Code__c, Post_Code__c, SF_Owner_ID__c, Flag__c
        //                                                   FROM Account_Validation_Table__c
        //                                                  WHERE Account_Description__c = 'Kdc Storage & Distribution Ltd' AND Post_Code__c = 'G60 5AG' AND Post_Code__c != null];
        System.AssertEquals(1, fixedLeads.size());
        //System.AssertEquals(1, avtAccounts.size());
        System.AssertEquals(avt.SF_Owner_ID__c, fixedLeads[0].OwnerId);
    }

    public static testMethod void Test23() {
    // AVT NAME AND ADDRESS MATCH - no flag__c set (postcode lookup Corporate)
        Lead_Auto_Assignment_Parameter__c fixedParam = new Lead_Auto_Assignment_Parameter__c( Lead_Source__c = 'O2 Sandbox Existing23',
                                                                                              Test_Entry__c = 'Fixed|Existing|Online'
                                                                                             );
        insert fixedParam;
        
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule223',
                                    Company = 'Miss Joanne Dyer',
                                    Postalcode = 'CF3 3PN',
                                    LeadSource = 'O2 Sandbox Existing23',
                                    No_of_Connections__c = 50,
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 550,       // Corporate
                                    O2_Sector__c = 'Government'
                                   );
        insert fixedLead;
        
        List<Lead> fixedLeads = [SELECT Id, OwnerId, Owner.Name FROM LEAD where Id=:fixedLead.Id];
        String newOwnerName = AP01Lead.GetCorporateNameForPostcode('CF3');
        //System.AssertEquals(1, fixedLeads.size());
        //System.AssertNotEquals('', newOwnerName);
        //System.AssertEquals(newOwnerName, fixedLeads[0].Owner.Name);
    }

    public static testMethod void Test24() {
    // AVT NAME AND ADDRESS MATCH - no flag__c set (postcode lookup Aquisition)
        Lead_Auto_Assignment_Parameter__c fixedParam = new Lead_Auto_Assignment_Parameter__c( Lead_Source__c = 'O2 Sandbox Existing24',
                                                                                              Test_Entry__c = 'Fixed|Existing|Online'
                                                                                             );
        insert fixedParam;
        
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule224',
                                    Company = 'Miss Joanne Dyer',
                                    Postalcode = 'CF3 3PN',
                                    LeadSource = 'O2 Sandbox Existing24',
                                    No_of_Connections__c = 50,    // Aquisition
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
                                   );
        insert fixedLead;
        
        List<Lead> fixedLeads = [SELECT Id, OwnerId, Owner.Name FROM LEAD where Id=:fixedLead.Id];
        String newOwnerName = AP01Lead.GetAquisitionNameForPostcode('CF3');
        System.AssertEquals(1, fixedLeads.size());
        System.AssertNotEquals('', newOwnerName);
        System.AssertEquals(newOwnerName, fixedLeads[0].Owner.Name);
    }

    public static testMethod void Test25() {
    // AVT NAME AND ADDRESS MATCH - no flag__c set (postcode lookup DMU)
        Lead_Auto_Assignment_Parameter__c fixedParam = new Lead_Auto_Assignment_Parameter__c( Lead_Source__c = 'O2 Sandbox Existing25',
                                                                                              Test_Entry__c = 'Fixed|Existing|Online'
                                                                                             );
        insert fixedParam;
        
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule225',
                                    Company = 'Miss Joanne Dyer',
                                    Postalcode = 'CF3 3PN',
                                    LeadSource = 'O2 Sandbox Existing25',
                                    No_of_Connections__c = 4,    // DMU
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
                                   );
        insert fixedLead;
        
        List<Lead> fixedLeads = [SELECT Id, OwnerId, Owner.Name FROM LEAD where Id=:fixedLead.Id];
        String newOwnerName = AP01Lead.GetDMUNameForPostcode('CF3');
        System.AssertEquals(1, fixedLeads.size());
        System.AssertNotEquals('', newOwnerName);
        System.AssertEquals(newOwnerName, fixedLeads[0].Owner.Name);
    }

    public static testMethod void Test30() {
    // ACCOUNT NAME AND ADDRESS MATCH
        Lead_Auto_Assignment_Parameter__c fixedParam = new Lead_Auto_Assignment_Parameter__c( Lead_Source__c = 'O2 Sandbox Existing30',
                                                                                              Test_Entry__c = 'Fixed|Existing|Online'
                                                                                             );
        insert fixedParam;

        Account a1 = new Account( Name = 'O2SandboxAP01TestModule2Test30',
                                  BillingStreet = 'Street',
                                  BillingCity = 'City',
                                  BillingPostalCode = 'SW3 9XY',
                                  Postcode__c = 'SW3 9XY'
                                 );
        insert a1;
        
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule2Test30 ',
                                    Company = 'O2SandboxAP01TestModule2Test30',
                                    Postalcode = 'SW3 9XY',
                                    LeadSource = 'O2 Sandbox Existing30',
                                    No_of_Connections__c = 5,
                                    No_Fixed_Connections__c = 0,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
                                   );
        insert fixedLead;
        
        List<Lead> fixedLeads = [SELECT Id, OwnerId, Owner.Name FROM LEAD where Id=:fixedLead.Id];
        List<Account> sfAccounts = [SELECT Id, OwnerId, Name
                                      FROM Account
                                     WHERE Name = 'O2SandboxAP01TestModule2Test30' AND Postcode__c = 'SW3 9XY' AND Postcode__c != null];
        System.AssertEquals(1, fixedLeads.size());
        System.AssertEquals(1, sfAccounts.size());
        System.AssertEquals(sfAccounts[0].OwnerId, fixedLeads[0].OwnerId);
    }

}