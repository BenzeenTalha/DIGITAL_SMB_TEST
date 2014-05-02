@isTest
private class TestMyO2BusinessBoltOns {
	private static Integer numberOfSamples = 1;
    private static String testFilterName = 'Will'; 
    private static Id subscriptionId;
    
    static testmethod void testMyO2BusinessBoltOns() {

		System.debug('testMyO2BusinessSubscriptionsController entry point');
        CreateRecords(1);
		System.debug('testMyO2BusinessSubscriptionsController created records');
        // Test
        Test.startTest();
		System.debug('testMyO2BusinessSubscriptionsController test started');
        MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
        con.clearFilter();
        con.filterNames = testFilterName;
        con.filterNumbers = '123,2(3)4';
        con.selectedValue = subscriptionId;
        con.advancedFilter();
		System.debug('testMyO2BusinessSubscriptionsController advanced filter passed');
        PageReference boltOnsRef = con.goToSMBBoltOnsChanges();
        PageReference continueJourneySMB = con.continueSMBJourney();
        MyO2BusinessRequestBoltOnsController boltonCon = new MyO2BusinessRequestBoltOnsController(con);
        boltonCon.RefreshExtras();
        PageReference finishSMB = boltonCon.FinishEditBoltons();
        PageReference cancelSMB = con.Cancel();
		System.debug('testMyO2BusinessSubscriptionsController before stop test');
        Test.stopTest();
		System.debug('testMyO2BusinessSubscriptionsController after stop test');
        System.assertEquals(con.subscriptions.size(), numberOfSamples);
        System.assert(con.subscriptions[0].subscription.Subscription_Name__c.contains('Will'));

    }
    
    static testmethod void TestBoltOnsLineItemCompare(){
        CreateRecords(1);
        Test.startTest();
        
    	MyO2BusinessRequestBoltOnsController.BoltOnsLineItem boli1 = new MyO2BusinessRequestBoltOnsController.BoltOnsLineItem(subscriptionsExtra[0]);
    	MyO2BusinessRequestBoltOnsController.BoltOnsLineItem boli2 = new MyO2BusinessRequestBoltOnsController.BoltOnsLineItem(subscriptionsExtra[0]);
    	boli1.CompareField = 'MOBILE_NUMBER';
    	Integer result = 0;
    	result = boli1.compareTo(boli2);
    	System.assertEquals(0, result);
    	boli1.CompareField = 'SUBSCRIBER';
    	result = boli1.compareTo(boli2);
    	System.assertEquals(0, result);
    	boli1.CompareField = 'Bolt_Ons';
    	result = boli1.compareTo(boli2);
    	System.assertEquals(0, result);
    	
        Test.stopTest();
    }
    
    static testmethod void TestBoltOnJourneyAddDays(){
		System.debug('testbolton entry point');
        //Create records
        CreateRecords(1);
		System.debug('testbolton records created');

        //Start test
        Test.startTest();
		
		System.debug('testbolton test started');
        //Search some subscriptions and select them
        MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
        con.clearFilter();
        con.filterNames = testFilterName;
        con.selectedValue = subscriptionId;
        con.advancedFilter();
		System.debug('testbolton after advanced filter');
        for(MyO2BusinessSubscriptionsController.SubscriptionWrapper sw : con.subscriptions){
            sw.isSelected = true;
            System.debug('test bolt on journey, subscription = ' + sw);
        }
        
        PageReference boltOnsRef = con.goToBoltOnsRequest();
		System.debug('testbolton after gotoadminchanges');

        MyO2BusinessRequestBoltOnsController boltonCtrl = new MyO2BusinessRequestBoltOnsController (con);
		System.debug('testbolton after adminCtrl creation');
        boltonCtrl.RefreshExtras();
		System.debug('testbolton after refresh extras');
        
       
        System.assertEquals(numberOfSamples, boltonCtrl.BoltOnsLineItems.size());

        boltonCtrl.OrderFieldNameTemp = 'MOBILE_NUMBER';
        boltonCtrl.SortList();

        boltonCtrl.OrderFieldNameTemp = 'SUBSCRIBER';
        boltonCtrl.SortList();

        boltonCtrl.OrderFieldNameTemp = 'COST_CENTRE';
        boltonCtrl.SortList();
        boltonCtrl.SortList();
        
        System.assert(boltonCtrl.matchedBoltOns.size() > 0);
        boltonCtrl.matchedBoltOns[0].isSelected = true;

		System.debug('testbolton before submit request');
        //Submit
        boltonCtrl.FinishEditBoltons();
        boltonCtrl.SubmitRequest();
		System.debug('testbolton after submit request');

    }
    
