@isTest
private class TestMyO2BusinessActivationController
{
  
private static testMethod void testMyO2BusinessActivationController()
    {
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact('frank', 'smith', 'fs@fs.fs.edu');

        //test.setCurrentPage(Page.MyO2BusinessLogin);
        MyO2BusinessActivationController con = new MyO2BusinessActivationController();
        
        System.runAs(u)
        {
          try{
             con.question = 'Test Question';
             con.answer = 'Test Answer';
             con.answerHint = 'Test Hint';
             con.newPassword = 'Passwrd';
             con.setSecurityQAAndPassword();
             
             con.gotoInfo();
             con.gotoConfiguration();
            
            }catch(Exception e){
            }
        }
    }

   private static testMethod void testRedirect()
    {
         User u = TestMyO2BusinessUtility.createPortalUserAccountContact('frank', 'smith', 'fs@fs.fs.edu');

        //test.setCurrentPage(Page.MyO2BusinessLogin);
        MyO2BusinessActivationController con = new MyO2BusinessActivationController();
        
        System.runAs(u)
        {
          try{
            test.setCurrentPage(Page.MyO2BusinessActivationConfiguration);
           // ApexPages.currentPage().getParameters().put('username',USERNAME_1);
            //ApexPages.currentPage().getParameters().put('password',PASSWORD_1);
            //ApexPages.currentPage().getParameters().put('autologin',RELAY_STATE_1);
           // ApexPages.currentPage().getParameters().put('startUrl',START_URL_1);   
            MyO2BusinessActivationController controller = new MyO2BusinessActivationController ();
            
            //controller.username = TEST_DATA;    
               
            //controller.password = TEST_DATA;      
                  
            //controller.= TEST_DATA;  
              
               
            //controller.= TEST_DATA;    
           
            controller.getBusinessUser();
            PageReference pr = controller.redirect();
            PageReference pr1 = controller.redirectConfiguration();
            
         }catch(exception e){
         }
         }
    }
    
    //---------------------------------------------------
    //   MyO2BusinessActivationCodeExtension Test Class
    
    //----------------------------------------------------
    
    
    static testmethod void testMyO2BusinessActivationCodeExtension() {
       
       Test.startTest();
       MyO2BusinessActivationController con = new MyO2BusinessActivationController ();
       
       
       MyO2BusinessActivationCodeExtension actExtCon = new MyO2BusinessActivationCodeExtension(con);
       Test.stopTest();
    
    }
    
     static testmethod void testMyO2BusinessActivationCodeExtension2() {
       
       Test.startTest();
       MyO2BusinessForgotPasswordController con = new MyO2BusinessForgotPasswordController ();
       MyO2BusinessActivationCodeExtension actExtCon = new MyO2BusinessActivationCodeExtension(con);
       actExtCon.sendActivationCode();
       actExtCon.sendForgotPasswordCode();
       Test.stopTest();
    
    }
    
    
      static testmethod void testsendSMS() {
       User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Jose', 'Garcia', 'jg@gose.jose.edu');
       
       System.runAs(u)
        {
       
           PageReference pr1 = Page.MyO2BusinessForgotPassword;
           Test.setCurrentPage(pr1);
           MyO2BusinessForgotPasswordController con = new MyO2BusinessForgotPasswordController ();
           con.username = u.email;
           con.getBusinessUser();
           MyO2BusinessActivationCodeExtension actExtCon = new MyO2BusinessActivationCodeExtension(con);
           actExtCon.sendForgotPasswordCode();
      }
    
    }
    
      
      static testmethod void testvalidateActivationCode() {
       User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Jose', 'Garcia', 'jg@gose.jose.edu');
       
       System.runAs(u)
        {
       
           PageReference pr1 = Page.MyO2BusinessForgotPassword;
           Test.setCurrentPage(pr1);
           MyO2BusinessForgotPasswordController con = new MyO2BusinessForgotPasswordController ();
           con.username = u.email;
           con.getBusinessUser();
           MyO2BusinessActivationCodeExtension actExtCon = new MyO2BusinessActivationCodeExtension(con);
           actExtCon.validateActivationCode();
      }
    
    } 

}