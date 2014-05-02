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
public with sharing class TestPopulateContactswithContactProfile {
	
	
	  static testMethod void PopulateContactswithContactProfile(){
	  	
	  	 String contactCustomerProfileId;
         boolean hasfailed = false;
	  	
	  	 //create setup data
        Account testAcc = new Account(Name='APEXTESTACC0010145');
        insert testAcc;
        String strAccId = testAcc.Id;
        
        Contract_Profile__c contractprofile = new Contract_Profile__c(Account__c =strAccId);
        insert contractprofile;
        
        
        Contact testCon1 = new Contact(FirstName='BETEST267', LastName='TEST00102987', AccountId=strAccId, Buying_Role__c='Other', Email='test1032@test.com',Contract_Profile__c =contractprofile.id );
        insert testCon1;
        String strConId1 = testCon1.Id;
        
         List<ContactswithCustomerProfile__c>  contactWithCustProfile  = [Select  Contact__c,Contract_Profile__c from ContactswithCustomerProfile__c where Contact__c =: strConId1 and Contract_Profile__c=:contractprofile.id];
        
    
        
         if(contactWithCustProfile.isEmpty()){
        	
        	
        	try{
        	
        	 		ContactswithCustomerProfile__c contactWithCustomerProfile = new  ContactswithCustomerProfile__c(Contact__c = strConId1, Contract_Profile__c= contractprofile.id );
		
					insert contactWithCustomerProfile;
			
					system.assertEquals(strConId1, contactWithCustomerProfile.Contact__c);
					system.assertEquals(contractprofile.id, contactWithCustomerProfile.Contract_Profile__c);
        	 	}catch(Exception e){
        			hasfailed = true;
        	  		System.assert(hasFailed);
        		}	
          
        	
        	}
        
	  
	  }

}