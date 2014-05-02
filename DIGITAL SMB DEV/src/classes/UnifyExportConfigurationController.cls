/**
*   Controller for UnifyExportConfiguration Page, performs configuration export
*   @since  14/01/2013
*   @author  lukasz.skrodzki@cloudsensesolutions.com, ivan.tadic@cloudsensesolutions.com
*/
public with sharing class UnifyExportConfigurationController {
    public String exportContent {get;set;}
    public final static string delim = '$$';
    public String fileName {get;set;}

    public UnifyExportConfigurationController(){
        fileName = System.now().format('yyyyMMdd');

        Map<String, String> mPar = System.currentPageReference().getParameters();

        if(mPar.containsKey('id')){
            String noteId = mPar.get('id');
            String orderGroupId = '';
            if(mPar.containsKey('ogId'))
            	orderGroupId = mPar.get('ogId');

            Note n = [select Id, Body from Note where Id = :noteId];

            UnifyExportSiteSelectionController.exportRequestClass req = new UnifyExportSiteSelectionController.exportRequestClass();

            req = (UnifyExportSiteSelectionController.exportRequestClass)JSON.deserialize(n.Body, UnifyExportSiteSelectionController.exportRequestClass.class);
            System.debug('***** req ' + req);

            cscfgc__Product_Configuration__c[] tempConfs;
            Map<Id,List<SLA__c>> mapOrdSLAs = new Map<Id,List<SLA__c>>();


			List<id> sitesIdList = req.sitesIds;
			//Get All Sites and their Orders
	        string sitesQuery = 'SELECT ' + Utility.getSobjectFields('Unify_Site__c') + ', ' +
	        					'Order_Group__r.Unify_Customer_Purchase_order__c, Order_Group__r.Unify_Supplier_Purchase_order__c, ' +
	        					'Location__r.PAF_Building_Name__c, Location__r.Contact__r.Name, Location__r.Contact__r.Phone, Location__r.Contact__r.Email, ' +
	        					'Location__r.Street__c, Location__r.PAF_Post_Town__c, Location__r.PAF_County__c, Location__r.PAF_Postcode__c, Location__r.Country__c, ' +
	        					'(SELECT ' + Utility.getSobjectFields('Order__c') +' FROM Orders__r) ' +
	        					' FROM Unify_Site__c WHERE Id IN :sitesIdList ORDER BY Name';
			List<Unify_Site__c> sites = Database.query(sitesQuery);

			//Create Sets:  All Orders, All Product Configurations
			Set<Id> prodConfigSet = new Set<Id>();
			Set<Id> orderSet = new Set<Id>();
			Map<Id,Order__c> pcOrderMap = new Map<Id,Order__c>();
			for(Unify_Site__c site : sites){
				for(Order__c o : site.Orders__r){
					orderSet.add(o.Id);
					prodConfigSet.add(o.Product_Configuration__c);
					pcOrderMap.put(o.Product_Configuration__c,o);
				}
			}

			//Get Product configs
            if(req.exportType == 'SNOW') {
                tempConfs = [SELECT
                				Id, Name, Unify_Solution__c, cscfgc__Product_Definition__r.Name,
                				(SELECT
                					Id, Name, cscfgc__Attribute_Definition__r.cscfgc__Label__c, cscfgc__Value__c, cscfgc__Price__c,
                					cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name, cscfgc__Attribute_Definition__r.Name,
                					cscfgc__Attribute_Definition__r.Unify_SNOW_exportable__c,
                					cscfgc__Attribute_Definition__r.Unify_SNOW_Export_Order__c
                                FROM
                                	cscfgc__Attributes__r
                                WHERE
                                	cscfgc__Attribute_Definition__r.Unify_SNOW_exportable__c = TRUE
                                ORDER BY
                                	cscfgc__Attribute_Definition__r.Unify_SNOW_Export_Order__c)
                             FROM
                             	cscfgc__Product_Configuration__c
                             WHERE
                             	Id IN :prodConfigSet
                             ORDER BY
                             	cscfgc__Product_Definition__r.Name];
            }
            else if(req.exportType == 'DISE') {
                tempConfs = [SELECT
                				Id, Name, Unify_Solution__c, cscfgc__Product_Definition__r.Name,
                           		(SELECT
                					Id, Name, cscfgc__Attribute_Definition__r.cscfgc__Label__c, cscfgc__Value__c, cscfgc__Price__c,
                					cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name, cscfgc__Attribute_Definition__r.Name,
                					cscfgc__Attribute_Definition__r.Unify_DISE_exportable__c,
                					cscfgc__Attribute_Definition__r.Unify_DISE_Export_Order__c
                                FROM
                                	cscfgc__Attributes__r
                                WHERE
                                	cscfgc__Attribute_Definition__r.Unify_DISE_exportable__c = TRUE
                                ORDER BY
                                	cscfgc__Attribute_Definition__r.Unify_DISE_Export_Order__c)
                             FROM
                             	cscfgc__Product_Configuration__c
                             WHERE
                             	Id IN :prodConfigSet
                             ORDER BY
                             	cscfgc__Product_Definition__r.Name];
            }
            Map<Id,cscfgc__Product_Configuration__c> prodConfigsMap = new Map<Id,cscfgc__Product_Configuration__c>(tempConfs);

			//Get all SLA's
			Map<Id,Order__c> ordersWithSLAsMap = new Map<Id,Order__c>([SELECT Id,(SELECT Id,Actual_Date__c,Name FROM SLAs__r WHERE Name IN ('Billing start date')) FROM Order__c WHERE Id in :orderSet]);

            String singleLine = '';

            if(req.exportType == 'DISE' || req.exportType == 'SNOW') {
                fileName = fileName + '_export_to_' + req.exportType;

                //Begining of csv header for export - hardcoded Site Name field
                exportContent = '<tr><td>Site Name</td>';
                exportContent += '<td>Solution</td>';
                exportContent += '<td>Account Number</td>';
                exportContent += '<td>Corporate Code</td>';
                exportContent += '<td>Group Code</td>';
                exportContent += '<td>Cost Centre</td>';
                exportContent += '<td>Customer Purchase Order</td>';
                exportContent += '<td>Supplier Purchase Order</td>';
                exportContent += '<td>Account Level Billing</td>';
                exportContent += '<td>Cancellation Costs</td>';
                exportContent += '<td>Billing Start Date</td>';
                exportContent += '<td>Comments</td>';

                //The header of csv will contain then attributes names
                Set<String> attributeNames = new Set<String>();
                decimal seqNo = 0;
                for(cscfgc__Product_Configuration__c pc : tempConfs) {
                    //If SNOW, skip canceled Orders
                    if(req.exportType == 'SNOW' && pcOrderMap.get(pc.Id).Order_Status__c == 'Cancelled')
                    	continue;

                    for(cscfgc__Attribute__c attr : pc.cscfgc__Attributes__r) {

						// Those are the attributes common for all pillars which we pull to one coulmn
                        if(attr.cscfgc__Attribute_Definition__r.Name != 'Supplier Purchase Order' &&
                             attr.cscfgc__Attribute_Definition__r.Name != 'Customer Purchase Order' &&
                             attr.cscfgc__Attribute_Definition__r.Name != 'Bill Account' &&
                             attr.cscfgc__Attribute_Definition__r.Name != 'Comment' &&
                             attr.cscfgc__Attribute_Definition__r.Name != 'Tariff Code'){
							// ignore PO attribute, we deal with it separetly later

                            if(req.exportType == 'DISE') {
                                seqNo = attr.cscfgc__Attribute_Definition__r.Unify_DISE_Export_Order__c;
                            } else {
                                seqNo = attr.cscfgc__Attribute_Definition__r.Unify_SNOW_Export_Order__c;
                            }
                            String attLabel;
                            if(attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c != null && attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c != ''){
                                attLabel = attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c;
                            }else{
                                attLabel = attr.cscfgc__Attribute_Definition__r.Name;
                            }
                            attributeNames.add(attr.cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name + '_' + delim + convertToStringFixedLength(seqNo) + delim + '_' + attLabel);
                        }
                    }
                }
                List<String> sortedAttributeNames = new List<String>();
                sortedAttributeNames.addAll(attributeNames);
                sortedAttributeNames.sort();
                //Check if the Site Tariff Code has been already put -  it should be the first column after Connectivity Pilar
                boolean tariffColumnPut = false;
                List<String> lAttributeNames = new List<String>();
                for(String attr : sortedAttributeNames) {
                    if(!tariffColumnPut && !attr.startsWith(UnifyConfig.mPillars2Name().get('Connectivity'))){
                        exportContent += '<td>Site Tariff Code</td>';
                        tariffColumnPut = true;
                    }
                    string ph1 = attr.substring(0,attr.indexOf(delim));
                    string ph2 = attr.substring(attr.indexOf(delim) + 9);
                    attr = ph1 + ph2;
                    exportContent += '<td>' + attr + '</td>';
                    lAttributeNames.add(attr);
                }

				// End of the header
                exportContent += '</tr>';

                exportContent += '\n';


				//Go through all sites
				for(Unify_Site__c site : sites){

					//Go trough all orders
					for(Order__c o : site.Orders__r){
						if(o.Order_Status__c == 'Cancelled'){
	                        exportContent += '<tr style="background-color:red"><td>' + site.Name +'</td>';
	                    }else{
	                        exportContent += '<tr><td>' + site.Name + '</td>';
	                    }

	                   	// Putting attributes values for all sites in separate lines
						exportContent += '<td>' + site.Solution__c + '</td>';
	                    exportContent += '<td>' + site.Dise_Account_No__c + '</td>';
	                    exportContent += '<td>' + site.Corporate_Code__c + '</td>';
	                    exportContent += '<td>' + site.Group_Code__c + '</td>';
	                    exportContent += '<td>' + site.Cost_Centre__c + '</td>';

	                    //Get Product Configuration
			            cscfgc__Product_Configuration__c pc = prodConfigsMap.get(o.Product_Configuration__c);

						Map<String, String> attrToValueMap = new Map<String, String>();
	                    for(cscfgc__Attribute__c attr : pc.cscfgc__Attributes__r) {
	                        String attLabel;
	                        if(attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c != null && attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c != ''){
	                            attLabel = attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c;
	                        }else{
	                            attLabel = attr.cscfgc__Attribute_Definition__r.Name;
	                        }
	                        //If attribute has price value use it instead of normal value
	                        if(attr.cscfgc__Price__c != null){
	                            attrToValueMap.put(attr.cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name + '_' + attLabel, '£' + String.valueOf(attr.cscfgc__Price__c));
	                        }else{
	                            string attrValue = attr.cscfgc__Value__c;
	                            if(attr.Name == 'DISE Bill Label' && attr.cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name == 'Hardware'){
	                                if(attrValue.length() > 30){
	                                	attrValue = attrValue.substring(0,30);
	                                }
	                            }
	                            attrToValueMap.put(attr.cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name + '_' + attLabel, attrValue);
	                        }
	                    }
	                    String customerPurchaseOrder =  '';
	                    String supplierPurchaseOrder = '';
	                    String billAccount = 'No';
	                    String tariffCode = '';
	                    String comment = '';
	                    if(attrToValueMap.containsKey(pc.cscfgc__Product_Definition__r.Name + '_Customer Purchase Order')
	                    	&& !string.isBlank(attrToValueMap.get(pc.cscfgc__Product_Definition__r.Name + '_Customer Purchase Order'))){
	                    		//Order PO
	                        	customerPurchaseOrder = attrToValueMap.get(pc.cscfgc__Product_Definition__r.Name + '_Customer Purchase Order');
	                    }else if(!string.isBlank(site.Customer_Purchase_Order__c)){
	                    		//Site PO
	                        	customerPurchaseOrder = site.Customer_Purchase_Order__c;
	                    }else{
	                    		//Order Group PO
	                        	customerPurchaseOrder = site.Order_Group__r.Unify_Customer_Purchase_order__c;
	                    }
	                    if(attrToValueMap.containsKey(pc.cscfgc__Product_Definition__r.Name + '_Supplier Purchase Order')
	                    	&& !string.isBlank(attrToValueMap.get(pc.cscfgc__Product_Definition__r.Name + '_Supplier Purchase Order'))){
	                    		//Order PO
	                        	supplierPurchaseOrder = attrToValueMap.get(pc.cscfgc__Product_Definition__r.Name + '_Supplier Purchase Order');
	                    }else if(!string.isBlank(site.Supplier_Purchase_Order__c)){
	                    		//Site PO
	                        	supplierPurchaseOrder = site.Supplier_Purchase_Order__c;
	                    }else{
	                    		//Order Group PO
	                        	supplierPurchaseOrder = site.Order_Group__r.Unify_Supplier_Purchase_order__c;
	                    }

	                    if(attrToValueMap.containsKey(pc.cscfgc__Product_Definition__r.Name + '_Bill Account')){
	                        billAccount = attrToValueMap.get(pc.cscfgc__Product_Definition__r.Name + '_Bill Account').toUpperCase();
	                    }
	                    if(attrToValueMap.containsKey(pc.cscfgc__Product_Definition__r.Name + '_DISE Tariff Code')){
	                        tariffCode = attrToValueMap.get(pc.cscfgc__Product_Definition__r.Name + '_DISE Tariff Code');
	                    }
	                    if(attrToValueMap.containsKey(pc.cscfgc__Product_Definition__r.Name + '_Comment')){
	                        comment = attrToValueMap.get(pc.cscfgc__Product_Definition__r.Name + '_Comment');
	                    }
	                    exportContent += '<td>' + customerPurchaseOrder + '</td>';
	                    exportContent += '<td>' + supplierPurchaseOrder + '</td>';
	                    exportContent += '<td>' + billAccount + '</td>';
	                    exportContent += '<td>' + o.Unify_Cancellation_Costs__c + '</td>';
	                    Order__c oWSLA = ordersWithSLAsMap.get(o.Id);
	                    Datetime billingStartDate = oWSLA.SLAs__r.size() > 0 ? oWSLA.SLAs__r[0].Actual_Date__c : null;
	                    exportContent += '<td>' + billingStartDate + '</td>';
	                    exportContent += '<td>' + comment + '</td>';
	                    Boolean tariffValuePut = false;
	                    for(String attrName : lAttributeNames) {
	                        if(!tariffValuePut && !attrName.startsWith(UnifyConfig.mPillars2Name().get('Connectivity'))){
	                            exportContent += '<td>' + tariffCode + '</td>';
	                            tariffValuePut = true;
	                        }
	                        if(attrToValueMap.get(attrName) != null ) {
	                            exportContent += '<td>' + attrToValueMap.get(attrName)+ '</td>';
	                        } else {
	                            exportContent += '<td/>';
	                        }
	                    }
						// End of the row
	                    exportContent += '</tr>\n';
					}
				}
            }

            if(req.exportType == 'SNOW') {

                //Begining of csv header for export - hardcoded Site Name field
                exportContent = '<tr><td>DISE Account Number</td>';
                exportContent += '<td>Corporate Code</td>';
                exportContent += '<td>Site Name</td>';
                exportContent += '<td>Location(Building)</td>';
                exportContent += '<td>Application Tags</td>';
                exportContent += '<td>Autonomous System Number</td>';
                exportContent += '<td>Contact Name</td>';
                exportContent += '<td>Contact Number</td>';
                exportContent += '<td>Contact Email</td>';
                exportContent += '<td>Address Street</td>';
                exportContent += '<td>Address Town</td>';
                exportContent += '<td>Address County</td>';
                exportContent += '<td>Address Post Code</td>';
                exportContent += '<td>Address Country</td>';
                exportContent += '<td>Solution</td>';
                //The header of csv will contain then attributes names
                Set<String> attributeNames = new Set<String>();
                decimal seqNo = 0;
                for(cscfgc__Product_Configuration__c pc : tempConfs) {
                    if(req.exportType == 'SNOW' && pcOrderMap.get(pc.Id).Order_Status__c == 'Cancelled')
                    	continue;
                    for(cscfgc__Attribute__c attr : pc.cscfgc__Attributes__r) {
                    	//Bill Account
                        seqNo = attr.cscfgc__Attribute_Definition__r.Unify_SNOW_Export_Order__c;
                        String attLabel;
                        if(!string.isBlank(attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c)){
                            attLabel = attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c;
                        }else{
                            attLabel = attr.cscfgc__Attribute_Definition__r.Name;
                        }
                        attributeNames.add(attr.cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name + '_' + delim + convertToStringFixedLength(seqNo) + delim + '_' + attLabel);
                    }
                }
                List<String> sortedAttributeNames = new List<String>();
                sortedAttributeNames.addAll(attributeNames);
                sortedAttributeNames.sort();
                List<String> lAttributeNames = new List<String>();
                for(String attr : sortedAttributeNames) {
                    string ph1 = attr.substring(0,attr.indexOf(delim));
                    string ph2 = attr.substring(attr.indexOf(delim) + 9);
                    attr = ph1 + ph2;
                    exportContent += '<td>' + attr + '</td>';
                    lAttributeNames.add(attr);
                }
                exportContent += '</tr>';

                exportContent += '\n';



                //Go through all sites
				for(Unify_Site__c site : sites){
                	//Go trough all orders
					for(Order__c o : site.Orders__r){
						//Skip cancelled orders
						if(o.Order_Status__c == 'Cancelled')
							continue;

						//Fill sites attributes
                        exportContent += '<tr><td>' + site.DISE_Account_No__c + '</td>';
                        exportContent += '<td>' + site.Corporate_Code__c + '</td>';
                        exportContent += '<td>' + site.Name + '</td>';
                        exportContent += '<td>' + site.Location__r.PAF_Building_Name__c + '</td>';
                        exportContent += '<td>' + site.Application_Tags__c +'</td>';
                        exportContent += '<td>' + site.Autonomous_System_Number__c +'</td>';
                        exportContent += '<td>' + site.Location__r.Contact__r.Name + '</td>';
                        exportContent += '<td>' + site.Location__r.Contact__r.Phone + '</td>';
                        exportContent += '<td>' + site.Location__r.Contact__r.Email + '</td>';
                        exportContent += '<td>' + site.Location__r.Street__c + '</td>';
                        exportContent += '<td>' + site.Location__r.PAF_Post_Town__c + '</td>';
                        exportContent += '<td>' + site.Location__r.PAF_County__c + '</td>';
                        exportContent += '<td>' + site.Location__r.PAF_Postcode__c + '</td>';
                        exportContent += '<td>' + site.Location__r.Country__c + '</td>';
                        exportContent += '<td>' + site.Solution__c + '</td>';

						//Get Product Configuration
		            	cscfgc__Product_Configuration__c pc = prodConfigsMap.get(o.Product_Configuration__c);

						//Fill configuration attributes
                        Map<String, String> attrToValueMap = new Map<String, String>();
                        for(cscfgc__Attribute__c attr : pc.cscfgc__Attributes__r) {
                            String attLabel;
                            if(attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c != null && attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c != ''){
                                attLabel = attr.cscfgc__Attribute_Definition__r.cscfgc__Label__c;
                            }else{
                                attLabel = attr.cscfgc__Attribute_Definition__r.Name;
                            }
                            attrToValueMap.put(attr.cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name + '_' + attLabel, attr.cscfgc__Value__c);
                        }

                        for(String attrName : lAttributeNames) {
                            if(attrToValueMap.get(attrName) != null ) {
                                exportContent += '<td>' + attrToValueMap.get(attrName)+ '</td>';
                            } else {
                                exportContent += '<td/>';
                            }
                        }
                        exportContent += '</tr>\n';
					}
				}
            }
        }
        exportContent = exportContent.replaceAll('<td>null</td>','<td/>');
    }

    public string convertToStringFixedLength(decimal i){
        if(i != null){
           if(i<10){
               return '000'+i;
           }else if(i < 100){
                return '00' + i;
           }else if(i < 1000){
                return '0' + i;
           } else {
               return string.valueOf(i);
           }
        } else {
            return '99';
        }
    }
}