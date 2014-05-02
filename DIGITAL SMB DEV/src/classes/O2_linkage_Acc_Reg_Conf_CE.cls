public class O2_linkage_Acc_Reg_Conf_CE {
	
	// Account being controlled

	private Account acct;
	
		// Registered Status Message
	private String registeredStatus = Label.INIT_REG_STAT;
	
		// Get the status of the related account (registered or not!)
	
	public Boolean statusrdy {get;set;}
	
	public String getRegisteredStatus() {
		return this.registeredStatus;
	} // end getRegisteredStatus
	
	// Boilerplate text
	public String getCancelButton() {
		return Label.CANCEL_BUTTON;		
	} // end getCancelButton
	
	public String getAccRegConfMsg() {
		return Label.ACC_REG_CONF_MSG;
	} // end getAccRegConfMsg
	
	public String getRegConfTitle() {
		return Label.REG_CONF_TITLE;
	} // end getRegConfTitle	
	
	public String getConfirmButton() {
		return Label.CONFIRM_BUTTON;		
	} // end getConfirmButton
		
	// Actions
	public PageReference cancel() {
		return new PageReference('/' + this.acct.Id);
	} // end cancel
	
	public void confirm() {
		Account tmp_acc = [SELECT 	DISE_Group_Code_Account_No_4__c, 
									DISE_Group_Code_Account_No_3__c, 
									DISE_Group_Code_Account_No_2__c, 
									DISE_Group_Code_Account_No_1__c, 
									OAR_Account_Reference_1__c, 
									OAR_Account_Reference_4__c, 
									OAR_Account_Reference_3__c, 
									OAR_Account_Reference_2__c, 
									Register_Requested__c 				FROM Account WHERE id = :this.acct.Id];
		tmp_acc.Register_Requested__c = true;
		checkOARRegistered(tmp_acc);
		update tmp_acc;
	} // end confirm
	
	public PageReference checkOARRegistered(Account p_acc) {
		
		statusrdy = true;	
		// Only relevant if user has chosen via button click or something has been registered on this
		// account before (e.g. from the opportunity automatically)
		if ((p_acc.Register_Requested__c) || (p_acc.OAR_Account_Reference_1__c != null)) {
		
			// Only attempt to register if there is a DISE billing code with no
			// corresponding OAR reference
			if (((p_acc.OAR_Account_Reference_1__c == null) && (p_acc.DISE_Group_Code_Account_No_1__c != null)) ||
				((p_acc.OAR_Account_Reference_2__c == null) && (p_acc.DISE_Group_Code_Account_No_2__c != null)) ||
				((p_acc.OAR_Account_Reference_3__c == null) && (p_acc.DISE_Group_Code_Account_No_3__c != null)) ||
				((p_acc.OAR_Account_Reference_4__c == null) && (p_acc.DISE_Group_Code_Account_No_4__c != null))) { 
// Acc REG CHANGE START					
				

				
				
				Integer count = [SELECT count() FROM contact WHERE accountid = :p_acc.id];
				Boolean missing			= false;
				String	missingfield	=	'';
				
				List<Contact> tmp_contactList	=	new List<Contact>();

				tmp_contactList = [SELECT id, Salutation, Title, FirstName, LastName, Buying_Role__c, Phone, Email, MailingCity, MailingPostalCode, MailingStreet FROM Contact WHERE accountid = :p_acc.id];
				
				for(Contact tmp_con : tmp_contactList)
				{
					if(tmp_con.Title == null)
					{	
						count			= -1;
						missing			= true;	
						missingfield	+= 'Title, '; 
					}
					if(tmp_con.FirstName == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'First Name, ';						
					}
					if(tmp_con.LastName == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'Last Name, ';						
					}
					if(tmp_con.Buying_Role__c == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'Buying Role, ';						
					}
					if(tmp_con.Phone == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'Phone, ';						
					}
					if(tmp_con.Email == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'E-Mail, ';						
					}
					if(tmp_con.MailingCity == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'Mailing City, ';						
					}					
					if(tmp_con.MailingPostalCode == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'Postal code, ';						
					}	
					else if(tmp_con.MailingStreet == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'Street, ';						
					}	
					if(tmp_con.Salutation == null)
					{
						count			= -1;
						missing			= true;	
						missingfield	+= 'Salutation, ';						
					}	
				}
				
				if(count>0)
				{
					// Attempt to register 
					System.debug('Need to register account - calling register');
					String returnStatus = O2_linkage_utils.registerAccount(null, p_acc.Id);
					System.debug('Back from register');
					if(returnStatus==null)
					{
						returnStatus =	'';		
					}
					//this.registeredStatus = returnStatus;
					ApexPages.Message status = new ApexPages.Message(ApexPages.Severity.info, returnStatus);	
					ApexPages.addMessage(status);					
				}
				else
				{
					if(missing)
					{
						//this.registeredStatus =	'Mandatory field(s) \'' + missingfield + '\' in contact is/are missing.';
						ApexPages.Message am_missing = new ApexPages.Message(ApexPages.Severity.warning, 'Mandatory field(s) \'' + missingfield + '\' in contact is/are missing.');	
						ApexPages.addMessage(am_missing);										
					}
					else
					{
						//this.registeredStatus =	'Account does not have any contacts';
						ApexPages.Message am_noCon = new ApexPages.Message(ApexPages.Severity.warning, 'Account does not have any contacts');	
						ApexPages.addMessage(am_noCon);		
					}
					
				}
// Acc REG CHANGE END
			
			} // end check for missing reference if
			else {
				//this.registeredStatus = Label.NO_BLANK_BILL_CODES;
				ApexPages.Message am_noBillCodes = new ApexPages.Message(ApexPages.Severity.info, Label.NO_BLANK_BILL_CODES);	
				ApexPages.addMessage(am_noBillCodes);					
			} // end check for missing reference else
		} // end registration allowed for this record if
		else {
			//this.registeredStatus = Label.NO_OAR_HANDOVER;
			ApexPages.Message am_noOAR_Handover = new ApexPages.Message(ApexPages.Severity.info, Label.NO_OAR_HANDOVER);	
			ApexPages.addMessage(am_noOAR_Handover);					
		} // end registration allowed for this record else

		return null;
	} // end checkOARRegistered
	
	// Constructor
	public O2_linkage_Acc_Reg_Conf_CE(ApexPages.StandardController stdController) {
	    this.acct = (Account)stdController.getRecord();
	} // end constructor
} // end class