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
private class TestCreateServiceHelper
{
    private static List<String> wonOppIdList {get; set;}
    private static Opportunity opp {get; set;}
    private static Opportunity oppParentChild {get; set;}

    private static Map<String,OpportunityLineItem> oppLineItemMap {get; set;}
    private static Map<String,list<cscfgc__Product_Configuration__c>> productConfigMap {get; set;}
    private static Map<String,String> orderConfigMap {get; set;}
    private static Map<String,String> tariffCodeConfigMap {get; set;}

    private static cscfgc__Product_Configuration__c pc1 {get; set;}
    private static cscfgc__Product_Configuration__c pc2 {get; set;}
    private static List<cscfgc__Product_Configuration__c> pcList;

    private static List<String> productBundleIdList {get; set;}
    private static Map<String,list<cscfgc__Product_Configuration__c>> parentProductConfigMap {get; set;}
    private static Map<String,list<cscfgc__Product_Configuration__c>> childProductConfigMap {get; set;}
    private static Map<String,set<String>> orderTypesBundleIdMap {get; set;}
    private static Map<String,list<String>> orderTypeAndParentCfgConfigIdMap {get; set;}

    static void setupData1()
    {

        opp = TestStockObjects.getOpportunity1();

        // update the opp as we need it to be Closed Wonwe
        opp.Close_Comment__c='well done John - you are a star!';
        opp.StageName = 'Paused';
        update opp;

        TestDataForO2OrderHelper.createbundle(opp.id);

		//
		// Create process template
		//
		CSPOFA__Orchestration_Process_Template__c orchTemp = new CSPOFA__Orchestration_Process_Template__c();
		orchTemp.Name = 'Process for Order Groups';
		orchTemp.CSPOFA__Process_Type__c = 'New Provide';
		insert orchTemp;

    	//
    	// Fails becauce there is not standard pricebook available in test isolation
    	//
        // O2OrderHelper.synchBundleWithOpportunity(TestDataForO2OrderHelper.test_bundle);

        wonOppIdList = new List<String>();
        wonOppIdList.add(opp.Id);

        system.debug('opp: '+opp);
    }

    static void setupData1b()
    {

        Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'well done Marko';
		insert pricebook;

        oppParentChild = TestStockObjects.getOpportunityParentChildConfigs();

        // update the opp as we need it to be Closed Wonwe
        oppParentChild.Close_Comment__c='well done John - you are a star!';
        oppParentChild.StageName = 'Paused';
        oppParentChild.priceBook2id = pricebook.id;
        update oppParentChild;

    	TestDataForO2OrderHelper.createbundle(oppParentChild.id);
    	cscfgc__Product_Bundle__c bundle = [Select cscfgc__Opportunity__r.pricebook2id From cscfgc__Product_Bundle__c LIMIT 1];
    	//
    	// Fails becauce there is not standard pricebook available in test isolation
    	//
        //O2OrderHelper.synchBundleWithOpportunity(bundle);

        wonOppIdList = new List<String>();
        wonOppIdList.add(oppParentChild.Id);

        system.debug('oppParentChild: '+oppParentChild);
    }

    static void setupData2()
    {
        oppLineItemMap = new Map<String,OpportunityLineItem>();

        pc1 = new cscfgc__Product_Configuration__c();
        pc2 = new cscfgc__Product_Configuration__c();

        insert pc1;
        insert pc2;

        pc1 = O2OrderHelper.populateConfiguration(pc1.Id, null);

        system.debug('pc1: '+pc1);
        O2OrderHelper.populateConfiguration(pc2.Id, null);

        pcList = new List<cscfgc__Product_Configuration__c>();
        pcList.add(pc1);
        pcList.add(pc2);

        productConfigMap = new Map<String,list<cscfgc__Product_Configuration__c>>();
        productConfigMap.put('key', pcList);

        orderConfigMap = new Map<String,String> ();

        tariffCodeConfigMap = new Map<String,String>();
    }

    static void setupData13()
    {
        // TODO: Need to get this data correct

        productBundleIdList = new List<String> ();
        parentProductConfigMap = new Map<String,list<cscfgc__Product_Configuration__c>> ();
        childProductConfigMap = new Map<String,list<cscfgc__Product_Configuration__c>>  ();
        orderTypesBundleIdMap = new Map<String,set<String>>();
        orderTypeAndParentCfgConfigIdMap = new Map<String,list<String>>();
    }

    static void check1()
    {

    }

    static void check2()
    {

    }

    // cannot run this as get the 'cannot execute more than one ExecuteBatch in testmethod error */
    static testMethod void testcreateOrdersFromOpportunity()
    {
        setupData1();

        Test.startTest();
        CreateServiceHelper.createOrdersFromOpportunity(wonOppIdList);
        Test.stopTest();

        check1();

    }

