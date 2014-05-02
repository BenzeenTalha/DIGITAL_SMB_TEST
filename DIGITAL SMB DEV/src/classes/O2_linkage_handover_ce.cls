public class O2_linkage_handover_ce {
	
	// Account being controlled
	private Account acct;
	
	// User entered search filter string
	public String searchFilterString {get;set;}	
	
	// List of users from OAR and SFDC to display
    public List<OARUserListItem> usersForDisplay {public get;private set;}
    
    // Result of OAR Call
    public OARResponse handoverResult {get;public set;}
    
    // Getters and setters    
	
    public String getHandoverDescription() {
    	return this.handoverResult.description;
    } // end getHandoverDescription
		
	// Constructor for controller extension
	public O2_linkage_handover_ce(ApexPages.StandardController stdController) {
	    this.acct = (Account)stdController.getRecord();
	} // end constructor
	
	// Action Methods
	// Cancel the search
	public PageReference cancelSearch() {
		return new PageReference('/' + acct.Id);
	} // end cancelSearch
		
	// Move to step 1
	public PageReference step1() {
		return Page.O2_linkage_User_Handover_Step1;
	} // end step1
			
	// Move to step 2.
	public PageReference step2() {
		if (this.searchFilterString == '') {
			return Page.O2_linkage_User_Handover_none_selected;
		} // end filter string entered check if
		
        // Get users from OAR provided this account has been registered in OAR
        if (this.acct.OAR_Account_Reference_1__c != null) {
	        try {
	        	System.debug('Calling O2_linkage_utils.getOARUserList');
	        	this.usersForDisplay = O2_linkage_utils.getOARUserList(this.searchFilterString);
	        	System.debug('Back from O2_linkage_utils.getOARUserList');
	        } // end try block
	        catch (Exception e) {
	        	return Page.O2_linkage_User_Handover_Dropdown_Error;
	        } // end exception block
        }
        else {
        	this.usersForDisplay = new List<OARUserListItem>();
        }
        
        // Query back the users from Salesforce and add them to the list
        String compareString = '%' + this.searchFilterString + '%';
        List<User> salesforceUsers = [Select Username, Phone, LastName, Id, FirstName, Email From User Where Name Like :compareString AND IsActive=true]; // Mirco changed that. "is active"
        for (User salesforceUser : salesforceUsers) {
        	OARUserListItem item = new OARUserListItem();
        	item.firstName = salesforceUser.FirstName;
        	item.lastName = salesforceUser.LastName;
        	item.telephone = salesforceUser.Phone;
        	item.email = salesforceUser.Email;
        	item.salesforceUserName = salesforceUser.Username;
        	item.userId = 'none';
        	item.salesforceFlag = 'Yes';
        	this.usersForDisplay.add(item);
        } // end loop through matching Saleforce users
        System.debug('Paul list is ' + usersForDisplay);
		// If there are no elements, redirect to warning screen
		if (usersForDisplay.size() == 0) return Page.O2_linkage_User_Handover_Warn_No_Users;
		return Page.O2_linkage_User_Handover_Step2;
	} // end step2 function	
	
	// Move to step 3
	public PageReference step3() {
		String selectedId = this.getSelectedId();
		if (selectedId == null) return Page.O2_linkage_User_Handover_nothing_sel;
		return Page.O2_linkage_User_Handover_Step3;
	} // end step3	
	
	// Move to step 4
	public PageReference step4() {
		if ((this.acct.OAR_Account_1_Handover_Comment__c == null) || (this.acct.OAR_Account_1_Handover_Effective_Date__c == null)) {
			return Page.O2_linkage_User_Handover_Blank_Field;
		}
		String ownerId;
		
		// Process for handover to Salesforce User
		if (this.getSelectedId() == 'none') {
								
			ownerId = this.getSelectedSalesforceName();
			
			// Send an email to the user we are handing to
			// Get the current user email address
			User currentUser = [Select email From User Where Id = :UserInfo.getUserId()];
			
			// Prepare email
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			// Email to address
			String[] toAddresses = new String[] {this.getSelectedEmail()};
			//String[] toAddresses = new String[] {'CPTarpey@yahoo.de'};
			mail.setToAddresses(toAddresses);
			mail.setReplyTo(currentUser.email);
			mail.setSenderDisplayName(UserInfo.getName());
			mail.setSubject(Label.ACCOUNT_HANDOVER);
			String htmlBody = '<b>' + this.acct.Name + '</b><br><br>';
			htmlBody += Label.EMAIL_BODY;
			htmlBody += '<a href=\"https://' + ApexPages.currentPage().getHeaders().get('Host') + '/' + this.acct.Id + '\">Link</a>';
			mail.setHtmlBody(htmlBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
		}
		else {
			// Handover to an OAR user
			ownerId = this.getSelectedId();
			handoverResult = O2_linkage_utils.handoverAccount(this.acct.Id,this.getSelectedId(),this.acct.OAR_Account_1_Handover_Comment__c,this.acct.OAR_Account_1_Handover_Effective_Date__c);
			System.debug('<Response><Status Value="1" /><Description Value="1" /></Response>');
			if (handoverResult.statusValue != '1') return Page.O2_linkage_User_Handover_Error_Result;
		}
		
		// Success so update the account record
		Account updateAccount = new Account(Id = this.acct.Id,
											OAR_Account_1_Owner_Name__c = this.getSelectedName(), 
											OAR_Account_1_Owner_Id__c = ownerId, 
											OAR_Account_1_Handover_Status__c = O2_linkage_configuration.getParam('HANDED_OVER_WAIT'), 
											OAR_Account_1_Handover_Effective_Date__c = this.acct.OAR_Account_1_Handover_Effective_Date__c, 
											OAR_Account_1_Handover_Comment__c = this.acct.OAR_Account_1_Handover_Comment__c,
											OAR_Account_1_Hand_Over_Requested_Date__c = Datetime.now());

		// Only update the fields for subsequent billing codes if there are any !											
		if (this.acct.DISE_Group_Code_Account_No_2__c != null) updateAccount.OAR_Account_2_Handover_Status__c = O2_linkage_configuration.getParam('HANDED_OVER_WAIT');
		if (this.acct.DISE_Group_Code_Account_No_3__c != null) updateAccount.OAR_Account_3_Handover_Status__c = O2_linkage_configuration.getParam('HANDED_OVER_WAIT');
		if (this.acct.DISE_Group_Code_Account_No_4__c != null) updateAccount.OAR_Account_4_Handover_Status__c = O2_linkage_configuration.getParam('HANDED_OVER_WAIT');
		update updateAccount;												
		
		return Page.O2_linkage_User_Handover_Step4;

	} // end step4

	
	// Return the id of the selected record
	public String getSelectedId() {
		String retId;
		for (OARUserListItem item : usersForDisplay) {
			if (item.selected) {
				retId = item.userId;
				break;
			}
		} // end loop through the users
		return retId;
	} // end getSelectedId	
	
	// Return the sfdc id of the selected record
	public String getSelectedSalesforceName() {
		String retId;
		for (OARUserListItem item : usersForDisplay) {
			if (item.selected) {
				retId = item.salesforceUserName;
				break;
			}
		} // end loop through the users
		return retId;
	} // end getSelectedSalesforceId	
		
	// Return the user name of the selected record
	public String getSelectedName() {
		String retId;
		for (OARUserListItem item : usersForDisplay) {
			if (item.selected) {
				retId = item.firstName + ' ' + item.lastName;
				break;
			}
		} // end loop through the users
		return retId;
	} // end getSelectedName

	// Return the id of the selected record
	public String getSelectedEmail() {
		String retId;
		for (OARUserListItem item : usersForDisplay) {
			if (item.selected) {
				retId = item.email;
				break;
			}
		} // end loop through the users
		return retId;
	} // end getSelectedEmail
	
	// Routine returns true if it is allowed to handover an account at this point
	public Boolean getAcc1Valid() {
		if ((this.acct.DISE_Group_Code_Account_No_1__c != null) && 
			(this.acct.OAR_Account_1_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) return true;
		else return false;
	} // end getAcc1Valid
	
	public Boolean getNotAcc1Valid() {
		return !getAcc1Valid();
	} // end getNotAcc1Valid
	
	public String getOARWarning() {
		if (this.acct.OAR_Account_Reference_1__c == null) return Label.NOT_OAR_REG;
		else return null;
	} // end getOARWarning
} // end O2_linkage_handover_ce