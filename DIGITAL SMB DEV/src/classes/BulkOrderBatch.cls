global class BulkOrderBatch implements Database.Batchable<sObject>,Database.Stateful{
    global List<String> bulkOrderRecordIds;
    
    private	cscfgc__Product_Definition__c smbLandline = [SELECT Id, Name FROM cscfgc__Product_Definition__c WHERE Name = 'SMB Landline' LIMIT 1];
	private cscfgc__Product_Definition__c smbBoltOns = [select Id, Name from cscfgc__Product_Definition__c WHERE Name = 'Landline Bolt Ons' LIMIT 1];
	
	public cscfgc.Api_1.ApiSession apiSess {get; set;}
	public cscfgc.SessionManager.SessionInfo userSess {get; set;}
	
	public cscfgc__Product_Basket__c basket {get; set;} 
	public Opportunity opp;
	public String accountId ;
	public String contactId ;

	global String message = '';
	global Integer recordSize = 0;
    

	public BulkOrderBatch(){
		
	}
	
	public BulkOrderBatch(List<Id> bulkOrderRecordIds){
		this.bulkOrderRecordIds = bulkOrderRecordIds;
		recordSize = bulkOrderRecordIds.size();
		
	}

	 
    global Database.QueryLocator start(Database.BatchableContext BC){ 
 			return Database.getQueryLocator([Select Id,
                                                    bulkOrderFieldValue__c
                                             From Bulk_Order_Intermediate__c 
                                             Where Id in :bulkOrderRecordIds
                                             ]);
	}
	
	global void execute(SchedulableContext sc) {
       Database.executeBatch(new BulkOrderBatch(), 1);
    }

	global void execute(Database.BatchableContext BC, List<sObject> scope ){
		
		for(SObject obj : scope){
			
			Bulk_Order_Intermediate__c bulkOrderObj = (Bulk_Order_Intermediate__c) obj;
			
			Bulk_Order_Intermediate__c bulkOrder;
			List<String> fields = new List<String>();
	
			if (userSess != null) {
				apiSess = cscfgc.Api_1.getApiSession();
				cscfgc.SessionManager.SessionInfo userSessNew = apiSess.loadUserSession(userSess.userSession.id);				
			} else {
				apiSess = cscfgc.Api_1.getApiSession();				
				userSess = apiSess.getUserSession();				
			}   
	   
			apiSess.setProductToConfigure(smbLandline);		
			
			String query = 'Select Id,bulkOrderFieldValue__c From Bulk_Order_Intermediate__c Where Id = \'' + bulkOrderObj.Id + '\' ';
			bulkOrder = Database.query(query);
			
			String bulkOrderVal = bulkOrder.bulkOrderFieldValue__c;
			fields = bulkOrderVal.split(',',-1);
						
			// Set Opportunity and Header Values
			accountId = fields[0];
			contactId = fields[3];

				
			cscfgc.ProductConfiguration config = apiSess.getConfiguration();
			
			//Set values
			config.getAttribute('Directorate').setValue(fields[7]);
			config.getAttribute('Product Category').setValue(fields[8]);
			
			config.getAttribute('Trading Title/Title').setValue(fields[9]);
			config.getAttribute('Building Name').setValue(fields[10]);
			config.getAttribute('Building Number').setValue(fields[11]);
			config.getAttribute('Street').setValue(fields[12]);
			config.getAttribute('City').setValue(fields[13]);
			config.getAttribute('Postcode').setValue(fields[14]);		
			config.getAttribute('Provide Type').setValue(fields[15]);
			
			config.getAttribute('New Order Type').setValue(fields[16]);
			config.getAttribute('Line Type').setValue(fields[17]);
			config.getAttribute('Number of Lines').setValue('1');	// Should be in API spec
			// IGNORE: We should set this from rules 
			config.getAttribute('Monthly Tariff').setValue(fields[18]);
			// Calling and Network Features: config.getAttribute('').setValue(fields[19]);
			config.getAttribute('Care Package').setValue(fields[20]);
			// Not required : config.getAttribute('Free of Charge Offers').setValue(fields[21]);
			config.getAttribute('Installation Work Required?').setValue(fields[22]);
			config.getAttribute('Primary On-Site Contact First Name').setValue(fields[23]);
			config.getAttribute('Primary On-Site Contact Last Name').setValue(fields[24]);
			config.getAttribute('Primary On-Site Contact Telephone Number').setValue(fields[25]);
			config.getAttribute('Termination Type').setValue(fields[26]);
			config.getAttribute('Termination Floor').setValue(fields[27]);
			config.getAttribute('Termination Room').setValue(fields[28]);
			config.getAttribute('Termination Location').setValue(fields[29]);
			config.getAttribute('Installation Type').setValue(fields[30]);
			config.getAttribute('EC Charge Level').setValue(fields[31]);
			config.getAttribute('TR Charge Band').setValue(fields[32]);
			config.getAttribute('Health and Safety').setValue(fields[33]);
			config.getAttribute('Site Access Information').setValue(fields[34]);
			config.getAttribute('Directory Enquiry Type').setValue(fields[35]);
			config.getAttribute('Contract Term').setValue(fields[36]);
			config.getAttribute('Payment Period').setValue(fields[37]);

			// Add the Landline Bolt On to this Order
			cscfgc.ProductConfiguration relatedConfig = apiSess.AddRelatedProduct('Calling and Network Features', smbBoltOns.Id);
			// For O2 Wifi Set the Call Barring
			relatedConfig.getAttribute('Permanent Outgoing Call Barring').setValue('Yes');
	
			apiSess.executeRules();        
			apiSess.persistConfiguration(true);
			
		}
	} 
	
	global void finish(Database.BatchableContext ctx){ 
		AsyncApexJob a;
		
		if(accountId == null)
		{
			message += 'Entered Account is null or does not exist in your organization.';
		}
		else{
		
			Id opportunityId = createOrder(accountId, contactId);
			
			//Query the AsyncApexJob object to retrieve the current job's information.
			a = [Select Id, CreatedBy.Email from AsyncApexJob where Id = :ctx.getJobId()];
			
			message += '\n The bulk order load from a csv/text file has been completed and  '+ recordSize +'  products have been automatically configured ready for provisioning.';
			message += '\n';
			message += '\n Use the following link to view your Opportunity: ';
			
			message += '\n '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ opportunityId;
			message += '\n';
			message += '\n Please review your Opportunity and set the Stage to Achievement of Results to start the provisioning process.';
		}

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Salesforce Bulk Order Upload'); 
		mail.setSubject('Salesforce Bulk Order Upload Completed'); 
		mail.setPlainTextBody(message);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		deleteBulkOrderIntermediateRecords(bulkOrderRecordIds);		
	}
	
	public Id createOrder(String accountId, String contactId) {

		Account acc;
		RecordType oppRecordType;
		
		// Retrieve the account details
		acc = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
		try{
			oppRecordType = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Opportunity' and r.DeveloperName = 'Configurator'];
		}
		catch(Exception e){
			System.debug('Exception while get a recording type of Opportunity.'+e.getMessage());
		}
				
		// Now create an Opportunity, Bundle and hopefully an Order for the above
		// We should already have a handle on the basket from the above iteration
		basket = userSess.getSessionBasket();
		
		// Set the mandatory fields
    	opp = new Opportunity();
    		
    	if(oppRecordType != null)
			opp.RecordTypeId = oppRecordType.Id;
		
		//Get locale time zone not GMT	
		Datetime d = system.now();
		String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');
		
			
		opp.Name = 'Order: ' + acc.Name + ': '+strDatetime;
		opp.AccountId = acc.Id;
		opp.CloseDate = System.today();
		opp.StageName = 'Awareness of Needs';   //@TODO - This should be a configuration
		opp.Credit_Ref_Status__c = 'n/a';
		opp.Credit_Ref_Date__c = System.today();
		opp.Credit_Ref_Number__c = 'O2Wifi';		

		insert opp;
		
		O2OrderHelper.addContactRoles(opp.Id, contactId);
		cscfgc__Product_Bundle__c bundle = O2OrderHelper.createBundle(opp.Id, basket);
		
		// Create a configuration request records for each product configuration.
		ConfigurationRequestUtils.createConfigurationRequest(bundle.Id);		

		//Close the Api session 
		apiSess.close();
		
		// Check if the bundle is valid first then...
		O2OrderHelper.synchBundleWithOpportunity(bundle);


		// The below commented code should be implemented later as it throws an error that @future method cannot be called from @futtuer method from opportunity trigger.
	/*	bundle.Name = 'Bundle for O2 Wifi order';
		update bundle;

		Update the Opportunity to create the Order
		opp.StageName = 'Achievement of Results';
		update opp;*/
		
		return opp.id;
	
	}
	
	//Delete all the bulk order records created for this opportunity id.
	public static void deleteBulkOrderIntermediateRecords(List<String> bulkOrderRecordIds)
	{		
		Bulk_Order_Intermediate__c[] bulkRecords = [Select Id, Name from Bulk_Order_Intermediate__c where Id IN :bulkOrderRecordIds]; 
		
		try{
		    delete bulkRecords;
		}
		catch (DmlException e){
			//Process exception here
		    System.debug('Exception while deleting Bulk order Ids after opportunity is created. '+e.getMessage());
		} 
	}
	
	//This method is called from the controller.
	public static Id startJob(List<ID> bulkOrderIds){
		ID batchprocessid = Database.executeBatch(new BulkOrderBatch(bulkOrderIds),1); 
		return batchprocessid;
	}
}