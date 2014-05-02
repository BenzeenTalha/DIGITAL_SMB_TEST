public with sharing class O2OnlineProductBasketController {

    public static final String DRAFT_STATUS = 'DRAFT';
    public static final String EDIT_ATTR_NAME = 'Product Reconfigurable';
    public cscfgc__Product_Basket__c pbasket ;
    public O2OnlineMainController parentController {get;set;}
    public O2OnlineMainController parentController2 {get;set;}
    public O2OnlineMobileController mobileController {get;set;}
    public cscfgc__Product_Basket__c sessionbasket {get;set;}
    public cscfgc__Product_Basket__c currentBasket {get;set;}
    public List<cscfgc__Product_Configuration__c> currentConfigs {get;set;}
    public Map<String, Page_Product__c> pageProductsByDefId {get; set;}
    public String removeProductId {get;set;}
    public String editConfigId {get;set;}
    public String editScreenFlow {get;set;}
    public String editOfferId {get; set;}
    public boolean displayControls {get;set;}
    public boolean sidebar {get;set;}
    Decimal totalOneOff;
    Decimal totalRecurring;
    Boolean basketTotalled = false;
    public Map<String, String> categoryIndexes {get; set;}

    public O2OnlineProductBasketController() {  }
    public O2OnlineProductBasketController(O2OnlineMainController maincontroller) {this.parentController = maincontroller; this.parentController2 = maincontroller;}

    public PageReference retrieveBasket() {
        currentbasket = retrieveCurrentBasket();
        return null;
    }
    public cscfgc__Product_Basket__c retrieveCurrentBasket() {
        //if (parentController.newUserSession!=null && sidebar!=true) {
            if (parentController.newUserSession==null) {parentController.startSession();}   //make sure that there is a usersession active
            if (sessionbasket==null) {sessionbasket = parentController.sessionbasket;}  //make sure that have a sessionbasket from the user session
            if (sessionbasket!=null) {
                currentBasket = [SELECT Id,Customer_Email__c , Name, cscfgc__User_Session__c, cscfgc__Total_Price__c, cscfgc__Shared_Context_Configuration__c, cscfgc__Opportunity__c, cscfgc__Basket_Status__c
                                    FROM cscfgc__Product_Basket__c WHERE Id = :sessionbasket.Id LIMIT 1];
                currentConfigs = [SELECT Id, Name, cscfgc__Total_Price__c, cscfgc__Recurring_Charge__c, cscfgc__Product_Basket__c, cscfgc__Product_Bundle__c, cscfgc__One_Off_Charge__c,
                                    cscfgc__configuration_status__c, cscfgc__Parent_Configuration__c, cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name, cscfgc__Screen_Flow__r.Name,
                                    O2_DISE_Map_Mobile__c, O2_DISE_Map_Handset__c, O2_DISE_Map_Handset__r.Product_Code__c, O2_DISE_Map_Handset_Selection__c,
                                    Quantity_of_Accessory__c, O2_DISE_Map_Mobile_Bolton__c,
                                    (SELECT Id, Name, cscfgc__Price__c, cscfgc__Value__c
                                        FROM cscfgc__Attributes__r
                                        WHERE ((cscfgc__Is_Line_Item__c=true AND cscfgc__Recurring__c=false AND cscfgc__Price__c <> null) OR (Name = :EDIT_ATTR_NAME)))
                                     FROM cscfgc__Product_Configuration__c
                                     WHERE cscfgc__Product_Basket__c=:currentBasket.Id ORDER BY cscfgc__Serial_Number__c desc];
            }
        //}
        //parentController.currentbasket = currentbasket;
        parentController.currentConfigs = currentConfigs;   //SW CDECISIONS 10/01/2012 - added in place of line above since currentbasket no longer has child product configs
        return currentBasket;
    }

    public String getBasketSize() {
        String strSize = '';
        currentBasket = retrieveCurrentBasket();
        System.debug('### OUTPUT >>>>> getBasketSize: sessionbasket: '+sessionbasket);
        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
        if (currentBasket!=null) {
            for (cscfgc__Product_Configuration__c cfg: currentConfigs) {
                if (cfg.cscfgc__Parent_Configuration__c==null && cfg.cscfgc__Configuration_Status__c != DRAFT_STATUS) {configs.add(cfg);}
            }
        }
        if (sessionbasket!=null) {
            System.debug('getBasketSize: configs.size(): '+configs.size());
            System.debug('getBasketSize: configs: '+configs);
            if (configs.size()==0) strSize = 'Empty';
            else if (configs.size()==1) strSize = '1 package';
            else strSize = configs.size()+' packages';
        }
        else strSize = 'Empty';
        parentcontroller.numProducts = strSize;
        return strSize;
    }

    public Decimal getTotalRecurring() {
        if (!basketTotalled) {
            if (currentBasket == null) currentBasket = retrieveCurrentBasket();
            if (currentBasket != null) {
                calculateBasketTotals(currentConfigs);
            }
            basketTotalled = true;
        }
        return totalRecurring;
    }

    public Decimal getTotalOneOff() {
        if (!basketTotalled) {
            if (currentBasket == null) currentBasket = retrieveCurrentBasket();
            if (currentBasket != null) {
                calculateBasketTotals(currentConfigs);
            }
            basketTotalled = true;
        }
        return totalOneOff;
    }

    public class BasketConfiguration {
        public Integer index {get;set;}
        public cscfgc__Product_Configuration__c cfg {get;set;}
        public Decimal dRecurringPrice {get;set;}
        public Decimal dOneOffPrice {get;set;}
        public Boolean hasSavings {get;set;}
        public Boolean hasExtras {get;set;}
        public Boolean canEdit {get;set;}
        public BasketConfiguration() {}
    }

    public BasketConfiguration[] getBasketConfigs() {
        BasketConfiguration[] basketconfigs = new BasketConfiguration[0];
        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
        configs = getBasketProducts();
        if (configs!=null && configs.size()>0) {
            //build list of parent cfgs
            List<cscfgc__Product_Configuration__c> parCfgList = new List<cscfgc__Product_Configuration__c>();
            for (cscfgc__Product_Configuration__c cfg: configs) {
                if (cfg.cscfgc__Parent_Configuration__c == null && cfg.cscfgc__configuration_status__c != DRAFT_STATUS) parCfgList.add(cfg);
            }
            //cycle through all configs, calc prices, and build list of output basket configs
            if (parCfgList!=null && parCfgList.size()>0) {
                Integer i=0;
                for (cscfgc__Product_Configuration__c parcfg: parCfgList) {
                    BasketConfiguration bsk = new BasketConfiguration();
                    bsk.cfg = parcfg;
                    bsk.dRecurringPrice = 0;
                    bsk.dOneOffPrice = 0;
                    bsk.hasSavings = false;
                    bsk.canEdit = true;
                    bsk.index = i++;
                    for (cscfgc__Product_Configuration__c c: configs) {
                        if (c.Id == parcfg.Id || c.cscfgc__Parent_Configuration__c == parcfg.Id) {
                            if( c.cscfgc__Recurring_Charge__c!=null) bsk.dRecurringPrice += c.cscfgc__Recurring_Charge__c;
                            //SW CDECISIONS 21/12/2011 - added conditional if savings detected, so calculated from actual attribs
                            if (c.cscfgc__Attributes__r != null) {
                                for (cscfgc__Attribute__c att: c.cscfgc__Attributes__r) {
                                    //[zz 121112 negative line item calculation]

                                    if (att.cscfgc__Price__c > 0) bsk.dOneOffPrice += att.cscfgc__Price__c;
                                    else bsk.hasSavings = true;
                                    if (att.Name==EDIT_ATTR_NAME && att.cscfgc__Value__c!=null && att.cscfgc__Value__c.toUpperCase()=='NO') bsk.canEdit = false;
                                }
                            }
                            else bsk.dOneOffPrice += c.cscfgc__One_Off_Charge__c;
                        }
                    }
                    basketconfigs.add(bsk);
                }
            }
        }
        System.debug('### OUTPUT >>>>> getBasketConfigs: basketconfigs: '+basketconfigs);
        return basketconfigs;
    }

    public cscfgc__Product_Configuration__c[] getBasketProducts() {
        currentBasket = retrieveCurrentBasket();
        System.debug('### OUTPUT >>>>> getBasketProducts: sessionbasket: '+currentBasket);
        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
        if (currentBasket!=null) {
            System.debug('### OUTPUT >>>>> getBasketProducts: sessionbasket_products: '+currentConfigs);
            configs = currentConfigs;
            System.debug('### OUTPUT >>>>> getBasketProducts: configs: '+configs);
        }

        List<String> ids = new Id[0];
        pageProductsByDefId = new Map<String, Page_Product__c>{};
        for (cscfgc__Product_Configuration__c config : configs) {
            ids.add(config.cscfgc__product_definition__c);
        }
        List<Page_Product__c> pageProducts = [select product_definition__c, screen_flow__r.name, offer__c from Page_Product__c where product_definition__c in :ids];
        for (Page_Product__c p : pageProducts) {
            pageProductsByDefId.put(p.product_definition__c, p);
        }

        return configs;
    }
    public PageReference removeProductFromBasket() {
        System.debug('### OUTPUT >>>>> removeProductId: '+removeProductId);
        System.debug('### OUTPUT >>>>> removeProductFromBasket: sessionbasket: '+sessionbasket);
        //if (sessionbasket!=null) {parentController.apiSession.removeConfigurationFromBasket(removeProductId);}
        if (sessionbasket != null)
        {
            System.debug('### OUTPUT >>>>> removeProductFromBasket: about to call BasketManager functions...');
            List<cscfgc__Product_Configuration__c> prodList = [select Id,name,cscfgc__Product_Basket__c  from cscfgc__Product_Configuration__c where Id = :removeProductId ];
            try {
                cscfgc.ProductBasketManager.removeProductsFromBasket(prodlist, sessionbasket);
                cscfgc.ProductBasketManager.updateBasketStatusAndTotal(sessionbasket);

            } catch(System.DmlException dmle) {
                // ignore the exception
                system.debug('DML Exception: '+dmle.getMessage());
            }
            // allow the costs to be recalculated
            basketTotalled = false;
        }
        return null;
    }

    public PageReference editProductInBasket() {
        if (currentBasket == null) retrieveCurrentBasket();
        cscfgc__Product_Configuration__c[] configs = currentConfigs;
        for (cscfgc__Product_Configuration__c config : configs) {
            if (config.id == editConfigId) return parentController.editBasketProduct(editConfigId, editScreenFlow, editOfferId);
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No matching product found in basket'));

        /*
        System.debug('### OUTPUT >>>>> editProductInBasket: editConfigId: '+editConfigId);
        cscfgc__Product_Configuration__c cfg = new cscfgc__Product_Configuration__c(id = editConfigId) ;
        Map<ID, cscfgc__Product_Configuration__c> mpConfigs = new Map<ID, cscfgc__Product_Configuration__c>(sessionbasket.cscfgc__Product_Configurations__r);
        System.debug('### OUTPUT >>>>> editProductInBasket: mpConfigs: '+mpConfigs);
        parentController.definitionId=mpConfigs.get(editConfigId).cscfgc__Product_Definition__c;
        cscfgc__Product_Definition__c def = new cscfgc__Product_Definition__c(Id=parentController.definitionId);
        System.debug('### OUTPUT >>>>>  editProductInBasket: definitionId: '+parentController.definitionId);
        parentController.newApiSession = parentController.apiSession = cscfgc.API_1.getApiSession(def);
        parentController.newUserSession = parentController.userSession = parentController.newApiSession.loadUserSession(parentController.newApiSession.getUserSession().usersession.Id);
        parentController.newApiSession.setConfigurationToEdit(cfg);
        parentController.productName = parentController.getProduct();   //ensure that the product name has been identified to set attributes
        System.debug('### OUTPUT >>>>> editProductInBasket: productName: '+parentController.getProduct());
        //apiSession.getController().reference = '';
        //editScreenFlow = 'SMB Landline Online SW';
        System.debug('### OUTPUT >>>>> editProductInBasket: editScreenFlow: '+editScreenFlow);
        parentController.screenIndex = '1'; //set to the beginning of selected screenflow
        //parentController.screenFlowName = editScreenFlow; //set to the screenflow
        //return parentController.selectScreen();
        */
        return null;
    }

    public PageReference emptyBasket() {
        //parentController.userSession.clearBasket();
        System.debug('### OUTPUT >>>>> emptyBasket: '+sessionbasket);
        if (sessionbasket!=null && currentBasket != null)
        {
            List<cscfgc__Product_Configuration__c> prodList = new List<cscfgc__Product_Configuration__c>(currentConfigs);
            System.debug('### OUTPUT >>>>> emptyBasket: prodList: '+prodList);
            cscfgc.ProductBasketManager.removeProductsFromBasket(prodlist, sessionbasket);
            cscfgc.ProductBasketManager.updateBasketStatusAndTotal(sessionbasket);
        }
        return null;
    }


    void calculateBasketTotals(List<cscfgc__Product_Configuration__c> configs) {
        totalRecurring = 0;
        totalOneOff = 0;
        Map<Id, cscfgc__Product_Configuration__c> configsById = getConfigsById(currentConfigs);
        for (cscfgc__Product_Configuration__c cfg: currentConfigs) {
            String status = cfg.cscfgc__configuration_status__c;
            if (cfg.cscfgc__parent_configuration__c != null) {
                cscfgc__Product_Configuration__c parent = configsById.get(cfg.cscfgc__parent_configuration__c);
                if (parent != null) status = parent.cscfgc__configuration_status__c;
            }
            if (status != DRAFT_STATUS) {
                totalRecurring += cfg.cscfgc__Recurring_Charge__c;
                //SW CDECISIONS 21/12/2011 - added conditional if savings detected, so calculated from actual attribs
                if (cfg.cscfgc__Attributes__r != null) {
                    for (cscfgc__Attribute__c att: cfg.cscfgc__Attributes__r) {
                        if (att.cscfgc__Price__c > 0) totalOneOff += att.cscfgc__Price__c;
                    }
                }
                else totalOneOff += cfg.cscfgc__One_Off_Charge__c;
            }
        }
    }

    public static Map<Id, cscfgc__Product_Configuration__c> getConfigsById(List<cscfgc__Product_Configuration__c> configs) {
        Map<Id, cscfgc__Product_Configuration__c> configMap = new Map<Id, cscfgc__Product_Configuration__c>();
        for (cscfgc__Product_Configuration__c cfg: configs) {
            configMap.put(cfg.id, cfg);
        }
        return configMap;
    }

    public class BasketCategory {
        public String cat {get;set;}
        public String index {get;set;}
        public boolean isFirstCat {get;set;}
        public BasketCategory() 
        {
            isFirstCat = false;
        }
        
    }
    public List<BasketCategory> getBasketCategories() {
        List<BasketCategory> retCategories = new List<BasketCategory>();
        Map<String, BasketCategory> mpCats = new Map<String, BasketCategory>();
        BasketCategory defCat = new BasketCategory();   //add default empty category
        defCat.cat = '';
        defCat.index = '1';
        mpCats.put(defCat.cat, defCat);
        if (OnlineConfiguratorSettings__c.getInstance()!=null) {
            for (OnlineConfiguratorSettings__c cfg: OnlineConfiguratorSettings__c.getAll().values()) {
                if (cfg.Category__c!=null) {
                    if (mpCats.containsKey(cfg.Category__c)) {
                        if (cfg.Screen_Index__c!=null && mpCats.get(cfg.Category__c).index!=null && Integer.valueOf(cfg.Screen_Index__c) > Integer.valueOf(mpCats.get(cfg.Category__c).index)) {
                            BasketCategory bskCat = new BasketCategory();
                            bskCat.cat = cfg.Category__c;
                            bskCat.index = cfg.Screen_Index__c;
                            mpCats.put(cfg.Category__c, bskCat);
                        }
                    } else {
                        BasketCategory bskCat = new BasketCategory();
                        bskCat.cat = cfg.Category__c;
                        if (cfg.Screen_Index__c != null) bskCat.index = cfg.Screen_Index__c; else bskCat.index = defCat.index;
                        mpCats.put(cfg.Category__c, bskCat);
                    }
                }
                //else ASSERT: do nothing
            }
        }
        List<String> sortList = new List<String>(mpCats.keySet());
        sortList.sort();
        for (String s: sortList) {retCategories.add(mpCats.get(s));}
        //populate category index map
        categoryIndexes = new Map<String, String>();
        boolean isFirstCategory = true;
        for (BasketCategory bc: retCategories) {
            if (bc.cat == 'Savings')
            {
                bc.isFirstCat = true;
                isFirstCategory = false;
            }
            else bc.isFirstCat = false;
            categoryIndexes.put(bc.cat, bc.index);
        }
        return retCategories;
    }



    public String firstName {get;set;}
    public String lastName {get;set;}
    public String customerEmail {get;set;}
    public String confirmCustomerEmail {get;set;}
    public String phoneNumber {get;set;}

    public void SendEmail(){

        if (currentBasket == null) retrieveCurrentBasket();
        if(currentBasket!=null ){
            currentBasket.Send_Email__c=true;
            currentBasket.Customer_Email__c= customerEmail;
            currentBasket.First_Name__c= firstName;
            currentBasket.Last_Name__c= lastName;
            currentBasket.Phone_number__c=phoneNumber;
            update currentBasket;

        }
     }
     public PageReference gotoEmailConfirmation() {
        if (currentBasket!=null && currentBasket.Customer_Email__c!=null){

            PageReference emailConfPage = new PageReference('/apex/O2OnlineSendEmailConfirmation?e='+currentBasket.Customer_Email__c);
            emailConfPage.setRedirect(true);
            return emailConfPage;
        }
        else return null;
     }

    public boolean showCoverageCheckMessage{
        get{
            string v = OnlineGeneralSettings__c.getInstance('COVERAGE_CHECK_MESSAGE_ENABLED').Value__c;
            return v == 'Y';
        }
    }
}