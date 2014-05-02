public with sharing class UnifyEditAllSitesController {
	public List<Unify_Site__c> sitesList{get;set;}
	public Order_Group__c orderGroup{get;set;}
	public UnifyEditAllSitesController(ApexPages.StandardController contr){
		sitesList = new List<Unify_Site__c>();
		orderGroup = (Order_Group__c)contr.getRecord();
		sitesList = [Select Id, Name, Full_Address__c, DISE_Account_No__c, Group_Code__c, Corporate_Code__c, Cost_Centre__c, Solution__c, Supplier_Purchase_Order__c, Customer_Purchase_Order__c from Unify_Site__c where Order_Group__c = :orderGroup.Id];
	}
	public PageReference save(){
		try{
			update sitesList;
		}catch(Exception e){
			return null;
		}

		return new PageReference('/' + orderGroup.Id);
	}
	public PageReference cancel(){
		return new PageReference('/' + orderGroup.Id);
	}
}