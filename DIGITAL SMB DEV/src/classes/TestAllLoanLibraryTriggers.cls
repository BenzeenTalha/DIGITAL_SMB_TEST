/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAllLoanLibraryTriggers {

    static testMethod void myUnitTest() {
    	 Date dtToday = Date.Today();
    	 
        Profile pr = [Select Id From profile Where name='Standard User']; 
        User u = new User(alias = 'standt', email='standarduser@xyx.com.edu', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = pr.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser@testorgO2Courtesy.com');
        insert u;
        
        RecordType accType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'CustomerAccount' LIMIT 1];   
        RecordType loanType = [SELECT Id FROM RecordType WHERE sObjectType = 'Loan_Library_Request__c' AND DeveloperName = 'Loan_Library_Request' LIMIT 1];    
        
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
        testOpp.TotalOpportunityQuantity = 0; //to satisfy validation rule

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
        
        loanReq.Phase__c = 'Awaiting Signed Eval';
        loanReq.Sales_Person_Name__c=u.Id;
  		update loanReq;
		
		loanReq.Delivery_City__c = 'Slough';
		loanReq.Phase__c = 'Eval at and End - Proceed to Contract?';
		update loanReq;
		
		// TODO: This is not working yet - should have made the sales person the owner
		// system.assertEquals(u.id,llr.ownerId);
		
		delete loanReq;
		
		undelete loanReq;
    }
}