@isTest
private class TestViewConfigurationController
{

	private static Account acc {get; set;}
	private static Contact con {get; set;}
	private static Opportunity oppr {get; set;}
	private static cscfgc__Product_Definition__c prodDef {get; set;}
	private static cscfgc__Product_Bundle__c bundle {get; set;}
	private static cscfgc__Product_Configuration__c prodConfig {get; set;}
	private static cscfgc__Configuration_Offer__c offer {get; set;}
	private static String boostboxType='Standard Office';
	private static User u {get; set;}

	public static List<cscfgc__Attribute_Definition__c> createAttributeDefinition(Id prodDefId)
	{
		List<cscfgc__Attribute_Definition__c> attDefList = new List<cscfgc__Attribute_Definition__c>();
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Needs Access List', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Boostbox Type', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Install Building Name', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Install Premise Number', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Install Postcode', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Install Street', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Installation Address Sub Building Name', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Install County', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Install City', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		attDefList.add(new cscfgc__Attribute_Definition__c(Name='Access List', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
		insert attDefList;
		return attDefList;
	}

	static void setupData()
	{
		offer = new cscfgc__Configuration_Offer__c(Name='Test Offer');
		insert offer;

		List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
		TestDataForO2OrderHelper.createRecordTypeForAccount();
		acc = TestDataForO2OrderHelper.createAccount();
		con = TestDataForO2OrderHelper.createContact();
		oppr = TestDataForO2OrderHelper.createOpportunity();

		//
		// Create product definition
		//
		prodDef = new cscfgc__Product_Definition__c();
		prodDef.Name = 'Boostbox';
		prodDef.cscfgc__Description__c = 'Test Helper';
		insert prodDef;

		//
		// Create process template
		//
		CSPOFA__Orchestration_Process_Template__c orchTemp = new CSPOFA__Orchestration_Process_Template__c();
		orchTemp.Name = 'Process for Order Groups';
		orchTemp.CSPOFA__Process_Type__c = 'New Provide';
		insert orchTemp;

		//
		// Create user
		//
        Profile pr = [SELECT Id FROM profile WHERE name='System Administrator'];
        system.assert(pr != null);

        u = new User(alias = 'systema', email='systemadmin@testorgO2Courtesy.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pr.Id,
            timezonesidkey='America/Los_Angeles', username='systemadmin@testorgO2Courtesy.com');
        insert u;

        //
        // Create custom settings
        //
        renderOrderImsiPanel__c panel = new renderOrderImsiPanel__c();
        panel.Name = 'System Administrator';
        insert panel;

		system.debug('prodDef: '+prodDef);
		List<cscfgc__Attribute_Definition__c> prodDefAttr = createAttributeDefinition(prodDef.Id);
		system.debug('prodDefAttr: '+prodDefAttr);

		bundle = createbundle(oppr.Id);
		system.debug('bundle: '+bundle);

		prodConfig = createProductConfiguration(prodDefAttr, bundle.Id, prodDef.Id, offer.Id);
		system.debug('prodConfig1: '+prodConfig);
	}

	// Create the bundle and add it to the supplied opportunity
	public static cscfgc__Product_Bundle__c createbundle(Id oppId)
	{
		// Create a new Bundle for this Opportunity Id
		cscfgc__Product_Bundle__c test_bundle = new cscfgc__Product_Bundle__c();
		Datetime d = system.now();
		String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');
		test_bundle.Name = 'Test Order ' + strDatetime;

		test_bundle.cscfgc__Opportunity__c = oppId;
		test_bundle.cscfgc__Synchronised_with_Opportunity__c = true;
		insert test_bundle;
		return test_bundle;
	}

