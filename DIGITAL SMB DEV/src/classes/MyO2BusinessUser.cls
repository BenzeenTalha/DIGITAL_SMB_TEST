//------------------------------------------------------------------------------
// MyO2BusinessUser class for single sign on functionality
// Withour sharing because it needs to retrieve user data.
//------------------------------------------------------------------------------
public without sharing class MyO2BusinessUser
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	public static final String ACTIVATION_PENDING = 'Activation Pending';
	public static final String ACTIVE = 'Active';
	public static final String NUMBER_OF_ATTEMPTS = 'Number_Of_Attempts';
	public static final String LOCKOUT_PERIOD = 'Lockout_Period';

	//--------------------------------------------------------------------------
	// Private members
	//--------------------------------------------------------------------------
	private Boolean isActivationCodeValid = false;

	//--------------------------------------------------------------------------
	// Is activation code is valid
	//--------------------------------------------------------------------------
	public Boolean getIsActivationCodeValid()
	{
		return isActivationCodeValid;
	}

	//--------------------------------------------------------------------------
	// Checking of login status
	//--------------------------------------------------------------------------
	public without sharing class LoginStatus
	{
		//----------------------------------------------------------------------
		// Private members
		//----------------------------------------------------------------------
		private List<LoginHistory> loginHistoryList;

		//----------------------------------------------------------------------
		// Constructor
		//----------------------------------------------------------------------
		public LoginStatus(Id userId)
		{
			loginHistoryList =
				[
					SELECT UserId, Status, LoginTime
					FROM LoginHistory
					WHERE UserId = :userId
					ORDER BY LoginTime DESC
					LIMIT 20
				];
		}

		//----------------------------------------------------------------------
		// Is locked
		//----------------------------------------------------------------------
		public Boolean isLocked()
		{
			Boolean isLocked = false;
			if (isFirstTimeLocked()
				|| (loginHistoryList.size() > 0
					&& loginHistoryList[0].Status == 'Password Lockout'))
			{
				isLocked = true;
			}
			return isLocked;
		}

		//----------------------------------------------------------------------
		// Is locked for the first time
		// Login history shouldn't have two in a row password lockouts
		//----------------------------------------------------------------------
		public Boolean isFirstTimeLocked()
		{
			Boolean isFirstTimeLocked = false;
			//
			// Default value of attempts
			//
			Integer numberOfAttempts = getNumberOfAttempts();
			//
			// Count invalid password statuses in a row
			//
			Integer i = 0;
			for (i = 0; i < loginHistoryList.size(); i++)
			{
				if (loginHistoryList[i].Status != 'Invalid Password')
				{
					break;
				}
			}
			if (i > 0 && Math.mod(i, numberOfAttempts) == 0)
			{
				//
				// Multiple of NUMBER_OF_ATTEMPTS in a row
				//
				isFirstTimeLocked = true;
			}

			return isFirstTimeLocked;
		}

	}

	//--------------------------------------------------------------------------
	// Single sign on settings
	//--------------------------------------------------------------------------
	private static Integer getSSOSettings(String name)
	{
		Integer returnValue = null;
		SSOSettings__c ssoSettings = SSOSettings__c.getInstance(name);
		if (ssoSettings != null)
		{
			returnValue = Integer.valueOf(ssoSettings.Number__c);
			system.debug('SSO Settings ' + name + ': ' + returnValue);
		}
		return returnValue;
	}

	//----------------------------------------------------------------------
	// Number of attempts from custom setting
	//----------------------------------------------------------------------
	public static Integer getNumberOfAttempts()
	{
		Integer numberOfAttempts = getSSOSettings(NUMBER_OF_ATTEMPTS);
		if (numberOfAttempts == null)
		{
			//
			// Default value is three
			//
			numberOfAttempts = 3;
		}
		return numberOfAttempts;
	}

	//--------------------------------------------------------------------------
	// Lockout period form custom settings
	//--------------------------------------------------------------------------
	public static Integer getLockoutPeriod()
	{
		Integer lockoutPeriod = getSSOSettings(LOCKOUT_PERIOD);
		if (lockoutPeriod == null)
		{
			//
			// Default value is 15
			//
			lockoutPeriod = 15;
		}
		return lockoutPeriod;
	}

	//--------------------------------------------------------------------------
	// Login status
	//--------------------------------------------------------------------------
	public LoginStatus getLoginStatus()
	{
		return new LoginStatus(getUserId());
	}

	//--------------------------------------------------------------------------
	// Members
	//--------------------------------------------------------------------------
	private User myO2BusinessUser;

	//--------------------------------------------------------------------------
	// Getters / setters
	//--------------------------------------------------------------------------
	public User getUser()
	{
		return myO2BusinessUser;
	}

	//--------------------------------------------------------------------------
	// Get user id
	//--------------------------------------------------------------------------
	public Id getUserId()
	{
		return myO2BusinessUser.Id;
	}

	//--------------------------------------------------------------------------
	// Get username
	//--------------------------------------------------------------------------
	public String getUserName()
	{
		return myO2BusinessUser.UserName;
	}

	//--------------------------------------------------------------------------
	// Set username
	//--------------------------------------------------------------------------
	public void setUserName(String userName)
	{
		myO2BusinessUser.UserName = userName;
	}
	
	public String getUserProfile(){
		
		return myO2BusinessUser.ProfileId;
	
	}
	
	public void setUserprofile(String profileId){
		myO2BusinessUser.ProfileId = profileId;
	
	}

	//--------------------------------------------------------------------------
	// Get title
	//--------------------------------------------------------------------------
	public String getTitle()
	{
		return myO2BusinessUser.Title;
	}

	//--------------------------------------------------------------------------
	// Set title
	//--------------------------------------------------------------------------
	public void setTitle(String title)
	{
		myO2BusinessUser.Title = title;
	}


	public String getAccountSegment(){
		
		return myO2BusinessUser.Contact.Account.segment__c;
	
	}
	
	
	//--------------------------------------------------------------------------
	// Get first name
	//--------------------------------------------------------------------------
	public String getFirstName()
	{
		return myO2BusinessUser.FirstName;
	}

	//--------------------------------------------------------------------------
	// Set first name
	//--------------------------------------------------------------------------
	public void setFirstName(String firstName)
	{
		myO2BusinessUser.FirstName = firstName;
	}

	//--------------------------------------------------------------------------
	// Get last name
	//--------------------------------------------------------------------------
	public String getLastName()
	{
		return myO2BusinessUser.LastName;
	}

	//--------------------------------------------------------------------------
	// Set last name
	//--------------------------------------------------------------------------
	public void setLastName(String lastName)
	{
		myO2BusinessUser.LastName = lastName;
	}

	//--------------------------------------------------------------------------
	// Set can pass my details option
	//--------------------------------------------------------------------------
	public void setCanPassMyDetails(Boolean value)
	{
		myO2BusinessUser.MO2B_ShareDetails__c = value;
	}

	//--------------------------------------------------------------------------
	// Set can update me
	//--------------------------------------------------------------------------
	public void setCanUpdateMe(Boolean value)
	{
		myO2BusinessUser.MO2B_OptIn__c = value;
	}

	//--------------------------------------------------------------------------
	// Set security question
	//--------------------------------------------------------------------------
	public void setSecurityQuestion(String question)
	{
		myO2BusinessUser.SSO_Question__c = question;
	}

	//--------------------------------------------------------------------------
	// Set security answer
	// Throws exception if answer is smaller that 5 characters
	//--------------------------------------------------------------------------
	public void setSecurityAnswer(String answer)
	{
		if (answer == null || answer.length() < 5)
		{
			throw new MyO2BusinessUserException
				(
					MyO2BusinessUserException.Reason.INVALID_SECURITY_ANSWER,
					'Invalid security answer'
				);
		}
		myO2BusinessUser.SSO_Answer__c = answer;
	}

	//--------------------------------------------------------------------------
	// Set security answer hint
	//--------------------------------------------------------------------------
	public void setSecurityAnswerHint(String answerHint)
	{
		myO2BusinessUser.SSO_Answer_Hint__c = answerHint;
	}

	//--------------------------------------------------------------------------
	// Set email address
	//--------------------------------------------------------------------------
	public void setEmail(String email)
	{
		myO2BusinessUser.Email = email;
	}

	//--------------------------------------------------------------------------
	// Set new email for confirmation
	//--------------------------------------------------------------------------
	public void setNewEmail(String newEmail)
	{
		//
		// If new email is different than current one
		// Set new email and email change request datetime
		//
		if (myO2BusinessUser.Email != newEmail)
		{
			myO2BusinessUser.SSO_New_Email__c = newEmail;
			myO2BusinessUser.SSO_New_Email_Date__c = Datetime.now();
		}
	}

	//--------------------------------------------------------------------------
	// Set phone
	//--------------------------------------------------------------------------
	public void setPhone(String phone)
	{
		myO2BusinessUser.Phone = phone;
	}

	//--------------------------------------------------------------------------
	// Set mobile phone
	//--------------------------------------------------------------------------
	public void setMobilePhone(String mobilePhone)
	{
		myO2BusinessUser.MobilePhone = mobilePhone;
	}

	//--------------------------------------------------------------------------
	// Get security question
	//--------------------------------------------------------------------------
	public String getSecurityQuestion()
	{
		return myO2BusinessUser.SSO_Question__c;
	}

	//--------------------------------------------------------------------------
	// Get security answer
	//--------------------------------------------------------------------------
	public String getSecurityAnswer()
	{
		return myO2BusinessUser.SSO_Answer__c;
	}

	//--------------------------------------------------------------------------
	// Get security answer hint
	//--------------------------------------------------------------------------
	public String getSecurityAnswerHint()
	{
		return myO2BusinessUser.SSO_Answer_Hint__c;
	}

	//--------------------------------------------------------------------------
	// Get email
	//--------------------------------------------------------------------------
	public String getEmail()
	{
		return myO2BusinessUser.Email;
	}

	//--------------------------------------------------------------------------
	// Get new email
	//--------------------------------------------------------------------------
	public String getNewEmail()
	{
		return myO2BusinessUser.SSO_New_Email__c;
	}

	//--------------------------------------------------------------------------
	// Get new email request date
	//--------------------------------------------------------------------------
	public Datetime getNewEmailDate()
	{
		return myO2BusinessUser.SSO_New_Email_Date__c;
	}

	//--------------------------------------------------------------------------
	// Get phone
	//--------------------------------------------------------------------------
	public String getPhone()
	{
		return myO2BusinessUser.Phone != null ?
				myO2BusinessUser.Phone : myO2BusinessUser.Contact.Phone;
	}

	//--------------------------------------------------------------------------
	// Get mobile phone
	//--------------------------------------------------------------------------
	public String getMobilePhone()
	{
		return myO2BusinessUser.MobilePhone != null ?
				myO2BusinessUser.MobilePhone
				: myO2BusinessUser.Contact.MobilePhone;
	}

	//--------------------------------------------------------------------------
	// Get forgot password
	//--------------------------------------------------------------------------
	public Boolean getIsForgotPassword()
	{
		return myO2BusinessUser.SSO_Forgot_Password__c;
	}

	//--------------------------------------------------------------------------
	// Set forgot password
	//--------------------------------------------------------------------------
	public void setIsForgotPassword(Boolean value)
	{
		myO2BusinessUser.SSO_Forgot_Password__c = value;
	}

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessUser()
	{
		retrieveUser((Id)UserInfo.getUserId());
	}

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessUser(Id userId)
	{
		retrieveUser(userId);
	}

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessUser(String userName)
	{
		retrieveUser(username);
	}

	//--------------------------------------------------------------------------
	// Retrieve user record based on user id
	//--------------------------------------------------------------------------
	private void retrieveUser(Id userId)
	{
		system.debug('User Id: ' + userId);
		myO2BusinessUser =
		[
			SELECT Id, UserName, Title, FirstName, LastName, MobilePhone, Phone,profileid,
			Email, SSO_Question__c, SSO_Answer__c, SSO_Answer_Hint__c,
			SMS_for_Portal_Activation__c, SSO_Registration_State__c,
			SSO_New_Email__c, SSO_New_Email_Date__c, SSO_Forgot_Password__c,
			MO2B_OptIn__c, MO2B_ShareDetails__c, Contact.Email, Contact.Phone,
			Contact.MobilePhone, Contact.Account.Name,Contact.Account.segment__c
			FROM User
			WHERE Id = :userId
		];
	}

	//--------------------------------------------------------------------------
	// Retrieve user record based on username
	//--------------------------------------------------------------------------
	private void retrieveUser(String userName)
	{
		
	    
		
		myO2BusinessUser =
		[
			SELECT Id, UserName, Title, FirstName, LastName, MobilePhone, Phone,
			Email, SSO_Question__c, SSO_Answer__c, SSO_Answer_Hint__c,
			SMS_for_Portal_Activation__c, SSO_Registration_State__c,
			SSO_New_Email__c, SSO_New_Email_Date__c, SSO_Forgot_Password__c,
			MO2B_OptIn__c, MO2B_ShareDetails__c, Contact.Email, Contact.Phone,
			Contact.MobilePhone, Contact.Account.Name, Contact.Account.segment__c
			FROM User
			WHERE UserName = :userName + Label.ENTERPRISE_USERNAME_SUFFIX
		];
	}

	//--------------------------------------------------------------------------
	// Check activation pending state
	//--------------------------------------------------------------------------
	public Boolean isActivationPending()
	{
		Boolean activationPending = false;
		if (myO2BusinessUser.SSO_Registration_State__c == ACTIVATION_PENDING)
		{
			activationPending = true;
		}
		return activationPending;
	}

	//--------------------------------------------------------------------------
	// Check active state
	//--------------------------------------------------------------------------
	public Boolean isActive()
	{
		Boolean activeUser = false;
		if (myO2BusinessUser.SSO_Registration_State__c == ACTIVE)
		{
			activeUser = true;
		}
		return activeUser;
	}

	//--------------------------------------------------------------------------
	// If user doesn't have security answer than first time activation
	//--------------------------------------------------------------------------
	public Boolean isFirstTimeActivation()
	{
		Boolean firstTimeActivation =
			myO2BusinessUser.SSO_Answer__c != null
			&& myO2BusinessUser.SSO_Answer__c != '';
		return firstTimeActivation;
	}

	//--------------------------------------------------------------------------
	// Save user record
	//--------------------------------------------------------------------------
	public void save()
	{
		update myO2BusinessUser;
		syncContact(getUserId());
	}

	//--------------------------------------------------------------------------
	// Sync contact
	// This should be done in feature method because of the DML_MIXED_OPERATION
	// DML exception
	//--------------------------------------------------------------------------
	@future
	private static void syncContact(Id userId)
	{
		User myO2BusinessUser = (new MyO2BusinessUser(userId)).getUser();
		if (myO2BusinessUser.Contact != null)
		{
			setContactFields(myO2BusinessUser.Contact, myO2BusinessUser);
			update myO2BusinessUser.Contact;
		}
	}

	//--------------------------------------------------------------------------
	// Set contact fields
	//--------------------------------------------------------------------------
	private static void setContactFields(Contact c, User u)
	{
		if (c != null)
		{
			c.title = u.title;
			c.firstname = u.firstname;
			c.lastname = u.lastname;
			c.email = u.email;
			c.phone = u.phone;
			c.mobilephone = u.mobilephone;
		}
	}

	//--------------------------------------------------------------------------
	// Activates current user in activation process and sets new password
	//--------------------------------------------------------------------------
	public void activateUser(String password)
	{
		//
		// Set new password and change activation state and
		// set security question and answer
		//
		system.setPassword(getUserId(), password);
		getUser().SSO_Registration_State__c = ACTIVE;
		save();
	}

	//--------------------------------------------------------------------------
	// Generates activation code
	//--------------------------------------------------------------------------
	public String generateActivationCode()
	{
		String activationCode = MyO2BusinessSignOnUtils.generateActivationCode();
		system.debug('activationCode: ' + activationCode);
		myO2BusinessUser.SMS_for_Portal_Activation__c = activationCode;
		return activationCode;
	}

	//--------------------------------------------------------------------------
	// Validate activation code
	//--------------------------------------------------------------------------
	public Boolean validateActivationCode(String activationCode)
	{
		Boolean valid = false;
		if (activationCode != null
			&& myO2BusinessUser.SMS_for_Portal_Activation__c != null
			&& myO2BusinessUser.SMS_for_Portal_Activation__c == activationCode.trim())
		{
			valid = true;
		}
		isActivationCodeValid = valid;
		return valid;
	}
}