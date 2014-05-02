@isTest
private class TestSyncLocationWithParent {
	
	static TestMethod void testSyncLocationWithParentAsBilling()
	{
		//create setup data
		RecordType accType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'CustomerAccount' LIMIT 1];        
        System.assertNotEquals(null, accType);  
        
        Account testAcc = new Account(Name='APEXTESTACCSYNC', RecordTypeId=accType.Id);
        insert testAcc;
        String strAccId = testAcc.Id;
        
        Location__c loc = new Location__c();
        loc.Account__c = strAccId;
        loc.Type__c = 'Billing';
        loc.PAF_Building_Name__c = 'Princess house';
        loc.PAF_Building_Number__c = '50';
        loc.PAF_Postcode__c = 'W1W8EA';
        loc.PAF_County__c = 'Greater London';
        loc.PAF_Sub_Building_Name__c = 'Suite 303';
        loc.PAF_Thoroughfare_Name__c = 'Eastcastle street';
        loc.PAF_Post_Town__c = 'London'; 
        loc.Country__c = 'United Kingdom';
        
        insert loc;
        
        Account updateAcc = [Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode from Account where Id = :testAcc.Id];
        System.assertNotEquals(null, updateAcc);
        System.assertEquals('London', updateAcc.BillingCity);
        System.assertEquals('W1W8EA', updateAcc.BillingPostalCode);
        System.assertEquals('Greater London', updateAcc.BillingState);
        //System.assertEquals('Eastcastle street', updateAcc.BillingStreet);
        
  	}
  	
  	static TestMethod void testSyncLocationWithParentAsShiping()
	{
		//create setup data
		RecordType accType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'CustomerAccount' LIMIT 1];        
        System.assertNotEquals(null, accType);  
        
        Account testAcc1 = new Account(Name='APEXTESTACCSYNC001', RecordTypeId=accType.Id);
        insert testAcc1;
        String strAccId = testAcc1.Id;
        
        Location__c loc = new Location__c();
        loc.Account__c = strAccId;
        loc.Type__c = 'Shipping';
        loc.PAF_Building_Name__c = 'Princess house';
        loc.PAF_Building_Number__c = '50';
        loc.PAF_Postcode__c = 'W1W8EA';
        loc.PAF_County__c = 'Greater London';
        loc.PAF_Sub_Building_Name__c = 'Suite 303';
        loc.PAF_Thoroughfare_Name__c = 'Eastcastle street';
        loc.PAF_Post_Town__c = 'London'; 
        loc.Country__c = 'United Kingdom';
        
        insert loc;
        
        Account updateAcc1 = [Select Id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode from Account where Id = :testAcc1.Id];
        System.assertNotEquals(null, updateAcc1);
        System.assertEquals('London', updateAcc1.ShippingCity);
        System.assertEquals('W1W8EA', updateAcc1.ShippingPostalCode);
        System.assertEquals('Greater London', updateAcc1.ShippingState);
        //System.assertEquals('Eastcastle street', updateAcc1.ShippingStreet);
        
  	}

}