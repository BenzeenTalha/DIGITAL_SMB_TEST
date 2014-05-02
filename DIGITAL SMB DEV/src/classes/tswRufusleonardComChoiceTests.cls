/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class tswRufusleonardComChoiceTests {

    private static testMethod void getSecurityTokenTest() {
    	
		// Show we are testing so that web services are not called
		O2_linkage_configuration.TESTING = true;
		//O2_linkage_configuration.FORCE_RESPONSE = 'Pass';
		
		// Make system think we are on sandbox to go down sandbox branches
		// First get the current system - this will force configuration initialisers to run
		O2_linkage_configuration.getCurrentSystem();
		
		// Override the value for sandbox
		O2_linkage_configuration.setCurrentSystem(Label.Sandbox_String);
		
		tswRufusleonardComChoice rlObject = new tswRufusleonardComChoice('un','pw');
		rlObject.GetSecurityToken(12,'username','deepurl');
		
		// Override the value for production
		O2_linkage_configuration.setCurrentSystem(Label.Production_String);	
		
		tswRufusleonardComChoice anotherObject = new tswRufusleonardComChoice('un','pw');
		anotherObject.GetSecurityToken(12,'username','deepurl');

    } // end getSecurityTokenTest
}