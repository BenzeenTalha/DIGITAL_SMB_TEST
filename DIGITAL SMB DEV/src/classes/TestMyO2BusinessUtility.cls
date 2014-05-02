public with sharing class TestMyO2BusinessUtility {
 
    //
    // Individual methods to create the portal account, contact and user
    //
    public static Account createPortalAccount(String firstName, String lastName) {
        Account acc = new Account(name=firstName +' '+ lastName, 
                                  ownerId=UserInfo.getUserId(),
                                  Fixed_Contract_End_Date__c=system.today()+14,
                                  Fixed_Voice_Network_Lines_Provider_1__c='O2',
                                  Number_of_Lines__c=1);
        insert acc;
        system.debug('createPortalAccount: '+acc);
        return acc;
    }

    public static Contact createPortalContact(Account acc, String firstName, String lastName, String email) {
        Contact c = new Contact(accountId=acc.Id, firstname=firstName, lastName=lastName, email=email);
        insert c;
        system.debug('createPortalContact: '+c);
        return c;
    }
    

    public static User createPortalUser(Contact c) {
        User u = MyO2BusinessCreateUser.createUserFromContact(c, false);
        system.debug('createPortalUser: '+u);
        return u;
    }
    
    public static User setUserQA(User u, String question, String answer) {
        u.SSO_Question__c = question;
        u.SSO_Answer__c = answer;
        update u;
        return u;
    }
    
    public static Boolean getProfileContactCreatable() {
        Schema.DescribeSObjectResult dsor = Contact.sObjectType.getDescribe();
        return dsor.isCreateable();
    }
    
    //
    // Convenience method that creates all three (account, contact, user)
    //
    public static User createPortalUserAccountContact(String firstName, String lastName, String email) {
        User u = null;
        
        Account a = createPortalAccount(firstName, lastName);
        if (a != null) {
            Contact c = createPortalContact(a, firstName, lastName, email);
            if (c != null) {
                u = createPortalUser(c);
            }
        }
        return u;
    }
    
    //
    // Get a Guest User
    //
    public static User getGuestUser() {
        //Colin Kenworthy remove isActive check so user record can be read even when Site is deactivated.
        //List<User> users = [SELECT Id, FirstName, LastName, Email, UserType FROM User u WHERE u.usertype='Guest' AND u.isActive=true];
        List<User> users = [SELECT Id, FirstName, LastName, Email, UserType, IsActive FROM User u WHERE u.usertype='Guest'];
        system.assert(users != null);
        system.assert(users.isEmpty() == false);
        
	    User returnUser = users[0];
	    // if first user is inactive then see if there is an active user to return in place of it, if not then just return the inactive user
	    if ( (!returnUser.IsActive) && (users.size()>1) ) {
	    	for (User testUser : users) {
	        	system.debug('getGuestUser: '+testUser);
	        	if (testUser.IsActive) {
	        		returnUser = testUser;
	        		break;
	        	}
	    	}
	    }
        system.debug('getGuestUser return: '+returnUser);
        return returnUser;
    }
    
    //
    // Create Email Handler stuff
    //
    private static final String TOKEN_CONFIGURATION = 'Default'; 
    public static Messaging.InboundEmail getRegistrationEmail(Contact c) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        if (!Test.isRunningTest()) {
            email.toAddresses = new String[] {SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).self_register_email_handler__c};
        } else {
            email.toAddresses = new String[] {'emailhandler.com'};
        }
        email.plainTextBody = (String)c.Id;
        email.fromAddress ='test@test.com';
        email.subject = c.Id;
        
        return(email);
    }
    
    public static Messaging.InboundEnvelope getRegistrationEnvelope() {
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        return(env);
    }
    
    //
    // Create a Service Provider
    // 
    public static SSO_Service_Provider__c createSP(String aName, String aLabel, String aLoginURL, String aLogoutURL, String aRelayState) {
        SSO_Service_Provider__c sp = new SSO_Service_Provider__c(Name=aName, label__c=aLabel, Login_URL__c=aLoginURL, Logout_URL__c=aLogoutURL, Relay_State__c=aRelayState);
        insert sp;
        system.debug('createSP: '+sp);
        return sp;
    }
    
    //
    // Get a List of Service Providers
    //
    public static List<String> getSPForUser(User u) {
        List<String> sps = new List<String>();
        String serviceProvidersList = [select sso_service_providers__c from user where Id=:UserInfo.getUserId()].sso_service_providers__c;
        if (serviceProvidersList!=null) {
            for(String spName: serviceProvidersList.split(';',-1)){
                sps.add(spName);
            }
        }
        system.debug('getSPForUser: ' + sps);       
        return sps;
    }
    
    //
    // Update the list of SP
    //
    public static User updateSPForUser(User u, List<String> sps) {
            String spString = '';
            Boolean bFirst = true;
            for (String sp:sps) {
                if (bFirst) {
                    bFirst = false;
                } else {
                    spString = spString + ';';
                }
                spString = spString + sp;
            }
            u.SSO_Service_Providers__c = spString;
            update u;           
            system.debug('updateSPForUser: '+u);
        return u;
    }
    
    //
    // Remove a string from a list
    //
    public List<String> removeFromList(List<String> aList, String s) {
        system.debug('removeFromList: before: '+aList);
        Integer listLimit = aList.size();
        Integer listI = 0;
        Boolean done = false;
        while ((!done) && (listI < listLimit)) {
            if (aList[listI].equalsIgnoreCase(s)) {
                aList.remove(listI);
                done = true;
            }
            listI++;    
        }
        system.debug('removeFromList: after: '+aList);
        return aList;       
    }
    
    //
    // Create a case 
    //
    public static Case createCase(String subject, String status) {
        Case newCase = new Case();
        newCase.Subject     = subject;
        newCase.Description = 'test case for '+subject;
        newCase.Status      = status;
        insert newCase;
 
        return newCase;
    }
    
    private static Id getUserLicenseId(String licenseName) {
        Id licenseId = null;
    	List<UserLicense> license = [SELECT Id FROM UserLicense WHERE Name=:licenseName]; 
    	if (license.size()==1)
    	   licenseId = license[0].Id;
    	
    	return licenseId;
    }
    
    //
    // Create permission set
    //
    // Too many fields to accept here as param. So modify it your self when you receive the object back from this call.
    public static PermissionSet createPermissionSet(String psname, String pslabel, String psdescription, String pslicenseType) {
        PermissionSet ps = null;
        Id pslicenseId = getUserLicenseId(pslicenseType);
        if (pslicenseId != null) {
            ps = new PermissionSet(name=psname, label=pslabel, description=psdescription, userlicenseId=pslicenseId);                    	
        }
                
        return ps;
    }
    
    public static PermissionSetAssignment createPermissionSetAssignment(PermissionSet ps, User u) {
        PermissionSetAssignment psa = null;
        
        if (ps != null && u != null) {
        	psa = new PermissionSetAssignment(assigneeId=u.Id, permissionSetId=ps.Id);
        }
        
        return psa;
    }
    
    private static testmethod void test_it() {
        Account a1 = TestMyO2BusinessUtility.createPortalAccount('firstName1', 'lastName1');
        system.assert(a1 != null);

        Contact c1 = TestMyO2BusinessUtility.createPortalContact(a1, 'firstName2', 'lastName2', 'email@domain.com1');
        system.assert(c1 != null);

        User u1 = TestMyO2BusinessUtility.createPortalUser(c1);
        system.assert(u1 != null);

        User u2 = TestMyO2BusinessUtility.createPortalUserAccountContact('first','last','email@domain.com');
        system.assert(u2 != null);
        
        System.runAs(u2) {
            TestMyO2BusinessUtility.setUserQA(u2, 'q','a');
        }
        system.assertEquals(true, getProfileContactCreatable());
        
        User u3 = TestMyO2BusinessUtility.getGuestUser();
        system.assert(u3 != null);
        
        Messaging.InboundEmail im = TestMyO2BusinessUtility.getRegistrationEmail(c1);
        system.assert(im != null);
        
        Messaging.InboundEnvelope ie = TestMyO2BusinessUtility.getRegistrationEnvelope();
        system.assert(ie != null);
        
        SSO_Service_Provider__c sp = TestMyO2BusinessUtility.createSP('SpName', 'Splabel', 'http://LoginURL', 'http://LogoutURL', 'relaystate');
        system.assert(sp != null);
        
        List<String> sps = TestMyO2BusinessUtility.getSPForUser(u1);
        System.runAs(u1) {
            u1 = TestMyO2BusinessUtility.updateSPForUser(u1, sps);          
        }
        
        //sps = TestMyO2BusinessUtility.removeFromList(sps, 'SpName');
        
        Case cas1 = TestMyO2BusinessUtility.createCase('subject', 'new');
        system.assert(cas1 != null);
        
        // create a perm set
        PermissionSet ps = TestMyO2BusinessUtility.createPermissionSet('testps', '#com.o2.sales.account.read#', 'test for read account', 'Overage High Volume Customer Portal');
        system.assert(ps!=null);
        
        PermissionSetAssignment psa = TestMyO2BusinessUtility.createPermissionSetAssignment(ps, u1);
        system.assert(psa!=null);
    }
}