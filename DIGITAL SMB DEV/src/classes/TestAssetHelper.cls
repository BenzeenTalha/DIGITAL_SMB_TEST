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
private class TestAssetHelper {
	static final String ASSET1 = 'TestAsset1';
	static final String ASSET2 = 'TestAsset2';
	static final String ASSETCFG1 = 'TestAssetCfg1';
	static final String ASSETCFG2 = 'TestAssetCfg2';
	static final String ORDER_NAME = 'TestOrder';
	static final String ACCOUNT_NAME = 'TestAccount';
	
	private static Account account {get; set;}
	private static Order__c order {get; set;}
	private static Asset_Configuration__c ac1 {get; set;}
	private static Asset_Configuration__c ac2 {get; set;}
	private static Order_Asset__c oa1 {get; set;}
	private static Order_Asset__c oa2 {get; set;}

	static void setupData() {
		account = new Account(Name=ACCOUNT_NAME);
		insert account;
		
		order = new Order__c(Name=ORDER_NAME, Account__c=account.Id);
		insert order;
		
    	oa1 = new Order_Asset__c(Name=ASSET1, Order__c=order.Id);
    	oa2 = new Order_Asset__c(Name=ASSET2, Order__c=order.Id);
    	
    	insert oa1;
    	insert oa2;

    	ac1 = new Asset_Configuration__c(Name=ASSETCFG1, order_Asset__c=oa1.Id);
    	ac2 = new Asset_Configuration__c(Name=ASSETCFG2, order_Asset__c=oa2.Id);
  
  		insert ac1;
  		insert ac2;  		
    	
		system.debug('ac1: '+ac1);
		system.debug('ac2: '+ac2);
		system.debug('oa1: '+oa1);
		system.debug('oa2: '+oa2);
	}

    static testMethod void testgetAssetConfigurationList() {
		setupData();
		
 		Set <String> assetSet = new Set<String>();
 		assetSet.add(oa1.Id);
 		assetSet.add(oa2.Id);   	
 
  		Test.startTest();

		List<Asset_Configuration__c> assetList = AssetHelper.getAssetConfigurationList(assetSet);

		system.debug('assetList: '+assetList);

		Test.stopTest();
		
		System.assert(assetList != null);
		System.assert(assetList.size() == 2);
		System.assert(assetList[0].Name.equals(ASSETCFG1) || (assetList[1].Name.equals(ASSETCFG1)));
		System.assert(assetList[0].Name.equals(ASSETCFG2) || (assetList[1].Name.equals(ASSETCFG2)));
    }
    
    static testMethod void testgetAssetConfigurationMap() {
		setupData();
		
		List <Order_Asset__c> assetList = new List<Order_Asset__c>();
		assetList.add(oa1);
		assetList.add(oa2);
		
		Test.startTest();
		
		Map<ID,Asset_Configuration__c> assetMap = AssetHelper.getAssetConfigurationMap(assetList);
		system.debug('assetMap: '+assetMap);

		Test.stopTest();
		
		System.assert(assetMap != null);
		System.assert(assetMap.size() == 2);
		System.assert(assetMap.containsKey(oa1.Id));
		System.assert(assetMap.containsKey(oa2.id));
    	
    }
}