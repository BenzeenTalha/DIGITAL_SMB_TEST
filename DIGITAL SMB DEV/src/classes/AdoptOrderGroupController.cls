public with sharing class AdoptOrderGroupController {
	private Order_Group__c orderGroup; 
    //
	// Constructor
    public AdoptOrderGroupController(ApexPages.StandardController stdController) {
        this.orderGroup = (Order_Group__c)stdController.getRecord();
    }
	
	// Adopt all the orders in the group by assigning the current user as the 
	// provisioning Agent
	public PageReference adoptOrderGroup() {
		// Select all orders belonging to this order group
		orderGroup = [select Id, Provisioning_Agent__c, Adopted__c, Provisioning_Agent_Assigned__c, 
							(select Id, Provisioning_Agent__c, Provisioning_Agent_Assigned__c from Orders__r) 
					  from Order_Group__c where id = :OrderGroup.Id 
					  limit 1];
		//
		orderGroup.Provisioning_Agent__c = UserInfo.getUserId();
		orderGroup.Provisioning_Agent_Assigned__c = True;
		orderGroup.Adopted__c = True;
		//
		for (Order__c order : orderGroup.orders__r) {
			order.Provisioning_Agent__c = UserInfo.getUserId();
			order.Provisioning_Agent_Assigned__c = True;
		}
		//
		update orderGroup.orders__r;
		update orderGroup;
	    // ---------------------------------------------------------------
		//
        // Go back to the order group
        PageReference orderGroupPage = new PageReference('/'+orderGroup.Id);
        orderGroupPage.setRedirect(true);
        return orderGroupPage;  
	}
}