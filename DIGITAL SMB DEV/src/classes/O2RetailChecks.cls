public with sharing class O2RetailChecks
{
    //--------------------------------------------------------------------------
    // Constants
    //--------------------------------------------------------------------------
    private static final String O2 = 'O2';
    private static final String DISE = 'DISE';
    private static final String REV_SHARE = 'Rev share';
    private static final String BONUS = 'Bonus';
    private static final String MOBILE = 'Mobile';
    private static final String UK_COUNTRY_CODE = '44';
    private static final String REGEX_PHONE_NUMBER = '^(\\+?)([0-9]{6,15})$';
    private static final String O2_RETAIL_UPGRADE = 'O2 Retail Upgrade';
    private static final String LINE_RENTAL_CHARGE = 'LINECH';
    private static final String URN_PREFIX = 'XB';
    private static final String UPGRADE_TYPE_HARDWARE = '1';
    private static final String UPGRADE_TYPE_SIM_ONLY = '2';
    private static final String UPGRADE_STATUS = 'Complete';
    private static final String SOURCE_SYSTEM = 'Salesforce';

    //--------------------------------------------------------------------------
    // Return values
    //--------------------------------------------------------------------------
    public static final String NON_O2 = 'nonO2';
    public static final String ACCOUNT_MANAGED = 'accountManaged';
    public static final String PARTNER = 'partner';
    public static final String VIP = 'VIP';
    public static final String FRANCHISE = 'franchise';
    public static final String DIRECT = 'direct';
    public static final String UNKNOWN = 'unknown';
    public static final String SERVICE_ERROR = 'serviceError';
    public static final String WRONG_PHONE_NUMBER = 'wrongPhoneNumber';
    public static final String DISCONNECTED_CUSTOMER = 'not connected';
    public static final String SUCCESS = 'success';
    //--------------------------------------------------------------------------
    // Properties
    //--------------------------------------------------------------------------
    //
    // Pre-load name/value map from custom settings - loaded by parent controller
    public Map<String, String> retailNameValueMap;

    // Current subscription data
    public String subscriptionNumber;
    public String accountNumber;
    public String storeCode;
    public String salesAccountCode;
    public String salesAccountCategory;
    public String customerStatus;
    //----------------------------------
    // Sales account code and person number of current store
    public String newSalesAccountCode;
    public String newSalesPersonNumber;
    //----------------------------------
    // Current contract data
    public String tariffCode;
    public String tariffDescription;
    public String tariffType;
    public Date connectedDate;
    public Date contractStartDate;
    public Integer termOfContract;
    public Integer monthlyLineRentalFee;
    public String packageCode;
    //----------------------------------
    public Date newContractStartDate;
    public String companyName;
    public String companyAddress1;
    public String companyAddress2;
    public String companyAddress3;
    public String companyAddress4;
    public String companyAddress5;
    public String companyPostcode;
    public String emailAddress;
    public Boolean isFranchise;
    public String customerType;
    //----------------------------------
    // Needed for contract
    public String upgradeReferenceNumber;
    //----------------------------------
    // Needed for Blue Prism automation and reporting
    public String msisdn;
    public String newSimNumber;
    public String newImeiNumber;
    public String newTariffCode;
    public String newTariffDescription;
    public String newPackageCode;
    public String newTermOfContract;
    public String newHandsetMake;
    public String newHandsetModel;
    public String newHandsetCost;
    public String upgradeType;
    public Boolean insurance;
    public String internationalFavouritesServiceCode;
    public String additionalDataServiceCode;
    public String offPickCallsServiceCode;
    public Boolean isLeased;
    public String upgradeReportId;
    public String insuranceServiceCode;
    //properties for contact - SW CDECISIONS 10/10/12
    public String contactFirstName;
    public String contactMiddleName;
    public String contactLastName;
    public String contactTitle;
    public Date contactDateOfBirth;
    public String contactOccupation;
    public String contactTelephoneNumber;
    public String contactOtherTelephoneNumber;
    public String contactFaxNumber;

    //
    // For Eligibility checks
    public Date previousContractStartDate;
    public Integer previousContractTerm;
    public Date nextUpgradeDate;
    public Date standardUpgradeDate;
    public Integer earlyUpgradeFee;
    public Integer remainingMonths;
    public Integer amountOverdue;
    public Integer midTermUpgradeCharge;
    public String isEligible;
    public Boolean isEligibleHardWareUpgrade;
    public Boolean isSimOnlyMidTerm;
    public Boolean isSimOnlyStandardTerm;
    public Boolean isMidTermUpgrade;
    public Boolean isSubscriptionDisconnected;
    public Date upgradeAvailableDate;
    private Boolean foundAccountBalance;
    private Boolean hasExecutedAccountBalance;
    //
    // main map for storing an passing values back to parent controller
    private Map<String, Object> eligibilityResultsMap;
    //
    // DPA level 1 Data
    private List<Integer> passwordCharacterLocations;
    private String accountPassword;
    private Integer accountPin;
    //
    // DPA level 2 Data
    private String bankAccountNumber;
    private String bankSortCode;
    private Date lastInvoiceDate;
    private Date lastPaymentDate;
    private Integer lastInvoiceAmount;
    private String lastInvoiceNumber;

    //--------------------------------------------------------------------------
    // Private members
    //--------------------------------------------------------------------------
    private O2RetailUpgradeServicesInterface servicesInterface =
        new O2RetailUpgradeServicesProxy(new O2RetailUpgradeSOAPServices());
    private O2RetailUpgradeServicesUtils.ServiceErrorLog serviceErrorLog =
        new O2RetailUpgradeServicesUtils.ServiceErrorLog();

    //--------------------------------------------------------------------------
    // Public members
    //--------------------------------------------------------------------------
    public O2RetailUpgradeSupportMethods dataCollector;

    //--------------------------------------------------------------------------
    // Gets and stores the customer payment or invoice information
    // Returns:
    //  String SUCCESS or error string
    //--------------------------------------------------------------------------
    public String retrieveCustomerTransactions
    (
        String accountNumber,
        String transType,
        String transFilter,
        Integer numOfRecords
    )
    {

        String returnValue = 'no customer details'; // default return value

        Map<String, Object> resultMap =
            servicesInterface.getCustomerTransactions(accountNumber, transType,
                                                      transFilter, numOfRecords);
        //
        // Check if there is error calling the service
        //
        if (checkForError(resultMap))
        {
            //
            // Error while calling service
            //
            System.debug('O2RetailChecks.retrieveCustomerTransactions END');
            return SERVICE_ERROR;
        }
        //
        // Set customer transaction details
        //
        SOAViewBusinessCustomerTransData.transactionDetailsType[] custTrans =
            (SOAViewBusinessCustomerTransData.transactionDetailsType[])resultMap.get('custTransResponse');
        system.debug('***' + custTrans);
        if (custTrans != null && custTrans.size() > 0)
        {
            if (custTrans[0].transactionCategory == 'PAYMENT')
            {
                lastPaymentDate = custTrans[0].paymentDueOrReceivedDate;
                returnValue = 'SUCCESS';
            }
            else if (custTrans[0].transactionCategory == 'INVOICE')
            {
                lastInvoiceDate = custTrans[0].transactionDate;
                lastInvoiceAmount = custTrans[0].transactionAmount;
                lastInvoiceNumber = custTrans[0].transactionReference;
                returnValue = 'SUCCESS';
            }
        }
        // Note: validate when validating against user input
        //
        return returnValue;
    }
    //--------------------------------------------------------------------------
    // validate last payment date and last invoice date methods
    // input: String input date of DDMMYYYY
    // output: true if valid
    //--------------------------------------------------------------------------
    public Boolean validateLastPaymentDate(String input)
    {
        return validateDDMMYYYYDate(input, lastPaymentDate);
    }

    public Boolean validateLastInvoiceDate(String input)
    {
        return validateDDMMYYYYDate(input, lastInvoiceDate);
    }

    //--------------------------------------------------------------------------
    // Validate any input date
    // input: String of date characters DDMMYYYY
    //      Date to compare
    // output: true if valid
    //--------------------------------------------------------------------------
    private Boolean validateDDMMYYYYDate(String inputChars, Date storedDate)
    {
        Boolean retValue = false;
        system.debug('***validateDate:' + inputChars + ' stored:' + storedDate);
        try
        {
            if (inputChars != null
                && inputChars.length() == 8)
            {
                Integer inputDD = Integer.valueOf(inputChars.substring(0, 2));
                Integer inputMM = Integer.valueOf(inputChars.substring(2, 4));
                Integer inputYYYY = Integer.valueOf(inputChars.substring(4, 8));

                Date inputDate = Date.newInstance(inputYYYY, inputMM, inputDD);

                if (inputDate != null
                    && lastPaymentDate != null
                    && inputDate.isSameDay(storedDate))
                {
                    retValue = true;
                }
            }
        }
        catch (Exception e) {}
        return retValue;
    }
    //--------------------------------------------------------------------------
    // validate line rental amount and last invoice amount methods
    // input: String input amount
    // output: true if valid
    //--------------------------------------------------------------------------
    public Boolean validateLineRentalAmount(String input)
    {
        return validateAmount(input, monthlyLineRentalFee, 5);
    }

    public Boolean validateLastInvoiceAmount(String input)
    {
        return validateAmount(input, lastInvoiceAmount, 5);
    }

    //--------------------------------------------------------------------------
    // Validate any input amount (in pounds and pence) to a given amount (in pence!)
    // input: String amount
    //      Double amount to compare
    //      Double tolerance, e.g. 2.5% would be 2.5
    // output: true if valid
    //--------------------------------------------------------------------------
    private Boolean validateAmount
    (
        String inputChars,
        Double storedAmount,
        Double tolerancePercent
    )
    {
        Boolean retValue = false;
        system.debug('***validateAmount(pounds):' + inputChars + ' to storedAmount(pennies):' + storedAmount);
        Double inputAmount;
        try
        {
            if (inputChars != null && inputChars != '')
            {
                inputAmount = Double.valueOf(inputChars);
            }
            if (inputAmount != null && storedAmount != null)
            {
                Double storedAmountPounds = storedAmount / 100;
                Double margin = math.abs(inputAmount - storedAmountPounds);
                Double tolAmount = storedAmountPounds * (tolerancePercent / 100);
                if (tolAmount >= margin)
                {
                    retValue = true;
                }
            }
        }
        catch (Exception e) {}
        return retValue;
    }
    //--------------------------------------------------------------------------
    // Gets and stores the bank information
    // Returns:
    //  String SUCCESS or error string
    // Or empty string
    //--------------------------------------------------------------------------
    public String retrieveAccountPaymentDetails(String accountNumber)
    {

        String returnValue = '';

        String[] filter = new String[]{'PAYMENT_DETAILS'};
        Map<String, Object> resultMap = servicesInterface.getAccountDetails(accountNumber, filter);

        //
        // Check if there is error calling the service
        //
        if (checkForError(resultMap))
        {
            //
            // Error while calling service
            //
            System.debug('O2RetailChecks.retrieveAccountPaymentDetails END');
            return SERVICE_ERROR;
        }
        //
        // Set account details
        //
        bankAccountNumber = (String)resultMap.get('bankAccountNumber');
        bankSortCode = (String)resultMap.get('bankSortCode');
        //
        // validate
        //
        if (bankAccountNumber != null
            && bankAccountNumber != ''
            && bankSortCode != null
            && bankSortCode != '')
        {
            returnValue = SUCCESS;
        }
        else
        {
            returnValue = 'no bank details!';
        }

        return returnValue;
    }
    //--------------------------------------------------------------------------
    // Validate Bank Details
    // Sort Code 1st and last digits and last 3 digits of Bank Account Number
    // input: String of 5 characters
    // output: true if valid
    //--------------------------------------------------------------------------
    public Boolean validateBankDetails(String inputChars)
    {
        Boolean retValue = false;
        system.debug('***validateBankDetails inputChars:' + inputChars + ' length:' + inputChars.length());
        if (inputChars != null
            && inputChars.length() == 5
            && bankSortCode != null
            && bankAccountNumber != null
            && bankSortCode != ''
            && bankAccountNumber != '')
        {
            String inputSCodeFirst = inputChars.substring(0, 1);
            String inputSCodeLast = inputChars.substring(1, 2);
            String inputAccLast = inputChars.substring(2, 5);

            if (bankSortCode.startsWith(inputSCodeFirst)
                && bankSortCode.endsWith(inputSCodeLast)
                && bankAccountNumber.endsWith(inputAccLast))
            {
                retValue = true;
            }
        }
        return retValue;
    }

    //--------------------------------------------------------------------------
    // Gets and stores the account information and generates random character
    // locations from the account password.
    // Returns:
    //  String of password character locations, e.g. 1st, 3rd, 5th.
    // Or empty string
    //--------------------------------------------------------------------------
    public String retrieveAccountDetails(String accountNumber)
    {

        String returnLocations = '';

        String[] filter = new String[]{'CUSTOMER_DETAILS'};
        Map<String, Object> resultMap = servicesInterface.getAccountDetails(accountNumber, filter);

        //
        // Check if there is error calling the service
        //
        if (checkForError(resultMap))
        {
            //
            // Error while calling service
            //
            System.debug('O2RetailChecks.retrieveCustomerDetails END');
            return SERVICE_ERROR;
        }
        //
        // Set account details
        //
        accountPassword = (String)resultMap.get('accountPassword');
        accountPin = (Integer)resultMap.get('accountPIN');
        //
        // Validation
        if (accountPassword == null
            || accountPassword.length() < Integer.valueOf(retailNameValueMap.get('PW Characters Requested')))
        {
            return returnLocations;
        }
        //
        // Generate random character locations
        returnLocations = randomCharacterGenerator();

        return returnLocations.trim();
    }

    //--------------------------------------------------------------------------
    // Generate 3 random password character positions
    //--------------------------------------------------------------------------
    private String randomCharacterGenerator()
    {
        String returnLocations = '';
        passwordCharacterLocations = new List<Integer>();
        Set<Integer> intSet = new Set<Integer>();

        // Abstract the real password to a copy with no spaces
        // - first create map of character locations - new mapped to original positions
        Map<Integer, Integer> pwNoSpaceToRealPWMap = new Map<Integer, Integer>();
        Integer absPWidx = 0;
        for (Integer i = 0; i < accountPassword.length(); i++)
        {
            String currChar = accountPassword.substring(i, i + 1);
            if (currChar != ' ')
            {
                pwNoSpaceToRealPWMap.put(absPWidx, i);
                absPWidx++;
            }
        }
        // - now remove spaces to get password with no spaces
        String pwNoSpace = accountPassword.replaceAll(' ', '');
        //
        // Work with 'no space' password to find random characters
        while (passwordCharacterLocations.size() < Integer.valueOf(retailNameValueMap.get('PW Characters Requested')))
        {
            //Get random character position
            Integer idxLoc = (math.random() * pwNoSpace.length()).intValue();
            //Use it if we haven't had it before
            if (!intSet.contains(idxLoc))
            {
                intSet.add(idxLoc);
                //
                //get the real position in the proper password
                Integer realIdx = pwNoSpaceToRealPWMap.get(idxLoc);
                //
                //add to list
                passwordCharacterLocations.add(realIdx);
            }
        }
        //
        // Sort the order so the user is requested in ascending order
        passwordCharacterLocations.sort();
        for (Integer idx : passwordCharacterLocations)
        {
            Integer realIdx = idx + 1;  //this is zero based array location - add 1 for actual position
            if (realIdx == 1) returnLocations += realIdx + 'st ';
            if (realIdx == 2) returnLocations += realIdx + 'nd ';
            if (realIdx == 3) returnLocations += realIdx + 'rd ';
            if (realIdx > 3) returnLocations += realIdx + 'th ';
        }
        return returnLocations.trim();
    }
    //--------------------------------------------------------------------------
    // Check Account PIN is available
    //--------------------------------------------------------------------------
    public Boolean pinAvailable()
    {
        Boolean isPin;
        if (accountPin != null)
            isPin = true;
        else
            isPin = false;
        return isPin;
    }
    //--------------------------------------------------------------------------
    // Validate given password characters against password.
    // Return true if valid.
    //--------------------------------------------------------------------------
    public Boolean validatePassword(List<String> inputCharacterList)
    {
        Boolean validPassword = false;
        system.debug('***pw: ' + accountPassword + ' locations:'
                     + passwordCharacterLocations + ' vs input chars:'
                     + inputCharacterList);
        if (inputCharacterList.size() != passwordCharacterLocations.size())
        {
            return false;
        }

        for (Integer i = 0; i < inputCharacterList.size(); i++)
        {
            Integer idx = passwordCharacterLocations[i];
            String storedChar = accountPassword.substring(idx, idx + 1).toUpperCase();
            if (storedChar == null
                || inputCharacterList[i] == null
                || !storedChar.equals(inputCharacterList[i].toUpperCase()))
            {
                return false;
            }
        }
        system.debug('***pw' + accountPassword + ':'
                     + passwordCharacterLocations + ' vs input chars:'
                     + inputCharacterList);
        return true;
    }

    //--------------------------------------------------------------------------
    // Validate PIN
    // Return true if valid.
    //--------------------------------------------------------------------------
    public Boolean validatePIN(String pin)
    {
        Boolean validPin = false;
        system.debug('***account pin:' + accountPin + ' input pin: ' + pin);
        if (String.valueOf(accountPin) == pin.trim())
        {
            validPin = true;
        }
        return validPin;
    }

    //--------------------------------------------------------------------------
    // Checks if retail user is allowed to be upgraded.
    // Should be business user.
    // Return values are:
    //   accountManaged        - account is managed
    //   partner               - subscription from O2 partners
    //   VIP                   - VIP subscription
    //   franchise             - franchised O2 subscription
    //   direct                - direct O2 subscription
    //   unknown               - unknown O2 subscription
    //   serviceError          - error while calling SOA function
    //   wrongPhoneNumber      - wrong phone number
    // or Error values
    //   customerStatus        - not connected
    //--------------------------------------------------------------------------
    public String retrieveCustomerDetails(String mobilePhoneNumber)
    {
        System.debug('O2RetailChecks.retrieveCustomerDetails(' + mobilePhoneNumber + ') BEGIN');
        //
        // Clear everything from previous function call
        //
        clearMembers();
        if (mobilePhoneNumber == null  || !Pattern.matches(REGEX_PHONE_NUMBER, mobilePhoneNumber))
        {
            //
            // Write error message if mobile phone number is incorrect
            //
            System.debug('Entered mobile phone number: ' + mobilePhoneNumber + ' is incorrect');
            System.debug('O2RetailChecks.retrieveCustomerDetails END');
            return WRONG_PHONE_NUMBER;
        }
        //
        // Format msisdn
        //
        String msisdn = prepareMsisdn(mobilePhoneNumber);
        this.msisdn = msisdn;
        System.debug('MSISDN: ' + msisdn);
        //
        // Retrieve subscription details
        //
        if (!retrieveSubscriptionDetails(msisdn))
        {
            if (customerStatus!= null && customerStatus == DISCONNECTED_CUSTOMER)
            {
                return DISCONNECTED_CUSTOMER;
            }
            System.debug('returnValue: ' + SERVICE_ERROR);
            System.debug('O2RetailChecks.retrieveCustomerDetails END');
            return SERVICE_ERROR;
        }
        //
        // Get subscription type
        //
        String customerDetailsCheck = checkCustomerDetails();
        System.debug('returnValue: ' + customerDetailsCheck);
        System.debug('O2RetailChecks.retrieveCustomerDetails END');
        return customerDetailsCheck;
    }

    //--------------------------------------------------------------------------
    // Placing the retail upgrade order
    // Back end automation for retail upgrade process
    // There are five parts of automation:
    //   - sending email with tarrif and SIM change to the back office team
    //   - write record to DISE upgrade history file by calling
    //     ManageBusinessUpgrades->addUpgradeDetails
    //   - update contract details by calling ManageBusinessCustomer->
    //     updateContractDetails
    //   - create FTU payment reference by calling
    //     ManageCustomerContact_2_0->addBusinessCustomerContactEvent and
    //     ManageBusinessBoltons_2_0->addBolton twice (Torex invoicing)
    //   - send a spreadsheet to the relevant mailbox providing information
    //     which Blue Prism will use to update the tariff information in DISE
    //--------------------------------------------------------------------------
    public void placeOrder()
    {
        System.debug('O2RetailChecks.placeOrder BEGIN');
        //
        // Back end automation
        //
        prepareData();
        if (retailNameValueMap.containsKey('EnableDISEIntegration')
            && retailNameValueMap.get('EnableDISEIntegration') == 'Y')
        {
            addUpgradeDetails();
            updateContractDetails();
            createFTUPaymentReference();
        }
        //
        // Send email to the Blue Prism
        //
        if (retailNameValueMap.containsKey('EnableBluePrismIntegration')
            && retailNameValueMap.get('EnableBluePrismIntegration') == 'Y')
        {
            sendBluePrismEmail();
        }
        //
        // Save to the report table
        //
        upgradeReportId = O2RetailReports.addRetailUpgrade
        (
            storeCode,
            upgradeReferenceNumber,
            msisdn,
            companyName != null ? companyName : getContactName(),
            newSimNumber,
            newImeiNumber,
            newSalesAccountCode,
            earlyUpgradeFee,
            newTariffDescription,
            insurance,
            newHandsetMake,
            newHandsetModel,
            isLeased,
            newTariffCode,
            newTermOfContract,
            insuranceServiceCode
        );
        //
        // Log service errors
        //
        serviceErrorLog.save();
        System.debug('O2RetailChecks.placeOrder END');
    }

    //--------------------------------------------------------------------------
    // Prepare data for processing by retrieving it from data collector
    //--------------------------------------------------------------------------
    private void prepareData()
    {
        if (dataCollector != null)
        {
            //
            // New device
            //
            if (dataCollector.thisDevice != null
                && dataCollector.thisDevice.device != null)
            {
                System.debug('newDevice: ' + dataCollector.thisDevice.device);
                //
                // Handset model
                //
                newHandsetModel = dataCollector.thisDevice.device.Name;
                //
                // Handset make
                //
                if (dataCollector.thisDevice.device.Product_Code__c != null)
                {
                    newHandsetMake = dataCollector.thisDevice.device.Product_Code__r.Brand__c;
                }
            }
            //
            // Basket
            //
            if (dataCollector.basketController != null
                && dataCollector.basketController.selDevicesListNew != null
                && dataCollector.basketController.selDevicesListNew.size() > 0)
            {
                System.debug('selDevicesListNew: ' + dataCollector.basketController.selDevicesListNew);
                //
                // Handset cost
                //
                newHandsetCost = String.valueOf(dataCollector.basketController.selDevicesListNew[0].price);
            }
            //
            // Tariff
            //
            if (dataCollector.thisTariff != null
                && dataCollector.thisTariff.tariff != null)
            {
                System.debug('tariff: ' + dataCollector.thisTariff.tariff);
                newTariffDescription = dataCollector.thisTariff.tariff.Name;
                newTariffCode = dataCollector.thisTariff.tariff.Tariff_Code__c;
                newPackageCode = dataCollector.thisTariff.tariff.Package_Code__c;
                newTermOfContract = dataCollector.thisTariff.tariff.Contract_Length__c;
            }
            //
            // New SIM
            //
            if (dataCollector.SIMswap)
            {
                newSimNumber = dataCollector.SIMnumber;
            }
            //
            // IMEI
            //
            newImeiNumber = dataCollector.IMEInumber;
            //
            // Insurance
            //
            insurance = dataCollector.addInsurance;
            insuranceServiceCode = dataCollector.insuranceServiceCode;
            //
            // International Favourites
            //
            if (dataCollector.thisFaveBolton != null)
            {
                internationalFavouritesServiceCode = dataCollector.thisFaveBolton.Service_Code__c;
            }
            //
            // Additional Data
            //
            if (dataCollector.thisDataBolton != null)
            {
                additionalDataServiceCode = dataCollector.thisDataBolton.Service_Code__c;
            }
            //
            // Off Peak Calls
            //
            if (dataCollector.thisMinsBolton != null)
            {
                offPickCallsServiceCode = dataCollector.thisMinsBolton.Service_Code__c;
            }
            //
            // Upgrade type
            //
            if (dataCollector.upgradeType != null
                && dataCollector.upgradeType == O2RetailUpgradeSupportMethods.UPGRADETYPE1)
            {
                upgradeType = UPGRADE_TYPE_HARDWARE;
            }
            else
            {
                upgradeType = UPGRADE_TYPE_SIM_ONLY;
            }
        }
    }

    //--------------------------------------------------------------------------
    // Write record to DISE upgrade history file by calling
    // ManageBusinessUpgrades->addUpgradeDetails_1 SOA service
    // Date being upgraded is:
    //   - URN Prefix   Two-character alpha value, denoting customer
    //     'Spend Band' and 'Segment'. [Hard-coded value of ‘XB’].
    //   - Subscription Number
    //   - New Tariff Code
    //   - New Tariff Description
    //   - Original Connected Date
    //   - Actual Upgrade Date
    //     [Always date upgrade being processed/record added to file]
    //   - Actual Upgrade Time
    //   - New Contract Start Date
    //   - New Contract Term
    //   - Upgrade or Re-Sign Value: 1 = Upgrade  2 = Re-sign
    //     [Should always be ‘1’ for Retail Upgrades]
    //   - Next Upgrade Date
    //   - Previous Next Upgrade Date
    //   - Previous Contract Start Date
    //   - Previous Contract Term
    //   - Salesperson Code
    //   - Previous Salesperson Code
    //   - Upgrade Status In Progress/Complete/Reversed, etc
    //     [Always ‘Complete’ for Retail Upgrades]
    //   - New Device Free Form Value
    //   - Updated by SOA System User ID [Salesforce UserID]
    //   - Actual Fast Track Upgrade Fee
    //     [Only when a FTU Fee is generated, obviously]
    //--------------------------------------------------------------------------
    private void addUpgradeDetails()
    {
        System.debug('O2RetailChecks.addUpgradeDetails BEGIN');
        //
        // Fill request
        //
        Map<String, Object> request = new Map<String, Object>();
        request.put('URNPrefix', URN_PREFIX);
        request.put('subscriptionNumber', subscriptionNumber);
        request.put('msisdn', msisdn);
        Map<String, String> currentTariff = new Map<String, String>();
        currentTariff.put('tariffCode', newTariffCode);
        currentTariff.put('tariffDescription', newTariffDescription);
        request.put('currentTariff', currentTariff);
        request.put('originalConnectedDate', connectedDate);
        Datetime actualUpgradeDatetime = Datetime.now();
        request.put('actualUpgradeDate', actualUpgradeDatetime.date());
        request.put('actualUpgradeTime', formatTime(actualUpgradeDatetime.time()));
        request.put('newContractStartDate', newContractStartDate);
        request.put('newContractTerm', newTermOfContract);
        request.put('upgradeType', upgradeType);
        Date newNextUpgradeDate = newContractStartDate.addMonths(Integer.valueOf(newTermOfContract));
        request.put('nextUpgradeDate', newNextUpgradeDate);
        request.put('previousNextUpgradeDate', nextUpgradeDate);
        request.put('previousContractStartDate', contractStartDate);
        request.put('previousContractTerm', termOfContract != null ? String.valueOf(termOfContract) : null);
        request.put('salesPersonCode', newSalesPersonNumber);
        request.put('previousSalesPersonCode', salesAccountCode);
        request.put('upgradeStatus', UPGRADE_STATUS);
        request.put('sourceSystem', SOURCE_SYSTEM);
        Map<String, String> newDevice = new Map<String, String>();
        newDevice.put('make', newHandsetMake);
        newDevice.put('model', newHandsetModel);
        request.put('newDevice', newDevice);
        //
        // This field cannot be larger that 15 characters
        //
        String username = System.UserInfo.getUsername();
        if (username.length() > 15)
        {
            username = username.substring(0, 15);
        }
        request.put('processedByUserID', username);
        
        request.put('upgradeCost', earlyUpgradeFee);
        Map<String, String> response =
            servicesInterface.addUpgradeDetails(request);
        //
        // There is nothing that we can do with error at this stage
        //
        logErrorResponse(response, 'addUpgradeDetails(' + request + ')');
        //
        // Retrieve URN number from response
        //
        String urnPrefix = response.get('URNPrefix');
        String urn = response.get('URN');
        upgradeReferenceNumber = urnPrefix != null ? urnPrefix : '';
        upgradeReferenceNumber +=  urn != null ? urn : '';
        System.debug('O2RetailChecks.addUpgradeDetails END');
    }

    //--------------------------------------------------------------------------
    // Update conntract details by calling
    // ManageBusinessCustomerDetails->updateContractDetails
    //--------------------------------------------------------------------------
    private void updateContractDetails()
    {
        System.debug('O2RetailChecks.updateContractDetails BEGIN');
        Map<String, String> response =
            servicesInterface.updateContractDetails
            (
                Integer.valueOf(subscriptionNumber),
                upgradeReferenceNumber, // new contract number
                Date.today(),
                newTermOfContract
            );
        logErrorResponse
        (
            response,
            'updateContractDetails('+ subscriptionNumber + ', '
            + upgradeReferenceNumber + ', ' + Date.today() + ', '
            + newTermOfContract + ')'
        );
        System.debug('O2RetailChecks.updateContractDetails END');
    }

    //--------------------------------------------------------------------------
    // Create FTU payment reference by calling
    //   - ManageCustomerContact_2_0.addBusinessCustomerContactEvent with
    //     eventType FAST and eventCode REST
    //   - ManageBusinessBoltons_2_0.addBolton Add Dise debit service FTURET and
    //     input the value of the FTU fee
    //   - ManageBusinessBoltons_2_0.addBolton Add Dise credit service FTUPIS
    //     and input the corresponding value of the FTU fee as a credit amount
    //     to offset the debit
    //--------------------------------------------------------------------------
    private void createFTUPaymentReference()
    {
        //
        // ManageCustomerContact_2_0.addBusinessCustomerContactEvent with
        // eventType FAST and eventCode REST
        //
        Map<String, Object> request = new Map<String, Object>();
        request.put('subscriptionNumber', subscriptionNumber);
        request.put('eventType', 'FAST');
        request.put('eventCode', 'REST');
        request.put('processCommand', 'YES');
        Map<String, Object> response =
            servicesInterface.addBusinessCustomerContactEvent(request);
        logErrorResponse(response, 'createFTUPaymentReference(' + request + ')');
        //
        // Check if early upgrade fee exists and if it is greater than zero
        //
        if (earlyUpgradeFee != null && earlyUpgradeFee > 0)
        {
            //
            // ManageBusinessBoltons_2_0.addBolton Add Dise debit service
            // FTURET and input the value of the FTU fee
            //
            addBolton('FTURET', earlyUpgradeFee);
            //
            // ManageBusinessBoltons_2_0.addBolton Add Dise credit service
            // FTUPIS and input the corresponding value of the FTU fee as a
            // credit amount to offset the debit
            // Note: service price is negative value of FTU fee
            addBolton('FTUPIS', -earlyUpgradeFee);
        }
    }

    //--------------------------------------------------------------------------
    // Adds bolton to subscription number on todays date
    // Input value are:
    //  - serviceCode
    //  - servicePrice
    //--------------------------------------------------------------------------
    private void addBolton(String serviceCode, Integer servicePrice)
    {
        System.debug('O2RetailChecks.addBolton(' + serviceCode + ', ' + servicePrice + ') BEGIN');
        Map<String, String> response =
            servicesInterface.addBolton
            (
                Integer.valueOf(subscriptionNumber), // subscription number
                serviceCode,                         // service code
                Date.today(),                        // activation date
                null,                                // expiry date
                null,                                // bolton properties
                servicePrice,                        // service price
                null,                                // sales person identifier
                null                                 // description
            );
        logErrorResponse
        (
            response,
            'addBolton(' + subscriptionNumber + ', ' + serviceCode + ', '
            + Date.today() + ', ' + servicePrice + ')'
        );
        System.debug('O2RetailChecks.addBolton END');
    }

    //--------------------------------------------------------------------------
    // Send a spreadsheet to the relevant mailbox providing information
    // which Blue Prism will use to update the tariff information in DISE
    //--------------------------------------------------------------------------
    private void sendBluePrismEmail()
    {
        System.debug('O2RetailChecks.sendBluePrismEmail BEGIN');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //
        // Retrieve toAddress from custom settings
        //
        String toAddress = O2RetailUpgradeEmails__c.getValues('Blue_Prism').Email__c;
        System.debug('Sending mail to address: ' + toAddress);
        String[] toAddresses = new String[] { toAddress };
        //
        // To address
        //
        mail.setToAddresses(toAddresses);
        //
        // Sender display name
        //
        //
        // Get id of O2 Retail Upgrade organization wide email address
        // If email doesn't exist use email address of logged user
        //
        List<OrgWideEmailAddress> emails = [ select Id from OrgWideEmailAddress where DisplayName = :O2_RETAIL_UPGRADE ];
        if (emails != null && emails.size() > 0)
        {
            mail.setOrgWideEmailAddressId(emails[0].Id);
        }
        else
        {
            mail.setSenderDisplayName(O2_RETAIL_UPGRADE);
        }
        //
        // Mail subject
        //
        mail.setSubject(O2RetailUpgradeEmails__c.getValues('Blue_Prism').Subject__c);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        //
        // Create plain text body
        //
        String messageBody = createBluePrismMessageBody();
        mail.setPlainTextBody(messageBody);
        //
        // Send email
        //
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('O2RetailChecks.sendBluePrismEmail END');
    }

    //--------------------------------------------------------------------------
    // Creates Blue Prism message body
    // Information that needs to be passed to Blue Prism is:
    //   - 1. Dise Source Of Sales Code (Rep Code)
    //   - 2. Account Name
    //   - 3. Customer Mobile Number
    //   - 4. New Sim (if applicable)
    //   - 5. Tariff Code (if applicable)
    //   - 6. Package Code (if applicable)
    //   - 7. Term Of Contract (optional for Synergy)
    //   - 8. Handset Make (optional for Synergy)
    //   - 9. Handset Model (optional for Synergy)
    //   - 10. Cost Of Handset (optional for Synergy)
    //   - 11. Additional Service 1
    //   - 12. Additional Service 2
    //   - 13. Additional Service 3
    //   - 14. Additional Service 4
    //--------------------------------------------------------------------------
    private String createBluePrismMessageBody()
    {
        System.debug('O2RetailChecks.createBluePrismMessageBody() BEGIN');
        String message = '';
        message += createMessageItem('SalesAccountCode', newSalesAccountCode);
        message += createMessageItem('AccountNumber', accountNumber);
        message += createMessageItem('MSISDN', msisdn);
        message += createMessageItem('NewSIM', newSimNumber);
        message += createMessageItem('TariffCode', newTariffCode);
        message += createMessageItem('PackageCode', newPackageCode);
        message += createMessageItem('TermOfContract', newTermOfContract);
        message += createMessageItem('HandsetMake', newHandsetMake);
        message += createMessageItem('HandsetModel', newHandsetModel);
        message += createMessageItem('HandsetCost', newHandsetCost);
        message += createMessageItem('AdditionalService1', insurance ? insuranceServiceCode : null);
        message += createMessageItem('AdditionalService2', internationalFavouritesServiceCode);
        message += createMessageItem('AdditionalService3', additionalDataServiceCode);
        message += createMessageItem('AdditionalService4', offPickCallsServiceCode);
        //
        // Cut the last comma from message
        //
        if (message.length() > 0)
        {
            message = message.substring(0, message.length() - 1);
        }
        System.debug('O2RetailChecks.createBluePrismMessageBody END');
        return message;
    }

    //--------------------------------------------------------------------------
    // Creates message item.
    // Input values are item name and item
    // Return value is string in format 'name:item,' if item is not null
    // empty string is otherwise
    //--------------------------------------------------------------------------
    private static String createMessageItem(String name, Object item)
    {
        String message = '';
        //
        // Check if item exists
        //
        if (item != null)
        {
            message += name + ':' + item + ',';
            System.debug('Added \'' + name + ':' + item + ',\' to message body');
        }
        return message;
    }

    //--------------------------------------------------------------------------
    // Format time for SOA service
    //--------------------------------------------------------------------------
    private static String formatTime(Time p_time)
    {
        String returnValue;
        if (p_time != null)
        {
            returnValue =
                formatNumberForTime(p_time.hour()) + ':'
                + formatNumberForTime(p_time.minute()) + ':'
                + formatNumberForTime(p_time.second());
        }
        return returnValue;
    }

    //--------------------------------------------------------------------------
    // Fromat number in time for SOA service. Number should always have 2
    // characters
    //--------------------------------------------------------------------------
    private static String formatNumberForTime(Integer value)
    {
        String returnValue;
        if (value != null)
        {
            returnValue = String.valueOf(value);
            //
            // If length is one character add zero in the beginning
            //
            if (returnValue.length() == 1)
            {
                returnValue = '0' + returnValue;
            }
        }
        return returnValue;
    }

    //--------------------------------------------------------------------------
    // Resets the state of class
    //--------------------------------------------------------------------------
    private void clearMembers()
    {
        subscriptionNumber = null;
        accountNumber = null;
        salesAccountCode = null;
        salesAccountCategory = null;
        tariffCode = null;
        tariffDescription = null;
        tariffType = null;
        connectedDate = null;
        contractStartDate = null;
        termOfContract = null;
        monthlyLineRentalFee = null;
        companyName = null;
        companyAddress1 = null;
        companyAddress2 = null;
        companyAddress3 = null;
        companyAddress4 = null;
        companyAddress5 = null;
        companyPostcode = null;
        isFranchise = false;
        emailAddress = null;
        // Needed for Blue Prism automatization and reporting
        msisdn = null;
        newSimNumber = null;
        newImeiNumber = null;
        newTariffDescription = null;
        newTariffCode = null;
        newPackageCode = null;
        newTermOfContract = null;
        newHandsetMake = null;
        newHandsetModel = null;
        newHandsetCost = null;
        upgradeType = null;
        insurance = false;
        internationalFavouritesServiceCode = null;
        additionalDataServiceCode = null;
        offPickCallsServiceCode = null;
        isLeased = false;
        //clear contact properties - SW CDECISIONS 10/10/12
        contactFirstName = null;
        contactMiddleName = null;
        contactLastName = null;
        contactTitle = null;
        contactDateOfBirth = null;
        contactOccupation = null;
        contactTelephoneNumber = null;
        contactOtherTelephoneNumber = null;
        contactFaxNumber = null;
        // New contract starts from today
        newContractStartDate = Date.today();
        earlyUpgradeFee = null;
    }

    //--------------------------------------------------------------------------
    // Prepare MSISDN number
    //--------------------------------------------------------------------------
    private String prepareMsisdn(String mobilePhoneNumber)
    {
        String msisdn;
        //
        // If it starts with '00' erease two zeros
        //
        if (mobilePhoneNumber.startsWith('00'))
        {
            msisdn = mobilePhoneNumber.substring(2);
        }
        //
        // If it starts with '+' erease plus
        //
        else if (mobilePhoneNumber.startsWith('+'))
        {
            msisdn = mobilePhoneNumber.substring(1);
        }
        //
        // If it starts with '0' erease zero and add 44 at the beggining
        //
        else if (mobilePhoneNumber.startsWith('0'))
        {
            msisdn = UK_COUNTRY_CODE + mobilePhoneNumber.substring(1);
        }
        else
        {
            msisdn = mobilePhoneNumber;
        }
        return msisdn;
    }

    //--------------------------------------------------------------------------
    // Retrieves customer subscription data
    // Return values are:
    //   true   - on success
    //   false  - on SOA service call error
    //--------------------------------------------------------------------------
    private Boolean retrieveSubscriptionDetails(String msisdn)
    {
        //
        // Call ManageBusinessSubscriptions->getSubscriptionDetails
        //
        Map<String, Object> subscriptionDetails;
        String[] filter = new String[] {'BASIC', 'ADDRESS', 'CONTRACTANDSALES', 'SERVICES'};
        subscriptionDetails = servicesInterface.getSubscriptionDetails(msisdn, filter);
        //
        // Check for serviceError
        //
        if (checkForError(subscriptionDetails))
        {
            system.debug('***Error: retrieveSubscriptionDetails:' + subscriptionDetails);
            return false;
        }
        //
        // BASIC information
        //
        Map<String, Object> basic = (Map<String, Object>)subscriptionDetails.get('BASIC');
        if (basic != null)
        {
            //
            // If BASIC information exists fill members
            //
            String subscriptionStatus = (String)basic.get('subscriptionStatus');
            system.debug('***subscriptionStatus: ' + subscriptionStatus);
            //
            // Check if subscription disconnected
            if (subscriptionStatus != null)
            {
                subscriptionStatus = subscriptionStatus.toUpperCase();
                if (subscriptionStatus == 'DISCONNECTED'
                    || subscriptionStatus == 'NOT CONNECTED'
                    || subscriptionStatus == 'CONNECTION FAILED'
                    || subscriptionStatus == 'CONNECTION PENDING')
                {
                    customerStatus = DISCONNECTED_CUSTOMER;
                    return false;
                }
            }
            subscriptionNumber = (String)basic.get('subscriptionNumber');
            accountNumber = (String)basic.get('accountNumber');
            salesAccountCode = (String)basic.get('salesAccountCode');
            salesAccountCategory = (String)basic.get('salesAccountCategory');
            tariffCode = (String)basic.get('tariffCode');
            tariffDescription = (String)basic.get('tariffDescription');
            tariffType = (String)basic.get('tariffType');
            connectedDate = (Date)basic.get('connectedDate');
            emailAddress = (String)basic.get('emailAddress');
            monthlyLineRentalFee = (Integer)basic.get('monthlyLineRentalFee');
        }
        //
        // ADDRESS information
        //
        Map<String, Object> address  = (Map<String, Object>)subscriptionDetails.get('ADDRESS');
        if (address != null)
        {
            //
            // If ADDRESS information exists fill members
            //
            Map<String, Object> businessAddress = (Map<String, Object>)address.get('businessAddress');
            if (businessAddress != null)
            {
                //
                // If business address exist retrieve company name, address and contact details
                //
                companyName = (String)businessAddress.get('companyName');
                retrieveAddress(businessAddress);
                //
                //SW CDECISIONS 10/10/12 - added to retrieve and store the main contact information for checkout
                //
                retrieveContactNameAndOccupation(businessAddress);
                //
                // Specific stuff for business address
                //
                contactTelephoneNumber = getValueOrFromMap(contactTelephoneNumber , businessAddress, 'companyTelephoneNumber');
                contactOtherTelephoneNumber = getValueOrFromMap(contactOtherTelephoneNumber , businessAddress, 'contactTelephoneNumber');
                contactFaxNumber = getValueOrFromMap(contactFaxNumber , businessAddress, 'faxNumber');
            }
            //SW CDECISIONS 10/10/12 - added to retrieve and store the main contact information for checkout
            Map<String, Object> personalAddress = (Map<String, Object>)address.get('personalAddress');
            if (personalAddress != null)
            {
                //
                // If businessAddress doesn't exist use personalAddress
                //
                if (businessAddress == null)
                {
                    retrieveAddress(personalAddress);
                }
                //
                // Retrieve contact name and occupation
                //
                retrieveContactNameAndOccupation(personalAddress);
                //
                // Specific stuff for personal address
                //
                contactDateOfBirth = getValueOrFromMap(contactDateOfBirth , personalAddress, 'dateOfBirth');
                contactTelephoneNumber = getValueOrFromMap(contactTelephoneNumber , personalAddress, 'telephoneNumber');
                contactOtherTelephoneNumber = getValueOrFromMap(contactOtherTelephoneNumber , personalAddress, 'eveningTelephoneNumber');
                contactFaxNumber = getValueOrFromMap(contactFaxNumber , personalAddress, 'faxNumber');
            }
        }
        //
        // CONTRACTANDSALES information
        //
        Map<String, Object> contractAndSales = (Map<String, Object>)subscriptionDetails.get('CONTRACTANDSALES');
        if (contractAndSales != null)
        {
            //
            // If CONTRACTANDSALES information exists fill members
            //
            contractStartDate = (Date)contractAndSales.get('contractStartDate');
            termOfContract = (Integer)contractAndSales.get('termOfContract');
        }
        //
        // SERVICES information
        // Get monthlyRentalFee from SERVICES field servicePrice with serviceCode LINECH
        //
        List<Map<String, Object>> services = (List<Map<String, Object>>)subscriptionDetails.get('SERVICES');
        //
        // Check if service details exists
        //
        if (services != null)
        {
            for (Map<String, Object> service : services)
            {
                if (LINE_RENTAL_CHARGE.equalsIgnoreCase((String)service.get('serviceCode')))
                {
                    monthlyLineRentalFee = (Integer)service.get('servicePrice');
                    packageCode = (String)service.get('packageCode');
                    break;
                }
            }
        }
        return true;
    }

    //--------------------------------------------------------------------------
    // If value exists return value otherwise retrieves value from map with key
    // Input parameters are:
    //   - value                 Current value
    //   - returnMap             Map with values
    //   - key                   Key in the map
    // Return value is
    //   - value if exists otherwise retrieves value from the map
    //--------------------------------------------------------------------------
    private static String getValueOrFromMap(String value, Map<String, Object> returnMap, String key)
    {
        if (value != null)
        {
            return value;
        }
        return (String)returnMap.get(key);
    }

    //--------------------------------------------------------------------------
    // If value exists return value otherwise retrieves value from map with key
    // Input parameters are:
    //   - value                 Current value
    //   - returnMap             Map with values
    //   - key                   Key in the map
    // Return value is
    //   - value if exists otherwise retrieves value from the map
    //--------------------------------------------------------------------------
    private static Date getValueOrFromMap(Date value, Map<String, Object> returnMap, String key)
    {
        if (value != null)
        {
            return value;
        }
        return (Date)returnMap.get(key);
    }

    //--------------------------------------------------------------------------
    // Retrieves address from address response map
    //--------------------------------------------------------------------------
    private void retrieveAddress(Map<String, Object> addressMap)
    {
        companyAddress1 = getValueOrFromMap(companyAddress1, addressMap, 'address1');
        companyAddress2 = getValueOrFromMap(companyAddress2, addressMap, 'address2');
        companyAddress3 = getValueOrFromMap(companyAddress3, addressMap, 'address3');
        companyAddress4 = getValueOrFromMap(companyAddress4, addressMap, 'address4');
        companyAddress5 = getValueOrFromMap(companyAddress5, addressMap, 'address5');
        companyPostcode = getValueOrFromMap(companyPostcode, addressMap, 'postcode');
    }

    //--------------------------------------------------------------------------
    // Retrieves contact name and ocupation from address response map
    //--------------------------------------------------------------------------
    private void retrieveContactNameAndOccupation(Map<String, Object> addressMap)
    {
        contactFirstName = getValueOrFromMap(contactFirstName, addressMap, 'forename');
        contactMiddleName = getValueOrFromMap(contactMiddleName, addressMap, 'middleName');
        contactLastName = getValueOrFromMap(contactLastName, addressMap, 'surname');
        contactTitle = getValueOrFromMap(contactTitle, addressMap, 'title');
        contactOccupation = getValueOrFromMap(contactOccupation, addressMap, 'occupation');
    }

    //--------------------------------------------------------------------------
    // Retrieves contact name form contact title, fist, middle and last name.
    //--------------------------------------------------------------------------
    public String getContactName()
    {
        String returnValue = '';
        returnValue += addToName(contactTitle);
        returnValue += addToName(contactFirstName);
        returnValue += addToName(contactMiddleName);
        returnValue += addToName(contactLastName);
        returnValue = returnValue.trim();
        return returnValue.length() > 0 ? returnValue : null;
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
    // Check customer details
    // Return values are:
    //   accountManaged        - account is managed
    //   partner               - subscription from O2 partners
    //   VIP                   - VIP subscription
    //   franchise             - franchised O2 subscription
    //   direct                - direct O2 subscription
    //   unknown               - unknown O2 subscription
    //   serviceError          - error whila calling SOA function
    //--------------------------------------------------------------------------
    private String checkCustomerDetails()
    {
        //
        // Check if customer account is managed calling getAccountManageDetails
        // service
        //
        Map<String, Object> resultMap =
            servicesInterface.getAccountManagedDetails(accountNumber);
        if (checkForError(resultMap))
        {
            return SERVICE_ERROR;
        }
        Boolean isAccountManaged = (Boolean)resultMap.get('isAccountManaged');
        if (isAccountManaged == true)
        {
            return ACCOUNT_MANAGED;
        }
        //
        // Partner sales account category
        //
        if (REV_SHARE.equalsIgnoreCase(salesAccountCategory))
        {
            return PARTNER;
        }
        //
        // VIP sales account category
        //
        else if (VIP.equalsIgnoreCase(salesAccountCategory))
        {
            return VIP;
        }
        //
        // Franchise sales account category
        //
        else if (BONUS.equalsIgnoreCase(salesAccountCategory))
        {
            isFranchise = true;
            customerType = FRANCHISE;
            return FRANCHISE;
        }
        //
        // Direct sales account category
        //
        else if (salesAccountCategory == null
                || DIRECT.equalsIgnoreCase(salesAccountCategory)
                || (salesAccountCategory.trim().length() == 0))
        {
            customerType = DIRECT;
            return DIRECT;
        }
        //
        // What if it's something else
        //
        else
        {
            return UNKNOWN;
        }
    }

    //--------------------------------------------------------------------------
    // Checks if there is error in the response
    // Input value is result map from service call
    // Return value is boolean:
    //   - true if error in the response
    //   - false otherwise
    //--------------------------------------------------------------------------
    private static Boolean checkForError(Map<String, Object> resultMap)
    {
        return O2RetailUpgradeServicesUtils.checkForError(resultMap);
    }

    //--------------------------------------------------------------------------
    // Logging of error response
    //--------------------------------------------------------------------------
    private Boolean logErrorResponse(Map<String, Object> response, String functionName)
    {
        if (O2RetailUpgradeServicesUtils.logErrorResponse(response, functionName))
        {
            //
            // If there is error add to services error logs
            //
            serviceErrorLog.add(functionName + ': ' + response);
            return true;
        }
        return false;
    }

    //--------------------------------------------------------------------------
    // Establish eligibility
    // Inputs: store Sales Account Code, store type (direct or franchise)
    // Returns: Map of results by string value...
    // - message: information message
    // - endProcess: process should end with message display
    // - upgradeAvailableMsg: fast track upgrade date
    // - messageSIM: additional message for SIM only
    // - leased: leased device message
    // - checkCustTariffReminder: reminder message to check customer's tariff
    //--------------------------------------------------------------------------
    public Map<String, Object> establishEligibility
    (
        String storeSalesPersonNumber,
        String storeType
    )
    {
        eligibilityResultsMap = new Map<String, Object>();
        isSimOnlyMidTerm = false;
        isEligibleHardWareUpgrade = false;
        isSimOnlyStandardTerm = false;
        isMidTermUpgrade = false;
        isSubscriptionDisconnected = false;
        foundAccountBalance = false;
        hasExecutedAccountBalance = false;
        eligibilityResultsMap.put('proceedMessage', retailNameValueMap.get('UPGRADE_WITHOUT_FEE')); // Default value

        System.debug('***tariffType: ' + tariffType);
        // step 7a
        if (tariffType == null)
        {
            eligibilityResultsMap.put('message', retailNameValueMap.get('INELIGIBLE_TARIFFTYPE_NULL'));
            eligibilityResultsMap.put('endProcess', 'yes');
            return eligibilityResultsMap; //DISPLAY_MESSAGE_8 and End Process
        }
        // step 7b
        if (tariffType.toUpperCase() == 'SIMPLICITY')
        {
            isEligibleHardWareUpgrade = true;
            eligibilityResultsMap.put('message', retailNameValueMap.get('ELIGIBLE_HARDWARE_ANYTIME_UPGRADE'));
            return eligibilityResultsMap; // DISPLAY_MESSAGE_7 and step 13
        }
        // step 7c
        System.debug('***7c contractStartDate: ' + contractStartDate);
        if (tariffType.toUpperCase() == 'SIM ONLY'
            && contractStartDate.addMonths(6)>Date.today()
            && connectedDate <= contractStartDate)
        {
            eligibilityResultsMap.put('message', retailNameValueMap.get('INELIGIBLE_SIM_LESS_SIX_MONTH'));
            eligibilityResultsMap.put('upgradeAvailableDateMsg', retailNameValueMap.get('UPGRADE_AVAILABLE'));
            upgradeAvailableDate = contractStartDate.addMonths(6);
            System.debug('***SIMO upgradeAvailableDate: ' + upgradeAvailableDate);
            eligibilityResultsMap.put('endProcess', 'yes');
            return eligibilityResultsMap; // DISPLAY_MESSAGE_5 and End Process
        }
        // step 7d  SIM Only and more than 6 months into contract or connected date after contract start date
        System.debug('***7d connectedDate: ' + connectedDate);
        if (tariffType.toUpperCase() == 'SIM ONLY'
            && (contractStartDate.addMonths(6) <= Date.today()
                || connectedDate > contractStartDate))
        {
            isEligibleHardWareUpgrade = true;
            Boolean foundUHD = retrieveUpgradeHistoryDetails();
            System.debug('***7d1 previousContractStartDate: ' + previousContractStartDate);
            System.debug('***7d1 previousContractTerm: ' + previousContractTerm);
            //
            // step 7d1
            if (foundUHD && previousContractStartDate.addMonths(previousContractTerm) > Date.today())
            {
                // goto step 13a
                isSimOnlyMidTerm = true;
            }
            else
            {
            //if (foundUHD && previousContractStartDate.addMonths(previousContractTerm) <= Date.today()) {
                // goto step 13b
                isSimOnlyStandardTerm = true;
            }
            //if (!foundUHD) {
                // goto step 13b
            //}
            eligibilityResultsMap.put('messageSIM', retailNameValueMap.get('ELIGIBLE_SIM_ONLY'));
            customerTypeValidation(storeSalesPersonNumber, storeType);  // steps 11,12

            checkAccountBalance();      // Step 9 - account balance check (included on request) - RW20121024
            return eligibilityResultsMap;
        }
        //
        // step 7e
        System.debug('***7e');
        //if (tariffType.toUpperCase() == 'HARDWARE' || tariffType.toUpperCase() == 'LEASED') {
        if (tariffType.toUpperCase() == 'LEASED')
        {
            eligibilityResultsMap.put('leased', retailNameValueMap.get('RETURN_LEASED_DEVICE'));
            isLeased = true;
        }
        //}
        // step 8
        System.debug('***8 isLeased: ' + isLeased);
        upgradeAvailableDate = contractStartDate.addMonths(3);
        System.debug('***8 upgradeAvailableDate: ' + upgradeAvailableDate);
        // step 8a
        if (contractStartDate.addMonths(3)>Date.today()) // less than 3 months into contract
        {
            eligibilityResultsMap.put('message', retailNameValueMap.get('INELIGIBLE_CONTRACT_LESS_THREE_MONTH'));
            eligibilityResultsMap.put('upgradeAvailableDateMsg', retailNameValueMap.get('UPGRADE_AVAILABLE'));
            eligibilityResultsMap.put('endProcess', 'yes');
            return eligibilityResultsMap; // DISPLAY_MESSAGE_9 and End Process
        }
        // step 8b - implied must be over 3 months into contract

        //
        // step 9
        System.debug('***9');
        if (checkAccountBalance()) {
            System.debug('***9 checkAccountBalance() == true');
            return eligibilityResultsMap;
        }
        //
        // step 10
        // SOA rules
        /* Done by SOA layer
        Boolean isMidTermPlusTwelve = false;
        Boolean isMidTermPlusTwentyFour = false;
        Boolean isNoMidTermUpgradesAllowed = false;
        if (contractStartDate<Date.newInstance(2010, 02, 15))
        {
            isMidTermPlusTwelve = true;
        }
        else if (contractStartDate >= Date.newInstance(2010, 02, 15)
                 && contractStartDate <= Date.newInstance(2011, 03, 28))
        {
            isMidTermPlusTwentyFour = true;
        }
        else
        {
            isNoMidTermUpgradesAllowed = true;
        }*/
        //
        // SOA call for upgrade details
        Boolean foundUpgradeDetails = retrieveUpgradeDetails();
        if (isSubscriptionDisconnected)
        {
            eligibilityResultsMap.put('message', retailNameValueMap.get('SUBSCRIPTION_DISCONNECTED'));
            eligibilityResultsMap.put('endProcess', 'yes');
            return eligibilityResultsMap; // Display disconnected message and End Process
        }
        else if (!foundUpgradeDetails)
        {
            eligibilityResultsMap.put('error', SERVICE_ERROR);
            eligibilityResultsMap.put('endProcess', 'yes');
            return eligibilityResultsMap;
        }
        //
        //check if next upgrade date has passed
        Boolean isNextUpgradeDatePassed = false;
        if (nextUpgradeDate < Date.today())
        {
            System.debug('***nextUpgradeDateHasPassed');
            isNextUpgradeDatePassed = true;
            eligibilityResultsMap.put('nextUpgradeDateHasPassed', 'yes');
        }
        //
        // determine if mid-term upgrade
        /* For info, from design
        1) If Standard Upgrade Date = Next Upgrade Date  then Next upgrade is a Standard Upgrade

        2) If Next Upgrade Date is in the past (ie before enquiry date) or is less than 30 days (1 month) from the enquiry date then eligible to upgrade NOW

        3) If Standard Upgrade Date is AFTER the Next Upgrade Date AND  the Contract Start Date  < 15/02/2010
        then Next upgrade is a Mid Term Upgrade and the Customer is allowed to mid-term upgrade with 12 month contract extension and 12 month upgrade cycle for last time, then;
            (i.e. customer will then be at contract end so new terms will apply. No future mid-term upgrade allowed.)

        4) Else If Standard Upgrade Date is AFTER the Next Upgrade Date AND  the Contract Start Date  >= 15/02/2010 and <= 28/03/2011 then;
            Next upgrade is a Mid Term Upgrade and the customer can still take mid-term upgrade, but must sign a new 24 month contract.
            (i.e. Customers taking their mid-term upgrade between 15/02/10 and 28/03/2011 will be eligible for mid-term upgrades twice during their contract tenure
             with new contract upgrade cycle of 12 months.)

        5) Else If Standard Upgrade Date is AFTER the Next Upgrade Date AND  the Contract Start Date  >= 29/03/2011 then;
            No mid-term upgrade available and new terms apply, calculate early upgrade eligibility and early upgrade fee.
        */
        if (standardUpgradeDate > Date.today()) // standard upgrade date is NOT in the past
        {
            //
            // Union of two conditions
            // 1 Contract Start Date < 15/02/2010
            // 2 Contract Start Date >= 15/02/2010 and <= 28/03/2011
            // = Contract Start Date <= 28/03/2011
            //
            if (standardUpgradeDate > nextUpgradeDate
                && contractStartDate <= Date.newInstance(2011, 03, 28))
            {
                isMidTermUpgrade = true;
            }
        }
        System.debug('***10 nextUpgradeDate: ' + nextUpgradeDate);
        System.debug('***10 standardUpgradeDate: ' + standardUpgradeDate);
        System.debug('***10 contractStartDate: ' + contractStartDate);
        System.debug('***10 today (now): ' + Date.today());
        System.debug('***10 isEligible: ' + isEligible);
        System.debug('***10 isMidTermUpgrade: ' + isMidTermUpgrade);
        //
        // step 10a
        if (isEligible == 'Y')
        {
            customerTypeValidation(storeSalesPersonNumber, storeType);  // steps 11, 12
            return eligibilityResultsMap;
        }
        // step 10b/10c
        System.debug('***10b/c isMidTermUpgrade: ' + isMidTermUpgrade);
        //
        // If next upgrade date is passed no need to calculate eartly upgrade fee
        //
        if (!isMidTermUpgrade && !isNextUpgradeDatePassed)
        {
            remainingMonths = calculateMonthsBetween(Date.today(), nextUpgradeDate);
            if (nextUpgradeDate == null)
            {
                system.debug('***Error: unable to calculate remainingMonths: nextUpgradeDate is null');
                eligibilityResultsMap.put('error', SERVICE_ERROR);
                eligibilityResultsMap.put('endProcess', 'yes');
            }
            Boolean foundEarlyUpgradeFee = retrieveEarlyUpgradeFee();
            if (!foundEarlyUpgradeFee)
            {
                eligibilityResultsMap.put('error', SERVICE_ERROR);
                eligibilityResultsMap.put('endProcess', 'yes');
            }
            eligibilityResultsMap.put('proceedMessage', retailNameValueMap.get('UPGRADE_WITH_FTU_FEE'));
            customerTypeValidation(storeSalesPersonNumber, storeType);  // steps 11, 12

        }
        return eligibilityResultsMap;
    }
    //--------------------------------------------------------------------------
    // Check account balance (step 9, 9a, 9b)
    // Returns:
    //  true if process should end
    //--------------------------------------------------------------------------
    private Boolean checkAccountBalance()
    {
        Boolean endProcess = false;
        //
        // get account balance SOA call - if not executed already
        System.debug('***9 hasExecutedAccountBalance: ' + hasExecutedAccountBalance);
        if (!hasExecutedAccountBalance)
        {
            foundAccountBalance = retrieveAccountBalance();
            hasExecutedAccountBalance = true;
        }
        System.debug('***9 foundAccountBalance: ' + foundAccountBalance);
        if (!foundAccountBalance) {
            eligibilityResultsMap.put('error', SERVICE_ERROR);
            eligibilityResultsMap.put('endProcess', 'yes');
            endProcess = true;
        }
        // step 9a
        if (amountOverdue>0) {
            eligibilityResultsMap.put('message', retailNameValueMap.get('REFER_CUST_SERVICES'));
            eligibilityResultsMap.put('endProcess', 'yes');
            endProcess = true;  // DISPLAY_MESSAGE_10 and End Process
        }
        // step 9b - implied no amount overdue
        System.debug('***9 amountOverdue: ' + amountOverdue);
        //
        return endProcess;
    }
    //--------------------------------------------------------------------------
    // Customer type validation (Direct/Fanchise) versus store details
    //      (steps 11, 12)
    // Inputs: store Sales Account Code, store type (Direct or Franchise)
    // Returns:
    //  true if process should end
    //--------------------------------------------------------------------------
    private Boolean customerTypeValidation
    (
        String storeSalesPersonNumber,
        String storeType
    )
    {
        Boolean endProcess = false;
        Boolean inContract =
            contractStartDate.addMonths(termOfContract) > Date.today();

        System.debug('***11,12 inContract: ' + inContract);
        System.debug('***11,12 storeSalesPersonNumber: ' + storeSalesPersonNumber);
        System.debug('***11,12 salesAccountCode: ' + salesAccountCode);
        //
        //Find if SalesAccountNumbers match
        Boolean isSalesAccountNumbersMatch = false;
        if (storeSalesPersonNumber != null
            && salesAccountCode != null
            && storeSalesPersonNumber.equals(salesAccountCode))
        {
            isSalesAccountNumbersMatch = true;
        }
        System.debug('***11,12 customerType: ' + customerType);
        System.debug('***11,12 isSalesAccountNumbersMatch: ' + isSalesAccountNumbersMatch);
        //
        // Apply rules
        /*
        If customer-type is Franchise and MSISDN is NOT currently in contract, then proceed to Tariff Selection.

        If customer-type is Franchise, MSISDN is in contract AND owning Franchise and processing StoreID match, then proceed to Tariff Selection
            ELSE If customer-type is Franchise, MSISDN is in contract and owning Franchise and processing StoreID DO NOT match, then refer customer to owning Franchise holder.

        If customer-type is Direct, store-type is Franchise and MSISDN is NOT currently in contract, then proceed to Tariff Selection.
            ELSE If customer-type is Direct, store-type is Franchise and MSISDN IS in contract, refer customer to O2 Customer Service.

            ELSE if customer-type is Direct AND store-type is Direct, then proceed to Tariff Selection.

        1) If Franchise customer, is in contract and Franchise stores Sales Account Numbers do not match - display message 13
        2) If Direct customer enquiring in a Franchise store - refer customer to a standard O2 store - display message 14
        3) If out of contract of if logic control has validated store's authority to upgrade the customer - proceed to Step 12
        */
        //
        // Minimized function is
        /*
        If MSISDN is NOT in contract he can proceed to Tariff Selection
        If customer-type is Franchise and storeType is Franchise and if sales account numbers match proceed to tariff selection
        If customer-type is Direct and storeType is Direct proceed to tariff selection
        */
        if ((!inContract)
            || (customerType == DIRECT && storeType == DIRECT)
            || (customerType == FRANCHISE
                && storeType == FRANCHISE
                && isSalesAccountNumbersMatch))
        {
            // eligible
            eligibilityResultsMap.put('checkCustTariffReminder', retailNameValueMap.get('CHECK_CUST_TARIFF_REMINDER'));
            System.debug('***11,12 eligible');
        }
        else
        {
            // not eligible
            if (customerType == FRANCHISE)
            {
                eligibilityResultsMap.put('message', retailNameValueMap.get('FRANCHISE_CUST_WRONG_STORE'));
            }
            if (customerType == DIRECT)
            {
                eligibilityResultsMap.put('message', retailNameValueMap.get('DIRECT_CUST_WRONG_STORE'));
            }
            eligibilityResultsMap.put('endProcess', 'yes');
            endProcess = true;
            System.debug('***11,12 not eligible');
        }
        return endProcess;
    }

    //--------------------------------------------------------------------------
    // Gets and stores the account balance
    // Returns:
    //  true if successful
    //--------------------------------------------------------------------------
    private Boolean retrieveAccountBalance()
    {
        Boolean found = false;
        Map<String, Object> resultMap = servicesInterface.getAccountBalance(accountNumber);
        //
        // Check if there is error calling the service
        //
        if (checkForError(resultMap))
        {
            //
            // Error while calling service
            //
            System.debug('O2RetailChecks.retrieveAccountBalance END');
            return false;
        }
        amountOverdue = (Integer)resultMap.get('amountOverdue');
        try
        {
            if (amountOverdue != null)
            {
                found = true;
            }
        }
        catch (Exception e) {}

        return found;
    }

    //--------------------------------------------------------------------------
    // Gets and stores the upgrade history details
    // Returns:
    //  true if successful
    //--------------------------------------------------------------------------
    private Boolean retrieveUpgradeHistoryDetails()
    {
        Boolean found = false;
        Map<String, Object> resultMap =
            servicesInterface.getUpgradeHistoryDetails_1(subscriptionNumber);
        //
        // Check if there is error calling the service
        //
        if (checkForError(resultMap))
        {
            //
            // Error while calling service
            //
            System.debug('O2RetailChecks.retrieveUpgradeHistoryDetails END');
            return false;
        }
        previousContractStartDate = (Date)resultMap.get('previousContractStartDate');
        String previousContractTermStr = (String)resultMap.get('previousContractTerm');
        try
        {
            if (previousContractTermStr != null && previousContractTermStr != '')
            {
                previousContractTerm = Integer.valueOf(previousContractTermStr);
                found = true;
            }
        }
        catch (Exception e) {}

        return found;
    }

    //--------------------------------------------------------------------------
    // Gets and stores the upgrade details
    // Returns:
    //  true if successful
    //--------------------------------------------------------------------------
    private Boolean retrieveUpgradeDetails()
    {
        Boolean returnValue = false; // default return value
        Map<String, Object> resultMap = servicesInterface.getUpgradeDetails_1(subscriptionNumber);
        //
        // Check if there is error calling the service
        //
        String errorResult = (String)resultMap.get('error');
        //
        // Check if subscription is disconnected or terminated
        if (errorResult != null
            && errorResult.contains('Subscription is either disconnected or terminated'))
        {
            isSubscriptionDisconnected = true;
            return true;
        }
        else if (checkForError(resultMap))
        {
            //
            // Error while calling service
            //
            System.debug('O2RetailChecks.retrieveUpgradeDetails END');
            return false;
        }
        //
        // Set customer transaction details
        //
        SOAManageBusinessUpgradesData.getUpgradeDetails_1Response upgradeDetails =
            (SOAManageBusinessUpgradesData.getUpgradeDetails_1Response)resultMap.get('Response');

        if (upgradeDetails != null)
        {
            nextUpgradeDate = upgradeDetails.nextUpgradeDate;
            standardUpgradeDate = upgradeDetails.standardUpgradeDate;
            if (upgradeDetails.eligibilityOptions != null
                && upgradeDetails.eligibilityOptions.size() > 0)
            {
                isEligible = upgradeDetails.eligibilityOptions[0].isEligible;
            }
            midTermUpgradeCharge = upgradeDetails.midTermUpgradeCharge;
            returnValue = true;
        }

        return returnValue;
    }
    //--------------------------------------------------------------------------
    // Gets and stores the early upgrade fee
    // Returns:
    //  true if successful
    //--------------------------------------------------------------------------
    private Boolean retrieveEarlyUpgradeFee()
    {

        Boolean returnValue = false; // default return value

        Map<String, Object> resultMap = servicesInterface.getEarlyUpgradeFee_1(monthlyLineRentalFee, remainingMonths);
        //
        // Check if there is error calling the service
        //
        if (checkForError(resultMap))
        {
            //
            // Error while calling service
            //
            System.debug('O2RetailChecks.retrieveUpgradeDetails END');
            return false;
        }
        //
        // Set customer transaction details
        //
        String earlyUpgradeFeeStr = (String)resultMap.get('earlyUpgradeFee');
        try {
            if (earlyUpgradeFeeStr != null && earlyUpgradeFeeStr != '')
            {
                earlyUpgradeFee = Integer.valueOf(earlyUpgradeFeeStr);
                returnValue = true;
            }
        }
        catch (Exception e) {}
        //
        // If early upgrade fee is negative clear the value
        //
        if (earlyUpgradeFee < 0)
        {
            earlyUpgradeFee = null;
        }

        return returnValue;
    }

    //--------------------------------------------------------------------------
    // Calculate months between two dates
    //--------------------------------------------------------------------------
    private static Integer calculateMonthsBetween(Date firstDate, Date secondDate)
    {
        Integer returnValue = 0;
        //
        // Check if dates exists
        //
        if (firstDate != null && secondDate != null)
        {
            returnValue = firstDate.monthsBetween(secondDate);
            //
            // If the day of the month of first is bigger than the second
            //
            if (firstDate.day() > secondDate.day())
            {
                returnValue--;
            }
        }
        return returnValue;
    }

    //--------------------------------------------------------------------------
    // getters
    //--------------------------------------------------------------------------

    public String getBankAccountNumber()
    {
        return bankAccountNumber;
    }

    public String getBankSortCode()
    {
        return bankSortCode;
    }

   
}