//------------------------------------------------------------------------------
// Email confirmation controller
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessEmailConfirmationController 
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	private static String EMAIL_CONFIRMED_EMAIL_TEMPLATE = 'MyO2BusinessEmailConfirmed';

	//--------------------------------------------------------------------------
	// Private members
	//--------------------------------------------------------------------------
	private String token;
	private MyO2BusinessToken businessToken;
	public String accountSegment { get; set; }

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessEmailConfirmationController()
	{
		token = ApexPages.currentPage().getParameters().get('tk');
		businessToken = new MyO2BusinessToken(token);
		accountSegment = businessToken.getUser().getAccountSegment();
		system.debug('Account segment is :' + accountSegment);
	}

	//--------------------------------------------------------------------------
	// Authorize
	//--------------------------------------------------------------------------
	public PageReference authorize()
	{
		PageReference pr = null;

		if (businessToken.validate(MyO2BusinessToken.EMAIL_CONFIRMATION)
				&& businessToken.getUser().getNewEmail() != null)
		{
			//
			// Update mail, username and send confirmation email
			//
			system.debug('token is valid');
			MyO2BusinessUser businessUser = businessToken.getUser();
			businessUser.setEmail(businessUser.getNewEmail());
			businessUser.setNewEmail(null);
			businessUser.setUserName
				(
				 businessUser.getEmail() + MyO2BusinessCreateUser.USERNAME_SUFFIX
				);
				system.debug('new email is is :' +  businessUser.getEmail());
			system.debug('new user name is :' +  businessUser.getEmail() + MyO2BusinessCreateUser.USERNAME_SUFFIX);
			businessUser.save();
			sendConfirmationEmail();
			pr = Page.MyO2BusinessEmailConfirmed;
		}
		else if (businessToken.validateUserAndOrg()				
				&& businessToken.validateSingleUse())
		{
			//
			// Token is expired
			//
			system.debug('token is expired');
			pr = Page.MyO2BusinessEmailConfirmationExpired;
		}
		else
		{
			//
			// Token is not valid and show error message
			//
			system.debug('token is invalid');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MO2B_TOKEN_INVALID));
		}
		return pr;
	}

	//--------------------------------------------------------------------------
	// Send confirmation email
	//--------------------------------------------------------------------------
	private void sendConfirmationEmail()
	{
		MyO2BusinessSignOnUtils.sendEmail
			(
				businessToken.getUser().getUserId(),
				EMAIL_CONFIRMED_EMAIL_TEMPLATE
			);
	}
}