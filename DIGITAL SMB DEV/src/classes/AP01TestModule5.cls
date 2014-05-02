/*
* Lead Assignment Module 5 – DBAM Referral
* - .
* 
* Revision history
* June 2010 Colin Kenworthy (Radius Technology) - initial version
*/
public class AP01TestModule5 {
    
    static String THIS_TEST = 'DBAM';
    
    
    
    public static void RunTest(AP01Lead.wrapperLead thisWrapperLead) {
        // check Lead properties.
        String lookup;
        
        if (   thisWrapperLead.le.NumberOfEmployees >= thisWrapperLead.le.f_Corporate_Employees_Start_Point__c
            && thisWrapperLead.le.No_of_Connections__c > thisWrapperLead.le.f_DBAM_Max_MPN__c) {
            // lead owner is corporate queue
            lookup = 'Corporate';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerName=AP01Lead.GetCorporateNameForPostcode(thisWrapperLead.halfPostcode);
            System.Debug('##### AP01TestModule5 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Corporate postcode lookup for '+thisWrapperLead.halfPostcode);
        } else
        if (thisWrapperLead.le.No_of_Connections__c > thisWrapperLead.le.f_DBAM_Max_MPN__c) {
            // lead owner is Aquisition
            lookup = 'Aquisition';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerName=AP01Lead.GetAquisitionNameForPostcode(thisWrapperLead.halfPostcode);
            System.Debug('##### AP01TestModule5 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Aquisition postcode lookup for '+thisWrapperLead.halfPostcode);
        } else {
            // lead owner is DBAM
            lookup = 'DBAM';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerName=AP01Lead.GetDBAMNameForPostcode(thisWrapperLead.halfPostcode);
            System.Debug('##### AP01TestModule5 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. DBAM postcode lookup for '+thisWrapperLead.halfPostcode);
        }
        // in case no Lead Owner was pulled back then output meaningful error
        if (thisWrapperLead.newOwnerName == null || thisWrapperLead.newOwnerName == '') {
            System.Debug('##### AP01TestModule5 ##### Could not assign to '+lookup+' for post code '+thisWrapperLead.halfPostcode+'.');
        }

    }
    
        
}