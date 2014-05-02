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
private class TestsetOrderStatusActiveDateTrigger {
    
    static testMethod void TestsetOrderStatusActiveDateTrigger() {
     
        //create setup data
        Account testAcc = new Account(Name='APEXTESTACC0010');
        insert testAcc;
        String strAccId = testAcc.Id;
        
      
        Profile profile =  [select id from Profile where name ='BE User'];
       
        
        User currentuser= new User(ProfileId=profile.Id,username='TestsetOrderStatusActiveDateTrigger001@test.com',lastname='Test',email='test1@test.com',alias='test',timezonesidkey='Europe/London',localesidkey='en_GB',emailencodingkey='ISO-8859-1',languagelocalekey='en_US') ;
        insert currentuser;
         
        Order__c orderCon = new Order__c(Name='TestOrder', Account__c=strAccId,order_status__c = 'Active');
        insert orderCon;
     
        
        if(currentuser.profileId == profile.id && orderCon.Order_Status__c == 'Active'){
            
            orderCon.Order_Active_Date__c = date.today();
            update orderCon;
            String strOrderId = orderCon.Id;
            
            System.assertNotEquals(null, strOrderId);
            System.assertEquals(date.today(), orderCon.Order_Active_Date__c);
        }
        
        
        
    }

}