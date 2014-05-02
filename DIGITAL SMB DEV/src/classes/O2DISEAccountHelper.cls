//------------------------------------------------------------------------------
// Helper for retrieving DISE account information
//------------------------------------------------------------------------------
public with sharing class O2DISEAccountHelper
{
	//--------------------------------------------------------------------------
	// DISE account subscirption data
	//--------------------------------------------------------------------------
	public class DISEAccount
	{
		public String subscriptionNumber {get; set;}
		public String accountNumber {get; set;}
		public String tariffCode {get; set;}
		public String tariffDescription {get; set;}
		public String tariffType {get; set;}
		public String companyName {get; set;}
		public String streetAddress {get; set;}
		public String city {get; set;}
		public String county {get; set;}
		public String postCode {get; set;}
		public String contactTitle {get; set;}
		public String contactFirstName {get; set;}
		public String contactMiddleName {get; set;}
		public String contactLastName {get; set;}
		public String contactOccupation {get; set;}
		public String contactPhone {get; set;}
		public String contactEmail {get; set;}
		public Decimal monthlyLineRentalFee {get; set;}
		public String salesAccountCategory {get; set;}
		public Boolean isAccountManaged {get; set;}
	}

	//--------------------------------------------------------------------------
	// DPA checks data
	//--------------------------------------------------------------------------
	public class DPAChecks
	{
		public String accountPassword {get; set;}
		public Integer accountPin {get; set;}
		public String bankAccountNumber {get; set;}
    	public String bankSortCode {get; set;}
		public Date lastInvoiceDate {get; set;}
		public Date lastPaymentDate {get; set;}
		public Decimal lastInvoiceAmount {get; set;}
		public String lastInvoiceNumber {get; set;}

		public String bankAccountNumberSecure
        {
            get{
	            string mask = '*';
	            return (bankAccountNumber != null? (mask.repeat(bankAccountNumber.length() -3) + bankAccountNumber.right(3)):'');
            }
        }

        public String bankSortCodeSecure {
	        get{
	            string mask = '*';
	            return  (bankSortCode != null? (bankSortCode.left(1)+ mask.repeat(bankSortCode.length() -2) + bankSortCode.right(1)):'');
            }
        }
	}

	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
    private static final String LINE_RENTAL_CHARGE = 'LINECH';

	//--------------------------------------------------------------------------
	// Retrieve account information from DISE
	//--------------------------------------------------------------------------
	public static DISEAccount getDISEAccount(String mobile)
	{
		DISEAccount diseAccount = null;
		if (String.isNotBlank(mobile))
		{
			//
			// Call getSubscriptionDetails to get account details
			//
			String msisdn = SOAUtils.cleanDirectoryNumber(mobile);
			O2RetailUpgradeServicesInterface servicesInterface =
				new O2RetailUpgradeServicesProxy(new O2RetailUpgradeSOAPServices());
			Map<String, Object> subscriptionDetails =
				servicesInterface.getSubscriptionDetails(
						msisdn,
						new String[]{'BASIC', 'ADDRESS', 'SERVICES'});
			diseAccount = mapDISEAccount(subscriptionDetails);

			//
			// Call setAccountManagedDetails to get managed details
			//
			if (diseAccount != null)
			{
				Map<String, Object> accountManagedDetails =
					servicesInterface.getAccountManagedDetails(diseAccount.accountNumber);
				diseAccount.isAccountManaged = (Boolean)accountManagedDetails.get('isAccountManaged');
			}
		}
		return diseAccount;
	}

	//--------------------------------------------------------------------------
	// Retrieve DPA check information from DISE
	//--------------------------------------------------------------------------
	public static DPAChecks getDPAChecks(String accountNumber)
	{
		DPAChecks dpaChecks = null;
		if (String.isNotEmpty(accountNumber))
		{
			dpaChecks = new DPAChecks();
			//
			// Call getAccountDetails to get account PIN and password
			//
			O2RetailUpgradeServicesInterface servicesInterface =
				new O2RetailUpgradeServicesProxy(new O2RetailUpgradeSOAPServices());
			Map<String, Object> accountDetails =
				servicesInterface.getAccountDetails(
						accountNumber,
						new String[]{'CUSTOMER_DETAILS', 'PAYMENT_DETAILS'});
			system.debug('accountDetails: ' + accountDetails);
			if (!O2RetailUpgradeServicesUtils.checkForError(accountDetails))
			{
				dpaChecks.accountPassword = (String)accountDetails.get('accountPassword');
				dpaChecks.accountPin = (Integer)accountDetails.get('accountPIN');
				dpaChecks.bankAccountNumber = (String)accountDetails.get('bankAccountNumber');
				dpaChecks.bankSortCode = (String)accountDetails.get('bankSortCode');
			}
			//
			// Call getCustomerTransactions to get last payment
			//
			Map<String, Object> customerTransactions = servicesInterface.getCustomerTransactions(
					accountNumber,
					'PAYMENT',
					'POSTED_ALL',
					1);
			system.debug('customerTransactions: ' + customerTransactions);
			if (!O2RetailUpgradeServicesUtils.checkForError(customerTransactions))
			{
				SOAViewBusinessCustomerTransData.transactionDetailsType[] transactions;
				transactions = (SOAViewBusinessCustomerTransData.transactionDetailsType[])
					customerTransactions.get('custTransResponse');
				if (transactions != null && transactions.size() > 0)
				{
					dpaChecks.lastPaymentDate = transactions[0].paymentDueOrReceivedDate;
				}
			}
			//
			// Call getCustomerTransactions to get last invoice
			//
			customerTransactions = servicesInterface.getCustomerTransactions(
					accountNumber,
					'INVOICE',
					'POSTED_ALL',
					1);
			system.debug('customerTransactions: ' + customerTransactions);
			if (!O2RetailUpgradeServicesUtils.checkForError(customerTransactions))
			{
				SOAViewBusinessCustomerTransData.transactionDetailsType[] transactions;
				transactions = (SOAViewBusinessCustomerTransData.transactionDetailsType[])
					customerTransactions.get('custTransResponse');
				if (transactions != null && transactions.size() > 0)
				{
					dpaChecks.lastInvoiceDate = transactions[0].transactionDate;
					dpaChecks.lastInvoiceAmount = transactions[0].transactionAmount;
					dpaChecks.lastInvoiceNumber = transactions[0].transactionReference;
				}
			}
		}
		return dpaChecks;
	}

	//--------------------------------------------------------------------------
	// Map service response do to DISEAccount
	//--------------------------------------------------------------------------
	private static DISEAccount mapDISEAccount(Map<String, Object> subscriptionDetails)
	{
		DISEAccount diseAccount = null;
		if (!O2RetailUpgradeServicesUtils.checkForError(subscriptionDetails))
		{
			diseAccount = new DISEAccount();

			mapBasic(diseAccount, subscriptionDetails);
			mapAddress(diseAccount, subscriptionDetails);
			mapServices(diseAccount, subscriptionDetails);
		}
		return diseAccount;
	}

	//--------------------------------------------------------------------------
	// BASIC information
	//--------------------------------------------------------------------------
	private static void mapBasic(
		DISEAccount diseAccount,
		Map<String, Object> subscriptionDetails)
	{
		Map<String, Object> basic =
			(Map<String, Object>)subscriptionDetails.get('BASIC');
		if (basic != null)
		{
			diseAccount.accountNumber = (String)basic.get('accountNumber');
			diseAccount.subscriptionNumber =
				(String)basic.get('subscriptionNumber');
			diseAccount.tariffCode = (String)basic.get('tariffCode');
			diseAccount.tariffDescription = (String)basic.get('tariffDescription');
			diseAccount.tariffType = (String)basic.get('tariffType');
			diseAccount.contactEmail = (String)basic.get('emailAddress');
			diseAccount.monthlyLineRentalFee =
				(Integer)basic.get('monthlyLineRentalFee');
			diseAccount.salesAccountCategory = (String)basic.get('salesAccountCategory');
		}
	}

	//--------------------------------------------------------------------------
	// ADDRESS information
	//--------------------------------------------------------------------------
	private static void mapAddress(
			DISEAccount diseAccount,
			Map<String, Object> subscriptionDetails)
	{
		Map<String, Object> address =
			(Map<String, Object>)subscriptionDetails.get('ADDRESS');
		if (address != null)
		{
			//
			// Business address
			//
			Map<String, Object> businessAddress =
				(Map<String, Object>)address.get('businessAddress');
			if (businessAddress != null)
			{
				diseAccount.companyName = (String)businessAddress.get('companyName');
				retrieveAddress(diseAccount, businessAddress);
				retrieveContactNameAndOccupation(diseAccount, businessAddress);
				diseAccount.contactPhone = (String)businessAddress.get('contactTelephoneNumber');
			}
			//
			// Personal address
			//
			Map<String, Object> personalAddress =
				(Map<String, Object>)address.get('personalAddress');
			//
			// Only if business address doesn't exist
			// use personal address
			//
			if (personalAddress != null
				&& businessAddress == null)
			{
				retrieveAddress(diseAccount, personalAddress);
			}
			//
			// If personal address exists
			//
			if (personalAddress != null)
			{
				retrieveContactNameAndOccupation(diseAccount, personalAddress);
				diseAccount.contactPhone = (String)personalAddress.get('telephoneNumber');
			}
		}
	}

	//--------------------------------------------------------------------------
	// SERVICES information
	//--------------------------------------------------------------------------
	private static void mapServices(
			DISEAccount diseAccount,
			Map<String, Object> subscriptionDetails)
	{
		List<Map<String, Object>> services =
			(List<Map<String, Object>>)subscriptionDetails.get('SERVICES');
		if (services != null)
		{
			//
			// Look for line rental charge
			//
			for (Map<String, Object> service : services)
			{
				if (LINE_RENTAL_CHARGE.equalsIgnoreCase(
						(String)service.get('serviceCode')))
				{
					diseAccount.monthlyLineRentalFee =
						((Integer)service.get('servicePrice'));
					break;
				}
			}
		}
	}

	//--------------------------------------------------------------------------
	// Retrieve address to DISE account
	//--------------------------------------------------------------------------
	private static void retrieveAddress(
			DISEAccount diseAccount,
			Map<String, Object> address)
	{
		system.debug('Address: ' + address);
		String address1 = nullToBlank((String)address.get('address1'));
		String address2 = nullToBlank((String)address.get('address2'));
		diseAccount.streetAddress = (address1 + ' ' + address2).trim();
		diseAccount.city = (String)address.get('address3');
		diseAccount.county = (String)address.get('address4');
		diseAccount.postCode = (String)address.get('postcode');
	}

	//--------------------------------------------------------------------------
	// Retrieve contact name and occupation
	//--------------------------------------------------------------------------
	private static void retrieveContactNameAndOccupation(
			DISEAccount diseAccount,
			Map<String, Object> address)
	{
		diseAccount.contactTitle = (String)address.get('title');
		diseAccount.contactFirstName = (String)address.get('forename');
		diseAccount.contactMiddleName = (String)address.get('middleName');
		diseAccount.contactLastName = (String)address.get('surname');
		diseAccount.contactOccupation = (String)address.get('occupation');
	}

	//--------------------------------------------------------------------------
	// Convert null string to blank
	//--------------------------------------------------------------------------
	private static String nullToBlank(String value)
	{
		return value == null ? '' : value;
	}
}