/*
* 1st Aug : To create configuration request records from product configuration. Methods used for Bulk Order Load and Online shop
*/
public class ConfigurationRequestUtils {

	//Pass the bundle id as a parameter for which the product configurations have already been created.
	// This method creates configuration request record for each product config record.
	public static void createConfigurationRequest(Id bundleId){
		List<Configuration_Request__c> configRequestList = new List<Configuration_Request__c>();

		System.debug('*********************** bundle I:  '+bundleId);
		List<cscfgc__Product_Configuration__c> configList = [SELECT id, cscfgc__Product_Definition__c,cscfgc__Parent_Configuration__c from cscfgc__Product_Configuration__c WHERE cscfgc__Product_Bundle__c = :bundleId];

		// Get product Map keyed by product id
    	Map<String,String> productMap = getproductMap();

		for(Integer i=0; i<configList.size(); i++){
			if(configList[i].cscfgc__Parent_Configuration__c == null){
				Configuration_Request__c configReq = new Configuration_Request__c();
				configReq.Product_Bundle__c = bundleId;
				configReq.Product_Configuration__c = configList[i].Id;
				configReq.Product_Definition__c = configList[i].cscfgc__Product_Definition__c;
				configReq.Product_Name__c =	productMap.get(configList[i].cscfgc__Product_Definition__c);

				if(productMap.get(configList[i].cscfgc__Product_Definition__c) == 'SMB Landline' || productMap.get(configList[i].cscfgc__Product_Definition__c) == 'SMB Calls Only'){
					configReq.Product_Category__c = 'SMB Fixed Line';
				}

				if(productMap.get(configList[i].cscfgc__Product_Definition__c) == 'SMB Business Broadband'){
					configReq.Product_Category__c = 'Business Broadband';
				}
				configRequestList.add(configReq);
			}
		}
		SaveConfigurationRequest(configRequestList);
	}

	private static void SaveConfigurationRequest(List<Configuration_Request__c> configRequestList){
		if(configRequestList != null)
		{
			insert configRequestList;
		}
	}

	// Get product Map keyed by product name
    private static Map<String,String> getproductMap() {
    	List<cscfgc__Product_Definition__c> productDefList = [select Id, Name from cscfgc__Product_Definition__c];
    	//
    	Map<String,String> productMap = new Map<String,String>();
    	for (cscfgc__Product_Definition__c prod : productDefList) {
    		productMap.put(prod.Id, prod.Name);
    	}
    	//
    	return productMap;
    }
}