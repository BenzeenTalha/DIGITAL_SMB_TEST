//------------------------------------------------------------------------------
// User locked page controller
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessLockedController
{
	//--------------------------------------------------------------------------
	// Number of attempts
	//--------------------------------------------------------------------------
	public Integer getNumberOfAttempts()
	{
		return MyO2BusinessUser.getNumberOfAttempts();
	}

	//--------------------------------------------------------------------------
	// Lockout period
	//--------------------------------------------------------------------------
	public Integer getLockoutPeriod()
	{
		return MyO2BusinessUser.getLockoutPeriod();
	}
}