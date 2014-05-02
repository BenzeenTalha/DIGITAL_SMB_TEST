//------------------------------------------------------------------------------
// An apex page controller that exposes the site forgot password functionality
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessForgotPasswordController implements MyO2BusinessUserInterface
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	static final String FORGOT_PASSWORD_EMAIL_TEMPLATE = 'MyO2BusinessRequestSecurityQuestion';
	static final String EMAIL_ERROR_GENERAL = Label.MO2B_UNABLE_TOSEND_EMAIL;
	static final String EMAIL_ERROR_UNKNOWN = Label.MO2B_UNKNOWN_EMAIL_ADDRESS;
	static final String EMAIL_NO_SECRET = Label.MO2B_NO_SECRET;

	//--------------------------------------------------------------------------
	// Geters / setters
	//--------------------------------------------------------------------------
	public String username { get; set; }

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessForgotPasswordController()
	{
	}

	//--------------------------------------------------------------------------
	// This can be part of controller extension
	//--------------------------------------------------------------------------
	//--------------------------------------------------------------------------
	// Send email with security question answer link
	//--------------------------------------------------------------------------
	public PageReference requestSecretQuestion()
	{
		PageReference pr = null;
		try
		{
			system.debug('WHERE username=' + username);
			MyO2BusinessUser businessUser = new MyO2BusinessUser(username);
			system.debug('user: ' + businessUser);

			if (String.isEmpty(businessUser.getSecurityQuestion())
				|| String.isEmpty(businessUser.getSecurityAnswer()))
			{
				//
				// This shouldn't happen
				//
				showErrorMsg(EMAIL_NO_SECRET);
			}
			else
			{
				//
				// Send email with security QA link
				//
				MyO2BusinessSignOnUtils.sendEmail(
						businessUser.getUserId(),
						FORGOT_PASSWORD_EMAIL_TEMPLATE);
				pr = Page.MyO2BusinessForgotPasswordConfirm;
			}

		}
		catch (System.QueryException qe)
		{
			showErrorMsg(EMAIL_ERROR_UNKNOWN);
		}
		catch (Exception ex)
		{
			String msg = EMAIL_ERROR_GENERAL
				+ ex.getTypeName() + ': ' + ex.getMessage();
			showErrorMsg(msg);
		}
		return pr;
	}

	//--------------------------------------------------------------------------
	// Shows error message in the page
	//--------------------------------------------------------------------------
	private static void showErrorMsg(String msg)
	{
		system.debug(msg);
		ApexPages.Message myMsg =
			new ApexPages.Message(ApexPages.Severity.ERROR, msg);
		ApexPages.addMessage(myMsg);
	}

	//--------------------------------------------------------------------------
	// Get business user
	//--------------------------------------------------------------------------
	public MyO2BusinessUser getBusinessUser()
	{
		MyO2BusinessUser returnValue = null;
		try
		{
			system.debug('Username: ' + username);
			returnValue = new MyO2BusinessUser(username);
		}
		catch (Exception e)
		{
		}
		return returnValue;
	}
}