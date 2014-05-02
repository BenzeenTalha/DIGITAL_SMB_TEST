@IsTest
public class TestDeleteOffice365SalesReport {
	
	@IsTest
	static void testBatch() {
		insert new Sales_Report_O365__c[] {
			new Sales_Report_O365__c(),
			new Sales_Report_O365__c(),
			new Sales_Report_O365__c()
		};
		
		// custom setting value
		insert new BatchSize__c(SetupOwnerId = UserInfo.getUserId(), DeleteOffice365SalesReport__c = 50);
		
		Test.startTest();
		
		DeleteOffice365SalesReport job = new DeleteOffice365SalesReport();
		job.execute(null);
		
		Test.stopTest();
		
		Sales_Report_O365__c[] reportData = [select Id from Sales_Report_O365__c];
		system.assertEquals(0, reportData.size());
	}

}