	public static cscfgc__Product_Configuration__c createProductConfiguration(List<cscfgc__Attribute_Definition__c> prodDefAttribute, Id bundleId, Id prodDefId, Id offerId)
	{

		cscfgc__Attribute_Definition__c[] attdefs = prodDefAttribute;
		//create new configuration
		String strBunId = bundleId;
		String strDefId = prodDefId;
		String strOfferId = offerId;

		cscfgc__Product_Configuration__c config = new cscfgc__Product_Configuration__c();
		config.cscfgc__Product_Bundle__c = strBunId;
		config.cscfgc__Product_Definition__c = strDefId;
		if (offerId != null)
			config.cscfgc__Configuration_Offer__c = strOfferId;
		config.cscfgc__Configuration_Status__c = 'Valid';
		config.cscfgc__Unit_Price__c = 10;
		config.cscfgc__Quantity__c = 1;
		config.cscfgc__Recurrence_Frequency__c = 12;
		insert config;
		String strConfigId = config.Id;
		//create associated attributes
		cscfgc__Attribute__c[] attribs = new cscfgc__Attribute__c[0];
		for (integer i=0; i<attdefs.size(); i++)
		{
			if (attdefs[i].cscfgc__is_Line_Item__c || attdefs[i].cscfgc__Required__c)
			{
				cscfgc__Attribute__c att = new cscfgc__Attribute__c();
				att.cscfgc__Product_Configuration__c = strConfigId;
				att.cscfgc__Attribute_Definition__c = attdefs[i].Id;
				att.Name = attdefs[i].Name;
				att.cscfgc__is_Line_Item__c = attdefs[i].cscfgc__is_Line_Item__c;
				if (attdefs[i].Name=='Needs Access List')
				{
					att.cscfgc__line_item_Description__c = 'test1';
					att.cscfgc__Value__c = 'true';
				}
				else if (attdefs[i].Name=='Boostbox Type')
				{
					att.cscfgc__line_item_Description__c = 'test2';
					att.cscfgc__Value__c = boostboxType;
				}
				else if (attdefs[i].Name=='Install Building Name')
				{
					att.cscfgc__line_item_Description__c = 'test3';
					att.cscfgc__Value__c = 'Towner two';
					att.cscfgc__Recurring__c = true;
				}
				else if (attdefs[i].Name=='Install Premise Number')
				{
					att.cscfgc__line_item_Description__c = 'test4';
					att.cscfgc__Value__c = '438';
				}
				else if (attdefs[i].Name=='Install Postcode')
				{
					att.cscfgc__line_item_Description__c = 'test5';
					att.cscfgc__Value__c = 'Sl1 1XL';
				}
				else if (attdefs[i].Name=='Install Street')
				{
					att.cscfgc__line_item_Description__c = 'test6';
					att.cscfgc__Value__c = '26 Street';
				}
				else if (attdefs[i].Name=='Access List')
				{
					att.cscfgc__line_item_Description__c = 'test7';
					att.cscfgc__Value__c = '123456,2345678,3456789,748848484,8382828,95949,83838,8383838,74747272,82828,83839,26262';
				}
				att.cscfgc__is_Active__c = true;
				attribs.add(att);
			}
		}
		insert attribs;
		return config;
	}

	static testmethod void testController()
	{
		setupData();
		Order__c ord = new Order__c();
		cscfgc__Product_Configuration__c pc = new cscfgc__Product_Configuration__c();
		Account a = [SELECT Id from Account LIMIT 1];
		insert pc;
		cscfgc__Attribute__c attr = new cscfgc__Attribute__c();
		attr.cscfgc__Product_Configuration__c = pc.Id;
		insert attr;

		ord.Product_Configuration__c = pc.Id;
		ord.Account__c = a.Id;
		insert ord;

		ApexPages.StandardController stc = new ApexPages.StandardController(ord);
		ViewConfigurationController testcontroller = new ViewConfigurationController(stc);

		Test.setCurrentPage(Page.ProvisioningViewConfiguration);
		testcontroller.orderId = ord.Id;
		testcontroller.loadConfiguration();

		//testcontroller.getController();
		testcontroller.attributeName = 'Postcode';
		String result = testcontroller.getAttributeValue();
		testcontroller.navBack();
	}

