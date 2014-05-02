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
private class TestO2AccountHelper
{
    //--------------------------------------------------------------------------
    // Test getting of account with mobile phone number
    //--------------------------------------------------------------------------
    static testMethod void testGetAccountsWithMPN()
    {
        //
        // Create test accounts that will be used
        //
        TestO365Helper.createTestAccounts();
        //
        // Create service data
        //
        TestO365Helper.createServiceData();
        //
        // Create mock for service calls
        //
        Test.setMock(WebServiceMock.class, new TestO365Helper.ServiceMock());

        //
        // Call getAccountsWithMPN
        //
        Test.startTest();
            //
            // All accounts are with DISE account number somewhere
            //
            List<Account> accounts = O2AccountHelper.getAccountsWithMPN('086983342');
            system.assertEquals(2, accounts.size());

        Test.stopTest();
    }

    //--------------------------------------------------------------------------
    // Test getting of accounts with name
    //--------------------------------------------------------------------------
    static testMethod void testGetAccountsWithName()
    {
        //
        // Create test accounts that will be used
        //
        TestO365Helper.createTestAccounts();
        //
        // Create service data
        //
        TestO365Helper.createServiceData();
        //
        // Create mock for service calls
        //
        Test.setMock(WebServiceMock.class, new TestO365Helper.ServiceMock());

        //
        // Call getAccountsWithName
        //
        Test.startTest();
            //
            // Only one account has Account5 in the name
            //
            List<Account> accounts =
                O2AccountHelper.getAccountsWithName('Account5');
            system.assertEquals(1, accounts.size());
        Test.stopTest();
    }

    //--------------------------------------------------------------------------
    // Test getting of accounts with post code
    //--------------------------------------------------------------------------
    static testMethod void testGetAccountsWithPostCode()
    {
        //
        // Create test accounts that will be used
        //
        TestO365Helper.createTestAccounts();
        //
        // Create service data
        //
        TestO365Helper.createServiceData();
        //
        // Create mock for service calls
        //
        Test.setMock(WebServiceMock.class, new TestO365Helper.ServiceMock());

        //
        // Call getAccountsWithName
        //
        Test.startTest();
            //
            // Five accounts have postal code
            //
            List<Account> accounts =
                O2AccountHelper.getAccountsWithPostCode('NE12 9AH');
            system.assertEquals(5, accounts.size());
        Test.stopTest();
    }

    //--------------------------------------------------------------------------
    // Test getting of accounts with mobile phone, name and post code
    //--------------------------------------------------------------------------
    static testMethod void testGetAccounts()
    {
        //
        // Create test accounts that will be used
        //
        TestO365Helper.createTestAccounts();
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
            // Call getDISEAccountNumber
            //
            String DISEAccountNumber = O2AccountHelper.getDISEAccountNumber('086983342');
            //
            // Call getAccounts
            //
            List<Account> accounts = O2AccountHelper.getAccounts(
                    DISEAccountNumber,
                    null,
                    null);
            system.assertEquals(2, accounts.size());

            accounts = O2AccountHelper.getAccounts(
                    null,
                    'Account5',
                    null);
            system.assertEquals(1, accounts.size());

            accounts = O2AccountHelper.getAccounts(
                    null,
                    null,
                    'NE12 9AH');
            system.assertEquals(5, accounts.size());

            //
            // Zero accounts have all criteria
            // so postocode filter is ignored
            //
            accounts = O2AccountHelper.getAccounts(
                    DISEAccountNumber,
                    '3',
                    'NE12 9AH');
            system.assertEquals(1, accounts.size());

            //
            // Zero accounts have all criteria
            // so company name filter is ignored
            //
            accounts = O2AccountHelper.getAccounts(
                    DISEAccountNumber,
                    '100',
                    'NE12 9AH');
            system.assertEquals(2, accounts.size());

            //
            // One account match criteria
            //
            accounts = O2AccountHelper.getAccounts(
                    DISEAccountNumber,
                    '7',
                    'NE12 9AH');
            system.assertEquals(2, accounts.size());
        Test.stopTest();
    }
}