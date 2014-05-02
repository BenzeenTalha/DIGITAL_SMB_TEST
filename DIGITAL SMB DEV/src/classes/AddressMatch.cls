/*
*       This class is a controller to test the BT Address Match Service functionality
*       SO'Halloran - (SFDC)
*       Revision History 
*       1.0    10/03/2011  Initial Version
*/   
public with sharing class AddressMatch {
    

    public String OrganisationName {get; private set;}
    public String poBox {get; private set;}
    public String subPremises {get; private set;}
    public String premisesName {get; private set;}
    public String thoroughfareNumber {get; private set;}
    public String dependentThoroughfareName {get; private set;}
    public String thoroughfareName {get; private set;}
    public String doubleDependentLocality {get; private set;}
    public String locality {get; private set;}
    public String postTown {get; private set;}
    public String county {get; private set;}
    public String postcode {get; private set;}
    public String country {get; private set;}   
    
    public String addressKey {get; private set;}
    public String referenceDate {get; private set;}
    public String qualifier {get; private set;}
    public String districtCode {get; private set;}
    //public String cssDatabaseCode {get; private set;} 
    public String exchangeGroupCode {get; private set;}
    
    public String inputOrganisationName {get; set;}
    public String inputpoBox {get; set;}
    public String inputsubPremises {get; set;}
    public String inputpremisesName {get; set;}
    public String inputthoroughfareNumber {get; set;}
    public String inputdependentThoroughfareName {get; set;}
    public String inputthoroughfareName {get; set;}
    public String inputdoubleDependentLocality {get; set;}
    public String inputlocality {get; set;}
    public String inputpostTown {get; set;}
    public String inputcounty {get; set;}
    public String inputpostcode {get; set;}
    public String inputcountry {get; set;}
        
    public AddressMatch () {}
    public class CustomException extends Exception {}
    public PageReference addressMatch() {
        SOAViewFixedLineAvailabilityData.britishAddressType inputAddress;       
        try {
            inputAddress = new SOAViewFixedLineAvailabilityData.britishAddressType();
            inputAddress.OrganisationName = inputOrganisationName;
            inputAddress.poBox = inputpoBox;
            inputAddress.subPremises = inputsubPremises;
            inputAddress.premisesName = inputpremisesName;
            inputAddress.thoroughfareNumber = inputthoroughfareNumber;
            inputAddress.dependentThoroughfareName = inputdependentThoroughfareName;
            inputAddress.thoroughfareName = inputthoroughfareName;
            inputAddress.doubleDependentLocality = inputdoubleDependentLocality;
            inputAddress.locality = inputlocality;
            inputAddress.postTown = inputpostTown;
            inputAddress.county = inputcounty;
            inputAddress.postcode = inputpostcode;
            inputAddress.country = inputcountry;
    
            SOAViewFixedLineAvailabilityService.ViewFixedLineAvailabilityPort port = 
                new SOAViewFixedLineAvailabilityService.ViewFixedLineAvailabilityPort();
            port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            port.timeout_x = SoaUtils.SOA_TIMEOUT;
            SOAViewFixedLineAvailabilityData.getBTAddressMatch_1Response am;
            if(!Test.isRunningTest()) {
            	am = port.getBTAddressMatch_1(inputAddress);
            } else {
            	if(inputthoroughfareName == 'testError') {
            		throw new CustomException('testError');
            	} else {
	            	am = new SOAViewFixedLineAvailabilityData.getBTAddressMatch_1Response();
	            	am.addressReference = new SOAOpenreachPSCommonOpenreach.btAddressReferenceType();
	            	am.addressReference.addressKey = 'test';
	            	am.matchedAddress = new SOAViewFixedLineAvailabilityData.britishAddressType();
	            	am.matchedAddress.dependentThoroughfareName = 'test street';
            	}
            }
            SOAViewFixedLineAvailabilityData.britishAddressType matchedAddress = am.matchedAddress;
            SOAOpenreachPSCommonOpenreach.btAddressReferenceType addressReference = am.addressReference;
             
            organisationName = matchedAddress.organisationName;
            poBox = matchedAddress.poBox;
            subPremises = matchedAddress.subPremises;
            premisesName = matchedAddress.premisesName;
            thoroughfareNumber = matchedAddress.thoroughfareNumber;
            dependentThoroughfareName = matchedAddress.dependentThoroughfareName;
            thoroughfareName = matchedAddress.thoroughfareName;
            doubleDependentLocality = matchedAddress.doubleDependentLocality;
            locality = matchedAddress.locality;
            postTown = matchedAddress.postTown;
            county = matchedAddress.county;
            postcode = matchedAddress.postcode;
            country = matchedAddress.country;   
            
            addressKey = addressReference.addressKey;
            referenceDate = addressReference.referenceDate;
            qualifier = addressReference.qualifier;
            districtCode = addressReference.districtCode;
            //cssDatabaseCode = addressReference.cssDatabaseCode;
            exchangeGroupCode = addressReference.exchangeGroupCode;                     
        
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            organisationName = '';
            poBox = '';
            subPremises = '';
            premisesName = '';
            thoroughfareNumber = '';
            dependentThoroughfareName = '';
            thoroughfareName = '';
            doubleDependentLocality = '';
            locality = '';
            postTown = '';
            county = '';
            postcode = '';
            country = '';   
            
            addressKey = '';
            referenceDate = '';
            qualifier = '';
            districtCode = '';
            //cssDatabaseCode = '';
            exchangeGroupCode = '';            
        }
        return null;
    }    
    
    // Related Service Tests to be moved to a specific Test class
        static testMethod void testAddressMatch() {
			AddressMatch am = new AddressMatch();
			am.inputthoroughfareName = 'test';
			am.addressMatch();
			System.assertEquals('test street',am.dependentThoroughfareName);
        }  
        
        static testMethod void testAddressMatchError() {
			AddressMatch am = new AddressMatch();
			am.inputthoroughfareName = 'testError';
			am.addressMatch();
			System.assertEquals('',am.dependentThoroughfareName);
        }          
        
        static testMethod void testSOASecurityElement() {
                SOASecurityElement.Security_element securityElement = new SOASecurityElement.Security_element('username', 'password');
                SOASecurityElement.UsernameToken_element unToken = securityElement.usernameToken;
                system.assertEquals(unToken.username, 'username');
                system.assertEquals(unToken.password, 'password');
        }     
        
        static testMethod void testSOAViewPostalAddressData() {
                SOAViewPostalAddressData.getAddressMatch addressMatch = new SOAViewPostalAddressData.getAddressMatch();
                addressMatch.buildingName='test';
                addressMatch.buildingNumber='test';
                addressMatch.postcode='test';
                SOAViewPostalAddressData.requestAddressType t = new SOAViewPostalAddressData.requestAddressType();
                t.buildingName = '';
                t.buildingNumber = '';
                t.county = '';
                t.dependentLocality = '';
                t.dependentStreet = '';
                t.locality = '';
                t.organisation = '';
                t.postcode = '';
                SOAViewPostalAddressData.searchAddress addressSearch = new SOAViewPostalAddressData.searchAddress();
                addressSearch.address = t;
        }    
                
        static testMethod void testSearchAddress() {
        SOAViewPostalAddressService.ViewPostalAddressPort port = new SOAViewPostalAddressService.ViewPostalAddressPort();
        port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
        port.timeout_x = SoaUtils.SOA_TIMEOUT;
                SOAViewPostalAddressData.requestAddressType address = new SOAViewPostalAddressData.requestAddressType();
                address.postcode='SSSAAA';
                SOAViewPostalAddressData.searchAddressResponse response = new SOAViewPostalAddressData.searchAddressResponse();
        response.address = port.searchAddress(address);     
        }
 
        static testMethod void testGetAddressMatch() {
        SOAViewPostalAddressService.ViewPostalAddressPort port = new SOAViewPostalAddressService.ViewPostalAddressPort();
        port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
        port.timeout_x = SoaUtils.SOA_TIMEOUT;
                SOAViewPostalAddressData.requestAddressType address = new SOAViewPostalAddressData.requestAddressType();
                address.postcode='SSSAAA';
                SOAViewPostalAddressData.getAddressMatchResponse response = new SOAViewPostalAddressData.getAddressMatchResponse();
        response.address = port.getAddressMatch('buildingName', '11', 'LL27XX'); 
        }           
}