/**
 * Description: Linkage Inbound Email Handler.  This class is automatically called by 
 * Salesforce when email messages are received from OAR O2 Linkage Project.  This
 * code determines what action to follow based on the subject line
 *
 * Author: Paul Tarpey, Saaspoint, December 2008
 *
 * Version History:
 * 1 - Initial Version
 */
 
// Global email handler class
global class LinkageInboundEmail implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

		List<Email_Log_Entry__c> messages = new List<Email_Log_Entry__c>();
		messages.add(new Email_Log_Entry__c(Message__c = 'Got inbound email'));
		messages.add(new Email_Log_Entry__c(Message__c = 'subject = ' + email.subject));
		messages.add(new Email_Log_Entry__c(Message__c = 'body = ' + email.plainTextBody));
		
    	// Check for subjects that match digit:digit (instruction followed by id)
    	pattern subjectPattern = pattern.compile('(\\d+):(\\d+)');
    	matcher subjectMatcher = subjectPattern.matcher(email.subject);

    	if(subjectMatcher.matches()) {
    		messages.add(new Email_Log_Entry__c(Message__c = 'matched on subject'));
    		
    		// We have a match so collect the instruction code and the record id
	    	String code = subjectMatcher.group(1);
			String OARId = subjectMatcher.group(2);  
			
			// Process for OAR handover response
			if (code == '1') {
				messages.add(new Email_Log_Entry__c(Message__c = 'processing for code = 1'));
				// Should get a response integer:message
				pattern bodyPattern = pattern.compile('(\\d+):(.+)\\n');
				matcher bodyMatcher = bodyPattern.matcher(email.plainTextBody);
				if (bodyMatcher.matches()) {
					messages.add(new Email_Log_Entry__c(Message__c = 'body pattern match'));
					// Dig out the code and the text
					String response = bodyMatcher.group(1);
					String message = bodyMatcher.group(2);

					// Select back the record with this OAR id
					List<Account> accts = [	Select	Id,
													OAR_Account_1_Owner_Name__c,
													OAR_Account_Reference_4__c,
													OAR_Account_Reference_3__c,
													OAR_Account_Reference_2__c,
													OAR_Account_Reference_1__c,
													OAR_Account_1_Handover_Status__c,
													OAR_Account_2_Handover_Status__c,
													OAR_Account_3_Handover_Status__c,
													OAR_Account_4_Handover_Status__c
											From	Account
											Where 	OAR_Account_Reference_4__c = :OARId
											Or		OAR_Account_Reference_3__c = :OARId
											Or		OAR_Account_Reference_2__c = :OARId
											Or		OAR_Account_Reference_1__c = :OARId];

					// We should get one record back only
					if (accts.size() == 1) {
						messages.add(new Email_Log_Entry__c(Message__c = 'found matching sfdc account id = ' + accts.get(0).Id));
						// Prepare update record
						Account updateAccount = new Account(Id = accts.get(0).Id);
						
						// Process if it is the first billing code that matches
						if ((accts.get(0).OAR_Account_Reference_1__c == OARId) && 
							(accts.get(0).OAR_Account_1_Handover_Status__c == O2_linkage_configuration.getParam('HANDED_OVER_WAIT'))) {
							updateAccount.OAR_Account_1_Response__c = message;
							if (response == '0') {
								updateAccount.OAR_Account_1_Handover_Status__c = 'Hand Over Declined';
							}
							else {
								updateAccount.OAR_Account_1_Handover_Approved_Date__c = Datetime.now();
								updateAccount.OAR_Account_1_Handover_Status__c = 'Handed Over - Approved';
							}
						} // end check first billing code

						// Process if it is the second billing code that matches
						if ((accts.get(0).OAR_Account_Reference_2__c == OARId) && 
							(accts.get(0).OAR_Account_2_Handover_Status__c == O2_linkage_configuration.getParam('HANDED_OVER_WAIT'))) {
							updateAccount.OAR_Account_2_Response__c = message;
							if (response == '0') {
								updateAccount.OAR_Account_2_Handover_Status__c = 'Hand Over Declined';
							}
							else {
								updateAccount.OAR_Account_2_Handover_Approved_Date__c = Datetime.now();
								updateAccount.OAR_Account_2_Handover_Status__c = 'Handed Over - Approved';
							}
						} // end check second billing code

						// Process if it is the third billing code that matches
						if ((accts.get(0).OAR_Account_Reference_3__c == OARId) && 
							(accts.get(0).OAR_Account_3_Handover_Status__c == O2_linkage_configuration.getParam('HANDED_OVER_WAIT'))) {
							updateAccount.OAR_Account_3_Response__c = message;
							if (response == '0') {
								updateAccount.OAR_Account_3_Handover_Status__c = 'Hand Over Declined';
							}
							else {
								updateAccount.OAR_Account_3_Handover_Approved_Date__c = Datetime.now();
								updateAccount.OAR_Account_3_Handover_Status__c = 'Handed Over - Approved';
							}
						} // end check third billing code
						
						
						// Process if it is the fourth billing code that matches
						if ((accts.get(0).OAR_Account_Reference_4__c == OARId) && 
							(accts.get(0).OAR_Account_4_Handover_Status__c == O2_linkage_configuration.getParam('HANDED_OVER_WAIT'))) {
							updateAccount.OAR_Account_4_Response__c = message;
							if (response == '0') {
								updateAccount.OAR_Account_4_Handover_Status__c = 'Hand Over Declined';
							}
							else {
								updateAccount.OAR_Account_4_Handover_Approved_Date__c = Datetime.now();
								updateAccount.OAR_Account_4_Handover_Status__c = 'Handed Over - Approved';
							}
						} // end check fourth billing code		

						// We need to change the Salesforce owner too
						// Get the lookup from the employee table
						List<Employee_Table_OAR__c> ownerRecs = new List<Employee_Table_OAR__c>([Select SFDC_Lookup__c From Employee_Table_OAR__c Where Name__c = :accts.get(0).OAR_Account_1_Owner_Name__c And Role__c in ('BAM','BRM') Limit 1]);
						System.debug('ownerrecs in new table = ' + ownerRecs);
						
						// Set the default owner id
						Id ownerIdToUse = O2_linkage_configuration.getParam('HANDOVER_DEFAULT_ID');
						System.debug('Default id to use = ' + ownerIdToUse);
						
						// If not there then get the default Salesforce userid
						if (ownerRecs.size() == 1) {
							List<User> userRecs = new List<User>([Select Id From User Where Name = :ownerRecs.get(0).SFDC_Lookup__c Limit 1]);
							System.debug('User rec found = ' + userRecs);
							if (userRecs.size() == 1) {
								ownerIdToUse = userRecs.get(0).Id;
							}
						}
						
						updateAccount.OwnerId = ownerIdToUse;
						update updateAccount;
						System.debug('Update account rec = ' + updateAccount);
					} // end check that one record was returned if
				} // end body matches check if
			} // end code = 1 (accept reject handover) if
			else {
				System.debug('Did not match 1 trying to match 2');
				messages.add(new Email_Log_Entry__c(Message__c = 'fail match on 1 so trying 2'));
				
				// Check if the incoming message is for an OAR to OAR owner change
				if (code == '2') {
					messages.add(new Email_Log_Entry__c(Message__c = 'matched on 2'));
					// Attempt to match user id:user name
					pattern bodyPattern = pattern.compile('(\\d+):(.+)\\n');
					matcher bodyMatcher = bodyPattern.matcher(email.plainTextBody);
					if (bodyMatcher.matches()) {
						messages.add(new Email_Log_Entry__c(Message__c = 'body matched'));
						// Dig out the code and the text
						String OARUserId = bodyMatcher.group(1);
						String OARUserName = bodyMatcher.group(2);
						messages.add(new Email_Log_Entry__c(Message__c = 'got oar user id = ' + OARUserId));
						messages.add(new Email_Log_Entry__c(Message__c = 'got oar user name = ' + OARUserName));
						// Select back the record with this OAR id
						List<Account> accts = [	Select	Id,
														OAR_Account_Reference_1__c,
														OAR_Account_Reference_2__c,
														OAR_Account_Reference_3__c,
														OAR_Account_Reference_4__c
												From	Account
												Where 	OAR_Account_Reference_1__c = :OARId
												Or		OAR_Account_Reference_2__c = :OARId
												Or		OAR_Account_Reference_3__c = :OARId
												Or		OAR_Account_Reference_4__c = :OARId];
						
						// We should get one record back only
						if (accts.size() == 1) {
							
							// Prepare update record
							Account updateAccount = new Account(Id = accts.get(0).Id);
							messages.add(new Email_Log_Entry__c(Message__c = 'found account = ' + accts.get(0).Id));
							// Process if it is the first billing code that matches
							if (accts.get(0).OAR_Account_Reference_1__c == OARId) {
								updateAccount.OAR_Account_1_Owner_Name__c = OARUserName;
								updateAccount.OAR_Account_1_Owner_Id__c = OARUserId;
							} // end check first billing code
							
							// Process if it is the second billing code that matches
							if (accts.get(0).OAR_Account_Reference_2__c == OARId) {
								updateAccount.OAR_Account_2_Owner_Name__c = OARUserName;
								updateAccount.OAR_Account_2_Owner_Id__c = OARUserId;
							} // end check second billing code
							
							// Process if it is the third billing code that matches
							if (accts.get(0).OAR_Account_Reference_3__c == OARId) {
								updateAccount.OAR_Account_3_Owner_Name__c = OARUserName;
								updateAccount.OAR_Account_3_Owner_Id__c = OARUserId;
							} // end check third billing code
							
							// Process if it is the fourth billing code that matches
							if (accts.get(0).OAR_Account_Reference_4__c == OARId) {
								updateAccount.OAR_Account_4_Owner_Name__c = OARUserName;
								updateAccount.OAR_Account_4_Owner_Id__c = OARUserId;
							} // end check fourth billing code						
								
							update updateAccount;
						} // end 1 record found check if
					} // end found match check if
				} // end code = 2 (change oar owner) if
				else {
					System.debug('failed to match 2 code');
				}
			} // end code = 1 (accept reject handover) else
    	} // end subject matches (code:id) if
    	else {
    		System.debug('subject no match');
    	}
    	
    	// Prepare a result message as one is required by the interface !	
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        messages.add(new Email_Log_Entry__c(Message__c = 'exiting'));
        insert messages;
        return result;
    }
    

} // end class