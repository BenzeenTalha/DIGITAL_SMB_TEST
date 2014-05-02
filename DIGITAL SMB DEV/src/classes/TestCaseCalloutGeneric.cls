@isTest
private class TestCaseCalloutGeneric {

    static final String PREFIX = 'Test';
    static final String NUMBER_PREFIX = '78787878';
    static final String VALID_SIM_NUMBER_PREFIX = '8944110065174691779';
    										
    
    static Account createAccount() 
    {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;     
    }
    
    static AC_Container__c createACContainer() 
    {
        AC_Container__c cont = new AC_Container__c(Name = 'Test Container');
        insert cont;
        return cont;     
    }
    
    static List<AC_Subscription__c>  createSubscribers(AC_Container__c cont, Integer recordCount) 
    {
		Integer i = 0;
        List<AC_Subscription__c> subsList = new List<AC_Subscription__c>();
        
        for (i=0; i<recordCount; i++) {
            AC_Subscription__c sub = new AC_Subscription__c();
            sub.Subscription_Name__c = PREFIX + i;
            sub.AC_Container__c = cont.Id;
            //sub.customerCostCentre__c = 'XYZ';
            sub.Network_Serial_No__c = NUMBER_PREFIX + i;
            sub.Subscription_ID__c = NUMBER_PREFIX + i;
            //sub.tariffCode__c = 'XYZ';
            //sub.tariffDescription__c = 'XYZ desc';
            subsList.add(sub);
        }
        
        insert subsList;
        
        List<AC_Subscription__c> orderedList = [SELECT Id, Subscription_Name__c FROM AC_Subscription__c WHERE AC_Container__c=:cont.Id ORDER BY Subscription_Name__c];
        
        return orderedList;
    }
    
    static List<Case>  createCases(Account acc, Integer recordCount) 
    {
		Integer i = 0;
        List<Case> casesList = new List<Case>();
        
        for (i=0; i<recordCount; i++) {
            Case c = new Case();
            c.RecordTypeId = Cache.RecordTypeId('Case.' + CaseUtils.CASE_RECORD_TYPE);
        	c.Origin = CaseUtils.CASE_ORIGIN;
        	c.Subject = PREFIX + i;
            c.AccountId = acc.id;
            casesList.add(c);
        }
        
        insert casesList;
        
        List<Case> orderedList = [SELECT Id, Subject FROM Case WHERE AccountId=:acc.Id ORDER BY Subject];
        
        return orderedList;
    }
    
    static List<mo2b_CaseLineItem__c>  createCaseLineItems(list<Case> cases,list<AC_Subscription__c> subs, Integer recordCount) 
    {
		Integer i = 0;
        List<mo2b_CaseLineItem__c> cliList = new List<mo2b_CaseLineItem__c>();
        
        for(i=0; i<cases.size(); i++)
        {
        	for(integer j = 0; j<recordCount; j++)
        	{
	        	mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c();
	        	cli.Case__c = cases[i].Id;
	        	cli.New_SIM_Number__c = VALID_SIM_NUMBER_PREFIX + j;
	        	cli.SOA_Call_Type__c = CaseUtils.UPDATE_SUBSCRIPTION_SERIAL_NUMBERS;
	        	cli.AC_Subscription__c = subs[j].Id;
	        	 
	        	cliList.add(cli);
        	}
        }
        
        insert cliList;
        
        return cliList;
    }
    
