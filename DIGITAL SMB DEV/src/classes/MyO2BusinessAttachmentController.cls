public with sharing class MyO2BusinessAttachmentController {
    
    private boolean inFlow = true;
    public Attachment attachment {get; set;}
    
    public MyO2BusinessAttachmentController() {}
    
    public MyO2BusinessAttachmentController(ApexPages.StandardController controller) {
      // Existing
      if(System.currentPagereference().getParameters().get('flow')!=null) {
          if(System.currentPagereference().getParameters().get('flow')=='false') {
              inFlow = false;
          }
      }
      
      attachment = (Attachment)controller.getRecord();
      System.debug('attachement controller, attachement = ' + attachment);
      if(attachment.Id!=null) {
          attachment = [select id, name, description, parentId from attachment where id=:attachment.Id];
      } else if (!Test.isRunningTest()){ 
          attachment.parentId = System.currentPagereference().getParameters().get('parentId');
      } 
      if(attachment.parentId==null) { 
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.MO2B_ID_REQUIRED_IN_URL));      
      }    
    }
 
    public PageReference upload() {
        PageReference pRef = null;      
		// this code is for file sizes related messages from visualforce        
        if(ApexPages.hasMessages(ApexPages.severity.ERROR)) {
        	System.debug('upload - apex page error');
            return null;
        }
        
        if(attachment == null || attachment.body == null){
        	System.debug('upload - attachment ' + attachment + ' body ' + attachment.Body);
          	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MO2B_ATTACHMENT_PLEASESELECT));
          	return null;              
        }
        
        if (!Schema.sObjectType.Attachment.isUpdateable() && Schema.sObjectType.Attachment.isCreateable()){
        	System.debug('upload - attachment is not updateable and is createable');
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MO2B_ATTACHMENT_PRIVS));
          return null;        
        }
        //  attachment.OwnerId = UserInfo.getUserId();        
        // Database.SaveResult sr = Database.upsert(attachment,false);
        
        
        
        try {
          	attachment.OwnerId = UserInfo.getUserId();
          	if(attachment.body!=null) {
          		System.debug('upload - upserting attachment');
              	upsert attachment;
          	}
        	} catch (DMLException e) {
          		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MO2B_UPLOAD_ATTACHMENT));
          	return null;
        } 
        
        
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        if(!inFlow) {
        	System.debug('upload - not in flow');
            pRef = Page.MyO2BusinessServiceRequestDetails;
        } else {
            pRef = Page.MyO2BusinessCaseDetails;
        }
        pRef.getParameters().put('Id',attachment.parentId);
        return pRef;
    }
    
}