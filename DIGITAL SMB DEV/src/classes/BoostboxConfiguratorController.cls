global with sharing class BoostboxConfiguratorController {
	
	
	@RemoteAction
	global static String validateIAPostalCode(String thePostalCode){
	
		return 'Helloooo from in validateIAPostalCode ' + thePostalCode;	
		
	}
	
	Webservice static String validateIAPostalCode2(String thePostalCode){
	
		return 'Helloooo2 ' + thePostalCode;	
		
	}
	 

}