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
public class TestStockObjects {

	public static Opportunity getOpportunity1() {
		cscfgc__Configuration_Offer__c offer = TestDataForO2OrderHelper.createOffer();
    	
    	TestDataForO2OrderHelper.createRecordTypeForAccount();
    	TestDataForO2OrderHelper.createRecordTypeForOpportunity();
    	
    	Account account = TestDataForO2OrderHelper.createAccount();
 		Contact contact = TestDataForO2OrderHelper.createContact();
    	Opportunity opp = TestDataForO2OrderHelper.createOpportunity();
    	
    	List<OpportunityContactRole> ocrList = TestDataForO2OrderHelper.createOpportunityContactRole(opp.Id, contact.Id);

    	cscfgc__Product_Bundle__c prodBundle = TestDataForO2OrderHelper.createbundle(opp.Id);
    	system.debug('bundle1: '+prodBundle);
    	cscfgc__Product_Definition__c prodDef = TestDataForO2OrderHelper.createProductDefinition();
    	system.debug('bundle2: '+prodBundle);
    	
    	List<cscfgc__Attribute_Definition__c> attrList = TestDataForO2OrderHelper.createAttributeDefinition(prodDef.Id);
    	system.debug('bundle3: '+prodBundle);
    	cscfgc__Product_Configuration__c prodConfig = TestDataForO2OrderHelper.createProductConfiguration(attrList, prodBundle.Id, prodDef.Id, offer.Id);
    	system.debug('bundle4: '+prodBundle);
		
		return opp;
	}
	
	public static Opportunity getOpportunityParentChildConfigs() {
		cscfgc__Configuration_Offer__c offer = TestDataForO2OrderHelper.createOffer();
    	
    	TestDataForO2OrderHelper.createRecordTypeForAccount();
    	TestDataForO2OrderHelper.createRecordTypeForOpportunity();
    	
    	Account account = TestDataForO2OrderHelper.createAccount();
 		Contact contact = TestDataForO2OrderHelper.createContact();
    	Opportunity opp = TestDataForO2OrderHelper.createOpportunity();
    	
    	List<OpportunityContactRole> ocrList = TestDataForO2OrderHelper.createOpportunityContactRole(opp.Id, contact.Id);

    	cscfgc__Product_Bundle__c prodBundle = TestDataForO2OrderHelper.createbundle(opp.Id);
     	cscfgc__Product_Definition__c prodDef1 = TestDataForO2OrderHelper.createProductDefinition();
     	cscfgc__Product_Definition__c prodDef2 = TestDataForO2OrderHelper.createProductDefinition();
    	
    	List<cscfgc__Attribute_Definition__c> attrList1 = TestDataForO2OrderHelper.createAttributeDefinition(prodDef1.Id);
    	List<cscfgc__Attribute_Definition__c> attrList2 = TestDataForO2OrderHelper.createAttributeDefinition(prodDef2.Id);
    	cscfgc__Product_Configuration__c prodConfigParent = TestDataForO2OrderHelper.createProductConfiguration(attrList1, prodBundle.Id, prodDef1.Id, offer.Id);
    	cscfgc__Product_Configuration__c prodConfigChild = TestDataForO2OrderHelper.createProductConfiguration(attrList2, prodBundle.Id, prodDef2.Id, offer.Id);
		
		prodConfigChild.cscfgc__Parent_Configuration__c = prodConfigParent.Id;
		update prodConfigChild;
		
		return opp;
	}
	
}