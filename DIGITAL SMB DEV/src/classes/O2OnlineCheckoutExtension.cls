public without sharing class O2OnlineCheckoutExtension {

    public O2OnlineMainController parentController {get;set;}

	public Id BundleId;

    public static final String DRAFT_STATUS = 'DRAFT';

    public cscfgc.API_1.ApiSession apiSession;
    public cscfgc.SessionManager.SessionInfo userSession;

    public Account webAccount {get;set;}
    public Contact webContact {get;set;}
    public Credit_Vet__c webCreditVet {get;set;}
    Decimal totalRecurring ;
    //Business details
    public String numberofEmp { get; set;}
    public String buildingName { get; set;}
    public String buildingNo {get; set;}
    public String streetName {get;
    	set
    	{
    		String strAddr='';
    		String comma = ', ';
    		streetName = value;
    		if(flatNumber != null && flatNumber != '') {strAddr += flatNumber;}
    		if(strAddr != '' && strAddr!=null && buildingNo != '') {strAddr += comma;}
    		if(buildingNo != null && buildingNo != '') {strAddr += buildingNo;}
    		if(strAddr != '' && strAddr!=null && buildingName != '') {strAddr += comma;}
    		if(buildingName != null && buildingName != '') {strAddr += buildingName;}
    		flatOrBuildingNo = strAddr;
    	}
    }
    public String cityName {get; set;}
    public String postalCode {get; set;}

    public String countyName {get; set;}
    public String flatNumber {get; set;}
    public String selectedCountry {
    	get{
    		if(selectedCountry != '' && selectedCountry != null)  return selectedCountry; else return defaultCountry;
    	}
    	set;
    }

    public String flatOrBuildingNo {get;set;}

    //directors address
    public String dirBuildingName { get; set;}
    public String dirBuildingNo {get; set;}
    public String dirStreetName {get;
    	set
    	{
    		String strDirAddr = '';
    		String comma = ', ';
    		dirStreetName = value;
    		if(dirFlatNumber != null && dirFlatNumber != '') {strDirAddr += dirFlatNumber;}
    		if(strDirAddr != '' && strDirAddr !=null && dirBuildingNo != '') {strDirAddr += comma;}
    		if(dirBuildingNo != null && dirBuildingNo != '') {strDirAddr += dirBuildingNo;}
    		if(strDirAddr != '' && strDirAddr != null && dirBuildingName != '') {strDirAddr += comma;}
    		if(dirBuildingName != null && dirBuildingName != '') {strDirAddr += dirBuildingName;}
    		dirFlatOrBuildingNo = strDirAddr;
    	}
    }
    public String dirCityName {get; set;}
    public String dirPostalCode {get; set;}

    public String dirCountyName {get; set;}
    public String dirFlatNumber {get; set;}
    public String selectedCurCountry {
    	get{
    		if(selectedCurCountry != '' && selectedCurCountry != null) return selectedCurCountry; else return defaultCountry;
    	}
   		set;
    }

    public String dirFlatOrBuildingNo {get;set;}


    //Directors Previous Addr
    public String dirPreBuildingName { get; set;}
    public String dirPreBuildingNo {get; set;}
    public String dirPreStreetName {get;
    	set
    	{
    		String strPreDirAddr = '';
    		String comma = ', ';
    		dirPreStreetName = value;
    		if(dirPreFlatNumber != null && dirPreFlatNumber != '') {strPreDirAddr += dirPreFlatNumber;}
    		if(strPreDirAddr != '' && strPreDirAddr !=null && dirPreBuildingNo != '') {strPreDirAddr += comma;}
    		if(dirPreBuildingNo != null && dirPreBuildingNo != '') {strPreDirAddr += dirPreBuildingNo;}
    		if(strPreDirAddr != '' && strPreDirAddr !=null && dirPreBuildingName != '') {strPreDirAddr += comma;}
    		if(dirPreBuildingName != null && dirPreBuildingName != '') {strPreDirAddr += dirPreBuildingName;}
    		dirPreFlatOrBuildingNo = strPreDirAddr;

    	}
    }
    public String dirPreCityName {get; set;}
    public String dirPrePostalCode {get; set;}

    public String dirPreCountyName {get; set;}
    public String dirPreFlatNumber {get; set;}
    public String selectedPreCountry {
    	get{
    		if(selectedPreCountry != '' && selectedPreCountry != null) return selectedPreCountry; else return defaultCountry;
    	}
    	set;
    }

   	public String dirPreFlatOrBuildingNo {get;set;}


    //Director's details
    public String title{get; set{
    		title = value;
    		webContact.Salutation = value;
    		webCreditVet.Title__c = value;
    	}
    }
    public String firstName{get; set{
    		firstName = value;
    		webContact.FirstName = value;
    	}
    }
    public String lastName{get; set{
    		lastName = value;
    		webContact.LastName = value;
    	}
    }

    public String day{get; set;}
    public String month{get; set;}
    public String year{get; set;}

    public Date getDateOfBirth(){
		String dateOfBirth = day+'/'+month+'/'+year;
		Date birthDate = date.parse(dateOfBirth);
		webContact.Date_of_Birth__c = birthDate;
		webCreditVet.Date_of_Birth__c = birthDate;
  	 	return birthDate;
    }

    public String email{get; set{
    		email = value;
    		webCreditVet.Director_E_mail_Address__c = value;
    		webContact.Email = value;
    	}
    }

    public String confirmEmail{get; set {
    		//if(email == value)
    		confirmEmail = value;
    		//else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Email addresses do not match.'));
    	}
    }


    //Business details
    public String businessType {get; set
    	{
    		businessType = value;
    		webCreditVet.Business_Type__c = value;
    	}
    }


    public String companyName{get; set{
    		companyName = value;
    		webAccount.Name = value;
    	}
    }

    public String companyRegNo{get; set{
    		companyRegNo = value;
    		webAccount.Company_Reg_No__c = value;
    		webCreditVet.Company_Reg_No__c = value;
    	}
    }

    //Director's Previous Address
    public String previousAddrYear{
    	 get {if (previousAddrYear == null) return '-'; else return previousAddrYear;}
    	 set {
    	 	previousAddrYear = value;
    	 	if(previousAddrYear!=null && previousAddrYear == '3+') previousAddrMonth = '0';
    	 }
    }
    public String previousAddrMonth{
    	get {
    		if (previousAddrYear!=null && previousAddrYear == '3+') return '0';
    		else if (previousAddrMonth==null) return '-';
    		else return previousAddrMonth;
    	}
     	set {previousAddrMonth = value;}
    }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //[zz 221108] for conditinal mll rendering
  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  // checks if order contains mll
  public Boolean isMLLOrder
  {
    get
    {
      try
      {
      	if (sessionbasket!=null)
      	{
      		if(sessionbasket.cscfgc__Products_In_Basket__c.contains('Mobile Landline'))
        	{
        		return true;
        	}
      	}
      	return false;
      }
      catch (Exception ex)
      {
        return false;
      }
    }
  }
  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    public cscfgc__Product_Basket__c sessionbasket {get;set;}
    public cscfgc__Product_Basket__c currentBasket {get;set;}
    public List<cscfgc__Product_Configuration__c> currentConfigs {get;set;}

    public O2OnlineCheckoutExtension() {  }
    public O2OnlineCheckoutExtension (O2OnlineMainController orderController) {
        this.parentController = orderController;
        this.opptyFields  = new Map<String, String>();
        //this.sessionbasket = orderController.userSession.getSessionBasket();
        if (this.webAccount==null) {this.webAccount = new Account();}
        if (this.webContact==null) {this.webContact = new Contact();}
        if (this.webCreditVet==null) {this.webCreditVet = new Credit_Vet__c();}
    }

    public void retrieveSession() {
    	System.debug('### OUTPUT >>>>> retrieveSession: start');
    	if (parentController.newUserSession==null) parentController.startSession();	//SW 08/08/2011 - added line to ensure that we have a user session
    	System.debug('### OUTPUT >>>>> retrieveSession: userSession: '+parentController.newUserSession);
    	userSession = parentController.newUserSession;
    	sessionbasket = userSession.getSessionBasket();
    }

    public void addError(String Field, String Message, String Value) {
		if(Value == null) Value = '';
		CoremetricsValidationData cmvd = new CoremetricsValidationData(Field, Message, '', Value);
		coremetricValidationDataList.add(cmvd);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Message));
    }
    public PageReference backToBasket() {return Page.O2OnlineProductPageFinal;}
    public PageReference backToCustomerDetails() {return Page.O2OnlineCheckoutPage1;}
    public PageReference proceedToDirectorsDetails() {
    	//Empty coremetrics list
    	coremetricValidationDataList = new CoremetricsValidationData[]{};

    	//validate required inputs and formats before continuing
    	if (businessType==null || businessType==''){
    		addError('Business type','Business Type is required. Please supply a value.', businessType);
    	} else {
    		if (numberofEmp==null || numberofEmp=='') addError('Number Of Employees', 'Number Of Employees is required. Please supply a value.', numberofEmp);
    		try {
	    		if (numberofEmp!=null && numberofEmp!='') Integer.valueOf(numberofEmp);
	    		system.debug('Number Of Employees  '+ numberofEmp);
	    	} catch (TypeException e) {
	    		addError('Number Of Employees', 'Number Of Employees must be a non decimal number.', numberofEmp);
	    	}
    	}
    	if (postalCode==null || postalCode=='') addError('Postal Code', 'Postal Code is required. Please supply a value.', postalCode);
    	if (streetName==null || streetName=='') addError('Street', 'Street is required. Please supply a value.', streetName);
    	if (cityName==null || cityName=='') addError('Town/city', 'Town/City is required. Please supply a value.', cityName);


	    //if (selectedCountry==null || selectedCountry=='') addError('Country is required. Please supply a value.');
    	if (businessType=='Limited Company') {
	    	if (companyName==null || companyName=='') addError('Company Name', 'Company Name is required. Please supply a value.', companyName);
    		if (companyRegNo==null || companyRegNo=='') addError('Company Registration Number', 'Company Registration Number is required. Please supply a value.', companyRegNo);
    		//try {
    			//Long.valueOf(companyRegNo);
    			system.debug('companyRegNo '+companyRegNo);
    	//	} catch (TypeException e) {
    		//	addError('Registration Number', 'Registration Number must be a number.', companyRegNo);
    		//}
	    	if (webCreditVet.Business_Phone__c==null || webCreditVet.Business_Phone__c=='') addError('Business Phone Number', 'Business Phone Number is required. Please supply a value.', webCreditVet.Business_Phone__c);
	//        try {Integer.valueOf(webCreditVet.Business_Phone__c);system.debug('Business Phone Number  '+webCreditVet.Business_Phone__c);} catch (TypeException e) {addError('Business Phone Number must be a non decimal number.');}

	 //AK  	if (webCreditVet.Years__c==null || webCreditVet.Years__c=='') addError('Years is required. Please supply a value.');
	 //AK 	if (webCreditVet.Months__c==null || webCreditVet.Months__c=='') addError('Months is required. Please supply a value.');
	 //AK 	if (webCreditVet.Number_of_Directors__c==null || webCreditVet.Number_of_Directors__c=='') addError('Number of Directors is required. Please supply a value.');
		} else if (businessType=='Self Employed/Partnership' || businessType=='Other') {
	    	if (companyName==null || companyName=='') addError('Company Name', 'Company Name is required. Please supply a value.', companyName);
	 //   	if (webCreditVet.Years__c==null || webCreditVet.Years__c=='') addError('Years is required. Please supply a value.');
	 //   	if (webCreditVet.Months__c==null || webCreditVet.Months__c=='') addError('Months is required. Please supply a value.');
	    	if (webCreditVet.Business_Phone__c==null || webCreditVet.Business_Phone__c=='') addError('Business Phone Number', 'Business Phone Number is required. Please supply a value.', webCreditVet.Business_Phone__c);
	//	    try {Integer.valueOf(webCreditVet.Business_Phone__c);system.debug('Business Phone Number  '+webCreditVet.Business_Phone__c);} catch (TypeException e) {addError('Business Phone Number must be a non decimal number.');}

		}
    	if (ApexPages.hasMessages()) return null;
    	return Page.O2OnlineCheckoutDirectorDetails;
    }
    public PageReference backToDirectorsDetails() {return Page.O2OnlineCheckoutDirectorDetails;}
    public PageReference proceedToPayment() {
    	coremetricValidationDataList = new CoremetricsValidationData[]{};

    	//validate required inputs and formats before continuing
    	if (title==null || title=='') addError('Title', 'Title is required. Please supply a value.', title);
     	if (firstName==null || firstName=='') addError('First Name', 'First Name is required. Please supply a value.', firstName);
    	if (lastName==null || lastName=='') addError('Last Name', 'Last Name is required. Please supply a value.', lastName);
    	if ((day==null || day=='') ||( month==null || month=='' )|| (year==null || year=='')) addError('Date of Birth','Date of Birth is required. Please supply a value.', day + '/' + month + '/' + year);

    	if(day != null && month != null && year != null)
    //	if((day != null && month != null && year != null) || (day != '' && month != '' && year != ''))
    //    if ((day != null && day != '') && ( month != null && month != '' ) && (year != null && year != ''))
    	{   System.debug('day '+day + ' month '+month+ ' year '+year );
    		if(Date.isLeapYear(Integer.valueOf(year)) && month =='2' && Integer.valueOf(day)>29) addError('Date of Birth','Please supply a valid date of birth.', day + '/' + month + '/' + year);
    		else if(!Date.isLeapYear(Integer.valueOf(year)) && month == '2' && Integer.valueOf(day) > 28) addError('Date of Birth','Please supply a valid date of birth.', day + '/' + month + '/' + year);
    		else if((month=='4' || month=='6' || month=='9' || month=='11') && Integer.valueOf(day) == 31) addError('Date of Birth','Please supply a valid date of birth.', day + '/' + month + '/' + year);
    	}

  //AK 	if (webCreditVet.Gender__c==null || webCreditVet.Gender__c=='') addError('Gender is required. Please supply a value.');
    	if (webCreditVet.Director_Phone_Number__c==null || webCreditVet.Director_Phone_Number__c=='') addError('Phone Number', 'Phone Number is required. Please supply a value.', webCreditVet.Director_Phone_Number__c);
    	if (email==null || email==''){
    		addError('Email Address', 'Email Address is required. Please supply a value.', email);
    	} else {
    		if (!Pattern.matches('^([\\w-]+(?:\\.[\\w-]+)*)@((?:[\\w-]+\\.)*\\w[\\w-]{0,66})\\.([a-z]{2,6}(?:\\.[a-z]{2})?)$', email)){
    			addError('Email address', email+' is not a valid email address.', email);
    		}
    	}
    	if (confirmEmail==null || confirmEmail==''){
    		addError('Confirm email address', 'You must confirm your email address. Please supply a value.', confirmEmail);
    	} else {
    		//if ((email != null && email != '') && (confirmEmail != null && confirmEmail=='') && (email != confirmEmail)) addError('Confirm email address', 'Email addresses do not match. Please supply the correct email address', confirmEmail);
    		if (email != confirmEmail) {
    			addError('Confirm email address', 'Email addresses do not match. Please supply the correct email address', confirmEmail);
    		}
    	}

    	//Check for Role or Position
    	if (businessType=='Self Employed/Partnership' || businessType=='Other'){
    	 if (webCreditVet.Position_in_Company__c==null || webCreditVet.Position_in_Company__c=='') addError('Position / Role', 'Position / Role is required. Please supply a value.', webCreditVet.Position_in_Company__c);

    	}

    	//validate director address
    	//if (dirBuildingNo==null || dirBuildingNo=='') addError('Building Number is required. Please supply a value.');
    	if (selectedDirectorsAddressIndex==null) {
	    	if (dirPostalCode==null || dirPostalCode=='') addError('Directors current postcode', 'Directors current postcode is required. Please supply a value.', dirPostalCode);
	    	if (dirStreetName==null || dirStreetName=='') addError('Directors current street', 'Directors current street is required. Please supply a value.', dirStreetName);
	    	if (dirCityName==null || dirCityName=='') addError('Directors current town/city', 'Directors current town/city is required. Please supply a value.', dirCityName);
	    	//if (selectedCurCountry==null || selectedCurCountry=='') addError('Directors current country is required. Please supply a value.');
    	}
    	if (previousAddrYear==null || previousAddrYear=='' || previousAddrYear=='-') addError('Length of time at this address (years)', 'Length of time at this address (years) is required. Please supply a value.', previousAddrYear);
    	if ((previousAddrMonth==null || previousAddrMonth=='' || previousAddrMonth=='-') && previousAddrYear != '3+') addError('Length of time at this address (months)', 'Length of time at this address (months) is required. Please supply a value.', previousAddrMonth);
    	//valdiate previous address if required
    	if (previousAddrYear!=null && previousAddrYear!='' && previousAddrYear!='-' && previousAddrYear!='3+') {
	    	//if (dirPreBuildingNo==null || dirPreBuildingNo=='') addError('Building Number is required. Please supply a value.');
	    	if (dirPrePostalCode==null || dirPrePostalCode=='') addError('Directors previous postcode', 'Directors previous postcode is required. Please supply a value.', dirPrePostalCode);
	    	if (dirPreStreetName==null || dirPreStreetName=='') addError('Directors previous street', 'Directors previous street is required. Please supply a value.', dirPreStreetName);
	    	if (dirPreCityName==null || dirPreCityName=='') addError('Directors previous town/city', 'Directors previous town/city is required. Please supply a value.', dirPreCityName);
	    	//if (selectedPreCountry==null || selectedPreCountry=='') addError('Directors previous country is required. Please supply a value.');
    	}
    	if (ApexPages.hasMessages()) {
    	   system.debug(ApexPages.getmessages());
    		return null;
    	}
    	return Page.O2OnlineCheckoutPage2;
    }
    public PageReference backToPayment() {return Page.O2OnlineCheckoutPage2;}
    public PageReference proceedToSummary() {
    	coremetricValidationDataList = new CoremetricsValidationData[]{};
    	//### perform data validation checks
    	//check bank name, account name, sort code, and account number
    	if (!Pattern.matches('^[0-9a-zA-Z\\s]+$', bankBuildingSociety)) {addError('Bank Name', 'Bank Name is required and must not contain special characters.', '');}
    	//if (!Pattern.matches('^[0-9a-zA-Z\\s]+$', bankAccountName)) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account Name is required and must not contain special characters.'));return null;}
    	if(bankAccountName==null || bankAccountName=='') addError('Account Name', 'Account Name is required . Please supply a value.', '');

    	try {Integer.valueOf(bankSortCode);} catch (TypeException e) {addError('Sort Code','Sort Code is required and must be a number. Please supply a valid number.','');}
    	if(bankSortCode != null && bankSortCode != '' &&Integer.valueOf(bankSortCode.length()) < 6) addError('Sort Code','Sort code must be a 6 digit number. Please supply a valid number.','');

    	if(bankAccountNumber==null || bankAccountNumber=='') addError('Account Number', 'Account Number is required and must be a number. Please supply a valid number.', '');
    	else{ try {Integer.valueOf(bankAccountNumber);} catch (TypeException e) {addError('Account Number', 'Account Number must be a 10 digit number. Please supply a valid number.','');}}

        if (agreeDirectDebit==null || !agreeDirectDebit) {addError('Direct Debit Guarantee', 'Please check details and confirm you have read the Direct Debit Guarantee.', string.valueOf(agreeDirectDebit));}

        //SW CDECISIONS 20/06/2012 - added following code to handle the credit card field validation in the event that IDV checks are turned on (custom setting)
        if (getcreditCheckEnabled()) {
        	if (cardType==null || cardType=='') {addError('Card Type','Card Type is a required field. Please select a value.','');}
	    	if (nameOnCard==null || nameOnCard=='') {addError('Name on Card', 'Name on Card is required and must not contain special characters.', '');}
	    	else if (!Pattern.matches('^[0-9a-zA-Z\\s]+$', nameOnCard)) {addError('Name on Card', 'Name on Card is required and must not contain special characters.','');}
	    	if (cardNumber==null || cardNumber=='') {addError('Card Number', 'Card Number is required. Please supply a value.', '');}
        	else {
        		cardNumber = cardNumber.trim();
		    	if (cardType=='Visa Credit' && cardNumber.length()!=16 && cardNumber.length()!=13) {addError('Card Number','Card number must be either 13 or 16 digits for this card type. Please supply a valid number.','');}
		    	else if (cardType=='Mastercard' && cardNumber.length()!=16) {addError('Card Number', 'Card number must be exactly 16 digits for this card type. Please supply a valid number.','');}
		    	else if (cardType=='American Express' && cardNumber.length()!=15) {addError('Card Number', 'Card number must be exactly 15 digits for this card type. Please supply a valid number.','');}
		    	else if (cardType!='Visa Credit' && cardType!='Mastercard' && cardType!='American Express' && cardNumber.length()>19) {addError('Card Number', 'Card number must be no longer than 19 digits for this card type. Please supply a valid number.','');}
		    	else if (!Pattern.matches('^[0-9\\s]+$', cardNumber)) {addError('Card Number', 'Card number must be a number. Please supply a valid number.','');}
        	}
        	if (cardType=='Maestro' && (startDateMM==null || startDateMM=='' || startDateYY==null || startDateYY=='')) {addError('Start Date', 'Start Date is required. Please select a month and year.', '');}
        	if (expiryDateMM==null || expiryDateMM=='' || expiryDateYY==null || expiryDateYY=='') {addError('Expiry Date', 'Expiry Date is required. Please select a month and year.', '');}
	    	if (ccvNumber==null || ccvNumber=='') addError('Security code', 'Security code is a required field. Please supply a value.', '');
	    	else {
	    		if (cardType=='American Express') {if (ccvNumber.length()!=4) addError('Security code', 'Security code must be 4 characters. Please supply a valid number.', '');}
	    		else {if (ccvNumber.length()!=3) addError('Security code', 'Security code must be 3 characters. Please supply a valid number.', '');}
		    	try {Integer.valueOf(ccvNumber);} catch(TypeException e) {addError('Security code', 'Security code must be a number. Please supply a valid number.', '');}
	    	}
	    	if (cardType=='Maestro') {
	    		if (issueNumber==null || issueNumber=='') addError('Issue number','Issue number is a required field. Please supply a value.', '');
	    		else {try {Integer.valueOf(issueNumber);} catch(TypeException e) {addError('Issue number','Issue number must be a number. Please supply a valid number.', '');}}
	    	}
        }

    	if (ApexPages.hasMessages()) return null;
    	return Page.O2OnlineCheckoutPageFinal;
    }

    public List<SelectOption> getSalutations(){

    	Schema.DescribeFieldResult F = Contact.Salutation.getDescribe();
		List<Schema.PicklistEntry> P = F.getPicklistValues();

    	List<SelectOption> slOptions = new List<SelectOption>();
    	slOptions.add(new SelectOption('', '-- Select --'));

    	for(Schema.PicklistEntry pickVal : P){
    		slOptions.add(new SelectOption(pickVal.getValue(), pickVal.getLabel()));
    	}

    	return slOptions;
    }

    public List<SelectOption> getDays(){
    	List<SelectOption> dOptions = new List<SelectOption>();
    	dOptions.add(new SelectOption('', 'DD'));
		for(Integer i=1;i<=31;i++)
		{
    		dOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
    	return dOptions;
    }

    public List<SelectOption> getMonths(){
    	List<SelectOption> mOptions = new List<SelectOption>();
    	mOptions.add(new SelectOption('', 'MM'));
		for(Integer i=1;i<=12;i++)
		{
    		mOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
    	return mOptions;
    }

    public List<SelectOption> getYears(){
    	List<SelectOption> yOptions = new List<SelectOption>();
    	yOptions.add(new SelectOption('', 'YYYY'));
    	Integer curYear = calculateYear();
		for(Integer i=1901;i<=curYear;i++)
		{
    		yOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
    	return yOptions;
    }

    public Integer calculateYear(){
    	Date curDate = Date.today();
    	Integer curYear = curDate.year();
    	Integer resYear = curYear - 18;
    	return resYear;
    }

    public List<SelectOption> getBusinessTypes(){
    	List<SelectOption> btOptions = new List<SelectOption>();
    	btOptions.add(new SelectOption('', '-- Select company type --'));
    	btOptions.add(new SelectOption('Limited Company', 'Limited Company'));
    	btOptions.add(new SelectOption('Self Employed/Partnership', 'Non-Limited Company'));
    	btOptions.add(new SelectOption('Other', 'Other - Government/Charity'));
    	return btOptions;
    }

    public List<SelectOption> getPreviousAddressYears(){
    	List<SelectOption> ayOptions = new List<SelectOption>();
    	ayOptions.add(new SelectOption('-', '-- none --'));
    	ayOptions.add(new SelectOption('0', '0'));
    	ayOptions.add(new SelectOption('1', '1'));
    	ayOptions.add(new SelectOption('2', '2'));
    	ayOptions.add(new SelectOption('3+', '3+'));
    	return ayOptions;
    }
	public List<SelectOption> getPreviousAddressMonths(){
    	List<SelectOption> amOptions = new List<SelectOption>();
    	amOptions.add(new SelectOption('-', '-- none --'));
    	for(Integer j=0;j<12;j++)
    		amOptions.add(new SelectOption(String.valueOf(j), String.valueOf(j)));
    	return amOptions;
    }


    public String defaultCountry {get;set;}

    public List<SelectOption> getAddressCountries() {

    	List<SelectOption> lsOptions = new List<SelectOption>();
        Map<String, CountryCodes__c> countries = CountryCodes__c.getAll();
        if (countries!=null && countries.size()>0) {
        	/*if(selectedCountry == '' && selectedCountry == null) selectedCountry = countries.get('default').Country_Name__c;
        	if(selectedCurCountry == '' && selectedCurCountry == null) selectedCurCountry = countries.get('default').Country_Name__c;
        	if(selectedPreCountry == '' && selectedPreCountry == null) selectedPreCountry = countries.get('default').Country_Name__c;*/
        	defaultCountry = countries.get('default').Country_Name__c;

        	lsOptions.add(new SelectOption(countries.get('default').Country_Name__c, countries.get('default').Country_Name__c));
        }

        lsOptions.add(new SelectOption('', '-- Select One --'));
        // Sort them by name
        List<String> countryNames = new List<String>(countries.keySet());
        countryNames.sort();
        // Create the Select Options.
        for (String countryName : countryNames) {
            CountryCodes__c country = countries.get(countryName);
            if(country!=null && country.Name != 'default') lsOptions.add(new SelectOption(country.Country_Name__c, country.Country_Name__c));
        }
        return lsOptions;
    }

    private Account createAccount() {
        System.debug('createAccount: Company Name is '+webAccount.Name+' usertype is '+UserInfo.getUserType()+ ' userid is '+UserInfo.getUserId());
        /* Workaround for validation errors - if required
        webAccount.billingstreet = this.streetName;
        webAccount.billingcity = this.cityName;
        webAccount.billingpostalcode = this.postalcode;
        */
        if (webAccount.Id!=null) upsert webAccount; else insert webAccount;
        return webAccount;
    }

    private Contact createContact(Id accId) {
        webContact.AccountId = accId;
        webContact.Date_of_Birth__c = getDateOfBirth();
        if (webContact.Id!=null) upsert webContact; else insert webContact;
        return webContact;
    }
    //SW CDECISIONS 21/06/2012 - added idvResponse parameter to store id check data on credit vet record as well
    private Credit_Vet__c createCreditVet(Id accId, Id oppId, CreditCheckSOAHandler.CreditCheckResponse idvResponse, String error) {
    	RecordType creditVetRT = [Select r.SobjectType, r.Name, r.IsActive, r.Id, r.DeveloperName From RecordType r where r.SobjectType='Credit_Vet__c' and r.IsActive= true and r.DeveloperName = 'Credit_Vet_Online_Shop'];
    	webCreditVet.Name__c = firstName+' '+lastName;
    	webCreditVet.RecordTypeId = creditVetRT.Id;
    	webCreditVet.Date_of_Birth__c = getDateOfBirth();
    	webCreditVet.Number_Of_Employees__c=Integer.valueOf(numberofEmp);
    	webCreditVet.Opportunity__c = oppId;
    	webCreditVet.Company_Name__c = accId;
    	//if the IDV check is enabled and has returned a non-null response, then save it to the credit vet record here
    	//System.debug('### OUTPUT >>>>> createCreditVet: idvResponse: '+idvResponse);
    	System.debug('### OUTPUT >>>>> createCreditVet: error: '+error);
    	if (getcreditCheckEnabled() && idvResponse!=null) {
    		webCreditVet.IDV_Result__c = CreditCheckSettings__c.getInstance(idvResponse.creditCheckResultCode).Code__c;
    		webCreditVet.IDV_Result_Code__c = idvResponse.creditCheckResultCode + ' - ' + CreditCheckSettings__c.getInstance(idvResponse.creditCheckResultCode).Value__c;
    		List<String> sCodes = idvResponse.reasonCodeMap;
    		System.debug('### OUTPUT >>>>> createCreditVet: sCodes: '+sCodes);
    		webCreditVet.IDV_Reason_Code__c = (sCodes!=null && sCodes.size()>0 ? sCodes[0] : null);
    		if (CreditCheckSettings__c.getInstance(sCodes[0])!=null) {
    			webCreditVet.IDV_Reason_Description__c = (sCodes!=null && sCodes.size()>0 ? CreditCheckSettings__c.getInstance(sCodes[0]).Value__c : null);
    		}
    	}
    	else if (error!=null && error!='') {
    		webCreditVet.IDV_Result__c = 'Error';
    		webCreditVet.IDV_Reason_Description__c = error;
    	}
    	//System.debug('### OUTPUT >>>>> createCreditVet: webCreditVet: '+webCreditVet);
    	if (webCreditVet.Id!=null) upsert webCreditVet; else insert webCreditVet;
    	return webCreditVet;
    }

	//#######################################
	//##### BASKET DETAILS AND PRICES #######
	//#######################################
    public cscfgc__Product_Basket__c getcurrentBasket() {
    	if (sessionbasket!=null) {
	    	currentBasket = [SELECT Id, Name, cscfgc__User_Session__c, cscfgc__Total_Price__c, cscfgc__Shared_Context_Configuration__c, cscfgc__Opportunity__c, cscfgc__Basket_Status__c
			                  FROM   cscfgc__Product_Basket__c
			                  WHERE  Id = :sessionbasket.Id LIMIT 1];
            currentConfigs = [SELECT Id, Name, cscfgc__Total_Price__c, cscfgc__Recurring_Charge__c, cscfgc__Product_Basket__c, cscfgc__Product_Bundle__c, cscfgc__One_Off_Charge__c,
                        		cscfgc__configuration_status__c, cscfgc__Parent_Configuration__c, cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name, cscfgc__Screen_Flow__r.Name,
                    			(SELECT Id, Name, cscfgc__Price__c FROM cscfgc__Attributes__r
                    				WHERE cscfgc__Is_Line_Item__c=true AND cscfgc__Recurring__c=false AND cscfgc__Price__c <> null)
		                         FROM cscfgc__Product_Configuration__c
		                         WHERE cscfgc__Product_Basket__c=:currentBasket.Id ORDER BY cscfgc__Serial_Number__c desc];
    	}
    	return currentBasket;
    }
    public cscfgc__Product_Configuration__c[] getBasketProducts() {
        currentBasket = getCurrentBasket();
        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
        if (currentBasket!=null) {
            configs = currentConfigs;
        }
        return configs;
    }
    public Decimal getTotalRecurring() {
    	totalRecurring = 0.0;
    	currentBasket = getCurrentBasket();
    	System.debug('***currentBasket' +currentBasket);
    	System.debug('***currentConfigs' +currentConfigs);
    	if (currentBasket != null) {
	        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
	        for (cscfgc__Product_Configuration__c cfg: currentConfigs) {
	            totalRecurring += cfg.cscfgc__Recurring_Charge__c;
	        }
    	}
    	System.debug('***totalRecurring'+totalRecurring);
    	webCreditVet.Amount__c = totalRecurring;
    	return totalRecurring;
    }
  	public Decimal getTotalOneOff() {
 		Decimal totalOneOff = 0.0;
    	currentBasket = getCurrentBasket();
    	if (currentBasket!=null) {
	        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
	        for (cscfgc__Product_Configuration__c cfg: currentConfigs) {
				//SW CDECISIONS 21/12/2011 - added conditional if savings detected, so calculated from actual attribs
				if (cfg.cscfgc__Attributes__r != null) {
	    			for (cscfgc__Attribute__c att: cfg.cscfgc__Attributes__r) {
	    				if (att.cscfgc__Price__c > 0) totalOneOff += att.cscfgc__Price__c;
	    			}
				}
	            else totalOneOff += cfg.cscfgc__One_Off_Charge__c;
	        }
    	}
 		return totalOneOff;
 	}
    public class BasketConfiguration {
    	public cscfgc__Product_Configuration__c cfg {get;set;}
    	public Decimal dRecurringPrice {get;set;}
    	public Decimal dOneOffPrice {get;set;}
    	public BasketConfiguration() {}
    	public Integer index {get;set;}

    }

    public BasketConfiguration[] getBasketConfigs() {
        BasketConfiguration[] basketconfigs = new BasketConfiguration[0];
        cscfgc__Product_Configuration__c[] configs = new cscfgc__Product_Configuration__c[0];
        configs = getBasketProducts();
        if (configs!=null && configs.size()>0) {
        	//build list of parent cfgs
        	List<cscfgc__Product_Configuration__c> parCfgList = new List<cscfgc__Product_Configuration__c>();
        	for (cscfgc__Product_Configuration__c cfg: configs) {
        		if (cfg.cscfgc__Parent_Configuration__c == null && cfg.cscfgc__configuration_status__c != DRAFT_STATUS) parCfgList.add(cfg);
        	}
        	//cycle through all configs, calc prices, and build list of output basket configs
        	if (parCfgList!=null && parCfgList.size()>0) {
        		Integer i=0;
        		for (cscfgc__Product_Configuration__c parcfg: parCfgList) {
        			BasketConfiguration bsk = new BasketConfiguration();
        			bsk.cfg = parcfg;
        			bsk.dRecurringPrice = 0;
        			bsk.dOneOffPrice = 0;
        			bsk.index = i++;
        			for (cscfgc__Product_Configuration__c c: configs) {
        				if (c.Id == parcfg.Id || c.cscfgc__Parent_Configuration__c == parcfg.Id) {
        					bsk.dRecurringPrice += c.cscfgc__Recurring_Charge__c;
        					//SW CDECISIONS 21/12/2011 - added conditional if savings detected, so calculated from actual attribs
		        			if (c.cscfgc__Attributes__r != null) {
			        			for (cscfgc__Attribute__c att: c.cscfgc__Attributes__r) {
			        				if (att.cscfgc__Price__c > 0) bsk.dOneOffPrice += att.cscfgc__Price__c;
			        			}
		        			}
        					else bsk.dOneOffPrice += c.cscfgc__One_Off_Charge__c;
        				}
        			}
        			basketconfigs.add(bsk);
        		}
        	}
        }
        return basketconfigs;
    }

    public String orderRequestNumber{get;set;}
    public Decimal orderValue {get;set;}	//SW CDECISIONS 17/04/2012 - ADDED FOR WEBCHAT OUTPUT ON ORDER CONFIRMATION PAGE

	//#######################################
	//#######################################


    public class O2OnlineException extends Exception {}

    public Map<ID, Location__c> savedLocations = new Map<ID, Location__c>();
    public Map<String, Location__c> locTypes = new Map<String, Location__c>();

    public List<Location__c> newLocations = new List<Location__c>();
    public List<Location__c> savedLocationList = new List<Location__c>();
    public List<Location__c> nonPAFLocationList = new List<Location__c>();
    public String selectedAddressIndex {get;set;}
    public String selectedDirectorsAddressIndex {get;set;}
    public String selectedDirPreviousAddressIndex {get;set;}
    public List<SelectOption> getsavedLocationList() {
		List<Location__c> loclist = [SELECT Id, Name, Number_and_Street__c, Building_Unit_Name__c, PAF_Sub_Building_Name__c, PAF_Building_Name__c, PAF_Building_Number__c, Street__c,
									 PAF_Post_Town__c, PAF_County__c, PAF_Postcode__c, PAF_Thoroughfare_Name__c, PAF_Thoroughfare_Descriptor__c, PAF_Dependent_Locality__c, Country__c, Name_and_Street__c
									 FROM Location__c WHERE User_Session__c = :userSession.userSession.Id];
		if (loclist!=null && loclist.size()>0) {savedLocations = new Map<ID, Location__c>(loclist);}
		return convertSavedLocationList(loclist);
	}

    public PageReference performCheckout() {
        CreditCheckSOAHandler.CreditCheckResponse idvResponse;
        String errIDVCheck;
    	try {
	        System.debug('### OUTPUT >>>>> performCheckout: sessionbasket: ' + sessionbasket);
	        //check all required fields are supplied
	        if (agreeTerms==null || !agreeTerms) {throw new O2OnlineException('You must agree to our Terms and Conditions in order to proceed.');}
	        // Inflate the basket object
	        if (sessionbasket!=null && currentBasket==null) {
				currentBasket = getcurrentBasket();
	        }

	        //SW CDECISIONS 21/06/2012 - added code to conditionally perform IDV check if enabled - this is done first before any DML operations to avoid 'you have uncommitted work pending' errors
	        if (getCreditCheckEnabled()) {
	        	try {idvResponse = performIDCheck();}
	        	catch (CreditCheckSOAHandler.ResponseException re) {
	        		addError('IDV Check','IDV Check Response Error: '+re.getMessage(),'');
	        		if (re.getMessage().length()>254) errIDVCheck=re.getMessage().substring(0, 254); else errIDVCheck=re.getMessage();
	        	}
	        	catch (Exception e) {
	        		addError('IDV Check','IDV Check General Error: '+e.getMessage(),'');
	        		if (e.getMessage().length()>254) errIDVCheck=e.getMessage().substring(0, 254); else errIDVCheck=e.getMessage();
	        	}
	        }
	        //System.debug('### OUTPUT >>>>> performCheckout: idvResponse:'+idvResponse);
	        System.debug('### OUTPUT >>>>> performCheckout: errIDVCheck:'+errIDVCheck);

	        // Create the Account & Contact from the details entered at Checkout
	        Account acc = createAccount();
	        Contact con = createContact(acc.Id);

	        // Create the Opportunity and Product Bundle from the basket
	        System.debug('### OUTPUT >>>>> performCheckout: opptyFields: '+opptyFields);
	        //Email address for Email confirmation after checkout
	        opptyFields.put('ConfirmationEmailAddr', con.Email);

    		cscfgc__Product_Bundle__c bundle = O2OrderHelper.createOpportunityBundle(con.Id, acc, currentBasket, opptyFields);

	        Id oppId = bundle.cscfgc__Opportunity__c;

	        BundleId = bundle.Id;

	        // get order request number from opportunity to display it on Thank you page.
	        //SW CDECISIONS 17/04/2012 - added bundle retrieval into below query to get total bundle value for webchat tracking in confirmation page
	        Opportunity orderOpp = [Select Id, Order_Request_Number__c, (Select id, cscfgc__Bundle_Status__c, cscfgc__Total_Price__c from cscfgc__Product_Bundles__r WHERE Id=:bundle.Id) from Opportunity where Id= :oppId];
	        orderRequestNumber = orderOpp.Order_Request_Number__c;
	        if (orderOpp!=null && orderOpp.cscfgc__Product_Bundles__r!=null) orderValue = orderOpp.cscfgc__Product_Bundles__r[0].cscfgc__Total_Price__c;	//SW CDECISIONS 17/04/2012 - added to set total order value for webchat code in confirmation page

	        //
	        // Added Josip J. (26/6/12): requirement to auto-synchronize valid bundles
	        //cscfgc__Product_Bundle__c refreshedBundle = [select id, cscfgc__Bundle_Status__c from cscfgc__Product_Bundle__c where id = :bundle.id];
	        if (orderOpp!=null && orderOpp.cscfgc__Product_Bundles__r!=null && orderOpp.cscfgc__Product_Bundles__r[0].cscfgc__Bundle_Status__c == 'Valid') {
	        	O2OrderHelper.synchBundleWithOpportunity(bundle);
	        	//cscfgc.API_1.syncBundleToOpportunity((string)orderOpp.cscfgc__Product_Bundles__r[0].id);
	        }

	        //Addeed Ivor Goreta 14.02.2013 Bundle must be synched before mail is sent after stage is set to Decision.
	        //orderOpp.StageName = 'Decision';
	        //update orderOpp;

	        Credit_Vet__c  creditV = createCreditVet(acc.Id, oppId, idvResponse, errIDVCheck);	//SW CDECISIONS 21/06/2012 - added param and moved to after the opportunity is requeried in order to perform IDV check

			if(!locTypes.containsKey('Billing') && (postalCode != null && postalCode != ''))
			{
				//if(selectedCountry == '' || selectedCountry == null) selectedCountry = defaultCountry;
				saveNonPAFLocations('Billing', flatNumber, buildingName, buildingNo, postalCode, streetName, cityName, countyName, selectedCountry);

			}

			if(!locTypes.containsKey('Registered') && (postalCode != null && postalCode != ''))
			{
				//if(selectedCountry == '' || selectedCountry == null) selectedCountry = defaultCountry;
	        	saveNonPAFLocations('Registered', flatNumber, buildingName, buildingNo, postalCode, streetName, cityName, countyName, selectedCountry);

			}

			if(!locTypes.containsKey('Director/Proprietor') && (dirPostalCode != null && dirPostalCode != ''))
			{
				//if(selectedCurCountry == '' || selectedCurCountry == null) selectedCurCountry = defaultCountry;
	        	saveNonPAFLocations('Director/Proprietor', dirFlatNumber, dirBuildingName, dirBuildingNo, dirPostalCode, dirStreetName, dirCityName, dirCountyName, selectedCurCountry);

			}

			if(!locTypes.containsKey('Director/Proprietor Previous') && (dirPrePostalCode != null && dirPrePostalCode != ''))
			{
				if(previousAddrYear != null && previousAddrYear != '' && previousAddrYear != '-' && previousAddrYear != '3+')
				{
					//if(selectedPreCountry == '' || selectedPreCountry == null) selectedPreCountry = defaultCountry;
	        		saveNonPAFLocations('Director/Proprietor Previous', dirPreFlatNumber, dirPreBuildingName, dirPreBuildingNo, dirPrePostalCode, dirPreStreetName, dirPreCityName, dirPreCountyName, selectedPreCountry);
				}
			}
			upsertLocationRecord(nonPAFLocationList,acc,con,creditV);

	        upsertLocationRecord(newLocations,acc,con,creditV);
	        upsertLocationRecord(savedLocationList,acc,con,creditV);

	        //close the session
	        if (apiSession!=null) apiSession.close();	// SW 08/08/2011 - ASSERT: this should never fire since we have not initialised apiSession
    	}
    	catch (Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    		return null;
    	}
        if (getCreditCheckEnabled() && (/*ApexPages.hasMessages() || */(idvResponse!=null && idvResponse.creditCheckResultCode!=null && CreditCheckSettings__c.getInstance(idvResponse.creditCheckResultCode)!=null && CreditCheckSettings__c.getInstance(idvResponse.creditCheckResultCode).Code__c!='Accept' && CreditCheckSettings__c.getInstance(idvResponse.creditCheckResultCode).Code__c!='Decline'))) return Page.O2OnlineCheckoutResultFail;
        else return Page.O2OnlineCheckoutResult;
    }

    public void upsertLocationRecord(List<Location__c> upsertList, Account acc, Contact con, Credit_Vet__c creditV)
    {
    	if(upsertList != null)
	        {
	        	List<Location__c> locUpsertList = new List<Location__c>();
	        	for(Location__c newLocation : upsertList)
	        	{
	        		if(newLocation.Type__c == 'Billing' )
	        		{
	        			newLocation.Account__c = acc.Id;
	        		}
	        		else if(newLocation.Type__c == 'Registered')
	        		{
	        			newLocation.Account__c = acc.Id;
	        			newLocation.Credit_Vet__c = creditV.Id;
	        		}
	        		else
	        		{
	        			if(newLocation.Type__c == 'Director/Proprietor')
	        			{
	        				if (previousAddrMonth!=null && previousAddrMonth!='' && previousAddrMonth!='-') newLocation.Months__c = previousAddrMonth;
	        				if (previousAddrYear!=null && previousAddrYear!='' && previousAddrYear!='-') newLocation.Years__c = previousAddrYear;
	        			}
	        			newLocation.Contact__c = con.Id;
	        			newLocation.Credit_Vet__c = creditV.Id;
	        		}
	        		newLocation.User_Session__c = userSession.userSession.Id;
	        		locUpsertList.add(newLocation);
	        	}
	        	upsert locUpsertList;
	        }

    }

  //  public Boolean movingMobileNum {get; set;} //AK
    public Boolean movingMobileNum{get; set{
    	   webCreditVet.movingMobileNum__c = value;
    	}
    }

    public Boolean newRegisteredAddress {get { if (newRegisteredAddress==null) return true; else return newRegisteredAddress;} set;}
    public String selectedRegisteredAddress {get;set;}


    public void selectSavedRegisteredAddress() {
    	selectAddress(savedLocations.get(selectedAddressIndex), 'registered');
    	saveSelectedLocations('Billing',savedLocations.get(selectedAddressIndex));
    	saveSelectedLocations('Registered',savedLocations.get(selectedAddressIndex));
    }

    public void saveNonPAFLocations(String strType, String nonPAFFlatNumber, String nonPAFBuildingName, String nonPAFBuildingNumber, String nonPAFPostalCode, String nonPAFStreet, String nonPAFCity, String nonPAFCounty, String nonPAFCountry){
    	Location__c nonPAFLocation = new Location__c(
    								Type__c = strType,
									Sync_with_Parent__c = true,
									PAF_Sub_Building_Name__c = nonPAFFlatNumber,
									PAF_Building_Name__c = nonPAFBuildingName,
									PAF_Building_Number__c = nonPAFBuildingNumber,
									PAF_Dependent_Thoroughfare_Descriptor__c = '',
									PAF_Thoroughfare_Descriptor__c = '',
									PAF_Thoroughfare_Name__c = nonPAFStreet,
									PAF_Post_Town__c = nonPAFCity,
									PAF_County__c = nonPAFCounty,
									PAF_Postcode__c = nonPAFPostalCode,
									Country__c = nonPAFcountry);
		nonPAFLocationList.add(nonPAFLocation);

    }

    public void saveSelectedLocations(String strType, Location__c oldLoc)
    {
    	Location__c savedNewLoc;
    	if(savedLocations != null && savedLocations.values().size() > 0)
    	{
			if(oldLoc != null)
			{
				savedNewLoc = new Location__c(
							Type__c = strType,
							Sync_with_Parent__c = true,
							PAF_Sub_Building_Name__c = oldLoc.PAF_Sub_Building_Name__c,
							PAF_Building_Name__c = oldLoc.PAF_Building_Name__c,
							PAF_Building_Number__c = oldLoc.PAF_Building_Number__c,
							//PAF_Organisation_Name__c = oldLoc.PAF_Organisation_Name__c,
							//PAF_Dependent_Thoroughfare__c = oldLoc.PAF_Dependent_Thoroughfare__c,
							PAF_Dependent_Thoroughfare_Descriptor__c = '',
							PAF_Thoroughfare_Name__c = oldLoc.PAF_Thoroughfare_Name__c,
							PAF_Thoroughfare_Descriptor__c = '',
							//PAF_Double_Dependent_Locality__c = oldLoc.PAF_Double_Dependent_Locality__c,
							PAF_Dependent_Locality__c = oldLoc.PAF_Dependent_Locality__c,
							PAF_Post_Town__c = oldLoc.PAF_Post_Town__c,
							PAF_County__c = oldLoc.PAF_County__c,
							PAF_Postcode__c = oldLoc.PAF_Postcode__c,
							Country__c = oldLoc.Country__c
							);

				savedLocationList.add(savedNewLoc);
				locTypes.put(strType, savedNewLoc);
    		}
    	}
    }

    public void selectRegisteredAddress() {
    	saveAndSelectAddress(selectedRegisteredAddress, 'registered');
    }
    //method to set UI field variables
	public void selectAddress(Location__c selectedloc, String strType) {
		if (strType == 'registered' && selectedloc!=null) {
			if (selectedloc.PAF_Building_Name__c!=null) buildingName = selectedloc.PAF_Building_Name__c;
			if (selectedloc.PAF_Sub_Building_Name__c!=null) flatNumber = selectedloc.PAF_Sub_Building_Name__c;
			if (selectedloc.PAF_Building_Number__c!=null) buildingNo = selectedloc.PAF_Building_Number__c;
			if (selectedloc.PAF_Thoroughfare_Name__c!=null) streetName = selectedloc.PAF_Thoroughfare_Name__c;
			if (selectedloc.PAF_Thoroughfare_Descriptor__c!=null) streetName += selectedloc.PAF_Thoroughfare_Descriptor__c;
			if (selectedloc.PAF_Post_Town__c!=null) cityName = selectedloc.PAF_Post_Town__c;
			if (selectedloc.PAF_County__c!=null) countyName = selectedloc.PAF_County__c;
			if (selectedloc.PAF_Postcode__c!=null) postalCode = selectedloc.PAF_Postcode__c;
			if (selectedloc.Country__c!=null) selectedCountry = selectedloc.Country__c;
		}
		else if(strType == 'director' && selectedloc!=null)
		{
			if (selectedloc.PAF_Building_Name__c!=null) dirBuildingName = selectedloc.PAF_Building_Name__c;
			if (selectedloc.PAF_Sub_Building_Name__c!=null) dirFlatNumber = selectedloc.PAF_Sub_Building_Name__c;
			if (selectedloc.PAF_Building_Number__c!=null) dirBuildingNo = selectedloc.PAF_Building_Number__c;
			if (selectedloc.PAF_Thoroughfare_Name__c!=null) dirStreetName = selectedloc.PAF_Thoroughfare_Name__c;
			if (selectedloc.PAF_Thoroughfare_Descriptor__c!=null) dirStreetName += selectedloc.PAF_Thoroughfare_Descriptor__c;
			if (selectedloc.PAF_Post_Town__c!=null) dirCityName = selectedloc.PAF_Post_Town__c;
			if (selectedloc.PAF_County__c!=null) dirCountyName = selectedloc.PAF_County__c;
			if (selectedloc.PAF_Postcode__c!=null) dirPostalCode = selectedloc.PAF_Postcode__c;
			if (selectedloc.Country__c!=null) selectedCurCountry = selectedloc.Country__c;
		}
		else if(strType == 'directorprevious' && selectedloc!=null)
		{
			if (selectedloc.PAF_Building_Name__c!=null) dirPreBuildingName = selectedloc.PAF_Building_Name__c;
			if (selectedloc.PAF_Sub_Building_Name__c!=null) dirPreFlatNumber = selectedloc.PAF_Sub_Building_Name__c;
			if (selectedloc.PAF_Building_Number__c!=null) dirPreBuildingNo = selectedloc.PAF_Building_Number__c;
			if (selectedloc.PAF_Thoroughfare_Name__c!=null) dirPreStreetName = selectedloc.PAF_Thoroughfare_Name__c;
			if (selectedloc.PAF_Thoroughfare_Descriptor__c!=null) dirPreStreetName += selectedloc.PAF_Thoroughfare_Descriptor__c;
			if (selectedloc.PAF_Post_Town__c!=null) dirPreCityName = selectedloc.PAF_Post_Town__c;
			if (selectedloc.PAF_County__c!=null) dirPreCountyName = selectedloc.PAF_County__c;
			if (selectedloc.PAF_Postcode__c!=null) dirPrePostalCode = selectedloc.PAF_Postcode__c;
			if (selectedloc.Country__c!=null) selectedPreCountry = selectedloc.Country__c;
		}
		else if (strType==null || strType=='') {
			throw new O2OnlineCheckoutException('Could not determine address type to select. Please use the contact form to notify us of this fault.');
		}
	}

    //perform search for router address and show results in output selectoptions
	public List<AddressCheckController.Address> registeredResAddresses;
	public List<selectOption> registeredAddresses {get;set;}
	public PageReference searchRegisteredAddresses() {
		coremetricValidationDataList = new CoremetricsValidationData[]{};

		List<selectOption> outputOptions = new List<selectOption>();
		registeredResAddresses = findAddresses(buildingName, buildingNo, postalCode);

		if (registeredResAddresses!=null && registeredResAddresses.size()>0) {
			//populate selectlist records from results list
			outputOptions.add(new SelectOption('', '-Select address-'));
			for (integer i=0; i<registeredResAddresses.size(); i++) {
				String strAddr = '';
				if (registeredResAddresses[i].subBuildingName!=null && registeredResAddresses[i].subBuildingName!='') strAddr+=registeredResAddresses[i].subBuildingName+',';
				if (registeredResAddresses[i].buildingName!=null && registeredResAddresses[i].buildingName!='') strAddr+=registeredResAddresses[i].buildingName+',';
				if (registeredResAddresses[i].buildingNumber!=null && registeredResAddresses[i].buildingNumber!='') strAddr+=registeredResAddresses[i].buildingNumber+',';
				if (registeredResAddresses[i].street!=null && registeredResAddresses[i].street!='') strAddr+=registeredResAddresses[i].street+',';
				if (strAddr!='') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-1)));
			}
		}
		else {
			if(postalCode!=null && postalCode!=' ') {addError('Postcode', 'Postcode is required. Please enter the postcode.', postalCode);}

			//populate selectlist with 'NO RESULTS' marker
			outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
		}
		registeredAddresses = outputOptions;
		return null;
	}


	//Director's address
	public Boolean newDirectorsAddress {get { if (newDirectorsAddress==null) return true; else return newDirectorsAddress;} set;}
	public String selectedDirectorsAddress {get;set;}


    public void selectSavedDirectorsAddress() {
    	selectAddress(savedLocations.get(selectedDirectorsAddressIndex), 'director');
    	saveSelectedLocations('Director/Proprietor',savedLocations.get(selectedDirectorsAddressIndex));

    }

    //perform search for router address and show results in output selectoptions
	public List<AddressCheckController.Address> directorsResAddresses;
	public List<selectOption> directorsAddresses {get;set;}
	public PageReference searchdirectorsAddresses() {
		List<selectOption> outputOptions = new List<selectOption>();
		directorsResAddresses = findAddresses(dirBuildingName, dirBuildingNo, dirPostalCode);

		if (directorsResAddresses!=null && directorsResAddresses.size()>0) {
			//populate selectlist records from results list
			outputOptions.add(new SelectOption('', '-Select address-'));
			for (integer i=0; i<directorsResAddresses.size(); i++) {
				String strAddr = '';
				if (directorsResAddresses[i].subBuildingName!=null && directorsResAddresses[i].subBuildingName!='') strAddr+=directorsResAddresses[i].subBuildingName+',';
				if (directorsResAddresses[i].buildingName!=null && directorsResAddresses[i].buildingName!='') strAddr+=directorsResAddresses[i].buildingName+',';
				if (directorsResAddresses[i].buildingNumber!=null && directorsResAddresses[i].buildingNumber!='') strAddr+=directorsResAddresses[i].buildingNumber+',';
				if (directorsResAddresses[i].street!=null && directorsResAddresses[i].street!='') strAddr+=directorsResAddresses[i].street+',';
				if (strAddr!='') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-1)));
			}
		}
		else {
			if(dirPostalCode!=null && dirPostalCode!=' ') {addError('Postcode', 'Postcode is required. Please enter the postcode.', dirPostalCode);}

			//populate selectlist with 'NO RESULTS' marker
			outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
		}
		directorsAddresses = outputOptions;
		return null;
	}


	public void selectDirectorsAddress() {
    	saveAndSelectAddress(selectedDirectorsAddress, 'director');
    }


    //Direcotor's previous address
    public Boolean newDirectorsPrevAddress {get { if (newDirectorsPrevAddress==null) return true; else return newDirectorsPrevAddress;} set;}
    public String selectedDirectorsPrevAddress {get;set;}

    public void selectSavedDirectorsPreAddress() {
    	selectAddress(savedLocations.get(selectedDirPreviousAddressIndex), 'directorprevious');
    	saveSelectedLocations('Director/Proprietor Previous',savedLocations.get(selectedDirPreviousAddressIndex));
    }

    //perform search for router address and show results in output selectoptions
	public List<AddressCheckController.Address> directorsPrevResAddresses;
	public List<selectOption> directorsPrevAddresses {get;set;}
	public PageReference searchDirectorsPrevAddresses() {
		List<selectOption> outputOptions = new List<selectOption>();

		directorsPrevResAddresses = findAddresses(dirPreBuildingName, dirPreBuildingNo, dirPrePostalCode);

		if (directorsPrevResAddresses != null && directorsPrevResAddresses.size()>0) {
			//populate selectlist records from results list
			outputOptions.add(new SelectOption('', '-Select address-'));
			for (integer i=0; i<directorsPrevResAddresses.size(); i++) {
				String strAddr = '';
				if (directorsPrevResAddresses[i].subBuildingName!=null && directorsPrevResAddresses[i].subBuildingName!='') strAddr+=directorsPrevResAddresses[i].subBuildingName+',';
				if (directorsPrevResAddresses[i].buildingName!=null && directorsPrevResAddresses[i].buildingName!='') strAddr+=directorsPrevResAddresses[i].buildingName+',';
				if (directorsPrevResAddresses[i].buildingNumber!=null && directorsPrevResAddresses[i].buildingNumber!='') strAddr+=directorsPrevResAddresses[i].buildingNumber+',';
				if (directorsPrevResAddresses[i].street!=null && directorsPrevResAddresses[i].street!='') strAddr+=directorsPrevResAddresses[i].street+',';
				if (strAddr!='') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-1)));
			}
		}
		else {
			if(dirPrePostalCode!=null && dirPrePostalCode!=' ') {addError('Postcode', 'Postcode is required. Please enter the postcode.', dirPrePostalCode);}
			//populate selectlist with 'NO RESULTS' marker
			outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
		}
		directorsPrevAddresses = outputOptions;
		return null;
	}

	public void selectDirectorsPrevAddress() {
    	saveAndSelectAddress(selectedDirectorsPrevAddress, 'directorprevious');
    }



	public List<AddressCheckController.Address> findAddresses (String pafBuildingName, String pafBuildingNumber, String pafPostcode) {
		List<AddressCheckController.Address> resAddresses;
		try {
			System.debug('### OUTPUT >>>>> findAddresses: method start');
			AddressCheckController pafcontroller = new AddressCheckController();
			if (pafBuildingName!=null) pafcontroller.buildingName = pafBuildingName;
			if (pafBuildingNumber!=null) pafcontroller.buildingNumber = pafBuildingNumber;
			if (pafPostcode!=null && pafPostcode !=' ') pafcontroller.postcode = pafPostcode;
			system.debug('### OUTPUT >>>>> postal code: value in find address '+pafPostcode);
			if (pafcontroller.postcode!=null && pafcontroller.postcode!='') {
				PageReference resPage = pafcontroller.addressSearch();
				resAddresses = pafcontroller.addressResults;
				system.debug('### OUTPUT >>>>> resAddresses: value in find address '+resAddresses);
			}
		}
		catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));}
		return resAddresses;
	}


	//method to convert Location__c list to selectoptions list
	public List<SelectOption> convertSavedLocationList(Location__c[] loclist) {
		List<SelectOption> outputOptions = new List<SelectOption>();
		if (loclist!=null && loclist.size()>0) {
			outputOptions.add(new SelectOption('', '-Select address-'));
			for (Integer i=0; i<loclist.size(); i++) {
				if (loclist[i].Name_and_Street__c!=null && loclist[i].Name_and_Street__c!='')
					outputOptions.add(new SelectOption(loclist[i].Id, loclist[i].Name_and_Street__c));
			}
		}
		else {outputOptions.add(new SelectOption('NO ADDRESSES SAVED', 'NO ADDRESSES SAVED'));}
		return outputOptions;
	}

	//method to save selected paf result address to session Locations list, and then select ie. set UI field variables
	public void saveAndSelectAddress(String index, String addrType) {
		if (addrType=='registered') {
			if (registeredResAddresses!=null && registeredResAddresses.size()>0 && index!=null && index!='') {
				integer i = Integer.valueOf(index);
				System.debug('### OUTPUT >>>>> setSaveAddress: resAddresses:'+registeredResAddresses[i]);
				Location__c newLoc = createSavedSessionLocation(registeredResAddresses[i], 'Billing', userSession.userSession.Id);
				Location__c newLocReg = createSavedSessionLocation(registeredResAddresses[i], 'Registered', userSession.userSession.Id);
				selectAddress(newLoc, addrType);
			}
		}
		else if(addrType=='director')
		{
			if (directorsResAddresses!=null && directorsResAddresses.size()>0 && index!=null && index!='') {
				integer i = Integer.valueOf(index);
				System.debug('### OUTPUT >>>>> setSaveAddress: resAddresses:'+directorsResAddresses[i]);
				Location__c newLoc = createSavedSessionLocation(directorsResAddresses[i], 'Director/Proprietor', userSession.userSession.Id);
				selectAddress(newLoc, addrType);
			}
		}
		else if(addrType=='directorprevious')
		{
			if (directorsPrevResAddresses!=null && directorsPrevResAddresses.size()>0 && index!=null && index!='') {
				integer i = Integer.valueOf(index);
				System.debug('### OUTPUT >>>>> setSaveAddress: resAddresses:'+directorsPrevResAddresses[i]);
				Location__c newLoc = createSavedSessionLocation(directorsPrevResAddresses[i], 'Director/Proprietor Previous', userSession.userSession.Id);
				selectAddress(newLoc, addrType);
			}
		}
		else {
			throw new O2OnlineCheckoutException('Could not determine address type to save. Please use the contact form to notify us of this fault.');
		}
	}


	//method to create session Location record and if successful add to cached locations map
	public Location__c createSavedSessionLocation(AddressCheckController.Address addr, String strType, ID sessId) {
		Location__c newLoc;
		try {
			if (addr!=null) {
				newLoc = new Location__c(
					Type__c = strType,
					Sync_with_Parent__c = true,
					PAF_Sub_Building_Name__c = addr.subBuildingName,
					PAF_Building_Name__c = addr.buildingName,
					PAF_Building_Number__c = addr.buildingNumber,
					PAF_Organisation_Name__c = addr.organisation,
					PAF_Dependent_Thoroughfare__c = addr.dependentStreet,
					PAF_Dependent_Thoroughfare_Descriptor__c = '',
					PAF_Thoroughfare_Name__c = addr.street,
					PAF_Thoroughfare_Descriptor__c = '',
					PAF_Double_Dependent_Locality__c = addr.dependentLocality,
					PAF_Dependent_Locality__c = addr.locality,
					PAF_Post_Town__c = addr.postTown,
					PAF_County__c = addr.county,
					PAF_Postcode__c = addr.postcode,
					Country__c = countryNameByType(strType)
				);
				//insert newLoc;	//insert moved to the AddToBasket method since we will then have a config id to include
				newLocations.add(newLoc);
				locTypes.put(strType, newLoc);
			}
		}
		catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));}
		return newLoc;
	}



	public String countryNameByType(String locType)
	{
		String countryName;
		if(locType == 'Billing' || locType == 'Registered')
		{
			if(selectedCountry != '' && selectedCountry != null)  countryName = selectedCountry; else countryName = defaultCountry;
		}
		else if(locType == 'Director/Proprietor')
		{
			if(selectedCurCountry != '' && selectedCurCountry != null)  countryName = selectedCurCountry; else countryName = defaultCountry;
		}
		else
		{
			if(selectedPreCountry != '' && selectedPreCountry != null)  countryName = selectedPreCountry; else countryName = defaultCountry;
		}

		return countryName;
	}


    public class O2OnlineCheckoutException extends Exception {}

	//PAYMENT CODE AND METHODS
	public String bankBuildingSociety
	{get;set
		{
			bankBuildingSociety = value;
			webCreditVet.Bank_or_Building_Society__c = value;
			opptyFields.put('bankBuildingSociety', String.valueOf(value));
		}
	}
	public String bankAccountName
	{get;set
		{
			bankAccountName = value;
			webCreditVet.Bank_Account_Name__c = value;
			opptyFields.put('bankAccountName', String.valueOf(value));
		}
	}
	public String bankSortCode {get;set;}
	public String bankSortBit1 {get;set;}
	public String bankSortBit2 {get;set;}
	public String bankSortBit3 {
		get;
		set {
			bankSortBit3 = String.valueOf(value);
			String strRes = '';
			if (bankSortBit1!=null && bankSortBit1!='') {strRes+=bankSortBit1;}
			if (bankSortBit2!=null && bankSortBit2!='') {strRes+=bankSortBit2;}
			if (bankSortBit3!=null && bankSortBit3!='') {strRes+=bankSortBit3;}
			bankSortCode = strRes;
			webCreditVet.Bank_Account_Sort_Code__c = strRes;
			opptyFields.put('bankSortCode', strRes);
		}
	}
	public String bankAccountNumber
	{get;set
		{
			bankAccountNumber = value;
			webCreditVet.Bank_Account_Number__c = value;
			opptyFields.put('bankAccountNumber', String.valueOf(value));
		}
	}
	public Boolean confirmDetails {get;set {confirmDetails = value; opptyFields.put('confirmDetails', String.valueOf(value));}}
	public Boolean agreeTerms {get;set {agreeTerms = value; opptyFields.put('agreeTerms', String.valueOf(value));}}
	public Boolean agreeDirectDebit {get;set;}
    public Map<String, String> opptyFields;

    //############################################################################
    //### IDV Check Changes ######################################################
    //############################################################################
    public String cardType {get;set;}
    public String nameOnCard {get;set;}
    public String cardNumber {get;set;}
    public String startDateMM {get;set;}
    public String startDateYY {get;set;}
    public String expiryDateMM {get;set;}
    public String expiryDateYY {get;set;}
    public String ccvNumber {get;set;}
    public String issueNumber {get;set;}

    public Boolean getCreditCheckEnabled() {
    	Boolean boolEnabled = false;
    	if (CreditCheckSettings__c.getInstance('Online Enabled') != null && CreditCheckSettings__c.getInstance('Online Enabled').Value__c == 'Y') boolEnabled=true;
    	return boolEnabled;
    }
    public List<SelectOption> getcardTypes() {
    	List<SelectOption> retList = new List<SelectOption>();
        Map<String, CreditCheckSettings__c> mpCodes = new Map<String, CreditCheckSettings__c>();
    	if (CreditCheckSettings__c.getAll().values()!=null) {
    		for (CreditCheckSettings__c cc: CreditCheckSettings__c.getAll().values()) {
    			if (cc.Name.contains('CARDTYPE') && cc.Code__c!=null && cc.Active__c) mpCodes.put(cc.Sequence__c+cc.Code__c, cc);
    		}
    		List<String> sortList = new List<String>(mpCodes.keySet());
    		sortList.sort();
    		for (String s: sortList) {
				SelectOption opt = new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Value__c);
				opt.setEscapeItem(false);
				retList.add(opt);
    		}
    	}
    	return retList;
    }
    public List<SelectOption> getStartYears(){
    	List<SelectOption> yOptions = new List<SelectOption>();
    	yOptions.add(new SelectOption('', 'YYYY'));
    	Integer curYear = Date.today().year();
		for(Integer i=curYear-3;i<=curYear;i++) {yOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));}
    	return yOptions;
    }
    public List<SelectOption> getExpiryYears(){
    	List<SelectOption> yOptions = new List<SelectOption>();
    	yOptions.add(new SelectOption('', 'YYYY'));
    	Integer curYear = Date.today().year();
		for(Integer i=curYear;i<=curYear+3;i++) {yOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));}
    	return yOptions;
    }

    public CreditCheckSOAHandler.CreditCheckResponse performIDCheck() {
        //System.debug('### OUTPUT >>>>> performIDCheck: webCreditVet: '+webCreditVet);
		CreditCheckSOAHandler cc = new CreditCheckSOAHandler();
		CreditCheckSOAHandler.CreditCheckRequest cr = new CreditCheckSOAHandler.CreditCheckRequest();
		//defaulted IDV context data
		cr.applicationDetails.buildLevel = CreditCheckSettings__c.getInstance('CreditCheck.buildLevel').Value__c;
		cr.sourceOfSaleDetails.code = CreditCheckSettings__c.getInstance('CreditCheck.code').Value__c;
		cr.customerDetails.personalDetails.maritalStatus = CreditCheckSettings__c.getInstance('CreditCheck.maritalStatus').Value__c;
		cr.customerDetails.personalDetails.agreeToCreditCheck = CreditCheckSettings__c.getInstance('CreditCheck.agreeToCreditCheck').Value__c;
		cr.customerDetails.currentEmploymentDetails.employmentStatus = CreditCheckSettings__c.getInstance('CreditCheck.employmentStatus').Value__c;
		cr.applicationDetails.transactionDateTime = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss');
		cr.applicationDetails.transactionType = CreditCheckSettings__c.getInstance('CreditCheck.transactionType').Value__c;
		//personal details
		if (title!=null && title!='') cr.customerDetails.personalDetails.title = title;
		if (firstName!=null && firstName!='') cr.customerDetails.personalDetails.foreName = firstName;
		if (lastName!=null && lastName!='') cr.customerDetails.personalDetails.surName = lastName;
		if (day!=null && day!='' && month!=null && month!='' && year!=null && year!='') cr.customerDetails.personalDetails.dateOfBirth = year+'-'+ (month.length()<2 ? '0'+month : month) +'-'+ (day.length()<2 ? '0'+day : day);
		cr.customerDetails.personalDetails.residentialStatus = CreditCheckSettings__c.getInstance('CreditCheck.residentialStatus').Value__c;
		//current address details
		if (dirFlatOrBuildingNo!=null && dirFlatOrBuildingNo!='') cr.customerDetails.currentAddress.houseNumber = dirFlatOrBuildingNo;
		if (dirStreetName!=null && dirStreetName!='') cr.customerDetails.currentAddress.street1 = dirStreetName;
		cr.customerDetails.currentAddress.district = '';	//we don't capture district from PAF selection
		if (dirCityName!=null && dirCityName!='') cr.customerDetails.currentAddress.town = dirCityName;
		if (dirPostalCode!=null && dirPostalCode!='') cr.customerDetails.currentAddress.postcode = dirPostalCode;
		if (previousAddrYear!=null && previousAddrYear!='') cr.customerDetails.currentAddress.yearsAtAddress = previousAddrYear.replace('+', '');
		if (previousAddrMonth!=null && previousAddrMonth!='') cr.customerDetails.currentAddress.monthsAtAddress = previousAddrMonth;
		//contact details
		if (email!=null && email!='') cr.customerDetails.contactDetails.emailAddress = email;
		if (webCreditVet!=null && webCreditVet.Director_Phone_Number__c!=null && webCreditVet.Director_Phone_Number__c!='') {
			if (webCreditVet.Director_Phone_Number__c.startsWith('0')) cr.customerDetails.contactDetails.contactMobilePhoneNumber = webCreditVet.Director_Phone_Number__c.replaceFirst('0', '+44');
			else if (!webCreditVet.Director_Phone_Number__c.startsWith('+')) cr.customerDetails.contactDetails.contactMobilePhoneNumber = '+'+webCreditVet.Director_Phone_Number__c;
			else cr.customerDetails.contactDetails.contactMobilePhoneNumber = webCreditVet.Director_Phone_Number__c;
		}
		//banking details
		if (cardType!=null && cardType!='') cr.customerDetails.creditOrDebitCardDetails.cardType = cardType;
		if (nameOnCard!=null && nameOnCard!='') cr.customerDetails.creditOrDebitCardDetails.cardHolderName = nameOnCard;
		if (cardNumber!=null && cardNumber!='') cr.customerDetails.creditOrDebitCardDetails.cardNumber = cardNumber;
		if (cardType=='Maestro' && startDateYY!=null && startDateYY!='' && startDateMM!=null && startDateMM!='') cr.customerDetails.creditOrDebitCardDetails.startDate = startDateYY+'-'+(startDateMM.length()<2 ? '0'+startDateMM : startDateMM);
		if (expiryDateYY!=null && expiryDateYY!='' && expiryDateMM!=null && expiryDateMM!='') cr.customerDetails.creditOrDebitCardDetails.expiryDate = expiryDateYY+'-'+(expiryDateMM.length()<2 ? '0'+expiryDateMM : expiryDateMM);
		if (ccvNumber!=null && ccvNumber!='') cr.customerDetails.creditOrDebitCardDetails.cvc = ccvNumber;
		if (cardType=='Maestro' && issueNumber!=null && issueNumber!='') cr.customerDetails.creditOrDebitCardDetails.issueNumber = issueNumber;
		if (bankAccountNumber!=null && bankAccountNumber!='') cr.customerDetails.bankingDetails.accountNumber = bankAccountNumber;
		if (bankSortCode!=null && bankSortCode!='') cr.customerDetails.bankingDetails.sortCode = bankSortCode;
		if (bankAccountName!=null && bankAccountName!='') cr.customerDetails.bankingDetails.accountName = bankAccountName;
        //System.debug('### OUTPUT >>>>> performIDCheck: CreditCheckRequest: '+cr);

	    //call service and get response
	    CreditCheckSOAHandler.CreditCheckResponse sp = cc.creditCheckResquest(cr);

        if (CreditCheckSettings__c.getInstance('Send Debug Logs')!=null && CreditCheckSettings__c.getInstance('Send Debug Logs').Value__c == 'Y') {
	        sendEmailLog(String.valueOf(cr), email, 'IDV Check log request: '+Datetime.now());
		    sendEmailLog(String.valueOf(sp), email, 'IDV Check log response: '+Datetime.now());
        }

	    return sp;
    }

    @future
    public static void sendEmailLog(String body, String toAddress, String subject) {
        //log request in email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.reserveSingleEmailCapacity(1);
        String[] toAddresses = new String[] {toAddress};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    //### END IDV Check Changes ######################################################


   	public class CoremetricsShopAction9Info {
		public string ProductId { get; set; }
		public string ProductName { get; set; }
		public double Quantity { get; set; }
		public double Price { get; set; }
		public string Category { get; set; }
		public string OrderId { get; set; }
		public string CustomerId { get; set; }
		public double SubTotal { get; set; }

		public CoremetricsShopAction9Info() {}
		public CoremetricsShopAction9Info(string prodId, string prodName, double quantity, double price, string category) {
			this.ProductId = prodId;
			this.ProductName = prodName;
			this.Quantity = quantity;
			this.Price = price;
			this.Category = category;
		}
   	}

   	public static final String CM_CATEGORY_TARIFFS = 'Business-shop tariffs';
   	public static final String CM_CATEGORY_PHONES = 'Business-shop phones';
   	public static final String CM_CATEGORY_BOLTONS = 'Business-shop bolt-ons';
   	public static final String CM_CATEGORY_ACCESSORIES = 'Business-shop accessories';

   	public string getCoremetricsShopAction9Infos() {
		CoremetricsShopAction9Info[] result = new CoremetricsShopAction9Info[] {};
		//SW CDECISIONS 24/07/2012 - added if statement to prevent errors when accessing the confirmation pages standalone
		cscfgc__Product_Configuration__c[] allBasketConfigs = new cscfgc__Product_Configuration__c[] {};
		if (sessionbasket!=null) {
	   		system.debug('>>>> getting ShopAction9Infos for basket: ' + sessionbasket.id);
			allBasketConfigs = [SELECT Id, Name, cscfgc__Total_Price__c, cscfgc__Recurring_Charge__c, cscfgc__Product_Basket__c, cscfgc__Product_Bundle__c, cscfgc__One_Off_Charge__c,
		                        		cscfgc__configuration_status__c, cscfgc__Parent_Configuration__c, cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name, cscfgc__Screen_Flow__r.Name,
		                        		cscfgc__Product_Basket__r.cscfgc__Opportunity__r.Order_Request_Number__c, cscfgc__Product_Basket__r.cscfgc__Opportunity__r.Confirmation_Email_Address__c,
		                    			(SELECT Id, Name, cscfgc__Price__c, cscfgc__Value__c
		                    				FROM cscfgc__Attributes__r
		                    				WHERE Name IN ('Primary Handset Tariff Code', 'Primary Handset Package Code', 'Voice Tariff Name', 'Line Rental', 'SKU', 'Tariff', 'Hardware',
		                    								'Primary Handset Model', 'Handset Price', 'Service Code', 'Service Name', 'Price', 'Accessory Product Code',
		                    								'Accessory Description', 'Quantity', 'Total Price', 'Product Code', 'Tariff Description', 'Tariff Price',
		                    								'Product Code', 'Hardware Description', 'Hardware Price', 'Payment Period', 'Contact Term', 'Care Package',
		                    								'Monthly Tariff', 'Tariff Code', 'Package Code', 'Caller Display', 'O2 Controlled Selective Call Barring', 'Remote Call Forwarding',
		                    								'Call Sign', 'Call Minder', 'Call Waiting', 'Extra Minutes Type', 'Package Type', 'Care Package Line Item Description'))
		                         FROM cscfgc__Product_Configuration__c
		                         WHERE cscfgc__Product_Basket__c=:sessionbasket.Id ORDER BY cscfgc__Serial_Number__c desc];
		}

        for (cscfgc__Product_Configuration__c cfg : allBasketConfigs) {
        	if (cfg.cscfgc__Parent_Configuration__c == null && cfg.cscfgc__configuration_status__c != O2OnlineProductBasketController.DRAFT_STATUS) {
        		string orderId = cfg.cscfgc__Product_Basket__r.cscfgc__Opportunity__r.Order_Request_Number__c;
        		string customerId = cfg.cscfgc__Product_Basket__r.cscfgc__Opportunity__r.Confirmation_Email_Address__c;
        		CoremetricsShopAction9Info[] tagsWithSameRoot = new CoremetricsShopAction9Info[]{};

        		map<string, cscfgc__Attribute__c> atts = getAttsMap(cfg);

        		//
        		// SMB Landline
        		if (cfg.cscfgc__Product_Definition__r.Name == 'SMB Landline') {

    				// Tariff
        			tagsWithSameRoot.add(new CoremetricsShopAction9Info(
        				'Landline_' + getAttValueSafe(atts.get('Payment Period')) + '_' + getAttValueSafe(atts.get('Contract Term'))  + '_' + getAttValueSafe(atts.get('Care Package')) + '_Basket',
        				getAttValueSafe(atts.get('Payment Period')) + ' ' + getAttValueSafe(atts.get('Contract Term')),
        				1,
        				tryParseDouble(getAttValueSafe(atts.get('Monthly Tariff'))),
        				'business-shop landline ' + getAttValueSafe(atts.get('Care Package'))
        			));


        			string tariffCode = getAttValueSafe(atts.get('Tariff Code'));

        			//Child configurations
        			for (cscfgc__Product_Configuration__c childCfg : allBasketConfigs) {
        				if (childCfg.cscfgc__Parent_Configuration__c == cfg.id) {
        					map<string, cscfgc__Attribute__c> childAtts = getAttsMap(childCfg);

        					// Landline Boltons
        					if (childCfg.cscfgc__Product_Definition__r.Name == 'Landline Bolt Ons') {

                            	string callerDisplay = getAttValueSafe(childAtts.get('Caller Display'));
                            	string callBarring = getAttValueSafe(childAtts.get('O2 Controlled Selective Call Barring'));
                            	string remoteCallForwarding = getAttValueSafe(childAtts.get('Remote Call Forwarding'));
                            	string callSign = getAttValueSafe(childAtts.get('Call Sign'));
                            	string callMinder = getAttValueSafe(childAtts.get('Call Minder'));
                            	string callWaiting = getAttValueSafe(childAtts.get('Call Waiting'));

        						O2OnlineMainController.O2_Dise_Map_Landline_Wrapper[] serviceCodes = O2OnlineMainController.getDiseServiceCodes(tariffCode,
        								new List<string[]> {
        									new string[] { 'Caller Display', callerDisplay },
        									new string[] { 'O2 Controlled Selective Call Barring', callBarring },
        									new string[] { 'Remote Call Forwarding', remoteCallForwarding },
        									new string[] { 'Call Sign', callSign },
        									new string[] { 'Call Minder', callMinder },
        									new string[] { 'Call Waiting', callWaiting }
        								});

        						for (O2OnlineMainController.O2_Dise_Map_Landline_Wrapper dml : serviceCodes) {
        							if (dml.ServiceCode != null && dml.ServiceCode.trim() != '') {
        								string prodName =
        									dml.AttributeName == 'Caller Display' ? 'Caller Display' :
        									dml.AttributeName == 'O2 Controlled Selective Call Barring' ? 'Call Barring' :
        									dml.AttributeName == 'Remote Call Forwarding' ? 'Call Forwarding' :
        									dml.AttributeName == 'Call Sign' ? 'Call Sign' :
        									dml.AttributeName == 'Call Minder' ? 'Call Minder' :
        									dml.AttributeName == 'Call Waiting' ? 'Call Waiting' : '';

    									double price = tryParseDouble(getAttPriceSafe(childAtts.get(dml.AttributeName)));

        								tagsWithSameRoot.add(new CoremetricsShopAction9Info(
					        				dml.ServiceCode,
					        				prodName,
					        				1,
					        				price,
					        				'business-shop landline bolt-ons'
					        			));
        							}
        						}
        					}
        					else if (childCfg.cscfgc__Product_Definition__r.Name == 'Fixed Line Minute Bolt On') {
	        					// Fixed Line Boltons
        						string serviceCode = getAttValueSafe(childAtts.get('Service Code'));

        						if(serviceCode != null && serviceCode.trim() != '') {
	        						tagsWithSameRoot.add(new CoremetricsShopAction9Info(
				        				serviceCode + '_Basket',
				        				getAttValueSafe(childAtts.get('Extra Minutes Type')),
				        				1,
				        				tryParseDouble(getAttValueSafe(childAtts.get('Price')).replace('£', '')),
				        				'business-shop landline bolt-ons'
				        			));
        						}
        					}
        				}
        			}
        		}
        		else if (cfg.cscfgc__Product_Definition__r.Name == 'SMB Business Broadband') {
	        		// SMB Business Broadband
        			tagsWithSameRoot.add(new CoremetricsShopAction9Info(
        				getAttValueSafe(atts.get('Tariff Code')),
        				getAttValueSafe(atts.get('Package Type')),
        				1,
        				tryParseDouble(getAttPriceSafe(atts.get('Package Type'))),
        				'business-shop broadband ' + getAttValueSafe(atts.get('Care Package Line Item Description'))
        			));
        		}
        		else if (cfg.cscfgc__Product_Definition__r.Name == 'Business Single Tariff') {
        			// SW CDECISIONS 19/09/2012 - added as this was absent to support mobile products
    				// Tariff
        			tagsWithSameRoot.add(new CoremetricsShopAction9Info(
        				getAttValueSafe(atts.get('Primary Handset Tariff Code')) + '_' + getAttValueSafe(atts.get('Primary Handset Package Code')),
        				getAttValueSafe(atts.get('Voice Tariff Name')),
        				1,
        				tryParseDouble(getAttValueSafe(atts.get('Line Rental'))),
        				CM_CATEGORY_TARIFFS
        			));


        			//Handset
        			if (atts.containsKey('SKU') && atts.get('SKU').cscfgc__Value__c != null) {
        				tagsWithSameRoot.add(new CoremetricsShopAction9Info(
	        				getAttValueSafe(atts.get('SKU')),
	        				getAttValueSafe(atts.get('Primary Handset Model')),
	        				1,
	        				tryParseDouble(getAttValueSafe(atts.get('Handset Price'))),
	        				CM_CATEGORY_PHONES
	        			));
        			}

        			//Child configurations
        			for (cscfgc__Product_Configuration__c childCfg : allBasketConfigs) {
        				if (childCfg.cscfgc__Parent_Configuration__c == cfg.id) {
        					map<string, cscfgc__Attribute__c> childAtts = getAttsMap(childCfg);

        					// BOLT ONs
        					if (childAtts.containsKey('Parent Name') && childAtts.get('Parent Name').cscfgc__Value__c == 'Bolt On') {
        						tagsWithSameRoot.add(new CoremetricsShopAction9Info(
			        				getAttValueSafe(childAtts.get('Service Code')),
			        				getAttValueSafe(childAtts.get('Service Name')),
			        				1,
			        				tryParseDouble(getAttValueSafe(childAtts.get('Price'))),
			        				CM_CATEGORY_BOLTONS
			        			));
        					}
        					// ACCESSORIES
        					else if (childCfg.cscfgc__Product_Definition__r.Name == 'Business Mobile Accessories') {
        						tagsWithSameRoot.add(new CoremetricsShopAction9Info(
			        				getAttValueSafe(childAtts.get('Accessory Product Code')),
			        				getAttValueSafe(childAtts.get('Accessory Description')),
			        				tryParseDouble(getAttValueSafe(childAtts.get('Quantity'))),
			        				tryParseDouble(getAttValueSafe(childAtts.get('Total Price'))),
			        				CM_CATEGORY_ACCESSORIES
			        			));
        					}
        				}
        			}
        		}
        		else if (cfg.cscfgc__Product_Definition__r.Name == 'Mobile Broadband') {
        			// SW CDECISIONS 19/09/2012 - added as this was absent to support mobile products
    				// Tariff
        			if (atts.containsKey('Tariff') && atts.get('Tariff').cscfgc__Value__c != null) {
	        			tagsWithSameRoot.add(new CoremetricsShopAction9Info(
	        				getAttValueSafe(atts.get('Tariff Code')) + '_' + getAttValueSafe(atts.get('Package Code')),
	        				getAttValueSafe(atts.get('Tariff Description')),
	        				1,
	        				tryParseDouble(getAttValueSafe(atts.get('Tariff Price'))),
	        				CM_CATEGORY_TARIFFS
	        			));
        			}

        			//Handset
        			if (atts.containsKey('Hardware') && atts.get('Hardware').cscfgc__Value__c != null) {
        				tagsWithSameRoot.add(new CoremetricsShopAction9Info(
	        				getAttValueSafe(atts.get('Product Code')),
	        				getAttValueSafe(atts.get('Hardware Description')),
	        				1,
	        				tryParseDouble(getAttValueSafe(atts.get('Hardware Price'))),
	        				CM_CATEGORY_PHONES
	        			));
        			}
        		}
        		// Mobile Landline string prodId, string prodName, double quantity, double price, string category
                else if (cfg.cscfgc__Product_Definition__r.Name == 'Mobile Landline') {
                    result.add(new CoremetricsShopAction9Info(
                        getAttValueSafe(atts.get('Tariff Code')),
                        getAttValueSafe(atts.get('Product')),
                        1,
                        tryParseDouble(getAttPriceSafe(atts.get('Price'))),
                        'business-shop mobile landline'
                    ));
                }

        		if (tagsWithSameRoot.size() > 0) {
        			double subTotal = 0;
        			for (CoremetricsShopAction9Info tag : tagsWithSameRoot) {
        				subTotal += tag.Price;
        			}

        			for (CoremetricsShopAction9Info tag : tagsWithSameRoot) {
        				tag.SubTotal = subTotal;
        				tag.OrderId = orderId;
        				tag.CustomerId = customerId;
        			}

        			result.addAll(tagsWithSameRoot);
        		}
        	}
        }

        return JSON.serialize(result).replaceAll('\'', '\\\'');
   	}


   	static map<string, cscfgc__Attribute__c> getAttsMap(cscfgc__Product_Configuration__c cfg) {
   		map<string, cscfgc__Attribute__c> atts = new map<string, cscfgc__Attribute__c>();
		for (cscfgc__Attribute__c att : cfg.cscfgc__Attributes__r) {
			atts.put(att.Name, att);
		}
		return atts;
   	}

    static double tryParseDouble(string d) {
    	try {
    		return decimal.valueof(d);
    	} catch(Exception ex) {
    		return 0;
    	}
    }
    static string getAttValueSafe(cscfgc__Attribute__c att) {
    	if (att != null) return att.cscfgc__Value__c;
    	return '';
    }
    static string getAttPriceSafe(cscfgc__Attribute__c att) {
    	if (att != null && att.cscfgc__Price__c != null) return  string.valueof(att.cscfgc__Price__c);
    	return '';
    }

    //SW CDECISIONS 19/09/2012 - added following function to generate a random number to support caching for FlashTalking tags
    public String getFTRandomNumber() {
    	return String.valueOf(Math.random()*1000000);
    }

    //Part of PreOrderOption2 T-00681
   public String getPreBackOrderMessage() {

	    //CHECK CUSTOM SETTINGS.------------------------------------------------------------------------
 	    if (CreditCheckSettings__c.getInstance('Online Enabled').Value__c != 'Y') { return ''; }

	    List<Opportunity> opps = [ select id from Opportunity where Order_Request_Number__c = :orderRequestNumber ];

 	    //CHECK CREDIT VET.-----------------------------------------------------------------------------
	 	/*List<Credit_Vet__c> credits = [
	 	  select id,
	 	         name,
	 	         IDV_Result__c
	      from   Credit_Vet__c
	      where  Opportunity__c = :opps[0].id
	    ];

	    if(credits.size()>0) { if (credits[0].IDV_Result__c != 'Accept' && credits[0].IDV_Result__c != 'Data Amend') { return ''; } } */

		//GET ALL PRODUCT CONFIGURATIONS.
		List<cscfgc__Product_Configuration__c> configurations = [
			select 	id,
					name,

					O2_DISE_Map_Handset_Selection__c,
					O2_DISE_Map_Handset_Selection__r.id,

					O2_DISE_Map_Handset_Selection__r.Product_Code__c,
					O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_Preorder__c,
					O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_BackOrder__c,
					O2_DISE_Map_Handset_Selection__r.Product_Code__r.Stock_Message__c,
					O2_DISE_Map_Handset_Selection__r.Product_Code__r.PreOrder_Stock_Level__c

			from 	cscfgc__Product_Configuration__c
			where 	O2_DISE_Map_Handset_Selection__c != null
			and		cscfgc__Product_Bundle__c in (
						select 	id
						from 	cscfgc__Product_Bundle__c
						where 	cscfgc__Opportunity__c                   = :opps[0].id
						and		cscfgc__Synchronised_with_Opportunity__c = true
					)
		];

		boolean preOrder     = false;
		boolean backOrder    = false;
		String  stockMessage = '';
		for(cscfgc__Product_Configuration__c config : configurations ) {
			Boolean AvailableForPreOrder  = config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_Preorder__c;
			Boolean AvailableForBackOrder = config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_BackOrder__c;
			if(AvailableForPreOrder  == true) { preOrder  = true; }
			if(AvailableForBackOrder == true) { backOrder = true; }
		}

		String message = '';
		if (preOrder  == true) 						{ message = Label.ONLINE_CONFIRMATION_PREORDER;    } //message = 'One or more items are Pre Order.'
		if (backOrder == true) 						{ message = Label.ONLINE_CONFIRMATION_BACKORDER;   } //message = 'One or more items are Back Order.'
		if (preOrder  == true && backOrder == true) { message = Label.ONLINE_CONFIRMATION_PREBACKORDER;} //message = 'One or more items are Back Order and Pre Order.'

        return message;
    }
   

	//Internal class used to store Coremetrics validation data
	public class CoremetricsValidationData {
		public String Field{get; set;}
		public String Message{get; set;}
		public String Category{get{return 'Err Biz';}}
		public String Page{get; set;}
		public String Value{get; set;}
		public CoremetricsValidationData(String Field, String Message, String Page, String Value){
			this.Field = Field;
			this.Message = Message;
			this.Page = Page;
			this.Value = Value;
		}
	}

	public CoremetricsValidationData[] coremetricValidationDataList {get;set;}
	public string myCoremetricsValidationData {
		get{
			return JSON.serialize(coremetricValidationDataList);
		}
	}

	/*
	 * One Tag Implementatin
	 * by Ivan Tadic
	 */
	public OneTagInfo OneTag{
      	get {

			if(OneTag == null){
	          OneTag = new OneTagInfo();
	        }
			try
			{
		        //User session (ftXRef)
		        OneTag.tagValues.put('ftXRef', BundleId);

	        	//Referer (ns)
	        	OneTag.tagValues.put('ns', ApexPages.currentPage().getHeaders().get('Referer'));

				//Current url (ft_referrer)
				OneTag.tagValues.put('ft_referrer', URL.getCurrentRequestUrl().toExternalForm().replace('/apex',''));

				//Customer type (U2)
				OneTag.tagValues.put('U2', 'Business' );

				//Random (cb)
				Double d = math.random() * 1000000;
				OneTag.tagValues.put('cb', string.valueOf(d.intValue()));

	      		string ftXCurrency, ftXType, ftXName, ftXValue, ftXNumItems, U1, U3, U4, U5, U6, U7, U8, U9, U10, U11, U12, U13, U14, U15, U16, U17, U18, U19, U20, U21, U22, U23, U24;
	      		ftXCurrency = ftXType = ftXName = ftXValue = ftXNumItems = U1 = U3 = U4 = U5 = U6 = U7 = U8 = U9 = U10 = U11 = U12 = U13 = U14 = U15 = U16 = U17 = U18 = U19 = U20 = U21 = U22 = U23 = U24 = '';
	      		integer orderQuantity, accessoryQuantity;
	      		orderQuantity = accessoryQuantity = 0;
	      		decimal oneOffCost, recurringCost, accessoryPrice;
	      		oneOffCost = recurringCost = accessoryPrice = 0;

				//Get list of all Valid configurations
				if(BundleId != null){
		      		List<Id> validConfigs = new List<Id>();
		      		List<string> validProdCodes = new List<string>();
		      		Map<Id, Map<string,string>> configAttributesMap = new Map<Id, Map<string,string>>();
		      		Map<Id, O2_DISE_Ref_Hardware_Portfolio__c> configHardwareMap = new Map<Id,O2_DISE_Ref_Hardware_Portfolio__c>();
			  		List<cscfgc__Product_Configuration__c> orderConfigs = [SELECT Id, Name, cscfgc__Total_Price__c,
			  																	  cscfgc__Recurring_Charge__c, cscfgc__Product_Basket__c, cscfgc__Product_Bundle__c,
		                     													  cscfgc__One_Off_Charge__c, cscfgc__configuration_status__c, cscfgc__Parent_Configuration__c,
		                     													  cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name,
		                     													  cscfgc__Screen_Flow__r.Name, O2_DISE_Map_Mobile__c, O2_DISE_Map_Handset__c,
		                     													  O2_DISE_Map_Handset__r.Product_Code__c, O2_DISE_Map_Handset_Selection__c,
		                     													  Quantity_of_Accessory__c, O2_DISE_Map_Mobile_Bolton__c,
		                     													  (SELECT Id, Name, cscfgc__Price__c, cscfgc__Value__c
		                      													   FROM cscfgc__Attributes__r
																				   WHERE ((cscfgc__Is_Line_Item__c=true AND cscfgc__Recurring__c=false AND cscfgc__Price__c <> null) OR (Name = :O2OnlineProductBasketController.EDIT_ATTR_NAME)))
		                   												  FROM cscfgc__Product_Configuration__c
		                   												  WHERE cscfgc__Product_Bundle__c=:BundleId ORDER BY cscfgc__Serial_Number__c desc];

					if(orderConfigs != null && orderConfigs.size() > 0){

			      		for(cscfgc__Product_Configuration__c config : orderConfigs){

		          			validConfigs.add(config.Id);
		          			validProdCodes.add(config.O2_DISE_Map_Handset__r.Product_Code__c);
		          			configAttributesMap.put(config.Id, new Map<string,string>());

			      		}

		      			//Get all attributes
		      			List<cscfgc__Attribute__c> allAttributes = [SELECT Id, Name, cscfgc__Value__c, cscfgc__Product_Configuration__c
		                             								FROM cscfgc__Attribute__c
		                             								WHERE cscfgc__Product_Configuration__c IN :validConfigs];

		      			//Save attributes in map
		      			for(cscfgc__Attribute__c att : allAttributes){
		        			(configAttributesMap.get(att.cscfgc__Product_Configuration__c)).put(att.Name, att.cscfgc__Value__c);
		      			}

		      			//Get all Hardware portfolios
		      			List<O2_DISE_Ref_Hardware_Portfolio__c> allPortfolios = [SELECT Id, Brand__c, Operating_System__c, Hardware_Description__c, Product_Code__c
		                                   										 FROM O2_DISE_Ref_Hardware_Portfolio__c
		                                   										 WHERE Product_Code__c IN :validProdCodes];

		      			//Save portfolios in map
		      			for(cscfgc__Product_Configuration__c config : orderConfigs){
		        			for(O2_DISE_Ref_Hardware_Portfolio__c portf : allPortfolios){
		          				if(config.O2_DISE_Map_Handset__r.Product_Code__c == portf.Product_Code__c){
		            				configHardwareMap.put(config.Id, portf);
		            				break;
		          				}
		        			}
		      			}

						//Read from configurations
		      			for(cscfgc__Product_Configuration__c config : orderConfigs){

		          			//If it's Tariff + Handset
		          			if((config.O2_DISE_Map_Mobile__c != null) && (config.O2_DISE_Map_Handset__c != null) && (config.O2_DISE_Map_Handset_Selection__c != null)){
			            		accessoryPrice = 0;
			            		accessoryQuantity = 0;
			            		ftXType += 'PAYM|HS,';
			            		U1 += 'POSTPAY,';
			            		ftXName += (configAttributesMap.get(config.Id)).get('Primary Handset Model') + ',';
			            		U3 += (configHardwareMap.get(config.Id)).Brand__c + ',';
			            		U4 += (configAttributesMap.get(config.Id)).get('Primary Handset Class') + ',';
			            		U5 += (configAttributesMap.get(config.Id)).get('Flavour') + ',';
			            		U6 += (configAttributesMap.get(config.Id)).get('Inclusive Minutes Line Item') + ',';
			            		U7 += (configAttributesMap.get(config.Id)).get('Inclusive Texts Line Item') + ',';
			            		decimal includedData = 0;
			            		try{
			              			includedData = decimal.valueOf(configAttributesMap.get(config.Id).get('Inclusive Core Data'));
			            		} catch(Exception ex){ }
			            		includedData /= 1000;
			            		U8 += string.valueOf(includedData) + 'GB,';
			            		U9 += 'PAYM,';
			            		U11 += (configHardwareMap.get(config.Id)).Operating_System__c + ',';
			            		U12 += (configAttributesMap.get(config.Id)).get('Contract Term') + 'month,';
			            		ftXValue += string.valueOf(config.cscfgc__Recurring_Charge__c) + ',';
			            		U10 += string.valueOf(config.cscfgc__One_Off_Charge__c) + ',';
			            		ftXNumItems += '1,';
			            		ftXCurrency += '£,';

			            		//Look all childs
			            		for(cscfgc__Product_Configuration__c childConfig : orderConfigs){
			            			if(childConfig.cscfgc__Parent_Configuration__c == config.Id){

			            				//If it's accessory
							          	if(childConfig.Quantity_of_Accessory__c > 0){
							            	U13 += (configAttributesMap.get(childConfig.Id)).get('Accessory Description') + '|';
							            	accessoryPrice += childConfig.cscfgc__One_Off_Charge__c;
							            	accessoryQuantity += childConfig.Quantity_of_Accessory__c.intValue();
							          	}

							          	//If it's bolt-on
							          	if(childConfig.O2_DISE_Map_Mobile_Bolton__c != null){
							            	U16 += (configAttributesMap.get(childConfig.Id)).get('Service Name') + '|';
							          	}

			            			}
			            		}
			            		U13 = U13.removeEnd('|') + ',';
			            		U14 += string.valueOf(accessoryPrice) + ',';
			            		U15 += string.valueOf(accessoryQuantity) + ',';
			            		U16 = U16.removeEnd('|') + ',';

		          			}

	          				//If it's SIM Only
	          				if((config.O2_DISE_Map_Mobile__c != null) && (config.O2_DISE_Map_Handset__c == null) && (config.O2_DISE_Map_Handset_Selection__c == null)){
	            				ftXType += 'PAYM,';
				            	U1 += 'POSTPAY,';
				            	U5 += (configAttributesMap.get(config.Id)).get('Contract Type') + ',';
				            	U6 += (configAttributesMap.get(config.Id)).get('Inclusive Minutes Line Item') + ',';
				            	U7 += (configAttributesMap.get(config.Id)).get('Inclusive Texts Line Item') + ',';
				            	decimal includedData = 0;
				            	try{
				              		includedData = decimal.valueOf(configAttributesMap.get(config.Id).get('Inclusive Core Data'));
				            	} catch(Exception ex){ }
				            	includedData /= 1000;
				            	U8 += string.valueOf(includedData) + 'GB,';
				            	U9 += 'PAYM,';
					            U12 += (configAttributesMap.get(config.Id)).get('Contract Term') + 'month,';
					            ftXValue += string.valueOf(config.cscfgc__Recurring_Charge__c) + ',';
			            		U10 += string.valueOf(config.cscfgc__One_Off_Charge__c) + ',';
			            		ftXNumItems += '1,';
			            		ftXCurrency += '£,';
					            //Look all childs
			            		for(cscfgc__Product_Configuration__c childConfig : orderConfigs){
			            			if(childConfig.cscfgc__Parent_Configuration__c == config.Id){

			            				//If it's accessory
							          	if(childConfig.Quantity_of_Accessory__c > 0){
							            	U13 += (configAttributesMap.get(childConfig.Id)).get('Accessory Description') + '|';
							            	accessoryPrice += childConfig.cscfgc__One_Off_Charge__c;
							            	accessoryQuantity += childConfig.Quantity_of_Accessory__c.intValue();
							          	}

							          	//If it's bolt-on
							          	if(childConfig.O2_DISE_Map_Mobile_Bolton__c != null){
							            	U16 += (configAttributesMap.get(childConfig.Id)).get('Service Name') + '|';
							          	}

			            			}
			            		}
			            		U13 = U13.removeEnd('|') + ',';
			            		U14 += string.valueOf(accessoryPrice) + ',';
			            		U15 += string.valueOf(accessoryQuantity) + ',';
			            		U16 = U16.removeEnd('|') + ',';
	          				}


						}
					}
				}
	  			OneTag.tagValues.put('ftXType', ftXType);
			  	OneTag.tagValues.put('U1', U1);
			  	OneTag.tagValues.put('ftXName', ftXName);
			  	OneTag.tagValues.put('U3', U3);
			  	OneTag.tagValues.put('U4', U4);
			  	OneTag.tagValues.put('U5', U5);
			  	OneTag.tagValues.put('U6', U6);
			  	OneTag.tagValues.put('U7', U7);
			  	OneTag.tagValues.put('U8', U8);
			  	OneTag.tagValues.put('ftXNumItems', ftXNumItems);
			  	OneTag.tagValues.put('U9', U9);
			  	OneTag.tagValues.put('U10', U10);
			  	OneTag.tagValues.put('U11', U11);
			  	OneTag.tagValues.put('U12', U12);
			  	OneTag.tagValues.put('ftXValue', ftXValue);
			  	OneTag.tagValues.put('U13', U13);
			  	OneTag.tagValues.put('U14', U14);
			  	OneTag.tagValues.put('U15', U15);
			  	OneTag.tagValues.put('U16', U16);
			  	OneTag.tagValues.put('ftXCurrency', ftXCurrency );
				//OneTag.tagValues.put('U10', string.valueOf(oneOffCost));
				//OneTag.tagValues.put('ftXValue', string.valueOf(recurringCost));
	        	//OneTag.tagValues.put('U14', string.valueOf(accessoryPrice));
			} catch (Exception ex) {
				System.debug('******* Error creating OneTag: ' + ex);
			}
        	return OneTag;
		}
      	private set;
    }

    //Class used to store One Tag data
    public class OneTagInfo{
      	public Map<string, string> tagValues;
      	public boolean OneTagEnabled{get; private set;}
      	public OneTagInfo(){
        	tagValues = new Map<string, string>();
      	}

      	public string IframeUrl{
	        get{
    	      	//Build URL

          		//Read from custom setting
          		string protocol = OnlineGeneralSettings__c.getInstance('OneTagProtocol').Value__c;
          		string domain = OnlineGeneralSettings__c.getInstance('OneTagDomain').Value__c;
          		string path = OnlineGeneralSettings__c.getInstance('OneTagPath').Value__c;
          		string url = protocol + '://' + domain + path + '?';

            	//Go through items and add them to URL
            	for(string key : tagValues.keySet()){
            		string v = tagValues.get(key);
              			if(string.isNotBlank(v)){
                		url += key + '=' + EncodingUtil.urlEncode(v.removeEnd(','), 'UTF-8') + '&';
              		}
            	}

        		url = url.removeEnd('&');
        		return url;
        	}
        	private set;
      	}
    }
}