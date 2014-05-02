/*
//Typical usage:-

//[1]

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
handler.populateSubscriberProfile( '447738642924');

//[2]

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
String organisation;
String buildingName;
String buildingNumber;
String postcode;
organisation = '';
buildingName = '';
buildingNumber = '*';
postcode = 'SL9 8RG';             
handler.populateAddresses(organisation, buildingName, buildingNumber, postcode);

// [3]

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
String organisation;
String buildingName;
String buildingNumber;
String postcode;
organisation = '';
buildingName = '';
buildingNumber = '*';
postcode = 'SL9 8RG';             
buildingNumber = '13';
String street = 'south view road';
String postTown = 'gerrards cross';   
String subBuildingName;
String dependentStreet;
String dependentLocality;
String locality;
String county;
handler.populateAddresses(organisation,subBuildingName, buildingName, buildingNumber, street, postTown, dependentStreet, dependentLocality, locality, county, postcode);

// [4]

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
handler.populateAccountBasicAndAddress('2023655');

// [5]

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
handler.populateSubscriptionBasic('10466243', '', '');
handler.populateSubscriptionBasic('', '', '7808647981');

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
handler.populateSubscriptionBasic('', '', '07740406701');

// [6]

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
FemtocellSOAHandler.Address addr=new FemtocellSOAHandler.Address();
addr.buildingName='Towner two';
addr.buildingNumber='438';
addr.street='26 Street';
addr.subBuildingName='Mains';
addr.postTown='Hinkley';
addr.postcode='SL1 1XL';
addr.county='YorkShire';
String orderRef='12347';
String cellType='1';
String operationalMode='O';
String userName='MAGNET';
handler.provisionRadioParameters_1(orderRef,cellType,operationalMode,userName,addr);
system.debug('***CellSiteRef'+handler.getMNDCellSiteReferenceNumber());

// [7]

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
String cellSiteReferenceNumber='997821';
String orderReferenceNumber='';
String buildingDetails='';
String postCode='SL1 1XL';
Datetime stDate=datetime.newInstance(2012, 5, 23, 12, 0, 0);
Datetime enDate=datetime.newInstance(2014, 5, 23, 12, 0, 0);
handler.getRadioProvisioningParameters_1(cellSiteReferenceNumber,orderReferenceNumber, 
        buildingDetails, postCode, stDate, enDate);
System.debug('***radio prov parms: '+handler.radioProvisioningParmameters.getText());

// [8]

FemtocellSOAHandler handler =  new FemtocellSOAHandler();
String msisdn='447802209408';
String imsi='234109920000004';
String imei='3570660053160004';
String brand='Nokia';
String model='6230i';
String displayBrand='Nokia';
String displayModel='6230i';
List<FemtocellSOAHandler.MapItem> mapItems = new List<FemtocellSOAHandler.MapItem>();
mapItems.add(new FemtocellSOAHandler.MapItem('hardware_gprs',123));
handler.getDeviceProfile(msisdn, imsi, imei, brand, model, displayBrand, displayModel, mapItems);
System.debug('***device profile: '+handler.deviceProfile.getText());

*/


