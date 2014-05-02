//------------------------------------------------------------------------------
// MyO2BusinessUserException class if user data is incorrect
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessUserException extends Exception
{
	public enum Reason { INVALID_SECURITY_ANSWER }

	private Reason reason;

	//--------------------------------------------------------------------------
	// Getter
	//--------------------------------------------------------------------------
	public Reason getReason()
	{
		return reason;
	}

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public MyO2BusinessUserException(Reason reason, String message)
	{
		this.setMessage(message);
		this.reason = reason;
	}
}