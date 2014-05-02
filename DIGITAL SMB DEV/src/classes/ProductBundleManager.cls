//#################################################################################
//# REVISION HISTORY
//#
//# Date modified		By			Comments
//# 6th July 2010 		CPS  		Added static bundle status constants
//#
//#									Moved Bundle validation code out of
//#									controller into this class
//#								
//# 4 Oct    2010		CPS			Added method to clone bundle from one
//#									opportuinity to another.
//#
//#################################################################################

public with sharing class ProductBundleManager {


	//#
	//# Manage these status constants in one place
	//#
	public static final	string VALID_STATUS = 'Valid';
	public static final	string INVALID_STATUS = 'Incomplete';				



	
	/**
	 * Returns a list of fully-reconstructed ProductConfigurations belonging to the supplied bundle.
	 * Only top-level ProductConfigurations should be attached directly to the bundle. 
	 * Child configurations (i.e. related products) will be reconstructed and populated into the appropriate attributes.
	 */
	public static List<cscfgc.ProductConfiguration> getConfigurationsForBundle(cscfgc__Product_Bundle__c bundle) {

		List<cscfgc.ProductConfiguration> configurations = new List<cscfgc.ProductConfiguration>();

		Map<Id, cscfgc__Product_Configuration__c> pcs = new Map<Id, cscfgc__Product_Configuration__c>(
				[select	id
						from cscfgc__Product_Configuration__c
						where cscfgc__product_bundle__c = :bundle.id
						and cscfgc__parent_configuration__c = null]
		);
			
		List<Id> ids = new Id[]{};
		ids.addAll(pcs.keySet());
		List<cscfgc__Product_Configuration__c> configSObjects = getProductConfigurationSObjectsByIdList(ids);

		for (cscfgc__Product_Configuration__c config : configSObjects) configurations.add(new cscfgc.ProductConfiguration(config));
		
		return configurations;		
	}


	//##############################################################################
	//# Method to walk through all configs in a bundle and
	//# and determine it's status.
	//##############################################################################
    public static string getBundleStatusForNewConfig(cscfgc__Product_Bundle__c bundle, cscfgc.ProductConfiguration currentConfig)
    {
	
		string retStatus = ProductBundleManager.VALID_STATUS ;
		string newConfigStatus = ProductBundleManager.VALID_STATUS ;
		
		if (currentConfig != null)
			newConfigStatus = currentConfig.getConfigStatus();
	
		List<string> statusCodes = new list<string>();	
		List<cscfgc__Product_configuration__c> configs = new list<cscfgc__Product_configuration__c>();
		
		
		if (bundle.id == null)
		{
			//#
			//# It's a new bundle - so this is the first 
			//# config. Therefore we can use this
			//# config status for the whole bundle
			//#
			retStatus = newConfigStatus;
		}
		else
		{
			if (newConfigStatus == ProductBundleManager.INVALID_STATUS) 
			{			
				//#
				//# This new config is invalid, so we don;t
				//# even need to check the rest
				//#
				retStatus = ProductBundleManager.INVALID_STATUS;
			} 
	 		else
	 		{
 				//#
				//# Find all the status of all configs in this bundle
				//#			
				 configs = [SELECT cscfgc__configuration_status__c 
				 				FROM cscfgc__Product_Configuration__c
				 				WHERE cscfgc__Product_Bundle__c = :bundle.id
				 				AND cscfgc__parent_configuration__c = null];
			
			
				for(cscfgc__Product_Configuration__c savedConfig : configs)
				{
					//#
					//# Don't include the same one we're about to save in the list...
					//# it may be saved as invalid, but the one passed in may now be valid..
					//#
					if (currentConfig != null)
					{
						if (currentConfig.getId() == null || savedConfig.id != currentConfig.getId()) 
							statusCodes.add(savedconfig.cscfgc__configuration_status__c);
					}
					else
					{
						statusCodes.add(savedconfig.cscfgc__configuration_status__c);	
					}	
				}
				
				//#
				//# Also add the current config status
				//#
				if (currentConfig != null)
					statusCodes.add(newConfigStatus);
			
				//#
				//# Now san through the status codes.
				//# candidate to move this to another class
				//#				
				for(string status: statusCodes)
				{
					if (status != ProductBundleManager.VALID_STATUS) 
					{
						retStatus = ProductBundleManager.INVALID_STATUS;
						break;
					}					
				}
 			 			 		 			
	 		}
 		} //# End if currentConfig is invalid
 		
 		return retStatus;
 
    }
 
 	//#
 	//# Method to clone a bundle from one opportunity to another.
 	//#
 	public static result copyBundleToOpportunity(string sourceBundleId, string targetOppId, string newName)
    {
 		Result res;
    
    	try
    	{
			//#
			//# Get Bundle and target Opp
			//#
    		cscfgc__Product_Bundle__c[] bundles = [select 	Id,
    									   			Name,
    									   			cscfgc__Bundle_Status__c,
    									   			cscfgc__Opportunity__c,
    									   			cscfgc__Synchronised_with_Opportunity__c,
    									   			cscfgc__Total_Price__c
    									    From  	cscfgc__Product_Bundle__c
    									    Where 	Id = :sourceBundleId];
    								
			Opportunity[] targetOpps = 		[select id 
											From 	Opportunity 
											Where 	Id = :targetOppId];    								
    									    
			//#
			//# Validation
			//#    									    
    		if (bundles.size() != 1) throw new ConfiguratorException('source bundle Id does not exist');
    		if (targetOpps.size() != 1) throw new ConfiguratorException('destination opportunity Id does not exist');
			
			//#
			//# We know now that we have 1 opp and 1 bundle.
			//#					
			Opportunity targetOpp = targetOpps[0];
			
			cscfgc__Product_Bundle__c[] newBundles = bundles.deepClone(false);
			newBundles[0].cscfgc__Opportunity__c = targetOpp.Id;
			newBundles[0].Name =  ((newName == null || newName == '')) ? 'Copied from ' +  newBundles[0].Name : newName; 
			
			insert (newbundles);
			
					
			//#
			//# Now get the Product Configs and their attributes.
			//#				
			cscfgc__Product_Configuration__c[]  bundleConfigs = [select Id,
																Name,
																cscfgc__Attribute_Name__c,
																cscfgc__Configuration_Status__c,
																cscfgc__Description__c,
																cscfgc__Entry_Date__c,
																cscfgc__Index__c,
																cscfgc__Last_Screen_Index__c,
																cscfgc__Recurrence_Frequency__c,
																cscfgc__Parent_Configuration__c,
																cscfgc__Product_Basket__c,
																cscfgc__Product_Bundle__c,
																cscfgc__Product_Definition__c,
																cscfgc__Quantity__c,
																cscfgc__Screen_Flow__c,
																cscfgc__Serial_Number__c,
																cscfgc__Total_Price__c,
																cscfgc__Unit_Price__c,
																cscfgc__User_Session__c
															From
																cscfgc__Product_Configuration__c
															Where
																cscfgc__Product_Bundle__c = :bundles[0].Id];
			
			cscfgc__Product_Configuration__c[] newConfigs = bundleConfigs.deepClone(false);
			Map<string,cscfgc__Product_Configuration__c> configMap = new Map<string,cscfgc__Product_Configuration__c>();
			for (integer iLoop = 0 ; iLoop < newConfigs.size() ; iLoop++) 
			{
					configMap.Put(bundleConfigs[iLoop].Id, newConfigs[iLoop]);
					newConfigs[iLoop].cscfgc__Product_Bundle__c = newBundles[0].Id;
			} 
			insert (newconfigs);
	
															
						
			cscfgc__Attribute__c[] attributes =		[Select Id,
																Name,
																cscfgc__Annualised_Price__c,
																cscfgc__Attribute_Definition__c,
																cscfgc__Hidden__c,
																cscfgc__is_active__c,
																cscfgc__Is_Line_Item__c,
																cscfgc__Line_Item_Description__c,
																cscfgc__Line_Item_Sequence__c,
																cscfgc__Price__c,
																cscfgc__Product_Configuration__c,
																cscfgc__Recurring__c,
																cscfgc__Value__c
														From	cscfgc__Attribute__c
														Where cscfgc__Product_Configuration__r.cscfgc__Product_Bundle__c = :bundles[0].Id ]; 				 									    
    		
			cscfgc__Attribute__c[] newAtts = attributes.deepClone(false);
			for (cscfgc__Attribute__c a : newAtts) 
			{
				a.cscfgc__Product_Configuration__c = configMap.get(a.cscfgc__Product_Configuration__c).Id; 				
			}
			insert (newAtts);
    	    	
    		res = Result.success(newBundles[0].id);

    	}
    	catch (Exception ex)
    	{
    		string msg = 'Could not clone Bundle: ' + ex;
    		system.debug(msg);
    		//throw new ConfiguratorException(msg);	
    		res = Result.failure(msg);
  		
   	
    	}
    
    	return res;
    
    }
 
 	//
 	// Loop thorugh the configuration to be copied and all of its children and copy all of them to the specified bundle
 	public static void copyConfigAndChildrenToBunlde(string sourceConfigId, string targetBundleId) {
 		// Get all the config Details
 		String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
        	', (select '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r) '+
        	', (select Id from cscfgc__Related_Configurations__r) '+
            ' from cscfgc__Product_Configuration__c where Id = \''+sourceConfigId+'\'';
        //
        List<cscfgc__Product_Configuration__c> configsToBeClonedList = Database.query(queryString);
        // Get a map of cofigs to be cloned keyed by config Id
        Map<String,cscfgc__Product_Configuration__c> configsToClonedMap = new Map<String,cscfgc__Product_Configuration__c>();
        for (cscfgc__Product_Configuration__c config : configsToBeClonedList) {
        	configsToClonedMap.put(config.Id,config);
        }
        // First clone the main source config
        cscfgc__Product_Configuration__c sourceConfig = configsToClonedMap.get(sourceConfigId);
        cscfgc__Product_Configuration__c newMainClonedConfig = sourceConfig.clone(false,true);
        newMainClonedConfig.cscfgc__Product_Bundle__c = targetBundleId;
        // Insert the new cloned config
        insert newMainClonedConfig;
        //
        // Clone the associated attributes
        List<cscfgc__Attribute__c> newMainClonedAttributes = sourceConfig.cscfgc__Attributes__r.deepClone(false);
        for (cscfgc__Attribute__c att : newMainClonedAttributes) {
        	att.cscfgc__Product_Configuration__c = newMainClonedConfig.Id;
        }
        insert newMainClonedAttributes;
        //
        //-------------
        // Now clone the children
        copyChildConfigsToBunlde(sourceConfig, targetBundleId, newMainClonedConfig, newMainClonedAttributes);
 	}
 	
 	//
 	// Loop thorugh the child configuration copy all of them to the specified bundle
 	private static void copyChildConfigsToBunlde(cscfgc__Product_Configuration__c sourceConfig, 
 												string targetBundleId, 
 												cscfgc__Product_Configuration__c newMainClonedConfig, 
 												List<cscfgc__Attribute__c> newMainClonedAttributes) {
        // Get all the config Details
 		String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
        	', (select '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r) '+
        	', (select Id from cscfgc__Related_Configurations__r) '+
            ' from cscfgc__Product_Configuration__c where Id in '+Utility.convertListToString(sourceConfig.cscfgc__Related_Configurations__r);
        List<cscfgc__Product_Configuration__c> childConfigsToBeClonedList = Database.query(queryString);
        //
        List<cscfgc__Product_Configuration__c> clonedChildConfigsList = new List<cscfgc__Product_Configuration__c>();
        for (cscfgc__Product_Configuration__c config : childConfigsToBeClonedList) {
        	cscfgc__Product_Configuration__c newClonedChildConfig = config.clone(false,true);
        	newClonedChildConfig.cscfgc__Product_Bundle__c = targetBundleId;
        	newClonedChildConfig.cscfgc__Parent_Configuration__c = newMainClonedConfig.Id;
        	clonedChildConfigsList.add(newClonedChildConfig);
        }
        insert clonedChildConfigsList;
        // Get a Map of the old and new child configs
       	Map<String,String> oldtoNewConfigMap = new Map<String,String>();
       	Integer iLoop = 0;
       	for (cscfgc__Product_Configuration__c config : childConfigsToBeClonedList) {
       		oldtoNewConfigMap.put(config.Id,clonedChildConfigsList[iLoop].Id);
       		iLoop++;
       	}
        // Now clone the attributes belonging to the children
        iLoop = 0; // reset the loop counter
        List<List<cscfgc__Attribute__c>> clonedChildAttributeList = new List<List<cscfgc__Attribute__c>>();
        for (cscfgc__Product_Configuration__c config : childConfigsToBeClonedList) {
        	List<cscfgc__Attribute__c> newChildClonedAttributeList = config.cscfgc__Attributes__r.deepClone(false);
        	for (cscfgc__Attribute__c att : newChildClonedAttributeList) {
        		att.cscfgc__Product_Configuration__c = clonedChildConfigsList[iLoop].Id;
        	}
        	insert newChildClonedAttributeList;
        	//
        	clonedChildAttributeList.add(newChildClonedAttributeList);
        	iLoop++;
        }
        // We need to update the related product attributes on the parent configuration
        for (cscfgc__Attribute__c att : newMainClonedAttributes) {
        	if (oldtoNewConfigMap.containsKey(att.cscfgc__value__c)) att.cscfgc__value__c = oldtoNewConfigMap.get(att.cscfgc__value__c);
        }
        update newMainClonedAttributes;
        // Check if we need to call this method again
        iLoop = 0; // reset the loop counter
        for (cscfgc__Product_Configuration__c config : childConfigsToBeClonedList) {
        	if (!config.cscfgc__Related_Configurations__r.isEmpty()) {
        		//
		        //-------------
		        // This child has children - clone them
		        copyChildConfigsToBunlde(config, targetBundleId, clonedChildConfigsList[iLoop], clonedChildAttributeList[iloop]);
        	}
        	iLoop++;
        }
 	}
 	
 	//#
 	//# Method to clone a bundle from one opportunity to another.
 	//#
 	public static result copyConfigurationToBundle(string sourceConfigId, string targetBundleId)
    {
 		Result res = result.Success(true);
    
    	try
    	{
			//#
			//# Get Bundle and target Opp
			//#
    		cscfgc__Product_Bundle__c[] targetBundles = [select 	Id
    									    From  	cscfgc__Product_Bundle__c
    									    Where 	Id = :targetBundleId];
    		
			//#
			//# Now get the Product Configs and their attributes.
			//#				
			cscfgc__Product_Configuration__c[]  sourceConfigs = [select Id,
																Name,
																cscfgc__Attribute_Name__c,
																cscfgc__Configuration_Status__c,
																cscfgc__Description__c,
																cscfgc__Entry_Date__c,
																cscfgc__Index__c,
																cscfgc__Last_Screen_Index__c,
																cscfgc__Recurrence_Frequency__c,
																cscfgc__Parent_Configuration__c,
																cscfgc__Product_Basket__c,
																cscfgc__Product_Bundle__c,
																cscfgc__Product_Definition__c,
																cscfgc__Quantity__c,
																cscfgc__Screen_Flow__c,
																cscfgc__Serial_Number__c,
																cscfgc__Total_Price__c,
																cscfgc__Unit_Price__c,
																cscfgc__User_Session__c
															From
																cscfgc__Product_Configuration__c
															Where
																Id = :sourceConfigId];
    								
			//#
			//# Validation
			//#    									    
    		if (targetBundles.size() != 1) throw new ConfiguratorException('target bundle Id does not exist');
    		if (sourceConfigs.size() != 1) throw new ConfiguratorException('source config Id does not exist');
			
			//#
			//# We know now that we have 1 Config and 1 bundle.
			//#					
			
			cscfgc__Product_Configuration__c[] newConfigs = sourceConfigs.deepClone(false);
			Map<string,cscfgc__Product_Configuration__c> configMap = new Map<string,cscfgc__Product_Configuration__c>();
			for (integer iLoop = 0 ; iLoop < newConfigs.size() ; iLoop++) 
			{
					configMap.Put(sourceConfigs[iLoop].Id, newConfigs[iLoop]);
					newConfigs[iLoop].cscfgc__Product_Bundle__c = targetBundleId;
			} 
			insert (newconfigs);
	
															
			//#
			//# Clone the attributes
			//#						
			cscfgc__Attribute__c[] attributes =					[Select Id,
																Name,
																cscfgc__Annualised_Price__c,
																cscfgc__Attribute_Definition__c,
																cscfgc__Hidden__c,
																cscfgc__is_active__c,
																cscfgc__Is_Line_Item__c,
																cscfgc__Line_Item_Description__c,
																cscfgc__Line_Item_Sequence__c,
																cscfgc__Price__c,
																cscfgc__Product_Configuration__c,
																cscfgc__Recurring__c,
																cscfgc__Value__c
														From	cscfgc__Attribute__c
														Where cscfgc__Product_Configuration__c = :sourceConfigId ]; 				 									    
    		
			cscfgc__Attribute__c[] newAtts = attributes.deepClone(false);
			for (cscfgc__Attribute__c a : newAtts) 
			{
				a.cscfgc__Product_Configuration__c = configMap.get(a.cscfgc__Product_Configuration__c).Id; 				
			}
			insert (newAtts);
    	    	
    	    	
    		
    	}
    	catch (Exception ex)
    	{
    		string msg = 'Could not copy Configuration to Bundle: ' + ex;
    		system.debug(msg);
    		//throw new ConfiguratorException(msg);	
    		res = Result.failure(msg);
  		
   	
    	}
    
    	return res;
    
    }
	
	public static List<cscfgc__Product_Configuration__c> getProductConfigurationSObjectsByIdList(String[] ids) {
		return [select  name, 
						cscfgc__description__c,
						cscfgc__serial_number__c,
						cscfgc__attribute_name__c,
						cscfgc__index__c,
						cscfgc__unit_price__c,
						cscfgc__quantity__c,
						cscfgc__total_price__c,
						cscfgc__recurrence_frequency__c,
						cscfgc__parent_configuration__c,
						cscfgc__product_bundle__c,
						cscfgc__product_definition__c,
						cscfgc__product_definition__r.name,
						cscfgc__product_definition__r.cscfgc__description__c,
						cscfgc__product_definition__r.cscfgc__name_is_read_only__c,
						cscfgc__product_definition__r.cscfgc__allow_progress_from_incomplete_screens__c,
						cscfgc__product_definition__r.cscfgc__opportunity_mapping__c, // CPS 17/8/2010
						cscfgc__configuration_status__c,
						cscfgc__entry_date__c, // CPS 21/7/2010
						cscfgc__screen_flow__c,
						cscfgc__screen_flow__r.name,
						cscfgc__last_screen_index__c,
						(select name,
								cscfgc__product_configuration__c,
								cscfgc__attribute_definition__c,
								cscfgc__attribute_definition__r.name,
								cscfgc__attribute_definition__r.cscfgc__product_definition__r.name,
								cscfgc__value__c,
								cscfgc__cascade_value__c,
								cscfgc__display_value__c,
								cscfgc__hidden__c,
								cscfgc__is_active__c,
								cscfgc__is_line_item__c,
								cscfgc__line_item_description__c,
								cscfgc__line_item_sequence__c,
								cscfgc__price__c,
								cscfgc__recurring__c,
								cscfgc__annualised_price__c
						from cscfgc__Attributes__r
						order by cscfgc__line_item_sequence__c)
				from cscfgc__Product_Configuration__c
				where id in :ids
				order by cscfgc__index__c];
		/*
		return [select name,
					cscfgc__description__c,
					cscfgc__serial_number__c,
					cscfgc__attribute_name__c,
					cscfgc__index__c,
					cscfgc__unit_price__c,
					cscfgc__quantity__c,
					cscfgc__total_price__c,
					cscfgc__recurrence_frequency__c,
					cscfgc__parent_configuration__c,
					cscfgc__product_bundle__c,
					cscfgc__product_definition__c,
					cscfgc__product_definition__r.name,
					cscfgc__product_definition__r.cscfgc__description__c,
					cscfgc__product_definition__r.cscfgc__name_is_read_only__c,
					cscfgc__product_definition__r.cscfgc__allow_progress_from_incomplete_screens__c,
					cscfgc__product_definition__r.cscfgc__opportunity_mapping__c, // CPS 17/8/2010
					cscfgc__configuration_status__c,
					cscfgc__entry_date__c, // CPS 21/7/2010
					cscfgc__screen_flow__c,
					cscfgc__screen_flow__r.name,
					cscfgc__last_screen_index__c
					from cscfgc__Product_Configuration__c					
					where id in :ids
					order by cscfgc__index__c
		];*/
	}
	
    public static List<cscfgc.ProductConfiguration> getProductConfigurationsByIdList(Id[] ids) {
		List<cscfgc.ProductConfiguration> configurations = new List<cscfgc.ProductConfiguration>();
		List<cscfgc__Product_Configuration__c> configs = getProductConfigurationSObjectsByIdList(ids);
		
		for (cscfgc__Product_Configuration__c config : configs) {
			cscfgc.ProductConfiguration conf = new cscfgc.ProductConfiguration(config);
			configurations.add(conf);
		}
		
		return configurations;		
	}
    
	public virtual class ConfiguratorException extends Exception {
	
	}
 	
    
}