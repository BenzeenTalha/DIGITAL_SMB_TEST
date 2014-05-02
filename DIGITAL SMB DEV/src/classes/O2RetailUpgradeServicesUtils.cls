//------------------------------------------------------------------------------
// Utils for O2 Retail Upgrade services
//------------------------------------------------------------------------------
public with sharing class O2RetailUpgradeServicesUtils
{
    //--------------------------------------------------------------------------
    // Checks if there is error in the response
    // Input value is result map from service call
    // Return value is boolen:
    //   - true if error in the response
    //   - false otherwise
    //--------------------------------------------------------------------------
    public static Boolean checkForError(Map<String, Object> resultMap)
    {
    	Boolean returnValue = false;
    	if (resultMap != null)
    	{
    		if (resultMap.get('error') != null)
    		{
    			returnValue = true;
    		}
    	}
    	return returnValue;
    }

	//--------------------------------------------------------------------------
	// Trace exception leaves debug log of the method name and exception
	// Input values are:
	//   - methodName is name of SOA function that is called
	//   - e is exception that was cought
	//--------------------------------------------------------------------------
	public static void processException
	(
		Map<String, Object> returnValues,
		String methodName, Exception e
	)
	{
		returnValues.put('error', 'Error while calling ' + methodName + ': ' + e.getMessage());
		System.debug('Error while calling ' + methodName + ': ' + e.getMessage());
		System.debug(e.getStackTraceString());
	}

	//--------------------------------------------------------------------------
	// Logging of error response
	//--------------------------------------------------------------------------
	public static Boolean logErrorResponse
	(
		Map<String, Object> response,
		String functionName
	)
	{
		if (checkForError(response))
		{
			System.debug('Error while calling ' + functionName + ': ' + response.get('error'));

			return true;
		}
		return false;
	}

	public without sharing class ServiceErrorLog
	{
		//--------------------------------------------------------------------------
		// services errors list
		//--------------------------------------------------------------------------
		private List<String> serviceErrors;

		//--------------------------------------------------------------------------
		// Add service error to list of errors
		//--------------------------------------------------------------------------
		public void add(String error)
		{
			//
			// Check if error exist
			//
			if (error != null)
			{
				//
				// Check if service errors exist
				//
				if (serviceErrors == null)
				{
					serviceErrors = new List<String>();
				}
				serviceErrors.add(error);
			}
		}

		//----------------------------------------------------------------------
		// Saves services errors to a custom object
		//----------------------------------------------------------------------
		public void save()
		{
			System.debug('saveServiceErrors() BEGIN');
			if (serviceErrors != null)
			{
				//
				// Get length of the fields
				//
				Integer log1Length = O2_Retail_Upgrade_Error_Log__c.Log1__c.getDescribe().getLength();
				Integer log2Length = O2_Retail_Upgrade_Error_Log__c.Log2__c.getDescribe().getLength();
				Integer log3Length = O2_Retail_Upgrade_Error_Log__c.Log3__c.getDescribe().getLength();
				Integer log4Length = O2_Retail_Upgrade_Error_Log__c.Log4__c.getDescribe().getLength();
				//
				// Create list of custom objects
				//
				List<O2_Retail_Upgrade_Error_Log__c> errorLogs = new List<O2_Retail_Upgrade_Error_Log__c>();
				System.debug('log1Length: ' + log1Length + ',log2Length: ' + log2Length + ',log3Length: ' + log3Length + ',log4Length: ' + log4Length);
				for (String error : serviceErrors)
				{
					//
					// Insert new custom object element in the list
					//
					O2_Retail_Upgrade_Error_Log__c errorLog = new O2_Retail_Upgrade_Error_Log__c();
					O2RetailUpgradeServicesUtils.LogFields logFields =
						new O2RetailUpgradeServicesUtils.LogFields(error);
					errorLog.Log1__c = logFields.getLogField(log1Length);
					errorLog.Log2__c = logFields.getLogField(log2Length);
					errorLog.Log3__c = logFields.getLogField(log3Length);
					errorLog.Log4__c = logFields.getLogField(log4Length);
					errorLogs.add(errorLog);
				}
				//
				// Insert all elements to Salesforce
				//
				try
				{
					insert errorLogs;
				}
				catch (Exception e) {}
				//
				// Clear service errors
				//
				serviceErrors.clear();
			}
			System.debug('saveServiceErrors END');
		}
	}

	//--------------------------------------------------------------------------
	// Helper class for writing in log fields
	//--------------------------------------------------------------------------
	private class LogFields
	{
		private String error;

		//----------------------------------------------------------------------
		// Constructor
		//----------------------------------------------------------------------
		public LogFields(String p_error)
		{
			error = p_error;
		}

		//----------------------------------------------------------------------
		// Get log for
		//----------------------------------------------------------------------
		public String getLogField(Integer logLength)
		{
			String returnValue = null;
			if (error != null && error.length() > 0)
			{
				if (logLength < error.length())
				{
					returnValue = error.substring(0, logLength);
					error = error.substring(logLength);
				}
				else
				{
					returnValue = error;
					error = null;
				}
			}
			return returnValue;
		}
	}
}