/*
Class Name :SMBRenewalDetailsController
Page name :SMBRenewalDetails
Date: 28-May-2013
Requirement : SMB Customer Portal
Description: This class is used to display renewal information related to logged in user  
*/
public class SMBRenewalDetailsController { 
    /*
    //public List<AC_Subscription__c> selectedSubscriptions
    public PageReference pageName{get; set;}
    private integer counter=0;  //keeps track of the offset
    private integer list_size=10; //sets the page size or number of rows
    public integer total_size; //this will contains total number of records
     
    public SMBRenewalDetailsController() {
        
        getSelectedSubscriptions();
        List<String> containerList = new List<String>();
        Map<Id, AC_Subscription__c> subscriptionsMap = new Map<Id, AC_Subscription__c>();
                        
        User currentUser = [SELECT Id, AccountId, ContactId, Name, Email FROM User WHERE Id =: userInfo.getUserId()];
       
        for(AC_Container__c acContainer : [SELECT Subscription_Container_ID__c FROM AC_Container__c WHERE SFAccountId__c =: currentUser.AccountId]){
           containerList.add(acContainer.Subscription_Container_ID__c);
        }
         
        total_size = [SELECT count() FROM AC_Subscription__c WHERE Subscription_Container_ID__c IN : containerList];
        pageName = Page.SMBHome;
        
    }
    
    public List<AC_Subscription__c> getselectedSubscriptions() {
        
        List<AC_Subscription__c> selectedSubscriptions = new List<AC_Subscription__c>();
        
        List<String> containerList = new List<String>();
        Map<Id, AC_Subscription__c> subscriptionsMap = new Map<Id, AC_Subscription__c>();
                        
        User currentUser = [SELECT Id, AccountId, ContactId, Name, Email FROM User WHERE Id =: userInfo.getUserId()];
       
        for(AC_Container__c acContainer : [SELECT Subscription_Container_ID__c FROM AC_Container__c WHERE SFAccountId__c =: currentUser.AccountId]){
           containerList.add(acContainer.Subscription_Container_ID__c);
        }
         
        for(AC_Subscription__c smbSubscriptions : [SELECT Id,AC_Container__r.SFAccountId__r.Channel__c, AC_container__r.CT_Salesperson_Container_ID__c,
                                                          Network_Serial_No__c, Tariff_Description__c, 
                                                          Start_Date__c, End_Date__c, Term__c, TariffType__c, 
                                                          NextUpgradeDate__c, UpgradeEligibilityStatus__c, 
                                                          UpgradeNotes__c  FROM AC_Subscription__c 
                                                          WHERE Subscription_Container_ID__c IN : containerList limit :list_size offset :counter]){
           
            date contractStartDate  = smbSubscriptions.Start_Date__c ;
            if(smbSubscriptions.TariffType__c=='SIM Only' || smbSubscriptions.TariffType__c == 'Simplicity'){
                if(contractStartDate != null){
                    smbSubscriptions.NextUpgradeDate__c = contractStartDate.addMonths(6);
                    
                    if(smbSubscriptions.NextUpgradeDate__c > System.Today()){
                        smbSubscriptions.UpgradeEligibilityStatus__c = 'Not Eligible';
                    }else {
                        smbSubscriptions.UpgradeEligibilityStatus__c = 'Eligible';
                    }
                }else {
                    smbSubscriptions.NextUpgradeDate__c = null;
                    smbSubscriptions.UpgradeEligibilityStatus__c = 'Not Eligible';
                }
            }else if(smbSubscriptions.TariffType__c != null){   
                        if(contractStartDate != null){
                            smbSubscriptions.NextUpgradeDate__c = smbSubscriptions.End_Date__c;
                            if(smbSubscriptions.NextUpgradeDate__c > System.Today()){
                                smbSubscriptions.UpgradeEligibilityStatus__c = 'Not Eligible';
                            }else{
                                smbSubscriptions.UpgradeEligibilityStatus__c = 'Eligible';
                            }
                        }else {
                            smbSubscriptions.NextUpgradeDate__c = null;
                            smbSubscriptions.UpgradeEligibilityStatus__c = 'Not Eligible';
                        }
            }
            
            if(smbSubscriptions.AC_Container__r.SFAccountId__r.Channel__c != null){
                smbSubscriptions.Customer_Type__c = smbSubscriptions.AC_Container__r.SFAccountId__r.Channel__c;
            }else {
                smbSubscriptions.Customer_Type__c = 'Direct';
            }
            if((smbSubscriptions.Customer_Type__c == 'Partner' || smbSubscriptions.Customer_Type__c == 'Franchise')
                && (smbSubscriptions.UpgradeEligibilityStatus__c == 'Eligible') ) {
                smbSubscriptions.UpgradeNotes__c = 'You are eligible for upgrade. Please contact your Partner /Franchise '+
                smbSubscriptions.AC_container__r.CT_Salesperson_Container_ID__c + ' for initiating this process';
            }
            selectedSubscriptions.add(smbSubscriptions);
        } 
        
        return selectedSubscriptions;
    }
    
    public PageReference Back() {
        if(pageName != null){
            return Page.SMBHome;
        }else{
            return null;
        }
    }
    
    public PageReference Next() {
      counter += list_size;
      return null;
    }
    
    public PageReference Previous() {
      counter -= list_size;
      return null;
   }
   
   public PageReference Beginning() {
      counter = 0;
      return null;
   }
   
   public PageReference End() {
      counter = total_size - math.mod(total_size, list_size);
      return null;
   }
   
   //This method will disable previous and beginning buttons
   public Boolean getDisablePrevious() { 
      if (counter>0) return false; else return true;
   }
   
   //This method will disable Nextand End buttons
   public Boolean getDisableNext() {
      if (counter + list_size < total_size) return false; else return true;
   }
*/
}