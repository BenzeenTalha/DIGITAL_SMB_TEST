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
private class TestAllOpportunityTriggers {

	private static Opportunity opp1 {get; set;}
	private static Opportunity opp2 {get; set;}
	private static List<Opportunity> opps {get;set;}

	private static void setupData() {
		opp1 = new Opportunity(Name='One is the magic number', CloseDate=System.today(), StageName = 'Awareness of Needs');
		opp1.TotalOpportunityQuantity = 0; // need for validation rule

		opp2 = new Opportunity(Name='Two is the magic number', CloseDate=System.today(), StageName = 'Awareness of Needs');
		opp2.TotalOpportunityQuantity = 0; // need for validation rule
		opps = new List<Opportunity>();
		opps.add(opp1);
		opps.add(opp2);
		
		// Say we want to Create Orders
		CreateServiceHelper.createOrders = true;
	}

    static testMethod void testInsert() {
		setupData();
		insert opps;
    }

    static testMethod void testUpdate() {
		setupData();
		Test.startTest();
			insert opps;
			opp1.Description = 'updated';
			opp1.StageName = 'Paused';
			opp1.TotalOpportunityQuantity = 0; // need for validation rule
			opp2.Amount = 30.0;
			// TODO - need to add a product to bypass the validation rule.
			//opp2.StageName = 'Closed Won';
			opp2.Close_Comment__c = 'Go Magic - beat Umbrell to the deal!';
			opp2.TotalOpportunityQuantity = 0; // need for validation rule
			update opps;
			
			// finaly progress opp1 to Closed Won
			// TODO - need to add a product to bypass the validation rule.
			//opp2.StageName = 'Closed Won';
			//opp2.Close_Comment__c = 'Just made it - great team work guys';
			//update opp2;
		Test.stopTest();
		
		// TODO: Add some tests here
		
    }

    static testMethod void testDeleteUndelete() {
		setupData();
		insert opps;
		delete opps;
		undelete opps;
    }

}