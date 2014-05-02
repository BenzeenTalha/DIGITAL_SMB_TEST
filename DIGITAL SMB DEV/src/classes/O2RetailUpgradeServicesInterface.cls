public interface O2RetailUpgradeServicesInterface {
	//--------------------------------------------------------------------------
	// Retrives subscription details from mobile phone number by calling
	// ManageBusinessSubcription->getSubscriptionDetails
	// Input values are:
	//   msisdn   - MSISDN in international format
	//   filter   - Filter output values. Can be one or more of	BASIC, ADDRESS, BILLINGMEDIA, BUNDLES,
	//              DISCOUNTS, CONTRACTANDSALES, CUSTOMERDETAILS, DISCOUNTOVERRIDES, SERIALNUMBERS,
	//              SERVICES, SUBSCRIPTIONBARS, USAGEANDCREDITCONTROL
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
	//   BILLINGMEDIA
	//     billingMediaCode
	//     billingMediaDescription
	//     billingMediaCopyInvoiceMediaCode
	//     billingMediaCopyInvoiceMediaCodeDescription
	//     billingMediaOverrideInvoiceMediaCode
	//     billingMediaOverrideInvoiceMediaDescription
	//	   lastAmendedDate
	//   BUNDLES
	//     List of 1..*
	//       bundleCode
	//       bundleTypeCode
	//       bundleTypeDescription
	//       bundleEffectiveDate
	//       bundleExpiryDate
	//       lastAmmendDate
	//   DISCOUNTS
	//     List of 1..*
	//       discountTypeCode
	//       discountTypeDescription
	//       discountSchemeCode
	//       discountDescription
	//       effectiveDate
	//       expiryDate
	//       packageCode
	//       lastAmendedDate
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
	//   CUSTOMERDETAILS
	//     userName
	//     itemCode
	//     directoryListingAllowed
	//     customerCostCentre
	//     lastAmendedDate
	//   DISCOUNTOVERRIDES
	//     ignoreAgreementDiscounts
	//     ignoreAccountDiscounts
	//     lastAmendedDate
	//   SERIALNUMBERS
	//     managedSerialNumbers
	//       List 0..5
	//         networkSerialNumberID
	//         networkSerialNumber
	//         networkEffectiveDate
	//         networkCode
	//         networkSerialStatus
	//         lastAmendedDate
	//     nonManagedSerialNumbers
	//       List 0..9
	//         nonManagedSerialNumberID
	//         nonManagedSerialNumber
	//         networkEffectiveDate
	//         networkSerialStatus
	//         lastAmendedDate
	//     networkSubCodes
	//       List O..2
	//         networkCodeID
	//         networkSubCode
	//         networkEffectiveDate
	//         networkCode
	//         networkSerialStatus
	//         lastAmendedDate
	//   SERVICES
	//     List of 0..*
	//       serviceCode
	//       packageCode
	//       servicePrice
	//       description
	//       effectiveDate
	//       expiryDate
	//       lastAmendedDate
	//   SUBSCRIPTIONBARS
	//     List of 1..*
	//       networkCommandCode
	//       barredDate
	//       unBarredDate
	//       barReasonCode
	//       barReasonDescription
	//       unbarReasonCode
	//       unbarReasonDescription
	//       adminBarFlag
	//       lastAmendedDate
	//   USAGEANDCREDITCONTROL
	//     lowerUsageLimit
	//     upperUsageLimit
	//     ignoreUsageLimits
	//     autoAdjust
	//     ignoreCreditControlProcedures
	//     lastAmendedDate
	//   error
	//--------------------------------------------------------------------------
	Map<String, Object> getSubscriptionDetails(String p_msisdn, String[] p_filter);

	//--------------------------------------------------------------------------
	// Retrieves upgrade details from subscription by calling
	// ManageBusinessUpgrades->getUpgradeDetails_1
	// Input values: subscriptionNumber
	// Return values are:
	//  'Response'
	//		SOAManageBusinessUpgradesData.getUpgradeDetails_1Response
	// or
	//	'error'
	//		Exception string
	//--------------------------------------------------------------------------
	Map<String, Object> getUpgradeDetails_1(String subscriptionNumber);

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
	Map<String, Object> getAccountDetails(String accountNumber, String[] filter);

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
	Map<String, Object> getEarlyUpgradeFee_1(Integer lineRentalFee, Integer remainingMonths);

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
	Map<String, Object> getCustomerTransactions(String accountNumber, String transactionType, String transactionFilter, Integer noOfRecordsToBeRetrieved);

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
	Map<String, Object> getUpgradeHistoryDetails_1(String subscriptionNumber);

	//--------------------------------------------------------------------------
	// Retrieves if account is managed or not by calling
	// ManagedBusinessCustomerDetails->getAccountManagedDetails_1
	// Input value is account number
	// Output values are:
	//   isAccountManaged   - true if account is managed false otherwise
	//   error              - On error this value exists
	//--------------------------------------------------------------------------
	Map<String, Object> getAccountManagedDetails(String accountNumber);

	//--------------------------------------------------------------------------
	// Retrieves account balance
	// ViewBusinessAccountBalance->getAccountBalance
	// Input value is account number
	// Output values are:
	//   amountOverdue   - reater than zero than account is in arrears
	//   error              - On error this value exists
	//--------------------------------------------------------------------------
	Map<String, Object> getAccountBalance(String accountNumber);

	//--------------------------------------------------------------------------
	// Add upgrade details to DISE
	// ManageBusinessUpgrades->addUpgradeDetails_1
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
	Map<String, String> addUpgradeDetails(Map<String, Object> parameters);

	//--------------------------------------------------------------------------
	// Updates contract details in DISE
	// ManageBusinessCustomerDetails->updateContractDetails
	// Manage
	// Input values are:
	//   - subscritionID                   - Integer
	//   - contractNumber                  - String
	//   - contractStartDate               - Date
	//   - termOfContract                  - String
	// Output values are:
	//   - statusCode
	//   - externalDescription
	//   - internalDescription
	//   - error Exception string
	//--------------------------------------------------------------------------
	Map<String, String> updateContractDetails
	(
		Integer subscriptionID,
		String contractNumber,
		Date contractStartDate,
		String termOfContract
	);

	//--------------------------------------------------------------------------
	// Adds bolton to the subscription. First three values are mandotory.
	//ManageBusinessBoltons->addBolton_1
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
	Map<String, String> addBolton
	(
		Integer subscriptionID,
		String serviceCode,
		Date activationDate,
		Date expiryDate,
		Map<String, String[]> boltonPropertiesMap,
		Integer servicePrice,
		String salesPersonIdentifier,
		String description
	);

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
	Map<String, String> addBusinessCustomerContactEvent(Map<String, Object> parameters);
}