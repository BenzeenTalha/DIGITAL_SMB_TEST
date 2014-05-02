public with sharing class CreateMacOpportunityController {
	private Order__c order;
    //
	// Controller
    public CreateMacOpportunityController(ApexPages.StandardController stdController) {
        this.order = (Order__c)stdController.getRecord();
        this.order = getOrderAndRelatedLists(this.order.Id); 
    }   
                
    // Get a order and its related lists
    public static Order__c getOrderAndRelatedLists(String orderId) {
        String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('Order__c')+
        	', (select '+Utility.getSobjectFields('Order_Line_Item__c')+
        		' from Order_Line_Items__r where Payment_Frequency__c = \'Recurring\'), '+
        	' (select '+Utility.getSobjectFields('Order__c')+' from secondary_orders__r) '+
            ' from Order__c where ID = \''+orderId+'\'';
        List <Order__c> orderToLineItemsList = Database.query(queryString);
        Map <ID,Order__c> orderToLineItemsMap = new Map <ID,Order__c> ();
        for (Order__c svc : orderToLineItemsList) {
            orderToLineItemsMap.put(svc.Id,svc);
        }
        return orderToLineItemsMap.get(orderId);
    }    
	 
    //
	// Create a new opportunity
	public PageReference createRenewalOpportunity() {
		// Create an Opportunity
		Opportunity newOpp = new Opportunity(Name                          = order.Name,
											 Type                          = 'Existing Business',
											 AccountId                     = order.Account__c,
											 Order_To_Be_Replaced__c       = order.Id,
											 StageName                     = 'Awareness of Needs',
											 CloseDate                     = date.today().addMonths(1)
										  );
		insert newOpp;
		//
		// Create an empty bundle against this opportunity
		cscfgc__Product_Bundle__c newBundle = new cscfgc__Product_Bundle__c(Name = 'Regrade: '+order.Name,
							   												cscfgc__Opportunity__c = newOpp.Id, 
							   												cscfgc__Bundle_Status__c = 'Valid');
		insert newBundle;
		//
		// Clone the configuration associated with the Order being replaced and associate it to this bundle
		ProductBundleManager.copyConfigAndChildrenToBunlde(order.Product_Configuration__c,newBundle.Id);
		// ---------------------------------------------------------------
		// Synchronise the newly created bundle with the opportunity 
		ApexPages.StandardController stdController = new ApexPages.StandardController(newBundle);
		ProductBundleController ctrl = new ProductBundleController(stdController);
		PageReference oppDetailsPage = ctrl.syncWithOpportunity();
        // Go to the newly created opportunity using the page reference returned from the sync method
        oppDetailsPage.setRedirect(true);
        return oppDetailsPage;
	}
}