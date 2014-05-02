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
@isTest
global class TestO365Helper
{
	public class MockSOAPException extends Exception {}

	//--------------------------------------------------------------------------
	// Class for mock service
	//--------------------------------------------------------------------------
	global class ServiceMock implements WebServiceMock
	{
		global void doInvoke(
				Object stub,
				Object request,
				Map<String, Object> response,
				String endpoint,
				String soapAction,
				String requestName,
				String responseNS,
				String responseName,
				String responseType)
		{
			if (requestName != null
				&& response != null)
			{
				if (requestName == 'getSubscriptionDetails_1')
				{
					response.put('response_x', getSubscriptionDetails_1(request));
				}
				else if (requestName == 'getAccountDetails')
				{
					response.put('response_x', getAccountDetails(request));
				}
				else if (requestName == 'getCustomerTransactions')
				{
					response.put('response_x', getCustomerTransactions(request));
				}
				else if (requestName == 'getAccountManagedDetails_1')
				{
					response.put('response_x', getAccountManagedDetails_1(request));
				}
			}
		}
	}

	//--------------------------------------------------------------------------
	// Mocking getSubscriptionDetails service call
	//--------------------------------------------------------------------------
	private static Object getSubscriptionDetails_1(Object request)
	{
		//
		// If request contains blank MSIDN throw exception
		//
		SOAManageBusinessSubscriptionsData.getSubscriptionDetailsType req =
			(SOAManageBusinessSubscriptionsData.getSubscriptionDetailsType)request;
		if (req != null
			&& req.subscriptionData != null
			&& req.subscriptionData.primarySerialNumber != null
			&& String.isBlank(req.subscriptionData.primarySerialNumber.parameterValue))
		{
			throw new MockSOAPException('Service error');
		}
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
		   <man:salesAccountCode>12345</man:salesAccountCode>
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
		subscriptionDetails.basicDetails.accountNumber = '12345';
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

		return subscriptionDetails;
	}

	//--------------------------------------------------------------------------
	// Mocking getAccountDetails service call
	//--------------------------------------------------------------------------
	private static Object getAccountDetails(Object request)
	{
		SOAManageBusinessCustomerDetailsData.getAccountDetails req =
			(SOAManageBusinessCustomerDetailsData.getAccountDetails)request;
		if (req.accountNumber == null)
		{
			throw new MockSOAPException('SOAP Error: Test');
		}
        SOAManageBusinessCustomerDetailsData.getAccountDetailsResponse accountDetails =
			new SOAManageBusinessCustomerDetailsData.getAccountDetailsResponse();
		accountDetails.accountBasic =
			new SOAManageBusinessCustomerDetailsData.accountBasicType();
        accountDetails.discounts =
			new SOAManageBusinessCustomerDetailsData.discountDetailsType();
        accountDetails.paymentDetails =
			new SOAManageBusinessCustomerDetailsData.accountPaymentDetailsType();
        accountDetails.paymentDetails.directDebit =
			new SOAManageBusinessCustomerDetailsData.directDebitType();
        accountDetails.paymentDetails.paymentCard =
			new SOAManageBusinessCustomerDetailsData.paymentCardType();

        accountDetails.addressDetails =
			new SOAManageBusinessCustomerDetailsData.accountAddressType();
        accountDetails.autoPayments =
			new SOAManageBusinessCustomerDetailsData.autoPaymentsType();
        accountDetails.creditControl =
			new SOAManageBusinessCustomerDetailsData.creditControlType();
        accountDetails.accountTypeAndUsage =
			new SOAManageBusinessCustomerDetailsData.accountTypeAndUsageType();
        accountDetails.customerDetails =
			new SOAManageBusinessCustomerDetailsData.accountCustomerDetailsType();
        accountDetails.subscriptionInvoiceControl =
			new SOAManageBusinessCustomerDetailsData.subscriptionInvoiceControlType();
        accountDetails.nonSubscriptionInvoiceControl =
			new SOAManageBusinessCustomerDetailsData.nonSubscriptionInvoiceControlType();

        // Alow request to determine response
        if (!req.accountNumber.contains('noBkAN'))
		{
			accountDetails.paymentDetails.directDebit.bankAccountNumber = '0123456789';
		}
        if (!req.accountNumber.contains('noBkSC'))
		{
			accountDetails.paymentDetails.directDebit.bankSortCode = '012345';
		}
        if (!req.accountNumber.contains('noPW'))
		{
			// easy test of random character selection
			accountDetails.customerDetails.accountPassword = 'AAAAAA';
		}
        if (!req.accountNumber.contains('noPin'))
		{
		   	accountDetails.customerDetails.accountPIN = 9999;
		}

		return accountDetails;
	}

	//--------------------------------------------------------------------------
	// Mocking getCustomerTransactions service call
	//--------------------------------------------------------------------------
	private static Object getCustomerTransactions(Object request)
	{
		SOAViewBusinessCustomerTransData.getCustomerTransactions req =
			(SOAViewBusinessCustomerTransData.getCustomerTransactions)request;
		if (req.accountNumber == null)
		{
			throw new MockSOAPException('SOAP Error: Test');
		}
		SOAViewBusinessCustomerTransData.getCustomerTransactionsResponse response_x =
			new SOAViewBusinessCustomerTransData.getCustomerTransactionsResponse();
		SOAViewBusinessCustomerTransData.transactionDetailsType[] custTransResponse =
			new SOAViewBusinessCustomerTransData.transactionDetailsType[]{};
		SOAViewBusinessCustomerTransData.transactionDetailsType tdt =
			new SOAViewBusinessCustomerTransData.transactionDetailsType();
		// set :
		//		lastInvoiceDate = custTransResponse[0].transactionDate;
		//		lastInvoiceAmount = custTransResponse[0].transactionAmount;
		//		lastInvoiceNumber = custTransResponse[0].transactionReference;
		tdt.transactionCategory = req.transactionType;
		tdt.paymentDueOrReceivedDate = Date.today().addDays(-10);
		tdt.transactionDate = Date.today().addDays(-12);
		tdt.transactionAmount = 5555;
		tdt.transactionReference = '3333';
		custTransResponse.add(tdt);
		response_x.transaction_x = custTransResponse;
		return response_x;
	}

	//--------------------------------------------------------------------------
	// Mocking getAccountManagedDetails service call
	//--------------------------------------------------------------------------
	private static Object getAccountManagedDetails_1(Object request)
	{
		SOAManageBusinessCustomerDetailsData.getAccountManagedDetails_1 req =
			(SOAManageBusinessCustomerDetailsData.getAccountManagedDetails_1) request;
		if (req.accountNumber == null)
		{
			throw new MockSOAPException('SOAP Error: Test');
		}
		SOAManageBusinessCustomerDetailsData.getAccountManagedDetails_1Response response_x =
			new SOAManageBusinessCustomerDetailsData.getAccountManagedDetails_1Response();
		response_x.isAccountManaged = true;
		return response_x;
	}

	//--------------------------------------------------------------------------
	// Prepare data for testing
	//--------------------------------------------------------------------------
	public static void createServiceData()
	{
		//
		// Create custom settings for service call
		//
		List<SOA_Integration_Settings__c> settings =
			new List<SOA_Integration_Settings__c>();

		settings.add(prepareSOAIntegration('ManageBusinessSubscriptions_1_0'));
		settings.add(prepareSOAIntegration('Manage_Business_Customer_Details'));
		settings.add(prepareSOAIntegration('ViewBusinessCustomerTransactions_1_0'));

		insert settings;

		//
		// Create security credentials for service call
		//
		wsSecurity__c security = new wsSecurity__c();
		security.Username__c = 'Juro';
		security.Password__c = 'Mecko';
		insert security;
	}

	//--------------------------------------------------------------------------
	// Prepares custom setting for service call
	//--------------------------------------------------------------------------
	private static SOA_Integration_Settings__c prepareSOAIntegration(String name)
	{
		SOA_Integration_Settings__c setting = new SOA_Integration_Settings__c();
		setting.Name = name;
		setting.Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/' + name;
		setting.Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk';
		setting.Timeout__c = 60000;
		setting.MAX_SOA_RETRIES__c = 1;
		return setting;
	}

	//--------------------------------------------------------------------------
	// Create test accounts
	//--------------------------------------------------------------------------
	public static void createTestAccounts()
	{
		//
		// Create account validation table
		//
		List<Account_Validation_Table__c> validations =
			new List<Account_Validation_Table__c>();

		Account_Validation_Table__c validation1 =
			new Account_Validation_Table__c();
		prepareValidation(validation1);
		validation1.Account__c = '12345';
		validation1.Full_Account__c = '012345';
		validations.add(validation1);

		Account_Validation_Table__c validation2 =
			new Account_Validation_Table__c();
		prepareValidation(validation2);
		validation2.Account__c = '54321';
		validation2.Full_Account__c = '054321';
		validations.add(validation2);

		insert validations;

		//
		// Create accounts
		//
		List<Account> accounts = new List<Account>();

		Account testAccount1 = new Account();
		testAccount1.Name = 'Test Account1';
		prepareAccount(testAccount1);
		testAccount1.DISE_Group_Code_Account_No_1__c = '12345';
		accounts.add(testAccount1);

		Account testAccount2 = new Account();
		testAccount2.Name = 'Test Account2';
		prepareAccount(testAccount2);
		testAccount2.DISE_Group_Code_Account_No_1__c = '54321';
		testAccount2.DISE_Group_Code_Account_No_2__c = '12345';
		accounts.add(testAccount2);

		Account testAccount3 = new Account();
		testAccount3.Name = 'Test Account3';
		accounts.add(testAccount3);

		Account testAccount4 = new Account();
		testAccount4.Name = 'Test Account4';
		accounts.add(testAccount4);

		Account testAccount5 = new Account();
		testAccount5.Name = 'Test Account5';
		prepareAccount(testAccount5);
		testAccount5.DISE_Group_Code_Account_No_1__c = '54321';
		testAccount5.DISE_Account_No__c = '12345';
		accounts.add(testAccount5);

		Account testAccount6 = new Account();
		testAccount6.Name = 'Test Account6';
		prepareAccount(testAccount6);
		testAccount6.DISE_Group_Code_Account_No_1__c = '54321';
		testAccount6.DISE_Group_Code_Account_No_2__c = '54321';
		testAccount6.DISE_Group_Code_Account_No_3__c = '12345';
		accounts.add(testAccount6);

		Account testAccount7 = new Account();
		testAccount7.Name = 'Test Account7';
		prepareAccount(testAccount7);
		testAccount7.DISE_Group_Code_Account_No_1__c = '54321';
		testAccount7.DISE_Group_Code_Account_No_2__c = '54321';
		testAccount7.DISE_Group_Code_Account_No_3__c = '54321';
		testAccount7.DISE_Group_Code_Account_No_4__c = '12345';
		accounts.add(testAccount7);

		insert accounts;
		//
		// Create account containers
		//
		List<AC_Container__c> containers = new List<AC_Container__c>();
		AC_Container__c container1 = new AC_Container__c();
		container1.Name = 'Test Container1';
		container1.CT_Organisation_Container__c = testAccount3.Id;
		container1.DISE_Account_No__c = '12345';
		containers.add(container1);

		AC_Container__c container2 = new AC_Container__c();
		container2.Name = 'Test Container2';
		container2.MB_Organisation_Container__c = testAccount4.Id;
		containers.add(container2);

		insert containers;

		//
		// Create account subcriptions
		//
		List<AC_Subscription__c> subscriptions = new List<AC_Subscription__c>();
		AC_Subscription__c subscription1 = new AC_Subscription__c();
		subscription1.Name = 'Test Subscription1';
		subscription1.AC_Container__c = container2.Id;
		subscription1.DISE_Account_No__c = '12345';
		subscriptions.add(subscription1);

		insert subscriptions;
	}

	//--------------------------------------------------------------------------
	// Prepares account
	//--------------------------------------------------------------------------
	private static void prepareAccount(Account account)
	{
		account.Status__c = 'Customer';
		account.Date_Effective_From__c = Date.today();
		account.Contract_Start_Date__c = Date.today();
		account.Contract_End_Date__c = Date.today().addMonths(24);
		account.Contract_Duration__c = '24';
		account.BillingStreet = 'C/O 31 Forest Avenue';
		account.BillingCity = 'Newcastle Upon Tyne';
		account.BillingPostalCode = 'NE12 9AH';
	}

	//--------------------------------------------------------------------------
	// Prepares account validation table
	//--------------------------------------------------------------------------
	private static void prepareValidation(Account_Validation_Table__c validation)
	{
		validation.AccountType__c = 275;
		validation.SAT_Code__c = 'DA_03157999';
		validation.MPN_s__c = 1;
		validation.Account_Description__c = 'Test Account1';
		validation.Post_Code__c = 'NE12 9AH';
	}
}