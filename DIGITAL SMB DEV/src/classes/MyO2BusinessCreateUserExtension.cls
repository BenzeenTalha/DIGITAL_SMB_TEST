public with sharing class MyO2BusinessCreateUserExtension
{

	public class ValidationException extends Exception {}

	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
    private static final String ACCOUNT_CONTACT_ROLE = 'Enterprise Business Customer';
    private static final String PRIMARY_ADMIN_USER_TYPE = 'Primary Admin';
    private static final String ACCOUNT_HAS_PRIMARY_ADMIN_MESSAGE = 'The account this contact is associated with already has a Primary Admin user. Only one Primary Admin user is allowed per account.';
    private static final String PROBLEM_CREATING_USER = Label.MO2B_PROBLEM_CREATING_USER;
    private static final String PROBLEM_CREATING_USER_PHONE = Label.MO2B_PROBLEM_CREATING_USER_PHONE;

    //--------------------------------------------------------------------------
    // Getters / setters
    //--------------------------------------------------------------------------
    public Boolean associated
    {
    	get
    	{
            return associatedUser != null;
    	}
    	set;
    }

    public User associatedUser { get; set; }
    public AccountContactRole acrole { get; set; }
    public boolean accountHasPrimaryUser { get; set; }
    public String licenseType { get; set; }
    public String profile { get; set; }
    private Contact myContact { get; set; }
    private String errorMessage { get; set; }
    
    public String accountSegment{get;set;}
   

    public String accountAdminMessage
    {
    	get
    	{
    		return (accountHasPrimaryUser ? ACCOUNT_HAS_PRIMARY_ADMIN_MESSAGE : '');
    	}
    	set;
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    public List<SelectOption> getUserTypeOptions()
    {
        return createSelectOptionsForField(Contact.User_Type__c, accountHasPrimaryUser ? 'Admin' : '', myContact);
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    public List<SelectOption> getUserContactRoleOptions()
    {
        // implemented as a picklist for phase3 compatibility
        return createSelectOptionsForField(AccountContactRole.role, ACCOUNT_CONTACT_ROLE, null);
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    public List<SelectOption> getUserSegmentOptions()
    {
        
        return createSelectOptionsForField(Account.Segment__c, '', myContact.Account);
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    public MyO2BusinessCreateUserExtension(ApexPages.StandardController controller)
    {
        licenseType = Label.MO2B_LICENSE_TYPE;
        profile = Label.MO2B_PROFILE;

        // load contact
        //myContact = (Contact) controller.getRecord();
        myContact = [select FirstName,lastname, phone,email,Salutation,mobilephone,Account.Segment__c,AccountId,RecordTypeId,User_Type__c from Contact where Id =: controller.getRecord().id limit 1];

        // search for any existing account contact roles
        List<AccountContactRole> acroles = [SELECT id, role FROM AccountContactRole where contactId =:myContact.Id and accountId=:myContact.AccountId and Role=:ACCOUNT_CONTACT_ROLE LIMIT 1];
        // although if the acrole.role is null or empty it should be set when page loads for an unassociated contact, it isn't so we have to do it manually (a SF bug?)
        acrole = acroles.size() == 0 ? new AccountContactRole(Role=ACCOUNT_CONTACT_ROLE) : acroles[0];

        // check is there a user associated to this contact, if yes, check is it active or not
        List<User> associatedUsers = [SELECT Username, Id, LastLoginDate, isActive, SSO_Registration_State__c FROM User u WHERE u.ContactId=:myContact.Id AND isActive = true];
        
       
        if (associatedUsers.size() == 0)
        {
			
        }
        else if (associatedUsers.size() == 1)
        {
        	system.debug('userName: 1');
        	associatedUser = associatedUsers[0];
        	// load it's account data if there is a user associated to show accouint.segment__c
        	
        	List<Account> accs = [SELECT Id, Segment__c FROM Account WHERE Id = :myContact.AccountId];
        	if(accs.size() > 0)
        	{
        		myContact.Account = accs[0];
        		
        	}
        }
        else
        {
        	system.debug('userName: > 1');
        }
        accountHasPrimaryUser = [SELECT COUNT() FROM User WHERE accountId =:myContact.AccountId AND contact.user_type__c =:PRIMARY_ADMIN_USER_TYPE AND isActive = true] > 0;
        errorMessage = '';
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    public PageReference doCreate()
    {
        PageReference redirectToUser = null;
        if (associatedUser == null) {
	        try
	        {
	        	createUser();
	        	redirectToUser = new PageReference('/' + associatedUser.Id);
	        }
	        catch (ValidationException e)
	        {
	            system.debug('exception: '+e);
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	        }
	        catch (Exception e)
	        {
	        	// error message gets added to ApexPages automatically obviously, so this error msg below is not needed
	        	//errorMessage = PROBLEM_CREATING_USER + ': ' + e.getMessage();
	        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, PROBLEM_CREATING_USER + ': ' + e.getMessage()));
	        }
        }

        // need to return to previous page
        return redirectToUser;
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    public PageReference doResend()
    {
        PageReference pr = null;

        //system.debug('doresend: '+userName);
        //User u = [SELECT Id FROM User WHERE username=:userName];

        MyO2BusinessCreateUser.mapContactToUser(myContact, associatedUser);
        system.debug('doresend: u: '+ associatedUser);
        MyO2BusinessCreateUser.sendNewUserEmail(associatedUser);
        //
        // This will set state to activation pending too
        //
        update associatedUser;
        pr =  new PageReference('/' + associatedUser.Id);

        return pr;
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    private User createUser()
    {
        // create the user
        if(myContact.MobilePhone == null || myContact.MobilePhone.trim().equals('')) throw new ValidationException(PROBLEM_CREATING_USER_PHONE);
        system.debug('my contact is :' + myContact);
        associatedUser = MyO2BusinessCreateUser.createUserFromContact(myContact, true);
        // update the contact with new email and user type
        update myContact;
        // insert if new account user role is created
        if (acrole.Id == null)
        {
            acrole.AccountId = myContact.AccountId;
            acrole.ContactId = myContact.Id;
            insert acrole;
        }
        // update the account if Segment__c has changed
        update myContact.Account;
        return associatedUser;
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    private List<SelectOption> createSelectOptionsForField(Schema.sObjectField field, String prefixFilter, sObject setDefault)
    {
        List<SelectOption> retVal = new List<SelectOption>();
        Schema.DescribeFieldResult fieldDescription = field.getDescribe();
        List<Schema.Picklistentry> entries = fieldDescription.getPicklistValues();
        if(entries != null && entries.size() > 0)
        {
            for(Schema.Picklistentry picklistEntry : entries)
            {
                if(picklistEntry.value.startsWith(prefixFilter))
                {
                    retVal.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
                }
               /** if(picklistEntry.defaultValue)
                {
                    //setDefault = picklistEntry.getValue();
                    setDefault.put(fieldDescription.getName(), picklistEntry.getValue());
                    
                }*/
            }
        }
        return retVal;
    }

}