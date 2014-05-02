@isTest
private class TestUnifyTaskCloseController {
	private static testMethod void test(){
		Task t = new Task();
		insert t;
		ApexPages.StandardController stdController = new ApexPages.StandardController(t);
		UnifyTaskCloseController contr = new UnifyTaskCloseController(stdController);

		contr.closeTask();
	}
	private static testMethod void test2(){
		Task t = new Task();
		t.Unify_Completed_Date__c = System.today();
		insert t;
		ApexPages.StandardController stdController = new ApexPages.StandardController(t);
		UnifyTaskCloseController contr = new UnifyTaskCloseController(stdController);

		contr.closeTask();
	}
}