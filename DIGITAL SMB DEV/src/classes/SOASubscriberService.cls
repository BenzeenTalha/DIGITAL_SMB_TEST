//Generated by wsdl2apex

public class SOASubscriberService {
    public class SubscriberPort {
        //public String endpoint_x = 'http://greenwich:8080/services/Subscriber_2_0';
        //public String endpoint_x = 'https://sdpapi.ref.o2.co.uk/services/Subscriber_2_0';
        public String endpoint_x = SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c;
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
        private String[] ns_map_type_info = new String[]{'http://soa.o2.co.uk/subscriberservice_2', 'SOASubscriberService', 'http://soa.o2.co.uk/coredata_1', 'SOACoreData2', 'http://soa.o2.co.uk/subscriberdata_2', 'SOASubscriberData'};
        public SOASubscriberData.subscriberProfileType getSubscriberProfile(String subscriberID) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getSubscriberProfile request_x = new SOASubscriberData.getSubscriberProfile();
            SOASubscriberData.getSubscriberProfileResponse response_x;
            request_x.subscriberID = SOAUtils.cleanDirectoryNumber(subscriberID);
            Map<String, SOASubscriberData.getSubscriberProfileResponse> response_map_x = new Map<String, SOASubscriberData.getSubscriberProfileResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberProfile',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberProfileResponse',
              'SOASubscriberData.getSubscriberProfileResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.subscriberProfile;
        }

        public SOASubscriberData.getSubscriberAndBillingSystemResponse getSubscriberAndBillingSystem(String msisdn) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getSubscriberAndBillingSystem request_x = new SOASubscriberData.getSubscriberAndBillingSystem();
            SOASubscriberData.getSubscriberAndBillingSystemResponse response_x;
            request_x.msisdn = msisdn;
            Map<String, SOASubscriberData.getSubscriberAndBillingSystemResponse> response_map_x = new Map<String, SOASubscriberData.getSubscriberAndBillingSystemResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberAndBillingSystem',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberAndBillingSystemResponse',
              'SOASubscriberData.getSubscriberAndBillingSystemResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }

