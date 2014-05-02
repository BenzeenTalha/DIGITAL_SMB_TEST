/*
*       This class is the controller for the PAF Address page
*       It is used to call the PAF Address service to retrieve the Address details and save them to an account billing address
*       Revision History 
*       1.0    20/07/2011  Initial Version
*/ 
public with sharing class AddressCheckController {

    private Account acc;
    public string addresses {public get; set;}
    public string requestMessage {get; private set;}
    private static final string PSC_NS = 'http://soa.o2.co.uk/pscommonpostpaydata_1';
    private static final string VPAD_NS = 'http://soa.o2.co.uk/viewpostaladdressdata_1';
    private static final string BODY_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final string CORE_NS = 'http://soa.o2.co.uk/coredata_1';
    private static final string MSG_NO_POSTCODE = 'Please provide the Postcode for this type of search';
    private static final string MSG_NO_BUILDING_NAME_NUMBER = 'Please provide the Building Name or Number for this type of search';
    private static final string MSG_NO_STREET_TOWN = 'Please provide the Street and Postal Town for this type of search';
    private static final string MSG_ACCESS_RIGHTS = 'Insufficient access to update address';
    private static final string MSG_SAVE_ERR = 'Could not save address details';
    
    public String detailedBuildingName { get; set; }
    public String detailedBuildingNumber { get; set; }
    
    public String outputMessage { get; set; }
    public String organisation{ get; set; }
    public String buildingNumber { get; set; }
    public String subBuildingName { get; set; }
    public String buildingName { get; set; }
    public String street { get; set; }
    public String dependentStreet { get; set; }
    public String dependentLocality { get; set; }
    public String locality { get; set; }
    public String county { get; set; }
    public String postTown { get; set; }
    public String postcode { get; set; }
    public List<Address> addressResults { get; set; }
        
    public AddressCheckController() {
        detailedBuildingName = '';
        detailedBuildingNumber = '';
        postTown = '';
        buildingName = '';
        buildingNumber = '';
        postcode = '';
        String callbackfunction = ApexPages.currentPage().getParameters().get('CallbackFunction');
        if(callbackfunction!=null) addressLookup();
    }
    
    public AddressCheckController(ApexPages.StandardController controller) {
        this();
        acc = (Account)controller.getRecord();
        acc = [select id, billingpostalcode, billingstreet, billingcity from account where id=:acc.Id];
        
        buildingNumber = acc.billingstreet;
        posttown = acc.billingcity;
        postcode = acc.billingpostalcode;
    }

 
    
    public class Address {
        public boolean selected {get; set;}
        public String organisation{ get; set; }
        public String buildingNumber { get; set; }
        public String subBuildingName { get; set; }
        public String buildingName { get; set; }
        public String street { get; set; }
        public String dependentStreet { get; set; }
        public String dependentLocality { get; set; }
        public String locality { get; set; }
        public String county { get; set; }
        public String postTown { get; set; }
        public String postcode { get; set; }
    }


    public PageReference addressLookup() {
        SOAViewPostalAddress port = new SOAViewPostalAddress();
        String buildingNumber = ApexPages.currentPage().getParameters().get('buildingnumber');
        String callbackfunction = ApexPages.currentPage().getParameters().get('CallbackFunction');
        String postcode= ApexPages.currentPage().getParameters().get('postcode');
        Dom.Document doc =  port.getAddressMatch('', '',buildingNumber,postcode);
        Dom.XMLNode root= doc.getRootElement();
        Dom.XMLNode body = root.getChildElement('Body',BODY_NS);
        Dom.XMLNode getAddressMatchResponse= body.getChildElement('getAddressMatchResponse',VPAD_NS );
        parseResults(getAddressMatchResponse);
        requestMessage = port.requestMessage;            
        addresses = callbackfunction + parseResultsToJSON();    
        return null;
    }
    

    
    private String parseResultsToJSON() {
        String op = '([';
        Integer count = 0;
        for(Address a: addressResults) {
            if(count!=0) op += ',';
            count++;
            op += '{';
            op += '"Udprn":"1","Department":"",';
            op += '"Company":"'+a.organisation+'",';
            op += '"BuildingNumber":"'+a.buildingNumber+'",';
            op += '"BuildingName":"'+a.subBuildingName+'",';
            op += '"SubBuilding":"'+a.subBuildingName+'",';
            op += '"Line1":"'+a.buildingNumber+'",';
            //op += '"Line2":""';
            op += '"Line2":"'+a.street+'",';
            op += '"PrimaryStreet":"'+a.street+'",';
            op += '"County":"'+a.county+'",';
            op += '"PostTown":"'+a.postTown+'",';    
            op += '"Postcode":"'+a.postcode+'"';          
            op += '}';
        }
        op+=']);';
        return op;
    }     
            
    public PageReference addressMatch() {
    /*
        if(detailedBuildingName.trim().length()==0 && detailedBuildingNumber.trim().length()==0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + MSG_NO_BUILDING_NAME_NUMBER));
            return null;        
        }    
        if(street.trim().length()==0 && postTown.trim().length()==0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + MSG_NO_STREET_TOWN));
            return null;        
        }   */      
        addressResults = new List<Address>();
        SOAViewPostalAddress port = new SOAViewPostalAddress();
        organisation = organisation==null?'':organisation;
        Dom.Document doc = port.searchAddress(organisation.trim(),'',buildingName.trim(),buildingNumber.trim(),street.trim()+'*',postTown.trim()+'*','','','','','');
        outputMessage = doc.toXmlString();
        Dom.XMLNode root= doc.getRootElement();
        Dom.XMLNode body = root.getChildElement('Body',BODY_NS);
        Dom.XMLNode searchAddressResponse = body.getChildElement('searchAddressResponse',VPAD_NS);
        requestMessage = port.requestMessage;   
        if(searchAddressResponse ==null) {
            parseFault(body);            
        } else {
            parseResults(searchAddressResponse );
        }        
        return null;
    }
       
        
        
    public PageReference addressSearch() {
        /*
        if(postcode.trim().length()==0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + MSG_NO_POSTCODE));
            return null;        
        }*/
        addressResults = new List<Address>();
        SOAViewPostalAddress port = new SOAViewPostalAddress();
        buildingName = '';
        buildingNumber = buildingNumber == ''?'*':buildingNumber;
        organisation = organisation==null?'':organisation;
        Dom.Document doc =  port.getAddressMatch(organisation.trim(), buildingName.trim(),buildingNumber.trim(),postcode.trim().toUpperCase()); 
        outputMessage = doc.toXmlString();
        Dom.XMLNode root= doc.getRootElement();
        Dom.XMLNode body = root.getChildElement('Body',BODY_NS);
        Dom.XMLNode getAddressMatchResponse= body.getChildElement('getAddressMatchResponse',VPAD_NS );
        if(getAddressMatchResponse==null) {
            parseFault(body);            
        } else {
            parseResults(getAddressMatchResponse);
        }
        requestMessage = port.requestMessage;   
        return null;
    }
    
    private void parseResults(Dom.XMLNode results) {
        addressResults = new List<Address>();
        if(results==null) return;
        Integer count = results.getChildElements().size();
        for(Dom.XMLNode address: results.getChildElements()) {
                
            Dom.XMLNode organisation= address.getChildElement('organisation',PSC_NS);
            Dom.XMLNode subBuildingName = address.getChildElement('subBuildingName',PSC_NS);
            Dom.XMLNode buildingNumber = address.getChildElement('buildingNumber',PSC_NS);
            Dom.XMLNode buildingName = address.getChildElement('buildingName',PSC_NS);
            Dom.XMLNode street = address.getChildElement('street',PSC_NS);
            Dom.XMLNode dependentStreet= address.getChildElement('dependentStreet',PSC_NS);
            Dom.XMLNode dependentLocality = address.getChildElement('dependentLocality',PSC_NS);
            Dom.XMLNode locality= address.getChildElement('locality',PSC_NS);
            Dom.XMLNode county= address.getChildElement('county',PSC_NS);
            Dom.XMLNode postTown = address.getChildElement('postTown',PSC_NS);            
            Dom.XMLNode postcode= address.getChildElement('postcode',PSC_NS);
            
            Address a = new Address();
            if(count==1) {
                a.selected = true;
            } else {
                a.selected = false;
            }
            a.organisation= organisation!=null?organisation.getText():'';
            a.buildingNumber = buildingNumber!=null?buildingNumber.getText():'';
            a.subBuildingName = subBuildingName!=null? subBuildingName.getText():'';
            a.buildingName = buildingName!=null? buildingName.getText():'';
            a.street = street!=null? street.getText():'';
            a.dependentStreet= dependentStreet!=null? dependentStreet.getText():'';
            a.dependentLocality = dependentLocality!=null? dependentLocality.getText():'';
            a.locality= locality!=null? locality.getText():'';
            a.county = county!=null? county.getText():'';
            a.postTown = postTown!=null? postTown.getText():'';
            a.postcode = postcode!=null? postcode.getText():'';            
            addressResults.add(a);
        }
    }  
    
    private void parseFault(Dom.XMLNode body) {
        Dom.XMLNode fault = body.getChildElement('Fault',BODY_NS );
        String strFault = fault!=null?fault.getText():'';
        
        Dom.XMLNode faultCode = fault.getChildElement('faultcode',null);
        String strFaultCode = faultCode!=null?faultCode.getText():'';
        
        Dom.XMLNode faultString = fault.getChildElement('faultstring',null);
        String strFaultString = faultString!=null?faultString.getText():'';
        
        Dom.XMLNode faultDetail = fault.getChildElement('detail',null);
        String strFaultDetail = faultDetail!=null?faultDetail .getText():'';
        
        //if(faultDetail!=null) {
        //    Dom.XMLNode faultInner= faultDetail.getChildElement('Fault',null);
        //    String strFaultInner= faultInner!=null?faultInner.getText():'';
        //}
        
        Dom.XMLNode SOAfaultOriginator = fault.getChildElement('SOAFaultOriginator',CORE_NS );
        String strSOAfaultOriginator = SOAfaultOriginator !=null?SOAfaultOriginator .getText():'';
        
        Dom.XMLNode SOAfaultCode = fault.getChildElement('SOAFaultCode',CORE_NS );
        String strSOAfaultCode = SOAfaultCode!=null?SOAfaultCode.getText():'';
        
        Dom.XMLNode SOAfaultString = fault.getChildElement('faultDescription',CORE_NS );    
        String strSOAfaultString = SOAfaultString!=null?SOAfaultString .getText():'';
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strFaultString));
        System.debug('[Fault Code: '+ strFaultCode + '][Fault Description: '+strFaultString+'][SOA Fault Code: '+strSOAfaultCode+'][SOA Fault Description: '+strSOAfaultString+']');
    }  
    
    public PageReference save() {
        if (!Schema.sObjectType.Account.fields.billingstreet.isUpdateable() || 
                !Schema.sObjectType.Account.fields.billingcity.isUpdateable() || 
                !Schema.sObjectType.Account.fields.billingstate.isUpdateable() || 
                !Schema.sObjectType.Account.fields.billingpostalcode.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MSG_ACCESS_RIGHTS ));
            return null;
        }        
        if(addressResults!=null && !addressResults.isEmpty()) {
            for(Address address : addressResults) {
                if(address.selected==true) {
                    String billingStreet = '';
                    billingstreet = address.buildingName;
                    if(billingstreet!='') billingstreet+=' ';
                    billingstreet += address.buildingNumber;
                    if(billingstreet!='') billingstreet+='\n';
                    billingstreet += address.street;
                    acc.billingstreet = billingstreet;
                    acc.billingcity = address.postTown;
                    acc.billingstate = address.county;
                    acc.billingpostalcode = address.postcode;            
                        
                }
            }
        }
        try {
            update acc; 
            PageReference acctPage = new ApexPages.StandardController(acc).view();
            acctPage.setRedirect(true); 
            return acctPage; 
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + MSG_SAVE_ERR +' : ['+e.getMessage()+']'));
            return null;
        }
    }    
    
    static testMethod void testAddressCheckController () {
        Account acc = new Account(name='test');
        insert acc;
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AddressCheckController addrCC = new AddressCheckController(sc);
        addrCC.detailedBuildingName='Test';
        addrCC.detailedBuildingNumber='11';
        addrCC.buildingNumber='11';
        addrCC.street='Test';
        addrCC.postTown='Test';
        addrCC.postcode='A11 1AA';        
        addrCC.addressMatch();      
        addrCC.addressSearch();
        ApexPages.currentPage().getParameters().put('buildingnumber','');
        ApexPages.currentPage().getParameters().put('CallbackFunction','');
        ApexPages.currentPage().getParameters().put('postcode','');  
        addrCC.addressLookup();
        addrCC.save();
        acc = [select id, name, billingStreet from account where id=:acc.Id];
        System.assertEquals('testStreet',acc.billingStreet);
    }
    
    static testMethod void testAddressCheckControllerFaults () {
        boolean errorFound = false;
        Account acc = new Account(name='test');
        insert acc;
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AddressCheckController addrCC = new AddressCheckController(sc);
        addrCC.detailedBuildingName='Test';
        addrCC.detailedBuildingNumber='11';
        addrCC.buildingNumber='11';
        addrCC.street='Test';
        addrCC.postTown='Test';
        addrCC.postcode='THROW FAULT';        
        addrCC.addressSearch();      
        ApexPages.Message[] mssgs = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs){
           if(m.getDetail().contains('PostCode Format Validation'))
              errorFound=true;
        }
    }
    
}