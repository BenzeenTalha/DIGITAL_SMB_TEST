public class O2RepeatLineItemsController {

	cscfgc.RepeatLineItemsController lineItemController = new cscfgc.RepeatLineItemsController();
	public cscfgc__Product_Configuration__c config {get;set;}
	public String AttributeCategory {
		get {if (AttributeCategory == null) return ''; else return AttributeCategory;}
		set;
	}
	
	public class OnlineLineItem {
		public cscfgc.LineItem lineitem {get;set;}
		public String category {get;set;}
		public Boolean display {get;set;}
		public OnlineLineItem(cscfgc.LineItem li, String s, Boolean b) {
			lineitem = li;
			category = s;
			display = b;
		}
	}
	
	public Map<String, OnlineConfiguratorSettings__c> cfgSettings {
		get {
			if (cfgSettings!=null && cfgSettings.size()>0) return cfgSettings;
			else {
				if (OnlineConfiguratorSettings__c.getInstance() != null) {
					Map<String, OnlineConfiguratorSettings__c> retSettings = new Map<String, OnlineConfiguratorSettings__c>();
					for (OnlineConfiguratorSettings__c cfg: OnlineConfiguratorSettings__c.getAll().values()) {
						//String cat = cfg.Category__c!=null ? cfg.Category__c : '';
						retSettings.put(cfg.Attribute_Name__c, cfg);
					}
					return retSettings;
				}
				else return null;
			}
		}
		set;
	}
	
	public List<OnlineLineItem> getLineItems() {
		List<OnlineLineItem> retItems = new List<OnlineLineItem>();
		List<cscfgc.LineItem> prodItems;
		if (lineItemController!=null && config!=null) {
			lineItemController.config = this.config;
			prodItems = lineItemController.getLineItems();
		}
		if (prodItems!=null) {
			for (cscfgc.LineItem l: prodItems) {
				String strCat = '';
				Boolean boolDisplay = true;
				//get line item name for matching
				String attribName = config.cscfgc__Product_Definition__r.Name + '.' + l.getAttribute().Name;
				//get category and display from Custom Setting for matching attrib name
				if (cfgSettings!=null && cfgSettings.size()>0 && attribName!=null && cfgSettings.containsKey(attribName)) {
					strCat = cfgSettings.get(attribName).Category__c!=null ? cfgSettings.get(attribName).Category__c : strCat;
					boolDisplay = cfgSettings.get(attribName).Hide_in_Basket__c ? false : boolDisplay;
				}
				//add to output
				retItems.add(new OnlineLineItem(l, strCat, boolDisplay));
			}
		}
		return retItems;
	}
	
	//Test method
	public static testmethod void testO2RepeatLineItemsController()
	{
		TestDataForO2OrderHelper.createRecordTypeForAccount();
		TestDataForO2OrderHelper.createRecordTypeForOpportunity();
		Account acc = TestDataForO2OrderHelper.createAccount();
		Contact con = TestDataForO2OrderHelper.createContact();
		
		cscfgc__Product_Definition__c prodDef = TestDataForO2OrderHelper.createProductDefinition();
		List<cscfgc__Attribute_Definition__c> attrDefs = TestDataForO2OrderHelper.createAttributeDefinition(prodDef.Id);
		 
		cscfgc__Configuration_Offer__c offer = TestDataForO2OrderHelper.createOffer();
		Opportunity opp = TestDataForO2OrderHelper.createOpportunity();
		
		cscfgc__Product_Bundle__c bundle = TestDataForO2OrderHelper.createbundle(opp.Id);
		cscfgc__Product_Configuration__c config = TestDataForO2OrderHelper.createProductConfiguration(attrDefs, bundle.Id, prodDef.Id, offer.Id);
		
		O2RepeatLineItemsController repeatLineItemController = new O2RepeatLineItemsController();
		repeatLineItemController.config = config;
		
		List<OnlineLineItem> onlineItems = repeatLineItemController.getLineItems();
		
		System.assertEquals(onlineItems!=null, true);
		
		Map<String, String> onlineItemMap = new  Map<String, String>();
		for(OnlineLineItem l: onlineItems)
		{
			onlineItemMap.put(l.lineitem.getAttribute().Name, l.category);
		}
		
		System.assert(onlineItemMap.containsKey('Monthly Tariff'));
		
	}
}