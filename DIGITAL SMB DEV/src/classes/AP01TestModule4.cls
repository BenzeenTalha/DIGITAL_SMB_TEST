/*
* Lead Assignment Module 4 – Retail.
* - Check Store/Branch is CoE Aligned or not.
* 
* Revision history
* June 2010 Colin Kenworthy (Radius Technology) - initial version
*/
public class AP01TestModule4 {
    
    static String THIS_TEST = 'Retail';
    
    
    
    public static void RunTest(AP01Lead.wrapperLead thisWrapperLead) {
        // check Lead properties.
        String lookup;
        
        if (thisWrapperLead.le.NumberOfEmployees >= thisWrapperLead.le.f_Corporate_Employees_Start_Point__c) {
            // lead owner is Corporate queue
            lookup = 'Corporate';
            thisWrapperLead.processed=TRUE;
            thisWrapperLead.matchedRule=THIS_TEST;
            thisWrapperLead.newOwnerName=AP01Lead.GetCorporateNameForPostcode(thisWrapperLead.halfPostcode);
            System.Debug('##### AP01TestModule4 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Corporate postcode lookup for '+thisWrapperLead.halfPostcode);
        } else {
            Boolean treatAsNonCoE=FALSE;
            Boolean isCoEAligned = AP01Lead.BranchIsCoEAligned(thisWrapperLead.le.Referred_From_Branch_Code__c)<>null && AP01Lead.BranchIsCoEAligned(thisWrapperLead.le.Referred_From_Branch_Code__c);
            if (isCoEAligned) {
                // lead owner is CoE
                lookup = 'CoE';
                thisWrapperLead.processed=TRUE;
                thisWrapperLead.matchedRule=THIS_TEST;
                thisWrapperLead.newOwnerName=AP01Lead.GetCoEAlignedNameForPostcode(thisWrapperLead.halfPostcode);
                System.Debug('##### AP01TestModule4 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. CoE postcode lookup for '+thisWrapperLead.halfPostcode);
                if (thisWrapperLead.newOwnerName == null) {
                    treatAsNonCoE=TRUE;
                }
            }
            if (treatAsNonCoE || ! isCoEAligned) {
                if (thisWrapperLead.le.No_of_Connections__c > thisWrapperLead.le.f_Franchise_Max_MPN__c) {
                    // lead owner is Aquisition
                    lookup = 'Aquisition';
                    thisWrapperLead.processed=TRUE;
                    thisWrapperLead.matchedRule=THIS_TEST;
                    thisWrapperLead.newOwnerName=AP01Lead.GetAquisitionNameForPostcode(thisWrapperLead.halfPostcode);
                    System.Debug('##### AP01TestModule4 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Aquisition postcode lookup for '+thisWrapperLead.halfPostcode);
                } else {
                    // lead owner is Franchise
                    lookup = 'Franchise';
                    thisWrapperLead.processed=TRUE;
                    thisWrapperLead.matchedRule=THIS_TEST;
                    thisWrapperLead.newOwnerName=AP01Lead.GetFranchiseNameForPostcode(thisWrapperLead.halfPostcode);
                    System.Debug('##### AP01TestModule4 ##### Setting owner name to '+thisWrapperLead.newOwnerName+'. Franchise postcode lookup for '+thisWrapperLead.halfPostcode);
                }
            }
        }
        // in case no Lead Owner was pulled back then output meaningful error
        if (thisWrapperLead.newOwnerName == null || thisWrapperLead.newOwnerName == '') {
            System.Debug('##### AP01TestModule4 ##### Could not assign to '+lookup+' for post code '+thisWrapperLead.halfPostcode+'.');
        }
    
    }
    
    
}