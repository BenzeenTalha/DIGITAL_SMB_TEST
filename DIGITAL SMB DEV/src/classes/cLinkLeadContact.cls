// This class reads the Lead of a Lead Contact based on an external Id (Tree Org Reg No) and populates 
//  a Custom Lookup field (Lead__c) to build a link between the two records
// based on the Lead passed to it. This allows a Related list of dependents to be displayed
// Note that the TreeId of the Lead is the field linking the Contacts.
// 
public class cLinkLeadContact {
   public static void LinkLeadContact(Contacts_For_Leads__c[] CurrentChild){
      //
      boolean debugit = false,  logit;
      string strErrorAction;
      logit = true;
      //
      try{
         for (Contacts_For_Leads__c CC:CurrentChild) {
            if (CC.Tree_Organisation_ID__c != null) {
               // Read the Parent using the Tree_Org_Reg_No__c to get the Parent record Id
               strErrorAction = '[select ID from Lead where Tree_Org_Reg_no__c = :CC.Tree_Organisation_ID__c limit 1]';
               CC.Lead__c = [select ID from Lead where Tree_Org_Reg_no__c = :CC.Tree_Organisation_ID__c limit 1].ID;
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


}                                         // End of Class MyLeadValidation