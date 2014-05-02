@isTest
private class TestUnifyAddSiteController{

	/*
		Runing controller when there are no locations.
	*/
 	static testMethod void AddSiteControllerTest_NO_Location() {
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp; 
        
        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('id', opp.Id);
        
        Test.startTest();

       
        UnifyAddSiteController uasc = new UnifyAddSiteController();
    	uasc.getotherSitesExist();
    	
    	Test.stopTest();

    }

	/*
		Saving existing location.
	*/
	static testMethod void AddSiteControllerTest_EXIST() {
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp; 
        
        Location__c otherLoc = new Location__c();
        insert otherLoc;
        
        Unify_Opportunity_Location__c uol = new Unify_Opportunity_Location__c();
        uol.Location__c = otherLoc.Id;
        uol.Opportunity__c=opp.Id;
        insert uol;
        
        Location__c loc = new Location__c();
        loc.Account__c=acc.Id;
        loc.Unify_Unique_Site_Name__c='test';
        loc.Unify_Validated_Postcode__c='M11AA';
        loc.Type__c='Installation';
        
        insert  loc;
        
        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('id', opp.Id);
        Test.startTest();

       
        UnifyAddSiteController uasc = new UnifyAddSiteController();
        uasc.changeOpt();
    	uasc.getotherSitesExist();
    	
    	uasc.locsList[0].selected=true;
    	
    	uasc.saveSite();
        
        Test.stopTest();

    }

 	/*
    	Adding new location;
    */
	static testMethod void AddSiteControllerTest_NEW() {
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp; 
        
        Location__c otherLoc = new Location__c();
        insert otherLoc;
        
        Unify_Opportunity_Location__c uol = new Unify_Opportunity_Location__c();
        uol.Location__c = otherLoc.Id;
        uol.Opportunity__c=opp.Id;
        insert uol;
        
        Location__c loc = new Location__c();
        loc.Account__c=acc.Id;
        loc.Unify_Unique_Site_Name__c='test';
        loc.Unify_Validated_Postcode__c='M11AA';
        loc.Type__c='Installation';
        
       
        
        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('id', opp.Id);
        Test.startTest();

       
        UnifyAddSiteController uasc = new UnifyAddSiteController();
        uasc.loc=loc;
        uasc.chosenOpt='NEW';
    	uasc.getotherSitesExist();
    	
    	
    	uasc.saveSite();
        
        Test.stopTest();

    }
    /*
    Adding already existing location; Adding location without postal code.
    */
   	static testMethod void AddSiteControllerTest_NEW2() {
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp; 
        
        Location__c otherLoc = new Location__c();
        insert otherLoc;
        
        Unify_Opportunity_Location__c uol = new Unify_Opportunity_Location__c();
        uol.Location__c = otherLoc.Id;
        uol.Opportunity__c=opp.Id;
        insert uol;
        
        Location__c loc = new Location__c();
        loc.Account__c=acc.Id;
        loc.Unify_Unique_Site_Name__c='test';
        loc.Unify_Validated_Postcode__c='M11AA';
        loc.Type__c='Installation';
        insert loc;
       
        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('id', opp.Id);
        Test.startTest();
       
        UnifyAddSiteController uasc = new UnifyAddSiteController();
        uasc.loc=loc;
        uasc.chosenOpt='NEW';
    	uasc.getotherSitesExist();
    	
    	uasc.saveSite();
        
        Location__c loc2 = new Location__c();
        loc2.Account__c=acc.Id;
        loc2.Unify_Unique_Site_Name__c='test';
        loc2.Unify_Validated_Postcode__c='';
        loc2.Type__c='Installation';
        
        uasc.loc=loc2;
        
     
        uasc.saveSite();
		Test.stopTest();
    }
    
    /*
    Testing validation
    */
    static testMethod void AddSiteControllerTest_NEW3() {
    	
    	Test.startTest();
    	
    	UnifyAddSiteController uasc = new UnifyAddSiteController();
    	
    	Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp; 
        
        Location__c otherLoc = new Location__c();
        insert otherLoc;
        
        Unify_Opportunity_Location__c uol = new Unify_Opportunity_Location__c();
        uol.Location__c = otherLoc.Id;
        uol.Opportunity__c=opp.Id;
        insert uol;
        
        Location__c loc = new Location__c();
        loc.Account__c=acc.Id;
        loc.Unify_Unique_Site_Name__c='test';
        loc.Unify_Validated_Postcode__c='M11AA';
        loc.Type__c='Installation';
        insert loc;
       
        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('id', opp.Id);
       
        uasc = new UnifyAddSiteController();
        uasc.chosenOpt = 'NEW';
        uasc.saveSite();
        uasc.loc.Unify_Unique_Site_Name__c = UnifyConfig.CENTRAL_SITE_KEY_NAME;
        uasc.saveSite();
        uasc.chosenOpt = 'EXIST';
        uasc.saveSite();
    }
}