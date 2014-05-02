/**
 * An apex class that creates a portal user
 */
global class MyO2BusinessSiteRegisterController {

    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    //private static Id PORTAL_ACCOUNT_ID = '001F000000iZr7V';
    
    private static final String TOKEN_CONFIGURATION = 'Default'; 
    
    public MyO2BusinessSiteRegisterController () {
    }

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}

    //public String password {get; set {password = value == null ? value : value.trim(); } }
    //public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
      
    //private boolean isValidPassword() {
    //    return password == confirmPassword;
    //}
    /*
    public PageReference registerUser1() {
        // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
        User u = new User();
        u.Username = username;
        u.Email = email;
        u.FederationIdentifier = communityNickname;
        u.CommunityNickname = communityNickname;
        
        String accountId = PORTAL_ACCOUNT_ID;

        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        String userId = Site.createPortalUser(u, accountId, password);
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(username, password, null);
            }
            else {
                PageReference page = System.Page.SiteRegisterConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }*/
    
    public PageReference registerUser() {
        PageReference pr = null; 
            
        try {
            pr =  createPortaluser();
        } catch (Exception e) {
        }
        return pr;
    }
    
      
    public PageReference createPortaluser(){
        // check user isn't already registered
        if (!Test.isRunningTest()) {
	        if([select count() from user where username=:email+MyO2BusinessCreateUser.USERNAME_SUFFIX]>0) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_EMAIL_ALREADY_REGISTERED));
	            return null;
	        }        	
        }

		system.debug('adding account');
        Account acc = new Account(name=firstName +' '+ lastName,billingStreet='setme', billingcity='setme',billingpostalcode='setme');
        insert acc;
		system.debug('adding contact');
        Contact c = new Contact(accountId=acc.Id, firstname=firstName, lastName=lastName, email=email);
        insert c;
        //String selectedProfileId = '00eA0000000d3Yw';
        //SiteRegisterController.createUser((String)c.Id, email, '', username,username,selectedProfileId);
		system.debug('email');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (!Test.isRunningTest()) {
	   		mail.setToAddresses(new String[] {SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).self_register_email_handler__c});        	
        } else {
        	mail.setToAddresses(new String[] {'yodel.meister@yoyo.yoyo.yoyo.com'});
        }
	    mail.setSubject(c.Id);
        mail.setPlainTextBody((String)c.Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return Page.MyO2BusinessRegisterConfirm;
    }
       /*
    @future static void createUser(String contactId, String email, String firstName, String lastName, String userName, String profileId) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = true;
        User u = new User(alias = 'standt', email=email, 
            emailencodingkey='UTF-8', lastname=email, languagelocalekey='en_US', 
            localesidkey='en_US', profileid = profileId, contactId=contactId,
            timezonesidkey='America/Los_Angeles', username=username);
        
        u.setOptions(dmo);
        insert u;
    }*/
           
    private static testMethod void testRegistration() {
        Profile p = [Select Id From profile Where name='Standard User']; 
		system.assert(p != null);

        User u = new User(alias = 'standt', email='standarduser@testorgO2Courtesy.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser@testorgO2Courtesy.com',
            SSO_question__c='Name of your pet?', SSO_answer__c='godzilla', MO2B_OptIn__c=true, MO2B_ShareDetails__c=true);
        insert u;
		system.assert(u != null);
    	
    	System.runAs(u) {
        	MyO2BusinessSiteRegisterController controller = new MyO2BusinessSiteRegisterController();
	        controller.firstName = 'robert';
	        controller.lastName = 'robertson';
	        controller.email = 'test@force.com';
	        //controller.communityNickname = 'test';
	        // registerUser will always return null when the page isn't accessed as a guest user
			PageReference pr = controller.registerUser();
			system.assert(pr != null);
			String url = pr.getUrl();
			system.assert(url != null);
	        System.assert(url.contains('myo2businessregisterconfirm'));    
	        
	        //controller.password = 'abcd1234';
	        //controller.confirmPassword = 'abcd123';
	        //System.assert(controller.registerUser() == null);      		
    	}	 
    }

    private static final String TEST_DATA = 'TESTDATA';
    private static testMethod void testProperties() {
        MyO2BusinessSiteRegisterController controller = new MyO2BusinessSiteRegisterController();
        controller.firstName = TEST_DATA;
        system.assertEquals(TEST_DATA, controller.firstName);

        controller.lastName = TEST_DATA;
        system.assertEquals(TEST_DATA, controller.lastName);

        controller.email = TEST_DATA;
        system.assertEquals(TEST_DATA, controller.email);
    }
}