    static void testCreateObjects(Account acc, AC_Container__c cont, Integer recordCount) 
    {
        List<Account> accList = [SELECT Id FROM Account WHERE Id=:acc.Id];
        system.assert(accList != null);
        system.assertEquals(1, accList.Size());
        
        List<AC_Container__c> contList = [SELECT Id FROM AC_Container__c WHERE Id=:cont.Id];
        system.assert(contList != null);
        system.assertEquals(1, contList.Size());

        List<AC_Subscription__c> subsList = [SELECT Id FROM AC_Subscription__c WHERE AC_Container__c=:cont.Id];
        system.assert(subsList != null);
        system.assertEquals(recordCount, subsList.Size());
        
        List<mo2b_CaseLineItem__c> cliList = [SELECT Id FROM mo2b_CaseLineItem__c WHERE AC_Subscription__r.AC_Container__c=:cont.Id];
        system.assert(cliList != null);
        system.assertEquals(recordCount, cliList.Size());
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // Check that batch jobs defer when there are 10 or more case line items to be processed
    static testMethod void testCaseInputProcessorAndProcessCases()
    {
		// Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
        
		//Set up data
		Account acc = createAccount();
		AC_Container__c cont = createACContainer();
        List<AC_Subscription__c> subsList = createSubscribers(cont, 6);
        List<Case> casesList = createCases(acc, 1);
        List<mo2b_CaseLineItem__c> cliList = createCaseLineItems(casesList, subsList, 6);
        testCreateObjects(acc, cont, 6);
        
        //set the callout status to in progress
        for(Case c : casesList){
            c = CaseInputProcessor.processCase(c);
            //verify that callout status is in progress
            System.assertEquals(CaseUtils.IN_PROGRESS, c.Callout_Status__c); 
        }

        // Start test
        Test.startTest();

        CaseUtils.processCases(new List<Id>{casesList[0].Id});
        
        // Stop test
        Test.stopTest();

        // Last one should not have been processed
        Case c = [Select Id, Callout_Status__c From Case Where Id = : casesList[0].Id];
        system.debug('+++ c: ' + c);
        //System.assertEquals(CaseUtils.IN_PROGRESS, c.Callout_Status__c);

    }
	
    static testMethod void testDeferredCases()
    {
        // Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
        
        //Set up data
		Account acc = createAccount();
        AC_Container__c cont = createACContainer();
        List<AC_Subscription__c> subsList = createSubscribers(cont, 11);
        List<Case> casesList = createCases(acc, 2);
        List<mo2b_CaseLineItem__c> cliList = createCaseLineItems(casesList, subsList, 11);

        //set the callout status to in progress
        for(Case c : casesList){
            c = CaseInputProcessor.processCase(c);
            //verify that callout status is in progress
            System.assertEquals(CaseUtils.IN_PROGRESS, c.Callout_Status__c); 
        }

        // Start test
        Test.startTest();

        CaseUtils.processCases(new List<Id>{casesList[0].Id, casesList[1].Id});
        
        // Stop test
        Test.stopTest();

        // These cases should not have been processed
        Case c1 = [Select Id, Callout_Status__c From Case Where Id = : casesList[0].Id];
        System.assertEquals(CaseUtils.DEFERRED, c1.Callout_Status__c);
        
        Case c2 = [Select Id, Callout_Status__c From Case Where Id = : casesList[1].Id];
        System.assertEquals(CaseUtils.DEFERRED, c2.Callout_Status__c);
    }
    
    static testMethod void testSweep()
    {
        // Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
        
        //Set up data
		Account acc = createAccount();
        AC_Container__c cont = createACContainer();
        List<AC_Subscription__c> subsList = createSubscribers(cont, 1);
        List<Case> casesList = createCases(acc, 1);
        List<mo2b_CaseLineItem__c> cliList = createCaseLineItems(casesList, subsList, 1);
        testCreateObjects(acc, cont, 1);
        
        for(Case c : casesList){
        	c.Callout_Status__c = CaseUtils.DEFERRED;
        }
        update casesList;

        
        // Start test
        Test.startTest();
		// Improve code coverage by initating the sweep functionality
        SchedulableContext SC;
        CaseBatchAsync sch = new CaseBatchAsync();
        sch.execute(SC);
        Test.stopTest();
    }
    
    static testMethod void testSOAFaultException()
    {
        string code = 'testFaultCode';
        string description = 'testFaultDescription';
        string trace = 'testFaultTrace';
        
        try{
        	throw new CaseUtils.SOAFaultException(code, description, trace);
        }
        catch (CaseUtils.SOAFaultException ex){
        	system.assertEquals(code, ex.SOAFaultCode);
        	system.assertEquals(description, ex.faultDescription);
        	system.assertEquals(trace, ex.faultTrace);
        }
    }
    
    static testMethod void testClearACSubscriptionExtras()
    {
        //Set up data
		AC_Container__c cont = createACContainer();
        List<AC_Subscription__c> subsList = createSubscribers(cont, 1);
        AC_Subscription_Extra__c subExtra = new AC_Subscription_Extra__c(AC_Subscription__c = subsList[0].Id);
        insert subExtra;
        
        // Start test
        Test.startTest();
		SchedulableContext SC;
        ClearACSubscriptionExtras sch = new ClearACSubscriptionExtras();
        sch.execute(SC);
        Test.stopTest();
        
        integer countSubExtra = [select count() from AC_Subscription_Extra__c];
        system.assertEquals(0,countSubExtra);
    }

}