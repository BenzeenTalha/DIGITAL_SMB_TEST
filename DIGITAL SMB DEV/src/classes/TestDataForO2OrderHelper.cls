public class TestDataForO2OrderHelper {
	
	private static string SUFFIX_NAME = 'O2HelperTest';
	private static Map<String, Id> accRecTypes ;
	private static Map<String, Id> opptyRecTypes;
	public static Account test_Account {get;set;}
	public static Contact test_Contact {get;set;}
	public static Opportunity test_Opportunity {get;set;}
	public static cscfgc__Product_Bundle__c test_bundle {get;set;}
	
	
	public static Account createAccount(){
		system.debug('Enter create account method....');		
		test_Account = new Account();
		test_Account.Name = 'TestAccount';
		test_Account.RecordTypeId = accRecTypes.get('Customer Account');
		test_Account.NumberOfEmployees = 1;
		test_Account.O2_Sector__c='Finance';
		insert test_Account;	
		
		return test_Account;			
	}
	
	public static void createRecordTypeForAccount(){
		RecordType[] lsAccRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account'];
		accRecTypes = new Map<String, Id>();
		for (RecordType r: lsAccRecTypes) {
			accRecTypes.put(r.Name, r.Id);
		}		 
	}
	
	public static Contact createContact(){		
		test_Contact = new Contact();
		test_Contact.Salutation = 'Mrs.';
		test_Contact.FirstName = 'TestContact';
		test_Contact.LastName = SUFFIX_NAME;
		test_Contact.Email = 'jack.jones@junkmail.yahoo.com.uk';
		test_Contact.Phone = '07951069913';
		test_Contact.AccountId = test_Account.Id;
		insert test_Contact;	
		return test_Contact;		
	}
	
	public static void createRecordTypeForOpportunity(){
		RecordType[] lsOpptyRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity'];
        opptyRecTypes = new Map<String, Id>();
        for (RecordType r: lsOpptyRecTypes) {
        	opptyRecTypes.put(r.Name, r.Id);
        }		
	}
	
	public static Opportunity createOpportunity(){
		test_Opportunity = new Opportunity();	
		test_Opportunity.Name = 'Online Order: ' + test_Account.Name + ':'+datetime.now();
		test_Opportunity.AccountId = test_Account.Id;
		test_Opportunity.CloseDate = System.today();
		test_Opportunity.StageName = 'Awareness of Needs';   //@TODO - This should be a configuration
		test_Opportunity.Credit_Ref_Status__c = 'n/a';
		test_Opportunity.Credit_Ref_Date__c = System.today();
		test_Opportunity.Credit_Ref_Number__c = 'O2Wifi';
		test_Opportunity.TotalOpportunityQuantity = 0; // added this as validation rule was complaining it was missing
		insert test_Opportunity;
		return test_Opportunity;
	}
	
	// Create the bundle and add it to the supplied opportunity
	public static cscfgc__Product_Bundle__c createbundle(Id oppId){
		// Create a new Bundle for this Opportunity Id
		test_bundle = new cscfgc__Product_Bundle__c();
		Datetime d = system.now();
		String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');
		test_bundle.Name = 'Test Order ' + strDatetime;
		
		test_bundle.cscfgc__Opportunity__c = oppId;
		test_bundle.cscfgc__Synchronised_with_Opportunity__c = true;
		insert test_bundle; 
		return test_bundle;		
	}
	
	// call this to get object needed for createAttributeDefinition()
	public static cscfgc__Product_Definition__c createProductDefinition(){
		cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(Name='SMB Landline Test', cscfgc__Description__c = 'Test helper');
        insert def;
        return def;
	}
	
	public static List<cscfgc__Attribute_Definition__c> createAttributeDefinition(Id prodDefId){
		List<cscfgc__Attribute_Definition__c> attDefList = new List<cscfgc__Attribute_Definition__c>();
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Number of Lines', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Monthly Tariff', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Contract Term', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
        attDefList.add(new cscfgc__Attribute_Definition__c(Name='Provide Type', cscfgc__Product_Definition__c = prodDefId, cscfgc__is_Line_Item__c = true));
        insert attDefList;
        return attDefList;
	}
	
	public static cscfgc__Product_Configuration__c createProductConfigurationFast() {
        cscfgc__Product_Configuration__c pc = null;

		// create an opportunity
        Opportunity opp = createOpportunity();
        
        // create product definition
        cscfgc__Product_Definition__c pd = createProductDefinition();
        
		// create attribute definition
		List<cscfgc__Attribute_Definition__c> adl = createAttributeDefinition(pd.Id);
		
		// create bundle
		cscfgc__Product_Bundle__c pb = createbundle(opp.Id);
		
		// create offer
        cscfgc__Configuration_Offer__c offer = createOffer();

		// create product configuration
		pc = createProductConfiguration(adl, pb.Id, pd.Id, offer.Id);
		
		return pc;
	}
	
	// needs a list of attribute definitions, a bundle and a product definition
	public static cscfgc__Product_Configuration__c createProductConfiguration(List<cscfgc__Attribute_Definition__c> prodDefAttribute, Id bundleId, Id prodDefId, Id offerId){
		
		cscfgc__Attribute_Definition__c[] attdefs = prodDefAttribute;
        //create new configuration
        String strBunId = bundleId;
        String strDefId = prodDefId;
        String strOfferId = offerId;
        
        cscfgc__Product_Configuration__c config = new cscfgc__Product_Configuration__c();
        config.cscfgc__Product_Bundle__c = strBunId;
        config.cscfgc__Product_Definition__c = strDefId;
        if (offerId != null)
        	config.cscfgc__Configuration_Offer__c = strOfferId;
        config.cscfgc__Configuration_Status__c = 'Valid';
        config.cscfgc__Unit_Price__c = 10;
        config.cscfgc__Quantity__c = 1;
        config.cscfgc__Recurrence_Frequency__c = 12;
        insert config;
        String strConfigId = config.Id;
        //create associated attributes
        cscfgc__Attribute__c[] attribs = new cscfgc__Attribute__c[0];
        for (integer i=0; i<attdefs.size(); i++) {
            if (attdefs[i].cscfgc__is_Line_Item__c || attdefs[i].cscfgc__Required__c) {
                cscfgc__Attribute__c att = new cscfgc__Attribute__c();
                att.cscfgc__Product_Configuration__c = strConfigId;
                att.cscfgc__Attribute_Definition__c = attdefs[i].Id;
                att.Name = attdefs[i].Name;
                att.cscfgc__is_Line_Item__c = attdefs[i].cscfgc__is_Line_Item__c;
                if (attdefs[i].Name=='Number of Lines') {
                	att.cscfgc__line_item_Description__c = 'test1';
                    att.cscfgc__Value__c = '1'; 
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Price__c = 25;
                }
                else if (attdefs[i].Name=='Monthly Tariff') {
                	att.cscfgc__line_item_Description__c = 'test2';
                    att.cscfgc__Value__c = '25.00'; 
                    att.cscfgc__Display_Value__c = '£25.00';
                }
                else if (attdefs[i].Name=='Contract Term') {
                	att.cscfgc__line_item_Description__c = 'test3';
                    att.cscfgc__Value__c = '24';
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Display_Value__c = '24 Months';
                    att.cscfgc__Price__c = 0;
                }
                else if (attdefs[i].Name=='Provide Type') {
                	att.cscfgc__line_item_Description__c = 'test4';
                    att.cscfgc__Value__c = 'New Provide';
                    att.cscfgc__Price__c = 25*12;
                    att.cscfgc__Display_Value__c = 'New Provide';                        
                }
                att.cscfgc__is_Active__c = true;
                attribs.add(att);
            }
        }
        insert attribs;
		return config;
	}
	
	public static cscfgc__Configuration_Offer__c createOffer() {
		cscfgc__Configuration_Offer__c offer = new cscfgc__Configuration_Offer__c(Name='Test Offer');  
        insert offer;
		return offer;
	}
	
    public static List<OpportunityContactRole> createOpportunityContactRole(Id oppId, Id contactId) {
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>(); 
        
        // Create a primary billing contact
        OpportunityContactRole ocrBill = new OpportunityContactRole();
        ocrBill.OpportunityId = oppId;
        ocrBill.ContactId = contactId;
        ocrBill.IsPrimary = true;
        ocrBill.Role = 'Billing';
        ocrList.add(ocrBill);
        
        // Also create a Centre of Power contact
        OpportunityContactRole ocrCop = new OpportunityContactRole();
        ocrCop.OpportunityId = oppId;
        ocrCop.ContactId = contactId;
        ocrCop.IsPrimary = false;
        ocrCop.Role = 'Centre of Power';
        ocrList.add(ocrCop);
        
        insert ocrList;
        
        return ocrList;
    }   
    
    public static void setBundleSync(cscfgc__Product_Bundle__c bundle, Boolean flag) {
    	bundle.cscfgc__Synchronised_with_Opportunity__c = flag;
    	update bundle;
    }
}