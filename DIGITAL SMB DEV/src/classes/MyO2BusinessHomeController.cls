public with sharing class MyO2BusinessHomeController {
    
    class CaseGroup {
        public string ctype {get; set;}
        public integer cval {get; set;}
        public caseGroup(){}
        public caseGroup(AggregateResult ar) {
            ctype=(String)ar.get('status');
            cval=(Integer)ar.get('Total');
        }
    }
    
    public List<CaseGroup> getCasesByType() {
        List<CaseGroup> cg = new List<CaseGroup>();
        for(AggregateResult ar :[select status, count(Id) Total from case group by status]) {
            CaseGroup v = new CaseGroup(ar);
            cg.add(v);
        }
        // show a total of 0 if no cases exist
        if(cg.size()==0) {
            CaseGroup v = new CaseGroup();
            v.ctype='All';
            v.cval=0;
            cg.add(v);        
        }
        return cg;
    }

	private static testmethod void test_properties() {
		CaseGroup cg = new CaseGroup();
		system.assert(cg!=null);
		cg.ctype = 's';
		system.assertEquals('s', cg.ctype);
		cg.cval = 1;
		system.assertEquals(1, cg.cval);
	}

	private static testmethod void test_it() {
		List<Case> cList = new List<Case>();
		for (Integer i=0; i<5; i++) {
			Case c = new Case(subject='new'+i, status='new');
			cList.add(c);
		}
		for (Integer i=0; i<5; i++) {
			Case c = new Case(subject='fixed'+i, status='fixed');
			cList.add(c);
		}
		insert(cList);
		MyO2BusinessHomeController con = new MyO2BusinessHomeController();
		system.assert(con!=null);
		List<CaseGroup> cgList = con.getCasesByType();
		system.assert(cgList!=null);
		
	}
/*   
    static String DEFAULT_SERVICE_PROVIDER_NAME = 'SSO_SP_Org';   
    
    // properties that decide whether something is visible
    public Boolean showServiceProviders {get; private set;}
    public Boolean showServiceRequests {get; private set;}
    public Boolean showGeneralServiceRequests {get; private set;}
    public Boolean showActivateSim {get; private set;}
    public Boolean showSimSwap {get; private set;}
    public Boolean showBlock {get; private set;}
    public Boolean showBoltons {get; private set;}
    
    public String serviceProvider {get; set;}
    
    List<SSO_Service_Provider__c> serviceProviders;  
    
    // Constructor checks whether the user is authorized to proceed. In other words, this controller can only be used in by a logged in user
    public MyO2BusinessHomeController() {
        if (UserInfo.getUsertype() == 'GUEST') {
            throw new NoAccessException();
        }
        // decide what boxes are visible on screen
        setBoxVisibility();
    }
    
    public boolean getHasManageUsers() {
        return Schema.sObjectType.Contact.isCreateable();
    }
        
    public List<SSO_Service_Provider__c> getServiceProviders() {
        if(serviceProviders ==null) {
            serviceProviders = new List<SSO_Service_Provider__c>();
            // !!!! DML  not allowed on permission set assignment - So cannot use permission sets 
            //for(PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment where AssigneeId =: UserInfo.getUserId()]) {
            //    serviceProviders.add(SSO_Service_Provider__c.getInstance(psa.PermissionSet.Name));
            //}
            String serviceProvidersList = [select sso_service_providers__c from user where Id=:UserInfo.getUserId()].sso_service_providers__c;
            system.debug('serviceProvidersList: '+serviceProvidersList);
            if(serviceProvidersList!=null) {
                for(String spName: serviceProvidersList.split(';',-1)){
                    serviceProviders.add(SSO_Service_Provider__c.getInstance(spName));
                }
            } 
            // Add this default one if none set on user record
            if(serviceProviders.size()==0)           
                serviceProviders.add(SSO_Service_Provider__c.getInstance(DEFAULT_SERVICE_PROVIDER_NAME ));
        }
        return serviceProviders;
    }
    
    public PageReference goToSP() {
        PageReference ref = null;
        SSO_Service_Provider__c sp = getSP(serviceProvider);
        ref = new PageReference(SP.Login_URL__c);
        addSession(SP.Logout_URL__c);
        return ref;
    }

    private static SSO_Service_Provider__c getSP(string spName) {
        SSO_Service_Provider__c serviceProvider = null;
        for(SSO_Service_Provider__c SP : SSO_Service_Provider__c.getall().values()) {
            if(SP.name.contains(spName)) {
                serviceProvider = SP;
                break;
            }
        } 
        return serviceProvider;   
    }
    
    // add the session to a list of session and store as a Cookie belonging to this page
    // we add a session as we navigate to a Service Provider (SP) and the 'session' is actually the LogoutURL of the SP.
    private static void addSession(String session) {
        // Add session in JSON format to cookie
        Cookie sessions = ApexPages.currentPage().getCookies().get('sessions');
        Set <String> sset = new Set<String>();
        if(sessions !=null) {
            sset = (Set<String>)JSON.deserialize(sessions.getValue(),Set<String>.class);
        }
        sset.add(session);
        sessions = new Cookie('sessions', JSON.serialize(sset),null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{sessions});    
    }    
    
    // currently this is hard-coded but this method could be expanded to use custom-settings or some identity management
    // to select the boxes    
    private void setBoxVisibility() {
        showServiceProviders = false;
                showServiceRequests = true;
                showGeneralServiceRequests = false;
                showActivateSim = true;
                showSimSwap = false;
                showBlock = true;
                showBoltons = true;     
    }
        
    //
    // test methods
    //
    private static testMethod void test_constructorValidUser() {
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Piotr', 'Kadinsky', 'pk@pk.pk.edu');
        System.runAs(u) {
            try {
                MyO2BusinessHomeController hc = new MyO2BusinessHomeController();                           
                system.assert(true);
            } catch (Exception e) {
                // should not throw exception
                system.assert(false);
            }
        }
    } 

    private static testMethod void test_constructorInvalidUser() {
        User u = TestMyO2BusinessUtility.getGuestUser();
        System.runAs(u) {
            try {
                MyO2BusinessHomeController hc = new MyO2BusinessHomeController();                           
                // should not throw exception
                system.assert(false);
            } catch (Exception e) {
                // should not throw exception
                system.assert(true);
            }
        }       
    } 

    private static testMethod void test_getHasManageUsers() {
        MyO2BusinessHomeController hc = new MyO2BusinessHomeController();
        // get the flag from the profile and check it works
        system.assert(TestMyO2BusinessUtility.getProfileContactCreatable(), hc.getHasManageUsers());
    }
    
    private static testMethod void test_getServiceProviders_none_defined() {
        // has to use one of the SP on the user object picklist
        
        // look for it
        MyO2BusinessHomeController hc = new MyO2BusinessHomeController();
        List<SSO_Service_Provider__c> sps = hc.getServiceProviders();
        
        Boolean found = false;
        // did we get it
        for (SSO_Service_Provider__c sp:sps) {
            system.debug('sp: '+sp);
            if (sp.Name.equals('SSO_SP_Org'))
                found = true;
        }
        system.assert(found);
    }
    
    private static testMethod void test_getServiceProviders_one_defined() {
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact('karl', 'Kostavic', 'kk@kk.kk.edu');        
        
        // look for it
        MyO2BusinessHomeController hc = new MyO2BusinessHomeController();
 
        System.runAs(u) {
            List<SSO_Service_Provider__c> sps = hc.getServiceProviders();
            
            Boolean found = false;
            // did we get it
            for (SSO_Service_Provider__c sp:sps) {
                system.debug('sp: '+sp);
                if (sp.Name.equals('SSO_SP_Org'))
                    found = true;
            }
            system.assert(found);           
        }
    }

    private static testMethod void test_goToSP() {
        // look for it
        MyO2BusinessHomeController hc = new MyO2BusinessHomeController();
        SSO_Service_Provider__c sp1 = TestMyO2BusinessUtility.createSP('TEST_RSTSP', 'RSTSP', 'http://www.login.com', 'http://www.logout.com', 'relaystate');
        hc.serviceProvider = 'RSTSP';
        PageReference prExpected = new PageReference('http://www.login.com');
        PageReference prActual = hc.goToSP();
        String sExpected = prExpected.getUrl();
        String sActual = prActual.getUrl();
        system.debug('prExpected: '+sExpected);
        system.debug('prActual: '+sActual);
        system.assertEquals(sExpected, sActual);    
        
        // do it again, it exercises a code-path that uses the cache
        hc.goToSP();
    }  
*/      
}