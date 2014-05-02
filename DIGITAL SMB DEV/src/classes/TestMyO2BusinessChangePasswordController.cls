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
private class TestMyO2BusinessChangePasswordController 
{

    static testMethod void testChangePassword() {
        // TO DO: implement unit test
    }

    static testMethod void testForgotPassword() {
        // TO DO. implement unit test
    }
    
    private static testMethod void testRedirect() {
    	MyO2BusinessChangePasswordController ctrl = new MyO2BusinessChangePasswordController();
    	ctrl.redirect();
    }
    
    private static testMethod void testChangePasswordController()    {
         // User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Jose', 'Garcia', 'jg@gose.jose.edu');
         // System.runAs(u){      
                  // Instantiate a new controller with all parameters in the page 
             MyO2BusinessChangePasswordController controller = new MyO2BusinessChangePasswordController();
            // controller.username = u.email;            
             //TestMyO2BusinessUtility.setUserQA(u, 'question', 'answer');   
             //PageReference pr = controller.setNewPassword();           
            /* if (ApexPages.hasMessages()) {
                system.assertEquals(pr, null);      
             }else{         
                 system.assertEquals(pr, Page.MyO2BusinessForgotPasswordConfirm); 
             } */     
        //  } 
    }
    
     // ******** TEST CODE ***********
     
     private static testmethod void test_registered()
    {
        test_basic(true);
    }

   
    private static testmethod void test_unregistered()
    {
        test_basic(false);
    }
     
     private static void test_basic(Boolean bHasAnswer){
        createData();
        Profile pr = [SELECT Id FROM profile WHERE name = 'Standard User'];
        system.assert(pr != null);

        User u = new User(alias = 'standt', email = 'standarduser@testorgO2Courtesy.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = pr.Id,
                timezonesidkey = 'America/Los_Angeles', username = 'standarduser@testorgO2Courtesy.com',
                SSO_question__c = 'Name of your pet?', MO2B_OptIn__c = true, MO2B_ShareDetails__c = true);
        if (bHasAnswer)
        {
            u.SSO_answer__c = 'godzilla';
        }
        insert u;
        u.SSO_Forgot_Password__c = true;
        system.assert(u != null);

        System.runAs(u)
        {
            Test.setCurrentPageReference(Page.MyO2BusinessChangePassword);
            // set parameters
            ApexPages.currentPage().getParameters().put('retURL','/apex/MyO2BuisnessHome');
            ApexPages.currentPage().getParameters().put('fromFrontdoor','something');
            ApexPages.currentPage().getParameters().put('display','something');

            // create controller
            MyO2BusinessChangePasswordController con = new MyO2BusinessChangePasswordController();
            con.oldPassword = 'secret1';
            con.newPassword = 'secret2';
            con.verifyNewPassword = 'secret3';
            con.businessUser.setIsForgotPassword(true);
            con.getIsForgotPassword();
            con.setNewPassword();
            con.businessUser.setIsForgotPassword(false);
            con.setNewPassword();
             // read it back to check success
            List<User> users = [SELECT SSO_question__c,SSO_answer__c,MO2B_OptIn__c,MO2B_ShareDetails__c FROM User WHERE Id = :u.Id];
            system.assert(users != null);
            system.assert(users.size() == 1);

            // try the goback
            PageReference pr1 = con.goBack();
            system.assert(pr1 != null);
        }
    }


    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
    private static void createData()
    {
        SSO_Stock_Questions__c q1 = new SSO_Stock_Questions__c(Name = 'Q1', Question__c = 'What is the capital of Outer Mongolia?', active__c = true, ranking__c = 1);
        SSO_Stock_Questions__c q2 = new SSO_Stock_Questions__c(Name = 'Q2', Question__c = 'How many socks in my sock drawer?', active__c = true, ranking__c = 2);
        SSO_Stock_Questions__c q3 = new SSO_Stock_Questions__c(Name = 'Q3', Question__c = 'Name of your favourite snail?', active__c = false, ranking__c = 3);
        insert q1;
        insert q2;
        insert q3;
    }

    
}