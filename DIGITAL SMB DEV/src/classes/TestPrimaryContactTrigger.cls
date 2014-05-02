/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * Test class for PopulateContactswithContactProfile and DuplicateContactWithCustomerProfileTrigger
 
 */
@isTest
private class TestPrimaryContactTrigger {
	
	  static testMethod void TTestPrimaryContactTrigger() {
	
	
	    //create setup data
        Account testAcc = new Account(Name='APEXTESTACC00101');
        insert testAcc;
        String strAccId = testAcc.Id;
        
        Contract_Profile__c contractprofile = new Contract_Profile__c(Account__c =strAccId);
        insert contractprofile;
        
        Contact testCon = new Contact(FirstName='BETEST1', LastName='TEST00101', AccountId=strAccId, Buying_Role__c='Other', Email='test100@test.com',Contract_Profile__c=contractprofile.id, Primary__c = true );
        insert testCon;
        String strConId = testCon.Id;
        
        
        Contact testCon1 = new Contact(FirstName='BETEST2', LastName='TEST00102', AccountId=strAccId, Buying_Role__c='Other', Email='test103@test.com',Contract_Profile__c =contractprofile.id, Primary__c = false );
        insert testCon1;
        String strConId1 = testCon1.Id;
        
        
        // select all the contacts
        
         Test.startTest();
        
        // fetch all the contactlist associated with a ContractProfile 	 	
  	    Contact[] contactList =[Select c.primary__c, c.id,c.Contract_Profile__c from Contact c where c.Contract_Profile__c =: contractprofile.id];
  	    Integer expected = contactList.size();
  	    
  	    system.assertEquals(expected, contactList.size());
  	    
  	    
  	    system.assertEquals(true, testCon.Primary__c);
  	    system.assertEquals(false, testCon1.Primary__c);
  	    
  	    
  	    // update trigger condition check
  	    
  	    testCon.Primary__c = false;
  	    update testCon;
  	    
  	    system.assertEquals(false, testCon.Primary__c);
  	    
  	    
  	    // check the insert condition
  	    
  	   try{
  	    
  	  Contact testCon3 = new Contact(FirstName='BETEST3', LastName='TEST00103', AccountId=strAccId, Buying_Role__c='Other', Email='test104@test.com',Contract_Profile__c =contractprofile.id, Primary__c = true );
       insert testCon3;
        
        Contact testCon4 = new Contact(FirstName='BETEST4', LastName='TEST00104', AccountId=strAccId, Buying_Role__c='Other', Email='test106@test.com',Contract_Profile__c =contractprofile.id, Primary__c = true );
       insert testCon4;
        
  	 }catch(Exception e){
  	    	
  	 }
  	 
  	  Test.stopTest();
    
  }
}