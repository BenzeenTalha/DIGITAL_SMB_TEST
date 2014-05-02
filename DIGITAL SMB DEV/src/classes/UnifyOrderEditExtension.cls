/**
 * Extension used on UnifyOrdersEdit page
 * @author: Ivan Tadic (CloudSense)
 * @since:      27/11/2013
**/
public with sharing class UnifyOrderEditExtension {

	//Util properties
	public string orderCompletedStatus {get; set;}
	public string billingStartDateSLA {get; set;}

	//Standard Controller
	public ApexPages.StandardController stdCtrl;

	//SLA's
	public List<SLA__c> slas {get; set;}
	
	//Is Order Placed Date Required
	public boolean IsOPDRequired {get; set;}

	//Constructor
	public UnifyOrderEditExtension(ApexPages.StandardController controller){
		stdCtrl = controller;
		string orderId = stdCtrl.getId();

	 	//Get SLA's
        string slaQuery = 'SELECT ' + Utility.getSobjectFields('SLA__c') + ' FROM SLA__c WHERE Order__c = :orderId AND Tracking_Type__c IN (\'Actual\',\'Target\') ORDER BY Milestone_Order__c';
    	slas = Database.query(slaQuery);

    	//Get utils
    	orderCompletedStatus = UnifyConfiguration__c.getInstance('ORDER_COMPLETED_STATUS').Value__c;
    	billingStartDateSLA = UnifyConfiguration__c.getInstance('BILLING_START_DATE_SLA').Value__c;
    	
    	//IsOPDRequired
    	Order__c o = [SELECT Id, Product_Type__c FROM Order__c WHERE Id = :stdCtrl.getId()];
    	IsOPDRequired = (o.Product_Type__c != 'Maintenance') && (o.Product_Type__c != 'Other') && (o.Product_Type__c != 'Professional Services');
	}

	//Save
	public PageReference Save(){

		//Don't update Target Dates and Statuses if Order Placed Date is changed
		Order__c oNew = (Order__c)stdCtrl.getRecord();
		Order__c oOld = [SELECT Id, Order_Placed_Date__c FROM Order__c WHERE Id = :oNew.Id LIMIT 1];
		boolean orderPlacedChanged = oNew.Order_Placed_Date__c != oOld.Order_Placed_Date__c;

		//Save Order
		PageReference saveReference = stdCtrl.save();

		//Save SLA's
		List<SLA__c> slasForUpdate = new List<SLA__c>();
		for(SLA__c sla : slas){
			SLA__c slaForUpdate = new SLA__c(Id = sla.Id,
											 Actual_Date__c = sla.Actual_Date__c);
			if(!orderPlacedChanged){
				slaForUpdate.Target_Date__c = sla.Target_Date__c;
				slaForUpdate.SLA_Status__c = sla.SLA_Status__c;
			}
			slasForUpdate.add(slaForUpdate);
		}

		if(slasForUpdate.size() > 0)
			update slasForUpdate;

		return saveReference;

	}

	//Cancel
	public PageReference Cancel(){
		return stdCtrl.cancel();
	}

}