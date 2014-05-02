/*****************************************************************************/
/* Paul Tarpey (paul.tarpey@saaspoint.com)                                   */
/* This is the controller for the SFDC accept/reject wizard                  */
/*                                                                           */
/* Revision History                                                          */
/* 0.1    15/02/2009  Initial Version                                        */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/
public class Accept_Reject_Controller {
 
	// Account being controlled
	private Account acct;
	private Boolean forceException = false;
	public String errorDescription {get; private set;}
	
	// Cancel the search
	public PageReference cancelSearch() {
		return new PageReference('/' + acct.Id);
	}
	
	public PageReference accept() {
		User recordOwner = [Select email,username From User Where Id = :acct.OwnerId];
		User currentUser = [Select email,username From User Where Id = :UserInfo.getUserId()];
		
		// Call force handover to tell OAR of the change
		Boolean forceException = false;
		XMLDom forceResponse;
		try {
			System.debug('calling force response');
			forceResponse = O2_linkage_utils.forceHandOverAccount(	this.acct.Id,
			 														recordOwner.username, 
			 														currentUser.username);
			 														
			XMLDom.Element elem = forceResponse.ownerDocument().getElementByTagName('Status');
			if (elem.getAttribute('Value') != '1') {
				XMLDom.Element des = forceResponse.ownerDocument().getElementByTagName('Description');
				this.errorDescription = des.getAttribute('Value');
			}			 														
		} // end forcehandover try
		catch (Exception e) {
			System.debug('in exception ' + e);
			forceException = true;
			this.errorDescription = e.getMessage();
		} // end forcehandover exception block

		// Redirect to the error page if necessary
		if ((this.errorDescription != null) || (this.forceException)) {
			return Page.Accept_Reject_Error;
		} // end error check if
		
		// Set the owner to the current logged in user
		Account updateAccount = new Account(Id = this.acct.Id,
											OwnerId = UserInfo.getUserId(),
											OAR_Account_1_Handover_Status__c = '',
											OAR_Account_2_Handover_Status__c = '',
											OAR_Account_3_Handover_Status__c = '',
											OAR_Account_4_Handover_Status__c = '');
		update updateAccount;	
		
		// Change the ownership of all related contacts too
		List<Contact> contactsForUpdate = new List<Contact>();
		List<Contact> relatedContacts = [Select OwnerId From Contact Where AccountId = :this.acct.Id];
		for (Contact con : relatedContacts) {
			System.debug('Contact found with owner id = ' + con.OwnerId);
			if (con.OwnerId == acct.OwnerId) contactsForUpdate.add(new Contact(Id = con.Id, OwnerId = UserInfo.getUserId()));
		}
		if (contactsForUpdate.size() > 0) update contactsForUpdate;
		System.debug(contactsForUpdate);
		
		// Prepare email
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		// Email to address
		String[] toAddresses = new String[] {recordOwner.email};
		//String[] toAddresses = new String[] {'CPTarpey@yahoo.de'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo(currentUser.email);
		mail.setSenderDisplayName(UserInfo.getName());
		mail.setSubject(Label.HANDOVER_ACC_SUBJECT + ' ' + this.acct.Name);
		String htmlBody = Label.HANDOVER_ACC_EMAIL;
		mail.setHtmlBody(htmlBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
						
		return cancelSearch();
	} // end accept
			
	public PageReference reject() {
		Account updateAccount = new Account(Id = this.acct.Id,
											OAR_Account_1_Handover_Status__c = O2_linkage_configuration.getParam('HAND_OVER_DECLINED'));
											
		// If there are other billing codes, then these are rejected too
		if (this.acct.DISE_Group_Code_Account_No_2__c != null) updateAccount.OAR_Account_2_Handover_Status__c = O2_linkage_configuration.getParam('HAND_OVER_DECLINED');										
		if (this.acct.DISE_Group_Code_Account_No_3__c != null) updateAccount.OAR_Account_3_Handover_Status__c = O2_linkage_configuration.getParam('HAND_OVER_DECLINED');										
		if (this.acct.DISE_Group_Code_Account_No_4__c != null) updateAccount.OAR_Account_4_Handover_Status__c = O2_linkage_configuration.getParam('HAND_OVER_DECLINED');																		
		update updateAccount;	
		
		User recordOwner = [Select email From User Where Id = :acct.OwnerId];
		User currentUser = [Select email From User Where Id = :UserInfo.getUserId()];
												
		// Prepare email
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		// Email to address
		String[] toAddresses = new String[] {recordOwner.email};
		//String[] toAddresses = new String[] {'CPTarpey@yahoo.de'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo(currentUser.email);
		mail.setSenderDisplayName(UserInfo.getName());
		mail.setSubject(Label.HANDOVER_DEC_SUBJECT + ' ' + this.acct.Name);
		String htmlBody = Label.HANDOVER_DEC_EMAIL;
		mail.setHtmlBody(htmlBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		return cancelSearch();
	}
	
	// Return true if this account is at the correct stage for accepting
	// and the requested user is the logged in user
	public Boolean getValidAccount() {
		System.debug(this.acct.OAR_Account_1_Owner_Id__c);
		System.debug(UserInfo.getUserName());

		if ((this.acct.OAR_Account_1_Handover_Status__c == O2_linkage_configuration.getParam('HANDED_OVER_WAIT')) &&
			(this.acct.OAR_Account_1_Owner_Id__c == UserInfo.getUserName())) {
			return true;
		}
		else {
			return false;
		}
	} // end getValidAccount
	
	public Boolean getNotValidAccount() {
		return !getValidAccount();
	}

	// Constructor
	public Accept_Reject_Controller(ApexPages.StandardController stdController) {
	    this.acct = (Account)stdController.getRecord();
	} // end constructor
	

} // end class