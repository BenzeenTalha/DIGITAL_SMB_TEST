public without sharing class O2RetailUpgradeController {
    //--------------------------------------------------------------------------
    // Constants
    //--------------------------------------------------------------------------
    private static final String PHONE_NUMBER_PARAMETER = 'context';
    private static final String DECIMAL_SEPARATOR = '.';
    private static final Integer PRICE_CHARS_AFTER_DOT = 2;
    private static final String CUSTOMER_TYPE_O2 = 'O2';
    private static final String CUSTOMER_TYPE_FRANCHISE = 'Franchise';
    private static final String CUSTOMER_TYPE_PARTNER = 'Partner';

    //--------------------------------------------------------------------------
    // Members
    //--------------------------------------------------------------------------
    private Map<String, String> customerTypeMap;

	//--------------------------------------------------------------------------
	// Getters / setters
	//--------------------------------------------------------------------------
	//
    // The primary custom setting reference table
    // - many settings can be placed in this table for easy access
    public List<O2RetailUpgradeSettings__c> refCodes {
        get {if (refCodes == null) return O2RetailUpgradeSettings__c.getAll().values(); else return refCodes;}
        set;
    }
    //
    // Pre-load name/value map from custom settings
    public Map<String, String> retailNameValueMap {
    	get {
	    	if(retailNameValueMap==null) {
		        retailNameValueMap = new Map<String, String>();
		        if (refCodes!=null && refCodes.size()>0) {
		            for (O2RetailUpgradeSettings__c ref: refCodes) {
		            	retailNameValueMap.put(ref.Name, ref.Value__c);
		            }
		        }
	    	}
	    	return retailNameValueMap;
    	}
    	set;
    }
    public Boolean isPhoneNumberRetrieved { get; set; }
    public String mobilePhoneNumber {get; set {mobilePhoneNumber = value != null ? value.trim() : '';}}
    public String storeCode {get;set;}
    public String storeName {get;set;}
    public String errorMessage { get; set; }
    public String errorMessageDPA1 { get; set; }
    public String errorMessageDPA2 { get; set; }
    public Boolean checkSucceeded { get; set; }
    public string testString { get; set; }
    //-----------------------------------------
    // Needed for configuration page
    // Must be set to false when edit is clicked on summary page
    public Boolean isConfigurationValidated { get; set; }
    //-----------------------------------------
    // Needed for summary and contract pages
    // Company name is used in summary and contract pages
    public String getCompanyName() { return retailChecks.companyName; }
	// Company address is used in summary and contract pages
    public String getCompanyAddress()
    {
		String returnValue = '';
		returnValue += retailChecks.companyAddress1 != null ? retailChecks.companyAddress1 : '';
		returnValue += appendAddress(retailChecks.companyAddress2);
		returnValue += appendAddress(retailChecks.companyAddress3);
		returnValue += appendAddress(retailChecks.companyAddress4);
		returnValue += appendAddress(retailChecks.companyAddress5);
		returnValue += appendAddress(retailChecks.companyPostcode);
		return returnValue;
    }
    // Address lines for contract
    public List<String> getCompanyAddressList()
    {
    	List<String> returnValue = new List<String>();
    	appendAddressList(returnValue, retailChecks.companyAddress1);
    	appendAddressList(returnValue, retailChecks.companyAddress2);
    	appendAddressList(returnValue, retailChecks.companyAddress3);
    	appendAddressList(returnValue, retailChecks.companyAddress4);
    	appendAddressList(returnValue, retailChecks.companyAddress5);
    	appendAddressList(returnValue, retailChecks.companyPostcode);
		//
		// Add empty values to the end of the list
		//
		Integer numberOfEmptyFields = 6 - returnValue.size();
		for (Integer index = 0; index < numberOfEmptyFields; index++)
		{
			returnValue.add('');
		}
    	return returnValue;
    }
    // Contact name is used in contract page
    public String getContactName()
    {
    	String returnValue = '';
    	returnValue += addToName(retailChecks.contactTitle);
		returnValue += addToName(retailChecks.contactFirstName);
		returnValue += addToName(retailChecks.contactMiddleName);
		returnValue += addToName(retailChecks.contactLastName);
		returnValue = returnValue.trim();
		return returnValue.length() > 0 ? returnValue : null;
    }
    // Contact telephone is used in contract page
    public String getContactTelephone() { return retailChecks.contactTelephoneNumber; }
    // Upgrade reference number is used in contract and confirmation pages
    public String getUpgradeReferenceNumber() { return retailChecks.upgradeReferenceNumber; }
    // Subscription number is used in summary and contract pages
    public String getSubscriptionNumber() { return retailChecks.subscriptionNumber; }
    // Account number is used in summary and contract pages
    public String getAccountNumber() { return retailChecks.accountNumber; }
    // Customer type is used in summary and contract pages
    public String getCustomerType()
    {
    	return customerTypeMap.get(retailChecks.customerType);
    }
    // Sales account code is used in summary and contract pages
    public String getSalesAccountCode() { return storeSalesAccountCode; }
    // Sales person number is user in contract page
    public String getSalesPerson() { return Userinfo.getName(); }
    // Start of the new contract is used in summary and contract pages
    public String getNewContractStartDate()
    {
		return retailChecks.newContractStartDate != null ? retailChecks.newContractStartDate.format() : null;
    }
    // New term of contract is used in summary and contract pages
   	public String getNewTermOfContract()
   	{
		if (dataCollector.thisTariff != null
   			&& dataCollector.thisTariff.tariff != null
			&& dataCollector.thisTariff.tariff.Contract_Length__c != null)
		{
			return dataCollector.thisTariff.tariff.Contract_Length__c + ' months';
		}
		else
		{
			return null;
		}
   	}
   	// IMEI number is used in summary and contract pages
    public String getImei()
    {
		if (dataCollector.IMEInumber != null
			&& dataCollector.IMEInumber.trim().length() > 0)
		{
			return dataCollector.IMEInumber;
		}
		else
		{
			return '-';
		}
    }
    // New SIM number is used in summary and contract pages
    public String getNewSIM() { return dataCollector.SIMswap == true ? dataCollector.SIMnumber : '-'; }
    // New device is used in summary and contract pages
    public String getNewDevice()
    {
		if (dataCollector.thisDevice != null
			&& dataCollector.thisDevice.device != null)
		{
			return dataCollector.thisDevice.device.Name;
		}
		else
		{
			return '-';
		}
    }
    // New tariff is used in summary and contract pages
    public String getNewTariff() {
		if (dataCollector.thisTariff != null
			&& dataCollector.thisTariff.tariff != null
			&& dataCollector.thisTariff.tariff.Name != null)
		{
			return dataCollector.thisTariff.tariff.Name + ' (' + formatPrice(dataCollector.thisTariff.tariff.Price__c) + ')';
		}
		else
		{
			return '-';
		}
    }
    // Inclusive data is used in summary and contract pages
    public String getInclusiveData() {
	 	if (dataCollector.thisTariff != null
	 		&& dataCollector.thisTariff.tariff != null
	 		&& dataCollector.thisTariff.tariff.Inclusive_Core_Data__c != null)
	 	{
	 		if (dataCollector.thisTariff.tariff.Inclusive_Core_Data__c>=1000) return dataCollector.thisTariff.tariff.Inclusive_Core_Data__c.divide(1000,0)+'Gb';
	 		else return Integer.valueOF(dataCollector.thisTariff.tariff.Inclusive_Core_Data__c)+'MB';
	 	}
	 	else return '-';
   	}
    // Insurance is used in summary and contact pages
    public String getInsurance()
    {
		if (dataCollector.addInsurance != null
			&& dataCollector.addInsurance
			&& dataCollector.insurancePrice != null)
		{
			return formatPrice(dataCollector.insurancePrice);
		}
		else
		{
			return '-';
		}
    }
    // Insurance price user in configuration page
    public String getInsurancePrice()
    {
    	return formatPrice(dataCollector.insurancePrice);
    }
    // Additional data is used in summary and contract pages
    public String getAdditionalData()
    {
		return formatBolton(dataCollector.thisDataBolton);
    }
    // Off pick calls is used in summary and contract pages
    public String getOffPickCalls()
    {
   		return formatBolton(dataCollector.thisMinsBolton);
    }
    // International favourites is used in summary and contract pages
    public String getInternationalFavourites()
    {
    		return formatBolton(dataCollector.thisFaveBolton);
    }
    // FTU fee is used in summary and contract pages
    public String getFtuFee()
    {
  		if (retailChecks.earlyUpgradeFee != null)
   		{
			return formatPrice(Decimal.valueOf(retailChecks.earlyUpgradeFee) / 100);

		}
		else
		{
			return '-';
		}
	}
    // Total monthly charge is used in summary and contract pages
    public String getTotalMonthlyCharge()
    {
    	Decimal totalMonthlyCharge = Decimal.valueOf(0);
    	//
    	// Add tariff price
    	//
    	if (dataCollector.thisTariff != null
    		&& dataCollector.thisTariff.tariff != null
    		&& dataCollector.thisTariff.tariff.Price__c != null)
    	{
    		totalMonthlyCharge += dataCollector.thisTariff.tariff.Price__c;
    	}
    	//
    	// Add boltons prices
    	//
		totalMonthlyCharge += getBoltonPrice(dataCollector.thisDataBolton);
		totalMonthlyCharge += getBoltonPrice(dataCollector.thisMinsBolton);
		totalMonthlyCharge += getBoltonPrice(dataCollector.thisFaveBolton);
		if (dataCollector.addInsurance != null
			&& dataCollector.addInsurance
			&& dataCollector.insurancePrice != null)
		{
			totalMonthlyCharge += dataCollector.insurancePrice;
		}
		return formatPrice(totalMonthlyCharge);
    }
    // placingOrderState is variable for visualforce action chaining pattern
    public Integer placingOrderStep { get; set; }

	//added by DD - start
	public String getOfice365SelectedProductName()
	{
		return (dataCollector.Ofice365SelectedProductName());
	}
	//added by DD - end

    public String pin { get; set; }
    public Boolean forgotPin { get; set; }

    public Map<String, O2_Retail_Store_Mapping__c> retailCodes {
        get {if (retailCodes == null) return O2_Retail_Store_Mapping__c.getAll(); else return retailCodes;}
        set;
    }
    public List<O2_Retail_Store_Mapping__c> retailCodeValues {
        get {if (retailCodeValues == null) return O2_Retail_Store_Mapping__c.getAll().values(); else return retailCodeValues;}
        set;
    }
	//
    // DPA properties
    //
    public Boolean checkDPA1Succeeded { get; set; }
    public Boolean checkDPA2Succeeded { get; set; }
    public Boolean proceedToDPA2 { get; set; }
	public Boolean dpa2TryAgain { get; set; }
	public Boolean dpa2LevelFail { get; set; }

    public Boolean isPinAvailable {
    	get {
    		return retailChecks.pinAvailable();
    	}
    	set;
    }
    public String passwordCharacters { get; set; }
    public class InputChar {
    	public String pwInChar { get; set;}
    	public Integer idx { get; set;}
    	public InputChar(String str, Integer i) {
    		pwInChar=str;
    		idx=i;
    	}
    }
    public List<InputChar> pwInCharList {
    	get {
    		if(pwInCharList==null || pwInCharList.isEmpty()) {
    			pwInCharList=new List<InputChar>();
    			for(Integer i=0; i< Integer.valueOf(retailNameValueMap.get('PW Characters Requested')); i++) {
    				InputChar ic=new InputChar('--',i);
    				pwInCharList.add(new InputChar('--',i));
    			}
    		}
    		return pwInCharList;
    	}
    	set;
    }

    public List<SelectOption> passwordCharacterOptions {
    	get {
	    	if (passwordCharacterOptions==null || passwordCharacterOptions.size()==0) {
	    		passwordCharacterOptions = new List<SelectOption>();

	    		// get list of characters from ascii numbers
	    		List<Integer> charList=new List<Integer>();
	    		for ( integer i = 1; i < 91; i ++ ) {
					charList.add(i);
				}
				//make into string
				String charactersStr = String.fromCharArray(charList);

				//remove unwanted characters
				charactersStr=charactersStr.replaceAll('[^A-Z0-9]','');

				//load characters into select options
				passwordCharacterOptions.add(new SelectOption('--','--'));
				for(Integer i=0; i<charactersStr.length(); i++) {
					String characterItem=charactersStr.substring(i,i+1);
					passwordCharacterOptions.add(new SelectOption(characterItem, characterItem));
				}
	    	}
	    	return passwordCharacterOptions;
    	}
    	set;
    }
	//
    // Question and Answers from page
    //
    public String dpa2Q1Selection { get; set; }
    public String dpa2Q2Selection { get; set; }
    public String dpa2Q3Selection { get; set; }
    public String dpa2Answer1 { get; set; }
    public String dpa2Answer2 { get; set; }
    public String dpa2Answer3 { get; set; }

    // Question options master list
    public List<SelectOption> dpa2Questions {
    	get {
    		if (dpa2Questions==null || dpa2Questions.size()==0) {
    			dpa2Questions=dpaQOptions();
    		}
    		return dpa2Questions;
    	}
    	set;
    }
	//
	// Load options for dpa2Questions()
    private List<SelectOption> dpaQOptions() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2RetailUpgradeSettings__c> mpCodes = new Map<String, O2RetailUpgradeSettings__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2RetailUpgradeSettings__c ref: refCodes) {
      			System.debug(LoggingLevel.INFO,'*** dpaQuestions: reference code:'+ref);
                if (ref.Type__c == 'DPAQUESTION')
                {
                	mpCodes.put(ref.Sequence__c+ref.Name, ref);
      				System.debug(LoggingLevel.INFO,'*** dpaQuestions: ref added to map in key:'+ref.Sequence__c+ref.Name+', ref:'+ref);
				}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {
            SelectOption newOpt = new SelectOption(mpCodes.get(s).Name, mpCodes.get(s).Value__c);
            newOpt.setEscapeItem(false);
            opt.add(newOpt);
      		System.debug(LoggingLevel.INFO,'*** dpaQuestions: creating select option:'+newOpt);
        }
        return opt;
    }
	//
    // Eligibility properties
    //
	public String renderEligible {
		get {
			if(renderEligible==null) renderEligible='no';
			return renderEligible;
		}
		set;
	}
	public Boolean ftuButton {get; set;}
	public Boolean proceedButton {get; set;}
	public String proceedMessage {get; set;}
	public String eligibleMessage {get; set;}
	public String eligibleErrorMessage {get; set;}
	public String leasedMessage {get; set;}
	public Boolean isEligibleInfoDisplay {get; set;}

	public String nextUpgradeDateHasPassedDsp {get; set;}
	public Date upgradeAvailableDateDsp {get; set;}
	public String upgradeAvailableDateMsgDsp {get; set;}
	public Double earlyUpgradeFeeDsp {get; set;}
	public boolean isEarlyUpgradeFeeDsp {get; set;}
	public Date nextUpgradeDateDsp {get; set;}
    public Integer remainingMonthsDsp {get; set;}
    public Double amountOverdueDsp {get; set;}

	public String accountNumberDsp {get; set;}
    public String salesAccountCodeDsp {get; set;}
    public String salesAccountCategoryDsp {get; set;}
    public String tariffCodeDsp {get; set;}
    public String tariffDescriptionDsp {get; set;}
    public String tariffTypeDsp {get; set;}
	public Date connectedDateDsp {get; set;}
	public Date contractStartDateDsp {get; set;}
	public Integer termOfContractDsp {get; set;}
	public Double monthlyLineRentalFeeDsp {get; set;}
	public String companyNameDsp {get; set;}
	public String isFranchiseDsp {get; set;}
	public String isMidTermUpgradeDsp {get; set;}
	public String isLeasedDeviceDsp {get; set;}

    //--------------------------------------------------------------------------
    // Properties
    //--------------------------------------------------------------------------
    private String storeSalesAccountCode;
    private String storeSalesPersonNumber;
    private String storeType;


    private Integer dpa1_count;
    private	Integer dpa2_count;

    //
    // DPA Level 2 Question and Answer storage
    public class QA {
    	public String dpaQSelection;
    	public String dpaAnswer;
    	public boolean correct;
    	public Integer incorrect_count;
    	public QA() {
    		this.correct=false;
    		this.incorrect_count=0;
    	}
    }
    public List<QA> qaList;

    //--------------------------------------------------------------------------
    // Local members
    //--------------------------------------------------------------------------
    public O2RetailChecks retailChecks;
	//--------------------------------------------------------------------------
    // Data collector
    //--------------------------------------------------------------------------
    public O2RetailUpgradeSupportMethods dataCollector {get; set;}
    //--------------------------------------------------------------------------
    // Exceptions
    //--------------------------------------------------------------------------
    public class ManUpgradeException extends Exception {}

    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------
    public O2RetailUpgradeController() {
    	//
    	// Create customer type map
    	//
    	customerTypeMap = new Map<String, String>();
    	customerTypeMap.put(O2RetailChecks.DIRECT, CUSTOMER_TYPE_O2);
    	customerTypeMap.put(O2RetailChecks.FRANCHISE, CUSTOMER_TYPE_FRANCHISE);
    	customerTypeMap.put(O2RetailChecks.PARTNER, CUSTOMER_TYPE_PARTNER);
        String context = ApexPages.currentPage().getParameters().get(PHONE_NUMBER_PARAMETER);
		//
		// Get URL paramters
		//
        System.debug('### OUTPUT >>>>> O2RetailUpgradeController: constructor: context: '+context);
        if (context!=null && context.contains('|')) {
            String[] arParams = context.split('\\|');
            System.debug('### OUTPUT >>>>> O2RetailUpgradeController: constructor: arParams: '+arParams);
            if (arParams.size()>0) {
                mobilePhoneNumber = arParams[0];
                storeCode = arParams[1];
                storeName= arParams[2];
                //
                // Lookup reference table values
                O2_Retail_Store_Mapping__c rsm=retailCodes.get(storeCode);
                if(rsm!=null) {
                	storeSalesPersonNumber=rsm.Salesperson_Number__c;
                	storeSalesAccountCode=rsm.Sales_Account_Number__c;
                	storeType=rsm.Type__c;
                	if(storeType.toLowerCase().equals('direct')) {
                		storeType=O2RetailChecks.DIRECT;
                	}
                	if(storeType.toLowerCase().equals('franchise')) {
                		storeType=O2RetailChecks.FRANCHISE;
                	}
                }
                system.debug('***refTable storeCode:'+storeCode+' SalesAccountCode:'+storeSalesAccountCode+' Store Type:'+storeType);
            }
        }
        dataCollector = new O2RetailUpgradeSupportMethods();
        retailChecks = new O2RetailChecks();
        //
        // Check if mobile phone number is retrieved
        // If it is not retrieved on page is shown link to reporting
        //
        if (mobilePhoneNumber != null
        	&& mobilePhoneNumber.trim().length() > 0)
        {
        	isPhoneNumberRetrieved = true;
        }
        else
        {
        	isPhoneNumberRetrieved = false;
        }
        //
        // Retail checks needs to have data from data collector
        //
        retailChecks.storeCode = storeCode;
        retailChecks.dataCollector = dataCollector;
        retailChecks.newSalesAccountCode = storeSalesAccountCode;
        retailChecks.newSalesPersonNumber = storeSalesPersonNumber;
		//
		// Retail checks needs custom setting values
		retailChecks.retailNameValueMap=retailNameValueMap;
		//
        System.debug('### OUTPUT >>>>> O2RetailUpgradeController: constructor: mobilePhoneNumber: '+mobilePhoneNumber+' - storeCode:'+storeCode+' - sosCode:'+storeName);
    }

    //--------------------------------------------------------------------------
    // Initialize controller state
    //--------------------------------------------------------------------------
    public void initController()
    {
        errorMessage = null;
        errorMessageDPA1=null;
        errorMessageDPA2=null;
        checkSucceeded = false;
        forgotPin = false;
        checkDPA1Succeeded=false;
        checkDPA2Succeeded=false;
        isPinAvailable=false;
        proceedToDPA2=false;
        dpa1_count=0;
        dpa2TryAgain=true;
        dpa2LevelFail=false;
        dpa2_count=0;
        qaList=new List<QA>();
		qaList.add(new QA());
		qaList.add(new QA());
		qaList.add(new QA());
		proceedButton=false;
		proceedMessage=null;
		isEligibleInfoDisplay=false;
		placingOrderStep = 0;
		isConfigurationValidated = false;
    }

    //--------------------------------------------------------------------------
    // Format bolton for summary and contract pages
    //--------------------------------------------------------------------------
    private static String formatBolton(O2_DISE_Map_Mobile_Bolton__c bolton)
    {
    	if (bolton != null
    		&& bolton.Name != null)
    	{
    		String returnValue = bolton.Name;
    		if (bolton.Price__c != null)
    		{
   				returnValue += ' (' + formatPrice(bolton.Price__c) + ')';
    		}
    		return returnValue;
    	}
    	else
    	{
    		return '-';
    	}
    }

    //--------------------------------------------------------------------------
    // Format price for in format £###.##
    //--------------------------------------------------------------------------
    public static String formatPrice(Decimal value)
    {
    	//
    	// Check if value exists
    	//
    	if (value != null)
    	{
    		String price = value.format();
    		Integer dotIndex = price.indexOf(DECIMAL_SEPARATOR);
    		if (dotIndex == -1)
    		{
	    		//
	    		// If there is no dot add '.' and zeros
	    		//
    			price += '.';
    			Integer trailingZeros = PRICE_CHARS_AFTER_DOT;
    			while (trailingZeros-- > 0)
    			{
    				price += '0';
    			}
    		}
    		else
    		{
    			if (dotIndex == 0)
	    		{
	    			//
	    			// Add '0' in the begging
	    			//
	    			price = '0' + price;
	    		}
    			//
    			// Add zeroes if needed
    			//
    			Integer trailingChars = price.length() - dotIndex - 1;
    			Integer trailingZeros = PRICE_CHARS_AFTER_DOT - trailingChars;

    			while (trailingZeros-- > 0)
    			{
					price += '0';
    			}
    		}
    		return '£' + price;
    	}
    	//
    	// If value doesn't exist
    	//
    	else
    	{
    		return '-';
    	}
    }

    //--------------------------------------------------------------------------
    // Appending to address
    //--------------------------------------------------------------------------
    private static String appendAddress(String address)
    {
    	if (address != null
    		&& address.trim().length() > 0)
    	{
    		return '<br>' + address.trim();
    	}
    	else
    	{
    		return '';
    	}
    }

	//--------------------------------------------------------------------------
	// Appending to address list
	//--------------------------------------------------------------------------
	private static void appendAddressList
	(
		List<String> addressList,
		String addressLine
	)
	{
		//
		// Check if list exists
		//
		if (addressList != null)
		{
			//
			// Check if address line is not empty
			//
			if (addressLine != null
				&& addressLine.trim().length() > 0)
			{
				addressList.add(addressLine);
			}
		}
	}

    //--------------------------------------------------------------------------
	// Add name to contact name
	//--------------------------------------------------------------------------
	private static String addToName(String name)
	{
		if (name != null
			&& name.trim().length() > 0)
		{
			return name.trim() + ' ';
		}
		return '';
	}

    //--------------------------------------------------------------------------
    // Gets bolton price
    //--------------------------------------------------------------------------
    private static Decimal getBoltonPrice(O2_DISE_Map_Mobile_Bolton__c bolton)
    {
    	if (bolton != null
    		&& bolton.Price__c != null)
    	{
    		return bolton.Price__c;
    	}
    	else
    	{
    		return Decimal.valueOf(0);
    	}
    }

    //--------------------------------------------------------------------------
    // Check mobile phone number and retrieves customer details
    //--------------------------------------------------------------------------
    public void checkMobilePhoneNumber()
    {
        //
        // Restore initial state
        //
        initController();
        //
        // Call SOA services
        //
        System.debug('O2RetailUpgradeController.checkMobilePhoneNumber BEGIN');
        //
        // Retrieve customer details
        //
        String customerType = retailChecks.retrieveCustomerDetails(mobilePhoneNumber);
        createErrorMessage(customerType);
        //
        // If error message should be displayed
        //
        if (errorMessage == null)
        {
            //
            // If there is no error message
            //
            checkSucceeded = true;
            dpaCheckAccountDetails();
        }
        System.debug('O2RetailUpgradeController.checkMobilePhoneNumber END');
    }
    //--------------------------------------------------------------------------
    // DPA Level 2: Preparation for questions - get data to answer questions
    // Note: errors are just logged here, as we don't know yet which data will answer the user inputs
    //--------------------------------------------------------------------------
	public void dpa2PrepForQuestions() {
		boolean buildDPA2QuestionsSucceeded=false;
		String result;
		//
		// Get Bank details
		result=retailChecks.retrieveAccountPaymentDetails(retailChecks.accountNumber);
        if (checkResultError(result)) {
        	system.debug('Error: retrieveAccountPaymentDetails with account number:'+retailChecks.accountNumber);
        }
		//
		// Get Customer payment
		result=retailChecks.retrieveCustomerTransactions(retailChecks.accountNumber, 'PAYMENT', 'POSTED_ALL', 1);
        if (checkResultError(result)) {
        	system.debug('Error: retrieveCustomerTransactions PAYMENT with account number:'+retailChecks.accountNumber);
        }
		//
		// Get Customer invoice
		result=retailChecks.retrieveCustomerTransactions(retailChecks.accountNumber, 'INVOICE', 'POSTED_ALL', 1);
        if (checkResultError(result)) {
			system.debug('Error: retrieveCustomerTransactions INVOICE with account number:'+retailChecks.accountNumber);
        }
		//
		// If necessary get subscription details if they haven't been fetched already
		if(retailChecks.monthlyLineRentalFee==null) {
			system.debug('***retrieveCustomerDetails with mobilePhoneNumber'+mobilePhoneNumber);
			result=retailChecks.retrieveCustomerDetails(mobilePhoneNumber);
	        if (checkResultError(result)) {
				system.debug('Error: retrieveCustomerDetails mobile phone number:'+mobilePhoneNumber);
	        }
		}
	}

	public PageReference doNothing() {
		return null;
	}

    //--------------------------------------------------------------------------
    // DPA Level 2: Check question answers before proceeding
    //--------------------------------------------------------------------------
    public void checkDPA2() {
    	System.debug('O2RetailUpgradeController.checkDPA2 START');

		Integer correct_count=0;
		dpa2LevelFail=false;
		dpa2TryAgain=true;
		//
		// Load and questions and answers into array for easier processing
    	qaList[0].dpaQSelection=dpa2Q1Selection;
    	qaList[0].dpaAnswer=dpa2Answer1;
    	qaList[1].dpaQSelection=dpa2Q2Selection;
    	qaList[1].dpaAnswer=dpa2Answer2;
    	qaList[2].dpaQSelection=dpa2Q3Selection;
    	qaList[2].dpaAnswer=dpa2Answer3;
    	//
		// Get input answers for correctness
    	for(Integer idx=0; idx<qaList.size(); idx++) {
    		String ans=qaList[idx].dpaAnswer.replaceAll(' ','');
    		ans=ans.replaceAll('/','');
    		system.debug('***answer cleaned:'+ans);

    		if(qaList[idx].dpaQSelection=='dpaQ1') {
    			qaList[idx].correct=retailChecks.validateBankDetails(ans);
    		}
    		if(qaList[idx].dpaQSelection=='dpaQ2') {
    			qaList[idx].correct=retailChecks.validateLastPaymentDate(ans);
    		}
    		if(qaList[idx].dpaQSelection=='dpaQ3') {
    			qaList[idx].correct=retailChecks.validateLastInvoiceDate(ans);
    		}
    		if(qaList[idx].dpaQSelection=='dpaQ4') {
    			qaList[idx].correct=retailChecks.validateLastInvoiceAmount(ans);
    		}
    		if(qaList[idx].dpaQSelection=='dpaQ5') {
    			qaList[idx].correct=retailChecks.validateLineRentalAmount(ans);
    		}
    		system.debug('***dpa2 question/answer: '+qaList[idx]);
			//
    		// Check answer and update counts
    		if(qaList[idx].correct) {
    				correct_count++;
    		} else {
    			qaList[idx].incorrect_count++;
    		}
    		system.debug('***dpa2 question/answer with counts: '+qaList[idx]);
    	}
    	//
		// Success! goto next page
		if(correct_count>=Integer.valueOf(retailNameValueMap.get('DPA2_MIN_CORRECT_QUESTIONS')))	{
			checkDPA2Succeeded=true;
			dpa2TryAgain=false;
			errorMessageDPA2='';
        	System.debug('O2RetailUpgradeController.checkDPA2 END - PASS');
		} else {
			dpa2_count++;
	    	//
	    	// 3 attempts at all questions are wrong - level 2 fail
			if(dpa2_count>=Integer.valueOf(retailNameValueMap.get('DPA2_MAX_ATTEMPTS')) || dpa2LevelFail) {
				dpa2LevelFail=true;
				dpa2TryAgain=false;
				errorMessageDPA2=retailNameValueMap.get('DPA2_FAILURE');
				System.debug('O2RetailUpgradeController.checkDPA2 END - 3 ATTEMPTS FAILURE');
			}
		}
		//
		// check try again
		if(dpa2TryAgain) {
			errorMessageDPA2=retailNameValueMap.get('DPA2_TRY_AGAIN');
		}
		System.debug('O2RetailUpgradeController.checkDPA2 END - '+ errorMessageDPA2);
    }

    //--------------------------------------------------------------------------
    // DPA Level 1: Preparation - get pin/password
    //--------------------------------------------------------------------------
    public void dpaCheckAccountDetails() {
        String result=retailChecks.retrieveAccountDetails(retailChecks.accountNumber);

    	if (checkResultError(result)) {
        	checkSucceeded=false;
            return;
    	}
        if(result!=null && result!='') {
            passwordCharacters=result;
        }
    }
    //--------------------------------------------------------------------------
    // DPA Level 1: Check inputs before proceeding with checks
    //--------------------------------------------------------------------------
    public void checkDPA1() {
    	System.debug('O2RetailUpgradeController.checkDPA1 START');
    	if(forgotPin)
    		proceedToDPA2=true;	// exit to DPA level 2
    	else
    		doDPA1Check();
    	//
    	// If for DPA level 2 - Load question answers by SOA calls
    	if(proceedToDPA2)
	    	dpa2PrepForQuestions();

    	System.debug('O2RetailUpgradeController.checkDPA1 END');
    }
    //--------------------------------------------------------------------------
    // DPA Levels: Page call to Configuration page
    //--------------------------------------------------------------------------
    public PageReference gotoConfigPage() {
		return Page.O2RetailUpgradeConfiguration;
    }
    //--------------------------------------------------------------------------
    // DPA Level 1: Checks for pin/password
    //--------------------------------------------------------------------------
    private void doDPA1Check() {
    	//
    	// Get input password characters
    	//
    	boolean isPWChars=false;
    	List<String> inps=new List<String>();
    	for(InputChar ic : pwInCharList) {
    		if(ic.pwInChar=='--') {
    			// any characters not there then quit
    			isPWChars=true;
    			break;
    		} else {
				inps.add(ic.pwInChar);
			}
    	}
		//
    	// Do either Password check or PIN check, not both
    	//
    	boolean pinOrPasswordValid=false;
    	if(!isPWChars) {
			pinOrPasswordValid=retailChecks.validatePassword(inps);
		} else {
			if(pin!=null && pin !='')
				pinOrPasswordValid=retailChecks.validatePIN(pin);
		}
		system.debug('***pinOrPasswordValid:'+pinOrPasswordValid);
        //
        // If error message should be displayed
        //
        if (pinOrPasswordValid)
        {
            //
            // If there is no error message
            //
            checkDPA1Succeeded = true;
        } else {
        	//
        	// Check 3 strikes rule
        	dpa1_count++;
        	if(dpa1_count>=Integer.valueOf(retailNameValueMap.get('DPA1_MAX_ATTEMPTS')))
    			proceedToDPA2=true;	// exit to DPA level 2
        	else
        		errorMessageDPA1 =retailNameValueMap.get('DPA1_PASSWORD_INVALID');
        }
    }

    //--------------------------------------------------------------------------
    // Create error message if customer type requires it
    // Returns
    //	 - true if error message is created
    //   - false if we can continue with process
    //--------------------------------------------------------------------------
    private void createErrorMessage(String customerType)
    {
        // Disconnected customer
        if (customerType == O2RetailChecks.DISCONNECTED_CUSTOMER)
        {
            errorMessage = getMessage('NOT_ACTIVE_USER');
        }
        // Non O2 customer
        else if (customerType == O2RetailChecks.NON_O2)
        {
        	// Message #1
            errorMessage = getMessage('NON_O2_MESSAGE');
        }
        // Account managed
        else if (customerType == O2RetailChecks.ACCOUNT_MANAGED)
        {
        	// Message #2
            errorMessage = getMessage('ACCOUNT_MANAGED_MESSAGE');
        }
        // Partner
        else if (customerType == O2RetailChecks.PARTNER)
        {
        	// Message #3
            errorMessage = getMessage('PARTNER_MESSAGE');
        }
        // VIP
        else if (customerType == O2RetailChecks.VIP)
        {
        	// Message #4
            errorMessage = getMessage('VIP_MESSAGE');
        }
        // Unknown
        else if (customerType == O2RetailChecks.UNKNOWN)
        {
            errorMessage = getMessage('UNKNOWN_MESSAGE');
        }
        // Service error
        else if (customerType == O2RetailChecks.SERVICE_ERROR)
        {
            errorMessage = getMessage('SERVICE_ERROR_MESSAGE');
        }
        // Wrong phone number
        else if (customerType == O2RetailChecks.WRONG_PHONE_NUMBER)
        {
            errorMessage = getMessage('WRONG_PHONE_NUMBER_MESSAGE');
        }
        // Franchise
        else if (customerType == O2RetailChecks.FRANCHISE)
        {
            errorMessage = null;
        }
        // Direct
        else if (customerType == O2RetailChecks.DIRECT)
        {
            errorMessage = null;
        }
        else if (customerType == O2RetailChecks.SUCCESS)
        {
        	errorMessage = null;
        }
        else
        {
            errorMessage = getMessage('SERVICE_ERROR_MESSAGE');
        }
    }
    //--------------------------------------------------------------------------
    // Create error message if result requires it
    // Returns
    //	 - true if error message is created
    //   - false if we can continue with process
    //--------------------------------------------------------------------------
    private boolean checkResultError(String result)
    {
        // Non O2 customer
        if (result == O2RetailChecks.SUCCESS)
        {
            errorMessage = null;
        }
        // Service error
        else if (result == O2RetailChecks.SERVICE_ERROR)
        {
            errorMessage = getMessage('SERVICE_ERROR_MESSAGE');
        }
        else
        	errorMessage = null;

        if(errorMessage!=null)
        	return true;
        else
        	return false;
    }

    //--------------------------------------------------------------------------
	// Eligibility checks and results display
    //--------------------------------------------------------------------------
	public void checkEligibility() {
		//
		// initialise values
		renderEligible='yes';
		eligibleErrorMessage=null;
		eligibleMessage=null;
		upgradeAvailableDateDsp=null;
		upgradeAvailableDateMsgDsp=null;
		leasedMessage=null;
		proceedButton=false;
		proceedMessage=null;
		earlyUpgradeFeeDsp=null;
		isEarlyUpgradeFeeDsp=false;
		ftuButton=false;
		isEligibleInfoDisplay=false;
		//
		// carry out eligibility steps
		Map<String, Object> results=retailChecks.establishEligibility(storeSalesPersonNumber, storeType);
		system.debug('***establishEligibility results:'+results);
		//
		// set error message
		eligibleErrorMessage=(String)results.get('error');
		eligibleMessage=(String)results.get('message');
		if(eligibleMessage==null) {
			system.debug('***eligible message is null');
			eligibleMessage='';
		}
		//
		// set leased message and leased device
		leasedMessage=(String)results.get('leased');
		if(leasedMessage!=null) {
			isLeasedDeviceDsp='Yes';
			system.debug('***eligible message append leasedMessage: '+leasedMessage);
			eligibleMessage=eligibleMessage+' '+ leasedMessage;
		} else {
			isLeasedDeviceDsp='No';
		}
		//
		// check if eligible information should be set and displayed, i.e. not endProcess
		if((String)results.get('endProcess')==null) {
			isEligibleInfoDisplay=true;
		}
		//
		// set if next upgrade date has passed
		nextUpgradeDateHasPassedDsp=(String)results.get('nextUpgradeDateHasPassed');
		if(nextUpgradeDateHasPassedDsp==null) nextUpgradeDateHasPassedDsp='no';
		//
		// set upgrade available information
		upgradeAvailableDateDsp=retailChecks.upgradeAvailableDate;
		//
		// set upgrade available message if required
		upgradeAvailableDateMsgDsp=(String)results.get('upgradeAvailableDateMsg');
		if(upgradeAvailableDateMsgDsp!=null) {
			//
			// Note: if not null date value is appended in page
			eligibleMessage= eligibleMessage+' '+upgradeAvailableDateMsgDsp+' ';
		}
		//
		// Set and display eligible items - steps 13,13a,13b
		if(isEligibleInfoDisplay) {
			//
			// set SIM message - step 13a and 13b
			String simMessage=(String)results.get('messageSIM');
			if(simMessage!=null) {
				system.debug('***eligible message append simMessage: '+simMessage);
				eligibleMessage=eligibleMessage+' '+ simMessage;
			}
			//
			// set Best Plan Advice message
			String bestPlanAdvice=(String)results.get('checkCustTariffReminder');
			if(bestPlanAdvice!=null) {
				system.debug('***eligible message append bestPlanAdvice: '+bestPlanAdvice);
				eligibleMessage=eligibleMessage+' '+ bestPlanAdvice;
			}
			//
			// set display fields
			accountNumberDsp=retailChecks.accountNumber;
			salesAccountCodeDsp=retailChecks.salesAccountCode;//==null ? ' ' : retailChecks.salesAccountCode;
			salesAccountCategoryDsp=retailChecks.salesAccountCategory;//==null ? ' ' : retailChecks.salesAccountCategory;
			tariffCodeDsp=retailChecks.tariffCode;//==null ? '' : retailChecks.tariffCode;
			tariffDescriptionDsp=retailChecks.tariffDescription;//==null ? '' : retailChecks.tariffDescription;
			tariffTypeDsp=retailChecks.tariffType;//==null ? '' : retailChecks.tariffType;
			connectedDateDsp=retailChecks.connectedDate;
			contractStartDateDsp=retailChecks.contractStartDate;
			termOfContractDsp=retailChecks.termOfContract;
			monthlyLineRentalFeeDsp=retailChecks.monthlyLineRentalFee==null ? null : (Double)retailChecks.monthlyLineRentalFee/100;
			companyNameDsp=retailChecks.companyName;
			if(retailChecks.isFranchise!=null && retailChecks.isFranchise) {
				isFranchiseDsp='Yes';
			} else {
				isFranchiseDsp='No';
			}
			nextUpgradeDateDsp=retailChecks.nextUpgradeDate;
			if(nextUpgradeDateHasPassedDsp!='yes') {
				earlyUpgradeFeeDsp=retailChecks.earlyUpgradeFee==null ? null : (Double)retailChecks.earlyUpgradeFee/100;
				if(earlyUpgradeFeeDsp!=null) isEarlyUpgradeFeeDsp=true;
			} else {
				earlyUpgradeFeeDsp=null;
				upgradeAvailableDateDsp=null;
			}
			remainingMonthsDsp=retailChecks.remainingMonths;
			amountOverdueDsp=retailChecks.amountOverdue;
			//
			// set mid-term flag - step 13a and step 10
			if(retailChecks.isMidTermUpgrade || retailChecks.isSimOnlyMidTerm) {
				isMidTermUpgradeDsp='Yes';
			} else {
				isMidTermUpgradeDsp='No';
			}
			//
			// if eligible info dislayed then proceed button enabled
			proceedButton=true;
			proceedMessage=(String)results.get('proceedMessage');
			system.debug('***proceedMessage'+proceedMessage);
		}
	}

    /***************************************************************************
    ** KK: VF functionality
    ***************************************************************************/

    public Account clientAcc {get; set;}
    public Contact clientCon {get; set;}
    public Id oppId {get; set;}
    public String pageMessage {get; set;}
    public boolean pageEdit = false;
    public boolean firstRender = true;
    public boolean acceptTerms {get;set;}

	//--------------------------------------------------------------------------
	// On cancel config, close session and remove and delete products
	// from basket.
	// User session and basket record stay in system.
	//--------------------------------------------------------------------------

    public PageReference cancelConfiguration()
    {
    	if(dataCollector.basketController.maincontroller.apiSession != null || dataCollector.basketController.maincontroller.newAPISession != null)
    	{
			dataCollector.emptyBasket();
			dataCollector.closeSession();
    	}
    	return Page.O2RetailUpgradeCancel;
    }

    public PageReference closeSession()
    {
    	dataCollector.closeSession();
    	return Page.O2RetailUpgradeCancel;
    }

	//--------------------------------------------------------------------------
	// Validates SIM and IMEI numbers
	// SIM is needed only when SIM swap is selected and IMEI when HS selection
	// is choosen.
	//--------------------------------------------------------------------------
    public PageReference validateConfiguration()
    {
    	pageMessage = null;
    	if((dataCollector.upgradeType == O2RetailUpgradeSupportMethods.UPGRADETYPE1 && dataCollector.deviceId == null)
    		|| (dataCollector.upgradeType == O2RetailUpgradeSupportMethods.UPGRADETYPE2 && (dataCollector.chooseSIMOnly == null || dataCollector.chooseSIMOnly == '')))
    	{
    		pageMessage = 'You must select a device';
    		isConfigurationValidated = false;
    		return null;
    	}
    	if(!dataCollector.validateIMEInumber())	// IMEI not needed for sim only
    	{
    		//pageEdit = true;	// to set selected values correctly
    		pageMessage = 'IMEI number missing or incorrect';
    		isConfigurationValidated = false;
    		return null;
    	}
    	if(dataCollector.tariffId == null)
    	{
    		pageMessage = 'You must select a tariff';
    		isConfigurationValidated = false;
    		return null;
    	}
    	if(dataCollector.SIMswap && !dataCollector.validateSIMnumber())
    	{
    		//pageEdit = true;	// to set selected values correctly
    		pageMessage = 'SIM number missing or incorrect';
    		isConfigurationValidated = false;
    		return null;
    	}
    	isConfigurationValidated = true;
    	return null;
    }

	//--------------------------------------------------------------------------
	// Sort out collected data and create basket.
	// Put product in basket.
	//--------------------------------------------------------------------------
    public pageReference proceedConfiguration()
    {
    	pageEdit = false;
    	acceptTerms = false;
    	firstRender = false;
    	pageMessage = null;
    	if(!dataCollector.SIMswap && dataCollector.SIMnumber != null) dataCollector.SIMnumber = null; // not needed
    	dataCollector.proceedData();
    	dataCollector.createBasket();
    	return Page.O2RetailUpgradeSummary;
    }

	//--------------------------------------------------------------------------
	// Edit details returns from summary to configuration page
	//--------------------------------------------------------------------------
    public pageReference editDetails()
    {
    	pageEdit = true;
    	String deviceId = dataCollector.deviceId;
    	String tariffId = dataCollector.tariffId;
    	String dataBoltonId = dataCollector.dataBoltonId;
    	String minsBoltonId = dataCollector.minsBoltonId;
    	String faveBoltonId = dataCollector.faveBoltonId;
    	String chooseSIMOnly = dataCollector.chooseSIMOnly;

    	dataCollector.emptyBasket();
    	dataCollector.retrieveMobileDevices();
    	dataCollector.deviceId = deviceId;
    	dataCollector.retrieveMobileTariffs();
    	dataCollector.tariffId = tariffId;
    	dataCollector.setMobileTariffBoltonsSO();
    	dataCollector.chooseSIMOnly = chooseSIMOnly;

    	dataCollector.dataBoltonId = dataBoltonId;
    	dataCollector.minsBoltonId = minsBoltonId;
    	dataCollector.faveBoltonId = faveBoltonId;
    	isConfigurationValidated = false;
    	return Page.O2RetailUpgradeConfiguration;
    }

    public void resetValuesOnUpgradeChange()
    {
    	dataCollector.deviceId = null;
    	dataCollector.thisDevice = null;
    	dataCollector.tariffId = null;
    	dataCollector.thisTariff = null;
    	dataCollector.dataBoltonId = null;
    	dataCollector.thisDataBolton = null;
    	dataCollector.faveBoltonId = null;
    	dataCollector.thisFaveBolton = null;
    	dataCollector.minsBoltonId = null;
    	dataCollector.thisMinsBolton = null;
    	dataCollector.chooseSIMOnly = null;
    	dataCollector.IMEInumber = null;
    	dataCollector.addInsurance = false;
    	dataCollector.SIMswap = false;
    	dataCollector.SIMnumber = null;
    	pageMessage = null;
    	dataCollector.refreshDevices();
    }

    public boolean getTariffsAvailable()
    {
    	// we can't find tariffs if handset is not selected
    	return (dataCollector.upgradeType == O2RetailUpgradeSupportMethods.UPGRADETYPE1 && dataCollector.deviceId != null)
    			|| (dataCollector.upgradeType == O2RetailUpgradeSupportMethods.UPGRADETYPE2 && dataCollector.chooseSIMOnly != null && dataCollector.chooseSIMOnly != '');
    }

    public boolean getBoltonsAvailable()
    {
    	// we can't find boltons if tariff is not selected
    	return dataCollector.tariffId != null;
    }

    public String getExitPageEdit()
    {
    	pageEdit = false;
    	return '';
    }

    public boolean getFirstRender()
    {
    	return firstRender;
    }

    public List<Selectoption> getSO_MobileDevices()
    {
    	Id deviceId = pageEdit ? dataCollector.deviceId : null;
    	return dataCollector.getMobileDevicesSO(deviceId);
    }

    public List<Selectoption> getSO_MobileTariffs()
    {
    	Id tariffId = pageEdit ? dataCollector.tariffId : null;
    	List<Selectoption> soL = dataCollector.getMobileDeviceTariffsSO(tariffId, retailChecks.tariffCode, retailChecks.packageCode);
    	//pageEdit = false;
    	return soL;
    }

    public List<Selectoption> getSO_SIMOnlyCombos()
    {
    	String selectSIM = pageEdit ? dataCollector.chooseSIMOnly : null;
    	return dataCollector.getSIMOnlyCombosSO(selectSim);
    }

    public void refreshTariffs()
    {
    	dataCollector.refreshTariffs(retailChecks.tariffCode,retailChecks.packageCode);
    }

	//--------------------------------------------------------------------------
	// Retrieve account and contact from database, or create new.
	//--------------------------------------------------------------------------
    public void processClient()
    {
    	// account bit
    	Map<String,Object> accFieldMap = new Map<String,Object>();
    	String name;
    	//
    	// Check for company name. If it exists use it for name
    	// otherwise use the contactName.
    	//
    	if (retailChecks.companyName != null)
    	{
    		name = retailChecks.companyName;
    	}
    	else
    	{
    		name = getContactName();
    	}
   		accFieldMap.put('Name',(object) name);
    	accFieldMap.put('OwnerId',(object) retailNameValueMap.get('RETAIL UPGRADE OWNER'));

    	clientAcc = O2RetailUpgradeSupportMethods.resolveAccount(retailChecks.accountNumber, accFieldMap);

    	// contact bit
    	Map<String,Object> conFieldMap = new Map<String,Object>();
    	if(retailChecks.contactFirstName != null) 				conFieldMap.put('FirstName',(object) retailChecks.contactFirstName);
    	if(retailChecks.contactLastName != null) 				conFieldMap.put('LastName',(object) retailChecks.contactLastName);
    	else													conFieldMap.put('LastName',(object) retailChecks.companyName);
    	if(retailChecks.contactTitle != null) 					conFieldMap.put('Salutation',(object) retailChecks.contactTitle);
    	if(retailChecks.contactOccupation != null) 				conFieldMap.put('Title',(object) retailChecks.contactOccupation);
    	if(retailChecks.emailAddress != null && Pattern.matches('^([\\w-]+(?:\\.[\\w-]+)*)@((?:[\\w-]+\\.)*\\w[\\w-]{0,66})\\.([a-z]{2,6}(?:\\.[a-z]{2})?)$', retailChecks.emailAddress)) conFieldMap.put('Email',(object) retailChecks.emailAddress);
    	if(retailChecks.contactDateOfBirth != null) 			conFieldMap.put('Date_of_Birth__c',(object) retailChecks.contactDateOfBirth);

    	if(retailChecks.contactTelephoneNumber != null
    		&& retailChecks.contactTelephoneNumber.isNumericSpace())		conFieldMap.put('Phone',(object) retailChecks.contactTelephoneNumber);
    	if(retailChecks.contactOtherTelephoneNumber != null
    		&& retailChecks.contactOtherTelephoneNumber.isNumericSpace()) 	conFieldMap.put('OtherPhone',(object) retailChecks.contactOtherTelephoneNumber);
    	if(retailChecks.contactFaxNumber != null
    		&& retailChecks.contactFaxNumber.isNumericSpace()) 				conFieldMap.put('Fax',(object) retailChecks.contactFaxNumber);

    	conFieldMap.put('OwnerId',(object) retailNameValueMap.get('RETAIL UPGRADE OWNER'));

    	clientCon = O2RetailUpgradeSupportMethods.resolveContact(clientAcc.Id, retailChecks.accountNumber, conFieldMap);

    	//if we have a business address, store it in the Location object so we have the DISE address on file at the very least
		Location__c billingAddress = new Location__c();
    	if (clientAcc!=null && clientAcc.Id!=null) {
    		//check whether we already have a DISE_Billing location record and use it if yes
			List<Location__c> accountLocations = new List<Location__c>();
			accountLocations = [SELECT Id FROM Location__c WHERE Account__c = :clientAcc.Id and Type__c = 'DISE_Billing' LIMIT 1];
			if (accountLocations!=null && accountLocations.size()>0) billingAddress = accountLocations[0];
    	}
    	if (retailChecks.companyAddress1!=null || retailChecks.companyPostcode!=null) {
    		//this checks whether we have at least a street address (assumed) or postcode (assumed in last line)
    		if (retailChecks.companyAddress1!=null && retailChecks.companyAddress1!='') billingAddress.DISE_Address_Line_1__c = retailChecks.companyAddress1;
    		if (retailChecks.companyAddress2!=null && retailChecks.companyAddress2!='') billingAddress.DISE_Address_Line_2__c = retailChecks.companyAddress2;
    		if (retailChecks.companyAddress3!=null && retailChecks.companyAddress3!='') billingAddress.DISE_Address_Line_3__c = retailChecks.companyAddress3;
    		if (retailChecks.companyAddress4!=null && retailChecks.companyAddress4!='') billingAddress.DISE_Address_Line_4__c = retailChecks.companyAddress4;
    		if (retailChecks.companyAddress5!=null && retailChecks.companyAddress5!='') billingAddress.DISE_Address_Line_5__c = retailChecks.companyAddress5;
    		if (retailChecks.companyPostcode!=null && retailChecks.companyPostcode!='') billingAddress.DISE_Postcode__c = retailChecks.companyPostcode;
    	}
    	if (clientAcc!=null && clientAcc.Id!=null) {
    		//make sure the link to Account is present and preparatory fields are set correctly
    		billingAddress.Account__c = clientAcc.Id;
			billingAddress.Sync_with_Parent__c = false;
			billingAddress.Type__c='DISE_Billing';
    		upsert billingAddress;
    	}
    }

	//--------------------------------------------------------------------------
	// Placing order checkout basket created in previous step
	//--------------------------------------------------------------------------
    public pageReference placeOrder()
    {
    	pageMessage = null;
    	if(!acceptTerms)
    	{
    		pageMessage = 'Customer must accept T&C\'s!';
    		return null;
    	}

    	processClient();

    	Map<String,String> opptyFields = new Map<String,String>();
		opptyFields.put('bankBuildingSociety',null);
		opptyFields.put('bankAccountName',null);
		opptyFields.put('bankSortCode',retailchecks.getBankSortCode());
		opptyFields.put('bankAccountNumber',retailchecks.getBankAccountNumber());
		opptyFields.put('confirmDetails',null);
		opptyFields.put('agreeTerms',null);
		opptyFields.put('ConfirmationEmailAddr',null);
		if(dataCollector.IMEInumber != null) opptyFields.put('IMEInumber',dataCollector.IMEInumber);
		if(dataCollector.SIMnumber != null) opptyFields.put('SIMnumber',dataCollector.SIMnumber);
		opptyFields.put('OwnerId',retailNameValueMap.get('RETAIL UPGRADE OWNER'));
		opptyFields.put('SIMswap',dataCollector.SIMswap ? 'true' : 'false');
		opptyFields.put('leadSource', 'O2 Retail');
		opptyFields.put('opptyType', 'Existing Business');

		if(dataCollector.basketController.maincontroller.apiSession != null)
		{
    		oppId = O2RetailUpgradeSupportMethods.bundleBasket(dataCollector.basketController.maincontroller.apiSession.getBasket(), clientAcc, clientCon, opptyFields);
    		dataCollector.closeSession();
    		//
    		// Variable for visualforce action chaining pattern
    		//
    		placingOrderStep = 1;
		}
		else
		{
			pageMessage = 'Error while placing order';
		}
		return null;
    }

    //--------------------------------------------------------------------------
    // Do back end automation after order is in place.
    // Returns confirmation page
    //--------------------------------------------------------------------------
    public PageReference doBackendAutomation()
    {
    	retailChecks.placeOrder();
    	if (retailChecks.upgradeReportId!=null && oppId!=null) {
    		List<Opportunity> updateOpptyReport = new List<Opportunity>();
    		updateOpptyReport = [SELECT Id, O2_Retail_Upgrade__c FROM Opportunity WHERE Id=:oppId LIMIT 1];
    		if (updateOpptyReport!=null && updateOpptyReport.size()>0) {
    			updateOpptyReport[0].O2_Retail_Upgrade__c = retailChecks.upgradeReportId;
    			update updateOpptyReport[0];
    		}
    	}
    	placingOrderStep = 2;
    	return null;
    }

    //--------------------------------------------------------------------------
    // Goes to confirmation page after order is placed and backautomation is
    // done
    //--------------------------------------------------------------------------
    public PageReference gotoConfirmationPage()
    {
    	return Page.O2RetailUpgradeConfirmation;
    }

	//--------------------------------------------------------------------------
	// Retrieves message from retailNameValueMap.
	// If message exists than it is return otherwise is returned
	// created error message.
	//--------------------------------------------------------------------------
	public String getMessage(String messageName)
	{
		String returnValue = retailNameValueMap.get(messageName);
		if (returnValue == null)
		{
			returnValue = messageName + ' is missing';
		}
		return returnValue;
	}
}