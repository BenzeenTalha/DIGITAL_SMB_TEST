public with sharing class SOASearchBusinessCustomerDetails extends SOAServicesBase  {
    
    static final String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sear="http://soa.o2.co.uk/searchbusinesscustomerdetailsdata_1">';
    static final String endpoint = SOA_Integration_Settings__c.getValues('Search_Business_Customer_Details').Endpoint__c;

    public String postcode { get; set; }
    public String name { get; set; }
    public String address { get; set; }
    public String customerLevel { get; set; }

    public PageReference run() {
        return getBusinessCustomerbyCriteria();    
    }
        
    public PageReference getBusinessCustomerbyCriteria() {
        String innerXML = '';
        innerXML +='<sear:getBusinessCustomerbyCriteria>';
        innerXML +='<sear:postcode>'+postcode+'</sear:postcode>';
        innerXML +='<sear:name>'+name+'</sear:name>';
        innerXML +='<sear:address>'+address+'</sear:address>';
        innerXML +='<sear:customerLevel>'+customerLevel+'</sear:customerLevel>';
        innerXML +='</sear:getBusinessCustomerbyCriteria>';
        sendRequest(endpoint,envelopeXML,innerXML );
        return null;
    }            
/*
      <sear:getBusinessCustomerbyCriteria>
         <sear:postcode>?</sear:postcode>
         <!--Optional:-->
         <sear:name>?</sear:name>
         <!--Optional:-->
         <sear:address>?</sear:address>
         <sear:customerLevel>?</sear:customerLevel>
      </sear:getBusinessCustomerbyCriteria>

*/                    
    
    static testMethod void testSOASearchBusinessCustomerDetails  () {
        SOASearchBusinessCustomerDetails controller = new SOASearchBusinessCustomerDetails  ();
        controller.getBusinessCustomerbyCriteria();
        // TODO: Add Asserts here    
    }
        

}