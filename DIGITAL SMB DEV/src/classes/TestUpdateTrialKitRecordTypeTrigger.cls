@isTest
private class TestUpdateTrialKitRecordTypeTrigger {
	static TestMethod void testUpdateTrialKitRecordTypeInApproval() {

		 Map<String, Id> recordtypeMap = new Map<String, Id>();
		 
 		 //get supporting data records
        Date dtToday = Date.Today();
        RecordType accType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'CustomerAccount' LIMIT 1];        
        System.assertNotEquals(null, accType);        
        
         RecordType loanType = [SELECT Id FROM RecordType WHERE sObjectType = 'Loan_Library_Request__c' AND DeveloperName = 'Loan_Library_Request' LIMIT 1]; 
         RecordType[] trialRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Trial_Kit_Equipment__c']; 
         
         for(RecordType r: trialRecordType){
         	recordtypeMap.put(r.DeveloperName, r.Id);
         }  
        
        //create setup data
        Account testAcc = new Account(Name='APEXTESTACC001', RecordTypeId=accType.Id);
        insert testAcc;
        String strAccId = testAcc.Id;
        
        Contact testCon = new Contact(FirstName='TEST', LastName='TEST001', AccountId=strAccId, Buying_Role__c='Other', Email='scrap@scrap.com');
        insert testCon;
        String strConId = testCon.Id;
        
        Opportunity testOpp = new Opportunity(AccountId=strAccId, Name='APEXTESTOPP001'); 
        testOpp.Type = 'Existing Business';
        testOpp.StageName = 'Awareness of Needs';
        testOpp.CloseDate = dtToday + 365;
        testOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule

        insert testOpp;
        String strOpptyId = testOpp.Id;
        System.assertNotEquals(null, testOpp.Id);
        
        Loan_Product__c loanProduct = new Loan_Product__c();
        loanProduct.Active__c = true;
        loanProduct.Is_SIM_Only__c = false;
        loanProduct.Loan_Type__c = 'Data Centric Device, cards and/or SIM (inc. BB Connect)';
        loanProduct.Manufacturer__c = 'AppleTest';
        loanProduct.Name = 'iPhone 3GsTest';
        loanProduct.Out_of_Stock__c = false;
        insert loanProduct;
        System.assertNotEquals(null, loanProduct);
        
        Handset_SIM_Asset__c handset = new Handset_SIM_Asset__c();
        handset.Model__c = loanProduct.Id;
        handset.Name = '1231487883';
        //handset.ID__c = '10342';
        handset.Type__c = 'Handset';
        handset.Status__c = 'Unallocated';
        handset.Loan_Area__c = 'Slough';
        
        insert handset;
        
        Loan_Library_Request__c loanReq = new Loan_Library_Request__c();
        loanReq.Opportunity_Name__c = testOpp.Id;
        loanReq.Loan_Categorisation__c = 'Loan Library';
        loanReq.Approval_Status__c = 'Not Submitted';
        loanReq.Phase__c = 'Trial Request Created';
        loanReq.RecordTypeId = loanType.Id;
        loanReq.Loan_Type_LL__c = loanProduct.Loan_Type__c;
        loanReq.Sales_Person_Name__c = UserInfo.getUserId();
        
        loanReq.Account__c = testAcc.Id;
        loanReq.City_LL__c = 'London';
        loanReq.County_LL__c = 'Greater London';
        loanReq.Post_Code_LL__c = 'W1W 8EA';
        loanReq.Contact__c = testCon.Id;
        
        loanReq.Length_of_Loan_Requested_in_Days__c = 15.0;
        
        insert loanReq;
        
        System.assertNotEquals(null, loanReq.Id);
        
        Trial_Kit_Equipment__c trialKitEquip = new Trial_Kit_Equipment__c();
        trialKitEquip.Loan_Library_Request__c = loanReq.Id;
        trialKitEquip.Loan_Type__c = 'Data Centric Device, cards and/or SIM (inc. BB Connect)'; //loanProduct.Loan_Type__c;
        trialKitEquip.Model__c = loanProduct.Id;
        trialKitEquip.Number_of_Handsets__c = 2.0;
        trialKitEquip.APN_Required__c = 'No';
        trialKitEquip.SIMs_Required__c = 'No';
        trialKitEquip.Roaming_Required__c = 'No';
        
        insert trialKitEquip;
        System.assertNotEquals(null, trialKitEquip.Id);
        
        loanReq.Approval_Status__c = 'Submitted';
        update loanReq;
        
        Trial_Kit_Equipment__c trail1 = [Select Id, Name,RecordTypeId from Trial_Kit_Equipment__c where Id = :trialKitEquip.Id];
        System.assertNotEquals(null, trail1.RecordTypeId);
        
