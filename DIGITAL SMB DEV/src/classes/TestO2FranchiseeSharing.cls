@isTest
public class TestO2FranchiseeSharing {

    private static testMethod void testHandler() {
        Account acc = TestMyO2BusinessUtility.createPortalAccount('Ragnur', 'Steffansson');
        Contact c = TestMyO2BusinessUtility.createPortalContact(acc, 'Ragnur', 'Steffansson', 'rs@steff.steff.edu');
        
        acc.Torex_Code__c = 'TEST';
        update acc;
        
        O2_Franchisee__c rec = new O2_Franchisee__c(Name = 'Test'
        											,Torex_Code__c = 'TEST'
        											,L5_Description__c = 'Test'
        											,Account_Number__c = 'Test'
        											,Address_Line_1__c = 'Test');
    	insert rec;
    }

}