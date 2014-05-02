/*
*   This class contains web service calls for the Postal Address Services
*   This is used instead of WSDL2Apex classes as the WSDL2Apex classes
*   currently do not function with these services and the fault detail 
*   cannot be retrieved from the response
* 
*   SO'Halloran - (SFDC)
*   Revision History 
*   1.0    04/04/2011  Initial Version  
*/     
public with sharing class SOAViewPostalAddress {
    
    //private String endpoint = SOAUtils.ENDPOINT + '/services/ViewPostalAddress_1_0'; 
    private String endpoint = SOA_Integration_Settings__c.getValues('View_Postal_Address').Endpoint__c;
    private static string SOAP_ENV = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">';
    
    public String requestMessage {get {return requestMessage.replaceAll(WSSecurityUtil.getPassword(),'********');} private set;}
    
    public Dom.Document searchAddress(String organisation,String subBuildingName,String buildingName,String buildingNumber,String street,String postTown,String dependentStreet,String dependentLocality,String locality,String county,String postcode) {
        String soapMessage = '';  
        soapMessage+=SOAP_ENV;
        soapMessage+= getSoapHeader();
        soapMessage+='<soapenv:Body><view:searchAddress><view:address>';    
        
        if(organisation!=null && organisation.trim().length()>0) soapMessage+='<view:organisation>'+organisation.trim()+'</view:organisation>';
        if(subBuildingName!=null && subBuildingName.trim().length()>0) soapMessage+='<view:subBuildingName>'+subBuildingName.trim()+'</view:subBuildingName>';
        if(buildingName!=null && buildingName.trim().length()>0) soapMessage+='<view:buildingName>'+buildingName.trim()+'</view:buildingName>';
        if(buildingNumber!=null && buildingNumber.trim().length()>0) soapMessage+='<view:buildingNumber>'+buildingNumber.trim()+'</view:buildingNumber>';
        if(dependentStreet!=null && dependentStreet.trim().length()>0) soapMessage+='<view:dependentStreet>'+dependentStreet.trim()+'</view:dependentStreet>';
        if(street!=null && street.trim().length()>0) soapMessage+='<view:street>'+street.trim()+'</view:street>';       
        if(dependentLocality!=null && dependentLocality.trim().length()>0) soapMessage+='<view:dependentLocality>'+dependentLocality.trim()+'</view:dependentLocality>';    
        if(locality!=null && locality.trim().length()>0) soapMessage+='<view:locality>'+locality.trim()+'</view:locality>';
        if(postTown!=null && postTown.trim().length()>0) soapMessage+='<view:postTown>'+postTown.trim()+'</view:postTown>';
        if(county!=null && county.trim().length()>0) soapMessage+='<view:county>'+county.trim()+'</view:county>';
        if(postcode!=null && postcode.trim().length()>0) soapMessage+='<view:postcode>'+postcode.trim().toUpperCase()+'</view:postcode>';
        soapMessage+='</view:address></view:searchAddress></soapenv:Body>';
        soapMessage+='</soapenv:Envelope>';
        
        requestMessage = soapMessage;
        System.debug('soapMessage: ' + soapMessage);
        Dom.Document doc = SOAViewPostalAddress.processRequest(endpoint, soapMessage);
        if (doc != null ) {
            System.Debug('doc.toXmlString(): ' + doc.toXmlString());
            return doc;
        } else {
            return null;
        }
    }   
     
    public Dom.Document getAddressMatch(String organisation,String buildingNumber, String buildingName, String postCode) {
        String soapMessage = '';  
        soapMessage+=SOAP_ENV;
        soapMessage+= getSoapHeader();
        soapMessage+='<soapenv:Body>'; 
        soapMessage+='<view:getAddressMatch>';
        if(organisation!=null && organisation.trim().length()>0) soapMessage+='<view:organisation>'+organisation.trim()+'</view:organisation>';
        if(buildingName!=null && buildingName.trim().length()>0) soapMessage+='<view:buildingName>' + buildingName.trim() + '</view:buildingName>';
        if(buildingNumber!=null && buildingNumber.trim().length()>0) soapMessage+='<view:buildingNumber>' + buildingNumber.trim() + '</view:buildingNumber>';
        soapMessage+='<view:postcode>' + postCode.trim().toUpperCase() + '</view:postcode>';
        soapMessage+='</view:getAddressMatch>'; 
        soapMessage+='</soapenv:Body>';
        soapMessage+='</soapenv:Envelope>';
        requestMessage = soapMessage;
        System.debug('soapMessage: ' + soapMessage);
        Dom.Document doc = SOAViewPostalAddress.processRequest(endpoint, soapMessage);
        if (doc != null ) {
            System.Debug('doc.toXmlString(): ' + doc.toXmlString());
            return doc;
        } else {
            return null;
        }
    }
        
    //
    // wrap up common processing around message request
    //
    private static Dom.Document processRequest(String endpoint, String message) {
        Dom.Document doc;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setBody(message);       
        req.setTimeout(20000);
        // salesforce self certified certificate
        req.setClientCertificateName(SOAUtils.CERTIFICATE_NAME);
 
        HttpResponse res;
        if (!Test.isRunningTest()) {
            res = h.send(req);   
            doc = res.getBodyDocument();       
        } else {
            // Test version of response for Apex Unit Tests
            String stype = '';
            if(message.contains('THROW FAULT')) {
                stype = 'THROW FAULT';
            } else if(message.contains('view:searchAddress')) {
                stype = 'searchAddressResponse';
            } else if(message.contains('view:getAddressMatch')) { 
                stype = 'getAddressMatchResponse';
            }
            doc = new Dom.Document();
            if(stype=='THROW FAULT') {
                doc.load('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"> <soapenv:Header xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1"> <cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">ef9efadf-1e5c-4a17-a00e-3827192f453c</cor:SOATransactionID></soapenv:Header> <soapenv:Body xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1"> <soapenv:Fault> <faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:Server</faultcode> <faultstring>Please check the post code provided</faultstring> <detail> <view:getAddressMatchFault> <cor:SOAFaultOriginator xmlns:cor="http://soa.o2.co.uk/coredata_1">PostCode Format Validation</cor:SOAFaultOriginator> <cor:SOAFaultCode xmlns:cor="http://soa.o2.co.uk/coredata_1">viewpostaladdress-11290-4001-V</cor:SOAFaultCode> <cor:faultDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">Please check the post code provided</cor:faultDescription> <cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">ef9efadf-1e5c-4a17-a00e-3827192f453c</cor:SOATransactionID></view:getAddressMatchFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>');                
            } else {
                doc.load('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1" xmlns:addr="http://soa.o2.co.uk/pscommonpostpaydata_1">'+
                    '<soapenv:Header/>'+
                    '<soapenv:Body>'+
                    '<view:'+stype+'>'+
                    '<address><addr:street>testStreet</addr:street></address>'+
                    '</view:'+stype+'>'+
                    '</soapenv:Body>'+
                    '</soapenv:Envelope>');
            }
        }
        return doc;
    }
    
    private String getSoapHeader() {
        String soapMessage = '';    
        soapMessage+='<soapenv:Header>';
        soapMessage+='<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
        soapMessage+='<wsse:UsernameToken>';
        soapMessage+='<wsse:Username>' + WSSecurityUtil.getUserName() + '</wsse:Username>';
        soapMessage+='<wsse:Password>' + WSSecurityUtil.getPassword() + '</wsse:Password>';
        soapMessage+='</wsse:UsernameToken>';
        soapMessage+='</wsse:Security>';         
        soapMessage+='</soapenv:Header>';
        return soapMessage;
    }    
    
    static testMethod void testSOAViewPostalAddress() {
        SOAViewPostalAddress port = new SOAViewPostalAddress();
        Dom.Document doc =  port.getAddressMatch('organisation','buildingNumber', 'buildingName', 'postCode'); 
        System.assert(doc.toXmlString().contains('testStreet'));
        doc =  port.searchAddress('organisation','subBuildingName','buildingName','buildingNumber','street','postTown','dependentStreet','dependentLocality','locality','county','postcode');
        System.assert(doc.toXmlString().contains('testStreet'));    
    }       
    
        
}