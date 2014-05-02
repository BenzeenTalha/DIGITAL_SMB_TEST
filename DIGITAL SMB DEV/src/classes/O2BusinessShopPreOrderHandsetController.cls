public with sharing class O2BusinessShopPreOrderHandsetController {

	public O2_DISE_Ref_Hardware_Portfolio__c hardware {get; set;}
	
	public O2BusinessShopPreOrderHandsetController(O2OnlineMainController mc)
	{
		String prodCode = Apexpages.currentPage().getParameters().get('pc');
		try
		{
			hardware = (prodCode == null) ? new O2_DISE_Ref_Hardware_Portfolio__c()
						: [select id, Hardware_Image_URL__c, Hardware_Description__c, Available_for_PreOrder__c, Product_code__c
							from O2_DISE_Ref_Hardware_Portfolio__c where Product_code__c = :prodCode limit 1];
		}
		catch(exception e)
		{
			hardware = new O2_DISE_Ref_Hardware_Portfolio__c();
		}
	}
	
	public static testMethod void testController()
	{
		O2OnlineMainController omc = new O2OnlineMainController();
		O2BusinessShopPreOrderHandsetController poc = new O2BusinessShopPreOrderHandsetController(omc);
		insert new O2_DISE_Ref_Hardware_Portfolio__c(Name = 'test handset', product_code__c = 'PC0000');
		Test.setCurrentPage(new Pagereference('/apex/O2BusinessShopPreOrderHandset?pc=PC0000'));
		poc = new O2BusinessShopPreOrderHandsetController(omc);
		Test.setCurrentPage(new Pagereference('/apex/O2BusinessShopPreOrderHandset?pc=XX'));
		poc = new O2BusinessShopPreOrderHandsetController(omc);
	}
	
}