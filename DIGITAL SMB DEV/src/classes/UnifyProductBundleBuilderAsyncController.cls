/**
*   Controller for UnifyProductBundleBuilderAsync Page (often called Bundle Builder)
*   @since  06/12/2012
*   @author  emil.puchalski@cloudsensesolutions.com
*/
global with sharing class UnifyProductBundleBuilderAsyncController {

    public cscfgc__Product_Bundle__c bundle {get; set;}
    public List<cConfigSite> configSitesList {get; set;}
    public List<cConfigReq> configProductList {get; set;}
    public boolean created {get;set;}
    public boolean hasCentralSite {get;set;}
    public boolean siteMode {get;set;}
    public boolean isSA;
    public boolean sitesToRefresh;
    public boolean isUploading;
    public boolean continueRefreshing {get;set;}
    public integer uploadProcessedNo {get;set;}
    public integer uploadAllNo {get;set;}

    /*
    *   Method checks whether there is no running batch config upload process (based on Unify_Upload_Single_Entity__c entries)
    *   Used in Page logic in order to show / hide proper sections / progress bar
    *   @return boolean value which represents whether any running batch process for this Product Bundle has been found
    */
    public boolean getIsUploading(){
        if(bundle != null && bundle.Id != null){
           Unify_Upload_Single_Entity__c[] chck = [select Id, Processed__c from Unify_Upload_Single_Entity__c where Product_Bundle__c = :bundle.Id];
            if(chck == null || chck.size() == 0){
                return false;
            } else {
                this.uploadAllNo = chck.size();
                this.uploadProcessedNo = 0;
                for(Unify_Upload_Single_Entity__c c1 : chck){
                    if(c1.Processed__c){
                        this.uploadProcessedNo++;
                    }
                }
                if(this.uploadAllNo == this.uploadProcessedNo){
                    return false;
                }
                continueRefreshing = true;
                return true;
            }
        } else {
            return false;
        }
    }

    /*
    *   Method invoked by page actionPoller every 5 sec
    *   It manage continueRefreshing flag which is responsible for continuation or its stop of page refresh
    */
    public void refreshUploadStatus(){
        boolean upl = getIsUploading();
        if(upl){
            continueRefreshing = true;
        } else {
            continueRefreshing = false;
        }
    }

    public String selOppLoc {get;set;}

    public Opportunity opp {get; set;}
    public List<cscfgc__Product_Definition__c> pillars {get; set;}
    private List<cscfgc__Product_Definition__c> refreshPillars(string solution){
        List<cscfgc__Product_Definition__c> p = [SELECT
                                                    Id, cscfgc__Product_Category__c, cscfgc__Label__c, cscfgc__Product_Category__r.Name, Name
                                                 FROM
                                                    cscfgc__Product_Definition__c
                                                 WHERE
                                                    cscfgc__Product_Category__r.Name = 'Unify' AND
                                                    cscfgc__IsArchived__c = false
                                                 ORDER BY
                                                    cscfgc__Sequence__c asc];
        List<cscfgc__Product_Definition__c> result = new List<cscfgc__Product_Definition__c>();
        if(UnifyConfig.solution2Pillars().containsKey(solution)){
            set<string> avaliablePillars = UnifyConfig.solution2Pillars().get(solution);
            for(cscfgc__Product_Definition__c def : p){
                if(avaliablePillars.contains(def.Name))
                    result.add(def);
            }
            return result;
        }
        else{
            return p;
        }
    }

    public Map<Id,cscfgc__Product_Definition__c> mPillars {get;set;}
    public Integer ind {get;set;}
    public string selSolution;


    /**
    *   Additional class construction used to represent user's choice of Location reusage
    */
    public class LocationElement{
        public Location__c loc {get;set;}
        public boolean selected {get;set;}
    }

    public Location__c loc {get;set;}
    public string chosenOpt {get;set;}

    public void changeOpt(){
        System.debug('XXXXXXXXX chosenOpt:' + this.chosenOpt);
    }

    public LocationElement[] locsList {get;set;}
    public boolean isEdit {get;set;}

    /**
    *   Method executed when page is requested by Server.
    *   @return - returns possible options to be selected by user when he want to create new Sites (Location__c); options displayed as a radio buttons
    */
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('NEW','Create New Site'));
        options.add(new SelectOption('EXIST','Reuse Customer Site'));
        return options;
    }

    /**
    *   Method used to initialize / update list of Locations available to user
    *   List is limited to Installation locations of related Customer and records which has not been added to this Opportunity yet
    *   It is exectuted from page controller (first initialization) and saveSite method (list refresh)
    */
    public void refreshListOfLocs(){
        locsList = new LocationElement[]{};
        Unify_Opportunity_Location__c[] oppLoc = [select Id, Name, Location__c, Opportunity__c from Unify_Opportunity_Location__c where Opportunity__c = :bundle.cscfgc__Opportunity__c];
        Set<Id> sLoc = new Set<Id>();
        for(Unify_Opportunity_Location__c opl1 : oppLoc){
            sLoc.add(opl1.Location__c);
        }
        Location__c[] locs = [select Id, Name, Type__c, Account__c, Unify_Unique_Site_Name__c, PAF_Postcode__c, PAF_Post_Town__c, Street__c, Unify_Validated_Postcode__c  from Location__c where Account__c = :bundle.cscfgc__Opportunity__r.AccountId and Type__c = 'Installation' and Id not in :sLoc];
        for(Location__c l1 : locs){
            LocationElement le1 = new LocationElement();
            le1.loc = l1;
            le1.selected = false;
            locsList.add(le1);
        }
    }

    /**
    *   Method checks existance of Locations available to be reused, previously prepared by refreshListOfLocs method
    *   Used in Page logic in order to show / hide proper sections
    *   @return  boolean value which represents whether any Locations to be reused has been found
    */
    public boolean getotherSitesExist(){
        if(locsList != null && locsList.size() > 0){
            return true;
        } else {
            return false;
        }
    }


    /**
    *   Method invoked by the user, when ADD SITE button is clicked
    *   It changes values of variables responsible for presenting site creation layer
    */
    public void addSite(){
        this.siteMode = true;
        this.chosenOpt = 'EXIST';
        loc = new Location__c();
        isEdit = false;
        refreshListOfLocs();
    }

    /**
    *   Method invoked by the user, when EXIT button is clicked on site creation layer
    *   It changes values of variables responsible for presenting / hiding site creation layer
    */
    public void exitSite(){
        this.siteMode = false;
        if(sitesToRefresh){
            sitesListRefresh();
        }
        sitesToRefresh = false;
        chosenOpt = '';
    }

    /**
    *   RemoteAction method invoked by page Javascript when user tries to remove related Location
    *   (or rather Opportunity location entry, Location itself is not deleted)
    *   It checks whether for selected Opportunity Location any configurations has been created
    *   @param oppLocId - id of Opportunity Location which user wants to remove
    *   @return string - if configurations has been found method return its number (then user JS inform user, which needs to decide whether he wants to remove it or not) or error message
    */
    @RemoteAction
    global static String checkConfigNo(String oppLocId){
        Unify_Opportunity_Location__c ol = [select Id, Location__c, Opportunity__c from Unify_Opportunity_Location__c where Id = :oppLocId];
        cscfgc__Product_Configuration__c[] pc = [Select Name, Id, cscfgc__Product_Bundle__c, Unify_Site__r.Location__c, (select Id from Orders__r) From cscfgc__Product_Configuration__c where Unify_Site__r.Location__c = :ol.Location__c and cscfgc__Product_Bundle__r.cscfgc__Opportunity__c = :ol.Opportunity__c];
        if(pc == null || pc.size() == 0){
            return '0';
        } else {
            for(cscfgc__Product_Configuration__c pc1 : pc){
                if(pc1.Orders__r != null && pc1.Orders__r.size() > 0){
                    return 'You are not allowed to delete this site because there is already a provisioning order created for related configuration (' + pc1.Name + ').';
                }
            }
            return String.valueOf(pc.size());
        }
    }

    /*
    *   RemoteAction method invoked by page Javascript when user tries to remove related Location and confirm that he wants to remove it
    *   It deletes pointed Opportunity Location and related Sites
    *   @param oppLocId id of Opportunity Location which user wants to remove
    *   @return string result message that is presented to the user
    */
    @RemoteAction
    global static String removeSite(String oppLocId){
        Savepoint sp = Database.setSavepoint();
        try{
            Unify_Opportunity_Location__c ol = [select Id, Location__c, Opportunity__c from Unify_Opportunity_Location__c where Id = :oppLocId];
            delete ol;
            delete [select Id, Unify_RAG__c, Central_Site__c from Unify_Site__c where Location__c = :ol.Location__c];
            return 'Site has been succesfully deleted.';
        } catch(Exception e){
            if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                Database.rollback(sp);
                return 'Operation failed: Problem with access rights. \n\nPlease check whether Opportunity is locked or please contact with System Administrator.';
            } else {
                Database.rollback(sp);
                return 'Unexpected error occured. Site has not been removed. \n\nError details: ' + e.getMessage();
            }
        }
    }

    /**
    *   Method below used to refresh bundle data which might be changed (ie. COMMERCIAL APPROVED flag)
    */
    public void refreshBundleData(){
        if(bundle.Id != null){
           cscfgc__Product_Bundle__c bundleTemp = [Select c.cscfgc__Total_Price__c, c.Unify_RAG__c , c.cscfgc__Synchronised_with_Opportunity__c, c.cscfgc__Shared_Context_Configuration__c, c.cscfgc__Opportunity__c, c.cscfgc__Bundle_Status__c, c.Unify_Commercial_Approved__c, c.Id From cscfgc__Product_Bundle__c c where Id = :bundle.Id];
           this.bundle.Unify_Commercial_Approved__c = bundleTemp.Unify_Commercial_Approved__c;
           this.bundle.cscfgc__Synchronised_with_Opportunity__c = bundleTemp.cscfgc__Synchronised_with_Opportunity__c;
           this.bundle.cscfgc__Bundle_Status__c = bundleTemp.cscfgc__Bundle_Status__c;
        }
    }

    /**
    *   Method used to refresh all presented data; invoked after significant changes has been performed by the user (ie. location has been removed)
    */
    public void refreshAll(){
        refreshBundleData();
        sitesListRefresh();
        configsListRefresh();
    }

    /**
    *   Setter method invoked from page by user who changes the Solution value
    *   It refreshes configurations list based on new criteria
    */
    public void setSelSolution(String s){
        boolean refresh  = false;
        if(selSolution != s) refresh = true;
        selSolution = s;
        if(refresh){
            configsListRefresh();
            pillars = refreshPillars(selSolution);
        }
    }

    /**
    *   Getter method executed when page is requested by Server.
    */
    public String getSelSolution(){
        return selSolution;
    }

    /*
    *   Method checks whether there are any existing pillars configurations for selected criteria
    *   Used in Page logic in order to show / hide proper sections
    *   @return return FALSE if no configurations has been found or otherwise TRUE
    */
    public boolean getNoProducts(){
        if(this.configProductList.size () > 0)
           return false;
        else
           return true;
    }

    /**
    *   Getter method executed when page is requested by Server.
    *   It takes selected Solutions from parent Opportunity record and converts them into user available options on the page
    */
    public List<SelectOption> getSolutionItems() {
        List<SelectOption> options = new List<SelectOption>();
        if(opp.Unify_Solution__c != null && opp.Unify_Solution__c != ''){
            List<String> ls = opp.Unify_Solution__c.split(';');
            options.add(new SelectOption('ALL','- ALL -'));
            for(String s : ls){
                options.add(new SelectOption(s,s));
            }
        } else {
            options.add(new SelectOption('','-solution not set-'));
        }
        return options;
    }

    /**
    *   Method invoked when user clicks EDIT icon next to the listed site record
    *   As a result siteMode variable is changed which is responsible for presenting Site Layer
    */
    public void editLoc(){
        isEdit = true;
        siteMode = true;
        chosenOpt = 'NEW';
        this.loc = [select Id, PAF_Organisation_Name__c, Unify_Unique_Site_Name__c, PAF_Post_Town__c, Unify_Validated_Postcode__c, PAF_Thoroughfare_Name__c, PAF_County__c, PAF_Building_Name__c, PAF_Sub_Building_Name__c, PAF_Building_Number__c from Location__c where Id = :selOppLoc];
    }

    /**
    *   Method invoked when user clicks MARK AS APROOVED button
    *   As a result Product Bundle is marked as Commercially Approved and Opportunity stage is moved to POST BID
    *   In case of any problems error message is displayed to the user
    */
    public void approveCommercial(){
        Savepoint sp = Database.setSavepoint();
        boolean uploadCheck = getIsUploading();
        try{
            if(uploadCheck){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed! Configuration Upload procedure is in progress. You are not allowed to Commercially Approve configuration till upload is finished.'));
                Database.rollback(sp);
                return;
            }
            if(!bundle.Unify_Commercial_Approved__c){
               bundle.Unify_Commercial_Approved__c = true;
               update bundle;
               opp.StageName = 'Post Bid';
               update opp;
            }
        } Catch(exception e){
            if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed: Problem with access rights. Please check whether Opportunity is locked or please contact with System Administrator.'));
                bundle.Unify_Commercial_Approved__c = false;
                Database.rollback(sp);
                return;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed! Reason: ' + e.getMessage()));
                bundle.Unify_Commercial_Approved__c = false;
                Database.rollback(sp);
                return;
            }
        }
    }

    /**
    *   Technical methods which is used to refresh listed Locations (or rather Opportunity Locations)
    *   Method invoked after solution is changed or some location is deleted by the user
    */
    public PageReference sitesListRefresh(){
        hasCentralSite = false;
        configSitesList = new List<cConfigSite>();
        this.opp = [select Id, Name, Unify_Solution__c from Opportunity where Id = :bundle.cscfgc__Opportunity__c][0];
        Unify_Opportunity_Location__c[] opl = [select Id, Name, Location__r.Unify_Central_Site__c, Location__c, Full_Address__c, (select Id, Unify_RAG__c, Unify_RAG_Value__c from Sites__r where Solution__c = :selSolution) from Unify_Opportunity_Location__c where Opportunity__c = :this.opp.Id order by Location__r.Unify_Central_Site__c desc, Location__r.Unify_Unique_Site_Name__c asc];
        for(Unify_Opportunity_Location__c ol1: opl){
            cConfigSite c1 = new cConfigSite();
            c1.oppLoc = ol1;
            configSitesList.add(c1);
            if(ol1.Location__r.Unify_Central_Site__c){
                hasCentralSite = true;
            }
        }
        return null;
    }

    /*
    *   Method executed when page is requested by Server.
    *   Used in Page logic in order to show / hide proper sections / progress bar
    *   @return returns TRUE value if there is at least one configuration for specified Solution, or otherwise FALE
    */
    public boolean getSitesAdded(){
        if(configSitesList.size() > 0){
            return true;
        } else {
            return false;
        }
    }

    /**
    *   Technical methods which is used to refresh listed Pillars Configurations
    *   Refresh is done based on currenly chosen Solution value and Product Bundle context
    *   Method invoked after solution is changed or some configuration is deleted
    */
    public void configsListRefresh() {
        this.ind = 1;
        configProductList = new List<cConfigReq>();
        if(this.selSiteLine != '' && this.selSiteLine != null && this.selSolution != ''){
            Unify_Opportunity_Location__c[] ol = [select Id, Location__c, Opportunity__c from Unify_Opportunity_Location__c where Id = :this.selSiteLine];
            if(ol == null || ol.size() == 0){ //site has been removed by JS remote action
                System.debug('XXXXXXXXX not found! CLEAN val');
                this.selSiteLine = '';
                return;
            }
            String queryString = null;
            queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                ',cscfgc__Product_Definition__r.Name, cscfgc__Product_Definition__r.cscfgc__Label__c, (select '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r where Name in (\'DISE Bill Label\',\'Supplier\',\'Total Annual Cost\'))'+
                ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \''+bundle.Id+'\' and Unify_Site__r.Location__c  = \''+ ol[0].Location__c + '\'';

            if(this.selSolution != 'ALL'){
                queryString = queryString + ' and Unify_Solution__c = \'' + this.selSolution + '\'';
            } else {
                //no additional query filters - take all configurations;
            }

            List<cscfgc__Product_Configuration__c> tempConfs = Database.query(queryString);

            for(cscfgc__Product_Configuration__c pc1 : tempConfs){
                cConfigReq c1 = new cConfigReq();
                c1.product = pc1.cscfgc__Product_Definition__r.cscfgc__Label__c;
                c1.status = pc1.cscfgc__Configuration_Status__c != null ? pc1.cscfgc__Configuration_Status__c : 'Incomplete';
                c1.indexNo = String.valueOf(ind);
                c1.pc = pc1;
                c1.solution = pc1.Unify_Solution__c;
                if(pc1.cscfgc__Attributes__r != null){
                    for(cscfgc__Attribute__c a1 : pc1.cscfgc__Attributes__r){
                        if(a1.Name == 'DISE Bill Label'){
                            c1.diseLabel = a1.cscfgc__Value__c;
                        } else if(a1.Name == 'Supplier'){
                            c1.supplier = a1.cscfgc__Value__c;
                        } else if(a1.Name == 'Total Annual Cost' && a1.cscfgc__Value__c != null && a1.cscfgc__Value__c != ''){
                            try{
                                c1.cost = decimal.valueOf(a1.cscfgc__Value__c).setScale(2);
                            } catch(Exception e){
                                c1.status = 'Invalid COST value';
                            }
                        }
                    }
                }
                configProductList.add(c1);
                ind++;
            }
        }
        //refresh bundle element because some of the values might changed (ie Commercial Approved flag)
        refreshBundleData();
        return;
    }

    public string selSiteLine {get;set;}

    public string selProdLine {get;set;}


    /**
    *   Class Constructor responsible for setting apropriate variables' values and preparing all required data
    */
    public UnifyProductBundleBuilderAsyncController(ApexPages.StandardController stdController) {
        this.bundle = (cscfgc__Product_Bundle__c)stdController.getRecord();
        this.created = false;
        this.chosenOpt = 'EXIST';
        this.ind = 0;
        this.uploadProcessedNo = 0;
        this.uploadAllNo = 0;
        this.selSolution = 'ALL';
        this.hasCentralSite = false;
        this.siteMode = false;
        this.sitesToRefresh = false;
        this.continueRefreshing = false;

        pillars = refreshPillars(selSolution);
        mPillars = new Map<Id,cscfgc__Product_Definition__c>();
        for(cscfgc__Product_Definition__c p1:pillars){
            mPillars.put(p1.Id,p1);
        }

        if (this.bundle.Id == null) {
            Datetime d = system.now();
            String opid = apexPages.currentPage().getParameters().get('opid');
            this.opp = [select Id, Name, Unify_Solution__c from Opportunity where Id = :opid][0]; //Unify_Solution__c,
            String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');
            this.bundle.Name = 'Bundle: '+strDatetime;
            this.bundle.cscfgc__Opportunity__c = opp.Id;
            this.bundle.cscfgc__Bundle_Status__c = 'Incomplete';
        } else {
            this.created = true;
            //refreshBundleData();specific refresh - take additionaly Name and Rag Value (in generic function they shouldn't be replaced, because they might be changed by the user)
            bundle = [Select cscfgc__Opportunity__r.Name, Name, cscfgc__Total_Price__c, Unify_RAG__c , Unify_RAG_Value__c, cscfgc__Synchronised_with_Opportunity__c, cscfgc__Shared_Context_Configuration__c, cscfgc__Opportunity__c, cscfgc__Bundle_Status__c, Unify_Commercial_Approved__c, SystemModstamp, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, cscfgc__Opportunity__r.AccountId From cscfgc__Product_Bundle__c where Id = :bundle.Id];
            configProductList = new List<cConfigReq>();
            sitesListRefresh();
        }
    }

    /**
    *   Additional class construction used to support user activities on the page (related to listed Sites [Opportunity Locations])
    */
    public class cConfigSite {
        public Unify_Opportunity_Location__c oppLoc {get; set;}
        public Boolean selected {get; set;}
        public integer addressIndex {get;set;}
        /*
        *   Method which takes RAG flag from proper Site__c entry (based on selected solution)
        */
        public string getRagFlag(){
            if(oppLoc.sites__r != null && oppLoc.sites__r.size() > 0){
                return oppLoc.Sites__r[0].Unify_RAG__c;
            } else {
                return '';
            }
        }
        public string validProducts {get;set;}
    }

    /**
    *   Additional class construction used to support user activities on the page (related to listed Product Configurations)
    */
    public class cConfigReq {
        public cscfgc__Product_Configuration__c pc {get;set;}
        public string indexNo {get; set;}
        public string product {get; set;}
        public List<SelectOption> optionsProducts{get; set;}
        public String productSel{get; set;}
        public string status {get; set;}
        public string diseLabel {get; set;}
        public string description {get; set;}
        public decimal cost {get; set;}
        public integer quantity {get; set;}
        public string supplier {get; set;}
        public string solution {get; set;}
    }

    /*
    *   Methods invoked after ADD PRODUCT button is clicked by user
    *   It creates new mock entry for Configuration list, where user is allowed to specify particular Pillar Definition
    */
    public void addProduct() {
        cConfigReq cr1 = new cConfigReq();
        cr1.productSel = '';
        cr1.optionsProducts = new List<SelectOption>();
        cr1.indexNo = String.valueOf(ind);
        cr1.status = 'Incomplete';
        ind++;
        for(cscfgc__Product_Definition__c p1 : pillars){
           cr1.optionsProducts.add(new SelectOption(p1.Id, p1.cscfgc__Label__c));
        }
        this.configProductList.add(cr1);
    }

    /*
    *   Methods invoked after CREATE CONFIGURATION icon is clicked next to the Configuration mock entry
    *   It saves previously created (by addProduct method) mock entry as a Product Configuration (with corresponding Site)
    */
    public PageReference createConf() {
        for(cConfigReq cr1 : this.configProductList){
            if(cr1.indexNo == selProdLine){
                cr1.product = mPillars.get(cr1.productSel).cscfgc__Label__c;
                Unify_Site__c us = new Unify_Site__c();
                try{
                    us = UnifyBatchConfigUpload.prepareSiteObjectBasedOnOppLoc(Id.valueOf(selSiteLine), selSolution, bundle.Id);
                } catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                    return null;
                }

                cscfgc__Product_Definition__c prodDef = mPillars.get(cr1.productSel);
                cscfgc.API_1.ApiSession apiSession = cscfgc.API_1.getApiSession(prodDef);

                apiSession.setBundle(bundle);
                cscfgc.ProductConfiguration config = apiSession.getRootConfiguration();
                config.getAttribute('A-End').setValue(us.Id);
                config.getAttribute('Solution').setValue(selSolution);
                apiSession.persistConfiguration();
                sobject sconf = apiSession.getConfiguration().getSObject();
                if(cr1.product == 'Maintenance' || cr1.product == 'Other' || cr1.product == 'Hardware'){
                    //set product configuration id parameter - required for DISE calculation
                    config.getAttribute('Configuration Id').setValue(sconf.Id);
                    apiSession.persistConfiguration();
                }
                config.getAttribute('Solution').setValue(selSolution);
                sconf.put('Unify_Site__c', us.Id);
                sconf.put('cscfgc__product_bundle__c', bundle.Id);
                sconf.put('Unify_Solution__c', selSolution);
                update sconf;
            }
        }
        configsListRefresh();
        return null;
    }

    /*
    *   Methods invoked after REMOVE icon is clicked next to the Configuration entry
    *   It deletes corresponding cscfgc__Product_Configuration__c based on passed selProdLine
    *   (which contains the configuration index no)
    */
    public PageReference delConf() {
        Integer internalInd = 0;
        Savepoint sp = Database.setSavepoint();
        try{
            for(cConfigReq cr1 : this.configProductList){
                if(cr1.indexNo == selProdLine){
                    if(cr1.pc != null && cr1.pc.Id != null){
                        cscfgc__Product_Configuration__c pc = new cscfgc__Product_Configuration__c(Id = cr1.pc.Id);
                        delete pc;
                    }
                    break;
                }
                internalInd ++;
            }
            this.configProductList.remove(Integer.valueOf(internalInd));
        } catch (Exception e){
            Database.rollback(sp);
            if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed: Problem with access rights. Please check whether Opportunity is locked or please contact with System Administrator.'));
                return null;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed! Reason: ' + e.getMessage()));
                return null;
            }
        }
        refreshBundleData();
        return null;
    }

    /*
    *   Methods invoked after SAVE button is clicked
    *   It saves (insert or updates) modified Product Bundles Name and RAG (other Product Bundle parameters are saved on the fly)
    */
    public PageReference save() {
        PageReference retPage;
        try{
            if(created){
                upsert bundle;
                retPage = new PageReference('/' + bundle.Id);
            } else {
                insert bundle;
                retPage = new PageReference('/apex/UnifyProductBundleBuilderAsync?id='+bundle.id);
            }
        } catch(Exception e){
            if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed: Problem with access rights. Please check whether Opportunity is locked or please contact with System Administrator.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed! Reason: ' + e.getMessage()));
            }
            return null;
        }
        retPage.setRedirect(true);
        return retPage;
    }

    /**
    *   Method triggered by user after clicking UPDATE or ADD button on Site Layer
    *   It is used to update Location record (if user is in isEdit mode) or creates new entry when chosenOpt == 'NEW'
    *   In case when steering parameter chosenOpt equals 'EXIST' then selected existing location is assigned to context of this Opportunity
    */
    public void saveSite(){
        Savepoint sp = Database.setSavepoint();
        boolean error = false;
        if(isEdit){
            try{
              update this.loc;
              this.sitesToRefresh = true;
            } catch (Exception e){
                ApexPages.addMessages(e);
                return ;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'Site [' + loc.Unify_Unique_Site_Name__c + '] has been succesfully updated.'));
        } else if(chosenOpt == 'NEW'){
            this.sitesToRefresh = true;
            if(loc.Unify_Unique_Site_Name__c == '' || loc.Unify_Unique_Site_Name__c == null){
                loc.Unify_Unique_Site_Name__c.addError('Site Name is required.');
                error = true;
            } else {
                Location__c[] locCheck = [select Id, Unify_Unique_Site_Name__c from Location__c where Unify_Unique_Site_Name__c = :loc.Unify_Unique_Site_Name__c and Account__c = :this.bundle.cscfgc__Opportunity__r.AccountId];
                if(locCheck != null && locCheck.size() > 0){
                    loc.Unify_Unique_Site_Name__c.addError('Site identified with this name already exist for this Customer. Please reuse it.');
                    error = true;
                }
            }
            if(!error && (loc.Unify_Validated_Postcode__c == '' || loc.Unify_Validated_Postcode__c == null)){
                loc.Unify_Validated_Postcode__c.addError('Post Code is mandatory.');
                error = true;
            }
            if(!error && loc.Unify_Unique_Site_Name__c != null && loc.Unify_Unique_Site_Name__c.toUpperCase() == UnifyConfig.CENTRAL_SITE_KEY_NAME.toUpperCase()){
                loc.Unify_Unique_Site_Name__c.addError('You can not create a Central Site manually. To add it use ADD CENTRAL SITE button presented on Product Bundle Builder page.');
                error = true;
            }
            if(error){
                return ;
            } else {
                try{
                    loc.Account__c = this.bundle.cscfgc__Opportunity__r.AccountId;
                    loc.Type__c = 'Installation';
                    insert loc;
                    Unify_Opportunity_Location__c opl = new Unify_Opportunity_Location__c();
                    opl.Name = loc.Unify_Unique_Site_Name__c;
                    opl.Location__c = loc.Id;
                    opl.Opportunity__c = this.bundle.cscfgc__Opportunity__c;
                    insert opl;
                } catch (Exception e){
                    Database.rollback(sp);
                    if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Operation failed: Problem with access rights. \n\nPlease check whether Opportunity is locked or please contact with System Administrator.'));
                    } else {
                        ApexPages.addMessages(e);
                    }
                    //ApexPages.addMessages(e);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                    return ;
                }
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'New Site [' + loc.Unify_Unique_Site_Name__c + '] has been added.'));
            loc = new Location__c();
        } else if(chosenOpt == 'EXIST'){
            Unify_Opportunity_Location__c[] ol2ins = new Unify_Opportunity_Location__c[]{};
            integer i = 0;
            for(LocationElement l1 : locsList){
                if(l1.selected){
                    ol2ins.add(new Unify_Opportunity_Location__c(Location__c = l1.loc.Id, Opportunity__c = bundle.cscfgc__Opportunity__c, Name = l1.loc.Unify_Unique_Site_Name__c));
                    i++;
                }
            }
            try {
                if(ol2ins.size() > 0){
                    insert ol2ins;
                    this.sitesToRefresh = true;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'No Location has been selected.'));
                    return ;
                }
            } catch(Exception e){
                Database.rollback(sp);
                if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Operation failed: Problem with access rights. \n\nPlease check whether Opportunity is locked or please contact with System Administrator.'));
                } else {
                    ApexPages.addMessages(e);
                }
                //ApexPages.addMessages(e);
                return ;
            }
            refreshListOfLocs();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'Selected ' + i + ' Location(s) has been added to this Opportunity.'));
        }
    }

    /*
    *   Method invoked after SYNC WITH OPPORTUNITY button is clicked
    *   Runs external, generic method on bundleOpportunitySync controller which synchronized Product Bundle configuration with Opportunity
    */
    public PageReference sync(){
        refreshBundleData();
        PageReference retPage;
        Savepoint sp = Database.setSavepoint();
        boolean uploadCheck = getIsUploading();
        try{
            if(uploadCheck){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed! Configuration Upload procedure is in progress. You are not allowed to Synchronize data with Opportunity till upload is finished.'));
               Database.rollback(sp);
               return null;
            }
            if(bundle.cscfgc__Bundle_Status__c == 'Valid'){
                retPage = new PageReference('/apex/bundleOpportunitySync?id='+bundle.id);
                retPage.setRedirect(true);
                return retPage;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'This bundle contains errors and cannot be synchronised with an Opportunity.'));
                return null;
            }
        } Catch(exception e){
            if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed: Problem with access rights. Please check whether Opportunity is locked or please contact with System Administrator.'));
                Database.rollback(sp);
                return null;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed! Reason: ' + e.getMessage()));
                Database.rollback(sp);
                return null;
            }
        }
    }

    /*
    *   Method invoked when CANCEL button is clicked
    *   It redirects user to Product Bundle record page (in view mode)
    *   changes provided to PB name or RAG are not saved
    */
    public PageReference cancel() {
        PageReference retPage;
        if(created)
            retPage = new PageReference('/' + bundle.Id);
        else
            retPage = new PageReference('/' + opp.Id);
        retPage.setRedirect(true);
        return retPage;
    }

    /*
    *   Method invoked when ADD CENTRAL SITE button is clicked
    *   It creates Central Site entry through generic UnifyCommonMethods.addCentralSite method
    */
    public void addCentral(){
        String res = UnifyCommonMethods.addCentralSite(this.opp.Id);
        if(res == 'OK'){
            sitesListRefresh();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, res));
        }
    }
}