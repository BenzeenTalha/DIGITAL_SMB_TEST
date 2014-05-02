public virtual with sharing class O2RetailUpgradeSOAPServices implements O2RetailUpgradeServicesInterface {
	//--------------------------------------------------------------------------
	// Retrives subscription details from mobile phone number by calling
	// ManageBusinessSubscription->getSubscriptionDetails
	// Input values are:
	//   msisdn   - MSISDN in international format
	//   filter   - Filter output values. Can be one or more of	BASIC, CONTRACTANDSALES
	// Return values are:
	//   BASIC                             - Map<String, Object>
	//     subscriptionNumber              - String
	//     agreementNumber                 - String
	//     accountNumber                   - String
	//     corporateNumber                 - String
	//     groupNumber                     - String
	//     companyNumber                   - String
	//     salesAccountCode                - String
	//     salesAccountCategory            - String
	//     subscriptionStatus              - String
	//     tariffCode                      - String
	//     tariffDescription               - String
	//     tariffType                      - String
	//     networkCode                     - String
	//     connectedDate                   - Date
	//     disconnectedDate                - Date
	//     terminateOn                     - String
	//     connectionReason                - String
	//     emailAddress                    - String
	//     monthlyLineRentalFee            - Integer
	//     lastAmendedDate                 - Datetime
	//   ADDRESS                           - Map<String, Object>
	//     personalAddress                 - Map<String, Object>
	//       title                         - String
	//       forename                      - String
	//       middleName                    - String
	//       surname                       - String
	//       address1                      - String
	//       address2                      - String
	//       address3                      - String
	//       address4                      - String
	//       address5                      - String
	//       postcode                      - String
	//       dateOfBirth                   - Date
	//       gender                        - String
	//       maritalStatus                 - String
	//       dateOfResidence               - Date
	//       customerType                  - String
	//       addressType                   - String
	//       addressCategory               - String
	//       occupation                    - String
	//       idType                        - String
	//       idNumber                      - String
	//       telephoneNumber               - String
	//       eveningTelephoneNumber        - String
	//       faxNumber                     - String
	//     businessAddress                 - Map<String, Object>
	//       companyName                   - String
	//       address1                      - String
	//       address2                      - String
	//       address3                      - String
	//       address4                      - String
	//       address5                      - String
	//       postcode                      - String
	//       companyTelephoneNumber        - String
	//       faxNumber                     - String
	//       contactTelephoneNumber        - String
	//       companyType                   - String
	//       addressType                   - String
	//       addressCategory               - String
	//       industrialClassificationCode  - String
	//       companyRegistration           - String
	//       dateOfIncorporation           - Date
	//       title                         - String
	//       forename                      - String
	//       middleName                    - String
	//       surname                       - String
	//       jobTitle                      - String
	//     lastAmendedDate                 - Datetime
	//   CONTRACTANDSALES                  - Map<String, Object>
	//     contractNumber                  - String
	//     pricePlanCode                   - String
	//     firstInvoiceDate                - Date
	//     lastInvoiceDate                 - Date
	//     nextInvoiceDate                 - Date
	//     contractStartDate               - Date
	//     termOfContract                  - Integer
	//     termsAndConditionsCode          - String
	//     terminationInvoiceProduced      - Boolean
	//     lastAmendedDate                 - Datetime
	//   SERVICES                          - List<Map<String, Object>>
	//     List of 0..*                    - List of Map<String, Object>
	//       serviceCode                   - String
	//       packageCode                   - String
	//       servicePrice                  - Integer
	//       description                   - String
	//       effectiveDate                 - Date
	//       expiryDate                    - Date
	//       lastAmendedDate               - DateTime
	//   error
	//--------------------------------------------------------------------------
	public virtual Map<String, Object> getSubscriptionDetails(String msisdn, String[] filter)
	{
		System.debug('O2RetailUpgradeSOAPServices.getSubscriptionDetails(' + msisdn + ', ' + filter + ') BEGIN');
		Map<String, Object> returnValues = new Map<String, Object>();
		try
		{
			//
			// Call ManageBusinessSubscriptions->getSubscriptionDetails
			//
			SOAManageBusinessSubscriptionsService.ManageBusinessSubscriptionsPort manageBusinessSubscriptionPort =
				new SOAManageBusinessSubscriptionsService.ManageBusinessSubscriptionsPort();
			manageBusinessSubscriptionPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
			manageBusinessSubscriptionPort.timeout_x = SOAUtils.SOA_TIMEOUT;
			//
			// Set MSISDN
			//
			System.debug('setting msisdn');
			SOAPSCommonDiseData.subscriptionData subscriptionData = new SOAPSCommonDiseData.subscriptionData();
			subscriptionData.primarySerialNumber = new SOAPSCommonDiseData.primarySerialNumberType();
			subscriptionData.primarySerialNumber.parameterValue = msisdn;
			subscriptionData.primarySerialNumber.parameterType = 'Mobile';
			//
			// Set data filter
			//
			System.debug('setting data filter');
			SOAManageBusinessSubscriptionsData.subscriptionDataFiltersType subscriptionDataFilters =
				new SOAManageBusinessSubscriptionsData.subscriptionDataFiltersType();
			subscriptionDataFilters.subscriptionDataFilter = filter;
			System.debug('before getSubscriptionDetails_1');
			//
			// Call ManageBusinessSubriptions->getSubscriptionDetails_1
			//
			SOAManageBusinessSubscriptionsData.getSubscriptionDetailsResponseType getSubscriptionDetailsResponse =
				manageBusinessSubscriptionPort.getSubscriptionDetails_1(subscriptionData, subscriptionDataFilters);
			System.debug('after getSubscriptionDetails_1');
			System.debug('getSubscriptionResponseType is: ' + getSubscriptionDetailsResponse);
			//
			// Map BASIC details
			//
			mapBasicDetails(returnValues, getSubscriptionDetailsResponse.basicDetails);
			//
			// Map ADDRESS details
			//
			mapAddressDetails(returnValues, getSubscriptionDetailsResponse.addressDetails);
			//
			// Map CONTRACTANDSALES details
			//
			mapContractAndSalesDetails(returnValues, getSubscriptionDetailsResponse.contractAndSalesDetails);
			//
			// Map SERVICES details
			//
			mapServiceDetails(returnValues, getSubscriptionDetailsResponse.serviceDetails);
		}
		catch (Exception e)
		{
			processException(returnValues, 'getSubscriptionDetails', e);
		}
		System.debug('O2RetailUpgradeSOAPServicesgetSubscriptionDetails END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Retrieves upgrade details from subscription by calling
	// Subscriber->getUpgradeDetails_1
	// Return values are:
	//  'Response'
	//		SOAManageBusinessUpgradesData.getUpgradeDetails_1Response
	// or
	//	'error'
	//		Exception string
	//--------------------------------------------------------------------------
	public virtual Map<String, Object> getUpgradeDetails_1(String subscriptionNumber)
	{
		System.debug('O2RetailUpgradeSOAPServices.getUpgradeDetails_1(' + subscriptionNumber + ') BEGIN');
		Map<String, Object> returnValues = new Map<String, Object>();
		try
		{
			//
			// Call ManageBusinessUpgrades->getUpgradeDetails_1
			//
			SOAManageBusinessUpgradesService.ManageBusinessUpgradesPort mbuPort = new SOAManageBusinessUpgradesService.ManageBusinessUpgradesPort();
            mbuPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            mbuPort.timeout_x = SOAUtils.SOA_TIMEOUT;

            SOAManageBusinessUpgradesData.getUpgradeDetails_1Response upgradeDetails = mbuPort.getUpgradeDetails_1(subscriptionNumber,null,'No');
            returnValues.put('Response', upgradeDetails);
            System.debug(upgradeDetails);
		}
		catch (Exception e)
		{
			processException(returnValues, 'getUpgradeDetails_1', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.getUpgradeDetails_1 END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Retrieves early upgrade fee
	// ManageBusinessUpgrades->getEarlyUpgradeFee_1
	// Input values are lineRentalFee and remainingMonths
	// Return values are:
	//  'earlyUpgradeFee'
	//		String earlyUpgradeFee
	// or
	//	'error'
	//		Exception string
	//--------------------------------------------------------------------------
	public virtual Map<String, Object> getEarlyUpgradeFee_1(Integer lineRentalFee, Integer remainingMonths)
	{
		System.debug('O2RetailUpgradeSOAPServices.getEarlyUpgradeFee_1(' + lineRentalFee+', '+remainingMonths + ') BEGIN');
		Map<String, Object> returnValues = new Map<String, Object>();
		try
		{
			//
			// Call ManageBusinessUpgrades->getEarlyUpgradeFee_1
			//
			SOAManageBusinessUpgradesService.ManageBusinessUpgradesPort mbuPort = new SOAManageBusinessUpgradesService.ManageBusinessUpgradesPort();
            mbuPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            mbuPort.timeout_x = SOAUtils.SOA_TIMEOUT;

            String earlyUpgradeFee = mbuPort.getEarlyUpgradeFee_1(lineRentalFee, remainingMonths);
            returnValues.put('earlyUpgradeFee', earlyUpgradeFee);
            System.debug(earlyUpgradeFee);
		}
		catch (Exception e)
		{
			processException(returnValues, 'getEarlyUpgradeFee_1', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.getEarlyUpgradeFee_1 END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Retrieves account details from account by calling
	// ManageBusinessCustomerDetails->getAccountDeatils
	// Input value is accountNumber and filter list
	// Return values are:
	//  'Response'
	//		SOAManageBusinessCustomerDetailsData.getAccountDetailsResponse
	// or
	//	'error'
	//		Exception string
	//--------------------------------------------------------------------------
	public virtual Map<String, Object> getAccountDetails(String accountNumber, String[] filter)
	{
		System.debug('O2RetailUpgradeSOAPServices.getAccountDetails(' + accountNumber + ', '+filter[0]+') BEGIN');
		Map<String, Object> returnValues = new Map<String, Object>();
		try
		{
			SOAManageBusinessCustomerDetailsService.ManageBusinessCustomerDetailsPort mbuPort = new SOAManageBusinessCustomerDetailsService.ManageBusinessCustomerDetailsPort();
            mbuPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            mbuPort.timeout_x = SOAUtils.SOA_TIMEOUT;

			SOAManageBusinessCustomerDetailsData.accountDataFiltersType accountDataFilters=new SOAManageBusinessCustomerDetailsData.accountDataFiltersType();
			accountDataFilters.accountDataFilter= filter;
            SOAManageBusinessCustomerDetailsData.getAccountDetailsResponse accountDetails = mbuPort.getAccountDetails(accountNumber, accountDataFilters);
            System.debug(accountDetails);
            if(accountDetails.paymentDetails!=null) {
	            if(accountDetails.paymentDetails.directDebit!=null) {
					returnValues.put('bankAccountNumber', accountDetails.paymentDetails.directDebit.bankAccountNumber);
					returnValues.put('bankSortCode', accountDetails.paymentDetails.directDebit.bankSortCode);
				}
				if(accountDetails.paymentDetails.paymentCard!=null) {
					returnValues.put('cardNumber', accountDetails.paymentDetails.paymentCard.cardNumber);
				}
            }
			if(accountDetails.customerDetails!=null) {
            	returnValues.put('accountPassword', accountDetails.customerDetails.accountPassword);
            	returnValues.put('accountPIN', accountDetails.customerDetails.accountPIN);
			}
		}
		catch (Exception e)
		{
			processException(returnValues, 'getAccountDetails', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.getAccountDetails END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Retrieves customer transactions from account by calling
	// ViewBusinessCustomerTransactions->getCustomerTransactions
	// Input value is accountNumber transactionType transactionFilter and noOfRecordsToBeRetrieved
	// Return values are:
	//  'Response'
	//		SOAViewBusinessCustomerTransData.transactionDetailsType[]
	// or
	//	'error'
	//		Exception string
	//--------------------------------------------------------------------------
	public virtual Map<String, Object> getCustomerTransactions(String accountNumber, String transactionType, String transactionFilter, Integer noOfRecordsToBeRetrieved)
	{
		System.debug('O2RetailUpgradeSOAPServices.getCustomerTransactions(' + accountNumber + ', '+
			transactionType+ ', '+
			transactionFilter+ ', '+
			noOfRecordsToBeRetrieved+ ', '+
			') BEGIN');
		Map<String, Object> returnValues = new Map<String, Object>();
		try
		{
			SOAViewBusinessCustomerTransService.ViewBusinessCustomerTransactionsPort mbuPort = new SOAViewBusinessCustomerTransService.ViewBusinessCustomerTransactionsPort();
            mbuPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            mbuPort.timeout_x = SOAUtils.SOA_TIMEOUT;

            SOAViewBusinessCustomerTransData.transactionDetailsType[] custTransResponse =
            		mbuPort.getCustomerTransactions(accountNumber, transactionType, transactionFilter, noOfRecordsToBeRetrieved);
            System.debug(custTransResponse);
            returnValues.put('custTransResponse', custTransResponse);
		}
		catch (Exception e)
		{
			processException(returnValues, 'getCustomerTransactions', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.getCustomerTransactions END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Retrieves upgrade history details
	// ManageBusinessUpgrades->getUpgradeHistoryDetails_1
	// Input value is subscriptionNumber
	// Return values are:
	//  'previousContractStartDate' - Date
	//	'previousContractTerm' - Integer
	// or
	//	'error'
	//		Exception string
	//--------------------------------------------------------------------------
	public virtual Map<String, Object> getUpgradeHistoryDetails_1(String subscriptionNumber)
	{
		System.debug('O2RetailUpgradeSOAPServices.getUpgradeHistoryDetails_1(' + subscriptionNumber +
			') BEGIN');
		Map<String, Object> returnValues = new Map<String, Object>();
		try
		{
			SOAManageBusinessUpgradesService.ManageBusinessUpgradesPort mbuPort = new SOAManageBusinessUpgradesService.ManageBusinessUpgradesPort();
            mbuPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            mbuPort.timeout_x = SOAUtils.SOA_TIMEOUT;

            SOAManageBusinessUpgradesData.getUpgradeHistoryDetails_1Response uhdResponse =
            		mbuPort.getUpgradeHistoryDetails_1(subscriptionNumber, null);
            System.debug(uhdResponse);
            returnValues.put('previousContractStartDate', uhdResponse.previousContractStartDate);
            returnValues.put('previousContractTerm', uhdResponse.previousContractTerm);
		}
		catch (Exception e)
		{
			processException(returnValues, 'getUpgradeHistoryDetails_1', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.getUpgradeHistoryDetails_1 END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Retrieves if account is managed or not by calling
	// ManageBusinessCustomerDetails->getAccountManagedDetails_1
	// Input value is account number
	// Output values are:
	//   isAccountManaged   - true if account is managed false otherwise
	//   error              - On error this value exists
	//--------------------------------------------------------------------------
	public virtual Map<String, Object> getAccountManagedDetails(String accountNumber)
	{
		System.debug('O2RetailUpgradeSOAPServices.getAccountManagedDetails(' + accountNumber + ') BEGIN');
		Map<String, Object> returnValues = new Map<String, Object>();
		try
		{
			SOAManageBusinessCustomerDetailsService.ManageBusinessCustomerDetailsPort mbuPort =
				new SOAManageBusinessCustomerDetailsService.ManageBusinessCustomerDetailsPort();
            mbuPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            mbuPort.timeout_x = SOAUtils.SOA_TIMEOUT;

			Boolean isAccountManaged = mbuPort.getAccountManagedDetails_1(accountNumber);
			mapObject(returnValues, 'isAccountManaged', isAccountManaged);
		}
		catch (Exception e)
		{
			processException(returnValues, 'getAccountManagedDetails', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.getAccountManagedDetails END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Retrieves account balance
	// ViewBusinessAccountBalance->getAccountBalance
	// Input value is account number
	// Output values are:
	//   amountOverdue   - reater than zero than account is in arrears
	//   error              - On error this value exists
	//--------------------------------------------------------------------------
	public virtual Map<String, Object> getAccountBalance(String accountNumber)
	{
		System.debug('O2RetailUpgradeSOAPServices.getAccountBalance(' + accountNumber + ') BEGIN');
		Map<String, Object> returnValues = new Map<String, Object>();
		try
		{
			SOAViewBusinessAccountBalanceService.ViewBusinessAccountBalancePort mbuPort = new SOAViewBusinessAccountBalanceService.ViewBusinessAccountBalancePort();
            mbuPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            mbuPort.timeout_x = SOAUtils.SOA_TIMEOUT;

            SOAViewBusinessAccountBalanceData.getAccountBalanceResponse uhdResponse =
            		mbuPort.getAccountBalance(accountNumber);
            System.debug(uhdResponse);
            returnValues.put('amountOverdue', uhdResponse.amountOverdue);
		}
		catch (Exception e)
		{
			processException(returnValues, 'getAccountBalance', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.getAccountBalance END');
		return returnValues;

	}

	//--------------------------------------------------------------------------
	// Add upgrade details to DISE
	// ManagedBusinessUpgrades->appUpgradeDetails_1
	// Input values are:
	//   - URNPrefix                       - String
	//   - subscriptionNumber              - String
	//   - msisdn                          - String
	//   - currentTariff                   - Map<String, String>
	//     - tariffCode                    - String
	//     - tariffDescription             - String
	//   - originalConnectedDate           - Date
	//   - actualUpgradeDate               - Date
	//   - actualUpgradeTime               - String
	//   - newContractStartDate            - Date
	//   - newContractTerm                 - String
	//   - upgradeType                     - String
	//   - nextUpgradeDate                 - Date
	//   - previousNextUpgradeDate         - Date
	//   - previousContractStartDate       - Date
	//   - previousContractTerm            - String
	//   - salesPersonCode                 - String
	//   - previousSalesPersonCode         - String
	//   - upgradeStatus                   - String
	//   - sourceSystem                    - String
	//   - batchReference                  - String
	//   - repCodeOverride                 - String
	//   - eligibilityOverride             - String
	//   - newDevice                       - Map<String, String>
	//     - make                          - String
	//     - model                         - String
	//   - previousDevice                  - Map<String, String>
	//     - make                          - String
	//     - model                         - String
	//   - processedByUserID               - String
	//   - upgradeCost                     - Integer
	//   - upgradeNotes                    - String
	//   - averageSpend                    - Integer
	//   - migratedSystem                  - String
	//   - newRepCodeCategory              - String
	//   - previousRepCodeCategory         - String
	//   - nextStandardUpgradeDate         - Date
	//   - originalContractStartDate       - Date
	//   - contractTerms                   - String
	//   - contractStatus                  - String
	//   - reversedURN                     - String
	// Return values are:
	//   - URN                             - String
	//   - URNPrefix                       - String
	//   - error                           - String
	//--------------------------------------------------------------------------
	public virtual Map<String, String> addUpgradeDetails(Map<String, Object> parameters)
	{
		System.debug('O2RetailUpgradeSOAPServices.addUpgradeDetails(' + parameters + ') BEGIN');
		Map<String, String> returnValues = new Map<String, String>();
		try
		{
			SOAManageBusinessUpgradesService.ManageBusinessUpgradesPort manageBusinessUpgradesPort =
				new SOAManageBusinessUpgradesService.ManageBusinessUpgradesPort();
			manageBusinessUpgradesPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
			manageBusinessUpgradesPort.timeout_x = SOAUtils.SOA_TIMEOUT;
			//
			// Create request for addUpgradeDetails
			//
			SOAManageBusinessUpgradesData.addUpgradeDetails_1 request =
				createAddUpgradeDetailsRequest(parameters);
			//
			// Call ManagedBusinessUpgrades->appUpgradeDetails_1
			//
			SOAManageBusinessUpgradesData.addUpgradeDetails_1Response response =
				manageBusinessUpgradesPort.addUpgradeDetails_1(request);
			//
			// Map output values
			//
			mapObject(returnValues, 'URN', response.URN);
			mapObject(returnValues, 'URNPrefix', response.URNPrefix);
		}
		catch (Exception e)
		{
			processException(returnValues, 'addUpgradeDetails', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.addUpgradeDetails END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Updates contract details in DISE
	// ManageBusinessCustomerDetails->updateContractDetails
	// Input values are:
	//   - subscritionID                   - Integer
	//   - contractNumber                  - String
	//   - contractStartDate               - Date
	//   - termOfContract                  - String
	// Output values are:
	//   - statusCode                      - String
	//   - externalDescription             - String
	//   - internalDescription             - String
	//   - error Exception string          - String
	//--------------------------------------------------------------------------
	public virtual Map<String, String> updateContractDetails
	(
		Integer subscriptionID,
		String contractNumber,
		Date contractStartDate,
		String termOfContract
	)
	{
		System.debug
		(
			'O2RetailUpgradeSOAPService.updateContractDetails(' +
			subscriptionID + ', ' +
			contractNumber + ', ' +
			contractStartDate + ', ' +
			termOfContract + ') BEGIN'
		);
		Map<String, String> returnValues = new Map<String, String>();
		try
		{
			SOAManageBusinessCustomerDetailsService.ManageBusinessCustomerDetailsPort manageBusinessCustomerDetailsPort =
				new SOAManageBusinessCustomerDetailsService.ManageBusinessCustomerDetailsPort();
			manageBusinessCustomerDetailsPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
			manageBusinessCustomerDetailsPort.timeout_x = SOAUtils.SOA_TIMEOUT;
			//
			// Create request for updateContractDetails
			//
			SOAPSCommonDiseData.subscriptionData subscriptionData =
				new SOAPSCommonDiseData.subscriptionData();
			subscriptionData.subscriptionID = subscriptionID;
			SOAManageBusinessCustomerDetailsData.contractDetailsType contractDetails =
				new SOAManageBusinessCustomerDetailsData.contractDetailsType();
			contractDetails.contractNumber = contractNumber;
			contractDetails.contractStartDate = contractStartDate;
			contractDetails.termOfContract = termOfContract;
			//
			// Call ManageBusinessCustomerDetails->updateContractDetails
			//
			SOACoreData2.ServiceResultType response =
				manageBusinessCustomerDetailsPort.updateContractDetails(subscriptionData, contractDetails);
			//
			// Map output values
			//
			mapObject(returnValues, 'statusCode', response.statusCode);
			mapObject(returnValues, 'externalDescription', response.externalDescription);
			mapObject(returnValues, 'internalDescription', response.internalDescription);
		}
		catch (Exception e)
		{
			processException(returnValues, 'updateContractDetails', e);
		}
		System.debug('O2RetailUpgradeSOAPService.updateContractDetails END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Adds bolton to the subscription. First three values are mandotory.
	// ManageBusinessBoltons->addBolton_1
	// Input values are:
	//   - subscriptionId                  - Integer
	//   - serviceCode                     - String
	//   - activationDate                  - Date
	//   - boltonPropertiesMap             - Map<String, String[]>
	//   - servicePrice                    - Integer
	//   - salesPersonIdentifier           - String
	//   - description                     - String
	// Outpur values are:
	//   - statusCode                      - String
	//   - externalDescription             - String
	//   - internalDescription             - string
	//   - error Exception string          - String
	//--------------------------------------------------------------------------
	public virtual Map<String, String> addBolton
	(
		Integer subscriptionID,
		String serviceCode,
		Date activationDate,
		Date expiryDate,
		Map<String, String[]> boltonPropertiesMap,
		Integer servicePrice,
		String salesPersonIdentifier,
		String description
	)
	{
		System.debug('O2RetailUpgradeSOAPServices.addBolton BEGIN');
		Map <String, String> returnValues = new Map<String, String>();
		try
		{
			//
			// Create request
			//
			SOAPSCommonDiseData.subscriptionData subscriptionIdentifier =
				new SOAPSCommonDiseData.subscriptionData();
			subscriptionIdentifier.subscriptionID = subscriptionID;
			//
			// Create bolton properties
			//
			SOAManageBusinessBoltonsData2.boltonProperties boltonProperties =
				createBoltonProperties(boltonPropertiesMap);
			//
			// Call ManageBusinessBoltons->addBolton_1
			//
			SOAManageBusinessBoltonsService.ManageBusinessBoltonsPort manageBusinessBoltonsPort =
				new SOAManageBusinessBoltonsService.ManageBusinessBoltonsPort();
			manageBusinessBoltonsPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
			manageBusinessBoltonsPort.timeout_x = SOAUtils.SOA_TIMEOUT;
			SOACoreData2.ServiceResultType response =
				manageBusinessBoltonsPort.addBolton_1
				(
					subscriptionIdentifier,
					serviceCode,
					activationDate,
					expiryDate,
					boltonProperties,
					servicePrice,
					salesPersonIdentifier,
					description
				);
			//
			// Map output values
			//
			mapObject(returnValues, 'statusCode', response.statusCode);
			mapObject(returnValues, 'externalDescription', response.externalDescription);
			mapObject(returnValues, 'internalDescription', response.internalDescription);
		}
		catch (Exception e)
		{
			processException(returnValues, 'addBolton', e);
		}
		System.debug('O2RetailUpgradeSOAPServcies.addBolton END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Adds business customer contact event. First four values are mandotory.
	// ManageCustomerContact->addBusinessCustomerContactEvent
	// Input values are:
	//   - subscriptionNumber              - String
	//   - eventType                       - String
	//   - eventCode                       - String
	//   - processCommand                  - String
	//   - processDate                     - Date
	//   - processBackDate                 - Date
	//   - contactInformation              - String
	//   - telephoneNumber                 - String
	//   - resolutionRequiredByDate        - Date
	//   - reasonCode                      - String
	//   - passToUserID                    - String
	//   - includeNotesDefault             - Boolean
	//   - notes                           - String
	// Outpur values are:
	//   - contactEventId                  - String
	//   - error                           - String
	//--------------------------------------------------------------------------
	public virtual Map<String, String> addBusinessCustomerContactEvent(Map<String, Object> parameters)
	{
		System.debug('O2RetailUpgradeSOAPServices.addBusinessCustomerContactEvent(' + parameters + ') BEGIN');
		Map<String, String> returnValues = new Map<String, String>();
		try
		{
			//
			// Create request
			//
			SOAManageCustomerContactData2.customerContactDataType request =
				new SOAManageCustomerContactData2.customerContactDataType();
			request.targetIdentifier = new SOAManageCustomerContactData2.targetIdentifierType();
			request.targetIdentifier.accountIdentifier = (String)parameters.get('subscriptionNumber');
			request.eventType = (String)parameters.get('eventType');
			request.eventCode = (String)parameters.get('eventCode');
			request.processCommand = (String)parameters.get('processCommand');
			request.processDate = (Date)parameters.get('processDate');
			request.processBackDate = (Date)parameters.get('processBackDate');
			request.contactInformation = (String)parameters.get('contactInformation');
			request.telephoneNumber = (String)parameters.get('telephoneNumber');
			request.resolutionRequiredByDate = (Date)parameters.get('resolutionRequiredByDate');
			request.reasonCode = (String)parameters.get('reasonCode');
			request.passToUserID = (String)parameters.get('passToUserID');
			request.includeNotesDefault = (Boolean)parameters.get('includeNotesDefault');
			request.notes = (String)parameters.get('notes');
			//
			// Call ManageCustomerContact->addBusinessCustomerContactEvent
			//
			SOAManageCustomerContactService.ManageCustomerContactPort manageCustomerContactPort =
				new SOAManageCustomerContactService.ManageCustomerContactPort();
			manageCustomerContactPort.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
			manageCustomerContactPort.timeout_x = SOAUtils.SOA_TIMEOUT;
			String response =
				manageCustomerContactPort.addBusinessCustomerContactEvent(request);
		}
		catch (Exception e)
		{
			processException(returnValues, 'addBusinessCustomerContactEvent', e);
		}
		System.debug('O2RetailUpgradeSOAPServices.addBusinessCustomerContactEvent END');
		return returnValues;
	}

	//--------------------------------------------------------------------------
	// Creates device map from make and model
	// Input values are
	//   - make
	//   - model
	// Return value is map with make and model
	//--------------------------------------------------------------------------
	public static Map<String, String> createDeviceMap(String make, String model)
	{
		Map<String, String> deviceMap;
		if (make != null || model != null)
		{
			mapObject(deviceMap, 'make', make);
			mapObject(deviceMap, 'model', model);
		}
		return deviceMap;
	}

	//--------------------------------------------------------------------------
	// Creates boltonProperties from map
	// Input values is:
	//   - boltonPropertiesMap			- Map<String, String[]>
	// Return values is
	//   - boltonProperties null if there is no properties otherwise
	//--------------------------------------------------------------------------
	private static SOAManageBusinessBoltonsData2.boltonProperties createBoltonProperties
	(
		Map<String, String[]> boltonPropertiesMap
	)
	{
		System.debug('O2RetailUpgradeSOAPService.createBoltonProperties(' + boltonPropertiesMap + ') BEGIN');
		SOAManageBusinessBoltonsData2.boltonProperties boltonProperties;
		if (boltonPropertiesMap != null)
		{
			for (String boltonName : boltonPropertiesMap.keySet())
			{
				//
				// Create bolton property
				//
				SOAManageBusinessBoltonsData2.boltonProperty boltonProperty =
					new SOAManageBusinessBoltonsData2.boltonProperty();
				boltonProperty.propertyName = boltonName;
				boltonProperty.propertyValue = boltonPropertiesMap.get(boltonName);
				System.debug('boltonName: ' + boltonProperty.propertyName);
				System.debug('boltonValue: ' + boltonProperty.propertyValue);
				//
				// Create bolton properties if not created before
				//
				if (boltonProperties == null)
				{
					boltonProperties = new SOAManageBusinessBoltonsData2.boltonProperties();
					boltonProperties.boltonProperty =
						new List<SOAManageBusinessBoltonsData2.boltonProperty>();
				}
				//
				// Add bolton property
				//
				boltonProperties.boltonProperty.add(boltonProperty);
			}
		}
		System.debug('O2RetailUpgradeSOAPService.createBoltonProperties END');
		return boltonProperties;
	}

	//--------------------------------------------------------------------------
	// Trace exception leaves debug log of the method name and exception
	// Input values are:
	//   - methodName is name of SOA function that is called
	//   - e is exception that was cought
	//--------------------------------------------------------------------------
	private static void processException
	(
		Map<String, Object> returnValues,
		String methodName, Exception e
	)
	{
		O2RetailUpgradeServicesUtils.processException(returnValues, methodName, e);
	}

	//--------------------------------------------------------------------------
	// Creates request for addUpgradeDetails SOA call
	//--------------------------------------------------------------------------
	private static SOAManageBusinessUpgradesData.addUpgradeDetails_1
	createAddUpgradeDetailsRequest(Map<String, Object> parameters)
	{
		System.debug('O2RetailUpgradeSOAPServcies.createAddUpgradeDetailsRequest BEGIN');
		SOAManageBusinessUpgradesData.addUpgradeDetails_1 request;
		if (parameters != null) {
			//
			// Create request
			//
			request = new SOAManageBusinessUpgradesData.addUpgradeDetails_1();
			//
			// Create tariff details type
			//
			SOAManageBusinessUpgradesData.tariffDetailsType tariffDetails =
				createTariffDetailsFromMap((Map<String, String>)parameters.get('currentTariff'));
			//
			// Create previous and new device type
			//
			SOAManageBusinessUpgradesData.deviceType newDevice =
				createDeviceFromMap((Map<String, String>)parameters.get('newDevice'));
			SOAManageBusinessUpgradesData.deviceType previousDevice =
				createDeviceFromMap((Map<String, String>)parameters.get('previousDevice'));
			//
			// Fill request members
			//
	        request.URNPrefix = (String)parameters.get('URNPrefix');
	        request.subscriptionNumber = (String)parameters.get('subscriptionNumber');
	        request.msisdn = (String)parameters.get('msisdn');
	        request.currentTariffDetails = tariffDetails;
	        request.originalConnectedDate = (Date)parameters.get('originalConnectedDate');
	        request.actualUpgradeDate = (Date)parameters.get('actualUpgradeDate');
	        request.actualUpgradeTime = (String)parameters.get('actualUpgradeTime');
	        request.newContractStartDate = (Date)parameters.get('newContractStartDate');
	        request.newContractTerm = (String)parameters.get('newContractTerm');
	        request.upgradeType = (String)parameters.get('upgradeType');
	        request.nextUpgradeDate = (Date)parameters.get('nextUpgradeDate');
	        request.previousNextUpgradeDate = (Date)parameters.get('previousNextUpgradeDate');
	        request.previousContractStartDate = (Date)parameters.get('previousContractStartDate');
	        request.previousContractTerm = (String)parameters.get('previousContractTerm');
	        request.salesPersonCode = (String)parameters.get('salesPersonCode');
	        request.previousSalesPersonCode = (String)parameters.get('previousSalesPersonCode');
	        request.upgradeStatus = (String)parameters.get('upgradeStatus');
	        request.sourceSystem = (String)parameters.get('sourceSystem');
	        request.batchReference = (String)parameters.get('batchReference');
	        request.repCodeOverride = (String)parameters.get('repCodeOverride');
	        request.eligibilityOverride = (String)parameters.get('eligibilityOverride');
	        request.newDevice = newDevice;
	        request.previousDevice = previousDevice;
	        request.processedByUserID = (String)parameters.get('processedByUserID');
	        request.upgradeCost = (Integer)parameters.get('upgradeCost');
	        request.upgradeNotes = (String)parameters.get('upgradeNotes');
	        request.averageSpend = (Integer)parameters.get('averageSpend');
	        request.migratedSystem = (String)parameters.get('migratedSystem');
	        request.newRepCodeCategory = (String)parameters.get('newRepCodeCategory');
	        request.previousRepCodeCategory = (String)parameters.get('previousRepCodeCategory');
	        request.nextStandardUpgradeDate = (Date)parameters.get('nextStandardUpgradeDate');
	        request.originalContractStartDate = (Date)parameters.get('originalContractStartDate');
			request.contractTerms = (String)parameters.get('contractTerms');
			request.contractStatus = (String)parameters.get('contractStatus');
			request.reversedURN = (String)parameters.get('reversedURN');
		}
		System.debug('O2RetailUpgradeSOAPServcies.createAddUpgradeDetailsRequest END');
        return request;
	}

	//--------------------------------------------------------------------------
	// Creates device from map
	// Input values are:
	//   - make
	//   - model
	// Return device type with make and model
	//--------------------------------------------------------------------------
	private static SOAManageBusinessUpgradesData.deviceType createDeviceFromMap(Map<String, String> deviceMap)
	{
		SOAManageBusinessUpgradesData.deviceType device;
		if (deviceMap != null)
		{
			device = new SOAManageBusinessUpgradesData.deviceType();
			device.make = deviceMap.get('make');
			device.model = deviceMap.get('model');
			System.debug('Created device from map: ' + deviceMap);
		}
		return device;
	}

	private static SOAManageBusinessUpgradesData.tariffDetailsType createTariffDetailsFromMap
	(
		Map<String, String> tariffDetalisMap
	)
	{
		SOAManageBusinessUpgradesData.tariffDetailsType tariffDetails = new SOAManageBusinessUpgradesData.tariffDetailsType();
		if (tariffDetalisMap != null)
		{
			tariffDetails.tariffCode = tariffDetalisMap.get('tariffCode');
			tariffDetails.tariffDescription = tariffDetalisMap.get('tariffDescription');
		}
		return tariffDetails;
	}

	//--------------------------------------------------------------------------
	// Mapping of subscriber profile structure to a map
	//--------------------------------------------------------------------------
	private static void mapSubscriberProfileType(Map<String, String> returnValues, SOASubscriberData.subscriberProfileType subscriberProfileType)
	{
		System.debug('O2RetailUpgradeSOAPServices.mapSubscriberProfileType BEGIN');
		//
		// Check if subscriber profile exists
		//
		if (subscriberProfileType != null)
		{
			mapObject(returnValues, 'subscriberID', subscriberProfileType.subscriberID);
			mapObject(returnValues, 'operator', subscriberProfileType.operator);
			mapObject(returnValues, 'channel', subscriberProfileType.channel);
			mapObject(returnValues, 'paymentCategory', subscriberProfileType.paymentCategory);
			mapObject(returnValues, 'puk', subscriberProfileType.puk);
			mapObject(returnValues, 'segment', subscriberProfileType.segment);
			mapObject(returnValues, 'status', subscriberProfileType.status);
		}
		System.debug('O2RetailUpgradeSOAPServices.mapSubscriberProfileType END');
	}

	//--------------------------------------------------------------------------
	// Mapping of a subscriber profile structure to a map
	//--------------------------------------------------------------------------
	private static void mapSubscriberProfileType (Map<String, Object> returnValues, SOACoreData2.SubscriberProfileType subscriberProfileType)
	{
		System.debug('O2RetailUpgradeSOAPServices.mapSubscriberProfileType BEGIN');
		//
		// Check if subscriber profile exists
		//
		if (subscriberProfileType != null)
		{
			mapObject(returnValues, 'subscriberID', subscriberProfileType.SubscriberID);
			mapObject(returnValues, 'operator', subscriberProfileType.Operator);
			mapObject(returnValues, 'channel', subscriberProfileType.channel);
			mapObject(returnValues, 'paymentCategory', subscriberProfileType.PaymentCategory);
			mapObject(returnValues, 'segment', subscriberProfileType.Segment);
			mapObject(returnValues, 'status', subscriberProfileType.Status);
			mapObject(returnValues, 'serviceProviderID', subscriberProfileType.ServiceProviderID);
		}
		System.debug('O2RetailUpgradeSOAPServices.mapSubscriberProfileType END');
	}

	//--------------------------------------------------------------------------
	// Mapping of BASIC details
	//--------------------------------------------------------------------------
	private static void mapBasicDetails(Map<String, Object> returnValues, SOAManageBusinessSubscriptionsData.subscriptionBasicType basicDetails)
	{
		System.debug('O2RetailUpgradeSOAPServicesmapBasicDetails BEGIN');
		//
		// Check if BASIC details exists
		//
		if (basicDetails != null)
		{
			Map<String, Object> basicDetailsMap = new Map<String, Object>();
			//
			// Map values
			//
			mapObject(basicDetailsMap, 'subscriptionNumber', basicDetails.subscriptionNumber);
			mapObject(basicDetailsMap, 'agreementNumber', basicDetails.agreementNumber);
			mapObject(basicDetailsMap, 'accountNumber', basicDetails.accountNumber);
			mapObject(basicDetailsMap, 'corporateNumber', basicDetails.corporateNumber);
			mapObject(basicDetailsMap, 'groupNumber', basicDetails.groupNumber);
			mapObject(basicDetailsMap, 'companyNumber', basicDetails.companyNumber);
			mapObject(basicDetailsMap, 'salesAccountCode', basicDetails.salesAccountCode);
			mapObject(basicDetailsMap, 'salesAccountCategory', basicDetails.salesAccountCategory);
			mapObject(basicDetailsMap, 'subscriptionStatus', basicDetails.subscriptionStatus);
			mapObject(basicDetailsMap, 'tariffCode', basicDetails.tariffCode);
			mapObject(basicDetailsMap, 'tariffDescription', basicDetails.tariffDescription);
			mapObject(basicDetailsMap, 'tariffType', basicDetails.tariffType);
			mapObject(basicDetailsMap, 'networkCode', basicDetails.networkCode);
			mapObject(basicDetailsMap, 'connectedDate', basicDetails.connectedDate);
			mapObject(basicDetailsMap, 'disconnectedDate', basicDetails.disconnectedDate);
			mapObject(basicDetailsMap, 'terminateOn', basicDetails.terminateOn);
			mapObject(basicDetailsMap, 'connectionReason', basicDetails.connectionReason);
			mapObject(basicDetailsMap, 'emailAddress', basicDetails.emailAddress);
			mapObject(basicDetailsMap, 'monthlyLineRentalFee', basicDetails.monthlyLineRentalFee);
			mapObject(basicDetailsMap, 'lastAmendedDate', basicDetails.lastAmendedDate);
			//
			// Put BASIC details map into return values
			//
			returnValues.put('BASIC', basicDetailsMap);
		}
		System.debug('O2RetailUpgradeSOAPServicesmapBasicDetails END');
	}

	//--------------------------------------------------------------------------
	// Mapping of ADDRESS details
	//--------------------------------------------------------------------------
	private static void mapAddressDetails(
		Map<String, Object> returnValues,
		SOAManageBusinessSubscriptionsData.addressQueryType addressDetails)
	{
		System.debug('O2RetailUpgradeSOAPServices.mapAddressDetails BEGIN');
		//
		// Check if ADDRESS details exists
		//
		if (addressDetails != null)
		{
			Map<String, Object> addressDetailsMap = new Map<String, Object>();
			//
			// Map personal address
			//
			mapPersonalAddress(addressDetailsMap, addressDetails.personalAddress);
			//
			// Map business address
			//
			mapBusinessAddress(addressDetailsMap, addressDetails.businessAddress);
			//
			// Last amended date
			//
			mapObject(addressDetailsMap, 'lastAmendedDate', addressDetails.lastAmendedDate);
			//
			// Put ADDRESS to return map
			//
			returnValues.put('ADDRESS', addressDetailsMap);
		}
		System.debug('O2RetailUpgradeSOAPServices.mapAddressDetails END');
	}

	//--------------------------------------------------------------------------
	// Mapping of personalAddressQueryType
	//--------------------------------------------------------------------------
	private static void mapPersonalAddress(
		Map<String, Object> returnValues,
		SOAManageBusinessSubscriptionsData.personalAddressQueryType personalAddress)
	{
		//
		// Check if personal address exists
		//
		if (personalAddress != null)
		{
			Map<String, Object> personalAddressMap = new Map<String, Object>();
			//
			// Map values
			//
			mapObject(personalAddressMap, 'title', personalAddress.title);
			mapObject(personalAddressMap, 'forename', personalAddress.forename);
			mapObject(personalAddressMap, 'middleName', personalAddress.middleName);
			mapObject(personalAddressMap, 'surname', personalAddress.surname);
			mapObject(personalAddressMap, 'address1', personalAddress.address1);
			mapObject(personalAddressMap, 'address2', personalAddress.address2);
			mapObject(personalAddressMap, 'address3', personalAddress.address3);
			mapObject(personalAddressMap, 'address4', personalAddress.address4);
			mapObject(personalAddressMap, 'address5', personalAddress.address5);
			mapObject(personalAddressMap, 'postcode', personalAddress.postcode);
			mapObject(personalAddressMap, 'dateOfBirth', personalAddress.dateOfBirth);
			mapObject(personalAddressMap, 'gender', personalAddress.gender);
			mapObject(personalAddressMap, 'maritalStatus', personalAddress.maritalStatus);
			mapObject(personalAddressMap, 'dateOfResidence', personalAddress.dateOfResidence);
			mapObject(personalAddressMap, 'customerType', personalAddress.customerType);
			mapObject(personalAddressMap, 'addressType', personalAddress.addressType);
			mapObject(personalAddressMap, 'addressCategory', personalAddress.addressCategory);
			mapObject(personalAddressMap, 'occupation', personalAddress.occupation);
			mapObject(personalAddressMap, 'idType', personalAddress.idType);
			mapObject(personalAddressMap, 'idNumber', personalAddress.idNumber);
			mapObject(personalAddressMap, 'telephoneNumber', personalAddress.telephoneNumber);
			mapObject(personalAddressMap, 'eveningTelephoneNumber', personalAddress.eveningTelephoneNumber);
			mapObject(personalAddressMap, 'faxNumber', personalAddress.faxNumber);
			//
			// Put personal address to map
			//
			returnValues.put('personalAddress', personalAddressMap);
		}
	}

	//--------------------------------------------------------------------------
	// Mapping of businessAddressQueryType
	//--------------------------------------------------------------------------
	private static void mapBusinessAddress(
		Map<String, Object> returnValues,
		SOAManageBusinessSubscriptionsData.businessAddressQueryType businessAddress)
	{
		//
		// Check if business address exists
		//
		if (businessAddress != null)
		{
			Map<String, Object> businessAddressMap = new Map<String, Object>();
			//
			// Map values
			//
			mapObject(businessAddressMap, 'companyName', businessAddress.companyName);
			mapObject(businessAddressMap, 'address1', businessAddress.address1);
			mapObject(businessAddressMap, 'address2', businessAddress.address2);
			mapObject(businessAddressMap, 'address3', businessAddress.address3);
			mapObject(businessAddressMap, 'address4', businessAddress.address4);
			mapObject(businessAddressMap, 'address5', businessAddress.address5);
			mapObject(businessAddressMap, 'postcode', businessAddress.postcode);
			mapObject(businessAddressMap, 'companyTelephoneNumber', businessAddress.companyTelephoneNumber);
			mapObject(businessAddressMap, 'faxNumber', businessAddress.faxNumber);
			mapObject(businessAddressMap, 'contactTelephoneNumber', businessAddress.contactTelephoneNumber);
			mapObject(businessAddressMap, 'companyType', businessAddress.companyType);
			mapObject(businessAddressMap, 'addressType', businessAddress.addressType);
			mapObject(businessAddressMap, 'addressCategory', businessAddress.addressCategory);
			mapObject(businessAddressMap, 'industrialClassificationCode', businessAddress.industrialClassificationCode);
			mapObject(businessAddressMap, 'companyRegistration', businessAddress.companyRegistration);
			mapObject(businessAddressMap, 'dateOfIncorporation', businessAddress.dateOfIncorporation);
			mapObject(businessAddressMap, 'title', businessAddress.title);
			mapObject(businessAddressMap, 'forename', businessAddress.forename);
			mapObject(businessAddressMap, 'middleName', businessAddress.middleName);
			mapObject(businessAddressMap, 'surname', businessAddress.surname);
			mapObject(businessAddressMap, 'jobTitle', businessAddress.jobTitle);
			//
			// Put business address to map
			//
			returnValues.put('businessAddress', businessAddressMap);
		}
	}

	//--------------------------------------------------------------------------
	// Mapping of CONTRACTANDSALES details
	//--------------------------------------------------------------------------
	private static void mapContractAndSalesDetails(
		Map<String, Object> returnValues,
		SOAManageBusinessSubscriptionsData.contractAndSalesType contractAndSalesDetails)
	{
		System.debug('O2RetailUpgradeSOAPServices.mapContractAndSalesDetails BEGIN');
		//
		// Check if CONTRACTANDSALES details exists
		//
		if (contractAndSalesDetails != null)
		{
			Map<String, Object> contractAndSalesDetailsMap = new Map<String, Object>();
			//
			// Map values
			//
			mapObject(contractAndSalesDetailsMap, 'contractNumber', contractAndSalesDetails.contractNumber);
			mapObject(contractAndSalesDetailsMap, 'pricePlanCode', contractAndSalesDetails.pricePlanCode);
			mapObject(contractAndSalesDetailsMap, 'firstInvoiceDate', contractAndSalesDetails.firstInvoiceDate);
			mapObject(contractAndSalesDetailsMap, 'lastInvoiceDate', contractAndSalesDetails.lastInvoiceDate);
			mapObject(contractAndSalesDetailsMap, 'nextInvoiceDate', contractAndSalesDetails.nextInvoiceDate);
			mapObject(contractAndSalesDetailsMap, 'contractStartDate', contractAndSalesDetails.contractStartDate);
			mapObject(contractAndSalesDetailsMap, 'termOfContract', contractAndSalesDetails.termOfContract);
			mapObject(contractAndSalesDetailsMap, 'termsAndConditionsCode', contractAndSalesDetails.termsAndConditionsCode);
			mapObject(contractAndSalesDetailsMap, 'terminationInvoiceProduced', contractAndSalesDetails.terminationInvoiceProduced);
			mapObject(contractAndSalesDetailsMap, 'lastAmendedDate', contractAndSalesDetails.lastAmendedDate);
			//
			// Put CONTRACTANDSALES datails map to return values
			//
			returnValues.put('CONTRACTANDSALES', contractAndSalesDetailsMap);

		}
		System.debug('O2RetailUpgradeSOAPServicesmapContractAndSalesDetails END');
	}

	//--------------------------------------------------------------------------
	// Mapping of SERVICE details
	//--------------------------------------------------------------------------
	private static void mapServiceDetails
	(
		Map<String, Object> returnValues,
		SOAManageBusinessSubscriptionsData.serviceDetailsType servicesDetails
	)
	{
		System.debug('O2RetailUpgradeSOAPServices.mapServiceDetails BEGIN');
		//
		// Check if there are services
		//
		if (servicesDetails != null && servicesDetails.service != null)
		{
			List<Map<String, Object>> servicesDetailsList = new List<Map<String, Object>>();
			for (SOAManageBusinessSubscriptionsData.serviceDetailType service : servicesDetails.service)
			{
				Map<String, Object> serviceMap = new Map<String, Object>();
				mapObject(serviceMap, 'serviceCode', service.serviceCode);
				mapObject(serviceMap, 'packageCode', service.packageCode);
				mapObject(serviceMap, 'servicePrice', service.servicePrice);
				mapObject(serviceMap, 'description', service.description);
				mapObject(serviceMap, 'effectiveDate', service.effectiveDate);
				mapObject(serviceMap, 'expiryDate', service.expiryDate);
				mapObject(serviceMap, 'lastAmendedDate', service.lastAmendedDate);
				servicesDetailsList.add(serviceMap);
			}
			returnValues.put('SERVICES', servicesDetailsList);
		}
		System.debug('O2RetailUpgradeSOAPServices.mapSerivceDetails END');
	}

	//--------------------------------------------------------------------------
	// Mapping of object
	//--------------------------------------------------------------------------
	private static void mapObject(Map<String, Object> values, String key, Object value)
	{
		if (value != null)
		{
			values.put(key, value);
			System.debug(key + ': ' + value);
		}
	}

	//--------------------------------------------------------------------------
	// Test cases
	//--------------------------------------------------------------------------
	@isTest(SeeAllData=true)
	public static void testSOAPServices()
	{
		O2RetailUpgradeSOAPServices retailUpgradeServices = new O2RetailUpgradeSOAPServices();
		Map<String, Object> subscriptionDetails = retailUpgradeServices.getSubscriptionDetails('447734872466', new String[] {'BASIC', 'CONTRACTANDSALES'});
		Map<String, Object> upgradeDetails = retailUpgradeServices.getUpgradeDetails_1('10466241');
		Map<String, Object> accountManagedDetails = retailUpgradeServices.getAccountManagedDetails('2023655');
		Map<String, Object> addUpgradeDetailsRequest = new Map<String, Object>();
		addUpgradeDetailsRequest.put('msisdn', '447734872466');
		Map<String, Object> addUpgradeDetails = retailUpgradeServices.addUpgradeDetails(addUpgradeDetailsRequest);
		//
		// Print results
		//
		System.debug('subscriptionDetails: ' + subscriptionDetails);
		System.debug('upgradeDetails: ' + upgradeDetails);
		System.debug('accountManagedDetails: ' + accountManagedDetails);
	}
}