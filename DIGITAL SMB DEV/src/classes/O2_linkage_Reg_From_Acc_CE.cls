public class O2_linkage_Reg_From_Acc_CE {
	
	// Account controlled
	private Account acct {get;set;}
	
	// Registered Status Message
	private String registeredStatus = Label.INIT_REG_STAT;
	
	// Constructor
	public O2_linkage_Reg_From_Acc_CE(ApexPages.StandardController stdController) {
	    this.acct = (Account)stdController.getRecord();
	} // end constructor
	
	// Get the status of the related account (registered or not!)
	public String getRegisteredStatus() {
		return this.registeredStatus;
	} // end getRegisteredStatus
	 
	// Check to see if the record is registered or not
	public PageReference checkOARRegistered() {
			
		// Only relevant if user has chosen via button click or something has been registered on this
		// account before (e.g. from the opportunity automatically)
		if ((this.acct.Register_Requested__c) || (this.acct.OAR_Account_Reference_1__c != null)) {
		
			// Only attempt to register if there is a DISE billing code with no
			// corresponding OAR reference
			if (((this.acct.OAR_Account_Reference_1__c == null) && (this.acct.DISE_Group_Code_Account_No_1__c != null)) ||
				((this.acct.OAR_Account_Reference_2__c == null) && (this.acct.DISE_Group_Code_Account_No_2__c != null)) ||
				((this.acct.OAR_Account_Reference_3__c == null) && (this.acct.DISE_Group_Code_Account_No_3__c != null)) ||
				((this.acct.OAR_Account_Reference_4__c == null) && (this.acct.DISE_Group_Code_Account_No_4__c != null))) {
// Acc REG CHANGE START					
				
				this.registeredStatus = '';
				
				if((this.acct.OAR_Account_Reference_1__c == null) && (this.acct.DISE_Group_Code_Account_No_1__c != null))
				{
					this.registeredStatus += 'Group Code 1 was entered, but has not been registered yet! ';	
				}
				if((this.acct.OAR_Account_Reference_2__c == null) && (this.acct.DISE_Group_Code_Account_No_2__c != null))
				{
					this.registeredStatus += 'Group Code 2 was entered, but has not been registered yet! ';		
				}
				if((this.acct.OAR_Account_Reference_3__c == null) && (this.acct.DISE_Group_Code_Account_No_3__c != null))
				{
					this.registeredStatus += 'Group Code 3 was entered, but has not been registered yet! ';		
				}
				if((this.acct.OAR_Account_Reference_4__c == null) && (this.acct.DISE_Group_Code_Account_No_4__c != null))
				{
					this.registeredStatus += 'Group Code 4 was entered, but has not been registered yet! ';		
				}
				
				
	/*			
				Integer count = [SELECT count() FROM contact WHERE accountid = :this.acct.id];
				Boolean missing			= false;
				String	missingfield	=	'';
				
				List<Contact> tmp_contactList	=	new List<Contact>();

				tmp_contactList = [SELECT id, Salutation, Title, FirstName, LastName, Buying_Role__c, Phone, Email, MailingCity, MailingPostalCode, MailingStreet FROM Contact WHERE accountid = :this.acct.id];
				
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
					String returnStatus = O2_linkage_utils.registerAccount(null, this.acct.Id);
					System.debug('Back from register');
					if(returnStatus==null)
					{
						returnStatus =	'';		
					}
					this.registeredStatus = returnStatus;					
				}
				else
				{
					if(missing)
					{
						this.registeredStatus =	'Mandatory field(s) \'' + missingfield + '\' in contact is/are missing.';				
					}
					else
					{
						this.registeredStatus =	'Account does not have any contacts';		
					}
					
				}*/
// Acc REG CHANGE END
			
			} // end check for missing reference if
			else {
				this.registeredStatus = Label.NO_BLANK_BILL_CODES;
			} // end check for missing reference else
		} // end registration allowed for this record if
		else {
			this.registeredStatus = Label.NO_OAR_HANDOVER;
		} // end registration allowed for this record else

		return null;
	} // end checkOARRegistered

} // end class