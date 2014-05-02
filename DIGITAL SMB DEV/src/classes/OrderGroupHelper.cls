public with sharing class OrderGroupHelper {
	
	public static void assignProjectCoordinator (Order_Group__c og){
		
		List <Order__c> ords = [select Id,Assignee__c from Order__c where Order_Group__r.Id = : og.Id];
			
		for (integer i = 0; i < ords.size(); ++i) {
			ords[i].Assignee__c = og.Unify_Project_Coordinator__c;
		}
		og.Unify_Installation_Status__c = 'In Progress';
		OrderHelper.orderUpdatedFromOrderGroup = true;
		update ords;
	}
}