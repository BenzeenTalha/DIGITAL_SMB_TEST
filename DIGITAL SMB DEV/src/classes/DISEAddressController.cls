/*
*       This class is the controller for the DISE Address page
*       It is used to call the DISE getAccountDetails service to retrieve the Billing Address from DISE, give a DISE account number
*       Revision History 
*       1.0    20/07/2011  Initial Version
*/ 
public with sharing class DISEAddressController {
    
    private Account acc;
    
    public String DISEAccountNumber { get; set; } 
    
    public String companyName { get; private set; }
    public String address1 { get; private set; }
    public String address2 { get; private set; }
    public String address3 { get; private set; }
    public String address4 { get; private set; }
    public String address5 { get; private set; }
    public String postcode { get; private set; }
    public String companyTelephoneNumber { get; private set; }    
    
    public DISEAddressController(ApexPages.StandardController controller) {
        acc = (Account)controller.getRecord();
        try {
            DISEAccountNumber = [select DISE_Group_Code_Account_No_1__c from account where id=:acc.Id].DISE_Group_Code_Account_No_1__c;  
            // Do we want an auto search on the current DISE account number when the page is opened?
            //if(DISEAccountNumber!=null && DISEAccountNumber!='') {
                //getAccountDetailsProxy();
            //}    
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot find account'));
        }
    }
    
    // Use the WDSL proxy class to call the DISE service and parse the response into the address variables
    public PageReference getAccountDetailsProxy() {
        address1 = '';
        address2 = '';
        address3 = '';
        address4 = '';
        address5 = '';
        companyName = '';
        postcode = '';
        companyTelephoneNumber = '';

        try {
            Integer.valueOf(DISEAccountNumber);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Invalid Account Number.'));
            return null;
        }
        SOAManageBusinessCustomerDetailsService.ManageBusinessCustomerDetailsPort port = new SOAManageBusinessCustomerDetailsService.ManageBusinessCustomerDetailsPort();
        port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
        port.timeout_x = SoaUtils.SOA_TIMEOUT;        
        SOAManageBusinessCustomerDetailsData.accountDataFiltersType adft = new SOAManageBusinessCustomerDetailsData.accountDataFiltersType();
        adft.accountDataFilter = new List<String>();
        adft.accountDataFilter.add('ADDRESS');
        try {
            SOAManageBusinessCustomerDetailsData.getAccountDetailsResponse result;
            if(!Test.isRunningTest()) {
                result = port.getAccountDetails(DISEAccountNumber, adft);    
            } else {
                // Tests cannot call a service so this simulates a response for the unit tests
                result = new SOAManageBusinessCustomerDetailsData.getAccountDetailsResponse();
                result.accountBasic = new SOAManageBusinessCustomerDetailsData.accountBasicType();
                result.accountTypeAndUsage = new SOAManageBusinessCustomerDetailsData.accountTypeAndUsageType();
                result.addressDetails = new SOAManageBusinessCustomerDetailsData.accountAddressType();
                result.addressDetails.businessDetails = new SOAManageBusinessCustomerDetailsData.businessAccountDetailsType();
                result.addressDetails.businessDetails.companyName = 'Acme';
                result.addressDetails.businessDetails.address1 = '123';
                result.addressDetails.businessDetails.address2 = 'High Street';
                result.addressDetails.businessDetails.address3 = 'New Town';
                result.addressDetails.businessDetails.address4 = 'New County';
                result.addressDetails.businessDetails.address5 = '';
                result.addressDetails.businessDetails.postcode = 'AA1 1AA';
                result.addressDetails.businessDetails.companyTelephoneNumber = '123456789';
                
                result.autoPayments = new SOAManageBusinessCustomerDetailsData.autoPaymentsType();
                result.creditControl = new SOAManageBusinessCustomerDetailsData.creditControlType();
                result.customerDetails = new SOAManageBusinessCustomerDetailsData.accountCustomerDetailsType();
                result.discounts = new SOAManageBusinessCustomerDetailsData.discountDetailsType();
                result.lastAmendedDate = System.now();
                result.nonSubscriptionInvoiceControl = new SOAManageBusinessCustomerDetailsData.nonSubscriptionInvoiceControlType();
                result.paymentDetails = new SOAManageBusinessCustomerDetailsData.accountPaymentDetailsType();
                result.subscriptionInvoiceControl = new SOAManageBusinessCustomerDetailsData.subscriptionInvoiceControlType();                
            }
            if(result.addressDetails!=null) {
                if(result.addressDetails.businessDetails!=null) {
                    if(result.addressDetails.businessDetails.companyName!=null) companyName =result.addressDetails.businessDetails.companyName;
                    if(result.addressDetails.businessDetails.address1!=null) address1=result.addressDetails.businessDetails.address1;
                    if(result.addressDetails.businessDetails.address2!=null) address2=result.addressDetails.businessDetails.address2;
                    if(result.addressDetails.businessDetails.address3!=null) address3=result.addressDetails.businessDetails.address3;
                    if(result.addressDetails.businessDetails.address4!=null) address4=result.addressDetails.businessDetails.address4;
                    if(result.addressDetails.businessDetails.address5!=null) address5=result.addressDetails.businessDetails.address5;
                    if(result.addressDetails.businessDetails.postcode!=null) postcode=result.addressDetails.businessDetails.postcode;
                    if(result.addressDetails.businessDetails.companyTelephoneNumber!=null) companyTelephoneNumber=result.addressDetails.businessDetails.companyTelephoneNumber;
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ' Billing Details not found for this account: ['+e.getMessage()+']'));
        }
        return null;
    }
    
    public PageReference save() {
        // Verify the users access rights
        if (!Schema.sObjectType.Account.fields.name.isUpdateable() || 
                !Schema.sObjectType.Account.fields.billingstreet.isUpdateable() || 
                !Schema.sObjectType.Account.fields.billingcity.isUpdateable() || 
                !Schema.sObjectType.Account.fields.billingstate.isUpdateable() || 
                !Schema.sObjectType.Account.fields.billingpostalcode.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update address'));
            return null;
        }
        String billingStreet = '';
        // Not currently overwritting the Account DISE Number with the searched on DISE Number
        if((acc.DISE_Group_Code_Account_No_1__c==null || acc.DISE_Group_Code_Account_No_1__c=='') && DISEAccountNumber!='') {
            acc.DISE_Group_Code_Account_No_1__c = DISEAccountNumber ;
        }
        acc.Name =companyName;
        billingStreet += address1;  
        if(billingStreet!='') billingStreet += '\n' ;   
        billingStreet += address2;
        acc.billingstreet = billingStreet;
        acc.billingcity = address3;
        acc.billingstate = address4;
        //acc.address5;
        acc.billingpostalcode = postcode;
        acc.phone = companyTelephoneNumber;  
        try {
            update acc; 
            PageReference acctPage = new ApexPages.StandardController(acc).view();
            acctPage.setRedirect(true); 
            return acctPage; 
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ' Could not save billing details : ['+e.getMessage()+']'));
            return null;
        }
    }
    
    static testMethod void testDISEAddressController() {
        boolean errorFound = false;
        Account acc = new Account();
        acc.name = 'Test Acc';
        insert acc;
        ApexPages.StandardController sc = new ApexPages.StandardController(acc); 
        DISEAddressController controller = new DISEAddressController(sc);
        controller.DISEAccountNumber = '3882';
        controller.getAccountDetailsProxy();    
        controller.save();
        acc = [select id, name, billingStreet, billingcity, billingstate, billingpostalcode, phone from Account where id=:acc.Id];
        //System.assertEquals('Acme',acc.name);
        //System.assertEquals('New Town',acc.billingcity);
        //System.assertEquals('AA1 1AA',acc.billingpostalcode);       
    }
    
    static testMethod void testDISEAddressControllerExceptions() {
        boolean errorFound = false;
        Account acc = new Account();
        ApexPages.StandardController sc = new ApexPages.StandardController(acc); 
        DISEAddressController controller = new DISEAddressController(sc);
        ApexPages.Message[] mssgs = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs){
           if(m.getDetail().contains('Cannot find account'))
              errorFound=true;
        }   
        System.assert(errorFound==true);
        errorFound = false;
                
        controller.DISEAccountNumber = 'xxxx';
        controller.getAccountDetailsProxy();    
        mssgs = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs){
           if(m.getDetail().contains('Invalid Account Number'))
              errorFound=true;
        }   
        System.assert(errorFound==true);
        errorFound = false;
        
        controller.save();
        mssgs = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs){
           if(m.getDetail().contains('Could not save billing details'))
              errorFound=true;
        }   
        System.assert(errorFound==true);
        
    }

}