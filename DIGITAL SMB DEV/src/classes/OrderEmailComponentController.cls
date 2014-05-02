public with sharing class OrderEmailComponentController {

	public Id orderId {get; set;}
	public Order__c newOrder {get; private set;}

	public OrderEmailComponentController() { }

	public Boolean getFindOrder()
	{
		if(orderId != null)
		{
			newOrder = [Select DISE_Order_No__c,
							DISE_Account_Number__c,
							Customer_Order_Start_date__c,
							Customer_Order_End_Date__c,
							Order_Status__c,
							Order_Number__c,
							Account__r.Name,
								(Select Name,
								Cost__c,
								Discount_Amount__c,
								List_Price__c,
								Package_Code__c,
								Product_Code__c,
								Quantity__c,
								Total_Price__c
								From Order_Line_Items__r)
							From Order__c
							Where Id = :orderId];
			return false;
		}
		else
		{
			newOrder = new Order__c();
		}
		return true;
	}

	public String getSfInstance()
	{
	  return URL.getSalesforceBaseUrl().toExternalForm();
	}

}