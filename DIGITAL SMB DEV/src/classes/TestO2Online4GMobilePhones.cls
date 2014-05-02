@isTest(seealldata=true)
private class TestO2Online4GMobilePhones {

    static testMethod void testController() {

		O2OnlineMainController controller = new O2OnlineMainController();
		Test.startTest();
		O2Online4GMobilePhones extension = new O2Online4GMobilePhones(controller);
		string json = extension.getJsonArray;
		Test.stopTest();
    }
}