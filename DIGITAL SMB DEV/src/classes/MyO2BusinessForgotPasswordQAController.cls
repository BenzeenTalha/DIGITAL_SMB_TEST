//------------------------------------------------------------------------------
// An apex page controller for sending security question / answer link to
// change password.
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessForgotPasswordQAController
{
	//--------------------------------------------------------------------------
	// Getters setteers
	//--------------------------------------------------------------------------
	public Boolean isValidToken {get; private set;}
	public String question {get; set;}
	public String answer {get; set;}
	public MyO2BusinessUser businessUser;

	//--------------------------------------------------------------------------
	// Private members
	//--------------------------------------------------------------------------
	private MyO2BusinessToken businessToken;

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessForgotPasswordQAController()
	{
		isValidToken = false;
		String token = ApexPages.currentPage().getParameters().get('tk');
		businessToken = new MyO2BusinessToken(token);
	}

	//--------------------------------------------------------------------------
	// Authorize token
	//   1. If token valid stay on the same page
	//   2. If token expired redirect to expired page
	//   3. Else show error that token is invalid
	//--------------------------------------------------------------------------
	public PageReference authorize()
	{
		PageReference pr = null;
		//
		// If token is valid
		//
		if (businessToken.validate(MyO2BusinessToken.FORGOT_PASSWORD))
		{
			//
			// Token is valid goto to forgot password security question
			// answer page
			//
			system.debug('token is valid');
			businessUser = businessToken.getUser();
			pr = Page.MyO2BusinessForgotPasswordQA;
			isValidToken = true;
		}
		else if (businessToken.validateUserAndOrg()
				&& businessToken.validateSingleUse())
		{
			//
			// Token is expired goto to forgot password expired page
			//
			businessUser = businessToken.getUser();
			system.debug('token is expired');
			pr = Page.MyO2BusinessForgotPasswordExpired;
		}
		else
		{
			//
			// Token is not valid show error message
			//
			system.debug('token is invalid');
			ApexPages.addMessage(
					new ApexPages.Message(
							ApexPages.Severity.ERROR,
							Label.MO2B_TOKEN_INVALID));
		}

		return pr;
	}

	//--------------------------------------------------------------------------
	// Retrieve username
	//--------------------------------------------------------------------------
	public String getUserName()
	{
		String userName = '';
		if (businessUser != null)
		{
			userName = businessUser.getUserName();
		}
		return userName;
	}

	//--------------------------------------------------------------------------
	// Retrieve security question
	//--------------------------------------------------------------------------
	public String getSecurityQuestion()
	{
		String securityQuestion = '';
		if (businessUser != null)
		{
			securityQuestion = businessUser.getSecurityQuestion();
		}
		return securityQuestion;
	}

	//--------------------------------------------------------------------------
	// Retrieve security answer help
	//--------------------------------------------------------------------------
	public String getSecurityAnswerHint()
	{
		String securityAnswerHint = '';
		if (businessUser != null)
		{
			securityAnswerHint = businessUser.getSecurityAnswerHint();
		}
		return securityAnswerHint;
	}

	//--------------------------------------------------------------------------
	// Is answer correct
	//--------------------------------------------------------------------------
	private Boolean isAnswerCorrect()
	{
		Boolean matches =  false;
		try
		{
			//
			// Remove white space
			//
			String userAnswer = answer.replaceAll('\\s+', '');
			String correctAnswer = businessUser.getSecurityAnswer().replaceAll('\\s+', '');

			matches = userAnswer.equalsIgnoreCase(correctAnswer);
			if (matches)
			{

				matches = true;
				//
				// Correct answer
				//
				/**ApexPages.addmessage(
						new ApexPages.message(
							ApexPages.severity.WARNING,
							Label.MO2B_PROBLEM_WITH_USER)); */
			} 
			else if(userAnswer == ''){

				ApexPages.addmessage(
						new ApexPages.message(
								ApexPages.severity.WARNING,
						'Please provide the Security Answer'));

			}else{

				//
				// Incorrect answer
				//
				ApexPages.addmessage(
						new ApexPages.message(
								ApexPages.severity.WARNING,
								Label.MO2B_ANSWER_NOT_MATCH));
			}

		}
		catch (Exception e)
		{
			//
			// On error
			//
			ApexPages.addmessage(
					new ApexPages.message(
							ApexPages.severity.ERROR,
							Label.MO2B_COULD_NOT_CHECK_ANSWER + ' ' + e.getMessage()));
			System.debug('**Error message'+e.getMessage());
		}
		return matches;
	}

	//--------------------------------------------------------------------------
	// Check answer
	//--------------------------------------------------------------------------
	public PageReference checkAnswer()
	{
		PageReference pr = ApexPages.currentPage();
		if (isAnswerCorrect())
		{
			//
			// Set forgot password to true in User record
			// This will change change password screen layout
			// without old password field
			//
			businessUser.setIsForgotPassword(true);
			businessUser.save();
			if (!Test.isRunningTest())
			{
				System.ResetPasswordResult rpr = null;
				User currUser = [SELECT Id, Name, IsActive FROM User where id= :businessUser.getUserId()];
				
				if (!currUser.IsActive){
					System.debug('check answer - user is inactive');
				    return new PageReference(Label.MY_O2_BUSINESS_DEFAULT_REDIRECT_ADDRESS+'?inactive=true');
					
				} 
				rpr = system.resetPassword(businessUser.getUserId(), false);
				pr = Site.login(
						businessUser.getUserName(),
						rpr.getPassword(),
						Page.MyO2BusinessHome.getUrl()); 

			}
		}
		return pr;
	}
}