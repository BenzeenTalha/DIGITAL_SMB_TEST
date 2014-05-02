public with sharing class CaseCallout_GetSubscriptionDetails 
{
	static final String envelopeXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
	static final String endpoint = SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0').Endpoint__c;

	static final String envelopeXMLPUK = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">';
	static final String endpointPUK = SOA_Integration_Settings__c.getValues('Subscriber').Endpoint__c;

	static final String envelopeXMLBoltOns = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1" xmlns:view="http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1">'; 
	static final String endpointBoltOns = SOA_Integration_Settings__c.getValues('Manage_Business_Customer_Details').Endpoint__c;


	private static final string ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
	private static final string MAN_NS = 'http://soa.o2.co.uk/managebusinesssubscriptionsdata_1';
	private static final string PSC_NS = 'http://soa.o2.co.uk/dise/pscommondisedata_1';
	private static final string COR_NS = 'http://soa.o2.co.uk/coredata_1';
	private static final string SUB_NS = 'http://soa.o2.co.uk/subscriberdata_2';
	private static final string VIEW_NS = 'http://soa.o2.co.uk/managebusinesscustomerdetailsdata_1';

	public SOAServicesBase soaBase = null;  

	public static Boolean FORCE_TEST_MODE = false;

	@future (callout=true)
	public static void executeFuture(set<Id> subExtraSubsetIds)
	{
		// system.debug('PUKCodeFlag in executeFutureCall'+MyO2BusinessSubscriptionsController.PUKCodeFlag);
		list<AC_Subscription_Extra__c> subsExtra = [Select Term_of_Contract__c, 
		                                            //Tariff_Description__c, 
		                                            //Subscription_Name__c, 
		                                            Subscription_ID__c, 
		                                            SIM_Number__c, 
		                                            Name, 
		                                            Mobile_Number__c, 
		                                            Last_Amended_Date_Subscription_Bars__c,
		                                            Last_Amended_Date_Serial_Numbers__c, 
		                                            Last_Amended_Date_Customer_Details__c, 
		                                            Last_Callout_Date__c,
		                                            LastModifiedDate, 
		                                            Id, 
		                                            //Customer_Cost_Centre__c, 
		                                            Callout_Error__c,
		                                            //Agreement_Number__c,
		                                            Mobile_Extension_Number__c, 
		                                            Group_Mobile_Number__c,
		                                            IMEI_Number__c,
		                                            Next_Invoice_Date__c,

		                                            AC_Subscription__r.Agreement_ID__c,
		                                            AC_Subscription__r.Tariff_Code__c,
		                                            AC_Subscription__r.Tariff_Description__c,
		                                            AC_Subscription__r.Contract_ID__c,
		                                            AC_Subscription__r.Customer_Cost_Centre__c,
		                                            AC_Subscription__r.Subscription_Name__c,
		                                            AC_Subscription__r.Network_Code__c,
		                                            AC_Subscription__r.Network_Serial_No__c,

		                                            GPRS__c, 
		                                            Roaming_Call_Bar_Display__c, 
		                                            Premium_Call_Bar_Display__c, 
		                                            International__c,
		                                            Device_Bar__c,
		                                            Full_Bar__c, 

		                                            Premium_rate_call_bar__c, 
		                                            Stolen_Bar__c,
		                                            O2_only_roam_bar__c, 
		                                            Internet_premium_call_bar__c, 
		                                            International_premium_roam__c, 
		                                            International_prem_roam_local__c, 
		                                            International_Call_Bar_Display__c, //
		                                            International_Bar__c, 
		                                            IMEI_Bar__c, 
		                                            GPRS_Bar__c, 
		                                            Fullbar_with_no_msg__c, 
		                                            Fullbar_with_msg__c, 
		                                            Chat_Bar__c, 
		                                            Bars_h_s_for_calls_from_o_s_UK__c, 
		                                            Adult_and_Chat_Bar__c, 
		                                            Adult_Bar__c, 
		                                            Add_full_international_access__c, 
		                                            Add_Premium_Adult_Bar__c, 
		                                            PUK_Code_Flag__c,
		                                            BoltOns_Flag__c,
		                                            AC_Subscription__c,
		                                            Contractual_Bolt_Ons__c,
		                                            Other_Bolt_Ons__c,
		                                            Service_Code__c,
		                                            Package_Code__c,
		                                            Effective_Date__c,
		                                            Expiry_Date__c
		                                            From AC_Subscription_Extra__c
		                                            Where  Id IN : subExtraSubsetIds];



		list<AC_Subscription__c> subs = new list<AC_Subscription__c>();
		if(subsExtra.size()>0) 
		{
			for(AC_Subscription_Extra__c subExtra : subsExtra)
			{
				subExtra.Callout_Error__c = false;

				//reset all bars to false so the callout can update them
				subExtra.Device_Bar__c = false;
				subExtra.Full_Bar__c = false;
				subExtra.International__c = false;
				subExtra.Premium_Call_Bar_Display__c = false;
				subExtra.Roaming_Call_Bar_Display__c = false;
				subExtra.GPRS__c = false;

				subExtra.IMEI_Bar__c = false;
				subExtra.Fullbar_with_no_msg__c = false;
				subExtra.Fullbar_with_msg__c = false;
				subExtra.Stolen_Bar__c = false;
				subExtra.International_Call_Bar_Display__c = false;
				subExtra.Add_full_international_access__c = false;
				subExtra.Internet_premium_call_bar__c = false;
				subExtra.International_Bar__c = false;
				subExtra.International_prem_roam_local__c = false;
				subExtra.International_premium_roam__c = false;
				subExtra.Premium_rate_call_bar__c = false;
				subExtra.Add_Premium_Adult_Bar__c = false;
				subExtra.Adult_and_Chat_Bar__c = false;
				subExtra.Adult_Bar__c = false;
				subExtra.Chat_Bar__c = false;
				subExtra.Bars_h_s_for_calls_from_o_s_UK__c = false;
				subExtra.O2_only_roam_bar__c = false;
				subExtra.GPRS_Bar__c = false;
				subExtra.Contractual_Bolt_Ons__c = null;
				subExtra.Other_Bolt_Ons__c = null;
				subExtra.Package_Code__c = null;
				subExtra.Service_Code__c = null;
				subExtra.Effective_Date__c = null;
				subExtra.Expiry_Date__c = null;
				
				System.debug('**subExtra**'+subExtra);
				//call the web service
				try{
					subExtra = invokeGetDetails(subExtra);
				}catch(Exception e){
					throw e;
				}

				system.debug('**subExtra---------------->>>>**'+subExtra);
				subExtra.Last_Callout_Date__c = system.now();

				if(!subExtra.Callout_Error__c)
				{
					AC_Subscription__c sub = subExtra.AC_Subscription__r;
					subs.add(sub);
				}
			}
			system.debug('*** subs: ' + subs);


			if(!subsExtra.isEmpty()){
				system.debug('subsExtra-size-->>'+subsExtra.size());
				system.debug('subsExtra--->>'+subsExtra);
				Database.upsert(subsExtra);
			}
			if(!subs.isEmpty()){
				Database.update(subs);
			}
				

		}

	}

	/********************************************************************************************/
	//callout to the getSubscriptionDetails_1 service
	public static AC_Subscription_Extra__c invokeGetDetails(AC_Subscription_Extra__c subExtra)
	{
		//  system.debug('PUKCodeFlag in invokeDetails'+MyO2BusinessSubscriptionsController.PUKCodeFlag);
		// Pre-existing classes to interact with SOA service
		SOAServicesBase soaBase = new SOAServicesBase();

		String resXml = null;

		System.debug('***Flag Value***'+subExtra.PUK_Code_Flag__c);
		// Generate XML request 


		if((!subExtra.PUK_Code_Flag__c)){

			String innerXML = '';
			innerXML += '<man:getSubscriptionDetails_1>';
			innerXML +=     '<man:subscriptionData>';
			innerXML +=         '<psc:subscriptionID>' + subExtra.Subscription_ID__c + '</psc:subscriptionID>';
			innerXML +=     '</man:subscriptionData>';
			innerXML +=     '<man:subscriptionDataFilters>';
			innerXML +=         '<man:subscriptionDataFilter>BASIC</man:subscriptionDataFilter>';
			innerXML +=         '<man:subscriptionDataFilter>CONTRACTANDSALES</man:subscriptionDataFilter>';
			innerXML +=         '<man:subscriptionDataFilter>CUSTOMERDETAILS</man:subscriptionDataFilter>';
			innerXML +=         '<man:subscriptionDataFilter>SERIALNUMBERS</man:subscriptionDataFilter>';
			innerXML +=         '<man:subscriptionDataFilter>SUBSCRIPTIONBARS</man:subscriptionDataFilter>';
			innerXML +=         '<man:subscriptionDataFilter>SERVICES</man:subscriptionDataFilter>';
			innerXML +=     '</man:subscriptionDataFilters>';
			innerXML += '</man:getSubscriptionDetails_1>';

			system.debug('**NornmalinnerXML**'+innerXML);
			resXml = soaBase.sendRequest(endpoint, envelopeXML, innerXML); 
			system.debug('xml response is :' + resXml);
		}else {
			String NetworkSerialNumberCopy = subExtra.AC_Subscription__r.Network_Serial_No__c;
			Integer SerialNoLength = NetworkSerialNumberCopy.Length();
			System.debug('**NetworkSerialNumberCopy**'+NetworkSerialNumberCopy);
			String trimSerialNo = NetworkSerialNumberCopy.substring(1,SerialNoLength);

			System.debug('**trimSerialNo1**'+trimSerialNo);

			trimSerialNo = '44' + trimSerialNo;
			System.debug('**trimSerialNo2**'+trimSerialNo);


			String innerXML = '';
			innerXML +='<sub:getSubscriberProfile>';
			innerXML +='<sub:subscriberID>'+trimSerialNo+'</sub:subscriberID>';
			innerXML +='</sub:getSubscriberProfile>';

			system.debug('**innerXML**'+innerXML);

			resXml = soaBase.sendRequest(endpointPUK, envelopeXMLPUK, innerXML);

		}

		/*
		if(test.isrunningtest()){
			if (subExtra.PUK_Code_Flag__c) {
				resXml = '<?xml version="1.0" encoding="UTF-8"?>';
				resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
				resXml += '<soapenv:Header xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">';
				resXml += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">837239e0-e144-49e4-8f84-0715af20a390</cor:SOATransactionID>';
				resXml += '</soapenv:Header>';
				resXml += '<env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
				resXml += '<sub:getSubscriberProfileResponse xmlns:sub="http://soa.o2.co.uk/subscriberdata_2">';
				resXml += '<sub:subscriberProfile>';
				resXml += '<sub:subscriberID>447702059016</sub:subscriberID>';
				resXml += '<sub:operator>O2</sub:operator>';
				resXml += '<sub:paymentCategory>Postpay</sub:paymentCategory>';
				resXml += '<sub:segment>SME</sub:segment>';
				resXml += '<sub:serviceProviderID>486</sub:serviceProviderID>';
				resXml += '<sub:status>A</sub:status>';
				resXml += '<sub:puk>1234</sub:puk>';
				resXml += '</sub:subscriberProfile>';
				resXml += '</sub:getSubscriberProfileResponse>';
				resXml += '</env:Body>';
				resXml += '</soapenv:Envelope>';
			}
			else if (!subExtra.BoltOns_Flag__c) {

				resXml = '<?xml version="1.0" encoding="UTF-8"?>';
				resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
				resXml += '<soapenv:Header xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1"><cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">153f8847-80e1-4dd9-b472-bcaba8612f6b</cor:SOATransactionID></soapenv:Header>';
				resXml += '<soapenv:Body xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1">';
				resXml += '<man:getSubscriptionDetails_1Response><man:basicDetails><man:subscriptionNumber>10607010</man:subscriptionNumber>';
				resXml += '<man:agreementNumber>3779758</man:agreementNumber><man:accountNumber>4064960</man:accountNumber><man:corporateNumber>AAROAD</man:corporateNumber>';
				resXml += '<man:groupNumber>THEAA</man:groupNumber><man:companyNumber>001</man:companyNumber><man:salesAccountCode>3196</man:salesAccountCode>';
				resXml += '<man:salesAccountCategory>Direct</man:salesAccountCategory><man:subscriptionStatus>Normal</man:subscriptionStatus><man:tariffCode>AAPAT1</man:tariffCode>';
				resXml += '<man:tariffDescription>Mobile Broadband 5GB</man:tariffDescription><man:networkCode>CDIG</man:networkCode><man:connectedDate>2011-08-01</man:connectedDate>';
				resXml += '<man:connectionReason>NB</man:connectionReason><man:lastAmendedDate>2013-07-19T06:59:56.000Z</man:lastAmendedDate>';
				resXml += '</man:basicDetails>';

				resXml += '<man:customerDetails><man:userName>John Davies 104959</man:userName><man:itemCode>23GPUNIN</man:itemCode>';
				resXml += '<man:directoryListingAllowed>true</man:directoryListingAllowed><man:customerCostCentre>A7822</man:customerCostCentre>';
				resXml += '<man:lastAmendedDate>2013-07-19T06:59:56.000Z</man:lastAmendedDate>';
				resXml += '</man:customerDetails>';

				resXml += '<man:contractAndSalesDetails><man:contractNumber>Unassigned</man:contractNumber>';
				resXml += '<man:firstInvoiceDate>2011-08-05</man:firstInvoiceDate><man:lastInvoiceDate>2013-07-05</man:lastInvoiceDate>';
				resXml += '<man:nextInvoiceDate>2013-08-05</man:nextInvoiceDate><man:contractStartDate>2011-08-01</man:contractStartDate>';
				resXml += '<man:termOfContract>36</man:termOfContract><man:termsAndConditionsCode>STD</man:termsAndConditionsCode>';
				resXml += '<man:terminationInvoiceProduced>false</man:terminationInvoiceProduced><man:lastAmendedDate>2013-07-19T06:59:56.000Z</man:lastAmendedDate>';
				resXml += '</man:contractAndSalesDetails>';

				resXml += '<man:serialNumberDetails><man:managedSerialNumbers><man:managedSerialNumber><man:networkSerialNumberID>1</man:networkSerialNumberID>';
				resXml += '<man:networkSerialNumber>447738770927</man:networkSerialNumber><man:networkEffectiveDate>2011-08-01</man:networkEffectiveDate>';
				resXml += '<man:networkCode>CDIG</man:networkCode><man:networkSerialStatus>Current</man:networkSerialStatus><man:lastAmendedDate>2011-08-01T13:35:52.000Z</man:lastAmendedDate>';
				resXml += '</man:managedSerialNumber></man:managedSerialNumbers>';
				resXml += '</man:serialNumberDetails></man:getSubscriptionDetails_1Response></soapenv:Body></soapenv:Envelope>';        
			}
			else {
				resXml = '<?xml version="1.0" encoding="UTF-8"?>';
				resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
				resXml += '<soapenv:Header xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1">';
				resXml += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">becceb51-fc84-42e5-9c3b-c665796931d8</cor:SOATransactionID>';
				resXml += '</soapenv:Header>';
				resXml += '<soapenv:Body xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1">';
				resXml += '<man:getSubscriptionDetails_1Response>';
				resXml += '<man:basicDetails>';
				resXml += '<man:subscriptionNumber>13041999</man:subscriptionNumber>';
				resXml += '<man:agreementNumber>2605545</man:agreementNumber>';
				resXml += '<man:accountNumber>4901518</man:accountNumber>';
				resXml += '<man:corporateNumber>BRTMOB</man:corporateNumber>';
				resXml += '<man:groupNumber>BRITVI</man:groupNumber>';
				resXml += '<man:companyNumber>001</man:companyNumber>';
				resXml += '<man:salesAccountCode>53808</man:salesAccountCode>';
				resXml += '<man:salesAccountCategory>Direct</man:salesAccountCategory>';
				resXml += '<man:subscriptionStatus>Normal</man:subscriptionStatus>';
				resXml += '<man:tariffCode>BR1MDS</man:tariffCode>';
				resXml += '<man:tariffDescription>Mobile Extension Data Sense</man:tariffDescription>';
				resXml += '<man:networkCode>CDIG</man:networkCode>';
				resXml += '<man:connectedDate>2013-07-29</man:connectedDate>';
				resXml += '<man:connectionReason>NB</man:connectionReason>';
				resXml += '<man:lastAmendedDate>2013-09-20T21:04:18.000Z</man:lastAmendedDate>';
				resXml += '</man:basicDetails>';
				resXml += '<man:customerDetails>';
				resXml += '<man:userName>William Heathcote</man:userName>';
				resXml += '<man:directoryListingAllowed>true</man:directoryListingAllowed>';
				resXml += '<man:customerCostCentre>8008430</man:customerCostCentre>';
				resXml += '<man:lastAmendedDate>2013-09-20T21:04:18.000Z</man:lastAmendedDate>';
				resXml += '</man:customerDetails>';
				resXml += '<man:serviceDetails>';
				resXml += '<man:service>';
				resXml += '<man:serviceCode>FOCIB</man:serviceCode>';
				resXml += '<man:packageCode>BR1PK1</man:packageCode>';
				resXml += '<man:servicePrice>0</man:servicePrice>';
				resXml += '<man:description>Free Itemised Billing</man:description>';
				resXml += '<man:effectiveDate>2013-07-29</man:effectiveDate>';
				resXml += '<man:lastAmendedDate>2013-08-30T01:01:21.000Z</man:lastAmendedDate>';
				resXml += '</man:service>';
				resXml += '<man:service>';
				resXml += '<man:serviceCode>FOCITS</man:serviceCode>';
				resXml += '<man:packageCode>BR1PK1</man:packageCode>';
				resXml += '<man:servicePrice>0</man:servicePrice>';
				resXml += '<man:description>Int Traveller Service - FOC</man:description>';
				resXml += '<man:effectiveDate>2013-07-29</man:effectiveDate>';
				resXml += '<man:lastAmendedDate>2013-08-30T01:01:21.000Z</man:lastAmendedDate>';
				resXml += '</man:service>';
				resXml += '<man:service>';
				resXml += '<man:serviceCode>LINECH</man:serviceCode>';
				resXml += '<man:packageCode>BR1PK1</man:packageCode>';
				resXml += '<man:servicePrice>0</man:servicePrice>';
				resXml += '<man:description>Line Rental Charge</man:description>';
				resXml += '<man:effectiveDate>2013-07-29</man:effectiveDate>';
				resXml += '<man:lastAmendedDate>2013-08-30T01:01:21.000Z</man:lastAmendedDate>';
				resXml += '</man:service>';
				resXml += '</man:serviceDetails>';
				resXml += '</man:getSubscriptionDetails_1Response>';
				resXml += '</soapenv:Body>';
				resXml += '</soapenv:Envelope>';
			}

		}*/       
		system.debug('*** resXml: ' + resXml);

		subExtra = processResultXML(resXml, subExtra);

		return subExtra;

	}

	public static String FormatPrice(String servicePriceFromDise)
	{
		String price = servicePriceFromDise;
		Integer priceLen = price.length();
		if (priceLen < 3){
			for (Integer i = 0; i < (3-priceLen); i++){
				price = '0' + price;
			}
		}

		priceLen = price.length();

		String priceFormatted = price.substring(0, (priceLen - 2)) + '.' + price.substring((priceLen - 2), (priceLen)); 
		return priceFormatted;


	} 



	private static AC_Subscription_Extra__c processResultXML(string resultXML, AC_Subscription_Extra__c subExtra)
	{
		// System.debug('**PUKCodeFlag in processXML'+MyO2BusinessSubscriptionsController.PUKCodeFlag);
		System.debug('PUKCODEFlag'+subExtra.PUK_Code_Flag__c);
		system.debug('subExtra****'+subExtra);

		// XML to DOM
		Dom.Document document = new Dom.Document();
		document.load(resultXML);
		Dom.XMLNode rootNode = document.getRootElement();

		CaseUtils.SOAResponseDetail SOAResponse = new CaseUtils.SOAResponseDetail();


		// Check for soapenv Body element
		Dom.XMLNode bodyElement = rootNode.getChildElement('Body', ENV_NS);
		Dom.XMLNode faultElement ;

		if(bodyElement!= null){

			// Check for soapenv Fault element
			faultElement = bodyElement.getChildElement('Fault', ENV_NS);
		}


		if (faultElement != null)
		{
			subExtra.Callout_Error__c = true;
			/*Dom.XMLNode detailElement = faultElement.getChildElement('detail', null);
            Dom.XMLNode responseFaultElement = detailElement.getChildElement('getSubscriptionDetails_1Fault', MAN_NS);

            Dom.XMLNode SOAFaultCodeElement = responseFaultElement.getChildElement('SOAFaultCode', COR_NS);
            SOAResponse.SOAFaultCode = SOAFaultCodeElement.getText();

            Dom.XMLNode faultDescriptionElement = responseFaultElement.getChildElement('faultDescription', COR_NS);
            SOAResponse.faultDescription = faultDescriptionElement.getText();

            Dom.XMLNode faultTraceElement = responseFaultElement.getChildElement('faultTrace', COR_NS);
            SOAResponse.faultTrace = faultTraceElement.getText();

            throw new CaseUtils.SOAFaultException(SOAResponse.SOAFaultCode, SOAResponse.faultDescription, SOAResponse.faultTrace);*/
		}
		else if(subExtra.PUK_Code_Flag__c){
			System.debug('Inside PUK');
			Dom.XMLNode responseElement = bodyElement.getChildElement('getSubscriberProfileResponse', SUB_NS);

			System.debug('responseElement1'+responseElement);

			Dom.XMLNode basicDetailsElement = responseElement.getChildElement('subscriberProfile', SUB_NS);
			system.debug('subExtra'+subExtra);
			if (basicDetailsElement != null){
				subExtra.PUK_Code__c = CaseUtils.getElemText(basicDetailsElement, 'puk', SUB_NS);  
				subExtra.PUK_Code_Flag__c = false;

				System.debug('**subExtra.PUK_Code__c**'+subExtra.PUK_Code__c);              
			}
		}else

		{
			// Check for getSubscriptionDetails_1Response element
			Dom.XMLNode responseElement = bodyElement.getChildElement('getSubscriptionDetails_1Response', MAN_NS);

			//**BASIC details**//
			Dom.XMLNode basicDetailsElement = responseElement.getChildElement('basicDetails', MAN_NS);
			if (basicDetailsElement != null)
			{
				subExtra.Subscription_ID__c = CaseUtils.getElemText(basicDetailsElement, 'subscriptionNumber', MAN_NS);
				subExtra.AC_Subscription__r.Agreement_ID__c = CaseUtils.getElemText(basicDetailsElement, 'agreementNumber', MAN_NS);
				subExtra.AC_Subscription__r.Tariff_Description__c = CaseUtils.getElemText(basicDetailsElement, 'tariffDescription', MAN_NS);
				subExtra.Tariff_Description__c=CaseUtils.getElemText(basicDetailsElement, 'tariffDescription', MAN_NS);
				subExtra.AC_Subscription__r.Tariff_Code__c = CaseUtils.getElemText(basicDetailsElement, 'tariffCode', MAN_NS);
				subExtra.DISE_Account_No__c  = CaseUtils.getElemText(basicDetailsElement, 'accountNumber', MAN_NS); 

			}

			//**CONTRACTANDSALES details**//
			Dom.XMLNode contractAndSalesElement = responseElement.getChildElement('contractAndSalesDetails', MAN_NS);
			if (contractAndSalesElement != null)
			{
				subExtra.Term_of_Contract__c = CaseUtils.getElemText(contractAndSalesElement, 'termOfContract', MAN_NS);
				subExtra.Next_Invoice_Date__c = CaseUtils.parseDateFromString(CaseUtils.getElemText(contractAndSalesElement, 'nextInvoiceDate', MAN_NS));
				subExtra.AC_Subscription__r.Contract_ID__c = CaseUtils.getElemText(contractAndSalesElement, 'contractNumber', MAN_NS);
			}

			//**CUSTOMER details**//
			Dom.XMLNode customerDetailsElement = responseElement.getChildElement('customerDetails', MAN_NS);
			if (customerDetailsElement != null)
			{
				subExtra.AC_Subscription__r.Subscription_Name__c = CaseUtils.getElemText(customerDetailsElement, 'userName', MAN_NS);
				subExtra.Subscription_Name__c=CaseUtils.getElemText(customerDetailsElement, 'userName', MAN_NS);
				System.debug('$$subExtra.AC_Subscription__r.Subscription_Name__c---'+subExtra.AC_Subscription__r.Subscription_Name__c);
				subExtra.AC_Subscription__r.Customer_Cost_Centre__c = CaseUtils.getElemText(customerDetailsElement, 'customerCostCentre', MAN_NS);
				system.debug('$$subExtra.AC_Subscription__r.Customer_Cost_Centre__c --'+subExtra.AC_Subscription__r.Customer_Cost_Centre__c );
				subExtra.Last_Amended_Date_Customer_Details__c = CaseUtils.getElemText(customerDetailsElement, 'lastAmendedDate', MAN_NS);
			}
			//**SERIALNUMBER details**//
			Dom.XMLNode serialNumberDetailsElement = responseElement.getChildElement('serialNumberDetails', MAN_NS);
			if (serialNumberDetailsElement != null)
			{
				Dom.XMLNode managedSerialNumbersElement = serialNumberDetailsElement.getChildElement('managedSerialNumbers', MAN_NS);
				if (managedSerialNumbersElement != null)
				{
					for(Dom.XMLNode elem : managedSerialNumbersElement.getChildElements())
					{
						string networkSerialNumberID = CaseUtils.getElemText(elem, 'networkSerialNumberID', MAN_NS);
						string networkSerialNumber   = CaseUtils.getElemText(elem, 'networkSerialNumber', MAN_NS);
						string networkEffectiveDate  = CaseUtils.getElemText(elem, 'networkEffectiveDate', MAN_NS);
						string networkCode           = CaseUtils.getElemText(elem, 'networkCode', MAN_NS);
						string networkSerialStatus   = CaseUtils.getElemText(elem, 'networkSerialStatus', MAN_NS);
						string lastAmendedDate       = CaseUtils.getElemText(elem, 'lastAmendedDate', MAN_NS);

						if(networkSerialNumberID == '1')
						{
							subExtra.AC_Subscription__r.Network_Serial_No__c = CaseUtils.changeNumberFormat(networkSerialNumber);
							subExtra.Mobile_Number__c = CaseUtils.changeNumberFormat(networkSerialNumber);
						}
						else if(networkSerialNumberID == '2')
						{
							subExtra.SIM_Number__c = networkSerialNumber;
							subExtra.Last_Amended_Date_Serial_Numbers__c = lastAmendedDate;
						}
						else if(networkSerialNumberID == '3')
						{
							subExtra.Mobile_Extension_Number__c = networkSerialNumber;
						}
						else if(networkSerialNumberID == '4')
						{
							subExtra.IMEI_Number__c = networkSerialNumber;
						}
						else if(networkSerialNumberID == '5')
						{
							subExtra.Group_Mobile_Number__c = networkSerialNumber;
						}
					}
				}
			}
			//**SUBSCRIPTIONBARS details**//
			Dom.XMLNode subscriptionBarDetailsElement = responseElement.getChildElement('subscriptionBarDetails', MAN_NS);
			if (subscriptionBarDetailsElement != null)
			{
				for(Dom.XMLNode elem : subscriptionBarDetailsElement.getChildElements())
				{
					string networkCommandCode        = CaseUtils.getElemText(elem, 'networkCommandCode', MAN_NS);
					string barredDate                = CaseUtils.getElemText(elem, 'barredDate', MAN_NS);
					string unBarredDate              = CaseUtils.getElemText(elem, 'unBarredDate', MAN_NS);
					//string unbarReasonCode           = CaseUtils.getElemText(elem, 'unbarReasonCode', MAN_NS);
					//string unbarReasonDescription    = CaseUtils.getElemText(elem, 'unbarReasonDescription', MAN_NS);
					//string barReasonCode               = CaseUtils.getElemText(elem, 'barReasonCode', MAN_NS);
					//string barReasonDescription        = CaseUtils.getElemText(elem, 'barReasonDescription', MAN_NS);
					//string adminBarFlag                = CaseUtils.getElemText(elem, 'adminBarFlag', MAN_NS);
					//string lastAmendedDate         = CaseUtils.getElemText(elem, 'lastAmendedDate', MAN_NS);
					System.debug('process result xml, network command code = ' + networkCommandCode);
					System.debug('process result xml, unBarredDate = ' + unBarredDate);
					//IMEI Bar
					if(networkCommandCode == Label.MO2B_BAR_IMEI && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.IMEI_Bar__c = true;
						subExtra.Device_Bar__c = true;
					}
					//full bar with no message
					else if(networkCommandCode == Label.MO2B_BAR_FULL_WITH_NO_MESSAGE && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Fullbar_with_no_msg__c = true;
						subExtra.Full_Bar__c = true;
					}
					//full bar with message
					else if(networkCommandCode == Label.MO2B_BAR_FULL_WITH_MESSAGE && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Fullbar_with_msg__c = true;
						subExtra.Full_Bar__c = true;
					}
					//Stolen Bar
					else if(networkCommandCode == Label.MO2B_BAR_STOLEN && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Stolen_Bar__c = true;
						subExtra.Full_Bar__c = true;
					}
					//international call bar
					else if(networkCommandCode == Label.MO2B_BAR_INTERNATIONAL_CALL && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.International__c = true;
						subExtra.International_Call_Bar_Display__c = true;
					}
					//Add full international access
					else if(networkCommandCode == Label.MO2B_BAR_FULL_INTERNATIONAL_ACCESS && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Add_full_international_access__c = true;
						subExtra.International_Call_Bar_Display__c = true;
					}
					//internat & premium call bar
					else if(networkCommandCode == Label.MO2B_BAR_INTERNAT_PREMIUM_CALL && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Internet_premium_call_bar__c = true;
						subExtra.International_Call_Bar_Display__c = true;
						subExtra.Premium_Call_Bar_Display__c = true;
					}
					//International Bar
					else if(networkCommandCode == Label.MO2B_BAR_INTERNATIONAL && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.International_Bar__c = true;
						subExtra.International_Call_Bar_Display__c = true;
					}
					//international+prem+roam+local
					else if(networkCommandCode == Label.MO2B_BAR_INTERNATIONAL_PREMIUM_ROAM_LOCAL    && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.International_prem_roam_local__c = true;
						subExtra.International_Call_Bar_Display__c = true;
						subExtra.Premium_Call_Bar_Display__c = true;
						subExtra.Roaming_Call_Bar_Display__c = true;
					}
					//International+premium+roam bar
					else if(networkCommandCode == Label.MO2B_BAR_INTERNATIONAL_PREMIUM_ROAM  && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.International_premium_roam__c = true;
						subExtra.International_Call_Bar_Display__c = true;
						subExtra.Premium_Call_Bar_Display__c = true;
						subExtra.Roaming_Call_Bar_Display__c = true;

					}
					//premium rate call bar
					else if(networkCommandCode == Label.MO2B_BAR_PREMIUM_RATE_CALL && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Premium_rate_call_bar__c = true;
						subExtra.Premium_Call_Bar_Display__c = true;
					}
					//Add Premium Adult Bar
					else if(networkCommandCode == Label.MO2B_BAR_PREMIUM_ADULT && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Add_Premium_Adult_Bar__c = true;
						subExtra.Premium_Call_Bar_Display__c = true;
					}
					//Adult and Chat Bar
					else if(networkCommandCode == Label.MO2B_BAR_ADULT_AND_CHAT && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Adult_and_Chat_Bar__c = true;
						subExtra.Premium_Call_Bar_Display__c = true;
					}
					//Adult Bar
					else if(networkCommandCode == Label.MO2B_BAR_ADULT && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Adult_Bar__c = true;
						subExtra.Premium_Call_Bar_Display__c = true;
					}
					//Chat Bar
					else if(networkCommandCode == Label.MO2B_BAR_CHAT && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Chat_Bar__c = true;
						subExtra.Premium_Call_Bar_Display__c = true;
					}
					//bars h/s for calls from o/s UK
					else if(networkCommandCode == Label.MO2B_BAR_H_S_FOR_CALLS_FROM_O_S_UK && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.Bars_h_s_for_calls_from_o_s_UK__c = true;
						subExtra.Roaming_Call_Bar_Display__c = true;
					}  
					//O2 Only roam Bar
					else if(networkCommandCode == Label.MO2B_BAR_O2_ONLY_ROAM && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.O2_only_roam_bar__c = true;
						subExtra.Roaming_Call_Bar_Display__c = true;
					}
					//GPRS Bar
					else if(networkCommandCode == Label.MO2B_BAR_GPRS && unBarredDate == CaseUtils.BAR_CHANGE_DEFAULT_UNBARRED_DATE)
					{
						subExtra.GPRS_Bar__c = true;
						subExtra.GPRS__c = true;
					}
				}

			}

			Dom.XMLNode basicDetailsElement1 = responseElement.getChildElement('serviceDetails', MAN_NS);
			Dom.XMLNode basicDetailsElementNext;
			if(basicDetailsElement1 != null){
				basicDetailsElementNext = basicDetailsElement1.getChildElement('service', MAN_NS);
			}



			system.debug('subExtra'+subExtra);
			if (basicDetailsElementNext != null){
				String contractualBoltOns ;
				String otherBoltOns ;
				String serviceCodeList;
				String packageCodeList;
				String effectiveDateFromDiseOrg = null;
				String expiryDateFromDiseOrg = null;

				for(Dom.XMLNode elemServices : basicDetailsElement1.getChildElements()){
					System.debug('**elem**'+elemServices);
					String ServiceCodeFromDise = CaseUtils.getElemText(elemServices, 'serviceCode', MAN_NS); 
					String packageCodeFromDise = CaseUtils.getElemText(elemServices, 'packageCode', MAN_NS);
					String descriptionFromDise = CaseUtils.getElemText(elemServices, 'description', MAN_NS); 
					String servicePriceFromDise = CaseUtils.getElemText(elemServices, 'servicePrice', MAN_NS);
					String effectiveDateFromDise = CaseUtils.getElemText(elemServices, 'effectiveDate', MAN_NS);
					String expiryDateFromDise = CaseUtils.getElemText(elemServices, 'expiryDate', MAN_NS);
					effectiveDateFromDiseOrg = effectiveDateFromDise;
					expiryDateFromDiseOrg = expiryDateFromDise;
					
					System.debug('**ServiceCodeFromDise**'+ServiceCodeFromDise);
					System.debug('**packageCodeFromDise**'+packageCodeFromDise); 
					System.debug('**effectiveDateFromDise**'+effectiveDateFromDise); 
					System.debug('**expiryDateFromDise**'+expiryDateFromDise); 
					System.debug('**descriptionFromDise**'+descriptionFromDise); 
					System.debug('**servicePriceFromDise**'+servicePriceFromDise);  
					system.debug('**expiryFromDise**'+expiryDateFromDise);

					if(ServiceCodeFromDise != null && ServiceCodeFromDise != ''){
						String serviceCodeWithDescription = '[' + ServiceCodeFromDise +',' + descriptionFromDise + ']' + ',';
						if(serviceCodeList != null){
							serviceCodeList = serviceCodeList + serviceCodeWithDescription ;
						}else{
							serviceCodeList = serviceCodeWithDescription ;
						}
					}

					if(packageCodeFromDise != null && packageCodeFromDise != ''){
						if(packageCodeList != null){
							packageCodeList = packageCodeList + ',' + packageCodeFromDise ;
						}else{
							packageCodeList = packageCodeFromDise ;
						}
					}
					Date todayDate = Date.today();
					String yearStr = String.valueOf(todayDate.year());
					String monthStr = String.valueOf(todayDate.month());
					String dayStr = String.valueOf(todayDate.day());
					if (monthStr.length() == 1) {
						monthStr = '0' + monthStr;
					}
					if (dayStr.length() == 1) {
						dayStr = '0' + dayStr;
					}
					String todayStr = yearStr + '-' + monthStr + '-' + dayStr;
					if ((effectiveDateFromDise == null) || (effectiveDateFromDise == '')) {
						effectiveDateFromDise='1000-01-01';
					}
					if ((expiryDateFromDise == null) || (expiryDateFromDise == '')) {
						expiryDateFromDise='3000-01-01';
					}
					System.debug('case callout process result xml, today - ' + todayStr);
					System.debug('case callout process result xml, effective date - ' + effectiveDateFromDise);
					System.debug('case callout process result xml, expiry date - ' + expiryDateFromDise);
					if(ServiceCodeFromDise !=null && packageCodeFromDise != null && packageCodeFromDise != ''){

						servicePriceFromDise = FormatPrice(servicePriceFromDise);

						system.debug('price is :' + servicePriceFromDise);

						String DescriptionWithPrice =  '[' + ServiceCodeFromDise + ',' + descriptionFromDise +',' + servicePriceFromDise + ']' + ',';
						System.debug('**DescriptionWithPriceContractual**'+DescriptionWithPrice);
						if(((effectiveDateFromDise <= todayStr) && (expiryDateFromDise >= todayStr)) ||(expiryDateFromDise == '3000-01-01' &&  (effectiveDateFromDise <= todayStr)) ){
							System.debug('case callout process result xml, adding to contractual');
							if(contractualBoltOns != null){
								contractualBoltOns = contractualBoltOns + DescriptionWithPrice;
							}else {
								contractualBoltOns = DescriptionWithPrice;
							}
						}

					}else if(ServiceCodeFromDise !=null && (packageCodeFromDise == null || packageCodeFromDise == '')){
						system.debug('Inside Other BoltOns');

						servicePriceFromDise = FormatPrice(servicePriceFromDise);

						system.debug('price1 is :' + servicePriceFromDise);
						String DescriptionWithPrice = '[' + ServiceCodeFromDise + ',' + descriptionFromDise + ',' + servicePriceFromDise + ',' + effectiveDateFromDise + ']' + ',';
						System.debug('**DescriptionWithPriceOther**'+DescriptionWithPrice);
						if((effectiveDateFromDise <= todayStr) && (expiryDateFromDise >= todayStr)){
							System.debug('case callout process result xml, adding to other');
							if(otherBoltOns != null){
								otherBoltOns = otherBoltOns + DescriptionWithPrice;
							}else {
								otherBoltOns = DescriptionWithPrice;
							}
						}
					}
				}
				if(contractualBoltOns != null){
					Integer lengthOfString = contractualBoltOns.length();
					contractualBoltOns = contractualBoltOns.substring(0,(lengthOfString - 1));
					subExtra.Contractual_Bolt_Ons__c = contractualBoltOns;
				}
				if(otherBoltOns != null){
					Integer lengthOfString = otherBoltOns.length();
					otherBoltOns = otherBoltOns.substring(0,(lengthOfString - 1));
					subExtra.Other_Bolt_Ons__c = otherBoltOns;
				}
				if(serviceCodeList != null){
					Integer lengthOfString = serviceCodeList.length();
					serviceCodeList = serviceCodeList.substring(0,(lengthOfString - 1));
					subExtra.Service_Code__c = serviceCodeList;
				}
				if(packageCodeList != null){
					subExtra.Package_Code__c = packageCodeList;
				}
				if ((effectiveDateFromDiseOrg != null) && (effectiveDateFromDiseOrg != '')){
					Date effectiveDateDF = Date.valueOf(effectiveDateFromDiseOrg); 
					subExtra.Effective_Date__c = effectiveDateDF;
				}
				if ((expiryDateFromDiseOrg != null) && (expiryDateFromDiseOrg != '')){
					Date expiryDateDF = Date.valueOf(expiryDateFromDiseOrg);
					subExtra.Expiry_Date__c = expiryDateDF;
				}
				system.debug('**contractualBoltOns**'+subExtra.Contractual_Bolt_Ons__c);
				system.debug('**otherBoltOns**'+subExtra.Other_Bolt_Ons__c);
				subExtra.BoltOns_Flag__c = false;                
				System.debug('**subExtra for Update**'+subExtra);                

			}







		}

		return subExtra;
	}

}