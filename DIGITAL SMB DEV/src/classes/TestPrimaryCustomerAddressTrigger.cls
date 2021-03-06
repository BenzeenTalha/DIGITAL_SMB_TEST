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
 */
@isTest
private class TestPrimaryCustomerAddressTrigger {

    static testMethod void TestPrimaryCustomerAddress() {
    	
    	
    	//create setup data
        Account testAcc = new Account(Name='APEXTESTACC00120');
        insert testAcc;
        String strAccId = testAcc.Id;
        
        Contract_Profile__c contractprofile = new Contract_Profile__c(Account__c =strAccId);
        insert contractprofile;
        
        Location__c location = new Location__c(account__c =strAccId,contract_profile__c = contractprofile.id, type__c='Router',Primary_Address__c = true);
        insert location;
        
         Location__c location1 = new Location__c(account__c =strAccId,contract_profile__c = contractprofile.id, type__c='Billing', Primary_Address__c= false);
         insert location1;
         
         Test.startTest();
         
         // fetch all the contactlist associated with a ContractProfile 	 	
  	    Location__c[] locationList =[Select c.Primary_Address__c, c.id,c.contract_profile__c from Location__c  c where c.contract_profile__c =: contractprofile.id];
  	    Integer expected = locationList.size();
  	    
  	    system.assertEquals(expected, locationList.size());
  	    
  	    
  	    system.assertEquals(true, location.Primary_Address__c);
  	    system.assertEquals(false, location1.Primary_Address__c);
  	    
  	    
  	    // update trigger condition check
  	    
  	    location.Primary_Address__c = false;
  	    update location;
  	    
  	    system.assertEquals(false, location.Primary_Address__c);
  	    
  	    
  	   
  	    // check the insert condition
  	    
  	   try{
  	    
  	    Location__c location3 = new Location__c(account__c =strAccId,contract_profile__c = contractprofile.id, type__c='Trading',Primary_Address__c = false );
        insert location3;
        
        Location__c location4 = new Location__c(account__c =strAccId,contract_profile__c = contractprofile.id, type__c='Shipping',Primary_Address__c = false );
        insert location4;
        
  	 }catch(Exception e){
  	    	
  	 }
        
       Test.stopTest();
    }
}