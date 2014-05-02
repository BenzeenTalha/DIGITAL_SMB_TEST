public with sharing class CaseCallout_AdminChange implements CalloutForCaseLineItem
{
	static final String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
    static final String endpoint = SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0').Endpoint__c;
    
    private static final string ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final string MAN_NS = 'http://soa.o2.co.uk/managebusinesssubscriptionsdata_1';
    private static final string PSC_NS = 'http://soa.o2.co.uk/dise/pscommondisedata_1';
    private static final string COR_NS = 'http://soa.o2.co.uk/coredata_1';
    
    public SOAServicesBase soaBase = null;  
    
       
    //callout to the updateSubscriptionDetails_1 service
    public mo2b_CaseLineItem__c invokeWS(mo2b_CaseLineItem__c caseLineItemRequest)
    {
        // Pre-existing classes to interact with SOA service
        SOAServicesBase soaBase = new SOAServicesBase();
        
        String resXml = null;
           	 // Generate XML request 
        String innerXML = '';
        
     if(caseLineItemRequest.New_Cost_Centre__c != null && caseLineItemRequest.New_Subscriber_Name__c != null){
        	
     	System.debug('Inside third Call');
        
        innerXML += '<man:updateSubscriptionDetails_1>';
        innerXML +=     '<man:subscriptionIdentifier>' + caseLineItemRequest.AC_Subscription__r.Subscription_ID__c + '</man:subscriptionIdentifier>';
        innerXML +=     '<man:customerDetails>';
        innerXML +=     	'<man:userName>' + caseLineItemRequest.New_Subscriber_Name__c + '</man:userName>';
        innerXML +=     	'<man:customerCostCentre>' + caseLineItemRequest.New_Cost_Centre__c + '</man:customerCostCentre>';
        innerXML +=     	'<man:lastAmendedDate>' + caseLineItemRequest.SOA_Last_Amended_Date__c + '</man:lastAmendedDate>';
        innerXML +=     '</man:customerDetails>';
        innerXML += '</man:updateSubscriptionDetails_1>';
        	
        	
        }else if(caseLineItemRequest.New_Cost_Centre__c == null){
      	System.debug('Inside First Call');
        	
        	 innerXML += '<man:updateSubscriptionDetails_1>';
        innerXML +=     '<man:subscriptionIdentifier>' + caseLineItemRequest.AC_Subscription__r.Subscription_ID__c + '</man:subscriptionIdentifier>';
        innerXML +=     '<man:customerDetails>';
        innerXML +=     	'<man:userName>' + caseLineItemRequest.New_Subscriber_Name__c + '</man:userName>';
        innerXML +=     	'<man:lastAmendedDate>' + caseLineItemRequest.SOA_Last_Amended_Date__c + '</man:lastAmendedDate>';
        innerXML +=     '</man:customerDetails>';
        innerXML += '</man:updateSubscriptionDetails_1>';
        
        } else if(caseLineItemRequest.New_Subscriber_Name__c == null){
        	System.debug('Inside Second Call');
        	
        innerXML += '<man:updateSubscriptionDetails_1>';
        innerXML +=     '<man:subscriptionIdentifier>' + caseLineItemRequest.AC_Subscription__r.Subscription_ID__c + '</man:subscriptionIdentifier>';
        innerXML +=     '<man:customerDetails>';
        innerXML +=     	'<man:customerCostCentre>' + caseLineItemRequest.New_Cost_Centre__c + '</man:customerCostCentre>';
        innerXML +=     	'<man:lastAmendedDate>' + caseLineItemRequest.SOA_Last_Amended_Date__c + '</man:lastAmendedDate>';
        innerXML +=     '</man:customerDetails>';
        innerXML += '</man:updateSubscriptionDetails_1>';
        	
        }
        
       

         system.debug('+++ requestXml: ' + innerXML);
        resXml = soaBase.sendRequest(endpoint, envelopeXML, innerXML);
        system.debug('+++ resXml: ' + resXml);
        
        CaseUtils.SOAResponseDetail response = processResultXML(resXml); 
        System.debug('**Status Code**'+response.statusCode);
        System.debug('**externalDescription**'+response.externalDescription);
        caseLineItemRequest.Callout_Status_Code__c = response.statusCode;
        caseLineItemRequest.Callout_Response__c = response.externalDescription;
        
        return caseLineItemRequest;
    }
    
    private static CaseUtils.SOAResponseDetail processResultXML(string resultXML)
    {
        // XML to DOM
        Dom.Document document = new Dom.Document();
        document.load(resultXML);
        Dom.XMLNode rootNode = document.getRootElement();
        
        CaseUtils.SOAResponseDetail SOAResponse = new CaseUtils.SOAResponseDetail();
        
        
        // Check for soapenv Body element
        Dom.XMLNode bodyElement = rootNode.getChildElement('Body', ENV_NS);
        
        // Check for soapenv Fault element
        Dom.XMLNode faultElement = bodyElement.getChildElement('Fault', ENV_NS);
        if (faultElement != null)
        {
            system.debug('*** bodyElement: ' + bodyElement);
            system.debug('*** faultElement: ' + faultElement);
            Dom.XMLNode detailElement = faultElement.getChildElement('detail', null);
            system.debug('*** detailElement: ' + detailElement);
            Dom.XMLNode responseFaultElement = detailElement.getChildElement('updateSubscriptionDetails_1Fault', MAN_NS);
            
            Dom.XMLNode SOAFaultCodeElement = responseFaultElement.getChildElement('SOAFaultCode', COR_NS);
            SOAResponse.SOAFaultCode = SOAFaultCodeElement.getText();
            
            Dom.XMLNode faultDescriptionElement = responseFaultElement.getChildElement('faultDescription', COR_NS);
            SOAResponse.faultDescription = faultDescriptionElement.getText();
            
            Dom.XMLNode faultTraceElement = responseFaultElement.getChildElement('faultTrace', COR_NS);
            SOAResponse.faultTrace = faultTraceElement.getText();
            
            throw new CaseUtils.SOAFaultException(SOAResponse.SOAFaultCode, SOAResponse.faultDescription, SOAResponse.faultTrace);
        }
        
        // Check for updateSubscriptionDetails_1Response element
        Dom.XMLNode responseElement = bodyElement.getChildElement('updateSubscriptionDetails_1Response', MAN_NS);
        Dom.XMLNode resultElement = responseElement.getChildElement('result', MAN_NS);
        
        Dom.XMLNode statusCodeElement = resultElement.getChildElement('statusCode', COR_NS);
        SOAResponse.statusCode = statusCodeElement.getText();
        
        Dom.XMLNode externalDescriptionElement = resultElement.getChildElement('externalDescription', COR_NS);
        SOAResponse.externalDescription = externalDescriptionElement.getText();
        
        return SOAResponse;
    }
}