    static testMethod void testcreateOrdersFromOpportunityB()
    {
        setupData1b();

        Test.startTest();
        try
        {
            // think it will fail as there are two orders and only one is expected
            CreateServiceHelper.createOrdersFromOpportunity(wonOppIdList);
        }
        catch (Exception e)
        {
        }
        Test.stopTest();

        check1();

    }

    static testMethod void testcreateOrderLineItems()
    {
        setupData2();

        Test.startTest();
        List<Order_Line_Item__c> orderLineItems = CreateServiceHelper.createOrderLineItems(oppLineItemMap, productConfigMap, orderConfigMap, tariffCodeConfigMap);
        Test.stopTest();

        check2();
    }

    static testMethod void testgetOrderConfigMap()
    {
        // TO DO: implement unit test
    }

    static testMethod void testgetTariffCodeConfigMap()
    {
        // TO DO: implement unit test
    }

    static testMethod void testgetOrderGroupOppIdMap()
    {
        // TO DO: implement unit test
    }

    static testMethod void testcreateOrderList()
    {
        // TO DO: implement unit test
    }

    static testMethod void testfillOrderWithAttributeDetails()
    {
        // TO DO: implement unit test
    }

    static testMethod void testfillOrderWithOppDetails()
    {
        // TO DO: implement unit test
    }

    static testMethod void testgetOrderName()
    {
        // TO DO: implement unit test
    }

    static testMethod void testgetMaincontactId()
    {
        // TO DO: implement unit test
    }
    static testMethod void testgetBillingContactId()
    {
        // TO DO: implement unit test
    }
    static testMethod void testgetConfigAttributeMap()
    {
        // TO DO: implement unit test
    }
    static testMethod void testgetProductConfigurationMap()
    {
        setupData13();
        CreateServiceHelper.getProductConfigurationMap(productBundleIdList,parentProductConfigMap,childProductConfigMap,orderTypesBundleIdMap,orderTypeAndParentCfgConfigIdMap);
    }
    static testMethod void testgetOpportunityLineItemMap()
    {
        // TO DO: implement unit test
    }
    static testMethod void testgetProductBundleIdList() {
        // TO DO: implement unit test
    }
    static testMethod void testgetBundleIdOppMap() {
        // TO DO: implement unit test
    }
    static testMethod void testgetMapOfWonOpportunities() {
        // TO DO: implement unit test
    }
    static testMethod void getListOfWonOpportunities() {
        // TO DO: implement unit test
    }

    static void check21(Date d1, Integer dd, Integer mm, Integer yyyy) {
        system.assertEquals(dd, d1.day());
        system.assertEquals(mm, d1.month());
        system.assertEquals(yyyy, d1.year());
    }

    static testMethod void teststringToDate() {
        // date is dd/mm/yyyy
        Date d1 = CreateServiceHelper.stringToDate('01/01/2011');
        check21(d1, 1, 1, 2011);

        Date d2 = CreateServiceHelper.stringToDate('01/01/11');
        check21(d2, 1, 1, 2011);

        // invalid input returns null date
        Date d3 = CreateServiceHelper.stringToDate('21/09');
        system.assertEquals(d3, null);

        Date d4 =  CreateServiceHelper.stringToDate(null);
        system.assertEquals(d4, null);
    }

    static Line_Availability__c updateLa() {
        Line_Availability__c la = [select id from line_availability__c where status__c = 'Completed' limit 1];
        // more populate configuration tests needed
        // first modify the LA to have values that mean more code gets tested
        Line_Availability_DDI_Range__c ddir = new Line_Availability_DDI_Range__c(Line_Availability__c=la.Id);
        insert ddir;

        la.Service_Type__c = 'ISDN2 Digital Home';
        la.CareLvl__c = '1';
        la.Number_Of_Channels__c = 4;   // will affect Number_of_lines__c
        la.TermType__c = 'termtype';
        la.InstType__c = 'insttype';
        la.Post_Code__c = 'L42QH';
        la.Carrier_Pre_Select__c = 'C';
        la.Directory_Number__c = '441512634281';
        la.TotDDIR__c = 1.0;
        la.DDI_Ranges__c = ddir.Id;
        la.TotSNDDI__c = 1.0;
        la.TotDDI__c = 1.0;
        la.TotMSN__c = 1.0;
        la.BusCont__c = 'Y';
        la.Number_Of_Bearers__c = 1.0;
        la.lineLengthEstimate__c = '200';

        update la;
        return la;
    }

        private static cscfgc.ProductConfiguration getConfig(String s) {
        cscfgc__Product_Definition__c smbLandline = [SELECT Id, Name FROM cscfgc__Product_Definition__c WHERE Name = :s LIMIT 1];
        cscfgc.API_1.ApiSession apiSess = cscfgc.Api_1.getApiSession();
        cscfgc.SessionManager.SessionInfo userSess = apiSess.getUserSession();
        cscfgc.SessionManager.SessionInfo userSessNew = apiSess.loadUserSession(userSess.userSession.id);
        apiSess.setProductToConfigure(smbLandline);
        return apiSess.getConfiguration();

    }
}