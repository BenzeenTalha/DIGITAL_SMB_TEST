public with sharing class SMBbillingsummaryController {
    public AC_Account_Invoice__c InvoiceRecord {get; set;}
    public boolean showInfo {get;set;}
    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------
    public SMBbillingsummaryController()
    {
        list<string> corporateList = new list<string>();
        InvoiceRecord = new AC_Account_Invoice__c() ;
        showInfo = false;
        //InvoiceRecord = null;
    
        User currentUser = [SELECT Id, AccountId, Name, Email FROM User WHERE Id = :userInfo.getUserId()][0];
        
        system.debug('currentUser.AccountId---'+currentUser.AccountId);
        for(AC_Corporate_ID_Map__c corporateId : [SELECT Id, DISE_Account_No__c from AC_Corporate_ID_Map__c where SFAccountID__c =: currentUser.AccountId ]){        
            corporateList.add(corporateId.DISE_Account_No__c);
        }
        System.debug('**corporateList**'+corporateList);
        
        for(AC_Account_Invoice__c InvoiceObj : [SELECT Id, Account_ID__c, Invoice_Amount__c, Invoice_Amount_Formatted__c, Last_Invoice_Tax_Date__c, Payment_Due_Date__c , Invoice_ID__c FROM AC_Account_Invoice__c WHERE (Account_ID__c IN : corporateList AND Account_ID__c != null) order by Invoice_ID__c desc  limit 1]){
            System.debug('**InvoiceObj**'+InvoiceObj);
            System.debug('First');
            InvoiceRecord = InvoiceObj;
            break;
        }
        
        //System.debug('**InvoiceRecord**'+InvoiceRecord);
        if(InvoiceRecord != null ){
            System.debug('First');
            showInfo = true;
        }else{
            System.debug('Two');
            showInfo = false;
        }
        System.debug('**InvoiceRecord**'+InvoiceRecord);
        
        if(InvoiceRecord.Id == null){
            System.debug('two');
            showInfo = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Your previous and future bills will be stored here once your first bill is available.');
            ApexPages.addMessage(myMsg);
        }
    }   
}