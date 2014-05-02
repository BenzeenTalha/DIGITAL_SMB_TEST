// This class reads the Parent Lead based on an external Id (Tree Parent Org Reg No) and populates 
//  a Custon Lookup field (Tree_Parent_ID) to build a link between the two records
// based on the Lead passed to it. This allows a Related list od dependents to be displayed
// Note that the TreeId of the Parent is the field linking the Leads.
// 
public class cLinkParentLead {
   public static void LinkParentLead(Lead[] CurrentLead){
      //
      Lead PL;
      boolean Finished = false,  logit;
      string strErrorAction;
      logit = true;
      //
      try{
         for (Lead CL:CurrentLead) {
            if (CL.Tree_Parent_Org_Reg_No__c != null) {
               // Read the Parent Lead using the Tree_Id__c to get the Parents record Id
               strErrorAction = '[select ID from Lead where Tree_Org_Reg_no__c = :CL.Tree_Parent_Org_Reg_no__c limit 1].ID;';
               CL.Tree_Parent_ID__c = [select ID from Lead where Tree_Org_Reg_no__c = :CL.Tree_Parent_Org_Reg_no__c limit 1].ID;
               //
               strErrorAction = 'update Current Lead (CL)';
            }                             // End If
            
            if (CL.Related_Company__c != null) {
               // Read the Company Record using the Related_Company__c and put it's Id onto the Lead record
               strErrorAction = '[select ID from Company_Hierarchy__c where Company_Number__c = CL:Related_Company__C limit 1];';
               CL.Related_Company_Id__c = [select ID from Company_Hierarchy__c where Company_Number__c = :CL.Related_Company__c limit 1].ID;
            }                             // End If
         }                                // End of For
      }                                   // End of try
      catch (Exception e) {
         if (logit) {
            Error_Log__c err = new Error_Log__c (
                 Error_Message__c = e.getMessage()
               , Error_Type__c = e.getTypeName()
               , Error_Action__c = strErrorAction
            ); 
            insert err;
         }
      }                                   // catch
   }                                      // End of CheckParentFireld
   //

}                                         // End of Class MyLeadValidation