@isTest(SeeAllData=true) // Clause required for API version 24.0 and greater, to allow test methods access to custom settings and other org data that happens to be referenced by pre-existing classes in their construction / instantiation.
public with sharing class FemtocellSOAHandler {
    
    private static final String ENVELOPE_XML_SUBS = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">';
    private static final String ENVELOPE_XML_DISE = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1" xmlns:view="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1">';
    private static final String ENVELOPE_XML_MND = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xcore="http://soa.o2.co.uk/coredata_1" xmlns:mnd="http://soa.o2.co.uk/managenetworkprovisioningdata_2">';
    private static final String ENVELOPE_XML_MANDEV = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://soa.o2.co.uk/managedevicedata_1"'+
            ' xmlns:psc="http://soa.o2.co.uk/pscommondevicedata_1"'+
            ' xmlns:cor="http://soa.o2.co.uk/coredata_1">';
    
    private static final string BODY_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final string SUBS_NS = 'http://soa.o2.co.uk/subscriberdata_2';  
    private static final string VPAD_NS = 'http://soa.o2.co.uk/viewpostaladdressdata_1'; 
    private static final string PSC_NS = 'http://soa.o2.co.uk/pscommonpostpaydata_1';
    private static final string COR_NS = 'http://soa.o2.co.uk/coredata_1';
    private static final string MAN_NS = 'http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1';  
    private static final string MND_NS = 'http://soa.o2.co.uk/managenetworkprovisioningdata_2';
    private static final string MAN_DEV_NS = 'http://soa.o2.co.uk/managedevicedata_1';
    private static final string MANDEV_PSC_NS = 'http://soa.o2.co.uk/pscommondevicedata_1';
        
    private static final String TEST_GOOD_SUBSCRIBER_ID = '447738642924';  

    public Boolean testFault { get; set; }      
    private Integer testCounter=0;
    
    // Pre-existing classes to interact with DISE
    private SOAServicesBase soaBase = null; 
    private SOAViewPostalAddress soaAddress = null;
    
    // DISE Data representations defined in this class as inner classes
    private SubscriberProfile subscriberProfile = null;
    private AddressList addressList = null;
    private AccountBasicAndAddress accountBasicAndAddress = null;
    private SubscriptionBasic subscriptionBasic = null;
    private ProvisionRadioParameters provisionRadioParameters = null;
    public RadioProvisioningParmameters radioProvisioningParmameters = null;
    public DeviceProfile deviceProfile = null;
    
    // Custom exceptions that can be thrown by this class
    public class RequiredDataException extends Exception {}
    public class ResponseException extends Exception {}
    
    
    /*
    <?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
    <soapenv:Header xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">
    <cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">41d84f9e-35d8-4633-9aa3-522449ef5f04</cor:SOATransactionID></soapenv:Header>
    <env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
    <env:Fault>
    <faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:Server</faultcode>
    <faultstring>Invalid MSISDN</faultstring>
    <detail>
    <ns1:getSubscriberProfileFault xmlns:ns1="http://soa.o2.co.uk/subscriberdata_2" xmlns:xcore="http://soa.o2.co.uk/coredata_1">
    <xcore:SOAFaultOriginator>Route To Spa.getServiceProviderCategoriesForGetSubscriberProfile</xcore:SOAFaultOriginator>
    <xcore:SOAFaultCode>subscriber-11200-4001-V</xcore:SOAFaultCode>
    <xcore:faultDescription>Invalid MSISDN</xcore:faultDescription>
    <xcore:SOATransactionID>41d84f9e-35d8-4633-9aa3-522449ef5f04</xcore:SOATransactionID></ns1:getSubscriberProfileFault></detail></env:Fault></env:Body></soapenv:Envelope>        
    */

    public FemtocellSOAHandler() {
        testFault=false;
    }

    // Error data returned by DISE / SOA
    public class SOAFault {
        
        public String faultcode{ get; set; }
        public String faultstring { get; set; }     
        public String info { get; set; }        
        public Boolean detected { get; set; }       
        
        public SOAFault(Dom.XMLNode bodyElem) {
            Dom.XMLNode faultElem = bodyElem.getChildElement('Fault', BODY_NS );
            if (faultElem == null) {
                faultcode = null;
                faultstring = null;
                detected = false;
                info = '';
            } else {
                faultcode = getElemText(faultElem, null, 'faultcode');
                faultstring = getElemText(faultElem, null, 'faultstring');
                info = stri(faultstring) + ' (' + faultcode + ')';
                detected = true;
            }
        }
        
                
    }
    
    static testMethod void testSOAFault() {
        String xml = '<bod>test</bod>';
        Dom.XMLNode bodyElem1 = getBodyElem(xml);
        System.assert(bodyElem1 == null);
        xml = '<Data><env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">test</env:Body></Data>';
        bodyElem1 = getBodyElem(xml);
        System.assert(bodyElem1 != null);
        SOAFault sf1 =  new SOAFault(bodyElem1);
        System.assert(sf1.faultcode == null);
        System.assert(sf1.faultstring == null);
        System.assert(sf1.detected == false);
        FemtocellSOAHandler pfh = new FemtocellSOAHandler();
        pfh.testFault = true;
        xml = pfh.getSubscriberTestXml();
        Dom.XMLNode bodyElem2 = getBodyElem(xml);
        SOAFault sf2 =  new SOAFault(bodyElem2);
        System.assert(sf2.faultcode != null);
        System.assert(sf2.faultstring != null);
        System.assert(sf2.detected == true);
        System.assert(sf2.info.equalsIgnoreCase(sf2.faultstring + ' ('+sf2.faultcode+')'));
    }
    
    
    public class SubscriberProfile {
        
        /*
        <?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
        <soapenv:Header xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">
        <cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">cd01db54-3303-43a9-9838-1ff1b9a6373f</cor:SOATransactionID></soapenv:Header>
        <env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
        <sub:getSubscriberProfileResponse xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">
        <sub:subscriberProfile>
        <sub:subscriberID>441613665103</sub:subscriberID>
        <sub:operator>nonO2</sub:operator>
        <sub:paymentCategory>Unknown</sub:paymentCategory>
        <sub:segment>Consumer</sub:segment>
        <sub:channel>Offline</sub:channel>
        <sub:status /></sub:subscriberProfile></sub:getSubscriberProfileResponse></env:Body></soapenv:Envelope> 
        */      
        
        public String subscriberID{ get; set; }
        public String operator { get; set; }
        public String paymentCategory { get; set; }
        public String segment { get; set; }
        public String channel { get; set; }
        public String status { get; set; }
        public SOAFault fault = null;
        
        public SubscriberProfile(String xml) {
            if (isEmpty(xml)) throw new RequiredDataException('xml is required!');          
            Dom.XMLNode subscriberProfileElem = getMainDataElem(xml);                       
            subscriberID = getElemText(subscriberProfileElem, SUBS_NS, 'subscriberID');
            operator = getElemText(subscriberProfileElem, SUBS_NS, 'operator');
            paymentCategory = getElemText(subscriberProfileElem, SUBS_NS, 'paymentCategory');
            segment = getElemText(subscriberProfileElem, SUBS_NS, 'segment');
            channel = getElemText(subscriberProfileElem, SUBS_NS, 'channel');
            status = getElemText(subscriberProfileElem, SUBS_NS, 'status');
        }
        
        private Dom.XMLNode getMainDataElem(String xml) {
            Dom.XMLNode bodyElem = getBodyElem(xml);
            if (bodyElem == null) throw new ResponseException('Failed to process response. Empty bodyElem!');               
            fault = new SOAFault(bodyElem); 
            if (fault.detected) throw new ResponseException('Fault: '+ fault.info);        
            Dom.XMLNode getSubscriberProfileResponseElem = bodyElem.getChildElement('getSubscriberProfileResponse', SUBS_NS);           
            if (getSubscriberProfileResponseElem == null) throw new ResponseException('Failed to process response. Empty getSubscriberProfileResponseElem!');
            Dom.XMLNode subscriberProfileElem = getSubscriberProfileResponseElem.getChildElement('subscriberProfile', SUBS_NS);
            if (subscriberProfileElem == null) throw new ResponseException('Failed to process response. Empty subscriberProfileElem!');
            return subscriberProfileElem;
        }        
        
        public String getText() {
            return 'SubscriberProfile:subscriberID=' + subscriberID + ':' +
                        'operator=' + operator + ':' +
                        'paymentCategory=' + paymentCategory + ':' +
                        'segment=' + segment + ':' +
                        'channel=' + channel + ':' +
                        'status=' + status;
            
        }
                
    }   

    public class RadioProvisioningParmameters {
        public String orderReferenceNumber { get; set; }
        public String userName { get; set; }
        public String buildingDetails { get; set; }
        public String postCode { get; set; }
        public String cellSiteReferenceNumber { get; set; }
        public String entryDate { get; set; }
        public String locationAreaCode { get; set; }
        public String regionAreaCode { get; set; }
        public String serviceAreaCode { get; set; }
        public String easting { get; set; }
        public String northing { get; set; }
        public String operationMode { get; set; }
        public String femtoRegion { get; set; }
        public String requestEntryDate { get; set; }
        public String userLogged { get; set; }
        
        public String statusCode { get; set; }
        public String externalDescription { get; set; }
        public SOAFault fault = null;

        public RadioProvisioningParmameters(String xml) {

          /*<mnd:getRadioProvisioningParameters_1Response xsi:schemaLocation="http://soa.o2.co.uk/managenetworkprovisioningdata_2 managenetworkprovisioningdata_2_0.xsd" xmlns:xcore="http://soa.o2.co.uk/coredata_1" xmlns:mnd="http://soa.o2.co.uk/managenetworkprovisioningdata_2">
             <mnd:radioProvisionList>
                <mnd:orderReferenceNumber>3765</mnd:orderReferenceNumber>
                <mnd:userName>MAGNET</mnd:userName>
                <mnd:buildingDetails>3024</mnd:buildingDetails>
                <mnd:postCode>IG2 7ZS</mnd:postCode>
                <mnd:cellSiteReferenceNumber>252</mnd:cellSiteReferenceNumber>
                <mnd:entryDate>2001-12-31T12:00:00</mnd:entryDate>
                <mnd:locationAreaCode>9911</mnd:locationAreaCode>
                <mnd:regionAreaCode>1</mnd:regionAreaCode>
                <mnd:serviceAreaCode>11106</mnd:serviceAreaCode>
                <mnd:easting>23423</mnd:easting>
                <mnd:northing>23424</mnd:northing>
                <mnd:operationMode>O</mnd:operationMode>
                <mnd:femtoRegion>1</mnd:femtoRegion>
                <mnd:requestEntryDate>2001-12-31T12:00:00</mnd:requestEntryDate>
                <mnd:userLogged>STHOMAS2</mnd:userLogged>
             </mnd:radioProvisionList>
             <mnd:result>
                <xcore:statusCode>managenetworkprovisioning-10033-0001-S</xcore:statusCode>
                <xcore:externalDescription>Records obtained successfully</xcore:externalDescription>
             </mnd:result>
          </mnd:getRadioProvisioningParameters_1Response>*/
      
            if (isEmpty(xml)) throw new RequiredDataException('xml is required!');          
            Dom.XMLNode getRadioProvisioningParametersElem = getMainDataElem(xml);                       
            Dom.XMLNode radioProvisionListElem = getRadioProvisioningParametersElem.getChildElement('radioProvisionList', MND_NS);
            orderReferenceNumber = getElemText(radioProvisionListElem, MND_NS, 'orderReferenceNumber');
            userName = getElemText(radioProvisionListElem, MND_NS, 'userName');
            buildingDetails = getElemText(radioProvisionListElem, MND_NS, 'buildingDetails');
            postCode = getElemText(radioProvisionListElem, MND_NS, 'postCode');
            cellSiteReferenceNumber = getElemText(radioProvisionListElem, MND_NS, 'cellSiteReferenceNumber');
            entryDate = getElemText(radioProvisionListElem, MND_NS, 'entryDate');
            locationAreaCode = getElemText(radioProvisionListElem, MND_NS, 'locationAreaCode');
            regionAreaCode = getElemText(radioProvisionListElem, MND_NS, 'regionAreaCode');
            serviceAreaCode = getElemText(radioProvisionListElem, MND_NS, 'serviceAreaCode');
            easting = getElemText(radioProvisionListElem, MND_NS, 'easting');
            northing = getElemText(radioProvisionListElem, MND_NS, 'northing');
            operationMode = getElemText(radioProvisionListElem, MND_NS, 'operationMode');
            femtoRegion = getElemText(radioProvisionListElem, MND_NS, 'femtoRegion');
            requestEntryDate = getElemText(radioProvisionListElem, MND_NS, 'requestEntryDate');
            userLogged = getElemText(radioProvisionListElem, MND_NS, 'userLogged');
            
            //standard result info
            Dom.XMLNode resultElem = getRadioProvisioningParametersElem.getChildElement('result', MND_NS);
            statusCode = getElemText(resultElem, COR_NS, 'statusCode');
            externalDescription = getElemText(resultElem, COR_NS, 'externalDescription');
        }
        
        private Dom.XMLNode getMainDataElem(String xml) {
            Dom.XMLNode bodyElem = getBodyElem(xml);
            if (bodyElem == null) throw new ResponseException('Failed to process response. Empty bodyElem!');               
            fault = new SOAFault(bodyElem); 
            if (fault.detected) throw new ResponseException('Fault: '+ fault.info);        
            Dom.XMLNode getRadioProvisioningParameters_1ResponseElem = bodyElem.getChildElement('getRadioProvisioningParameters_1Response', MND_NS);           
            if (getRadioProvisioningParameters_1ResponseElem == null) throw new ResponseException('Failed to process response. Empty getRadioProvisioningParameters_1Response!');
            return getRadioProvisioningParameters_1ResponseElem;
        }
        
        public String getText() {
            return 'RadioProvisioningParmameters: orderReferenceNumber=' + orderReferenceNumber + ':' +
                        'userName=' + userName + ':' +
                        'buildingDetails=' + buildingDetails + ':' +
                        'postCode=' + postCode + ':' +
                        'cellSiteReferenceNumber=' + cellSiteReferenceNumber + ':' +
                        'entryDate=' + entryDate + ':' +
                        'locationAreaCode=' + locationAreaCode + ':' +
                        'regionAreaCode=' + regionAreaCode + ':' +
                        'serviceAreaCode=' + serviceAreaCode + ':' +
                        'easting=' + easting + ':' +
                        'northing=' + northing + ':' +
                        'operationMode=' + operationMode + ':' +
                        'femtoRegion=' + femtoRegion + ':' +
                        'requestEntryDate=' + requestEntryDate + ':' +
                        'userLogged=' + userLogged + ':' +
                        'statusCode=' + statusCode+ ':' +
                        'externalDescription=' + externalDescription;
        }       
    }

    public class DeviceProfile {
        public String msisdn { get; set; }
        public String imsi { get; set; }
        public String imei { get; set; }
        public String brand { get; set; }
        public String model { get; set; }
        public String displayBrand { get; set; }
        public String displayModel { get; set; }
        public List<MapItem> mapItemList { get; set; }
        public SOAFault fault = null;

        public DeviceProfile(String xml) {
            if (isEmpty(xml)) throw new RequiredDataException('xml is required!');          
            Dom.XMLNode getDeviceProfileElem = getMainDataElem(xml);                       
            Dom.XMLNode deviceProfileElem = getDeviceProfileElem.getChildElement('deviceProfile', MAN_DEV_NS);
            msisdn = getElemText(deviceProfileElem, MANDEV_PSC_NS, 'msisdn');
            imsi = getElemText(deviceProfileElem, MANDEV_PSC_NS, 'imsi');
            imei = getElemText(deviceProfileElem, MANDEV_PSC_NS, 'imei');
            brand = getElemText(deviceProfileElem, MANDEV_PSC_NS, 'brand');
            model = getElemText(deviceProfileElem, MANDEV_PSC_NS, 'model');
            displayBrand = getElemText(deviceProfileElem, MANDEV_PSC_NS, 'displayBrand');
            displayModel = getElemText(deviceProfileElem, MANDEV_PSC_NS, 'displayModel');
            
            //Retrieve mapItems into list
            Dom.XMLNode deviceAttributesElem = deviceProfileElem.getChildElement('deviceAttributes', MANDEV_PSC_NS);
            mapItemList = new List<MapItem>();
            for(Dom.XMLNode elem : deviceAttributesElem.getChildElements()) {
                MapItem mapItem=new MapItem();
                String key = getElemText(elem, COR_NS, 'key');
                
                // Get correct value by type
                String intValueStr=getElemText(elem, COR_NS, 'intValue');
                if(intValueStr!=null && intValueStr!='') {
                    Integer intValue=Integer.valueOf(intValueStr);
                    mapItem=new MapItem(key, intValue);
                }
                String strValue=getElemText(elem, COR_NS, 'strValue');
                if(strValue!=null && strValue!='') {
                    mapItem=new MapItem(key, strValue);
                }
                String boolValueStr=getElemText(elem, COR_NS, 'boolValue');
                if(boolValueStr!=null && boolValueStr!='') {
                    boolean boolValue=Boolean.valueOf(boolValueStr);
                    mapItem=new MapItem(key, boolValue);
                }
                mapItemList.add(mapItem);
            }
        }
        
        private Dom.XMLNode getMainDataElem(String xml) {
            Dom.XMLNode bodyElem = getBodyElem(xml);
            if (bodyElem == null) throw new ResponseException('Failed to process response. Empty bodyElem!');               
            fault = new SOAFault(bodyElem); 
            if (fault.detected) throw new ResponseException('Fault: '+ fault.info);        
            Dom.XMLNode getDeviceProfileResponseElem = bodyElem.getChildElement('getDeviceProfileResponse', MAN_DEV_NS);           
            if (getDeviceProfileResponseElem == null) throw new ResponseException('Failed to process response. Empty getDeviceProfileResponse!');
            return getDeviceProfileResponseElem;
        }
        
        public String getText() {
            return 'DeviceProfile:msisdn=' + msisdn + ':' +
                        'imsi=' + imsi + ':' +
                        'imei=' + imei + ':' +
                        'brand=' + brand + ':' +
                        'model=' + model + ':' +
                        'displayBrand=' + displayBrand + ':' +
                        'displayModel=' + displayModel + ':' +
                        'mapItems=' + mapItemList;
        }
    }
    public class ProvisionRadioParameters {

        /*<man:provisionRadioParameters_1Response xmlns:man="http://soa.o2.co.uk/managenetworkprovisioningdata_2">
           <man:cellSiteReferenceNumber>997549</man:cellSiteReferenceNumber>
           <man:result>
            <cor:statusCode xmlns:cor="http://soa.o2.co.uk/coredata_1">managenetworkprovisioning-10033-0001-S</cor:statusCode>
            <cor:externalDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">Radio record provisioning successful.</cor:externalDescription>
           </man:result>
        </man:provisionRadioParameters_1Response> */
        
        public String cellSiteReferenceNumber { get; set; }
        public String statusCode { get; set; }
        public String externalDescription { get; set; }
        public SOAFault fault = null;

        public ProvisionRadioParameters(String xml) {
            if (isEmpty(xml)) throw new RequiredDataException('xml is required!');          
            Dom.XMLNode provisionRadioParametersElem = getMainDataElem(xml);                       
            cellSiteReferenceNumber = getElemText(provisionRadioParametersElem, MND_NS, 'cellSiteReferenceNumber');
            Dom.XMLNode resultElem = provisionRadioParametersElem.getChildElement('result', MND_NS);
            statusCode = getElemText(resultElem, COR_NS, 'statusCode');
            externalDescription = getElemText(resultElem, COR_NS, 'externalDescription');
        }
        
        private Dom.XMLNode getMainDataElem(String xml) {
            Dom.XMLNode bodyElem = getBodyElem(xml);
            if (bodyElem == null) throw new ResponseException('Failed to process response. Empty bodyElem!');               
            fault = new SOAFault(bodyElem); 
            if (fault.detected) throw new ResponseException('Fault: '+ fault.info);        
            Dom.XMLNode provisionRadioParameters_1ResponseElem = bodyElem.getChildElement('provisionRadioParameters_1Response', MND_NS);           
            if (provisionRadioParameters_1ResponseElem == null) throw new ResponseException('Failed to process response. Empty provisionRadioParameters_1Response!');
            return provisionRadioParameters_1ResponseElem;
        }
        
        public String getText() {
            return 'ProvisionRadioParameters:cellSiteReferenceNumber=' + cellSiteReferenceNumber + ':' +
                        'statusCode=' + statusCode+ ':' +
                        'externalDescription=' + externalDescription;
        }
    }
            
    static testMethod void testSubscriberProfile() {
        
        SubscriberProfile sp = null;
        
        Boolean exceptFound = false;
        String xml = '<bod>test</bod>';
        try {
            sp = new SubscriberProfile(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        exceptFound = false;
        try {
            sp = new SubscriberProfile(null);
        } catch (RequiredDataException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        
        exceptFound = false;
        FemtocellSOAHandler pfh = new FemtocellSOAHandler();
        pfh.testFault = true;
        xml = pfh.getSubscriberTestXml();
        try {
            sp = new SubscriberProfile(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        
        exceptFound = false;
        pfh.testFault = false;
        xml = pfh.getSubscriberTestXml();
        try {
            sp = new SubscriberProfile(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == false);
        System.debug('sp.getText()='+sp.getText());     
        System.assert(sp.getText().contains('segment=Consumer'));

        sp.channel = '1';
        System.assert(sp.channel.equalsIgnoreCase('1'));
        sp.operator = '1';
        System.assert(sp.channel.equalsIgnoreCase('1'));
        sp.paymentCategory = '1';
        System.assert(sp.operator.equalsIgnoreCase('1'));
        sp.segment = '1';
        System.assert(sp.segment.equalsIgnoreCase('1'));
        System.assert(sp.channel.equalsIgnoreCase('1'));
        sp.status = '1';
        System.assert(sp.status.equalsIgnoreCase('1'));
        sp.subscriberID = '1';
        System.assert(sp.subscriberID.equalsIgnoreCase('1'));
        
    }
    
    private String getSubscriberTestXml() {
    
        String resXml = '';
        
        if (testFault) {
            resXml = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<soapenv:Header xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">';
            resXml += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">41d84f9e-35d8-4633-9aa3-522449ef5f04</cor:SOATransactionID></soapenv:Header>';
            resXml += '<env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<env:Fault>';
            resXml += '<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:Server</faultcode>';
            resXml += '<faultstring>Invalid MSISDN</faultstring>';
            resXml += '<detail>';
            resXml += '<ns1:getSubscriberProfileFault xmlns:ns1="http://soa.o2.co.uk/subscriberdata_2" xmlns:xcore="http://soa.o2.co.uk/coredata_1">';
            resXml += '<xcore:SOAFaultOriginator>Route To Spa.getServiceProviderCategoriesForGetSubscriberProfile</xcore:SOAFaultOriginator>';
            resXml += '<xcore:SOAFaultCode>subscriber-11200-4001-V</xcore:SOAFaultCode>';
            resXml += '<xcore:faultDescription>Invalid MSISDN</xcore:faultDescription>';
            resXml += '<xcore:SOATransactionID>41d84f9e-35d8-4633-9aa3-522449ef5f04</xcore:SOATransactionID></ns1:getSubscriberProfileFault></detail></env:Fault></env:Body></soapenv:Envelope>';
        } else {
            resXml = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<soapenv:Header xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">';
            resXml += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">cd01db54-3303-43a9-9838-1ff1b9a6373f</cor:SOATransactionID></soapenv:Header>';
            resXml += '<env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<sub:getSubscriberProfileResponse xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">';
            resXml += '<sub:subscriberProfile>';
            resXml += '<sub:subscriberID>'+TEST_GOOD_SUBSCRIBER_ID+'</sub:subscriberID>';
            resXml += '<sub:operator>nonO2</sub:operator>';
            resXml += '<sub:paymentCategory>Unknown</sub:paymentCategory>';
            resXml += '<sub:segment>Consumer</sub:segment>';
            resXml += '<sub:channel>Offline</sub:channel>';
            resXml += '<sub:status /></sub:subscriberProfile></sub:getSubscriberProfileResponse></env:Body></soapenv:Envelope>';    
        }
        
        return resXml;      
        
    }
    
    private String getProvisionRadioParametersTestXml() {
        String resXml='';
        if (testFault) {
            resXml += '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<soapenv:Header xmlns:xcore="http://soa.o2.co.uk/coredata_1" xmlns:mnd="http://soa.o2.co.uk/managenetworkprovisioningdata_2">';
            resXml += '<xcore:SOATransactionID>c31d4edf-6bea-43f4-9af9-066c849130d2</xcore:SOATransactionID></soapenv:Header>';
            resXml += '<env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<env:Fault>';
                resXml += '<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:Server</faultcode>';
                resXml += '<faultstring>Order Reference Number and Postcode has already been assigned a CSR.</faultstring>';
            resXml += '<detail>';
            resXml += '<ns1:provisionRadioParameters_1Fault xmlns:ns1="http://soa.o2.co.uk/managenetworkprovisioningdata_2" xmlns:xcore="http://soa.o2.co.uk/coredata_1">';
            resXml += '<xcore:SOAFaultOriginator>manageradioprovisioning</xcore:SOAFaultOriginator>';
            resXml += '<xcore:SOAFaultCode>managenetworkprovisioning-10033-3013-E</xcore:SOAFaultCode>';
            resXml += '<xcore:faultDescription>Order Reference Number and Postcode has already been assigned a CSR.</xcore:faultDescription>';
            resXml += '<xcore:faultTrace>manageradioprovisioning-37152-3008-E:Order Reference Number and Postcode has already been assigned a CSR.</xcore:faultTrace>';
            resXml += '<xcore:SOATransactionID>c31d4edf-6bea-43f4-9af9-066c849130d2</xcore:SOATransactionID></ns1:provisionRadioParameters_1Fault></detail></env:Fault></env:Body></soapenv:Envelope>';
        } else {
            resXml += '<?xml version="1.0" encoding="UTF-8"?>';
            resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<soapenv:Header xmlns:xcore="http://soa.o2.co.uk/coredata_1" xmlns:mnd="http://soa.o2.co.uk/managenetworkprovisioningdata_2">';
            resXml += '<xcore:SOATransactionID>caeaf1d5-1840-4f94-92e1-a430cc9e9326</xcore:SOATransactionID>';
            resXml += '</soapenv:Header>';
            resXml += '<env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
                resXml += '<man:provisionRadioParameters_1Response xmlns:man="http://soa.o2.co.uk/managenetworkprovisioningdata_2">';
                   resXml += '<man:cellSiteReferenceNumber>997549</man:cellSiteReferenceNumber>';
                   resXml += '<man:result>';
                    resXml += '<cor:statusCode xmlns:cor="http://soa.o2.co.uk/coredata_1">managenetworkprovisioning-10033-0001-S</cor:statusCode>';
                    resXml += '<cor:externalDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">Radio record provisioning successful.</cor:externalDescription>';
                   resXml += '</man:result>';
                resXml += '</man:provisionRadioParameters_1Response>';
            resXml += '</env:Body>';
            resXml += '</soapenv:Envelope>';
        }
        return resXml;
    }
    private String getRadioProvisioningParametersTestXml() {
        String resXml='';
        if (testFault) {
            resXml += '<?xml version="1.0" encoding="UTF-8"?>';
            resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
               resXml += '<soapenv:Header xmlns:cor="http://soa.o2.co.uk/coredata_1">';
                  resXml += '<cor:SOATransactionID>7b2c7bec-1412-44a3-a600-b966a4ba05b7</cor:SOATransactionID>';
               resXml += '</soapenv:Header>';
               resXml += '<soapenv:Body>';
                  resXml += '<soapenv:Fault>';
                     resXml += '<faultcode>managenetworkprovisioning-10033-3014-E</faultcode>';
                     resXml += '<faultstring>No records found for the given search criteria.</faultstring>';
                     resXml += '<details>';
                        resXml += '<mnd:getRadioProvisioningParameters_1Fault xsi:schemaLocation="http://soa.o2.co.uk/managenetworkprovisioningdata_2 managenetworkprovisioningdata_2_0.xsd" xmlns:xcore="http://soa.o2.co.uk/coredata_1" xmlns:mnd="http://soa.o2.co.uk/managenetworkprovisioningdata_2">';
                           resXml += '<xcore:SOAFaultOriginator>ManageNetworkProvisioning_2_0</xcore:SOAFaultOriginator>';
                           resXml += '<xcore:SOAFaultCode>managenetworkprovisioning-10033-3014-E</xcore:SOAFaultCode>';
                           resXml += '<xcore:faultDescription>No records found for the given search criteria.</xcore:faultDescription>';
                           resXml += '<xcore:SOATransactionID>f099a6e7-ca06-48bc-b8ad-c3b3e4e77bdf</xcore:SOATransactionID>';
                        resXml += '</mnd:getRadioProvisioningParameters_1Fault>';
                     resXml += '</details>';
                  resXml += '</soapenv:Fault>';
               resXml += '</soapenv:Body>';
            resXml += '</soapenv:Envelope>';
        } else {
            resXml += '<?xml version="1.0" encoding="UTF-8"?>';
            resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<soapenv:Header xmlns:cor="http://soa.o2.co.uk/coredata_1">';
            resXml += '<cor:SOATransactionID>0c7f553f-b9f4-464a-913b-b4fc68d73cd3</cor:SOATransactionID>';
            resXml += '</soapenv:Header>';// xmlns:xcore="http://soa.o2.co.uk/coredata_1" xmlns:mnd="http://soa.o2.co.uk/managenetworkprovisioningdata_2">';
               resXml += '<soapenv:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
                  resXml += '<man:getRadioProvisioningParameters_1Response xmlns:man="http://soa.o2.co.uk/managenetworkprovisioningdata_2">';
                     resXml += '<man:radioProvisionList>';
                        resXml += '<man:orderReferenceNumber>12347</man:orderReferenceNumber>';
                        resXml += '<man:userName>MAGNET</man:userName>';
                        resXml += '<man:buildingDetails>438Towner two</man:buildingDetails>';
                        resXml += '<man:postCode>SL1 1XL</man:postCode>';
                        resXml += '<man:cellSiteReferenceNumber>997821</man:cellSiteReferenceNumber>';
                        resXml += '<man:entryDate>2012-05-23T00:00:00.000+01:00</man:entryDate>';
                        resXml += '<man:locationAreaCode>9611</man:locationAreaCode>';
                        resXml += '<man:regionAreaCode>1</man:regionAreaCode>';
                        resXml += '<man:serviceAreaCode>12183</man:serviceAreaCode>';
                        resXml += '<man:easting>497792</man:easting>';
                        resXml += '<man:northing>180107</man:northing>';
                        resXml += '<man:operationMode>O</man:operationMode>';
                        resXml += '<man:femtoRegion>1</man:femtoRegion>';
                        resXml += '<man:requestEntryDate>2012-05-23 16:30:15.0</man:requestEntryDate>';
                        resXml += '<man:userLogged>WLAPP</man:userLogged>';
                     resXml += '</man:radioProvisionList>';
                     resXml += '<man:result>';
                        resXml += '<cor:statusCode xmlns:cor="http://soa.o2.co.uk/coredata_1">managenetworkprovisioning-10033-0002-S</cor:statusCode>';
                        resXml += '<cor:externalDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">Records obtained successfully.</cor:externalDescription>';
                     resXml += '</man:result>';
                  resXml += '</man:getRadioProvisioningParameters_1Response>';
              resXml += '</soapenv:Body>';
            resXml += '</soapenv:Envelope>';
        }
        return resXml;
    }
    private String getDeviceProfileTestXml() {
        String resXml='';
        if (testFault) {
            resXml += '<?xml version="1.0" encoding="UTF-8"?>';
            resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
              resXml += '<soapenv:Header xmlns:psc="http://soa.o2.co.uk/pscommondevicedata_1" xmlns:man="http://soa.o2.co.uk/managedevicedata_1" xmlns:cor="http://soa.o2.co.uk/coredata_1">';
                resXml += '<cor:SOATransactionID>9365c927-ff1b-4541-8b6d-51d62ad740ec</cor:SOATransactionID>';
              resXml += '</soapenv:Header>';
              resXml += '<soapenv:Body xmlns:psc="http://soa.o2.co.uk/pscommondevicedata_1" xmlns:man="http://soa.o2.co.uk/managedevicedata_1" xmlns:cor="http://soa.o2.co.uk/coredata_1">';
                resXml += '<soapenv:Fault>';
                  resXml += '<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:Server</faultcode>';
                  resXml += '<faultstring>Input parameter is invalid.</faultstring>';
                  resXml += '<detail>';
                    resXml += '<man:getDeviceProfileFault>';
                      resXml += '<cor:SOAFaultOriginator>MDM Adapter</cor:SOAFaultOriginator>';
                      resXml += '<cor:SOAFaultCode>managedeviceservice-10023-4001-V</cor:SOAFaultCode>';
                      resXml += '<cor:faultDescription>Input parameter is invalid.</cor:faultDescription>';
                      resXml += '<cor:SOATransactionID>9365c927-ff1b-4541-8b6d-51d62ad740ec</cor:SOATransactionID>';
                    resXml += '</man:getDeviceProfileFault>';
                  resXml += '</detail>';
                resXml += '</soapenv:Fault>';
              resXml += '</soapenv:Body>';
            resXml += '</soapenv:Envelope>';        
        } else {
            testCounter++;
            resXml += '<?xml version="1.0" encoding="UTF-8"?>';
            resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
              resXml += '<soapenv:Header xmlns:psc="http://soa.o2.co.uk/pscommondevicedata_1" xmlns:man="http://soa.o2.co.uk/managedevicedata_1" xmlns:cor="http://soa.o2.co.uk/coredata_1">';
                resXml += '<cor:SOATransactionID>9f592bc1-1985-4e52-ba88-96edee2bd644</cor:SOATransactionID>';
              resXml += '</soapenv:Header>';
              resXml += '<soapenv:Body xmlns:psc="http://soa.o2.co.uk/pscommondevicedata_1" xmlns:man="http://soa.o2.co.uk/managedevicedata_1" xmlns:cor="http://soa.o2.co.uk/coredata_1">';
                resXml += '<man:getDeviceProfileResponse>';
                  resXml += '<man:deviceProfile>';
                    resXml += '<psc:msisdn>447802209408</psc:msisdn>';
                    resXml += '<psc:imsi>2399908022094'+testCounter+'</psc:imsi>';
                    resXml += '<psc:imei>3570660053160004</psc:imei>';
                    resXml += '<psc:brand>Nokia</psc:brand>';
                    resXml += '<psc:model>6230i</psc:model>';
                    resXml += '<psc:displayBrand>Nokia</psc:displayBrand>';
                    resXml += '<psc:displayModel>6230i</psc:displayModel>';
                    resXml += '<psc:deviceAttributes>';
                      resXml += '<cor:mapItem>';
                        resXml += '<cor:key>hardware_gprs</cor:key>';
                        resXml += '<cor:boolValue>true</cor:boolValue>';
                      resXml += '</cor:mapItem>';
                    resXml += '</psc:deviceAttributes>';
                  resXml += '</man:deviceProfile>';
                resXml += '</man:getDeviceProfileResponse>';
              resXml += '</soapenv:Body>';
            resXml += '</soapenv:Envelope>';
        }
        return resXml;
    }
    public class MapItem {
        public String key { get; set; }
        public Integer intValue { get; set; }
        public String strValue { get; set; }
        public boolean boolValue { get; set; }
        public MapItem(){}
        public MapItem(String k, Integer v) {
            key=k;
            intValue=v;
        }
        public MapItem(String k, String v) {
            key=k;
            strValue=v;
        }
        public MapItem(String k, boolean v) {
            key=k;
            boolValue=v;
        }
    }
    public DeviceProfile getDeviceProfile(String msisdn, String imsi, String imei, String brand, String model, String displayBrand, String displayModel, List<MapItem> mapItemList) {
        soaBase = new SOAServicesBase();
        
        // convert mapItemList into tag string
        String mapItemStr='';
        if(mapItemList!=null) {
            for(MapItem mapItem : mapItemList) {
                if(mapItem.intValue!=null) {
                    mapItemStr+=getTag('cor:mapItem',
                        getTag('cor:key',mapItem.key)+
                        getTag('cor:intValue',String.valueOf(mapItem.intValue)));   
                }
                if(mapItem.strValue!=null) {
                    mapItemStr+=getTag('cor:mapItem',
                        getTag('cor:key',mapItem.key)+
                        getTag('cor:strValue',mapItem.strValue));   
                }
                if(mapItem.boolValue!=null) {
                    mapItemStr+=getTag('cor:mapItem',
                        getTag('cor:key',mapItem.key)+
                        getTag('cor:boolValue', mapItem.boolValue ? 'true' : 'false')); 
                }
            }
        }
        
        String innerXML = getTag('man:getDeviceProfile', getTag('man:deviceProfile',
                        getTag('psc:msisdn',msisdn)+
                         getTag('psc:imsi',imsi)+
                         getTag('psc:imei',imei)+
                         getTag('psc:brand',brand)+
                         getTag('psc:model',model)+
                         getTag('psc:displayBrand',displayBrand)+
                         getTag('psc:displayModel',displayModel)+
                         getTag('psc:deviceAttributes', mapItemStr)));


        String endPoint = null;        
        String resXml = null;
        
        if (Test.isRunningTest()) { 
            resXml = getDeviceProfileTestXml();
        } else {
            endPoint = SOA_Integration_Settings__c.getValues('Manage_Device').Endpoint__c;
            //endpoint = 'https://sdpapi.ref.o2.co.uk/services/ManageDevice_1_4';
            
            if (isEmpty(endPoint)) throw new RequiredDataException('endPoint is required!'); 
            
            resXml = soaBase.sendRequest(endPoint, ENVELOPE_XML_MANDEV, innerXML);            
        }    
        System.debug('MND resXml'+resXml);
        deviceProfile = new DeviceProfile(resXml);
        System.debug('deviceProfile.getText()='+ deviceProfile.getText()); 
        
        return deviceProfile;
    }
    
    public RadioProvisioningParmameters getRadioProvisioningParameters_1(String cellSiteReferenceNumber, String orderReferenceNumber, String buildingDetails, String postCode, Datetime startDate, Datetime endDate) {
        soaBase = new SOAServicesBase();
        String startDateStr='';
        String endDateStr='';
        if(startDate!=null) startDateStr=startDate.format('yyyy-MM-dd\'T\'HH:mm:ss');
        if(endDate!=null) endDateStr=endDate.format('yyyy-MM-dd\'T\'HH:mm:ss');
        
        // Empty tags not allowed so only pass tags for which we have values
        String cellSiteReferenceNumberTag='';
        if(cellSiteReferenceNumber!='') {
            cellSiteReferenceNumberTag=getTag('mnd:cellSiteReferenceNumber',cellSiteReferenceNumber);
        }
        String postCodeTag='';
        if(postCode!='') {
            postCodeTag=getTag('mnd:postCode',postCode);
        }
        String orderReferenceNumberTag='';
        if(orderReferenceNumber!='') {
            orderReferenceNumberTag=getTag('mnd:orderReferenceNumber',orderReferenceNumber);
        }
        String buildingDetailsTag='';
        if(buildingDetails!='') {
            buildingDetailsTag=getTag('mnd:buildingDetails',buildingDetails);
        }
        String durationRangeTag='';
        if(startDateStr!='' || endDateStr!='') {
            durationRangeTag=getTag('mnd:durationRange',
                            getTag('mnd:startDate',startDateStr)+
                            getTag('mnd:endDate',endDateStr));
        }
        String innerXML = getTag('mnd:getRadioProvisioningParameters_1',
                        cellSiteReferenceNumberTag+
                        orderReferenceNumberTag+
                        buildingDetailsTag+
                        postCodeTag+
                        durationRangeTag);
        /*              
                         getTag('mnd:cellSiteReferenceNumber',cellSiteReferenceNumber)+
                         getTag('mnd:orderReferenceNumber',orderReferenceNumber)+
                         getTag('mnd:buildingDetails',buildingDetails)+
                         getTag('mnd:postCode',postCode)+
                         getTag('mnd:durationRange',
                            getTag('mnd:startDate',startDateStr)+
                            getTag('mnd:endDate',endDateStr)));
        */
        String endPoint = null;        
        String resXml = null;
        
        if (Test.isRunningTest()) {
            resXml = getRadioProvisioningParametersTestXml();
        } else {
            endPoint = SOA_Integration_Settings__c.getValues('Manage_Network_Provisioning').Endpoint__c;
            //endpoint = 'https://sdpapi.ref.o2.co.uk/services/ManageNetworkProvisioning_2_0';
            
            if (isEmpty(endPoint)) throw new RequiredDataException('endPoint is required!'); 
            
            resXml = soaBase.sendRequest(endPoint, ENVELOPE_XML_MND, innerXML);            
        }    
        System.debug('RadioProv resXml'+resXml);
        radioProvisioningParmameters = new RadioProvisioningParmameters(resXml);
        System.debug('radioProvisioningParmameters.getText()='+ radioProvisioningParmameters.getText());
        
        return radioProvisioningParmameters;      
    }
    
    // TODO - addressType: reuse Address object as parameter, this may need to change if not appropriate
    public void provisionRadioParameters_1(String orderRef, String cellType, String operationalMode, String userName, Address addressDetails) {
        soaBase = new SOAServicesBase();
        
        // TODO - validate postcode??
        
        String innerXML = getTag('mnd:provisionRadioParameters_1',
                        getTag('mnd:orderReferenceNumber',orderRef)+
                         getTag('mnd:userName',username)+
                         getTag('mnd:addressDetails',
                            getTag('xcore:subBuildingName',addressDetails.subBuildingName)+
                            getTag('xcore:buildingName',addressDetails.buildingName)+
                            getTag('xcore:buildingNumber',addressDetails.buildingNumber)+
                            getTag('xcore:thoroughfareNameAndDescriptor',addressDetails.street)+
                            getTag('xcore:postTown',addressDetails.postTown)+
                            getTag('xcore:county',addressDetails.county)+
                            getTag('xcore:postCode',addressDetails.postcode))+
                         getTag('mnd:operationalMode',operationalMode)+
                         getTag('mnd:cellType',cellType));
                                
         /*String innerXML = getTag('mnd:provisionRadioParameters_1',
                        getTag('mnd:orderReferenceNumber','12346')+
                         getTag('mnd:userName','MAGNET')+
                         getTag('mnd:addressDetails',
                            getTag('xcore:subBuildingName','Mains')+
                            getTag('xcore:buildingName','Towner two')+
                            getTag('xcore:buildingNumber','438')+
                            getTag('xcore:thoroughfareNameAndDescriptor','26 Street')+
                            getTag('xcore:postTown','Hinkley')+
                            getTag('xcore:county','YorkShir')+
                            getTag('xcore:postCode','SL1 1XL'))+
                         getTag('mnd:operationalMode','O')+
                         getTag('mnd:cellType','1'));
        */
        
        String endPoint = null;        
        String resXml = null;
        
        if (Test.isRunningTest()) {
            resXml = getProvisionRadioParametersTestXml();
        } else {
            endPoint = SOA_Integration_Settings__c.getValues('Manage_Network_Provisioning').Endpoint__c;
            //endpoint = 'https://sdpapi.ref.o2.co.uk/services/ManageNetworkProvisioning_2_0';
            
            if (isEmpty(endPoint)) throw new RequiredDataException('endPoint is required!'); 
            
            resXml = soaBase.sendRequest(endPoint, ENVELOPE_XML_MND, innerXML);            
        }    
        System.debug('MND resXml'+resXml);
        provisionRadioParameters = new ProvisionRadioParameters(resXml);
        System.debug('provisionRadioParameters.getText()='+ provisionRadioParameters.getText());
        
    }
    public String getMNDCellSiteReferenceNumber() {
        return provisionRadioParameters.cellSiteReferenceNumber;
    }
    
    
    public void populateSubscriberProfile(String subscriberId) {
        soaBase = new SOAServicesBase();        
        if (isEmpty(subscriberId)) throw new RequiredDataException('subscriberId is required!');
        String innerXML = getTag('sub:getSubscriberProfile', getTag('sub:subscriberID', subscriberId));
        String endPoint = null;
        
        String resXml = null;
        
        if (Test.isRunningTest()) {
            resXml = getSubscriberTestXml();
        } else {
            endPoint = SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c;
            
            if (isEmpty(endPoint)) throw new RequiredDataException('endPoint is required!'); 
            
            resXml = soaBase.sendRequest(endPoint, ENVELOPE_XML_SUBS, innerXML);
        }    
        
        subscriberProfile = new SubscriberProfile(resXml);
        System.debug('subscriberProfile.getText()='+ subscriberProfile.getText());
    }   
    
    public class Address {
        
        public boolean selected {get; set;}
        public String organisation{ get; set; }
        public String buildingNumber { get; set; }
        public String buildingName { get; set; }
        public String subBuildingName { get; set; }
        public String street { get; set; }
        public String dependentStreet { get; set; }
        public String dependentLocality { get; set; }
        public String locality { get; set; }
        public String county { get; set; }
        public String postTown { get; set; }
        public String postcode { get; set; }
        
        public String getText() {
            return 'Address:selected=' + selected + ':' +
                        'organisation=' + organisation + ':' +
                        'buildingNumber=' + buildingNumber + ':' +
                        'subBuildingName=' + buildingName + ':' +
                        'subBuildingName=' + subBuildingName + ':' +
                        'street=' + street + ':' +
                        'dependentStreet=' + dependentStreet + ':' +
                        'locality=' + locality + ':' +
                        'county=' + county + ':' +
                        'postTown=' + postTown + ':' +
                        'postcode=' + postcode;
        }
        
        public String getPrettyText() {
            String txt = '';
            txt = addTxt(txt, organisation);
            txt = addTxt(txt, buildingNumber);
            txt = addTxt(txt, buildingName);
            txt = addTxt(txt, subBuildingName);
            txt = addTxt(txt, street);
            txt = addTxt(txt, dependentStreet);
            txt = addTxt(txt, locality);
            txt = addTxt(txt, county);
            txt = addTxt(txt, postTown);
            txt = addTxt(txt, postcode);
            return txt;
        }
        
        
        
    }   
    
    static testMethod void testAddress() {
        Address ad = new Address();
        ad.selected = false;
        ad.organisation = '1';
        ad.buildingNumber = '2';
        ad.subBuildingName = '3';
        ad.buildingName = '4';
        ad.street = '5';
        ad.dependentStreet = '6';
        ad.dependentLocality = '7';
        ad.locality = '8';
        ad.county = '9';
        ad.postTown = '10';
        ad.postcode = '11';
        System.assert(ad.selected == false);
        System.assert(ad.organisation == '1');
        System.assert(ad.buildingNumber == '2');
        System.assert(ad.subBuildingName == '3');
        System.assert(ad.buildingName == '4');
        System.assert(ad.street == '5');
        System.assert(ad.dependentStreet == '6');
        System.assert(ad.dependentLocality == '7');
        System.assert(ad.locality == '8');
        System.assert(ad.county == '9');
        System.assert(ad.postTown == '10');
        System.assert(ad.postcode == '11'); 
        System.assert(ad.getText().contains('postcode=11'));            
        //System.assert(ad.getPrettyText().contains('postcode=11'));            
    }
    
    
    public class AddressList {
/*

// soaAddress.searchAddress response

<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Header xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">
<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">ff6a9109-8189-47b3-a500-f1e592df5ce7</cor:SOATransactionID></soapenv:Header>
<soapenv:Body>
<view:searchAddressResponse xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">13</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address></view:searchAddressResponse></soapenv:Body></soapenv:Envelope>

// soaAddress.getAddressMatch response

<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Header xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">
<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">a1e02360-f8b2-4199-9494-2c93b6dbbfd1</cor:SOATransactionID></soapenv:Header>
<soapenv:Body>
<view:getAddressMatchResponse xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">
<view:address>
<psc:organisation xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">CORNER SOFTWARE LTD</psc:organisation>
<psc:buildingName xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">HARLEY COTTAGE</psc:buildingName>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">7</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">13</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">12</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">11</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">10</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">7</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address></view:getAddressMatchResponse></soapenv:Body></soapenv:Envelope>
14:24:08.257 (1257383000)|METHOD_EXIT|[438]|01p20000000Eh8R|SOAViewPostalAddress.getAddressMatch(String, String, String, String)
14:24:08.257 (1257922000)|USER_DEBUG|[439]|DEBUG|doc.toXmlString()=<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Header xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">
<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">a1e02360-f8b2-4199-9494-2c93b6dbbfd1</cor:SOATransactionID></soapenv:Header>
<soapenv:Body>
<view:getAddressMatchResponse xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">
<view:address>
<psc:organisation xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">CORNER SOFTWARE LTD</psc:organisation>
<psc:buildingName xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">HARLEY COTTAGE</psc:buildingName>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">7</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">13</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">12</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">11</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">10</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address>
<view:address>
<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">7</psc:buildingNumber>
<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>
<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>
<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>
<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address></view:getAddressMatchResponse></soapenv:Body></soapenv:Envelope>

*/      
        
        public List<Address> addresses = null;
        public SOAFault fault = null;
        
        public AddressList(String xml) {
            
            if (isEmpty(xml)) throw new RequiredDataException('xml is required!');
            Dom.XMLNode getAddressMatchResponseElem = getMainDataElem(xml);
            Integer cnt = getAddressMatchResponseElem.getChildElements().size();
            
            
            addresses = new List<Address>();

                
            for(Dom.XMLNode addr: getAddressMatchResponseElem.getChildElements()) {
                    
                Dom.XMLNode organisation= addr.getChildElement('organisation',PSC_NS);
                Dom.XMLNode subBuildingName = addr.getChildElement('subBuildingName',PSC_NS);
                Dom.XMLNode buildingNumber = addr.getChildElement('buildingNumber',PSC_NS);
                Dom.XMLNode buildingName = addr.getChildElement('buildingName',PSC_NS);
                Dom.XMLNode street = addr.getChildElement('street',PSC_NS);
                Dom.XMLNode dependentStreet= addr.getChildElement('dependentStreet',PSC_NS);
                Dom.XMLNode dependentLocality = addr.getChildElement('dependentLocality',PSC_NS);
                Dom.XMLNode locality = addr.getChildElement('locality',PSC_NS);
                Dom.XMLNode county = addr.getChildElement('county',PSC_NS);
                Dom.XMLNode postTown = addr.getChildElement('postTown',PSC_NS);            
                Dom.XMLNode postcode = addr.getChildElement('postcode',PSC_NS);
                
                Address a = new Address();
                if(cnt==1) {
                    a.selected = true;
                } else {
                    a.selected = false;
                }
                a.organisation= organisation!=null?organisation.getText():'';
                a.buildingNumber = buildingNumber!=null?buildingNumber.getText():'';
                a.subBuildingName = subBuildingName!=null? subBuildingName.getText():'';
                a.buildingName = buildingName!=null? buildingName.getText():'';
                
                // In case street is not provided 
                if(street!=null && street.getText() != ''){
                    a.street=street.getText();
                    if(dependentStreet!=null){
                        a.street += ', ' + dependentStreet.getText();
                    }
                    System.debug('using street');
                }else if(locality!=null && locality.getText() != ''){
                    a.street=locality.getText();
                    System.debug('using locality');
                }else if (dependentStreet!=null && dependentStreet.getText() != ''){
                    a.street=dependentStreet.getText();
                    System.debug('using depstreet');
                }else if (dependentLocality!=null && dependentLocality.getText() != ''){
                    a.street=dependentLocality.getText();
                    System.debug('using deplocality');
                }
                System.debug('street set as ' + a.street);
                //a.street = street!=null? street.getText():'';
                a.dependentStreet= dependentStreet!=null? dependentStreet.getText():'';
                a.dependentLocality = dependentLocality!=null? dependentLocality.getText():'';
                a.locality= locality!=null? locality.getText():'';
                a.county = county!=null? county.getText():'';
                a.postTown = postTown!=null? postTown.getText():'';
                a.postcode = postcode!=null? postcode.getText():''; 
                           
                addresses.add(a);
                
                
            }

        }
        
        private Dom.XMLNode getMainDataElem(String xml) {
            Dom.XMLNode bodyElem = getBodyElem(xml);
            if (bodyElem == null) throw new ResponseException('Failed to process response. Empty bodyElem!');               
            fault = new SOAFault(bodyElem); 
            if (fault.detected) throw new ResponseException('Fault: '+ fault.info);        
            Dom.XMLNode respNode = bodyElem.getChildElement('getAddressMatchResponse', VPAD_NS);
            if (respNode == null) { 
                respNode = bodyElem.getChildElement('searchAddressResponse', VPAD_NS);
                
            } 
            if (respNode == null) throw new ResponseException('Failed to process response. Empty getAddressMatchResponse or empty searchAddressResponse elemet!');
            return respNode;
        }
        
        public String getText() {
            
            String retVal = 'AddressList:';
            Integer i = 1;
            
            for(Address addr: addresses) {
                retVal += '\r\n' + i++ + ' - ' + addr.getText();
            }
            
            return retVal;
        }
        
    
    }
    
    private String getAddressListTestXml() {
    
        String resXml = '';
        
        if (testFault) {
            resXml = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<soapenv:Header xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">';
            resXml += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">30543ad9-aebd-4e32-abaa-2e840d9e55c8</cor:SOATransactionID></soapenv:Header>';
            resXml += '<soapenv:Body xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">';
            resXml += '<soapenv:Fault>';
            resXml += '<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:Server</faultcode>';
            resXml += '<faultstring>Please check the post code provided</faultstring>';
            resXml += '<detail>';
            resXml += '<view:getAddressMatchFault>';
            resXml += '<cor:SOAFaultOriginator xmlns:cor="http://soa.o2.co.uk/coredata_1">PostCode Format Validation</cor:SOAFaultOriginator>';
            resXml += '<cor:SOAFaultCode xmlns:cor="http://soa.o2.co.uk/coredata_1">viewpostaladdress-11290-4001-V</cor:SOAFaultCode>';
            resXml += '<cor:faultDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">Please check the post code provided</cor:faultDescription>';
            resXml += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">30543ad9-aebd-4e32-abaa-2e840d9e55c8</cor:SOATransactionID></view:getAddressMatchFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        } else {
            resXml = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            resXml += '<soapenv:Header xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">';
            resXml += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">ff6a9109-8189-47b3-a500-f1e592df5ce7</cor:SOATransactionID></soapenv:Header>';
            resXml += '<soapenv:Body>';
            resXml += '<view:searchAddressResponse xmlns:view="http://soa.o2.co.uk/viewpostaladdressdata_1">';
            resXml += '<view:address>';
            resXml += '<psc:buildingNumber xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">13</psc:buildingNumber>';
            resXml += '<psc:street xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SOUTH VIEW RD</psc:street>';
            resXml += '<psc:postTown xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">GERRARDS CROSS</psc:postTown>';
            resXml += '<psc:county xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">BUCKS</psc:county>';
            resXml += '<psc:postcode xmlns:psc="http://soa.o2.co.uk/pscommonpostpaydata_1">SL9 8RG</psc:postcode></view:address></view:searchAddressResponse></soapenv:Body></soapenv:Envelope>';
        }
        
        return resXml;      
        
    }
    
    
    
    static testMethod void testAddressList() {
        
        AddressList al = null;
        
        Boolean exceptFound = false;
        String xml = '<bod>test</bod>';
        try {
            al = new AddressList(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        exceptFound = false;
        try {
            al = new AddressList(null);
        } catch (RequiredDataException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        
        exceptFound = false;
        FemtocellSOAHandler pfh = new FemtocellSOAHandler();
        pfh.testFault = true;
        xml = pfh.getAddressListTestXml();
        try {
            al = new AddressList(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        
        exceptFound = false;
        pfh.testFault = false;
        xml = pfh.getAddressListTestXml();
        try {
            al = new AddressList(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == false);
        System.debug('al.getText()='+al.getText());     
        System.assert(al.getText().contains('AddressList:'));

        
    }        
    
    public void populateAddresses(String organisation, String buildingName, String buildingNumber, String postcode) {
        soaAddress = new SOAViewPostalAddress();
        if (isEmpty(buildingNumber)) buildingNumber = '*';
        String xml = null;
        if (!Test.isRunningTest()) {        
            Dom.Document doc = soaAddress.getAddressMatch(stri(organisation), stri(buildingName), stri(buildingNumber), stri(postcode).toUpperCase());
            xml = doc.toXmlString();
        } else {
            xml = getAddressListTestXml();
            System.debug('xml=' + xml);
        }
        addressList = new AddressList(xml);
        System.debug(addressList.getText());
    }
    
    public void populateAddresses(String organisation,String subBuildingName,String buildingName,String buildingNumber,String street,String postTown,String dependentStreet,String dependentLocality,String locality,String county,String postcode) {
        
        System.debug('organisation='+organisation);
        System.debug('subBuildingName='+subBuildingName);
        System.debug('buildingName='+buildingName);
        System.debug('buildingNumber='+buildingNumber);
        System.debug('street='+street);
        System.debug('postTown='+postTown);
        System.debug('dependentStreet='+dependentStreet);
        System.debug('dependentLocality='+dependentLocality);
        System.debug('county='+county);
        System.debug('postcode='+postcode);
        
        soaAddress = new SOAViewPostalAddress();    
        if (isEmpty(buildingNumber)) buildingNumber = '*';      
        String xml = null;
        if (!Test.isRunningTest()) {        
            Dom.Document doc =  soaAddress.searchAddress(stri(organisation), stri(subBuildingName), stri(buildingName), stri(buildingNumber), stri(street), stri(postTown), stri(dependentStreet), stri(dependentLocality), stri(locality), stri(county), stri(postcode).toUpperCase());
            xml = doc.toXmlString();
        } else {
            xml = getAddressListTestXml();
            System.debug('xml=' + xml);
        }
        addressList = new AddressList(xml);
        System.debug(addressList.getText());
    }
    
    public class AccountBasicAndAddress {
        
        /*
<man:getAccountDetailsResponse xmlns:man="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1">
<man:accountBasic>
<man:accountNumber>2023655</man:accountNumber>
<man:corporateCode>KINSS</man:corporateCode>
<man:groupCode>KINSS</man:groupCode>
<man:companyNumber>001</man:companyNumber>
<man:paymentTypeCode>DD</man:paymentTypeCode>
<man:paymentTypeDescription>DIRECT DEBIT CUSTOMERS</man:paymentTypeDescription>
<man:paymentTermsCode>C</man:paymentTermsCode>
<man:paymentTermsDescription>30 DAYS AIRTIME</man:paymentTermsDescription>
<man:bondAmount>0</man:bondAmount>
<man:emailAddress>EKS@KSLAW.CO.UK</man:emailAddress>
<man:lastAmendedDate>2012-03-07T09:21:38.000Z</man:lastAmendedDate>
</man:accountBasic>
</man:getAccountDetailsResponse>
        */      
        
        // BASIC
        public String accountNumber{ get; set; }
        public String corporateCode{ get; set; }
        public String groupCode{ get; set; }
        public String companyNumber{ get; set; }
        public String paymentTypeCode{ get; set; }
        public String paymentTypeDescription{ get; set; }
        public String bondAmount{ get; set; }
        public String emailAddress{ get; set; }
        public String lastAmendedDate{ get; set; }
        
        // ADDRESS
        public String companyName{ get; set; }
        public String address1{ get; set; }
        public String address2{ get; set; }
        public String address3{ get; set; }
        public String address4{ get; set; }
        public String address5{ get; set; }
        public String postcode{ get; set; }
        public String companyTelephoneNumber{ get; set; }
        public String contactTelephoneNumber{ get; set; }
        public String companyType{ get; set; }
        public String companyRegistration{ get; set; }
        public String forename{ get; set; }
        public String surname{ get; set; }
        

        public SOAFault fault = null;
        
        public AccountBasicAndAddress(String xml) {
            
            if (isEmpty(xml)) throw new RequiredDataException('xml is required!');      
            
            // BASIC    
            Dom.XMLNode accountBasicElem = getMainDataElem(xml, 'BASIC');                               
            accountNumber = getElemText(accountBasicElem, MAN_NS, 'accountNumber');
            corporateCode = getElemText(accountBasicElem, MAN_NS, 'corporateCode');
            groupCode = getElemText(accountBasicElem, MAN_NS, 'groupCode');
            companyNumber = getElemText(accountBasicElem, MAN_NS, 'companyNumber');
            paymentTypeCode = getElemText(accountBasicElem, MAN_NS, 'paymentTypeCode');
            paymentTypeDescription = getElemText(accountBasicElem, MAN_NS, 'paymentTypeDescription');
            bondAmount = getElemText(accountBasicElem, MAN_NS, 'bondAmount');
            emailAddress = getElemText(accountBasicElem, MAN_NS, 'emailAddress');
            lastAmendedDate = getElemText(accountBasicElem, MAN_NS, 'lastAmendedDate');
            
            // ADDRESS
            Dom.XMLNode businessDetailsElem = getMainDataElem(xml, 'ADDRESS');                              
            companyName = getElemText(businessDetailsElem,MAN_NS, 'companyName');
            address1 = getElemText(businessDetailsElem,MAN_NS, 'address1');
            address2 = getElemText(businessDetailsElem,MAN_NS, 'address2');
            address3 = getElemText(businessDetailsElem,MAN_NS, 'address3');
            address4 = getElemText(businessDetailsElem,MAN_NS, 'address4');
            address5 = getElemText(businessDetailsElem,MAN_NS, 'address5');
            postcode = getElemText(businessDetailsElem,MAN_NS, 'postcode');
            companyTelephoneNumber = getElemText(businessDetailsElem,MAN_NS, 'companyTelephoneNumber');
            contactTelephoneNumber = getElemText(businessDetailsElem,MAN_NS, 'contactTelephoneNumber');
            companyType = getElemText(businessDetailsElem,MAN_NS, 'companyType');
            companyRegistration = getElemText(businessDetailsElem,MAN_NS, 'companyRegistration');
            forename = getElemText(businessDetailsElem,MAN_NS, 'forename');
            surname = getElemText(businessDetailsElem,MAN_NS, 'surname');
            if(companyName == null || companyName == ''){
                companyName = forename + ' '  + surname;
            }

        }
        
        private Dom.XMLNode getMainDataElem(String xml, String area) {

            if (xml == null) throw new RequiredDataException('xml required!');              
            if (area == null) throw new RequiredDataException('area required!');                
            if (area != 'BASIC' && area != 'ADDRESS') throw new RequiredDataException('Invalid area! [' + area + ']');              

            Dom.XMLNode bodyElem = getBodyElem(xml);
            if (bodyElem == null) throw new ResponseException('Failed to process response. Empty bodyElem!');               
            fault = new SOAFault(bodyElem); 
            if (fault.detected) throw new ResponseException('Fault: '+ fault.info);        
            Dom.XMLNode getAccountDetailsResponseElem = bodyElem.getChildElement('getAccountDetailsResponse', MAN_NS);          
            if (getAccountDetailsResponseElem == null) throw new ResponseException('Failed to process response. Empty getAccountDetailsResponseElem!');
            
            if (area.equalsIgnoreCase('BASIC')) {
                Dom.XMLNode accountBasicElem = getAccountDetailsResponseElem.getChildElement('accountBasic', MAN_NS);           
                if (accountBasicElem == null) throw new ResponseException('Failed to process response. Empty accountBasicElem!');
                return accountBasicElem;
            } else if (area.equalsIgnoreCase('ADDRESS')) {
                Dom.XMLNode accountAddressElem = getAccountDetailsResponseElem.getChildElement('addressDetails', MAN_NS);           
                if (accountAddressElem == null) throw new ResponseException('Failed to process response. Empty accountAddressElem!');
                Dom.XMLNode businessDetailsElem = accountAddressElem.getChildElement('businessDetails', MAN_NS);            
                                // Use personal address details if no business details available
                if (businessDetailsElem == null)
                    businessDetailsElem = accountAddressElem.getChildElement('personalDetails', MAN_NS);
                if (businessDetailsElem == null) throw new ResponseException('Failed to process response. Empty buiness/personalDetails!');
                return businessDetailsElem;
            }
            
            return null;
            
        }        
        
        public String getText() {
            
            return 'AccountBasicAndAddress: BASIC accountNumber=' + accountNumber + ':' +
                        'corporateCode=' + corporateCode + ':' +
                        'groupCode=' + groupCode + ':' +
                        'companyNumber=' + companyNumber + ':' +
                        'paymentTypeCode=' + paymentTypeCode + ':' +
                        'paymentTypeDescription=' + paymentTypeDescription + ':' +
                        'bondAmount=' + bondAmount + ':' +
                        'emailAddress=' + emailAddress + ':' +
                        'paymentTypeCode=' + paymentTypeCode + ':' +
                        'lastAmendedDate=' + lastAmendedDate + ':' +
                        'ADDRESS companyName=' +  companyName + ':' +
                        'address1=' + address1 + ':' +
                        'address2=' + address2 + ':' +
                        'address3=' + address3 + ':' +
                        'address4=' + address4 + ':' +
                        'address5=' + address5 + ':' +
                        'postcode=' + postcode + ':' +
                        'companyTelephoneNumber=' + companyTelephoneNumber + ':' +
                        'contactTelephoneNumber=' + contactTelephoneNumber + ':' +
                        'companyType=' + companyType + ':' +
                        'companyRegistration=' + companyRegistration + ':' +
                        'forename=' + forename;
            
        }
                
    }  
    
    static testMethod void testAccountBasicAndAddress() {
        
        AccountBasicAndAddress ab = null;
        
        Boolean exceptFound = false;
        String xml = '<bod>test</bod>';
        try {
            ab = new AccountBasicAndAddress(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        exceptFound = false;
        try {
            ab = new AccountBasicAndAddress(null);
        } catch (RequiredDataException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        
        exceptFound = false;
        FemtocellSOAHandler pfh = new FemtocellSOAHandler();
        pfh.testFault = true;
        xml = pfh.getAccountBasicAndAddressTestXml();
        try {
            ab = new AccountBasicAndAddress(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        
        exceptFound = false;
        pfh.testFault = false;
        xml = pfh.getAccountBasicAndAddressTestXml();
        try {
            ab = new AccountBasicAndAddress(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == false);
        System.debug('ab.getText()='+ab.getText());     
        System.assert(ab.getText().contains('AccountBasicAndAddress:'));

        
    }        
        
    public void populateAccountBasicAndAddress(String accountNumber) {
        soaBase = new SOAServicesBase();        
        if (isEmpty(accountNumber)) throw new RequiredDataException('accountNumber is required!');
        
        String innerXML = getTag('view:getAccountDetails', 
                                getTag('view:accountNumber', accountNumber) +
                                getTag('view:accountDataFilters', 
                                    getTag('view:accountDataFilter', 'BASIC') + 
                                    getTag('view:accountDataFilter', 'ADDRESS')
                                    )
                                );
        
        String endPoint = null;        
        String resXml = null;
        
        if (Test.isRunningTest()) {
            resXml = getAccountBasicAndAddressTestXml();
        } else {
            endPoint = SOA_Integration_Settings__c.getValues('Manage_Business_Customer_Details').Endpoint__c;
            
            if (isEmpty(endPoint)) throw new RequiredDataException('endPoint is required!'); 
            
            resXml = soaBase.sendRequest(endPoint, ENVELOPE_XML_DISE, innerXML);            
        }    
        
        accountBasicAndAddress = new AccountBasicAndAddress(resXml);
        System.debug('accountBasicAndAddress.getText()='+ accountBasicAndAddress.getText());
    }
    
    public AccountBasicAndAddress getAccountBasicAndAddress() {
        return accountBasicAndAddress;
    }
    
    public AddressList getAddressList() {
        System.debug('get address list ' + addressList);
        return addressList;
    }
    
    public SubscriberProfile getSubscriberProfile() {
        return subscriberProfile;
    }
    
    public SubscriptionBasic getSubscriptionBasic() {
        return subscriptionBasic;
    }
    
    private String getAccountBasicAndAddressTestXml() {
        String retVal = null;
    
        if (testFault) {
            retVal = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            retVal += '<soapenv:Header>';
            retVal += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1" /></soapenv:Header>';
            retVal += '<soapenv:Body>';
            retVal += '<soapenv:Fault>';
            retVal += '<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:server</faultcode>';
            retVal += '<faultstring>Internal Error</faultstring>';
            retVal += '<detail>';
            retVal += '<Fault>';
            retVal += '<cor:SOAFaultOriginator xmlns:cor="http://soa.o2.co.uk/coredata_1">AG</cor:SOAFaultOriginator>';
            retVal += '<cor:SOAFaultCode xmlns:cor="http://soa.o2.co.uk/coredata_1">AG-100000-2000-F</cor:SOAFaultCode>';
            retVal += '<cor:faultDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">Internal Error</cor:faultDescription>';
            retVal += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1" /></Fault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        } else {        
            retVal = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            retVal += '<soapenv:Header xmlns:view="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
            retVal += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">86affba1-b82e-4256-aec9-3da00cbf9c3d</cor:SOATransactionID></soapenv:Header>';
            retVal += '<soapenv:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
            retVal += '<man:getAccountDetailsResponse xmlns:man="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1">';
            retVal += '<man:accountBasic>';
            retVal += '<man:accountNumber>2023655</man:accountNumber>';
            retVal += '<man:corporateCode>KINSS</man:corporateCode>';
            retVal += '<man:groupCode>KINSS</man:groupCode>';
            retVal += '<man:companyNumber>001</man:companyNumber>';
            retVal += '<man:paymentTypeCode>DD</man:paymentTypeCode>';
            retVal += '<man:paymentTypeDescription>DIRECT DEBIT CUSTOMERS</man:paymentTypeDescription>';
            retVal += '<man:paymentTermsCode>C</man:paymentTermsCode>';
            retVal += '<man:paymentTermsDescription>30 DAYS AIRTIME</man:paymentTermsDescription>';
            retVal += '<man:bondAmount>0</man:bondAmount>';
            retVal += '<man:emailAddress>EKS@KSLAW.CO.UK</man:emailAddress>';
            retVal += '<man:lastAmendedDate>2012-03-07T09:21:38.000Z</man:lastAmendedDate></man:accountBasic>';
            retVal += '<man:addressDetails>';
            retVal += '<man:businessDetails>';
            retVal += '<man:companyName>Testing Account</man:companyName>';
            retVal += '<man:address1>1 Test Street</man:address1>';
            retVal += '<man:address2>Preston Brook</man:address2>';
            retVal += '<man:address3>Runcorn</man:address3>';
            retVal += '<man:address4>Cheshire</man:address4>';
            retVal += '<man:address5>England</man:address5>';
            retVal += '<man:postcode>ME4 4EE</man:postcode>';
            retVal += '<man:companyTelephoneNumber>01634811118</man:companyTelephoneNumber>';
            retVal += '<man:contactTelephoneNumber>01634811118</man:contactTelephoneNumber>';
            retVal += '<man:companyType>03</man:companyType>';
            retVal += '<man:companyRegistration>.</man:companyRegistration>';
            retVal += '<man:forename>ELISABETH</man:forename></man:businessDetails>';
            retVal += '<man:lastAmendedDate>2012-01-04T09:28:13.000Z</man:lastAmendedDate></man:addressDetails></man:getAccountDetailsResponse></soapenv:Body></soapenv:Envelope>';

        }
        return retVal;      
    }
    
    public class SubscriptionBasic {
        
        /*
<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Header xmlns:view="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">
<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">ae0b5ebb-d01c-4188-b381-84108938de3d</cor:SOATransactionID></soapenv:Header>
<soapenv:Body xmlns:view="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">
<view:getSubscriptionDetailsResponse>
    <view:basicDetails>
        <view:subscriptionID>10466243</view:subscriptionID>
        <view:agreementNumber>1465935</view:agreementNumber>
        <view:accountNumber>2023655</view:accountNumber>
        <view:corporateNumber>KINSS</view:corporateNumber>
        <view:groupNumber>KINSS</view:groupNumber>
        <view:companyNumber>001</view:companyNumber>
        <view:salesAccountCode>55186</view:salesAccountCode>
        <view:subscriptionStatus>Normal</view:subscriptionStatus>
        <view:tariffCode>Q11JAE</view:tariffCode>
        <view:tariffDescription>Mobile Broadband 1GB</view:tariffDescription>
        <view:networkCode>CDIG</view:networkCode>
        <view:connectedDate>2011-06-14</view:connectedDate>
        <view:connectionReason>NB</view:connectionReason>
        <view:lastAmendedDate>2012-03-06T15:07:10.000Z</view:lastAmendedDate>
    </view:basicDetails>
</view:getSubscriptionDetailsResponse>
</soapenv:Body></soapenv:Envelope>
        */      
        
        // BASIC
        public String subscriptionID{ get; set; }
        public String agreementNumber{ get; set; }
        public String accountNumber{ get; set; }
        public String corporateNumber{ get; set; }
        public String groupNumber{ get; set; }
        public String companyNumber{ get; set; }
        public String salesAccountCode{ get; set; }
        public String subscriptionStatus{ get; set; }
        public String tariffCode{ get; set; }
        public String tariffDescription{ get; set; }
        public String networkCode{ get; set; }
        public String connectedDate{ get; set; }
        public String connectionReason{ get; set; }
        public String lastAmendedDate{ get; set; }
        
        // SERVICES
        public String packageCode{ get; set; }
        
        
        public SOAFault fault = null;
        
        public SubscriptionBasic(String xml) {
            
            if (isEmpty(xml)) throw new RequiredDataException('xml is required!');
                        
            Dom.XMLNode basicDetailsElem = getMainDataElem(xml);
            subscriptionID = getElemText(basicDetailsElem, MAN_NS, 'subscriptionID');
            agreementNumber = getElemText(basicDetailsElem, MAN_NS, 'agreementNumber');
            accountNumber = getElemText(basicDetailsElem, MAN_NS, 'accountNumber');
            corporateNumber = getElemText(basicDetailsElem, MAN_NS, 'corporateNumber');
            groupNumber = getElemText(basicDetailsElem, MAN_NS, 'groupNumber');
            companyNumber = getElemText(basicDetailsElem, MAN_NS, 'companyNumber');
            salesAccountCode = getElemText(basicDetailsElem, MAN_NS, 'salesAccountCode');
            subscriptionStatus = getElemText(basicDetailsElem, MAN_NS, 'subscriptionStatus');
            tariffCode = getElemText(basicDetailsElem, MAN_NS, 'tariffCode');
            tariffDescription = getElemText(basicDetailsElem, MAN_NS, 'tariffDescription');
            networkCode = getElemText(basicDetailsElem, MAN_NS, 'networkCode');
            connectedDate = getElemText(basicDetailsElem, MAN_NS, 'connectedDate');
            connectionReason = getElemText(basicDetailsElem, MAN_NS, 'connectionReason');
            lastAmendedDate = getElemText(basicDetailsElem, MAN_NS, 'lastAmendedDate');
            
            ///Dom.XMLNode serviceDetailsElem = ///
            // NOTES FROM ANDREW
            /*
            
populateSubscriptionBasic mobile # as input
'BASIC' + 'SERVICES'

BASIC
<view:tariffCode>Q40FGR</view:tariffCode

SERVICES
<view:packageCode>Q1S114</view:packageCode>


sf TABLES....

1) O2 Dise Map Mobile Bolton __c.Service Code where tariffCode = Q40FGR

returns service codes for tarrif that are compatible


2) 

O2 Dise Map Mobile __c filter by tarrif code and package code 

            */
            

        }
        
        private Dom.XMLNode getMainDataElem(String xml) {
            Dom.XMLNode bodyElem = getBodyElem(xml);
            if (bodyElem == null) throw new ResponseException('Failed to process response. Empty bodyElem!');               
            fault = new SOAFault(bodyElem); 
            if (fault.detected) throw new ResponseException('Fault: '+ fault.info);        
            Dom.XMLNode getSubscriptionDetailsResponseElem = bodyElem.getChildElement('getSubscriptionDetailsResponse', MAN_NS);            
            if (getSubscriptionDetailsResponseElem == null) throw new ResponseException('Failed to process response. Empty getSubscriptionDetailsResponseElem!');
            Dom.XMLNode basicDetailsElem = getSubscriptionDetailsResponseElem.getChildElement('basicDetails', MAN_NS);          
            if (basicDetailsElem == null) throw new ResponseException('Failed to process response. Empty basicDetailsElem!');
            return basicDetailsElem;
        }        
        
        public String getText() {
            return 'SubscriptionBasic:subscriptionID=' + subscriptionID + ':' +
                        'agreementNumber=' + agreementNumber + ':' +
                        'accountNumber=' + accountNumber + ':' +
                        'corporateNumber=' + corporateNumber + ':' +
                        'groupNumber=' + groupNumber + ':' +
                        'companyNumber=' + companyNumber + ':' +
                        'salesAccountCode=' + salesAccountCode + ':' +
                        'subscriptionStatus=' + subscriptionStatus + ':' +
                        'tariffCode=' + tariffCode + ':' +
                        'tariffDescription=' + tariffDescription + ':' +
                        'networkCode=' + networkCode + ':' +
                        'connectedDate=' + connectedDate + ':' +
                        'connectionReason=' + connectionReason + ':' +
                        'connectedDate=' + connectedDate + ':' +
                        'lastAmendedDate=' + lastAmendedDate;
                                
        }
                
    }   
        
    private String getSubscriptionBasicTestXml() {
        String retVal = null;
    
        if (testFault) {
            retVal = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            retVal += '<soapenv:Header>';
            retVal += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1" /></soapenv:Header>';
            retVal += '<soapenv:Body>';
            retVal += '<soapenv:Fault>';
            retVal += '<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:server</faultcode>';
            retVal += '<faultstring>Internal Error</faultstring>';
            retVal += '<detail>';
            retVal += '<Fault>';
            retVal += '<cor:SOAFaultOriginator xmlns:cor="http://soa.o2.co.uk/coredata_1">AG</cor:SOAFaultOriginator>';
            retVal += '<cor:SOAFaultCode xmlns:cor="http://soa.o2.co.uk/coredata_1">AG-100000-2000-F</cor:SOAFaultCode>';
            retVal += '<cor:faultDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">Internal Error</cor:faultDescription>';
            retVal += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1" /></Fault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        } else {        
            retVal = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            retVal += '<soapenv:Header xmlns:view="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
            retVal += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">ae0b5ebb-d01c-4188-b381-84108938de3d</cor:SOATransactionID></soapenv:Header>';
            retVal += '<soapenv:Body xmlns:view="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
            retVal += '<view:getSubscriptionDetailsResponse>';
            retVal += ' <view:basicDetails>';
            retVal += '     <view:subscriptionID>10466243</view:subscriptionID>';
            retVal += '     <view:agreementNumber>1465935</view:agreementNumber>';
            retVal += '     <view:accountNumber>2023655</view:accountNumber>';
            retVal += '     <view:corporateNumber>KINSS</view:corporateNumber>';
            retVal += '     <view:groupNumber>KINSS</view:groupNumber>';
            retVal += '     <view:companyNumber>001</view:companyNumber>';
            retVal += '     <view:salesAccountCode>55186</view:salesAccountCode>';
            retVal += '     <view:subscriptionStatus>Normal</view:subscriptionStatus>';
            retVal += '     <view:tariffCode>Q11JAE</view:tariffCode>';
            retVal += '     <view:tariffDescription>Mobile Broadband 1GB</view:tariffDescription>';
            retVal += '     <view:networkCode>CDIG</view:networkCode>';
            retVal += '     <view:connectedDate>2011-06-14</view:connectedDate>';
            retVal += '     <view:connectionReason>NB</view:connectionReason>';
            retVal += '     <view:lastAmendedDate>2012-03-06T15:07:10.000Z</view:lastAmendedDate>';
            retVal += ' </view:basicDetails>';
            retVal += '</view:getSubscriptionDetailsResponse>';
            retVal += '</soapenv:Body></soapenv:Envelope>';

        }
        return retVal;      
    }
    
    static testMethod void testSubscriptionBasic() {
        
        SubscriptionBasic sb = null;
        
        Boolean exceptFound = false;
        String xml = '<bod>test</bod>';
        try {
            sb = new SubscriptionBasic(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        exceptFound = false;
        try {
            sb = new SubscriptionBasic(null);
        } catch (RequiredDataException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound == true);
        
        
        exceptFound = false;
        FemtocellSOAHandler pfh = new FemtocellSOAHandler();
        pfh.testFault = true;
        xml = pfh.getSubscriptionBasicTestXml();
        try {
            sb = new SubscriptionBasic(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(exceptFound);
        
        
        exceptFound = false;
        pfh.testFault = false;
        xml = pfh.getSubscriptionBasicTestXml();
        try {
            sb = new SubscriptionBasic(xml);
        } catch (ResponseException ex) {
            exceptFound = true;
        }
        System.assert(!exceptFound);
        System.debug('sb.getText()='+sb.getText());     
        System.assert(sb.getText().contains('SubscriptionBasic:'));
        
    } 
    
    public void populateSubscriptionBasic(String subscriptionId, String primarySerialNumberType, String primarySerialNumber) {
        if (isEmpty(subscriptionId) && isEmpty(primarySerialNumber)) throw new RequiredDataException('subscriptionId or primarySerialNumber are required!');

        soaBase = new SOAServicesBase();        
        
        String sd = null;
        if (!isEmpty(subscriptionId)) {
            sd = getTag('psc:subscriptionID', subscriptionId);
            
        } else if(!isEmpty(primarySerialNumber)) {
            sd = getTag('psc:primarySerialNumber', 
                        getTag('psc:parameterType', stri(primarySerialNumberType)) + 
                        getTag('psc:parameterValue', primarySerialNumber)
                    );
            
        }
        
        String innerXML = getTag('view:getSubscriptionDetails', 
                                getTag('view:subscriptionData', sd) +
                                getTag('view:subscriptionDataFilters', 
                                    getTag('view:subscriptionDataFilter', 'BASIC') +
                                    getTag('view:subscriptionDataFilter', 'SERVICES')
                                    )
                                );
        
        String endPoint = null;        
        String resXml = null;
        
        System.debug('innerXML='+innerXML);
        
        if (Test.isRunningTest()) {
            resXml = getSubscriptionBasicTestXml();
        } else {
            endPoint = SOA_Integration_Settings__c.getValues('Manage_Business_Customer_Details').Endpoint__c;
            
            if (isEmpty(endPoint)) throw new RequiredDataException('endPoint is required!'); 
            
            resXml = soaBase.sendRequest(endPoint, ENVELOPE_XML_DISE, innerXML);            
        }    
        
        subscriptionBasic = new SubscriptionBasic(resXml);
        System.debug('subscriptionBasic.getText()='+ subscriptionBasic.getText());
    }
        
    
    public String getSubscriberProfileID() {
        return subscriberProfile.subscriberID;
    }
    
    public String getAdressListText() {
        if (addressList == null) {
            return '';
        } else {
            return addressList.getText();
        }
    }
    
    
    // HELPER METHODS
    
    public static String getTag(String tag, String content) {
        return '<' + tag + '>' + stri(content) + '</' + tag + '>';
    }
    
    public static String stri(String str) {
        if (str == null) {
            return '';
        } else {
            return str.trim();
        }
    }
    
    public static Boolean isEmpty(String str) {
        if (str == null) {
            return true;
        } else if (str.trim().length() == 0) {
            return true;
        } else {
            return false;
        }
    }
    
    public static String getElemText(Dom.XMLNode node, String nameSapce, String tag) {
        Dom.XMLNode childNode = node.getChildElement(tag, nameSapce);
        if (childNode == null) {
            return '';
        } else {
            return childNode.getText();
        }
    }    
    
    public static Dom.XMLNode getBodyElem(String xml) {
        if (isEmpty(xml)) throw new RequiredDataException('xml is required!');
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        Dom.XMLNode rootElem = doc.getRootElement();
        if (rootElem == null) throw new ResponseException('Failed to process response. Empty rootElem!');
        Dom.XMLNode bodyElem = rootElem.getChildElement('Body', BODY_NS);
        return bodyElem;
    }    
    
    
    // TEST STATIC HELPER METHODS
    
    static testMethod void testHelpers() {
        
        System.assert(FemtocellSOAHandler.getTag('aa', 'bb').equalsIgnoreCase('<aa>bb</aa>'));
        System.assert(FemtocellSOAHandler.stri(null).equalsIgnoreCase(''));
        System.assert(FemtocellSOAHandler.stri('dfd ').equalsIgnoreCase('dfd'));
        System.assert(FemtocellSOAHandler.isEmpty(null)==true);
        System.assert(FemtocellSOAHandler.isEmpty('dd')==false);
        
        // getElemText
        String xml = '<?xml version="1.0" encoding="utf-8"?><responseblock version="3.67">  <requestreference>X9093110</requestreference>  <response type="ERROR">    <timestamp>2012-03-26 15:09:29</timestamp>    <error>      <message>Invalid field</message>      <code>30000</code>      <data>pan</data>    </error>  </response></responseblock>';
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        String errorMessage = '';
        Dom.XMLNode responseRootElem = doc.getRootElement();
        for(Dom.XmlNode node1 : responseRootElem.getChildElements()) {
            System.debug(node1.getName());
            if (node1.getName()=='response') {
                if (node1.getAttribute('type', '').equalsIgnoreCase('ERROR')) {
                    for(Dom.XmlNode node2 : node1.getChildElements()) {
                        if (node2.getName()=='error') {
                            System.assert(FemtocellSOAHandler.getElemText(node2, null, 'message') == 'Invalid field');
                        }
                    }
                }
            }
        }
        
        // See testSOAFault for getBoyElem testing
        
    }
    
    
    // TEST PUBLIC METHODS

    
    static testMethod void testPopulateSubscriberProfile() {
            
        // Test SOA nromal response
        FemtocellSOAHandler handler =  new FemtocellSOAHandler();
        handler.testFault = false;
        String subscriberID = FemtocellSOAHandler.TEST_GOOD_SUBSCRIBER_ID;
        handler.populateSubscriberProfile(subscriberID);
        System.debug('subscriberID=handler.getSubscriberProfileID()'+subscriberID+'|'+handler.getSubscriberProfileID());
        System.assert(handler.getSubscriberProfileID().equalsIgnoreCase(subscriberID));
        
        // Test SOA error response
        Boolean didFail = false;
        subscriberID = 'kk';
        handler.testFault = true;
        try {
            handler.populateSubscriberProfile(subscriberID);
        } catch (Exception e) {
            System.debug('e.getMessage()='+e.getMessage());
            System.assert(e.getMessage().contains('Invalid'));          
            didFail = true;
        }
        System.assert(didFail);        
        
    }
    
  
    
    static testMethod void testPopulateAccountBasicAndAddress() {
        Boolean didFail = false;
        FemtocellSOAHandler handler =  new FemtocellSOAHandler();
        handler.testFault = true;
        try {
            handler.populateAccountBasicAndAddress('fff');
        } catch (Exception e) {
            System.debug('e.getMessage()='+e.getMessage());
            didFail = true;
        }
        System.assert(didFail);

        handler.testFault = false;

        try {
            handler.populateAccountBasicAndAddress('fff');
            didFail = false;
        } catch (Exception e) {
            System.debug('e.getMessage()='+e.getMessage());
            didFail = true;
        }
        System.assert(!didFail);
        System.assert(handler.accountBasicAndAddress.getText().contains('AccountBasicAndAddress'));
    }
    
    static testMethod void testPopulateSubscriptionBasic() {
        Boolean didFail = false;
        FemtocellSOAHandler handler =  new FemtocellSOAHandler();
        handler.testFault = true;
        try {
            handler.populateSubscriptionBasic('fff', '', '');
        } catch (Exception e) {
            System.debug('e.getMessage()='+e.getMessage());
            didFail = true;
        }
        System.assert(didFail);

        handler.testFault = false;

        try {
            handler.populateSubscriptionBasic('fff', '', '');
            didFail = false;
        } catch (Exception e) {
            System.debug('e.getMessage()='+e.getMessage());
            didFail = true;
        }
        System.assert(!didFail);
        //System.assert(handler.subscriptionBasic.getText().contains('AccountBasicAndAddress'));
    }
    
    static testMethod void testPopulateAddresses() {
        
        FemtocellSOAHandler handler =  new FemtocellSOAHandler();       
        
        String organisation;
        String buildingName;
        String buildingNumber;
        String postcode;
        organisation = '';
        buildingName = '';
        buildingNumber = '*';
        postcode = 'SL9 8RG'; 
        
        // Test normal response 
        handler.testFault = false;           
        handler.populateAddresses(organisation, buildingName, buildingNumber, postcode);
        System.assert(handler.getAdressListText().contains('AddressList:'));    
        
        // Test fault response
        handler.testFault = true;
        Boolean exceptFound = false;
        try {           
            handler.populateAddresses(organisation, buildingName, buildingNumber, postcode);
        } catch (ResponseException re) {
            exceptFound = true;
        }
        System.assert(exceptFound); 
        

        // Test normal response 
        handler.testFault = false;   
        organisation = '';
        buildingName = '';
        buildingNumber = '*';
        postcode = 'SL9 8RG';             
        buildingNumber = '13';
        String street = 'south view road';
        String postTown = 'gerrards cross';   
        String subBuildingName;
        String dependentStreet;
        String dependentLocality;
        String locality;
        String county;
        handler.populateAddresses(organisation,subBuildingName, buildingName, buildingNumber, street, postTown, dependentStreet, dependentLocality, locality, county, postcode);
        System.assert(handler.getAdressListText().contains('AddressList:'));            
                
        
        // Test fault response
        handler.testFault = true;
        exceptFound = false;
        try {           
            handler.populateAddresses(organisation,subBuildingName, buildingName, buildingNumber, street, postTown, dependentStreet, dependentLocality, locality, county, postcode);
        } catch (ResponseException re) {
            exceptFound = true;
        }
        System.assert(exceptFound == true); 
        
            
    }
   
    public static String addTxt(String mainTxt, String addTxt) {
        String retVal = '';
        if (mainTxt != null) {
            retVal = mainTxt.trim();
        } 
        if (retVal.length() == 0) {
            retVal = addTxt;
        } else {
            if (addTxt != null && addTxt.trim().length() > 0) {
                retVal += ', ' + addTxt;
            }
        }
        return retVal;
    
    }
        

}