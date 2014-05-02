/**
 * This class contains unit tests for TestMyO2BusinessSubscriptionsController controller.
 */
@isTest
private class TestSMBbillingsummaryController {

    public static testmethod void testSMBbillingsummaryController () {
     // CreateRecords();
      Account acc = TestMyO2BusinessUtility.createPortalAccount('Ragnur1', 'Steffansson1');
      AC_Corporate_ID_Map__c corporateAcc = new AC_Corporate_ID_Map__c();
      corporateAcc.DISE_Account_No__c = '9990';
      corporateAcc.SFAccountID__c = acc.id;
      insert corporateAcc;


      Contact c = TestMyO2BusinessUtility.createPortalContact(acc, 'firstName', 'lastName', 'email@email.emial.com');     
      User u = TestMyO2BusinessUtility.createPortalUser(c);
      
      List<AC_Account_Invoice__c> accountInvoices = new List<AC_Account_Invoice__c>();
      
      AC_Account_Invoice__c ai1 = new AC_Account_Invoice__c(Account_ID__c = '9990',
                                     Invoice_Amount__c = 32342.986, Last_Invoice_Tax_Date__c = System.today(),
                                     Payment_Due_Date__c = System.today(), AIUID__c = '01IW00000000SpJ');
        
       
      AC_Account_Invoice__c ai2 = new AC_Account_Invoice__c(Account_ID__c = '9990' ,
                                     Invoice_Amount__c = 34242.776, Last_Invoice_Tax_Date__c = System.today(),
                                     Payment_Due_Date__c = System.today(), AIUID__c = '01IW00000000SpK');
        

      accountInvoices.add(ai1);
      accountInvoices.add(ai2);                                                 
        
      insert accountInvoices;  
      
      Test.startTest();
      System.runAs(u) {
        SMBbillingsummaryController con = new SMBbillingsummaryController();
      }
      Test.stopTest();
    }
    
    
     //Create records used by test methods
    static void CreateRecords(){
       
       //TestMyO2BusinessUtility.createPortalUserAccountContact('Angus', 'McAngus', 'angus.mcangus@sfdc.com.test');       
       
                
       //Insert new Account(DISE_Account_No__c='X-999990', name='X-999990'); 
      // Account acc1 = TestMyO2BusinessUtility.createPortalAccount('Ragnur1', 'Steffansson1');
       //Account acc2 = TestMyO2BusinessUtility.createPortalAccount('Ragnur2', 'Steffansson2');
       
                                                       
    
    }
}