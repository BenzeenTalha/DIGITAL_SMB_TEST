//------------------------------------------------------------------------------
// An apex page controller that exposes the site login functionality
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessLoginController
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	private final String LOCKED_EMAIL_TEMPLATE = 'MyO2BusinessLocked';
	//--------------------------------------------------------------------------
	// Private members
	//--------------------------------------------------------------------------
	private MyO2BusinessUser businessUser;

	private MyO2BusinessUser businessUser1;

	//--------------------------------------------------------------------------
	// Getters / setters
	//--------------------------------------------------------------------------
	public String username { get; set; }
	public String password { get; set; }
	public String autologin { get; set; }
	public String sessionTimeout { get; set; }
	public String inactive { get; set; }

	public String startUrl
	{
		get
		{
			if (isNull(startUrl))
			{
				startUrl= ApexPages.currentPage().getParameters().get('startUrl');
				system.debug('startUrl---->>'+startUrl);
			}
			return startUrl;
		}
		set;
	}

	//--------------------------------------------------------------------------
	// Empty constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessLoginController () {}

	//--------------------------------------------------------------------------
	// Login Action
	//--------------------------------------------------------------------------
	public PageReference login()
	{
		PageReference ref = null;
		try
		{

			businessUser = new MyO2BusinessUser(username);
			system.debug('login method- businessUser --->'+businessUser);
			// If user is not activated redirect to not activated page

			if (businessUser.isActivationPending())
			{
				system.debug('login: activation pending');
				ref = Page.MyO2BusinessNotActivated;
			}
			//
			// If user is active login to MyO2Business portal
			//
			else if (businessUser.isActive())
			{
				system.debug('login: user active');

				ref = Site.login(username + MyO2BusinessCreateUser.USERNAME_SUFFIX, password, getURL());

				system.debug('reference is :' + ref);
				system.debug('get url is :' + getURL());
				if(ref == null){
					// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Username not crrct.....'));
				}
			}
			//
			// User is deactivated
			//
			else
			{
				system.debug('login: user not active');
				//
				// TODO: Maybe for phase 3
				//
				ApexPages.addMessage
				(
						new ApexPages.Message
						(
								ApexPages.Severity.Info,
								'User is deactivated'
						)
				);
			}
		}
		catch (Exception e)
		{
			//
			// Username doesn't exist
			//
			system.debug('login: username doesn\'t exist');
			system.debug('e getmessage--login page----'+e.getMessage());
			businessUser = null;
			ref = Site.login(username + MyO2BusinessCreateUser.USERNAME_SUFFIX, password, getURL());

		}
		//
		// Unsuccessful login
		//
		if (ref == null)
		{
			system.debug('login: unsuccessful login');
			(
					new ApexPages.Message
					(
							ApexPages.Severity.Info,
							'Username is wrong.'
					)
			);
			ref = onUnsuccessfulLogin();
		}
		return ref;
	}

	//--------------------------------------------------------------------------
	// Redirecting for login page
	//  1. If user is logged in than redirect to home page
	//  2. Else stay on the login page
	//--------------------------------------------------------------------------
	public PageReference redirect()
	{
		PageReference ref = null;
		//
		// Page parameters
		//
		username = ApexPages.currentPage().getParameters().get('username');
		password = ApexPages.currentPage().getParameters().get('password');
		autologin = ApexPages.currentPage().getParameters().get('autologin');
		sessionTimeout = ApexPages.currentPage().getParameters().get('sessionTimeout');
		inactive = ApexPages.currentPage().getParameters().get('inactive');
		System.debug('redirect - username = ' + username);
		System.debug('redirect - business username = ' + businessUser);
		//
		// If user is logged in redirect to startUrl or homepage
		//
		if (MyO2BusinessSignOnUtils.authorize())
		{
			system.debug('redirect: already logged in');
			system.debug('get url:' + getURL());
			ref = new PageReference(getURL());
			ref.setRedirect(true);
		}
		//
		// If autologin is set login immediately
		//
		if (autologin == '1')
		{
			system.debug('redirect: autologin');
			return login();
		}
		
		// User is inactive
		if (inactive == 'true') {
			ApexPages.addMessage (
				new ApexPages.Message (
					ApexPages.Severity.Info,
					Label.MY_O2_BUSINESS_INACTIVE_USER
				)
			);
			return ref;
		}
		//
		// Session timeout
		//
		if (sessionTimeout == 'true')
		{

			ApexPages.addMessage
			(
					new ApexPages.Message
					(
							ApexPages.Severity.Info,
							'For security reasons, your session has timed out after 15 minutes of inactivity.'
					)
			);
			ApexPages.addMessage
			(
					new ApexPages.Message
					(
							ApexPages.Severity.Info,
							'Please login to your account again'
					)
			);

		} 



		return ref;
	}

	//--------------------------------------------------------------------------
	// Send new activation mail for user
	//--------------------------------------------------------------------------
	public PageReference resendActivationEmail()
	{
		PageReference pref = null;
		//
		// If user exist
		//
		try
		{
			MyO2BusinessUser user = new MyO2BusinessUser(username);
			//
			// If is in activation pending state
			//
			if (user.isActivationPending())
			{
				MyO2BusinessCreateUser.sendNewUserEmail(user.getUser());
				pref = Page.MyO2BusinessRegisterConfirm;
			}
			//
			// If user is not in activation pedning state
			//
			else
			{
				ApexPages.addMessage
				(
						new ApexPages.Message
						(
								ApexPages.Severity.Error,
								Label.MO2B_COULD_NOT_SEND_ACTIVATION_EMAIL
						)
				);
			}
		}
		//
		// If user doesn't exist
		//
		catch (Exception e)
		{
			ApexPages.addMessage
			(
					new ApexPages.Message
					(
							ApexPages.Severity.Error,
							Label.MO2B_COULD_NOT_SEND_ACTIVATION_EMAIL
					)
			);
		}
		return pref;
	}

	//--------------------------------------------------------------------------
	// Checks if sting exist and if it is not empty
	//--------------------------------------------------------------------------
	private static Boolean isNull(String value)
	{
		if (value == null || value.trim().equals(''))
		{
			return true;
		}
		return false;
	}

	//--------------------------------------------------------------------------
	// Retrieves url to go after login
	//--------------------------------------------------------------------------
	private String getURL()
	{
		String url;
		system.debug('username is :' + username);
		System.debug('get username is: ' + ApexPages.currentPage().getParameters().get('username'));
		system.debug('getURL() starturl--->>'+startUrl);
		if (!isNull(startUrl))
		{
			system.debug('Inside if not null condition');
			url = startUrl;
			system.debug('start url is :' + startUrl);
		}
		else
		{
			if (username==null){
				businessUser = new MyO2BusinessUser();
			}
			if(businessUser != null && businessUser.getAccountSegment().contains(Label.SMB_ACCOUNT_SEGMENT)){
				url = Page.smbhome.getURL();
				//url= Page.testPageRedirect.getURL();

			}else if (businessUser != null && businessUser.getAccountSegment().contains(Label.ENTERPRISE_ACCOUNT_SEGMENT)){ 
				url = Page.MyO2BusinessHome.getURL();
			} else {
				url = Page.MyO2BusinessLogin.getURL();

			}

		}
		System.debug('get URL - url = '+ url);
		return url;
	}

	//--------------------------------------------------------------------------
	// Unsuccessful login
	//--------------------------------------------------------------------------
	private PageReference onUnsuccessfulLogin()
	{
		PageReference ref = null;
		if (businessUser != null)
		{
			MyO2BusinessUser.LoginStatus loginStatus = businessUser.getLoginStatus();
			//
			// If user locked redirect to locked page
			//
			if (loginStatus.isLocked())
			{
				system.debug('login: user is locked');
				ref = Page.MyO2BusinessLocked;
			}
			//
			// If user is locked for a first time send email
			//
			if (loginStatus.isFirstTimeLocked())
			{
				system.debug('login: user is first time locked');
				MyO2BusinessSignOnUtils.sendEmail
				(
						businessUser.getUserId(),
						LOCKED_EMAIL_TEMPLATE
				);
			}
		}
		return ref;
	}
}