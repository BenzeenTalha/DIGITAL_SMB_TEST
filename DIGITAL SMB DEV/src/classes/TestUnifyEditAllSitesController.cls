@isTest
private class TestUnifyEditAllSitesController {
	private static testMethod void testController(){
		Order_Group__c og = TestUnifyHelper.createOrderGroup();

		ApexPages.StandardController sc = new ApexPages.StandardController(og);
		UnifyEditAllSitesController contr = new UnifyEditAllSitesController(sc);
		contr.save();
		contr.cancel();

		contr.sitesList.add(new Unify_Site__c());
		contr.save();
	}
}