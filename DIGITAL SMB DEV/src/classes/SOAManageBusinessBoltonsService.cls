//Generated by wsdl2apex

public class SOAManageBusinessBoltonsService {
    public class ManageBusinessBoltonsPort {
    	//--------------------
        //public String endpoint_x = 'https://sdpapi.o2.co.uk/services/ManageBusinessBoltons_2_0';
        public String endpoint_x = SOA_Integration_Settings__c.getValues('ManageBusinessBoltons_2_0').Endpoint__c;
        //--------------------
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        // -------------------
        public SOASecurityElement.Security_element Security;
        private String Security_hns = 'Security=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
        // -------------------
        private String[] ns_map_type_info = new String[]{'http://soa.o2.co.uk/dise/pscommondisedata_1', 'SOAPSCommonDiseData', 'http://soa.o2.co.uk/coredata_1', 'SOACoreData2', 'http://soa.o2.co.uk/managebusinessboltonsservice_2', 'SOAManageBusinessBoltonsService', 'http://soa.o2.co.uk/managebusinessboltonsdata_2', 'SOAManageBusinessBoltonsData2'};
        public SOAManageBusinessBoltonsData2.setBolton_1Response setBolton_1(SOAPSCommonDiseData.targetIdentifier_2Type targetIdentifier,String serviceCode,SOAManageBusinessBoltonsData2.boltonProperties boltonProperties) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOAManageBusinessBoltonsData2.setBolton_1 request_x = new SOAManageBusinessBoltonsData2.setBolton_1();
            SOAManageBusinessBoltonsData2.setBolton_1Response response_x;
            request_x.targetIdentifier = targetIdentifier;
            request_x.serviceCode = serviceCode;
            request_x.boltonProperties = boltonProperties;
            Map<String, SOAManageBusinessBoltonsData2.setBolton_1Response> response_map_x = new Map<String, SOAManageBusinessBoltonsData2.setBolton_1Response>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'setBolton_1',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'setBolton_1Response',
              'SOAManageBusinessBoltonsData2.setBolton_1Response'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public SOACoreData2.ServiceResultType addBolton_1(SOAPSCommonDiseData.subscriptionData subscriptionIdentifier,String serviceCode,Date activationDate,Date expiryDate,SOAManageBusinessBoltonsData2.boltonProperties boltonProperties,Integer servicePrice,String salesPersonIdentifier,String description) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOAManageBusinessBoltonsData2.addBolton_1 request_x = new SOAManageBusinessBoltonsData2.addBolton_1();
            SOAManageBusinessBoltonsData2.addBolton_1Response response_x;
            request_x.subscriptionIdentifier = subscriptionIdentifier;
            request_x.serviceCode = serviceCode;
            request_x.activationDate = activationDate;
            request_x.expiryDate = expiryDate;
            request_x.boltonProperties = boltonProperties;
            request_x.servicePrice = servicePrice;
            request_x.salesPersonIdentifier = salesPersonIdentifier;
            request_x.description = description;
            Map<String, SOAManageBusinessBoltonsData2.addBolton_1Response> response_map_x = new Map<String, SOAManageBusinessBoltonsData2.addBolton_1Response>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'addBolton_1',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'addBolton_1Response',
              'SOAManageBusinessBoltonsData2.addBolton_1Response'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public SOACoreData2.ServiceResultType removeBolton(SOAPSCommonDiseData.subscriptionData subscriptionIdentifier,String serviceCode,Date expiryDate) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOAManageBusinessBoltonsData2.removeBolton request_x = new SOAManageBusinessBoltonsData2.removeBolton();
            SOAManageBusinessBoltonsData2.removeBoltonResponse response_x;
            request_x.subscriptionIdentifier = subscriptionIdentifier;
            request_x.serviceCode = serviceCode;
            request_x.expiryDate = expiryDate;
            Map<String, SOAManageBusinessBoltonsData2.removeBoltonResponse> response_map_x = new Map<String, SOAManageBusinessBoltonsData2.removeBoltonResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'removeBolton',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'removeBoltonResponse',
              'SOAManageBusinessBoltonsData2.removeBoltonResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public SOAManageBusinessBoltonsData2.boltonDetails getCurrentBoltons(SOAPSCommonDiseData.subscriptionData subscriptionIdentifier) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOAManageBusinessBoltonsData2.getCurrentBoltons request_x = new SOAManageBusinessBoltonsData2.getCurrentBoltons();
            SOAManageBusinessBoltonsData2.getCurrentBoltonsResponse response_x;
            request_x.subscriptionIdentifier = subscriptionIdentifier;
            Map<String, SOAManageBusinessBoltonsData2.getCurrentBoltonsResponse> response_map_x = new Map<String, SOAManageBusinessBoltonsData2.getCurrentBoltonsResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'getCurrentBoltons',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'getCurrentBoltonsResponse',
              'SOAManageBusinessBoltonsData2.getCurrentBoltonsResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.boltonDetails;
        }
        public SOACoreData2.ServiceResultType updateBolton_1(String subscriptionIdentifier,String agreementIdentifier,String serviceCode,Date effectiveDate,SOAManageBusinessBoltonsData2.serviceBasicUpdatesType serviceBasicUpdates) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOAManageBusinessBoltonsData2.updateBolton_1Type request_x = new SOAManageBusinessBoltonsData2.updateBolton_1Type();
            SOAManageBusinessBoltonsData2.updateBolton_1ResponseType response_x;
            request_x.subscriptionIdentifier = subscriptionIdentifier;
            request_x.agreementIdentifier = agreementIdentifier;
            request_x.serviceCode = serviceCode;
            request_x.effectiveDate = effectiveDate;
            request_x.serviceBasicUpdates = serviceBasicUpdates;
            Map<String, SOAManageBusinessBoltonsData2.updateBolton_1ResponseType> response_map_x = new Map<String, SOAManageBusinessBoltonsData2.updateBolton_1ResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'updateBolton_1',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'updateBolton_1Response',
              'SOAManageBusinessBoltonsData2.updateBolton_1ResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public SOAManageBusinessBoltonsData2.getFavouriteNumbers_1Response getFavouriteNumbers_1(String CUGNumber,String CUGNumbersFilter,String CUGFilter) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOAManageBusinessBoltonsData2.getFavouriteNumbers_1 request_x = new SOAManageBusinessBoltonsData2.getFavouriteNumbers_1();
            SOAManageBusinessBoltonsData2.getFavouriteNumbers_1Response response_x;
            request_x.CUGNumber = CUGNumber;
            request_x.CUGNumbersFilter = CUGNumbersFilter;
            request_x.CUGFilter = CUGFilter;
            Map<String, SOAManageBusinessBoltonsData2.getFavouriteNumbers_1Response> response_map_x = new Map<String, SOAManageBusinessBoltonsData2.getFavouriteNumbers_1Response>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'getFavouriteNumbers_1',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'getFavouriteNumbers_1Response',
              'SOAManageBusinessBoltonsData2.getFavouriteNumbers_1Response'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public SOAManageBusinessBoltonsData2.boltonDetails getAgreementBoltons(String agreementNumber) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOAManageBusinessBoltonsData2.getAgreementBoltons request_x = new SOAManageBusinessBoltonsData2.getAgreementBoltons();
            SOAManageBusinessBoltonsData2.getAgreementBoltonsResponse response_x;
            request_x.agreementNumber = agreementNumber;
            Map<String, SOAManageBusinessBoltonsData2.getAgreementBoltonsResponse> response_map_x = new Map<String, SOAManageBusinessBoltonsData2.getAgreementBoltonsResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'getAgreementBoltons',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'getAgreementBoltonsResponse',
              'SOAManageBusinessBoltonsData2.getAgreementBoltonsResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.agreementBoltons;
        }
        public SOAManageBusinessBoltonsData2.getFavouriteNumbersList_1Response getFavouriteNumbersList_1(SOAPSCommonDiseData.targetQueryIdentifier_2Type targetQueryIdentifer,String CUGFilter) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOAManageBusinessBoltonsData2.getFavouriteNumbersList_1 request_x = new SOAManageBusinessBoltonsData2.getFavouriteNumbersList_1();
            SOAManageBusinessBoltonsData2.getFavouriteNumbersList_1Response response_x;
            request_x.targetQueryIdentifer = targetQueryIdentifer;
            request_x.CUGFilter = CUGFilter;
            Map<String, SOAManageBusinessBoltonsData2.getFavouriteNumbersList_1Response> response_map_x = new Map<String, SOAManageBusinessBoltonsData2.getFavouriteNumbersList_1Response>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'getFavouriteNumbersList_1',
              'http://soa.o2.co.uk/managebusinessboltonsdata_2',
              'getFavouriteNumbersList_1Response',
              'SOAManageBusinessBoltonsData2.getFavouriteNumbersList_1Response'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
  //--------------------------------------------------------------------------
  // Test method
  //--------------------------------------------------------------------------
    @isTest(SeeAllData=true)
    static void testCodeCoverage()
    {
	    SOAManageBusinessBoltonsService.ManageBusinessBoltonsPort port =
	      new SOAManageBusinessBoltonsService.ManageBusinessBoltonsPort();
	
	    try { port.setBolton_1(null, null, null);
	    } catch (Exception e) {}
		try { port.addBolton_1(null, null, null, null, null, null, null, null); 
	    } catch (Exception e) {}
	    try { port.removeBolton(null, null, null);
	    } catch (Exception e) {}
	    try { port.getCurrentBoltons(null);
	    } catch (Exception e) {}
	    try { port.updateBolton_1(null, null, null, null, null);
	    } catch (Exception e) {}
	    try { port.getFavouriteNumbers_1(null, null, null);
	    } catch (Exception e) {}
	    try { port.getAgreementBoltons(null);
	    } catch (Exception e) {}
	    try {port.getFavouriteNumbersList_1(null, null);
	    } catch (Exception e) {}
    }
}