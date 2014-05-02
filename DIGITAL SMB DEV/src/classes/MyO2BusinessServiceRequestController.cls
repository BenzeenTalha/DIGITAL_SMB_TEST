public with sharing class MyO2BusinessServiceRequestController {

    public static final String SIM_PREFIX = '8944';
    private Boolean recalculateList {get; set;}
                
                public Id accountId {get; set;}
                
                // which user
                private User theUser {get {
                        if (theUser == null) {
                                theUser = [SELECT Id, ContactId, AccountId, ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
                                system.debug('theUser: '+theUser);
                        }
                        return theUser;
                } set; 
                }
                
                // The case we are going to create
                public Case theCase {get; set;}
                public String externalReference {get; set;}
                public String caseDescription {get; set;}
                
                // The number of employeeWrapper items that are currently selected
                public Integer caseLineItemSuspendCount {
                    get {
                        caseLineItemSuspendCount = 0;
                        for (List <mo2b_CaseLineItem__c> clis:employeePagination.storedClis.values()) {
                            for(mo2b_CaseLineItem__c cli: clis) {
                                if (cli.Suspend__c) 
                                    caseLineItemSuspendCount++;
                                }
                        }
                        return caseLineItemSuspendCount;
                    }
                    set;
                }
                public Integer caseLineItemSIMCount {
                    get {
                        system.debug('caseLineItemSIMCount: entry');
                        caseLineItemSIMCount = 0;
                        for (List <mo2b_CaseLineItem__c> clis:employeePagination.storedClis.values()) {
                            for(mo2b_CaseLineItem__c cli: clis) {
                                if (!isBlank(cli.New_SIM_Number__c)) 
                                    caseLineItemSIMCount++;
                            }
                        }                        
                        system.debug('caseLineItemSIMCount: exit: '+caseLineItemSIMCount);                      
                        return caseLineItemSIMCount;
                    }
                    set;
                }
                public Integer caseLineItemBoltonCount {get;set;}       
                
                // cache complete list of available options
                private static List<SelectOption> allAvailableOptions {get {
                    if(allAvailableOptions==null) {
                        allAvailableOptions = MyO2BusinessUtility.getPickValues(new mo2b_CaseLineItem__c(), 'Bolt_On__c', null);
                    } 
                    return allAvailableOptions ;
                
                } set;}
                
                // This indicates whether a single or multi CaseLineItem
                public Boolean singleCaseLineItemWizard {get; set;}
                
                // small class to wrap around mo2b_Subscription__c as we want a checkbox field that is not part of the type
                public class EmployeeWrapper {
                        public Integer index {get; set;}
                        public mo2b_Subscription__c employee {get; set;}
                        public Boolean selected {get; set;}
                        public List<SelectOption> availableOptions {get; set;}
                        
                        public List <SelectOption> selectableOptions {get {                        
                                List <SelectOption> selectableOptions = new List <SelectOption>();                                                   
                                Set <String> currentBoltons = new Set <String>();
                                if(this.clis!=null) {
                                    for (mo2b_CaseLineItem__c c :this.clis ) {                                       
                                        if(c.Bolt_On__c!=null) {
                                            currentBoltons.add(c.Bolt_On__c.trim());
                                        }
                                    }
                                }
                                
                                system.debug('@@@ currentBoltons:['+currentBoltons+']');
                                
                                for (SelectOption so: allAvailableOptions ) {
                                    if(!currentBoltons.contains(so.getValue().trim())) {
                                        selectableOptions.add(so);
                                    }
                                }
                                system.debug('@@@ selectableOptions:['+selectableOptions+']');                                                
                                return selectableOptions;
                            } 
                            private set;}
                        public mo2b_CaseLineItem__c cli {
                            get
                              {
                                // set default values
                                if(cli!=null) {
                                    if(cli.Start_Date__c==null) cli.Start_Date__c = System.today();
                                    if(cli.New_SIM_Number__c==null) cli.New_SIM_Number__c = SIM_PREFIX;
                                } 
                                return cli;} 
                            set;}
                        public List <mo2b_CaseLineItem__c> clis {get; set;}
                        public List <mo2b_CaseLineItem__c> clisNotEmpty {get {
                            List <mo2b_CaseLineItem__c> clisRet = new List <mo2b_CaseLineItem__c>();
                            if(clis!=null) {
                                for(mo2b_CaseLineItem__c c: clis) {
                                    if(c.bolt_on__c!=null) clisRet.add(c);
                                }
                            }
                            return clisRet;
                        } set;}

                        public EmployeeWrapper(mo2b_Subscription__c aEmployee, Boolean aSelected, Integer aIndex) {
                                employee = aEmployee;
                                selected = aSelected;
                                index = aIndex;
                                cli = new mo2b_CaseLineItem__c();
                                cli.New_SIM_Number__c = SIM_PREFIX;
                                cli.Start_Date__c = System.today();
                                cli.mo2b_subscription__c = aEmployee.Id;
                                clis = new List <mo2b_CaseLineItem__c>();
                        }
                }
                
                // small class to wrap around boltons
                public class BoltonWrapper {
                        public SelectOption bolton {get; set;}
                        public Boolean selected {get; set;}
                        
                        public BoltonWrapper(SelectOption aBolton, Boolean aSelected) {
                                bolton = aBolton;
                                selected = aSelected;
                        }
                }
                                
                public class Case2BoltonsWrapper {
                        public mo2b_CaseLineItem__c c2b {get; set;}
                        public String description {get; set;}
                        public Integer index {get; set;}                // TODO Retire
                        public Id subscriberId {get; set;}
                        public String phone {get; set;}
                        public String name {get; set;}
                        
                        public Case2BoltonsWrapper(mo2b_CaseLineItem__c c, String d, Id id, String n, String p) {
                                c2b = c;
                                description = d;
                                subscriberId = id;
                                name = n;
                                phone = p;                              
                        }
                }
                
                // should we show a button or the search panel
                public Boolean showSearchPanel {get; set;}
                public PageReference enableSearchPanel() {
                        showSearchPanel = true;
                        showZeroEmployeesMessage = false;
                        return null;
                }
                public PageReference disableSearchPanel() {
                        showSearchPanel = false;
                        showZeroEmployeesMessage = false;
                        return null;
                }

                // page information for the wizard
                public Integer stepCount {get; private set;}
                
                public String wizardName {get; set;}

                // The Page Title of the Wizard
        public String wizardTitle{get; set;}

                // The Steps for this wizard
        public List<String> wizardSteps{get; set;}
        
        // The pages for this wizard
        public List<String> wizardPages{get; set;}
        public String wizardPage {get; set;}
        public String wizardConfirmPage {get; set;}
                public String confirmTitle {get; set;}
        public String responseTime {get; set;}

                // page that the wizard was called from
                public PageReference calledFromPage {get; set;}

                // The buttons for the wizard
                public String wizardPrevButton {get; set;}
                public String wizardNextButton {get; set;}
                
                public List<String> wizardPrevButtons {get; set;}
                public List<String> wizardNextButtons {get; set;}

                // The Steps for this wizard
        public List<String> wizardStepDescriptions{get; set;}

                // The String for the Wizard Progress, each step separated by a '->'
        public String wizardProgressBar {get;set;}

                // The current wizard step
        public Integer wizardStep {get;set;}

                // The current wizard step
        public String wizardStepDescription {get;set;}
        
        // the sub-heading
        private List<String> wizardSubHeadings {get; set;}
        public String wizardSubHeading {get; set;}

                // The account being used by the user
        public Account account {get; set;}

                // what the user typed in one screen1 of a wizard
                public String nameTextArea {get; set;}
                public String numberTextArea {get; set;}

                // the SOQL filter that happened because of the user's searchFilter
                private String searchFilterString {get; set;}
                private Boolean searchFilterSupplied {get; set;}

                public List<SelectOption> boltonCombo { get; set;}

                // bolton selected from the combo
                public String boltonSelectedForEmployees {get; set;}

                // start and end date
                public DateTime startDate {get; set;}
                public DateTime endDate {get; set;}
                

                // The string being used by the user in the search box
                public String filterString {get; set;}
                private Boolean filterSupplied {get; set;}

                public String editTitle {get; set;}

                // validation methods
                public String valMethod {get; set {
                        system.debug('validationMethod: set: '+value);
                        valMethod = value;
                } }

                // used to manage the changing query string
                private SOQLQuery queryEmployees;
                private SOQLQuery querySubscribers {get; set;}

                // The list of SIMS to show in the list 
                public Integer employeeCount {get; set;}
                
                public Boolean showEmployees {get; set;}
                public Boolean showZeroEmployeesMessage {get; set;}
                
                private static final Integer EMPLOYEE_PAGE_SIZE = 10;
                public MyO2BusinessEmployeePagination employeePagination {get; set;}

                public PageReference empPageFirst() {
                        // TODO - retire dumpEmployeeList('first');
                        employeePagination.storeRecords(employeeList);
                                        employeePagination.first();
                                        employeeList = employeePagination.getRecords();
                        return null;
                }
                
                public PageReference empPageLast() {
                        // TODO - retire dumpEmployeeList('last');
                        employeePagination.storeRecords(employeeList);
                                        employeePagination.last();
                                        employeeList = employeePagination.getRecords();
                        return null;
                }

                public PageReference empPageNext() {
                        // TODO - retire dumpEmployeeList('next');
                        employeePagination.storeRecords(employeeList);
                                        employeePagination.next();
                                        employeeList = employeePagination.getRecords();
                        return null;
                }

                public PageReference empPagePrevious() {
                        // TODO - retire dumpEmployeeList('prev');
                        employeePagination.storeRecords(employeeList);
                                        employeePagination.previous();
                                        employeeList = employeePagination.getRecords();
                        return null;
                }


                public List<EmployeeWrapper> employeeList {get {
                        if (employeeList == null) {
                                employeeList = new List<EmployeeWrapper>();
                        }
                        return employeeList;
                } set;}
                                              
                public Integer employeesSelectedCount {get {
                        Integer employeesSelectedCount = 0;
                        for (EmployeeWrapper emp:employeeList) {
                                if (emp.selected)
                                        employeesSelectedCount++;
                        }
                        system.debug('employeesSelectedCount: '+employeesSelectedCount);
                        return employeesSelectedCount;
                } private set;}
                
                public String employeesSelected {get {
                        return employeesSelectedCount + ' Subscribers selected.'; 
                } set;}
               
               public Id checkBoxEmployeeId {get; set;}
               public Boolean checkBox {get; set;}
                
               public Boolean atLeastOneSelected {
                        get {
                                        system.debug('atLeastOneSelected: employeesSelectedCount: '+employeesSelectedCount);
                                // is there one on this page?
                                atLeastOneSelected = (employeesSelectedCount > 0);
                                                                system.debug('atLeastOneSelected: '+atLeastOneSelected);
                                if (!atLeastOneSelected) {
                                        // may not be something on this page, what about the pages not in focus?
                                        atLeastOneSelected = (employeePagination.employeesSelectedCount > 0);
                                                        system.debug('atLeastOneSelected: employeePagination.employeesSelectedCount: '+employeePagination.employeesSelectedCount);
                                }
                                return atLeastOneSelected;
                        } private set;
                }
                
                public Integer getSelectedCount() {
                    return employeePagination.employeesSelectedCount;
                }
                 
                public PageReference checkBoxChanged() {
                    system.debug('checkBoxChanged: entry');
                    system.debug('checkBoxEmployeeId: '+checkBoxEmployeeId);
                    system.debug('checkBox: '+checkBox);
                    
                    for (EmployeeWrapper ew:employeeList) {
                        if (ew.employee.Id == checkBoxEmployeeId) {
                                ew.cli.suspend__c = checkBox;
                        }
                    }
                    employeePagination.storeRecords(employeeList);
                    
                    if (checkBox == false) {                    
                        // need to remove it from the list of Ids as we may have it set there
                        employeePagination.deselectId(checkBoxEmployeeId);                      
                    }
                    return null;
                }
                
        
        // List of available boltons
        public List<BoltonWrapper> boltonsAvailable {get {
                if (boltonsAvailable == null) {
                        boltonsAvailable = new List<BoltonWrapper>();
                }
                return boltonsAvailable;
        } set;}
        
        public List<BoltonWrapper> boltonsUnassigned {get {
                if (boltonsUnassigned == null) {
                        boltonsUnassigned = new List<BoltonWrapper>();
                }
                return boltonsUnassigned;
        } set;}
        
        public Boolean expandBoltonDetails {get; set;}
                
        // List of Ids selected in the list
        public Set<Id> selectedSIMS {get; set;}
        
        // do we need to add the WHERE clause?
        private Boolean addWhere;
        
                // The standard controller
        private ApexPages.Standardcontroller standardController;

                // The config that dictates how this wizard should be displayed (custom setting)
        private MyO2BusinessWizard__c config;
                
        // default constructor
        public MyO2BusinessServiceRequestController() {
                getReferrer();
                initPage(ApexPages.currentPage().getUrl());
        }

                // get the caller
                private void getReferrer() {
                        system.debug('getReferrer: entry');
                        String url = (String) apexpages.currentPage().getParameters().get('retURL');
                        system.debug('getReferrer: url: '+url);
                        if (url != null) {
                                calledFromPage = new PageReference(url);
                                system.debug('getReferrer: PageReference: '+calledFromPage);                                                    
                        }
                }

                // get the page ready for use
        private void initPage(String url) {             
                recalculateList = true;
                String pageName = getPageName(url);
                getConfig(pageName);
                if (config != null) {
                                wizardName=config.Name;
                        wizardTitle=config.Title__c;    
                        wizardSubHeading=config.SubHeading__c;                
                        getWizardSteps();
                        editTitle = config.EditTitle__c;
                        wizardConfirmPage = config.Confirm_Page__c;
                        confirmTitle = config.Confirm_Title__c;
                        responseTime= config.Response_Time__c;
                        /* TODO - Retire getEditValues();*/
                }
                getAccount();
                getBoltons();
                selectedSIMS = new Set<Id>();
                initQuery();
                showSearchPanel = false;
                showZeroEmployeesMessage = false;
                caseLineItemBoltonCount = 0;
                initCaseLineItemMode();
                createEmployeeList(null);
                showEmployees = true;
        }
        
        private void initCaseLineItemMode() {
                if (wizardName.equals('Boltons')) {
                        singleCaseLineItemWizard = false;
                } else singleCaseLineItemWizard = true;
                system.debug('The '+wizardName+' wizard is singleCaseLineItemWizard: '+singleCaseLineItemWizard);
        }
       
                // initialise the query strings
                private void initQuery() {
            queryEmployees = new SOQLQuery('mo2b_Subscription__c');
            queryEmployees.columns = MyO2BusinessUtility.getSobjectFields('mo2b_Subscription__c');
                        queryEmployees.orderBy = 'userName__c ASC';
                        queryEmployees.searchFilter = null;
                        queryEmployees.filter = null;
                        
                        filterSupplied = false;
                        searchFilterSupplied = false;
                }
                
                // get the account that the service requests belong to
        private void getAccount() {             
                accountId = ApexPages.currentPage().getParameters().get('id');
                if (accountId != null)
                        account = [SELECT Id, Name FROM Account WHERE Id=:accountId LIMIT 1];
        }
        
        private void getBoltons() {
                mo2b_CaseLineItem__c obj = new mo2b_CaseLineItem__c();
                List<SelectOption> boltons = MyO2BusinessUtility.getPickValues(obj, 'Bolt_On__c', null);
        
                // TODO OLD CODE List<mo2bBolton__c>boltons = [SELECT Id, Description__c FROM mo];
                for (SelectOption so:boltons) {
                        BoltonWrapper bw = new BoltonWrapper(so, false);
                        boltonsAvailable.add(bw);
                        boltonsUnassigned.add(bw);
                }
        }
        
        // get the name of the page in anticipation of getting the Custom Setting that describes how to
        // layout this wizard page
        private String getPageName(String myUrl) {
               system.debug('getPageName: mrUrl'+myUrl);
                 String[] tokenSlash = myUrl.split('/', -1);
                String[] tokenParam = tokenSlash[2].split('\\?', -1);
                system.debug('getPageName: '+tokenParam[0]);
                return tokenParam[0];
        }
        
        // get the config for this wizard page
        private void getConfig(String configName) {
                        system.debug('getConfig: name: '+configName);
                                String query = 'SELECT Response_Time__c, Name, ActionMethod__c, Confirm_Title__c, Confirm_Page__c, PageName__c, Title__c, Steps__c, EditTitle__c,EditProperty__c,Step_Description__c,SubHeading__c,Prev_Buttons__c,Next_Buttons__c FROM MyO2BusinessWizard__c WHERE PageName__c LIKE \''+configName+'%\' LIMIT 1';
                try {
                       config = Database.query(query);                  
                } catch (Exception e) {
                        config = null;
                }
                                system.debug('getConfig: object: '+config);
        }
        
       // get the wizard steps from the config
        private void getWizardSteps() {
                                stepCount = 0;
                wizardProgressBar = '';
                
                wizardSteps = new List<String>();
                                wizardStepDescriptions = new List<String>();
                                wizardPrevButtons = new List<String>();
                                wizardNextButtons = new List<String>();
                                wizardSubHeadings = new List<String>();
                wizardPages = new List<String>();
                actionMethods = new List<String>();
                
                if (config != null) {
                    // get the lists from the config
                    wizardSteps = getListValues(config.Steps__c, ';');
                    wizardStepDescriptions = getListValues(config.Step_Description__c, ';');
                    wizardPrevButtons = getListValues(config.Prev_Buttons__c, ';');
                    wizardNextButtons = getListValues(config.Next_Buttons__c, ';');
                                        wizardSubHeadings = getListValues(config.SubHeading__c, ';');
                                        wizardPages = getListValues(config.PageName__c, ';');
                                        actionMethods = getListValues(config.ActionMethod__c, ';');

                                        // Build the steps string
                    for(String step:wizardSteps) {
                        if (stepCount == 0) {
                                                        // do not append '->' as it is first wizard step
                        } else {
                            wizardProgressBar = wizardProgressBar + ' -> '; 
                        }
                        wizardProgressBar = wizardProgressBar + step;
                        stepCount++;
                    }                        

                                        // Set first page
                                        setStringsForPage(0);
                }
                                // always start at the first step
        }
        
                private Set<Id> copySelectedIds() {
                        Set<Id> targetSelectedIds = MyO2BusinessUtility.copySetIds(employeePagination.selectedIds);
                        return targetSelectedIds;
                }

                                private void resetCase2Boltons() {
                                        if (case2Boltons != null) {
                                                caseLineItemBoltonCount=0;
                                                case2Boltons.clear();
                                        }
                                }

                private void setDataForPage(Integer pageX) {
                        if (pageX == 0) {
                                                                // need to empty the Case2Boltons as they get reset when you go page 2 to page 1
                                                                resetCase2Boltons();

                                // get the current selections
                                Set<Id> oldSelections = copySelectedIds();
                                
                                // set the employeeList back to it's initial state
                                createEmployeeList(oldSelections);
                        }
                }

                private void setStringsForPage(Integer pageX) {
            wizardStep = pageX;
            wizardStepDescription = wizardStepDescriptions[pageX];
            system.debug('wizardPrevButtons: '+wizardPrevButtons);
            system.debug('wizardNextButtons: '+wizardNextButtons);
            wizardPrevButton = wizardPrevButtons[pageX];
            wizardNextButton = wizardNextButtons[pageX];
            wizardSubHeading = wizardSubHeadings[pageX];
            wizardPage = wizardPages[pageX];
            system.debug('wizardPage: '+wizardPage);                    
                }

                private List<String> getListValues(String configString, String sep) {
                        List<String> strList = new List<String>();
                String[] tokens = configString.split(sep,-1);
            for (String s:tokens) {
                strList.add(s);
            }
                        return strList;
                }
                               
                // methods for selecting SIMs in the List View
                
                public Id thisId {get; set;}
                
                public void selectAllEmployees() {
                        system.debug('selectAllEmployees');
                        for (EmployeeWrapper emp:employeeList) {
                                system.debug('selectAllEmployees: emp: '+emp);
                                emp.selected = true;
                        }
                }
                
                public void deselectAllEmployees() {
                        system.debug('deselectAllEmployees');
                        for (EmployeeWrapper emp:employeeList) {
                                if (emp.selected) {
                                        // remove from current page
                                        emp.selected = false;
                                                                // remove from paginator as it is counting towards the employeeSelectedCount
                                employeePagination.deselectId(emp.employee.Id);                                                                 
                                }
                        }
                }
                                
                private Boolean isBlank(String s) {
                        Boolean b = false;
                        if (s == null)
                                b = true;
                        else if (s.equals(''))
                                b = true;
                        return b;
                }
                                
                private String validateEmployeesSelected() {
                        system.debug('validateEmployeesSelected: entry');
                        String retVal = null;
                        
                        if (atLeastOneSelected == false) {
                                system.debug('validateEmployeesSelected: 0');
                                retVal = 'Please select at least one subscriber or return to Home Screen';
                        }
                        
                        system.debug('validateEmployeesSelected: '+retVal);
                        return retVal;
                }
                
                private Boolean validateInput(Integer wizardStep) {
                        // not guilty unless proven otherwise
                        system.debug('validateInput: entry');

                        // TODO: Temp code to make it work
                        valMethod = (wizardStep == 0) ? 'v0' : null;

                        Boolean retVal = true;
                        String errorMsg = null;
                        
                        if (valMethod == null) {
                                system.debug('validateInput: get params');
                                valMethod = (String) ApexPages.currentPage().getParameters().get('valMethod');
                                system.debug('validationMethod: ' +valMethod);
                                String c = (String) ApexPages.currentPage().getParameters().get('column');
                                system.debug('c: '+c);
                        }

                        if (valMethod != null) {
                                system.debug('validateInput: method defined: '+valMethod);

                                if (valMethod.equals('v0')) {
                                        errorMsg = validateEmployeesSelected();
                                }
                                
                                if (errorMsg != null) {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                                        retVal = false;
                                }                               
                        }
                        return retVal;
                }

                private List<String> actionMethods {get; set;}
                private String actionMethod{get;set;}
                
                private void doAction(Integer page) {
                        system.debug('doAction: entry');
                        system.debug('doAction: page: '+page);
                        system.debug('doAction: actionMethods: '+actionMethods);
                        actionMethod = actionMethods[page];
                        system.debug('doAction: actionMethod: '+actionMethod);
                        if (actionMethod != null) {                             
                                if (actionMethod.equals('filterEmployees'))
                                        filterEmployees();                              
                                else if (actionMethod.equals('createBoltons'))
                                        createBoltonObjects();
                                else if (actionMethod.equals('prepareSIMs'))
                                        prepareSIMs();
                                else if (actionMethod.equals('createSIMSwap'))
                                        createSIMSwap();                                                                        
                                else if (actionMethod.equals('prepareSuspends'))
                                        prepareSuspends();                                                                      
                                else if (actionMethod.equals('createSuspends'))
                                        createSuspends();                                                                       
                        } else {
                                system.debug('doAction: no method found');
                        }
                }

                //
                // Take the initial list of employees and removes those that were not selected
                //
                private void filterEmployees() {
                        system.debug('filterEmployees: entry');

                        // store the selections of the page that was being viewed when user clicked Next>
                        employeePagination.storeRecords(employeeList);
                        prepareEmployees();
                        
                        system.debug('filterEmployees: exit');
                }


                public static final Integer OP_SIM_SWAP = 0;
                public static final Integer OP_SUSPEND_NUMBER = 1;
                private void deselectUnused(Integer op) {
                    system.debug('deselectUnunsed: op='+op);
                    Integer lastPage = employeePagination.getTotalPageNumber();
                    Integer currentPage = 0;
                    employeePagination.first();
                    while (currentPage < lastPage) {
                            employeeList = employeePagination.getRecords();
                            for (EmployeeWrapper ew:employeeList) {
                                Boolean deselect = false;
                                    system.debug('ew: '+ew);
                                    if (op == OP_SIM_SWAP) {
                                        deselect = isBlank(ew.cli.New_SIM_Number__c);
                                    } else if (op == OP_SUSPEND_NUMBER) {
                                        deselect = !ew.cli.Suspend__c;
                                    }
                                    if (deselect) {
                                        // deselect this one
                                         employeePagination.deselectId(ew.employee.Id);
                                    }
                            }
                            currentPage++;
                            if (currentPage < lastPage) {
                                    employeePagination.next();
                            }
                    }
                    
                }

                                private void prepareEmployees() {
                    // take the existing query and remove the current where clause                                          
                    querySubscribers.resetWhere();
                    // get the new where clause from the paginator that includes all the Id's selected on first page of wizard
                    querySubscribers.whereClause = employeePagination.getIdInClause();
                    // create a new paginator
                    employeePagination.newQuery(querySubscribers.query);
                    // get the first page
                    employeeList = employeePagination.getRecords();                                     
                                }

                private Case createCase(String subject, String requestType) {
                        // create the case
                        Case c = new Case();
                        c.Subject = subject;
                        c.Service_Request_Type__c = requestType;
                        c.Description = caseDescription;
                        c.External_Reference__c = externalReference;
                        c.ContactId = theUser.ContactId;
                        c.AccountId = theUser.AccountId;
                        insert c;
                        system.debug('createCase: case: '+c);

                        return c;
                }

                                private Boolean notEmptyCli(mo2b_CaseLineItem__c cli) {
                                        system.debug('notEmptyCli: '+cli);
                                        Boolean notEmpty = false;
                                        
                                        if (cli != null) {
                                                if ((isBlank(cli.Bolt_On__c)==false) || (isBlank(cli.New_SIM_Number__c)==false) || (cli.Suspend__c ==true)) {
                                                        notEmpty = true;
                                                }
                                        }
                                        
                                        system.debug('notEmptyCli: exit: '+notEmpty);
                                        return notEmpty;
                                }

                private void createCaseLineItems() {
                        // create the case line items
                        
                        List<List<mo2b_CaseLineItem__c>> cliListList = employeePagination.storedClis.values();
                        List<mo2b_CaseLineItem__c> cliToAddList = new List<mo2b_CaseLineItem__c>();
                        for (List<mo2b_CaseLineItem__c> cliList:cliListList) {
                             for (mo2b_CaseLineItem__c cli:cliList) {
                                    if (notEmptyCli(cli)) {
                                            cli.Case__c = theCase.Id;
                                        cliToAddList.add(cli);                                                                  
                                    }
                            }
                        }
                        system.debug('cliToAddList: size '+cliToAddList.Size());
                        insert cliToAddList;
                }

                private void createCaseObjects(String subject, String requestType) {
                        try {
                                // create the case
                                Case c = createCase(subject, requestType);
        
                                // requery to get the CaseNumber
                                theCase = [SELECT CaseNumber, Id FROM Case WHERE Id=:c.Id LIMIT 1];
                                system.debug('createCaseObjects: theCase: '+theCase);
        
                                createCaseLineItems();
                        } catch (Exception ex) {
                                system.debug('exception: '+ex);
                                throw ex;
                        }                       
                }

                private void createBoltonObjects() {
                        system.debug('createBoltonObjects: entry');

                        createCaseObjects('Bolt-Ons Request', 'Bolt-ons');

                        system.debug('createBoltonObjects: exit');
                }

                // take the employees and build the CaseToBolton structure
                public void prepareSIMs() {
                       system.debug('prepareSIMs: entry');
                        
                        // we allow the user to not supply a sim number and this causes de-selection
                                                try {
                                // save the current page
                                employeePagination.storeRecords(employeeList);
                                // check we don't have more than one SIM card number with same value
                                //employeePagination.lookAtClisForUniqueness(OP_SIM_SWAP);
                                // remove unused from all pages
                                deselectUnused(OP_SIM_SWAP);
                                // get 1st page ready for next screen
                                prepareEmployees();
                                                        
                                                } catch (MyO2BusinessTokenException te) {
                                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, te.getMessage()));
                                                }
                                                
                        system.debug('prepareSIMs: exit');                       
                }

                private void createSIMSwap() {
                        system.debug('createSIMSwap: entry');

                        createCaseObjects('SIM Swap Request', 'SIM Swap');

                        system.debug('createSIMSwap: exit');                    
                }

                private void prepareSuspends() {
                        system.debug('prepareSuspends: entry');

                        // save the current page
                        employeePagination.storeRecords(employeeList);
                        // remove unused from all pages
                        deselectUnused(OP_SUSPEND_NUMBER);
                        // get first page ready for next wizard page
                        prepareEmployees();                       
                        system.debug('prepareSuspends: exit');                                           
                }

                private void createSuspends() {
                        system.debug('createSuspends: entry');

                        createCaseObjects('Suspend Number Request', 'Block SIM');

                        system.debug('createSuspends: exit');                   
                        
                }

                // page navigation
                public PageReference nextStep() {
                        system.debug('nextStep: C2B: '+case2Boltons);
                        PageReference pr = null;
                        
                        if (validateInput(wizardStep) ) {
                                if (wizardStep < stepCount - 1) {
                                        doAction(wizardStep);                           
                                        wizardStep++;
                                        setStringsForPage(wizardStep);
                                        pr = new PageReference('/apex/'+wizardPage);
                                } else {                                        
                                        doAction(wizardStep);                           
                                        pr = new PageReference('/apex/'+wizardConfirmPage);
                                }
                        }
                        
                        system.debug('nextStep: '+pr);
                        return pr;
                }
                
                public PageReference prevStep() {
                            system.debug('prevStep: C2B: '+case2Boltons);
                        
                        PageReference pr = null;
                        if (wizardStep > 0) {
                                wizardStep--;
                                setStringsForPage(wizardStep); 
                                setDataForPage(wizardStep); 
                                pr = new PageReference('/apex/'+wizardPage);
                        }
                        system.debug('prevStep: '+pr);
                        return pr;
                }
                
                public PageReference goServiceRequests() {
                        return Page.MyO2BusinessMyCases;
                }
                
                public PageReference goBackToCaller() {
                        return calledFromPage;
                }
                
                public PageReference clearNumberArea() {
                        numberTextArea = '';
                        showZeroEmployeesMessage = false;
                        //showEmployees = true;
                        //createEmployeeList(null);
                        return null;
                }
                public PageReference clearNameArea() {
                                system.debug('clearNameArea: entry');
                        nameTextArea = '';
                        showZeroEmployeesMessage = false;
                        //showEmployees = true;
                        //createEmployeeList(null);
                                system.debug('clearNameArea: exit');
                        return null;
                }

                public PageReference clearAllAreas() {
                        clearNumberArea();
                        clearNameArea();
                        showZeroEmployeesMessage = false;
                        showEmployees = true;
                        
                        createEmployeeList(null);
                        return null;
                }

                                // This method exists for Pages to call as an action. We set the parameter to null as the pages don't have any
                                // idea of what has been selected or not.
                                public PageReference createEmployeeList() {
                                        return createEmployeeList(null);
                                }

                public PageReference createEmployeeList(Set<Id> previousSelectedIds) {
                        Integer spaceLeft = MyO2BusinessUtility.MAX_SOQL_LENGTH;
                        system.debug('createEmployeeList: entry');

                        querySubscribers = new SOQLQuery('mo2b_Subscription__c');
                        querySubscribers.columns =  MyO2BusinessUtility.getSobjectFields('mo2b_Subscription__c');
                        if (accountId != null) {
                                querySubscribers.filter = 'Account__c=\''+accountId+'\'';
                                querySubscribers.whereOperator = ' AND ';
                                spaceLeft -= querySubscribers.query.length();
                                system.debug('query: created: spaceLeft: '+spaceLeft);                  
                        }
                        querySubscribers.orderBy = 'username__c ASC';
                        
                        // need to consider that the buffer may not be big enough for the WHERE clause
                        try {
                                String w1 = MyO2BusinessUtility.getWhereClauseCondition('username__c', nameTextArea, spaceLeft);
                                spaceLeft -= w1.length();
                                system.debug('query: w1 created: spaceLeft: '+spaceLeft);
                                
                                String w2 = MyO2BusinessUtility.getWhereClauseCondition('primarySerialNumber__c', numberTextArea, spaceLeft);
                                system.debug('query: w2 created: spaceLeft: '+spaceLeft);

                                if (isBlank(w1)) {
                                        if (isBlank(w2)) {
                                                // user did not supply anything - show everything for the account
                                        } else {
                                                querySubscribers.searchFilter = w2;                                                                                
                                        }
                                } else {
                                        if (isBlank(w2)) {
                                                querySubscribers.searchFilter = w1;
                                        } else {
                                                querySubscribers.searchFilter = w1 + ' AND ' + w2;                                                                          
                                        }                                       
                                }
                        } catch (Exception e) {
                                // just return everything for the account
                        }
                                
                                defaultAvailableOptions = getAvailableOptions(defaultAvailableOptions);
                                employeePagination = new MyO2BusinessEmployeePagination(querySubscribers.query, EMPLOYEE_PAGE_SIZE, defaultAvailableOptions, singleCaseLineItemWizard, previousSelectedIds);
                                employeeList = employeePagination.getRecords();
                        
                showEmployees = (employeeList.Size() > 0);
                showZeroEmployeesMessage = !showEmployees;
                        system.debug('createEmployeeList: size '+employeeList.Size());
                        
                        system.debug('createEmployeeList: exit');
                        return null;
                }

                public List<Case2BoltonsWrapper> case2Boltons {get {
                        if (case2Boltons == null) {
                                case2Boltons = new List<Case2BoltonsWrapper>();
                        }
                        return case2Boltons;
                } set;}
                
                public List<Case2BoltonsWrapper> case2BoltonsForX {get {
                        system.debug('case2BoltonsForX: entry');
                        case2BoltonsForX = new List<Case2BoltonsWrapper>();
                        for (Case2BoltonsWrapper c2bw:case2Boltons) {
                                system.debug('case2BoltonsForX: c2bw: '+c2bw);

                                                                if (c2bw.subscriberId == drillId) {

                                        case2BoltonsForX.add(c2bw);
                                }

                        }
                        system.debug('case2BoltonsForX: exit: '+case2BoltonsForX);
                        return case2BoltonsForX;
                } set;}
                

                // object used for creating a new Bolton assignment
                public mo2b_CaseLineItem__c newBoltonRequest {get {
                        system.debug('newBoltonRequest: get:');
                        if (newBoltonRequest == null) {
                                newBoltonRequest = new mo2b_CaseLineItem__c();
                                newBoltonRequest.Start_Date__c = newBoltonRequest.End_Date__c = System.today();
                        }
                        system.debug('newBoltonRequest: '+newBoltonRequest);
                        return newBoltonRequest;
                } set;}
                
                private void validateBoltonRequest() {
                        system.debug('validateBoltonRequest');
                }
                
                private Boolean pendingCase2BoltonAdd(String c2bwDescription, Boolean bRemove) {
                        Integer i = 0;
                        Integer pos = -1;
                        Boolean found = false;
                        
                        system.debug('pendingCase2BoltonAdd: check: '+c2bwDescription + ' drillId: '+drillId );
                        for(Case2BoltonsWrapper c2bw:case2Boltons) {
                                system.debug('c2bw.bolton.Description: '+c2bw.Description+' id: '+drillId);
                                if (c2bw!=null && c2bw.Description!=null && c2bw.subscriberId!=null && c2bw.Description.equals(c2bwDescription) && drillId == c2bw.subscriberId) {
                                        found = true;
                                        pos = i;
                                        break;
                                }
                                i++;    
                        }
                        if (bRemove && (pos != -1)) {
                                case2Boltons.remove(pos);
                        }
                        system.debug('pos: '+pos);
                        return found;
                }
                
                private Boolean pendingCase2BoltonAdd2(String c2bwDescription, Boolean bRemove) {
                        Integer i = 0;
                        Integer pos = -1;
                        Boolean found = false;
                        
                        EmployeeWrapper ew = employeePagination.getEmployeeById(drillId);
                        system.debug('pendingCase2BoltonAdd2: check: '+c2bwDescription + ' drillId: '+drillId );
                        for(mo2b_CaseLineItem__c cli:ew.clis) {
                                system.debug('cli.bolt_on__c: '+cli.bolt_on__c+' id: '+drillId);
                                if (cli!=null && cli.bolt_on__c!=null && cli.bolt_on__c.equals(c2bwDescription)) {
                                        found = true;
                                        pos = i;
                                        break;
                                }
                                i++;    
                        }
                        if (bRemove && (pos != -1)) {
                                ew.clis.remove(pos);
                        }
                        system.debug('pos: '+pos);
                        return found;
                }                
                
                public PageReference createBoltonRequest() {
                        system.debug('createBoltonRequest: newBoltonRequest: '+newBoltonRequest);
                        // TODO validate input
                        validateBoltonRequest();

                        // record the request
                        
                        // The newBoltonRequest needs to be copied as it is used for screen input and will change on next user input
                        mo2b_CaseLineItem__c cli = copyCaseLineItem(newBoltonRequest);
 
                        EmployeeWrapper ew = employeePagination.getEmployeeById(drillId);
                        if (ew != null) {
                                if(ew.clis==null) {
                                        ew.clis=new List<mo2b_CaseLineItem__c>();
                                }
                                                                system.debug('ew.clis: on entry: '+ew.clis);
                                
                                String name = ew.employee.username__c;
                                system.debug('name: '+name);
                                String phone = ew.employee.primarySerialNumber__c;
                                system.debug('phone: '+phone);
                                Case2BoltonsWrapper c2b = new Case2BoltonsWrapper(cli, cli.Bolt_On__c, drillId, name, phone);                  
                                system.debug('createBoltonRequest: c2b: '+c2b);
                                cli.mO2b_subscription__c = ew.employee.Id;
                                if(cli!=null && cli.bolt_on__c!=null && cli.bolt_on__c!='') ew.clis.add(cli);
                                                                system.debug('ew.clis: after add: '+ew.clis);
                                case2Boltons.add(c2b);
                                system.debug('createBoltonRequest: case2Boltons: '+case2Boltons);
        
                                // remove the bolton from the combo list
                                system.debug('newBoltonRequest: '+newBoltonRequest);
                                ew.availableOptions = removeAvailableOptions(ew.availableOptions, newBoltonRequest.Bolt_On__c);                                 
                        }



                        caseLineItemBoltonCount++;

                        return null;
                }
                
                private mo2b_CaseLineItem__c copyCaseLineItem(mo2b_CaseLineItem__c source) {
                        mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c();
                        cli.Bolt_On__c = source.Bolt_On__c;
                        cli.End_Date__c = source.End_Date__c;
                        cli.Start_Date__c = source.Start_Date__c;
                        return cli;
                }
                
                public String deleteCase2Bolton {get; set;}

                public PageReference deleteBoltonRequest2() 
                {
                        system.debug('deleteBoltonRequest2: entry');
                        if (deleteCase2Bolton == null) {
                                deleteCase2Bolton = (String) ApexPages.currentPage().getParameters().get('d2cb');                               
                        }
                        // test - to see if this causes the button to disable
                        if (caseLineItemBoltonCount > 0)
                                caseLineItemBoltonCount--;
                        pendingCase2BoltonAdd(deleteCase2Bolton, true);
                        pendingCase2BoltonAdd2(deleteCase2Bolton, true);
                        return null;
                }                
                
                public Boolean showDrillDownDetail {get; set;}
                
                public PageReference drillDown() {
                        system.debug('drillDown: entry');
                        system.debug('drillDown: employeeList: '+employeeList);
                        system.debug('drillDown: drillId: '+drillId);
                        // show the detail panel
                        showDrillDownDetail = true;
                        


                        // which user was selected?
                        
                        EmployeeWrapper ew = employeePagination.getEmployeeById(drillId);
                        drillUser = (!isBlank(ew.employee.username__c)) ? ew.employee.username__c : ew.employee.primarySerialNumber__c;
                        
                        // set the combo box, work it out for the employee and then assign it to the combo
                        ew.availableOptions = getAvailableOptions(ew.availableOptions);
                        boltonCombo = ew.availableOptions;
                                                

                        system.debug('drillDown: '+drillUser);
                        return null;
                }
                                
                public Id drillId {get {
                        if (drillId == null) {
                                system.debug('drillId: not set');
                                drillId = ApexPages.currentPage().getParameters().get('drillId');
                        }
                        system.debug('drillId: get: '+drillId);
                        return drillId;
                } set {
                        drillId = value;
                        system.debug('drillId: set: '+drillId);
                } }
                
                public String drillUser {get; set;}
                
                public EmployeeWrapper drillEmployee {get; set;}
                
                private List<SelectOption> defaultAvailableOptions {get; set;}
                private List<SelectOption> getAvailableOptions(List<SelectOption> opts) {
                        if (opts == null) {
                                // need to initialise with the full set of available options
                                opts = new List<SelectOption>();
                                for (BoltonWrapper bw:boltonsUnassigned) {
                                        opts.add(bw.bolton);                            
                                }
                        }
                        return opts;
                }
                
                                private List<SelectOption> addAvailableOptions(List<SelectOption> opts, String value) {
                                        system.debug('addAvailableOptions: value: '+value);                                     
                                        for (BoltonWrapper bw:boltonsUnassigned) {
                                                system.debug('addAvailableOptions: so.value: '+bw.bolton.getValue());
                                                if (bw.bolton.getValue().equals(value)) {
                                opts.add(bw.bolton);
                                                }                            
                    }
                    return opts;        
                                }

                private List<SelectOption> removeAvailableOptions(List<SelectOption> opts, String opt) {
                        Integer pos = -1;
                        Integer i = 0;
                        for (SelectOption so:opts) {
                                if (so.getLabel().equals(opt)) {
                                        pos = i;
                                        break;
                                }
                                i++;                            
                        }
                        if (pos != -1) {
                                opts.remove(pos);                               
                        }
                        return opts;
                }                
}