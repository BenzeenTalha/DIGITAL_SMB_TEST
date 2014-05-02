/*
* Generic / Bucket Service Request Creation
* 
* Revision history
* February 2013 - S O'Halloran - initial version
* May 2013 - S O'Halloran - addition of order form part 
*/
public with sharing class MyO2BusinessCaseExtension {

    public Case thisCase {get; set;}
    public mo2b_CaseLineItem__c cli {get; set;}
    public List <mo2b_CaseLineItem__c> clis {get; set;}
    public Attachment attachment {get; set;}
    public MyO2BusinessForm__c sectionSettings {get; set;}
    public boolean readOnly {get; private set;}
    public Boolean smbUser{get; set;}    
    MyO2BusinessUser businessUser;
    
    public MyO2BusinessCaseExtension() {
        readOnly = false;
        clis = new List <mo2b_CaseLineItem__c>();
        Id id = ApexPages.currentPage().getParameters().get('id');
        thisCase = new Case();
        //thisCase.OwnerId ='00520000001cxxF';
        System.debug('myo2businesscaseextension constructor thisCase = ' + thisCase);
        smbUser = CaseUtils.checkLoginUserSegment();
        
        if(id==null) { // New case line item
            attachment = new Attachment();
            cli = new mo2b_CaseLineItem__c();
            sectionSettings = MyO2BusinessForm__c.getValues('Default');
        } else { // Existing case line item
            readOnly = true;
            String query = 'SELECT ';
            Map<String, Schema.FieldSet> fsMap = Schema.SObjectType.mo2b_CaseLineItem__c.fieldSets.getMap();
            for(Schema.FieldSet fs : fsMap.values()) {
                for(Schema.FieldSetMember f : fs.getFields()) {
                    query += f.getFieldPath() + ', ';
                }
            }
            query += 'Id, Name, Case__r.Request_Sub_Type__c, Case__c FROM mo2b_CaseLineItem__c where Id=:Id LIMIT 1';
            cli = Database.query(query);  
            if(cli!=null) {
                thisCase.Request_Sub_Type__c = cli.Case__r.Request_Sub_Type__c;
                sectionSettings = MyO2BusinessForm__c.getValues(thisCase.Request_Sub_Type__c);    
            }
        }
        
    }

    public MyO2BusinessCaseExtension(ApexPages.StandardController controller) {
        thisCase = (Case)controller.getRecord();
        smbUser = CaseUtils.checkLoginUserSegment();
        attachment = new Attachment();
    }
    
    
    public PageReference doAddDetails() {
        sectionSettings = MyO2BusinessForm__c.getValues(thisCase.Request_Sub_Type__c);
        return Page.MyO2BusinessForm;
    }
    
    public PageReference doClone() {
        clis.add(cli);
        cli = cli.clone();
        return null;
    }
    
    public PageReference doDetailSave() {
        clis.add(cli);  
        return doSave();
    }
        
    public PageReference doSave() {
        System.debug('----$$$$$$$$$$$$$$---- inside-doSave-----');
        PageReference ref = null;
        Id newCaseId;
        
        /*
        if  (!validateForm())           
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Request type and Request sub type are required'));
            return null;
        }
        */
        
        try {
            if(!clis.isEmpty() && clis[0].Id !=null) {
                upsert clis;
                newCaseId = clis[0].case__c;
            } else {
                newCaseId = createCase();
                // If an attachment has been selected then also insert it now that we have the case id
                if(attachment.name!=null) {
                    attachment.ParentId = newCaseId;
                    insert attachment;  
                }
                for(mo2b_CaseLineItem__c cli : clis) {
                    cli.Case__c = newCaseId;
                }    
                if(!clis.isEmpty()) {
                    
                    insert clis;
                }
            }
            ref = Page.MyO2BusinessServiceRequestDetails;
            ref.getParameters().put('id',newCaseId);     
            ref.setRedirect(true);       
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Case Created : #' + [select casenumber from case where id=:newCaseId].casenumber));            
        } catch (Exception e) {
            //if(!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        } finally {
            attachment = new Attachment(); 
        }
        return ref;
    }    
    
    private Id createCase() {
                System.debug('----$$$$$$$$$$$$$$---- inside-createCase-----');
        
        Id newCaseId;
        
        if (!Schema.sObjectType.Case.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.MO2B_UPDATE_PRIVS));
        }  
        else if  (thisCase.Id==null && !Schema.sObjectType.Case.isCreateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.MO2B_CREATE_PRIVS));
        } else {
            try {
                // Required for Case Assignment - Set DML option "useDefaultRule"
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                thisCase.setOptions(dmo);
                // Map the request type to the standard subject field
                thisCase.subject = thisCase.Service_Request_Type__c;
                thisCase.origin = 'Customer Portal';
                System.debug('----$$$$$$$$$$$$$$---- inside-createCase--befre insert---');
                insert thisCase;
                newCaseId = thisCase.Id;
                System.debug('----$$$$$$$$$$$$$$---- inside-createCase--after insert---' + thisCase.Id);
                thisCase = new Case();
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            }
        }  
        return newCaseId;  
    }   
    
    private boolean validateForm(){
        
        if(thisCase.Service_Request_Type__c == null || 
            thisCase.Request_Sub_Type__c == null ||
            thisCase.Service_Request_Type__c == '' || 
            thisCase.Request_Sub_Type__c == ''
        
        ){
            return false;
        } else{
            return true;
        }
        
    }
    public PageReference Cancel() {
        system.debug('value of smb user is :' + smbUser);
        if(smbUser){
            
        return Page.smbhome;
        }else{
            
            return Page.MyO2BusinessHome;
        }
    }
}