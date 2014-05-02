public with sharing class OpportunityHelper {
    //
    public static void createServicesFromOpportunity(List<Opportunity> wonOppList, Map<ID,Opportunity> wonOppMap) {
    	// Create a new Service record for every won opportunity
        List<Order__c> orderList = new List<Order__c>();
        Integer svcNumber = 0;
        String mainContactId = null;
        //
        for(Integer i = 0; i < wonOppList.size(); i++) {
        	// Get the current opportunity object
            Opportunity opp = wonOppMap.get(wonOppList[i].Id);
            // 
            // Get the Main Contact to populate against the created services
            if (opp.OpportunityContactRoles.size() != 0) {
                for (OpportunityContactRole oppContactRole : opp.OpportunityContactRoles) {
                    if (oppContactRole.Role == 'Technical Buyer') {
                        if (mainContactId == null)
                            mainContactId = oppContactRole.contactId;
                    } 
                    //
                    if (oppContactRole.IsPrimary){
                        if (mainContactId == null)
                            mainContactId = oppContactRole.contactId;
                    }
                }
                //
                if (mainContactId == null) {
                    //throw new ContactRoleException('The Opportunity does not have a Primary contact. Add a primary contact first');
                }
            } else {
                //throw new ContactRoleException('The Opportunity does not have a Primary contact. Add a primary contact first');
            }
            //
            // Get a List of bundle Ids
            List<String> prodBundleIdList = new List<String>();
            // 
            for (cscfgc__Product_Bundle__c prodBundle : opp.cscfgc__Product_Bundles__r) {
            	prodBundleIdList.add(prodBundle.Id);
            }
            // Get a list of all bundle Configs
            List<cscfgc__Product_Configuration__c> prodConfigList = [select Id, Name, cscfgc__Parent_Configuration__c, cscfgc__Product_Bundle__c, cscfgc__Product_Definition__r.Name,
            											 (select Id, cscfgc__Attribute_Definition__r.Name, cscfgc__is_Line_Item__c, 
            											  cscfgc__Line_Item_Description__c, cscfgc__Line_Item_Sequence__c, cscfgc__Price__c, cscfgc__Value__c, 
            											  cscfgc__Product_Configuration__c from cscfgc__Attributes__r order by cscfgc__Line_Item_Sequence__c) from cscfgc__Product_Configuration__c 
            											  where cscfgc__Product_bundle__c in :prodBundleIdList];
            // Get a Map of all product configs keyed on bundle
            Map<String,list<cscfgc__Product_Configuration__c>> prodConfigMap = new Map<String,List<cscfgc__Product_Configuration__c>>();
            List<cscfgc__Product_Configuration__c> pConfigList;
            for (cscfgc__Product_Configuration__c prodConfig : prodConfigList) {
            	if (prodConfigMap.containsKey(prodConfig.cscfgc__Product_Bundle__c)) {
            		pConfigList = prodConfigMap.get(prodConfig.cscfgc__Product_Bundle__c);
            		pConfigList.add(prodConfig);
            		prodConfigMap.put(prodConfig.cscfgc__Product_Bundle__c,pConfigList);
            	} else {
            		pConfigList = new List<cscfgc__Product_Configuration__c>();
            		pConfigList.add(prodConfig);
            		prodConfigMap.put(prodConfig.cscfgc__Product_Bundle__c,pConfigList);
            	}
            }
            //
            List<String> ProdConfigIdList = new List<String>();
            // Loop throiugh all the bundles
            for (cscfgc__Product_Bundle__c prodBundle : opp.cscfgc__Product_Bundles__r) {
            	List<cscfgc__Product_Configuration__c> productConfigList;
            	if (prodConfigMap.containsKey(prodBundle.Id)) {
            		productConfigList = prodConfigMap.get(prodBundle.Id);
	            	// Loop through all configurations for this bundle
	            	for (cscfgc__Product_Configuration__c prodConfig : productConfigList) {
	            		// Loop thorugh all attributes in this configuration
	            		Map<String,cscfgc__Attribute__c> attributeMap = new Map<String,cscfgc__Attribute__c>();
	            		for (cscfgc__Attribute__c attrib : prodConfig.cscfgc__Attributes__r) {
	            			System.debug('******>>>>Attribute Name:'+attrib.cscfgc__Attribute_Definition__r.Name+'='+
	            						 attrib.cscfgc__Value__c+' --> sequence ='+attrib.cscfgc__Line_Item_Sequence__c+
	            						 ' : LineItemFlag = '+attrib.cscfgc__Line_Item_Sequence__c+' : Price='+
	            						 attrib.cscfgc__Price__c+' Description='+attrib.cscfgc__Line_Item_Description__c);
	            			attributeMap.put(attrib.cscfgc__Attribute_Definition__r.Name,attrib);
	            		}
	            		//
	            		Order__c currentOrder = new Order__c();
	            		if (attributeMap.containsKey('Installation PostCode')) {
	            			if (attributeMap.get('Installation PostCode').cscfgc__value__c != null) {
	            				currentOrder.Name = prodConfig.Name+' - '+attributeMap.get('Installation PostCode').cscfgc__value__c;
	            			} else {
	            				currentOrder.Name = prodConfig.Name;
	            			}
	            		} else {
	            			currentOrder.Name = prodConfig.Name;
	            		}
	            		String orderType;
	            		if (opp.type == 'New Business') {
	            			orderType = opp.Type;
	            		} else {
	            			//orderType = opp.Existing_Business_Change_Type__c;
	            		}
	            		currentOrder.Order_Status__c = 'In Provisioning';
	            		currentOrder.Order_Status_Reason__c = orderType;
	            		currentOrder.Sales_Order_Type__c = orderType;
	            		//currentOrder.Related_Parent_Order__c = opp.order_to_be_Replaced__c;
	            		currentOrder.Product_Type__c = prodConfig.cscfgc__Product_Definition__r.Name;
	            		currentOrder.Process_Orchestration_Enabled__c = true;
	            		currentOrder.Opportunity__c = opp.Id;
	            		currentOrder.Account__c = opp.AccountId;
	            		currentOrder.Main_Contact__c = mainContactId;
	            		currentOrder.Product_Configuration__c = prodConfig.Id;
	            		//
	            		ProdConfigIdList.add(prodConfig.Id);
	            		//
	            		orderList.add(currentOrder);
	            	}
            	}
            }
            insert orderList;
            //
            // Create a Map of Config Id and Service Id
            Map<String,String> orderProdConfigMap = new Map<String,String>();
            for (Order__c order : orderList) {
            	orderProdConfigMap.put(order.Product_Configuration__c,order.Id);
            } 
            //
            // Get a list of all bundle Configs
            List<cscfgc__Product_Configuration__c> prodConfiglineItemList = [select Id, Name, cscfgc__Parent_Configuration__c, cscfgc__Product_Bundle__c, cscfgc__Product_Definition__r.Name,
            											 (select Id, cscfgc__Attribute_Definition__r.Name, cscfgc__is_Line_Item__c, 
            											  cscfgc__Line_Item_Description__c, cscfgc__Line_Item_Sequence__c, cscfgc__Price__c, cscfgc__Value__c, 
            											  cscfgc__Product_Configuration__c from cscfgc__Attributes__r where cscfgc__is_Line_Item__c = true order by cscfgc__Line_Item_Sequence__c) from cscfgc__Product_Configuration__c 
            											  where id in :ProdConfigIdList];
            //
            List<Order_Line_Item__c> orderLineItemsList = new List<Order_Line_Item__c>();
            String paymentFrequency = 'One-Off';
            // Loop through the Configurations and add line items to the services inserted above
            for (cscfgc__Product_Configuration__c pc : prodConfiglineItemList) {
            	for (cscfgc__Attribute__c attrib : pc.cscfgc__Attributes__r) {
            		if (attrib.cscfgc__Attribute_Definition__r.Name == 'Install charge') {
            			paymentFrequency = 'One-Off';
            		} else {
            			paymentFrequency = 'Recurring';
            		}
            		Order_Line_Item__c orderli = new Order_Line_Item__c(List_price__c               = attrib.cscfgc__Price__c,
								                    					Name                        = attrib.cscfgc__Line_Item_Description__c,
								                    					Line_Description__c         = attrib.cscfgc__Line_Item_Description__c,
								                    					Quantity__c                 = 1,
								                    					Sales_Price__c              = attrib.cscfgc__Price__c,
								                    					Total_Price__c              = attrib.cscfgc__Price__c,
								                    					Payment_Frequency__c        = paymentFrequency,
								                    					order__c                    = orderProdConfigMap.get(pc.Id)
								                    				   );
					orderLineItemsList.add(orderli);
            	}
            }
            insert orderLineItemsList;
        }
    }
    
    //
    public static Map<ID,Opportunity> getMapOfWonOpportunities(List<Opportunity> wonOppList) {
        // Get a Map of the won Opportunities and their corresponding Line Items, and primary contact 
        //
        String queryString = null;
        queryString = 'select '+getSobjectFields('Opportunity')+', (select '+getSobjectFields('OpportunityLineItem')+
            ', PriceBookEntry.Name,PriceBookEntry.ProductCode from OpportunityLineItems), (select contactId,IsPrimary,Role from OpportunityContactRoles '+
            ' where IsPrimary = true or Role = \'Technical Buyer\' or Role = \'Homeworker\'), (select '+getSobjectFields('cscfgc__Product_Bundle__c')+
            ' from cscfgc__Product_Bundles__r) from Opportunity where ID in '+convertListToString(wonOppList);
        //
        List<Opportunity> OppList = Database.query(queryString);
        Map <ID,Opportunity> wonOppMap = new Map <ID,Opportunity> ();
        for (Opportunity opp : OppList) {
            wonOppMap.put(opp.Id,opp);
        }
        return wonOppMap;
    }
    
    // Get a comma separated SObject Field list 
    public static String getSobjectFields(String so) {
        String fieldString;
   
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        if (sot == null) return null;
   
        List<Schema.SObjectField> fields = sot.getDescribe().fields.getMap().values();
       
        fieldString = fields[0].getDescribe().LocalName;
        for (Integer i = 1; i < fields.size(); i++) {
            fieldString += ',' + fields[i].getDescribe().LocalName;
        }
        return fieldString;
    }
        
    // convert a List to a Quoted comma separated list in Parentheses 
    // for use with the in clause in dynamic SOQL
    public static String convertListToString(List<SObject> vList) {
        String listString = '(\'\')';
        if (vList.size() > 0) {
            listString = '(\''+vList[0].Id+'\'';
            for (Integer i = 1; i < vList.size(); i++) {
                listString += ',\'' + vList[i].Id+'\'';
            }
            listString += ')';
        }
        return listString ;
    }

}