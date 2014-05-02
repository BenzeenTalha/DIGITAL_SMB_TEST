@IsTest
public class TestCalculateO365SalesReportDefault {

	@IsTest
	static void testBatch() {
		Account acc = new Account(Name = 'Test acc.');
        insert acc;
        
        Opportunity opp = new Opportunity(AccountId = acc.Id, StageName = 'Open', Name = 'Test', CloseDate = Date.today());
        insert opp;
        
        O2_Product_Detail__c prodDetail1 = new O2_Product_Detail__c(Opportunity__c = opp.Id, Product__c = 'Office 365', Quantity__c = 4,
        										Total_Contract_Value__c = 100.0);
		O2_Product_Detail__c prodDetail2 = new O2_Product_Detail__c(Opportunity__c = opp.Id, Product__c = 'Office 365 Consultation', Quantity__c = 1,
        										Total_Contract_Value__c = 150.0);
        										
        insert new O2_Product_Detail__c[] { prodDetail1, prodDetail2 };
        
        // custom setting value
		insert new BatchSize__c(SetupOwnerId = UserInfo.getUserId(), CalculateO365SalesReportDefault__c = 50);
		
        Test.startTest();
        
        CalculateO365SalesReportDefault job = new CalculateO365SalesReportDefault();
        job.execute(null);
        
        Test.stopTest();
        
        Sales_Report_O365__c[] reportData = [select Id, Account__c, O2_Product_Detail__c, Display_Name__c,
                                                 Opportunity__c, Opportunity_Type__c, Quantity__c
                                             from Sales_Report_O365__c];
        system.assertEquals(2, reportData.size());
        
        system.assertEquals(acc.Id, reportData[0].Account__c);
        system.assertEquals(prodDetail1.Id, reportData[0].O2_Product_Detail__c);
        system.assertEquals(prodDetail1.Product__c, reportData[0].Display_Name__c);
        system.assertEquals(opp.Id, reportData[0].Opportunity__c);
        system.assertEquals('Default', reportData[0].Opportunity_Type__c);
        system.assertEquals(prodDetail1.Quantity__C, reportData[0].Quantity__c);
	}

}