        System.assertEquals(trail1.RecordTypeId, recordtypeMap.get('Trial_Kit_In_Approval'), 'Trial Kit Equipment record type not updated after Loan Request apporval.');
	}
	
	static TestMethod void testUpdateTrialKitRecordTypeRejected() {

		 Map<String, Id> recordtypeMap = new Map<String, Id>();
		 
 		 //get supporting data records
        Date dtToday = Date.Today();
        RecordType accType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'CustomerAccount' LIMIT 1];        
        System.assertNotEquals(null, accType);        
        
         RecordType loanType = [SELECT Id FROM RecordType WHERE sObjectType = 'Loan_Library_Request__c' AND DeveloperName = 'Loan_Library_Request' LIMIT 1]; 
         RecordType[] trialRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Trial_Kit_Equipment__c']; 
         
         for(RecordType r: trialRecordType){
         	recordtypeMap.put(r.DeveloperName, r.Id);
         }  
        
        //create setup data
        Account testAcc = new Account(Name='APEXTESTACC001', RecordTypeId=accType.Id);
        insert testAcc;
        String strAccId = testAcc.Id;
        
        Contact testCon = new Contact(FirstName='TEST', LastName='TEST001', AccountId=strAccId, Buying_Role__c='Other', Email='scrap@scrap.com');
        insert testCon;
        String strConId = testCon.Id;
        
        Opportunity testOpp = new Opportunity(AccountId=strAccId, Name='APEXTESTOPP001');
        testOpp.Type = 'Existing Business';
        testOpp.StageName = 'Awareness of Needs';
        testOpp.CloseDate = dtToday + 365;
        testOpp.TotalOpportunityQuantity = 0; // added to satisfy validation rule

        insert testOpp;
        String strOpptyId = testOpp.Id;
        System.assertNotEquals(null, testOpp.Id);
        
        Loan_Product__c loanProduct = new Loan_Product__c();
        loanProduct.Active__c = true;
        loanProduct.Is_SIM_Only__c = false;
        loanProduct.Loan_Type__c = 'Data Centric Device, cards and/or SIM (inc. BB Connect)';
        loanProduct.Manufacturer__c = 'AppleTest';
        loanProduct.Name = 'iPhone 3GsTest';
        loanProduct.Out_of_Stock__c = false;
        insert loanProduct;
        System.assertNotEquals(null, loanProduct);
        
                
        Handset_SIM_Asset__c handset = new Handset_SIM_Asset__c();
        handset.Model__c = loanProduct.Id;
        handset.Name = '1231487883';
        //handset.ID__c = '10342';
        handset.Type__c = 'Handset';
        handset.Status__c = 'Unallocated';
        handset.Loan_Area__c = 'Slough';
        
        insert handset;
        
        Loan_Library_Request__c loanReq = new Loan_Library_Request__c();
        loanReq.Opportunity_Name__c = testOpp.Id;
        loanReq.Loan_Categorisation__c = 'Loan Library';
        loanReq.Approval_Status__c = 'Not Submitted';
        loanReq.Phase__c = 'Trial Request Created';
        loanReq.RecordTypeId = loanType.Id;
        loanReq.Loan_Type_LL__c = loanProduct.Loan_Type__c;
        loanReq.Sales_Person_Name__c = UserInfo.getUserId();
        
        loanReq.Account__c = testAcc.Id;
        loanReq.City_LL__c = 'London';
        loanReq.County_LL__c = 'Greater London';
        loanReq.Post_Code_LL__c = 'W1W 8EA';
        loanReq.Contact__c = testCon.Id;
        
        loanReq.Length_of_Loan_Requested_in_Days__c = 15.0;
        
        insert loanReq;
        
        System.assertNotEquals(null, loanReq.Id);
        
        Trial_Kit_Equipment__c trialKitEquip = new Trial_Kit_Equipment__c();
        trialKitEquip.Loan_Library_Request__c = loanReq.Id;
        trialKitEquip.Loan_Type__c = loanProduct.Loan_Type__c;
        trialKitEquip.Model__c = loanProduct.Id;
        trialKitEquip.Number_of_Handsets__c = 2.0;
        trialKitEquip.APN_Required__c = 'No';
        trialKitEquip.SIMs_Required__c = 'No';
        trialKitEquip.Roaming_Required__c = 'No';
        
        insert trialKitEquip;
        System.assertNotEquals(null, trialKitEquip.Id);
        
        loanReq.Approval_Status__c = 'Rejected';
        update loanReq;
        
        Trial_Kit_Equipment__c trail1 = [Select Id, Name,RecordTypeId from Trial_Kit_Equipment__c where Id = :trialKitEquip.Id];
        System.assertNotEquals(null, trail1.RecordTypeId);
        
        System.assertEquals(trail1.RecordTypeId, recordtypeMap.get('Trial_Kit_Post_Approval'), 'Trial Kit Equipment record type not updated after Loan Request apporval.');
	}
}