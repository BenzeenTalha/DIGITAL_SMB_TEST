public with sharing class O2ContractHelper {
	
	private final static String PRICE_FIELD = 'cscfgc__Price__c';
	private final static String IS_LINE_ITEM_FIELD = 'cscfgc__Is_Line_Item__c';
	
	
	/**
	 * Public interface method for the Order processing. At the minimum, the Order should 
	 * have Order__c, Order_Group__c and Product_Configuration__c fields fetched.
	 * As a result of the processing, the following objects are inserted into the database:
	 * - Contract__c related to the Order
	 * - (possibly) Customer_Asset__c object related to the Contract__c
	 *
	 * @param completedOrder Order that should be processed.
	 */ 		
	public static void processOrder(Order__c completedOrder) {
		
		// completedOrder = [Select Id, Order__c, Order_Group__c, Product_Configuration__c from Order__c where Id = :completedOrder.Id limit 1];
		
		Contract__c contract = getContract(completedOrder);
		
		if (contract == null) {
			contract = buildContract(completedOrder);
		} else {
			updateContract(contract, completedOrder);
		}
		
		upsert contract;
		
		List<Customer_Asset__c> assets = buildCustomerAssets(contract, completedOrder);
		if (assets.size() > 0) {
			insert assets;
		}
	}
	
	private static void updateContract(Contract__c contract, Order__c completedOrder) {
		Date startDate = Date.today();
		Date endDate = null;
		Integer contractTerm = getContractTerm(completedOrder);
		
		if (contractTerm != null) {
			endDate = startDate.addMonths(contractTerm);
			if (contract.End_Date__c == null || contract.End_Date__c.daysBetween(endDate) > 0) {
				contract.End_Date__c = endDate;
			} 
		}		
	}
	
	/**
	 * Tries to retrieve a contract related to the given order. If no
	 * such contract is avaiable, returns null.
	 *
	 * @completedOrder Order for which the related Contract is queried
	 */ 	
	private static Contract__c getContract(Order__c completedOrder) {
		List<Contract__c> contracts = [
			Select 
				Id, 
				Start_Date__c, 
				End_Date__c,
				Order_Group__c,
				Order__c
			from 
				Contract__c 
			where 
				Order_Group__c = :completedOrder.Order_Group__c
			limit 1
		];
		if (contracts.size() > 0) {
			return contracts.get(0);
		} else {
			return null;		
		}
	}
	
	/**
	 * Builds customer assets for the given order using the order conversion rules
	 * custom setting list to query the product configuration and its related
	 * attributes. The created assets are related to the contract.
	 *	 
	 * @param completed Order with the 'completed' status that is being processed
	 * @param contract Contract to which the assets are related
	 */
	 public static List<Customer_Asset__c> buildCustomerAssets(Contract__c contract, Order__c completedOrder) {
		
		List<Customer_Asset__c> assets = new List<Customer_Asset__c>();
		
		ProductConfigurationRepository productConfigurationRepository = new ProductConfigurationRepository(completedOrder.Product_Configuration__c);
		OrderConversionRuleRepository ruleRepository = new OrderConversionRuleRepository(productConfigurationRepository.getProductConfigurationName());
								
		Map<String, List<OrderConversionRule>> conversionRuleGroups = ruleRepository.getRuleGroups();
		
		for (String groupName : conversionRuleGroups.keySet()) {
								
			Customer_Asset__c asset = new Customer_Asset__c();
			Boolean isGroupConvertible = false;
			
			List<OrderConversionRule> groupRules = conversionRuleGroups.get(groupName);
						
			for (OrderConversionRule rule : groupRules) {
				
				Object fieldValue = productConfigurationRepository.getFieldValue(rule.attributeName, rule.fieldName);
								
				if (!isGroupConvertible && productConfigurationRepository.isLineItem(rule.attributeName)) {
					isGroupConvertible = true;
				}
				try {
					asset.put(rule.destinationFieldName, fieldValue);
				} catch (System.SObjectException ex) {
					// access error to destination field name
				}				
			}
			
			if (isGroupConvertible) {
				asset.Contract__c = contract.Id;
				assets.add(asset);
			}
		}
		return assets;
	}
	
	/**
	 * Tries to retrieve contract term attribute related to the order product configuration
	 * and parse the contract term value. If successful returns the contract term, otherwise
	 * a null value
	 *
	 * @param completedOrder Order which might have a contract term related to it
	 */ 
	private static Integer getContractTerm(Order__c completedOrder) {
		Integer duration = null;
		
		List<cscfgc__Attribute__c> durationAttributes = [
			Select 
				a.cscfgc__Value__c 
			from 
				cscfgc__Attribute__c a 
			where 
				a.cscfgc__Product_Configuration__c = :completedOrder.Product_Configuration__c 
			and
				a.Name = 'Contract Term'
			limit 1
		];
		if (durationAttributes.size() > 0) {
			cscfgc__Attribute__c durationAttribute = durationAttributes.get(0);
			String durationText = durationAttribute.cscfgc__Value__c;
			if (!String.isEmpty(durationText)) {
				try {
					duration = Integer.valueOf(durationText);		
				} catch (System.TypeException ex) {
					// swallow if it is not a valid integer
				}
			}
		}
		return duration;
	}
	
	/**
	 * Builds a contract from a given order. Start Date is set to now,
	 * and End Date is set to Start Date + order duration.
	 *
	 * @param completedOrder Order to which the contract should be related to either directly or through its Order Group
	 */ 
	private static Contract__c buildContract(Order__c completedOrder) {
		
		Date startDate = Date.today();
		Date endDate = null;
		// alternatively, list assumption that contract term is available
		Integer contractTerm = getContractTerm(completedOrder);
		if (contractTerm != null) {
			endDate = startDate.addMonths(contractTerm);
		} 
			
		Contract__c contract = new Contract__c(
			Account__c = completedOrder.Account__c,
			Start_Date__c = startDate,
			End_Date__c = endDate,
			// the contract shall have a status of Active since the conversion will only occur 
			// when the order has been fully processed and provisioning completed
			Status__c = 'Active'
		);
		
		if (completedOrder.Order_Group__c != null) {
			contract.Order_Group__c = completedOrder.Order_Group__c;
		}
		else {
			contract.Order__c = completedOrder.Id;
		}
		
		// TODO: clarify
		contract.Contract_Number__c = '1234';
		
		return contract;
	}
	private class OrderConversionRule {
		
		String groupName { get; private set; }
		String productConfigurationName { get; private set; }
		String attributeName { get; private set; }
		String fieldName { get; private set; }
		String destinationFieldName { get; private set; }
		
		public OrderConversionRule(Order_Conversion_Rule__c rule) {
			String[] ruleParts = rule.From__c.split('\\.');
			productConfigurationName = ruleParts[0];
			attributeName = ruleParts[1];
			fieldName = ruleParts[2];
			destinationFieldName = rule.To__c;
			groupName = rule.Group__c; 
		}
	}
	
	/**
	 * This class serves as a wrapper around querying for Order Conversion Rule custom setting.
	 * Instantiating the class retrieves all order conversion rules and additionally filters and
	 * groups them depending on constructor parameters.
	 */
	private class OrderConversionRuleRepository {
		
		Map<String, List<OrderConversionRule>> ruleGroups;
		
		/**
		 * Constructor. Queries all Order Conversion Rule custom settings, filters them by Product Configuration
		 * name and groups them by the rule Group__c values.
		 */ 
		public OrderConversionRuleRepository(String productConfigurationName) {
			
			ruleGroups = new Map<String, List<OrderConversionRule>>();
			
			List<Order_Conversion_Rule__c> allConversionRules = Order_Conversion_Rule__c.getAll().values();
			
			for (Order_Conversion_Rule__c rule : allConversionRules) {
				
				if (!String.isEmpty(rule.From__c) && !String.isEmpty(rule.To__c) && !String.isEmpty(rule.Group__c)) {
					
					OrderConversionRule conversionRule = new OrderConversionRule(rule);
					
					if (productConfigurationName == conversionRule.productConfigurationName) {
						
						String groupName = conversionRule.groupName;
												
						if (ruleGroups.containsKey(groupName)) {
							ruleGroups.get(groupName).add(conversionRule);
						}
						else {
							List<OrderConversionRule> ruleGroup = new List<OrderConversionRule>();
							ruleGroup.add(conversionRule);
							ruleGroups.put(groupName, ruleGroup);
						}
					}
				}
			} 
		}
		
		/**
		 * Returns rules retrieved in a constructor as a map of (group name)-(rules) pairs
		 */
		public Map<String, List<OrderConversionRule>> getRuleGroups() {
						return ruleGroups;
		}
	}
	
	/**
	 * This class retrieves product configuration and offers methods to inspect the results.
	 */  
	private class ProductConfigurationRepository {
		
		private cscfgc__Product_Configuration__c productConfiguration;
		
		private Map<String, cscfgc__Attribute__c> attributeNameMap;
		
		/**
		 * Returns the name of the retrieved product configuration, or null if no product
		 * configuration is available or its name is not available.
		 */ 
		public String getProductConfigurationName() {
			if (productConfiguration != null && !String.isEmpty(productConfiguration.Name)) {
				return productConfiguration.Name;
			}
			return null;
		}
		
		/**
		 * Constructor. Tries to retrieve the Product Configuration by its id.
		 */ 
		public ProductConfigurationRepository(Id productConfigurationId) {
			List<cscfgc__Product_Configuration__c> productConfigurations = [Select 
			c.Name,
			c.Id,
			(Select 
				Id,
				IsDeleted,
				Name,
				CreatedDate,
				CreatedById,
				LastModifiedDate,
				LastModifiedById,
				SystemModstamp,
				cscfgc__Product_Configuration__c,
				cscfgc__Annualised_Price__c,
				cscfgc__Attribute_Definition__c,
				cscfgc__Cascade_value__c,
				cscfgc__Display_Value__c,
				cscfgc__Hidden__c,
				cscfgc__Is_Line_Item__c,
				cscfgc__Line_Item_Description__c,
				cscfgc__Line_Item_Sequence__c,
				cscfgc__Price__c,
				cscfgc__Recurring__c,
				cscfgc__Value__c,
				cscfgc__is_active__c,
				cscfgc__Billing_Price__c,
				cscfgc__Key__c 
			From 
				cscfgc__Attributes__r
			) 
			From 
				cscfgc__Product_Configuration__c c
			Where
				c.Id = :productConfigurationId
			];
			
			if (productConfigurations.size() > 0) {
				productConfiguration = productConfigurations.get(0);
				attributeNameMap = new Map<String, cscfgc__Attribute__c>();				
				
				for (cscfgc__Attribute__c attr : productConfiguration.cscfgc__Attributes__r) {
					attributeNameMap.put(attr.Name, attr);
				}
			}
		}
		
		/**
		 * Checks whether an attribute with a name attributeName is a line item in the retrieved
		 * Product Configuration.
		 * 
		 * @param attributeName attribute name for which a check is performed
		 * @return whether an attribute with the given attributeName is a line item attribute
		 */ 
		public Boolean isLineItem(String attributeName) {
			
			Boolean isLineItem = false;
				
			if (!String.isEmpty(attributeName)) {
				cscfgc__Attribute__c attr = attributeNameMap.get(attributeName);
				if (attr != null) {
					try {
						isLineItem = Boolean.valueOf(attr.get(IS_LINE_ITEM_FIELD));
					} catch (System.SObjectException ex) {
						// access error to specified field name
					}
				}
			}
			return isLineItem;		
		}
		
		/**
		 * Tries to find an attribute with named attributeName with a field named fieldName
		 * on that attribute in the retrieved Product Configuration. 
		 *
		 * If such a field is available, it returns the value of that field. Otherwise it
		 * returns null.
		 *
		 * @param attributeName name of the attribute on the Product Configuration
		 * @param fieldName name of the field on the attribute named attributeName
		 */ 
		public Object getFieldValue(String attributeName, String fieldName) {
			
			Object value = null;
			cscfgc__Attribute__c attr = attributeNameMap.get(attributeName);
			
			if (attr != null && !String.isEmpty(fieldName)) {
				try {
					value = attr.get(fieldName);
				} catch (System.SObjectException ex) {
					// access error to specified field name
				}
			}
			return value;
		}
	}
}