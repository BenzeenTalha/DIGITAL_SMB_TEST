/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
 */
public with sharing class MyO2BusinessProfilePageController
{
	//--------------------------------------------------------------------------
	// Private members
	//--------------------------------------------user------------------------------
	private Boolean isEdit = false;
	private List<SelectOption> stockQuestions;
	private static final String PROFILE_EMAIL_CHANGED_NOTIFICATION_EMAIL_TEMPLATE = 
		'MyO2BusinessProfileAndEmailChanged';
	private static final String PROFILE_CHANGED_NOTIFICATION_EMAIL_TEMPLATE = 
		'MyO2BusinessProfileChanged';
	private Boolean emailChanged = false;
	private MyO2BusinessUser businessUser;
	public String email { get; set; }
	public String question { get; set; }
	public String answer { get; set; }
	public String answerHint { get; set; }
	public String verifyPassword { get; set; }
	public String accountSegment { get; set; }
	
	public String userFNName { get; set; }
	public String userLNName { get; set; }
	public String userEmail { get; set; }
	public String userTitle { get; set; }
	
    //--------------------------------------------------------------------------
    // Constants - added for handling the scenario of unsuccessful login
    //--------------------------------------------------------------------------
  //  private final String LOCKED_EMAIL_TEMPLATE = 'MyO2BusinessLocked';
    //--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	// Retrieves user
	//--------------------------------------------------------------------------
	public MyO2BusinessUser getUser()
	{
		system.debug('businessUser---getUser--'+businessUser);
		return businessUser;
	}

	//--------------------------------------------------------------------------
	// Edit mode
	//--------------------------------------------------------------------------
	public Boolean getIsEdit()
	{
		return isEdit;
	}

	//--------------------------------------------------------------------------
	// Email changed
	//--------------------------------------------------------------------------
	public Boolean getEmailChanged()
	{
		return emailChanged;
	}

	//--------------------------------------------------------------------------
	// Security questions
	//--------------------------------------------------------------------------
	
	public List<SelectOption> getStockQuestions()
	{
		return MyO2BusinessSignOnUtils.getStockQuestions();
	}
	
	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessProfilePageController ()
	{
		businessUser = new MyO2BusinessUser();
		
				
		userFNName = businessUser.getFirstName();
	    userLNName = businessUser.getLastName();
	    userEmail = businessUser.getEmail();
	    userTitle = businessUser.getTitle();
		
		email = businessUser.getEmail();
		accountSegment = businessUser.getAccountSegment();
		system.debug('account segment is :' + accountSegment );
	     system.debug('userFNName------'+userFNName);
	}

	//--------------------------------------------------------------------------
	// Edit mode
	//--------------------------------------------------------------------------
	public void edit()
	{
		isEdit = true;
	}

	//--------------------------------------------------------------------------
	// Save profile info
	//--------------------------------------------------------------------------
	public PageReference save()
	{
		system.debug('businessUser---SAVE--'+businessUser);
		if (businessUser.getEmail() != email)
		{
			// change user username
			emailChanged = true;
		}

		try
		{
			//
			// Validate password
			//
			PageReference pr = Site.login(businessUser.getUsername(), verifyPassword, null);
			if (pr == null)
			{
				//
				// Unsuccessful login
				//
				system.debug('error message login failed');
				ApexPages.getMessages().clear();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,Label.MY_O2_BUSINESS_CUSTOMPASSWORD));
				
				//pr = onUnsuccessfulLogin();
				system.debug('after unsuccessful login called');
				return null;
				//return pr;
			}
			if ((question != null) && (question != '')) {
				businessUser.setSecurityQuestion(question);
				businessUser.setSecurityAnswer(answer);
				businessUser.setSecurityAnswerHint(answerHint);
			}
			
			if (emailChanged) 
			{
				businessUser.setNewEmail(email);
			}
			businessUser.save();

			//
			// Send emails
			//
			if (emailChanged == true) 
			{
				system.debug('email changed: ' + email);
				sendEmailConfirmationEmail();
				sendNotificationEmail(PROFILE_EMAIL_CHANGED_NOTIFICATION_EMAIL_TEMPLATE);
			}
			else
			{
				sendNotificationEmail(PROFILE_CHANGED_NOTIFICATION_EMAIL_TEMPLATE);
			}

			isEdit = false;
			system.debug('End-----');
			return Page.MyO2BusinessProfileChanged;
		}
		catch(DmlException e)
		{
			system.debug('Exception e-in ProfilePageController----'+e.getMessage());
			ApexPages.addMessages(e);
			isEdit = false;
			//
			// Renew user info
			//
			system.debug('after adding page message in ProfilePageController');
			businessUser = new MyO2BusinessUser();
			return null;
		}
	}

	//--------------------------------------------------------------------------
	// Cancel edit process
	//--------------------------------------------------------------------------
	public void cancel()
	{
		isEdit = false;
	}

	//--------------------------------------------------------------------------
	// Send notification email
	//--------------------------------------------------------------------------
	private void sendNotificationEmail(String emailTemplate)
	{
		MyO2BusinessSignOnUtils.sendEmail(
				UserInfo.getUserId(),
				emailTemplate);  
	}

	//--------------------------------------------------------------------------
	// Send email confirmation email
	//--------------------------------------------------------------------------
	private void sendEmailConfirmationEmail()
	{
		MyO2BusinessSignOnUtils.sendEmailToAddress(
				UserInfo.getUserId(),
				new MyO2BusinessEmailConfirmationTemplate(),
				email);
	}
	
		
	//--------------------------------------------------------------------------
    // Added for handling Unsuccessful login 
    //--------------------------------------------------------------------------
    /*
    private PageReference onUnsuccessfulLogin(){
        PageReference ref = null;
        if (businessUser != null)
        {
        	system.debug('businessUser------------------'+businessUser);
            MyO2BusinessUser.LoginStatus loginStatus = businessUser.getLoginStatus();
            //
            // If user locked redirect to locked page
            //
            system.debug('loginStatus---'+loginStatus);
            system.debug('loginStatus.isLocked()---'+loginStatus.isLocked());
            if (loginStatus.isLocked())
            {
                system.debug('login: user is locked&&&');
                ref = Page.MyO2BusinessLocked;
            }
            //
            // If user is locked for a first time send email
            //
            if (loginStatus.isFirstTimeLocked())
            {
                system.debug('login: user is first time locked&&&&&&');
                MyO2BusinessSignOnUtils.sendEmail
                (
                    businessUser.getUserId(),
                    LOCKED_EMAIL_TEMPLATE
                );
                system.debug('email sent----');
            }
        }
        system.debug('ref----'+ref);
        return ref;
    }
    */	
}