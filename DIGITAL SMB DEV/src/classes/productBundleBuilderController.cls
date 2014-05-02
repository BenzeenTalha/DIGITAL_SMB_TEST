public with sharing class productBundleBuilderController {
        public cscfgc.API_1.ApiSession apiSession;
    public cscfgc.SessionManager.SessionInfo userSession;
    
        private cscfgc__Product_Bundle__c bundle;
        public List<cConfigRequest> configRequestList {get; set;}
        public String configRequestId {get; set;}
        public Integer numberToClone {get; set;}
        public String configRequestFalseId {get; set;}
        public String timePlanId {get; set;}
        public String checkOptions {get; set;}

        
    // The batch job that is in progress
    public Batch_Job__c batchJob {get; set;}
    public Boolean refreshAvailabilityCheckStatus {get; set;}
    // Manually input into screen and used to display results
    public List<Line_Availability__c> lineAvailabilityRequests {get; set;}
    //
    private Map<String,String> boltOnFieldMap = new Map <String,String>();
    private Map<String,String> boltOnValueMap = new Map <String,String>();
    
    // Controller
    public productBundleBuilderController(ApexPages.StandardController stdController) {
        boltOnFieldMap = new Map<String, String>();
        populateFieldMap();
        this.bundle = (cscfgc__Product_Bundle__c)stdController.getRecord();
        if (this.bundle.Name == null) {
                Datetime d = system.now();
                    String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');
                this.bundle.Name = 'Bundle: '+strDatetime;
                //this.bundle.Name = 'Bundle: '+datetime.now();
                this.bundle.cscfgc__Bundle_Status__c = 'Incomplete';
        }
                // Query the Configuration requests related to this bundle
                queryConfigurationRequests();
    } 
    //
    
    public pageReference setDetailFlagFalse() {
        if (configRequestId != null) {
                for (cConfigRequest configRequestRec : configRequestList) {
                        if (configRequestRec.configRequest.Id == configRequestId) {
                                configRequestRec.detailRendered = False;
                        }
                }
        }
        return null;
    }
    
    public void setDetailFlagTrue() {
        if (configRequestId != null) {
                for (cConfigRequest configRequestRec : configRequestList) {
                        if (configRequestRec.configRequest.Id == configRequestId) {
                                configRequestRec.detailRendered = True;
                        }
                }
        }
    }
    
    //
    // Add new row to the Configuration request list
    public void addNewConfigurationRequest() {
        if (configRequestList == null)
                this.configRequestList = new List<cConfigRequest>();
        cConfigRequest configRequest = new cConfigRequest(new Configuration_Request__c(product_bundle__c = this.bundle.Id));
        this.configRequestList.add(configRequest);
        //
        saveConfigurationRequests();
    }
    
    // Line availability checks have been manually entered
    public PageReference submitRows() {
        lineAvailabilityRequests = new List<Line_Availability__c>();
        for (cConfigRequest configRequestRec : configRequestList) {
                if (configRequestRec.selected && configRequestRec.configRequest.Directory_Number__c != null && 
                        configRequestRec.configRequest.Post_Code__c != null) {
                        lineAvailabilityRequests.add(new Line_Availability__c(Directory_Number__c = configRequestRec.configRequest.Directory_Number__c, 
                                                                                                                                  Post_Code__c = configRequestRec.configRequest.Post_Code__c));
                }
        }
        // Check that the user has entered data
        if (lineAvailabilityRequests == null || lineAvailabilityRequests.size() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Please enter at least one directory number and postcode.'));
                return null;
        }
        Savepoint sp = Database.setSavepoint();
        try {
            //AvailabilityCheckInputProcessor inputProcessor = new AvailabilityCheckInputProcessor();
            //@TODO: Pass check type parameter based on the User Selection - currently set to Line Only
            
            // Bug fix : The input select option was commented out which resulted in null check type where a Line Check was expected
            if(checkOptions==null || checkOptions=='') checkOptions = AvailabilityCheckUtils.TYPE_LINE;
            
            batchJob = AvailabilityCheckInputProcessor.processLineAvailablityArray(lineAvailabilityRequests, AvailabilityCheckUtils.SCREEN_INPUT, checkOptions); //AvailabilityCheckUtils.TYPE_LINE);
            //
            Map<String,String> lineAvailabilityRequestMap = getLineAvailabilityRequestsMap();
            // update the configuration requests with the batch job id
            for(cConfigRequest configRequestRec : configRequestList){
            	if(configRequestRec.configRequest.Directory_Number__c != null){            		
                	// Line Check - DN starts with 44
                	if(configRequestRec.configRequest.Directory_Number__c.startsWith('0') && configRequestRec.configRequest.Line_Availability__r.Type__c=='Line'){
                		configRequestRec.configRequest.Directory_Number__c = '44' + configRequestRec.configRequest.Directory_Number__c.substring(1);
                	}
                	// Broadband Check (EMLC)- DN starts with 0
                	if(configRequestRec.configRequest.Directory_Number__c.startsWith('44') && configRequestRec.configRequest.Line_Availability__r.Type__c=='Broadband'){
                		configRequestRec.configRequest.Directory_Number__c = '0' + configRequestRec.configRequest.Directory_Number__c.substring(2);
                	}
                }
                String dirNumber = configRequestRec.configRequest.Directory_Number__c;
                String postCode  = configRequestRec.configRequest.Post_Code__c;
                if(configRequestRec.selected && dirNumber != null && postCode != null){
                    configRequestRec.configRequest.Availability_Check_Batch_Job__c = batchJob.Id;
                    	if(lineAvailabilityRequestMap.containsKey(dirNumber+'-'+postCode+'-'+batchJob.Id)){
                            configRequestRec.configRequest.Line_Availability__c = lineAvailabilityRequestMap.get(dirNumber+'-'+postCode+'-'+batchJob.Id);
                        }
                }
            }
            //
            saveConfigurationRequests();
            // Requery the Configuration requests
            queryConfigurationRequests();
        } 
        catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            return null;
        }
        // requeryBatchJobAndLineAvailabilities();
        //AvailabilityCheckUtils util = new AvailabilityCheckUtils();
        AvailabilityCheckUtils.processAvailabilityCheck(new List<Id>{batchJob.Id});
        //
        return null;
    }
    
    // Delete selected configuration requests
    public PageReference deleteRows() {
        List<Configuration_Request__c> configRequestListToDelete = new List<Configuration_Request__c>();
        List<Id> productConfigIdListToDelete = new List<Id>();
        for (cConfigRequest configRequestRec : configRequestList) {
                if (configRequestRec.selected) {
                        configRequestListToDelete.add(configRequestRec.configRequest);
                        productConfigIdListToDelete.add(configRequestRec.configRequest.Product_Configuration__c);
                }
        }
        Savepoint sp = Database.setSavepoint();
        try {
                List<cscfgc__Product_Configuration__c> productConfigListToDelete = new List<cscfgc__Product_Configuration__c>();
                if (!productConfigIdListToDelete.isEmpty()) {
                        //
                        productConfigListToDelete = [select Id 
                                                     from cscfgc__Product_Configuration__c 
                                                    where Id in :productConfigIdListToDelete];
                        //
                        delete productConfigListToDelete;
                } 
            delete configRequestListToDelete;
                // Requery the Configuration requests
                queryConfigurationRequests();
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            return null;
        }
        return null;
    }
    
    // Delete selected time Plan
    public PageReference deleteTimePlanRow() {
        Telemarketing_Time_Plan__c timePlan = [select Id from Telemarketing_Time_Plan__c where id = :timePlanId];
        Savepoint sp = Database.setSavepoint();
        try {
            delete timePlan;
                // Requery the Configuration requests
                queryConfigurationRequests();
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            return null;
        }
        return null;
    }
    
    public PageReference save() {
        Savepoint sp = Database.setSavepoint();
        try {
                upsert bundle;
                //
                        saveConfigurationRequests(); 
                } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            return null;
        }
        // ---------------------------------------------------------------
                //
        // Go back to the bundle
        PageReference retPage = new PageReference('/apex/ProductBundleBuilder?id='+bundle.id);
        retPage.setRedirect(true);
        return retPage;
        //return null;  
    }
    
    private void saveConfigurationRequests() {
        List<Configuration_Request__c> configRequestListToSave = new List<Configuration_Request__c>();
        for (cConfigRequest configRequestRec : configRequestList) {
                // Correct the format of the directory number 
                if (configRequestRec.configRequest.Directory_Number__c != null && configRequestRec.configRequest.Directory_Number__c.startsWith('0')) {
                        configRequestRec.configRequest.Directory_Number__c = '44' + configRequestRec.configRequest.Directory_Number__c.substring(1);
                }
                //
                configRequestListToSave.add(configRequestRec.configRequest);
        }
        //
        upsert configRequestListToSave;
    }
    
    // 
    // Query the Configuration requests related to this bundle
    public void queryConfigurationRequests() {
        if (bundle != null) {
                List<Configuration_Request__c> configRequestListRequeried = new List<Configuration_Request__c>();
                configRequestListRequeried = [select Id, Name, Availability_Check_Batch_Job__c, Product_Configuration__c, Number_Of_Requests_To_Clone__c,
                                                                                         Availability_Check_Progress_Indicator__c, Product_Definition__c, Availability_Check_Batch_Job__r.Status__c,
                                                                                         Directory_Number__c, Line_Availability__c, Line_Availability__r.Type__c, Product_Category__c, Product_Name__c,
                                                                                         Provide_Type__c, Product_Type__c, Line_Type__c, Number_of_Lines_ISDN2__c, Porting_Required__c, 
                                                                                         Number_of_Channels__c, 
                                                                                         Number_of_Lines__c, Post_Code__c, Product_Bundle__c, Config_Status__c,
                                                                                         (select Id, Name, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c from Telemarketing_Time_Plans__r)
                                                                                         from Configuration_Request__c 
                                                                                         where Product_bundle__c = :bundle.Id
                                                                                         Order by Name Asc];
                //
                if (configRequestList != null) {
                        configRequestList.clear();
                } else {
                        configRequestList = new List<cConfigRequest>();
                }
                //
                refreshAvailabilityCheckStatus = false;
                for (Configuration_Request__c rec : configRequestListRequeried) {
                        cConfigRequest cConfigReqRec = new cConfigRequest(rec);
                        if (rec.Availability_Check_Batch_Job__r.Status__c != 'Completed' && rec.Availability_Check_Batch_Job__r.Status__c != null) {
                                refreshAvailabilityCheckStatus = true;
                        } else if (!refreshAvailabilityCheckStatus) {
                                refreshAvailabilityCheckStatus = false;
                        }
                        //
                        if (rec.Telemarketing_Time_Plans__r.size() >= 3) {
                                cConfigReqRec.disableAddTimePlan = true;
                        } else {
                                cConfigReqRec.disableAddTimePlan = false;
                        }
                        //
                        configRequestList.add(cConfigReqRec);
                }
                //
            
        }
    }
    
    //
    // Get a Map of line availability requests keyed on the phone number and post code
    private Map<String,String> getLineAvailabilityRequestsMap() {
        Map<String,String> lineAvailabilityRequestMap = new  Map<String,String>();
        for (Line_Availability__c rec : [Select Id, Post_Code__c, Directory_Number__c, batch_Job__c From Line_Availability__c Where Batch_Job__c = :batchJob.Id]) {
                lineAvailabilityRequestMap.put(rec.Directory_Number__c+'-'+rec.Post_Code__c+'-'+rec.batch_Job__c,rec.Id);
        }
        //
        return lineAvailabilityRequestMap;
    }
    
    public Pagereference createConfigurations() {
        cscfgc__Configuration_Offer__c configOffer;
        Pagereference editPage;

        saveConfigurationRequests();
        //
        system.debug('******************>>><<<<configRequestId:'+configRequestId);
        //
        
        Configuration_Request__c configRequest = [select Id, Name, Availability_Check_Batch_Job__c, Product_Configuration__c,
                                                         Availability_Check_Progress_Indicator__c, Product_Definition__c, Number_Of_Requests_To_Clone__c,
                                                         Directory_Number__c, Line_Availability__c, Line_Availability__r.Type__c, Product_Category__c, Product_Name__c,
                                                         Provide_Type__c, Product_Type__c, Line_Type__c, Number_of_Lines_ISDN2__c, Porting_Required__c, 
                                                         Number_of_Channels__c, 
                                                         Number_of_Lines__c, Post_Code__c, Product_Bundle__c, Config_Status__c,
                                                 (select Id, Name, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c from Telemarketing_Time_Plans__r) 
                                          from Configuration_Request__c 
                                          where Id = :configRequestId
                                          limit 1];

            ApexPages.CurrentPage().getParameters().put('retURL', '/' + bundle.id);     

            System.debug(' product name************************************************  '+configRequest.Product_Name__c);
            
            if(configRequest.Product_Name__c == 'SMB Telemarketing Divert Plan'){
                Map<String,String> productMap = getproductMap();

                                // RC: Required to work with package 1.17
                //cscfgc.ProductConfiguratorController prodConfigController = new cscfgc.ProductConfiguratorController();
                                cscfgc.API_1.ApiSession sess = new cscfgc.API_1.ApiSession();
                        cscfgc.ProductConfiguratorController prodConfigController = sess.getController();
                
                prodConfigController.definitionId = productMap.get(configRequest.Product_Name__c);
                        prodConfigController.selectDefinition();
                        cscfgc.ProductConfiguration newProductConfig = prodConfigController.getConfig();
                        //
                        cscfgc.ProductConfiguration relatedConfig;
                        
                        Integer i = 1;
                        newProductConfig.getAttribute('Number of Timeplans').setValue(configRequest.Telemarketing_Time_Plans__r.size()+'');
                        for (Telemarketing_Time_Plan__c timePlan : configRequest.Telemarketing_Time_Plans__r) {
                                // Get the primary related product 
                                String attributeName = 'Timeplan ' + i;
                                ApexPages.CurrentPage().getParameters().put('attributeName', attributeName);
                                prodConfigController.relatedDefinitionId = productMap.get('Telemarketing Timeplan'); 
                                prodConfigController.addRelatedProduct();
                                prodConfigController.selectConfig();
                                cscfgc.Attribute related = newProductConfig.getAttribute(attributeName);
                                //
                                try {
                                        relatedConfig = related.getRelatedProducts().get(0);
                                        //
                                        relatedConfig.getAttribute('Timeplan Name').setValue(timePlan.Name);
                                        if (timePlan.Monday__c != null) {
                                                List<String> timePlanList = timePlan.Monday__c.split('-');
                                                relatedConfig.getAttribute('Monday Opening Time').setValue(timePlanList[0]);
                                                relatedConfig.getAttribute('Monday Closing Time').setValue(timePlanList[1]);
                                        }  
                                        if (timePlan.Tuesday__c != null) {
                                                List<String> timePlanList = timePlan.Tuesday__c.split('-');
                                                relatedConfig.getAttribute('Tuesday Opening Time').setValue(timePlanList[0]);
                                                relatedConfig.getAttribute('Tuesday Closing Time').setValue(timePlanList[1]);
                                        } 
                                        if (timePlan.Wednesday__c != null) {
                                                List<String> timePlanList = timePlan.Wednesday__c.split('-');
                                                relatedConfig.getAttribute('Wednesday Opening Time').setValue(timePlanList[0]);
                                                relatedConfig.getAttribute('Wednesday Closing Time').setValue(timePlanList[1]);
                                        } 
                                        if (timePlan.Thursday__c != null) {
                                                List<String> timePlanList = timePlan.Thursday__c.split('-');
                                                relatedConfig.getAttribute('Thursday Opening Time').setValue(timePlanList[0]);
                                                relatedConfig.getAttribute('Thursday Closing Time').setValue(timePlanList[1]);
                                        } 
                                        if (timePlan.Friday__c != null) {
                                                List<String> timePlanList = timePlan.Friday__c.split('-');
                                                relatedConfig.getAttribute('Friday Opening Time').setValue(timePlanList[0]);
                                                relatedConfig.getAttribute('Friday Closing Time').setValue(timePlanList[1]);
                                        } 
                                        if (timePlan.Saturday__c != null) {
                                                List<String> timePlanList = timePlan.Saturday__c.split('-');
                                                relatedConfig.getAttribute('Saturday Opening Time').setValue(timePlanList[0]);
                                                relatedConfig.getAttribute('Saturday Closing Time').setValue(timePlanList[1]);
                                        } 
                                        if (timePlan.Sunday__c != null) {
                                                List<String> timePlanList = timePlan.Sunday__c.split('-');
                                                relatedConfig.getAttribute('Sunday Opening Time').setValue(timePlanList[0]);
                                                relatedConfig.getAttribute('Sunday Closing Time').setValue(timePlanList[1]);
                                        }
                                } catch(Exception ex) {
                                        
                                }
                                //
                                i++;
                        }
                        
                        prodConfigController.userErrorsWarned = true;
                        prodConfigController.saveAndFinish();
                        //
                        // update the main configuration with the line availability check result
                        if (newProductConfig != null) {
                                cscfgc__Product_Configuration__c mainProdConfig = [select Id, Line_Availability_Check_Result__c, Directory_Number__c 
                                                                                                                                   from cscfgc__Product_Configuration__c 
                                                                                                                                   where id = :newProductConfig.getId() limit 1]; 
                                mainProdConfig.Line_Availability_Check_Result__c = configRequest.Line_Availability__c;
                                mainProdConfig.Directory_Number__c                               = configRequest.Directory_Number__c;
                                update mainProdConfig;
                                //
                                // update the config request with the main config Id
                                configRequest.Product_Configuration__c = newProductConfig.getId();
                                update configRequest;
                                queryConfigurationRequests();
                        }
                //editPage = new Pagereference('/apex/cscfgc__configureProduct?configId='+newProductConfig.getId()+'&retURL=/'+bundle.Id);
            }
            else{
            
                    try{
                                configOffer = [Select c.Name, c.Id, 
                                                                        (Select Name, cscfgc__Parent_Configuration__c, OwnerId 
                                                                                From cscfgc__Product_Configurations__r 
                                                                                where cscfgc__Parent_Configuration__c = '') 
                                                          From cscfgc__Configuration_Offer__c c 
                                                          Where c.Name = :configRequest.Product_Name__c];
                    }
                    catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No offer exists. Please create an offer.'));
                        return null;
                    }
                                                                                                                         
                   Id productConfigId;                                                                                                      
                   List<cscfgc__Product_Configuration__c>  prodConfig = configOffer.cscfgc__Product_Configurations__r;    
                   
                   if(prodConfig.size() > 0){
                        productConfigId = cscfgc.Api_1.cloneConfiguration(prodConfig[0], bundle, null);
                        cscfgc__Product_Configuration__c newConfig = [SELECT ownerId from cscfgc__Product_Configuration__c WHERE Id = :productConfigId];
                        newConfig.ownerId = UserInfo.getUserId();
                        update newConfig;
                        
                   }
                   else
                   {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No product configuration exists. Please create a product configuration for an offer.'));
                        return null;
                   }
                                
                   cscfgc__Product_Configuration__c currConfig = O2OrderHelper.populateConfiguration(productConfigId, configRequest.Line_Availability__c);
                   
                   Id curConfigId = updateBoltOnFieldMap(currConfig.Id, configRequest);
                   try{
                   if(currConfig != null){
                        // update currConfig;
                           
                        //update the config request with the main config Id
                        configRequest.Product_Configuration__c = currConfig.Id;
                        update configRequest;
                        queryConfigurationRequests();
                   }
                   }catch(Exception ex){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                   }
               //apiSession.executeRules();
                   //apiSession.persistConfiguration(true);
                        //editPage = new Pagereference('/apex/cscfgc__configureProduct?configId='+currConfig.Id+'&retURL=/'+bundle.Id);
            }

        //return editPage;
        return null;
    }
    
    public Id updateBoltOnFieldMap(Id curConfigId, Configuration_Request__c configRequest){
        
        cscfgc__Product_Configuration__c relatedConfig;
        
        Line_Availability__c laCheckResult = new Line_Availability__c();
        if (configRequest.Line_Availability__c != null)
            laCheckResult = O2OrderHelper.getlaCheckResults(configRequest.Line_Availability__c); 
       
        try{
        
        relatedConfig = [Select c.cscfgc__Parent_Configuration__c, c.cscfgc__Attribute_Name__c, c.Name, c.Id, 
                                    (Select Name, cscfgc__Product_Configuration__c, cscfgc__Attribute_Definition__c, 
                                    cscfgc__Display_Value__c, cscfgc__Is_Line_Item__c, cscfgc__Price__c, cscfgc__Recurring__c, 
                                    cscfgc__Value__c, cscfgc__is_active__c, cscfgc__Billing_Price__c From cscfgc__Attributes__r) 
                                From cscfgc__Product_Configuration__c c
                                where cscfgc__Parent_Configuration__c = :curConfigId];
        }
        catch(Exception ex){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No attributes on line availability check are set.'));
            System.debug('Error in product bundle builder for related config:::::::   '+ex.getMessage());
            return null;
        }
        List<cscfgc__Attribute__c> relatedAttributeList = relatedConfig.cscfgc__Attributes__r;
        
        Map<String, cscfgc__Attribute__c> attributeMap = new Map<String, cscfgc__Attribute__c>();
        for(cscfgc__Attribute__c attr : relatedAttributeList){
            attributeMap.put(attr.Name, attr);          
        }
        
        // Get the feature mappings
        if(boltOnFieldMap.isEmpty()) populateFieldMap();
        
        // Set the Caller Features Attributes
        if (configRequest.Line_Availability__c != null && relatedConfig != null) {
            String configAttr;
            String configValue;
            for (String fieldName : boltOnFieldMap.keySet()) {
            
                if (boltOnFieldMap.containsKey(fieldName)) configAttr = boltOnFieldMap.get(fieldName);
                else configAttr = null;
                if (boltOnValueMap.containsKey(fieldName)) configValue = boltOnValueMap.get(fieldName);
                else configValue = null;
                
                if (configAttr != null && configAttr != '') {
                    if (fieldName == 'Extra1471__c') {
                        if ((Boolean) laCheckResult.get(fieldName)) { 
                            if(attributeMap.containskey(configAttr))
                                attributeMap.get(configAttr).cscfgc__Value__c = '1471 Call Return';
                        } else {
                            if(attributeMap.containskey(configAttr))
                                attributeMap.get(configAttr).cscfgc__Value__c = 'Bar Use of 1471 Call Return';                           
                        }
                    }
                    /* Apply Override Values first */
                    else if ((boolean)laCheckResult.get(fieldName) && configValue != null & configValue != '') {
                            if(attributeMap.containsKey(configAttr))
                                attributeMap.get(configAttr).cscfgc__Value__c = configValue;
                        }
                    /* All other checkbox values */    
                    else {
                        if ((Boolean) laCheckResult.get(fieldName)){ 
                            if(attributeMap.containskey(configAttr))
                                attributeMap.get(configAttr).cscfgc__Value__c = 'Yes';       
                        }
                    }
                }
            }
        }
        
        
        if(!attributeMap.isEmpty()){
            List<cscfgc__Attribute__c> attrList = attributeMap.values();
            update attrList;                
        }
        
        return curConfigId;
    }
 
   
    public PageReference addTimePlan() {
        //
        saveConfigurationRequests(); 
        //
        List<Telemarketing_Time_Plan__c> timePlanList = new List<Telemarketing_Time_Plan__c>();
        Boolean errorsOccuredFlag = false;
        //
        // Get any existing time plans for this config request
        List<Telemarketing_Time_Plan__c> existingTimePlanList = [select Id, Name, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c 
                                                                                                                         from Telemarketing_Time_Plan__c where Configuration_Request__c = :configRequestId]; 
        //
        for (cConfigRequest cRec : configRequestList) {
                if (cRec.configRequest.Id == configRequestId) {
                        if (cRec.mondayOpenTime == '' &&
                                cRec.tuesdayOpenTime == '' &&
                                cRec.wednesdayOpenTime == '' &&
                                cRec.thursdayOpenTime == '' &&
                                cRec.fridayOpenTime == '' &&
                                cRec.saturdayOpenTime == '' &&
                                cRec.sundayOpenTime == '') {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must populate times for at least one day for a time plan to be valid'));
                                errorsOccuredFlag = true;
                                }
                                //
                                if (cRec.timePlanName == '') {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must populate the time plan name'));
                                errorsOccuredFlag = true;
                                }
                                //
                                if (errorsOccuredFlag) {
                                        return null;
                                } else {
                                //
                                Telemarketing_Time_Plan__c timePlan = new Telemarketing_Time_Plan__c();
                                timePlan.Name = cRec.timePlanName;
                                if (cRec.mondayOpenTime != '')
                                        timePlan.Monday__c = cRec.mondayOpenTime+'-'+cRec.mondayCloseTime;
                                if (cRec.tuesdayOpenTime != '')
                                        timePlan.Tuesday__c = cRec.tuesdayOpenTime+'-'+cRec.tuesdayCloseTime;
                                if (cRec.wednesdayOpenTime != '')
                                        timePlan.Wednesday__c = cRec.wednesdayOpenTime+'-'+cRec.wednesdayCloseTime;
                                if (cRec.thursdayOpenTime != '')
                                        timePlan.Thursday__c = cRec.thursdayOpenTime+'-'+cRec.thursdayCloseTime;
                                if (cRec.fridayOpenTime != '')
                                        timePlan.Friday__c = cRec.fridayOpenTime+'-'+cRec.fridayCloseTime;
                                if (cRec.saturdayOpenTime != '')
                                        timePlan.Saturday__c = cRec.saturdayOpenTime+'-'+cRec.saturdayCloseTime;
                                if (cRec.sundayOpenTime != '')
                                        timePlan.Sunday__c = cRec.sundayOpenTime+'-'+cRec.sundayCloseTime;
                                timePlan.Configuration_Request__c = cRec.configRequest.Id;
                                //
                                timePlanList.add(timePlan);
                                }
                }
        }
        //
        insert timePlanList;
        //
        queryConfigurationRequests();
        //
        return null;
    }
    //
    // clone Configuration request and related product configurations(Is this method deprecated? Cannot see from where it is called.)
    public PageReference cloneConfigurationRequests() {
        //
        saveConfigurationRequests(); 
        system.debug('******************>>><<<<configRequestId:'+configRequestId);
        //
        Configuration_Request__c configRequest = [select Id, Name, Availability_Check_Batch_Job__c, Product_Configuration__c,
                                                         Availability_Check_Progress_Indicator__c, Product_Definition__c, Number_Of_Requests_To_Clone__c,
                                                         Directory_Number__c, Line_Availability__c, Line_Availability__r.Type__c, Product_Category__c, Product_Name__c,
                                                         Provide_Type__c, Product_Type__c, Line_Type__c, Number_of_Lines_ISDN2__c, Porting_Required__c, 
                                                         Number_of_Channels__c, 
                                                         Number_of_Lines__c, Post_Code__c, Product_Bundle__c, Config_Status__c,
                                                 (select Id, Name, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c from Telemarketing_Time_Plans__r) 
                                          from Configuration_Request__c 
                                          where Id = :configRequestId
                                          limit 1];
        //
        List<Configuration_Request__c> configRequestsToCloneList = new List<Configuration_Request__c>();
        for (Integer i = 0; i < configRequest.Number_Of_Requests_To_Clone__c; i++) {
                configRequestsToCloneList.add(configRequest.clone(false,true));
        }
        system.debug('************configRequestsToCloneList.size():'+configRequestsToCloneList.size());
        if (!configRequestsToCloneList.isEmpty()) insert configRequestsToCloneList;
        //
                queryConfigurationRequests();
                //
        return null;
    }
    
        //
        // Loop thorugh the configuration to be copied and all of its children and copy all of them to the specified bundle
        public static void copyConfigAndChildrenToBunlde(string sourceConfigId, 
                                                                                                         string targetBundleId, 
                                                                                                         Integer numberToClone,
                                                                                                         List<Configuration_Request__c> clonedConfigRequestsList) {
                //Get all configs requiring cloning (both parents and children)
                List<cscfgc__Product_Configuration__c> configsToBeClonedList = 
                        [select Id from cscfgc__Product_Configuration__c where Id = :sourceConfigId or cscfgc__Parent_Configuration__c = :sourceConfigId];
                // Get all the config Details
                String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                ', (select '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r) '+
            ' from cscfgc__Product_Configuration__c where Id in '+Utility.convertListToString(configsToBeClonedList);
        //
        List<cscfgc__Product_Configuration__c> allConfigsToBeClonedList = Database.query(queryString);
        // Get a map of cofigs to be cloned keyed by config Id
        Map<String,cscfgc__Product_Configuration__c> configsToBeClonedMap = new Map<String,cscfgc__Product_Configuration__c>();
        for (cscfgc__Product_Configuration__c config : configsToBeClonedList) {
                configsToBeClonedMap.put(config.Id,config);
        }
        //
        List<cscfgc__Product_Configuration__c> newMainClonedConfigList = new List<cscfgc__Product_Configuration__c>();
        for (Integer i = 0; i < numberToClone; i++) {
                // First clone the main source config
                cscfgc__Product_Configuration__c sourceConfig = configsToBeClonedMap.get(sourceConfigId);
                cscfgc__Product_Configuration__c newMainClonedConfig = sourceConfig.clone(false,true);
                newMainClonedConfigList.add(newMainClonedConfig);
        }
        // Insert the new cloned config
        insert newMainClonedConfigList;
        //
        // Clone the associated attributes
        /**for (Integer i = 0; i < numberToClone; i++) {
                List<cscfgc__Attribute__c> newMainClonedAttributes = sourceConfig.cscfgc__Attributes__r.deepClone(false);
                for (cscfgc__Attribute__c att : newMainClonedAttributes) {
                        att.cscfgc__Product_Configuration__c = newMainClonedConfig.Id;
                }
        }
        insert newMainClonedAttributes;
        //
        //-------------
        // Now clone the children
        copyChildConfigsToBunlde(sourceConfig, targetBundleId, newMainClonedConfig, newMainClonedAttributes);
        ******/
        }
        
        //
        // Loop thorugh the child configuration copy all of them to the specified bundle
        private static void copyChildConfigsToBunlde(cscfgc__Product_Configuration__c sourceConfig, 
                                                                                                string targetBundleId, 
                                                                                                cscfgc__Product_Configuration__c newMainClonedConfig, 
                                                                                                List<cscfgc__Attribute__c> newMainClonedAttributes) {
        // Get all the config Details
                String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                ', (select '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r) '+
                ', (select Id from cscfgc__Related_Configurations__r) '+
            ' from cscfgc__Product_Configuration__c where Id in '+Utility.convertListToString(sourceConfig.cscfgc__Related_Configurations__r);
        List<cscfgc__Product_Configuration__c> childConfigsToBeClonedList = Database.query(queryString);
        //
        List<cscfgc__Product_Configuration__c> clonedChildConfigsList = new List<cscfgc__Product_Configuration__c>();
        for (cscfgc__Product_Configuration__c config : childConfigsToBeClonedList) {
                cscfgc__Product_Configuration__c newClonedChildConfig = config.clone(false,true);
                newClonedChildConfig.cscfgc__Product_Bundle__c = targetBundleId;
                newClonedChildConfig.cscfgc__Parent_Configuration__c = newMainClonedConfig.Id;
                clonedChildConfigsList.add(newClonedChildConfig);
        }
        insert clonedChildConfigsList;
        // Get a Map of the old and new child configs
        Map<String,String> oldtoNewConfigMap = new Map<String,String>();
        Integer iLoop = 0;
        for (cscfgc__Product_Configuration__c config : childConfigsToBeClonedList) {
                oldtoNewConfigMap.put(config.Id,clonedChildConfigsList[iLoop].Id);
                iLoop++;
        }
        // Now clone the attributes belonging to the children
        iLoop = 0; // reset the loop counter
        List<List<cscfgc__Attribute__c>> clonedChildAttributeList = new List<List<cscfgc__Attribute__c>>();
        for (cscfgc__Product_Configuration__c config : childConfigsToBeClonedList) {
                List<cscfgc__Attribute__c> newChildClonedAttributeList = config.cscfgc__Attributes__r.deepClone(false);
                for (cscfgc__Attribute__c att : newChildClonedAttributeList) {
                        att.cscfgc__Product_Configuration__c = clonedChildConfigsList[iLoop].Id;
                }
                insert newChildClonedAttributeList;
                //
                clonedChildAttributeList.add(newChildClonedAttributeList);
                iLoop++;
        }
        // We need to update the related product attributes on the parent configuration
        for (cscfgc__Attribute__c att : newMainClonedAttributes) {
                if (oldtoNewConfigMap.containsKey(att.cscfgc__value__c)) att.cscfgc__value__c = oldtoNewConfigMap.get(att.cscfgc__value__c);
        }
        update newMainClonedAttributes;
        // Check if we need to call this method again
        iLoop = 0; // reset the loop counter
        for (cscfgc__Product_Configuration__c config : childConfigsToBeClonedList) {
                if (!config.cscfgc__Related_Configurations__r.isEmpty()) {
                        //
                        //-------------
                        // This child has children - clone them
                        copyChildConfigsToBunlde(config, targetBundleId, clonedChildConfigsList[iLoop], clonedChildAttributeList[iloop]);
                }
                iLoop++;
        }
        }
    
    //@deprecated
    // Get the current lineAvailabilityCheckResult
    /*public static Line_Availability__c getLineAvailabilityCheckResults(String Id) {
        //
        String queryString = null;
        // RAC : Include DDI range data
        //queryString = 'select '+Utility.getSobjectFields('Line_Availability__c')+
        //                        ' from Line_Availability__c where ID = \''+Id+'\'';
        queryString = 'select '+Utility.getSobjectFields('Line_Availability__c') +
                                  ', (select ' + Utility.getSobjectFields('Line_Availability_DDI_Range__c') +
                                  ' from Line_Availability_DDI_Ranges__r)' +
                                  ' from Line_Availability__c where ID = \''+Id+'\'';
        //
        List<Line_Availability__c> lineAvailabilityCheckResultList = Database.query(queryString);
        Line_Availability__c lineAvailabilityCheckResult = new Line_Availability__c();
        //
        for (Line_Availability__c rec : lineAvailabilityCheckResultList) {
            lineAvailabilityCheckResult = rec;
        }
        return lineAvailabilityCheckResult;
    }*/

    /* RC : NOT YET REQUIRED, nested subquery used instead
    // Get the corresponding LineAvailability child data
    // Returns list of Sobjects of the Object type named in the objectName
    public static List<SObject> getLineAvailabilityCheckResultChildData(String laId, String objectName) {
        
        // @TODO: Put some validation in that only valid object names are passed
        List<SObject> resultList;
        
                String queryString = null;
                queryString = 'SELECT '+Utility.getSobjectFields(objectName) + ' FROM ' + objectName +
                                          ' WHERE Line_Availability__c = \'' + laId + '\''; 
                
                resultList = Database.query(queryString);                                       
        
        return resultList;
    }
        */
    
    //
    // Get product Map keyed by product name
    private Map<String,String> getproductMap() {
        List<cscfgc__Product_Definition__c> productDefList = [select Id, Name from cscfgc__Product_Definition__c];
        //
        Map<String,String> productMap = new Map<String,String>();
        for (cscfgc__Product_Definition__c prod : productDefList) {
                productMap.put(prod.Name,prod.Id);
        }
        //
        return productMap;
    }
    
    //
    // Get a list of Hours
    public List<SelectOption> getHours() { 
        List<SelectOption> options = new List<SelectOption>();
        for (Integer i = 0; i<24; i++) {
                if (i < 10) {
                        options.add(new SelectOption('0'+i,'0'+i));
                } else {
                        options.add(new SelectOption(''+i,''+i));
                }
        } 
        return options;
        }
    
    //
    // Get a list of Hours
    public List<SelectOption> getMinutes() { 
        List<SelectOption> options = new List<SelectOption>();
        for (Integer i = 0; i<60; i++) {
                if (i < 10) {
                        options.add(new SelectOption('0'+i,'0'+i));
                } else {
                        options.add(new SelectOption(''+i,''+i));
                }
        } 
        return options;
        }
        
    //
    /* 
       This is our wrapper/container class. The wrapper class contains both the standard salesforce 
       object Configuration_Request__c and a Boolean value 
    */
    public class cConfigRequest {
        public Configuration_Request__c configRequest {get; set;}
        public Boolean selected {get; set;}
        public Boolean detailRendered {get; set;}
            // Time Plan Variables
            public String timePlanName {get; set;}
            public String mondayOpenTime {get; set;}
            public String mondayCloseTime {get; set;}
            public String tuesdayOpenTime {get; set;}
            public String tuesdayCloseTime {get; set;}
            public String wednesdayOpenTime {get; set;}
            public String wednesdayCloseTime {get; set;}
            public String thursdayOpenTime {get; set;}
            public String thursdayCloseTime {get; set;}
            public String fridayOpenTime {get; set;}
            public String fridayCloseTime {get; set;}
            public String saturdayOpenTime {get; set;}
            public String saturdayCloseTime {get; set;}
            public String sundayOpenTime {get; set;}
            public String sundayCloseTime {get; set;}
            //
            public Boolean disableAddTimePlan {get; set;}
            public Integer numberToClone {get; set;}
        //
        /* 
           This is the contructor method. When we create a new cConfigRequest object we pass an 
           Configuration_Request__c that is set to the attachment property. We also set the selected value to false
        */
        public cConfigRequest(Configuration_Request__c a) {
            configRequest = a;
            selected = false;
            detailRendered = false;
            timePlanName = null;
                    mondayOpenTime = null;
                    mondayCloseTime = null;
                    tuesdayOpenTime = null;
                    tuesdayCloseTime = null;
                    wednesdayOpenTime = null;
                    wednesdayCloseTime = null;
                    thursdayOpenTime = null;
                    thursdayCloseTime  = null;
                    fridayOpenTime = null;
                    fridayCloseTime = null;
                    saturdayOpenTime = null;
                    saturdayCloseTime = null;
                    sundayOpenTime  = null;
                    sundayCloseTime = null;
        }
    }
    
    private void populateFieldMap() {
    
        List<LineAvailabilityTransformationMap__c> latms;
        latms = LineAvailabilityTransformationMap__c.getall().values();

        for(LineAvailabilityTransformationMap__c latm: latms) {
            boltOnFieldMap.put(latm.field_name__c, latm.Configurator_Field_Name__c);
            boltOnValueMap.put(latm.field_name__c, latm.Override_Value__c);
          }    
    }
    
}