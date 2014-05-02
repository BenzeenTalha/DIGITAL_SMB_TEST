@isTest
public class TestBoostobxOrdersSearchController {
	public static testMethod void controllerTest(){
		BoostboxOrdersSearchController controller = new BoostboxOrdersSearchController();
		controller.getorderStatuses();
		controller.searchText = 'a';
		controller.search();
	}
}