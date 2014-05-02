public without sharing class O2AdminUserController {

	//------------------------------------------------------------------------
	//	class and subclass structures
	//------------------------------------------------------------------------
		class UserDetails {
		public UserDetails(User user) {
			this.user = user;
		}
		public UserDetails(User user, String password) {
			this.user = user;
			this.password = password;
		}
		public User user { get; set; }
		public String password { get; set; }
	}
	
	public class UserAdminException extends Exception {}
	public class FileRecord {
		public String FirstName {get;set;}
		public String LastName {get;set;}
		public String Username {get;set;}
		public String Email {get;set;}
		public String Password {get;set;}
		public String lanID {get;set;}
		public String AccountName {get;set;}
		public String phone {get;set;}
		public String alias {get;set;}

		public FileRecord() {}
		public FileRecord(String fn, String ln, String un, String e, String lid, String pw, String acc) {
			this.FirstName = fn;
			this.LastName = ln;
			this.Username = un;
			this.Email = e;
			this.lanID = lid;
			this.Password = pw;
			this.AccountName = acc;
		}
	}
	
	//------------------------------------------------------------------------
	//	public variables
	//------------------------------------------------------------------------
	public String userAction {get;set;}
	public String selectedPortalId {get;set;}
	public String organizationId {
		get {return UserInfo.getOrganizationId();} set;
	}
	public String selectedProfileId {get;set;}
	public String loadType {get;set;}

	public String objectType {get;set;}
	public String queryClause {get;set;}

	public String standardEmail {get;set;}
	public String standardPassword {get;set;}

	public List<User> userList {get;set;}
	public List<Contact> contactList {get;set;}
	public Boolean recordsFound {get {if (recordsFound==null) return false; else return recordsFound;} set;}
	public Integer numRecords {get {if (numRecords==null) return 0; else return numRecords;} set;}

	public Blob fileContents {get;set;}
	public String fileName {get;set;}
	public List<FileRecord> fileRecords {get;set;}

	public Contact sampleContact {get;set;}
	public User sampleUser {get;set;}

	//class constructor
	public O2AdminUserController() {
		contactList = new List<Contact>();
		userList = new List<User>();
		fileRecords = new List<FileRecord>();
		sampleContact = new Contact(accountId=null);
		sampleUser = new User(IsActive=true,Sales_Channel__c='O2 Retail',TimeZoneSidKey=null,LocaleSidKey=null,EmailEncodingKey=null,LanguageLocaleKey=null);
	}

	//------------------------------------------------------------------------
	//	field population methods
	//------------------------------------------------------------------------
	public List<SelectOption> getPortalOptions() {
		List<SelectOption> retList = new List<SelectOption>();
		for (O2PortalGeneralSettings__c setting: O2PortalGeneralSettings__c.getAll().values()) {
			retList.add(new SelectOption(setting.Value__c, setting.Name));
		}
		//retList.add(new SelectOption('060W0000000D0Z0', 'O2 Retail'));
		return retList;
	}
	public Map<String, Profile> mpPortalProfiles = new Map<String, Profile>();
	public List<SelectOption> getPortalProfiles() {
		List<SelectOption> retList = new List<SelectOption>();
		if (mpPortalProfiles==null || mpPortalProfiles.size()==0) {
			mpPortalProfiles = new Map<String, Profile>([SELECT Id, Name, UserLicenseId FROM Profile WHERE UserType = 'CSPLitePortal']);
		}
		for (Profile p: mpPortalProfiles.values()) {
			retList.add(new SelectOption(p.Id, p.Name));
		}
		return retList;
	}

	//------------------------------------------------------------------------
	//	query methods
	//------------------------------------------------------------------------
	public void queryUserRecords() {
		String strQuery = 'SELECT Id, Name, FirstName, LastName, Email, Phone, Username';
        strQuery+=' FROM '+objectType+' WHERE UserType = \'CSPLitePortal\'';
        if (selectedProfileId!=null) strQuery+=' AND profileId = :selectedProfileId';
        if (queryClause!=null && queryClause!='') {
        	if (queryClause.contains('WHERE')) strQuery+=' AND '+queryClause.replace('WHERE', '');
        	else strQuery+=' AND '+queryClause;
        }
        userList = Database.query(strQuery);
        if (userList!=null && userList.size()>0) {
        	recordsFound = true;
        	numRecords = userList.size();
        } else {
        	recordsFound = false;
        	numRecords = 0;
        }
	}

	public void queryContactRecords() {
		String strQuery = 'SELECT Id, Name, FirstName, LastName, Email, Phone, Account.Name';
        strQuery+=' FROM '+objectType;
		if (queryClause!=null && queryClause!='') {
        	if (queryClause.contains('WHERE')) strQuery+=' AND '+queryClause.replace('WHERE', '');
        	else strQuery+=' AND '+queryClause;
        }
        contactList = Database.query(strQuery);
        if (contactList!=null && contactList.size()>0) {
        	recordsFound = true;
        	numRecords = contactList.size();
        } else {
        	recordsFound = false;
        	numRecords = 0;
        }
	}

	//------------------------------------------------------------------------
	//	action methods
	//------------------------------------------------------------------------
    public void addError(String strError) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
    }

	public PageReference queryRecords() {
		try {
			if (objectType==null) throw new UserAdminException('Object Type is required. Please select a value and try again.');
			else {
				if (objectType=='User') queryUserRecords();
				else if (objectType=='Contact') queryContactRecords();
			}
		}
		catch (Exception e) {addError(e.getMessage());}
		return null;
	}

	public PageReference setUserPasswords() {
		Savepoint sp3 = Database.setSavepoint();
		try {
			if (userList!=null && userList.size()>0) {
				if (standardPassword==null || standardPassword.trim()=='') addError('You have not provided a value for the standard password. Please provide a value and try again.');
				else {
					for (User u: userList) {
						if (!Test.isRunningTest()) System.debug('set pass: ' + u.Id + ' - ' + standardPassword);//System.setPassword(u.Id, standardPassword);
					}
				}
			}
		}
		catch(Exception e) {addError(e.getMessage());Database.rollback(sp3);}
		return null;
	}

	public PageReference updateUsers() {
		Savepoint sp2 = Database.setSavepoint();
		try {
			if (userList!=null && userList.size()>0) {
				if (standardEmail==null || standardEmail.trim()=='') addError('You have not provided any values for the fields to be updated (Email). Please provide values and try again.');
				else {
					for (User u: userList) {
						u.Email = standardEmail;
					}
					if (!Test.isRunningTest()) update userList;
				}
			}
		}
		catch(Exception e) {addError(e.getMessage());Database.rollback(sp2);}
		return null;
	}

	public PageReference convertToUsers() {
		Savepoint sp4 = Database.setSavepoint();
		try {
			throw new UserAdminException('Sorry, this function has not yet been implemented. Please contact your System Administrator.');
		}
		catch (Exception e) {addError(e.getMessage());Database.rollback(sp4);}
		return null;
	}

	/**
	 * Extracts FileRecord objects from a CSV file containing user information.
	 */
	public PageReference uploadInputFile() {
		try {
			if (fileContents!=null && fileName!=null) {
				System.debug('### OUTPUT >>>>> uploadInputFile: fileName: '+fileName);
				System.debug('### OUTPUT >>>>> uploadInputFile: fileContents: '+fileContents.toString());
				String contentString = fileContents.toString();
				String[] contentLines = contentString.split('\n');
				if (contentLines!=null && contentLines.size()>0) {
					List<FileRecord> retList = new List<FileRecord>();
					for (Integer i=1; i<(contentLines.size()); i++) {
						String[] contentFields = contentLines[i].split(',');
						if (contentFields!=null && contentFields.size()>0) {
							retList.add(
								new FileRecord(
									contentFields[0].replaceAll('\"', ''),
									contentFields[1].replaceAll('\"', ''),
									contentFields[2].replaceAll('\"', ''),
									contentFields[5].replaceAll('\"', ''),
									contentFields[3].replaceAll('\"', ''),
									contentFields[4].replaceAll('\"', ''),
									null
								)
							);
							if (contentFields[6].replaceAll('\"', '')!=null && contentFields[6].replaceAll('\"', '')!='') retList[retList.size()-1].phone = contentFields[6].replaceAll('\"', '');
							if (contentFields[7].replaceAll('\"', '')!=null && contentFields[7].replaceAll('\"', '')!='') retList[retList.size()-1].alias = contentFields[7].replaceAll('\"', '');
						}
						else throw new UserAdminException('Error parsing input file. Could not extract data from line '+i+'.');
					}
					System.debug('### OUTPUT >>>>> uploadInputFile: retList: '+retList);
					if (retList!=null && retList.size()>0) {
						fileRecords = retList;
						recordsFound = true;
						numRecords = fileRecords.size();
					}
					System.debug('### OUTPUT >>>>> uploadInputFile: fileRecords: '+fileRecords);
				}
				else throw new UserAdminException('Error parsing input file. Could not extract content lines.');
			}
			else throw new UserAdminException('No file selected. Please select a file to upload.');
		}
		catch(Exception e) {addError(e.getMessage());}
		return ApexPages.currentPage();
	}
	public PageReference doNothing() {
		return null;
	}
	
	/**
	 * Creates portal users from a pre-populated list of FileRecord objects extracted from a CSV file. 
	 * Has a hard limit of 90 users to prevent hitting governor limits for DML operations.
	 *
	 */
	public PageReference createPortalUsers() {
		
		List<UserDetails> userDetails = new List<UserDetails>();
		
		Savepoint sp = Database.setSavepoint();
		
		try {		
			System.debug('### createPortalUsers: sampleContact: ' + sampleContact);
			System.debug('### createPortalUsers: sampleContact.accountId: ' + sampleContact.accountId);
			if (sampleContact.accountId == null) {
				throw new UserAdminException('A customer Account must be selected to associate the portal Contacts to. Please select a value and try again.');
			}
			
			if (fileRecords.size() > 90) {
				throw new UserAdminException('A limit of 90 users per file is preventing user creations. Please upload a file with 90 users or less and try again.');
			}
			
			if (fileRecords != null && fileRecords.size() > 0) {
				contactList.clear();
				userList.clear();
				for (fileRecord rec : fileRecords) {
					
					// add contact record to dml list
					Contact rowContact = new Contact(
						accountId = sampleContact.accountId,
						FirstName = rec.FirstName,
						LastName = rec.LastName,
						Email = rec.Email,
						Phone = rec.Phone
					);
					
					contactList.add(rowContact);
						
					// add equivalent user record to dml list
					User rowUser = new User(
						FirstName = rec.FirstName,
						LastName = rec.LastName,
						Email = rec.Email,
						LAN_ID__c = rec.lanID,
						Phone = rec.phone,
						IsActive = true,
						Username = rec.Username,
						Alias = rec.alias,
						Sales_Channel__c = 'O2 Retail',
						//rowUser.UserType = 'CSPLitePortal';	//field is not writeable (apparently) - assume this is therefore set by profile id
						ProfileId = selectedProfileId,
						TimeZoneSidKey = sampleUser.TimeZoneSidKey,
						LocaleSidKey = sampleUser.LocaleSidKey,
						EmailEncodingKey = sampleUser.EmailEncodingKey,
						LanguageLocaleKey = sampleUser.LanguageLocaleKey					
					);
					
					userList.add(rowUser);
				}
			}
			else {
				throw new UserAdminException('No records found to process.');
			}
			
			System.debug('### createPortalUsers: contactList: ' + contactList);
			
			if (contactList.size() > 0 && !Test.isRunningTest()) {
				insert contactList;
			}
			
			// check whether the lists are of the same size - should be but should just check consistency
			if (contactList.size() != userList.size()) {
				throw new UserAdminException('An error occurred reconciling Contacts to Users. Please contact your System Administrator.');
			}
			
			// now that the contacts are created, amend the user list with contact FKs and create also
			for (Integer i = 0; i < userList.size(); i++) {
				userList[i].ContactId = contactList[i].Id;
			}
			System.debug('### createPortalUsers: userList: '+userList);
			
			if (userList.size() > 0 && !Test.isRunningTest()) {
				insert userList;
			}
			
			Map<String, FileRecord> usernameFileRecordMap = new Map<String, FileRecord>();
		
			for (FileRecord record : this.fileRecords) {
				usernameFileRecordMap.put(record.Username, record);
			}
			
			
			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
				
			// each password change is a DML operation
			for (User user : userList) {
				if (user.Id != null && usernameFileRecordMap.containsKey(user.Username)) {
					String password = usernameFileRecordMap.get(user.Username).password;
					System.setPassword(user.Id, password);
					
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
					email.setSubject('Salesforce user credentials');
					email.setPlainTextBody('This is an automated message. Please do not reply to this address.' + '\n' +
						'Dear ' + user.FirstName + ' ' + user.LastName + ',' + '\n' +
						'Your Salesforce Retail password has been set by your Administrator. Your username and password are below:' + '\n' +
						'User name: ' + user.Username + '\n' +
						'Password: ' + password + '\n' +
						'If you have any problems, please contact your Administrator.' + '\n' +
						'Thank you,' + '\n' +
						'Salesforce.com'
					);
					email.setToAddresses(new String[]{user.Email});
					emails.add(email);
				}
			}	
					
			Messaging.sendEmail(emails);
			
		}
		catch (Exception e) {
			addError(e.getMessage());
			Database.rollback(sp);
		}
		return null;
	}

	/**
	 * Deprecated
	 *
	@future
	public static void resetPasswords(Map<Id,String> passwords)	{
		for(Id u : passwords.keySet())
		{
			if (!Test.isRunningTest() && passwords.get(u)!=null && passwords.get(u)!='') System.setPassword(u, passwords.get(u));
		}
	}
	 */

	/**
	 * Resets the contact and user selection information on the page, then reloads the page.
	 */
	public PageReference resetForm() {
		sampleContact = null;
		sampleUser = null;
		PageReference p = new PageReference('/apex/AdminUserServices');
		p.setRedirect(true);
		return p;
	}
}