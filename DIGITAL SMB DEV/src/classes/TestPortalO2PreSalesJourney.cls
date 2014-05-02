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
@isTest(SeeAllData=true)
private with sharing  class TestPortalO2PreSalesJourney {

    static testMethod void myUnitTest() {
        
        Customizable_Testing_Parameters__c mc = Customizable_Testing_Parameters__c.getOrgDefaults();
        if(mc != null){
        	
        	String TestPortalUser = mc.Test_Portal_User__c;
        	String TestDISEAccountNo = mc.Test_DISE_Account_No__c;
        	
        	if(TestPortalUser != null && TestDISEAccountNo != null && TestPortalUser != '' && TestDISEAccountNo != ''){
        		
        		System.debug('**** Testing Started ***');
        		User testuser = new User(id=TestPortalUser);
		        System.runAs(testuser){
		            
		            List<Account> accs = [SELECT Id
		                FROM Account
		                WHERE DISE_Account_No__c = :TestDISEAccountNo
		                OR DISE_Group_Code_Account_No_1__c = :TestDISEAccountNo         
		                OR DISE_Group_Code_Account_No_2__c = :TestDISEAccountNo     
		                OR DISE_Group_Code_Account_No_3__c = :TestDISEAccountNo
		                OR DISE_Group_Code_Account_No_4__c = :TestDISEAccountNo];
		                
		            System.debug('accs=' + accs);
		        }
		        System.debug('**** Testing Ended ***');
        	}
        }
		        
    }
}