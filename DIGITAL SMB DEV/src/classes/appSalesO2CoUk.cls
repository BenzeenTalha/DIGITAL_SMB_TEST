//Generated by wsdl2apex

public class appSalesO2CoUk 
{
    public class CreateSale_element 
    {
        public String salesForceUserName;
        public String salesForceAccountIdentifier;
        public String saleDate;
        public String OARApplicationIdentifier;
        public String salesForceOpportunityIdentifier;
        public String salesVolume;
        public String mobilisationSpecialist;
        public String contractReference;
        public String contractTerms;
        public String notes;
        private String[] salesForceUserName_type_info = new String[]{'salesForceUserName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] salesForceAccountIdentifier_type_info = new String[]{'salesForceAccountIdentifier','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] saleDate_type_info = new String[]{'saleDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] OARApplicationIdentifier_type_info = new String[]{'OARApplicationIdentifier','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] salesForceOpportunityIdentifier_type_info = new String[]{'salesForceOpportunityIdentifier','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] salesVolume_type_info = new String[]{'salesVolume','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] mobilisationSpecialist_type_info = new String[]{'mobilisationSpecialist','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] contractReference_type_info = new String[]{'contractReference','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] contractTerms_type_info = new String[]{'contractTerms','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] notes_type_info = new String[]{'notes','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://sales.o2.co.uk/','true','false'};
        private String[] field_order_type_info = new String[]{'salesForceUserName','salesForceAccountIdentifier','saleDate','OARApplicationIdentifier','salesForceOpportunityIdentifier','salesVolume','mobilisationSpecialist','contractReference','contractTerms','notes'};
    }
    public class ApplicationSaleSoap 
    {
        // Get Endpoint from Custom Setting WebService_Endpoint__c the one read out is the endpoint__c of "AppSalesEndpoint"
    	
    	WebService_Endpoint__c tmp_currentEndpoint = WebService_Endpoint__c.getInstance('AppSalesEndpoint');
    	
    	
    	
    	
        public String endpoint_x = tmp_currentEndpoint.Endpoint__c; //'http://web.staging.sales.o2.rufusleonard.co.uk/oar/ApplicationSale.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public appSalesO2CoUk.OARAuthenticationHeader OARAuthenticationHeader;
        private String OARAuthenticationHeader_hns = 'OARAuthenticationHeader=https://sales.o2.co.uk/';
        private String[] ns_map_type_info = new String[]{'https://sales.o2.co.uk/', 'appSalesO2CoUk'};
        public String GetMobilisationSpecialists() 
        {
            appSalesO2CoUk.GetMobilisationSpecialists_element request_x = new appSalesO2CoUk.GetMobilisationSpecialists_element();
            appSalesO2CoUk.GetMobilisationSpecialistsResponse_element response_x;
            Map<String, appSalesO2CoUk.GetMobilisationSpecialistsResponse_element> response_map_x = new Map<String, appSalesO2CoUk.GetMobilisationSpecialistsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://sales.o2.co.uk/GetMobilisationSpecialists',
              'https://sales.o2.co.uk/',
              'GetMobilisationSpecialists',
              'https://sales.o2.co.uk/',
              'GetMobilisationSpecialistsResponse',
              'appSalesO2CoUk.GetMobilisationSpecialistsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetMobilisationSpecialistsResult;
        }
        public String CreateSale(String salesForceUserName,String salesForceAccountIdentifier,String saleDate,String OARApplicationIdentifier,String salesForceOpportunityIdentifier,String salesVolume,String mobilisationSpecialist,String contractReference,String contractTerms,String notes) {
            appSalesO2CoUk.CreateSale_element request_x = new appSalesO2CoUk.CreateSale_element();
            appSalesO2CoUk.CreateSaleResponse_element response_x;
            request_x.salesForceUserName = salesForceUserName;
            request_x.salesForceAccountIdentifier = salesForceAccountIdentifier;
            request_x.saleDate = saleDate;
            request_x.OARApplicationIdentifier = OARApplicationIdentifier;
            request_x.salesForceOpportunityIdentifier = salesForceOpportunityIdentifier;
            request_x.salesVolume = salesVolume;
            request_x.mobilisationSpecialist = mobilisationSpecialist;
            request_x.contractReference = contractReference;
            request_x.contractTerms = contractTerms;
            request_x.notes = notes;
            Map<String, appSalesO2CoUk.CreateSaleResponse_element> response_map_x = new Map<String, appSalesO2CoUk.CreateSaleResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://sales.o2.co.uk/CreateSale',
              'https://sales.o2.co.uk/',
              'CreateSale',
              'https://sales.o2.co.uk/',
              'CreateSaleResponse',
              'appSalesO2CoUk.CreateSaleResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.CreateSaleResult;
        }
        public String RetrieveApplications() {
            appSalesO2CoUk.RetrieveApplications_element request_x = new appSalesO2CoUk.RetrieveApplications_element();
            appSalesO2CoUk.RetrieveApplicationsResponse_element response_x;
            Map<String, appSalesO2CoUk.RetrieveApplicationsResponse_element> response_map_x = new Map<String, appSalesO2CoUk.RetrieveApplicationsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://sales.o2.co.uk/RetrieveApplications',
              'https://sales.o2.co.uk/',
              'RetrieveApplications',
              'https://sales.o2.co.uk/',
              'RetrieveApplicationsResponse',
              'appSalesO2CoUk.RetrieveApplicationsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RetrieveApplicationsResult;
        }
    }
    public class GetMobilisationSpecialists_element {
        private String[] apex_schema_type_info = new String[]{'https://sales.o2.co.uk/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class RetrieveApplicationsResponse_element {
        public String RetrieveApplicationsResult;
        private String[] RetrieveApplicationsResult_type_info = new String[]{'RetrieveApplicationsResult','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://sales.o2.co.uk/','true','false'};
        private String[] field_order_type_info = new String[]{'RetrieveApplicationsResult'};
    }
    public class GetMobilisationSpecialistsResponse_element {
        public String GetMobilisationSpecialistsResult;
        private String[] GetMobilisationSpecialistsResult_type_info = new String[]{'GetMobilisationSpecialistsResult','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://sales.o2.co.uk/','true','false'};
        private String[] field_order_type_info = new String[]{'GetMobilisationSpecialistsResult'};
    }
    public class RetrieveApplications_element {
        private String[] apex_schema_type_info = new String[]{'https://sales.o2.co.uk/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class CreateSaleResponse_element {
        public String CreateSaleResult;
        private String[] CreateSaleResult_type_info = new String[]{'CreateSaleResult','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://sales.o2.co.uk/','true','false'};
        private String[] field_order_type_info = new String[]{'CreateSaleResult'};
    }
    public class OARAuthenticationHeader {
        public String Username;
        public String Password;
        private String[] Username_type_info = new String[]{'Username','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://sales.o2.co.uk/','true','false'};
        private String[] field_order_type_info = new String[]{'Username','Password'};
    }
}