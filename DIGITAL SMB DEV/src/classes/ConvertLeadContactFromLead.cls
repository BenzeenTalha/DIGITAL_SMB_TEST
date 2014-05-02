public class ConvertLeadContactFromLead {

   public static void CreateLeadContacts(Lead[] TheseLeads){
      //
      Boolean         LogIt; 
      String          strLeadId, strErrorAction;
      Integer         i;
      //
      system.debug('*** in ConvertLeadContacts');
      try{ 
         for (Lead TA:TheseLeads) {
            LogIt = False ;                        
            //
            // Expect maximum one Lead from the Account, maybe none if Account was keyed directly
            strErrorAction = 'Read Lead where ConvertedAccountID = ' + TA.ID;
            Lead L = TA;
            //
            // If any Lead found, Read any Lead Contacts
            //
            if (L.ID != null) {
                system.debug('*** Lead ID is ' + L.ID);
               LogIt = True ; 
               strErrorAction = '*** Select Lead Contact details for the Lead ';
               //
               for (List<Contacts_for_Leads__c> LC :  [select 
                      Id
                     ,Buying_Role__c
                     ,Comp_ID__c
                     ,DDI__c
                     ,DMC__c
                     ,DMC_Data__c
                     ,DMC_IT__c
                     ,DMC_Mobile__c
                     ,DMC_Senior_IT__c
                     ,e_mail__c
                     ,First_Name__c
                     ,Last_Name__c
                     ,Lead__c
                     ,O2_Corporate_Magazine__c
                     ,OwnerId
                     ,Phone__c
                     ,Salutation__c
                     ,Title__c
                     ,Tree_Organisation_Id__c
                     ,V2_Contacts_ID__c
                  from Contacts_for_Leads__c where Lead__c = :L.ID]) {
                  //
                  for(i = 0; i < LC.size(); i++) {
                     //if (debugit) {system.debug('*** Lead Contact Name is ' + LC[i].Last_Name__c) ;}
                     strErrorAction = 'Insert New Contact for ' + LC[i].Last_Name__c + ' Account Id ' + TA.ID;
                     //
                     Contact C = new Contact (
                         Buying_Role__c = LC[i].Buying_Role__c
                        ,DDI__c = LC[i].DDI__c
                        ,DMC__c = LC[i].DMC__c
                        ,DMC_Data__c = LC[i].DMC_Data__c
                        ,DMC_IT__c = LC[i].DMC_IT__c
                        ,DMC_Mobile__c = LC[i].DMC_Mobile__c
                        ,DMC_Senior_IT__c = LC[i].DMC_Senior_IT__c
                        ,Email = LC[i].e_mail__c
                        ,FirstName = LC[i].First_Name__c
                        ,LastName = LC[i].Last_Name__c
                        ,O2_Corporate_Magazine__c = LC[i].O2_Corporate_Magazine__c
                        ,OwnerId = LC[i].OwnerId
                        ,Phone = LC[i].Phone__c
                        ,Salutation = LC[i].Salutation__c
                        ,Title = LC[i].Title__c
                        ,Tree_Individual_ID__c = LC[i].Tree_Organisation_Id__c
                        ,V2_Contact_ID__c = LC[i].V2_Contacts_ID__c
                        ,AccountID = TA.ConvertedAccountId
                     );
                     insert C;
                  }
               }                          // for (List<Lead_Contact__c)LC :
            } else {
                system.debug('*** Lead ID is null');
            }                            // If L.ID != null
         }                                // End of For
      }                                   // End of try
      catch (Exception e) {
         if (LogIt)  {
            Error_Log__c err = new Error_Log__c (
                 Error_Message__c = e.getMessage()
               , Error_Type__c = e.getTypeName()
               , Error_Action__c = strErrorAction
            ); 
            insert err;
         }                                // If Logit
      }                                   // catch
   }                                      // End of class ConvertLeadContacts 
   //
 

}