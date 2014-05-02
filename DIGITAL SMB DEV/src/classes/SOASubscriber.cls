public class SOASubscriber extends SOAServicesBase {

    static final String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">';
    
    public String subscriberID { get; set; } 
    public String msisdn { get; set; } 
    public String accountNumber { get; set; } 
    
    public PageReference run() {
        String ctype = ApexPages.currentPage().getParameters().get('type');
        if(ctype=='getBillingSystem') return getBillingSystem();
        if(ctype=='getBillProfile') return getBillProfile();
        if(ctype=='getChargingCategory') return getChargingCategory();
        if(ctype=='getSubscriberAndBillingSystem') return getSubscriberAndBillingSystem();
        if(ctype=='getSubscriberChannel') return getSubscriberChannel();
        if(ctype=='getSubscriberOperator') return getSubscriberOperator();
        if(ctype=='getSubscriberPaymentCategory') return getSubscriberPaymentCategory();
        if(ctype=='getSubscriberProfile') return getSubscriberProfile();
        else return getSubscriberProfile();
    }
    private PageReference getBillingSystem() {
        String innerXML = '' +
          '<sub:getBillingSystem>'+
          '   <sub:msisdn>'+ msisdn +'</sub:msisdn>'+
          '</sub:getBillingSystem>';
        sendRequest(SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c,envelopeXML,innerXML );
        return null;
    }
    private PageReference getBillProfile() {
        String innerXML = ''+
        '<sub:getBillProfile>';
         //<!--You have a CHOICE of the next 2 items at this level-->
        if(msisdn!='') innerXML +='<sub:msisdn>'+msisdn+'</sub:msisdn>';
        if(accountNumber!='') innerXML +='<sub:accountNumber>'+accountNumber+'</sub:accountNumber>';
        innerXML +='</sub:getBillProfile>';
        sendRequest(SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c,envelopeXML,innerXML );
        return null;
    }
    private PageReference getChargingCategory() {
        String innerXML = ''; 
        innerXML +='<sub:getChargingCategory>'; 
        innerXML +='<sub:msisdn>'+msisdn+'</sub:msisdn>'; 
        // <!--Optional:-->
        //innerXML +='<sub:productList>'; 
        //innerXML +='<sub:tariffProductId>?</sub:tariffProductId>'; 
        //    <!--Optional:-->
        //innerXML +='<sub:services>'; 
        //       <!--1 or more repetitions:-->
        //innerXML +='<sub:productId>?</sub:productId>'; 
        //innerXML +='</sub:services>'; 
        //innerXML +='</sub:productList>'; 
        innerXML +='</sub:getChargingCategory>'; 

        sendRequest(SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c,envelopeXML,innerXML );
        return null;
    }
    private PageReference getSubscriberAndBillingSystem() {
        String innerXML = ''; 
        innerXML +='<sub:getSubscriberProfile>';
        innerXML +='<sub:subscriberID>'+ msisdn+'</sub:subscriberID>';
        innerXML +='</sub:getSubscriberProfile>';
        sendRequest(SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c,envelopeXML,innerXML );
        return null;
    }
    private PageReference getSubscriberChannel() {
        String innerXML = ''; 
        innerXML +='<sub:getSubscriberChannel>';
        innerXML +='<sub:SubscriberID>'+ subscriberID +'</sub:SubscriberID>';
        innerXML +='</sub:getSubscriberChannel>';
        sendRequest(SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c,envelopeXML,innerXML );
        return null;
    }
    private PageReference getSubscriberOperator() {
        String innerXML = '';         
        innerXML +='<sub:getSubscriberOperator>';
        innerXML +='<sub:SubscriberID>'+ subscriberID +'</sub:SubscriberID>';
        innerXML +='</sub:getSubscriberOperator>';
        sendRequest(SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c,envelopeXML,innerXML );
        return null;
    }
    private PageReference getSubscriberPaymentCategory() {
        String innerXML = ''; 
        innerXML +='<sub:getSubscriberPaymentCategory>';
        innerXML +='<sub:SubscriberID>'+ subscriberID +'</sub:SubscriberID>';
        innerXML +='</sub:getSubscriberPaymentCategory>';
        sendRequest(SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c,envelopeXML,innerXML );
        return null;
    }                            
    private PageReference getSubscriberProfile() {
        String innerXML = ''; 
        innerXML +='<sub:getSubscriberProfile>';
        innerXML +='<sub:subscriberID>'+ subscriberID +'</sub:subscriberID>';
        innerXML +='</sub:getSubscriberProfile>';
        sendRequest(SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c,envelopeXML,innerXML );
        return null;
    }    

    static PageReference testRun(String typeName) {
		Test.setCurrentPage(Page.ChangePassword);
		ApexPages.currentPage().getParameters() .put('type',typeName);
		
        SOASubscriber controller = new SOASubscriber();
        controller.subscriberID = '123456789';
        controller.msisdn = '123456789';
        controller.accountNumber = '1234';
        return controller.run();   	
    }
    
    static testMethod void testSOASubscriber() {
        system.assertEquals(null, testRun('getBillingSystem'));
        system.assertEquals(null, testRun('getBillProfile'));
        system.assertEquals(null, testRun('getChargingCategory'));
        system.assertEquals(null, testRun('getSubscriberAndBillingSystem'));
        system.assertEquals(null, testRun('getSubscriberChannel'));
        system.assertEquals(null, testRun('getSubscriberOperator'));
        system.assertEquals(null, testRun('getSubscriberPaymentCategory'));
        system.assertEquals(null, testRun('getSubscriberProfile'));

    } 
}