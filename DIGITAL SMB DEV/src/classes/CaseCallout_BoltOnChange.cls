public with sharing class CaseCallout_BoltOnChange  implements CalloutForCaseLineItem{
	
	static final String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://soa.o2.co.uk/managebusinessboltonsdata_2" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
    static final String endpoint = SOA_Integration_Settings__c.getValues('ManageBusinessBoltons_2_0').Endpoint__c;
    
    private static final string ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final string MAN_NS = 'http://soa.o2.co.uk/managebusinessboltonsdata_2';
    private static final string PSC_NS = 'http://soa.o2.co.uk/dise/pscommondisedata_1';
    private static final string COR_NS = 'http://soa.o2.co.uk/coredata_1';
    
    public boolean addrequest{get;set;}
    public static boolean addflag = null;
    
    public SOAServicesBase soaBase = null;  
    
       
    //callout to the updateSubscriptionDetails_1 service
    public mo2b_CaseLineItem__c invokeWS(mo2b_CaseLineItem__c caseLineItemRequest)
    {
        // Pre-existing classes to interact with SOA service
        SOAServicesBase soaBase = new SOAServicesBase();
        
        String resXml = null;
       	List<String> serviceCodesToAdd = new List<String>();
       	List<String> serviceCodesToRemove = new List<String>();
       	List<String> boltsOnsToAdd = new List<String>();
       	List<String> boltsOnsToRemove = new List<String>();
        
        if(caseLineItemRequest.Service_codes_to_add__c!= null){
        	serviceCodesToAdd = caseLineItemRequest.Service_codes_to_add__c.split(',');
        }
        
        if(caseLineItemRequest.Service_codes_to_remove__c!= null){
        	serviceCodesToRemove = caseLineItemRequest.Service_codes_to_remove__c.split(',');
        }
            
        if(caseLineItemRequest.Bolt_Ons_to_add__c != null){
        	boltsOnsToAdd =  caseLineItemRequest.Bolt_Ons_to_add__c.split(',');
        }
        
        if(caseLineItemRequest.Bolt_Ons_to_remove__c != null){
        	boltsOnsToRemove =  caseLineItemRequest.Bolt_Ons_to_remove__c.split(',');
        }
        
        if (caseLineItemRequest.BoltOnCalloutStatusCode__c == null) {
        	caseLineItemRequest.BoltOnCalloutStatusCode__c = '';
        }
        
        if (caseLineItemRequest.BoltOnCalloutResponse__c == null) {
        	caseLineItemRequest.BoltOnCalloutResponse__c = '';
        }
       
		//remove boltons and services
		for(integer i=0 ; i< serviceCodesToRemove.size(); i++) {
        	System.debug('service code to be removed :' + serviceCodesToRemove.get(i));
        	System.debug('bolt ons to be removed :' + boltsOnsToRemove.get(i));
        	List<String> boltons = boltsOnsToRemove.get(i).split('_');
        	Integer price = Integer.valueof(boltons[1]);
        	System.debug('service code price is:' + price);
    		 // Generate XML request 
    		String innerXML = '';
    
    		String serviceCode ='';
    		serviceCode = serviceCodesToRemove.get(i);
    		addflag = false;
    		
	        innerXML += '<man:removeBolton>';
	        innerXML +=     '<man:subscriptionIdentifier>';  
	        innerXML +=      '<psc:subscriptionID>' + caseLineItemRequest.AC_Subscription__r.Subscription_ID__c + '</psc:subscriptionID> '; 
	        innerXML +=   	'</man:subscriptionIdentifier>';
	        innerXML +=     	'<man:serviceCode>' + serviceCodesToRemove.get(i) + '</man:serviceCode>';
	        innerXML +=     	'<man:expiryDate>' + caseLineItemRequest.SOA_Last_Amended_Date__c + '</man:expiryDate>';
	        innerXML += '</man:removeBolton>';
	        
	        
	        system.debug('+++ requestXml: ' + innerXML);
	        resXml = soaBase.sendRequest(endpoint, envelopeXML, innerXML);
	        system.debug('+++ resXml: ' + resXml);
	        
	        CaseUtils.SOAResponseDetail response = processResultXML(resXml); 
	        System.debug('**Status Code**'+response.statusCode);
	        System.debug('**externalDescription**'+response.externalDescription);
	        //caseLineItemRequest.Callout_Status_Code__c = response.statusCode;
	        //caseLineItemRequest.Callout_Response__c = response.externalDescription;
	        
	        if (response.SOAFaultCode != null) {
	        	caseLineItemRequest.Callout_Status__c = CaseUtils.FAILED;
	        }
	        
	        if (response.statusCode != null) {
	        	caseLineItemRequest.BoltOnCalloutStatusCode__c += serviceCode + '-' + response.statusCode + ';';
	        }
	        
	        if (response.externalDescription != null) {
	        	caseLineItemRequest.BoltOnCalloutResponse__c += serviceCode + '-' + response.externalDescription + ';';
	        }
	        
        }
        
        //add boltons and services
        for(integer i=0 ; i< serviceCodesToAdd.size(); i++){
        	
        	System.debug('service code to be added :' + serviceCodesToAdd.get(i));
        	System.debug('bolt ons to be added :' + boltsOnsToAdd.get(i));
        	List<String> boltons = boltsOnsToAdd.get(i).split('_');
        	Integer price = Integer.valueof(boltons[1]);
        	System.debug('service code price is:' + price);
    		
    		 // Generate XML request 
    		String innerXML = '';
    		
    		String serviceCode ='';
    		serviceCode = serviceCodesToAdd.get(i);
    		
    		addflag = true;
    
	        innerXML += '<man:addBolton_1>';
	        innerXML +=     '<man:subscriptionIdentifier>';  
	        innerXML +=      '<psc:subscriptionID>' + caseLineItemRequest.AC_Subscription__r.Subscription_ID__c + '</psc:subscriptionID> '; 
	        innerXML +=   	'</man:subscriptionIdentifier>';
	        innerXML +=     	'<man:serviceCode>' + serviceCodesToAdd.get(i) + '</man:serviceCode>';
	        innerXML +=     	'<man:activationDate>' + caseLineItemRequest.SOA_Last_Amended_Date__c + '</man:activationDate>';
	        innerXML +=     	'<man:servicePrice>' + price + '</man:servicePrice>';
	        innerXML += '</man:addBolton_1>';
	        
	        
	        system.debug('+++ requestXml: ' + innerXML);
	        resXml = soaBase.sendRequest(endpoint, envelopeXML, innerXML);
	        system.debug('+++ resXml: ' + resXml);
	        
	        CaseUtils.SOAResponseDetail response = processResultXML(resXml); 
	        System.debug('**Status Code**'+response.statusCode);
	        System.debug('**externalDescription**'+response.externalDescription);
	        //caseLineItemRequest.Callout_Status_Code__c = response.statusCode;
	        //caseLineItemRequest.Callout_Response__c = response.externalDescription;
	        
	        if (response.SOAFaultCode != null) {
	        	caseLineItemRequest.Callout_Status__c = CaseUtils.FAILED;
	        }
	        
	        if (response.statusCode != null) {
	        	caseLineItemRequest.BoltOnCalloutStatusCode__c += serviceCode + '-' + response.statusCode + ';';
	        }
	        
	        if (response.externalDescription != null) {
	        	caseLineItemRequest.BoltOnCalloutResponse__c += serviceCode + '-' + response.externalDescription + ';';
	        }
        }
           		

        
        // Add Bolt On Request Service
        
   /**     system.debug('add request is :' + caseLineItemRequest.AddRequest__c);
     	if(caseLineItemRequest.AddRequest__c != null && caseLineItemRequest.AddRequest__c ){
        addrequest = true;	
     	addflag = true;
        
        innerXML += '<man:addBolton_1>';
        innerXML +=     '<man:subscriptionIdentifier>';  
        innerXML +=      '<psc:subscriptionID>' + caseLineItemRequest.AC_Subscription__r.Subscription_ID__c + '</psc:subscriptionID> '; 
        innerXML +=   	'</man:subscriptionIdentifier>';
        innerXML +=     	'<man:serviceCode>' + caseLineItemRequest.Service_Code__c + '</man:serviceCode>';
        innerXML +=     	'<man:activationDate>' + caseLineItemRequest.SOA_Last_Amended_Date__c + '</man:activationDate>';
        innerXML +=     	'<man:servicePrice>' + caseLineItemRequest.Service_Price__c + '</man:servicePrice>';
        innerXML += '</man:addBolton_1>';
        	
        	
        }else if(!caseLineItemRequest.AddRequest__c ){
        	addrequest = false;
        	addflag = false;
      	
       	innerXML += '<man:removeBolton>';
        innerXML +=     '<man:subscriptionIdentifier>';  
        innerXML +=      '<psc:subscriptionID>' + caseLineItemRequest.AC_Subscription__r.Subscription_ID__c + '</psc:subscriptionID> '; 
        innerXML +=   	'</man:subscriptionIdentifier>';
        innerXML +=     	'<man:serviceCode>' + caseLineItemRequest.Service_Code__c + '</man:serviceCode>';
        innerXML +=     	'<man:expiryDate>' + caseLineItemRequest.SOA_Last_Amended_Date__c + '</man:expiryDate>';
        innerXML += '</man:removeBolton>';
        
        } 
         */
       

        
        
        return caseLineItemRequest;
    }
    
    private static CaseUtils.SOAResponseDetail processResultXML(string resultXML)
    {
        // XML to DOM
        Dom.Document document = new Dom.Document();
        document.load(resultXML);
        Dom.XMLNode rootNode = document.getRootElement();
        
        CaseUtils.SOAResponseDetail SOAResponse = new CaseUtils.SOAResponseDetail();
        Dom.XMLNode responseElement = null;
        
        
        // Check for soapenv Body element
        Dom.XMLNode bodyElement = rootNode.getChildElement('Body', ENV_NS);
        
        // Check for soapenv Fault element
        Dom.XMLNode faultElement = bodyElement.getChildElement('Fault', ENV_NS);
        if (faultElement != null)
        {
            
            Dom.XMLNode detailElement = faultElement.getChildElement('detail', null);
            Dom.XMLNode responseFaultElement = null;
            if(addflag){
            	
	            system.debug('*** bodyElement: ' + bodyElement);
	            system.debug('*** faultElement: ' + faultElement);
	           
	            system.debug('*** detailElement: ' + detailElement);
	            responseFaultElement = detailElement.getChildElement('addBolton_1Fault', MAN_NS);
            }
            
            else if(!addflag){
            	
            	responseFaultElement = detailElement.getChildElement('removeBoltonFault', MAN_NS);
            
            }   
	            Dom.XMLNode SOAFaultCodeElement = responseFaultElement.getChildElement('SOAFaultCode', COR_NS);
	            SOAResponse.SOAFaultCode = SOAFaultCodeElement.getText();
	            
	            Dom.XMLNode faultDescriptionElement = responseFaultElement.getChildElement('faultDescription', COR_NS);
	            SOAResponse.faultDescription = faultDescriptionElement.getText();
	            
	            Dom.XMLNode faultTraceElement = responseFaultElement.getChildElement('faultTrace', COR_NS);
	            SOAResponse.faultTrace = null;
	            if(faultTraceElement != null){
	            	 SOAResponse.faultTrace  = faultTraceElement.getText();
	            }
	            
	            SOAResponse.statusCode = SOAResponse.SOAFaultCode;
	            SOAResponse.externalDescription = SOAResponse.faultDescription;
	            return SOAResponse;
	            //throw new CaseUtils.SOAFaultException(SOAResponse.SOAFaultCode, SOAResponse.faultDescription, SOAResponse.faultTrace);
            	
            }
            
       
        
        // Check for updateSubscriptionDetails_1Response element
        if(addflag){
        	responseElement = bodyElement.getChildElement('addBolton_1Response', MAN_NS);
        	
        }else if(!addflag){
            responseElement = bodyElement.getChildElement('removeBoltonResponse', MAN_NS);
        }
        
        Dom.XMLNode resultElement = responseElement.getChildElement('result', MAN_NS);
        
        Dom.XMLNode statusCodeElement = resultElement.getChildElement('statusCode', COR_NS);
        SOAResponse.statusCode = statusCodeElement.getText();
        
        Dom.XMLNode externalDescriptionElement = resultElement.getChildElement('externalDescription', COR_NS);
        SOAResponse.externalDescription = externalDescriptionElement.getText();
        
        return SOAResponse;
    }

}