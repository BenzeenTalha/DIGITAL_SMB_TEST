public with sharing class ProductBundleBuilderAsyncController {

        //#
        //# Consts lifted from the Batch Job Type__c picklist
        //# 
        private static final string BATCH_CHECKTYPE_LINE = 'Line';
        private static final string BATCH_CHECKTYPE_BROADBAND = 'Broadband';
        private static final string BATCH_CHECKTYPE_BOTH = 'Line&Broadband';
        private static final string PROVIDE_TYPE_NEW = 'New Provide';
        private static final string PROVIDE_TYPE_TRANSFER = 'Transfer';
        private static final string PROVIDE_TYPE_UNKNOWN = 'Determined once product is created';
        private static final string LINE_CHECK_WORKING = 'working';
        private static final string LINE_CHECK_PAYPHONE = 'payphone';
        private static final string CONFIG_PENDING_VALIDATION = 'Pending Validation';
        
        private map<string,List<AddressCheckController.Address>> pafResultMap = new map<string,List<AddressCheckController.Address>>();     
        private static map<string, List<Configuration_Request_Rule__c>> ConfigRequestRulesMap;
        
        public static ProductBundleBuilderSettings settings;
        public cscfgc.API_1.ApiSession apiSession;
        public cscfgc.SessionManager.SessionInfo userSession;
    
        public transient string tPostCode {get; set;}
        public transient string tTelNo {get; set;}
        public transient string tRowId {get; set;}
        public transient string csvPasteText {get;set;}
    
        private cscfgc__Product_Bundle__c bundle;
        public List<cConfigRequest> configRequestList {get; set;}
        public static String configRequestId {get; set;}
        public static AddressCheckController.Address configAddress {get;set;}
        
        public Integer numberToClone {get; set;}
        public String configRequestFalseId {get; set;}
        public String timePlanId {get; set;}
        public String checkOptions {get; set;}


        
    // The batch job that is in progress
    public Batch_Job__c batchJob {get; set;}
    public Boolean refreshAvailabilityCheckStatus {get; set;}
    // Manually input into screen and used to display results
    public map<string,List<Line_Availability__c>> lineAvailabilityRequestsMap {get; set;}
    public List<Line_Availability__c> lineAvailabilityRequests {get; set;}
    //
    private Map<String,String> boltOnFieldMap = new Map <String,String>();
    private Map<String,String> boltOnValueMap = new Map <String,String>();
    
    public List<SelectOption> getFixedProductCategories() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','- None -'));
        options.add(new SelectOption('SMB Fixed Line','SMB Fixed Line'));
        options.add(new SelectOption('Enterprise Fixed Line','Enterprise Fixed Line'));
        options.add(new SelectOption('BE','BE'));
//        options.add(new SelectOption('',''));
        return options;
    }
    public List<SelectOption> getMobileProductCategories() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','- None -'));
        options.add(new SelectOption('Business Mobile','Business Mobile'));
        return options;
    }
    
    
    //##################################################################################
    //# CONSTRUCTOR
    // Controller
    public ProductBundleBuilderAsyncController(ApexPages.StandardController stdController) {
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
            refreshPafGlobalPafMap();
            refreshConfigRequestPafDetails();
                        
    }       
    
    
    //#
    //# Update the global PAF map
    //#
    public void refreshPafGlobalPafMap()
    {
        
            //#
            //# Do PAF lookups where an address has not already been selected.
            //# 
            list<string> lstPostCodes = new list<string>();
                        
            System.Debug('################# REFRESHING PAF MAP');
            
            if (this.configrequestList != null && this.configrequestList.Size() > 0)            
            {
                System.Debug('################# REFRESHING IN THE LIST');
                for (cConfigrequest cr : this.configrequestList)
                {
                    System.Debug('################# REFRESHING IN THE LIST' + cr.Configrequest.Post_Code__c  + ' -- ' + cr.Configrequest.Post_Code__c);
                                        
                    if (cr.Configrequest.Post_Code__c == null || cr.Configrequest.Post_Code__c == '')
                        continue; 
                    
                    string strPostCode = cr.Configrequest.Post_Code__c;
                    if (cr.Configrequest.Product_configuration__c == null )
                    {
                        if (! pafResultMap.containsKey(strPostCode) && pafResultMap.keyset().Size() < getSettings().MaxNoTransactionPAFCalls )
                                pafResultMap.put(strPostCode, findAddresses(null, null, strPostCode));
                    }
                }
            }
    }
    //
    // refresh Paf details
    //
    private void refreshConfigRequestPafDetails()
    {
        refreshConfigRequestPafDetails(this.configrequestList);
    }
    
    private void refreshConfigRequestPafDetails(cConfigRequest[] crList)
    {
            //#
            //# Do PAF lookups where an address has not already been selected.
            //# 
            list<string> lstPostCodes = new list<string>();
             
            
            System.Debug('################# REFRESHING PAF Entries FOR CR');
            
            if (crList != null && crList.Size() > 0)            
            {
                for (cConfigrequest cr : crList)
                {
                    if (cr.Configrequest.Post_Code__c == null || cr.Configrequest.Post_Code__c == '')
                        continue; 
                    
                    string strPostCode = cr.Configrequest.Post_Code__c;
                    if (cr.Configrequest.Product_configuration__c == null )
                    {
                        if (pafResultMap.containsKey(strPostCode))
                            cr.pafAddresses = pafResultMap.get(strPostCode);
                    }   
                    else
                    {
                        System.Debug('################# DID NOT CALL PAF AS CONFIG IS NOT NULL');
                    }
                }
                
            }
        
    }
    

    //#
    //# Build line check cache
    //#
    private void refreshLineCheckDetails()
    {
        
        list<string> lstEncodedkeys = new list<string>();
        map<string,Map<string, Line_Availability__c>> existingLineAvailabilityChecksMap;
        
        for (cConfigrequest cr : this.configRequestList)
        {
            //if (cr.ConfigRequest.Directory_number__c != null && cr.ConfigRequest.Post_code__c != null )
            if (cr.ConfigRequest.Directory_number__c != null || cr.ConfigRequest.Post_Code__c != null)
                lstEncodedKeys.add(encodeTelNoAndPostCodeKey(cr.ConfigRequest.Directory_number__c,cr.ConfigRequest.Post_code__c));
        }
        
        existingLineAvailabilityChecksMap  = getExistingLineAvailabilityChecksMap(lstEncodedKeys,getSettings().NumDaysLineCheckToReuse);
    
        for (cConfigrequest cr : this.configRequestList)
        {
            if (cr.ConfigRequest.Directory_number__c != null || cr.ConfigRequest.POst_Code__c != null ) // && cr.ConfigRequest.Post_code__c != null )
            {
                string encodedKey = encodeTelNoAndPostCodeKey(cr.ConfigRequest.Directory_number__c,cr.ConfigRequest.Post_code__c);
            
                if (existingLineAvailabilityChecksMap.containsKey(encodedKey))
                        cr.lineChecks = existingLineAvailabilityChecksMap.get(encodedKey); 
                else
                    cr.lineChecks = new map<string,Line_Availability__c>(); 
            }   
        }
        
        
    
    
    
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
        addMultipleConfigurationRequests(1,true);
    }
    
    //##################################################################################
    //# NEW - CPS
    //# Functions to support the addition of multiple items to the grid.
    //#
    /*
    public void setUpInitialConfigurationrequests() {
        if (configRequestList == null || configRequestList.size() == 0)             
            addMultipleConfigurationRequests(5,false);
    }
    */

    //##################################################################################
    //# NEW - CPS
    //# Functions to support the addition of multiple items to the grid.
    //#
    public void addMoreConfigurationRequests() {
        addMultipleConfigurationRequests(5,true);
    }
    
    //##################################################################################
    //# NEW - CPS
    //# Functions to support the addition of multiple items to the grid.
    //#
    public void addMultipleConfigurationRequests(integer noToAdd, boolean persist ) {
        if (configRequestList == null)
                this.configRequestList = new List<cConfigRequest>();
        
        refreshPafGlobalPafMap();        
        List<cConfigRequest> newRows = new  List<cConfigRequest>(); 
        
        for (integer iLoop = 0 ; iLoop < noToAdd ;  iLoop++)
        {
            cConfigRequest configRequest = new cConfigRequest(new Configuration_Request__c(product_bundle__c = this.bundle.Id));        
            newRows.add(configRequest);
            this.configRequestList.add(configRequest);
        }
        //
        if (persist)
        {                       
            saveConfigurationRequests(this.configRequestList);
            queryConfigurationRequests();           
        }    
    }   

    
    
    //#######################################################################
    //# ORIGINAL Batch Line check thingy.
    //#
    // Line availability checks have been manually entered
    /*
    public PageReference submitRows() {
        lineAvailabilityRequests = new List<Line_Availability__c>();
        for (cConfigRequest configRequestRec : configRequestList) {
                // if (configRequestRec.selected && configRequestRec.configRequest.Directory_Number__c != null &&
                if ( configRequestRec.configRequest.Directory_Number__c != null && 
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
            batchJob = AvailabilityCheckInputProcessor.processLineAvailablityArray(lineAvailabilityRequests, AvailabilityCheckUtils.SCREEN_INPUT, checkOptions); //AvailabilityCheckUtils.TYPE_LINE);
            //
            Map<String,String> lineAvailabilityRequestMap = getLineAvailabilityRequestsMap();
            // update the configuration requests with the batch job id
            for (cConfigRequest configRequestRec : configRequestList) {
                        if (configRequestRec.configRequest.Directory_Number__c != null && configRequestRec.configRequest.Directory_Number__c.startsWith('0')) {
                                        configRequestRec.configRequest.Directory_Number__c = '44' + configRequestRec.configRequest.Directory_Number__c.substring(1);
                                }
                                //
                String dirNumber = configRequestRec.configRequest.Directory_Number__c;
                String postCode  = configRequestRec.configRequest.Post_Code__c;
                        //if (configRequestRec.selected && dirNumber != null && postCode != null) {
                        if (dirNumber != null && postCode != null) {
                                configRequestRec.configRequest.Availability_Check_Batch_Job__c = batchJob.Id;
                                //
                                if (lineAvailabilityRequestMap.containsKey(dirNumber+'-'+postCode+'-'+batchJob.Id)) {
                                        configRequestRec.configRequest.Line_Availability__c = lineAvailabilityRequestMap.get(dirNumber+'-'+postCode+'-'+batchJob.Id);
                                }
                        }
                }
                //
                saveConfigurationRequests();
                // Requery the Configuration requests
                queryConfigurationRequests();
        } catch (Exception e) {
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
    */
    
    
    //############################################################################
    //# DELETE ROWS
    //#
    // Delete selected configuration requests
    public PageReference deleteRows() {
        List<Configuration_Request__c> configRequestListToDelete = new List<Configuration_Request__c>();
        List<string> LocationIdListToDelete = new List<string>();
        List<string> productConfigIdListToDelete = new List<string>();
        List<cConfigrequest> CRsToKeep = new List<cConfigrequest>();
        
        //#
        //# Callout to PAF BEFORE any saves otherwise callouts are forbidden (!)
        //#
        refreshPafGlobalPafMap();
        SaveConfigurationRequests(this.configRequestList);
        
        Savepoint sp = Database.setSavepoint();
        try {
                
               for (cConfigRequest configRequestRec : configRequestList) {
                    if (configRequestRec.selected) 
                    {
                        configRequestListToDelete.add(configRequestRec.configRequest);
                    
                        
                        if (configRequestRec.configRequest.Product_Configuration__c != null)
                        {
                            system.debug(LoggingLevel.Info,'##################### DELETING Prod Config:' + configRequestRec.configRequest.Product_Configuration__c);
                            productConfigIdListToDelete.add(configRequestRec.configRequest.Product_Configuration__c);
                            //if (configRequestRec.configRequest.Location__c != null)
                            //  LocationIdListToDelete.add(configRequestRec.configRequest.Location__c);
                        }
                    }
                    else
                    {
                        CRsToKeep.add(configRequestRec);
                    }
                }
                
                
                //#
                //# Delete any configs that were created
                //#
                if (!productConfigIdListToDelete.isEmpty()) {
                    //
                    List<cscfgc__Product_Configuration__c>  productConfigListToDelete = 
                                                 [select Id 
                                                 from cscfgc__Product_Configuration__c 
                                                where Id in :productConfigIdListToDelete];
                    //
                    delete productConfigListToDelete;
                }
                //#
                //# Delete any saved location from PAF lookup.
                //#
               
                //#if (!LocationIdListToDelete.isEmpty())
                //#{
                    List<Location__c> locationListToDelete 
                                                = [Select Id from Location__c 
                                                 where configuration_request__c  in :configRequestListToDelete];
                    delete locationListToDelete;
                //#}
               
                //#
                //# delete the config request rows
                //#
                delete configRequestListToDelete;
                
                
                //#
                //# Rather than re-querying, just remove the lines that we don't need.
                //#
                // Requery the Configuration requests
                this.configRequestList = null;
                queryConfigurationRequests();               
                //# DON'T REQUERY - JUST REMOVE THEM FROM THE LIST!
                //this.configRequestList = CRsToKeep;
            
        
        } catch (Exception e) {
            Database.rollback(sp);
            //throw e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            return null;
        }
        return null;
    }
    
    
    //############################################################################
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
    
    
    //############################################################################
    //# SAVE BUNDLE
    //#
    public PageReference save() {
        Savepoint sp = Database.setSavepoint();
        try {
                boolean isNew = (bundle.id == null); 
                
                    
                    
                upsert bundle;
                //
                //if (isNew) 
                //  addMoreConfigurationRequests();
                //else
                    saveConfigurationRequests(this.configRequestList);
                    
                     
                } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            return null;
        }
        // ---------------------------------------------------------------
                //
        // Go back to the bundle
        PageReference retPage = new PageReference('/apex/ProductBundleBuilderAsync?id='+bundle.id);
        retPage.setRedirect(true);
        return retPage;
        //return null;  
    }
    
    
    //#########################################################################################
    //#
    //#  SAVE 1 CONFIG REQUEST
    //#
    private void saveConfigurationRequest(cConfigRequest configRequestRow) 
    {
                

        cConfigRequest[] crs = new cConfigRequest[] {configRequestRow}; 
        saveConfigurationRequests(crs);
        
    }


    //#########################################################################################
    //#
    //# Revised version to save multiples - list of items to save is now passed in.
    //#     
    private void saveConfigurationRequests(List<cConfigRequest> configRequestList) {
        List<Configuration_Request__c> configRequestListToSave = new List<Configuration_Request__c>();
        for (cConfigRequest configRequestRec : configRequestList) {


                //#
                //# if they haven't selected anything then move on.
                //#
                /*
                if (configRequestRec.configRequest.Directory_Number__c == null &&
                    configRequestRec.configRequest.Post_Code__c == null &&
                    configRequestRec.configrequest.Product_Name__c == null)
                    continue;
                */
                //#
                //# Store the chosen paf record
                //#     
                if (configRequestRec.Configrequest.id == null)
                    insert configRequestRec.Configrequest;
                
                
                if (configRequestRec.addressIndex != null )
                {       
                system.debug('configRequestRec: '+configRequestRec);
                system.debug('configRequestRec.pafAddresses.size(): '+configRequestRec.pafAddresses.size());
//                    AddressCheckController.Address chosenAddress = configRequestRec.pafAddresses[configRequestRec.addressIndex];
//                    if (chosenAddress != null)

                    if (configRequestRec.pafAddresses.size() > 0)
                    {
                        AddressCheckController.Address chosenAddress = configRequestRec.pafAddresses[configRequestRec.addressIndex];

                        configRequestRec.Configrequest.PAF_Select_Option_Text__c =   buildOptionTextFromPafEntry(chosenAddress);
                        Location__c location = createLocationFromAddress(configRequestRec,chosenAddress,'Installation');                    
                    }
                
                }


                // Correct the format of the directory number 
                if (configRequestRec.configRequest.Directory_Number__c != null && configRequestRec.configRequest.Directory_Number__c.startsWith('0')) {
                        configRequestRec.configRequest.Directory_Number__c = '44' + configRequestRec.configRequest.Directory_Number__c.substring(1);
                }


                if (configRequestRec.configRequest.Directory_Number__c == null || configRequestRec.configRequest.Directory_Number__c == '')
                {
                    configRequestRec.configRequest.Provide_Type__c = PROVIDE_TYPE_NEW;
                    //#
                    //# Don't Do this ! It breaks broadband line checks that have no Directory no!
                    //#
                    //configRequestRec.configRequest.Line_Availability__c = null;
                    //configRequestRec.configRequest.Line_Availability__r = null;
                }
                else
                {                  
                    //#
                    //# Get product filter rule and provide type
                    //#
                    Configuration_Request_Rule__c crr = getMatchingProductRule(configRequestRec);
                    if (crr != null)
                    {
                        configRequestRec.configRequest.Configuration_Request_Rule__c = crr.id;
                        configRequestRec.configRequest.Provide_Type__c = crr.Default_Provide_Type__c; 
                    }
                }
                
                
                
                configRequestListToSave.add(configRequestRec.configRequest);
        }
        //
        upsert configRequestListToSave;
    }
    
    
        
    
    //##############################################################################################
    //# REFRESH ONE CONFIG REQUEST
    //#
    public void queryConfigurationRequest(cConfigRequest cr) 
    {
            Configuration_Request__c configRequestItem = getConfigRequestsByIds(new string[]{cr.Configrequest.Id})[0];
            cr.Configrequest = configRequestItem;
            refreshConfigRequestPafDetails(new cConfigRequest[]{cr});
            
        
                        
    }       
    
    
    //##############################################################################################
    //# REFRESH ALL CONFIG REQUESTS
    //#
    public void queryConfigurationRequests() {
        if (bundle == null) 
            return ;
            
            Map<Id,Configuration_Request__c> configRequestListRequeriedMap = new Map<Id, Configuration_Request__c>();
            Map<id,Configuration_Request__c> crIdMap = new Map<id,Configuration_Request__c>([select Id from Configuration_Request__c where Product_bundle__c != null AND Product_bundle__c = :bundle.Id]);
            list<Id> crIds = new list<id>();
            crIds.addAll(crIdMap.keySet());
            
            Configuration_Request__c[] sortedConfigrequestList = getConfigRequestsByIds(crIds);
            
            //#
            //# need the map later;
            //#
            for (Configuration_Request__c cr : sortedConfigrequestList)
                configRequestListRequeriedMap.put(cr.id,cr);     
            
            
                        
            if (configRequestList == null)
            {
                //#
                //# FIRST TIME INm so build the CRs - Sort them by something meaningful!
                //#
                configRequestList = new List<cConfigRequest>();
                
                for (Configuration_Request__c rec : sortedConfigrequestList) 
                {
                    cConfigRequest cConfigReqRec = new cConfigRequest(rec);
                    configRequestList.add(cConfigReqRec);                    
                }
            }
            else
            {   
                //#
                //# Refreshing items already in the screen
                //#                       
                for (cConfigRequest cr : this.configRequestList)
                { 
                    if (cr.configRequest != null && cr.configRequest.id != null)
                    {
                        Configuration_Request__c latestReq =  configRequestListRequeriedMap.get(cr.configRequest.id);                                                   
                        cr.ConfigRequest = latestReq;           
                    }
                }        
        
            }
            
            refreshConfigRequestPafDetails();
            refreshLineCheckDetails();
            
            
            
    }
    
 

    private static  Configuration_Request__c[] getConfigRequestsByIds(list<id> crIds)
    {
        
            return                                                              [select Id, Name, Availability_Check_Batch_Job__c,                       
                                                                                                 Product_Configuration__c, 
                                                                                                 Product_Configuration__r.cscfgc__Configuration_Status__c,
                                                                                                 Number_Of_Requests_To_Clone__c,
                                                                                                 Availability_Check_Progress_Indicator__c, 
                                                                                                 Product_Definition__c, 
                                                                                                 Availability_Check_Batch_Job__r.Status__c,
                                                                                                 Directory_Number__c, 
                                                                                                 Has_Line_Check_Error__c,
                                                                                                 Line_Check_Error_Message__c,
                                                                                                 PAF_Select_Option_Text__c,
                                                                                                 Line_Availability__c, 
                                                                                                 Line_Availability__r.Name,
                                                                                                 Line_Availability__r.Directory_Number__c,
                                                                                                 Line_Availability__r.Post_Code__c,
                                                                                                 Line_Availability__r.Status_Indicator__c,
                                                                                                 Line_Availability__r.External_Description__c,
                                                                                                 Line_Availability__r.Number_of_Lines__c,
                                                                                                 Line_Availability__r.Number_of_Channels__c,
                                                                                                 Line_Availability__r.Line_Type__c,
                                                                                                 Line_Availability__r.InstType__c,
                                                                                                 Line_Availability__r.CareLvl__c,
                                                                                                 Line_availability__r.Incompatible_Services__c,
                                                                                                 Line_availability__r.Features__c,
                                                                                                 Line_availability__r.Service_Type__c,
                                                                                                 Line_availability__r.LLU_or_IPS_available__c,
                                                                                                 Line_availability__r.Reason_code_short_text__c,
                                                                                                 Line_availability__r.productList__c,
                                                                                                 Line_availability__r.predictedDownloadSpeed__c,
                                                                                                 Line_availability__r.Type__c, 
                                                                                                 Line_availability__r.accessLineStatus__c,
                                                                                                 Line_availability__r.TotOrds__c,
                                                                                                 Line_availability__r.PayphType__c,                                                                                             
                                                                                                 Configuration_Request_Rule__c,
                                                                                                 Configuration_Request_Rule__r.Default_Provide_Type__c,
                                                                                                 Configuration_Request_Rule__r.Valid_Products__c,
                                                                                                 Product_Category__c, Product_Name__c,
                                                                                                 Provide_Type__c, Product_Type__c, Line_Type__c, Number_of_Lines_ISDN2__c, Porting_Required__c, 
                                                                                                 Number_of_Channels__c, 
                                                                                                 Number_of_Lines__c, 
                                                                                                 Post_Code__c, 
                                                                                                 Product_Bundle__c, 
                                                                                                 Config_Status__c, 
                                                                                                 ( Select 
                                                                                                    Id,
                                                                                                    PAF_Building_Name__c,
                                                                                                    PAF_Building_Number__c,
                                                                                                    Street__c,
                                                                                                    PAF_County__c,
                                                                                                    Locality__c,
                                                                                                    PAF_Organisation_Name__c,
                                                                                                    PAF_PO_Box_Number__c,
                                                                                                    PAF_Postcode__c,
                                                                                                    PAF_Post_Town__c
                                                                                                 From Locations__r order by Name desc LIMIT 1),                                                                                              
                                                                                                 (select Id, Name, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c from Telemarketing_Time_Plans__r)
                                                                                                 from Configuration_Request__c 
                                                                                                 where Id in  :crIds
                                                                                                 Order by Name];
            
        
        
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
    
    public void createConfigurations(cConfigRequest cr, AddressCheckController.Address chosenAddress) 
    {
        
        cscfgc__Configuration_Offer__c configOffer;
        Pagereference editPage;
        
        System.debug('##################### ENTERING CREATE CONFIGURATIONS');
        
        //#
        //# Done this before we get here in prepareOneRow
        //#
        //System.debug('##################### SAVE CONFIGS');        
        //saveConfigurationRequest(cr);
        //        
        
        
        Configuration_Request__c configRequest = getConfigRequestsByIds(new Id[]{cr.configrequest.Id})[0];
     
        Savepoint sp = Database.setSavepoint();
        
        try
        {
     
            //ApexPages.CurrentPage().getParameters().put('retURL', '/' + bundle.id);     

            System.debug(' ########## product name*********************  '+configRequest.Product_Name__c);

                        
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
                                ValidateConfigAsync(configRequest.Product_Configuration__c);
                                queryConfigurationRequest(cr);
                        }
                //editPage = new Pagereference('/apex/cscfgc__configureProduct?configId='+newProductConfig.getId()+'&retURL=/'+bundle.Id);
            } //###### END OF DIVERT PLAN ? (WHY IS THIS USING THE API AND EVERYTHING ELSE USING SOBJECTS?)
            else{
            
                System.debug('##################### NOT TELEMKTING');
            
                    try{
                            System.debug('##################### GETTING OFFER');
                
                                configOffer = [Select c.Name, c.Id, 
                                                                        (Select Name, cscfgc__Parent_Configuration__c, OwnerId  
                                                                                From cscfgc__Product_Configurations__r 
                                                                                where cscfgc__Parent_Configuration__c = '') 
                                                          From cscfgc__Configuration_Offer__c c 
                                                          Where c.Name = :configRequest.Product_Name__c LIMIT 1];
                    }
                    catch(Exception e){
                        System.debug('##################### PROBLEM GETTING OFFER: ' + e);
                        throw new ProductBundleBuilderException('No offer exists. Please create an offer.');
                        return; //null;
                    }
                                                                                                                         
                   Id productConfigId;                                                                                                      
                   List<cscfgc__Product_Configuration__c>  prodConfig = configOffer.cscfgc__Product_Configurations__r;    
                   
                   if(prodConfig.size() > 0){
                   		try{
                   			productConfigId = cscfgc.Api_1.cloneConfiguration(prodConfig[0], bundle, null);
                   		}
                        catch(Exception e){
                        	System.debug('##################### PROBLEM CLONING OFFER: ' + e);
                        	throw new ProductBundleBuilderException('Oops! failed creating the new product.');
                        	return; //null;
                    	}	
                        System.debug('##################### cloned configuration succesfully');
                        cscfgc__Product_Configuration__c newConfig = [SELECT ownerId from cscfgc__Product_Configuration__c WHERE Id = :productConfigId];
                        newConfig.ownerId = UserInfo.getUserId();
                        update newConfig;
                        
                   }
                   else
                   {
                        System.debug('##################### PROBLEM GETTING CONFIG FOR OFFER (Config Size = 0)');
                        Throw new productBundleBuilderException('No product configuration exists. Please create a product configuration for an offer.');
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No product configuration exists. Please create a product configuration for an offer.'));
                        return ;// null;
                   }
                                
                    //#
                    //# Populate the config with values from the PAF lookup AFTER
                    //# all the line stuff has been done,
                    //#
                    
                    System.debug('##################### ABOUT TO CALL ORDER HELPER: ');
                    
                    cscfgc__Product_Configuration__c currConfig = O2OrderHelper.populateConfiguration(productConfigId, configRequest.Line_Availability__c, cr.Configrequest.Provide_Type__c);                   
                    
                    System.debug('##################### ABOUT POPULATE ADDRESS: ');
                    if (chosenAddress != null)
                        currConfig = O2OrderHelper.populateConfigurationAddress(currConfig.Id, chosenAddress);
                    
                    if (configRequest.Line_Availability__c != null)
                        currConfig.Line_Availability_Check_Result__c = configRequest.Line_Availability__c; 

                    if (configRequest.Directory_Number__c != null)
                        currConfig.Directory_Number__c = configRequest.Directory_Number__c; 

                
                                       
                   Id curConfigId = updateBoltOnFieldMap(currConfig.Id, configRequest);
                   try{
                
                    System.debug('##################### UPDATING CONFIG');
                   if(currConfig != null){
                        currConfig.cscfgc__Configuration_Status__c = CONFIG_PENDING_VALIDATION;
                        update currConfig;
                           
                        //update the config request with the main config Id
                        configRequest.Product_Configuration__c = currConfig.Id;
                        update configRequest;
                        
                        
                        //#
                        //# got to validate the overall configuration and execute the rules
                        //#
                        //# All moved into a Future method:
                        System.debug('##################### CALLING ASYNC VALIDTE ');
                        ValidateConfigAsync(currConfig.Id);
                        
                        //#
                        //# Now re-query so that the status forumula fields are updated.
                        //#
                        System.debug('##################### RE-QUERYING');
                        queryConfigurationRequest(cr);
                   
                   }
               }catch(Exception ex){                    
                    System.debug('##################### ERROR!' + ex);
                    throw ex;
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
               }
           //apiSession.executeRules();
               //apiSession.persistConfiguration(true);
                    //editPage = new Pagereference('/apex/cscfgc__configureProduct?configId='+currConfig.Id+'&retURL=/'+bundle.Id);
          }

        }
        catch(Exception ex )
        {
            //#
            //# Roll back the DB and re-throw.
            //#
            Database.rollback(sp);
            QueryConfigurationrequest(cr);
            throw ex;
        }
        //return editPage;
        return; //null;
    }

    
    //#
    //# Is the chosen product valid? 
    //#
    public static boolean isProductValid(cConfigRequest cr)
    {
        boolean result = true;


        System.Debug('####################### Validating Against Rules:' + cr.Configrequest.product_name__c);

        if (cr.Configrequest.product_name__c == null || cr.Configrequest.product_name__c == '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No product has been selected'));
            return result;
        }
        
        System.Debug('####################### Validating Against against Line Availability' + cr.Configrequest.Line_Availability__r );
        //#
        //# THIS SECTION CONTAINS ONLY FIXED RULES.
        //#
        string cat = cr.Configrequest.Product_category__c;
        if (cr.Configrequest.Line_Availability__c != null)
        {
            
            string checkType = cr.Configrequest.Line_Availability__r.Type__c;
            
            //#
            //# IS IT THE RIGHT TYPE OF LINE CHECK FOR THE PRODUCT?
            //#
            if (checkType == BATCH_CHECKTYPE_LINE && getSettings().LineCheckCategories.containsKey(cat) == false)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The incorrect type of line check is being used for this type of product. Please refresh the line check.'));
                result = false;             
            }                   
            if (checkType == BATCH_CHECKTYPE_BROADBAND && getSettings().BroadbandCheckCategories.containsKey(cat) == false)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The incorrect type of broadband check is being used for this type of product. Please refresh the line check.'));
                result = false;             
            }                   
            
            //#
            //# ARE THERE ANY PENDING ORDERS ?
            //#
            if (cr.Configrequest.Line_Availability__r.TotOrds__c > 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Line Check shows pending orders for the number. No other orders can be placed at this time.'));
                result = false;
            }   
            //#
            //# IS IT A PAYPHONE ?
            //#
            if ((cr.Configrequest.Line_Availability__r.PayphType__c + '').toLowerCase().startswith(LINE_CHECK_PAYPHONE))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Line Check states that the number is a Payphone. Orders cannot be placed against payphones.'));
                result = false;
            }   

            //#
            //# IF IT'S BB AND THEY'VE SPECIFIED A DIRECTORY NO, IS THE LINE WORKING ?
            //#
            // RAC 15/03/2012: Case 00006943 permit both empty string and working to mean a working line
            if (cr.Configrequest.Line_Availability__r.Type__c == BATCH_CHECKTYPE_BROADBAND 
                    && cr.Configrequest.Directory_Number__c != null
                  && !LINE_CHECK_WORKING.contains((cr.Configrequest.Line_Availability__r.accessLineStatus__c == null ? '' : cr.Configrequest.Line_Availability__r.accessLineStatus__c).toLowerCase()) // case 6943 HB 2013.02 issue with the null values                     
                )
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Broadband can only be transferred where broadband is working.'));
                result = false;
            }               

            //#
            //# IF ITS LINE CHECK, DOES IT HAVE A SERVICE TYPE ?
            //#
            if (cr.Configrequest.Line_Availability__r.Service_Type__c == null && cr.Configrequest.Line_Availability__r.Type__c == BATCH_CHECKTYPE_LINE)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Line Check results do not support the chosen product on this Directory Number. Remove the Directory Number to create a New Provide order.'));
                result = false;
            }               

            
            if (!result)
                return result;
        }

        
        //#
        //# NOW CHECK THE AVAILABLE PRODUCTS BASED ON THE LINE RESULTS (SERVICE TYPE)
        //#                 
        if (cr.Configrequest.Configuration_request_rule__c != null)
        {
            System.Debug('####################### I have a rule:' + cr.Configrequest.Configuration_request_rule__c);
        
            //#
            //# Found a rule, so make sure that the chosen product is valid for the
            //# line check results
            //#         
            result = (cr.Configrequest.Configuration_request_rule__r.Valid_products__c.contains(cr.Configrequest.product_name__c));         
            if (!result)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The product is not compatible with the Line Check results'));
        
        }
        else
        {
            System.Debug('####################### There\'s No Rule');
            //#
            //# if we have a line check result, but no rule - then there are no 
            //# valid products for the given line check result 
            //#
            
            
            System.Debug('####################### Line availability is: ' + cr.Configrequest.Line_Availability__c);
            if (cr.Configrequest.Line_Availability__c == null)
            {                
                result = ( !cr.getRequiresLineCheck());
                if (!result)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Line Check results were returned for the specified directory number. No products are available.'));
            }
        }   
        
        System.Debug('####################### Result Validation is ' + result);
        
        return result;
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
        //saveConfigurationRequests(); 
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
    
    /*
    public PageReference cloneConfigurationRequests() {
        //
        saveConfigurationRequests(); 
        system.debug('******************>>><<<<configRequestId:'+configRequestId);
        //
        Configuration_Request__c configRequest = [select Id, Name, Availability_Check_Batch_Job__c, Product_Configuration__c,
                                                         Availability_Check_Progress_Indicator__c, Product_Definition__c, Number_Of_Requests_To_Clone__c,
                                                         Directory_Number__c, Line_Availability__c, Product_Category__c, Product_Name__c,
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
        //*for (Integer i = 0; i < numberToClone; i++) {
        //        List<cscfgc__Attribute__c> newMainClonedAttributes = sourceConfig.cscfgc__Attributes__r.deepClone(false);
        //        for (cscfgc__Attribute__c att : newMainClonedAttributes) {
        //                att.cscfgc__Product_Configuration__c = newMainClonedConfig.Id;
        //        }
        //}
        //insert newMainClonedAttributes;
        //
        //-------------
        // Now clone the children
        //copyChildConfigsToBunlde(sourceConfig, targetBundleId, newMainClonedConfig, newMainClonedAttributes);
        
        }
        ******/
        //
        // Loop thorugh the child configuration copy all of them to the specified bundle
        /*
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
        */
    
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
  
 
    
    private void populateFieldMap() {
    
        List<LineAvailabilityTransformationMap__c> latms;
        latms = LineAvailabilityTransformationMap__c.getall().values();

        for(LineAvailabilityTransformationMap__c latm: latms) {
            boltOnFieldMap.put(latm.field_name__c, latm.Configurator_Field_Name__c);
            boltOnValueMap.put(latm.field_name__c, latm.Override_Value__c);
          }    
          System.Debug('@@@ RD = ' + boltOnFieldMap);
          System.Debug('@@@ RD = ' + boltOnValueMap);
    }


    //###########################################################################################
    //#
    //#   NEW NEW NEW ! COPIED FROM O2ONLINE CONTROLLER FOR IMMEDIATE LINE CHECK
    //#
    //#
    public PageReference generateRowsFromCSV()
    {
        
        //#
        //# Cache the Paf results by post code - if the same post code is used more than once
        //# then it reduces the callouts. This shoul dbe batched same as line check.
        //#
        map<string,List<AddressCheckController.Address>> pafResultMap = new map<string,List<AddressCheckController.Address>>(); 
        list<string> lstEncodedKeys = new list<string>();
        map<string,Map<string, Line_Availability__c>>  existingLineAvailabilityChecksMap = new map <string,Map<string, Line_Availability__c>>();


        Savepoint sp; 
        try
        {
            //#
            //# First, split the data
            //#
            System.debug(logginglevel.info,'#################### Pasted text is: ' + csvPasteText );
            
    
            if (csvPasteText == null || csvPasteText.trim() == '') 
                return null;

            //#
            //# Save the screen state to the DB
            //#
            //sp = Database.setSavepoint();
        
            //#
            //# determine the row split char...
            //#
            string rowSplitChar = '\n';
            if ( csvPasteText.contains('\n')) rowSplitChar = '\n';
            else if ( csvPasteText.contains('\r')) rowSplitChar = '\r';
            
    
            
            //#
            //# determine the column split char...
            //#
            string colSplitChar = '';
            if ( csvPasteText.contains('\t')) colSplitChar = '\t';
            else if ( csvPasteText.contains('\f')) colSplitChar = '\f';
            else colSplitChar = ',';
    
            
            
            //#
            //# Now split the pasted in text by the line break char
            //#
            list<string> lstRows = csvPasteText.split(rowSplitChar);
            List<cConfigRequest> newRowsToSave = new List<cConfigRequest>();
            
            System.debug(logginglevel.info,'#################### Lines pasted : ' + lstRows);
                    
            
            if (configRequestList == null)
                   this.configRequestList = new List<cConfigRequest>();
        
            
                
            
            //#
            //# Build up the list of line checks that have been performed already for these
            //#
            for (string s : lstRows)
            {
                list<string> lstPhonePostCodeVals = s.split(colSplitChar);
                
                if (lstPhonePostCodeVals.Size() >  0)                
                {
                    string strPhone = lstPhonePostCodeVals[0].replace('\r','');
                    string strPostCode = '';
                    if (lstPhonePostCodeVals.Size() > 1)
                        strPostCode = lstPhonePostCodeVals[1].replace('\r','');
                    lstEncodedKeys.add(encodeTelNoAndPostCodeKey(strPhone,strPostCode));
                }
            }
            //#
            //# Search for line checks performed in the last n days.
            //#    
            if (lstEncodedKeys.Size() == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'The data pasted from Excel must contain only Directory Numbers and Post Code Columns.'));               
                return null;
            }
            //existingLineAvailabilityChecksMap  = getExistingLineAvailabilityChecksMap(lstEncodedKeys,getSettings().NumDaysLineCheckToReuse); 
            System.debug(logginglevel.info, '################### Availability check map :' + existingLineAvailabilityChecksMap.values());
            
       
        
            //#
            //# Loop thru each line and assume col 1 is phone number and col 2 is postcode,
            //# then generate the config requests for them.
            //#
            for (integer iLoop = 0 ; iLoop < lstRows.Size();  iLoop++)
            {
                list<string> lstPhonePostCodeVals = lstRows[iLoop].split(colSplitChar);
                
                if (lstPhonePostCodeVals.Size() >0)              
                {
                    string strPhone = lstPhonePostCodeVals[0].replace('\r','');
                    string strPostCode = '';
                    if (lstPhonePostCodeVals.Size() > 1)
                        strPostCode = lstPhonePostCodeVals[1].replace('\r','');

                    string encodedKey = encodeTelNoAndPostCodeKey(strPhone,strPostCode);
        
                    //#
                    //# Build the config request for the phone / post code here
                    //#
                    cConfigRequest configRequest = new cConfigRequest(new Configuration_Request__c(product_bundle__c = this.bundle.Id, Directory_Number__c = strPhone , Post_Code__c = strPostCode ));                      

    
                    this.configRequestList.add(configRequest);              
                    newRowsToSave.add(configRequest);
                }
    
            }

            //#
            //# Now Refresh the PAF map BEFORE WE SAVE!
            //#
            refreshPafGlobalPafMap();

            //#
            //# Save the configs
            //#
            System.debug(logginglevel.info,'#################### Saving Configs: ' + newRowsToSave);
            SaveConfigurationrequests(this.configRequestList);
            csvPasteText = '';
            QueryConfigurationrequests();
        }
        catch (exception ex)
        {           
            database.rollback(sp);
            
            this.configrequestList= null;
            
            //#
            //# Query config requests gets recent line checks AND does paf lookups where it needs to.
            //#
            QueryConfigurationrequests();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'There was a problem saving the data that has been pasted in. \n The data must be in the format of Directory Number then Post Code'));
                
        }       
    

        return null;
    }


    //###########################################################################################
    //#
    //# Save and redirect to the bundle summary page
    //#
    public Pagereference saveAndContinue()
    {                       
            
            saveConfigurationRequests(this.configRequestList);
            Pagereference p = new Pagereference('/' + bundle.id);
            p.Setredirect(true);
            
            return p;                       
    }


    //###############################################################################
    //#
    //# PERFORM POST CODE LOOKUP FOR A SPECIFIED ROW set controller Property tRowId
    //#
    public Pagereference lookupPostCode()
    {

        string rowId = tRowId; 
        
        System.Debug(logginglevel.info,'############################# Entering PAF with Row Id : ' + rowId );
        
        
        cConfigRequest cr;
        
        for (cConfigRequest cTemp : this.configRequestList)
        {
            if (cTemp.configRequest.Id == rowid)
            {
                cr = cTemp;
                break;
            }
        }       
        string postCode = cr.configRequest.Post_Code__c;
        

        System.Debug(logginglevel.info,'############################# Searching for postcode: ' + postCode );

        if (cr.pafAddresses != null) cr.pafAddresses.clear();
        cr.pafAddresses = findAddresses(null, null, postCode);
        cr.addressIndex = 0;
        

        return null;
        
    }



    //##############################################################################################
    //# Do line chack on category change event (with or without cache)
    //#
    //#
    public Pagereference doLineCheckForCategoryCached()
    {
        return doLineCheckForCategory(true);
    }
    public Pagereference  doLineCheckForCategoryNotCached()
    {
        return doLineCheckForCategory(false);
    }


    //#############################################################################################
    //#
    //# DO line Check for category - re-use cache if possible & specified in overload
    //#
    public Pagereference doLineCheckForCategory(boolean useCachedResults)
    {

        string rowId = tRowId;      
        cConfigRequest cr;
        
        for (cConfigRequest cTemp : this.configRequestList)
        {
            if (cTemp.configRequest.Id == rowid)
            {
                cr = cTemp;
                break;
            }
        }       

        if (cr == null)
            return null;

        //# no line check needed for mobile products or Femto/boost box
        system.debug('#### Product Category #### ' + cr.configRequest.Product_Category__c);
        if (cr.configRequest.Product_Category__c == 'Business Mobile' || cr.configRequest.Product_Category__c == 'Femtocells')
        {
            system.debug('#### Product Category #### ' + cr.configRequest.Product_Category__c);
            return null;
        }

        string postCode = cr.configRequest.Post_Code__c;
        string phoneNo  = cr.configRequest.Directory_Number__c;
        string category = cr.configRequest.Product_Category__c;
        cr.LineCheckresults = new map<string,string>();         
        string[] encodedKeyList = new string[] {encodeTelNoAndPostCodeKey(phoneNo,postCode)};
        cr.Configrequest.Product_name__c = null;
        cr.Configrequest.Provide_type__c = null;
        cr.configRequest.Line_Availability__c = null;
        cr.configRequest.Line_Availability__r = null;
        cr.configRequest.Configuration_Request_Rule__c = null;
        
        
        //#
        //# if they've changed the number or postcode, then the checks we have are invalid, so we
        //# also have to clear down the cached results and check again.
        //#
        if (!useCachedResults)
        {
            system.debug(logginglevel.info,'################# Clearing cached checks: because usecache =' + useCachedResults + ' for ' + encodedKeyList[0]);            
            cr.clearLineCheckCache();           
            
        }
                        

        //#
        //# If they have cleared down the number, then reset.
        //#
        if (phoneNo.length() == 0 && postCode.length() == 0 )
        {
            cr.clearLineCheckCache();       
            return null;
        }
        
        
        try
        {
            
            cDirectoryNoPostCode dnpc = decodeTelAndPostCodeKey(encodedKeyList[0]);
            
            string checkTypeKey = '';
            //#
            //# Requires much more exception handling if line check fails etc.
            //#     
            //if (phoneNo.length() > 0 && category.length() > 0 )
            if ((phoneNo.length() > 0 || postCode.length() > 0) && category.length() > 0 )
            {
            
                system.debug(logginglevel.info,'################# lookuing up line checks for: ' + phoneNo + ' - ' +  postcode + ' - ' + category);
                
                if ( getSettings().LineCheckCategories.containsKey(category))
                    checkTypeKey =  BATCH_CHECKTYPE_LINE;
                else if (getSettings().broadbandCheckCategories.containsKey(category))
                    checkTypeKey =  BATCH_CHECKTYPE_BROADBAND;
    
                
                system.debug(logginglevel.info,'################# Checking for type: ' + checkTypeKey);
                
                //#
                //# Clear Down
                //#
                cr.configRequest.Has_Line_Check_Error__c = false;
                cr.configRequest.Line_Check_Error_Message__c = '';
                cr.configRequest.Line_Availability__c = null;
                cr.configRequest.Line_Availability__r = null;
                cr.configRequest.Configuration_Request_Rule__c = null;
            
            
                //#
                //# VALIDATION FOR LANDLINE
                //#
                
                if (checkTypeKey ==  BATCH_CHECKTYPE_LINE)
                {
                    if (phoneNo.length() == 0)
                    {
                        //#
                        //# no number - assume it's a new provide
                        //# no line check required.
                        //#                     
                        saveConfigurationRequest(cr);
                        queryConfigurationRequest(cr);
                        return null;
                    }   
            
                    if (phoneNo.length() > 0  && postcode.length() == 0) 
                    {
                        //#
                        //# NUMBER AND POSTCODE REQUIRED FOR LINE CHECK!
                        //#
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Land Line Checks require both Directory Number and Post Code'));
                        saveConfigurationRequest(cr);
                        queryConfigurationRequest(cr);
                        return null;
                    }
                }   
                
            
            
                if (checkTypeKey != '')
                {                           
    
                    //#
                    //# if it's empty then refresh it
                    //#
                    if (cr.lineChecks.isEmpty())
                    {
                        map<string,map<string,Line_Availability__c>>  refreshedLineAvailabilityChecksMap  = getExistingLineAvailabilityChecksMap(encodedKeyList,getSettings().NumDaysLineCheckToReuse);
                        if (refreshedLineAvailabilityChecksMap.containsKey(encodedKeyList[0]))
                            cr.lineChecks = refreshedLineAvailabilityChecksMap.get(encodedKeyList[0]);
                    }
    
                    //#
                    //# LINE CHECK - REUSE OR RE-CHECK ?
                    //#
                    if (useCachedResults && cr.lineChecks.containsKey(checkTypeKey) )
                    {
                        system.debug(logginglevel.info,'################# Going to re-use line check type: ' + checkTypeKey);
                        //# REUSE!
                        cr.configRequest.Line_Availability__c = cr.lineChecks.get(checkTypeKey).Id;
                        cr.configRequest.Line_Availability__r = cr.lineChecks.get(checkTypeKey);
                        system.debug(logginglevel.info,'################# re-use: ' + cr.lineChecks.get(checkTypeKey).Name);                    
                        
                    }
                    else
                    {
                        
                        system.debug(logginglevel.info,'################# Line check not found - going to perform new one for: ' + checkTypeKey);
                        //# DON't HAVE ONE - DO THE CHECK NOW           
                        Map<String, String> lineCheckResults = (checkTypeKey == BATCH_CHECKTYPE_LINE) ?  
                                                                performLineCheck(dnpc.directoryTelNo,dnpc.postCode) : 
                                                                performBroadbandCheck(dnpc.directoryTelNo,dnpc.postCode);
                            
                        system.debug(logginglevel.info,'################# Check complete. results are: ' + lineCheckResults);
                        cr.LineCheckresults = lineCheckResults;
                        if (lineCheckresults.containskey('error'))
                        {
                            cr.configRequest.Has_Line_Check_Error__c = true;
                            cr.configRequest.Line_Check_Error_Message__c = lineCheckresults.get('error');
                        }
                        else
                        {
                            cr.configRequest.Has_Line_Check_Error__c = false;
                            cr.configRequest.Line_Check_Error_Message__c = '';
                        }
                    
                        //#
                        //# get the return id
                        //#             
                        cr.configRequest.Line_Availability__c = lineCheckResults.get('lineAvailabilityCheckId');                                    
                        
                        //#
                        //# refresh the linechecks cache for this row and see if we can get it from the DB again
                        //#
                        system.debug(logginglevel.info,'################# refreshing Cache for call: ');
                        map<string,map<string,Line_Availability__c>>  refreshedLineAvailabilityChecksMap  = getExistingLineAvailabilityChecksMap(encodedKeyList,getSettings().NumDaysLineCheckToReuse);
                        
                        system.debug(logginglevel.info,'################# Looking in refreshed cache for : ' + encodedKeyList[0]);
                        system.debug(logginglevel.info,'################# refreshed cache contains : ' + refreshedLineAvailabilityChecksMap);
                        if (refreshedLineAvailabilityChecksMap.containsKey(encodedKeyList[0]))
                        {
                            cr.lineChecks = refreshedLineAvailabilityChecksMap.get(encodedKeyList[0]); 
                            if (cr.lineChecks.containsKey(checkTypeKey))
                            {
                                system.debug(logginglevel.info,'################# one in the refreshed cache is: ' + cr.lineChecks.get(checkTypeKey));
    
                                cr.configRequest.Line_Availability__c = cr.lineChecks.get(checkTypeKey).Id;
                                cr.configRequest.Line_Availability__r = cr.lineChecks.get(checkTypeKey);
                            }
                        }
                        else
                        {
                            system.debug(logginglevel.info,'################# Did not find key in cache: ' + encodedKeyList[0]);
                            // Else it didn't work - so report something ?
                        }
                    }
                    
    
                }   
                        
                 
            }        
            
            
                    
            System.debug('##################################### line availability check is BEFORE SAVE:' + cr.configRequest.Line_Availability__r);
    
            saveConfigurationRequest(cr);
            System.debug('##################################### line availability check is AFTER SAVE:' + cr.configRequest.Line_Availability__r);
            queryConfigurationRequest(cr);
            System.debug('##################################### line availability check is AFTER REFRESH:' + cr.configRequest.Line_Availability__r);
        }
        catch (Exception ex)
        {
            throw ex;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There Was a problem performing the line check with the data provided: ' + ex.getMessage() + ' (' + ex.getLineNumber() + ')'));
            queryConfigurationRequest(cr);
        }
                    
        
        return null;        
    }




    //################################################################################################
    //#
    //# Do Line check, Paf check and generate configuration - NOTE A REAL WORLD SCENARIO
    //# as the user will have to pick a specific address from the postcode.
    //#
    public Pagereference prepareOneRow()
    { 

        cConfigRequest cr;
        try
        {
            string rowId = tRowId; //ApexPages.currentPage().getParameters().get('rowIdToProcess');
            AddressCheckController.Address chosenAddress = null; //new AddressCheckController.Address(); 
            
                        
            for (cConfigRequest cTemp : this.configRequestList)
            {
                if (cTemp.configRequest.Id == rowid)
                {
                    cr = cTemp;
                    break;
                }
            }
            if (cr == null)
                throw new ProductBundleBuilderException('row could not be identified');
            
            //#
            //# Check the validation rule that specifies what products 
            //# can be used based ona line check
            //#                         
            SYSTEM.DEBUG(lOGGINGlEVEL.iNFO, '#################### aBOUT TO GET RULE');
            Configuration_Request_Rule__c crr = getMatchingProductRule(cr);
            
            SYSTEM.DEBUG(lOGGINGlEVEL.iNFO,'#################### PRODUCT RULE IS ' + crr);
            
            if (crr != null)
            {
                cr.configRequest.Configuration_Request_Rule__c = crr.id;
                cr.configRequest.Provide_Type__c = crr.Default_Provide_Type__c; 
            }
            else
            {
                cr.configRequest.Configuration_Request_Rule__c = null;
                cr.configRequest.Provide_Type__c = PROVIDE_TYPE_NEW;
            }
            
            SYSTEM.DEBUG(lOGGINGlEVEL.iNFO,'#################### PROVIDE TYPE IS ' + cr.configRequest.Provide_Type__c);
            
            //#
            //# set the session return page for the configurator
            //# so edit and cancel are less random!
            //#
            cscfgc.SessionManager.getSessionInfo('/apex/ProductBundleBuilder');         
            saveConfigurationRequest(cr);
                        

            queryConfigurationRequest(cr); // refresh formula & name fields!
            
            System.debug(logginglevel.info,'##################### ROW ID IS ' + rowId);
            System.debug(logginglevel.info,'##################### THE CR IS ' + cr);
            
            string telNo =  cr.configRequest.Directory_Number__c;       
            string postCode = cr.configRequest.Post_Code__c;
            
            //#
            //# VALIDATION STARTS
            //#
            if (cr.configRequest.Product_Name__c == null || cr.configRequest.Product_Name__c == '')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A configuration cannot be created until a Category and Product are selected'));   
                return null;
            }           
            if (!isProductValid(cr))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This type of product is not compatible with line check results'));                
                return null;
            }
            

            //#
            //# Work out which address they chose
            //#
            if (cr.addressIndex != null  && cr.pafAddresses.size() > 0 )                                
            {
                chosenAddress = cr.pafAddresses[cr.addressIndex]; 
                cr.ConfigRequest.PAF_Select_Option_Text__c = buildOptionTextFromPafEntry(chosenAddress);
            }
            
            System.debug(logginglevel.info,'##################### CHOSEN ADDRESS IS ' + chosenAddress);              
            
            //#
            //# Now comes the magic bit - Create the config and post in the values.
            //#
            System.debug(logginglevel.info,'########################### About to save config request');       
            saveConfigurationRequest(cr);
            System.debug(logginglevel.info,'########################### About to create config');
            createConfigurations(cr, chosenAddress);
            System.debug(logginglevel.info,'########################### About to query config');
            QueryConfigurationrequest(cr);
            
        
        
        }
        catch (DMLException ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'A problem occurred whilst creating the configuration. The system is busy adding other configurations. Please try again in a few moments (' + ex.getMessage() + ' - ' + ex.getLineNumber() +')'));
            if (cr != null)
            {
                //saveConfigurationRequest(cr);                 
                QueryConfigurationrequest(cr);
            }
        }
        catch (Exception ex)
        {
            //throw ex;         
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'A problem occurred whilst creating a configuration. (' + ex.getMessage() + ' - [' + ex.getLineNumber() + '])' ));
            if (cr != null)
            {
                //saveConfigurationRequest(cr);                 
                QueryConfigurationrequest(cr);
            }
        }
        
    
     
        return null;    
        
    }

    //LINE CHECKER
    public static Map<String, String> performLineCheck(String strTransNum, String strTransPostcode) 
    {
        return performLineCheck(strTransNum,strTransPostcode,null);
    }
    
    public static Map<String, String> performLineCheck(String strTransNum, String strTransPostcode, cscfgc.ProductConfiguration currConfig) {
        Map<String, String> mpCheckResults = new Map<String, String>();
        String strLineType = '';
        String strSuccess = 'false';
        String strReason = '';
        String strcheckResId = '';
        try {
            strTransNum.trim();
            strTransPostcode.trim();
            Batch_Job__c checkJob  = AvailabilityCheckInputProcessor.processLineAvailablityImmediate(strTransNum, strTransPostcode, 'Line');
            if (checkJob!=null) {
                Line_Availability__c checkRes = [SELECT Id, Service_Type__c, Status__c, reasonCode__c, Progress_Indicator__c, Batch_Job__r.indicator__c FROM Line_Availability__c WHERE Batch_Job__c = :checkJob.Id];
                if (checkRes != null) {
                    strcheckResId = checkRes.Id; 
                    if (checkRes.Status__c == 'Completed') {
                        strSuccess = 'true';
                        // Need to pass this in or save it for later!
                        if (currConfig != null)
                        {
                            currConfig = O2OrderHelper.populateConfiguration(getProduct(currConfig), currConfig, checkRes.Id);
                            strLineType = currConfig.getAttribute('Line Type').getValue();
                        }
                        //cscfgc.ProductConfiguration currConfig = apiSession.getConfiguration();   
                        //currConfig = O2OrderHelper.populateConfiguration(getProduct(), currConfig, checkRes.Id);
                        //strLineType = currConfig.getAttribute('Line Type').getValue(); 
                    } else {
                        strSuccess = 'false';
                        strReason = checkRes.reasonCode__c;
                    }
                }
                else
                {
                    throw (new ProductBundleBuilderException('Line Availability Check result not returned'));
                }
            }
            else
            {
                throw (new ProductBundleBuilderException('Batch Job not created during Line Check'));
            }
            mpCheckResults.put('lineType', strLineType);
            mpCheckResults.put('success', strSuccess);
            mpCheckResults.put('reason', strReason);
            mpCheckResults.put('lineAvailabilityCheckId', strcheckResId);
        }
        catch (Exception e) {
            System.debug('### SERVICE_CALL_ERROR >>>>> performLineCheck: error: '+e.getMessage());
            mpCheckResults.put('success', 'false');
            mpCheckResults.put('error', e.getMessage());
        }
        return mpCheckResults;
    }
    //BROADBAND CHECKER
    public static Map<String, String> performBroadbandCheck(String strTransNum, String strTransPostcode) {
        Map<String, String> mpCheckResults = new Map<String, String>();
        String strLineSpeed = '';
        String strSuccess = 'false';
        String strReason = '';
        String strCheckid = '';
        string strIndicator = '';
        if (strTransPostcode == null) strTransPostcode = ''; 
        
        
        try {
            if (strTransNum!=null) strTransNum.trim();
            strTransPostcode.trim();
            Batch_Job__c checkJob  = AvailabilityCheckInputProcessor.processLineAvailablityImmediate(strTransNum, strTransPostcode, BATCH_CHECKTYPE_BROADBAND);
            if (checkJob!=null) {
                Line_Availability__c checkRes = [SELECT Id, 
                                                Service_Type__c, 
                                                Status__c, 
                                                reasonCode__c, 
                                                Progress_Indicator__c,                                               
                                                estimatedLineSpeed__c, 
                                                predictedDownloadSpeed__c, 
                                                Batch_Job__r.indicator__c FROM Line_Availability__c WHERE Batch_Job__c = :checkJob.Id];

                strIndicator = checkRes.Progress_Indicator__c;
                if (checkRes != null) {
                    strCheckid = checkRes.id;
                    System.debug('### OUTPUT >>>>> performBroadbandCheck: checkRes: '+checkRes);
                    System.debug('### OUTPUT >>>>> performBroadbandCheck: checkRes.Status__c'+checkRes.Status__c);
                    //if (checkRes.Status__c == 'Completed') {  //removed this line since calls were returning 'Bad Response' messages even though the call was successful
                    if (checkRes.predictedDownloadSpeed__c!=null) 
                    {                    
                        strSuccess = 'true';    
                        strLineSpeed = checkRes.estimatedLineSpeed__c;  
                        if (strLineSpeed==null || strLineSpeed=='') 
                            strLineSpeed = checkRes.predictedDownloadSpeed__c; 
                    } else 
                    {
                        strSuccess = 'false';
                        strReason = checkRes.reasonCode__c;
                    }
                }
                else
                {
                    throw (new ProductBundleBuilderException('Availability check result not returned'));    
                }
            }
            else
            {
                throw (new ProductBundleBuilderException('Batch Job not created during Line Check'));
            }
            mpCheckResults.put('lineSpeed', strLineSpeed);
            mpCheckResults.put('success', strSuccess);
            mpCheckResults.put('reason', strReason);
            mpCheckResults.put('lineAvailabilityCheckId', strCheckid);
            mpCheckResults.put('progressIndicator', strIndicator);
        }
        catch (Exception e) {
            //throw e;
            System.debug('### SERVICE_CALL_ERROR >>>>> performBroadbandCheck: error: '+e.getMessage());
            mpCheckResults.put('success', 'false');
            mpCheckResults.put('error', e.getMessage());
        }
        return mpCheckResults;
    } 
     
    //#
    //# PAF search method
    public static List<AddressCheckController.Address> findAddresses (String pafBuildingName, String pafBuildingNumber, String pafPostcode) {
        List<AddressCheckController.Address> resAddresses;
        
        try {
            System.debug('### OUTPUT >>>>> findAddresses: method start');
            AddressCheckController pafcontroller = new AddressCheckController();
            System.debug('pafBuildingName ********************************************** '+pafBuildingName);
            System.debug('pafPostcode ********************************************** '+pafPostcode);
           
            if (pafBuildingName!=null) pafcontroller.buildingName = pafBuildingName;
            if (pafBuildingNumber!=null) pafcontroller.buildingNumber = pafBuildingNumber;
            if (pafPostcode!=null) pafcontroller.postcode = pafPostcode;
            if (pafcontroller.postcode!=null && pafcontroller.postcode!='') {
                PageReference resPage = pafcontroller.addressSearch();
                resAddresses = pafcontroller.addressResults;
            }
        }
        catch (Exception e) 
        {
            throw e;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        System.debug('############### findAddress returning:' + resAddresses );
        
        return resAddresses;
    } 
 
 
     public static String getProduct(cscfgc.ProductConfiguration currConfig) 
     {
        String strProdName = '';
        if (currConfig!=null) strProdName = currConfig.getsObject().cscfgc__product_definition__r.name;
        return strProdname;
     }
 
     //####################################################################################################
     //# Returns map of line checks (keyed by number) that have been performed in the last [n] days
     //# Where n is specified by dayRange. Each map has a child map keyed on line type.
     //# CPS 21/11/11
     //#
     //# the return map looks like : 
     //#  Map<telno + PostCode object, map<line check type, line check results> 
     //#
     public static map<string,Map<string, Line_Availability__c>> getExistingLineAvailabilityChecksMap(List<string> phoneNosAndPostcodes, integer dayRange)
     {

        System.Debug(logginglevel.info,'################# About to check for exising line checks in last ' + dayRange + ' days for : ' + phoneNosAndPostcodes );

        string searchParms = '';            
        map<string,Map<string, Line_Availability__c>> results = new map<string,Map<string, Line_Availability__c>>();
     
        if (phoneNosAndPostcodes.isEmpty())
            return results;
     
        list<cDirectoryNoPostCode>  phoneNosAndPostcodesObjects = new list<cDirectoryNoPostCode>();
    
        for (string sTP : phoneNosAndPostcodes)
        {
             phoneNosAndPostcodesObjects.add(decodeTelAndPostCodeKey(sTP));
            System.debug(logginglevel.info,'########################### GETTING phone nos:' + decodeTelAndPostCodeKey(sTP));
        }
     
        //#
        //# Build up the SOQL statements for "Directory_No x AND postcode = y"
        //#
        for (cDirectoryNoPostCode dnpc: phoneNosAndPostcodesObjects)
        {   
            string telNo = (dnpc.directoryTelNo.startsWith('0')) ? '44' + dnpc.directoryTelNo.substring(1) : dnpc.directoryTelNo ; 
            string oneParam = '(Directory_Number__c = \'' + telNo + '\' and   Post_code__c = \'' + dnpc.postCode +'\')';
            if  (searchParms.length() > 0) oneParam = 'OR ' + oneParam + ' ';
                         
            searchParms  += oneParam;
                         
        }
     
        //#
        //# Now build the dynamic SOQL so that we can get the completed line checks
        //# within the specified period
        //#
        string soqlGetLineAvailChecks = 
            'Select ' + Utility.getSobjectFields('Line_Availability__c') +
            ' ,Batch_job__r.Type__c, Batch_job__r.Indicator__c ' +   
            ' From Line_Availability__c' +
            ' Where ((Type__c = \'line\' and Status__c = \'Completed\') or predictedDownloadSpeed__c != null) ' +
            ' And CreatedDate >= LAST_N_DAYS:' +  string.valueOf(dayRange) + 
            ' And (' + searchParms + ')' +
            ' Order by Directory_Number__c, Post_code__c,Batch_job__r.Type__c, DTM__c desc LIMIT 1000';
        
                             
        //#
        //# Execute the query (deep breath...)
        //#
        Line_Availability__c[] avails = Database.query(soqlGetLineAvailChecks);
        
        //#
        //# Now build up the map;
        //#
        for (Line_Availability__c la : avails)
        {
            
            string telPhoneKey = encodeTelNoAndPostCodeKey(la.Directory_Number__c,la.Post_code__c);
            Map<string, Line_Availability__c> lineChecks = new Map<string, Line_Availability__c>();
            
            //#
            //# get or create the map of line checks performed for the number / post code combo
            //#
            if (results.containsKey(telPhoneKey))
                lineChecks = results.get(telPhoneKey);
            else
                results.put(telPhoneKey,lineChecks);
                        
            //#
            //# LineChecks will no contain a map of linechecks keyed by type for the provided 
            //# tel no and postcode.
            //# so let's build it...
            //# Batch_job_r..Type__c is the line check type and contains Line, Broadband, Line and Broadband
            //# 
            //# Remember, we've sorted by Date Desc, so the first one we get will be the most recent.
            //# anything after that will not be required (so if they have done 3 checks in 2 days, we just get the
            //# the latest and ignore the rest.
            //#
            if (!lineChecks.containsKey( la.Batch_job__r.Type__c )) 
                lineChecks.put(la.Batch_job__r.Type__c,la);
        
                                        
        }
        
        //#
        //# Return the map which looks like
        //# Map<telno + PostCode , map<line check type, line check results>
        //# 
        System.Debug(logginglevel.info,'################# Line checks found for : ' + results.keyset());
        System.Debug(logginglevel.info,'################# Line checks reults : ' + results.values());
    
        return results;
        
     }


    //#############################################################################################
    //#
    //# FUTURE METHOD TO EXECUTE THE RULES AND VALIDATE THE CONFIGS IN THE BACKGROUND
    //#
     @future 
    static void ValidateConfigAsync(string configId) {
        
        
     Savepoint sp = Database.setSavepoint();


    cscfgc__Product_Configuration__c config = [Select Id, Name, 
                                               cscfgc__Product_Definition__c, 
                                               cscfgc__Product_Bundle__c,
                                               cscfgc__Configuration_Status__c,
                                               (Select Id, Name, 
                                               cscfgc__Parent_Configuration__c,
                                               cscfgc__Attribute_Name__c,
                                               cscfgc__Product_Definition__c, 
                                               cscfgc__Product_Bundle__c From cscfgc__Related_Configurations__r)                                                                                                            
                                               from cscfgc__Product_Configuration__c 
                                               WHERE Id = :configId];


     try
     {
            if (config.cscfgc__Configuration_Status__c == 'Pending Validation')
            {               
                cscfgc.API_1.ApiSession sess = new cscfgc.API_1.ApiSession();
                sess.setConfigurationToEdit(config);
                cscfgc.ProductConfiguration cfgrRootConfig = sess.getRootConfiguration();           
                System.debug('################## GOT ROOT CONFIG:' +  cfgrRootConfig);                                                                  
                sess.ExecuteRules();
                sess.persistConfiguration(true);            
                System.debug('################## ROOT CONFIG IS VALID ?:' +  sess.getController().configIsValid);        
            }
     }
     catch (Exception ex)
     {
        Database.rollback(sp);
        if (config.cscfgc__Configuration_Status__c == 'Pending Validation')
            config.cscfgc__Configuration_Status__c = 'Invalid';
        update config;
        
        System.debug('################## EXCEPTION WHEN PERFORMING ASYNC VALIDATION:' +  ex.getMessage());
     }
                         
        
            
            
    }



    //###############################################################################################
    //#
    //#  DIRECTORY NO AND POST CODE CLASS PLUS STATIC METHODS TO SUPPORT ACCESS
    //# use for passing around pairs of postcode 
    //#
    //#
    public class cDirectoryNoPostCode
    {
        public String directoryTelNo {get; set;}
        public String postCode {get;set;}
        
        cDirectoryNoPostCode()
        {}
        
        cDirectoryNoPostCode(string TelNo,string postcode)
        {
            this.directoryTelNo = telNo;
            this.postCode = postcode;
        }

        public string getEncodedKey()
        {
            return encodeTelNoAndPostCodeKey(this.directoryTelNo, this.postCode);
        }
        
    }
 
     
    //#
    //# Method to build a compound key for For telNo and Postcode
    //#
    public static string encodeTelNoAndPostCodeKey(string telNo, string postCode)
    {
        if (postCode == null) postcode = '';
        if (telNo== null) telNo = '';


        string tmpTel = (telNo.startsWith('0')) ? '44' + telNo.substring(1) : telNo; 
        return tmpTel.trim() + '|' + postCode.trim();
    }
    
    //#
    //# Method to decode a compound key into an object.
    //#
    public static cDirectoryNoPostCode decodeTelAndPostCodeKey(string encodedKey)
    {
        
        cDirectoryNoPostCode telNoPostCode = new cDirectoryNoPostCode(); 

        if (encodedKey.contains('|'))
        {

            string[] results = encodedKey.split('\\|');

            if (results.Size() > 0)
            {
                telNoPostCode.directoryTelNo = results[0].trim();
                if (results.Size() > 1)
                    telNoPostCode.postCode = results[1].trim();
            } 
        }
        else
        { 
            telNoPostCode.directoryTelNo = encodedKey; 
            telNoPostCode.postCode = '';
        }
    
        return telNoPostCode;
    
    }
 
 
 
     
    //####################################################################################################
    //#
    //# PRODUCT BUNDLE EXCEPTION CLASS
    //#
    //# For when we want to throw our own exceptions.
    //#
    public class ProductBundleBuilderException extends Exception
    {
        
    }
 
    //####################################################################################################
    //#
    //# Update the config status for COnfigs pending validation
    //#         
    public  Pagereference refreshConfigStatus()
    {

        try
        {

            for (cConfigrequest cr : this.configrequestList)
            {
                if (cr.ConfigRequest.Product_Configuration__c != null )//&& //cr.ConfigRequest.Product_Configuration__r.cscfgc__Configuration_Status__c != 'Incomplete')
                {
                    queryConfigurationRequest(cr);
                }
            
            }
        }
        catch (Exception e)
        {
            SYSTEM.Debug('############ Error refreshing status' + e.getMessage());  
            //# SWALLOW as this is just a cosmetic refresh...   
        }
            return null;        
        
    }
 
 
    //####################################################################################################
    //#
    //# CONFIGURATION REQUEST CLASS
    //#
    //#
    /* 
       This is our wrapper/container class. The wrapper class contains both the standard salesforce 
       object Configuration_Request__c and a Boolean value 
    */
    public class cConfigRequest {
        public Configuration_Request__c configRequest {get; set;}
        public map<string,Line_Availability__c> lineChecks {get;set;}
        public Boolean selected {get; set;}
        public map<string,string> LineCheckResults {get;set;}
        public List<AddressCheckController.Address> pafAddresses {get;set;}
        public integer addressIndex {get;set;}
        public string validProducts {get;set;}
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
            private Boolean disableAddTimePlan {get; set;}
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
 
 
            this.lineChecks = new map<string,Line_Availability__c>(); 
            this.LineCheckResults = new map<string,string>();  
            this.pafAddresses = new List<AddressCheckController.Address>(); 
        }
 
 
        //#
        //# revamp of disableTimePlan prop
        //#
        public boolean getDisableAddTimePlan()
        {       
            return (this.ConfigRequest.Telemarketing_Time_Plans__r != null  
                    &&
                    this.ConfigRequest.Telemarketing_Time_Plans__r.size() >= 3); 
        }
 
 
        //#
        //# Method to get PAF addresses as select options
        //#
        public List<Selectoption>getPafAddressOptions()
        {
            List<Selectoption> opts = new list<Selectoption>();
            integer index = 0;
            
            if  (configRequest == null)
                return opts;    
            
            if (configRequest.Locations__r.Size() > 0 && configRequest.product_configuration__c != null)
            {
                Location__c lr = configRequest.Locations__r[0];
                list<string> addressOpts = new list<string>();
                string sopt = '';
                
                if (lr.PAF_Organisation_Name__c != null)  addressOpts.add(lr.PAF_Organisation_Name__c);
                if (lr.PAF_Building_Number__c != null)  addressOpts.add(lr.PAF_Building_Number__c);
                if (lr.Street__c != null)  addressOpts.add(lr.Street__c);
                if (lr.PAF_Post_Town__c != null)  addressOpts.add(lr.PAF_Post_Town__c);             
                if (lr.PAF_County__c != null)  addressOpts.add(lr.PAF_County__c);
                
                for (string s: addressOpts)
                    sOpt +=  (sOpt=='') ? s : ',' + s;
                    
                opts.add(new SelectOption('',sOpt));
            }
            else if (pafAddresses == null || pafAddresses.isEmpty())
            {
                opts.add(new SelectOption('','No Address Found'));
                return opts;
            }
            else
            {
                opts.add(new SelectOption('','Please Select...'));
            }
            if (pafAddresses != null)
            {
                for(AddressCheckController.Address a : pafAddresses)
                {               
                    
                    
                    string strAddr = buildOptionTextFromPafEntry(a);                                        
                    if (strAddr != '') opts.add(new SelectOption(String.valueOf(index), strAddr.substring(0, strAddr.length()-2)));
                    
                    if (this.Configrequest.PAF_Select_Option_Text__c != null &&
                        strAddr.contains(this.Configrequest.PAF_Select_Option_Text__c) )
                        this.addressIndex = index;  
                    
                    index++;
                }
            }           
            return opts; 
            
        }

        //#
        //# Method to convert valid products from The config request rule into selectoptions
        //#
        public list<selectOption> getValidProductList()
        {
            list<selectOption> retlist = new list<selectOption>();
            
            if (this.configRequest != null && this.configRequest.Configuration_Request_Rule__r.Valid_Products__c != null)
            {
                string[] validProducts = this.configRequest.Configuration_Request_Rule__r.Valid_Products__c.split('\\;');
                                
                for (string s: validProducts)                                                                                   
                    retlist.add(new SelectOption(s, s));
                    
            } 
            
            if (retList.Size() == 0)
                retlist.add(new SelectOption('', '-No Valid Products-'));
            else
                retlist.add(0,new SelectOption('', '-None-'));
            
            return retList;
            
        }

 
        public string getLineCheckError()
        {
            if (this.getHasLineCheckError())
                return LineCheckResults.get('error');
            else
                return '';
        }
 
        public boolean getHasLineCheckError()
        {
            return (this.LineCheckResults != null && this.LineCheckResults.containsKey('error'));
        }
        
        
        //#
        //# Method to show if this category requires a check
        //#
        public boolean getRequiresLineCheck()
        {
            boolean result = false;
            if (this.Configrequest.Product_category__c == null)
                result = false; 
            else if (getSettings().LineCheckCategories.containsKey(this.Configrequest.Product_category__c))
            {
                //#
                //# Requires Line check - so do I have a line number ?
                //#
                if ((this.Configrequest.Directory_Number__c == null || this.Configrequest.Directory_Number__c == ''))
                    result = false;
                else
                    result = true;
                
            }   
            else if (getSettings().BroadBandCheckCategories.containsKey(this.Configrequest.Product_category__c))        
            {
                //#
                //# Requires BB check so do I have a line no or post code ?
                //#                 
                 if ( (this.Configrequest.Directory_Number__c == null || this.Configrequest.Directory_Number__c == '')
                       && (this.Configrequest.Post_Code__c == null || this.Configrequest.Post_Code__c == '') )
                    result = false;
                else
                    result = true;
            }   
            
                
            return result; 
        }
    
 
        //#
        //# build hover text for line availability
        //#
        public string getLineAvailabilityFeatureText()
        {
            string result = '';
        
            string defaultProvideType = PROVIDE_TYPE_UNKNOWN; 
            
            
            if (this.configRequest.Configuration_Request_rule__c != null && this.configRequest.Product_Configuration__c != null)
            {
                defaultProvideType = this.configRequest.Configuration_Request_rule__r.Default_Provide_Type__c;
            }
 
            if (this.configRequest != null && this.configRequest.Line_Availability__r != null)
            {
                
                if (this.configRequest.Line_Availability__r.Type__c != BATCH_CHECKTYPE_BROADBAND)
                {
                    //# For line check show:
                    //# no Lines, no Channels, incompat Features, Features, Service Type

                    if (this.ConfigRequest.Provide_type__c != null)
                        defaultProvideType = this.ConfigRequest.Provide_type__c;

                    string resTemplate  = 'Number: {0}     ' + 
                                          'Service Type: {1}     ' + 
                                          'Number of Lines: {2}     ' +
                                          'Number of Channels: {3}     ' +
                                          'Features: {4}     ' +
                                          'Incompatible Features: {5}     ' +
                                          'DEFAULT PROVIDE TYPE: {6}     ';
                                          
                    
                    result = string.format(resTemplate,new string[]{
                                            string.valueOf(this.configRequest.Line_Availability__r.Directory_Number__c),
                                            string.valueOf(this.configRequest.Line_Availability__r.Service_Type__c),
                                            string.valueOf(this.configRequest.Line_Availability__r.Number_Of_Lines__c),
                                            string.valueOf(this.configRequest.Line_Availability__r.Number_Of_Channels__c),
                                            string.valueOf(this.configRequest.Line_Availability__r.Features__c),                                            
                                            string.valueOf(this.configRequest.Line_Availability__r.Incompatible_Services__c),
                                            defaultProvideType                                          
                                            });


                }
                else
                {
                     //# FOR BB Check, we need
                     //# postcode, LLU / IPS , Reason , Available Product List, Exchange, Max speed
                        
                    if (this.ConfigRequest.Provide_type__c != null)
                        defaultProvideType = this.ConfigRequest.Provide_type__c;

                        
                    string resTemplate  = 'Post Code: {0}     ' + 
                                          'LLU / IPS: {1}     ' + 
                                          'Reason: {2}     ' +
                                          'Avaialble Products: {3}     ' +
                                          'Max. Speed: {4}     ' +
                                          'DEFAULT PROVIDE TYPE: {5}     ';

                    result = string.format(resTemplate,new string[]{
                                            string.valueOf(this.configRequest.Line_Availability__r.Post_Code__c),
                                            string.valueOf(this.configRequest.Line_Availability__r.LLU_or_IPS_available__c),
                                            string.valueOf(this.configRequest.Line_Availability__r.Reason_code_short_text__c),
                                            string.valueOf(this.configRequest.Line_Availability__r.productList__c),
                                            string.valueOf(this.configRequest.Line_Availability__r.predictedDownloadSpeed__c),                                          
                                            defaultProvideType
                                            });



                }
                
                
                                                
            }
        
            return result.replace('null','none ');
        }
 
        
        public void clearLineCheckCache()
        {           
            this.lineChecks = new map<string,Line_Availability__c>();  
            this.LineCheckResults  = new map<string,string>(); 
            this.ConfigRequest.Configuration_Request_Rule__c = null;
            
        }
 
 
    }

    public static string buildOptionTextFromPafEntry(AddressCheckController.Address a)
    {

            string strAddr = '';

                    if (a.organisation != null && a.organisation != '') strAddr+=a.organisation+', ';
                    if (a.subBuildingName != null && a.subBuildingName!='') strAddr+=a.subBuildingName+', ';
                    if (a.buildingName != null && a.buildingName!='') strAddr+=a.buildingName+', ';
                    if (a.buildingNumber != null && a.buildingNumber!='') strAddr+=a.buildingNumber+' ';
                    if (a.street != null && a.street!='') strAddr+=a.street+', ';
                    if (a.postTown != null && a.postTown != '') strAddr+=a.postTown+', ';
                    if (a.county != null && a.county!= '') strAddr+=a.county+', ';
                    if (a.postcode != null && a.postcode!= '') strAddr+=a.postcode+', ';
    
    
            return strAddr;
    
        
    }
 

    //##################################################################################
    //# Get the rule for the chosen category and line check - if one matches
    //# 
    public static Configuration_Request_Rule__c getMatchingProductRule(cConfigrequest cr)
    {

        Configuration_Request_Rule__c retRule; 
        
        system.debug(LoggingLevel.Info,'################## WHAT IS CATEGORY ? ' + cr.Configrequest.Product_Category__c );
        
        if (cr.ConfigRequest.Product_Category__c == null)
            return retRule;


        system.debug(LoggingLevel.Info,'################## GETTING RULES FOR CAT' + cr.Configrequest.Product_Category__c);
        Configuration_Request_rule__c[] rules = getCategoryConfigrequestRules(cr.Configrequest.Product_Category__c);

        system.debug(LoggingLevel.Info,'################## RULES ARE:' + rules);

        if (rules.Size() < 1)
            return retRule;
        else
        {   
            
            if (cr.Configrequest.Line_Availability__c != null)
            {
                system.debug(LoggingLevel.Info,'################## Checking rules for Service type:' + cr.Configrequest.Line_Availability__r.Service_Type__c);
                system.debug(LoggingLevel.Info,'################## Checking rules Looking for Product :' + cr.Configrequest.Product_Name__c);
                
                for (Configuration_Request_rule__c r : rules)
                {
                    // line check may have many rules..., broadband needs to be working
                    if (cr.Configrequest.Line_Availability__c != null 
                        &&  (   (cr.Configrequest.Product_Name__c != null 
                                && r.Valid_Products__c.toLowerCase().contains(cr.Configrequest.Product_Name__c.ToLowerCase())
                                // FJF - 25012012: 
                                // Check that r.Line_Check_Service_Types__c is not null before operating on it
                                && ( r.Line_Check_Service_Types__c!= null && r.Line_Check_Service_Types__c.contains(cr.Configrequest.Line_Availability__r.Service_Type__c +'')) 
                                )

                                || (cr.Configrequest.Line_Availability__r.accessLineStatus__c +'').toLowerCase() == 'working' ) 
                    ) 
                    {                           
                        system.debug('################## FOUND A MATCH:' + r);
                                
                        //#
                        //# set the provide type based on the rule
                        //# 
                        if (r.Default_Provide_Type__c != null)
                            cr.Configrequest.provide_type__c = r.Default_Provide_Type__c;
                        
                        retRule = r;                                                                                                                                                                                            
                        break;                                                      
                    }
                }
            }
        }   
        
        return retRule;
        
    }
            
        


    /*
    
    public List<selectOption> getFilteredProductList(cConfigrequest cr)
    {
              
        system.debug('################## GETTING FILTERED PRODUCT LIST');
              
              
        List<selectOption> stdOptions = new List<selectOption>();
        List<selectOption> retOptions = new List<selectOption>();
        
              
        
        
        system.debug('################## WHAT IS CATEGORY ? ' + cr.Configrequest.Product_Category__c );
        
        if (cr.ConfigRequest.Product_Category__c == null)
            return retOptions;

        system.debug('################## GETTING STANDARD OPTIONS  ' );

        //#
        //# Get the standard options from the filtered product list
        //#
        Schema.DescribeFieldResult fieldResult = Configuration_Request__c.Product_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)               
            stdOptions.add(new SelectOption(f.getLabel(), f.getValue()));
             
             
        system.debug('################## STANDARD OPTIONS : ' + stdOptions);
             
        //#
        //# now see if there are any rules that should be used instead of the default
        //#                             
        //# Setting default provide Type to New Provide 
        //this.Configrequest.provide_type__c = 'New Provide';
             
             
        if (cr.Configrequest.Directory_number__c.length() == 0 || cr.Configrequest.Line_Availability__c == null)
        {
             system.debug('################## NUMBER OR LINE CHECK EMPTY - RETURNING STANDARD OPTIONS');
             //#
             //# no line check, so no validation rules to apply - just send out
             //#
             retOptions.addAll(stdOptions);
        }
        else
        {
            //#
            //# OK - So we have a number and a line check here.
            //#                                     
            system.debug('################## GETTING RULES FOR CAT' + cr.Configrequest.Product_Category__c);
            Configuration_Request_rule__c[] rules = getCategoryConfigrequestRules(cr.Configrequest.Product_Category__c);

            system.debug('################## RULES ARE:' + rules);

            if (rules.Size() < 1)
                retOptions.addAll(stdOptions);
            else
            {   
                if (cr.Configrequest.Line_Availability__r.Service_Type__c != null)
                {
                    for (Configuration_Request_rule__c r : rules)
                    {
                        if (r.Line_Check_Service_Types__c.contains(cr.Configrequest.Line_Availability__r.Service_Type__c))
                        {
                                
                            system.debug('################## FOUND A MATCH:' + r);
                                
                            //#
                            //# set the provide type based on the rule
                            //# 
                            if (r.Default_Provide_Type__c != null)
                                cr.Configrequest.provide_type__c = r.Default_Provide_Type__c;
                                                                                                                    
                                                                        
                            string[] validProducts = r.Valid_Products__c.split('\\;');
                                
                            for (string s: validProducts)                                                                                   
                                retOptions.add(new SelectOption(s, s));
                                
                                break;                                                      
                        }
                     }
                }
            }   
        }
            
        system.debug('################## RET OPTIONS ARE:' + retOptions);
        cr.filteredProductOptions = retOptions;
        return retOptions;
            
    }
    
 
 */

    //#
    //# get or build the map of all configuration Request Rules
    //#
    public static list<Configuration_Request_Rule__c> getCategoryConfigRequestRules(string category)
    {
            
        if (ConfigRequestRulesMap == null)
        {
            ConfigRequestRulesMap = new map<string, list<Configuration_Request_Rule__c>>();
                
            Configuration_Request_Rule__c[] rules = [select Id, Name, 
                                                         Category__c,
                                                         Valid_Products__c,
                                                         Line_Check_Service_Types__c,
                                                         Default_Provide_Type__c
                                                         FROM 
                                                         Configuration_Request_Rule__c
                                                         order by Category__c]; 
                            
            for (Configuration_Request_Rule__c r : rules)
            {
                if (!ConfigRequestRulesMap.containsKey(r.Category__c))      
                    ConfigRequestRulesMap.put(r.Category__c, new list<Configuration_Request_Rule__c>{r});
                else
                    ConfigRequestRulesMap.get(r.Category__c).add(r);
            }
                    
        }
            
        if (ConfigRequestRulesMap.containsKey(category))
            return ConfigRequestRulesMap.get(category);
        else
            return new Configuration_Request_Rule__c[]{};
    
    
            
    }   
        

 
 
    //#####################################################################################################
    //#
    //# PRODUCT BUNDLE SETTINGS CLASS AND STATIC / SINGLETON ACCESSOR
    //#
    //# a kind of singleton settings getter.
    //#
    public static ProductBundleBuilderSettings getSettings()
    {   
        if (settings == null)
            settings = new ProductBundleBuilderSettings();
            
        return settings;
    }    
     
    public class ProductBundleBuilderSettings
    {
        public integer NumDaysLineCheckToReuse {get; private set;}
        public integer MaxNoTransactionPAFCalls {get;private set;}
        public map<string,string> LineCheckCategories {get; private set;}
        public map<string,string> BroadbandCheckCategories {get; private set;}
        public map<string,string> LineAndBroadbandCheckCategories {get; private set;}
    
        
        //#
        //# set them up in the cTor
        //#
        public ProductBundleBuilderSettings()
        {
            ProductBundleBuilderSettings__c pbSettings = ProductBundleBuilderSettings__c.getInstance(); 
                
                
            this.NumDaysLineCheckToReuse = pbSettings.Line_Check_Days_Check__c == null ? 5 : integer.valueOf(pbSettings.Line_Check_Days_Check__c);
            this.MaxNoTransactionPAFCalls = pbSettings.Maximum_number_of_PAF_calls_on_Paste__c == null ? 10 : integer.valueOf(pbSettings.Maximum_number_of_PAF_calls_on_Paste__c);


            //#
            //# Build the maps of which categories invoke which checks here
            //#                 
            map<string,string> lcMap = new map<string,string>();
            map<string,string> bbcMap = new map<string,string>();
            map<string,string> lbbcMap = new map<string,string>();
            
            list<string> lcItems = (pbSettings.Line_Check_Product_Categories__c == null)? new list<string>() : pbSettings.Line_Check_Product_Categories__c.split(',');
            list<string> bbcItems = (pbSettings.Broadband_Check_Product_Categories__c == null) ? new list<string>() :pbSettings.Broadband_Check_Product_Categories__c.split(',');
            list<string> lbbcItems = (pbSettings.Line_And_BB_Check_Product_Categories__c == null) ? new list<string>() :pbSettings.Line_And_BB_Check_Product_Categories__c.split(',');
            for (string s : lcItems) lcMap.put (s,s);
            for (string s : bbcItems) bbcMap.put (s,s);
            for (string s : lbbcItems) lbbcMap.put (s,s);
            
            this.LineCheckCategories = lcMap;
            this.BroadbandCheckCategories  = bbcMap;
            this.LineAndBroadbandCheckCategories = lbbcMap;
                        
            

        }
        
        
    }
    
 
    public static Location__c createLocationFromAddress(cConfigRequest cr, AddressCheckController.Address addr, String strType) {
        Location__c newLoc;
        try {
            if (addr!=null) {
                
                Location__c[] locs = [select Id from Location__c where Configuration_request__c = :cr.ConfigRequest.Id];                     
                for (Location__c l : locs) l.Location_UID__c = null;
                delete locs;
                
                newLoc = new Location__c();                             
                newLoc.Configuration_Request__c = cr.ConfigRequest.id;
                newLoc.Type__c = strType;
                //Product_Configuration__c = strConfigId,
                //User_Session__c = sessId,                             
                newLoc.Sync_with_Parent__c = false;
                newLoc.PAF_Sub_Building_Name__c = addr.subBuildingName;
                newLoc.PAF_Building_Name__c = addr.buildingName;
                newLoc.PAF_Building_Number__c = addr.buildingNumber;
                newLoc.PAF_Organisation_Name__c = addr.organisation;
                newLoc.PAF_Dependent_Thoroughfare__c = addr.dependentStreet;
                newLoc.PAF_Dependent_Thoroughfare_Descriptor__c = '';
                newLoc.PAF_Thoroughfare_Name__c = addr.street;
                newLoc.PAF_Thoroughfare_Descriptor__c = '';
                newLoc.PAF_Double_Dependent_Locality__c = addr.dependentLocality;
                newLoc.PAF_Dependent_Locality__c = addr.locality;
                newLoc.PAF_Post_Town__c = addr.postTown;
                newLoc.PAF_County__c = addr.county;
                newLoc.PAF_Postcode__c = addr.postcode;
                //Country__c = getCountryVal(strType)
                                        
                insert newloc;
                
            }
        }
        
        catch (Exception e) 
        {
            throw e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return newLoc;
    }
 
 
 
    
}