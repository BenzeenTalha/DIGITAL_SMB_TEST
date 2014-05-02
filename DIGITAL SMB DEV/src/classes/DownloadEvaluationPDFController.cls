public with sharing class DownloadEvaluationPDFController {
    
    ApexPages.StandardController controller;
    public Loan_Library_Request__c loanReq {get;set;}
    
    
    public DownloadEvaluationPDFController(ApexPages.StandardController stdController){
        controller = stdController;
        loanReq = (Loan_Library_Request__c) stdController.getRecord();      
    }
    
    public PageReference createPDFAttachment(){
        
        String pageName = 'DownloadEvaluationPDF';
        
        PageReference pdf = new PageReference('/apex/'+pageName+'?id='+loanReq.id);
        pdf.setRedirect(true);
        
        //Get locale time zone not GMT  
        Datetime d = system.now();
        String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');
        
        Attachment a = null;
        if (!Test.isRunningTest()) {
	        a = new Attachment(parentId = loanReq.id, name='EvaluationDocument'+ strDatetime+ '.pdf', body = pdf.getContent());
        } else {
        	// cannot call getContent in a test
        	Blob bodyData = Blob.valueOf('c3VyZS4=');
		    a = new Attachment(parentId = loanReq.id, name='EvaluationDocument'+ strDatetime+ '.pdf', body = bodyData);    	
        }
        
        try{
         insert a;
        }catch(exception ex){
        }
        
        return null;
    }
    public List<Equipment_Allocation__c> getRelatedListForHandsetInPDF(){
        List<Equipment_Allocation__c> equipmentAllocationList = [Select e.IMEI_Serial_No__r.Name,e.Product__r.Name, e.Trial_Kit__r.Manufacturer__c, 
        e.Trial_Kit__r.Private_APN_Number__c, e.Trial_Kit__r.Private_APN__c, e.Trial_Kit__r.O2_Mob_Web_APN__c, e.Type__c, e.Trial_Kit__r.O2_Mob_Web__c, 
        e.Trial_Kit__r.Model__c, e.Trial_Kit__r.Loan_Library_Request__c, e.Trial_Kit__r.BB_APN__c, e.Trial_Kit__c, e.MPN__c, e.IMEI_Serial_No__c 
        From Equipment_Allocation__c e where e.IMEI_Serial_No__c !=null and e.Trial_Kit__r.Loan_Library_Request__c = :loanReq.id and e.Type__c = 'Handset'];
        return equipmentAllocationList;
    }    
    public List<Equipment_Allocation__c> getRelatedListForSIMInPDF(){
        List<Equipment_Allocation__c> equipmentAllocationList = [Select e.Type__c, e.Trial_Kit__r.Loan_Library_Request__c, e.Trial_Kit__c, e.MPN__c, 
        e.IMEI_Serial_No__c, e.IMEI_Serial_No__r.Name From Equipment_Allocation__c e where e.IMEI_Serial_No__c !=null and 
        e.Trial_Kit__r.Loan_Library_Request__c = :loanReq.id and e.Type__c = 'SIM'];
        return equipmentAllocationList;
    }
    public String getLengthOfLoan(){
        Loan_Library_Request__c loan = [Select Id, Length_of_Loan_Approved_In_Days__c from Loan_Library_Request__c where Id = :loanReq.id];
        String lengthOfLoan = String.valueOf(loan.Length_of_Loan_Approved_In_Days__c);
        return lengthOfLoan;
    }
}