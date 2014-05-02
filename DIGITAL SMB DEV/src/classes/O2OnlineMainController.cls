global with sharing class O2OnlineMainController {

    public static string PACKAGE_PREFIX = 'cscfgc__';
    //public cscfgc.API_1.ApiSession apiSession {get; set;}
    //public cscfgc.SessionManager.SessionInfo userSession {get;set;}
    //public cscfgc.API_1.ApiSession newAPISession {get; set;}
    //public cscfgc.SessionManager.SessionInfo newUserSession {get;set;}

    public cscfgc.API_1.ApiSession apiSession {
        get{
            system.debug('get: apiSession: '+apiSession);
            return apiSession;
        }
        set{
            apiSession = value;
            system.debug('set: apiSession: '+apiSession);
        }
        }
    public cscfgc.SessionManager.SessionInfo userSession  {
        get{
            system.debug('get: userSession: '+userSession);
            return userSession;
        }
        set{
            userSession = value;
            system.debug('set: userSession: '+userSession);
        }
        }
    public cscfgc.API_1.ApiSession newAPISession  {
        get{
            system.debug('get: newAPISession: '+newAPISession);
            return newAPISession;
        }
        set{
            newAPISession = value;
            system.debug('set: newAPISession: '+newAPISession);
        }
        }
    public cscfgc.SessionManager.SessionInfo newUserSession  {
        get{
            system.debug('get: newUserSession: '+newUserSession);
            return newUserSession;
        }
        set{
            newUserSession = value;
            system.debug('set: newUserSession: '+newUserSession);
        }
        }

    global String definitionRef {get;set;}
    global String definitionId {get; set;}
    global String offerId {get; set;}
    global String screenFlowName {get; set;}
    global String definitionName {get;set;}
    global Boolean quickAddProduct {get;set;}

    public String screenIndex {get; set;}
    public Boolean generator {get;set;}
    public String startPage {get;set;}

    public Boolean editingProduct {get; set;}
    public String editConfigData {get; set;}

    public String productName {get;set;}


    public cscfgc.LayoutHelper.LinearScreenLayoutSequence screenSeq;
    public Integer lastIndex;

    public O2OnlineMainController() {
        if (ApexPages.currentPage().getParameters().get('ref')!=null) definitionRef = ApexPages.currentPage().getParameters().get('ref');
        if (ApexPages.currentPage().getParameters().get('def')!=null) definitionId = ApexPages.currentPage().getParameters().get('def');
        if (ApexPages.currentPage().getParameters().get('offer')!=null) offerId = ApexPages.currentPage().getParameters().get('offer');
        system.debug('vl+++ ' + ApexPages.currentPage().getParameters().get('offer'));
        if (ApexPages.currentPage().getParameters().get('screenFlowName')!=null) screenFlowName = ApexPages.currentPage().getParameters().get('screenFlowName');
        if (ApexPages.currentPage().getParameters().get('generator')!=null) generator = Boolean.valueOf(ApexPages.currentPage().getParameters().get('generator'));
                String browserType = Apexpages.currentPage().getHeaders().get('USER-AGENT');
                String enableIE8 = getIE8CompatibilityEnabled();
                if(browserType != null && browserType.contains('MSIE') && enableIE8 == 'Y'){
                        ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
                }


    }

    public O2OnlineMainController getController() {return this;}
    public void doNothing() {}

    public string getScreenFlowTemplate() {
        if (apiSession==null) return 'o2VfMainTemplate';
        return apiSession.getController().getcurrentScreen().cscfgc__screen_flow__r.cscfgc__template_reference__c;
    }

    public String getPreGeneratedContent() {
        System.debug('### OUTPUT >>>>> getPreGeneratedContent: offerId: '+offerId);
        if (offerId!=null) {
            String retValue = '';
            List<Attachment> lstAttach = [SELECT Id, Name, Body FROM Attachment WHERE ParentId=:offerId ORDER BY CreatedDate desc LIMIT 1];
            if (lstAttach!=null && lstAttach.size()>0) {
                retValue = O2OnlineUtils.getStringFromBlob(lstAttach[0].Body);
            }
            return retValue;
        }
        else return null;
    }

    public PageReference setContext() {
        System.debug('### OUTPUT >>>>> setContext: offerId: '+offerId);
        System.debug('### OUTPUT >>>>> setContext: screenFlowName: '+screenFlowName);
        System.debug('### OUTPUT >>>>> setContext: definitionId: '+definitionId);
        selectProduct();
        return null;
    }
    public PageReference selectScreen() {
            apiSession.getController().screenindex = this.screenIndex;
            PageReference p = apiSession.getController().selectScreen();

            string url = p.getUrl();
            url = url.replace(PACKAGE_PREFIX, '');
            System.debug('>>>>>>>> URL: ' + url);
            PageReference targetP = new PageReference(url);
            return targetP;
    }
    public PageReference getFirstPage() {
        startSession();
        if (startPage!=null && startPage!='') {return new PageReference('/apex/'+startPage);}
        else return Page.O2OnlineLandlineProductPage;
    }
    public void initSession() {
        System.debug('### OUTPUT >>>>> initSession: offerId: '+offerId);
//        System.debug('### OUTPUT >>>>> initSession: provideType: '+provideType);
        if (newApiSession==null) {
                selectProduct();
                newApiSession = apiSession;
                newUserSession = userSession;
            }
    }
    public PageReference startQuickShop() {
    //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    //changed by zoran zunko at 10.26.2012. if product in the basket is mll do not allow any other products of mll type to be added to the basket
    //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
       // System.debug(Logginglevel.DEBUG, '------------------------------ startSession();');
        if (offerId != null) {
                cscfgc__Product_Basket__c basket = cscfgc.SessionManager.getSessionInfo().getSessionBasket();
                System.debug(Logginglevel.DEBUG,basket );
                System.debug(Logginglevel.DEBUG,getProduct());
                System.debug(Logginglevel.DEBUG,offerId );
                System.debug('IT******' + offerId );
                List<cscfgc__Product_Configuration__c> configs = [select id, Name from cscfgc__Product_Configuration__c where cscfgc__configuration_offer__c = :offerId];
                System.debug(Logginglevel.DEBUG,configs );
                if(configs.size()==1 && basket.cscfgc__Products_In_Basket__c != null && basket.cscfgc__Products_In_Basket__c.contains('Mobile Landline') && configs[0].Name.contains('Mobile Landline'))
                {
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Only one Mobile Landline is allowed per single checkout.'));//TODO just test
                    if (startPage!=null && startPage!='') {return new PageReference('/apex/'+startPage);}
                    else
                    {
                        return null;
                    }
                 }
        }

        startSession();
        selectProduct();
        if (startPage!=null && startPage!='') {return new PageReference('/apex/'+startPage);}
        else
        {
          return null;
        }
    }
    
    public PageReference selectProduct() {
        System.debug('### OUTPUT >>>>> selectProduct: offerId: '+offerId);
        editingProduct = false;
        if (apiSession==null || newApiSession==null) {
             System.debug('apiSession==null || newApiSession==null' + offerId);
            if (offerId != null && offerId !='') {
                system.debug('vl+++ basket pre');
                cscfgc__Product_Basket__c basket = cscfgc.SessionManager.getSessionInfo().getSessionBasket();
                system.debug('vl+++ basket');
                for (cscfgc__Product_Configuration__c config : basket.cscfgc__product_configurations__r) {
                        if ((quickAddProduct==null || !quickAddProduct) && config.cscfgc__product_definition__c == definitionId && config.cscfgc__configuration_status__c == O2OnlineProductBasketController.DRAFT_STATUS) {
                                apiSession = cscfgc.API_1.getApiSession(new cscfgc__Product_Configuration__c(id = config.id), screenFlowName);
                                break;
                        }
                }
                system.debug('vl+++ cloning configurations pre...' + apiSession); 
                if (apiSession == null) {
                	    system.debug('vl+++ cloning configurations...');
                        List<cscfgc__Product_Configuration__c> configs = [select id from cscfgc__Product_Configuration__c where cscfgc__configuration_offer__c = :offerId];
                        List<Id> ids = cscfgc.API_1.cloneConfigurations(configs, null, basket);
                        configs = [select cscfgc__configuration_status__c from cscfgc__Product_Configuration__c where id in :ids and cscfgc__parent_configuration__c = null];
                        for (cscfgc__Product_Configuration__c config : configs) {
                                if (quickAddProduct==null || !quickAddProduct) config.cscfgc__configuration_status__c = O2OnlineProductBasketController.DRAFT_STATUS;
                        }
                        update configs;
                        apiSession = cscfgc.API_1.getApiSession(new cscfgc__Product_Configuration__c(id = ids[0]), screenFlowName);
                }
                //cfgTariffCode = apiSession.getConfiguration().getAttribute('Tariff Code').getValue();

            } else if (definitionRef!=null && definitionRef!='') {
                cscfgc__Product_Definition__c def = cscfgc.API_1.findProductDefinition(definitionRef);
                apiSession = cscfgc.API_1.getApiSession(def, screenFlowName);
            } else if (definitionId != null) {
                cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(id = definitionId);
                apiSession = cscfgc.API_1.getApiSession(def, screenFlowName);
            }
        }
        userSession = apiSession.loadUserSession(apiSession.getUserSession().usersession.Id);
        if (screenIndex==null) screenIndex = '0';
        productName = getProduct();
        //if (generator!=null && generator) return null;
        //else return selectScreen();
        return null;
    }

    public PageReference editBasketProduct(String configId, String theScreenFlowName, String theOfferId) {
        // must not selectProduct() here as that would clone another offer
        System.debug('>>>>>>>> editBasketProduct(): ' + newUserSession);
        offerId = theOfferId;
        editingProduct = true;
                apiSession = cscfgc.API_1.getApiSession(new cscfgc__Product_Configuration__c(id = configId), theScreenFlowName);
                newApiSession = apiSession;
                 userSession = apiSession.loadUserSession(apiSession.getUserSession().usersession.Id);
                screenIndex = '0';
                apiSession.getController().screenIndex = screenIndex;
                apiSession.getController().selectScreen();

                editConfigData = '{\n';
                editConfigData += getAttributesJSON(apiSession.getConfiguration(), '');
                editConfigData += '\n}';

                productName = getProduct();
                return Page.O2OnlineLandlineProductPage;
    }

    String getAttributesJSON(cscfgc.ProductConfiguration config, String lineBreak) {
            String json = '';
            for (cscfgc.Attribute attr : config.getAttributes()) {
                    if (attr == null) continue;
                    String value = attr.getValue();
                    if (value == null) {
                            value = '';
                    } else {
                            value = String.escapeSingleQuotes(value).replaceAll('\n', '\\\\n').replaceAll('\r', '\\\\r');
                    }
                    json += lineBreak + '\'' + String.escapeSingleQuotes(attr.getAbsoluteReference().getAsId()) + '\': { value: \'' + value +  '\'' + ', type: \'' + attr.getDefinition().cscfgc__type__c + '\'}';
                    lineBreak = ',\n\t';
                    if (attr.getDefinition().cscfgc__type__c == cscfgc.Attribute.RELATED_PRODUCT) {
                            for (cscfgc.ProductConfiguration related : attr.getRelatedProducts()) {
                                    json += getAttributesJSON(related, lineBreak);
                            }
                    }
            }
            return json;
    }

    public String getProduct() {
        String strProdName = '';
        if (apiSession!=null) {strProdName = apiSession.getConfiguration().getsObject().cscfgc__product_definition__r.name;}
        if (strProdName!=null && strProdName!='') productName = strProdName;
        return strProdname;
    }

    public cscfgc__Product_Configuration__c getConfiguration() {
        if (apiSession==null) return null;
        return apiSession.getConfiguration().getsObject();
    }

    public cscfgc.LayoutHelper.LinearScreenLayoutSequence getScreenSequence() {
        if (apiSession == null) return null;
        System.debug(apiSession.getConfiguration());
        if (screenSeq == null) screenSeq = cscfgc.LayoutHelper.generateScreenLayouts(apiSession.getConfiguration());
        return screenSeq;
    }
    public Integer getLastIndex() {
        if (apiSession == null) return null;
        if (lastIndex == null && screenSeq!=null) lastIndex = screenSeq.getLast().index;
        return lastIndex;
    }
    public String getHiddenAttributesAsHtml() {
        if (screenSeq == null) return null;
        if (screenSeq.offScreenAttributes == null || screenSeq.offScreenAttributes.size() == 0) return '\n<!-- NO ADDITIONAL ATTRS -->\n';
        String html = '\n<!-- ADDITIONAL ATTRS -->\n';
        html += cscfgc.ProductConfiguration.getAttributesAsHtml(screenSeq.offScreenAttributes);
        return html;
    }

    //### landline index 0 page code
    public String productLabel {
        get {
                if (apiSession!=null) return apiSession.getConfiguration().getAttribute('External Label').getValue();
                else return productLabel;
        }
        set;
    }
    public String provideType {
        get {
                if (provideType==null) return 'New Provide';
                else if (apiSession!=null) return apiSession.getConfiguration().getAttribute(getProvideTypeAttribute()).getValue();
                else return provideType;
        }
        set {
                provideType = value;
            apiSession.getConfiguration().getAttribute(getProvideTypeAttribute()).setValue(value);
            if (getProduct().contains('Landline')) {
                if (value=='New Provide') {
                        apiSession.getConfiguration().getAttribute('New Order Type').setValue('New Line Provide');
                    apiSession.getConfiguration().getAttribute('Installation Work Required?').setValue('Yes');
                } else {
                        apiSession.getConfiguration().getAttribute('New Order Type').setValue('');
                    apiSession.getConfiguration().getAttribute('Installation Work Required?').setValue('No');
                }
            }
        }
    }
    public String transferNumber {
        get {return apiSession.getConfiguration().getAttribute(getDNAttribute()).getValue();}
        set {
            apiSession.getConfiguration().getAttribute(getDNAttribute()).setValue(value);
            /* commented for olympus
            // Hard code temporarily
            transferNumber = value;
            if (getProduct().contains('Broadband')) apiSession.getConfiguration().getAttribute('O2 Customer').setValue('No');
        	*/
        	/* pulled out of the comment */
        	transferNumber = value;
        }
    }
    public String transferPostcode {
        get {if (transferPostcode!=null) return transferPostcode; else return apiSession.getConfiguration().getAttribute(getPCAttribute()).getValue();}
        set {transferPostcode = value;apiSession.getConfiguration().getAttribute(getPCAttribute()).setValue(value);}
    }
    public String existingCustomer {
        get {
                if (existingCustomer==null) return 'No';
                else return existingCustomer;
        }
        set {
                existingCustomer = value;
            /*
            // Hard code temporarily
            if (getProduct().contains('Broadband')) apiSession.getConfiguration().getAttribute('O2 Customer').setValue('No');
            else if (getProduct().contains('Landline')) apiSession.getConfiguration().getAttribute('O2 Customer').setValue(value);
        	*/
        	apiSession.getConfiguration().getAttribute('O2 Customer').setValue(value);
        }
    }
    public String existingNumber {
        get{ if (existingNumber!=null) return existingNumber; return apiSession.getConfiguration().getAttribute('O2 Mobile Phone Number').getValue();
                /*if(existingNumber==null)
                        return existingNumber;
                else
                        return apiSession.getConfiguration().getAttribute('O2 Mobile Phone Number').getValue();*/
        }
        set{
                System.debug('existingNumber ******************************** '+existingNumber);
                existingNumber=value;
                apiSession.getConfiguration().getAttribute('O2 Mobile Phone Number').setValue(value);
        }
    }

    private String getProvideTypeAttribute() {
        String attribName = '';
        if (getProduct().contains('Landline')) attribName = 'Provide Type';
        else if (getProduct().contains('Broadband')) attribName = 'Order Type';
        return attribName;
    }
    private String getDNAttribute() {
        String attribName = '';
        if (getProduct().contains('Landline') || getProduct().contains('ISDN2')) attribName = 'Existing Telephone Number';
        else if (getProduct().contains('Broadband')) attribName = 'Landline Number';
        else if (getProduct().contains('Calls Only')) attribName = 'Line Number';
        return attribName;
    }
    private String getPCAttribute() {
        String attribName = 'Postcode';
        // Just list the exceptions
        if (getProduct().contains('Broadband')) attribName = 'Install Postcode';
        return attribName;
    }


    //####### PAF ADDRESS HANDLING/CACHING CODE #######

    //### saved session addresses code
    public String selectedAddressIndex {get;set;}
    public String selectedRouterAddressIndex {get;set;}
    public Map<ID, Location__c> savedLocations = new Map<ID, Location__c>();
    public List<Location__c> nonPAFLocationList = new List<Location__c>();

    public Map<String, Location__c> locTypes = new Map<String, Location__c>();

    public List<Location__c> newLocations = new List<Location__c>();
    public List<SelectOption> getsavedLocationList() {
                        System.debug('### OUTPUT >>>>> getsavedlocation list: userSession: '+userSession);
                        if (userSession == null) return null;
                        List<Location__c> loclist = [SELECT Id, Name, Type__c, Number_and_Street__c, Building_Unit_Name__c, PAF_Sub_Building_Name__c, PAF_Building_Name__c, PAF_Building_Number__c, Street__c,
                                                 PAF_Post_Town__c, PAF_County__c, PAF_Postcode__c, PAF_Thoroughfare_Name__c, PAF_Thoroughfare_Descriptor__c, Country__c, Name_and_Street__c
                                                     FROM Location__c WHERE User_Session__c = :userSession.userSession.Id AND Type__c IN ('Installation', 'Router')];
                        if (loclist!=null && loclist.size()>0) {savedLocations = new Map<ID, Location__c>(loclist);}
                        System.debug('### OUTPUT >>>>> getsavedlocation list: savedLocations: '+savedLocations);
        return convertSavedLocationList(loclist);
    }
    public void selectSavedInstallAddress() {selectAddress(savedLocations.get(selectedAddressIndex), 'installation');}
    public void selectSavedRouterAddress() {selectAddress(savedLocations.get(selectedRouterAddressIndex), 'router');}
    public PageReference numSavedLocations() {getNumSavedLocations();return null;}
    public Integer getNumSavedLocations() {
        getSavedLocationList();
            System.debug('### OUTPUT >>>>> getNumSavedLocations: savedLocations: '+savedLocations);
        if (savedLocations==null) return 0;
        else return savedLocations.size();
    }

    //### installation address code
    public Boolean newInstallAddress {get {if (newInstallAddress==null) return true; else return newInstallAddress;} set;}

    public String selectedInstallAddress {get;set;}
    public void selectInstallAddress() {saveAndSelectAddress(selectedInstallAddress, 'installation');}
    public String defaultInstallCountry {get;set;}
    //individual installation address variables
    public List<SelectOption> getInstallAddrCountries() {
        List<SelectOption> lsOptions = new List<SelectOption>();
        Map<String, CountryCodes__c> countries = CountryCodes__c.getAll();
        if (countries!=null && countries.size()>0) {
                if (inCountry==null && inCountry=='') inCountry = countries.get('default').Country_Name__c;
                defaultInstallCountry = countries.get('default').Country_Name__c;
                System.debug('Output>>>>> Default country€€€€ ********** --'+countries.get('default').Country_Name__c);
                lsOptions.add(new SelectOption(countries.get('default').Country_Name__c, countries.get('default').Country_Name__c));
        }
        lsOptions.add(new SelectOption('', '-- Select One --'));
        // Sort them by name
        List<String> countryNames = new List<String>(countries.keySet());
        countryNames.sort();
        // Create the Select Options.
        for (String countryName : countryNames) {
            CountryCodes__c country = countries.get(countryName);
            if(country!=null && country.Name != 'default') lsOptions.add(new SelectOption(country.Country_Name__c, country.Country_Name__c));
        }
        return lsOptions;
    }

    public String inFlatNumber {get; set;}
    public String inBuildingName {
        get {
                if (apiSession == null) return null;
            if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Premise Name').getValue();
            else return apiSession.getConfiguration().getAttribute('Building Name').getValue();
        }
        set {
                if (apiSession == null) return;
                if(inFlatNumber != null && inFlatNumber != '')
                {
                    String instalbuildingName = inFlatNumber;
                    if(value != '' && value != null) instalbuildingName += ','+value;

                    if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Premise Name').setValue(instalbuildingName);
                    else apiSession.getConfiguration().getAttribute('Building Name').setValue(instalbuildingName);
                }
                else
                {
                    if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Premise Name').setValue(value);
                    else apiSession.getConfiguration().getAttribute('Building Name').setValue(value);
                }

            //if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Premise Name').setValue(value);
            //else apiSession.getConfiguration().getAttribute('Building Name').setValue(value);
        }
    }
    public String inBuildingNumber {
        get {
                if (apiSession == null) return null;
            if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Premise Number').getValue();
            else return apiSession.getConfiguration().getAttribute('Building Number').getValue();}
        set {
                if (apiSession == null) return;
            if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Premise Number').setValue(value);
            else apiSession.getConfiguration().getAttribute('Building Number').setValue(value);
        }
    }
    public String inPostcode {
        get {
                if (apiSession == null) return inPostcode;
            if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Postcode').getValue();
            else return apiSession.getConfiguration().getAttribute('Postcode').getValue();
        }
        set {
                if (apiSession == null) {
                        inPostcode = value;
                        return;
                }
            if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Postcode').setValue(value);
            else apiSession.getConfiguration().getAttribute('Postcode').setValue(value);
        }
    }
    public String inStreet {
        get {
                if (apiSession == null) return null;
            if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Street').getValue();
            else return apiSession.getConfiguration().getAttribute('Street').getValue();
        }
        set {
                if (apiSession == null) return;
            if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Street').setValue(value);
            else apiSession.getConfiguration().getAttribute('Street').setValue(value);
        }
    }
    /*public String inTown {
        get {
            if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install City').getValue();
            else return apiSession.getConfiguration().getAttribute('Town').getValue();
        }
        set {
            if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install City').setValue(value);
            else apiSession.getConfiguration().getAttribute('Town').setValue(value);
        }
    }*/
    public String inCity {
        get {
                if (apiSession == null) return null;
            if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install City').getValue();
            else return apiSession.getConfiguration().getAttribute('City').getValue();
        }
        set {
                if (apiSession == null) return;
            if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install City').setValue(value);
            else
            {
                apiSession.getConfiguration().getAttribute('City').setValue(value);
                apiSession.getConfiguration().getAttribute('Town').setValue(value);
            }
        }
    }
    public String inCounty {
        get {
                if (apiSession == null) return null;
            if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install County').getValue();
            else return apiSession.getConfiguration().getAttribute('County').getValue();
        }
        set {
                if (apiSession == null) return;
            if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install County').setValue(value);
            else apiSession.getConfiguration().getAttribute('County').setValue(value);
        }
    }
    public String inCountry {

        get {
                if (apiSession == null) return null;
            if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Country').getValue();
            else return apiSession.getConfiguration().getAttribute('Country').getValue();
        }
        set {
                if (apiSession == null) return;
            if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Country').setValue(value);
            else apiSession.getConfiguration().getAttribute('Country').setValue(value);
        }
    }


    //perform search for installation address and show results in output selectoptions
    public List<AddressCheckController.Address> installResAddresses;
    public List<selectOption> installationAddresses {get;set;}
    public PageReference searchInstallationAddresses() {
        System.debug('### OUTPUT >>>>> searchInstallationAddresses: method enter: '+inBuildingName+'|'+inBuildingNumber+'|'+inPostcode);
        List<selectOption> outputOptions = new List<selectOption>();
        installResAddresses = findAddresses(inBuildingName, inBuildingNumber, inPostcode);
        if (installResAddresses!=null && installResAddresses.size()>0) {
            //populate selectlist records from results list
            outputOptions.add(new SelectOption('', '-Select address-'));
            for (integer i=0; i<installResAddresses.size(); i++) {
                String strAddr = '';
                if (installResAddresses[i].subBuildingName!=null && installResAddresses[i].subBuildingName!='') strAddr+=installResAddresses[i].subBuildingName+',';
                if (installResAddresses[i].buildingName!=null && installResAddresses[i].buildingName!='') strAddr+=installResAddresses[i].buildingName+',';
                if (installResAddresses[i].buildingNumber!=null && installResAddresses[i].buildingNumber!='') strAddr+=installResAddresses[i].buildingNumber+',';
                if (installResAddresses[i].street!=null && installResAddresses[i].street!='') strAddr+=installResAddresses[i].street+',';
                if (strAddr!='') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-1)));
            }
        }
        else {
            //populate selectlist with 'NO RESULTS' marker
            outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
        }
        installationAddresses = outputOptions;

        return null;
    }

    //### router address code
    public Boolean newRouterAddress {get { if (newRouterAddress==null) return true; else return newRouterAddress;} set;}
    public String selectedRouterAddress {get;set;}
    public void selectRouterAddress() {saveAndSelectAddress(selectedRouterAddress, 'router');}
    public String defaultRouterCountry{get;set;}
    //individual router address variables
    public List<SelectOption> getRouterAddrCountries() {
        List<SelectOption> lsOptions = new List<SelectOption>();
        Map<String, CountryCodes__c> countries = CountryCodes__c.getAll();
        if (countries!=null && countries.size()>0) {
                if (rtCountry==null) rtCountry = countries.get('default').Country_Name__c;
                defaultRouterCountry = countries.get('default').Country_Name__c;
                lsOptions.add(new SelectOption(countries.get('default').Country_Name__c, countries.get('default').Country_Name__c));
        }
        lsOptions.add(new SelectOption('', '-- Select One --'));
        // Sort them by name
        List<String> countryNames = new List<String>(countries.keySet());
        countryNames.sort();
        // Create the Select Options.
        for (String countryName : countryNames) {
            CountryCodes__c country = countries.get(countryName);
            if(country!=null && country.Name != 'default') lsOptions.add(new SelectOption(country.Country_Name__c, country.Country_Name__c));
        }
        return lsOptions;
    }
    public String rtFlatNumber{get; set{
                rtFlatNumber = value;
        }
    }
    public String rtBuildingName {
        get {
                if (apiSession == null || !productName.contains('Broadband')) return null;
                return apiSession.getConfiguration().getAttribute('Router Premise Name').getValue();
        }
        set
        {
                if (apiSession == null || !productName.contains('Broadband')) return;
                if(rtFlatNumber != null && rtFlatNumber != '')
                {
                         String routerBuildingName = rtFlatNumber;
                         if(value != '' && value != null) routerBuildingName += ','+value;
                         apiSession.getConfiguration().getAttribute('Router Premise Name').setValue(routerBuildingName);
                }
                else
                {
                        apiSession.getConfiguration().getAttribute('Router Premise Name').setValue(value);
                }
                //apiSession.getConfiguration().getAttribute('Router Premise Name').setValue(value);
        }
    }
    public String rtBuildingNumber {
        get {
                if (apiSession == null || !productName.contains('Broadband')) return null;
                return apiSession.getConfiguration().getAttribute('Router Premise Number').getValue();
        }
        set {
                if (apiSession == null || !productName.contains('Broadband')) return;
                apiSession.getConfiguration().getAttribute('Router Premise Number').setValue(value);
        }
    }
    public String rtPostcode {
        get {
                if (apiSession == null || !productName.contains('Broadband')) return null;
                return apiSession.getConfiguration().getAttribute('Router Postcode').getValue();
        }
        set {
                if (apiSession == null || !productName.contains('Broadband')) return;
                apiSession.getConfiguration().getAttribute('Router Postcode').setValue(value);
        }
    }
    public String rtStreet {
        get {
                if (apiSession == null || !productName.contains('Broadband')) return null;
                return apiSession.getConfiguration().getAttribute('Router Street').getValue();
        }
        set {
                if (apiSession == null || !productName.contains('Broadband')) return;
                apiSession.getConfiguration().getAttribute('Router Street').setValue(value);
        }
    }
    public String rtCity {
        get {
                if (apiSession == null || !productName.contains('Broadband')) return null;
                return apiSession.getConfiguration().getAttribute('Router City').getValue();
        }
        set {
                if (apiSession == null || !productName.contains('Broadband')) return;
                apiSession.getConfiguration().getAttribute('Router City').setValue(value);
        }
    }
    public String rtCounty {
        get {
                if (apiSession == null || !productName.contains('Broadband')) return null;
                return apiSession.getConfiguration().getAttribute('Router County').getValue();
        }
        set {
                if (apiSession == null || !productName.contains('Broadband')) return;
                apiSession.getConfiguration().getAttribute('Router County').setValue(value);
        }
    }
    public String rtCountry {
        get {
                if (apiSession == null || !productName.contains('Broadband')) return null;
                return apiSession.getConfiguration().getAttribute('Router Country').getValue();
        }
        set {
                if (apiSession == null || !productName.contains('Broadband')) return;
                apiSession.getConfiguration().getAttribute('Router Country').setValue(value);
        }
    }


    //perform search for router address and show results in output selectoptions
    public List<AddressCheckController.Address> routerResAddresses;
    public List<selectOption> routerAddresses {get;set;}
    public PageReference searchRouterAddresses() {
        System.debug('>>>>>>>>> SearchRouterAddresses: ' + rtBuildingName + ', ' + rtBuildingNumber + ', ' + rtPostcode);
        List<selectOption> outputOptions = new List<selectOption>();
        routerResAddresses = findAddresses(rtBuildingName, rtBuildingNumber, rtPostcode);
        if (routerResAddresses!=null && routerResAddresses.size()>0) {
            //populate selectlist records from results list
            outputOptions.add(new SelectOption('', '-Select address-'));
            for (integer i=0; i<routerResAddresses.size(); i++) {
                String strAddr = '';
                if (routerResAddresses[i].subBuildingName!=null && routerResAddresses[i].subBuildingName!='') strAddr+=routerResAddresses[i].subBuildingName+',';
                if (routerResAddresses[i].buildingName!=null && routerResAddresses[i].buildingName!='') strAddr+=routerResAddresses[i].buildingName+',';
                if (routerResAddresses[i].buildingNumber!=null && routerResAddresses[i].buildingNumber!='') strAddr+=routerResAddresses[i].buildingNumber+',';
                if (routerResAddresses[i].street!=null && routerResAddresses[i].street!='') strAddr+=routerResAddresses[i].street+',';
                if (strAddr!='') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-1)));
            }
        }
        else {
            //populate selectlist with 'NO RESULTS' marker
            outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
        }
        routerAddresses = outputOptions;
        return null;
    }

    public void resetAddresses(String strType)
    {
        if(strType == 'installation')
        {
            inFlatNumber = '';
            inBuildingNumber = '';
            inBuildingName = '';
        }
        else
        {
            rtFlatNumber = '';
            rtBuildingNumber = '';
            rtBuildingName = '';
        }
    }

    //### generic paf/address utility code
    //PAF search method
    public List<AddressCheckController.Address> findAddresses (String pafBuildingName, String pafBuildingNumber, String pafPostcode) {
        List<AddressCheckController.Address> resAddresses;
        try {
            System.debug('### OUTPUT >>>>> findAddresses: method start');
            AddressCheckController pafcontroller = new AddressCheckController();
            System.debug('pafBuildingName ********************************************** '+pafBuildingName);
            if (pafBuildingName!=null) pafcontroller.buildingName = pafBuildingName;
            if (pafBuildingNumber!=null) pafcontroller.buildingNumber = pafBuildingNumber;
            if (pafPostcode!=null) pafcontroller.postcode = pafPostcode;
            if (pafcontroller.postcode!=null && pafcontroller.postcode!='') {
                PageReference resPage = pafcontroller.addressSearch();
                resAddresses = pafcontroller.addressResults;
            }
        }
        catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));}
        return resAddresses;
    }
    //method to convert Location__c list to selectoptions list
    public List<SelectOption> convertSavedLocationList(Location__c[] loclist) {
        List<SelectOption> outputOptions = new List<SelectOption>();
        if (loclist!=null && loclist.size()>0) {
            outputOptions.add(new SelectOption('', '-Select address-'));
            for (Integer i=0; i<loclist.size(); i++) {
                if (loclist[i].Name_and_Street__c!=null && loclist[i].Name_and_Street__c!='')
                    outputOptions.add(new SelectOption(loclist[i].Id, loclist[i].Name_and_Street__c));
            }
        }
        else {outputOptions.add(new SelectOption('NO ADDRESSES SAVED', 'NO ADDRESSES SAVED'));}
        return outputOptions;
    }
    //method to save selected paf result address to session Locations list, and then select ie. set UI field variables
    public void saveAndSelectAddress(String index, String addrType) {
        if (userSession == null) userSession = newUserSession;

        if (addrType=='installation') {
            if (installResAddresses!=null && installResAddresses.size()>0 && index!=null && index!='') {
                integer i = Integer.valueOf(index);
                System.debug('### OUTPUT >>>>> setSaveAddress: installAddress:'+installResAddresses[i]);
                Location__c newLoc = createSavedSessionLocation(installResAddresses[i], 'Installation', userSession.userSession.Id);
                selectAddress(newLoc, addrType);
            }
        }
        else if(addrType=='router') {
            if (routerResAddresses!=null && routerResAddresses.size()>0 && index!=null && index!='') {
                System.debug('### OUTPUT >>>>> setSaveAddress: in router...');
                integer i = Integer.valueOf(index);
                System.debug('### OUTPUT >>>>> setSaveAddress: routerAddress:'+routerResAddresses[i]);
                Location__c newLoc = createSavedSessionLocation(routerResAddresses[i], 'Router', userSession.userSession.Id);
                selectAddress(newLoc, addrType);
            }
        }
        else {
            throw new O2OnlineException('Could not determine address type to save. Please use the contact form to notify us of this fault.');
        }

    }
    public class O2OnlineException extends Exception {}
    //method to create session Location record and if successful add to cached locations map
    public Location__c createSavedSessionLocation(AddressCheckController.Address addr, String strType, ID sessId) {

        Location__c newLoc;
        try {
            if (addr!=null && sessId!=null) {
                String strConfigId;
                if (apiSession!=null) strConfigId = apiSession.getConfiguration().getsObject().Id;
                //system.debug('addr.subBuildingName ************************************  '+addr.subBuildingName);
                //system.debug('addr.buildingName ************************************  '+addr.buildingName);
                newLoc = new Location__c(
                    Type__c = strType,
                    User_Session__c = sessId,
                    Sync_with_Parent__c = false,
                    PAF_Sub_Building_Name__c = addr.subBuildingName,
                    PAF_Building_Name__c = addr.buildingName,
                    PAF_Building_Number__c = addr.buildingNumber,
                    PAF_Organisation_Name__c = addr.organisation,
                    PAF_Dependent_Thoroughfare__c = addr.dependentStreet,
                    PAF_Dependent_Thoroughfare_Descriptor__c = '',
                    PAF_Thoroughfare_Name__c = addr.street,
                    PAF_Thoroughfare_Descriptor__c = '',
                    PAF_Double_Dependent_Locality__c = addr.dependentLocality,
                    PAF_Dependent_Locality__c = addr.locality,
                    PAF_Post_Town__c = addr.postTown,
                    PAF_County__c = addr.county,
                    PAF_Postcode__c = addr.postcode,
                    Country__c = defaultInstallCountry

                );
                                if (strConfigId!=null) newLoc.Product_Configuration__c = strConfigId;   //ensure that if we have an apiSession and configId, that it is stored linked ot the address/location
                //insert newLoc;    //insert moved to the AddToBasket method since we will then have a config id to include
                system.debug('new loc obj ************************************************ '+newLoc);
                locTypes.put(strType, newLoc);
                newLocations.add(newLoc);
            }
        }
        catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));}
        return newLoc;
    }

    //method to return country value
    public String getCountryVal(String strType){
        if(strType == 'installation')
        {
                if(inCountry==null)  inCountry = defaultInstallCountry;
                return inCountry;
        }
        else
        {
                if(rtCountry==null)  rtCountry = defaultRouterCountry;
                return rtCountry;
        }
    }
    //method to set UI field variables
    public void selectAddress(Location__c selectedloc, String strType) {
        system.debug('strType ******************************************** '+strType);
        if (strType == 'installation' && selectedloc!=null) {
             resetAddresses(strType);
             if(newInstallVal == 'false')
             {
                if (selectedloc.PAF_Sub_Building_Name__c!=null) inFlatNumber = selectedloc.PAF_Sub_Building_Name__c;
                if (selectedloc.PAF_Building_Name__c!=null) inBuildingName = selectedloc.PAF_Building_Name__c;
             }
             else
             {
                if (selectedloc.PAF_Building_Name__c!=null) inBuildingName = selectedloc.PAF_Building_Name__c;
                if (selectedloc.PAF_Sub_Building_Name__c!=null) inFlatNumber = selectedloc.PAF_Sub_Building_Name__c;
             }


            system.debug('PAF_Sub_Building_Name__c1 ************************************* '+selectedloc.PAF_Sub_Building_Name__c);
            system.debug('inBuildingName ****************************************  '+inBuildingName);
            system.debug('inBuildingNumber ****************************************  '+inBuildingNumber);

            /*if (selectedloc.PAF_Sub_Building_Name__c!=null && selectedloc.PAF_Sub_Building_Name__c!='')
            {
                if (inBuildingName != null) inBuildingName = selectedloc.PAF_Sub_Building_Name__c+','+inBuildingName;
                else inBuildingName = selectedloc.PAF_Sub_Building_Name__c;//+','+inBuildingName;
            }   */
            if (selectedloc.PAF_Building_Number__c!=null) inBuildingNumber = selectedloc.PAF_Building_Number__c;
            if (selectedloc.PAF_Thoroughfare_Name__c!=null) inStreet = selectedloc.PAF_Thoroughfare_Name__c;
            if (selectedloc.PAF_Thoroughfare_Descriptor__c!=null) inStreet += selectedloc.PAF_Thoroughfare_Descriptor__c;
            if (selectedloc.PAF_Post_Town__c!=null) inCity = selectedloc.PAF_Post_Town__c;
            //if (selectedloc.PAF_Post_Town__c!=null) inTown = selectedloc.PAF_Post_Town__c;
            if (selectedloc.PAF_County__c!=null) inCounty = selectedloc.PAF_County__c;
            if (selectedloc.PAF_Postcode__c!=null) inPostcode = selectedloc.PAF_Postcode__c;
            if (selectedloc.Country__c!=null) inCountry = selectedloc.Country__c;
        }
        else if (strType == 'router' && selectedloc!=null) {
            resetAddresses(strType);
            if(newRouterVal == 'false')
             {
                 if (selectedloc.PAF_Sub_Building_Name__c!=null) rtFlatNumber = selectedloc.PAF_Sub_Building_Name__c;
                 if (selectedloc.PAF_Building_Name__c!=null) rtBuildingName = selectedloc.PAF_Building_Name__c;
             }
             else
             {
                 if (selectedloc.PAF_Building_Name__c!=null) rtBuildingName = selectedloc.PAF_Building_Name__c;
                 if (selectedloc.PAF_Sub_Building_Name__c!=null) rtFlatNumber = selectedloc.PAF_Sub_Building_Name__c;
             }

            system.debug('PAF_Sub_Building_Name__c ************************************* '+selectedloc.PAF_Sub_Building_Name__c);
            system.debug('rtBuildingName ****************************************  '+rtBuildingName);
            /*if (selectedloc.PAF_Sub_Building_Name__c!=null && selectedloc.PAF_Sub_Building_Name__c!='')
            {
                if (rtBuildingName != null) rtBuildingName = selectedloc.PAF_Sub_Building_Name__c+','+rtBuildingName;
                else rtBuildingName = selectedloc.PAF_Sub_Building_Name__c;//+','+rtBuildingName;
            }*/
            if (selectedloc.PAF_Building_Number__c!=null) rtBuildingNumber = selectedloc.PAF_Building_Number__c;
            if (selectedloc.PAF_Thoroughfare_Name__c!=null) rtStreet = selectedloc.PAF_Thoroughfare_Name__c;
            if (selectedloc.PAF_Thoroughfare_Descriptor__c!=null) rtStreet += selectedloc.PAF_Thoroughfare_Descriptor__c;
            if (selectedloc.PAF_Post_Town__c!=null) rtCity = selectedloc.PAF_Post_Town__c;
            if (selectedloc.PAF_County__c!=null) rtCounty = selectedloc.PAF_County__c;
            if (selectedloc.PAF_Postcode__c!=null) rtPostcode = selectedloc.PAF_Postcode__c;
            if (selectedloc.Country__c!=null) rtCountry = selectedloc.Country__c;
        }
        else if (strType==null || strType=='') {
            throw new O2OnlineException('Could not determine address type to select. Please use the contact form to notify us of this fault.');
        }
    }

    //NON PAF ADDRESS HANDLING
    public void saveNonPAFLocations(String strType, String nonPAFFlatNumber, String nonPAFBuildingName, String nonPAFBuildingNumber, String nonPAFPostalCode, String nonPAFStreet, String nonPAFCity, String nonPAFCounty, String nonPAFCountry){
        Location__c nonPAFLocation = new Location__c(
                                                                Type__c = strType,
                                                                        Sync_with_Parent__c = true,
                                                                        User_Session__c = userSession.userSession.Id,
                                                                        PAF_Sub_Building_Name__c = nonPAFFlatNumber,
                                                                        PAF_Building_Name__c = nonPAFBuildingName,
                                                                        PAF_Building_Number__c = nonPAFBuildingNumber,
                                                                        PAF_Dependent_Thoroughfare_Descriptor__c = '',
                                                                        PAF_Thoroughfare_Descriptor__c = '',
                                                                        PAF_Thoroughfare_Name__c = nonPAFStreet,
                                                                        PAF_Post_Town__c = nonPAFCity,
                                                                        PAF_County__c = nonPAFCounty,
                                                                        PAF_Postcode__c = nonPAFPostalCode,
                                                                        Country__c = nonPAFcountry);
                nonPAFLocationList.add(nonPAFLocation);

    }

    //##### END PAF ADDRESS HANDLING/CACHING CODE #####

    public PageReference addToBasket() {
        apiSession.getController().updateConfig();
        //apiSession.executeRules();
        apiSession.persistConfiguration(true);
        return goToBasket();
    }

    public String newInstallVal{get; set;}
    public String newRouterVal{get; set;}

    public PageReference addProductToSessionBasketThenGotoBasket() {
        addProductToSessionBasket();
        return goToBasket();
    }

    public PageReference addProductToSessionBasket() {
        PageReference pgSAVE_ERROR = Page.O2OnlineExceptionPage;
        System.debug(LoggingLevel.INFO, '### OUTPUT >>>>> addProductToSessionBasket: offerId: '+offerId);
        System.debug('### OUTPUT >>>>> addProductToSessionBasket: initial session variables: userSession--'+userSession);
        System.debug('### OUTPUT >>>>> addProductToSessionBasket: initial session variables: apiSession--'+apiSession);
        //System,debug('### OUTPUT >>>>> addProductToSessionBasket: initial config: config--'+apiSession.getConfiguration().getsObject().Attributes__r);
        if (apiSession!=null) {newApiSession = apiSession;} else initSession();
        if (newAPISession!=null && newUserSession==null) {
            newUserSession = newApiSession.getUserSession();
        }
        else if (newApiSession!=null && newUserSession!=null) newUserSession = newApiSession.loadUserSession(newApiSession.getUserSession().usersession.Id);
        if (newUserSession == null) newUserSession = cscfgc.SessionManager.getSessionInfo();
        if (userSession == null) userSession = newUserSession;

        System.debug('### OUTPUT >>>>> addProductToSessionBasket: new session variables: userSession--'+newUserSession);
        System.debug('### OUTPUT >>>>> addProductToSessionBasket: new session variables: apiSession--'+newApiSession);
        productName = getProduct();
        System.debug(LoggingLevel.INFO, '### OUTPUT >>>>> addProductToSessionBasket: product name: --'+productName);
        if (newApiSession!=null && apiSession!=null) {
            cscfgc.ProductConfiguratorController prodcontroller = newApiSession.getController();
            /*
            Map<String,String> parmMap=ApexPages.currentPage().getParameters();
            for(String parmKey : parmMap.keySet()) {
                System.debug(LoggingLevel.INFO, '*** parm:'+parmKey+' val:'+parmMap.get(parmKey));
            }*/
            cscfgc.ProductConfiguratorController.setParameters(ApexPages.currentPage().getParameters());

            String boltons=newApiSession.getConfiguration().getAttribute('Bolt On').getValue();
            System.debug(LoggingLevel.INFO, '***boltons:'+boltons);

            //update the configuration(s)
            newApiSession.updateConfig();
            // neil start
            newApiSession.executeRules();
            // neil end
            //persists all configurations to the basket
            newApiSession.persistConfiguration(true);
        }
        return null;    //stay on the same page
    }

    public PageReference addSessionToBasket() {
        PageReference pgSAVE_ERROR = Page.O2OnlineExceptionPage;
        System.debug('### OUTPUT >>>>> addSessionToBasket: offerId: '+offerId);
        System.debug('### OUTPUT >>>>> addSessionToBasket: initial session variables: userSession--'+userSession);
        System.debug('### OUTPUT >>>>> addSessionToBasket: initial session variables: apiSession--'+apiSession);
        //System,debug('### OUTPUT >>>>> addSessionToBasket: initial config: config--'+apiSession.getConfiguration().getsObject().Attributes__r);
        if (apiSession!=null) {newApiSession = apiSession;} else initSession();
        if (newAPISession!=null && newUserSession==null) {
                newUserSession = newApiSession.getUserSession();
        }
        else if (newApiSession!=null && newUserSession!=null) newUserSession = newApiSession.loadUserSession(newApiSession.getUserSession().usersession.Id);
        if (newUserSession == null) newUserSession = cscfgc.SessionManager.getSessionInfo();
        if (userSession == null) userSession = newUserSession;

        System.debug('### OUTPUT >>>>> addSessionToBasket: new session variables: userSession--'+newUserSession);
                System.debug('### OUTPUT >>>>> addSessionToBasket: new session variables: apiSession--'+newApiSession);
        productName = getProduct();
        System.debug('### OUTPUT >>>>> addSessionToBasket: product name: --'+productName);
        if (newApiSession!=null && apiSession!=null) {
                cscfgc.ProductConfiguratorController prodcontroller = newApiSession.getController();
                        System.debug('### OUTPUT >>>>> addSessionToBasket: page_parameters: '+ApexPages.currentPage().getParameters());
                        cscfgc.ProductConfiguratorController.setParameters(ApexPages.currentPage().getParameters());
                //SW 26/03/2012 - ADDED IF STATEMENT TO ALLOW SUCCESSFUL EXECUTION FOR NON-LL/BB PRODUCTS
                if (productName.contains('Broadband') || productName.contains('Landline')) {
                    //insert any non-PAF addresses identified for saving
                    if ((inPostcode != null && inPostcode != '') && newInstallAddress == true) {
                            if(locTypes == null || (locTypes!=null && !locTypes.containsKey('Installation'))) {
                                            saveNonPAFLocations('Installation', inFlatNumber, inBuildingName, inBuildingNumber, inPostcode, inStreet, inCity, inCounty, getCountryVal('installation'));
                            }
                    }

                    if (productName.contains('Broadband')) {
                            if(locTypes == null || (locTypes!=null && !locTypes.containsKey('Router'))) {
                                    if((rtPostcode != null && rtPostcode != '') && newRouterAddress == true) {
                                            saveNonPAFLocations('Router', rtFlatNumber, rtBuildingName, rtBuildingNumber, rtPostcode, rtStreet, rtCity, rtCounty, getCountryVal('router'));
                                    }
                            }
                    }

                    if(nonPAFLocationList!=null && nonPAFLocationList.size()>0) {
                            try{insert nonPAFLocationList;}
                            catch(Exception ex) {ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'ERROR: saving nonPAF Locations - '+ex.getMessage()));}
                    }

                    //insert any new addresses identified for saving
                    if (newLocations!=null && newLocations.size()>0) {
                            //for (Location__c loc: newLocations) {loc.Product_Configuration__c = apiSession.getController().getConfig().getsObject().Id;}
                            try {insert newLocations;}
                            catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'ERROR: saving Locations - '+e.getMessage()));}
                    }

                    //push saved locations address into configuartor
                    if(savedLocations != null)
                    {
                        newInstallVal = Apexpages.currentPage().getParameters().get('newInstallAddress');

                        if(productName.contains('Broadband'))
                        {
                            newRouterVal = Apexpages.currentPage().getParameters().get('newRouterAddress');
                        }

                        if(newInstallVal == 'false' && (selectedAddressIndex != '' || selectedAddressIndex != null) && savedLocations.get(selectedAddressIndex) != null)
                        {
                            selectAddress(savedLocations.get(selectedAddressIndex), 'installation');
                        }

                        if(productName.contains('Broadband') && newRouterVal == 'false' && (selectedRouterAddressIndex != '' || selectedRouterAddressIndex != null) && savedLocations.get(selectedRouterAddressIndex) != null)
                        {
                            selectAddress(savedLocations.get(selectedRouterAddressIndex), 'router');
                        }
                    }

                            /*add any minute bolt ons where necessary
                    if (productName.contains('Landline')) {
                            Decimal boltOnPrice = storeMinuteBoltOnsRelatedProduct();       //store the minute bolt-ons values to a related config
                    }*/
                }
                        //update the configuration(s)
                newApiSession.updateConfig();

                // We will need to execute rules asynchronously
                //newApiSession.executeRules();

                        //persists all configurations to the basket
                newApiSession.persistConfiguration(true);
        }

        return goToBasket();
    }
    public PageReference goToBasket() {
        Pagereference p = new Pagereference('/apex/O2OnlineProductPageFinal');
        p.setRedirect(true);
        return p;
    }

    //##################### MINUTE BOLT ONS CODE #########################
    public String minutesDestinationTypes {
        get {if (minutesDestinationTypes == null) return 'Calls to O2 Mobiles'; else return minutesDestinationTypes;}
        set;
    }
    public String minutesNumber {
            get {if (minutesNumber==null) return '0'; else return minutesNumber;}
            set;
    }
    public String cfgTariffCode {
            get {
            	system.debug('get cfg tariff code, api session = ' + apiSession);
            	if (apiSession!=null) system.debug('get cfg tariff code, get Tariff Code = ' + apiSession.getConfiguration().getAttribute('Tariff Code'));
            	if (apiSession!=null) system.debug('get cfg tariff code, get Tariff Code value= ' + apiSession.getConfiguration().getAttribute('Tariff Code').getValue());
            	if (apiSession!=null) system.debug('get cfg tariff code, get configuration = ' + apiSession.getConfiguration().getId());
            	if (apiSession!=null) return apiSession.getConfiguration().getAttribute('Tariff Code').getValue(); else return cfgTariffCode;}
            set {cfgTariffCode = value; if (apiSession!=null) apiSession.getConfiguration().getAttribute('Tariff Code').setValue(value);}
    }
    //####################################################################

    //#################### LINE/CUSTOMER CHECKER CODE ####################
    //Logic to execute checks and route result to page(s)
        public String getLineCheckEnabled() {
                if (OnlineGeneralSettings__c.getInstance('Enable Line Checks')!=null)
                        return OnlineGeneralSettings__c.getInstance('Enable Line Checks').Value__c;
                else return '';
        }
        public String getLiveTrackingEnabled() {
                if (OnlineGeneralSettings__c.getInstance('Enable Live Tracking')!=null)
                        return OnlineGeneralSettings__c.getInstance('Enable Live Tracking').Value__c;
                else return '';
        }
        public String getIE8CompatibilityEnabled() {
                if (OnlineGeneralSettings__c.getInstance('IE8 Compatibility Mode')!=null)
                        return OnlineGeneralSettings__c.getInstance('IE8 Compatibility Mode').Value__c;
                else return '';
        }
        public PageReference enableIE8CompatibilityMode() {
                ApexPages.CurrentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
                return null;
        }
        public String getLiveWebchatEnabled() {
                if (OnlineGeneralSettings__c.getInstance('Enable Live Chat')!=null)
                        return OnlineGeneralSettings__c.getInstance('Enable Live Chat').Value__c;
                else return '';
        }

        public Map<String, String> mpLineCheckResults {get;set;}
        public Map<String, String> mpBBCheckResults {get;set;}
        public Map<String, String> mpSubsCheckResults {get;set;}
        public String checkResult {get;set;}
        public boolean checksOK {get;set;}
        public boolean showContinue {get;set;}
        public boolean showCheck {get;set;}
        public static String TEXT_BB_CHECK_RESULT_1 = Label.ONLINE_SHOP_BB_CHECK_RESULT_1+' '; //.replaceAll('&', '&amp;');
        public static String TEXT_BB_CHECK_RESULT_2 = Label.ONLINE_SHOP_BB_CHECK_RESULT_2; //.replaceAll('&', '&amp;');


        public String O2Customer {get; private set;}
        public String checkProvideType {get; private set;}

    public PageReference performChecks() {
    	system.debug('start perform checks');
        checksOK = false; 
        showContinue = false; 
        showCheck = false; 
        O2Customer='No';
        
        PageReference pgPRODUCT_NOT_SUPPORTED = new PageReference('/apex/O2OnlineContactUsStandard?reason=nonProd');
        PageReference pgCHECK_SUCCESS = null;
        PageReference pgCHECK_FAIL = new PageReference('/apex/O2OnlineContactUsStandard?reason=AvChkFail');
        PageReference pgCHECK_ERROR = Page.O2OnlineExceptionPage;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        checkProvideType = params.get('provideType');
        String existingCustomer = params.get('o2Customer');
        String existingNumber = params.get('existingNumber');
        String transferNumber = params.get('transferNumber');
        String transferPostcode = params.get('transferPostcode');
		String packageType = '';

        try {
        	system.debug('perform checks, api session = '+ apiSession);
            if(apiSession!=null) {
                this.productName = apiSession.getConfiguration().getsObject().cscfgc__product_definition__r.name;
            }
        	system.debug('perform checks, product name = '+ this.productName);
            //system.debug('>>>>> this.productName:'+this.productName);
            boolean isExistingCustomer = existingCustomer=='Yes'?true:false;
            boolean isNewRequest = checkProvideType=='New Provide'?true:false;
            String cType = '';
            
            if(this.productName!=null && this.productName.contains('Landline')) {
            	cType='Line';
            } else if(this.productName!=null && this.productName.contains('Broadband')) {
                cType='Broadband';
                packageType = apiSession.getConfiguration().getAttribute('Package Type').getValue();
            }
            if (this.productName==null) {
            	String currProd = ApexPages.currentPage().getParameters().get(':_product');
	        	system.debug('perform checks, params = '+ ApexPages.currentPage().getParameters());
            	
	        	system.debug('perform checks, product = '+ currProd);
	        	if (currProd != null){
	            	if (currProd.contains('Broadband')) {
	            		cType='Broadband';
	            	}
	            	if (currProd.contains('Landline')) {
	            		cType='Line';
	            	}
	        	}
	        	system.debug('perform checks, cType from product = '+ cType);
            }
            
            if(cType=='') cType='Line';
        	system.debug('perform checks, cType = '+ cType);
            O2OnlineChecks.CheckResponseType  cr = O2OnlineChecks.getCheckResponse2(packageType, existingNumber, transferNumber, transferPostcode, cType, isNewRequest, isExistingCustomer);
            //O2OnlineChecks.getCheckResponse(existingNumber, transferNumber, transferPostcode, cType, isNewRequest, isExistingCustomer);
			//system.debug('perform checks >>>>> cr.responseCode:'+cr.responseCode);
            //system.debug('perform checks >>>>> cr.checkResponseItem.Display_Message__c:'+cr.checkResponseItem.Display_Message__c);
            //system.debug('perform checks >>>>> cr.getDisplayMessage:'+cr.getDisplayMessage());

            if(cType=='Line' && cr.responseCode.contains('4')) {
                /*
                // Replaced by formula - which returns 4 in this case
                    if(cr.checkResponse!=null && cr.checkResponse.Service_Type__c!=null
                    && (cr.checkResponse.Service_Type__c.contains('Multi')
                    || cr.checkResponse.Service_Type__c.contains('ISDN'))) */
                pgPRODUCT_NOT_SUPPORTED.getParameters().put('lineType', cr.checkResponse.Service_Type__c);
                return pgPRODUCT_NOT_SUPPORTED;
            }
            /* SW CDECISIONS 05/01/2012 - COMMENTED OUT SINCE THIS SHOULD BE RETRIEVED FROM checkResponseItem Custom Setting matrix
            if(cType=='Line' && cr.responseCode.contains('B')){
                    O2Customer='Yes';
                    existingCustomer='Yes';
            } else {
                    O2Customer='No';
                    existingCustomer='No';
            }
            */
            if (cr.checkResponseItem.O2_Customer__c!=null) o2Customer = cr.checkResponseItem.O2_Customer__c;
            if (cr.checkResponseItem.O2_Customer__c!=null) existingCustomer = cr.checkResponseItem.O2_Customer__c;
            if (cType=='Broadband' && cr.checkResponseItem.Provide_Type__c!=null) checkProvideType = cr.checkResponseItem.Provide_Type__c;

            checksOK = cr.checkResponseItem.Check_Button_Enabled__c;
            showCheck = cr.checkResponseItem.Check_Button_Enabled__c;
            showContinue = cr.checkResponseItem.Continue_Button_Enabled__c;
            checkResult = cr.getDisplayMessage();
            
			if (apiSession == null) {
				initSession();
			}
			
            if(cr.checkResponse!=null && checkResult!=null) {
            	if(cType=='Broadband' && cr.checkResponse.predictedDownloadSpeed__c!=null) {
                    cscfgc.ProductConfiguration currConfig = apiSession.getConfiguration();
                    currConfig = O2OrderHelper.populateConfiguration(getProduct(), currConfig, cr.checkResponse.Id);
                    system.debug('perform checks, curr config = ' + currConfig);
                    String strLineSpeed = currConfig.getAttribute('Download Speed').getValue();
                    if (strLineSpeed==null || strLineSpeed=='') strLineSpeed = cr.checkResponse.predictedDownloadSpeed__c;
                    Pattern p = Pattern.compile('[a-zA-Z]');
                    String strLineSpeedFormatted = p.matcher(strLineSpeed).replaceAll('');
                    checkResult = checkResult.replaceAll('<x MB>',strLineSpeedFormatted+' MB');
                    }
                if(cType=='Line' && cr.checkResponse.Status__c=='Completed') {
                    String strLineType = '';
                    cscfgc.ProductConfiguration currConfig = apiSession.getConfiguration();
                    currConfig = O2OrderHelper.populateConfiguration(getProduct(), currConfig, cr.checkResponse.Id);
                    strLineType = currConfig.getAttribute('Line Type').getValue();
                    checkResult = checkResult.replaceAll('<line type>',strLineType);
                }
            }
			if (apiSession!=null) {
	            if (apiSession.getConfiguration()!=null) {
	                /*
	                if(cr.checkResponseItem.O2_Customer__c!=null && apiSession.getConfiguration().getAttribute('O2 Customer')!=null) {
	                    //system.debug('>>>>> Setting configurator attribute: O2 Customer:'+cr.checkResponseItem.O2_Customer__c);
	                    apiSession.getConfiguration().getAttribute('O2 Customer').setValue(cr.checkResponseItem.O2_Customer__c);
	                }*/
	                if(cr.checkResponseItem.Provide_Type__c!=null && apiSession.getConfiguration().getAttribute('Provide Type')!=null) {
	                    //system.debug('>>>>> Setting configurator attribute: Provide Type:'+cr.checkResponseItem.Provide_Type__c);
	                    apiSession.getConfiguration().getAttribute('Provide Type').setValue(cr.checkResponseItem.Provide_Type__c);
	                }
	                if(cr.checkResponseItem.New_Order_Type__c!=null && apiSession.getConfiguration().getAttribute('New Order Type')!=null) {
	                    //system.debug('>>>>> Setting configurator attribute: New Order Type:'+cr.checkResponseItem.New_Order_Type__c);
	                    apiSession.getConfiguration().getAttribute('New Order Type').setValue(cr.checkResponseItem.New_Order_Type__c);
	                }
	                if(cType=='Line') {
	                    if(apiSession.getConfiguration().getAttribute('Provide Type')!=null) {
	                        apiSession.getConfiguration().getAttribute('Provide Type').setValue('Transfer');
	                        //system.debug('>>>>> Setting configurator attribute: Provide Type: Transfer');
	                    }
	                    if(apiSession.getConfiguration().getAttribute('Installation Work Required?')!=null) {
	                        apiSession.getConfiguration().getAttribute('Installation Work Required?').setValue('No');
	                        //system.debug('>>>>> Setting configurator attribute: Installation Work Required?: No');
	                    }
	                }
	                if(cr.responseCode.contains('B')){
	                    apiSession.getConfiguration().getAttribute('O2 Customer').setValue('Yes');
	                } else {
	                    apiSession.getConfiguration().getAttribute('O2 Customer').setValue('No');
	                }
	          	}
            }
            //System.debug('>>>>> checksOK:'+checksOK);
            //System.debug('>>>>> showCheck:'+showCheck);
            //System.debug('>>>>> showContinue:'+showContinue);
			System.debug('perform checks, cr=' + cr);
			System.debug('perform checks, response code=' + cr.responseCode);
			System.debug('perform checks, check response=' + cr.checkResponse);
			/*System.debug('BB >>>>>' + 
            	' inputs: ' + 
            		' | packageType: ' + packageType +
                	' | checkProvideType: ' + params.get('provideType') + 
	            	' | params.get(o2Customer): ' + params.get('o2Customer') +
	        		' | local.existingCustomer: ' + existingCustomer +
					' | existingNumber: ' + params.get('existingNumber') +
	        		' | transferNumber: ' + params.get('transferNumber') +
	        		' | transferPostcode: ' + params.get('transferPostcode') +
	        	//'api session: ' +
	            //	' | O2 Customer: ' + apiSession.getConfiguration().getAttribute('O2 Customer').getValue() + 
	            ' outputs: ' + 
	            	//' | productlist: ' + cr.checkResponse.productList__c + 
	            	' | productName: ' + this.productName +
	            	' | checksOK: ' + checksOK + 
	            	' | showCheck: '+ showCheck + 
	            	' | showContinue: ' + showContinue + 
	            	' | checkProvideType: ' + checkProvideType + 
	            	' | checkResult: ' + checkResult + 
	            	' | checkResponse.responseCode: ' + cr.responseCode + 
	            	' | lineavailability.id: ' + cr.checkResponse.Id + ''
	            	//' | checkResponseItem.Display_Message__c: ' + cr.checkResponseItem.Display_Message__c +
			);*/
        } catch (Exception e) {
        	system.debug('perform checks, exception=' + e);
        	system.debug('perform checks, exception msg=' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return pgCHECK_ERROR;
        }
        return pgCHECK_SUCCESS;
    }

    /*### SW 15/03/2012 - OLD LINE CHECKER CODE REMOVED ###*/

    //####################################################################
    //########################## TO BE FIXED #############################
    public cscfgc__Product_Basket__c sessionbasket {get;set;}
    //public cscfgc__Product_Basket__c currentbasket {get;set;} //SW CDECISIONS 10/01/2012 - commented out since currentbasket no longer set from product basket controller
    public List<cscfgc__Product_Configuration__c> currentConfigs {get;set;}       //SW CDECISIONS 10/01/2012 - added in place of currentbasket set from product basket controller
    public String numProducts {get;set;}
    public PageReference emptyBasket() {
        //parentController.userSession.clearBasket();
        System.debug('### OUTPUT >>>>> emptyBasket: '+sessionbasket);
        if (sessionbasket!=null && currentConfigs != null)
        {
            //List<cscfgc__Product_Configuration__c> prodList = new List<cscfgc__Product_Configuration__c>(currentBasket.cscfgc__Product_Configurations__r);
            System.debug('### OUTPUT >>>>> emptyBasket: prodList: '+currentConfigs);     //SW CDECISIONS 10/01/2012 - replaced prodList with currentConfigs
            cscfgc.ProductBasketManager.removeProductsFromBasket(currentConfigs, sessionbasket);        //SW CDECISIONS 10/01/2012 - replaced prodList with currentConfigs
            cscfgc.ProductBasketManager.updateBasketStatusAndTotal(sessionbasket);
        }
        return null;
    }
     //####################################################################  AK

     /*
    public PageReference startSession() {
        System.debug('>>>>>>>> startSession(): ' + newUserSession);
        if (newUserSession==null) newUserSession = cscfgc.SessionManager.getSessionInfo();
        sessionbasket = newUserSession.getSessionBasket();
        System.debug('>>>>>>>> end startSession(): ' + newUserSession.userSession.id);
        return null;
    }
     */
        //####################################################################  AK
    public cscfgc.SessionManager.SessionInfo basketUserSession {get;set;}
    public PageReference startSession() {

        string IsEmailBasket=System.currentPagereference().getParameters().get('IsEmailBasket');
        string bSessionId=System.currentPagereference().getParameters().get('bSessionId');

        System.debug('>>>>>>>> startSession(): ' + newUserSession);
        if (IsEmailBasket=='Yes' ){
            basketUserSession = cscfgc.SessionManager.getSessionByKey(bSessionId);
            //TODO if basketUserSession is null this needs to be redirected to a another page.
            sessionbasket = basketUserSession.getSessionBasket();
            System.debug('>>>>>>>> sessionbasket(): ' + sessionbasket);
            System.debug('>>>>>>>> sessionbasket(): ' + sessionbasket.cscfgc__product_configurations__r);
            //Query all the product config and run rules
           /*
            for (cscfgc__Product_Configuration__c config : sessionbasket.cscfgc__product_configurations__r) {
                    apiSession = cscfgc.API_1.getApiSession(new cscfgc__Product_Configuration__c(id = config.id), screenFlowName);
                    apiSession.executeRules();
                    System.debug('>>>>>>>> apiSession ' + apiSession );
               }
              */
            return null;
        }
        else {
        	System.debug('start session, newUserSession = ' + newUserSession);
            if (newUserSession==null) newUserSession = cscfgc.SessionManager.getSessionInfo();
            System.debug('start session, newUserSession = ' + newUserSession);
            sessionbasket = newUserSession.getSessionBasket();
            System.debug('start session, sessionbasket = ' + sessionbasket);
            System.debug('>>>>>>>> end startSession(): ' + newUserSession.userSession.id);
            return null;
        }
    }



     //####################################################################  AK

    public PageReference proceedToCheckout() {
        System.debug('### OUTPUT >>>>> proceedToCheckout: start');
            cscfgc__Product_Basket__c basket = cscfgc.SessionManager.getSessionInfo().getSessionBasket();
                Map<Id, cscfgc__Product_Configuration__c> configsById = O2OnlineProductBasketController.getConfigsById(basket.cscfgc__Product_Configurations__r);
                List<cscfgc__Product_Configuration__c> drafts = new List<cscfgc__Product_Configuration__c>();
                for (cscfgc__Product_Configuration__c cfg: basket.cscfgc__Product_Configurations__r) {
                        String status = cfg.cscfgc__configuration_status__c;
                        if (cfg.cscfgc__parent_configuration__c != null) {
                                cscfgc__Product_Configuration__c parent = configsById.get(cfg.cscfgc__parent_configuration__c);
                                if (parent != null) status = parent.cscfgc__configuration_status__c;
                        }
                        if (status == O2OnlineProductBasketController.DRAFT_STATUS) {
                                drafts.add(cfg);
                        }
                }
                delete drafts;
        if (getSecureCheckoutEnabled() && OnlineGeneralSettings__c.getInstance('Secure Online Shop URL')!=null) {
            return new PageReference(OnlineGeneralSettings__c.getInstance('Secure Online Shop URL').Value__c + '/O2OnlineCheckoutPage1');
        } else return Page.O2OnlineCheckoutPage1;
    }
    public Boolean getSecureCheckoutEnabled() {
        Boolean boolEnabled = false;
        if (OnlineGeneralSettings__c.getInstance('Secure Checkout')!=null && OnlineGeneralSettings__c.getInstance('Secure Checkout').Value__c=='Y') boolEnabled=true;
        return boolEnabled;
    }
     //#################################################################### AK
    public PageReference continueShopping() {
        if (OnlineGeneralSettings__c.getInstance('Online Shop URL')!=null){
                String strResult = '';
                strResult = OnlineGeneralSettings__c.getInstance('Online Shop URL').Value__c;
                //return new PageReference('http://businessshop.o2.co.uk');
                return new PageReference(strResult);
                }
        else return null;
           }
        //####################################################################

    public class CoremetricsShopAction5Info {
        public string ProductId { get; set; }
        public string ProductName { get; set; }
        public double Quantity { get; set; }
        public double Price { get; set; }
        public string Category { get; set; }

        public CoremetricsShopAction5Info() {}
        public CoremetricsShopAction5Info(string prodId, string prodName, double quantity, double price, string category) {
            this.ProductId = prodId;
            this.ProductName = prodName;
            this.Quantity = quantity;
            this.Price = price;
            this.Category = category;
        }
    }

    public static final String CM_CATEGORY_TARIFFS = 'Business-shop tariffs';
    public static final String CM_CATEGORY_PHONES = 'Business-shop phones';
    public static final String CM_CATEGORY_BOLTONS = 'Business-shop bolt-ons';
    public static final String CM_CATEGORY_ACCESSORIES = 'Business-shop accessories';

    public string getCoremetricsShopAction5Infos() {
        system.debug('>>>> getting ShopAction5Infos for basket: ' + sessionbasket.id);

        CoremetricsShopAction5Info[] result = new CoremetricsShopAction5Info[] {};

        cscfgc__Product_Configuration__c[] allBasketConfigs =
                            [SELECT Id, Name, cscfgc__Total_Price__c, cscfgc__Recurring_Charge__c, cscfgc__Product_Basket__c, cscfgc__Product_Bundle__c, cscfgc__One_Off_Charge__c,
                                    cscfgc__configuration_status__c, cscfgc__Parent_Configuration__c, cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name, cscfgc__Screen_Flow__r.Name,
                                    (SELECT Id, Name, cscfgc__Price__c, cscfgc__Value__c
                                        FROM cscfgc__Attributes__r
                                        WHERE Name IN ('Primary Handset Tariff Code', 'Primary Handset Package Code', 'Voice Tariff Name', 'Line Rental', 'SKU', 'Tariff', 'Hardware',
                                                        'Primary Handset Model', 'Handset Price', 'Service Code', 'Service Name', 'Price', 'Accessory Product Code',
                                                        'Accessory Description', 'Quantity', 'Total Price', 'Product Code', 'Tariff Description', 'Tariff Price',
                                                      /*zz 121029 duplicate product code -> product*/  'Product', 'Hardware Description', 'Hardware Price', 'Payment Period', 'Contact Term', 'Care Package',
                                                        'Monthly Tariff', 'Tariff Code', 'Package Code', 'Caller Display', 'O2 Controlled Selective Call Barring', 'Remote Call Forwarding',
                                                        'Call Sign', 'Call Minder', 'Call Waiting', 'Extra Minutes Type', 'Package Type', 'Care Package Line Item Description'))
                             FROM cscfgc__Product_Configuration__c
                             WHERE cscfgc__Product_Basket__c=:sessionbasket.Id ORDER BY cscfgc__Serial_Number__c desc];

        for (cscfgc__Product_Configuration__c cfg : allBasketConfigs) {
            if (cfg.cscfgc__Parent_Configuration__c == null && cfg.cscfgc__configuration_status__c != O2OnlineProductBasketController.DRAFT_STATUS) {
                map<string, cscfgc__Attribute__c> atts = getAttsMap(cfg);

                //
                // Business Single Tariff
                if (cfg.cscfgc__Product_Definition__r.Name == 'Business Single Tariff') {

                    // Tariff
                    result.add(new CoremetricsShopAction5Info(
                        getAttValueSafe(atts.get('Primary Handset Tariff Code')) + '_' + getAttValueSafe(atts.get('Primary Handset Package Code')),
                        getAttValueSafe(atts.get('Voice Tariff Name')),
                        1,
                        tryParseDouble(getAttValueSafe(atts.get('Line Rental'))),
                        CM_CATEGORY_TARIFFS
                    ));


                    //Handset
                    if (atts.containsKey('SKU') && atts.get('SKU').cscfgc__Value__c != null) {
                        result.add(new CoremetricsShopAction5Info(
                            getAttValueSafe(atts.get('SKU')),
                            getAttValueSafe(atts.get('Primary Handset Model')),
                            1,
                            tryParseDouble(getAttValueSafe(atts.get('Handset Price'))),
                            CM_CATEGORY_PHONES
                        ));
                    }

                    //Child configurations
                    for (cscfgc__Product_Configuration__c childCfg : allBasketConfigs) {
                        if (childCfg.cscfgc__Parent_Configuration__c == cfg.id) {
                            map<string, cscfgc__Attribute__c> childAtts = getAttsMap(childCfg);

                            // BOLT ONs
                            if (childAtts.containsKey('Parent Name') && childAtts.get('Parent Name').cscfgc__Value__c == 'Bolt On') {
                                result.add(new CoremetricsShopAction5Info(
                                    getAttValueSafe(childAtts.get('Service Code')),
                                    getAttValueSafe(childAtts.get('Service Name')),
                                    1,
                                    tryParseDouble(getAttValueSafe(childAtts.get('Price'))),
                                    CM_CATEGORY_BOLTONS
                                ));
                            }
                            // ACCESSORIES
                            else if (childCfg.cscfgc__Product_Definition__r.Name == 'Business Mobile Accessories') {
                                result.add(new CoremetricsShopAction5Info(
                                    getAttValueSafe(childAtts.get('Accessory Product Code')),
                                    getAttValueSafe(childAtts.get('Accessory Description')),
                                    tryParseDouble(getAttValueSafe(childAtts.get('Quantity'))),
                                    tryParseDouble(getAttValueSafe(childAtts.get('Total Price'))),
                                    CM_CATEGORY_ACCESSORIES
                                ));
                            }
                        }
                    }
                }
                else if (cfg.cscfgc__Product_Definition__r.Name == 'Mobile Broadband') {
                    // SW CDECISIONS 19/09/2012 - added as this was absent to support mobile products
                    // Tariff
                    if (atts.containsKey('Tariff') && atts.get('Tariff').cscfgc__Value__c != null) {
                        result.add(new CoremetricsShopAction5Info(
                            getAttValueSafe(atts.get('Tariff Code')) + '_' + getAttValueSafe(atts.get('Package Code')),
                            getAttValueSafe(atts.get('Tariff Description')),
                            1,
                            tryParseDouble(getAttValueSafe(atts.get('Tariff Price'))),
                            CM_CATEGORY_TARIFFS
                        ));
                    }

                    //Handset
                    if (atts.containsKey('Hardware') && atts.get('Hardware').cscfgc__Value__c != null) {
                        result.add(new CoremetricsShopAction5Info(
                            getAttValueSafe(atts.get('Product Code')),
                            getAttValueSafe(atts.get('Hardware Description')),
                            1,
                            tryParseDouble(getAttValueSafe(atts.get('Hardware Price'))),
                            CM_CATEGORY_PHONES
                        ));
                    }
                }

                //
                // SMB Landline
                else if (cfg.cscfgc__Product_Definition__r.Name == 'SMB Landline') {

                    // Tariff
                    result.add(new CoremetricsShopAction5Info(
                        'Landline_' + getAttValueSafe(atts.get('Payment Period')) + '_' + getAttValueSafe(atts.get('Contract Term'))  + '_' + getAttValueSafe(atts.get('Care Package')) + '_Basket',
                        getAttValueSafe(atts.get('Payment Period')) + ' ' + getAttValueSafe(atts.get('Contract Term')),
                        1,
                        tryParseDouble(getAttValueSafe(atts.get('Monthly Tariff'))),
                        'business-shop landline ' + getAttValueSafe(atts.get('Care Package'))
                    ));

                    string tariffCode = getAttValueSafe(atts.get('Tariff Code'));

                    //Child configurations
                    for (cscfgc__Product_Configuration__c childCfg : allBasketConfigs) {
                        if (childCfg.cscfgc__Parent_Configuration__c == cfg.id) {
                            map<string, cscfgc__Attribute__c> childAtts = getAttsMap(childCfg);

                            // Landline Boltons
                            if (childCfg.cscfgc__Product_Definition__r.Name == 'Landline Bolt Ons') {

                                string callerDisplay = getAttValueSafe(childAtts.get('Caller Display'));
                                string callBarring = getAttValueSafe(childAtts.get('O2 Controlled Selective Call Barring'));
                                string remoteCallForwarding = getAttValueSafe(childAtts.get('Remote Call Forwarding'));
                                string callSign = getAttValueSafe(childAtts.get('Call Sign'));
                                string callMinder = getAttValueSafe(childAtts.get('Call Minder'));
                                string callWaiting = getAttValueSafe(childAtts.get('Call Waiting'));

                                O2_Dise_Map_Landline_Wrapper[] serviceCodes = getDiseServiceCodes(tariffCode,
                                        new List<string[]> {
                                            new string[] { 'Caller Display', callerDisplay },
                                            new string[] { 'O2 Controlled Selective Call Barring', callBarring },
                                            new string[] { 'Remote Call Forwarding', remoteCallForwarding },
                                            new string[] { 'Call Sign', callSign },
                                            new string[] { 'Call Minder', callMinder },
                                            new string[] { 'Call Waiting', callWaiting }
                                        });

                                for (O2_Dise_Map_Landline_Wrapper dml : serviceCodes) {
                                    if (dml.ServiceCode != null && dml.ServiceCode.trim() != '') {
                                        string prodName =
                                            dml.AttributeName == 'Caller Display' ? 'Caller Display' :
                                            dml.AttributeName == 'O2 Controlled Selective Call Barring' ? 'Call Barring' :
                                            dml.AttributeName == 'Remote Call Forwarding' ? 'Call Forwarding' :
                                            dml.AttributeName == 'Call Sign' ? 'Call Sign' :
                                            dml.AttributeName == 'Call Minder' ? 'Call Minder' :
                                            dml.AttributeName == 'Call Waiting' ? 'Call Waiting' : '';

                                        double price = tryParseDouble(getAttPriceSafe(childAtts.get(dml.AttributeName)));

                                        result.add(new CoremetricsShopAction5Info(
                                            dml.ServiceCode,
                                            prodName,
                                            1,
                                            price,
                                            'business-shop landline bolt-ons'
                                        ));
                                    }
                                }
                            }

                            // Fixed Line Boltons
                            else if (childCfg.cscfgc__Product_Definition__r.Name == 'Fixed Line Minute Bolt On') {
                                string serviceCode = getAttValueSafe(childAtts.get('Service Code'));

                                if(serviceCode != null && serviceCode.trim() != '') {
                                    result.add(new CoremetricsShopAction5Info(
                                        serviceCode + '_Basket',
                                        getAttValueSafe(childAtts.get('Extra Minutes Type')),
                                        1,
                                        tryParseDouble(getAttValueSafe(childAtts.get('Price')).replace('£', '')),
                                        'business-shop landline bolt-ons'
                                    ));
                                }
                            }
                        }
                    }
                }

                // SMB Business Broadband
                else if (cfg.cscfgc__Product_Definition__r.Name == 'SMB Business Broadband') {
                    result.add(new CoremetricsShopAction5Info(
                        getAttValueSafe(atts.get('Tariff Code')),
                        getAttValueSafe(atts.get('Package Type')),
                        1,
                        tryParseDouble(getAttPriceSafe(atts.get('Package Type'))),
                        'business-shop broadband ' + getAttValueSafe(atts.get('Care Package Line Item Description'))
                    ));
                }
                //------------------------------here put the mobile landline action 5 tags!!!!
                 // Mobile Landline string prodId, string prodName, double quantity, double price, string category
                else if (cfg.cscfgc__Product_Definition__r.Name == 'Mobile Landline') {
                    result.add(new CoremetricsShopAction5Info(
                        getAttValueSafe(atts.get('Tariff Code')),
                        getAttValueSafe(atts.get('Product')),
                        1,
                        tryParseDouble(getAttPriceSafe(atts.get('Price'))),
                        'business-shop mobile landline'
                    ));
                }

            }
        }

        return JSON.serialize(result).replaceAll('\'', '\\\'');
    }

    static map<string, cscfgc__Attribute__c> getAttsMap(cscfgc__Product_Configuration__c cfg) {
        map<string, cscfgc__Attribute__c> atts = new map<string, cscfgc__Attribute__c>();
        for (cscfgc__Attribute__c att : cfg.cscfgc__Attributes__r) {
            atts.put(att.Name, att);
        }
        return atts;
    }

    static double tryParseDouble(string d) {
        try {
            return decimal.valueof(d);
        } catch(Exception ex) {
            return 0;
        }
    }
    static string getAttValueSafe(cscfgc__Attribute__c att) {
        if (att != null) return att.cscfgc__Value__c;
        return '';
    }
    static string getAttPriceSafe(cscfgc__Attribute__c att) {
        if (att != null && att.cscfgc__Price__c != null) return  string.valueof(att.cscfgc__Price__c);
        return '';
    }

    @RemoteAction
    global static O2_Dise_Map_Landline_Wrapper[] getDiseServiceCodes(string tariffCode, List<string[]> attributeValues) {
        if (attributeValues == null || attributeValues.size() == 0) {
            return null;
        }

        string query = 'select service_code__c, attribute_name__c, attribute_value__c, tariff_code__c ' +
                        'from O2_DISE_Map_Landline__c ' +
                        'WHERE tariff_code__c = \'' + tariffCode + '\' AND (';

        boolean isFirst = true;

        for (integer i=0; i<attributeValues.size(); i++) {
            if (isFirst == false) {
                query += ' OR ';
            }

            query += ' (attribute_name__c = \'' + attributeValues[i][0] + '\' AND ';
            query += ' attribute_value__c = \'' + attributeValues[i][1] + '\') ';

            isFirst = false;
        }

        query += ' )';

        sObject[] queryResult = Database.query(query);
        map<string, O2_Dise_Map_Landline_Wrapper> result = new map<string, O2_Dise_Map_Landline_Wrapper>();

        for (sObject so : queryResult) {
            O2_DISE_Map_Landline__c dml = (O2_DISE_Map_Landline__c)so;
            string key = dml.Attribute_Name__c + ',' + dml.Attribute_Value__c + ',' + dml.Tariff_Code__c;
            if (result.containsKey(key)) {
                O2_Dise_Map_Landline_Wrapper dmlWrapper = result.get(key);
                dmlWrapper.ServiceCode += dml.Service_Code__c;
            } else {
                result.put(key, new O2_Dise_Map_Landline_Wrapper(dml.Service_Code__c, dml.Attribute_Name__c, dml.Attribute_Value__c, dml.Tariff_Code__c));
            }
        }

        return result.values();
    }

    global class O2_Dise_Map_Landline_Wrapper {
        public string ServiceCode { get; set; }
        public string AttributeName { get; set; }
        public string AttributeValue { get; set; }
        public string TariffCode { get; set; }

        public O2_Dise_Map_Landline_Wrapper() {}
        public O2_Dise_Map_Landline_Wrapper(string serviceCode, string attributeName, string attributeValue, string tariffCode) {
            this.ServiceCode = serviceCode;
            this.AttributeName = attributeName;
            this.AttributeValue = attributeValue;
            this.TariffCode = tariffCode;
        }
    }

    public boolean OneTagEnabled{
        get{
                return OnlineGeneralSettings__c.getInstance('OneTagEnabled').Value__c == 'Y';
        }
        private set;
    }

        public boolean showCoverageCheckMessage{
                get{
                        string v = OnlineGeneralSettings__c.getInstance('COVERAGE_CHECK_MESSAGE_ENABLED').Value__c;
                        return v == 'Y';
                }
        }

}