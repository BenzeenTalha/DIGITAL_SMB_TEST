public class SOAManageBusinessBoltons extends SOAServicesBase {

    //static final String ENDPOINTSUFFIX = '/services/ManageBusinessBoltons_1_1';    
    static final String ENVELOPEXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://soa.o2.co.uk/dise/managebusinessboltonsdata_1">';
    static final String endpoint = SOA_Integration_Settings__c.getValues('Manage_Business_Boltons').Endpoint__c;
    
    public String propertyValue { get; set; }
    public String propertyName { get; set; }
    public String activationDate { get; set; }
    public String expiryDate { get; set; }
    public String externalIdentifier { get; set; }
    public String[] boltonType { get; set; }
    public String customerIdReference { get; set; }
    public String subscriberId { get; set; }
    public String agreementNumber { get; set; }
    public String subscriptionId { get; set; }
   
    
    public PageReference run() {
        String ctype = ApexPages.currentPage().getParameters().get('type');
        if(ctype=='addBolton') return addBolton();
        if(ctype=='removeBolton') return removeBolton();
        if(ctype=='setBolton') return setBolton();
        if(ctype=='getCurrentBoltons') return getCurrentBoltons();
        if(ctype=='getAgreementBoltons') return getAgreementBoltons();
        if(ctype=='getValidBoltons') return getValidBoltons();
        else return addBolton();    
    }
    
    public PageReference addBolton() {
        String innerXML = '<man:addBolton>'+getAddSetBoltonXML()+'</man:addBolton>';
        if(checkAccess()) sendRequest(endpoint,envelopeXML,innerXML);
        return null;
    }
    
    public PageReference setBolton() {
        String innerXML = '<man:setBolton>'+getAddSetBoltonXML()+'</man:setBolton>';
        if(checkAccess()) sendRequest(endpoint,envelopeXML,innerXML);
        return null;
    } 
    
    public PageReference removeBolton() {
        String innerXML = '';    
        innerXML +='<man:removeBolton>';
        innerXML += getCustomerIdXML();
        innerXML +='<man:customerIdReference>'+customerIdReference+'</man:customerIdReference>';
        innerXML +='<man:externalIdenitifier>'+externalIdentifier+'</man:externalIdenitifier>';
        innerXML +='<man:expiryDate>'+expiryDate+'</man:expiryDate>';
        innerXML +='</man:removeBolton>';
        if(checkAccess()) sendRequest(endpoint,envelopeXML,innerXML);
        return null;
    }
    
        
    public PageReference getCurrentBoltons() {
        String innerXML = '<man:getCurrentBoltons>'+ getBoltonXML()+'</man:getCurrentBoltons>';
        sendRequest(endpoint,envelopeXML,innerXML);
        return null;
    }    
    
    public PageReference getValidBoltons() {
        String innerXML = '<man:getValidBoltons>'+ getBoltonXML()+'</man:getValidBoltons>';
        sendRequest(endpoint,envelopeXML,innerXML);
        return null;
    }    
    
    public PageReference getAgreementBoltons() {
        String innerXML = '';
        innerXML +='<man:getAgreementBoltons>';
        innerXML +='<man:agreementNumber>'+agreementNumber+'</man:agreementNumber>';
        innerXML +='</man:getAgreementBoltons>';
        sendRequest(endpoint,envelopeXML,innerXML);
        return null;
    } 

    private boolean checkAccess() {
        // Do not allow write calls to live services
        try {
            SOAUtils.liveCheckOnWriteServices(endpoint);
        } catch (exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return false;
        }   
        return true;
    }
    
    private String getAddSetBoltonXML() {
        String innerXML = '';  
        innerXML += getCustomerIdXML();
        innerXML +='<man:customerIdReference>'+customerIdReference+'</man:customerIdReference>';
        innerXML +='<man:externalIdentifier>'+externalIdentifier+'</man:externalIdentifier>';
        innerXML +='<man:activationDate>'+activationDate+'</man:activationDate>';
        //<!--Optional:-->
        innerXML += getBoltonPropertiesXML();   
        return innerXML; 
    }
    
    private String getBoltonXML() {
        String innerXML = ''; 
        innerXML += getCustomerIdXML();
        innerXML +='<man:customerIdReference>'+customerIdReference+'</man:customerIdReference>';
        //<!--Zero or more repetitions:-->
        innerXML += getBoltonTypeXML(); 
        return innerXML;   
    }
        
    private String getBoltonTypeXML() {
        String innerXML ='';
        if(boltonType!=null) {
            for(String btype : boltonType ) {
                innerXML +='<man:boltonType>'+btype+'</man:boltonType>';
            }
        } 
        return innerXML;    
    }
    
    private String getBoltonPropertiesXML() {
        String innerXML ='';
        if(propertyName!=null) {
            innerXML +='<man:boltonProperties>';
                                //<!--1 or more repetitions:-->
            innerXML +='<man:boltonProperty>';
            innerXML +='<man:propertyName>'+propertyName+'</man:propertyName>';
                                    //<!--1 or more repetitions:-->
            innerXML +='<man:propertyValue>'+propertyValue+'</man:propertyValue>';
            innerXML +='</man:boltonProperty>';
            innerXML +='</man:boltonProperties>';
        }   
        return innerXML; 
    }
    
    private String getCustomerIdXML () {
        String innerXML ='<man:customerId>';
                        //<!--You have a CHOICE of the next 2 items at this level-->
        if(subscriberId!=null) {                
            innerXML +='<man:subscriberId>'+subscriberId+'</man:subscriberId>';
        } else {
            innerXML +='<man:subscriptionId>'+subscriptionId+'</man:subscriptionId>';
        }
        innerXML +='</man:customerId>';  
        return innerXML;  
    }
         
    static testMethod void testSOAManageBusinessBoltons() {
        SOAManageBusinessBoltons controller = new SOAManageBusinessBoltons();
        controller.boltonType = new List<String>();
        controller.propertyName = 'test';
        controller.propertyValue = 'test';
        controller.addBolton();
        controller.removeBolton();
        controller.setBolton();
        controller.getAgreementBoltons();
        controller.getCurrentBoltons();
        controller.getRequestXML();
        controller.getResultXML();
        // TODO: Add Asserts here    
    } 
            
}