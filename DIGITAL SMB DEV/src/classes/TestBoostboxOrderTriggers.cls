/**
 * This class contains unit tests for boostbox order and order group triggers.
 */
@isTest
private class TestBoostboxOrderTriggers
{
	private static Account acc {get; set;}
	private static Contact con {get; set;}
	private static Opportunity oppr {get; set;}
	private static List<CSPOFA__Orchestration_Process_Template__c> orchTemps { get; set; }

	static void setupData()
	{
		List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
		TestDataForO2OrderHelper.createRecordTypeForAccount();
		acc = TestDataForO2OrderHelper.createAccount();
		con = TestDataForO2OrderHelper.createContact();
		oppr = TestDataForO2OrderHelper.createOpportunity();
		orchTemps = createOrchestrationProcessTemplates();
	}

	static List<CSPOFA__Orchestration_Process_Template__c> createOrchestrationProcessTemplates()
	{
		List<CSPOFA__Orchestration_Process_Template__c> orchestrationTemplates =
			new List<CSPOFA__Orchestration_Process_Template__c>();

		CSPOFA__Orchestration_Process_Template__c orchTemp;
	    orchTemp = new CSPOFA__Orchestration_Process_Template__c();
		orchTemp.Name = 'Boostbox Order Group';
		orchTemp.CSPOFA__Process_Type__c = 'New Provide';
		orchestrationTemplates.add(orchTemp);

		orchTemp = new CSPOFA__Orchestration_Process_Template__c();
		orchTemp.Name = 'Boostbox Provisioning';
		orchTemp.CSPOFA__Process_Type__c = 'New Provide';
		orchestrationTemplates.add(orchTemp);

		insert orchestrationTemplates;
		return orchestrationTemplates;
	}

	static testMethod void boostboxOrderGroupCompletedTest()
	{
		setupData();

		Schema.DescribeSObjectResult d = Schema.SObjectType.Order_Group__c;
		Map<String, Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
		Schema.RecordTypeInfo rtByName =  rtMapByName.get('Boostbox');
		System.debug(LoggingLevel.INFO, '***og recordtype'+rtByName);

		Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id,
				RecordTypeId = rtByName.getRecordTypeId(), Order_Group_Status__c = 'In progress');
		insert newOG;

		Order__c newOrder1 = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Product_Type__c = 'Boostbox');
		insert newOrder1;
		Order__c newOrder2 = new Order__c (Opportunity__c = oppr.id, Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Product_Type__c = 'Boostbox');
		insert newOrder2;

        Test.startTest();
		// Test making one order Active does NOT make Order Group Complete
		newOrder1.Order_Status__c = 'Active';
		update newOrder1;

		Order_Group__c ogNew = [SELECT id, Name, Status__c, OwnerId
			FROM Order_Group__c
			WHERE id = :newOG.id];
		system.assertNotEquals(ogNew.Status__c, 'Completed');

		// Test making final order Active DOES make Order Group Complete
		newOrder2.Order_Status__c = 'Active';
		update newOrder2;

		ogNew = [SELECT id, Name, Status__c, OwnerId
			FROM Order_Group__c
			WHERE id = :newOG.id];
		system.assertEquals(ogNew.Status__c, 'Completed');
	}

	static testMethod void boostboxOrderGroupTriggerTest()
	{
		setupData();

		Schema.DescribeSObjectResult d = Schema.SObjectType.Order_Group__c;
		Map<String, Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
		Schema.RecordTypeInfo rtByName = rtMapByName.get('Boostbox');
		System.debug(LoggingLevel.INFO, '***og recordtype'+rtByName);

		Order_Group__c newOG = new Order_Group__c(Opportunity__c = oppr.id,
				RecordTypeId = rtByName.getRecordTypeId(), Order_Group_Status__c = 'In progress');
		insert newOG;
		newOG.Status__c = 'Completed';

		update newOG;

		CSPOFA__Orchestration_Process__c orch = [SELECT Name
			FROM CSPOFA__Orchestration_Process__c
			WHERE Order_Group__c = :newOG.id];

		system.assertEquals(orch.Name, 'Boostbox Order Group');
	}

	static testMethod void boostboxOrderTriggerTest()
	{
		setupData();

		Order__c newOrder = new Order__c (Opportunity__c = oppr.id, //Order_Group__c = newOG.id,
				Account__c = acc.id, Order_Status__c = '', Product_Type__c = 'Boostbox');
		insert newOrder;

		CSPOFA__Orchestration_Process__c orch = [SELECT Name
			FROM CSPOFA__Orchestration_Process__c
			WHERE Order__c = :newOrder.id];

		system.assertEquals(orch.Name, 'Boostbox Provisioning');
	}

	static testMethod void boostboxOrderBulkTest()
	{
		setupData();

			// Bulk test
		List<Order__c> ords = new List<Order__c>();
		Integer ordCount = 0;
		while (ordCount < 200)
		{
			ords.add(new Order__c (Opportunity__c = oppr.id, //Order_Group__c = newOG.id,
					Account__c = acc.id, Order_Status__c = '', Product_Type__c = 'Boostbox'));
			ordCount++;
		}
		insert ords;
	}

	static testMethod void boostboxOGBulkTest()
	{
		setupData();

		Schema.DescribeSObjectResult d = Schema.SObjectType.Order_Group__c;
		Map<String, Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
		Schema.RecordTypeInfo rtByName =  rtMapByName.get('Boostbox');
		System.debug(LoggingLevel.INFO, '***og recordtype'+rtByName);

		// Bulk test
		List<Order_Group__c> ogs = new List<Order_Group__c>();
		Integer ordCount = 0;
		while (ordCount < 200)
		{
			ogs.add(new Order_Group__c(Opportunity__c = oppr.id,
					RecordTypeId = rtByName.getRecordTypeId(), Order_Group_Status__c = 'In progress'));
			ordCount++;
		}
		insert ogs;

		// ensure no Orchestration records
		List<CSPOFA__Orchestration_Process__c> delOrchList = [SELECT id
			FROM CSPOFA__Orchestration_Process__c];
		delete delOrchList;

		for(Order_Group__c og : ogs)
		{
			og.Status__c = 'Completed';
		}
		update ogs;

		List<CSPOFA__Orchestration_Process__c> orchList = [SELECT Name, Order_Group__c, Order_Group__r.Status__c FROM CSPOFA__Orchestration_Process__c];
		system.assertEquals(orchList.size(), 200);
		system.assertEquals(orchList[0].Order_Group__r.Status__c, 'Completed');
	}
}