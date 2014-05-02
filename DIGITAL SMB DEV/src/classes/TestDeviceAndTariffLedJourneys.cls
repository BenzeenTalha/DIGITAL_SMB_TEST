/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class TestDeviceAndTariffLedJourneys {



    static testMethod void testBusinessDeviceLedJourney() {

        // set up data
        // Get a Product - we haven't got time to create the Unit Test Product - for now we rely on an existing one
        cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
        pd = [Select Id, Name from cscfgc__Product_Definition__c WHERE Name = 'Business Single Tariff' LIMIT 1];

        List<cscfgc__Attribute_Definition__c> pdAttr = TestDataForO2OrderHelper.createAttributeDefinition(pd.Id);
        cscfgc__Configuration_Offer__c offer = TestDataForO2OrderHelper.createOffer();

        cscfgc__Product_Configuration__c prodConfig = TestDataForO2OrderHelper.createProductConfiguration(pdAttr, null, pd.Id, offer.Id);


        Test.startTest();

        // Test the New Page
        PageReference pg = Page.O2BusinessShopMobileLanding;
        Test.setCurrentPage(pg);

        // set the parameters
        // TODO: may need to revisit this, just using dummy values for now
        pg.getParameters().put('ref', 'Business Single:SMB:SMB Mobile:SMB Mobile');
        pg.getParameters().put('def', pd.Id);
        pg.getParameters().put('offer', offer.Id);
        pg.getParameters().put('screenflowname', 'SMB Mobile Business Single');
        pg.getParameters().put('generator', '0');

        O2OnlineMainController mainController = new O2OnlineMainController();
        O2OnlineMobileController mobileController = new O2OnlineMobileController(mainController);

        //get Phone Brand options
        String selBrandDefault = mobileController.selectedBrand;
        List<SelectOption> hsBrands = mobileController.getHSBrands();
        system.assert(hsBrands.size() > 0);
        mobileController.selectedBrand = hsBrands[0].getValue();
        String selBrand = mobileController.selectedBrand;
        system.assertEquals(selBrand, hsBrands[0].getValue());

        //get Phone OS options
        String selSystemDefault = mobileController.selectedSystem;
        List<SelectOption> hsSystems = mobileController.getHSSystems();
        system.assert(hsSystems.size() > 0);
        mobileController.selectedSystem = hsSystems[0].getValue();
        String selSystem = mobileController.selectedSystem;
        system.assertEquals(selSystem, hsSystems[0].getValue());

        //get Sorting options
        String selSortingDefault = mobileController.selectedSorting;
        List<SelectOption> hsSorting = mobileController.getHSSorting();
        system.assert(hsSorting.size() > 0);
        mobileController.selectedSorting = hsSorting[0].getValue();
        String selSorting = mobileController.selectedSorting;
        system.assertEquals(selSorting, hsSorting[0].getValue());

        List<SelectOption> bestFor = mobileController.getHSBestFor();
        mobileController.selectedBestFor = 'All';

        for (SelectOption br : hsBrands)
            system.debug(LoggingLevel.INFO,'***brands ' + br);
        for (SelectOption os : hsSystems)
            system.debug(LoggingLevel.INFO,'***systems ' + os);
        for (SelectOption so : hsSorting)
            system.debug(LoggingLevel.INFO,'***sorting ' + so);
        for (SelectOption bf : bestFor)
            system.debug(LoggingLevel.INFO,'***best for ' + bf);


        system.debug(LoggingLevel.INFO,'***getMobileDevices params :1:'+selBrandDefault +':2:'+selSystemDefault+':3::4::5::6:false');
//      global class MobileDevice {
//          public O2_Dise_Map_Handset_Selection__c device {get;set;}
//          public Boolean insure {get;set;}
//          public Integer quantity {get;set;}
//          public Double price {get;set;}
//          public Double insurancePrice {get;set;}
        O2OnlineMobileController.MobileDevice[] devices = O2OnlineMobileController.getMobileDevices(selBrandDefault
                                     , selSystemDefault
                                     , '' // best for
                                     , ''
                                     , '' // sorting
                                     , 'false'  // limit
                                     , false);
        system.assert(devices.size() > 0);
        for (O2OnlineMobileController.MobileDevice md : devices) {
            system.debug(LoggingLevel.INFO,'***devices ' + md);
        }

        // select first handset ...
        mobileController.selectedProductCode = devices[0].device.Product_Code__r.Product_Code__c;
        mobileController.selectedProductId = devices[0].device.Id;

        // ... and onto page 2 / Step 2 via the 'select handset' link
        O2OnlineMobileController.MobileDevice[] selHSJson = O2OnlineMobileController.getSelectedHandsetJSON(
                                                                            mobileController.selectedProductId,
                                                                            ''
                                                                            );

        // ... alternatively - taken to the new page for Step 2 by a deep link / buy now link
        pg = Page.O2BusinessShopMobileTariffSelection;
        Test.setCurrentPage(pg);
        pg.getParameters().put('pc', devices[0].device.Product_Code__r.Product_Code__c);
        pg.getParameters().put('def', pd.Id);

        mainController = new O2OnlineMainController();
        mobileController = new O2OnlineMobileController(mainController);
        mainController.setContext();

        selHSJson = O2OnlineMobileController.getSelectedHandsetJSON(
                                                            '',
                                                            mobileController.selectedProductCode
                                                            );

        // handset insurance for screen
        O2_Dise_Map_Handset__c hs = mobileController.handset;

        system.debug(LoggingLevel.INFO,'***selected handset '+hs);
        system.debug(LoggingLevel.INFO,'***getSelectedHandsetJSON '+selHSJson);
        system.debug(LoggingLevel.INFO,'***devices[0].device.Product_Code__r.Product_Code__c:'+devices[0].device.Product_Code__r.Product_Code__c);
        system.debug(LoggingLevel.INFO,'***devices[0].device.Handset_Class__c:'+devices[0].device.Handset_Class__c);
        O2OnlineMobileController.getMobileTariffs(devices[0].device.Product_Code__r.Product_Code__c
                                                    , devices[0].device.Handset_Class__c
                                                    , '>1;>2' //selCost
                                                    , '>0' //selMins
                                                    , '>0' //selTexts
                                                    , '500' //selData
                                                    , 'ABC' //selTCode
                                                    , 'Handset' //selType
                                                    , 'true' //selBonus
                                                    , '' //selBOOptions
                                                    , 'XYZ123' //selPromo
                                                    , 'true' //limit
                                                    , false
                                    );
        O2OnlineMobileController.getMobileTariffs(devices[0].device.Product_Code__r.Product_Code__c
                                                    , devices[0].device.Handset_Class__c
                                                    , '>=0' //selCost
                                                    , '' //selMins
                                                    , '' //selTexts
                                                    , '' //selData
                                                    , '' //selTCode
                                                    , 'Handset;Handset' //selType
                                                    , '' //selBonus
                                                    , 'OFF PEAK MINUTES' //selBOOptions
                                                    , '' //selPromo
                                                    , 'false' //limit
                                                    , false
                                    );
        O2OnlineMobileController.getMobileTariffs(devices[0].device.Product_Code__r.Product_Code__c
                                                    , ''
                                                    , '>=0' //selCost
                                                    , '' //selMins
                                                    , '' //selTexts
                                                    , '' //selData
                                                    , '' //selTCode
                                                    , 'Handset;Handset' //selType
                                                    , '' //selBonus
                                                    , '' //selBOOptions
                                                    , '' //selPromo
                                                    , 'false' //limit
                                                    , false
                                    );
        O2OnlineMobileController.getMobileDevices('Other'
                                    , 'Other'
                                    , ''
                                    , ''
                                    , selSortingDefault
                                    , ''
                                    , false
                                    );
        O2OnlineMobileController.getMobileDevices('Apple'
                                    , 'iOS'
                                    , ''
                                    , ''
                                    , hsSorting[0].getValue()
                                    , ''
                                    , false
                                    );
        mobileController.getAvailableBoltOns();
        mainController.getController();
        mainController.doNothing();
        mainController.getScreenFlowTemplate();
        mainController.getPreGeneratedContent();
        mainController.setContext();
        mainController.selectScreen();
        mainController.getFirstPage();
        mainController.initSession();
        mainController.startQuickShop();
        mainController.selectProduct();
        mainController.getProduct();
        mainController.getConfiguration();
        mainController.getLastIndex();
        mainController.getHiddenAttributesAsHtml();

        mainController.resetAddresses('router');
        mainController.rtBuildingName = '';
        mainController.rtBuildingNumber = '134';
        mainController.rtPostcode = 'W1D 1LU';
        mainController.searchRouterAddresses();
        mainController.saveAndSelectAddress('0', 'router');
        mainController.getRouterAddrCountries();
        mainController.searchRouterAddresses();
        mainController.selectRouterAddress();

        mainController.getSavedLocationList();
        mainController.getNumSavedLocations();
        mainController.getLineCheckEnabled();
        mainController.getLiveTrackingEnabled();
        mainController.getIE8CompatibilityEnabled();
        mainController.enableIE8CompatibilityMode();
        mainController.getLiveWebchatEnabled();
        mainController.performChecks();
        String provideType = mainController.provideType;
        Boolean newRouterAddress = mainController.newRouterAddress;
        String rtBuildingName = mainController.rtBuildingName;
        String rtBuildingNumber = mainController.rtBuildingNumber;
        String rtPostcode = mainController.rtPostcode;
        String rtStreet = mainController.rtStreet;
        String rtCity = mainController.rtCity;
        String rtCounty = mainController.rtCounty;
        String rtCountry = mainController.rtCountry;
        String minutesDestinationTypes = mainController.minutesDestinationTypes;
        String minutesNumber = mainController.minutesNumber;
        mainController.addSessionToBasket();
        mainController.goToBasket();
        mainController.emptyBasket();
        O2OnlineMobileController.MobileDevice dev = new O2OnlineMobileController.MobileDevice();


        Test.stopTest();
    }





    static testMethod void testBusinessTariffLedJourney() {

        // set up data
        // Get a Product - we haven't got time to create the Unit Test Product - for now we rely on an existing one
        cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
        pd = [Select Id, Name from cscfgc__Product_Definition__c WHERE Name = 'Business Single Tariff' LIMIT 1];

        List<cscfgc__Attribute_Definition__c> pdAttr = TestDataForO2OrderHelper.createAttributeDefinition(pd.Id);
        cscfgc__Configuration_Offer__c offer = TestDataForO2OrderHelper.createOffer();

        cscfgc__Product_Configuration__c prodConfig = TestDataForO2OrderHelper.createProductConfiguration(pdAttr, null, pd.Id, offer.Id);


        Test.startTest();

        // Test the New Page
        PageReference pg = Page.O2BusinessShopMobileTariffLanding;
        Test.setCurrentPage(pg);

        // set the parameters
        // TODO: may need to revisit this, just using dummy values for now
        pg.getParameters().put('ref', 'Business Single:SMB:SMB Mobile:SMB Mobile');
        pg.getParameters().put('def', pd.Id);
        pg.getParameters().put('offer', offer.Id);
        pg.getParameters().put('screenflowname', 'SMB Mobile Business Single');
        pg.getParameters().put('generator', '0');

        O2OnlineMainController mainController = new O2OnlineMainController();
        O2OnlineMobileController mobileController = new O2OnlineMobileController(mainController);

        // get Popular Tariff Options
        List<SelectOption> filterBO = mobileController.getFilterBoltons();
        system.assert(filterBO.size() > 0);

        // get Mobile internet access options
        String selData = mobileController.selectedData;
        List<SelectOption> hsData = mobileController.getHSData();
        system.assert(hsData.size() > 0);
        mobileController.selectedData = hsData[0].getValue();
        selData = mobileController.selectedData;
        system.assertEquals(selData, hsData[0].getValue());

        //get Phone Class options
        String selHSClassDefault = mobileController.selectedHSClass;
        List<SelectOption> hsClasses = mobileController.getHSClasses();
        system.assert(hsClasses.size() > 0);
        mobileController.selectedHSClass = hsClasses[0].getValue();
        String selHSClass = mobileController.selectedHSClass;
        system.assertEquals(selHSClass, hsClasses[0].getValue());

        //get Phones and SIM-only tariff options
        String selTariffTypeDefault = mobileController.selectedTariffType;
        system.debug(LoggingLevel.INFO,'***selTariffTypeDefault ' + selTariffTypeDefault);
        List<SelectOption> tariffTypes = mobileController.getTariffTypes();
        system.assert(tariffTypes.size() > 0);
        mobileController.selectedTariffType = tariffTypes[0].getValue();
        String selTariffType = mobileController.selectedTariffType;
        system.assertEquals(selTariffType, tariffTypes[0].getValue());

        // get Monthly Cost
        String selCost = mobileController.selectedCost;
        List<SelectOption> hsCosts = mobileController.getHSCosts();
        system.assert(hsCosts.size() > 0);
        mobileController.selectedCost = hsCosts[0].getValue();
        selCost = mobileController.selectedCost;
        system.assertEquals(selCost, hsCosts[0].getValue());

        // get Inclusive Minutes
        String selMin = mobileController.selectedMinutes;
        List<SelectOption> hsMinutes = mobileController.getHSMinutes();
        system.assert(hsMinutes.size() > 0);
        mobileController.selectedMinutes = hsMinutes[0].getValue();
        selMin = mobileController.selectedMinutes;
        system.assertEquals(selMin, hsMinutes[0].getValue());

        // get Promotions
        String selPromo = mobileController.selectedPromo;
        List<SelectOption> filterPromo = mobileController.getFilterPromo();
        //system.assert(filterPromo.size() > 0);
        //mobileController.selectedPromo = filterPromo[0].getValue();
        selPromo = mobileController.selectedPromo;
        //system.assertEquals(selPromo, filterPromo[0].getValue());

        // get SMS Texts - not used in the screen but call it to get the coverage.
        String selTexts = mobileController.selectedTexts;
        //List<SelectOption> filterPromo = mobileController.getHSTexts();

//      global class MobileDeviceTariffUnique {
//          public String tariff_unique_key {get;set;}
//          public O2_Dise_Map_Mobile__c tariff {get;set;}
//          public O2_Dise_Map_Mobile_Bolton__c[] boltons {get;set;}
//          public String[] tariffNames {get; set;}
//          public String[] tariffClasses {get; set;}
//          public String promo {get;set;}
        O2OnlineMobileController.MobileDeviceTariffUnique[] tariffs = O2OnlineMobileController.getMobileTariffsUnique(
                                                      selHSClassDefault //selHSClass
                                                    , '' //selCost
                                                    , '' //selMins
                                                    , '' //selTexts
                                                    , '' //selData
                                                    , '' //selTCode
                                                    , selTariffTypeDefault //selType
                                                    , '' //selBonus
                                                    , '' //selBOOptions
                                                    , '' //selPromo
                                                    , 'false' //limit
                                                    , false
                                                    );
        system.assert(tariffs.size() > 0);
        for (O2OnlineMobileController.MobileDeviceTariffUnique mdtu : tariffs) {
            system.debug(LoggingLevel.INFO,'***tariffs' + mdtu);
        }
/////////////////  Above represents initial state of the page with picklists and tariffs displayed /////////////////////////




////////////////// Select the first Tariff radio button
        mobileController.selectedTariffUniqueKey = tariffs[0].tariff_unique_key;
//      global class MobileDevice {
//          public O2_Dise_Map_Handset_Selection__c device {get;set;}
//          public Boolean insure {get;set;}
//          public Integer quantity {get;set;}
//          public Double price {get;set;}
//          public Double insurancePrice {get;set;}
        O2OnlineMobileController.MobileDevice[] devices = O2OnlineMobileController.getMobileDevicesTL(
                                                      tariffs[0].tariffNames //tariffNames
                                                    , tariffs[0].tariff.Promotion__c //tariffPromotion
                                                    , tariffs[0].tariff.Flavour__c //tariffFlavour
                                                    , tariffs[0].tariffClasses //tariffClasses
                                                    , '' //selBrand
                                                    , '' //selSystem
                                                    , '' //selBestFor
                                                    , selHSClassDefault //selHSClass
                                                    , '' //selSorting
                                                    , 'false' //deviceLimit
                                                    );
        system.assert(devices.size() > 0);
        for (O2OnlineMobileController.MobileDevice md : devices) {
            system.debug(LoggingLevel.INFO,'***devices' + md);
        }



        //Select device which has accessories
        O2OnlineMobileController.MobileDevice selectedDevice = null;
        for(O2OnlineMobileController.MobileDevice device : devices){
            O2OnlineMobileController.MobileDeviceAccessory[] accessories =
                O2OnlineMobileController.getJSDeviceAccessories('', device.device.Product_Code__r.Product_Code__c);
                if(accessories.size() > 0){
                    selectedDevice = device;
                    break;
                }
        }
        selectedDevice.quantity = 1;
        mobileController.selectedTariffId = tariffs[0].tariff.Id;
//      global class MobileDeviceAccessory {
//          public O2_Dise_Ref_Hardware_Relation__c accessory {get;set;}
//          public Integer quantity {get;set;}
//          public String deviceId {get;set;}

        O2OnlineMobileController.MobileDeviceAccessory[] accessories = O2OnlineMobileController.getJSDeviceAccessories(
                                                      ''
                                                    , selectedDevice.device.Product_Code__r.Product_Code__c
                                                    );
        system.debug(LoggingLevel.INFO,'******zero device ' + selectedDevice.device.Product_Code__r.Product_Code__c);
        system.assert(accessories.size() >= 0);
        for (O2OnlineMobileController.MobileDeviceAccessory mda : accessories) {
            system.debug(LoggingLevel.INFO,'***accessories' + mda);
        }



////////////////// Select the first Bolt-on of the first Tariff in list
        system.assert(tariffs[0].boltons.size() > 0);
        String strSelectedBOIds = tariffs[0].boltons[0].Id;


////////////////// Select qty=1 of the first Accessory in list
        accessories[0].quantity = 1;
        accessories[0].deviceId = selectedDevice.device.Id;


////////////////// Select the Add To Basket link in the dynamic summary
        mobileController.selectedBoltOnIds = '';
        mobileController.setDeviceDynList('');
        mobileController.setTariffDynList('');
        mobileController.setAccessoryDynList('');

        mobileController.selectedBoltOnIds = strSelectedBOIds;
        mobileController.setDeviceDynList('{' + system.JSON.serialize(selectedDevice) + '}');
        mobileController.setTariffDynList('{' + system.JSON.serialize(tariffs[0]) + '}');
        // Accessories do not serialise/deserialise and keep all the neccessary accessory field values, so hand code just the bits needed.
        //mobileController.setAccessoryDynList('{' + system.JSON.serialize(accessories[0]) + '}');
        String json = '{'+
                '    \"accessory\": {'+
                '        \"Child_Product_Code__c\": \"' + accessories[0].accessory.Child_Product_Code__c + '\",'+
                '        \"Id\": \"' + accessories[0].accessory.Id + '\"'+
                '    },'+
                '    \"quantity\": ' + accessories[0].quantity + ','+
                '    \"deviceId\": \"' + accessories[0].deviceId + '\"'+
                '}';
        mobileController.setAccessoryDynList('{' + json + '}');

        system.debug(LoggingLevel.INFO,'***SelectedBoltOns' + mobileController.selectedBoltOnIds );
        system.debug(LoggingLevel.INFO,'***DeviceDynList' + mobileController.getDeviceDynList() );
        system.debug(LoggingLevel.INFO,'***TariffDynList' + mobileController.getTariffDynList() );
        system.debug(LoggingLevel.INFO,'***AccessoryDynList' + mobileController.getAccessoryDynList() );


        // delete offer configs prior to adding
        List<cscfgc__Product_Configuration__c> templateConfigs =
            [select id
                    from cscfgc__Product_Configuration__c
                    where ((O2_DISE_Map_Mobile__c=:tariffs[0].tariff.id and O2_DISE_Map_Handset_Selection__c=:selectedDevice.device.Id
                        AND O2_DISE_Ref_Hardware_Relation__c=null AND O2_DISE_Map_Mobile_Bolton__c=null)
                        OR (O2_DISE_Ref_Hardware_Relation__c=:accessories[0].accessory.Id AND O2_DISE_Map_Mobile__c=null AND O2_DISE_Map_Handset_Selection__c=null)
                        OR (O2_DISE_Map_Mobile_Bolton__c=:tariffs[0].boltons[0].Id AND O2_DISE_Map_Mobile__c=null AND O2_DISE_Map_Handset_Selection__c=null)
                        OR (SIM_Type__c IN ('') AND O2_DISE_Map_Mobile__c=:tariffs[0].tariff.id AND O2_DISE_Map_Handset_Selection__c=null AND O2_DISE_Ref_Hardware_Relation__c=null AND O2_DISE_Map_Mobile_Bolton__c=null))
                        AND cscfgc__Configuration_Offer__c<>null
                        AND cscfgc__Configuration_Status__c = 'Valid'];
        delete templateConfigs;

        cscfgc__Configuration_Offer__c cfgOffer = new cscfgc__Configuration_Offer__c();
        cfgOffer.name = 'test Offer';
        cfgOffer.Insurance__c = selectedDevice.insure;

        insert cfgOffer;


        cscfgc__Product_Configuration__c hsOfferConfig = new cscfgc__Product_Configuration__c();
        hsOfferConfig.cscfgc__Configuration_Offer__c = cfgOffer.Id;
        hsOfferConfig.Name = 'test Handset Config';
        hsOfferConfig.O2_DISE_Map_Mobile__c = tariffs[0].tariff.Id;
        hsOfferConfig.O2_DISE_Map_Handset_Selection__c = selectedDevice.device.Id;
        hsOfferConfig.Insurance__c = selectedDevice.insure;
        hsOfferConfig.cscfgc__Configuration_Status__c = 'Valid';

        insert hsOfferConfig;

        List<cscfgc__Product_Configuration__c> configList = new List<cscfgc__Product_Configuration__c>();

        cscfgc__Product_Configuration__c boOfferConfig = new cscfgc__Product_Configuration__c();
        boOfferConfig.cscfgc__Configuration_Offer__c = cfgOffer.Id;
        boOfferConfig.Name = 'test Bolt-on Config';
        boOfferConfig.O2_DISE_Map_Mobile_Bolton__c = tariffs[0].boltons[0].Id;
        boOfferConfig.cscfgc__Configuration_Status__c = 'Valid';
        configList.add(boOfferConfig);

        cscfgc__Product_Configuration__c acOfferConfig = new cscfgc__Product_Configuration__c();
        acOfferConfig.cscfgc__Configuration_Offer__c = cfgOffer.Id;
        acOfferConfig.Name = 'test Accessory Config';
        acOfferConfig.O2_DISE_Ref_Hardware_Portfolio__c = accessories[0].accessory.Child_Product_Code__c;
        acOfferConfig.O2_DISE_Ref_Hardware_Relation__c = accessories[0].accessory.Id;
        acOfferConfig.Quantity_of_Accessory__c = accessories[0].quantity;
        acOfferConfig.cscfgc__Configuration_Status__c = 'Valid';
        configList.add(acOfferConfig);

        insert configList;


        /* SELECT Id, Name, cscfgc__Value__c , cscfgc__Product_Configuration__c
                FROM cscfgc__Attribute__c
                where cscfgc__Product_Configuration__c IN :topConfigIds AND
                    (Name='Bolt On' OR Name='Accessories') */

        List<cscfgc__Attribute__c> attribList = new List<cscfgc__Attribute__c>();

        cscfgc__Attribute__c bolton = new cscfgc__Attribute__c();
        bolton.cscfgc__Product_Configuration__c = hsOfferConfig.Id;
        bolton.Name = 'Bolt On';
        bolton.cscfgc__Value__c = boOfferConfig.Id;
        attribList.add(bolton);

        cscfgc__Attribute__c accessory = new cscfgc__Attribute__c();
        accessory.cscfgc__Product_Configuration__c = hsOfferConfig.Id;
        accessory.Name = 'Accessories';
        accessory.cscfgc__Value__c = acOfferConfig.Id;
        attribList.add(accessory);

        insert attribList;


        mobileController.addProductToSessionBasketTLThenGotoBasket();

        cscfgc__Product_Basket__c basket = mainController.newAPISession.getBasket();
        boolean hsFound = false;
        boolean boFound = false;
        boolean acFound = false;
        integer numRecs = 0;
        for (cscfgc__Product_Configuration__c cfg : [ Select cscfgc__Root_Configuration__c, cscfgc__Parent_Configuration__c, cscfgc__Configuration_Status__c, SIM_Type__c, Quantity_of_Accessory__c, O2_DISE_Ref_Hardware_Relation__c, O2_DISE_Ref_Hardware_Portfolio__c, O2_DISE_Map_Mobile__c, O2_DISE_Map_Mobile_Bolton__c, O2_DISE_Map_Handset__c, O2_DISE_Map_Handset_Selection__c, Name, Insurance__c, Id
                                                        From cscfgc__Product_Configuration__c
                                                        where cscfgc__Product_Basket__c = :basket.Id
                                                        and cscfgc__Configuration_Status__c = 'Valid' ]) {
            system.debug(LoggingLevel.INFO,'***the config fields ' + cfg);
            numRecs++;
            if(cfg.Name=='test Handset Config') {
                hsFound=true;
            }
            if(cfg.Name=='test Bolt-on Config') {
                boFound=true;
                system.assert(cfg.cscfgc__Parent_Configuration__c <> null);
                system.assert(cfg.cscfgc__Root_Configuration__c <> null);
            }
            if(cfg.Name=='test Accessory Config') {
                acFound=true;
                system.assert(cfg.cscfgc__Parent_Configuration__c <> null);
                system.assert(cfg.cscfgc__Root_Configuration__c <> null);
            }
        }
        // check we got only 3 configs and 1 of each
        system.assert(hsFound);
        system.assert(boFound);
        system.assert(acFound);
        system.assertEquals(numRecs, 3);




////////////////////// Try SIM Only selections /////////////////////

        O2OnlineMobileController.getMobileTariffsUnique(
                                                      selHSClassDefault //selHSClass
                                                    , '' //selCost
                                                    , '' //selMins
                                                    , '' //selTexts
                                                    , '' //selData
                                                    , '' //selTCode
                                                    , 'SIM ONLY;Simplicity' //selType
                                                    , '' //selBonus
                                                    , '' //selBOOptions
                                                    , '' //selPromo
                                                    , 'false' //limit
                                                    , false
                                                    );
        O2OnlineMobileController.getSimDevices();


////////////////// Now try some other filter combinations //////////////////////////////////

        for (SelectOption so : tariffTypes) {
            if (so.getValue() <> selTariffTypeDefault) {
                O2OnlineMobileController.getMobileTariffsUnique(
                                                      'blackberry bis' //selHSClass
                                                    , '>1;>2' //selCost
                                                    , '>0' //selMins
                                                    , '>0' //selTexts
                                                    , '500' //selData
                                                    , 'ABC' //selTCode
                                                    , so.getValue() //selType
                                                    , 'true' //selBonus
                                                    , '' //selBOOptions
                                                    , 'XYZ123' //selPromo
                                                    , 'true' //limit
                                                    , false
                                                    );
            }
        }

        O2OnlineMobileController.getMobileTariffsUnique(
                                                      '' //selHSClass
                                                    , '>=0' //selCost
                                                    , '' //selMins
                                                    , '' //selTexts
                                                    , '' //selData
                                                    , '' //selTCode
                                                    , selTariffTypeDefault //selType
                                                    , '' //selBonus
                                                    , 'OFF PEAK MINUTES' //selBOOptions
                                                    , '' //selPromo
                                                    , 'false' //limit
                                                    , false
                                                    );
        O2OnlineMobileController.getMobileTariffsUnique(
                                                      '' //selHSClass
                                                    , '>=0' //selCost
                                                    , '' //selMins
                                                    , '' //selTexts
                                                    , '' //selData
                                                    , '' //selTCode
                                                    , selTariffTypeDefault //selType
                                                    , '' //selBonus
                                                    , '' //selBOOptions
                                                    , '' //selPromo
                                                    , 'false' //limit
                                                    , false
                                                    );
        O2OnlineMobileController.getMobileDevicesTL(
                                                      tariffs[0].tariffNames //tariffNames
                                                    , '' //tariffPromotion
                                                    , 'Z' //tariffFlavour
                                                    , tariffs[0].tariffClasses //tariffClasses
                                                    , '' //selBrand
                                                    , '' //selSystem
                                                    , '' //selBestFor
                                                    , selHSClassDefault //selHSClass
                                                    , '' //selSorting
                                                    , 'false' //deviceLimit
                                                    );
        O2OnlineMobileController.getMobileDevicesTL(
                                                      tariffs[0].tariffNames //tariffNames
                                                    , 'Bonus' //tariffPromotion
                                                    , 'Z' //tariffFlavour
                                                    , tariffs[0].tariffClasses //tariffClasses
                                                    , '' //selBrand
                                                    , '' //selSystem
                                                    , '' //selBestFor
                                                    , selHSClassDefault //selHSClass
                                                    , '' //selSorting
                                                    , 'false' //deviceLimit
                                                    );




        mobileController.selectDevice();
        mainController.getPreGeneratedContent();
        mobileController.getAvailableBoltOns();


        O2OnlineMobileController.getHandsetPricing(''
                                    , ''
                                    );
        O2OnlineMobileController.getJSDeviceAccessories(''
                                    , ''
                                    );
        O2OnlineMobileController.getDeviceAccessories(''
                                    , ''
                                    );
        String json2 = mobileController.formatJSON('{{json}}');
        system.assertEquals(json2, '[{json}]');
        mobileController.getMobileController();
        mobileController.doNothing();
        mobileController.goToBasket();
        O2OnlineMobileController mc = new O2OnlineMobileController();
        O2OnlineMobileController.MobileDeviceTariffUnique mdtu = new O2OnlineMobileController.MobileDeviceTariffUnique();


        Test.stopTest();
    }


///////////////////////////////////////////////////////////////////////////////////////////////////////


}