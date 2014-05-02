//------------------------------------------------------------------------------
// Controller for user activation process in Enterprise Business Protral
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessActivationController implements MyO2BusinessUserInterface
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	static final String WELCOME_EMAIL_TEMPLATE = 'MyO2BusinessRegistrationComplete';

	//--------------------------------------------------------------------------
	// Members
	//--------------------------------------------------------------------------
	public String businessMobile { get; private set; }
	public String fullName { get; private set; }
	public String phoneNumber { get; private set; }
	public String email { get; private set; }

	public String newPassword { get; set; }
	public String verifyNewPassword { get; set; }
	public String question { get; set; }
	public String answer { get; set; }
	public String answerHint { get; set; }
	public String userName {get;set;}
	public String accountSegment{get;set;}

	//--------------------------------------------------------------------------
	// Private members
	//--------------------------------------------------------------------------
	MyO2BusinessUser businessUser;
	List<SelectOption> stockQuestions;

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessActivationController()
	{
		businessUser = new MyO2BusinessUser();
		//
		// Activation Info data
		//
		businessMobile = businessUser.getMobilePhone();
		fullName = UserInfo.getName();
		phoneNumber = businessUser.getPhone();
		email = businessUser.getEmail();
		userName=businessUser.getUserName();
		accountSegment = businessUser.getAccountSegment();
	}

	//--------------------------------------------------------------------------
	// Get available questions
	//--------------------------------------------------------------------------
	public List<SelectOption> getStockQuestions()
	{
		return MyO2BusinessSignOnUtils.getStockQuestions();
	}

	//--------------------------------------------------------------------------
	// Set password and sercurity question and answer
	//--------------------------------------------------------------------------
	public PageReference setSecurityQAAndPassword()
	{
		PageReference pr = null;
		try
		{
			//
			// Check if first time activation and activate user
			//
			businessUser.setSecurityQuestion(question);
			businessUser.setSecurityAnswer(answer);
			businessUser.setSecurityAnswerHint(answerHint);
			businessUser.activateUser(newPassword);

			pr = Page.MyO2BusinessActivationSummary;

			sendWelcomeEmail();
		}
		catch(System.InvalidParameterValueException e)
		{
			//
			// Repeated password
			//
			String exceptionMessage = MyO2BusinessSignOnUtils.prepareExceptionMessage(e);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, exceptionMessage));
		}
		catch(MyO2BusinessUserException e)
		{
			//
			// Security answer is wrong
			//
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, e.getMessage()));
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
		return pr;
	}

	//--------------------------------------------------------------------------
	// Sends welcome mail template
	//--------------------------------------------------------------------------
	private void sendWelcomeEmail()
	{
		MyO2BusinessSignOnUtils.sendEmail
		(
			UserInfo.getUserId(),
			WELCOME_EMAIL_TEMPLATE
		);
	}

	//--------------------------------------------------------------------------
	// Returns to login page and logout
	//--------------------------------------------------------------------------
	public PageReference gotoInfo()
	{
		return Page.MyO2BusinessActivationInfo;
		
	}

	//--------------------------------------------------------------------------
	// Goto MyO2BusinessActivationConfiguration page
	//--------------------------------------------------------------------------
	public PageReference gotoConfiguration()
	{
		return Page.MyO2BusinessActivationConfiguration;
	}

	//--------------------------------------------------------------------------
	// Redirect to change password page if user account is activated
	//--------------------------------------------------------------------------
	public PageReference redirect()
	{
		PageReference pr = null;
		if (!businessUser.isActivationPending())
		{
			//
			// Redirect to MyO2BusinessChangePassword page
			//
			pr = Page.MyO2BusinessChangePassword;
		}
		return pr;
	}

	//--------------------------------------------------------------------------
	// Redirect configuration page
	//--------------------------------------------------------------------------
	public PageReference redirectConfiguration()
	{
		PageReference pr = null;
		if (!businessUser.getIsActivationCodeValid())
		{
			//
			// Redirect to MyO2BusinessActivationInfo page
			//
			pr = Page.MyO2BusinessActivationInfo;
		}
		return pr;
	}

	//--------------------------------------------------------------------------
	// Get business user
	//--------------------------------------------------------------------------
	public MyO2BusinessUser getBusinessUser()
	{
		return businessUser;
	}

}