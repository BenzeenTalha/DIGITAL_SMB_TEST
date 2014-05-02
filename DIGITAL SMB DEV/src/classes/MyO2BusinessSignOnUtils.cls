//------------------------------------------------------------------------------
// Sign On utilities
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessSignOnUtils
{
	public static final Integer CODE_LENGTH = 4;

	//--------------------------------------------------------------------------
	// Classs used for sending multiple emails
	//--------------------------------------------------------------------------
	public with sharing class Emails
	{
		//----------------------------------------------------------------------
		// Members
		//----------------------------------------------------------------------
		private List <Messaging.SingleEmailMessage> mails =
			new List <Messaging.SingleEmailMessage>();

		//----------------------------------------------------------------------
		// Add email
		//----------------------------------------------------------------------
		public void add(Id userId, String emailTemplate)
		{
	        Messaging.SingleEmailMessage mail = createEmail(userId, emailTemplate);
            mails.add(mail);
		}

		//----------------------------------------------------------------------
		// Sends emails
		//----------------------------------------------------------------------
		public void send()
		{
			Messaging.sendEmail(mails);
		}

	}

	//--------------------------------------------------------------------------
	// Get available questions
	//--------------------------------------------------------------------------
	public static List<SelectOption> getStockQuestions()
	{
		List<SelectOption> stockQuestions = new List<SelectOption>();
		stockQuestions.add(new SelectOption('', '--None--'));
		for (SSO_Stock_Questions__c q: [SELECT Question__c, Name FROM SSO_Stock_Questions__c WHERE active__c = true ORDER BY ranking__c ASC])
		{
			stockQuestions.add(new SelectOption(q.question__c, q.question__c));
		}
		return stockQuestions;
	}


	//--------------------------------------------------------------------------
	// Send email to user
	//--------------------------------------------------------------------------
    public static void sendEmail(Id userId, String emailTemplate)
    {
    	Messaging.SingleEmailMessage mail = createEmail(userId, emailTemplate);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

	//--------------------------------------------------------------------------
	// Send email to address
	//--------------------------------------------------------------------------
	public static void sendEmailToAddress(Id userId, MyO2BusinessEmailTemplate emailTemplate, String toAddress)
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		emailTemplate.setTargetId(userId);
		mail.setHtmlBody(emailTemplate.getHtmlBody());
		mail.setPlainTextBody(emailTemplate.getPlainTextBody());
		mail.setEmailPriority('High');
		mail.saveAsActivity = false;
		mail.setToAddresses(new String[] {toAddress});
		mail.setSubject('O2 Support – My O2 Business Email Address Change');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}

    //--------------------------------------------------------------------------
    // Create email for sending
    //--------------------------------------------------------------------------
    private static Messaging.SingleEmailMessage createEmail(Id userId, String emailTemplate)
    {
        Messaging.SingleEmailMessage mail =
        	new Messaging.SingleEmailMessage();
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = :emailTemplate];
		mail.setSenderDisplayName(Label.MO2B_MO2B);
		mail.setEmailPriority(Label.MO2B_HIGH_PRIORITY);
        mail.setTemplateId(et.Id);
        mail.setTargetObjectId(userId);
        mail.saveAsActivity = false;
       
        return mail;
    }

    //--------------------------------------------------------------------------
    // Generate activation code
    //--------------------------------------------------------------------------
    public static String generateActivationCode()
    {
    	Integer randomInteger = Crypto.getRandomInteger();
    	String activationCode = String.valueOf(randomInteger);
    	//
    	// If activation code is less than 4 characters fill with zeros
    	//
    	activationCode = addZeros(activationCode, CODE_LENGTH);
    	return activationCode.substring(activationCode.length() - CODE_LENGTH, activationCode.length());
    }

    //--------------------------------------------------------------------------
    // Adds zeros to begining
    //--------------------------------------------------------------------------
    private static String addZeros(String activationCode, Integer length)
    {
    	for (Integer i = activationCode.length(); i < length; i++)
    	{
    		activationCode = '0' + activationCode;
    	}
    	return activationCode;
    }

	//--------------------------------------------------------------------------
	// Mask string with x characters
	//--------------------------------------------------------------------------
	public static String maskMobilePhone(String mobilePhone, Integer lastDigits)
	{
		String returnValue = '';
		if (mobilePhone != null)
		{
			//
			// mobilePhone.length() - lastDigits 'x' characters
			//
			for (Integer i = 0; i < mobilePhone.length() - lastDigits; i++)
			{
				returnValue += 'x';
			}
			//
			// Add last digits
			//
			returnValue += mobilePhone.substring(
								mobilePhone.length() - lastDigits,
								mobilePhone.length());
		}
		return returnValue;
	}

	//-----------------------------------------------------------------------------
	// Checks if user is loged in
	//-----------------------------------------------------------------------------
	public static Boolean authorize()
	{
		return (UserInfo.getUserType() != 'Guest'
				&& (new MyO2BusinessUser()).isActive());
	}

	//-----------------------------------------------------------------------------
	// Prepare salesforce exception message
	//-----------------------------------------------------------------------------
	public static String prepareExceptionMessage(Exception e)
	{
		String returnValue = '';
		String exceptionMessage = e.getMessage();
		if (exceptionMessage != null)
		{
			returnValue = exceptionMessage.replaceAll('UNKNOWN_EXCEPTION:', '');
			returnValue = returnValue.trim();
			//
			// Uppercase first character
			//
			returnValue = returnValue.capitalize();
		}
		return returnValue;
	}
	
	
	/**public static void sendTestEmailToAddress(String message, String toAddress)
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setHtmlBody(message);
		mail.setPlainTextBody(message);
		mail.setEmailPriority('High');
		mail.saveAsActivity = false;
		mail.setToAddresses(new String[] {toAddress});
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}*/
}