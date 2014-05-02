public with sharing class MyO2BusinessRequestPUKCodeController {
    
    
     
      /*Properties*/
    //Subscription controller
    MyO2BusinessSubscriptionsController subscriptionController;

    //Puk Code line items
    public List<PUKCodeChangeCaseLineItem> PUKCodeChangeCaseLineItems{get; set;}
    
    //Consturctor
    public MyO2BusinessRequestPUKCodeController(MyO2BusinessSubscriptionsController controller) {
        //selectedSubscriptions = new List<AC_Subscription__c>();
        
        //Initalize controller
        subscriptionController = (MyO2BusinessSubscriptionsController)controller;
       subscriptionController.stepNumber = 2;
        subscriptionController.IsEditMode = true;
    	  subscriptionController.newCase = new Case();
       subscriptionController.caseLineItems = new List<mo2b_CaseLineItem__c>();
        OrderFieldNameTemp = '';
        OrderFieldName = '';
        OrderType = '';
        IsSubscriptionRefreshed = false;
       // IsSameCostCenter = false;
       
    }
     public PageReference smbPageName{get; set;}
     public boolean IsSubscriptionRefreshed{get; set;}
    public void RefreshExtras(){
        System.debug('Inside Refresh');
        boolean result = subscriptionController.GetSubscriptionExtras();
        if (subscriptionController.SubscriptionsSize == 0) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_NO_SUBSCRIPTIONS_AVAILABLE));
        }
        if(result){
            PUKCodeChangeCaseLineItems = new List<PUKCodeChangeCaseLineItem>();
            for(AC_Subscription_Extra__c selectedSubscription : subscriptionController.selectedExtraSubscriptions) {
                PUKCodeChangeCaseLineItems.add(new PUKCodeChangeCaseLineItem(selectedSubscription));
            }
        }
        IsSubscriptionRefreshed = result;       
    	smbPageName = Page.smbhome;
      
    }
    
     //Internal class used to store subscriptions
    public class PUKCodeChangeCaseLineItem implements Comparable{

        public AC_Subscription_Extra__c SubscriptionExtra{get; set;}
        public string MobileNumber{get; set;}
        public string Subscriber{get; set;}
        public string CompareField{get; set;}
        public string PUKCode{get; set;}
        public PUKCodeChangeCaseLineItem(AC_Subscription_Extra__c SubscriptionExtra){
            this.SubscriptionExtra = SubscriptionExtra;
            this.CompareField = '';
            this.MobileNumber = SubscriptionExtra.AC_Subscription__r.Network_Serial_No__c;
            this.Subscriber = SubscriptionExtra.AC_Subscription__r.Subscription_Name__c;
            this.PUKCode = SubscriptionExtra.PUK_Code__c;
            if (this.PUKCode == null || this.PUKCode == '') {
            	this.PUKCode = Label.MO2B_PUK_CODE_BLANK;
            }
        }

        public integer compareTo(Object compareTo){
            PUKCodeChangeCaseLineItem otherItem = (PUKCodeChangeCaseLineItem)compareTo;
            integer result = 0;
            if(CompareField == 'MOBILE_NUMBER'){
                result = this.MobileNumber.compareTo(otherItem.MobileNumber);
            } else if (CompareField == 'SUBSCRIBER'){
                result = this.Subscriber.compareTo(otherItem.Subscriber);
            } else if (CompareField == 'PUK_Code'){
                result = this.PUKCode.compareTo(otherItem.PUKCode);
            }
            return result;
        }
    }
    
  /*  
   public PageReference Cancel(){
        
        if(smbPageName != null){
         return Page.SMBHome;
        }else{
            
         return Page.MyO2BusinessHome;
        }
        
    }
    */
     //Sort
    public void SortList(){
        if(OrderFieldNameTemp != OrderFieldName){
            OrderType = 'ASC';
            OrderFieldName = OrderFieldNameTemp;
        } else {
            OrderType = OrderType != 'ASC' ? 'ASC' : 'DESC';
        }
        for(PUKCodeChangeCaseLineItem li : PUKCodeChangeCaseLineItems){
            li.CompareField = OrderFieldName;
        }
        PUKCodeChangeCaseLineItems.sort();
        if(OrderType == 'DESC'){
            List<PUKCodeChangeCaseLineItem> temp = new List<PUKCodeChangeCaseLineItem>();
            for(integer i = PUKCodeChangeCaseLineItems.size() - 1; i>= 0; i--){
                temp.add(PUKCodeChangeCaseLineItems[i]);
            }
            PUKCodeChangeCaseLineItems = temp;
        }
    }

    //Sort help properties
    public string OrderFieldNameTemp {get; set;}
    public string OrderFieldName {get; set;}
    public string OrderType {get; set;}
   
}