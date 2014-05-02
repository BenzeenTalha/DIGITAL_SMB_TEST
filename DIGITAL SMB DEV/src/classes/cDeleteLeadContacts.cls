public class cDeleteLeadContacts 
{
   public static void DeleteLeadContacts(Lead[] CurrentLead, Map<Id, Lead> LeadMap)
   {
      boolean logit = true; 
      string  strErrorAction;
      //
      Map<Id, Contacts_for_Leads__c> DeleteMap = new Map<Id, Contacts_for_Leads__c>(); 
      
      //
      try{
         /* for (Lead CL:CurrentLead){
            // Look for the Parent Company by Company Number to get it's ID
            //
            strErrorAction = '*** [select ID, Tree_Organisation_Id__c from Contacts_for_Leads__c where Lead__c = :CL.ID]';
            Contacts_for_Leads__c[] CFL = [select ID, Tree_Organisation_Id__c from Contacts_for_Leads__c where Lead__c = :CL.ID];
            //
            if (CFL.size() > 0){  
               for (Integer i = 0; i < CFL.size(); i++){
                  DeleteMap.put(CFL[i].ID, new Contacts_for_Leads__c(Id = CFL[i].ID, Tree_Organisation_Id__c = CFL[i].Tree_Organisation_Id__c));
               }
               //      
               if (DeleteMap.size() > 0) {
                  delete DeleteMap.values();
               }
            }
         } */
         
         Contacts_for_Leads__c[] CFL = [select ID, Tree_Organisation_Id__c from Contacts_for_Leads__c where Lead__c in :LeadMap.keySet()];
         
           if (CFL.size() > 0){  
               for (Integer i = 0; i < CFL.size(); i++){
                  DeleteMap.put(CFL[i].ID, new Contacts_for_Leads__c(Id = CFL[i].ID, Tree_Organisation_Id__c = CFL[i].Tree_Organisation_Id__c));
               }
               //      
               if (DeleteMap.size() > 0) {
                  delete DeleteMap.values();
               }         
           }
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

}                                         // End of Class CheckNoLeadContacts