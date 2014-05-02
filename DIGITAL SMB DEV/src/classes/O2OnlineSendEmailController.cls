public with sharing class O2OnlineSendEmailController {

	 public cscfgc__Product_Basket__c basket {get;set;}
	 public O2OnlineMainController parentController {get;set;}
	 
	 
	  public O2OnlineSendEmailController(){ 
	  	   
	  	   SendEmail();
	}
	 
	 public PageReference SendEmail(){
	 	
	 	System.debug('******Test Enter***');
	 	
	 	//PageReference page=new PageReference('/apex/O2OnlineSendEmailConfirmation');
	 	
	 	basket = parentController.sessionbasket;
	 	System.debug('***Basket :'+basket);
	 	System.debug('***Basket Id :'+basket.id);
	 	/*
	 	if(shoppingBasketId!=null && emailCapture!=null){
	 		
	 		System.debug('--->Coming');
	 		
	 		cscfgc__Product_Basket__c proBas=[select Customer_Email__c, Send_Email__c from cscfgc__Product_Basket__c where id =: shoppingBasketId limit 1];
	 		proBas.Customer_Email__c=emailCapture;
	 		proBas.Send_Email__c=true;
	 		update proBas;
	 	}
	 	*/
	 	return null;
	 }
	 /*
	 public String getEmailCapture(){
	 	return this.emailCapture;
	 }
	 
	 public void setEmailCapture(String ec){
	 	this.emailCapture=ec;
	// 	SendEmail();
	 }
	 */
	 
}