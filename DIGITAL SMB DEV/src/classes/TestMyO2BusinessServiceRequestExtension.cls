@isTest
public with sharing class TestMyO2BusinessServiceRequestExtension {
	private static testMethod void testMyO2BusinessServiceRequestExtension() {
        // create a case so we can instantiate the controller
        Case newCase = TestMyO2BusinessUtility.createCase('Test MyO2BusinessCaseExtension','New');
        newCase.status='In Progress';
        update newCase;        
        newCase = [select id, status, service_request_type__c from case where id=:newCase.Id];
        Test.setCurrentPage(Page.MyO2BusinessServiceRequestDetails);      
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);
        Test.startTest();
        MyO2BusinessServiceRequestExtension ce = new MyO2BusinessServiceRequestExtension(sc);
        ce.thisCase = newCase; 
        ce.cComment = new CaseComment(CommentBody='Test Code Comment');
        ce.addComment();
        ce.getCaseHistory();
        Test.stopTest();
        //system.assertEquals('New',ce.getCaseHistory()[0].oldValue);
        //system.assertEquals('In Progress',ce.getCaseHistory()[0].newValue);
        system.assertEquals('Test Code Comment',ce.getCaseComments()[0].commentBody);
        system.assertEquals(0,ce.getCaseLineItems().size());
    }
}