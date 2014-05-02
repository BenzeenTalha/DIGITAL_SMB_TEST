/*
*       This class is a controller to test the Subscriber Service functionality
*       SO'Halloran - (SFDC)
*       Revision History 
*       1.0    21/03/2011  Initial Version
*/   
// REF Test Number: 447702059016

public with sharing class SubscriberController {

                 
        public String inputNumber {get; set;}
                        
        public String operator {get; private set;}
        public String segment {get; private set;}
        public String billingSystem {get; private set;}
        public String billingProfile {get; private set;}
        public String channel {get; private set;}
        public String paymentCategory {get; private set;}
        public String puk {get; private set;}
        public String[] chargingCategory {get; private set;}
        public Long serviceProviderID {get; private set;}
        public String status {get; private set;}
        public String subscriberID {get; private set;}
        
        public String accountNumber {get; private set;}
        public String[] msisdns {get; private set;}
        
        SOASubscriberService.SubscriberPort port;
        
        public SubscriberController() {
                port = new SOASubscriberService.SubscriberPort();
                port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
                port.timeout_x = SoaUtils.SOA_TIMEOUT;
        }
                
        public String getO2Operator() {
            inputNumber = ApexPages.currentPage().getParameters().get('dn');
            if(inputNumber !=null) {
                getSubscriberProfile();
            }
            return operator;
        }
                
        //public SOASubscriberData.subscriberProfileType getSubscriberProfile(String subscriberID,String username,String password) {
        public PageReference getSubscriberProfile() {
                try {
                    SOASubscriberData.subscriberProfileType profile = port.getSubscriberProfile(inputNumber);                
                    setProfile(profile);
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }
                return null;
        } 
        
        private void setProfile(SOASubscriberData.subscriberProfileType profile) {
                channel = profile.channel;
                operator = profile.operator;
                paymentCategory = profile.paymentCategory;
                puk = profile.puk;
                segment = profile.segment;
                serviceProviderID = profile.serviceProviderID;
                status = profile.status;
                subscriberID = profile.subscriberID;            
        }
        
        private void setProfile(SOACoreData2.SubscriberProfileType profile) {
                channel = profile.channel;
                operator = profile.operator;
                paymentCategory = profile.paymentCategory;
                segment = profile.segment;
                serviceProviderID = profile.serviceProviderID;
                status = profile.status;
                subscriberID = profile.subscriberID;            
        }       
         
        //public SOASubscriberData.getSubscriberAndBillingSystemResponse getSubscriberAndBillingSystem(String msisdn,String username,String password) {
        public PageReference getSubscriberAndBillingSystem() {
                try {
                    SOASubscriberData.getSubscriberAndBillingSystemResponse subscriberAndBillingSystem = port.getSubscriberAndBillingSystem(inputNumber); 
                    billingProfile = subscriberAndBillingSystem.billingProfile;
                    setProfile(subscriberAndBillingSystem.subscriberProfile);
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }  
                return null;
        }

        //public SOASubscriberData.getBillProfileResponse getBillProfile(String msisdn,String accountNumber,String username,String password) 
        public PageReference getBillProfile() {
                try {
                    SOASubscriberData.getBillProfileResponse billProfile = port.getBillProfile(inputNumber,'accountNumber'); 
                    accountNumber = billProfile.accountNumber;
                    billingSystem = billProfile.billingSystem;
                    msisdns = billProfile.msisdnList!=null? billProfile.msisdnList.msisdn : new List<String>();               
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }                
                return null;
        }

        //public String getSubscriberOperator(String SubscriberID,String username,String password) {
        public PageReference  getSubscriberOperator() {
                try {
                    operator = port.getSubscriberOperator(inputNumber); 
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }
                return null;
        }
        
        //public String getSubscriberSegment(String SubscriberID,String username,String password) {
        public PageReference  getSubscriberSegment() {
                try {
                    segment = port.getSubscriberSegment(inputNumber); 
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }
                return null;
        }       
        //public String getBillingSystem(String msisdn,String username,String password) {
        public PageReference  getBillingSystem() {
                try {
                    billingSystem = port.getBillingSystem(inputNumber); 
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }
                return null;
        }       
        //public String getSubscriberChannel(String SubscriberID,String username,String password) {     
        public PageReference  getSubscriberChannel() {
                try {
                    channel = port.getSubscriberChannel(inputNumber); 
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }
                return null;
        }       
        //public String[] getChargingCategory(String msisdn,SOASubscriberData.productListType productList,String username,String password) {
        public PageReference  getChargingCategory() {
                try {
                    SOASubscriberData.productListType productList = new SOASubscriberData.productListType();
                    productList.tariffProductId='';
                    SOASubscriberData.servicesType services = new SOASubscriberData.servicesType();
                    services.productId = new List<String>();
                    productList.services = services;
                    chargingCategory = port.getChargingCategory(inputNumber, productList); 
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }
                return null;
        }       
        //public String getSubscriberPaymentCategory(String SubscriberID,String username,String password) {
        public PageReference  getSubscriberPaymentCategory() {
                try {
                    paymentCategory = port.getSubscriberPaymentCategory(inputNumber); 
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                }
                return null;
        }    
        
        static testMethod void testSubscriberController() {
        	SubscriberController sub = new SubscriberController();
        	ApexPages.currentPage().getParameters().put('dn','213978219');
        	sub.inputNumber = '213978219';
        	sub.getBillingSystem();
        	sub.getBillProfile();
        	sub.getChargingCategory();
        	sub.getO2Operator();
        	sub.getSubscriberAndBillingSystem();
        	sub.getSubscriberChannel();
        	sub.getSubscriberOperator();
        	sub.getSubscriberPaymentCategory();
        	sub.getSubscriberProfile();
        	sub.getSubscriberSegment();
        	// TODO: Add Asserts here   
        }                          
        
}