@isTest
private class TestBESalesTriggers {
    static TestMethod void testCreateOperationalDetail() {
        //get supporting data records
        Date dtToday = Date.Today();
        RecordType accType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'CustomerAccount' LIMIT 1];
        RecordType opptyType = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Be_Unlimited_Sale' LIMIT 1];
        System.assertNotEquals(null, accType);
        System.assertNotEquals(null, opptyType);
        
        //create setup data
        Account testAcc = new Account(Name='APEXTESTACC001', RecordTypeId=accType.Id);
        insert testAcc;
        String strAccId = testAcc.Id;
        
        Contact testCon = new Contact(FirstName='TEST', LastName='TEST001', AccountId=strAccId, Buying_Role__c='Other');
        insert testCon;
        String strConId = testCon.Id;
        
        Opportunity testOpp = new Opportunity(AccountId=strAccId, Name='APEXTESTOPP001', RecordTypeId=opptyType.Id);
        testOpp.Type = 'New Business';
        testOpp.StageName = '1. New';
        testOpp.LeadSource = 'BE Sales';
        testOpp.CloseDate = dtToday + 365;
        testOpp.Contract_End_Date__c = dtToday + 1;
        testOpp.Contract_Number__c = '012345';
        testOpp.Date_Contract_Sent__c = dtToday + 2;
        testOpp.Date_Contract_Signed_by_Be__c = dtToday + 3;
        testOpp.Date_Introduction_Email_Sent__c = dtToday + 4;
        testOpp.Date_ISF_Returned__c = dtToday + 5;
        testOpp.Date_ISF_Sent__c = dtToday + 6;
        testOpp.Date_Portal_Setup__c = dtToday + 7;
        testOpp.Date_Signed_Contract_Returned__c = dtToday + 8;
        testOpp.Date_Training_Complete__c = dtToday + 9;
        testOpp.Date_Welcome_Email_Guide_Sent__c = dtToday + 10;
        testOpp.Partner_Sign_off_Contact__c = strConId;
        testOpp.Partner_Sign_off_Date__c = dtToday + 12;
        insert testOpp;
        String strOpptyId = testOpp.Id;
        
        //test the creation of child OpDetail records on change of StageName
        testOpp.StageName = '4. Closed - Won';
        update testOpp;
        
        List<Operational_Detail__c> lsDetails = new List<Operational_Detail__c>();
        lsDetails = [SELECT Id FROM Operational_Detail__c WHERE Opportunity__c=:strOpptyId];
        System.assertNotEquals(null, lsDetails);
        //System.assertEquals(1, lsDetails.size());
        String strOpDetId = lsDetails[0].Id;
        
        //test the creating of a related renewal opportunity and therefore the deactivation of the originating OpDetail record
        Opportunity testRenewalOpp = new Opportunity(AccountId=strAccId, Name='APEXTESTOPP001', RecordTypeId=opptyType.Id);
        testRenewalOpp.Type = 'Contract Renewal';
        testRenewalOpp.StageName = '1. New';
        testRenewalOpp.LeadSource = 'BE Sales';
        testRenewalOpp.CloseDate = dtToday + 365;
        testRenewalOpp.Contract_End_Date__c = dtToday + 1;
        testRenewalOpp.Contract_Number__c = '012345';
        testRenewalOpp.Date_Contract_Sent__c = dtToday + 2;
        testRenewalOpp.Date_Contract_Signed_by_Be__c = dtToday + 3;
        testRenewalOpp.Date_Introduction_Email_Sent__c = dtToday + 4;
        testRenewalOpp.Date_ISF_Returned__c = dtToday + 5;
        testRenewalOpp.Date_ISF_Sent__c = dtToday + 6;
        testRenewalOpp.Date_Portal_Setup__c = dtToday + 7;
        testRenewalOpp.Date_Signed_Contract_Returned__c = dtToday + 8;
        testRenewalOpp.Date_Training_Complete__c = dtToday + 9;
        testRenewalOpp.Date_Welcome_Email_Guide_Sent__c = dtToday + 10;
        testRenewalOpp.Partner_Sign_off_Contact__c = strConId;
        testRenewalOpp.Partner_Sign_off_Date__c = dtToday + 12;
        testRenewalOpp.Originating_BE_Opportunity_ID__c = strOpptyId;
        insert testRenewalOpp;
        
        String strRenewOpptyId = testRenewalOpp.Id;
        lsDetails = [SELECT Status__c FROM Operational_Detail__c WHERE Id=:strOpDetId LIMIT 1];
        System.assertNotEquals(null, lsDetails);
        System.assertEquals(1, lsDetails.size());
        System.assertEquals('Inactive', lsDetails[0].Status__c);
        
        //test the deletion of parent Opportunity records and the cascade delete of child Operational Detail records
        delete testOpp;
        lsDetails = [SELECT Id FROM Operational_Detail__c WHERE Opportunity__c=:strOpptyId];
        System.assertNotEquals(null, lsDetails);
        System.assertEquals(0, lsDetails.size());
    }
}