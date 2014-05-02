@isTest
private class TestCaseCallout_AdminChange {

    static testMethod void testUpdateSubscriptionDetailsSuccess()
    {
        // Set the service endpoints custom setting
        Test.loadData(SOA_Integration_Settings__c.sObjectType, 'TestSOAIntegrationSettings');
        
        // Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
		
		// Set up the case and case line items records
        Case c = new Case(RecordTypeId = Cache.RecordTypeId('Case.' + CaseUtils.CASE_RECORD_TYPE),
        				  Origin = CaseUtils.CASE_ORIGIN,
        				  Status = CaseUtils.IN_PROGRESS,
        				  Subject='Admin Case');
        insert c;
        mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c(Case__c = c.Id,
        													SOA_Call_Type__c = CaseUtils.ADMIN_CHANGE_CALLOUT_TYPE,
        													New_Cost_Centre__c = 'centre1',
        													New_Subscriber_Name__c = 'name1');
        insert cli;
        
        Set<Id> cliSet = new Set<Id>();
        cliSet.add(cli.Id);
        mo2b_CaseLineItem__c cli2 = new mo2b_CaseLineItem__c(Case__c = c.Id,
        													SOA_Call_Type__c = CaseUtils.ADMIN_CHANGE_CALLOUT_TYPE,
        													New_Cost_Centre__c = 'centre1',
        													New_Subscriber_Name__c = null);
        cliSet.add(cli2.Id);
        mo2b_CaseLineItem__c cli3 = new mo2b_CaseLineItem__c(Case__c = c.Id,
        													SOA_Call_Type__c = CaseUtils.ADMIN_CHANGE_CALLOUT_TYPE,
        													New_Cost_Centre__c = null,
        													New_Subscriber_Name__c = 'name1');
        cliSet.add(cli3.Id);
        
        
        // Set up a web service mock
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testUpdateSubscriptionDetailsSuccess');
        mock.setStatusCode(200);        
		Test.setMock(HttpCalloutMock.class,mock);
        
        // Test
        Test.startTest();
        CaseBatchAsync.executeFuture(cliSet);
        Test.stopTest();
        
        // Verify the case line item is updated as expected
        cli = [select Id, Callout_Status_Code__c, Callout_Response__c from mo2b_CaseLineItem__c where Id = :cli.Id];
        System.assertEquals('managebusinesssubscriptions-37151-0501-S',cli.Callout_Status_Code__c);
        System.assertEquals('The request has been processed successfully.',cli.Callout_Response__c);
    }
    
    static testMethod void testUpdateSubscriptionDetailsFault()
    {
        // Set the service endpoints custom setting
        Test.loadData(SOA_Integration_Settings__c.sObjectType, 'TestSOAIntegrationSettings');
        
        // Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
		
		// Set up the case and case line items records
        Case c = new Case(RecordTypeId = Cache.RecordTypeId('Case.' + CaseUtils.CASE_RECORD_TYPE),
        				  Origin = CaseUtils.CASE_ORIGIN,
        				  Status = CaseUtils.IN_PROGRESS,
        				  Subject='Admin Case');
        insert c;
        mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c(Case__c = c.Id,
        													SOA_Call_Type__c = CaseUtils.ADMIN_CHANGE_CALLOUT_TYPE);
        insert cli;
        
        Set<Id> cliSet = new Set<Id>();
        cliSet.add(cli.Id);
        
        // Set up a web service mock
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testUpdateSubscriptionDetailsFault');
        mock.setStatusCode(200);        
		Test.setMock(HttpCalloutMock.class,mock);
        
        // Test
        Test.startTest();
        CaseBatchAsync.executeFuture(cliSet);
        Test.stopTest();
        
        // Verify the case line item is updated as expected
        cli = [select Id, Callout_Status_Code__c, Callout_Response__c, Callout_Error_Details__c from mo2b_CaseLineItem__c where Id = :cli.Id];
        System.assertEquals('managebusinesssubscriptions-37151-3003-E',cli.Callout_Status_Code__c);
        System.assertEquals('Validation errors in the data submitted for the request',cli.Callout_Response__c);
        System.assertEquals('mds.dise3g.validation:Validation errors in the data submitted for the request',cli.Callout_Error_Details__c);
    }
    
}