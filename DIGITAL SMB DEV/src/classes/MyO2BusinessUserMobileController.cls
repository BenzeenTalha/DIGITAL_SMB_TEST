//------------------------------------------------------------------------------
// Display last four characters of mobile phone
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessUserMobileController
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	public static final Integer LAST_DIGITS = 4;

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
				returnValue += mobilePhone.substring
								(
									mobilePhone.length() - LAST_DIGITS,
									mobilePhone.length()
								);
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
}