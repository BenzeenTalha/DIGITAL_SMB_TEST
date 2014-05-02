@isTest
public with sharing class TestMyO2BusinessLoginController {
	static String username = 'test@salesforce.com'; 
	static String password = '123456';
	
	public static testMethod void testSiteLoginController()
	{
		MyO2BusinessLoginController controller = new MyO2BusinessLoginController();
		controller.username = username;
		controller.password = password;
		System.assertEquals(null, controller.login());
		/*List<User> existingUsernameList = [Select Username From User where IsActive =true and IsPortalEnabled=true limit 1];
		if (existingUsernameList.size() > 0) {
			controller.username = existingUsernameList[0].Username;
			System.debug('test site login existing username: ' + controller.username);
			System.assertEquals(controller.login(),null);
		}*/
    }
    
    public static testMethod void testRedirect()
    {
    	ApexPages.currentPage().getParameters().put('username',username);
    	ApexPages.currentPage().getParameters().put('password',password);
    	MyO2BusinessLoginController controller = new MyO2BusinessLoginController();
    	
    	ApexPages.currentPage().getParameters().put('autologin','1');
    	ApexPages.currentPage().getParameters().put('sessionTimeout','false');
    	
    	System.assertEquals(null, controller.redirect());
    	
    	ApexPages.currentPage().getParameters().put('autologin','0');
    	ApexPages.currentPage().getParameters().put('sessionTimeout','true');
    	
    	System.assertEquals(null, controller.redirect());

    }
    
    public static testMethod void testResendActivationEmail()
    {
		MyO2BusinessLoginController controller = new MyO2BusinessLoginController();
		controller.username = username;
		System.assertEquals(controller.resendActivationEmail(),null);
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
		System.assertEquals(pageMessages.size(), 1);
		String detail = pageMessages[0].getDetail();
		String summary = pageMessages[0].getSummary();
		System.assertEquals(Label.MO2B_COULD_NOT_SEND_ACTIVATION_EMAIL, detail);
		System.assertEquals(Label.MO2B_COULD_NOT_SEND_ACTIVATION_EMAIL, summary);
    }
}