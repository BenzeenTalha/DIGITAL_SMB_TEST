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
private class TestMyO2BusinessUser
{
    //--------------------------------------------------------------------------
    // Test without custom settings
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

        MyO2BusinessUser.getNumberOfAttempts();
        MyO2BusinessUser.getLockoutPeriod();

        MyO2BusinessUser businessUser = new MyO2BusinessUser();
        businessUser = new MyO2BusinessUser(u.Id);
        businessUser = new MyO2BusinessUser('angus.mcangus@sfdc.com.test');
        u = businessUser.getUser();
        Id userId = businessUser.getUserId();
        //
        // Asserts
        //
        System.assertNotEquals(u, null);
        System.assertEquals(userId, u.Id);

        businessUser.setUserName(
                'marko.dvecko@juro.com' + MyO2BusinessCreateUser.USERNAME_SUFFIX);

        businessUser.setTitle('Mr');
        businessUser.setFirstName('Marko');
        businessUser.setLastName('Dvecko');
        String username = businessUser.getUserName();
        String title = businessUser.getTitle();
        String firstName = businessUser.getFirstName();
        String lastName = businessUser.getLastName();
        //
        // Asserts
        //
        System.assertEquals(
                username,
                'marko.dvecko@juro.com' + MyO2BusinessCreateUser.USERNAME_SUFFIX,
                'Setting username fails');
        System.assertEquals(title, 'Mr');
        System.assertEquals(firstName, 'Marko');
        System.assertEquals(lastName, 'Dvecko');

        businessUser.setCanPassMyDetails(true);
        businessUser.setCanUpdateMe(true);
        //
        // Asserts
        //
        System.assert(u.MO2B_ShareDetails__c);
        System.assert(u.MO2B_OptIn__c);

        businessUser.setSecurityQuestion('City where you are born');
        businessUser.setSecurityAnswer('Koprivnica');
        businessUser.setSecurityAnswerHint('Hello');
        businessUser.setEmail('marko.dvecko@cloudsensesolutions.com');
        businessUser.setNewEmail('dvecko.marko@cloudsensesolutions.com');
        businessUser.setPhone('+385123456789');
        businessUser.setMobilePhone('+385912345678');
        businessUser.setIsForgotPassword(true);
        String securityQuestion = businessUser.getSecurityQuestion();
        String securityAnswer = businessUser.getSecurityAnswer();
        String securityAnswerHint = businessUser.getSecurityAnswerHint();
        String email = businessUser.getEmail();
        String newEmail = businessUser.getNewEmail();
        String phone = businessUser.getPhone();
        String mobilePhone = businessUser.getMobilePhone();
        Datetime newEmailDate = businessUser.getNewEmailDate();
        Boolean isForgotPassword = businessUser.getIsForgotPassword();
        //
        // Asserts
        //
        System.assertEquals(securityQuestion, 'City where you are born');
        System.assertEquals(securityAnswer, 'Koprivnica');
        System.assertEquals(securityAnswerHint, 'Hello');
        System.assertEquals(email, 'marko.dvecko@cloudsensesolutions.com');
        System.assertEquals(newEmail, 'dvecko.marko@cloudsensesolutions.com');
        System.assertEquals(phone, '+385123456789');
        System.assertEquals(mobilePhone, '+385912345678');
        System.assertEquals(isForgotPassword, true);
        System.assertNotEquals(null, newEmailDate);

        Boolean isActivationPending = businessUser.isActivationPending();
        Boolean isActive = businessUser.isActive();
        Boolean isFirstTimeActivation = businessUser.isFirstTimeActivation();
        String activationCode = businessUser.generateActivationCode();
        Boolean validateActivationCode =
            businessUser.validateActivationCode(activationCode);
        //
        // Asserts
        //
        System.assert(isActivationPending);
        System.assert(!isActive);
        System.assert(isFirstTimeActivation);
        System.assert(validateActivationCode);

        Test.stopTest();
    }

    //--------------------------------------------------------------------------
    // Test method that are not tested before with custom settings
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
        // Custom settings
        //
        List<SSOSettings__c> settings = new List<SSOSettings__c>();
        SSOSettings__c setting1 = new SSOSettings__c();
        setting1.Name = MyO2BusinessUser.NUMBER_OF_ATTEMPTS;
        setting1.Number__c = 5;
        settings.add(setting1);
        SSOSettings__c setting2 = new SSOSettings__c();
        setting2.Name = MyO2BusinessUser.LOCKOUT_PERIOD;
        setting2.Number__c = 100;
        settings.add(setting2);
        insert settings;

        Test.startTest();

        Integer numberOfAttempts = MyO2BusinessUser.getNumberOfAttempts();
        Integer lockoutPeriod = MyO2BusinessUser.getLockoutPeriod();
        System.assertEquals(numberOfAttempts, 5);
        System.assertEquals(lockoutPeriod, 100);

        MyO2BusinessUser businessUser = new MyO2BusinessUser(u.Id);
        businessUser.setMobilePhone('+385912345678');
        MyO2BusinessUserException error = null;
        try
        {
            businessUser.setSecurityAnswer(null);
        }
        catch(MyO2BusinessUserException e)
        {
            error = e;
        }
        System.assertNotEquals(error, null);
        try
        {
            //
            // This is going to fail because we created account in the same transaction
            //
            businessUser.activateUser('password1234');
        }
        catch(Exception e) {}

        Test.stopTest();

        Boolean isActive = businessUser.isActive();
        //System.assert(!isActive);
    }

    //--------------------------------------------------------------------------
    // Test login history functionality
    //--------------------------------------------------------------------------
    static testMethod void testLoginHistory()
    {
        //
        // Create user
        //
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact(
                'Angus',
                'McAngus',
                'angus.mcangus@sfdc.com.test');

        Test.startTest();

        MyO2BusinessUser businessUser = new MyO2BusinessUser(u.Id);
        MyO2BusinessUser.LoginStatus loginStatus = businessUser.getLoginStatus();
        Boolean isLocked = loginStatus.isLocked();
        Boolean isFirstTimeLocked = loginStatus.isFirstTimeLocked();

        Test.stopTest();

        System.assert(!isLocked);
        System.assert(!isFirstTimeLocked);
    }
}