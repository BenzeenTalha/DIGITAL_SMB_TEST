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
private class TestMyO2BusinessToken
{
	//--------------------------------------------------------------------------
	// Test generating and validation of token with custom settings
	//--------------------------------------------------------------------------
	static testMethod void testWithCustomSettings()
	{
		//
		// Create user
		//
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact(
				'Angus', 
				'McAngus', 
				'angus.mcangus@sfdc.com.test');
		//
		// Create custom settings
		//
		createCustomSettings();
		
		Test.startTest();
		//
		// Create token
		//
		String token = MyO2BusinessToken.make(u.Id, MyO2BusinessToken.ACTIVATION);
		//
		// Validate token
		//
		MyO2BusinessToken businessToken = new MyO2BusinessToken(token);
		//
		// Check user
		//
		MyO2BusinessUser businessUser = businessToken.getUser();
		system.assertNotEquals(businessUser, null);
		//
		// Check configuration
		//
		system.assert(businessToken.validate(MyO2BusinessToken.ACTIVATION));
		system.assert(!businessToken.validate(MyO2BusinessToken.EMAIL_CONFIRMATION));
		system.assert(!businessToken.validate(MyO2BusinessToken.FORGOT_PASSWORD));
		//
		// Check token map
		//
		String userId = businessToken.getUserId(); 
		String configuration = businessToken.getConfiguration();
		system.assertEquals(userId, u.Id);
		system.assertEquals(configuration, MyO2BusinessToken.ACTIVATION);

		Test.stopTest();
	}

	//--------------------------------------------------------------------------
	// Test token generating and validation without custom settings
	//--------------------------------------------------------------------------
	static testMethod void testWithoutCustomSettings()
	{
		//
		// Create user
		//
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact(
				'Angus', 
				'McAngus', 
				'angus.mcangus@sfdc.com.test');

		Test.startTest();
		//
		// Create token
		//
		String token = MyO2BusinessToken.make(u.Id, MyO2BusinessToken.ACTIVATION);
		//
		// Validate token
		//
		MyO2BusinessToken businessToken = new MyO2BusinessToken(token);
		//
		// Check user
		//
		MyO2BusinessUser businessUser = businessToken.getUser();
		system.assertNotEquals(businessUser, null);
		//
		// Check configuration
		//
		system.assert(businessToken.validate(MyO2BusinessToken.ACTIVATION));
		system.assert(!businessToken.validate(MyO2BusinessToken.EMAIL_CONFIRMATION));
		system.assert(!businessToken.validate(MyO2BusinessToken.FORGOT_PASSWORD));
		//
		// Check token map
		//
		String userId = businessToken.getUserId(); 
		String configuration = businessToken.getConfiguration();
		system.assertEquals(userId, u.Id);
		system.assertEquals(configuration, MyO2BusinessToken.ACTIVATION);

		Test.stopTest();
	}

	//--------------------------------------------------------------------------
	// Validation of invalid token
	//--------------------------------------------------------------------------
	static testMethod void testInvalidToken()
	{
		//
		// Create user
		//
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact(
				'Angus', 
				'McAngus', 
				'angus.mcangus@sfdc.com.test');
		//
		// Create custom settings
		//
		createCustomSettings();

		Test.startTest();
		MyO2BusinessToken businessToken = new MyO2BusinessToken('rubbish');
		system.assert(!businessToken.validate(MyO2BusinessToken.ACTIVATION));
		Test.stopTest();
	}

	private static void createCustomSettings()
	{
		//
		// Create custom settings for each token configuration
		//
		List<SSOTokenProperties__c> tokenProperties = new List<SSOTokenProperties__c>();
		tokenProperties.add(getSSOTokenProperties(MyO2BusinessToken.ACTIVATION));
		tokenProperties.add(getSSOTokenProperties(MyO2BusinessToken.EMAIL_CONFIRMATION));
		tokenProperties.add(getSSOTokenProperties(MyO2BusinessToken.FORGOT_PASSWORD));
		insert tokenProperties;
		//
		// Cusotm settings for encryption key
		//
		SSOEncryptionKeys__c encryptionKey = new SSOEncryptionKeys__c();
		encryptionKey.Name = 'Token_Key';
		encryptionKey.Key__c = '1gt2dPQjZcD7wvvUZ1h2blw6zlVzO0r58Hxrk64ATT0=';
		insert encryptionKey;
	}

	//--------------------------------------------------------------------------
	// Fill token property record
	//--------------------------------------------------------------------------
	private static SSOTokenProperties__c getSSOTokenProperties(String name)
	{
		SSOTokenProperties__c configuration = new SSOTokenProperties__c();
		configuration.Name = name;
		configuration.Single_Use_Token__c = true;
		configuration.Token_Expires__c = true;
		configuration.Validity_After_Creation_In_Hours__c = 24;
		return configuration;
	}
}