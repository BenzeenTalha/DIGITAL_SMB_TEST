/**
 * Class is extension controller for O2BusinessShopMobilePckBuilder.page
 */
global with sharing class O2OnlineMobilePckBuilderController {
    /****************** properties and inner classes ******************/
    public O2OnlineMainController maincontroller {get;set;}
    public SelectedDeviceWrapper selectedDevice {get; set;}
    public O2OnlineMobileController mobileController {get; set;} // temporary **
    public class O2OnlineMobilePckBuilderException extends Exception {}
    
    /**
     * wrapper class to hold information about currently selected device
     */
    public class SelectedDeviceWrapper {
        public SelectedDeviceWrapper (O2_DISE_Map_Handset_Selection__c device) {
            this.deviceClass = device.Handset_Class__c;
            this.deviceDescription = device.Handset_Description__c;
            this.deviceImageURL = device.handset_image_url__c;
            this.deviceModel = device.Handset_Model__c;
            this.productCode = device.Product_Code__r.Product_Code__c;
            this.productId = device.Product_Code__r.Id;
        }
        public string deviceClass {get; private set;}
        public string deviceDescription {get; private set;}
        public string deviceImageURL {get; private set;}
        public string deviceModel {get; private set;}
        public string productCode {get; private set;}
        public string productId {get; private set;}
    }
    
    global class DigitalProductWrapper {
        public Device_Digital_Product_Map__c product {get;set;}
        public Integer quantity {get;set;}
        public Id deviceId;
    }
    
    // JSON objects that are used to store data from the page
    public String selectedBoltOnIds {get;set;}
    private String selectedDeviceJSON;
    private String selectedTariffJSON;
    private String selectedAccessoriesJSON;
    private String selectedDigitalProductsJSON;
    
    /****************** constructors ******************/
    public O2OnlineMobilePckBuilderController() {}
    
    public O2OnlineMobilePckBuilderController(O2OnlineMainController controller) {
        this.maincontroller = controller;
        // O2_DISE_Map_Handset_Selection__c id
        string selectedDeviceId = ApexPages.currentPage().getParameters().get('hsId'); 
        
        O2_DISE_Map_Handset_Selection__c deviceSelection = [select Name
                                                            ,      Handset_Class__c
                                                            ,      Handset_Description__c
                                                            ,      handset_image_url__c
                                                            ,      Handset_Model__c
                                                            ,      Product_Code__r.Product_Code__c
                                                            ,       Product_Code__r.Id
                                                            from   O2_DISE_Map_Handset_Selection__c
                                                            where  Id = :selectedDeviceId];
       // 
       selectedDevice = new SelectedDeviceWrapper (deviceSelection);
       mobileController = new O2OnlineMobileController(maincontroller);    
       mobileController.selectedProductCode = deviceSelection.Product_Code__c;    
    }
    /****************** static methods ******************/
    
    /****************** instance methods ******************/
    public O2OnlineMobilePckBuilderController getMobilePckBuilderController() {return this;}
    
    public String getSelectedDeviceJSON() {
        return selectedDeviceJSON;
    }
    public void setSelectedDeviceJSON(String json) {
        selectedDeviceJSON = json;
        // System.debug(LoggingLevel.INFO,'### OUTPUT *** setting selectedDeviceJSON:--'+selectedDeviceJSON);
    }        
    //
    public String getSelectedTariffJSON() {
        return selectedTariffJSON;
    }
    public void setSelectedTariffJSON(String json) {
        selectedTariffJSON = json;
        // System.debug(LoggingLevel.INFO,'### OUTPUT *** setting selectedTariffJSON:--' + selectedTariffJSON);
    }
    //
    public String getSelectedAccessoriesJSON() {
        return selectedAccessoriesJSON;
    }
    public void setSelectedAccessoriesJSON(String json) {
        selectedAccessoriesJSON = json;
    }      
    //
    public String getSelectedDigitalProductsJSON() {
        return selectedDigitalProductsJSON;
    }
    public void setSelectedDigitalProductsJSON(String json) {
        selectedDigitalProductsJSON = json;
        // System.debug(LoggingLevel.INFO,'### OUTPUT *** setting selectedDigitalProductsJSON:--' + selectedDigitalProductsJSON);
    }     
    // temporay function **
    public void tmpSessionInit() {
        this.mainController.quickAddProduct = false;
        //this.mainController.getProduct();
        this.mainController.startSession();
        this.mainController.setContext();
    }    
    
    /**
     * RemoteAction returns pricing/tariffs for a device (hsProductCode)
     *
     * @param hsProductCode
     * @param hsClass
     * @param cost
     * @param mins
     * @param texts
     * @param sData
     * @param tariffCode
     * @param tType
     * @param bonus
     * @param boltOns
     * @param promo
     * @param slimit
     * @param only4G
     * @return list of tariffs associated with device
     */
    @RemoteAction
    global static O2OnlineMobileController.MobileDeviceTariffUnique[] getDeviceTariffs(String hsProductCode, String hsClass, String cost, String mins, String texts, String sData, String tariffCode, String tType, String bonus, String boltOns, String promo, String slimit, boolean only4G) {
        return O2OnlineMobileController.getMobileTariffs(hsProductCode, hsClass, cost, mins, texts, sData, tariffCode, tType, bonus, boltOns, promo, slimit, only4G);
    }
    
    /**
     * RemoteAction returns list of digital products associated with a device
     *
     * @param deviceProdCode
     * @return list of digital products associated with a device
     */
    @RemoteAction
    global static DigitalProductWrapper[] getDeviceDigitalProducts(String deviceProdCode) {
        list<DigitalProductWrapper> digitalProductsList = new list<DigitalProductWrapper>();
        
        for (Device_Digital_Product_Map__c digitalProduct : [select Id
                                                             ,      Digital_Product_Name__c
                                                             ,      Cloud_Service_Description__c
                                                             ,      Content__c
                                                             ,      List_Price__c
                                                             ,      Cloud_Service__c
                                                             ,      Device__c
                                                             from   Device_Digital_Product_Map__c
                                                             where  Device__r.Product_Code__c = :deviceProdCode]) {
			DigitalProductWrapper wrappedDigitalProduct = new DigitalProductWrapper();
			wrappedDigitalProduct.product = digitalProduct;
			wrappedDigitalProduct.deviceId = digitalProduct.Device__c;
			digitalProductsList.add(wrappedDigitalProduct);                          	
        }
        return digitalProductsList;
    }
      
    /**
     * RemoteAction returns data about device in JSON format
     *
     * @param  strProdId 
     * @param  deviceProdCode 
     * @return data about a device
     */
    @remoteAction
    global static O2_Dise_Map_Handset__c[] getDevicePricing(String sProdCodes, String sTariffs) {
        return O2OnlineMobileController.getHandsetPricing(sProdCodes, sTariffs);
    }
    
    /**
     * RemoteAction returns data about device in JSON format
     *
     * @param  strProdId 
     * @param  deviceProdCode 
     * @return data about a device
     */
    @remoteAction
    global static O2OnlineMobileController.MobileDevice[] getDeviceJSON(String strProdId, String strProdCode) {
        return O2OnlineMobileController.getSelectedHandsetJSON(strProdId, strProdCode);
    }    
    
    /**
     * RemoteAction returns accessories associated with a device
     *
     * @param prodId
     * @param prodCode     
     * @return list of accessories associated with device
     */
    @remoteAction
    global static O2OnlineMobileController.MobileDeviceAccessory[] getDeviceAccessories(String prodId, String prodCode) {
        return O2OnlineMobileController.getJSDeviceAccessories(prodId, prodCode);
    }
    
    
    /**********************************************************************/
    private Map<Id, O2OnlineMobileController.MobileDeviceJS> hsMap = new Map<Id, O2OnlineMobileController.MobileDeviceJS>(); // map handset selection id to ordered device
    private Map<String, Id> simMap = new Map<String, Id>(); // map sim product ref to handset_selection id
    private Set<String> hsProcessedSet=new Set<String>();
    private Set<String> boSet = new Set<String>();
    private Set<String> simSet = new Set<String>();
    private Set<String> hsSet = new Set<String>();   
    private Set<String> digProdSet = new Set<String>();   
    
    public List<DigitalProductWrapper> selectedDigitalProducts = new list<DigitalProductWrapper>();
    public List<O2OnlineMobileController.MobileDeviceJS> selDevicesList = new List<O2OnlineMobileController.MobileDeviceJS>();
    public List<O2OnlineMobileController.MobileDeviceTariffUniqueJS> selTariffsList = new List<O2OnlineMobileController.MobileDeviceTariffUniqueJS>();
    public List<O2OnlineMobileController.MobileAccessoryJS> selAccessoriesList = new List<O2OnlineMobileController.MobileAccessoryJS>(); 
    
	/*
	public static final String TARIFF_SOBJECT_PREFIX = O2_Dise_Map_Mobile__c.SObjectType.getDescribe().getKeyPrefix();
    public static final String DEVICE_SOBJECT_PREFIX = O2_Dise_Map_Handset_Selection__c.SObjectType.getDescribe().getKeyPrefix();
    public static final String BOLTON_SOBJECT_PREFIX = O2_Dise_Map_Mobile_Bolton__c.SObjectType.getDescribe().getKeyPrefix();
    public static final String ACCESSORY_SOBJECT_PREFIX = O2_Dise_Ref_Hardware_Relation__c.SObjectType.getDescribe().getKeyPrefix();
    */
    public O2OnlineMobileController.MobileDeviceJS matchHandsetConfig(cscfgc__product_configuration__c config) {
        //get the handset from our order
        O2OnlineMobileController.MobileDeviceJS handset = hsMap.get(config.O2_DISE_Map_Handset_Selection__c);
        //if processed before ignore
        if(hsProcessedSet.contains(handset.device.id)) return null;

        //check other config fields correct
        if(config.insurance__c!=handset.insure) return null;

        //add handset to processed list so we don't process it again
        hsProcessedSet.add(handset.device.id);
        return handset;
    }
    
    /*
        public String formatJSON(String json) {
        	retrun json;
        	
        system.debug(LoggingLevel.INFO, '***json raw' + json);
        System.debug(LoggingLevel.INFO,'***tariff sobject prefix:'+TARIFF_SOBJECT_PREFIX);
        System.debug(LoggingLevel.INFO,'***device sobject prefix:'+DEVICE_SOBJECT_PREFIX);
        System.debug(LoggingLevel.INFO,'***bolton sobject prefix:'+BOLTON_SOBJECT_PREFIX);
        System.debug(LoggingLevel.INFO,'***accessory sobject prefix:'+ACCESSORY_SOBJECT_PREFIX);

        json=json.trim();
        json=json.replaceAll('"' + TARIFF_SOBJECT_PREFIX + '([a-z]|[A-Z]|[0-9]){15}":','');  // replace sfid prefix on each record
        json=json.replaceAll('"' + DEVICE_SOBJECT_PREFIX + '([a-z]|[A-Z]|[0-9]){15}":','');  // replace sfid prefix on each record
        json=json.replaceAll('"' + BOLTON_SOBJECT_PREFIX + '([a-z]|[A-Z]|[0-9]){15}":','');  // replace sfid prefix on each record - bolton
        json=json.replaceAll('"' + ACCESSORY_SOBJECT_PREFIX + '([a-z]|[A-Z]|[0-9]){15}":','');  // replace sfid prefix on each record - accessory
        System.debug(LoggingLevel.INFO,'***json 1'+json);
        json=json.substring(json.indexOf('{')+1, json.lastIndexOf('}'));  // remove surrounding braces
        json='['+json+']';      // add surrounding squared brackets
        System.debug(LoggingLevel.INFO,'***json parsed'+json);
        return json;
        
    }
    */
     public List<O2OnlineMobileController.MobileAccessoryJS> matchAccessoryConfig(cscfgc__product_configuration__c config) {
        // check our accessory config
        List<O2OnlineMobileController.MobileAccessoryJS> matchedAccList = new List<O2OnlineMobileController.MobileAccessoryJS>();
        for(O2OnlineMobileController.MobileAccessoryJS acc : selAccessoriesList) {
//          if(acc.accessory.Child_Product_Code__c==config.O2_Dise_Ref_Hardware_Portfolio__c &&
            if(acc.accessory.id==config.O2_Dise_Ref_Hardware_Relation__c &&
                    acc.quantity==config.Quantity_of_Accessory__c) {
                matchedAccList.add(acc);
            }
        }
        return matchedAccList;
    }
    
    public list<DigitalProductWrapper> matchDigitalProduct(cscfgc__product_configuration__c config) {
        List<DigitalProductWrapper> matchedDigProducts = new List<DigitalProductWrapper>();
        for (DigitalProductWrapper digProduct : selectedDigitalProducts) {
        	if (digProduct.product.Cloud_Service__c == config.O2_Ref_Cloud_Services__c) {
        	    matchedDigProducts.add(digProduct);
        	}
        }
        return matchedDigProducts;
    }
    
    public O2OnlineMobileController.MobileDeviceJS matchSIMConfig(cscfgc__product_configuration__c config) {
        Id hsId=simMap.get(config.SIM_Type__c);

        //get the handset from our order
        O2OnlineMobileController.MobileDeviceJS sim=hsMap.get(hsId);

        //if processed before ignore
        if(hsProcessedSet.contains(sim.device.id)) return null;

        //check other config fields correct
        if(config.insurance__c!=sim.insure) return null;

        //add handset to processed list so we don't process it again
        hsProcessedSet.add(sim.device.id);
        return sim;
    }
    
    public void parseJSONInputStrings() {
        if (selectedDeviceJSON!=null && selectedDeviceJSON!='') {
            selDevicesList=(List<O2OnlineMobileController.MobileDeviceJS>) System.JSON.deserialize(selectedDeviceJSON, List<O2OnlineMobileController.MobileDeviceJS>.class);
            System.debug(LoggingLevel.INFO,'***selDevicesList:'+ selDevicesList);
        }
        if (selectedTariffJSON!=null && selectedTariffJSON!='') {
            selTariffsList=(List<O2OnlineMobileController.MobileDeviceTariffUniqueJS>) System.JSON.deserialize(selectedTariffJSON, List<O2OnlineMobileController.MobileDeviceTariffUniqueJS>.class);
            System.debug(LoggingLevel.INFO,'***selTariffsList:'+ selTariffsList);
        }
        if (selectedAccessoriesJSON!=null && selectedAccessoriesJSON!='') {
            selAccessoriesList=(List<O2OnlineMobileController.MobileAccessoryJS>) System.JSON.deserialize(selectedAccessoriesJSON, List<O2OnlineMobileController.MobileAccessoryJS>.class);
            System.debug(LoggingLevel.INFO,'***selAccessoriesList:'+ selAccessoriesList);
        }
        if (selectedDigitalProductsJSON != null && selectedDigitalProductsJSON != '') {
            selectedDigitalProducts = (List<DigitalProductWrapper>) System.JSON.deserialize(selectedDigitalProductsJSON, List<DigitalProductWrapper>.class);
            System.debug(LoggingLevel.INFO,'***selAccessoriesList:'+ selectedDigitalProducts);
        }        
    }

    public PageReference goToBasket() {
        return maincontroller.goToBasket();
    }    
    
    /**
     * method will add products to the basket
     *
     * method originated from O2OnlineMobileController.addProductToSessionBasketTL
     * added digital products into the picture
     */    
    public PageReference addPackageToBasket() {
		PageReference pgSAVE_ERROR = Page.O2OnlineExceptionPage;
        if (maincontroller.apiSession != null) {
            maincontroller.newApiSession = maincontroller.apiSession;
        } else {
            maincontroller.initSession();
        }
        if (maincontroller.newAPISession != null && maincontroller.newUserSession == null) {
            maincontroller.newUserSession = maincontroller.newApiSession.getUserSession();
        } else if (maincontroller.newApiSession != null && maincontroller.newUserSession != null) {
            maincontroller.newUserSession = maincontroller.newApiSession.loadUserSession(maincontroller.newApiSession.getUserSession().usersession.Id);
        }
        if (maincontroller.newUserSession == null) {
            maincontroller.newUserSession = cscfgc.SessionManager.getSessionInfo();
        }
        if (maincontroller.userSession == null) {
            maincontroller.userSession = maincontroller.newUserSession;
        }

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: new session variables: userSession--'+maincontroller.newUserSession);
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: new session variables: apiSession--'+maincontroller.newApiSession);
        //maincontroller.productName = maincontroller.getProduct();
        //System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket2: product name: --'+maincontroller.productName);
        if (maincontroller.apiSession == null) maincontroller.newApiSession = maincontroller.apiSession = cscfgc.API_1.getApiSession();

        System.debug(LoggingLevel.INFO,'***newApiSession:'+maincontroller.newApiSession);
        System.debug(LoggingLevel.INFO,'***apiSession:'+maincontroller.apiSession);

        // Parse our dynamic summary JSON into objects
        parseJSONInputStrings();

        // Create maps and sets of object IDs for which we want Offers
        hsMap.clear();
        simMap.clear();
        boSet.clear();
        hsSet.clear();
        simSet.clear();
        digProdSet.clear();
        Integer deviceTotal = 0;  // device total should match eventual number of parent product_configurations
        for(O2OnlineMobileController.MobileDeviceJS dev : selDevicesList) {
            if (dev.quantity < 1) { // ignore zero quantity hs - Configurator rejects them anyway
                continue;
            }
            hsMap.put(dev.device.id, dev);
            if(dev.device.Handset_Class__c=='SIM') {
                simSet.add(dev.device.Product_Code__r.Product_Code__c);
                simMap.put(dev.device.Product_Code__r.Product_Code__c, dev.device.id);
            } else {
                hsSet.add(dev.device.id);
            }
            deviceTotal += dev.quantity;
        }
        Set<Id> acSet=new Set<Id>();
        for(O2OnlineMobileController.MobileAccessoryJS acc : selAccessoriesList) {
//          acSet.add(acc.accessory.child_product_code__c);
            acSet.add(acc.accessory.id);
        }
        for(DigitalProductWrapper wrappedDigitalProduct : selectedDigitalProducts) {
            digProdSet.add(wrappedDigitalProduct.product.Cloud_Service__c);
        }
        if (selectedBoltOnIds != null && selectedBoltOnIds != '') {
            if (selectedBoltOnIds.contains(',')) {
                for (String s: selectedBoltOnIds.split(',')) {boSet.add(s);}
            } else {
                boSet.add(selectedBoltOnIds);
            }
        }
        System.debug(LoggingLevel.INFO,'***hsMap: ' + hsMap);
        System.debug(LoggingLevel.INFO,'***hsSet: ' + hsSet);
        System.debug(LoggingLevel.INFO,'***simSet: ' + simSet);
        System.debug(LoggingLevel.INFO,'***boSet: ' + boSet);
        System.debug(LoggingLevel.INFO,'***acSet: ' + acSet);
        System.debug(LoggingLevel.INFO,'***digProdSet: ' + digProdSet);
        // Get all the Configurations we need to clone. Note: will contain extras as we need to filter quantities
        List<cscfgc__Product_Configuration__c> templateConfigs =
                [select  Id
,         Name
,         O2_DISE_Map_Mobile__c
,         O2_DISE_Map_Handset_Selection__c
,         Insurance__c
,        O2_DISE_Ref_Hardware_Relation__c
,         O2_DISE_Ref_Hardware_Portfolio__c
,         O2_DISE_Map_Mobile_Bolton__c
,         Quantity_of_Accessory__c
,        SIM_Type__c
,       O2_Ref_Cloud_Services__c
from     cscfgc__Product_Configuration__c
where     ( (O2_DISE_Map_Mobile__c = :selTariffsList[0].tariff.id 
           and O2_DISE_Map_Handset_Selection__c IN :hsSet
           and O2_DISE_Ref_Hardware_Relation__c = null
           and O2_DISE_Map_Mobile_Bolton__c = null)
        or (O2_DISE_Ref_Hardware_Relation__c IN :acSet 
           and O2_DISE_Map_Mobile__c = null 
           and O2_DISE_Map_Handset_Selection__c = null)
        or (O2_DISE_Map_Mobile_Bolton__c IN :boSet 
           and O2_DISE_Map_Mobile__c = null 
           and O2_DISE_Map_Handset_Selection__c = null)
        or (SIM_Type__c IN :simSet 
            and    O2_DISE_Map_Mobile__c = :selTariffsList[0].tariff.id 
            and    O2_DISE_Map_Handset_Selection__c = null 
            and O2_DISE_Ref_Hardware_Relation__c = null 
            and    O2_DISE_Map_Mobile_Bolton__c = null)
        or (O2_Ref_Cloud_Services__c in :digProdSet)    
        )
and        cscfgc__Configuration_Offer__c <> null
and        cscfgc__Configuration_Status__c = 'Valid'];

        // Build ALL config copy requests
        List<cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest> copyRequestList = new List<cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest>();

        // initialise hs set - to track each is processed only once
        hsProcessedSet.clear();
        Integer qty;
        for (cscfgc__Product_Configuration__c config : templateConfigs) {
            /*
            Integer qty=1;

            System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: config:--'+config);
            // check if handset
            if(config.O2_DISE_Map_Handset_Selection__c!=null) {
                O2OnlineMobileController.MobileDeviceJS handset=matchHandsetConfig(config);
                if(handset!=null)
                    qty=handset.quantity;
                else
                    continue;
            } else {
                // check if accessory
                if(config.O2_Dise_Ref_Hardware_Relation__c!=null) {
                    List<O2OnlineMobileController.MobileAccessoryJS> accList = matchAccessoryConfig(config);
                    if(accList.isEmpty()) continue; // accessory we don't want, e.g. wrong quantity
                    qty = accList.size();
                } else {
                    // check if bolt-on
                    if(config.O2_DISE_Map_Mobile_Bolton__c!=null) {
                        qty=deviceTotal; // Bolt-on will be added to every parent config
                    } else {
                        // check if SIM
                        if(config.SIM_Type__c!=null) {
                            O2OnlineMobileController.MobileDeviceJS sim=matchSIMConfig(config);
                            if(sim!=null)
                                qty=sim.quantity;
                            else
                                continue;
                        } else {
                            continue; // A Config we don't want!
                        }
                    }
                }
            }
            // Add to copy list
            system.debug(LoggingLevel.INFO,'****requesting:'+qty+' of '+config.Name);
            copyRequestList.add(new cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest(config.id, qty));
        */
            
            System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: config:--'+config);
            // configuration to clone is device
            if(config.O2_DISE_Map_Handset_Selection__c != null) {
                O2OnlineMobileController.MobileDeviceJS handset = matchHandsetConfig(config);
                if(handset == null)
                    continue;
                qty = handset.quantity;
            }
            // configuration to clone is accessory
            if(config.O2_Dise_Ref_Hardware_Relation__c!=null) {
                List<O2OnlineMobileController.MobileAccessoryJS> accList = matchAccessoryConfig(config);
                if (accList.isEmpty()) 
                    continue; 
                qty = accList.size();
            }
            // configuration to clone is bolton
            if (config.O2_DISE_Map_Mobile_Bolton__c != null) {
                qty = deviceTotal; // Bolt-on will be added to every parent config            
            }
            // configuration to clone is sim only
            if (config.SIM_Type__c != null) {
				O2OnlineMobileController.MobileDeviceJS sim = matchSIMConfig(config);
                if (sim == null)
                    continue;
               	qty=sim.quantity;
             }
            // configuration to clone is digital product
            if (config.O2_Ref_Cloud_Services__c != null) {
                list<DigitalProductWrapper> digitalProductList = matchDigitalProduct(config);
                if (digitalProductList.isEmpty()) 
                    continue; 
                qty = digitalProductList.size();
            }
            // populate configuration copy request list
           system.debug(LoggingLevel.INFO, '****requesting:' + qty + ' of ' + config.Name);
           copyRequestList.add(new cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest(config.id, qty));     
        }
        system.debug(LoggingLevel.INFO,'****copyRequestList:' + copyRequestList);

        if(copyRequestList.isEmpty()) {
            system.debug(LoggingLevel.INFO,'*** Empty copyRequestList check soql query (on cscfgc__Product_Configuration__c) for requested items in hsSet, simSet, boSet and acSet (listed above)! ***');
            throw new O2OnlineMobilePckBuilderException('None of your products have been found for your tariff: ' + selTariffsList[0].tariff.Name);
        }


        //////// Copy to the actual configurations to use ////////
        List<Id> ids = cscfgc.ProductConfigurationHelper.copyConfigurations(copyRequestList, null, maincontroller.newAPISession.getBasket().Id);


        // Get the new configs we just made
        List<cscfgc__Product_Configuration__c> configs = [
            select id, name, cscfgc__configuration_status__c,
                cscfgc__Root_Configuration__c, cscfgc__Parent_Configuration__c,
                O2_DISE_Map_Handset_Selection__c,
                O2_DISE_Ref_Hardware_Relation__c,
                O2_DISE_Ref_Hardware_Portfolio__c,
                O2_DISE_Map_Mobile_Bolton__c,
                Quantity_of_Accessory__c,
                SIM_Type__c,
                cscfgc__Configuration_Offer__c,
                O2_Ref_Cloud_Services__c
            from cscfgc__Product_Configuration__c where id in :ids]; // and cscfgc__parent_configuration__c = null];


        system.debug(LoggingLevel.INFO,'****new Ids:'+ids);
        system.debug(LoggingLevel.INFO,'****new configs:'+configs);

        //sort configs into types
        List<cscfgc__Product_Configuration__c> topConfigList = new List<cscfgc__Product_Configuration__c>();
        List<cscfgc__Product_Configuration__c> acConfigList = new List<cscfgc__Product_Configuration__c>();
        List<cscfgc__Product_Configuration__c> dpConfigList = new List<cscfgc__Product_Configuration__c>();
        
        Map<Id, List<cscfgc__Product_Configuration__c>> boConfigMap = new Map<Id, List<cscfgc__Product_Configuration__c>>();
        Set<String> topConfigIds = new Set<String>();


        for(cscfgc__Product_Configuration__c config : configs) {

            system.debug(LoggingLevel.INFO,'****process config:'+config);

            //remove parent Offer from all our new product configurations
            config.cscfgc__Configuration_Offer__c=null;

            if(config.O2_DISE_Map_Handset_Selection__c!=null || config.SIM_Type__c!=null) {
                topConfigList.add(config);
                topConfigIds.add(config.id);
            }
            if(config.O2_DISE_Ref_Hardware_Relation__c!=null) {
                acConfigList.add(config);
            }
            if(config.O2_DISE_Map_Mobile_Bolton__c!=null) {
                List<cscfgc__Product_Configuration__c> boConfigList=new List<cscfgc__Product_Configuration__c>();
                if(boConfigMap.containsKey(config.O2_DISE_Map_Mobile_Bolton__c)) {
                    boConfigList.addAll(boConfigMap.get(config.O2_DISE_Map_Mobile_Bolton__c));
                }
                boConfigList.add(config);
                boConfigMap.put(config.O2_DISE_Map_Mobile_Bolton__c, boConfigList);
            }
            if (config.O2_Ref_Cloud_Services__c != null) {
            	dpConfigList.add(config);
            }
        }

        update configs;


        // Map bolt on and accessories attributes for top-level configs
        List<cscfgc__Attribute__c> attrList = [SELECT Id, Name, cscfgc__Value__c , cscfgc__Product_Configuration__c
                FROM cscfgc__Attribute__c
                WHERE cscfgc__Product_Configuration__c IN :topConfigIds
                AND (Name='Bolt On' OR Name='Accessories')];

        Map<Id, cscfgc__Attribute__c> acConfigAttrMap = new Map<Id, cscfgc__Attribute__c>();
        Map<Id, cscfgc__Attribute__c> boConfigAttrMap = new Map<Id, cscfgc__Attribute__c>();
        for(cscfgc__Attribute__c attr : attrList) {
            if(attr.Name=='Bolt On') {  // bolt-ons go on every parent (related to tariff)
                boConfigAttrMap.put(attr.cscfgc__Product_Configuration__c, attr);
            }
            if(attr.Name=='Accessories') {  // accessories go on every parent (related to handset)
                acConfigAttrMap.put(attr.cscfgc__Product_Configuration__c, attr);
            }
        }

        // Process each parent(top-level config) setting fields as required
        List<cscfgc__Attribute__c> attrUpdateList=new List<cscfgc__Attribute__c>();
        List<cscfgc__Product_Configuration__c> relConfigUpdateList=new List<cscfgc__Product_Configuration__c>();
        List<O2OnlineMobileController.MobileAccessoryJS> accProcessList = new List<O2OnlineMobileController.MobileAccessoryJS>();
        accProcessList.addAll(selAccessoriesList);
        set<Id> processedAccConfigSet = new set<Id>();
 system.debug('*** dpConf' + dpConfigList);
        for(cscfgc__Product_Configuration__c topConfig : topConfigList) {

            // Bolt-ons

            // loop thru bolton configs for this device relating each to this parent (topConfig). e.g. 'interntional favourites' or 'data bolt on'
            cscfgc__Attribute__c boAttr = boConfigAttrMap.get(topConfig.Id);
            boAttr.cscfgc__Value__c = ''; //initialise value
            for(Id boId : boConfigMap.keySet()) {
                // get next child config
                cscfgc__Product_Configuration__c boConf = boConfigMap.get(boId).get(0);

                //set child on parent
                //if (boConfigMap.get(boId).size()==1) boAttr.cscfgc__Value__c+=boConf.Id;
                //else
                boAttr.cscfgc__Value__c += boConf.Id + ',';

                //set parent on child
                boConf.cscfgc__Parent_Configuration__c = topConfig.Id;
                boConf.cscfgc__Root_Configuration__c = topConfig.Id;
                relConfigUpdateList.add(boConf);

                // remove this child config from this list so we don't process it again
                boConfigMap.get(boId).remove(0);
            }
            //if attribute set add to update list and remove last comma
            if(boAttr!=null && boAttr.cscfgc__Value__c!=null && boAttr.cscfgc__Value__c!='')  {
                boAttr.cscfgc__Value__c = boAttr.cscfgc__Value__c.substring(0, boAttr.cscfgc__Value__c.length()-1);
                attrUpdateList.add(boAttr);
            }

            // Accessories

            //get all accessories we have for this device that HAVE NOT been processed
            List<O2OnlineMobileController.MobileAccessoryJS> accList = new List<O2OnlineMobileController.MobileAccessoryJS>();
            for(O2OnlineMobileController.MobileAccessoryJS acc : accProcessList) {
                if(acc.deviceId==topConfig.O2_DISE_Map_Handset_Selection__c) {
                    accList.add(acc);
                }
            }

            for(O2OnlineMobileController.MobileAccessoryJS acc : accList) {  // remove so we don't add them again
                for(Integer i=accProcessList.size()-1; i>=0; i--) {
                    if(acc.accessory.id==accProcessList.get(i).accessory.id &&
                            acc.deviceid==accProcessList.get(i).deviceid &&
                            acc.quantity==accProcessList.get(i).quantity)
                        accProcessList.remove(i);
                }
            }

            cscfgc__Attribute__c acAttr = acConfigAttrMap.get(topConfig.Id);
            acAttr.cscfgc__Value__c = ''; //initialise value
            for(O2OnlineMobileController.MobileAccessoryJS acc : accList) {
                for(cscfgc__Product_Configuration__c accConf : acConfigList) {

                    // ignore if we have used this before
                    if (processedAccConfigSet.contains(accConf.Id))
                        continue;
//                  if(acc.accessory.child_product_code__c==accConf.O2_DISE_Ref_Hardware_Portfolio__c &&
                    if(acc.accessory.id==accConf.O2_DISE_Ref_Hardware_Relation__c &&
                            acc.quantity==accConf.Quantity_of_Accessory__c) {

                        //set child on parent
                        acAttr.cscfgc__Value__c += accConf.Id + ',';

                        //set parent on child
                        accConf.cscfgc__Parent_Configuration__c = topConfig.Id;
                        accConf.cscfgc__Root_Configuration__c = topConfig.Id;
                        relConfigUpdateList.add(accConf);
                        processedAccConfigSet.add(accConf.Id);
                        // matched this accesssory - go to next accessory
                        break;

                    }
                }
            }
            //if attribute set add to update list and remove last comma
            if(acAttr!=null && acAttr.cscfgc__Value__c!=null && acAttr.cscfgc__Value__c!='') {
                acAttr.cscfgc__Value__c = acAttr.cscfgc__Value__c.substring(0, acAttr.cscfgc__Value__c.length()-1);
                attrUpdateList.add(acAttr);
            }

			for(cscfgc__Product_Configuration__c dpConf : dpConfigList) {
                dpConf.cscfgc__Parent_Configuration__c = topConfig.Id;
                        dpConf.cscfgc__Root_Configuration__c = topConfig.Id;
                        relConfigUpdateList.add(dpConf);           
        	}
        }
        //topConfigList.addAll(relConfigUpdateList);
        for (cscfgc__Product_Configuration__c pConf : relConfigUpdateList) {
            system.debug(LoggingLevel.INFO,'****relConfigUpdateList:'+pConf);
        }
        update relConfigUpdateList;
        update attrUpdateList;

     
        return goToBasket();
    }
}