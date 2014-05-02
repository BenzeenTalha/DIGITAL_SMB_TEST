/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
global class O2RetailUpgradeServicesMock implements WebServiceMock
{
	//--------------------------------------------------------------------------
	// Exception that is thrown on error
	//--------------------------------------------------------------------------
	public class ServiceMockException extends Exception {}
	//--------------------------------------------------------------------------
	// Test function for mocking WebService
	// Input values are similiar as in WebService.invoke function
	//--------------------------------------------------------------------------
   	global void doInvoke
   	(
		Object stub,
		Object request,
		Map<String, Object> response,
		String endpoint,
		String soapAction,
		String requestName,
		String responseNS,
		String responseName,
		String responseType
    )
	{
		System.debug('O2RetailUpgradeServicesMock.doInvoke() BEGIN');
		System.debug('stub: ' + stub);
		System.debug('request: ' + request);
		System.debug('response: ' + response);
		System.debug('endpoint: ' + endpoint);
		System.debug('soapAction: ' + soapAction);
		System.debug('requestName: ' + requestName);
		System.debug('responseNS: ' + responseNS);
		System.debug('responseName: ' + responseName);
		System.debug('responseType: ' + responseType);
		if (requestName != null
		    && response != null)
		{
			if (requestName == 'getSubscriptionDetails_1')
			{
				response.put('response_x', getSubscriptionDetails(request));
			}
			else if (requestName == 'getUpgradeDetails_1')
			{
				response.put('response_x', getUpgradeDetails_1(request));
			}
			else if (requestName == 'getAccountDetails')
			{
				response.put('response_x', getAccountDetails(request));
			}
			else if (requestName == 'getEarlyUpgradeFee_1')
			{
				response.put('response_x', getEarlyUpgradeFee_1(request));
			}
			else if (requestName == 'getCustomerTransactions')
			{
				response.put('response_x', getCustomerTransactions(request));
			}
			else if (requestName == 'getUpgradeHistoryDetails_1')
			{
				response.put('response_x', getUpgradeHistoryDetails_1(request));
			}
			else if (requestName == 'getAccountBalance')
			{
				response.put('response_x', getAccountBalance(request));
			}
			else if (requestName == 'addUpgradeDetails_1')
			{
				response.put('response_x', addUpgradeDetails(request));
			}
			else if (requestName == 'updateContractDetails')
			{
				response.put('response_x', updateContractDetails(request));
			}
			else if (requestName == 'addBolton_1')
			{
				response.put('response_x', addBolton(request));
			}
			else if (requestName == 'addBusinessCustomerContactEvent')
			{
				response.put('response_x', addBusinessCustomerContactEvent(request));
			}
		}
    	System.debug('O2RetailUpgradeServicesMock.doInvoke() END');
	}

	//--------------------------------------------------------------------------
	// Creates response for
	// ManageBusinessSubcription->getSubscriptionDetails_1 service
	//--------------------------------------------------------------------------
	private static Object getSubscriptionDetails(Object request)
	{
		SOAManageBusinessSubscriptionsData.getSubscriptionDetailsResponseType subscriptionDetails =
			new SOAManageBusinessSubscriptionsData.getSubscriptionDetailsResponseType();
		//
		// BASIC details
		//
		/*
		<man:basicDetails>
			<man:subscriptionNumber>9854628</man:subscriptionNumber>
			<man:agreementNumber>3769793</man:agreementNumber>
			<man:accountNumber>4858032</man:accountNumber>
			<man:companyNumber>001</man:companyNumber>
			<man:salesAccountCode>56021</man:salesAccountCode>
			<man:salesAccountCategory>Direct</man:salesAccountCategory>
			<man:subscriptionStatus>Normal</man:subscriptionStatus>
			<man:tariffCode>Q10ADX</man:tariffCode>
			<man:tariffDescription>Mobile Broadband 1GB</man:tariffDescription>
			<man:tariffType>HARDWARE</man:tariffType>
			<man:networkCode>CDIG</man:networkCode>
			<man:connectedDate>2010-11-01</man:connectedDate>
			<man:connectionReason>NB</man:connectionReason>
			<man:monthlyLineRentalFee>638</man:monthlyLineRentalFee>
			<man:lastAmendedDate>2012-10-25T16:12:10.000Z</man:lastAmendedDate>
		</man:basicDetails>
		*/
		subscriptionDetails.basicDetails =
			new SOAManageBusinessSubscriptionsData.subscriptionBasicType();
		subscriptionDetails.basicDetails.subscriptionNumber = '9854628';
		subscriptionDetails.basicDetails.agreementNumber = '3769793';
		subscriptionDetails.basicDetails.accountNumber = '4858032';
		subscriptionDetails.basicDetails.companyNumber = '001';
		subscriptionDetails.basicDetails.salesAccountCode = '56021';
		subscriptionDetails.basicDetails.salesAccountCategory = 'Direct';
		subscriptionDetails.basicDetails.subscriptionStatus = 'Normal';
		subscriptionDetails.basicDetails.tariffCode = 'Q10ADX';
		subscriptionDetails.basicDetails.tariffDescription = 'Mobile Broadband 1GB';
		subscriptionDetails.basicDetails.tariffType = 'HARDWARE';
		subscriptionDetails.basicDetails.networkCode = 'CDIG';
		subscriptionDetails.basicDetails.connectedDate = Date.newInstance(2010, 11, 1);
		subscriptionDetails.basicDetails.connectionReason = 'NB';
		subscriptionDetails.basicDetails.monthlyLineRentalFee = 638;
		subscriptionDetails.basicDetails.lastAmendedDate = Datetime.newInstance(2012, 10, 25, 16, 12, 10);
		//
		// ADDRESS details
		//
		/*
		<man:addressDetails>
			<man:businessAddress>
				<man:companyName>Testing Account - Chowdary</man:companyName>
				<man:address1>1 Test Street</man:address1>
				<man:address2>Preston Brook</man:address2>
				<man:address3>Runcorn</man:address3>
				<man:address4>Cheshire</man:address4>
				<man:address5>England</man:address5>
				<man:postcode>NE3 2EF</man:postcode>
				<man:companyTelephoneNumber>441928123123</man:companyTelephoneNumber>
				<man:contactTelephoneNumber>441928123124</man:contactTelephoneNumber>
				<man:dateOfIncorporation>1980-01-01</man:dateOfIncorporation>
			</man:businessAddress>
			<man:lastAmendedDate>2012-10-17T10:27:15.000Z</man:lastAmendedDate>
		</man:addressDetails>
		*/
		subscriptionDetails.addressDetails =
			new SOAManageBusinessSubscriptionsData.addressQueryType();
		subscriptionDetails.addressDetails.businessAddress =
			new SOAManageBusinessSubscriptionsData.businessAddressQueryType();
		subscriptionDetails.addressDetails.businessAddress.companyName = 'Testing Account - Chowdary';
		subscriptionDetails.addressDetails.businessAddress.address1 = '1 Test Street';
		subscriptionDetails.addressDetails.businessAddress.address2 = 'Preston Brook';
		subscriptionDetails.addressDetails.businessAddress.address3 = 'Runcorn';
		subscriptionDetails.addressDetails.businessAddress.address4 = 'Cheshire';
		subscriptionDetails.addressDetails.businessAddress.address5 = 'England';
		subscriptionDetails.addressDetails.businessAddress.postcode = 'NE3 2EF';
		subscriptionDetails.addressDetails.businessAddress.companyTelephoneNumber = '441928123123';
		subscriptionDetails.addressDetails.businessAddress.contactTelephoneNumber = '441928123124';
		subscriptionDetails.addressDetails.businessAddress.dateOfIncorporation = Date.newInstance(1980, 1, 1);
		subscriptionDetails.addressDetails.lastAmendedDate = Datetime.newInstance(2012, 10, 17, 20, 27, 15);

		subscriptionDetails.addressDetails.personalAddress =
			new SOAManageBusinessSubscriptionsData.personalAddressQueryType();
		//
		// TODO: CONTRACT AND SALES details
		//
		/*
		<man:contractAndSalesDetails>
			<man:contractNumber>BU-47207764</man:contractNumber>
			<man:firstInvoiceDate>2010-11-04</man:firstInvoiceDate>
			<man:lastInvoiceDate>2012-10-01</man:lastInvoiceDate>
			<man:nextInvoiceDate>2012-11-01</man:nextInvoiceDate>
			<man:contractStartDate>2012-10-25</man:contractStartDate>
			<man:termOfContract>24</man:termOfContract>
			<man:termsAndConditionsCode>STD</man:termsAndConditionsCode>
			<man:terminationInvoiceProduced>false</man:terminationInvoiceProduced>
			<man:lastAmendedDate>2012-10-25T16:12:10.000Z</man:lastAmendedDate>
		</man:contractAndSalesDetails>
		*/
		subscriptionDetails.contractAndSalesDetails =
			new SOAManageBusinessSubscriptionsData.contractAndSalesType();
		subscriptionDetails.contractAndSalesDetails.contractNumber = 'BU-47207764';
		subscriptionDetails.contractAndSalesDetails.firstInvoiceDate = Date.newInstance(2010, 11, 4);
		subscriptionDetails.contractAndSalesDetails.lastInvoiceDate = Date.newInstance(2012, 10, 1);
		subscriptionDetails.contractAndSalesDetails.nextInvoiceDate = Date.newInstance(2012, 11, 1);
		subscriptionDetails.contractAndSalesDetails.contractStartDate = Date.newInstance(2011, 01, 01);
		subscriptionDetails.contractAndSalesDetails.termOfContract = 12;
		subscriptionDetails.contractAndSalesDetails.termsAndConditionsCode = 'STD';
		subscriptionDetails.contractAndSalesDetails.terminationInvoiceProduced = false;
		subscriptionDetails.contractAndSalesDetails.lastAmendedDate = Datetime.newInstance(2012, 10, 25, 16, 12, 10);
		//
		// SERVICES details
		//
		/*
		<man:serviceDetails>
		</man:serviceDetails>
		*/
		subscriptionDetails.serviceDetails =
			new SOAManageBusinessSubscriptionsData.serviceDetailsType();
		subscriptionDetails.serviceDetails.service =
			new List<SOAManageBusinessSubscriptionsData.serviceDetailType>();
		/*
		<man:service>
			<man:serviceCode>BBWIFI</man:serviceCode>
			<man:packageCode>Q2SDAT</man:packageCode>
			<man:servicePrice>0</man:servicePrice>
			<man:description>Unlimited Wi-Fi</man:description>
			<man:effectiveDate>2010-11-01</man:effectiveDate>
			<man:lastAmendedDate>2012-10-01T00:29:50.000Z</man:lastAmendedDate>
		</man:service>
		*/
		SOAManageBusinessSubscriptionsData.serviceDetailType service =
			new SOAManageBusinessSubscriptionsData.serviceDetailType();
		service.serviceCode = 'BBWIFI';
		service.packageCode = 'Q2SDAT';
		service.servicePrice = 0;
		service.description = 'Unlimited Wi-Fi';
		service.effectiveDate = Date.newInstance(2010, 11, 1);
		service.lastAmendedDate = Datetime.newInstance(2012, 10, 1, 0, 29, 50);
		subscriptionDetails.serviceDetails.service.add(service);
		/*
		<man:service>
			<man:serviceCode>FOCIB</man:serviceCode>
			<man:packageCode>Q2SDAT</man:packageCode>
			<man:servicePrice>0</man:servicePrice>
			<man:description>Free Itemised Billing</man:description>
			<man:effectiveDate>2010-11-01</man:effectiveDate>
			<man:lastAmendedDate>2012-10-01T00:29:50.000Z</man:lastAmendedDate>
		</man:service>
		*/
		service = new SOAManageBusinessSubscriptionsData.serviceDetailType();
		service.serviceCode = 'FOCIB';
		service.packageCode = 'Q2SDAT';
		service.servicePrice = 0;
		service.description = 'Free Itemised Billing';
		service.effectiveDate = Date.newInstance(2010, 11, 1);
		service.lastAmendedDate = Datetime.newInstance(2012, 10, 1, 0, 29, 50);
		subscriptionDetails.serviceDetails.service.add(service);
		/*
		<man:service>
			<man:serviceCode>FTUPIS</man:serviceCode>
			<man:servicePrice>0</man:servicePrice>
			<man:description>Fast Track Fee Paid In Store</man:description>
			<man:effectiveDate>2012-10-25</man:effectiveDate>
			<man:lastAmendedDate>2012-10-25T16:12:14.000Z</man:lastAmendedDate>
		</man:service>
		*/
		service = new SOAManageBusinessSubscriptionsData.serviceDetailType();
		service.serviceCode = 'FTUPIS';
		service.servicePrice = 0;
		service.description = 'Fast Track Fee Paid In Store';
		service.effectiveDate = Date.newInstance(2010, 10, 25);
		service.lastAmendedDate = Datetime.newInstance(2012, 10, 25, 16, 12, 14);
		subscriptionDetails.serviceDetails.service.add(service);
		/*
		<man:service>
			<man:serviceCode>FTURET</man:serviceCode>
			<man:servicePrice>0</man:servicePrice>
			<man:description>O2 Retail Fast Track Fee</man:description>
			<man:effectiveDate>2012-10-25</man:effectiveDate>
			<man:lastAmendedDate>2012-10-25T16:12:13.000Z</man:lastAmendedDate>
		</man:service>
		*/
		service = new SOAManageBusinessSubscriptionsData.serviceDetailType();
		service.serviceCode = 'FOCIB';
		service.servicePrice = 0;
		service.description = 'O2 Retail Fast Track Fee';
		service.effectiveDate = Date.newInstance(2012, 10, 25);
		service.lastAmendedDate = Datetime.newInstance(2012, 10, 25, 16, 12, 13);
		subscriptionDetails.serviceDetails.service.add(service);
		/*
		<man:service>
			<man:serviceCode>GPRS</man:serviceCode>
			<man:packageCode>Q2SDAT</man:packageCode>
			<man:servicePrice>638</man:servicePrice>
			<man:description>O2 Mobile Broadband 1GB</man:description>
			<man:effectiveDate>2010-11-01</man:effectiveDate>
			<man:lastAmendedDate>2012-10-01T00:29:50.000Z</man:lastAmendedDate>
		</man:service>
		*/
		service = new SOAManageBusinessSubscriptionsData.serviceDetailType();
		service.serviceCode = 'GPRS';
		service.packageCode = 'Q2SDAT';
		service.servicePrice = 638;
		service.description = 'O2 Mobile Broadband 1GB';
		service.effectiveDate = Date.newInstance(2010, 11, 1);
		service.lastAmendedDate = Datetime.newInstance(2012, 10, 1, 0, 29, 50);
		subscriptionDetails.serviceDetails.service.add(service);
		/*
		<man:service>
			<man:serviceCode>MMSB</man:serviceCode>
			<man:servicePrice>0</man:servicePrice>
			<man:description>Multimedia Messaging Service</man:description>
			<man:effectiveDate>2010-11-01</man:effectiveDate>
			<man:lastAmendedDate>2012-10-01T00:29:50.000Z</man:lastAmendedDate>
		</man:service>
		*/
		service = new SOAManageBusinessSubscriptionsData.serviceDetailType();
		service.serviceCode = 'MMSB';
		service.servicePrice = 0;
		service.description = 'Multimedia Messaging Service';
		service.effectiveDate = Date.newInstance(2010, 11, 1);
		service.lastAmendedDate = Datetime.newInstance(2012, 10, 1, 0, 29, 50);
		subscriptionDetails.serviceDetails.service.add(service);
		return subscriptionDetails;
	}

	//--------------------------------------------------------------------------
	// Creates response for ManageBusinessUpgrades->getUpgradeDetails_1 service
	//--------------------------------------------------------------------------
	private static Object getUpgradeDetails_1(Object request)
	{
		SOAManageBusinessUpgradesData.getUpgradeDetails_1 req = (SOAManageBusinessUpgradesData.getUpgradeDetails_1)request;
		if(req.subscriptionNumber==null && req.msisdn==null) {
			throw new MockSOAPException('SOAP Error: Test');
		}

		SOAManageBusinessUpgradesData.getUpgradeDetails_1Response upgradeDetails = new SOAManageBusinessUpgradesData.getUpgradeDetails_1Response();
		List<SOAManageBusinessUpgradesData.eligibilityOptionsType> elOptList = new List<SOAManageBusinessUpgradesData.eligibilityOptionsType>();
		SOAManageBusinessUpgradesData.eligibilityOptionsType elOpt = new SOAManageBusinessUpgradesData.eligibilityOptionsType();
		//
        // Test: check if next upgrade date has passed if(nextUpgradeDate<Date.today()) {
        // Also:
		/*	if(standardUpgradeDate>Date.today()) { // standard upgrade date is NOT in the past
				if(standardUpgradeDate>nextUpgradeDate && contractStartDate<Date.newInstance(2010, 02, 15)) {
					isMidTermUpgrade=true;
				}else if(standardUpgradeDate>nextUpgradeDate && contractStartDate>=Date.newInstance(2010, 02, 15) && contractStartDate<=Date.newInstance(2011, 03, 28)) {
					isMidTermUpgrade=true;
				}
			}*/
        if(req.subscriptionNumber.contains('11111111')) {	// Not mid-term, nextUpgradeDate has passed, Eligible
        	upgradeDetails.nextUpgradeDate=Date.today().addMonths(-1);
        	upgradeDetails.midTermUpgradeCharge=5555;
        	upgradeDetails.standardUpgradeDate=Date.today().addYears(-2).addMonths(12);
        	upgradeDetails.lastUpgradeDate=Date.today().addMonths(-2);
			elOpt.isEligible='Y';
			elOptList.add(elOpt);
        	upgradeDetails.eligibilityOptions=elOptList;
        }
        if(req.subscriptionNumber.contains('11111110')) {	// Not Mid-term, nextUpgradeDate not passed, Eligible
        	upgradeDetails.nextUpgradeDate=Date.today().addMonths(1);
        	upgradeDetails.midTermUpgradeCharge=5555;
        	upgradeDetails.standardUpgradeDate=Date.today().addMonths(2);
			elOpt.isEligible='Y';
			elOptList.add(elOpt);
        	upgradeDetails.eligibilityOptions=elOptList;
        }
        if(req.subscriptionNumber.contains('11111100')) {	// Not Mid-term, eligible with FTU fee
        	upgradeDetails.nextUpgradeDate=Date.today().addMonths(1);
        	upgradeDetails.midTermUpgradeCharge=5555;
        	upgradeDetails.standardUpgradeDate=Date.today().addMonths(2);
			elOpt.isEligible='N';
			elOptList.add(elOpt);
        	upgradeDetails.eligibilityOptions=elOptList;
        }
        if(req.subscriptionNumber.contains('11111000')) {	// Not mid-term - standard upgrade date has passed, not eligible
        	upgradeDetails.nextUpgradeDate=Date.today().addMonths(1);
        	upgradeDetails.midTermUpgradeCharge=5555;
        	upgradeDetails.standardUpgradeDate=Date.today().addMonths(-2);
			elOpt.isEligible='N';
			elOptList.add(elOpt);
        	upgradeDetails.eligibilityOptions=elOptList;
        }
        if(req.subscriptionNumber.contains('11110000')) {	// Mid-term, eligible
        	upgradeDetails.nextUpgradeDate=Date.today().addMonths(1);
        	upgradeDetails.midTermUpgradeCharge=5555;
        	upgradeDetails.standardUpgradeDate=Date.today().addMonths(2);
			elOpt.isEligible='Y';
			elOptList.add(elOpt);
        	upgradeDetails.eligibilityOptions=elOptList;
        }

		return upgradeDetails;
	}

	public class MockSOAPException extends Exception {}
	//--------------------------------------------------------------------------
	// Creates response for ManageBusinessCustomerDetails->getAccountDetails service
	//--------------------------------------------------------------------------
	private static Object getAccountDetails(Object request)
	{
		SOAManageBusinessCustomerDetailsData.getAccountDetails req = (SOAManageBusinessCustomerDetailsData.getAccountDetails)request;
		if(req.accountNumber==null) {
			throw new MockSOAPException('SOAP Error: Test');
		}
        SOAManageBusinessCustomerDetailsData.getAccountDetailsResponse accountDetails = new SOAManageBusinessCustomerDetailsData.getAccountDetailsResponse();
		accountDetails.accountBasic=new SOAManageBusinessCustomerDetailsData.accountBasicType();
        accountDetails.discounts=new SOAManageBusinessCustomerDetailsData.discountDetailsType();
        accountDetails.paymentDetails=new SOAManageBusinessCustomerDetailsData.accountPaymentDetailsType();
        accountDetails.paymentDetails.directDebit=new SOAManageBusinessCustomerDetailsData.directDebitType();
        accountDetails.paymentDetails.paymentCard=new SOAManageBusinessCustomerDetailsData.paymentCardType();

        accountDetails.addressDetails=new SOAManageBusinessCustomerDetailsData.accountAddressType();
        accountDetails.autoPayments=new SOAManageBusinessCustomerDetailsData.autoPaymentsType();
        accountDetails.creditControl=new SOAManageBusinessCustomerDetailsData.creditControlType();
        accountDetails.accountTypeAndUsage=new SOAManageBusinessCustomerDetailsData.accountTypeAndUsageType();
        accountDetails.customerDetails=new SOAManageBusinessCustomerDetailsData.accountCustomerDetailsType();
        accountDetails.subscriptionInvoiceControl=new SOAManageBusinessCustomerDetailsData.subscriptionInvoiceControlType();
        accountDetails.nonSubscriptionInvoiceControl=new SOAManageBusinessCustomerDetailsData.nonSubscriptionInvoiceControlType();

        // Alow request to determine response
        if(!req.accountNumber.contains('noBkAN')) accountDetails.paymentDetails.directDebit.bankAccountNumber='0123456789';
        if(!req.accountNumber.contains('noBkSC')) accountDetails.paymentDetails.directDebit.bankSortCode='012345';
        if(!req.accountNumber.contains('noPW')) accountDetails.customerDetails.accountPassword='AAAAAA'; // easy test of random character selection
        if(!req.accountNumber.contains('noPin')) accountDetails.customerDetails.accountPIN=9999;

		return accountDetails;
	}

	//--------------------------------------------------------------------------
	// Creates response for ManageBusinessUpgrades->getEarlyUpgradeFee_1 service
	//--------------------------------------------------------------------------
	private static Object getEarlyUpgradeFee_1(Object request)
	{
		SOAManageBusinessUpgradesData.getEarlyUpgradeFee_1 req = (SOAManageBusinessUpgradesData.getEarlyUpgradeFee_1)request;
		if(req.lineRentalFee==null || req.remainingMonths==null) {
			throw new MockSOAPException('SOAP Error: Test');
		}
		SOAManageBusinessUpgradesData.getEarlyUpgradeFee_1Response fee =  new SOAManageBusinessUpgradesData.getEarlyUpgradeFee_1Response();
		fee.earlyUpgradeFee='1111';

		return fee;
	}

	//--------------------------------------------------------------------------
	// Creates response for ViewBusinessCustomerTransactions->getCustomerTransactions service
	//--------------------------------------------------------------------------
	private static Object getCustomerTransactions(Object request)
	{
//		SOAViewBusinessCustomerTransData.getCustomerTransactions req2 = new SOAViewBusinessCustomerTransData.getCustomerTransactions();

		SOAViewBusinessCustomerTransData.getCustomerTransactions req = (SOAViewBusinessCustomerTransData.getCustomerTransactions)request;
		if(req.accountNumber==null) {
			throw new MockSOAPException('SOAP Error: Test');
		}
		SOAViewBusinessCustomerTransData.getCustomerTransactionsResponse response_x=new SOAViewBusinessCustomerTransData.getCustomerTransactionsResponse();
		SOAViewBusinessCustomerTransData.transactionDetailsType[] custTransResponse = new SOAViewBusinessCustomerTransData.transactionDetailsType[]{};
		SOAViewBusinessCustomerTransData.transactionDetailsType tdt = new SOAViewBusinessCustomerTransData.transactionDetailsType();
		// set :
		//		lastInvoiceDate=custTransResponse[0].transactionDate;
		//		lastInvoiceAmount=custTransResponse[0].transactionAmount;
		//		lastInvoiceNumber=custTransResponse[0].transactionReference;
		tdt.transactionCategory=req.transactionType;
		tdt.paymentDueOrReceivedDate = Date.today().addDays(-10);
		tdt.transactionDate = Date.today().addDays(-12);
		tdt.transactionAmount = 5555;
		tdt.transactionReference = '3333';
		custTransResponse.add(tdt);
		response_x.transaction_x=custTransResponse;
		return response_x;
	}

	//--------------------------------------------------------------------------
	// Creates response for ManageBusinessUpgrades->getUpgradeHistoryDetails_1 service
	//--------------------------------------------------------------------------
	private static Object getUpgradeHistoryDetails_1(Object request)
	{
		SOAManageBusinessUpgradesData.getUpgradeHistoryDetails_1 req = (SOAManageBusinessUpgradesData.getUpgradeHistoryDetails_1)request;

		if(req.subscriptionNumber==null) {
			throw new MockSOAPException('SOAP Error: Test');
		}

		SOAManageBusinessUpgradesData.getUpgradeHistoryDetails_1Response upgradeDetails = new SOAManageBusinessUpgradesData.getUpgradeHistoryDetails_1Response();
		//
        // Test: previousContractStartDate.addMonths(previousContractTerm) <= Date.today()
        if(req.subscriptionNumber.contains('11111111')) {
        	upgradeDetails.previousContractTerm='12';
        	upgradeDetails.previousContractStartDate=Date.today().addMonths(-13);
        }
        // Test: previousContractStartDate.addMonths(previousContractTerm) > Date.today()
        if(req.subscriptionNumber.contains('11111110')) {
        	upgradeDetails.previousContractTerm='24';
        	upgradeDetails.previousContractStartDate=Date.today().addMonths(-1);
        }
		return upgradeDetails;
	}

	//--------------------------------------------------------------------------
	// Creates response for
	// ManagedBusinessCustomerDetails->getAccountManagedDetails_1 service
	//--------------------------------------------------------------------------
	private static Object getAccountManagedDetails(Object request)
	{
		SOAManageBusinessCustomerDetailsData.getAccountManagedDetails_1Response returnValue =
			new SOAManageBusinessCustomerDetailsData.getAccountManagedDetails_1Response();
		returnValue.isAccountManaged = false;
		return returnValue;
	}

	//--------------------------------------------------------------------------
	// Creates response for ViewBusinessAccountBalance->getAccountBalance service
	//--------------------------------------------------------------------------
	private static Object getAccountBalance(Object request)
	{
		SOAViewBusinessAccountBalanceData.getAccountBalance req = (SOAViewBusinessAccountBalanceData.getAccountBalance)request;
		if(req.accountNumber==null) {
			throw new MockSOAPException('SOAP Error: Test');
		}
		SOAViewBusinessAccountBalanceData.getAccountBalanceResponse response = new SOAViewBusinessAccountBalanceData.getAccountBalanceResponse();
		if(req.accountNumber.contains('555'))
			response.amountOverdue=2000;
		else
			response.amountOverdue=0;

		return response;
	}

	//--------------------------------------------------------------------------
	// Creates response for ManagedBusinessUpgrades->appUpgradeDetails_1 service
	//--------------------------------------------------------------------------
	private static Object addUpgradeDetails(Object request)
	{
		SOAManageBusinessUpgradesData.addUpgradeDetails_1Response response =
			new SOAManageBusinessUpgradesData.addUpgradeDetails_1Response();
		response.URNPrefix = 'XB';
		response.URN = '47207764';
		return response;
	}

	//--------------------------------------------------------------------------
	// Creates response for
	// ManageBusinessCustomerDetails->updateContractDetails service
	//--------------------------------------------------------------------------
	private static Object updateContractDetails(Object request)
	{
		/*
		<man:status>
			<cor:statusCode xmlns:cor="http://soa.o2.co.uk/coredata_1">managebusinesscustomerdetails-36510-0000-S</cor:statusCode>
			<cor:externalDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">The contract was updated successfully.</cor:externalDescription>
		</man:status>
		*/
		SOAManageBusinessCustomerDetailsData.updateContractDetailsResponse returnValue =
			new SOAManageBusinessCustomerDetailsData.updateContractDetailsResponse();
		SOACoreData2.ServiceResultType serviceResult =
			new SOACoreData2.ServiceResultType();
		serviceResult.statusCode = 'managebusinesscustomerdetails-36510-0000-S';
		serviceResult.externalDescription = 'The contract was updated successfully.';
		returnValue.status = serviceResult;
		return returnValue;
	}

	//--------------------------------------------------------------------------
	// Creates response for ManageBusinessBoltons->addBolton_1 service
	//--------------------------------------------------------------------------
	private static Object addBolton(Object request)
	{
		/*
 		<man:result>
	 		<cor:statusCode xmlns:cor="http://soa.o2.co.uk/coredata_1">managebusinessboltons-11510-0000-S</cor:statusCode>
	 		<cor:externalDescription xmlns:cor="http://soa.o2.co.uk/coredata_1">The service has been added successfully.</cor:externalDescription>
 		</man:result>
 		*/
 		SOAManageBusinessBoltonsData2.addBolton_1Response returnValue =
 			new SOAManageBusinessBoltonsData2.addBolton_1Response();
		SOACoreData2.ServiceResultType serviceResult =
			new SOACoreData2.ServiceResultType();
		serviceResult.statusCode = 'managebusinessboltons-11510-0000-S';
		serviceResult.externalDescription = 'The service has been added successfully.';
		returnValue.result = serviceResult;
 		return returnValue;
	}

	//--------------------------------------------------------------------------
	// Creates response for
	// ManageCustomerContact->addBusinessCustomerContactEvent service
	//--------------------------------------------------------------------------
	private static Object addBusinessCustomerContactEvent(Object request)
	{
		//
		// Throws exception because service is not implemented correctly
		//
		throw new ServiceMockException();
		return null;
	}
}