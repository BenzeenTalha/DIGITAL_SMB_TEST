global  without sharing class DiseMappingBatchAsync implements Database.Batchable<sObject> {
    global String query;
	public List<sObject> diseCodeList = new List<sObject>();
	
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    	List<Order_Line_Item__c> orderLineItemToUpdateList = new List<Order_Line_Item__c>();
        List<cscfgc__Log_Entry__c> logEntryList = new List<cscfgc__Log_Entry__c>();
        //
        //logEntryList = [select id from cscfgc__Log_Entry__c];
        //delete logEntryList;
        //
        if (scope.size()>0) {
            for (sObject rec: scope) {
            	Order__c order = (Order__c) rec;
            	//
		 		// Get all the config Details
		 		String queryString = null;
		        /****queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
		        	', (select cscfgc__Attribute_Definition__r.Name, cscfgc__Attribute_Definition__r.cscfgc__lookup_Query__c, '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r) '+
		            ' from cscfgc__Product_Configuration__c where Id = \''+order.Product_Configuration__c+'\'';******/
		        queryString = 'select Id '+
		        	', (select cscfgc__Attribute_Definition__r.Name, cscfgc__Attribute_Definition__r.cscfgc__lookup_Query__c, Id, Name, cscfgc__Value__c, cscfgc__Is_Line_Item__c from cscfgc__Attributes__r) '+
		            ' from cscfgc__Product_Configuration__c where Id = \''+order.Product_Configuration__c+'\'';
		        List<cscfgc__Product_Configuration__c> configsToBeClonedList = Database.query(queryString);
		        //
		        // Get a list of all the lookup queries associated with this order
		        List<String> lookupQueryIdList = new List<String>();
		        List<String> attributeIdList = new List<String>();
		        Map<String,cscfgc__Attribute__c> attributeMap = new Map<String,cscfgc__Attribute__c>();
		        for (cscfgc__Product_Configuration__c config : configsToBeClonedList) {
		        	for (cscfgc__Attribute__c att : config.cscfgc__Attributes__r) {
		        		if (att.cscfgc__Is_Line_Item__c && att.cscfgc__Attribute_Definition__r.cscfgc__lookup_Query__c != null) {
		        			lookupQueryIdList.add(att.cscfgc__Attribute_Definition__r.cscfgc__lookup_Query__c);
		        			attributeIdList.add(att.Id);
		        		}
		        		attributeMap.put(att.cscfgc__Attribute_Definition__r.Name,att);
		        	}
		        }
		        Map<String,cscfgc__Lookup_Query__c> lookupQueryMap = getLookupQuery(lookupQueryIdList);
		        //
		        diseCodeList = new List<sObject>();
		        //
		        String tariffcode = (order.Tariff_Code__c !=null?order.Tariff_Code__c:null) ;
		        
            	/*****if (order.Product_Category__c == 'Calls Only') diseCodeList = getDiseCodeMap('O2_DISE_Map_Calls_Only__c');
            	if (order.Product_Category__c == 'Landline' || order.Product_Category__c == 'Landline Bolt Ons') diseCodeList = getDiseCodeMap('O2_DISE_Map_Landline__c');
            	if (order.Product_Category__c == 'ISDN30' || order.Product_Category__c == 'ISDN2' || 
            		order.Product_Category__c == 'ISDN2 Bolt Ons' || order.Product_Category__c == 'ISDN30 ETSI Bolt Ons' || 
            		order.Product_Category__c == 'ISDN30 DASS Bolt Ons') diseCodeList = getDiseCodeMap('O2_DISE_Map_ISDN__c');
            	*****/
            	if (order.Product_Category__c == 'Calls Only') diseCodeList = getCallsOnlyDiseCodeMap(tariffcode);
            	if (order.Product_Category__c == 'Landline' || order.Product_Category__c == 'Landline Bolt Ons') diseCodeList = getLandlineDiseCodeMap(tariffcode);
            	if (order.Product_Category__c == 'ISDN30' || order.Product_Category__c == 'ISDN2' || 
            		order.Product_Category__c == 'ISDN2 Bolt Ons' || order.Product_Category__c == 'ISDN30 ETSI Bolt Ons' || 
            		order.Product_Category__c == 'ISDN30 DASS Bolt Ons') diseCodeList = getISDNDiseCodeMap(tariffcode);
            	if (order.Product_Category__c == 'Business Broadband') diseCodeList = getBBDiseCodeMap(tariffcode);
            	if (order.Product_Category__c == 'Telemarketing') diseCodeList = getNGNDiseCodeMap(tariffcode);
            	if (order.Product_Category__c == 'Minute Bolt Ons') diseCodeList = getMinutesDiseCodeMap();
            	//
		        logEntryList.add(new cscfgc__Log_Entry__c(cscfgc__Log_Detail__c='Order: '+order.Name));
            	for (Order_Line_Item__c item : order.Order_Line_Items__r) {
		          	logEntryList.add(new cscfgc__Log_Entry__c(cscfgc__Log_Detail__c='---------->item: '+item.Name));
            		// Get the associated lookup Query and its criteria
            		cscfgc__Lookup_Query__c currentLookupQuery = lookupQueryMap.get(item.Attribute__r.cscfgc__Attribute_Definition__r.cscfgc__lookup_Query__c);
            		//
            		Boolean statisfiedCriteria = false;
            		if (currentLookupQuery != null) {
            			Integer i = 0;
	            		for (sObject diseCodeColMap : diseCodeList) {
	            			statisfiedCriteria = false;
	            			//
		            		for (cscfgc__Lookup_Criterion__c criterion : currentLookupQuery.cscfgc__Lookup_Criteria__r) {
		            			String criterionValue = criterion.cscfgc__Value__c.replace('\'','');
		            			if (criterionValue.startsWith('\'') && criterionValue.endsWith('\'')) {
		            				criterionValue = criterionValue.replace('\'','');
		            			} else if (criterionValue.startsWith('{') && criterionValue.endsWith('}')) {
		            				criterionValue = criterionValue.replace('}','');
		            				criterionValue = criterionValue.replace('{','');
		            				if (attributeMap.containsKey(criterionValue))
		            					criterionValue = attributeMap.get(criterionValue).cscfgc__Value__c;
		            			}
		            			//
		            			if (checkValue(String.valueOf(diseCodeColMap.get(criterion.cscfgc__Field__c)), criterionValue, criterion.cscfgc__Operator__c)) {
		            				//if (diseCodeColMap.get(criterion.cscfgc__Field__c) == criterionValue)
		            				statisfiedCriteria = true;
		            			} else {
		            				statisfiedCriteria = false;
		            				break;
		            			}
		            		}
		            		// If statisfiedCriteria is true We have found the row we want 
		            		if (statisfiedCriteria) {
		            			item.Service_Code__c = String.valueOf(diseCodeColMap.get('Service_Code__c'));
		            			logEntryList.add(new cscfgc__Log_Entry__c(cscfgc__Log_Detail__c='          ----->Service_Code__c: '+item.Service_Code__c));
		            			break;
		            		}
		            		//
		            		i++;
	            		}
            		}
            		orderLineItemToUpdateList.add(item);
            	}
            	
            }
		    logEntryList.add(new cscfgc__Log_Entry__c(cscfgc__Log_Detail__c='>>>>orderLineItemToUpdateList.size(): '+orderLineItemToUpdateList.size()));
            if (!orderLineItemToUpdateList.isEmpty()) update orderLineItemToUpdateList;
        }
        upsert logEntryList;
    }
    
    global void finish(Database.BatchableContext BC) {
    	// Code to execute at the end of the batch process
    }
	
	public static Boolean checkValue(String diseMapValue, String criterionValue, String criterionOperator) {
		Boolean statisfiedCriteria = false;
		//
		if (criterionOperator == 'equals') {
			if (diseMapValue == criterionValue) {
				statisfiedCriteria = true;
			} else {
				statisfiedCriteria = false;
			}
		} else if (criterionOperator == 'is not') {
			if (diseMapValue != criterionValue) {
				statisfiedCriteria = true;
			} else {
				statisfiedCriteria = false;
			}
		} else if (criterionOperator == 'is greater than') {
			try {
				Decimal decimalDiceMapValue = Decimal.valueOf(diseMapValue);
				Decimal decimalCriterionValue = Decimal.valueOf(criterionValue);
				if (decimalDiceMapValue > decimalCriterionValue) {
					statisfiedCriteria = true;
				} else {
					statisfiedCriteria = false;
				}
			} catch(Exception ex) {
				if (diseMapValue > criterionValue) {
					statisfiedCriteria = true;
				} else {
					statisfiedCriteria = false;
				}
			}
		} else if (criterionOperator == 'is greater than or equal to') {
			try {
				Decimal decimalDiceMapValue = Decimal.valueOf(diseMapValue);
				Decimal decimalCriterionValue = Decimal.valueOf(criterionValue);
				if (decimalDiceMapValue >= decimalCriterionValue) {
					statisfiedCriteria = true;
				} else {
					statisfiedCriteria = false;
				}
			} catch(Exception ex) {
				if (diseMapValue >= criterionValue) {
					statisfiedCriteria = true;
				} else {
					statisfiedCriteria = false;
				}
			}
		} else if (criterionOperator == 'is less than') {
			try {
				Decimal decimalDiceMapValue = Decimal.valueOf(diseMapValue);
				Decimal decimalCriterionValue = Decimal.valueOf(criterionValue);
				if (decimalDiceMapValue < decimalCriterionValue) {
					statisfiedCriteria = true;
				} else {
					statisfiedCriteria = false;
				}
			} catch(Exception ex) {
				if (diseMapValue < criterionValue) {
					statisfiedCriteria = true;
				} else {
					statisfiedCriteria = false;
				}
			}
		} else if (criterionOperator == 'is less than or equal to') {
			try {
				Decimal decimalDiceMapValue = Decimal.valueOf(diseMapValue);
				Decimal decimalCriterionValue = Decimal.valueOf(criterionValue);
				if (decimalDiceMapValue <= decimalCriterionValue) {
					statisfiedCriteria = true;
				} else {
					statisfiedCriteria = false;
				}
			} catch(Exception ex) {
				if (diseMapValue <= criterionValue) {
					statisfiedCriteria = true;
				} else {
					statisfiedCriteria = false;
				}
			}
		}
		//
		return statisfiedCriteria;
	}
	
	
	public static List<sObject> getCallsOnlyDiseCodeMap(String tariffcode) {
		List<sObject> diseCodeList = new List<sObject>();
		List<O2_DISE_Map_Calls_Only__c> diseCodeDbList;

		if(tariffcode != null)
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
	            				o.Package_Code__c, o.Name, o.Manual_Mapping__c, o.Attribute_Value__c, o.Attribute_Name__c 
	            		  From O2_DISE_Map_Calls_Only__c o where o.Tariff_Code__c = :tariffcode];
		}
		else
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
	            				o.Package_Code__c, o.Name, o.Manual_Mapping__c, o.Attribute_Value__c, o.Attribute_Name__c 
	            		  From O2_DISE_Map_Calls_Only__c o];
		}
		//
		for(O2_DISE_Map_Calls_Only__c rec : diseCodeDbList)
		{
			sObject diseObjCalls = (sObject) rec;
			diseCodeList.add(diseObjCalls);
		}
		
		
		//RU 20/12/2011: Commented the below code as it was hitting the governor limits(too many script statements)
		/*for (O2_DISE_Map_Calls_Only__c rec : diseCodeDbList) {
			Map<String,String> recColumnMap = new Map<String,String>();
			recColumnMap.put('Tariff_Code__c',rec.Tariff_Code__c);
			recColumnMap.put('Service_Type__c',rec.Service_Type__c);
			recColumnMap.put('Service_Code__c',rec.Service_Code__c);
			recColumnMap.put('Service_Bill_Label__c',rec.Service_Bill_Label__c);
			recColumnMap.put('Package_Code__c',rec.Package_Code__c);
			recColumnMap.put('Name',rec.Name);
			recColumnMap.put('Manual_Mapping__c',rec.Manual_Mapping__c);
			recColumnMap.put('Attribute_Value__c',rec.Attribute_Value__c);
			recColumnMap.put('Attribute_Name__c',rec.Attribute_Name__c);
			//
			diseCodeList.add(recColumnMap);
		}*/
		
		return diseCodeList;
		
	}  

	public static List<sObject> getLandlineDiseCodeMap(String tariffcode) {

		List<sObject> diseCodeList = new List<sObject>();
		List<O2_DISE_Map_Landline__c> diseCodeDbList;
		if(tariffcode != null)
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, o.Package_Code__c, 
	            				o.Name, o.Minutes_Type__c, o.Minutes_Number__c, o.Manual_Mapping__c, o.Lines_Number__c, o.Line_Type__c, 
	            				o.Line_Designation__c, o.Id, o.Comments__c, o.Change_Reference__c, o.Care_Level__c, o.Attribute_Value__c, 
	            				o.Attribute_Name__c
	            		  From O2_DISE_Map_Landline__c o
	            		  where o.Tariff_Code__c = :tariffcode];
		}
		else
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, o.Package_Code__c, 
	            				o.Name, o.Minutes_Type__c, o.Minutes_Number__c, o.Manual_Mapping__c, o.Lines_Number__c, o.Line_Type__c, 
	            				o.Line_Designation__c, o.Id, o.Comments__c, o.Change_Reference__c, o.Care_Level__c, o.Attribute_Value__c, 
	            				o.Attribute_Name__c
	            		  From O2_DISE_Map_Landline__c o
	            		  ];
		}		  
	            
         //
		for(O2_DISE_Map_Landline__c rec : diseCodeDbList)
		{
			sObject diseObjLL = (sObject) rec;
			diseCodeList.add(diseObjLL);
		}
		
		//RU 20/12/2011: Commented the below code as it was hitting the governor limits(too many script statements)
		//			
		/*for (O2_DISE_Map_Landline__c rec : diseCodeDbList) {
			Map<String,String> recColumnMap = new Map<String,String>();
			recColumnMap.put('Tariff_Code__c',rec.Tariff_Code__c);
			recColumnMap.put('Service_Type__c',rec.Service_Type__c);
			recColumnMap.put('Service_Code__c',rec.Service_Code__c);
			recColumnMap.put('Service_Bill_Label__c',rec.Service_Bill_Label__c);
			recColumnMap.put('Package_Code__c',rec.Package_Code__c);
			recColumnMap.put('Minutes_Type__c',rec.Minutes_Type__c);
			recColumnMap.put('Minutes_Number__c',rec.Minutes_Number__c);
			recColumnMap.put('Name',rec.Name);
			recColumnMap.put('Lines_Number__c',rec.Lines_Number__c);
			recColumnMap.put('Line_Type__c',rec.Line_Type__c);
			recColumnMap.put('Line_Designation__c',rec.Line_Designation__c);
			recColumnMap.put('Change_Reference__c',rec.Change_Reference__c);
			recColumnMap.put('Care_Level__c',rec.Care_Level__c);
			recColumnMap.put('Attribute_Value__c',rec.Attribute_Value__c);
			recColumnMap.put('Attribute_Name__c',rec.Attribute_Name__c);
			//
			diseCodeList.add(recColumnMap);
		}*/
		
		return diseCodeList;
	} 

	public static List<sObject> getISDNDiseCodeMap(String tariffcode) {
		 
		List<sObject> diseCodeList = new List<sObject>();
		List<O2_DISE_Map_ISDN__c> diseCodeDbList;
		if(tariffcode != null)
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
	            				o.Package_Code__c, o.Name, o.Minutes_Type__c, o.Minutes_Number__c, 
	            				o.Manual_Mapping__c, o.Lines_Number__c, o.Line_Type__c, o.Id, o.ISDN_Type__c, 
	            				o.ISDN2_2011Q1_Minutes_Offer__c, o.Comments__c, o.Channels_Number__c, o.Change_Reference__c, 
	            				o.Care_Level__c, o.Attribute_Value__c, o.Attribute_Name__c 
	            		  From O2_DISE_Map_ISDN__c o
	            		  where o.Tariff_Code__c = :tariffcode];
		}
		else
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
	            				o.Package_Code__c, o.Name, o.Minutes_Type__c, o.Minutes_Number__c, 
	            				o.Manual_Mapping__c, o.Lines_Number__c, o.Line_Type__c, o.Id, o.ISDN_Type__c, 
	            				o.ISDN2_2011Q1_Minutes_Offer__c, o.Comments__c, o.Channels_Number__c, o.Change_Reference__c, 
	            				o.Care_Level__c, o.Attribute_Value__c, o.Attribute_Name__c 
	            		  From O2_DISE_Map_ISDN__c o
	            		  ];
		}
		//
		for(O2_DISE_Map_ISDN__c rec : diseCodeDbList)
		{
			sObject diseObj = (sObject) rec;
			diseCodeList.add(diseObj);
		}
		
		//RU 20/12/2011: Commented the below code as it was hitting the governor limits(too many script statements)
		/*for (O2_DISE_Map_ISDN__c rec : diseCodeDbList) {
			Map<String,String> recColumnMap = new Map<String,String>();
			recColumnMap.put('Tariff_Code__c',rec.Tariff_Code__c);
			recColumnMap.put('Service_Type__c',rec.Service_Type__c);
			recColumnMap.put('Service_Code__c',rec.Service_Code__c);
			recColumnMap.put('Service_Bill_Label__c',rec.Service_Bill_Label__c);
			recColumnMap.put('Package_Code__c',rec.Package_Code__c);
			recColumnMap.put('Minutes_Type__c',rec.Minutes_Type__c);
			recColumnMap.put('Minutes_Number__c',rec.Minutes_Number__c);
			recColumnMap.put('Name',rec.Name);
			recColumnMap.put('Lines_Number__c',rec.Lines_Number__c);
			recColumnMap.put('Line_Type__c',rec.Line_Type__c);
			recColumnMap.put('ISDN_Type__c',rec.ISDN_Type__c);
			recColumnMap.put('ISDN2_2011Q1_Minutes_Offer__c',rec.ISDN2_2011Q1_Minutes_Offer__c);
			recColumnMap.put('Channels_Number__c',rec.Channels_Number__c);
			recColumnMap.put('Change_Reference__c',rec.Change_Reference__c);
			recColumnMap.put('Care_Level__c',rec.Care_Level__c);
			recColumnMap.put('Attribute_Value__c',rec.Attribute_Value__c);
			recColumnMap.put('Attribute_Name__c',rec.Attribute_Name__c);
			//
			diseCodeList.add(recColumnMap);
		}*/
	
		return diseCodeList;
	}  

	public static List<sObject> getBBDiseCodeMap(String tariffcode) {
		List<sObject> diseCodeList = new List<sObject>();
		List<O2_DISE_Map_Broadband__c> diseCodeDbList;
		
		if(tariffcode != null)
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
	            				o.Package_Code__c, o.O2_Customer__c, o.Name, o.Manual_Mapping__c, 
	            				o.Line_Type__c, o.Id, o.Free_Of_Charge__c, o.Comments__c, o.Change_Reference__c, 
	            				o.Bundle_Type__c, o.Attribute_Value__c, o.Attribute_Name__c 
	            		  From O2_DISE_Map_Broadband__c o
	            		  where o.Tariff_Code__c = :tariffcode];
	            		  
		}
		else
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
	            				o.Package_Code__c, o.O2_Customer__c, o.Name, o.Manual_Mapping__c, 
	            				o.Line_Type__c, o.Id, o.Free_Of_Charge__c, o.Comments__c, o.Change_Reference__c, 
	            				o.Bundle_Type__c, o.Attribute_Value__c, o.Attribute_Name__c 
	            		  From O2_DISE_Map_Broadband__c o
	            		  ];
		}
		//
		for(O2_DISE_Map_Broadband__c rec : diseCodeDbList)
		{
			sObject diseObjBB = (sObject) rec;
			diseCodeList.add(diseObjBB);
		}
		
		//RU 20/12/2011: Commented the below code as it was hitting the governor limits(too many script statements)
		/*for (O2_DISE_Map_Broadband__c rec : diseCodeDbList) {
			Map<String,String> recColumnMap = new Map<String,String>();
			recColumnMap.put('Tariff_Code__c',rec.Tariff_Code__c);
			recColumnMap.put('Service_Type__c',rec.Service_Type__c);
			recColumnMap.put('Service_Code__c',rec.Service_Code__c);
			recColumnMap.put('Service_Bill_Label__c',rec.Service_Bill_Label__c);
			recColumnMap.put('Package_Code__c',rec.Package_Code__c);
			recColumnMap.put('O2_Customer__c',rec.O2_Customer__c);
			recColumnMap.put('Name',rec.Name);
			recColumnMap.put('Free_Of_Charge__c',rec.Free_Of_Charge__c);
			recColumnMap.put('Change_Reference__c',rec.Change_Reference__c);
			recColumnMap.put('Bundle_Type__c',rec.Bundle_Type__c);
			recColumnMap.put('Attribute_Value__c',rec.Attribute_Value__c);
			recColumnMap.put('Attribute_Name__c',rec.Attribute_Name__c);
			//
			diseCodeList.add(recColumnMap);
		}*/
		
		return diseCodeList;
	}   

	public static List<sObject> getMinutesDiseCodeMap() {
		List<O2_DISE_Map_Minutes__c> diseCodeDbList = 
            		[select o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
            				o.Name, o.Minutes_Type__c, o.Minutes_Number__c, o.Manual_Mapping__c, 
            				o.Id, o.Change_Reference__c, o.Attribute_Value__c, o.Attribute_Name__c 
            		  From O2_DISE_Map_Minutes__c o];
		//
		List<sObject> diseCodeList = new List<sObject>();
		
		for(O2_DISE_Map_Minutes__c rec : diseCodeDbList)
		{
			sObject diseObjMins = (sObject) rec;
			diseCodeList.add(diseObjMins);
		}
		
		//RU 20/12/2011: Commented the below code as it was hitting the governor limits(too many script statements)
		/*for (O2_DISE_Map_Minutes__c rec : diseCodeDbList) {
			Map<String,String> recColumnMap = new Map<String,String>();
			recColumnMap.put('Service_Type__c',rec.Service_Type__c);
			recColumnMap.put('Service_Code__c',rec.Service_Code__c);
			recColumnMap.put('Service_Bill_Label__c',rec.Service_Bill_Label__c);
			recColumnMap.put('Minutes_Type__c',rec.Minutes_Type__c);
			recColumnMap.put('Minutes_Number__c',rec.Minutes_Number__c);
			recColumnMap.put('Name',rec.Name);
			recColumnMap.put('Change_Reference__c',rec.Change_Reference__c);
			recColumnMap.put('Attribute_Value__c',rec.Attribute_Value__c);
			recColumnMap.put('Attribute_Name__c',rec.Attribute_Name__c);
			//
			diseCodeList.add(recColumnMap);
		}*/
		return diseCodeList;
	}    

	public static List<sObject> getNGNDiseCodeMap(String tariffcode) {
		List<sObject> diseCodeList = new List<sObject>();
		List<O2_DISE_Map_NGN__c> diseCodeDbList;
		if(tariffcode != null)
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
	            				o.Package_Code__c, o.Name, o.Manual_Mapping__c, o.Id, o.Directorate__c, o.Comments__c, 
	            				o.Change_Reference__c, o.Attribute_Value__c, o.Attribute_Name__c 
	            		  From O2_DISE_Map_NGN__c o
	            		  where o.Tariff_Code__c = :tariffcode];
		}
		else
		{
			diseCodeDbList = 
	            		[select o.Tariff_Code__c, o.Service_Type__c, o.Service_Code__c, o.Service_Bill_Label__c, 
	            				o.Package_Code__c, o.Name, o.Manual_Mapping__c, o.Id, o.Directorate__c, o.Comments__c, 
	            				o.Change_Reference__c, o.Attribute_Value__c, o.Attribute_Name__c 
	            		  From O2_DISE_Map_NGN__c o
	            		  ];
		}
		//
		for(O2_DISE_Map_NGN__c rec : diseCodeDbList)
		{
			sObject diseObjNGN = (sObject) rec;
			diseCodeList.add(diseObjNGN);
		}
		
		//RU 20/12/2011: Commented the below code as it was hitting the governor limits(too many script statements)
		/*for (O2_DISE_Map_NGN__c rec : diseCodeDbList) {
		Map<String,String> recColumnMap = new Map<String,String>();
		recColumnMap.put('Tariff_Code__c',rec.Tariff_Code__c);
		recColumnMap.put('Service_Type__c',rec.Service_Type__c);
		recColumnMap.put('Service_Code__c',rec.Service_Code__c);
		recColumnMap.put('Service_Bill_Label__c',rec.Service_Bill_Label__c);
		recColumnMap.put('Package_Code__c',rec.Package_Code__c);
		recColumnMap.put('Directorate__c',rec.Directorate__c);
		recColumnMap.put('Name',rec.Name);
		recColumnMap.put('Change_Reference__c',rec.Change_Reference__c);
		recColumnMap.put('Attribute_Value__c',rec.Attribute_Value__c);
		recColumnMap.put('Attribute_Name__c',rec.Attribute_Name__c);
		//
		diseCodeList.add(recColumnMap);
		}*/

		return diseCodeList;
	} 
	
	/******************
	public static List<Map<String,String>> getDiseCodeMap(String tableName) {
		//
 		// Get all the Map Details
 		String queryString = null;
        queryString = 'select '+Utility.getSobjectFields(tableName)+' from '+tableName;
        List<sObject> diseCodeDbList = Database.query(queryString);
        //
        List<Map<String,String>> diseCodeList = new List<Map<String,String>>();
        //
        List<String> columnNameList = Utility.getSobjectFields(tableName).split(',');
        //
        for (sObject rec : diseCodeDbList) {
        	Map<String,String> recColumnMap = new Map<String,String>();
        	for (String col : columnNameList) {
        		try {
        			recColumnMap.put(col,(String)rec.get(col));
        		} catch(Exception ex) {
        			// do nothing, we are only interested in strings.
        		}
        	}
        	//
			diseCodeList.add(recColumnMap);
        }
        //
        return diseCodeList;
	}
	***************/
	public static Map<String,cscfgc__Lookup_Query__c> getLookupQuery(List<String> lookupQueryIdList) {
		Map<String,cscfgc__Lookup_Query__c> lookupQueryMap = new Map<String,cscfgc__Lookup_Query__c>(
														[select Id, cscfgc__Logic__c, cscfgc__Lookup_Config__c, Name, 
																(select Id, Name, cscfgc__Field__c, cscfgc__Operator__c, cscfgc__Value__c from cscfgc__Lookup_Criteria__r)
														   from cscfgc__Lookup_Query__c 
														  where id in :lookupQueryIdList]);
		//
		return lookupQueryMap;
	}
}