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
private class TestCheckActiveFlagForDiscountTrigger {

	private static BE_Discount__c bed {get; set;}
	private static BE_Discount__c bed2 {get; set;}

	static void setupData() {
		Account account = new Account(Name='Ecma');
		insert account;

		bed = new BE_Discount__c(Account__c=account.Id, Status__c='Locked - Approved');
		insert bed;
		
		bed2 = new BE_Discount__c(Account__c=account.Id, Status__c='Locked - Approved');
		insert bed2;
			
	}

    static testMethod void testInsert() {
        setupData();
    }
    
    static testMethod void testUpdate() {
        setupData();
        bed.Active__c=true;
        update bed;
        bed2.Active__c=true;
        update bed2;
    }
    
    static testMethod void testDeleteUndelete() {
    	// nothing to do as trigger not defined
    }
}