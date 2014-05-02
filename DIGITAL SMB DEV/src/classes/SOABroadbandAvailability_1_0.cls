public class SOABroadbandAvailability_1_0 extends SOAServicesBase {

    static final String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bro="http://soa.o2.co.uk/broadbandavailabilitydata_1">';
    static final String endpoint = SOA_Integration_Settings__c.getValues('Broadband_Availability_Settings').Endpoint__c;
    
    public String postcode { get; set; }
    public String dn { get; set; }
    public String subscriberId { get; set; }
    public String typeOfResponse { get; set; }
    public String productCategory { get; set; }
  
    public PageReference run() {
        String ctype = ApexPages.currentPage().getParameters().get('type');
        if(ctype=='getAvailability') return getAvailability();
        if(ctype=='getBusinessAvailability_1') return getBusinessAvailability();
        if(ctype=='getAvailableProducts') return getAvailableProducts();
        if(ctype=='getDistanceFromExchange') return getDistanceFromExchange();
        else return getAvailability();    
    }
      
    public PageReference getAvailability() { 
        String innerXML = ''; 
        innerXML +='<bro:getAvailability>';
        innerXML += getIdentifierXML(); 
        innerXML +='</bro:getAvailability>';
        sendRequest(endpoint,envelopeXML,innerXML);
        return null;
    }
    
    public PageReference getBusinessAvailability() { 
        if(dn=='' && postcode=='') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Please enter a directory number or postcode.'));      
            return null;
        }
        if(dn!='') {
            if(!SOAUtils.isValidDirectoryNumber(dn)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Directory number not valid'));  
                return null;
            }          
        } else if(postcode!=null) { 
            if(!SOAUtils.isValidPostcode(postcode)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Postcode not valid')); 
                return null;
            }
        }    
        String innerXML = ''; 
        innerXML +='<bro:getBusinessAvailability_1>';
                        //<!--You have a CHOICE of the next 2 items at this level-->
        if(dn!='') {
            innerXML +='    <bro:dsl>'+dn+'</bro:dsl>';
        } else {
            innerXML +='    <bro:postCode>'+postcode+'</bro:postCode>';
        }
                        //<!--Optional:-->
        if(typeOfResponse!=null) {
            innerXML +='    <bro:typeOfResponse>'+typeOfResponse+'</bro:typeOfResponse>';
        }
                        //<!--Optional:-->
        if(productCategory!=null) {
            innerXML +='    <bro:productCategory>'+productCategory+'</bro:productCategory>';
        }
        innerXML +='</bro:getBusinessAvailability_1>';
        sendRequest(endpoint,envelopeXML,innerXML);
        return null; 
    }
    
    public PageReference getAvailableProducts() { 
        String innerXML = ''; 
        innerXML +='<bro:getAvailableProducts>';
        innerXML += getIdentifierXML();
        innerXML +='</bro:getAvailableProducts>';
        sendRequest(endpoint,envelopeXML,innerXML); 
        return null;
    }  
    
    public PageReference getDistanceFromExchange() { 
        String innerXML = ''; 
        innerXML +='<bro:getDistanceFromExchange>';
        innerXML += getIdentifierXML();
        innerXML +='</bro:getDistanceFromExchange>';
        sendRequest(endpoint,envelopeXML,innerXML);
        return null; 
    }
    
    private String getIdentifierXML () {
        String innerXML ='';
        //<!--You have a CHOICE of the next 2 items at this level-->' +
        if(dn!='') {
            innerXML +='    <bro:landlineNumber>'+dn+'</bro:landlineNumber>';
        } else {
            innerXML +='    <bro:postCode>'+postcode+'</bro:postCode>';
        }
        //<!--Optional:-->
        if(subscriberId!=null && subscriberId.length()>0) {
            innerXML +='    <bro:subscriberId>'+subscriberId+'</bro:subscriberId>';
        }  
        return innerXML;  
    }    
    
    static PageReference testRun(SOABroadbandAvailability_1_0 controller, String typeName) {
		Test.setCurrentPage(Page.ChangePassword);
		ApexPages.currentPage().getParameters() .put('type',typeName);
		
        return controller.run();   	
    }
    
    static testMethod void testSOABroadbandAvailability_1_0() {
        SOABroadbandAvailability_1_0 controller = new SOABroadbandAvailability_1_0();
        controller.postcode = 'A11 1AA';
        controller.typeOfResponse = 'test';
        controller.productCategory = 'test';
        controller.subscriberId = '123456789';
        controller.getAvailability();
        controller.getBusinessAvailability();
        controller.dn = '123456789';
        controller.getBusinessAvailability();
        controller.getAvailableProducts();
        controller.getDistanceFromExchange();
 
		// both postcode and dn
 		system.assertEquals(null, testRun(controller, 'getAvailability'));
 		
 		// dn and postcode
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
		// just dn
        controller.dn = '123456789';
 		controller.postcode = null;
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
		// just postcode
 		controller.dn = null;
		controller.postcode = 'A11 1AA'; 		
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
		// neither postcode and dn
		controller.dn = null;
		controller.postcode = null; 		
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
  		
  		// and again but with invalid values for DN and Postcode
		// both postcode and dn
        controller.dn = 'abracadabra';
 		controller.postcode = 'abracadabra';		
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
 		// dn and postcode
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
		// just dn
        controller.dn = 'abracadabra';
 		controller.postcode = null;
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
		// just postcode
 		controller.dn = null;
		controller.postcode = 'abracadabra'; 		
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
		// blank dn and postcode
		controller.dn = '';
 		controller.postcode = '';		
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
 		// blank dn and valid postcode
		controller.dn = '';
 		controller.postcode = 'AA11AZ';		
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
  		// blank dn and invalid postcode
		controller.dn = '';
 		controller.postcode = 'abracadabra';		
 		system.assertEquals(null, testRun(controller, 'getBusinessAvailability_1'));
 
  		
 		system.assertEquals(null, testRun(controller, 'getAvailableProducts'));
 		system.assertEquals(null, testRun(controller, 'getDistanceFromExchange'));
 		system.assertEquals(null, testRun(controller, 'doobedoobedoo'));
    }          
        
}