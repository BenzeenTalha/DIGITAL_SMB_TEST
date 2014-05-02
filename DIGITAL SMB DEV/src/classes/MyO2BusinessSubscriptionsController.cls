/*
    Main controller subscription selection and start of guided journeys
 */

public with sharing class MyO2BusinessSubscriptionsController {

    static final Integer PAGE_SIZE = 50;
    static final Integer QUERY_LIMIT = 51;
    static final Integer SMB_QUERY_LIMIT = 200;

    static final string FIELD_LIST = ' Id, Name, Network_Serial_No__c, Tariff_Code__c, AC_Container__r.DISE_Account_No__c,Tariff_Description__c, Subscription_Name__c, Subscription_ID__c, Network_Code__c';

    public static Boolean PUKCodeFlag = false;
    public static Boolean BoltOnsFlag = false;
    public Boolean showResult {get;set;}    
    public String filterNames { get; set; }
    public String filterNumbers { get; set; }
    public List<SubscriptionWrapper> subscriptions {get; set;}
    private final List<String> adminChangeNetworkCodes = new List<String> {
        Label.MY_O2_BUSINESS_FIXED_NWCODE,
        Label.MY_O2_BUSINESS_BBAND_NWCODE,
        Label.MY_O2_BUSINESS_CDIG_NWCODE,
        Label.MY_O2_BUSINESS_VDIG_NWCODE};
    private final List<String> standardNetworkCodes = new List<String> {
            Label.MY_O2_BUSINESS_CDIG_NWCODE,
            Label.MY_O2_BUSINESS_VDIG_NWCODE};

    public List<AC_Subscription__c> selectedSubscriptions {get; set;}
    public List<AC_Subscription_Extra__c> selectedExtraSubscriptions {get; set;}
    public List<AC_Subscription_Extra__c> errorExtraSubscriptions {get; private set;}
    public integer errorRetryCount {get; private set;}    
    public PageReference pageName{get; set;}

    public String pageValue{get;set;}

    public List<AC_Subscription__c> smbSubscriptions {get; private set;}

    public integer stepNumber{get; set;}
    public Boolean smbUser{get; set;}

    public String selectedValue { get; set;}

    public String tariffCode {get;set;}

    public String subscriptionId { get; set;}

    //private String  journeyType ='sim';

    ApexPages.StandardSetController con;


    //-------Start------Variables declaration related to Tariff Functionality

    public Integer numOfBBSubscription {get; set;}
    public Integer numOfMobSubscription  {get; set;}
    public Integer numOfFixedSubscription {get; set;}

    public List<AC_Subscription__c> mobileSubscriptions {get; set;}
    public List<AC_Subscription__c> broadBandSubscriptions {get; set;}
    public List<AC_Subscription__c> fixedSubscriptions {get; set;}
    public List<AC_Subscription__c> selectedTariffSubscriptions {get; set;}
    public List<AC_Subscription__c> specificTriffSubsc {get; set;}

    public List<String> listString =  new List<String>();

    public String tariffPageValue {get; set;}
    public List<SubscriptionWrapper> tarffSubscWrp {get; set;}
    private String allSubscDetails = '';
    //-------End----declaration of variables for Tariff Functionality

    public Integer adminSelectdSubs{get; set;}

    public Integer barSelectdSubs{get; set;}
	public Boolean displayMessages{get; set;}
	
    public MyO2BusinessSubscriptionsController() {
    	if (!Test.isRunningTest()){
    		CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
    	}
    	displayMessages = true;
        system.debug(' this.pageValue--constructor------'+ this.pageValue);
        showResult = false;
        subscriptions = null;
        stepNumber= 1;
        errorRetryCount = 0;
        //Added - all tariff
        allSubscDetails = '';
        smbUser= CaseUtils.checkLoginUserSegment();
        editableBoltOnCodes = new Set<String>();
        try {
            editableBoltOnCodes.addAll(Label.MO2B_EDITABLE_BOLTON_CODES.split(','));
        } catch (Exception e) {
            system.debug('Unable to fetch editable bolt on codes.');
        }
		String selectedId = ApexPages.currentPage().getParameters().get('subId');
		system.debug('myo2businesssubscriptionscontroller, selected id from parameter - ' + selectedId);
		if (selectedId != null) {
			filterNames = ApexPages.currentPage().getParameters().get('filterNames');
			filterNumbers = ApexPages.currentPage().getParameters().get('filterNumbers');
			selectedValue = selectedId;
			BoltOnsFlag = true;
			displayMessages = false;
			advancedFilter();
			displayMessages = true;
			system.debug('myo2businesssubscriptionscontroller, subscriptions' + subscriptions);
			system.debug('myo2businesssubscriptionscontroller, before save selections' + selectedId);
			saveSelections();
			system.debug('myo2businesssubscriptionscontroller, after save selections' + selectedId);
		}
        //getTariffSubscriptionsDetails();
        //IsSubscriptionRefreshed = false;       
        // journeyType = apexpages.currentpage().getparameters().get('journey');
        //system.debug('journey name is :' + journeyType);
    }

    // Wrapper class to store user selection of subscriptions
    public class SubscriptionWrapper {
        public Boolean isSelected {get;set;}
        public AC_Subscription__c subscription {get;set;}

        //  public String DISEAccount {get;set;}

        public SubscriptionWrapper(AC_Subscription__c subscription){
            this.subscription = subscription;
            this.isSelected = false;
            // this.DISEAccount = subscription.AC_Container__r.DISE_Account_No__c;
        }
    }    

    /** public PageReference redirectJourney(){

     if(journeyType != null && journeyType =='admin'){

            system.debug('before journey');
            return goToSMBAdminChanges();
            //system.debug('after journey');

         }else{
           return null;

         }


   } */

    // FORM ACTIONS
    public PageReference clearFilter() {
        filterNames = '';
        filterNumbers = '';
        if(subscriptions!=null) subscriptions.clear();
        return null;
    }
    
    private String buildNetworkCondFromList(List<String> condList){
        Boolean first = true;
        String networkCond = ' ';
        for (String code: condList) {
            if (first) {
                first = false;
                networkCond += 'Network_Code__c =\'' + code + '\'';
            } else {
                networkCond += ' OR ' + 'Network_Code__c =\'' + code + '\'';
            }
        }
        networkCond += ' ';
        return networkCond;
    }
    
    public void autoFilter() {
        if (autoFilter) {
            advancedFilter();
        }
    }
    
    public PageReference advancedFilter() {
        String smbAdminChk = apexpages.currentpage().getparameters().get('smbAdmin');
        system.debug('smbAdminChk ----------'+smbAdminChk);
        String mobileSubsFlow = apexpages.currentpage().getparameters().get('mobileSubsFlow');
        system.debug('mobileSubsFlow----------'+mobileSubsFlow);
        String allSubscDetails =ApexPages.CurrentPage().getParameters().get('allDetailsCtxt');
        system.debug('allSubscDetails----------'+allSubscDetails);
        showResult = true;
        System.debug('**showResult**'+showResult);
        String query = '';
        system.debug('filterNames----------------'+filterNames);
        system.debug('filterNumbers--------------'+filterNumbers);
        if (filterNames == null) {
            filterNames = '';
        }
        if (filterNumbers == null) {
            filterNumbers = '';
        }
        String filterNamesStr = parseCSVintoWhereClause('Subscription_Name__c', String.escapeSingleQuotes(filterNames));
        String filterNumbersStr = parseCSVintoWhereClause('Network_Serial_No__c', cleanNumbers(String.escapeSingleQuotes(filterNumbers)));

        system.debug('filterNamesStr----------------'+filterNamesStr);
        system.debug('filterNumbersStr---------------'+filterNumbersStr);

        if(filterNamesStr!='' || filterNumbersStr!='') {
            String filter = '';
            query = 'select '+FIELD_LIST+' from AC_Subscription__c where ';
            if(filterNamesStr != '') {

                if(filterNamesStr!='' && filterNumbersStr!='' && (smbAdminChk != null || allSubscDetails != null )){
                    filter = '(('+ filterNamesStr; 
                }else if(filterNamesStr!='' && filterNumbersStr =='' && smbAdminChk == null){
                    filter = '('+ filterNamesStr; 
                }
                else{
                    filter = '((' + filterNamesStr; 
                }
            }
            if(filter == '') { 
                filter = filterNumbersStr; 
            }else if(filterNamesStr!='' && filterNumbersStr =='' &&  smbAdminChk == null){
                filter+= ')';
            }else if(filterNamesStr!='' && filterNumbersStr =='' &&  (smbAdminChk != null || allSubscDetails != null)){
                filter+= '))';

            }
            else if(filterNamesStr!='' && filterNumbersStr!='') { 
                system.debug('filter---@@@@'+filter);
                if(smbAdminChk != null){
                    filter += ' OR ' + filterNumbersStr + '))';
                    system.debug('smbAdminChk filter---'+filter);
                }else{
                    filter += ' OR ' + filterNumbersStr + '))';
                    system.debug('filter---$$$$'+filter);
                }
            }
            if(mobileSubsFlow != null){
                filter += ' AND ( ' 
                        + buildNetworkCondFromList(standardNetworkCodes)
                        +')';
            } else if(smbAdminChk != null ||  allSubscDetails != null) {
                filter += ' AND ( ' 
                        + buildNetworkCondFromList(adminChangeNetworkCodes)
                        +')';
            } else {
                filter += ' AND ( ' 
                    + buildNetworkCondFromList(standardNetworkCodes)
                    +')';
            }
            system.debug('filter-------->>>>>'+filter);
            query += filter + ' limit '+QUERY_LIMIT;
            system.debug('$$$$$query--------------------------'+query);
            runQuery(query);
            system.debug('$$$query is  ------:' + query);
        } else  if(smbAdminChk != null ||  allSubscDetails != null){
            runQuery('select '+FIELD_LIST+' from AC_Subscription__c where' 
                    + buildNetworkCondFromList(adminChangeNetworkCodes)
                    + 'limit' + ' ' +QUERY_LIMIT);
            system.debug('----query is :' + query);
        }else {
            runQuery('select '+FIELD_LIST+' from AC_Subscription__c where' 
                    + buildNetworkCondFromList(standardNetworkCodes)
                    + 'limit' + ' ' +QUERY_LIMIT);
            system.debug('----query is :' + query);
        }
        return null;
    }
    // NAVIGATION METHODS
    public PageReference goToAdminChanges() {
        saveSelections();
        adminSelectdSubs = selectedSubscriptions.size();
        CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
        try{
            system.debug('*** selected subscription is :' + selectedSubscriptions);
            CaseUtils.processSubscriptions(selectedSubscriptions);
        } catch(CaseUtils.FutureLimitExceededException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
            System.debug('My O2 Business - Daily future methods calls limit exceeded.');
            return null;
        }
        return Page.MyO2BusinessRequestAdminChange;
    }



    public PageReference goToBarChanges() {
        saveSelections();
        barSelectdSubs = selectedSubscriptions.size();
        CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
        try{
            CaseUtils.processSubscriptions(selectedSubscriptions);
        } catch(CaseUtils.FutureLimitExceededException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
            System.debug('My O2 Business - Daily future methods calls limit exceeded.');
            return null;
        }
        return Page.MyO2BusinessRequestBarChange;
    }

    public PageReference goToSMBPUKCodeChanges() {
        system.debug('Inside PUK Call');
        PUKCodeFlag = true;
        saveSelections();


        CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
        try{
            System.debug('**selectedSubscriptions**'+selectedSubscriptions);
            CaseUtils.processSubscriptions(selectedSubscriptions);
        } catch(CaseUtils.FutureLimitExceededException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
            System.debug('My O2 Business - Daily future methods calls limit exceeded.');
            return null;
        }
        return Page.MyO2BusinessRequestPUKCode;

    }


    public PageReference goToSMBBarChanges() {
        //saveSelections();

        this.pageValue = Label.ENTERPRISE_BAR_MANAGEMENT_PAGE;
        getSubscriptions(this.pageValue);

        if(smbSubscriptions != null && smbSubscriptions.size() > Integer.valueOf(System.label.Subscription_Limit)){

            PageReference ref = Page.SMBManageSearchPage;

            //ref.getParameters().put('smbAdmin', 'networkCodeChk');
            ref.setredirect(false);
            system.debug('page ref is :' +ref);

            return ref; 

        }else{

            // barSelectdSubs = smbSubscriptions.size();
            CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
            try{
                CaseUtils.processSubscriptions(smbSubscriptions);
            } catch(CaseUtils.FutureLimitExceededException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
                System.debug('My O2 Business - Daily future methods calls limit exceeded.');
                return null;
            }


            return Page.MyO2BusinessRequestBarChange;

        }

    }

    public PageReference goToSMBSimSwapChanges() {
        //saveSelections();

        this.pageValue = Label.ENTERPRISE_SIM_SWAP_PAGE;
        getSubscriptions(this.pageValue);

        if(smbSubscriptions != null && smbSubscriptions.size() > Integer.valueOf(System.label.Subscription_Limit)){

            PageReference np = Page.SMBManageSearchPage; 
            np.setRedirect(false); 
            return np;

            //return Page.SMBManageSearchPage;

        }
        else{

            CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
            try{
                CaseUtils.processSubscriptions(smbSubscriptions);
            } catch(CaseUtils.FutureLimitExceededException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
                System.debug('My O2 Business - Daily future methods calls limit exceeded.');
                return null;
            }

            return Page.MyO2BusinessRequestSimSwap;

        }


    }

    public PageReference goToSMBAdminChanges() {

        System.debug('Inside Admin change');
        this.pageValue = Label.ENTERPRISE_ADMINCHANGE_PAGE;
        getSubscriptions(this.pageValue);

        system.debug('page value in method is :' +pageValue);

        if(smbSubscriptions != null && smbSubscriptions.size() > Integer.valueOf(System.label.Subscription_Limit)){
            //PageReference ref = new PageReference('/apex/SMBManageSearchPage');
            PageReference ref = Page.SMBManageSearchPage;

            ref.getParameters().put('smbAdmin', 'networkCodeChk');
            ref.setredirect(false);
            system.debug('page ref is :' +ref);

            return ref; 
            //return Page.SMBManageSearchPage;

        }
        else{
            adminSelectdSubs = smbSubscriptions.size();
            CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
            try{
                CaseUtils.processSubscriptions(smbSubscriptions);
            } catch(CaseUtils.FutureLimitExceededException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
                System.debug('My O2 Business - Daily future methods calls limit exceeded.');
                return null;
            }
            system.debug('page ref one is :' +Page.MyO2BusinessRequestAdminChange);
            return Page.MyO2BusinessRequestAdminChange;

        }


    }

    public PageReference goToPUKCodeChanges(){
        PUKCodeFlag = true;
        this.pageValue = Label.ENTERPRISE_PUKCODE_PAGE;
        getSubscriptions(this.pageValue);
        System.debug('**pageValue**'+pageValue);
        System.debug('subscription Size'+smbSubscriptions.size());
        if(smbSubscriptions != null && smbSubscriptions.size() > Integer.valueOf(System.label.Subscription_Limit)){
            System.debug('first');            
            return Page.SMBManageSearchPage;

        }
        else{
            PUKCodeFlag = true;
            system.debug('PUKCodeFlag in main controller'+PUKCodeFlag);
            System.debug('**smbSubscriptions**'+smbSubscriptions);
            CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
            try{
                CaseUtils.processSubscriptions(smbSubscriptions);
            } catch(CaseUtils.FutureLimitExceededException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
                System.debug('My O2 Business - Daily future methods calls limit exceeded.');
                return null;
            }

            return Page.MyO2BusinessRequestPUKCode;

        }

    }
    
    private Boolean BoltOnIsEditable() {
        String tariffCode = selectedSubscriptions[0].Tariff_Code__c;
        System.debug('go to bolt on, tariff code = ' + tariffCode);
        if (editableBoltOnCodes.contains(tariffCode)){
            List<String> packageList = new List<String>();
            //List<AC_Subscription_Extra__c> temp = [SELECT Package_Code__c FROM AC_Subscription_Extra__c WHERE AC_Subscription__c IN :selectedSubscriptions];
            if (selectedExtraSubscriptions != null) {
	            for (AC_Subscription_Extra__c ase : selectedExtraSubscriptions) {
	            	if (ase.Package_Code__c != null){
	                	packageList.addAll(ase.Package_Code__c.split(','));
	            	}
	            }
            }
            Integer matchingRDNum = [SELECT count() FROM RD_Tariff_Package_Service__c WHERE Tariff_Code__c =: tariffCode
                                     AND Package_Code__c =: packageList];
            System.debug('go to bolt on, package code list = ' + packageList);
            System.debug('go to bolt on, package code list size = ' + packageList.size());
            System.debug('go to bolt on, matching package number = ' + matchingRDNum);
            if (matchingRDNum == 0) { 
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
    }
    
    public PageReference goToBoltOnsRequest() {
        system.debug('Inside boltOnsRequeset');
        BoltOnsFlag = true;
        saveSelections();
        system.debug('BoltOnsFlag in main controller111'+BoltOnsFlag);
        CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
        try{
            CaseUtils.processSubscriptions(selectedSubscriptions);
        } catch(CaseUtils.FutureLimitExceededException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
            System.debug('My O2 Business - Daily future methods calls limit exceeded.');
            return null;
        } 
        try {
            Boolean boltOnEdit = BoltOnIsEditable();
            if (boltOnEdit) {
                return Page.MyO2BusinessRequestBoltOns;
            } else {
                return Page.MyO2BusinessRequestBoltOnsNonEditable;
            }
        } catch (System.ListException le) {
            System.debug('My O2 Business - No mobile phone subscriptions found.');
            return Page.MyO2BusinessRequestBoltOns;
        }
    } 

    Boolean autofilter = false;
    private Set<String> editableBoltOnCodes = new Set<String>(); 
    
    public PageReference goToSMBBoltOnsChanges(){
        BoltOnsFlag = true;
        system.debug('BoltOnsFlag in main controller'+BoltOnsFlag);
        this.pageValue = Label.ENTERPRISE_BoltOns_PAGE;
        getSubscriptions(this.pageValue);

        if(smbSubscriptions != null && smbSubscriptions.size() > 1){
            if (smbSubscriptions.size() >= Integer.valueOf(Label.MY_O2_BUSINESS_BOLT_ON_LIMIT)) {
                return Page.SMBBoltOnsRequestSearch;
            } else {
                autoFilter = true;
                return Page.SMBBoltOnsRequestSearch;
            }
        }else{
            BoltOnsFlag = true;
            CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
            try{
                CaseUtils.processSubscriptions(selectedSubscriptions);
            } catch(CaseUtils.FutureLimitExceededException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
                System.debug('My O2 Business - Daily future methods calls limit exceeded.');
                return null;
            }
            try {
                Boolean boltOnEdit = BoltOnIsEditable();
                if (boltOnEdit) {
                    return Page.MyO2BusinessRequestBoltOns;
                } else {
                    return Page.MyO2BusinessRequestBoltOnsNonEditable;
                }
            } catch (System.ListException le) {
                System.debug('My O2 Business - No mobile phone subscriptions found.');
                return Page.MyO2BusinessRequestBoltOns;
            }
        }
    }
    
    public PageReference goToSimSwap() {
        saveSelections();

        system.debug('selected subscrption is :' + selectedSubscriptions.size());
        CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
        try{
            CaseUtils.processSubscriptions(selectedSubscriptions);
        } catch(CaseUtils.FutureLimitExceededException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
            System.debug('My O2 Business - Daily future methods calls limit exceeded.');
            return null;
        }
        return Page.MyO2BusinessRequestSimSwap;
    }  

    // Execute the query
    private ApexPages.StandardSetController runQuery(String query) {
        if (displayMessages == null) {
        	displayMessages = true;
        }
        if(query.length()>10000) {
            //Display or handle error of query string > 10k characters
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The filter has too many filter items, please refine your query and try again.'));
        }
        system.debug('runQuery---query-----'+query);
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        con.setPageSize(PAGE_SIZE);
        subscriptions = new List<SubscriptionWrapper>();

        if(con.getResultSize()==0) {
        	if (displayMessages) {
            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No matching subscribers found'));
        	}
            return con;
        } else if(con.getResultSize()>PAGE_SIZE) {
        	if (displayMessages) {
            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'More than ' + PAGE_SIZE + ' records were found, please refine your search'));
        	}
        }

        for(AC_Subscription__c acSub : (List<AC_Subscription__c>)con.getRecords()) {
            subscriptions.add(new SubscriptionWrapper(acSub));


        }
        system.debug('$$$$$  subscriptions-----'+subscriptions); 

        return con;
    }

    // Move the selected subscriptions to a selected subscription list
    private void saveSelections() {
        selectedSubscriptions = new List<AC_Subscription__c>();

        if(allSubscDetails != null && allSubscDetails != ''){
            fixedSubscriptions = new List<AC_Subscription__c>();
            mobileSubscriptions = new List<AC_Subscription__c>();
            broadBandSubscriptions = new List<AC_Subscription__c>();

        }

        for(SubscriptionWrapper sw: subscriptions) {

            System.debug('**BoltOnsFlag**'+BoltOnsFlag);
            if(BoltOnsFlag){
                system.debug('selected subscription id in bolts Ons :' + sw.subscription.Id);
                system.debug('selected value in bolts Ons :' + selectedValue);
                if(selectedValue.equals(sw.subscription.Id)) {
                    selectedSubscriptions.add(sw.subscription);
                }
            }else if(allSubscDetails != null && allSubscDetails != '' && sw.isSelected){
                //system.debug('$$$$sw.DISEAccount----$$$$$'+sw.DISEAccount);
                selectedSubscriptions.add(sw.subscription);
                if(sw.subscription.Network_Code__c == Label.MY_O2_BUSINESS_BBAND_NWCODE){
                    broadBandSubscriptions.add(sw.subscription);
                }else if(sw.subscription.Network_Code__c == Label.MY_O2_BUSINESS_FIXED_NWCODE){
                    fixedSubscriptions.add(sw.subscription);
                }else if(sw.subscription.Network_Code__c == Label.MY_O2_BUSINESS_CDIG_NWCODE || sw.subscription.Network_Code__c == Label.MY_O2_BUSINESS_VDIG_NWCODE){
                    mobileSubscriptions.add(sw.subscription);

                }
            }else{
                system.debug('selected value is :' + sw.isSelected);
                if(sw.isSelected) {
                    system.debug('is selected' +  sw.subscription);
                    selectedSubscriptions.add(sw.subscription);
                }
            }
        }
    }


    // UTIL METHODS

    // Given a field name and CSV delimited string, construct a where clause where each value can be searched with wild cards
    // e.g. parseCSVintoWhereClause("MyField__c", "X, Y, X")
    // => returns "(MyField__c like '%X%') OR (MyField__c like '%Y%') OR (MyField__c like '%Z%'))"
    private static String parseCSVintoWhereClause(String fieldName, String value) {
        // replace new line and return characters with a comma, as pasting from excel uses the new line character as a separator
        value = value.replaceAll('\n|\r',',');
        // remove any repeating commas
        value = value.replaceAll('(,)\\1+',',');
        // remove any starting or ending commas
        value = value.replaceAll('^,|,$','');
        if(value.length()==0) {
            value = '';
        } else if(value.indexOf(',')>-1) {
            // remove duplicates
            Set <String> uniqueSet = new Set <String>();
            for(String s : value.split(',')) {
                uniqueSet.add(s);
            }
            value = ' (';
            Integer i = 0;
            for(String s : uniqueSet) {
                value += fieldName+' like \'%' + s.trim() + '%\'';
                i++;
                if(i!=uniqueSet.size()) value += ' OR ';
            }
            value += ')';
        } else {
            value = ' ('+fieldName+' like \'%'+value.trim()+'%\')';
        }
        return value;
    }

    // Given a number strip non numberic characters
    private static String cleanNumbers (String numbers) {
        // replace new line and return characters with a comma, as pasting from excel uses the new line character as a separator
        numbers = numbers.replaceAll('\n|\r',',');
        // remove non digits except commas
        Pattern numberPattern = Pattern.compile('[^\\d,]');
        String pnumber = numberPattern.matcher(numbers).replaceAll('');
        return pnumber;
    }

    //Case
    public Case newCase{get; set;}

    //Case line items
    public List<mo2b_CaseLineItem__c> caseLineItems{get; set;}

    //Save case and line items
    public void CreateCase(){
        try{
            User currentUser = [SELECT Id, AccountId, ContactId, Name, Email FROM User WHERE Id = :userInfo.getUserId()][0];

            System.debug('AdminChangaeFlag='+ MyO2BusinessRequestAdminChangeController.AdminChangeFlag);

            //Insert case
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            newCase.setOptions(dmo);
            newCase.RecordTypeId = Cache.RecordTypeId('Case.' + CaseUtils.CASE_RECORD_TYPE);
            newCase.Origin = CaseUtils.CASE_ORIGIN;
            newCase.Status = CaseUtils.IN_PROGRESS;
            //newCase.complexity__c=System.label.SMB_Case_Complexity;
            newCase.Specific_Case_Instructions__c = !string.isBlank(newCase.Description);

            system.debug('string.isBlank(newCase.Description)------------'+string.isBlank(newCase.Description));
            system.debug('newCase.Specific_Case_Instructions__c----------'+newCase.Specific_Case_Instructions__c);

            if(currentUser.AccountId != null) newCase.AccountId = currentUser.AccountId;
            if(currentUser.ContactId != null) newCase.ContactId = currentUser.ContactId;
            if(!string.isBlank(currentUser.Email)) newCase.E_mail__c = currentUser.Email;
            insert newCase;

            system.debug('caseLineItems insertion started---'+caseLineItems.size());
            //Insert case line items
            for(mo2b_CaseLineItem__c li : caseLineItems){
                li.Start_Date__c = Date.today();
                li.Case__c = newCase.Id;
            }
            system.debug('CreateCase () -----caseLineItems-------------'+caseLineItems);
            system.debug('CreateCase () -----caseLineItems---size----------'+caseLineItems.size());
            insert(caseLineItems);
            system.debug('caseLineItems insertion done--'+caseLineItems);

            //Process case

            if(!newCase.Specific_Case_Instructions__c){
                system.debug('CreateCase --- processing cases..newCase----------'+newCase);
                system.debug('Before update---');
                newCase = CaseInputProcessor.processCase(newCase);
                System.debug('Before Call');
                System.debug('**Description>>>>'+newCase.Description);
                if(newCase.Description == null || newCase.Description ==''){
                    System.debug('After Call processCases$$$$$$$');
                    CaseUtils.processCases(new List<Id>{newCase.Id});
                }
            }
        }catch(Exception e){
            System.debug('create case exception ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MO2B_ERROR_GUIDED_JOURNY));
            throw(e);
        } 

    }

    //Is Edit Mode
    public boolean IsEditMode{get; set;}

    public PageReference FinishEdit(){
        system.debug('FinishEdit---method called-');
        if (errorExtraSubscriptions != null){
	        errorExtraSubscriptions.clear();
        }
        IsEditMode = false;
        stepNumber = 3;
        return null;
    }

    public PageReference Cancel(){
        system.debug('value of smb user is :' + smbUser);

        PageReference ref =  null;

        if(smbUser){

            ref=new PageReference('/apex/smbhome');
        }else{

            ref=new PageReference('/apex/MyO2BusinessHome');
        }

        ref.setredirect(true);
        return ref;
    }


    //public boolean IsSubscriptionRefreshed{get; set;}

    public void getSubscriptions(){
        /**  User currentUser = [SELECT Id, AccountId, ContactId, Name, Email FROM User WHERE Id =: userInfo.getUserId()];
      List <AC_Container__c> acContainer  = [SELECT Subscription_Container_ID__c from AC_Container__c where SFAccountId__c =: currentUser.AccountId];
      List<String> containerList = new List<String>();
      if(acContainer!= null){
            for(AC_Container__c acContaineVal:acContainer){
                containerList.add(acContaineVal.Subscription_Container_ID__c);
            }
      }
      System.debug('**containerListvalue**'+containerList);
      smbSubscriptions = [select Subscription_ID__c, Subscription_Name__c from AC_Subscription__c where Subscription_Container_ID__c in : containerList ]; */

        smbSubscriptions =  [SELECT Id, Name, Network_Serial_No__c, Tariff_Code__c, Tariff_Description__c, Subscription_Name__c, Subscription_ID__c, AC_Container__r.DISE_Account_No__c ,Network_Code__c from AC_Subscription__c where Network_Code__c in ('CDIG','VDIG') limit :SMB_QUERY_LIMIT];
        // smbSubscriptions =  [SELECT Id, Name, Network_Serial_No__c, Tariff_Code__c, Tariff_Description__c, Subscription_Name__c, Subscription_ID__c  from AC_Subscription__c  limit :1];
        selectedSubscriptions = smbSubscriptions;
        System.debug('**selectedSubscriptionsresult**'+selectedSubscriptions);
        pageName = Page.smbhome;
        system.debug('page name is : ' + pageName);
    }

    private void getSubscriptions(String pageValue) {
        
        System.debug('get subscriptions with page value, pageValue = ' + pageValue);
        if (pageValue == Label.ENTERPRISE_ADMINCHANGE_PAGE) {
            System.debug('get subscriptions with page value, admin change');
            
            smbSubscriptions =  [SELECT Id, Name, Network_Serial_No__c, Tariff_Code__c, Tariff_Description__c, Subscription_Name__c, Subscription_ID__c, AC_Container__r.DISE_Account_No__c ,Network_Code__c from AC_Subscription__c where Network_Code__c in :adminChangeNetworkCodes limit :SMB_QUERY_LIMIT];
        } else {
            
            System.debug('get subscriptions with page value, not admin change');
            smbSubscriptions =  [SELECT Id, Name, Network_Serial_No__c, Tariff_Code__c, Tariff_Description__c, Subscription_Name__c, Subscription_ID__c, AC_Container__r.DISE_Account_No__c ,Network_Code__c from AC_Subscription__c where Network_Code__c in :standardNetworkCodes limit :SMB_QUERY_LIMIT];
        }
        selectedSubscriptions = smbSubscriptions;
        System.debug('get subscriptions with page value, subscriptions = '+selectedSubscriptions);
        pageName = Page.smbhome;
        system.debug('page name is : ' + pageName);
    }


    // This function is used for SMB Journey to decide  
    public PageReference continueSMBJourney(){

        PageReference reference = null;
        system.debug('Selected Value in continue  '+ selectedValue);
        system.debug('page value is :' + this.pageValue);
        system.debug('serach: aubscription list is :' + this.subscriptions.size());
        if(pageValue != null && pageValue == Label.ENTERPRISE_SIM_SWAP_PAGE){
            reference = this.goToSimSwap();
        } else if(pageValue == Label.ENTERPRISE_BAR_MANAGEMENT_PAGE){
            reference = this.goToBarChanges();
        }else if (pageValue ==Label.ENTERPRISE_ADMINCHANGE_PAGE){
            //reference = new PageReference('/apex/MyO2BusinessRequestAdminChange');
            reference = this.goToAdminChanges();
            //reference.setRedirect(false);
        }else if (pageValue ==Label.ENTERPRISE_PUKCODE_PAGE){
            reference = this.goToSMBPUKCodeChanges();
        }else if (pageValue ==Label.ENTERPRISE_BoltOns_PAGE){
            reference = this.goToBoltOnsRequest();
	        reference.getParameters().put('subId', selectedValue);
	        reference.getParameters().put('filterNames', filterNames);
	        reference.getParameters().put('filterNumbers', filterNumbers);
	        reference.setRedirect(true);
        }else if(pageValue == Label.MY_O2_TARIFF_MANAGEMENT_PAGE || pageValue == Label.MY_O2_VIEW_ALL_CONTRACT_PAGE){
            system.debug('inside eligibility');

            reference = this.goToSMBTariffRenewalDetails();
        }
        system.debug('continue smb journey, reference = ' + reference);
        return reference;
    }
    
    public Integer SubscriptionsSize {get;set;}
    public boolean IsSubscriptionExtraRefreshed {get;set;}
    
    public void SaveSelectionAndGetExtras() {
    	CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
    	BoltOnsFlag = true;
    	saveSelections();
    	IsSubscriptionExtraRefreshed = GetSubscriptionExtras();
    }
    
    public boolean GetSubscriptionExtras(){
        boolean result = false;
        system.debug('get subscription extras, selected subscription is :' + selectedSubscriptions);
        system.debug('**CalloutDateTime**'+CalloutDateTime);

        if((selectedSubscriptions == null) || (selectedSubscriptions.size() == 0)){
            getSubscriptions(this.pageValue);
        }
        SubscriptionsSize = selectedSubscriptions.size();
        /*if(CalloutDateTime == null){
            CalloutDateTime = DateTime.now().addMinutes(-1 * Integer.valueOf(Settings.SubscriptionRefreshMinutes__c));
        }*/
        
        System.debug('**selectedSubscriptions**'+selectedSubscriptions);
        //Get all subscription extras for selected subscriptions
        List<AC_Subscription_Extra__c> temp = [SELECT AC_Subscription__c, AC_Subscription__r.Subscription_Name__c, AC_Subscription__r.Subscription_ID__c, AC_Subscription__r.Tariff_Description__c,AC_Subscription__r.Tariff_Code__c, AC_Subscription__r.Network_Serial_No__c, AC_Subscription__r.Customer_Cost_Centre__c, AC_Subscription__r.Agreement_ID__c , Name, Callout_Error__c,  IMEI_Number__c, Last_Amended_Date_Customer_Details__c, Last_Amended_Date_Serial_Numbers__c, Last_Callout_Date__c, LastModifiedById, LastModifiedDate, Id, SIM_Number__c, Subscription_ID__c, SystemModstamp, Term_of_Contract__c,
                                               Full_Bar__c,International__c,GPRS_Bar__c,Device_Bar__c,International_Bar__c,Premium_Call_Bar_Display__c,Roaming_Call_Bar_Display__c,IMEI_Bar__c,GPRS__c,Fullbar_with_no_msg__c,Fullbar_with_msg__c,Stolen_Bar__c,Add_full_international_access__c,Bars_h_s_for_calls_from_o_s_UK__c,
                                               International_Call_Bar_Display__c,Internet_premium_call_bar__c,International_prem_roam_local__c,International_premium_roam__c,Add_Premium_Adult_Bar__c,Adult_and_Chat_Bar__c,Adult_Bar__c,Chat_Bar__c,O2_only_roam_bar__c,Premium_rate_call_bar__c,PUK_Code__c,Contractual_Bolt_Ons__c,Other_Bolt_Ons__c,Package_Code__c,Service_Code__c,DISE_Account_No__c,Mobile_Number__c,Subscription_Name__c,Effective_Date__c
                                               FROM AC_Subscription_Extra__c WHERE AC_Subscription__c IN :selectedSubscriptions];
        System.debug('get subs extra, counter = ' + [SELECT COUNT(Id), AC_Subscription__c FROM AC_Subscription_Extra__c WHERE AC_Subscription__c IN :selectedSubscriptions GROUP BY AC_Subscription__c ORDER BY COUNT(Id) DESC]);
        System.debug('**temp**'+temp);
        System.debug('**tempSize**'+temp.size());
        System.debug('**subscriptionSize**'+selectedSubscriptions.size());

        if(temp.size() == selectedSubscriptions.size()){
            selectedExtraSubscriptions = new List<AC_Subscription_Extra__c>();
            errorExtraSubscriptions = new List<AC_Subscription_Extra__c>();
            for(AC_Subscription_Extra__c acExtra : temp){
                //Compare Last Callout times 
                if(acExtra.Last_Callout_Date__c != null){
                    if(test.isrunningtest()){ 
                        selectedExtraSubscriptions.add(acExtra);
                    }else{
                        system.debug('acExtra.Last_Callout_Date__c'+acExtra.Last_Callout_Date__c.getTime());
                        system.debug('CalloutDateTime'+CalloutDateTime.getTime());
                        system.debug('Difference'+(acExtra.Last_Callout_Date__c.getTime() - CalloutDateTime.getTime()));

                        if(acExtra.Last_Callout_Date__c.getTime() - CalloutDateTime.getTime() > 0){
                            System.debug('**AccExtra**'+acExtra);
                            if(acExtra.Callout_Error__c){
                                errorExtraSubscriptions.add(acExtra);
                            } else {
                                selectedExtraSubscriptions.add(acExtra);
                            }
                        } else {
                        	selectedExtraSubscriptions.add(acExtra);
                        }
                    }
                }
            }
            System.debug('**selectedExtraSubscriptions**'+selectedExtraSubscriptions);
            system.debug('*** errorExtraSubscriptions.size(): ' + errorExtraSubscriptions.size());
            system.debug('*** errorExtraSubscriptions: ' + errorExtraSubscriptions);
            system.debug('*** selectedExtraSubscriptions.size(): ' + selectedExtraSubscriptions.size());
            system.debug('*** selectedSubscriptions.size(): ' + selectedSubscriptions.size());
            system.debug('*** errorRetryCount: ' + errorRetryCount);

            if(errorExtraSubscriptions.size() + selectedExtraSubscriptions.size() == selectedSubscriptions.size()){
                if(errorExtraSubscriptions.size() > 0 && errorRetryCount < Settings.CalloutRetryNumber__c){
                    system.debug('*** callout retry');
                    errorRetryCount ++;
                    List<AC_Subscription__c> retrySubs = new List<AC_Subscription__c>();

                    for(AC_Subscription_Extra__c e : errorExtraSubscriptions){
                        retrySubs.add(e.AC_Subscription__r);
                    }
                    System.debug('**errorExtraSubscriptions**'+errorExtraSubscriptions);
                    database.delete(errorExtraSubscriptions ,false);
                    System.debug('**retrySubs**'+retrySubs);
                    try{
                        CaseUtils.processSubscriptions(retrySubs);
                    }catch(CaseUtils.FutureLimitExceededException e){

                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'System can\'t process your request at the moment. Please try again tomorrow.'));
                    }

                } else {
                    system.debug('*** set result to true ');
                    result = true;
                } 
            }
        }
        System.debug('**Result Value**'+result);
        
        return result;
    }

    //DateTime used for compare
    private DateTime CalloutDateTime;

    //Custom settings
    public MyO2BusinessSettings__c Settings{
        get{
            if(Settings == null){
                Settings = MyO2BusinessSettings__c.getInstance('Settings');
            }
            return Settings;
        }

        private set{
            Settings = value;
        }
    }


    public void getTariffSubscriptionsDetailsCount(){


        numOfMobSubscription =  [SELECT COUNT() FROM AC_Subscription__c 
                                 where Network_Code__c in ('CDIG','VDIG') LIMIT 49999];

        numOfFixedSubscription =  [SELECT COUNT() FROM AC_Subscription__c 
                                   where Network_Code__c in ('FIXED') LIMIT 49999];

        numOfBBSubscription =  [SELECT COUNT() FROM AC_Subscription__c 
                                where Network_Code__c in ('BBAND') LIMIT 49999];    



    }

    public void getTariffSubscriptionsDetails(){
        selectedTariffSubscriptions = new List<AC_Subscription__c>();
        fixedSubscriptions = new List<AC_Subscription__c>();
        mobileSubscriptions = new List<AC_Subscription__c>();
        broadBandSubscriptions = new List<AC_Subscription__c>();

        for(AC_Subscription__c subscriptions : [SELECT Name,AC_Container__r.CT_Organisation_Container__r.Type,Start_Date__c,Tariff_Description__c,
                                                End_Date__c,Term__c,Network_Serial_No__c, Network_Code__c, DISE_Account_No__c,
                                                AC_Container__r.DISE_Account_No__c,Subscription_Name__c FROM AC_Subscription__c 
                                                where Network_Code__c in ('BBAND','FIXED','CDIG','VDIG') order by Network_Code__c limit :SMB_QUERY_LIMIT]){
            if(subscriptions.Network_Code__c == Label.MY_O2_BUSINESS_BBAND_NWCODE){
                broadBandSubscriptions.add(subscriptions);
            }else if(subscriptions.Network_Code__c == Label.MY_O2_BUSINESS_FIXED_NWCODE){
                fixedSubscriptions.add(subscriptions);
            }else if(subscriptions.Network_Code__c == Label.MY_O2_BUSINESS_CDIG_NWCODE || 
                    subscriptions.Network_Code__c == Label.MY_O2_BUSINESS_VDIG_NWCODE){
                mobileSubscriptions.add(subscriptions);

                listString.add(subscriptions.AC_Container__r.CT_Organisation_Container__r.Type);
            }
            selectedTariffSubscriptions.add(subscriptions);
        }

        numOfMobSubscription = mobileSubscriptions.size();
        numOfFixedSubscription = fixedSubscriptions.size();
        numOfBBSubscription = broadBandSubscriptions.size();

        selectedSubscriptions = selectedTariffSubscriptions;

        system.debug('selectedTariffSubscriptions size----'+selectedTariffSubscriptions.size());
    }



    public PageReference goToSMBTariffRenewalDetailsPage() {
        System.debug('Inside Admin change');
        allSubscDetails = '';
        allSubscDetails = ApexPages.CurrentPage().getParameters().get('allSubscDetails');
        getTariffSubscriptionsDetails();
        pageName = Page.smbhome;
        if(allSubscDetails== null || allSubscDetails == ''){

            this.pageValue = Label.MY_O2_TARIFF_MANAGEMENT_PAGE;
        }else{
            this.pageValue = Label.MY_O2_VIEW_ALL_CONTRACT_PAGE;
        }

        system.debug('page value in method is :' +pageValue);
        //ref.getParameters().put('smbAdmin', 'networkCodeChk');
		Integer numOfSelectedSubs = 50000;
		if(allSubscDetails == null || allSubscDetails == ''){
			numOfSelectedSubs = numOfMobSubscription;
        }else {
			if(allSubscDetails != null && allSubscDetails != ''){
				numOfSelectedSubs = numOfMobSubscription + numOfFixedSubscription + numOfBBSubscription;
			}
		}
		
		system.debug('renewal details page search, number of selected subs = ' + numOfSelectedSubs);
		system.debug('renewal details page search, MyO2MobileSubscription_Limit = ' + System.label.MyO2MobileSubscription_Limit);
		PageReference ref = null;
        if( selectedTariffSubscriptions != null && numOfSelectedSubs > Integer.valueOf(System.label.MyO2MobileSubscription_Limit)){
            ref = Page.SMBManageSearchPage;
        }else{
            ref = Page.SMBTariffRenewalDetailsPage;
        }

		if(allSubscDetails == null || allSubscDetails == ''){
        	ref.getParameters().put('mobileSubsFlow', 'mobileSubsFlow');
        }else {
			if(allSubscDetails != null && allSubscDetails != ''){
				ref.getParameters().put('allDetailsCtxt', 'allSubscDetails');
			}
		}

		ref.setredirect(false);
		system.debug('page ref is :' +ref);
		return ref;
    }

    // NAVIGATION METHODS
    public PageReference goToSMBTariffRenewalDetails() {
        saveSelections();
        PageReference ref = new PageReference('/apex/SMBTariffRenewalDetailsPage');
        ref.getParameters().put('tariffSearchFunc', 'search');
        if(allSubscDetails != null){
            system.debug('goToSMBTariffRenewalDetails allSubscDetails-----'+allSubscDetails);
            ref.getParameters().put('allDetailsCtxt', 'allSubscDetails');
        }
        ref.setredirect(false);
        system.debug('page ref is :' +ref);
        return ref;
    }


    public PageReference goToSMBTariffSection() {

        PageReference ref =  new PageReference('/apex/smbhome');
        ref.setAnchor('smbtariff');
        ref.setredirect(true);


        return ref;
    }

    public PageReference goToSMBManageDevicesSection() {

        PageReference ref =  new PageReference('/apex/smbhome');
        ref.setAnchor('journey');
        ref.setredirect(true);


        return ref;
    }


    public PageReference authorize()
    {
        PageReference ref = null;
        try
        {
            //
            // If user is guest or not active return login screen
            //
            if (!MyO2BusinessSignOnUtils.authorize())
            {
                ref = Page.MyO2BusinessLogin;
            }
            else {
                MyO2BusinessUser businessUser = new MyO2BusinessUser();
                if (businessUser != null && businessUser.getAccountSegment().contains(Label.ENTERPRISE_ACCOUNT_SEGMENT)){ 
                    ref = Page.MyO2BusinessHome;
                }
            }
        }
        catch (Exception e)
        {
            //
            // Unknown exception
            //
            system.debug('authorize: user not identifield: ' + e);
            ref = Page.MyO2BusinessLogin;
        }
        return ref;
    }


}