    static testmethod void TestBoltOnJourneyMatched(){
		System.debug('testbolton entry point');
        //Create records
        CreateRecords(-1);
		System.debug('testbolton records created');

        //Start test
        Test.startTest();
		
		System.debug('testbolton test started');
        //Search some subscriptions and select them
        MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
        con.clearFilter();
        con.filterNames = testFilterName;
        con.selectedValue = subscriptionId;
        con.advancedFilter();
		System.debug('testbolton after advanced filter');
        for(MyO2BusinessSubscriptionsController.SubscriptionWrapper sw : con.subscriptions){
            sw.isSelected = true;
            System.debug('test bolt on journey, subscription = ' + sw);
        }
        
        PageReference boltOnsRef = con.goToBoltOnsRequest();
		System.debug('testbolton after gotoadminchanges');

        MyO2BusinessRequestBoltOnsController boltonCtrl = new MyO2BusinessRequestBoltOnsController (con);
		System.debug('testbolton after adminCtrl creation');
        boltonCtrl.RefreshExtras();
		System.debug('testbolton after refresh extras');
        
       
        System.assertEquals(numberOfSamples, boltonCtrl.BoltOnsLineItems.size());

        boltonCtrl.OrderFieldNameTemp = 'MOBILE_NUMBER';
        boltonCtrl.SortList();

        boltonCtrl.OrderFieldNameTemp = 'SUBSCRIBER';
        boltonCtrl.SortList();

        boltonCtrl.OrderFieldNameTemp = 'COST_CENTRE';
        boltonCtrl.SortList();
        boltonCtrl.SortList();
        
        System.assert(boltonCtrl.matchedBoltOns.size() > 0);
		boltonCtrl.allBoltOnsOld[0].isSelected = true;
		List<MyO2BusinessRequestBoltOnsController.BoltOnWrapper> allBoltOns = new List<MyO2BusinessRequestBoltOnsController.BoltOnWrapper>();
		allBoltOns.addAll(boltonCtrl.matchedBoltOns);
		allBoltOns.addAll(boltonCtrl.internationalBoltOns);
		Integer matchedIndex = 0;
		for (MyO2BusinessRequestBoltOnsController.BoltOnWrapper newBoltOn: allBoltOns) {
			if (boltonCtrl.allBoltOnsOld[0].tariffPackage.Service_Code__c == newBoltOn.tariffPackage.Service_Code__c) {
				break;
			}
			matchedIndex++;
		}
        boltonCtrl.matchedBoltOns[matchedIndex].isSelected = false;
		
		System.debug('testbolton before submit request');
        //Submit
        boltonCtrl.FinishEditBoltons();
        boltonCtrl.SubmitRequest();
		System.debug('testbolton after submit request');

    }
    
    //Create records used by test methods
    static List<AC_Subscription_Extra__c> subscriptionsExtra = new List<AC_Subscription_Extra__c>();
    static List<AC_Subscription__c> subscriptions = new List<AC_Subscription__c>();
    
