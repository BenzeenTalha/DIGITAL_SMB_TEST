public with sharing class SMBAccountDetails {
    
    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------
    public SMBAccountDetails()
    {
    }


   public Account getAccountDetails(){
    
     Account account = null;
    
      User currentUser = [SELECT Id, AccountId, ContactId, Name, Email FROM User WHERE Id = :userInfo.getUserId()][0];
      
      //User currentUser = [SELECT Id, AccountId, ContactId, Name, Email FROM User WHERE Id = '005W0000000qrR1' ];
      
      if(currentUser != null){
              account = [SELECT name, AccountOwner__c, Billing_Country__c, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity from Account where id =: currentUser.AccountId  ];
        }
        
        
        return account;
   
   }
   
   
 
}