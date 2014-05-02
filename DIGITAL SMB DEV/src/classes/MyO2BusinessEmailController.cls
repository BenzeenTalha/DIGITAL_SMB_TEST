//------------------------------------------------------------------------------
// Used for:
// 1. Display last four characters of mobile phone
// 2. Display new email address that needs to be confirmed
// 3. Display new email request date
// 4. Display current date time
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessEmailController
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	public static final Integer LAST_DIGITS = 4;
	public static final String DATETIME_FORMAT = 'dd MMM yyyy \'at\' HH:mm';

	//--------------------------------------------------------------------------
	// Getters / setters
	//--------------------------------------------------------------------------
	public Id userId { get; set; }

	//--------------------------------------------------------------------------
	// Get last four digits of mobile phone number
	//--------------------------------------------------------------------------
	public String getMobilePhone()
	{
		String returnValue = '';
		try
		{
			MyO2BusinessUser businessUser = new MyO2BusinessUser(userId);
			String mobilePhone = businessUser.getMobilePhone();
			system.debug('mobilePhone: ' + mobilePhone);
			if (mobilePhone != null)
			{
				//
				// mobilePhone.length() - LAST_DIGITS 'x' characters
				//
				for (Integer i = 0; i < mobilePhone.length() - LAST_DIGITS; i++)
				{
					returnValue += 'x';
				}
				//
				// Add last digits
				//
				returnValue += mobilePhone.substring(
									mobilePhone.length() - LAST_DIGITS,
									mobilePhone.length());
			}
		}
		catch (Exception e)
		{
			//
			// Do nothing
			//
			system.debug('exception' + e.getMessage());
		}
		return returnValue;
	}

	//-----------------------------------------------------------------------------
	// Get new email address that needs to be confirmed
	//-----------------------------------------------------------------------------
	public String getNewEmail()
	{
		String returnValue = '';
		try
		{
			//
			// Get new email address
			//
			MyO2BusinessUser businessUser = new MyO2BusinessUser(userId);
			returnValue = businessUser.getNewEmail();
		}
		catch (Exception e)
		{
			//
			// Do nothing
			//
			system.debug('exception: ' + e.getMessage());
		}
		return returnValue;
	}

	//-----------------------------------------------------------------------------
	// Get new email request date
	//-----------------------------------------------------------------------------
	public String getNewEmailDate()
	{
		String returnValue = '';
		try
		{
			MyO2BusinessUser businessUser = new MyO2BusinessUser(userId);
			Datetime newEmailDate = businessUser.getNewEmailDate();
			if (newEmailDate != null)
			{
				returnValue = newEmailDate.format(DATETIME_FORMAT);
			}
		}
		catch (Exception e)
		{
			//
			// Do nothing
			//
			system.debug('exception: ' + e.getMessage());
		}
		return returnValue;
	}

	//-----------------------------------------------------------------------------
	// Get Datetime now
	//-----------------------------------------------------------------------------
	public String getNow()
	{
		return Datetime.now().format(DATETIME_FORMAT);
	}
}