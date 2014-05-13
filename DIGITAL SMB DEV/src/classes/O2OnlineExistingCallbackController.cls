public without sharing class O2OnlineExtCustCalBkController{

    Integer count = 0;
    
    String Submit = 'Submit';
    
    String CallbackMessage = '';
    
   
    public  UseCallBack useCallBack {get;set;}
    
    public O2OnlineExtCustCalBkController() {
        useCallBack = new useCallBack();
    }

    public class useCallBack{
        public string iExistCallBack {get;set;}
    }

  public PageReference doSubmit() {
    
      existingCustCallBackReq__c callTsk = new existingCustCallBackReq__c();
       
     callTsk.Call_me_back__c = useCallBack.iExistCallBack;
         
         Submit = 'Call back requested';
         CallbackMessage = 'We will call you back in the next 2 hours on the number you have given us';   
         
         count++;
           
    
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

    
     
}