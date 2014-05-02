public with sharing class MyO2BusinessServiceRequestExtension {

    // the case we are looking at
    public Case thisCase {get; set;}
    public CaseComment cComment {get; set;} 
    public Boolean smbUser{get; set;}  
    public map<string,string> caseStatusMap = new map<string,string>();
    
    // the standard controller for case
    ApexPages.StandardController sc;
    
  //  public Boolean caseProgressFlag {get; set;}
    
    public MyO2BusinessServiceRequestExtension(ApexPages.StandardController controller) {
    	//caseProgressFlag = false;
        sc = controller;
        smbUser = CaseUtils.checkLoginUserSegment();
        thisCase = (Case)controller.getRecord();
        cComment = new caseComment();
        populateStatusMap();
       // caseProgressFlag = checkingCaseStatus(thisCase.id);
       // system.debug('caseProgressFlag--------'+caseProgressFlag);
    }

    // Actions
    public PageReference addComment() {
        if(cComment.CommentBody!='') {
            cComment.parentId = thisCase.Id;
            insert cComment; 
            cComment = new caseComment();
        }
        return null;
    }
    
    public List<Attachment> getCaseAttachments() {
        return [select id, name, body, BodyLength, Description, contentType, parentId, createdby.name, systemmodstamp from Attachment where parentId =: thisCase.Id order by createddate desc];
    }    
    
    public List<CaseComment> getCaseComments() {
        return [select Id, CommentBody, IsPublished, CreatedById, CreatedDate from CaseComment 
                where ParentId=:thisCase.Id order by createddate desc];
    }

    public List<CaseHistory> getCaseHistory() {
//        return [select CreatedById, CreatedDate,  Field, NewValue, OldValue from CaseHistory 
//                where (Field = 'Status' OR Field = 'created') and CaseId=:thisCase.Id order by createddate desc];
        return [select CreatedById, CreatedDate,  Field, NewValue, OldValue from CaseHistory 
                where Field = 'mo2b_Status_value__c' and CaseId=:thisCase.Id order by createddate desc];
    }       

    public List<mo2b_caselineitem__c > getCaseLineItems() {
        return [select id, name, account_number__c, mobile_user_name__c, mobile_number__c, start_date__c, Subscription_Name__c, Network_Serial_No__c, Subscriber_Name__c, MPN__c,
                Old_SIM_Number__c, New_Cost_Centre__c, Old_Cost_Centre__c, New_SIM_Number__c, Suspend__c, Bolt_On__c, Customer_Contact_Status_Description__c, Subscription_used_on_a_new_device__c,
                New_Device_Details__c, Add_Remove_Bars__c, Requested_Bar_Changes__c, New_Subscriber_Name__c, Customer_Order_for__c
                from mo2b_caselineitem__c 
                where case__c=: thisCase.Id order by createddate desc];
    }
    
    public List<BoltOnCLIWrapper> getBoltOnCaseLineItems() { 
    	List<mo2b_caselineitem__c > clis = getCaseLineItems();
    	List<BoltOnCLIWrapper> boltOnUpdates = new List<BoltOnCLIWrapper>();
    	for (mo2b_caselineitem__c cli: clis) {
    		boltOnUpdates.Add(new BoltOnCLIWrapper(cli));
    	}
    	return boltOnUpdates;
    }
    
    public class BoltOnCLIWrapper {
    	public String toAdd {get;set;}
    	public String toRemove {get;set;}
    	public String subscriberName {get;set;}
    	public String MPN {get;set;}
    	public String customerContactStatusDescription {get;set;}
    	
    	public BoltOnCLIWrapper (mo2b_caselineitem__c cli) {
    		toAdd = '';
    		toRemove = '';
    		subscriberName = cli.Subscriber_Name__c;
    		MPN = cli.MPN__c;
    		customerContactStatusDescription = cli.Customer_Contact_Status_Description__c;
    		List<MyO2BusinessBoltOnUpdate__c> boltOnUpdates = [Select m.Price__c, m.Description__c,  m.Add_Remove__c From MyO2BusinessBoltOnUpdate__c m where m.Customer_Request__c = :cli.Id];
    		for (MyO2BusinessBoltOnUpdate__c boltOnUpdate: boltOnUpdates) {
    			String formattedBoltOn = boltOnUpdate.Description__c + '_£' + boltOnUpdate.Price__c + '; '; 
    			if (boltOnUpdate.Add_Remove__c == 'Add') {
    				toAdd += formattedBoltOn;
    			}
    			if (boltOnUpdate.Add_Remove__c == 'Remove') {
    				toRemove += formattedBoltOn;
    			}
    		}
    	}
    }
    
    private void populateStatusMap(){
        caseStatusMap.put('New', 'In Progress');
        caseStatusMap.put('In Progress', 'In Progress');
        caseStatusMap.put('On Hold', 'In Progress');
        caseStatusMap.put('Waiting on Customer', 'Awaiting Customer Response');
        caseStatusMap.put('Customer Response Received', 'In Progress');
        caseStatusMap.put('Draft', 'In Progress');
        caseStatusMap.put('Open', 'In Progress');
        caseStatusMap.put('Closed', 'Closed');
    }
    
    public List<CaseHistoryChanged> getCaseHistoryChanged(){
        List<CaseHistoryChanged> toreturnList = new List<CaseHistoryChanged>();
        List<CaseHistory> caseHistoryList = getCaseHistory();
        for(CaseHistory ch : caseHistoryList){
            CaseHistoryChanged chc = new CaseHistoryChanged();  
            chc.NewValue = string.valueof(ch.NewValue);
            chc.OldValue = string.valueof(ch.OldValue);
            //chc.createdDate = string.valueof( ch.CreatedDate );
            chc.createdDate = ch.CreatedDate.format('dd/MM/yyyy HH:mm');
            toreturnList.add(chc);
        }
        system.debug('toreturnList-----'+toreturnList);
        return toreturnList;
    } 
    
    public class CaseHistoryChanged{
        public string NewValue {get; set;}
        public string OldValue {get; set;}
        public string createdDate {get; set;}
    }    
    
    /*
    private Boolean checkingCaseStatus(Id caseId){
    	Boolean chkStatusFlag = false;
    	//List<CaseHistory> caseHistoryList = getCaseHistory();
        for(CaseHistory ch : [select CreatedById, CreatedDate,  Field, NewValue, OldValue from CaseHistory 
                where field='Status' and CaseId =: caseId order by createddate desc]){
            if((caseStatusMap.get(string.valueof(ch.NewValue)) == 'In Progress') || (caseStatusMap.get(string.valueof(ch.OldValue)) == 'In Progress')){
				system.debug('Inside value case status value check');
            	chkStatusFlag = true;
            }
        }
        system.debug('chkStatusFlag---'+chkStatusFlag);
        return chkStatusFlag;
    }
    */
    
}