	static testMethod void getRadioProvParmsTest()
	{
		setupData();

		//System.runAs(u)
		//{
			Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id, Order_Group_Status__c = 'In progress');
			insert newOG;
			Order__c newOrder = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
					Account__c = acc.id, Order_Status__c = '', Order_Status_Reason__c = '',
					Product_Configuration__c=prodConfig.Id, DISE_Order_No__c='123', CSR_No__c='123');
			insert newOrder;

			// Note: system admin profile must be included in the custom settings of ALU profiles (renderOrderImsiPanel__c)
			ApexPages.StandardController stc = new ApexPages.StandardController(newOrder);
			ViewConfigurationController testcontroller = new ViewConfigurationController(stc);

			Test.startTest();
			Test.setCurrentPage(Page.ProvisioningViewConfiguration);
			testcontroller.getRadioProvParms();

			testcontroller.orderId = newOrder.Id;
			testcontroller.loadConfiguration();

			system.debug(LoggingLevel.INFO,'****LAC'+testcontroller.lac);

			System.debug(LoggingLevel.INFO,'Current User: ' + UserInfo.getUserName());
			System.debug(LoggingLevel.INFO,'Current Profile: ' + UserInfo.getProfileId());
			system.assert(testcontroller.lac!=null);
			system.assert(testcontroller.sac!=null);
			system.assert(testcontroller.rac!=null);
			system.assert(testcontroller.lat!=null);
			system.assert(testcontroller.longi!=null);

			Test.stopTest();

			// test error
			testcontroller.testSOAFault=true;
			testcontroller.getRadioProvParms();
			System.debug(LoggingLevel.INFO,'****pageMsgs'+ApexPages.getMessages());
			system.assert(ApexPages.hasMessages()); // No error messages

			// test render IMSI panel setting
			system.assert(testcontroller.RenderImsiPanel);
			// test installation type
			system.assert(testcontroller.getBoostboxInstallationType()!=null);
		//}
	}


	static testMethod void getIMSIsTest()
	{
		setupData();

		Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id, Order_Group_Status__c = 'In progress');
		insert newOG;
		Order__c newOrder = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Order_Status_Reason__c = '',
				Product_Configuration__c=prodConfig.Id, DISE_Order_No__c='123');
		insert newOrder;

		ApexPages.StandardController stc = new ApexPages.StandardController(newOrder);
		ViewConfigurationController testcontroller = new ViewConfigurationController(stc);
		testcontroller.orderId = newOrder.Id;
		testcontroller.loadConfiguration();
		Test.setCurrentPage(Page.ProvisioningViewConfiguration);

		String userProfile=testcontroller.userProfile;
		system.assert(userProfile!=null);
		boolean showIMSI=testcontroller.showIMSI;
		system.assert(showIMSI!=null);

		Test.startTest();
		PageReference newPage = testcontroller.processAccessList();
		System.debug('****getIMSIsTest: new page1:'+ApexPages.getMessages());
		system.assert(!ApexPages.hasMessages()); // no error messages

		system.assert(testcontroller.imsiListStr.length()>0);
		system.assert(testcontroller.showIMSI);
		system.assert(testcontroller.moreIMSI>0);
		system.assertEquals(testcontroller.totalFetched, 10);

		// fetch more
		testcontroller.fetchIMSIMore();
		//System.debug('****getIMSIsTest: new page2:'+ApexPages.getMessages());
		//system.assert(!ApexPages.hasMessages()); // no error messages

		system.assert(testcontroller.imsiListStr.length()>0);
		system.assert(testcontroller.totalFetched>10);
		Test.stopTest();

	}
	static testMethod void getIMSIsFaultTest()
	{
		setupData();

		Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id, Order_Group_Status__c = 'In progress');
		insert newOG;
		Order__c newOrder = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Order_Status_Reason__c = '',
				Product_Configuration__c=prodConfig.Id, DISE_Order_No__c='123');
		insert newOrder;

		ApexPages.StandardController stc = new ApexPages.StandardController(newOrder);
		ViewConfigurationController testcontroller = new ViewConfigurationController(stc);
		testcontroller.orderId = newOrder.Id;
		testcontroller.loadConfiguration();
		Test.setCurrentPage(Page.ProvisioningViewConfiguration);

		testcontroller.testSOAFault=true;
		Test.startTest();

		PageReference newPage = testcontroller.processAccessList();
		System.debug('****new page'+ApexPages.getMessages());
		system.assert(ApexPages.hasMessages()); // error messages

		Test.stopTest();

	}

	static testMethod void getOrderCSREnterDISETest()
	{
		setupData();

		Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id, Order_Group_Status__c = 'In progress');
		insert newOG;
		Order__c newOrder = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Order_Status_Reason__c = '',
				Product_Configuration__c=prodConfig.Id, DISE_Order_No__c=null);
		insert newOrder;

		Test.startTest();
		String result=BoostboxWS.updateOrderCSR(newOrder.Id);
		Test.stopTest();

		system.assertEquals(result,'Please enter DISE Order No');
		Order__c fisOrdNew=[select id, DISE_Order_No__c, CSR_No__c from Order__c where id=:newOrder.Id];
		system.debug('***fisOrdNew: '+fisOrdNew);
		system.assert(fisOrdNew.CSR_No__c==null);
	}

	static testMethod void getOrderCSRUpdateTest()
	{
		setupData();

		Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id, Order_Group_Status__c = 'In progress');
		insert newOG;
		Order__c newOrder = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Order_Status_Reason__c = '',
				Product_Configuration__c=prodConfig.Id, DISE_Order_No__c='123');
		insert newOrder;

		Test.startTest();
		String result=BoostboxWS.updateOrderCSR(newOrder.Id);
		Test.stopTest();

		system.assertEquals(result,'Success');

		Order__c fisOrdNew=[select id, DISE_Order_No__c, CSR_No__c from Order__c where id=:newOrder.Id];
		system.debug('***fisOrdNew: '+fisOrdNew);
		system.assert(fisOrdNew.CSR_No__c!=null);
	}
	static testMethod void getOrderCSRUpdateTest2()
	{
		boostboxType='Larger Office';
		setupData();

		Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id, Order_Group_Status__c = 'In progress');
		insert newOG;
		Order__c newOrder = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Order_Status_Reason__c = '',
				Product_Configuration__c=prodConfig.Id, DISE_Order_No__c='123');
		insert newOrder;

		Test.startTest();
		String result=BoostboxWS.updateOrderCSR(newOrder.Id);
		Test.stopTest();

		system.assertEquals(result,'Success');

		Order__c fisOrdNew=[select id, DISE_Order_No__c, CSR_No__c from Order__c where id=:newOrder.Id];
		system.debug('***fisOrdNew: '+fisOrdNew);
		system.assert(fisOrdNew.CSR_No__c!=null);
	}
	static testMethod void getOrderCSRFaultTest()
	{
		setupData();

		Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id, Order_Group_Status__c = 'In progress');
		insert newOG;
		Order__c newOrder = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Order_Status_Reason__c = '',
				Product_Configuration__c=prodConfig.Id, DISE_Order_No__c='123');
		insert newOrder;

		Test.startTest();
		//BoostboxWS bws= new BoostboxWS();
		BoostboxWS.testFault=true;
		String result=BoostboxWS.updateOrderCSR(newOrder.Id);
		Test.stopTest();

		system.assert(result.contains('Error'));

		Order__c fisOrdNew=[select id, DISE_Order_No__c, CSR_No__c from Order__c where id=:newOrder.Id];
		system.debug('***fisOrdNew: '+fisOrdNew);
		system.assert(fisOrdNew.CSR_No__c==null);
	}
}