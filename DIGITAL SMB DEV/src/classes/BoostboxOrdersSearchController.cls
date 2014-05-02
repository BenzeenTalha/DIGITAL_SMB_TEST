public class BoostboxOrdersSearchController {
	public static final List<String> searchfields = new List<String>{'Name', 'Order_Number__c', 'Order_Status__c', 'Main_Contact__r.Name', 'Boostbox_Serial_No__c', 'DISE_Order_No__c', 'CSR_No__c', 'Installation_Zip_Postal_Code__c'};
	public static final Integer recordLimit = 20;
	public static final String queryBase = 'Select Id, CreatedDate ';
	public static final String queryObject = ' from Order__c where Product_Type__c = \'Boostbox\' AND (';	
	public static final String queryLimit = ' Limit ' + (recordLimit + 1);
	public static final String queryOrder = ' order by Name, Order_Status__c';
	public List<Order__c> ordersList{get;set;}
	public String searchText{get;set;}
	public String selectedOrderStatus{get;set;}
	
	public List<SelectOption> getorderStatuses(){
		List<SelectOption> picklistOptions = new List<SelectOption>();  
		List<Schema.PicklistEntry> reasonPicklistValues = Order__c.Order_Status__c.getDescribe().getPicklistValues();  
		for(Schema.PicklistEntry entry : reasonPicklistValues){  
			picklistOptions.add(new SelectOption(entry.getLabel(), entry.getValue()));  
		}
		return picklistOptions;
	}
	public BoostboxOrdersSearchController(){
		selectedOrderStatus = 'Radio Provisioning';
	}
	public void search(){
		String query = queryBase;
		
		for(String field : searchFields){
			query += ', ' + field;
		}
		query += queryObject;
		//query += ' Order_Status__c = \'' + selectedOrderStatus + '\' AND (';
		for(String field : searchFields){
			query += field + ' LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' OR  ';
		}
		
		//remove last OR
		query = query.substring(0, query.length() - 4);
		
		query += ')';
		query += queryOrder;
		query += queryLimit;
			
		System.debug(query);
		
		ordersList = Database.query(query);
		if(ordersList.size() > recordLimit){
			ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.INFO, 'More than 20 rows found, please refine your search.');
        	ApexPages.addMessage(msg1);                         
		}else if(ordersList.size() == 0){
			ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING, 'No records found, please refine your search.');
        	ApexPages.addMessage(msg1);
        	ordersList = null;                 
		}  
	}
}