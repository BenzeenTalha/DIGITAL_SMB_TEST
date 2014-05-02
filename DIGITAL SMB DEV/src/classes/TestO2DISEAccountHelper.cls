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
private class TestO2DISEAccountHelper
{
	//--------------------------------------------------------------------------
	// Test getting DISE account
	//--------------------------------------------------------------------------
	static testMethod void testGetDISEAccount()
	{
		//
		// Create service data
		//
		TestO365Helper.createServiceData();
		//
		// Create mock for service calls
		//
		Test.setMock(WebServiceMock.class, new TestO365Helper.ServiceMock());

		Test.startTest();
			//
			// Call getDISEAccount
			//
			O2DISEAccountHelper.DISEAccount diseAccount =
				O2DISEAccountHelper.getDISEAccount('086983342');
			system.assertEquals('9854628', diseAccount.subscriptionNumber);
			system.assertEquals('12345', diseAccount.accountNumber);
			system.assertEquals('Q10ADX', diseAccount.tariffCode);
			system.assertEquals('Mobile Broadband 1GB', diseAccount.tariffDescription);
			system.assertEquals('HARDWARE', diseAccount.tariffType);
			system.assertEquals('Testing Account - Chowdary', diseAccount.companyName);
			system.assertEquals('1 Test Street Preston Brook', diseAccount.streetAddress);
			system.assertEquals('Runcorn', diseAccount.city);
			system.assertEquals('Cheshire', diseAccount.county);
			system.assertEquals('NE3 2EF', diseAccount.postCode);
			system.assertEquals('Direct', diseAccount.salesAccountCategory);
			system.assertEquals(true, diseAccount.isAccountManaged);
			/*
			TODO Write those data in service mock
			system.assertEquals(, diseAccount.contactTitle);
			system.assertEquals(, diseAccount.contactFirstName);
			system.assertEquals(, diseAccount.contactMiddleName);
			system.assertEquals(, diseAccount.contactLastName);
			system.assertEquals(, diseAccount.contactOccupation);
			system.assertEquals(, diseAccount.contactPhone);
			system.assertEquals(, diseAccount.contactEmail);
			*/
			system.assertEquals(638, diseAccount.monthlyLineRentalFee);
		Test.stopTest();
	}

	static testMethod void testGetDISEAccountError()
	{
		//
		// Create service data
		//
		TestO365Helper.createServiceData();
		//
		// Create mock for service calls
		//
		Test.setMock(WebServiceMock.class, new TestO365Helper.ServiceMock());

		Test.startTest();
		{
			//
			// Call getDISEAccount
			//
			O2DISEAccountHelper.DISEAccount diseAccount =
				O2DISEAccountHelper.getDISEAccount('Error');
			system.assertEquals(null, diseAccount);
		}
		Test.stopTest();
	}

	//--------------------------------------------------------------------------
	// Test getting DPAChecks
	//--------------------------------------------------------------------------
	static testMethod void testGetDPAChecks()
	{
		//
		// Create service data
		//
		TestO365Helper.createServiceData();
		//
		// Create mock for service calls
		//
		Test.setMock(WebServiceMock.class, new TestO365Helper.ServiceMock());

		Test.startTest();
			//
			// Call getDPAChecks
			//
			O2DISEAccountHelper.DPAChecks dpaChecks =
				O2DISEAccountHelper.getDPAChecks('12345');
			system.assertEquals('AAAAAA', dpaChecks.accountPassword);
			system.assertEquals(9999, dpaChecks.accountPin);
			system.assertEquals('0123456789', dpaChecks.bankAccountNumber);
			system.assertEquals('012345', dpaChecks.bankSortCode);
			system.assertEquals(Date.today().addDays(-12), dpaChecks.lastInvoiceDate);
			system.assertEquals(Date.today().addDays(-10), dpaChecks.lastPaymentDate);
			system.assertEquals(5555, dpaChecks.lastInvoiceAmount);
			system.assertEquals('3333', dpaChecks.lastInvoiceNumber);
		Test.stopTest();
	}
}