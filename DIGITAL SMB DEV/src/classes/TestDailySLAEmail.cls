@isTest(SeeAllData=true)
private class TestDailySLAEmail {

    
    static testmethod void testCase(){
        
    test.startTest();
    
	DailySLAEmail slaE = new DailySLAEmail();
	String schedule = '0 0 23 * * ?';
	system.schedule('Daily SLA Email', schedule, slaE);
	
	test.stopTest();
    }
}