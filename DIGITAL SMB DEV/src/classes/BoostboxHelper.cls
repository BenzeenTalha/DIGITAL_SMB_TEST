global class BoostboxHelper 
{ 
	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public class BoostboxHelperException extends Exception {}
	
	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public class BoostboxDef 
	{
		public boolean Closed { get; set; }
		public String Boostbox_Type { get; set; }
		public String Installation_Address_Building_Name { get; set; }
		public String Installation_Address_Building_Number { get; set; }
		public String Installation_Address_County { get; set; }
		public String Installation_Address_Post_Town { get; set; }
		public String Installation_Address_Postal_Code { get; set; }
		public String Installation_Address_Street{ get; set; }
		public String Installation_Address_Sub_Building_Name { get; set; }
		public BoostboxDef(){}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static void addMsg(Exception e) 
	{
		System.debug(e);
		if (!System.Test.isRunningTest()) 
		{
			System.Pagereference pr = ApexPages.currentPage();
			if (pr != null) 
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			}
		}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static void addMsg(String msg, Boolean isErr) 
	{
		System.Pagereference pr = ApexPages.currentPage();
		if (pr == null) 
		{
			if (isErr) 
			{
				System.debug('Error: ' + msg);
			} else 
			{
				System.debug('Warning: ' + msg);
			}
		} 
		else 
		{
			if (isErr) 
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
			} 
			else 
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));
			}
		}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static Map<Id, BoostboxDef> getConfigAttrMap(Set<Id> configSet) 
	{

		system.debug('***configSet: '+configSet);

		List<cscfgc__Attribute__c> attrList = [SELECT Id, Name, cscfgc__Value__c , cscfgc__Product_Configuration__c
					FROM cscfgc__Attribute__c
					where cscfgc__Product_Configuration__c IN :configSet];

		system.debug('***attrList: '+attrList);

		Map<Id, List<cscfgc__Attribute__c>> configToAttributeListMap = new Map<Id, List<cscfgc__Attribute__c>>();
		for (cscfgc__Attribute__c attr : attrList) 
		{
			List<cscfgc__Attribute__c> attrMapList=new List<cscfgc__Attribute__c>();
			if (configToAttributeListMap.containsKey(attr.cscfgc__Product_Configuration__c)) 
			{
				attrMapList.addAll(configToAttributeListMap.get(attr.cscfgc__Product_Configuration__c));
			}
			attrMapList.add(attr);
			configToAttributeListMap.put(attr.cscfgc__Product_Configuration__c, attrMapList);
		}
		system.debug('***configToAttributeListMap: '+configToAttributeListMap);

		Map<Id, BoostboxDef> configToAttributeMap = new Map<Id, BoostboxDef>();
		for (Id config : configToAttributeListMap.keySet()) 
		{
			List<cscfgc__Attribute__c> attrMapList=configToAttributeListMap.get(config);
			BoostboxDef boostboxDef = new BoostboxDef();
			for (cscfgc__Attribute__c attr : attrMapList) 
			{
				if (attr.Name == 'Needs Access List') boostboxDef.Closed=(attr.cscfgc__Value__c == 'false' ? false : true);
				if (attr.Name == 'Boostbox Type') boostboxDef.Boostbox_Type=attr.cscfgc__Value__c;
				if (attr.Name == 'Install Building Name') boostboxDef.Installation_Address_Building_Name=attr.cscfgc__Value__c;
				if (attr.Name == 'Install Premise Number') boostboxDef.Installation_Address_Building_Number=attr.cscfgc__Value__c;
				if (attr.Name == 'Install County') boostboxDef.Installation_Address_County=attr.cscfgc__Value__c;
				if (attr.Name == 'Install City') boostboxDef.Installation_Address_Post_Town=attr.cscfgc__Value__c;
				if (attr.Name == 'Install Postcode') boostboxDef.Installation_Address_Postal_Code=attr.cscfgc__Value__c;
				if (attr.Name == 'Install Street') boostboxDef.Installation_Address_Street=attr.cscfgc__Value__c;
				if (attr.Name == 'Installation Address Sub Building Name') boostboxDef.Installation_Address_Sub_Building_Name=attr.cscfgc__Value__c;
			}
			configToAttributeMap.put(config, boostboxDef);
		}
		system.debug('***configToAttributeMap: '+configToAttributeMap);
		return configToAttributeMap;
	}

	//--------------------------------------------------------------------------
	// Orchestration of order group list in future method
	//--------------------------------------------------------------------------
	public static void createGroupOrderProcess(List<Id> orderGroupIdList)
	{
		// added for new version of Orchestrator 1.51.
		Id templateId = [SELECT Id FROM CSPOFA__Orchestration_Process_Template__c
			WHERE  CSPOFA__Process_Type__c = 'New Provide'
			AND Name = 'Boostbox Order Group'].Id;

		//
		// Create Orchestration Process record for Completed Boostbox records 
		//
		List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();

		for (Id orderGroupId : orderGroupIdList) 
		{
			processList.add(new CSPOFA__Orchestration_Process__c(Name = 'Boostbox Order Group',
						CSPOFA__Process_Type__c = 'New Provide',
						CSPOFA__Orchestration_Process_Template__c = templateId,
						Order_Group__c = orderGroupId));					
		}
		if (!processList.isEmpty()) insert processList;
	}
	
	//--------------------------------------------------------------------------
	// Orchestration of order link in future method
	//--------------------------------------------------------------------------
	public static void createOrderProcess(List<Id> orderIdList)
	{
		// added for new version of Orchestrator 1.51.
		Id templateId = [SELECT Id FROM CSPOFA__Orchestration_Process_Template__c
			WHERE  CSPOFA__Process_Type__c = 'New Provide'
			AND Name = 'Boostbox Provisioning'].Id;

		//
		// Create Orchestration Process record for Boostbox product types
		//
		List<CSPOFA__Orchestration_Process__c> processOrchList = new List<CSPOFA__Orchestration_Process__c>();

		for (Id orderId : orderIdList) 
		{
			processOrchList.add(new CSPOFA__Orchestration_Process__c(Name = 'Boostbox Provisioning',
						CSPOFA__Process_Type__c = 'New Provide',
						CSPOFA__Orchestration_Process_Template__c = templateId,
						Order__c = orderId));
		}
		if (!processOrchList.isEmpty()) insert processOrchList;
	}
}