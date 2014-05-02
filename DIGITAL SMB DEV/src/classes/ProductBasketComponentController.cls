public with sharing class ProductBasketComponentController {
	// CODE FROM HERE MOVED TO O2OnlineEmailConfirmationExtension . NOT USED ANYMORE
	/*
	public Id basId { get;set; }
	
  //UTILITY CUSTOM SETTING CODE
  public String getSiteURL() {
    String strResult = '';
    strResult = OnlineGeneralSettings__c.getInstance('Online Shop URL').Value__c;
    return strResult;
  }
  //END UTILITY CODE
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
  */
  /*
  public List<cscfgc__Product_Configuration__c> getProductConfigs(){
  	
  	if(basId!=null){
  		return [select name,cscfgc__Total_Price__c from cscfgc__Product_Configuration__c where cscfgc__Product_Basket__c =: basId];
  	}
  	else{
  		return null;
  	}
  	
  }
  */

}