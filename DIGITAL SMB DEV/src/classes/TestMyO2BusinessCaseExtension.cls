/**
 * This class contains unit tests for MyO2BusinessCaseExtension (bucket case) controller. 
 */
@isTest
private class TestMyO2BusinessCaseExtension{
    
  /*
  Given I am on the MyO2BusinessOtherServiceRequest
  When I fill in case details and I click save
  Then I should see the new case created
  */  
  
  static testMethod void testConstructor() {
  	List<mo2b_CaseLineItem__c> clis = [SELECT Id, Name, Case__r.Request_Sub_Type__c, Case__c FROM mo2b_CaseLineItem__c LIMIT 1];
  	MyO2BusinessCaseExtension mobce1 = new MyO2BusinessCaseExtension();
  	if (clis.size() > 0) {
	  	ApexPages.currentPage().getParameters().put('id', clis[0].Id);
	  	MyO2BusinessCaseExtension mobce2 = new MyO2BusinessCaseExtension();
  	}
  } 
  
  @isTest static void testCaseCreation() {
    PageReference pageRef = Page.MyO2BusinessOtherServiceRequest;
    Test.setCurrentPage(pageRef);
    Case c = new Case(Service_Request_Type__c='testCaseCreation');
    insert c;
    Attachment att = new Attachment(name='testAtt',body=Blob.valueOf('Unit Test Attachment Body'));
    Test.startTest();
    ApexPages.StandardController std = new ApexPages.StandardController(c);
    MyO2BusinessCaseExtension controller = new MyO2BusinessCaseExtension(std);
    controller.clis = new List <mo2b_CaseLineItem__c>();
    //MyO2BusinessCaseExtension controller = new MyO2BusinessCaseExtension();
    controller.thisCase = new Case(Service_Request_Type__c='testCaseCreation');
    controller.attachment = att;
    controller.cli = new mo2b_CaseLineItem__c(post_code__c='SW12 5PQ');
    String cid = controller.doDetailSave().getParameters().get('id');
    Test.stopTest();
    System.assertEquals('testCaseCreation', [select subject from case where id=:cid].subject);
    System.assertEquals(1,[select count() from attachment where parentId=:cid]);
    System.assertEquals(1,[select count() from mo2b_CaseLineItem__c where case__c=:cid]);
  }  

  @isTest static void testCaseCreationErrors() {
    PageReference pageRef = Page.MyO2BusinessOtherServiceRequest;
    Test.setCurrentPage(pageRef);
    Case c = new Case(Service_Request_Type__c='testCaseCreation');
    insert c;
    Attachment att = new Attachment(name='testAtt',body=Blob.valueOf('Unit Test Attachment Body'));
    ApexPages.StandardController std = new ApexPages.StandardController(c);
    MyO2BusinessCaseExtension controller = new MyO2BusinessCaseExtension(std);
    //MyO2BusinessCaseExtension controller = new MyO2BusinessCaseExtension();
    controller.thisCase = null;
    System.assertEquals(controller.doSave(), null);
    controller.attachment = null;
    System.assertEquals(controller.doSave(), null);
    controller.Cancel();
    //controller.pageName = new Pagereference('Test');
    controller.Cancel();
  }
  /*
  @isTest static void testCaseExtension() { 
    Case c = new Case(Service_Request_Type__c='testCaseCreation');
    insert c;    
    //ApexPages.StandardController std = new ApexPages.StandardController(c);
    //MyO2BusinessCaseExtension controller = new MyO2BusinessCaseExtension(std);
    Test.startTest();
    Test.setCurrentPageReference(new Pagereference('https://o2--dev.cs13.my.salesforce.com/MyO2SMB'));
    MyO2BusinessCaseExtension controller = new MyO2BusinessCaseExtension();
    insert controller.thisCase;
    System.debug('test case extension c.id = ' + c.Id);
    System.debug('test case extension controller.thisCase.Id = ' + controller.thisCase.Id);
    System.assertEquals(c.Id, controller.thisCase.Id);
    Test.stopTest();
  }*/

  @isTest static void testCaseEdit() { 
    Case c = new Case(Service_Request_Type__c='testCaseCreation');
    insert c;
    mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c(case__c=c.Id, post_code__c='SW12 5PQ');
    insert cli;
    ApexPages.currentPage().getParameters().put('id',cli.Id);
    Test.startTest();
    ApexPages.StandardController std = new ApexPages.StandardController(c);
    MyO2BusinessCaseExtension controller = new MyO2BusinessCaseExtension(std);
    //MyO2BusinessCaseExtension controller = new MyO2BusinessCaseExtension();
    controller.cli = cli;
    controller.clis = new List <mo2b_CaseLineItem__c>();
    controller.doAddDetails();
    controller.cli.Mobile_User_Name__c = 'test user name';
    controller.doDetailSave();
    controller.doClone();
    Test.stopTest();
    System.assertEquals(1,[select count() from mo2b_CaseLineItem__c where case__c=:c.Id]);
    List<mo2b_CaseLineItem__c> clis = [select Mobile_User_Name__c from mo2b_CaseLineItem__c where case__c=:c.Id limit 2];
    System.assertEquals('test user name',clis[0].Mobile_User_Name__c);
    //System.assertEquals('test user name',clis[1].Mobile_User_Name__c);
  } 
  
}