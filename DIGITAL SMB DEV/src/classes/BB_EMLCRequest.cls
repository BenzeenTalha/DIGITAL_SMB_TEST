public with sharing class BB_EMLCRequest {
    
    private final static string endpoint = SOA_Integration_Settings__c.getValues('SentryGatewayMLCv2_v14Soap').Endpoint__c;         
    private final static String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:open="http://www.openuri.org/" xmlns:gen="http://www.bt.com/eai/hub/or/GenericCPWSHubService" xmlns:urnX="urn:com.openreach.LineCharacteristics2v15-0" xmlns:urn1="urn:com.openreach.LineCharacteristics2v16-0" xmlns:urn2="urn:com.openreach.LineCharacteristics2v17-0" xmlns:urn3="urn:com.openreach.LineCharacteristics2v18-0" xmlns:urn4="urn:com.openreach.LineCharacteristics2v19-0" xmlns:urn="urn:com.openreach.LineCharacteristics2v20-0">';
    
    private String innerBodyXML = '';
    private String requestXML = '';
    
    private String requiredServiceType = 'All';
    private String dn = '';
    private String postcode = '';
        
    public Dom.Document sendRequest(String dn, String postcode){
        if(dn==Null && postcode==Null){
            return Null;
        }
        Dom.Document doc;
        // Set DirectoryNumber and PostCode
        this.dn = dn;
        this.postcode = postcode;
        // Concatenate Envelope, Header and Body of XML
        innerBodyXML = getBodyXMLManageLineCharacteristics();
        requestXML = envelopeXML;     
        requestXML += getHeaderXML(); 
        requestXML += '<soapenv:Body>';
        requestXML += innerBodyXML;
        requestXML += '</soapenv:Body>';
        requestXML += '</soapenv:Envelope>';                        
        // Send XML Request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setBody(requestXML);       
        req.setTimeout(SOAUtils.SOA_TIMEOUT);
        req.setClientCertificateName(SOAUtils.CERTIFICATE_NAME);        
        HttpResponse res;
        system.debug('**** Broadband EMLC XML Request ****'+req.getBody());
        res = h.send(req);
        system.debug('**** Http Response Status Code ****'+res.getStatusCode());
        system.debug('**** Broadband EMLC XML Response ****'+res.getBody());
        if(res == null){     
            return null;
        } 
        else{
            doc = res.getBodyDocument();
        }
        return doc;
    }
    
    private Static String getHeaderXML(){
        String header = '';
        if(!Test.isRunningTest()){
            header =          
            '  <soapenv:Header>' +
            '    <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">' +
            '      <wsse:UsernameToken>' +
            '        <wsse:Username>' + WSSecurityUtil.getUserName(endpoint) + '</wsse:Username>' +
            '        <wsse:Password>' + WSSecurityUtil.getPassword(endpoint) + '</wsse:Password>' +
            '      </wsse:UsernameToken>' +
            '    </wsse:Security>' +    
            '   <cor:SOAConsumerTransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">'+'SFDC-' + System.now().format('yyyyMMddHHmmssSSSZ') + ':' + UserInfo.getOrganizationId() + '-' + UserInfo.getUserId()+ '-' + UserInfo.getUserName() + '</cor:SOAConsumerTransactionID>' +    
            '    <cor:debugFlag xmlns:cor="http://soa.o2.co.uk/coredata_1">true</cor:debugFlag>' +
            '  </soapenv:Header>';
        }
        return header;   
    }
                                                                      
    private String getBodyXMLManageLineCharacteristics(){
        String urnNS = 'urn:com.openreach.LineCharacteristics2v20-0';
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement('open', 'DS_ManageLineCharacteristicsV2Request', 'http://www.openuri.org/');
        
        w.writeStartElement('gen', 'GenericCPWSHubService', 'http://www.bt.com/eai/hub/or/GenericCPWSHubService');
        w.writeStartElement('urn', 'AddLineCharacteristicsRequest2', urnNS);
        w.writeStartElement('urn', 'Query', urnNS);
        
        writeElement(w, 'urn', 'RequestersID', '50019999');
        writeElement(w, 'urn', 'IssueDateTime', Datetime.now().format('yyyy-MM-dd')+'T'+Datetime.now().format('hh:mm:ss'));
        
        w.writeStartElement('urn', 'RequesterParty', urnNS);
        w.writeStartElement('urn', 'Party', urnNS);
        w.writeStartElement('urn', 'PartyIdentification', urnNS);
        w.writeStartElement('urn', 'ID', urnNS);
        w.writeAttribute(null, null, 'identificationSchemeName', 'DUNS');
        w.writeCharacters('718803096');        
        w.writeEndElement();  
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();
        
        w.writeStartElement('urn', 'ResponderParty', urnNS);
        w.writeStartElement('urn', 'Party', urnNS);
        w.writeStartElement('urn', 'PartyIdentification', urnNS);
        w.writeStartElement('urn', 'ID', urnNS);
        w.writeAttribute(null, null, 'identificationSchemeName', 'DUNS');
        w.writeCharacters('364877501');        
        w.writeEndElement();  
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();        
        
        w.writeStartElement('urn', 'QueryLine', urnNS);
        w.writeStartElement('urn', 'QueryLineItem', urnNS);
        writeElement(w, 'urn', 'RequestersID', '1');
        w.writeStartElement('urn', 'Features', urnNS);
        w.writeStartElement('urn', 'LineCharacteristicsFeatureSet', urnNS);
        w.writeStartElement('urn', 'InputFeatures', urnNS);
        writeElement(w, 'urn', 'RequiredServiceType', requiredServiceType);
        writeElement(w, 'urn', 'InstallationDN', dn);
        writeElement(w, 'urn', 'PostCode', postcode);
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();  
        w.writeEndDocument(); 
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;    
    }
    
    private void writeElement(XmlStreamWriter w, String ns, String elName, String elValue){
        if(elValue!='' && elValue!=null){
            w.writeStartElement(ns, elName, '');
            w.writeCharacters(elValue);
            w.writeEndElement();    
        }
    }

}