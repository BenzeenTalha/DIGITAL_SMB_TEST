//Generated by wsdl2apex

public class SOAViewBusinessCustomerTransService {
    public class ViewBusinessCustomerTransactionsPort {
        public String endpoint_x = SOA_Integration_Settings__c.getValues('ViewBusinessCustomerTransactions_1_0').Endpoint__c;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        
        // ------------------- 
        public String email;
        public SOASecurityElement.Security_element Security;
        private String Security_hns = 'Security=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';

        public SOASecurityElement.SOAConsumerTransactionID_element SOAConsumerTransactionID;
        private String SOAConsumerTransactionID_hns = 'SOAConsumerTransactionID=http://soa.o2.co.uk/coredata_1';
         // -------------------

        private String[] ns_map_type_info = new String[]{'http://soa.o2.co.uk/dise/pscommondisedata_1', 'SOAPSCommonDiseData', 'http://soa.o2.co.uk/viewbusinesscustomertransactionsservice_1', 'SOAViewBusinessCustomerTransService', 'http://soa.o2.co.uk/coredata_1', 'SOACoredata2', 'http://soa.o2.co.uk/viewbusinesscustomertransactionsdata_1', 'SOAViewBusinessCustomerTransData'};
        public SOAViewBusinessCustomerTransData.transactionDetailsType[] getCustomerTransactions(String accountNumber,String transactionType,String transactionFilter,Integer noOfRecordsToBeRetrieved) {
            // -------------------
            Security = new SOASecurityElement.Security_element(endpoint_x);
            // -------------------

            SOAViewBusinessCustomerTransData.getCustomerTransactions request_x = new SOAViewBusinessCustomerTransData.getCustomerTransactions();
            SOAViewBusinessCustomerTransData.getCustomerTransactionsResponse response_x;
            request_x.accountNumber = accountNumber;
            request_x.transactionType = transactionType;
            request_x.transactionFilter = transactionFilter;
            request_x.noOfRecordsToBeRetrieved = noOfRecordsToBeRetrieved;
            Map<String, SOAViewBusinessCustomerTransData.getCustomerTransactionsResponse> response_map_x = new Map<String, SOAViewBusinessCustomerTransData.getCustomerTransactionsResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soa.o2.co.uk/viewbusinesscustomertransactionsdata_1',
              'getCustomerTransactions',
              'http://soa.o2.co.uk/viewbusinesscustomertransactionsdata_1',
              'getCustomerTransactionsResponse',
              'SOAViewBusinessCustomerTransData.getCustomerTransactionsResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.transaction_x;
        }
    }
  //--------------------------------------------------------------------------
  // Test method  - wsdl2apex generated (execute only)
  //--------------------------------------------------------------------------
    @isTest(SeeAllData=true)
    static void testCodeCoverage()
    {
	    SOAViewBusinessCustomerTransService.ViewBusinessCustomerTransactionsPort port =
	      new SOAViewBusinessCustomerTransService.ViewBusinessCustomerTransactionsPort();
	
	    try { port.getCustomerTransactions(null, null, null, null);
	    } catch (Exception e) {}
    }
}