public with sharing class O2OnlineEmailConfirmationExtension {

  public Id oppId {get;set;}
    public Opportunity opp {get;set;}
    public List<cscfgc__Product_Bundle__c> prodBundle;

    public O2OnlineEmailConfirmationExtension(){}
    public O2OnlineEmailConfirmationExtension getController() {return this;}

  public String title {get; set;}
  public String lastname {get; set;}
  public String firstname {get; set;}
  public String orderReq {get; set;}
  public String bundleId {get; set;}
  
  //Created by Ivor Goreta for Pre Order 2.
  public String getPreBackOrderMessage() { 	

 	//CHECK CUSTOM SETTINGS.------------------------------------------------------------------------
 	if (CreditCheckSettings__c.getInstance('Online Enabled').Value__c != 'Y') { return ''; }
 	
 	//CHECK CREDIT VET.-----------------------------------------------------------------------------
 /*	List<Credit_Vet__c> credits = [
 	  select id,
 	         name,
 	         IDV_Result__c
      from   Credit_Vet__c
      where  Opportunity__c = :oppId
    ];
    
    if(credits.size()>0) { if (credits[0].IDV_Result__c != 'Accept' && credits[0].IDV_Result__c != 'Data Amend') { return ''; } } */
 	
 	//GET ALL PRODUCT CONFIGURATIONS.
	List<cscfgc__Product_Configuration__c> configurations = [
		select 	id, 
				name, 
														
				O2_DISE_Map_Handset_Selection__c,
				O2_DISE_Map_Handset_Selection__r.id,
				
				O2_DISE_Map_Handset_Selection__r.Product_Code__c,
				O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_PreOrder__c,
				O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_BackOrder__c,
				O2_DISE_Map_Handset_Selection__r.Product_Code__r.Stock_Message__c,
				O2_DISE_Map_Handset_Selection__r.Product_Code__r.PreOrder_Stock_Level__c
				
		from 	cscfgc__Product_Configuration__c 
		where 	O2_DISE_Map_Handset_Selection__c != null
		and		cscfgc__Product_Bundle__c in (
					select 	id 
					from 	cscfgc__Product_Bundle__c 
					where 	cscfgc__Opportunity__c                   = : oppId
					
				)				
	];

	boolean preOrder     = false;
	boolean backOrder    = false;
	for(cscfgc__Product_Configuration__c config : configurations ) {
		Boolean AvailableForPreOrder  = config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_Preorder__c;
		Boolean AvailableForBackOrder = config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_BackOrder__c;

		if(AvailableForPreOrder  == true) { preOrder  = true; } 
		if(AvailableForBackOrder == true) { backOrder = true; } 
	}
	
	String message = '';
	if (preOrder  == true) 						{ message = Label.ONLINE_EMAIL_CONFIRMATION_PREORDER;    } //message = 'One or more items are Pre Order.'  
	if (backOrder == true) 						{ message = Label.ONLINE_EMAIL_CONFIRMATION_BACKORDER;   } //message = 'One or more items are Back Order.'               
	if (preOrder  == true && backOrder == true) { message = Label.ONLINE_EMAIL_CONFIRMATION_PREBACKORDER;} //message = 'One or more items are Back Order and Pre Order.' 

  	return message;  				
  }
  
  public String getOppContactRole(){

    if (oppId!=null) {
      Opportunity opp = [Select o.Id,o.Order_Request_Number__c, (Select Id, Name, cscfgc__Opportunity__c From cscfgc__Product_Bundles__r), (Select Id, OpportunityId, ContactId From OpportunityContactRoles) From Opportunity o where o.Id=:oppId limit 1];
      prodBundle = opp.cscfgc__Product_Bundles__r;
      orderReq = opp.Order_Request_Number__c;

      List<OpportunityContactRole> contactRole = opp.OpportunityContactRoles;
      if(contactRole.size() > 0){
        Contact con = [Select Id, Salutation, Lastname, FirstName from Contact where Id=:contactRole[0].ContactId limit 1];

        title = con.Salutation;
        lastname = con.LastName;
        firstname = con.FirstName;
      }
    }
    return null;
  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //[zz 121108] for conditinal mll rendering
  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  // checks if oreder is just mll
  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  public Boolean isMLLOnlyOrder
  {
    get
    {
      try
      {
        if(prodBundle == null)
        {

        	getOppContactRole();
        }
        if(prodBundle.size() == 1)
        {
        	List<EmailConfigWrapper> wrapper = getAllCreatedProductConfiguratons();
        	if(wrapper[0].cfgwrapper.config.Name.equals('Mobile Landline') ||  wrapper[0].cfgwrapper.config.Name.equals('Mobile Landline One Month Free'))
        	{
        		return true;
        	}
        }
        return false;
      }
      catch (Exception ex)
      {
        return false;
      }
    }
  }
  // checks if oreder contains mll
  public Boolean isMLLOrder
  {
    get
    {
      try
      {
        if(prodBundle == null)
        {
        	getOppContactRole();
        }
        if(prodBundle.size() > 0)
        {
        	List<EmailConfigWrapper> wrapper = getAllCreatedProductConfiguratons();
        	for(EmailConfigWrapper config: wrapper)
        	{
        		if(config.cfgwrapper.config.Name.equals('Mobile Landline') ||  config.cfgwrapper.config.Name.equals('Mobile Landline One Month Free'))
        		{
        			return true;
        		}
        	}
        }
        return false;
      }
      catch (Exception ex)
      {
        return false;
      }
    }
  }
  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  //public List<ProductBundleController.ConfigWrapper> getAllCreatedProductConfiguratons(){
  public List<EmailConfigWrapper> getAllCreatedProductConfiguratons(){
    if(prodBundle!=null && prodBundle.size() > 0){
      ApexPages.StandardController sc;
      if(prodBundle[0] != null) sc = new ApexPages.StandardController(prodBundle[0]);
      ProductBundleController prod = new ProductBundleController(sc);
      prod.bundleId = bundleId;
      //return prod.getAllProductConfigurations();
      //### START new one off calc code
      List<ProductBundleController.ConfigWrapper> cfgWrap = new List<ProductBundleController.ConfigWrapper>();
      cfgWrap = prod.getAllProductConfigurations();
      List<EmailConfigWrapper> eWrap = new List<EmailConfigWrapper>();
      if (cfgWrap!=null && cfgWrap.size()>0) {
        List<cscfgc__Product_Configuration__c> topLevelConfigs = new List<cscfgc__Product_Configuration__c>();
        for (ProductBundleController.ConfigWrapper cw: cfgWrap) {
          if (cw.config.cscfgc__Parent_Configuration__c == null) {topLevelConfigs.add(cw.config);}	//add toplevel configwrappers to reference list
        }
        if (topLevelConfigs!=null && topLevelConfigs.size()>0) {
          Integer i = 0;
          for (cscfgc__Product_Configuration__c cfg: topLevelConfigs) {
            EmailConfigWrapper ecw = new EmailConfigWrapper();
            ecw.dOneOffPrice = 0;
            ecw.index = i;
            for (ProductBundleController.ConfigWrapper cw: cfgWrap) {
              if (cw.config.Id == cfg.Id) ecw.cfgwrapper = cw;	//add toplevel configwrapper
              if (cw.config.Id == cfg.Id || cw.config.cscfgc__Parent_Configuration__c == cfg.Id) {
                List<cscfgc__Attribute__c> lsAttribs = cw.attributeList;
                if (lsAttribs!=null && lsAttribs.size()>0) {
                  for (cscfgc__Attribute__c att: lsAttribs) {
                    if (att.cscfgc__Price__c > 0 && !att.cscfgc__Recurring__c) {ecw.dOneOffPrice += att.cscfgc__Price__c;}
                  }
                }
              }
            }
            ecw.dFirstBillingCharge = ecw.cfgwrapper.getRecurringBillingCharge() + ecw.dOneOffPrice;
            eWrap.add(ecw);
            i++;
          }
        }
      }

      return eWrap;
      //### END new one off calc code
    }
    else
    {
      return null;
    }
  }

  //SW CDECISIONS 11/01/2012 - added following subclass and added calc into getAllCreatedProductConfigurations method
  public class EmailConfigWrapper {
    public ProductBundleController.ConfigWrapper cfgwrapper {get;set;}
    public Decimal dOneOffPrice {get;set;}
    public Decimal dFirstBillingCharge {get;set;}
    public Integer index {get;set;} //SW CDECISIONS 29/06/2012 - added to provide a sequential index to the configs in the list
    public EmailConfigWrapper() {}
  }

  //UTILITY CUSTOM SETTING CODE
  public String getSiteURL() {
    String strResult = '';
    strResult = OnlineGeneralSettings__c.getInstance('Online Shop URL').Value__c;
    return strResult;
  }
  //END UTILITY CODE

  //####################################################################
    //############## TO DISPLAY PRODUCT SUMMARY ON EMAIL #################
    //####################################################################

  //SEND EMAIL BASKET
    public cscfgc__Product_Basket__c  getSessionId(){
        if(basId!=null){
          return[Select c.cscfgc__User_Session__r.cscfgc__Session_Id__c, c.cscfgc__User_Session__c
                 From cscfgc__Product_Basket__c c
                 where id=:basId
                ];
        }
        else {
          return null;
        }
    }

    public class BasketConfiguration {
      public Integer index {get;set;}
      public cscfgc__Product_Configuration__c cfg {get;set;}
      public Decimal dRecurringPrice {get;set;}
      public Decimal dOneOffPrice {get;set;}
      public Boolean hasSavings {get;set;}
      public Boolean hasExtras {get;set;}
      public BasketConfiguration() {}
    }

    public class BasketCategory {
    public String cat {get;set;}
    public String index {get;set;}
    public BasketCategory() {}
  }
    //GET PRODUCT CONFIGURATION
    public List<cscfgc__Product_Configuration__c> currentConfigs {get;set;}
    public cscfgc__Product_Basket__c currentBasket {get;set;}
    public Id basId { get;set; }
    public static final String DRAFT_STATUS = 'DRAFT';
    public Map<String, String> categoryIndexes {get; set;}
    Decimal totalOneOff;
    Decimal totalRecurring;
    Boolean basketTotalled = false;

    public cscfgc__Product_Basket__c retrieveCurrentBasket() {
            if (basId != null) {
                currentBasket = [SELECT Id,Customer_Email__c , Name, cscfgc__User_Session__c, cscfgc__Total_Price__c, cscfgc__Shared_Context_Configuration__c, cscfgc__Opportunity__c, cscfgc__Basket_Status__c, cscfgc__Products_In_Basket__c
                              FROM cscfgc__Product_Basket__c WHERE Id = :basId];
                currentConfigs = [SELECT Id, Name, cscfgc__Total_Price__c, cscfgc__Recurring_Charge__c, cscfgc__Product_Basket__c, cscfgc__Product_Bundle__c, cscfgc__One_Off_Charge__c,
                                cscfgc__configuration_status__c, cscfgc__Parent_Configuration__c, cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name, cscfgc__Screen_Flow__r.Name,
                              (SELECT Id, Name, cscfgc__Price__c
                                FROM cscfgc__Attributes__r
                                WHERE cscfgc__Is_Line_Item__c=true AND cscfgc__Recurring__c=false AND cscfgc__Price__c <> null)
                               FROM cscfgc__Product_Configuration__c
                               WHERE cscfgc__Product_Basket__c=:currentBasket.Id ORDER BY cscfgc__Serial_Number__c desc];
            }
       return currentBasket;
    }
    //GET BASKET CONFIGURATION
    public BasketConfiguration[] getBasketConfigs() {
        BasketConfiguration[] basketconfigs = new BasketConfiguration[0];
        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
        currentBasket = retrieveCurrentBasket();
        configs = currentConfigs;

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
              bsk.index = i++;
              for (cscfgc__Product_Configuration__c c: configs) {
                if (c.Id == parcfg.Id || c.cscfgc__Parent_Configuration__c == parcfg.Id) {
                  if( c.cscfgc__Recurring_Charge__c!=null) bsk.dRecurringPrice += c.cscfgc__Recurring_Charge__c;
                    if (c.cscfgc__Attributes__r != null) {
                    for (cscfgc__Attribute__c att: c.cscfgc__Attributes__r) {
                      if (att.cscfgc__Price__c > 0) bsk.dOneOffPrice += att.cscfgc__Price__c;
                      else bsk.hasSavings = true;
                    }
                  }
                  else bsk.dOneOffPrice += c.cscfgc__One_Off_Charge__c;
                }
              }
              basketconfigs.add(bsk);
            }
          }
        }
        return basketconfigs;
    }

    //BASKET CATEGORIES
    public List<BasketCategory> getBasketCategories() {
    List<BasketCategory> retCategories = new List<BasketCategory>();
    Map<String, BasketCategory> mpCats = new Map<String, BasketCategory>();
    BasketCategory defCat = new BasketCategory();	//add default empty category
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

      }
    }
    List<String> sortList = new List<String>(mpCats.keySet());
    sortList.sort();
    for (String s: sortList) {retCategories.add(mpCats.get(s));}
        //populate category index map
        categoryIndexes = new Map<String, String>();
    for (BasketCategory bc: retCategories) {categoryIndexes.put(bc.cat, bc.index);}
    return retCategories;
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

    //####################################################################
    //############## END #################################################
    //####################################################################

  //SW CDECISIONS 27/06/2012 - added code to trigger notification from credit vet record
  public Id creditVetId {get;set;}
    public Credit_Vet__c creditvet {
      get {
        if (creditvet==null && creditVetId!=null) {return getCreditVetData();}
        else return creditvet;
      }
      set;
    }
    public Credit_Vet__c getCreditVetData() {
      Credit_Vet__c retCV;
      if (creditVetId!=null) {
        List<Credit_Vet__c> lsCV = [SELECT Id, Name, IDV_Result__c, IDV_Result_Code__c, IDV_Reason_Code__c, IDV_Reason_Description__c, Opportunity__c FROM Credit_Vet__c WHERE Id=:creditVetId LIMIT 1];
        if (lsCV!=null && lsCV.size()>0) {
          oppId = lsCV[0].Opportunity__c;
          retCV = lsCV[0];
          getOppContactRole();
        }
      }
      return retCV;
    }
}