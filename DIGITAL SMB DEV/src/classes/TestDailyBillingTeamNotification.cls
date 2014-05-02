@isTest
private class TestDailyBillingTeamNotification {

    static testMethod void myUnitTest() {
        //Insert records
        TestUnifyHelper.setupCustomSettings();
        Order_Group__c og1 = TestUnifyHelper.createOrderGroup();
    	Unify_Site__c siteRed = new Unify_Site__c(Name = 'Test Site Red',
    										   Order_Group__c = og1.Id,
    										   Added_to_Billing_System_RAG_Status__c = 'Red',
    										   Added_to_Billing_System_Target_Date__c = DateTime.now().addDays(-1),
    										   Solution__c = 'MWAN',
    										   Ready_for_Billing__c = true);
    	Unify_Site__c siteAmber = new Unify_Site__c(Name = 'Test Site Amber',
    										   Order_Group__c = og1.Id,
    										   Added_to_Billing_System_RAG_Status__c = 'Amber',
    										   Added_to_Billing_System_Target_Date__c = DateTime.now().addDays(1),
    										   Solution__c = 'MWAN',
    										   Ready_for_Billing__c = true);
    	insert siteRed;
    	insert siteAmber;

        test.startTest();

		DailyBillingTeamNotification btn = new DailyBillingTeamNotification();
		DailyBillingTeamNotification.scheduleMe();
		String schedule = '0 0 23 * * ?';
		system.schedule('Daily SLA Email', schedule, btn);
		Map <Id, List<Unify_Site__c>> ogSites =  DailyBillingTeamNotification.getSites();
    	if (!ogSites.isEmpty()) {
    		DailyBillingTeamNotification.sendEmail(ogSites);
    	}

		test.stopTest();
    }

    static testMethod void testSendRedAmberSiteSlas(){
    	//Insert Records
    	Order_Group__c og = TestUnifyHelper.createOrderGroup();
    	Unify_Site__c siteRed = new Unify_Site__c(Name = 'Test Site Red',
    										   Order_Group__c = og.Id,
    										   Added_to_Billing_System_RAG_Status__c = 'Red',
    										   Added_to_Billing_System_Target_Date__c = DateTime.now().addDays(-1),
    										   Solution__c = 'MWAN');
    	Unify_Site__c siteAmber = new Unify_Site__c(Name = 'Test Site Amber',
    										   Order_Group__c = og.Id,
    										   Added_to_Billing_System_RAG_Status__c = 'Amber',
    										   Added_to_Billing_System_Target_Date__c = DateTime.now().addDays(1),
    										   Solution__c = 'MWAN');
    	insert siteRed;
    	insert siteAmber;
    	TestUnifyHelper.setupCustomSettings();

    	test.startTest();
    	DailyBillingTeamNotification.sendRedAmberSiteSlas();
    	test.stopTest();
    }

}