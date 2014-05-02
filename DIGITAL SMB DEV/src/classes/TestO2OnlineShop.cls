public with sharing class TestO2OnlineShop {
    // for setup data
    private static Account acc {get; set;}
    private static Contact con {get; set;}
    private static Opportunity oppr {get; set;}
    private static cscfgc__Product_Definition__c prodDef {get; set;}
    private static cscfgc__Product_Bundle__c bundle {get; set;}
    private static cscfgc__Product_Configuration__c prodConfig {get; set;}
    private static cscfgc__Configuration_Offer__c offer {get; set;}
    // for run time data
    public cscfgc__Product_Basket__c sessionbasket {get;set;}
    cscfgc.SessionManager.SessionInfo userSession {get; set;}
    private static Location__c loc {get; set;}
    private static List<Location__c> locs {get; set;}
    private static AddressCheckController.Address address {get; set;}
    private static String flatNumber {get;set;}
    private static String buildingName  {get;set;}
    private static String buildingNo  {get;set;}
    private static String postalCode  {get;set;}
    private static String streetName  {get;set;}
    private static String cityName  {get;set;}
    private static String countyName  {get;set;}
    private static String selectedCountry  {get;set;}

    private static cscfgc__Product_Definition__c initLandline() {

        // Get a Product - we haven't got time to create the Unit Test Product - for now we rely on an existing one
        cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
        pd = [Select Id, Name from cscfgc__Product_Definition__c WHERE Name = 'SMB Landline' LIMIT 1];

        // Create a Screen Flow
        cscfgc__Screen_Flow__c sflow = new cscfgc__Screen_Flow__c();
        sflow.Name = 'JUC-Unit-Test';
        sflow.cscfgc__Landing_Page_Reference__c = 'BusinessShopLanding3';
        sflow.cscfgc__Template_Reference__c = 'o2VfMainTemplate';
        insert sflow;

        // Create a Configuration Screen
        //cscfgc__Configuration_Screen__c csc =
        //Select c.cscfgc__Type__c, c.cscfgc__Show_Product_Configuration_header__c, c.cscfgc__Show_Configuration_and_Product_Name__c, c.cscfgc__Screen_Flow__c, c.cscfgc__Screen_Flow_Index__c, c.cscfgc__Reference__c, c.Name From cscfgc__Configuration_Screen__c c

        // Create a screen section
        cscfgc__Screen_Section__c ss = new cscfgc__Screen_Section__c();
        ss.Name = 'UNIT TEST';
        //ss.cscfgc__Index__c = '0';
        //insert ss;

        // Create a Screen Flow Product Association
        cscfgc__Screen_Flow_Product_Association__c sfpa = new cscfgc__Screen_Flow_Product_Association__c();
        sfpa.cscfgc__Product_Definition__c = pd.id;
        sfpa.cscfgc__Screen_Flow__c = sflow.id;
        insert sfpa;

        // Create Site Page
        Site_Page__c sp = new Site_Page__c();
        sp.Name = 'JUC-Unit-Test';
        insert sp;

        // Create Page Product
        Page_Product__c pp = new Page_Product__c();
        pp.Name = 'JUC-Unit-Test';
        pp.Site_Page__c = sp.Id;
        pp.Type__c = 'Product Selection';
        pp.Sequence__c = 0;
        pp.Product_Definition__c = pd.Id;
        pp.Screen_Flow__c = sflow.Id;
        insert pp;

        return pd;
    }

    private static cscfgc__Product_Definition__c initBroadband() {
        cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
        pd = [Select Id, Name from cscfgc__Product_Definition__c WHERE Name = 'SMB Business Broadband' LIMIT 1];

        // Create a Screen Flow
        cscfgc__Screen_Flow__c sflow = new cscfgc__Screen_Flow__c();
        sflow.Name = 'JUC-Unit-Test';
        sflow.cscfgc__Landing_Page_Reference__c = 'BusinessShopLanding3';
        sflow.cscfgc__Template_Reference__c = 'o2VfMainTemplate';
        insert sflow;

        return pd;
    }

    static testmethod void testO2OnlineCheckoutExtension() {
        initLandline();
        //PageReference pg = Page.O2

    }

    static testmethod void testPageProductsController() {
        initLandline();

        PageProductsController ppc = new PageProductsController();
        ppc.productName = 'JUC-Unit-Test';
        ppc.siteNameValue = 'JUC-Unit-Test';
        ppc.queryProducts();    //SW CDECISIONS 17/04/2012 - changed from getProducts for new cached collection design pattern
        ppc.getProduct();
        ppc.getHasScrollableContent();  //SW CDECISIONS 17/04/2012 - added method call in to test whether page product has any scrollable content
    }

/* no longer needed
    static testmethod void testOnlineOrderController() {
        cscfgc__Product_Definition__c pdef = initLandline();
        PageReference pg = Page.O2BusinessShopLanding3;
        Test.setCurrentPage(pg);

        O2OnlineOrderController parentCtrl = new O2OnlineOrderController();
        parentCtrl.startSession();
        parentCtrl.definitionId = pdef.id;
        parentCtrl.selectProduct();
        parentCtrl.getController();

        parentCtrl.transferNumber = '012345678';
        parentCtrl.transferPostcode = 'AA1 1AA';
        parentCtrl.provideType = 'Transfer';
        parentCtrl.landlineCheck();

        //parentCtrl.broadbandCheck();
        parentCtrl.getprovideType();

        parentCtrl.screenIndex = '0';
        parentCtrl.selectScreen();

        parentCtrl.getCurrentConfigScreenIndex();
        parentCtrl.getCurrentScreenName();
        parentCtrl.getexistingCustomer();
        parentCtrl.getexistingNumber();
        parentCtrl.getprovideType();

        parentCtrl.addToBasket();

        parentCtrl.proceedToCheckout();

    }

    static testmethod void testOnlineOrderControllerBB() {
        cscfgc__Product_Definition__c pdef = initBroadband();
        PageReference pg = Page.O2BusinessShopLanding3;
        Test.setCurrentPage(pg);

        O2OnlineOrderController parentCtrl = new O2OnlineOrderController();
        parentCtrl.startSession();
        parentCtrl.definitionId = pdef.id;
        parentCtrl.selectProduct();
        parentCtrl.getController();

        parentCtrl.transferNumber = '012345678';
        parentCtrl.transferPostcode = 'AA1 1AA';
        parentCtrl.provideType = 'New';
        parentCtrl.broadbandCheck();

        parentCtrl.getprovideType();
    }
*/
    static void testBasketConfiguration(O2OnlineProductBasketController pbc) {
        O2OnlineProductBasketController.BasketConfiguration bc = new O2OnlineProductBasketController.BasketConfiguration();

        bc.index = 1;
        Integer newIndex = bc.index;
        system.assertEquals(1, newIndex);

        cscfgc__Product_Configuration__c oldCfg = new cscfgc__Product_Configuration__c();
        bc.cfg = oldCfg;
        system.assertEquals(oldCfg, bc.cfg);

        bc.dRecurringPrice = 2.0;
        system.assertEquals(2.0, bc.dRecurringPrice);

        bc.dOneOffPrice  = 2.0;
        system.assertEquals(2.0, bc.dOneOffPrice );
    }

    static testmethod void testOnlineProductBasketController() {
        cscfgc__Product_Definition__c pdef = initLandline();
        PageReference pg = Page.O2BusinessShopLanding3;
        Test.setCurrentPage(pg);

        // ntj - the parent controller is now an O2OnlineMainController
        //O2OnlineOrderController parentCtrl = new O2OnlineOrderController();
        O2OnlineMainController parentCtrl = new O2OnlineMainController();
        parentCtrl.startSession();
        parentCtrl.definitionId = pdef.id;
        parentCtrl.selectProduct();
        parentCtrl.getController();
        parentCtrl.addToBasket();
        // ntj - Main Controller does not have a getConfig() method
        // 001 Id pcId = parentCtrl.getConfig().getSobject().id;

        O2OnlineProductBasketController ctrl = new O2OnlineProductBasketController();
        ctrl.parentController = parentCtrl;
        ctrl.getBasketSize();
        ctrl.getBasketProducts();
        // ntj - Main Controller does not have a getcurrentBasket() method
        // 001 ctrl.getcurrentBasket();
        // ntj - Main Controller does not have a getConfig() method
        // 001 ctrl.editConfigId = pcId;
        //ctrl.editProductInBasket();
        //ctrl.emptyBasket();

        // ntj - new tests

        // use the other form of the constructor
        O2OnlineProductBasketController ctrl2 = new O2OnlineProductBasketController(parentCtrl);

        testBasketConfiguration(ctrl2);

        Decimal dTR = ctrl2.getTotalRecurring();
        Decimal dTOO = ctrl2.getTotalOneOff();

        O2OnlineProductBasketController.BasketConfiguration[] bcs = ctrl2.getBasketConfigs();

        PageReference pr = ctrl2.editProductInBasket();

        pr = ctrl2.removeProductFromBasket();

        ctrl2.emptyBasket();
        List<O2OnlineProductBasketController.BasketCategory> basktCats = ctrl2.getBasketCategories();
        System.assert(basktCats!=null);

        O2OnlineProductBasketController ctrl3 = new O2OnlineProductBasketController(parentCtrl);
        ctrl3.retrieveBasket();

    }

    static testmethod void testO2OrderHelper() {
        // Not required - separate test class in development
    }

    static O2OnlineMainController getO2OnlineMainController() {
        // set the current page
        PageReference pg = Page.O2BusinessShopLandlineLanding;
        Test.setCurrentPage(pg);

        // set the parameters
        // TODO: may need to revisit this, just using dummy values for now
        pg.getParameters().put('ref', 'Fixed Line:SMB:SMB Landline:SMB Landline');
        pg.getParameters().put('def', 'def');
        pg.getParameters().put('offer', offer.Id);
        pg.getParameters().put('screenflowname', 'SMB Landline Flow');
        pg.getParameters().put('generator', '0');

        // call the constructor
        O2OnlineMainController omc = new O2OnlineMainController();
        return omc;
    }

    static void testProperties(O2OnlineMainController omc) {
        // set/get/compare
        cscfgc.API_1.ApiSession oldSession = new cscfgc.API_1.ApiSession();
        omc.apiSession = oldSession;
        cscfgc.API_1.ApiSession newSession = omc.apiSession;
        system.assertEquals(oldSession, newSession);

        cscfgc.SessionManager.SessionInfo oldSessionInfo = new cscfgc.SessionManager.SessionInfo();
        omc.userSession = oldSessionInfo;
        cscfgc.SessionManager.SessionInfo newSessionInfo = omc.userSession;
        system.assertEquals(oldSessionInfo, newSessionInfo);

        omc.newAPISession = oldSession;
        newSession = omc.newAPISession;
        system.assertEquals(oldSession, newSession);

        omc.newUserSession = oldSessionInfo;
        newSessionInfo = omc.newUserSession;
        system.assertEquals(oldSessionInfo, newSessionInfo);

        String stringValue = '0';
        omc.definitionRef =  stringValue;
        system.assertEquals(stringValue, omc.definitionRef);

        omc.definitionId =  stringValue;
        system.assertEquals(stringValue, omc.definitionId);

        omc.offerId =  stringValue;
        system.assertEquals(stringValue, omc.offerId);

        omc.screenFlowName =  stringValue;
        system.assertEquals(stringValue, omc.screenFlowName);

        omc.screenIndex =  stringValue;
        system.assertEquals(stringValue, omc.screenIndex);

        omc.generator =  false;
        system.assertEquals(false, omc.generator);

        omc.editingProduct =  false;
        system.assertEquals(false, omc.editingProduct);

        omc.editConfigData =  stringValue;
        system.assertEquals(stringValue, omc.editConfigData);

        omc.productName =  stringValue;
        system.assertEquals(stringValue, omc.productName);

        system.assertEquals('Calls to O2 Mobiles', omc.minutesDestinationTypes);
        omc.minutesDestinationTypes =  stringValue;
        system.assertEquals(stringValue, omc.minutesDestinationTypes);

        system.assertEquals('0', omc.minutesNumber );
        omc.minutesNumber  =  '60';
        system.assertEquals('60', omc.minutesNumber );

    }

    // miscellaneous grouping which doesn't require any configurator knowledge
    static void testSimple(O2OnlineMainController omc) {
        O2OnlineMainController omc1 = omc.getController();
        system.assertEquals(omc, omc1);

        omc.doNothing();

        PageReference pg1 = omc.getFirstPage();



    }

    static void testComplexProperties(O2OnlineMainController omc) {
        String stringValue = 'Test';

        // TODO: this crashes
        omc.productLabel = stringValue;
        system.assertEquals('Landline', omc.productLabel);

        // TODO: this crashes
        omc.provideType = stringValue;
        system.assertEquals(stringValue, omc.provideType);

        omc.transferNumber = stringValue;
        system.assertEquals(stringValue, omc.transferNumber);

        omc.transferPostcode = stringValue;
        system.assertEquals(stringValue, omc.transferPostcode);

        omc.existingCustomer = stringValue;
        system.assertEquals(stringValue, omc.existingCustomer);

        omc.existingNumber = stringValue;
        system.assertEquals(stringValue, omc.existingNumber);

        omc.inBuildingName = stringValue;
        system.assertEquals(stringValue, omc.inBuildingName);

        omc.inBuildingNumber = stringValue;
        system.assertEquals(stringValue, omc.inBuildingNumber);

        omc.inPostcode = stringValue;
        system.assertEquals(stringValue, omc.inPostcode);

        omc.inStreet = stringValue;
        system.assertEquals(stringValue, omc.inStreet);

        omc.inCity = stringValue;
        system.assertEquals(stringValue, omc.inCity);

        omc.inCounty = stringValue;
        system.assertEquals(stringValue, omc.inCounty);

        omc.inCountry = stringValue;
        system.assertEquals(stringValue, omc.inCountry);

        // It is not broadband, so we receive null back
        omc.rtBuildingName = stringValue;
        system.assertEquals(null, omc.rtBuildingName);

        omc.rtBuildingNumber = stringValue;
        system.assertEquals(null, omc.rtBuildingNumber);

        omc.rtCity = stringValue;
        system.assertEquals(null, omc.rtCity);

        omc.rtCountry = stringValue;
        system.assertEquals(null, omc.rtCountry);

        omc.rtCounty = stringValue;
        system.assertEquals(null, omc.rtCounty);

        omc.rtFlatNumber = stringValue;
        system.assertEquals(stringValue, omc.rtFlatNumber);

        omc.rtPostcode = stringValue;
        system.assertEquals(null, omc.rtPostcode);

        omc.rtStreet = stringValue;
        system.assertEquals(null, omc.rtStreet);

        omc.cfgTariffCode = stringValue;
        system.assertEquals(stringValue, omc.cfgTariffCode);

    }


    static void setupData() {
        loc = new Location__c(PAF_Building_Name__c='Cilcain', PAF_Building_Number__c='1', PAF_Postcode__c='SA14RT', Location_UID__c='This is test 10000000000067');
        insert loc;

        locs = new List<Location__c>();
        locs.add(loc);

        offer = TestDataForO2OrderHelper.createOffer();

        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        TestDataForO2OrderHelper.createRecordTypeForAccount();
        TestDataForO2OrderHelper.createRecordTypeForOpportunity();
        acc = TestDataForO2OrderHelper.createAccount();
        con = TestDataForO2OrderHelper.createContact();
        oppr = TestDataForO2OrderHelper.createOpportunity();

        //prodDef = TestDataForO2OrderHelper.createProductDefinition();
        prodDef = initLandline();
        system.debug('prodDef: '+prodDef);
        List<cscfgc__Attribute_Definition__c> prodDefAttr = TestDataForO2OrderHelper.createAttributeDefinition(prodDef.Id);
        system.debug('prodDefAttr: '+prodDefAttr);

        bundle = TestDataForO2OrderHelper.createbundle(oppr.Id);
        system.debug('bundle: '+bundle);

        prodConfig = TestDataForO2OrderHelper.createProductConfiguration(prodDefAttr, bundle.Id, prodDef.Id, offer.Id);
        system.debug('prodConfig1: '+prodConfig);

        // Create a primary billing contact
        OpportunityContactRole ocrBill = new OpportunityContactRole();
        ocrBill.OpportunityId = oppr.Id;
        ocrBill.ContactId = con.Id;
        ocrBill.IsPrimary = true;
        ocrBill.Role = 'Billing';
        ocrList.add(ocrBill);

        // Also create a Centre of Power contact
        OpportunityContactRole ocrCop = new OpportunityContactRole();
        ocrCop.OpportunityId = oppr.Id;
        ocrCop.ContactId = con.Id;
        ocrCop.IsPrimary = false;
        ocrCop.Role = 'Centre of Power';
        ocrList.add(ocrCop);

        insert ocrList;

        AddressCheckController ac = new AddressCheckController();
        address = new AddressCheckController.Address();
        address.selected = true;
        address.organisation = 'test';
        address.buildingNumber = 'test';
        address.subBuildingName = 'test';
        address.buildingName = 'test';
        address.street = 'test';
        address.dependentStreet = 'test';
        address.dependentLocality = 'test';
        address.locality = 'test';
        address.county = 'test';
        address.postTown = 'test';
        address.postcode = 'test';

        flatNumber = '15';
        buildingName = 'Ty Bont';
        buildingNo = '16';
        postalCode = 'L42QH';
        streetName = 'OAKFIELD';
        cityName = 'LIVERPOOL';
        countyName = 'MERSEYSIDE';
        selectedCountry = 'UK';
    }

    static void testComplex() {
        PageReference pg = Page.O2BusinessShopLandlineLanding;
        Test.setCurrentPage(pg);

        // set the parameters
        pg.getParameters().put('offer', offer.Id);

        O2OnlineMainController omc = getO2OnlineMainController();

        // start a session, indirectly calls selectProduct
        omc.initSession();

        String s1 = omc.getScreenFlowTemplate();

        String s2 = omc.getPreGeneratedContent();

        try {
            // TODO: Fix this
            system.debug('prodConfig.Id: '+prodConfig.Id);
            system.debug('omc.screenFlowName: '+omc.screenFlowName);
            system.debug('offer.Id: '+offer.Id);
            cscfgc__Product_Configuration__c cfg = omc.getConfiguration();
            pg = omc.editBasketProduct(cfg.Id, omc.screenFlowName, offer.Id);
        } catch(exception e) {
        }

        Integer i = omc.getLastIndex();

        String s3 = omc.getHiddenAttributesAsHtml();

        List<SelectOption> opts = omc.getsavedLocationList();

        omc.selectSavedInstallAddress();

        omc.selectSavedRouterAddress();

        pg = omc.numSavedLocations();

        Integer i1 = omc.getNumSavedLocations();

        omc.selectInstallAddress();

        opts = omc.getInstallAddrCountries();

        pg = omc.searchInstallationAddresses();

        omc.selectRouterAddress();

        opts = omc.getRouterAddrCountries();

        pg = omc.searchRouterAddresses();

        omc.resetAddresses('installation');
        omc.resetAddresses('broadband');

        List<AddressCheckController.Address> addr = omc.findAddresses(loc.PAF_Building_Name__c, loc.PAF_Building_Number__c, loc.PAF_Postcode__c);

        // TODO: all address types, only doing 'Billing' at moment
        Location__c newLoc = omc.createSavedSessionLocation(address, 'Billing', omc.userSession.userSession.Id);
        // TODO: check the address has the correct fields (i.e. 'test' in each field)

        String s4 = omc.getCountryVal('installation');
        String s5 = omc.getCountryVal('not installation');

        omc.selectAddress(loc, 'installation');
        omc.selectAddress(loc, 'not installation');
        omc.selectAddress(loc, 'router');

        omc.saveNonPAFLocations('Billing', flatNumber, buildingName, buildingNo, postalCode, streetName, cityName, countyName, selectedCountry);
        omc.saveNonPAFLocations('Registered', flatNumber, buildingName, buildingNo, postalCode, streetName, cityName, countyName, selectedCountry);
        omc.saveNonPAFLocations('Director/Proprietor', flatNumber, buildingName, buildingNo, postalCode, streetName, cityName, countyName, selectedCountry);
        omc.saveNonPAFLocations('Installation', flatNumber, buildingName, buildingNo, postalCode, streetName, cityName, countyName, selectedCountry);
        omc.saveNonPAFLocations('Router', flatNumber, buildingName, buildingNo, postalCode, streetName, cityName, countyName, selectedCountry);

        pg = omc.addSessionToBasket();

        String s6 = omc.getLineCheckEnabled();

        pg = omc.performChecks();

        pg = omc.emptyBasket();

        pg = omc.proceedToCheckout();

        pg = omc.continueShopping();

        testComplexProperties(omc);

    }

    static testmethod void testO2OnlineMainController() {
        setupData();

        Test.startTest();
        O2OnlineMainController omc = getO2OnlineMainController();

        testComplex();

        testProperties(omc);

        testSimple(omc);

        Test.stopTest();
    }

    static testmethod void testO2OnlineContactUsExtension() {
        PageReference pg = Page.O2OnlineContactUsStandard;
        Test.setCurrentPage(pg);

        // standard constructor
        O2OnlineContactUsExtension cusEx1 = new O2OnlineContactUsExtension();

        // other constructor
        Lead newLead = new Lead(LastName='Bluewater', Company='Apex Hinges', Status='New', LeadSource='eShop');

        ApexPages.StandardController leadController = new ApexPages.StandardController(newLead);
        O2OnlineContactUsExtension cusEx2 = new O2OnlineContactUsExtension(leadController);

        PageReference pr = cusEx2.saveRecord();
    }
}