public with sharing class TestDataForJUC1 {
	
	private static Map<String, Id> accRecTypes ;
	private static Map<String, Id> opptyRecTypes;
	public static Map<String, Account> accMap = new Map<String, Account>();
	public static Map<String, Contact> contactMap = new Map<String, Contact>();
	public static Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
	
	public TestDataForJUC1(){

	}
	
	public static Account createAccount(String accName){
		Account testAccount;
		if(accMap != null && accMap.size() != 0 && accMap.containskey(accName)){
			testAccount = accMap.get(accName);
		}
		else{
			system.debug('Enter create account method....');		
			Account newAccount = new Account();
			newAccount.Name = accName;
			newAccount.Type = 'Prospect';
			newAccount.RecordTypeId = accRecTypes.get('Customer Account');
			newAccount.BillingStreet = 'EastCastle street';
			newAccount.BillingCity = 'London';
			newAccount.BillingState = 'Greater London';
			newAccount.BillingPostalCode = 'W1W 8EA';
			newAccount.Billing_Country__c = 'United Kingdom';	
			insert newAccount;
			
			accMap.put(accName, newAccount);
			testAccount = newAccount;
		}
		return testAccount;
	}
	
	public static void createRecordTypeForAccount(){
		RecordType[] lsAccRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account'];
		accRecTypes = new Map<String, Id>();
		for (RecordType r: lsAccRecTypes) {
			accRecTypes.put(r.Name, r.Id);
		}		
	}
	
	public static Contact createContact( Id accountId, String firstName, String lastName, String emailId){
		Contact testContact;	
		String conName = firstName+' '+lastName;
		if(contactMap != null && contactMap.size() != 0 && contactMap.containskey(conName)){
			testContact = contactMap.get(conName);
		}
		else{	
			
			Contact newContact = new Contact();
			newContact.FirstName = firstName;
			newContact.LastName = lastName;
			newContact.Email = emailId;
			newContact.Phone = '07951069913';
			newContact.AccountId = accountId;
			
			insert newContact;
			
			contactMap.put(conName,newContact);
			testContact = newContact;
				
		}
		return testContact;		
	}
	
	public static void createRecordTypeForOpportunity(){
		RecordType[] lsOpptyRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity'];
        opptyRecTypes = new Map<String, Id>();
        for (RecordType r: lsOpptyRecTypes) {
        	opptyRecTypes.put(r.Name, r.Id);
        }		
	}
	
	public static Opportunity createOpportunity(Id accountId, String oppName, String stageName){
		Opportunity testOpportunity;
		if(opportunityMap != null && opportunityMap.size() != 0 && opportunityMap.containskey(oppName)){
				testOpportunity = opportunityMap.get(oppName);
		}
		else{
			Opportunity newOpportunity = new Opportunity();	
			
			newOpportunity.Name = oppName;
			newOpportunity.AccountId = accountId;
			newOpportunity.StageName = stageName;
			newOpportunity.CloseDate = System.today();
			newOpportunity.RecordTypeId = opptyRecTypes.get('Configurator');
			insert newOpportunity;
			
			opportunityMap.put(oppName, newOpportunity);
			testOpportunity = newOpportunity;
			
		}
		return testOpportunity;
	}

}