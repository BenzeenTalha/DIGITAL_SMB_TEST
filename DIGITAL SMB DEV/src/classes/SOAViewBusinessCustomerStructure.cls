public class SOAViewBusinessCustomerStructure extends SOAServicesBase {
    
    static final String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:view="http://soa.o2.co.uk/viewbusinesscustomerstructuredata_2">';
    //static final String endpointSuffix = '/services/ViewBusinessCustomerStructure_2_0';
    static final String endpoint = SOA_Integration_Settings__c.getValues('View_Business_Customer_Structure').Endpoint__c;

    public String agreementNumber { get; set; }
    public String statusFilter { get; set; }
    public String customerLevelId { get; set; }
    public String customerLevel { get; set; }
    public String accountNumber { get; set; }

    public PageReference run() {
        String ctype = ApexPages.currentPage().getParameters().get('type');
        if(ctype=='getSubscriptions') return getSubscriptions();
        if(ctype=='getAgreements') return getAgreements();
        if(ctype=='getSubscriptionsForAgreement') return getSubscriptionsForAgreements();
        else return getSubscriptions();    
    }
            
    public PageReference getAgreements() {
        String innerXML = '';
        innerXML +='<view:getAgreements>';
        innerXML +='    <view:accountNumber>'+accountNumber+'</view:accountNumber>';
        innerXML +='</view:getAgreements>';
        sendRequest(endpoint,envelopeXML,innerXML );
        return null;
    }        
    
     
    public PageReference getSubscriptions() {
        String innerXML = '';
        innerXML +='<view:getSubscriptions>';
        innerXML +='    <view:customerLevel>'+customerLevel+'</view:customerLevel>';
        innerXML +='    <view:customerLevelId>'+customerLevelId+'</view:customerLevelId>';
        if(statusFilter!=null) {
            //<!--Optional:-->'
            innerXML +='    <view:statusFilter>'+statusFilter+'</view:statusFilter>';
        }
        innerXML +='</view:getSubscriptions>';
        sendRequest(endpoint,envelopeXML,innerXML );
        return null;
    }    
    
    public PageReference getSubscriptionsForAgreements() {
        String innerXML = '';
        innerXML +='<view:getSubscriptionsForAgreement>';
        innerXML +='    <view:agreementNumber>'+agreementNumber+'</view:agreementNumber>';
        innerXML +='</view:getSubscriptionsForAgreement>';
        sendRequest(endpoint,envelopeXML,innerXML );
        return null;
    }    
    
    static testMethod void testSOAViewBusinessCustomerStructure() {
        SOAViewBusinessCustomerStructure controller = new SOAViewBusinessCustomerStructure();
        controller.getAgreements();
        controller.getRequestXML();
        controller.getResultXML();
        controller.getSubscriptions();
        controller.getSubscriptionsForAgreements();
        // TODO: Add Asserts here    
    }
        
}