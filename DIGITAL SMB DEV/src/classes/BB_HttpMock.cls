@isTest(SeeAllData=true)
global class BB_HttpMock implements HttpCalloutMock {
    
    private String responsetype = '';
    private String acceptResponse = '';
    private String rejectResponse = '';
              
    // Constructor
    global BB_HttpMock(String restype){
        responsetype = restype;
        if(responsetype=='Accept'){
            acceptResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"> <soapenv:Body xmlns:urn3="urn:com.openreach.LineCharacteristics2v18-0" xmlns:urn="urn:com.openreach.LineCharacteristics2v20-0" xmlns:urn4="urn:com.openreach.LineCharacteristics2v19-0" xmlns:open="http://www.openuri.org/" xmlns:urn1="urn:com.openreach.LineCharacteristics2v16-0" xmlns:gen="http://www.bt.com/eai/hub/or/GenericCPWSHubService" xmlns:urn2="urn:com.openreach.LineCharacteristics2v17-0" xmlns:urnX="urn:com.openreach.LineCharacteristics2v15-0"> <open:DS_ManageLineCharacteristicsV2RequestResponse> <gen:GenericCPWSHubService> <urn:LineCharacteristicsRequestAccepted2> <urn:QueryResponse> <urn:RequestersID>50019999</urn:RequestersID> <urn:RespondersID>D20130903160538510.-1c5d1cd5:140dd4ce60c:-2f19@180065559</urn:RespondersID> <urn:IssueDateTime>2013-09-03T16:05:38</urn:IssueDateTime> <urn:ReceivedDateTime>2013-09-03T04:05:28</urn:ReceivedDateTime> <urn:RequesterParty> <urn:Party> <urn:PartyIdentification> <urn:ID identificationSchemeAgencyName="DUNS">718803096</urn:ID></urn:PartyIdentification></urn:Party></urn:RequesterParty> <urn:ResponderParty> <urn:Party> <urn:PartyIdentification> <urn:ID identificationSchemeName="DUNS">364877501</urn:ID></urn:PartyIdentification></urn:Party></urn:ResponderParty> <urn:RespondedQueryLine> <urn:QueryLineItem> <urn:RequestersID>1</urn:RequestersID> <urn:Features> <urn:LineCharacteristicsFeatureSet> <urn:InputFeatures> <urn:RequiredServiceType>All</urn:RequiredServiceType> <urn:InstallationDN>01142700690</urn:InstallationDN> <urn:PostCode>IP100PY</urn:PostCode></urn:InputFeatures> <urn:OutputFeatures> <urn:LineCharacteristics> <urn:DP>66</urn:DP> <urn:DistrictCode>SL</urn:DistrictCode> <urn:RecordedPostCode>IP10 0PY</urn:RecordedPostCode> <urn:AECapacitance>250</urn:AECapacitance> <urn:BECapacitance>250</urn:BECapacitance> <urn:DPLineLengthEstimate>100</urn:DPLineLengthEstimate> <urn:CircuitLineLengthEstimate>3000</urn:CircuitLineLengthEstimate> <urn:CircuitLineLengthCalculated>3000</urn:CircuitLineLengthCalculated> <urn:ANFPCategory>X</urn:ANFPCategory> <urn:MDFSiteId>SLIPSW3</urn:MDFSiteId> <urn:MDFSiteName>Ipswich 3</urn:MDFSiteName> <urn:BETEnabled>Y</urn:BETEnabled> <urn:CelerityDBLoss>82.13</urn:CelerityDBLoss> <urn:CalculatedDBLoss>82.13</urn:CalculatedDBLoss> <urn:LastDailyAssetUpdateDateTime>2013-09-02T00:00:00</urn:LastDailyAssetUpdateDateTime> <urn:LastWeeklyUpdateDateTime>2013-08-28T00:00:00</urn:LastWeeklyUpdateDateTime> <urn:LastMonthlyUpdateDateTime>2013-08-03T00:00:00</urn:LastMonthlyUpdateDateTime> <urn:LastCelerityUpdateDateTime>2013-08-24T00:00:00</urn:LastCelerityUpdateDateTime></urn:LineCharacteristics> <urn:FTTCAvailability> <urn:FTTCAvailable>Y</urn:FTTCAvailable> <urn:MaximumUpstreamDataBandwidth>20.5Mbit/s</urn:MaximumUpstreamDataBandwidth> <urn:MaximumDownstreamDataBandwidth>100.5Mbit/s</urn:MaximumDownstreamDataBandwidth> <urn:BandwidthMeasure>Predicted</urn:BandwidthMeasure> <urn:OHP> <urn:DistrictCode>SL</urn:DistrictCode> <urn:OHPExchangeCode>IPSW3</urn:OHPExchangeCode> <urn:OHPExchangeName>Ipswich 3</urn:OHPExchangeName> <urn:L2SId>IL2SSL1</urn:L2SId></urn:OHP></urn:FTTCAvailability> <urn:FTTPAvailability> <urn:FTTPAvailable>N</urn:FTTPAvailable> <urn:FVAAvailable>N</urn:FVAAvailable> <urn:PremisesType>Single Dwelling Unit Residential</urn:PremisesType> <urn:OHP> <urn:DistrictCode>SL</urn:DistrictCode> <urn:OHPExchangeCode>IPSW3</urn:OHPExchangeCode> <urn:OHPExchangeName>Ipswich 3</urn:OHPExchangeName> <urn:L2SId>IL2SSL1</urn:L2SId></urn:OHP></urn:FTTPAvailability> <urn:ListOfServiceCompatibility> <urn:ServiceCompatibility> <urn:ServiceType>MPF</urn:ServiceType> <urn:CompatibilityIndicator>Y</urn:CompatibilityIndicator></urn:ServiceCompatibility> <urn:ServiceCompatibility> <urn:ServiceType>SMPF</urn:ServiceType> <urn:CompatibilityIndicator>Y</urn:CompatibilityIndicator></urn:ServiceCompatibility> <urn:ServiceCompatibility> <urn:ServiceType>FTTC</urn:ServiceType> <urn:CompatibilityIndicator>Y</urn:CompatibilityIndicator></urn:ServiceCompatibility></urn:ListOfServiceCompatibility> <urn:ListOfTechnologyMessage> <urn:TechnologyMessage> <urn:TechnologyCode>Z</urn:TechnologyCode> <urn:TechnologyText>No Issues</urn:TechnologyText></urn:TechnologyMessage> <urn:TechnologyMessage /></urn:ListOfTechnologyMessage> <urn:ListOfServiceInformation> <urn:ServiceInformation> <urn:AccessLineId>01142700690</urn:AccessLineId> <urn:AccessLIneStatus>Working</urn:AccessLIneStatus></urn:ServiceInformation></urn:ListOfServiceInformation></urn:OutputFeatures></urn:LineCharacteristicsFeatureSet></urn:Features></urn:QueryLineItem> <urn:QueryLineMessageInfo> <urn:MessageInfo> <urn:CompletionCode>2150</urn:CompletionCode> <urn:Message>No Errors - Line characteristics obtained</urn:Message> <urn:Severity>Informational</urn:Severity></urn:MessageInfo></urn:QueryLineMessageInfo></urn:RespondedQueryLine></urn:QueryResponse></urn:LineCharacteristicsRequestAccepted2></gen:GenericCPWSHubService></open:DS_ManageLineCharacteristicsV2RequestResponse></soapenv:Body></soapenv:Envelope>';      
        }
        else if(responsetype=='Reject'){
            rejectResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"> <soapenv:Body xmlns:urn3="urn:com.openreach.LineCharacteristics2v18-0" xmlns:urn="urn:com.openreach.LineCharacteristics2v20-0" xmlns:urn4="urn:com.openreach.LineCharacteristics2v19-0" xmlns:open="http://www.openuri.org/" xmlns:urn1="urn:com.openreach.LineCharacteristics2v16-0" xmlns:gen="http://www.bt.com/eai/hub/or/GenericCPWSHubService" xmlns:urn2="urn:com.openreach.LineCharacteristics2v17-0" xmlns:urnX="urn:com.openreach.LineCharacteristics2v15-0"> <open:DS_ManageLineCharacteristicsV2RequestResponse> <gen:GenericCPWSHubService> <urn:LineCharacteristicsRequestRejected2> <urn:QueryResponse> <urn:RequestersID>50019999</urn:RequestersID> <urn:RespondersID>D20130903161829003.-1c5d1cd5:140dd4ce60c:-2e91@180065559</urn:RespondersID> <urn:IssueDateTime>2013-09-03T16:18:29</urn:IssueDateTime> <urn:ReceivedDateTime>2013-09-03T04:18:25</urn:ReceivedDateTime> <urn:RequesterParty> <urn:Party> <urn:PartyIdentification> <urn:ID identificationSchemeAgencyName="DUNS">718803096</urn:ID></urn:PartyIdentification></urn:Party></urn:RequesterParty> <urn:ResponderParty> <urn:Party> <urn:PartyIdentification> <urn:ID identificationSchemeName="DUNS">364877501</urn:ID></urn:PartyIdentification></urn:Party></urn:ResponderParty> <urn:RespondedQueryLine> <urn:QueryLineItem> <urn:RequestersID>1</urn:RequestersID> <urn:Features> <urn:LineCharacteristicsFeatureSet> <urn:InputFeatures> <urn:RequiredServiceType>All</urn:RequiredServiceType> <urn:InstallationDN>441142700690</urn:InstallationDN> <urn:PostCode>IP100PY</urn:PostCode></urn:InputFeatures></urn:LineCharacteristicsFeatureSet></urn:Features></urn:QueryLineItem> <urn:QueryLineMessageInfo> <urn:MessageInfo> <urn:CompletionCode>2152</urn:CompletionCode> <urn:Message>Telephone Number not recognised format</urn:Message> <urn:Severity>Error</urn:Severity></urn:MessageInfo></urn:QueryLineMessageInfo></urn:RespondedQueryLine></urn:QueryResponse></urn:LineCharacteristicsRequestRejected2></gen:GenericCPWSHubService></open:DS_ManageLineCharacteristicsV2RequestResponse></soapenv:Body></soapenv:Envelope>';    
        }
    }
    
    global HTTPResponse respond(HTTPRequest req){        
        // Verfy http request endpoint and method
        System.assertEquals(SOA_Integration_Settings__c.getValues('SentryGatewayMLCv2_v14Soap').Endpoint__c, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());        
        // Create a fake HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        if(responsetype=='Accept'){
            res.setBody(acceptResponse);
        }
        else if(responsetype=='Reject'){
            res.setBody(rejectResponse);
        }
        res.setStatusCode(200);
        return res;        
    }
        
}