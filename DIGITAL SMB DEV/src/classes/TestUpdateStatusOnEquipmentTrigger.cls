@isTest
private class TestUpdateStatusOnEquipmentTrigger {
    
    static TestMethod void testUpdateStatusOnEquipmentAllocation() {
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
        System.assertEquals(true, loanProduct.Active__c);
        System.assertEquals('Data Centric Device, cards and/or SIM (inc. BB Connect)', loanProduct.Loan_Type__c);
        
                
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
        trialKitEquip.Number_of_Handsets__c = 1.0;
        trialKitEquip.APN_Required__c = 'No';
        trialKitEquip.SIMs_Required__c = 'No';
        trialKitEquip.Roaming_Required__c = 'No';

        insert trialKitEquip;
        
        System.assertNotEquals(null, trialKitEquip.Id);
        
        loanReq.Approval_Status__c = 'Approved';
        update loanReq;
        
        
        trialKitEquip.Qty_Agreed__c = 1.0;
        update trialKitEquip;
        

        
        Equipment_Allocation__c equip = new Equipment_Allocation__c();
        equip.Trial_Kit__c = trialKitEquip.Id;
        equip.Type__c = 'Handset';
        equip.Product__c = loanProduct.Id;
        
        insert equip;
        System.assertNotEquals(null, equip.Id);
        
        equip.IMEI_Serial_No__c = handset.Id;
        update equip;
                
        Handset_SIM_Asset__c usedHandset = [Select Id,  Status__c from Handset_SIM_Asset__c where Id = :handset.Id];
        Equipment_Allocation__c equip1= [Select Id, Status__c from Equipment_Allocation__c where Id = :equip.Id];
        
        System.assertEquals('Allocated',usedHandset.Status__c, 'The status has not been updated.');
        System.assertEquals('Allocated',equip1.Status__c, 'The status has not been updated.');
        
        equip.IMEI_Serial_No__c = null;
        update equip;        
        
        Handset_SIM_Asset__c usedHandset1 = [Select Id, Status__c from Handset_SIM_Asset__c where Id = :handset.Id];        
        System.assertEquals('Unallocated',usedHandset1.Status__c, 'The status has not been updated.');   
        
        equip.IMEI_Serial_No__c =  handset.Id;
        update equip;
        
        
        equip.Return_Option__c = 'Returned';
        update equip;
        
        Handset_SIM_Asset__c usedHandsetRetStatus = [Select Id,  Status__c from Handset_SIM_Asset__c where Id = :handset.Id];
        Equipment_Allocation__c equip2= [Select Id, IMEI_Serial_No__c from Equipment_Allocation__c where Id = :equip.Id];
        
        System.assertEquals('Unallocated',usedHandsetRetStatus.Status__c, 'The status has not been updated.');
        System.assertEquals(null,equip2.IMEI_Serial_No__c, 'The status has not been updated.');
     
     	//handset.Status__c = 'Unallocated';
     	//update handset;
     	
     	equip.Return_Option__c = null;
     	equip.IMEI_Serial_No__c = null;
     	update equip;
    }
}