        public SOASubscriberData.getBillProfileResponse getBillProfile(String msisdn,String accountNumber) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getBillProfile request_x = new SOASubscriberData.getBillProfile();
            SOASubscriberData.getBillProfileResponse response_x;
            request_x.msisdn = msisdn;
            request_x.accountNumber = accountNumber;
            Map<String, SOASubscriberData.getBillProfileResponse> response_map_x = new Map<String, SOASubscriberData.getBillProfileResponse>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()) {
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getBillProfile',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getBillProfileResponse',
              'SOASubscriberData.getBillProfileResponse'}
            );} else {
            	response_map_x.put('response_x',new SOASubscriberData.getBillProfileResponse());
            }
            response_x = response_map_x.get('response_x');
            return response_x;
        }

        public String getSubscriberOperator(String SubscriberID) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getSubscriberOperator request_x = new SOASubscriberData.getSubscriberOperator();
            System.debug('request_x: ' + request_x);
            SOASubscriberData.getSubscriberOperatorResponse response_x;
            request_x.SubscriberID = SubscriberID;
            Map<String, SOASubscriberData.getSubscriberOperatorResponse> response_map_x = new Map<String, SOASubscriberData.getSubscriberOperatorResponse>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()) {
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberOperator',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberOperatorResponse',
              'SOASubscriberData.getSubscriberOperatorResponse'}
            );} else {
            	response_map_x.put('response_x',new SOASubscriberData.getSubscriberOperatorResponse());
            }
            response_x = response_map_x.get('response_x');
            return response_x.Operator;
        }

        public String getSubscriberSegment(String SubscriberID) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getSubscriberSegment request_x = new SOASubscriberData.getSubscriberSegment();
            SOASubscriberData.getSubscriberSegmentResponse response_x;
            request_x.SubscriberID = SubscriberID;
            Map<String, SOASubscriberData.getSubscriberSegmentResponse> response_map_x = new Map<String, SOASubscriberData.getSubscriberSegmentResponse>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()) {
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberSegment',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberSegmentResponse',
              'SOASubscriberData.getSubscriberSegmentResponse'}
            );} else {
            	response_map_x.put('response_x',new SOASubscriberData.getSubscriberSegmentResponse());
            }
            response_x = response_map_x.get('response_x');
            return response_x.Segment;
        }

        public String getBillingSystem(String msisdn) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getBillingSystem request_x = new SOASubscriberData.getBillingSystem();
            SOASubscriberData.getBillingSystemResponse response_x;
            request_x.msisdn = msisdn;
            Map<String, SOASubscriberData.getBillingSystemResponse> response_map_x = new Map<String, SOASubscriberData.getBillingSystemResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getBillingSystem',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getBillingSystemResponse',
              'SOASubscriberData.getBillingSystemResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.billingProfile;
        }

        public String getSubscriberChannel(String SubscriberID) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getSubscriberChannel request_x = new SOASubscriberData.getSubscriberChannel();
            SOASubscriberData.getSubscriberChannelResponse response_x;
            request_x.SubscriberID = SubscriberID;
            Map<String, SOASubscriberData.getSubscriberChannelResponse> response_map_x = new Map<String, SOASubscriberData.getSubscriberChannelResponse>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()) {
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberChannel',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberChannelResponse',
              'SOASubscriberData.getSubscriberChannelResponse'}
            );} else {
            	response_map_x.put('response_x',new SOASubscriberData.getSubscriberChannelResponse());
            }
            response_x = response_map_x.get('response_x');
            return response_x.channel;
        }

        public String[] getChargingCategory(String msisdn,SOASubscriberData.productListType productList) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getChargingCategory request_x = new SOASubscriberData.getChargingCategory();
            SOASubscriberData.getChargingCategoryResponse response_x;
            request_x.msisdn = msisdn;
            request_x.productList = productList;
            Map<String, SOASubscriberData.getChargingCategoryResponse> response_map_x = new Map<String, SOASubscriberData.getChargingCategoryResponse>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()) {
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getChargingCategory',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getChargingCategoryResponse',
              'SOASubscriberData.getChargingCategoryResponse'}
            );} else {
            	response_map_x.put('response_x',new SOASubscriberData.getChargingCategoryResponse());
            }
            response_x = response_map_x.get('response_x');
            return response_x.chargingCategory;
        }

        public String getSubscriberPaymentCategory(String SubscriberID) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------
            SOASubscriberData.getSubscriberPaymentCategory request_x = new SOASubscriberData.getSubscriberPaymentCategory();
            SOASubscriberData.getSubscriberPaymentCategoryResponse response_x;
            request_x.SubscriberID = SubscriberID;
            Map<String, SOASubscriberData.getSubscriberPaymentCategoryResponse> response_map_x = new Map<String, SOASubscriberData.getSubscriberPaymentCategoryResponse>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()) {
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberPaymentCategory',
              'http://soa.o2.co.uk/subscriberdata_2',
              'getSubscriberPaymentCategoryResponse',
              'SOASubscriberData.getSubscriberPaymentCategoryResponse'}
            );} else {
            	response_map_x.put('response_x',new SOASubscriberData.getSubscriberPaymentCategoryResponse());
            }
            response_x = response_map_x.get('response_x');
            return response_x.PaymentCategory;
        }
    }

    // This is wsdl2apex generated class - asserts not required
    static testMethod void testSOASubscriberService () {
    	String accountNumber ='12322332';
    	String SubscriberID ='12322332';
    	String msisdn = '12322332';
    	SOASubscriberService.SubscriberPort port = new SOASubscriberService.SubscriberPort();
    	try
    	{
			port.getBillingSystem(msisdn);
    	}
    	catch (Exception e)	{}
    	try
    	{
			port.getBillProfile(msisdn, accountNumber);
    	}
    	catch (Exception e)	{}
    	try
    	{
			port.getChargingCategory(msisdn, new SOASubscriberData.productListType());
    	}
    	catch (Exception e)	{}
    	try
    	{
			port.getSubscriberAndBillingSystem(msisdn);
    	}
    	catch (Exception e)	{}
    	try
    	{
			port.getSubscriberChannel(SubscriberID);
    	}
    	catch (Exception e)	{}
    	try
    	{
			port.getSubscriberOperator(SubscriberID);
    	}
    	catch (Exception e)	{}
    	try
    	{
			port.getSubscriberPaymentCategory(SubscriberID);
    	}
    	catch (Exception e)	{}
    	try
    	{
			port.getSubscriberProfile(SubscriberID);
    	}
    	catch (Exception e)	{}
    	try
    	{
			port.getSubscriberSegment(SubscriberID);
    	}
    	catch (Exception e)	{}
    }
}