    static void CreateRecords(Integer addedDays){

        //Custom settings
        SOA_Integration_Settings__c soaSettings = new SOA_Integration_Settings__c(Name = 'ManageBusinessSubscriptions_1_0',
                                                                                  Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/ManageBusinessSubscriptions_1_0',
                                                                                  Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk',
                                                                                  MAX_SOA_RETRIES__c = 1,
                                                                                  Timeout__c = 60000);
        insert soaSettings;
        
        SOA_Integration_Settings__c soaSettings2 = new SOA_Integration_Settings__c(Name = 'Manage_Business_Customer_Details',
                                                                                  Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/ManageBusinessCustomerDetails_1_0',
                                                                                  Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk',
                                                                                  MAX_SOA_RETRIES__c = 1,
                                                                                  Timeout__c = 60000);
        insert soaSettings2;
        
        
          SOA_Integration_Settings__c soaSettings3 = new SOA_Integration_Settings__c(Name = 'Subscriber',
                                                                                  Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/Subscriber_2_0',
                                                                                  Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk',
                                                                                  MAX_SOA_RETRIES__c = 1,
                                                                                  Timeout__c = 60000);
        insert soaSettings3;

        MyO2BusinessSettings__c myO2BusinessSettings = new MyO2BusinessSettings__c(Name = 'Settings',
                                                                                   SubscriptionRefreshCheckFrequency__c = 2000,
                                                                                   SubscriptionRefreshMinutes__c = 60,
                                                                                   SubscriptionRefreshTimeout__c = 60000);
        insert myO2BusinessSettings;

        AC_Container__c acc = new AC_Container__c();
        insert acc;
		
		AC_Account_Invoice__c ai = new AC_Account_Invoice__c(
														AIUID__c = '01234567890',
														Account_ID__c = '5131230',
														Next_Invoice_Tax_Date__c = Date.today().addDays(addedDays));
		insert ai;
		List<RD_Tariff_Package_Service__c> tpsList = new List<RD_Tariff_Package_Service__c>();
		
		RD_Tariff_Package_Service__c tps1 = new RD_Tariff_Package_Service__c (
														Package_Code__c = 'NWS02S',
														Service_Description__c = '2GB UK Data',
														Service_Price__c = 12.5,
														Service_Code__c = '2GBTST',
														Recurring__c = true,
														Tariff_Code__c = 'Q12KAA');
		tpsList.add(tps1);
		RD_Tariff_Package_Service__c tps2 = new RD_Tariff_Package_Service__c (
														Package_Code__c = 'NWS02S',
														Service_Description__c = '2GB UK Data',
														Service_Price__c = 12.5,
														Service_Code__c = '2GBTS1',
														Recurring__c = true,
														Tariff_Code__c = 'Q12KAA');
		tpsList.add(tps2);
		insert tpsList;
		
        
		System.debug('CreateRecords inserted account = ' + acc);
        AC_Subscription__c ac4 = new AC_Subscription__c(Name = 'William Heathcote',
                                                        AC_Container__c = acc.Id,
                                                        Agreement_ID__c = '2605545',
                                                        Contract_Status__c = 'out-of-contract',
                                                        Customer_Cost_Centre__c = 'CATMK',
                                                        Delivery_Address_ID__c = '6223210',
                                                        DISE_Account_No__c = '4901518' ,
                                                        Network_Code__c = 'CDIG',
                                                        Network_Serial_No__c = '07736747443',
                                                        Package_Code__c = 'BRTMPG',
                                                        Ringfence_Ind__c = 'ringfence',
                                                        Sales_Person_ID__c = '53808',
                                                        Subscription_Container_ID__c = '4901518-53808',
                                                        Subscription_ID__c = '2769502',
                                                        Subscription_Name__c = 'William Heathcote',
                                                        Subscription_Status__c = 'NORMAL',
                                                        Tariff_Code__c = 'Q12KAA');
                                                     
                                                        
                                                       
        subscriptions.add(ac4);
       
        insert subscriptions;

        
        System.debug('create record subscription id ' + ac4.id);
		subscriptionId = ac4.id;
        AC_Subscription_Extra__c ace4 = new AC_Subscription_Extra__c(AC_Subscription__c = ac4.Id,
                                                                     Callout_Error__c = true,
                                                                     IMEI_Number__c = '',
                                                                     Last_Amended_Date_Customer_Details__c = '2012-12-30T10:12:19.000Z',
                                                                     Last_Amended_Date_Serial_Numbers__c = '2011-02-17T14:05:13.000Z',
                                                                     Last_Callout_Date__c = DateTime.now(),
                                                                     SIM_Number__c = '8944110065094096501',
                                                                     Subscription_ID__c = '2769502',
                                                                     Term_of_Contract__c = '24',
                                                                     Device_Bar__c = true,
                                                                    Full_Bar__c = true,
                                                                    International__c = true,
                                                                    Premium_Call_Bar_Display__c = true,
                                                                    Roaming_Call_Bar_Display__c = true,
                                                                    GPRS__c = true,
                                                                    DISE_Account_No__c = '5131230',
                                                                    IMEI_Bar__c = true,
                                                                    Fullbar_with_no_msg__c = true,
                                                                    Fullbar_with_msg__c = true,
                                                                    Stolen_Bar__c = true,
                                                                    International_Call_Bar_Display__c = true,
                                                                    Add_full_international_access__c = true,
                                                                    Internet_premium_call_bar__c = true,
                                                                    International_Bar__c = true,
                                                                    International_prem_roam_local__c = true,
                                                                    International_premium_roam__c = true,
                                                                    Premium_rate_call_bar__c = true,
                                                                    Add_Premium_Adult_Bar__c = true,
                                                                    Adult_and_Chat_Bar__c = true,
                                                                    Adult_Bar__c = true,
                                                                    Chat_Bar__c = true,
                                                                    Bars_h_s_for_calls_from_o_s_UK__c = true,
                                                                    O2_only_roam_bar__c = true,
                                                                    GPRS_Bar__c = true,
                                                                    PUK_Code_Flag__c = false,
                                                                    BoltOns_Flag__c= true,
                                                                    Other_Bolt_Ons__c = '[2GBTST,Description,1250]',
                                                                    Package_Code__c = 'NWS02S',
                                                                    Service_Code__c = '[2GBTST,Description]',
                                                                    Contractual_Bolt_Ons__c = '[2GBCON,Description,1250]',
                                                                    Mobile_Number__c = '0123456789',
                                                                    Subscription_Name__c = 'William Heathcote',
                                                                    Effective_Date__c = Date.today());
                                                           
                                                                                                                                  
        subscriptionsExtra.add(ace4);
        
        insert(subscriptionsExtra);
        
        Test.loadData(SOA_Integration_Settings__c.sObjectType, 'TestSOAIntegrationSettings');
		Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
        
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestSuccessGetSubscriptionDetailsBoltOn');
        mock.setStatusCode(200);        
		Test.setMock(HttpCalloutMock.class,mock);
    }

}