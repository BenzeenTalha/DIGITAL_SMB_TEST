public with sharing class CaseCallout_SIMSwap implements CalloutForCaseLineItem
{
    static final String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
    static final String endpoint = SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0').Endpoint__c;
    
    private static final string ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final string MAN_NS = 'http://soa.o2.co.uk/managebusinesssubscriptionsdata_1';
    private static final string PSC_NS = 'http://soa.o2.co.uk/dise/pscommondisedata_1';
    private static final string COR_NS = 'http://soa.o2.co.uk/coredata_1';
    
    public SOAServicesBase soaBase = null;  
    
       
    //callout to the updateSubscriptionSerialNumbers_1 service
    public mo2b_CaseLineItem__c invokeWS(mo2b_CaseLineItem__c caseLineItemRequest)
    {
        // Pre-existing classes to interact with SOA service
        SOAServicesBase soaBase = new SOAServicesBase();
        
        Boolean nonNetworkChangeStatus = false;
        String resXml = null;
        
        // Generate XML request 
        String innerXML = '';
        
        innerXML += '<man:updateSubscriptionSerialNumbers_1>';
        innerXML +=     '<man:subscriptionIdentifier>' + caseLineItemRequest.AC_Subscription__r.Subscription_ID__c + '</man:subscriptionIdentifier>';
        innerXML +=     '<man:managedSerialNumbers>';
        innerXML +=         '<man:managedSerialNumber>';
        innerXML +=             '<man:networkSerialNumberID>2</man:networkSerialNumberID>';
        innerXML +=             '<man:networkSerialNumber>' + caseLineItemRequest.New_SIM_Number__c + '</man:networkSerialNumber>';
        innerXML +=         '</man:managedSerialNumber>';
        innerXML +=     '</man:managedSerialNumbers>';
        innerXML +=     '<man:nonNetworkChangeStatus>' + (nonNetworkChangeStatus ? 'true' : 'false') + '</man:nonNetworkChangeStatus>';
        innerXML += '</man:updateSubscriptionSerialNumbers_1>';

        
        system.debug('SIM request xml is :' + innerXML);
        resXml = soaBase.sendRequest(endpoint, envelopeXML, innerXML);
        system.debug('+++ resXml: ' + resXml);
        
        CaseUtils.SOAResponseDetail response = processResultXML(resXml); 
        
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
            Dom.XMLNode detailElement = faultElement.getChildElement('detail', null);
            Dom.XMLNode responseFaultElement = detailElement.getChildElement('updateSubscriptionSerialNumbers_1Fault', MAN_NS);
            
            Dom.XMLNode SOAFaultCodeElement = responseFaultElement.getChildElement('SOAFaultCode', COR_NS);
            SOAResponse.SOAFaultCode = SOAFaultCodeElement.getText();
            
            Dom.XMLNode faultDescriptionElement = responseFaultElement.getChildElement('faultDescription', COR_NS);
            SOAResponse.faultDescription = faultDescriptionElement.getText();
            
            Dom.XMLNode faultTraceElement = responseFaultElement.getChildElement('faultTrace', COR_NS);
            SOAResponse.faultTrace = faultTraceElement.getText();
            
            throw new CaseUtils.SOAFaultException(SOAResponse.SOAFaultCode, SOAResponse.faultDescription, SOAResponse.faultTrace);
        }
        
        // Check for updateSubscriptionSerialNumbers_1Response element
        Dom.XMLNode responseElement = bodyElement.getChildElement('updateSubscriptionSerialNumbers_1Response', MAN_NS);
        Dom.XMLNode resultElement = responseElement.getChildElement('result', MAN_NS);
        
        Dom.XMLNode statusCodeElement = resultElement.getChildElement('statusCode', COR_NS);
        SOAResponse.statusCode = statusCodeElement.getText();
        
        Dom.XMLNode externalDescriptionElement = resultElement.getChildElement('externalDescription', COR_NS);
        SOAResponse.externalDescription = externalDescriptionElement.getText();
        
        return SOAResponse;
    }
    
}