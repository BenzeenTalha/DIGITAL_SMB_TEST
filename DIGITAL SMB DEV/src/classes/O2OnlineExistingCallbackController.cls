public without sharing class O2OnlineExtCustCalBkController{

    Integer count = 0;
    
    String Submit = 'Request call back';
    
    String callfromCustomer = 'Call us on 08800 111 6005';
    
    String CallbackMessage = '';
    
    String callfromCustomerMsg = '';
    
    Boolean isDisabled;
    
    String BoldFont1;
    
    String BoldFont2;
    
    
   
    public  UseCallBack useCallBack {get;set;}
    
    public O2OnlineExtCustCalBkController() {
        useCallBack = new useCallBack();
    }

    public class useCallBack{
        public string iExistCallBack {get;set;}
    }

  public PageReference doSubmit() {
    
      existingCustCallBackReq__c callTsk = new existingCustCallBackReq__c();
       
       //callTsk.Call_me_back__c = useCallBack.iExistCallBack;
         callTsk.Call_me_back__c  = 'Customer requested call back';
         
         Submit = 'Call back requested';
         
          isDisabled = true;
  
         CallbackMessage = 'We will call you back in the next 2 hours on the number you have given us';   

         count++;

         BoldFont1 = 'font-weight:900;';

        insert callTsk;
        return null;
      
        }
        
        
   public PageReference doSubmit2() {
    
      existingCustCallBackReq__c callTsk = new existingCustCallBackReq__c();
       
      // callTsk.Call_me_back__c = useCallBack.iExistCallBack;
       callTsk.Call_me_back__c = 'Customer shall call us';  

         callfromCustomer = 'Call us on 08800 111 6005';

         isDisabled = true;
         
         callfromCustomerMsg = 'We look forward to hearing from you, we are open 9 a.m. - 6 p.m. Monday - Saturday';
         
         count++;
           
        BoldFont2 = 'font-weight:900;';
        
        insert callTsk;
        return null;
     
        
        }       
        
        
                   
   /* public PageReference incrementCounter() {
            count++;
            return null;
        }
*/                    
    public Integer getCount() {
        return count;
    }   
    
    
        public string getSubmit() {
        return submit;
        
    } 

         public string getCallbackMessage() {
        return callbackMessage;
        
    } 



    public string getcallfromCustomer(){
    return callfromCustomer;
    } 

    public string getcallfromCustomerMsg() {
    return callfromCustomerMsg;
    } 

    public Boolean getIsDisabled(){
    return this.isDisabled;
    }
    
    public string getBoldFont1(){
    return this.BoldFont1;
    }
    
    public string getBoldFont2(){
    return this.BoldFont2;
    }
     
}