public with sharing class DisplayAttributeController {

	public ViewConfigurationController parentController {get; set;}
    public String attributeName {get; set;}
    public String relatedProductName {get; set;}
    public String valueOrDisplayValuePreference {get; set;}

	public DisplayAttributeController() {}
	
    public String getAttributeValue() {
    	cscfgc__Attribute__c attr;
    	String key;
    	
    	if (relatedProductName != null) key = relatedProductName + '|' + attributeName;
    	else key = attributeName;
    	
    	if (parentController.attrMap != null && parentController.attrMap.containsKey(key)) 
    		attr = parentController.attrMap.get(key);
    	String rtnVal = null;
    	//System.debug('@@@RAC get attr '+attributeName+ ' value is ' + attr.+' map size is '+attrMap.size());

		// If attr displayValue is not null use the display value else use the value
		if (attr != null) {
			// CK 01/05/2012: allow preference of display order
			if(valueOrDisplayValuePreference == null || valueOrDisplayValuePreference == 'Display Value') {
				if(attr.cscfgc__Display_Value__c != null) 
					rtnVal = attr.cscfgc__Display_Value__c;
				else
					rtnVal = attr.cscfgc__Value__c;
			} else {
				if(attr.cscfgc__Value__c != null) 
					rtnVal = attr.cscfgc__Value__c;
				else
					rtnVal = attr.cscfgc__Display_Value__c;
			}
		}

    	return rtnVal;	
    }
    
    public static testmethod void testController() {
    	Order__c ord = new Order__c();
    	cscfgc__Product_Configuration__c pc = new cscfgc__Product_Configuration__c();
    	cscfgc__Product_Definition__c pd = [SELECT Id, (Select Id From cscfgc__Attribute_Definitions__r WHERE name = 'Postcode' LIMIT 1) from cscfgc__Product_Definition__c WHERE Name like '%Landline%' LIMIT 1];
    	Account a = [SELECT Id from Account LIMIT 1];
		insert pc;
		cscfgc__Attribute__c attr = new cscfgc__Attribute__c();
		attr.cscfgc__Product_Configuration__c = pc.Id;
		insert attr;
		
		ord.Product_Configuration__c = pc.Id;
    	ord.Account__c = a.Id;
    	insert ord;
    	
        ApexPages.StandardController stc = new ApexPages.StandardController(ord);     
    	ViewConfigurationController parent = new ViewConfigurationController(stc);
    	//parent.

    	Test.setCurrentPage(Page.ProvisioningViewConfiguration);
    	DisplayAttributeController controller = new DisplayAttributeController();
    	controller.parentController = parent;
    	
    	controller.attributeName = 'Postcode';
    	String result = controller.getAttributeValue();
    	
    }
}