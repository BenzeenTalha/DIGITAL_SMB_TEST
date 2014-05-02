@isTest
private class TestCaseCallout_SIMSwap 
{
	static testMethod void testUpdateSubscriptionSerialNumbersSuccess()
    {
        // Set the service endpoints custom setting
        Test.loadData(SOA_Integration_Settings__c.sObjectType, 'TestSOAIntegrationSettings');
        
        // Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
		
		// Set up the case and case line items records
        Case c = new Case(RecordTypeId = Cache.RecordTypeId('Case.' + CaseUtils.CASE_RECORD_TYPE),
        				  Origin = CaseUtils.CASE_ORIGIN,
        				  Status = CaseUtils.IN_PROGRESS,
        				  Subject='SIM Swap');
        insert c;
        mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c(Case__c = c.Id,
        													SOA_Call_Type__c = CaseUtils.UPDATE_SUBSCRIPTION_SERIAL_NUMBERS);
        insert cli;
        
        Set<Id> cliSet = new Set<Id>();
        cliSet.add(cli.Id);
        
        // Set up a web service mock
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testUpdateSubscriptionSerialNumbersSuccess');
        mock.setStatusCode(200);        
		Test.setMock(HttpCalloutMock.class,mock);
        
        // Test
        Test.startTest();
        CaseBatchAsync.executeFuture(cliSet);
        Test.stopTest();
        
        // Verify the case line item is updated as expected
        cli = [select Id, Callout_Status_Code__c, Callout_Response__c from mo2b_CaseLineItem__c where Id = :cli.Id];
        System.assertEquals('managebusinesssubscriptions-37151-0001-S',cli.Callout_Status_Code__c);
        System.assertEquals('The request has been processed successfully.',cli.Callout_Response__c);
    }
    
    static testMethod void testUpdateSubscriptionSerialNumbersFault()
    {
        // Set the service endpoints custom setting
        Test.loadData(SOA_Integration_Settings__c.sObjectType, 'TestSOAIntegrationSettings');
        
        // Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
		
		// Set up the case and case line items records
        Case c = new Case(RecordTypeId = Cache.RecordTypeId('Case.' + CaseUtils.CASE_RECORD_TYPE),
        				  Origin = CaseUtils.CASE_ORIGIN,
        				  Status = CaseUtils.IN_PROGRESS,
        				  Subject='SIM Swap');
        insert c;
        mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c(Case__c = c.Id,
        													SOA_Call_Type__c = CaseUtils.UPDATE_SUBSCRIPTION_SERIAL_NUMBERS);
        insert cli;
        
        Set<Id> cliSet = new Set<Id>();
        cliSet.add(cli.Id);
        
        // Set up a web service mock
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testUpdateSubscriptionSerialNumbersFault');
        mock.setStatusCode(200);        
		Test.setMock(HttpCalloutMock.class,mock);
        
        // Test
        Test.startTest();
        CaseBatchAsync.executeFuture(cliSet);
        Test.stopTest();
        
        // Verify the case line item is updated as expected
        cli = [select Id, Callout_Status_Code__c, Callout_Response__c, Callout_Error_Details__c from mo2b_CaseLineItem__c where Id = :cli.Id];
        System.assertEquals('managebusinesssubscriptions-37151-3004-E',cli.Callout_Status_Code__c);
        System.assertEquals('Validation errors in the data submitted for the request',cli.Callout_Response__c);
        System.assertEquals('mds.dise3g.subscription.managedSerialNumberNotUnique:Managed Serial Number is not unique.:Subscription|1647300|SIM Number|1732617',cli.Callout_Error_Details__c);
    }
}