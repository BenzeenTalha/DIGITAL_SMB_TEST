/*
*   This class is used to expose Billing Services to MOMAc
*   SO'Halloran - (SFDC)
*   Revision History
*   1.0    07/12/2012  Initial Version
*   2.0    20/02/2013  Colin Kenworthy(CloudSense) Change from Stub class to actual code.
*   2.1    05/03/2013  S O'Halloran (SFDC) Replaced labels (*Value) with (*)
*   2.2    18/03/2013  C Kenworthy(CloudSense) Return first name, not full name. Change param list to constructor.
*   2.3    17/04/2013  S O'Halloran (SFDC) Added approxNextInvoiceAmount functionality
*/  
@RestResource(urlMapping='/UnbilledUsageSummary/*')
global class ServiceUnbilledUsageSummary {

  @HttpGet
  global static UnbilledUsageSummaryResponse getUnbilledUsageSummary() {
    RestRequest req = RestContext.request;  
    String applicationNumber = req.params.get('applicationNumber');
    String MSISDN = req.params.get('MSISDN');
    String IMEI = req.params.get('IMEI');
    String IMSI = req.params.get('IMSI');
    String groupCode  = req.params.get('groupCode');
    return new UnbilledUsageSummaryResponse(MSISDN, IMEI, IMSI, groupCode);
  }

  global class ApplicationOutputDetails {
    public String EEapplicationNumber {get; set;}
    public Datetime EEapplicationLastUpdated {get; set;}
    public applicationOutputDetails() {
        EEapplicationNumber='12001';
        EEapplicationLastUpdated = Datetime.newInstance(2013, 03, 18, 12, 00, 00);
    }
  }

  global class ResponseDetails {
    public String responseCode {get; set;}
    public String responseCodeType {get; set;}
    public String responseCodeDescription {get; set;}
    public responseDetails() {
        responseCode= 'S0000';
        responseCodeType ='S';
        responseCodeDescription='Success';
    }
  }

  // used in the unbilled usage aggregation
  global class UnbilledUnitsTotals {
    public integer voiceHome {get; set;}
    public integer voiceInternational {get; set;}
    public integer voiceRoaming {get; set;}
    public integer textHome {get; set;}
    public integer textInternational {get; set;}
    public integer textRoaming {get; set;}
    public integer dataHome {get; set;}
    public integer dataRoaming {get; set;}
    public integer approxNextInvoiceAmount {get; set;}
    public UnbilledUnitsTotals() {
        voiceHome = 0;
        voiceInternational = 0;
        voiceRoaming = 0;
        textHome = 0;
        textInternational = 0;
        textRoaming = 0;
        dataHome = 0;
        dataRoaming = 0;
        approxNextInvoiceAmount = 0;
    }
  }

  global class UnbilledUsageSummary {
    public integer homeVoice {get; set;}
    public string  homeVoiceLimit {get; set;}
    public integer homeVoicePercentage {get; set;}
    public string  homeVoiceRAG {get; set;}
    public integer internationalVoice {get; set;}
    public string  internationalVoiceLimit {get; set;}
    public integer internationalVoicePercentage {get; set;}
    public string  internationalVoiceRAG {get; set;}
    public integer roamedVoice {get; set;}
    public string  roamedVoiceLimit {get; set;}
    public integer roamedVoicePercentage {get; set;}
    public string  roamedVoiceRAG {get; set;}
    public integer homeText {get; set;}
    public string  homeTextLimit {get; set;}
    public integer homeTextPercentage {get; set;}
    public string  homeTextRAG {get; set;}
    public integer internationalText {get; set;}
    public string  internationalTextLimit {get; set;}
    public integer internationalTextPercentage {get; set;}
    public string  internationalTextRAG {get; set;}
    public integer roamedText {get; set;}
    public string  roamedTextLimit {get; set;}
    public integer roamedTextPercentage {get; set;}
    public string  roamedTextRAG {get; set;}
    public integer homeData {get; set;}
    public string  homeDataLimit {get; set;}
    public integer homeDataPercentage {get; set;}
    public string  homeDataRAG {get; set;}
    public integer roamedData {get; set;}
    public string  roamedDataLimit {get; set;}
    public integer roamedDataPercentage {get; set;}
    public string  roamedDataRAG {get; set;}
    public UnbilledUsageSummary () {
        homeVoice = 0;
        homeVoiceLimit = '0';
        homeVoicePercentage = 0;
        homeVoiceRAG = '';
        internationalVoice = 0;
        internationalVoiceLimit = '0';
        internationalVoicePercentage = 0;
        internationalVoiceRAG = '';
        roamedVoice = 0;
        roamedVoiceLimit = '0';
        roamedVoicePercentage = 0;
        roamedVoiceRAG = '';
        homeText = 0;
        homeTextLimit = '0';
        homeTextPercentage = 0;
        homeTextRAG = '';
        internationalText = 0;
        internationalTextLimit = '0';
        internationalTextPercentage = 0;
        internationalTextRAG = '';
        roamedText = 0;
        roamedTextLimit = '0';
        roamedTextPercentage = 0;
        roamedTextRAG = '';
        homeData = 0;
        homeDataLimit = '0';
        homeDataPercentage = 0;
        homeDataRAG = '';
        roamedData = 0;
        roamedDataLimit = '0';
        roamedDataPercentage = 0;
        roamedDataRAG = '';
    }
  }


  global class UnbilledUsageSummaryResponse {

    public String userName { get; set;} 
    public String tariffCode { get; set;} 
    public String tariffCodeDescription { get; set;} 
    public String costCentreCode { get; set;} 
    public Date lastInvoiceDate { get; set;} 
    public Date nextInvoiceDate { get; set;} 
    public Integer approxNextInvoiceAmount { get; set;}
    public ApplicationOutputDetails applicationOutputDetails { get; set;} 
    public ResponseDetails responseDetails { get; set;} 
    public UnbilledUsageSummary unbilledUsageSummary { get; set;}

    public UnbilledUsageSummaryResponse(String MSISDN, String IMEI, String IMSI, String groupCode) {

        userName = '';
        tariffCode = '';
        tariffCodeDescription = '';
        costCentreCode = '';
        lastInvoiceDate = Date.newInstance(2000, 1, 1);
        nextInvoiceDate = Date.newInstance(2000, 1, 1);
        approxNextInvoiceAmount = 0;
        applicationOutputDetails = new ApplicationOutputDetails();
        responseDetails = new ResponseDetails();
        unbilledUsageSummary = new UnbilledUsageSummary();

// **************************************
// Sanity Checks
// **************************************
        if (MSISDN == null || MSISDN == '')
        {
            replyStatus('X0099', 'X', 'Invalid MSISDN structure', MSISDN, groupCode);
            return;
        }
        // special test case
        if ( MSISDN=='0' )
        {
            replyStatus('V0005', 'V', 'MSISDN entered is invalid', MSISDN, groupCode);
            return;
        }
        if ( !MSISDN.isNumeric() || (MSISDN.length() > 2 && MSISDN.left(2)!='44') || MSISDN.length() < 12 )
        {
            replyStatus('X0099', 'X', 'Invalid MSISDN structure', MSISDN, groupCode);
            return;
        }
        // must be mobile number not landline i.e. start with 447 (but not 4470!)
        if ( MSISDN.left(3)!='447' || MSISDN.left(4)=='4470' )
        {
            replyStatus('V0005', 'V', 'MSISDN entered is invalid', MSISDN, groupCode);
            return;
        }
        

        string ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
        string MAN_NS = 'http://soa.o2.co.uk/managebusinesssubscriptionsdata_1';
        string VIEW_NS= 'http://soa.o2.co.uk/viewbusinesscustomerusagedata_2';
        string PSC_NS = 'http://soa.o2.co.uk/dise/pscommondisedata_1';
        string COR_NS = 'http://soa.o2.co.uk/coredata_1';
    
// **************************************
// First Callout getSubscriptionDetails_1
// **************************************
        String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
        String endpoint = SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0').Endpoint__c;

        SOAServicesBase soaBase = new SOAServicesBase();
        
        String subscriptionDetailsXml = null;

        // Generate XML request 
        String innerXML = '';
        
        innerXML += '<man:getSubscriptionDetails_1>';
        innerXML +=   '<man:subscriptionData>';
        innerXML +=     '<psc:primarySerialNumber>';
        innerXML +=       '<psc:parameterType>Mobile</psc:parameterType>';
        innerXML +=       '<psc:parameterValue>' + MSISDN + '</psc:parameterValue>';
        innerXML +=     '</psc:primarySerialNumber>';
        innerXML +=   '</man:subscriptionData>';
        innerXML +=   '<man:subscriptionDataFilters>';
        innerXML +=     '<man:subscriptionDataFilter>BASIC</man:subscriptionDataFilter>';
        innerXML +=     '<man:subscriptionDataFilter>CUSTOMERDETAILS</man:subscriptionDataFilter>';
        innerXML +=     '<man:subscriptionDataFilter>CONTRACTANDSALES</man:subscriptionDataFilter>';
        innerXML +=   '</man:subscriptionDataFilters>';
        innerXML += '</man:getSubscriptionDetails_1>';

        // try catch here to catch any catastrophic event
        try {
            subscriptionDetailsXml = soaBase.sendRequest(endpoint, envelopeXML, innerXML);
        }
        catch (exception e) {
            // set error and return
            replyStatus('X0099', 'X', 'Other internal API error', MSISDN, groupCode);
            return;
        }
        system.debug('+++ subscriptionDetailsXml: ' + subscriptionDetailsXml);

        //
        // check xml for any errors/faults
        //
        // XML to DOM
        Dom.Document document = new Dom.Document();
        document.load(subscriptionDetailsXml);
        // finished with xml string now
        subscriptionDetailsXml = null;
        Dom.XMLNode rootNode = document.getRootElement();
        // Check for soapenv Body element
        Dom.XMLNode bodyElement = rootNode.getChildElement('Body', ENV_NS);
        if (bodyElement == null) {
            replyStatus('X0099', 'X', 'SOA service has technically failed', MSISDN, groupCode);
            return;
        }
        // Check for soapenv Fault element
        Dom.XMLNode faultElement = bodyElement.getChildElement('Fault', ENV_NS);
        if (faultElement != null)
        {
            Dom.XMLNode detailElement = faultElement.getChildElement('detail', null);
            Dom.XMLNode responseFaultElement = detailElement.getChildElement('getSubscriptionDetails_1Fault', MAN_NS);
            
            if (responseFaultElement == null) {
                // there are faults without this node which we can't get description for
                replyStatus('X0099', 'X', 'Other internal API error', MSISDN, groupCode);
                return;
            }

            Dom.XMLNode SOAFaultCodeElement = responseFaultElement.getChildElement('SOAFaultCode', COR_NS);
            String faultCode = SOAFaultCodeElement.getText();
            
            Dom.XMLNode faultDescriptionElement = responseFaultElement.getChildElement('faultDescription', COR_NS);
            string faultDescription = faultDescriptionElement.getText();
            if (faultDescription==null) {
                faultDescription='';
            }

            if (faultCode == 'managebusinesssubscriptions-37151-2501-F' ||
                faultCode == 'managebusinesssubscriptions-37151-2502-F'    ) {
                replyStatus('X0010', 'X', 'Service not available; try later', MSISDN, groupCode);
                return;
            }
            if (faultCode == 'managebusinesssubscriptions-37151-2506-F' ||
                faultCode == 'managebusinesssubscriptions-37151-2507-F'    ) {
                replyStatus('F0009', 'F', 'SOA service has technically failed', MSISDN, groupCode);
                return;
            }
            if (faultCode == 'managebusinesssubscriptions-37151-3000-E' ||
                faultCode == 'managebusinesssubscriptions-37151-3003-E'    ) {
                replyStatus('V0011', 'V', 'MSISDN entered does not exist', MSISDN, groupCode);
                return;
            }
            if (faultCode == 'managebusinesssubscriptions-37151-3002-E'    ) {
                replyStatus('V0005', 'V', 'MSISDN entered is invalid', MSISDN, groupCode);
                return;
            }
            if (faultCode == 'managebusinesssubscriptions-37151-3612-E' ||
                faultCode == 'managebusinesssubscriptions-37151-3999-E'    ) {
                replyStatus('X0099', 'X', 'SOA service has technically failed', MSISDN, groupCode);
                return;
            }
//            if (faultCode == 'managebusinesssubscriptions-37151-3003-E'    ) {
//                replyStatus('F0013', 'F', faultDescription.left(50), MSISDN, groupCode);
//                return;
//            }
            if (faultCode == 'managebusinesssubscriptions-37151-4501-V'    ) {
                replyStatus('V0012', 'V', 'General validation error', MSISDN, groupCode);
                return;
            }
            // catchall set error and return
            replyStatus('X0099', 'X', faultDescription.left(50), MSISDN, groupCode);
            return;
        }
        // assuming if not a fault then SOA call was a success

        
        // get codes from xml
        Dom.XMLNode responseElement = bodyElement.getChildElement('getSubscriptionDetails_1Response', MAN_NS);
        Dom.XMLNode basicDetailsElement = responseElement.getChildElement('basicDetails', MAN_NS);
        Dom.XMLNode groupNumberElement = basicDetailsElement.getChildElement('groupNumber', MAN_NS);

        // check Group Code matches
        String diseGroupCode = groupNumberElement.getText();
        if (groupCode != diseGroupCode) {
            // set error and return
            replyStatus('V0006', 'V', 'MSISDN entered does not exist on customer', MSISDN, groupCode);
            return;
        }
        
        // Populate return data with anything so far
        String accountNumber;
        Dom.XMLNode customerDetailsElement = responseElement.getChildElement('customerDetails', MAN_NS);
        Dom.XMLNode contractAndSalesDetailsElement = responseElement.getChildElement('contractAndSalesDetails', MAN_NS);
        if (basicDetailsElement != null) {
            // tariff code
            Dom.XMLNode tariffCodeElement = basicDetailsElement.getChildElement('tariffCode', MAN_NS);
            if (tariffCodeElement != null) {
                tariffCode = tariffCodeElement.getText();
            }
            // tariff description
            Dom.XMLNode tariffDescriptionElement = basicDetailsElement.getChildElement('tariffDescription', MAN_NS);
            if (tariffDescriptionElement != null) {
                tariffCodeDescription = tariffDescriptionElement.getText();
            }
            // account number (for governor limits lookup)
            Dom.XMLNode accountNumberElement = basicDetailsElement.getChildElement('accountNumber', MAN_NS);
            if (accountNumberElement != null) {
                accountNumber = accountNumberElement.getText();
            }
        }
        if (customerDetailsElement != null) {
            // user name
            Dom.XMLNode userNameElement = customerDetailsElement.getChildElement('userName', MAN_NS);
            if (userNameElement != null) {
                userName = userNameElement.getText();
                if (userName != null) {
                	userName = userName.trim().substringBefore(' ');
                }
            }
            // cost centre code
            Dom.XMLNode customerCostCentreElement = customerDetailsElement.getChildElement('customerCostCentre', MAN_NS);
            if (customerCostCentreElement != null) {
                costCentreCode = customerCostCentreElement.getText();
            }
        }
        if (contractAndSalesDetailsElement != null) {
            // last invoice date
            Dom.XMLNode lastInvoiceDateElement = contractAndSalesDetailsElement.getChildElement('lastInvoiceDate', MAN_NS);
            if (lastInvoiceDateElement != null) {
                lastInvoiceDate = Date.ValueOf(lastInvoiceDateElement.getText());
            }
            // next invoice date
            Dom.XMLNode nextInvoiceDateElement = contractAndSalesDetailsElement.getChildElement('nextInvoiceDate', MAN_NS);
            if (nextInvoiceDateElement != null) {
                nextInvoiceDate = Date.ValueOf(nextInvoiceDateElement.getText());
            }
        }

        // check for Disconnected or Terminated
        String subscriptionStatus = '';
        if (basicDetailsElement != null) {
            Dom.XMLNode subscriptionStatusElement = basicDetailsElement.getChildElement('subscriptionStatus', MAN_NS);
            if (subscriptionStatusElement != null) {
                subscriptionStatus = subscriptionStatusElement.getText();
            }
        }
        if (subscriptionStatus != null && subscriptionStatus != '') {
            subscriptionStatus = subscriptionStatus.toUpperCase();
            if (subscriptionStatus == 'DISCONNECTED'
                || subscriptionStatus == 'NOT CONNECTED'
                || subscriptionStatus == 'CONNECTION FAILED'
                || subscriptionStatus == 'CONNECTION PENDING'
                || subscriptionStatus == 'TERMINATED') {
                // just a warning - do not return
                replyStatus('W0001', 'W', 'Susbscription is terminated or disconnected', MSISDN, groupCode);
            }
        }

        // get SubscriptionID for next callout
        String SubscriptionId = '';
        if (basicDetailsElement != null) {
            Dom.XMLNode subscriptionNumberElement = basicDetailsElement.getChildElement('subscriptionNumber', MAN_NS);
            if (subscriptionNumberElement != null) {
                SubscriptionId = subscriptionNumberElement.getText();
            }
        }

// *******************************
// Second Callout getUnbilledUsage
// *******************************
        envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:view="http://soa.o2.co.uk/viewbusinesscustomerusagedata_2" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
        endpoint = SOA_Integration_Settings__c.getValues('ViewBusinessCustomerUsage_2_0').Endpoint__c;
    
        String unbilledUsageDetailsXml = null;

        // Generate XML request 
        innerXML = '';

        innerXML += '<view:getUnbilledUsage>';
        innerXML +=   '<view:subscriptionFilter>';
        innerXML +=     '<psc:subscriptionID>' + SubscriptionId + '</psc:subscriptionID>';
        innerXML +=   '</view:subscriptionFilter>';
        innerXML += '</view:getUnbilledUsage>';

        // try catch here to catch any catastrophic event
        try {
            unbilledUsageDetailsXml = soaBase.sendRequest(endpoint, envelopeXML, innerXML);
        }
        catch (exception e) {
            // set error and return
            replyStatus('X0099', 'Exceptional System', 'Other internal API error', MSISDN, groupCode);
            return;
        }
        system.debug('+++ unbilledUsageDetailsXml: ' + unbilledUsageDetailsXml);
        

        //
        // check xml for any errors/faults
        //
        // XML to DOM
        document = new Dom.Document();
        document.load(unbilledUsageDetailsXml);
        rootNode = document.getRootElement();
        // Check for soapenv Body element
        bodyElement = rootNode.getChildElement('Body', ENV_NS);
        if (bodyElement == null) {
            replyStatus('X0099', 'X', 'SOA service has technically failed', MSISDN, groupCode);
            return;
        }
        // Check for soapenv Fault element
        faultElement = bodyElement.getChildElement('Fault', ENV_NS);
        if (faultElement != null)
        {
            Dom.XMLNode detailElement = faultElement.getChildElement('detail', null);
            Dom.XMLNode responseFaultElement = detailElement.getChildElement('getUnbilledUsageFault', VIEW_NS);
            
            if (responseFaultElement == null) {
                // there are faults without this node which we can't get description for
                replyStatus('X0099', 'Exceptional System', 'Other internal API error', MSISDN, groupCode);
                return;
            }

            Dom.XMLNode SOAFaultCodeElement = responseFaultElement.getChildElement('SOAFaultCode', COR_NS);
            String faultCode = SOAFaultCodeElement.getText();
            
            Dom.XMLNode faultDescriptionElement = responseFaultElement.getChildElement('faultDescription', COR_NS);
            string faultDescription = faultDescriptionElement.getText();
            
            if (faultCode == 'viewbusinesscustomerusage-36560-3001-E'    ) {
                replyStatus('F0013', 'F', faultDescription.left(50), MSISDN, groupCode);
                return;
            }
            if (faultCode == 'viewbusinesscustomerusage-36560-2001-F'    ) {
                replyStatus('F0009', 'F', 'SOA service has technically failed', MSISDN, groupCode);
                return;
            }
            if (faultCode == 'viewbusinesscustomerusage-36560-2002-F' ||
                faultCode == 'viewbusinesscustomerusage-36560-2003-F' ||
                faultCode == 'viewbusinesscustomerusage-36560-2005-F'    ) {
                replyStatus('X0010', 'X', 'Service not available; try later', MSISDN, groupCode);
                return;
            }
            if (faultCode == 'viewbusinesscustomerusage-36560-2004-F'    ) {
                replyStatus('X0099', 'X', 'SOA service has technically failed', MSISDN, groupCode);
                return;
            }
            if (faultCode == 'viewbusinesscustomerusage-36560-4001-V'    ) {
                replyStatus('V0012', 'V', 'General validation error', MSISDN, groupCode);
                return;
            }
            // catchall set error and return
            replyStatus('X0099', 'X', faultDescription.left(50), MSISDN, groupCode);
            return;
        }
        // assuming if not a fault then SOA call was a success (or warning)

        // get codes from xml
        responseElement = bodyElement.getChildElement('getUnbilledUsageResponse', VIEW_NS);
        Dom.XMLNode statusCodeElement = responseElement.getChildElement('statusCode', VIEW_NS);
        string statusCode = statusCodeElement.getText();
        if (statusCode == 'viewbusinesscustomerusage-36560-6000-W') {
            // just a warning - do not return
            replyStatus('W0002', 'W', 'Too many records to display', MSISDN, groupCode);
        }
        // finished with document now
        document = null;

// *******************************
// Prepare Results To Return
// *******************************
        // aggregate unbilled usage
        UnbilledUnitsTotals uut = new UnbilledUnitsTotals();
        parseUnbilledUsageXmlResponse(unbilledUsageDetailsXml, uut);
        // finished with xml string now
        unbilledUsageDetailsXml = null;


        unbilledUsageSummary.homeVoice = uut.voiceHome;
        unbilledUsageSummary.internationalVoice = uut.voiceInternational;
        unbilledUsageSummary.roamedVoice = uut.voiceRoaming;

        unbilledUsageSummary.homeText = uut.textHome;
        unbilledUsageSummary.internationalText = uut.textInternational;
        unbilledUsageSummary.roamedText = uut.textRoaming;

        unbilledUsageSummary.homeData = uut.dataHome;
        unbilledUsageSummary.roamedData = uut.dataRoaming;

        //approxNextInvoiceAmount = 0;   // TODO - for future use/release = uut.approxNextInvoiceAmount;
        approxNextInvoiceAmount = uut.approxNextInvoiceAmount;

        // Governor Limits search order logic:
        // 1 Search matching Account Number
        // 2 Search matching Cost Centre
        // 3 Search default Account Number (999999) - null fields in this record count as high
        // 4 Search default Cost Centre (999999) - null fields in this record count as high
        // 5 Assume all high values

        String governorLimitsSearchName;
        Unbilled_Usage_Governors__c governors;

        governorLimitsSearchName = diseGroupCode + '-A-' + accountNumber;
        governors = Unbilled_Usage_Governors__c.getInstance(governorLimitsSearchName);
        if (governors==null) {
            governorLimitsSearchName = diseGroupCode + '-C-' + costCentreCode;
            governors = Unbilled_Usage_Governors__c.getInstance(governorLimitsSearchName);
        }
        if (governors==null) {
            governorLimitsSearchName = diseGroupCode + '-A-99999999';
            governors = Unbilled_Usage_Governors__c.getInstance(governorLimitsSearchName);
        }
        if (governors==null) {
            governorLimitsSearchName = diseGroupCode + '-C-99999999';
            governors = Unbilled_Usage_Governors__c.getInstance(governorLimitsSearchName);
        }
        if (governors==null) {
            governors = new Unbilled_Usage_Governors__c(Voice_Home_Allowance_Low__c=99999999.0,
                                                        Voice_Home_Allowance_High__c=99999999.0,
                                                        Voice_International_Allowance_Low__c=99999999.0,
                                                        Voice_International_Allowance_High__c=99999999.0,
                                                        Voice_Roaming_Allowance_Low__c=99999999.0,
                                                        Voice_Roaming_Allowance_High__c=99999999.0,
                                                        Text_Home_Allowance_Low__c=999999.0,
                                                        Text_Home_Allowance_High__c=999999.0,
                                                        Text_International_Allowance_Low__c=999999.0,
                                                        Text_International_Allowance_High__c=999999.0,
                                                        Text_Roaming_Allowance_Low__c=999999.0,
                                                        Text_Roaming_Allowance_High__c=999999.0,
                                                        Data_Home_Allowance_Low__c=999999999999.0,
                                                        Data_Home_Allowance_High__c=999999999999.0,
                                                        Data_Roaming_Allowance_Low__c=999999999999.0,
                                                        Data_Roaming_Allowance_High__c=999999999999.0,
                                                        Account_Code__c='99999999'
                                                       );
        }

        unbilledUsageSummary.homeVoiceLimit = getLimitInSeconds(governors, governors.Voice_Home_Allowance_High__c, MSISDN, groupCode);
        unbilledUsageSummary.homeVoicePercentage = usagePercentage(unbilledUsageSummary.homeVoice, unbilledUsageSummary.homeVoiceLimit, MSISDN, groupCode);
        unbilledUsageSummary.homeVoiceRAG = usageRAG(unbilledUsageSummary.homeVoice, getLimitInSeconds(governors, governors.Voice_Home_Allowance_Low__c, MSISDN, groupCode), unbilledUsageSummary.homeVoiceLimit);

        unbilledUsageSummary.internationalVoiceLimit = getLimitInSeconds(governors, governors.Voice_International_Allowance_High__c, MSISDN, groupCode);
        unbilledUsageSummary.internationalVoicePercentage = usagePercentage(unbilledUsageSummary.internationalVoice, unbilledUsageSummary.internationalVoiceLimit, MSISDN, groupCode);
        unbilledUsageSummary.internationalVoiceRAG = usageRAG(unbilledUsageSummary.internationalVoice, getLimitInSeconds(governors, governors.Voice_International_Allowance_Low__c, MSISDN, groupCode), unbilledUsageSummary.internationalVoiceLimit);

        unbilledUsageSummary.roamedVoiceLimit = getLimitInSeconds(governors, governors.Voice_Roaming_Allowance_High__c, MSISDN, groupCode);
        unbilledUsageSummary.roamedVoicePercentage = usagePercentage(unbilledUsageSummary.roamedVoice, unbilledUsageSummary.roamedVoiceLimit, MSISDN, groupCode);
        unbilledUsageSummary.roamedVoiceRAG = usageRAG(unbilledUsageSummary.roamedVoice, getLimitInSeconds(governors, governors.Voice_Roaming_Allowance_Low__c, MSISDN, groupCode), unbilledUsageSummary.roamedVoiceLimit);


        unbilledUsageSummary.homeTextLimit = getLimitInTexts(governors, governors.Text_Home_Allowance_High__c, MSISDN, groupCode);
        unbilledUsageSummary.homeTextPercentage = usagePercentage(unbilledUsageSummary.homeText, unbilledUsageSummary.homeTextLimit, MSISDN, groupCode);
        unbilledUsageSummary.homeTextRAG = usageRAG(unbilledUsageSummary.homeText, getLimitInTexts(governors, governors.Text_Home_Allowance_Low__c, MSISDN, groupCode), unbilledUsageSummary.homeTextLimit);

        unbilledUsageSummary.internationalTextLimit = getLimitInTexts(governors, governors.Text_International_Allowance_High__c, MSISDN, groupCode);
        unbilledUsageSummary.internationalTextPercentage = usagePercentage(unbilledUsageSummary.internationalText, unbilledUsageSummary.internationalTextLimit, MSISDN, groupCode);
        unbilledUsageSummary.internationalTextRAG = usageRAG(unbilledUsageSummary.internationalText, getLimitInTexts(governors, governors.Text_International_Allowance_Low__c, MSISDN, groupCode), unbilledUsageSummary.internationalTextLimit);

        unbilledUsageSummary.roamedTextLimit = getLimitInTexts(governors, governors.Text_Roaming_Allowance_High__c, MSISDN, groupCode);
        unbilledUsageSummary.roamedTextPercentage = usagePercentage(unbilledUsageSummary.roamedText, unbilledUsageSummary.roamedTextLimit, MSISDN, groupCode);
        unbilledUsageSummary.roamedTextRAG = usageRAG(unbilledUsageSummary.roamedText, getLimitInTexts(governors, governors.Text_Roaming_Allowance_Low__c, MSISDN, groupCode), unbilledUsageSummary.roamedTextLimit);


        unbilledUsageSummary.homeDataLimit = getLimitInKB(governors, governors.Data_Home_Allowance_High__c, MSISDN, groupCode);
        unbilledUsageSummary.homeDataPercentage = usagePercentage(unbilledUsageSummary.homeData, unbilledUsageSummary.homeDataLimit, MSISDN, groupCode);
        unbilledUsageSummary.homeDataRAG = usageRAG(unbilledUsageSummary.homeData, getLimitInKB(governors, governors.Data_Home_Allowance_Low__c, MSISDN, groupCode), unbilledUsageSummary.homeDataLimit);

        unbilledUsageSummary.roamedDataLimit = getLimitInKB(governors, governors.Data_Roaming_Allowance_High__c, MSISDN, groupCode);
        unbilledUsageSummary.roamedDataPercentage = usagePercentage(unbilledUsageSummary.roamedData, unbilledUsageSummary.roamedDataLimit, MSISDN, groupCode);
        unbilledUsageSummary.roamedDataRAG = usageRAG(unbilledUsageSummary.roamedData, getLimitInKB(governors, governors.Data_Roaming_Allowance_Low__c, MSISDN, groupCode), unbilledUsageSummary.roamedDataLimit);


    }




    //--------------------------------------------------------------------------
    // Parse through the XML
    //--------------------------------------------------------------------------
    private void parseUnbilledUsageXmlResponse(String unbilledUsageDetailsXml, UnbilledUnitsTotals uut) {
        XmlStreamReader xsr = new XmlStreamReader(unbilledUsageDetailsXml);
        while (xsr.hasNext()) {
            if (xsr.getEventType() == XmlTag.START_ELEMENT) {
                if ('unbilledUnit' == xsr.getLocalName()) {
                    parseUnbilledUnit(xsr, uut);
                } else if ('totalAmount' == xsr.getLocalName()) {
                    parseEstimatedTotal(xsr, uut);
                }
            }
            if (xsr.hasNext()) {
                xsr.next();
            }
        }
    }
    //--------------------------------------------------------------------------
    // Parse through the XML, enter this method with a totalAmount node in xsr
    //--------------------------------------------------------------------------
    private void parseEstimatedTotal(XmlStreamReader xsr, UnbilledUnitsTotals uut) {
        String totalAmount = null;
        while (xsr.hasNext()) {
            if (xsr.getEventType() == XmlTag.CHARACTERS) {
                totalAmount = xsr.getText();
                if (totalAmount!=null && totalAmount.isNumeric()) {
                    // we got the detail
                    uut.approxNextInvoiceAmount = stringToInteger(totalAmount);
                }
                break;
            }
            if (xsr.hasNext()) {
                xsr.next();
            }
        }
    }
    //--------------------------------------------------------------------------
    // Parse through the XML, enter this method with an unbilledUnit node in xsr
    //--------------------------------------------------------------------------
    private void parseUnbilledUnit(XmlStreamReader xsr, UnbilledUnitsTotals uut) {
        String unitDescription = null;
        String unitQuantity = null;
        while (xsr.hasNext()) {
            if (xsr.getEventType() == XmlTag.END_ELEMENT) {
                if ('unbilledUnit' == xsr.getLocalName()) {
                    if (unitQuantity!=null && unitDescription!=null) {
                        // we got both details for this unbilled unit so aggregate
                        aggregateUnits(unitQuantity, unitDescription, uut);
                    }
                    break;
                }
            } else if (xsr.getEventType() == XmlTag.START_ELEMENT) {
                if ('unitsUsed' == xsr.getLocalName()) {
                    xsr.next();
                    if (xsr.getEventType() == XmlTag.CHARACTERS) {
                        unitQuantity = xsr.getText();
                    }
                } else if ('classificationDescription' == xsr.getLocalName()) {
                    xsr.next();
                    if (xsr.getEventType() == XmlTag.CHARACTERS) {
                        unitDescription = xsr.getText();
                    }
                } /*else if ('callPrice' == xsr.getLocalName()) {
                    xsr.next();
                    if (xsr.getEventType() == XmlTag.CHARACTERS) {
                        uut.approxNextInvoiceAmount += stringToInteger(xsr.getText());
                    }
                }*/
            }
            
            if (xsr.hasNext()) {
                xsr.next();
            }
        }
    }
    private void aggregateUnits(String unitQuantity, String unitDescription, UnbilledUnitsTotals uut) {
        
        // 
        Unbilled_Usage_Params__c uup = Unbilled_Usage_Params__c.getInstance(unitDescription);
        if (uup != null) {
            if (uup.Call_Type__c == 'VH') {
                uut.voiceHome += stringToInteger(unitQuantity);
            }
            if (uup.Call_Type__c == 'VI') {
                uut.voiceInternational += stringToInteger(unitQuantity);
            }
            if (uup.Call_Type__c == 'VR') {
                uut.voiceRoaming += stringToInteger(unitQuantity);
            }
            if (uup.Call_Type__c == 'TH') {
                uut.textHome += stringToInteger(unitQuantity);
            }
            if (uup.Call_Type__c == 'TI') {
                uut.textInternational += stringToInteger(unitQuantity);
            }
            if (uup.Call_Type__c == 'TR') {
                uut.textRoaming += stringToInteger(unitQuantity);
            }
            if (uup.Call_Type__c == 'DH') {
                uut.dataHome += stringToInteger(unitQuantity);
            }
            if (uup.Call_Type__c == 'DR') {
                uut.dataRoaming += stringToInteger(unitQuantity);
            }
        }
    }


    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------
    private Integer usagePercentage(Integer amountUsed, String theLimit, String MSISDN, String groupCode) {
        if ('H'==theLimit) {
            return 0;
        }
        if (amountUsed>0 && theLimit=='0') {
            return 101;
        }
        if (amountUsed<=0 && theLimit=='0') {
            return 0;
        }
        if (stringToInteger(theLimit)==0) {
            replyStatus('W0004', 'W', 'Reference table fault', MSISDN, groupCode);
            return 0;
        }
        return amountUsed * 100 / stringToInteger(theLimit);
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------
    private String usageRAG(Integer amountUsed, String limitLow, String limitHigh) {
        if (limitLow=='H' || limitHigh=='H') {
            return 'G';
        }
        Decimal lowDecimal = Decimal.ValueOf(limitLow);
        Decimal highDecimal = Decimal.ValueOf(limitHigh);
        if (amountUsed<lowDecimal) {
            return 'G';
        }
        if (amountUsed>=highDecimal) {
            return 'R';
        }
        return 'A';
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------
    private String getLimitInSeconds(Unbilled_Usage_Governors__c governors, Decimal theLimit, String MSISDN, String groupCode) {
        if (governors.Account_Code__c=='99999999' || governors.Cost_Centre__c=='99999999') {
            if (theLimit==null || theLimit==99999999.0) {
                return 'H';
            }
        }
        if (theLimit==null || theLimit<0) {
            replyStatus('W0004', 'W', 'Reference table fault', MSISDN, groupCode);
            return '0';
        }
        return theLimit.toPlainString().substringBefore('.');
    }
    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------
    private String getLimitInTexts(Unbilled_Usage_Governors__c governors, Decimal limitInTexts, String MSISDN, String groupCode) {
        if (governors.Account_Code__c=='99999999' || governors.Cost_Centre__c=='99999999') {
            if (limitInTexts==null || limitInTexts==999999.0) {
                return 'H';
            }
        }
        if (limitInTexts==null || limitInTexts<0) {
            replyStatus('W0004', 'W', 'Reference table fault', MSISDN, groupCode);
            return '0';
        }
        return limitInTexts.toPlainString().substringBefore('.');
    }
    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------
    private String getLimitInKB(Unbilled_Usage_Governors__c governors, Decimal theLimit, String MSISDN, String groupCode) {
        if (governors.Account_Code__c=='99999999' || governors.Cost_Centre__c=='99999999') {
            if (theLimit==null || theLimit==999999999999.0) {
                return 'H';
            }
        }
        if (theLimit==null || theLimit<0) {
            replyStatus('W0004', 'W', 'Reference table fault', MSISDN, groupCode);
            return '0';
        }
        return theLimit.toPlainString().substringBefore('.');
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------
    private Integer stringToInteger(String amount) {
        return (amount==null || amount=='' || !amount.isNumeric()) ? 0 : integer.valueOf(amount);
    }

    //--------------------------------------------------------------------------
    // 
    //--------------------------------------------------------------------------
    private void replyStatus(String responseCode, String responseCodeType, String responseCodeDescription, String MSISDN, String groupCode) {
        System.debug('ServiceUnbilledUsageSummary.replyStatus ' + responseCode + ' ' + responseCodeType + ' for MSISDN:' + MSISDN + ', GroupCode:' + groupCode + ' Description:' + responseCodeDescription);
        //
        responseDetails.responseCode = responseCode;
        responseDetails.responseCodeType = responseCodeType;
        responseDetails.responseCodeDescription = responseCodeDescription;
    }


  }

}