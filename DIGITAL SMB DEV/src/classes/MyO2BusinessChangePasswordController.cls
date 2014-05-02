//------------------------------------------------------------------------------
// An apex page controller that exposes the change password functionality
//------------------------------------------------------------------------------
public class MyO2BusinessChangePasswordController
{

	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	static final String PASSWORD_CHANGED_EMAIL_TEMPLATE = 'MyO2BusinessPasswordWasChanged';

	//--------------------------------------------------------------------------
	// Getters / setters
	//--------------------------------------------------------------------------
	public String oldPassword { get; set; }
	public String newPassword { get; set; }
	public String verifyNewPassword { get; set; }
	public MyO2BusinessUser businessUser { get; set; }

	//--------------------------------------------------------------------------
	// Private members
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessChangePasswordController()
	{
		oldPassword = '';
		businessUser = new MyO2BusinessUser();
	}

	//--------------------------------------------------------------------------
	// Set password page
	//--------------------------------------------------------------------------
	public PageReference setNewPassword()
	{
		String exceptionMessage = '';
		PageReference pr = null;
		
		try
		{
			
			// case of Change Password - UP
			if (getIsForgotPassword())
			{
				System.setPassword(businessUser.getUserId(), newPassword);
				businessUser.setIsForgotPassword(false);
				businessUser.save();
				
				// On sucessful password change, Confirmation page is displayed and email is sent to user
				pr = Page.MyO2BusinessPasswordChanged;
				sendPasswordChangedEmail();
			}
			
			// case of password change when user clicks on "Change Password" from Header
 			else
			{
				pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
				system.debug('else part pr---'+pr);
				
				// Check for any errors else show the confirmation page
				if(pr!= null){
		
					pr = Page.MyO2BusinessPasswordChanged;
					sendPasswordChangedEmail();
				}
			}
			
		}
		catch(Exception ex)
		{
			exceptionMessage = '';
			exceptionMessage = MyO2BusinessSignOnUtils.prepareExceptionMessage(ex);
			system.debug('exceptionMessage-------'+exceptionMessage);
			ApexPages.addMessage(
					new ApexPages.Message(ApexPages.Severity.Error, exceptionMessage));
		}
		return pr;
	}

	//--------------------------------------------------------------------------
	// Send password changed email
	//--------------------------------------------------------------------------
	private void sendPasswordChangedEmail()
	{
		MyO2BusinessSignOnUtils.sendEmail
		(
			UserInfo.getUserId(),
			PASSWORD_CHANGED_EMAIL_TEMPLATE
		);
	}

	//--------------------------------------------------------------------------
	// Cancel password change
	//--------------------------------------------------------------------------
	public PageReference goBack()
	{
		PageReference pr = null;
		String url = (String) ApexPages.currentPage().getParameters().get('retURL');
		String fromFrontdoor = (String) ApexPages.currentPage().getParameters().get('fromFrontdoor');
		String display = (String) ApexPages.currentPage().getParameters().get('display');
		system.debug('goBackL url: ' + url);
		system.debug('goBackL fromFrontdoor: ' + fromFrontdoor);
		system.debug('goBackL display: ' + display);
		if (display != null || fromFrontdoor != null || url == null)
		{
			//pr = Page.MyO2BusinessHome;
			
			if(businessUser.getAccountSegment()== Label.SMB_ACCOUNT_SEGMENT){
			pr = Page.smbhome;
		
			}
			else{
			
				pr = Page.MyO2BusinessHome;
			}
		}
		else
		{
			pr = new PageReference(url);
		} 
		
		
		return pr; 
	}

	//--------------------------------------------------------------------------
	// Redirect to user activation page if user account is not activated
	//--------------------------------------------------------------------------
	public PageReference redirect()
	{
		PageReference pr = null;
		//
		// If user activation pending redirect to activation page
		//
		if (businessUser.isActivationPending())
		{
			pr = Page.MyO2BusinessActivationInfo;
		}
		return pr;
	}

	//--------------------------------------------------------------------------
	// Get is forgot password
	//--------------------------------------------------------------------------
	public Boolean getIsForgotPassword()
	{
		return businessUser.getIsForgotPassword();
	}
}