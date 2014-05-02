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
private class TestAttachQuoteToOppController {

	private static Quote thisQuote {get; set;}
	private static QuoteDocument thisQuoteDocument {get; set;}
	private static Opportunity opportunity {get; set;}

	static void setupData() {
		opportunity = new Opportunity(Name='Test Opp', StageName='Awareness of Needs', CloseDate=System.today());
		opportunity.TotalOpportunityQuantity = 0; //satisfy validation rule
		insert opportunity;
		
		thisQuote = new Quote(Name='Test Quote', OpportunityId=opportunity.Id);
		insert thisQuote;
	}

	static void updateSetupData() {
		Blob blobData = Blob.valueOf('cGxlYXN1cmUu');
		
		thisQuoteDocument = new QuoteDocument(QuoteId=thisQuote.Id, Document=blobData);
		insert thisQuoteDocument;
	}

    static testMethod void testNormal() {
    	setupData();
    	
      	Test.startTest();

    	ApexPages.Standardcontroller sc = new ApexPages.StandardController(thisQuote);		
		AttachQuoteToOppController aqto = new AttachQuoteToOppController(sc);
    	PageReference prOld = Page.AttachQuoteToOpp;
		Test.setCurrentPageReference(prOld);

		Boolean noDoc = aqto.getQuoteAvailable();
		
		// add a quote
		updateSetupData();

		Boolean shouldBeDoc = aqto.getQuoteAvailable();
	
		PageReference prNew = aqto.AttachQuoteToOpp();
		String url = prNew.getUrl();
		
		// is there an attachment added to our opportunity?
		Integer attachmentCount = [SELECT count() FROM Attachment WHERE parentId=:opportunity.Id];
	
    	Test.stopTest();

		System.assert(noDoc == false);
		System.assert(shouldBeDoc == true);
		system.assert(url.contains(opportunity.Id));
		system.assert(attachmentCount == 1);
    }
}