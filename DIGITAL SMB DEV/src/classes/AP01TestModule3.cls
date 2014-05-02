/*
* Lead Assignment Module 3 – Online / Direct (employee or FAM/aquisition referrals ) / Franchise / Staff / Self-Leads / Customer.
* - .
* 
* Revision history
* June 2010 Colin Kenworthy (Radius Technology) - initial version
*/
public class AP01TestModule3 {
    
    static String THIS_TEST = 'Online';
    
    
    
    public static void RunTest(AP01Lead.wrapperLead thisWrapperLead) {
        // check Lead properties.
        String lookup;
        
        if (thisWrapperLead.le.NumberOfEmployees >= thisWrapperLead.le.f_Corporate_Employees_Start_Point__c) {
            // lead owner is corporate queue
            lookup = 'Corporate';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerName=AP01Lead.GetCorporateNameForPostcode(thisWrapperLead.halfPostcode);
            System.Debug('##### AP01TestModule3 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Corporate postcode lookup for '+thisWrapperLead.halfPostcode);
        } else
        if (thisWrapperLead.le.No_of_Connections__c > thisWrapperLead.le.f_DMU_Max_MPN__c) {
            // lead owner is Aquisition
            lookup = 'Aquisition';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerName=AP01Lead.GetAquisitionNameForPostcode(thisWrapperLead.halfPostcode);
            System.Debug('##### AP01TestModule3 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Aquisition postcode lookup for '+thisWrapperLead.halfPostcode);
        } else {
            // lead owner is DMU
            lookup = 'DMU';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerName=AP01Lead.GetDMUNameForPostcode(thisWrapperLead.halfPostcode);
            System.Debug('##### AP01TestModule3 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. DMU postcode lookup for '+thisWrapperLead.halfPostcode);
        }
        // in case no Lead Owner was pulled back then output meaningful error
        if (thisWrapperLead.newOwnerName == null || thisWrapperLead.newOwnerName == '') {
            System.Debug('##### AP01TestModule3 ##### Could not assign to '+lookup+' for post code '+thisWrapperLead.halfPostcode+'.');
        }

    }
    
        
}