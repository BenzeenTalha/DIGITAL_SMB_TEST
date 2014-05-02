@isTest
private class TestMyO2BusinessUserUnlock {
	
  /*
      * Test unlocking a user *
      Given I am on the MyO2BusinessUserUnlock page which is a public Sites page
      When I enter a username and the users last login attempt was not successful
      Then the users password should be reset and redirected to the standard forgot password page     
  */
  @isTest static void testUnlockUser() {
      // Set the user
      PageReference ref = null;
      User u = TestMyO2BusinessUtility.createPortalUserAccountContact( 'fn', 'ln', 'test123@test123.com');
      // lockout the user
      for(integer i=0;i<10;i++) {
          Site.login(u.username, 'incorrectPassw046', null);
      }
      System.runAs(u) {
          MyO2BusinessUserUnlock uul = new MyO2BusinessUserUnlock();
          uul.username = u.username;
          ref = uul.resetPassword();
          System.assertEquals(false, uul.isError); 
      }
      // Unfortunately it is currently not possible to force an entry to the login history in unit testing to follow the unlock path
      // The unit testing assertions options are very limited, as it doesnt write to the login history
      System.assertNotEquals(null, ref);        
  }

  /*
      * Test redirect for user who is not locked *
      Given I am on the MyO2BusinessUserUnlock page which is a public Sites page
      When I enter a username and the users last login attempt was successful
      Then the users password should not be reset and should be redirected to the standard forgot password page     
  */
  @isTest static void testUnlockUserWhoIsNotLocked() {
      // Set the user
      PageReference ref = null;
      Id profileId = [ Select id from Profile where name = 'Standard User'].id;
      User u = new User( email='test-user@fakeemail.com', profileid = profileId, 
              UserName='test-user@fakeemail.o2.com', alias='tus23', CommunityNickName='tuser1', 
              TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
              LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' );
      insert u;   
      System.runAs(u) {
          MyO2BusinessUserUnlock uul = new MyO2BusinessUserUnlock();
          uul.username = u.username;
          ref = uul.resetPassword();
          System.assertEquals(false, uul.isError); 
      }
      System.assertNotEquals(null, ref);        
  }

  /*
      * Test Unlocking a non existant user *
      Given I am on the MyO2BusinessUserUnlock page which is a public Sites page
      When I enter a username and the user does not exist in the org
      Then an error is shown     
  */    
  @isTest static void testResetPasswordError() {
      PageReference ref = null;
      MyO2BusinessUserUnlock uul = new MyO2BusinessUserUnlock();
      uul.username = 'nonExistantUser@123943.com';
      ref = uul.resetPassword();
      System.assertEquals(true, uul.isError);   
      System.assertEquals(null, ref);      
  }   
	
}