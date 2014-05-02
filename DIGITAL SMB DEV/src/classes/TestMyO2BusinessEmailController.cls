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
private class TestMyO2BusinessEmailController
{
	//-----------------------------------------------------------------------------
	// Test all methods in MyO2BusinessEmailController with user
	//-----------------------------------------------------------------------------
    static testMethod void testWithUser()
    {
    	//
    	// Create user
    	//
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User();
		u.Username = 'angus.mcangus@sfdc.com.test.mo2b';
		u.Alias = 'angusm';
		u.FirstName = 'Angus';
		u.LastName = 'McAngus';
		u.MobilePhone = '385912345678';
		u.Email = 'angus.mcangus@sfdc.com.test';
		u.SSO_New_Email__c = 'marko.dvecko@cloudsensesolutions.com';
		u.SSO_New_Email_Date__c = Datetime.now();
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LocalesIdKey = 'en_GB';
        u.TimezonesIdKey = 'Europe/London';
		u.ProfileId = p.Id;
		insert u;

		Test.startTest();
		MyO2BusinessEmailController businessEmailController = new MyO2BusinessEmailController();
		businessEmailController.userId = u.Id;
		String mobilePhone = businessEmailController.getMobilePhone();
		String newEmail = businessEmailController.getNewEmail();
		String newEmailDate = businessEmailController.getNewEmailDate();
		String now = businessEmailController.getNow();
		//
		// Asserts
		//
		System.assertEquals('xxxxxxxx5678', mobilePhone);
		System.assertEquals('marko.dvecko@cloudsensesolutions.com', newEmail);
		System.assert(String.isNotBlank(newEmailDate));
		System.assert(String.isNotBlank(now));
		Test.stopTest();
    }

	//-----------------------------------------------------------------------------
	// Test all methods in MyO2BusinessEmailController with user
	//-----------------------------------------------------------------------------
	static testMethod void testWithoutUser()
	{
		Test.startTest();
		MyO2BusinessEmailController businessEmailController = new MyO2BusinessEmailController();
		String mobilePhone = businessEmailController.getMobilePhone();
		String newEmail = businessEmailController.getNewEmail();
		String newEmailDate = businessEmailController.getNewEmailDate();
		String now = businessEmailController.getNow();
		//
		// Asserts
		//
		System.assert(String.isBlank(mobilePhone));
		System.assert(String.isBlank(newEmail));
		System.assert(String.isBlank(newEmailDate));
		System.assert(String.isNotBlank(now));
		Test.stopTest();
	}
}