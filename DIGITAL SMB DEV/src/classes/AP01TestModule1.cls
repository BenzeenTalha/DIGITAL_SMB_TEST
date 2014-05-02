/*
* Lead Assignment Module 1 – Fixed Line / Azzurri.
* - 5 or less MPN in lead goes directly to Azzurri
* 
* Revision history
* June 2010 Colin Kenworthy (Radius Technology) - initial version
* 7 July 2010 Colin Kenworthy - check for null in No_of_Connections__c
*/
public class AP01TestModule1 {
    
    static String THIS_TEST = 'Fixed';
    
    
    
    public static void RunTest(AP01Lead.wrapperLead thisWrapperLead) {
        // if 0 or less then assign to Azzurri.
        if ( (thisWrapperLead.le.No_of_Connections__c == null) || (thisWrapperLead.le.No_of_Connections__c <= thisWrapperLead.le.f_Max_MPN_For_Fixed__c) ) {
            thisWrapperLead.processed = TRUE;
            thisWrapperLead.matchedRule = THIS_TEST;
            thisWrapperLead.newOwnerId = thisWrapperLead.le.f_Azzurri_Fixed_Queue_Id__c; // Q01 Azzurri Fixed
            System.Debug('##### AP01TestModule1 ##### Setting owner Id to '+thisWrapperLead.le.f_Azzurri_Fixed_Queue_Id__c+' (Azzurri Fixed Queue)');
        }
    
    }
    

//**********************************************************************************************
//*
//*     TEST METHODS
//*
//**********************************************************************************************
    public static testMethod void Test01() {
        Lead_Auto_Assignment_Parameter__c fixedParam = new Lead_Auto_Assignment_Parameter__c( Lead_Source__c = 'O2 Sandbox Fixed 01',
                                                                                              Test_Entry__c = 'Fixed|Existing|Online'
                                                                                             );
        insert fixedParam;
        
        Lead fixedLead = new Lead ( Salutation = 'Mr.',
                                    FirstName = 'ccccc',
                                    LastName = 'O2SandboxAP01TestModule1Test01',
                                    Postcode__c = 'XX1 9ZZ',
                                    LeadSource = 'O2 Sandbox Fixed 01',
                                    //No_of_Connections__c = 0,
                                    No_Fixed_Connections__c = 4,
                                    NumberOfEmployees = 50,
                                    O2_Sector__c = 'Government'
                                   );
        insert fixedLead;
        List<Lead> fixedLeads = [SELECT Id, OwnerId, Owner.Name FROM LEAD where Id=:fixedLead.Id];
        System.AssertEquals(1, fixedLeads.size());
        System.AssertEquals('Q01 - Azzurri Fixed', fixedLeads[0].Owner.Name);
    }

}