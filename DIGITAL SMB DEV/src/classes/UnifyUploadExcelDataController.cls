public with sharing class UnifyUploadExcelDataController {
    
    public string excelContent {get;set;}
    public string context {get;set;}
    public string sectionTitle {get;set;}
    
    public UnifyUploadExcelDataController() {
        if(ApexPages.currentPage().getParameters().containsKey('context')){
            context = ApexPages.currentPage().getParameters().get('context');
            if(context == 'hb'){
                sectionTitle = 'Hardware Bundle upload';
            } else if(context == 'site'){
                sectionTitle = 'Sites upload';
            } else if(context == 'config'){
                sectionTitle = 'Pillars configurations upload';
            }
        } else {
            
        }
    }
    
    public void uploadSites(){
        
        if(excelContent != '' && excelContent != null){
        
            string lineDelimiter = UnifyCommonMethods.setLineDelimeter(excelContent);
            String[] lines = excelContent.split(lineDelimiter);
            integer i = 0;
            
            Savepoint sp = Database.setSavepoint();
            
            Map<String, String[]> mSiteName2SiteRow = new Map<String, String[]>();
            
            Id oppId = ApexPages.currentPage().getParameters().get('id');
            
            Opportunity opp = [select Id, AccountId from Opportunity where Id = :oppId];
            
            String[] fieldsVals = new String[]{};
            string siteName;
            
            for(String s : lines){
                i++;            
                if(s.contains('\t')){
                    fieldsVals = s.split('\t');
                    if(fieldsVals.size() != UnifyConfig.SITES_COL_NO){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Line number ' + i + ' does not have proper structure. Number of columns should equal ' + UnifyConfig.SITES_COL_NO + ', found: ' + fieldsVals.size() + '. No records has been added.'));
                       Database.rollback(sp);
                       return;  
                    } else {
                        siteName = fieldsVals[0].toUpperCase().trim();
                        if(siteName == '' || siteName == null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Line number ' + i + ' does not contain mandatory Unique Site Name.'));
                            Database.rollback(sp);
                            return;     
                        }
                        if(mSiteName2SiteRow.containsKey(siteName)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Unique Site Name is not unique. More than one entry found with value: ' + siteName));
                            Database.rollback(sp);
                            return;
                        }
                        mSiteName2SiteRow.put(siteName, fieldsVals);
                    }
                    if(siteName == UnifyConfig.CENTRAL_SITE_KEY_NAME.toUpperCase()){
                        for(Integer j=3; j<=14; j++){
                            if(fieldsVals[j] != null && fieldsVals[j].trim() != ''){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'UNEXPECTED ERROR! Sites not imported. Reason: Central Site can not contain any Address / Contact data!'));
                                return;
                            }
                        }
                    }
                } else {
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Line number ' + i + ' does not have proper structure. TAB characters not found.'));
                    return;
                }
            }
            
            Location__c[] locs = [select Id, Unify_Unique_Site_Name__c, Unify_Unique_Site_Name_Upper_Case__c from Location__c where Unify_Unique_Site_Name_Upper_Case__c in: mSiteName2SiteRow.keySet() and Account__c = :opp.AccountId];
            Unify_Opportunity_Location__c[] existSiteOnOpp = [select Id, Location__c, Location__r.Unify_Unique_Site_Name__c, Location__r.Unify_Unique_Site_Name_Upper_Case__c from Unify_Opportunity_Location__c where Opportunity__c = :oppId and Location__r.Unify_Unique_Site_Name_Upper_Case__c in :mSiteName2SiteRow.keySet()];
            if(existSiteOnOpp.size() > 0){
                String[] existingSites = new String[]{};
                for(Unify_Opportunity_Location__c ol1 : existSiteOnOpp){
                    existingSites.add(ol1.Location__r.Unify_Unique_Site_Name__c);
                }
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'UNEXPECTED ERROR! Sites not imported. Reason: Sites identified with names: ' + existingSites + ' already exist!'));
                return;
            }
            Unify_Opportunity_Location__c[] ol2ins = new Unify_Opportunity_Location__c[]{};
                         
            for(Location__c l1 : locs){
                mSiteName2SiteRow.remove(l1.Unify_Unique_Site_Name_Upper_Case__c);
                ol2ins.add(new Unify_Opportunity_Location__c(Location__c = l1.Id, Opportunity__c = oppId, Name = l1.Unify_Unique_Site_Name__c));
            }
            
            locs = new Location__c[]{};
            Map<String, Location__c> mKey2Loc = new Map<String, Location__c>();
            Map<String, Contact> mKey2Cont = new Map<String, Contact>();
            Map<String, Contact> mContactKey2Cont = new Map<String, Contact>();
            Map<String, Contact> mKey2InsCont = new Map<String, Contact>();
            Set<String> sEmails = new Set<String>();
            Set<String> sPhones = new Set<String>();
            try{
                for(String s1 : mSiteName2SiteRow.keySet()){
                    Location__c l1 = new Location__c();
                    fieldsVals = mSiteName2SiteRow.get(s1);
                    l1.Unify_Unique_Site_Name__c = fieldsVals[0].trim();
                    if(s1.toUpperCase() == UnifyConfig.CENTRAL_SITE_KEY_NAME.toUpperCase()){
                        l1.Unify_Central_Site__c = true;
                        l1.Unify_Unique_Site_Name__c = UnifyConfig.CENTRAL_SITE_KEY_NAME;
                    }
                    l1.Unify_Validated_Postcode__c = fieldsVals[10];
                    l1.Account__c = opp.AccountId;
                    l1.PAF_Organisation_Name__c = fieldsVals[3];
                    l1.PAF_Building_Number__c = fieldsVals[4];
                    l1.PAF_Building_Name__c = fieldsVals[5];
                    l1.PAF_Sub_Building_Name__c = fieldsVals[6];
                    l1.PAF_Post_Town__c = fieldsVals[9];
                    l1.PAF_County__c = fieldsVals[8];
                    l1.PAF_Thoroughfare_Name__c = fieldsVals[7];
                    mKey2Loc.put(s1, l1);
                    if(!UnifyBatchConfigUpload.isExcelFieldNull(fieldsVals[11]) || !UnifyBatchConfigUpload.isExcelFieldNull(fieldsVals[12])){
                        String contactKey = UnifyBatchConfigUpload.excelValue(fieldsVals[11]) +'-'+ UnifyBatchConfigUpload.excelValue(fieldsVals[12]) +'-'+ UnifyBatchConfigUpload.excelValue(fieldsVals[13]) +'-'+ UnifyBatchConfigUpload.excelValue(fieldsVals[14]);
                        if(mContactKey2Cont.containsKey(contactKey)){
                            mKey2Cont.put(s1,mContactKey2Cont.get(contactKey));
                        } else {
                            Contact c = new Contact();
                            c.FirstName = fieldsVals[11].trim();
                            c.LastName = fieldsVals[12].trim();
                            c.AccountId = opp.AccountId;
                            if(!UnifyBatchConfigUpload.isExcelFieldNull(fieldsVals[13])){
                                c.Phone = fieldsVals[13].trim();        
                                sPhones.add(c.Phone);
                            }
                            if(!UnifyBatchConfigUpload.isExcelFieldNull(fieldsVals[14])){
                                c.Email = fieldsVals[14].trim();
                                sEmails.add(c.Email);
                            }
                            mKey2Cont.put(s1,c);
                            mKey2InsCont.put(s1,c);
                            mContactKey2Cont.put(contactKey,c);
                        }
                    }
                    locs.add(l1);
                }
                if(locs.size() > 0){
                    insert locs;
                }
                Contact[] existingContacts = new Contact[]{};
                if(mKey2InsCont.keySet().size() > 0 && (sEmails.size() > 0 || sPhones.size() > 0)){
                    if(sEmails.size() > 0 && sPhones.size() > 0){
                        existingContacts = [select Id, Email, MobilePhone, Phone, FirstName, LastName from Contact where AccountId = :opp.AccountId and (Email in :sEmails or Phone in :sPhones or MobilePhone in :sPhones)];
                    } else if(sEmails.size() > 0){
                        existingContacts = [select Id, Email, MobilePhone, Phone, FirstName, LastName from Contact where AccountId = :opp.AccountId and (Email in :sEmails)];
                    } else {
                        existingContacts = [select Id, Email, MobilePhone, Phone, FirstName, LastName from Contact where AccountId = :opp.AccountId and (Phone in :sPhones or MobilePhone in :sPhones)];
                    }
                }
                for(String s1: mKey2InsCont.keySet()){
                    Contact cNew = mKey2Cont.get(s1);
                    boolean matched = false;
                    for(Contact cExist : existingContacts){
                        if(cNew.Email != '' && cNew.Email != null && cExist.Email == cNew.Email){
                            mKey2Loc.get(s1).Contact__c = cExist.Id;
                            matched = true;
                            break;
                        } else if(cNew.Phone != '' && cNew.Phone != null && (cExist.MobilePhone == cNew.Phone || cExist.Phone == cNew.Phone)){
                            mKey2Loc.get(s1).Contact__c = cExist.Id;
                            matched = true;
                        }
                    }
                    if(matched){
                        mKey2InsCont.remove(s1);
                    }
                }
                
                if(mKey2InsCont.keySet().size() > 0){
                    insert mKey2InsCont.values();
                    for(string s1 : mKey2Cont.keySet()){
                        mKey2Loc.get(s1).Contact__c = mKey2Cont.get(s1).Id;
                    }
                }
                
                update mKey2Loc.values();
                
                for(Location__c l1 : locs){
                    ol2ins.add(new Unify_Opportunity_Location__c(Location__c = l1.Id, Opportunity__c = oppId, Name = l1.Unify_Unique_Site_Name__c));
                }
                if(ol2ins.size() > 0){
                    insert ol2ins;
                }
                excelContent = '';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'Sites succesfully created. New ' + ol2ins.size() + ' record(s) has been related to the Opportunity.'));
            } catch (Exception e){
                if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Operation failed: Problem with access rights. \n\nPlease check whether Opportunity is locked or please contact with System Administrator.'));
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Unexpected error! Sites not imported. \n\nReason: ' + e.getMessage()));
                }
                Database.rollback(sp);
                return;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'No data for upload found.'));
        }
    }
    
    public void uploadHBs(){
        if(excelContent != '' && excelContent != null){
            string lineDelimiter = UnifyCommonMethods.setLineDelimeter(excelContent);
            String[] lines = excelContent.split(lineDelimiter);
            integer i = 0;
            
            Savepoint sp = Database.setSavepoint();
            
            Unify_Hardware__c hd = new Unify_Hardware__c();
            Unify_Hardware_Item__c[] his = new Unify_Hardware_Item__c[]{};  
            
            Id oppId = ApexPages.currentPage().getParameters().get('id');
            
            for(String s : lines){
                i++;
                
                if(s.contains('\t')){
                    String[] fieldsVals = s.split('\t');
                    if(fieldsVals.size() != 4){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Line number ' + i + ' does not have proper structure. Number of columns should equal 4, found: ' + fieldsVals.size()));
                       Database.rollback(sp);
                       return;  
                    } else {
                        if(i == 1){
                            hd.Name = fieldsVals[0];
                            hd.Bundle_Description__c= fieldsVals[1].trim();
                            hd.Opportunity__c = oppId;
                            hd.RecordTypeId = [select Id from RecordType where SobjectType = 'Unify_Hardware__c' and Name = 'Hardware Bundle Custom'].Id;
                            insert hd;
                        } else if(i > 2){ //skip row no 2 - it contains headers only
                            Unify_Hardware_Item__c hi1 = new Unify_Hardware_Item__c();
                            hi1.Name = fieldsVals[0];
                            hi1.Description__c = fieldsVals[1];
                            hi1.Quantity__c = double.valueOf(fieldsVals[2]);
                            hi1.Unit_Cost__c = UnifyCommonMethods.covertAmount2decimal(fieldsVals[3]);
                            hi1.Unify_Hardware_Bundle__c = hd.Id; 
                            his.add(hi1);
                        }
                    }
                } else {
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Line number ' + i + ' does not have proper structure. TAB characters not found.'));
                    return;
                }
            }
    
            if(his.size() > 0){
                insert his;
                excelContent = '';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'Hardware Bundle succesfully created. You can check it <a href="/' + hd.Id + '" target="_blank">here</a>.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'No data for upload found.'));
            return;
        }
    }
    
    public void uploadConfigs(){        
        if(excelContent != '' && excelContent != null){
            
            Id bundleId = ApexPages.currentPage().getParameters().get('id');
            
            Datetime d = system.now();
            string uniqueKey = bundleId + '_' + string.valueOf(d.year()) + string.valueOf(d.month()) + string.valueOf(d.day()) + string.valueOf(d.hour()) + string.valueOf(d.minute()) + string.valueOf(d.second()) + string.valueOf(d.millisecond()) +  '-' + Math.random()*1000000000;
            
            string lineDelimiter = UnifyCommonMethods.setLineDelimeter(excelContent);
            String[] lines = excelContent.split(lineDelimiter);
            Unify_Upload_Single_Entity__c[] lToIns = new Unify_Upload_Single_Entity__c[]{};
            for(string s1 : lines){
                if(s1 != null && s1 != ''){
                    Unify_Upload_Single_Entity__c nr = new Unify_Upload_Single_Entity__c();
                    nr.Batch_Id__c = uniqueKey;
                    nr.Single_Record__c = s1;
                    nr.Product_Bundle__c = bundleId;
                    lToIns.add(nr); 
                }
            }        
            
            if(lToIns.size() > 0){
                insert lToIns;
            }
            UnifyBatchConfigUpload batch = new UnifyBatchConfigUpload();
            batch.productBundle = bundleId;
            batch.batchId = uniqueKey; 
            batch.submittedBy = System.Userinfo.getUserId();
            ID batchprocessid = Database.executeBatch(batch, 1);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'Request for pillars configuration upload saved. You will be notified via email about it\'s result.'));
            excelContent = '';
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'No data for upload found.'));
        }
    }
}