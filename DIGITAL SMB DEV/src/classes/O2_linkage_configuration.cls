/*****************************************************************************/
/* Paul Tarpey (paul.tarpey@saaspoint.com)                                   */
/* Reads in all parameters required by the system and maintains them in      */
/* static variables                                                          */
/*                                                                           */
/* Revision History                                                          */
/* 0.1    12/01/2009  Initial Version                                        */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

global class O2_linkage_configuration {
	
	// We have to bodge to get test coverage because Apex will not allow WS callouts
	// in test methods !!
	public static Boolean TESTING = false;
	
	// Variable used to force pass/fail if we are testing
	public static Boolean FAIL_TEST = true;
	
	// Exception class - to be thrown if there are config errors
	public class ConfigException extends Exception {}
	
	// The current system (production, sandbox etc)
	private static String CURRENT_SYSTEM;
	
	// Set of needed parameters
	private static Map<String,String> PARAMETERS;
	
	// Initialise once only (hence static)
	static {
		
		// Read in the system name - will only be 1 but do as a list to prevent a crash
		// if config is not correct - in which case throw an exception
		List<O2_OAR_Linkage_Parameter__c> sysNames = [Select Value__c From O2_OAR_Linkage_Parameter__c Where Name = 'CURRENT_SYSTEM' Limit 1];
		if (sysNames.size() != 1) {
			throw new ConfigException(Label.NO_SYS_NAME);
		}
		CURRENT_SYSTEM = sysNames[0].value__c;
		
		// Pull in all parameters for this system or All systems !  Shift them into the static list of parameters
		List<O2_OAR_Linkage_Parameter__c> params = [Select Name, Value__c From O2_OAR_Linkage_Parameter__c Where Applicable_Server__c in ('All',:CURRENT_SYSTEM)];
		PARAMETERS = new Map<String,String>();
		for (O2_OAR_Linkage_Parameter__c param : params) {
			PARAMETERS.put(param.Name, param.Value__c);
		} // end loop through parameters
	} // end of static block
	
	// Return the requested parameter
	webService static String getParam(String pName) {
		return PARAMETERS.get(pName);
	} // end getParam
	
	// Return the current system
	public static String getCurrentSystem() {
		return CURRENT_SYSTEM;
	} // end getCurrentSystem
	
	// This will only ever be used for testing - to override the current system
	// to go down chosen live/test branches
	public static void setCurrentSystem(String pSystem) {
		CURRENT_SYSTEM = pSystem;
	}
	
	// TESTED IN O2_linkage_tests
} // end of class