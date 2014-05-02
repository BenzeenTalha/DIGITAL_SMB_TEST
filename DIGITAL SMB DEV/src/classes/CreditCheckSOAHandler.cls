/*
Credit Check SOA Handler - wrapper class

R Wintle - CloudSense


Typical usage:-

    CreditCheckSOAHandler cc=new CreditCheckSOAHandler();
	CreditCheckSOAHandler.CreditCheckRequest cr = new CreditCheckSOAHandler.CreditCheckRequest();
               
        List<CreditCheckSOAHandler.OrderLine> orderLines = new List<CreditCheckSOAHandler.OrderLine>();
        for(Integer i=0;i<5;i++) {
            orderLines.add(new CreditCheckSOAHandler.OrderLine());
        }
        cr.applicationDetails.buildLevel = '1234';
        cr.sourceOfSaleDetails.code = 'EE029999';
        cr.customerDetails.personalDetails.maritalStatus = 'Q';
        cr.customerDetails.personalDetails.agreeToCreditCheck = 'Y';
        cr.customerDetails.currentEmploymentDetails.employmentStatus = 'Z';
        
        cr.applicationDetails.transactionDateTime = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss');
		cr.applicationDetails.transactionType = 'N';
        cr.customerDetails.personalDetails.title = 'Mr';
        cr.customerDetails.personalDetails.foreName = 'Joe';
        cr.customerDetails.personalDetails.surName = 'Bloggs';
        cr.customerDetails.personalDetails.dateOfBirth = '1980-01-01';
		cr.customerDetails.personalDetails.residentialStatus = 'O';
        cr.customerDetails.currentAddress.postcode = 'BB1 BB2';
        cr.customerDetails.currentAddress.yearsAtAddress = '1';
        cr.customerDetails.currentAddress.monthsAtAddress = '1';
        cr.customerDetails.creditOrDebitCardDetails.cardHolderName = 'JBloggs';
        cr.customerDetails.creditOrDebitCardDetails.cardNumber = '';
        cr.customerDetails.creditOrDebitCardDetails.expiryDate = '2014-10';
        cr.customerDetails.creditOrDebitCardDetails.cvc = '246';
        cr.customerDetails.bankingDetails.accountNumber = '';
        cr.customerDetails.bankingDetails.sortCode = '912012';
        cr.customerDetails.bankingDetails.accountName = 'JBloggs';
        //cr.orderDetails.paymentMethod = 'D';

		// validate fields
		List<String> requestCheckResult=cr.validate(); 
		if(!requestCheckResult.isEmpty()) 
			throw new MyException('Request invalid. Details: '+requestCheckResult);
        
    	CreditCheckSOAHandler.CreditCheckResponse sp = cc.creditCheckResquest(cr);
    	System.debug('***sp'+sp.getText());

*/

public with sharing class CreditCheckSOAHandler {
	
	// Envelope and namesapce settings
    private static final String ENVELOPE_XML_MANCC = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://soa.o2.co.uk/managecreditcheckdata_1" xmlns:psc="http://soa.o2.co.uk/pscommontransact_1">';
	private static final string ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final string OUG_NS = 'http://ougwebcomponent.components.oug.osgi.scorex.com';     
    private static final string PSC_NS = 'http://soa.o2.co.uk/pscommontransact_1';
	private static final string COR_NS = 'http://soa.o2.co.uk/coredata_1';
    private static final string MAN_NS = 'http://soa.o2.co.uk/managecreditcheckdata_1';  
	
	// Test flag to allow test of fault logic
    public Boolean testFault { get; set; }		
	
	// Pre-existing classes to interact with SOA service
	private SOAServicesBase soaBase = null;	

	// Data representations defined in this class as inner classes
    public CreditCheckResponse creditCheckResponse = null;
 	
	// Custom exceptions that can be thrown by this class
	public class RequiredDataException extends Exception {}
	public class ResponseException extends Exception {}
	public class ValidationException extends Exception {}

	public CreditCheckSOAHandler() {
		testFault=false;
	}

	// Error data returned by DISE / SOA
	public class SOAFault {
		
        public String faultcode{ get; set; }
        public String faultstring { get; set; }		
        public String info { get; set; }		
        public Boolean detected { get; set; }		
        
        public SOAFault(Dom.XMLNode bodyElem) {
        	Dom.XMLNode faultElem = bodyElem.getChildElement('Fault', ENV_NS);
        	if (faultElem == null) {
	        	faultcode = null;
	        	faultstring = null;
	        	detected = false;
	        	info = '';
        	} else {
	        	faultcode = getElemText(faultElem, null, 'faultcode');
	        	faultstring = getElemText(faultElem, null, 'faultstring');
	        	info = sTrim(faultstring) + ' (' + faultcode + ')';
	        	detected = true;
        	}
        }	        
	}
	

	// *** Request XML structure - CreditCheckRequest inner class ***
	
	public class CreditCheckRequest {
        public ApplicationDetails applicationDetails {get; set;}
        public SourceOfSaleDetails sourceOfSaleDetails {get; set;}
        public CustomerDetails customerDetails {get; set;}
        public OrderDetails orderDetails {get; set;}
        public CreditCheckRequest() {
        	applicationDetails=new ApplicationDetails();
        	sourceOfSaleDetails=new SourceOfSaleDetails();
        	customerDetails=new CustomerDetails();
        	orderDetails=new OrderDetails();
        }
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	ccErrorList.addAll(applicationDetails.validate());
        	if(!isEmpty(sourceOfSaleDetails.getText())) ccErrorList.addAll(sourceOfSaleDetails.validate());
        	if(!isEmpty(customerDetails.getText())) ccErrorList.addAll(customerDetails.validate());
        	if(!isEmpty(orderDetails.getText())) ccErrorList.addAll(orderDetails.validate());
        	return ccErrorList;
        }
        public String getText() {
        	return applicationDetails.getText()+sourceOfSaleDetails.getText()+customerDetails.getText()+
        		orderDetails.getText();
        }
    }
    
    public class ApplicationDetails {
        public String buildLevel {get; set;}
        public String applicationNumber {get; set;}
        public String transactionDateTime {get; set;}
        public String transactionType {
        	get;
        	set {
        		this.transactionType=sTrim(value).toUpperCase();
        	} 
        }
        public ApplicationDetails() {}
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	//validateField(String fieldName, String fieldValue, String mandatory, Integer minLen, Integer maxLen, String patternStr, String formatDesc)
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Build Level',buildLevel,'M',null,4,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Application Number',applicationNumber,null,null,9,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Transaction Type',transactionType,'M',null,null,'^[A-Z]$','valid letter');
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        }
        public String getText() {
        	return sTrim(buildLevel)+sTrim(applicationNumber)+sTrim(transactionDateTime)+sTrim(transactionType);
        }
    }
    public class SourceOfSaleDetails {
        public String code {get; set;}
        public String userName {get; set;}
        public String ipAddress {get; set;}
        public String macAddress {get; set;} 
        public SourceOfSaleDetails() {} 
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Code',code,'M',null,10,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Username',userName,null,null,30,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(code)+sTrim(userName)+sTrim(ipAddress)+sTrim(macAddress);
        } 
    }
    
    public class CustomerDetails {
        public PersonalDetails personalDetails {get; set;}
        public ContactDetails contactDetails {get; set;}
        public CurrentAddress currentAddress {get; set;}
        public PreviousAddress previousAddress {get; set;}
        public DeliveryAddress deliveryAddress {get; set;}
        public CurrentEmploymentDetails currentEmploymentDetails {get; set;}
        public CreditOrDebitCardDetails creditOrDebitCardDetails {get; set;}
        public BankingDetails bankingDetails {get; set;}
        public AdditionalInformation additionalInformation {get; set;}  
        public CustomerDetails() {
			personalDetails=new PersonalDetails();
			contactDetails=new ContactDetails();
			currentAddress=new CurrentAddress();
			previousAddress=new PreviousAddress();
			deliveryAddress=new DeliveryAddress();
			currentEmploymentDetails=new CurrentEmploymentDetails();
			creditOrDebitCardDetails=new CreditOrDebitCardDetails();
			bankingDetails=new BankingDetails();
			additionalInformation=new AdditionalInformation();
        }  
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	ccErrorList.addAll(personalDetails.validate());
        	ccErrorList.addAll(contactDetails.validate());
        	ccErrorList.addAll(currentAddress.validate());
        	if(!isEmpty(previousAddress.getText())) ccErrorList.addAll(previousAddress.validate());
        	if(!isEmpty(deliveryAddress.getText())) ccErrorList.addAll(deliveryAddress.validate());
        	if(!isEmpty(currentEmploymentDetails.getText())) ccErrorList.addAll(currentEmploymentDetails.validate());
        	if(!isEmpty(creditOrDebitCardDetails.getText())) ccErrorList.addAll(creditOrDebitCardDetails.validate());
        	if(!isEmpty(bankingDetails.getText())) ccErrorList.addAll(bankingDetails.validate());
        	if(!isEmpty(additionalInformation.getText())) { 
            	ccErrorList.addAll(additionalInformation.validate());
            }
        	return ccErrorList;
        }
        public String getText() {
        	return personalDetails.getText()+contactDetails.getText()+currentAddress.getText()+
        		previousAddress.getText()+deliveryAddress.getText()+currentEmploymentDetails.getText()+
        		creditOrDebitCardDetails.getText()+bankingDetails.getText()+additionalInformation.getText();
        }
    }
    
    public class PersonalDetails {
        public String title {get; set;}
        public String foreName {get; set;}
        public String middleName {get; set;}
        public String surName {get; set;}
        public String dateOfBirth {get; set;}
        public String gender {
        	get;
        	set {
        		this.gender=sTrim(value).toUpperCase();
        	} 
        }
        public String maritalStatus {
        	get;
        	set {
        		this.maritalStatus=sTrim(value).toUpperCase();
        	} 
        }
        public String numberOfCreditCards {get; set;}
        public String numberOfHandsets {get; set;}
        public String residentialStatus {
        	get;
        	set {
        		this.residentialStatus=sTrim(value).toUpperCase();
        	} 
        }
        public String numberOfDependants {get; set;}
        public String bfpoFlag {get; set;}
        public String totalHouseHoldIncome {get; set;}
        public String monthlyMortgageOrRentPayment {get; set;}
        public String agreeToCreditCheck {
        	get;
        	set {
        		this.agreeToCreditCheck=sTrim(value).toUpperCase();
        	} 
        }
        public String currentContractNumber {get; set;}  
        public PersonalDetails() {}  
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Title',title,'M',null,8,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Forename',foreName,'M',null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Middle Name',middleName,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Surname',surName,'M',null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Date of Birth',dateOfBirth,'M',null,null,'^\\d{4}-\\d{2}-\\d{2}$','yyyy-mm-dd');
        	if(valResult!='') ccErrorList.add(valResult);        	
        	valResult=CreditCheckSOAHandler.validateField('Marital Status',maritalStatus,'M',null,1,'^[A-Z]$','valid letter');
        	if(valResult!='') ccErrorList.add(valResult);        	
        	valResult=CreditCheckSOAHandler.validateField('Gender',gender,null,null,1,'^[A-Z]$','valid letter');
        	if(valResult!='') ccErrorList.add(valResult);  
        	valResult=CreditCheckSOAHandler.validateField('Residential Status',residentialStatus,'M',null,1,'^[A-Z]$','valid letter');
        	if(valResult!='') ccErrorList.add(valResult); 
        	valResult=CreditCheckSOAHandler.validateField('Agree to Credit Check',agreeToCreditCheck,'M',null,1,'^Y|N$','Y or N');
        	if(valResult!='') ccErrorList.add(valResult); 
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(title)+sTrim(foreName)+sTrim(middleName)+sTrim(surName)+sTrim(dateOfBirth)+sTrim(maritalStatus)+
        		sTrim(gender)+sTrim(numberOfCreditCards)+sTrim(numberOfHandsets)+
        		sTrim(residentialStatus)+sTrim(numberOfDependants)+sTrim(bfpoFlag)+
        		sTrim(totalHouseHoldIncome)+sTrim(monthlyMortgageOrRentPayment)+sTrim(currentContractNumber)+
        		sTrim(agreeToCreditCheck);
        } 
    }
    
    public class ContactDetails {
        public String landlineNumber {get; set;}
        public String exDirectoryFlag {
        	get;
        	set {
        		this.exDirectoryFlag=sTrim(value).toUpperCase();
        	} 
        }
        public String contactMobilePhoneNumber {get; set;}
        public String o2MobilePhoneNumber {get; set;}
        public String emailAddress {get; set;}   
        public ContactDetails() {} 
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Landline Number',landlineNumber,null,3,20,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Ex-directory Flag',exDirectoryFlag,null,null,null,'^[Y|N]$','Y or N');
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        }
        public String getText() {
        	return sTrim(landlineNumber)+sTrim(exDirectoryFlag)+sTrim(contactMobilePhoneNumber)+
        		sTrim(o2MobilePhoneNumber)+sTrim(emailAddress);
        }
    }
    
    public class CurrentAddress {
        public String flat {get; set;}
        public String houseName {get; set;}
        public String houseNumber {get; set;}
        public String street1 {get; set;}
        public String street2 {get; set;}
        public String district {get; set;}
        public String town {get; set;}
        public String county {get; set;}
        public String postcode {get; set;}
        public String equifaxAddressReference {get; set;}
        public String yearsAtAddress {get; set;}
        public String monthsAtAddress {get; set;}  
        public CurrentAddress() {}  
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Flat',flat,null,null,30,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('House Name',houseName,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Street 1',street1,'M',null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);        	
        	valResult=CreditCheckSOAHandler.validateField('Street 2',street2,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('District',district,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Town',town,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('County',county,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Postcode',postcode,'M',5,9,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Equifax Address Reference',equifaxAddressReference,null,null,11,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Years at Address',yearsAtAddress,'M',1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Months at Address',monthsAtAddress,'M',1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(flat)+sTrim(houseName)+sTrim(street1)+sTrim(street2)+sTrim(district)+
        		sTrim(town)+sTrim(county)+sTrim(postcode)+sTrim(equifaxAddressReference)+
        		sTrim(yearsAtAddress)+sTrim(monthsAtAddress);
        }  
    }
    
    public class PreviousAddress {
        public String prevflat {get; set;}
        public String prevhouseName {get; set;}
        public String prevhouseNumber {get; set;}
        public String prevstreet1 {get; set;}
        public String prevstreet2 {get; set;}
        public String prevdistrict {get; set;}
        public String prevtown {get; set;}
        public String prevcounty {get; set;}
        public String prevpostcode {get; set;}
        public String prevequifaxAddressReference {get; set;}
        public String prevyearsAtAddress {get; set;}
        public String prevmonthsAtAddress {get; set;}    
        public PreviousAddress() {}
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Previous Flat',prevflat,null,null,30,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous House Name',prevhouseName,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous Street 1',prevstreet1,'M',null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);        	
        	valResult=CreditCheckSOAHandler.validateField('Previous Street 2',prevstreet2,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous District',prevdistrict,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous Town',prevtown,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous County',prevcounty,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous Postcode',prevpostcode,'M',5,9,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous Equifax Address Reference',prevequifaxAddressReference,null,null,11,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous Years at Address',prevyearsAtAddress,null,1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Previous Months at Address',prevmonthsAtAddress,null,1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(prevFlat)+sTrim(prevhouseName)+sTrim(prevstreet1)+sTrim(prevstreet2)+sTrim(prevdistrict)+
        		sTrim(prevtown)+sTrim(prevcounty)+sTrim(prevpostcode)+sTrim(prevequifaxAddressReference)+
        		sTrim(prevyearsAtAddress)+sTrim(prevmonthsAtAddress);
        }  
    }
    
    public class DeliveryAddress {
        public String delflat {get; set;}
        public String delhouseName {get; set;}
        public String delhouseNumber {get; set;}
        public String delstreet1 {get; set;}
        public String delstreet2 {get; set;}
        public String deldistrict {get; set;}
        public String deltown {get; set;}
        public String delcounty {get; set;}
        public String delpostcode {get; set;}  
        public DeliveryAddress() {}  
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Delivery Flat',delflat,null,null,30,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Delivery House Name',delhouseName,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Delivery Street 1',delstreet1,'M',null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);        	
        	valResult=CreditCheckSOAHandler.validateField('Delivery Street 2',delstreet2,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Delivery District',deldistrict,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Delivery Town',deltown,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Delivery County',delcounty,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Delivery Postcode',delpostcode,'M',5,9,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(delFlat)+sTrim(delhouseName)+sTrim(delstreet1)+sTrim(delstreet2)+sTrim(deldistrict)+
        		sTrim(deltown)+sTrim(delcounty)+sTrim(delpostcode);
        }  
    }
    
    public class CurrentEmploymentDetails {
        public String employmentStatus {
        	get;
        	set {
        		this.employmentStatus=sTrim(value).toUpperCase();
        	} 
        }    
        public String yearsSinceEmployed {get; set;}    
        public String monthsSinceEmployed {get; set;} 
        public CurrentEmploymentDetails() {}  
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Employment Status',employmentStatus,'M',null,null,'^[A-Z]$','valid letter');
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Years Since Employed',yearsSinceEmployed,null,1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Months Since Employed',monthsSinceEmployed,null,1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(employmentStatus)+sTrim(yearsSinceEmployed)+sTrim(monthsSinceEmployed);
        }       
    }
    
    public class CreditOrDebitCardDetails {
        public String cardType {
        	get;
        	set {
        		this.cardType=sTrim(value).toUpperCase();
        	} 
        }   
        public String cardNumber {get; set;} 
        public String cardHolderName {get; set;}    
        public String startDate {get; set;}    
        public String expiryDate {get; set;}    
        public String cvc {get; set;}    
        public String issueNumber {get; set;}  
        public CreditOrDebitCardDetails() {}  
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Card Type',cardType,'M',null,null,'^[A-Z]$','valid letter');
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Card Number',cardNumber,'M',null,null,'^(\\d{15})|(\\d{16})$','15 or 16 numbers');
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Start Date',startDate,null,null,null,'^\\d{4}-((0[1-9])|(1[0-2]))$','format yyyy-mm');
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Expiry Date',expiryDate,'M',null,null,'^\\d{4}-((0[1-9])|(1[0-2]))$','format yyyy-mm');
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Card Holder Name',cardHolderName,'M',null,null,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('CVC',cvc,'M',null,null,'^(\\d{3})|(\\d{4})$','3 or 4 digit number');
        	if(valResult!='') ccErrorList.add(valResult);        	     
        	valResult=CreditCheckSOAHandler.validateField('Issue Number',issueNumber,null,null,null,'^(\\d{1})|(\\d{2})$','1 or 2 digit number');
        	if(valResult!='') ccErrorList.add(valResult);   
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(cardType)+sTrim(cardNumber)+sTrim(cardHolderName)+sTrim(startDate)+sTrim(expiryDate)+
        		sTrim(cvc)+sTrim(issueNumber);
        }  
    }
    
    public class BankingDetails {
        public String accountNumber {get; set;}    
        public String sortCode {get; set;}    
        public String accountName {get; set;}    
        public String yearsSinceBankAccount {get; set;}    
        public String monthsSinceBankAccount {get; set;} 
        public BankingDetails() {} 
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Account Number',accountNumber,'M',8,16,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Sort Code',sortCode,'M',6,6,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Account Name',accountName,'M',null,null,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Years Since Bank Account',yearsSinceBankAccount,null,1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Months Since Bank Account',monthsSinceBankAccount,null,1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(accountNumber)+sTrim(sortCode)+sTrim(accountName)+sTrim(yearsSinceBankAccount)+
        		sTrim(monthsSinceBankAccount);
        }  
    }
    
    public class AdditionalInformation {   
        public Passport passport {get; set;}
        public DrivingLicence drivingLicence {get; set;}
        public String mothersMaidenName {get; set;}
        public ProofOfIdentity proofOfIdentity {get; set;}
        public ProofOfAddress proofOfAddress {get; set;}
        public CreditOrDebitCardDetails creditOrDebitCardDetails {get; set;}
        public AdditionalInformation() {
        	passport=new Passport();
        	drivingLicence=new DrivingLicence();
        	proofOfIdentity=new ProofOfIdentity();
        	proofOfAddress=new ProofOfAddress();
        	creditOrDebitCardDetails=new CreditOrDebitCardDetails();
        }
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	if(!isEmpty(passport.getText())) ccErrorList.addAll(passport.validate());
        	if(!isEmpty(drivingLicence.getText())) ccErrorList.addAll(drivingLicence.validate());
        	valResult=CreditCheckSOAHandler.validateField('Mothers Maiden Name',mothersMaidenName,null,null,35,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	if(!isEmpty(proofOfIdentity.getText())) ccErrorList.addAll(proofOfIdentity.validate());
        	if(!isEmpty(proofOfAddress.getText())) ccErrorList.addAll(proofOfAddress.validate());
        	if(!isEmpty(creditOrDebitCardDetails.getText())) ccErrorList.addAll(creditOrDebitCardDetails.validate());
        	return ccErrorList;
        }
        public String getText() {
        	return passport.getText()+drivingLicence.getText()+sTrim(mothersMaidenName)+proofOfIdentity.getText()
        		+creditOrDebitCardDetails.getText();
        }
    } 
    
    public class Passport {
        public String passportCountryOfIssue {get; set;}    
        public PassportNumber passportNumber {get; set;}
        public String passportExpiryDate {get; set;}    
        public Passport() {
        	passportNumber=new PassportNumber();
        }
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Passport Country of Issue',passportCountryOfIssue,'M',3,3,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	ccErrorList.addAll(passportNumber.validate());
        	valResult=CreditCheckSOAHandler.validateField('Passport Expiry Date',passportExpiryDate,'M',null,null,'^\\d{4}-((0[1-9])|(1[0-2]))-(([0-2][1-9])|(3[0-1]))$','format yyyy-mm-dd');
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        } 
        public String getText() {
        	return sTrim(passportCountryOfIssue)+passportNumber.getText()+sTrim(passportExpiryDate);
        }  
    }
    
    public class PassportNumber {
        public String passportNumber1 {get; set;}    
        public String passportNumber2 {get; set;}    
        public String passportNumber3 {get; set;}    
        public String passportNumber4 {get; set;}    
        public String passportNumber5 {get; set;}    
        public String passportNumber6 {get; set;}    
        public String passportNumber7 {get; set;}  
        public PassportNumber() {} 
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Passport Number 1',passportNumber1,'M',null,10,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Passport Number 2',passportNumber2,'M',null,3,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Passport Number 3',passportNumber3,'M',null,7,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Passport Number 4',passportNumber4,'M',null,1,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Passport Number 5',passportNumber5,'M',null,7,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Passport Number 6',passportNumber6,'M',null,14,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Passport Number 7',passportNumber7,'M',1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        }
        public String getText() {
        	return sTrim(passportNumber1)+sTrim(passportNumber2)+sTrim(passportNumber3)+sTrim(passportNumber4)+
        		sTrim(passportNumber5)+sTrim(passportNumber6)+sTrim(passportNumber7);
        } 
    }
    
    public class DrivingLicence {
        public DrivingLicenceNumber drivingLicenceNumber {get; set;}
        public String drivingLicencePostCode {get; set;}   
        public String drivingLicenceMailSort {get; set;}  
        public DrivingLicence() {
        	drivingLicenceNumber=new DrivingLicenceNumber();
        }
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	ccErrorList.addAll(drivingLicenceNumber.validate());
        	valResult=CreditCheckSOAHandler.validateField('Driving License Postcode',drivingLicencePostCode,'M',5,9,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Driving License Mail Sort',drivingLicenceMailSort,null,null,7,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        } 
        public String getText() {
        	return drivingLicenceNumber.getText()+sTrim(drivingLicencePostCode)+sTrim(drivingLicenceMailSort);
        }    
    }
    
    public class DrivingLicenceNumber {
        public String drivingLicenceNumber1 {get; set;}   
        public String drivingLicenceNumber2 {get; set;}   
        public String drivingLicenceNumber3 {get; set;}   
        public String drivingLicenceNumber4 {get; set;} 
        public DrivingLicenceNumber() {}  
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Driving License Number 1',drivingLicenceNumber1,'M',1,5,null,null);
        	valResult=CreditCheckSOAHandler.validateField('Driving License Number 2',drivingLicenceNumber2,'M',1,6,null,null);
        	valResult=CreditCheckSOAHandler.validateField('Driving License Number 3',drivingLicenceNumber3,'M',1,3,null,null);
        	valResult=CreditCheckSOAHandler.validateField('Driving License Number 4',drivingLicenceNumber4,'M',1,2,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        }  
        public String getText() {
        	return sTrim(drivingLicenceNumber1)+sTrim(drivingLicenceNumber2)+sTrim(drivingLicenceNumber3)
        		+sTrim(drivingLicenceNumber4);
        }
    }
    
    public class ProofOfIdentity {
        public String proofOfIdentityType {get; set;}
        public String proofOfIdentityReference {get; set;}
        public ProofOfIdentity(){}
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Proof Of Identity Type',proofOfIdentityType,'M',null,null,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Proof Of Identity Reference',proofOfIdentityReference,'M',null,20,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        }
        public String getText() {
        	return sTrim(proofOfIdentityType)+sTrim(proofOfIdentityReference);
        }
    }
    
    public class ProofOfAddress {
        public String proofOfAddressType {get; set;}
        public String proofOfAddressDate {get; set;}  
        public ProofOfAddress() {}
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Proof Of Address Type',proofOfAddressType,'M',null,null,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Proof Of Address Date',proofOfAddressDate,'M',null,null,'^\\d{4}-((0[1-9])|(1[0-2]))-(([0-2][1-9])|(3[0-1]))$','format yyyy-mm-dd');
        	if(valResult!='') ccErrorList.add(valResult);
        	return ccErrorList;
        }
        public String getText() {
        	return sTrim(proofOfAddressType)+sTrim(proofOfAddressDate);
        }
    }  
    
    public class OrderDetails {
        public String orderStatus {
        	get;
        	set {
        		this.orderStatus=sTrim(value).toUpperCase();
        	} 
        }   
        public String contractNumber {get; set;}   
        public String totalMonthlyCharge {get; set;}   
        public String totalOneOffCharge {get; set;}   
        public String numberOfHandsets {get; set;}   
        //public String numberOfOrderLines {get; set;}   calculated as orderLines size
        public String paymentMethod {get; set;}   
        public String paymentReferenceNumber {get; set;}         
        public List<orderLine> orderLines {get; set;}
        public OrderDetails() {
        	orderLines=new List<orderLine>();
        }
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Order Status',orderStatus,'M',null,null,'^[A|C|D]$','code A,C or D');
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Contract Number',contractNumber,'M',null,80,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Total Monthly Charge',totalMonthlyCharge,'M',null,null,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Number of Handsets',numberOfHandsets,null,null,6,null,null);
        	if(valResult!='') ccErrorList.add(valResult);
        	valResult=CreditCheckSOAHandler.validateField('Payment Method',paymentMethod,null,1,1,null,null);
        	if(valResult!='') ccErrorList.add(valResult);        	
        	if(orderLines.size()>0) {
        		for(OrderLine ol : orderlines) {
        			ccErrorList.addAll(ol.validate());
        		}
        	}
        	return ccErrorList;
        }
        public String getText() {
        	String olListStr='';
        	for(OrderLine ol : orderlines) {
        		olListStr=olListStr+ol.getText();
        	}
        	return sTrim(orderStatus)+sTrim(contractNumber)+sTrim(totalMonthlyCharge)+sTrim(totalOneOffCharge)+
        		sTrim(numberOfHandsets)+sTrim(paymentMethod)+sTrim(paymentReferenceNumber)+olListStr;
        }
    }

    public class orderLine {
        public String productCode {
        	get;
        	set {
        		this.productCode=sTrim(value).toUpperCase();
        	} 
        }  
        public String productType {
        	get;
        	set {
        		this.productType=sTrim(value).toUpperCase();
        	} 
        }    
        public String productDescription {get; set;}   
        public String productCharge {get; set;}   
        public String productPrice {get; set;}   
        public String contractTerm {get; set;}   
        public String quantity {get; set;}   
        public orderLine() {}    
        public List<String> validate() {
        	List<String> ccErrorList = new List<String>();
        	String valResult='';
        	valResult=CreditCheckSOAHandler.validateField('Product Code',productCode,'M',1,1,null,null);
        	if(valResult!='') ccErrorList.add(valResult); 
        	valResult=CreditCheckSOAHandler.validateField('Product Type',productType,'M',3,3,null,null);
        	if(valResult!='') ccErrorList.add(valResult); 
        	valResult=CreditCheckSOAHandler.validateField('Contract Term',contractTerm,null,null,3,null,null);
        	if(valResult!='') ccErrorList.add(valResult); 
        	valResult=CreditCheckSOAHandler.validateField('Quantity',quantity,'M',null,6,null,null);
        	if(valResult!='') ccErrorList.add(valResult); 
        	return ccErrorList;
        }
        public String getText() {
        	return sTrim(productCode)+sTrim(productType)+sTrim(productDescription)+sTrim(productCharge)+
        		sTrim(productPrice)+sTrim(contractTerm)+sTrim(quantity);
        }
    }
	
	// **** END CreditCheckRequest inner class ***
	
	
	// Response object
	//  - throws ResponseException on SOAP fault
	
	public class CreditCheckResponse {
		public String creditCheckResultCode { get; set; }
		//public String creditCheckResultDescription { get; set; }
		public String contractStrategyCode { get; set; }
		public List<String> reasonCodeMap { get; set; }		//SW CDECISIONS 03/07/2012 - changed from Map<String, String> to list to preserve code ordering in output to User
		public SOAFault fault = null;

        // Build response properties from response xml
        public CreditCheckResponse(String xml) {
            if (isEmpty(xml)) throw new RequiredDataException('xml is required!');          
            Dom.XMLNode creditCheckResponseElem = getMainDataElem(xml);                       
            Dom.XMLNode decisionDetailsElem = creditCheckResponseElem.getChildElement('decisionDetails', MAN_NS);
            
            // get result code
            creditCheckResultCode = sTrim(getElemText(decisionDetailsElem, MAN_NS, 'creditCheckResultCode'));
            
            // get result code description from custom setting
            /*SW CDECISIONS 03/07/2012 - commented out the retrieval of the result description as this is done in the calling controller
            if(CreditCheckSettings__c.getValues(creditCheckResultCode)!=null) creditCheckResultDescription = CreditCheckSettings__c.getValues(creditCheckResultCode).value__c;
            else creditCheckResultDescription='';
            */
            // get strategy code
            contractStrategyCode = sTrim(getElemText(decisionDetailsElem, MAN_NS, 'contractStrategyCode'));
            
            // get reason codes into map of code and description
            Dom.XMLNode reasonCodesElem = decisionDetailsElem.getChildElement('reasonCodes', MAN_NS);
            reasonCodeMap = new List<String>();
            for(Dom.XMLNode elem : reasonCodesElem.getChildElements()) {
            	
            	// get reason code
            	String reasonCode = sTrim(elem.getText());//getElemText(elem, MAN_NS, 'reasonCode');
            	String reasonDesc = '';
            	
            	// get reason code description from custom setting
	            /*SW CDECISIONS 03/07/2012 - commented out the retrieval of the reason description as this is done in the calling controller
            	if(CreditCheckSettings__c.getValues(reasonCode)!=null) reasonDesc = CreditCheckSettings__c.getValues(reasonCode).value__c;
            	*/
            	//reasonCodeMap.put(sTrim(reasonCode), sTrim(reasonDesc));	//SW CDECISIONS 03/07/2012 - commented out since now only returning the code on it's own
            	reasonCodeMap.add(sTrim(reasonCode));
            }
        }
        
        // Get main response element and SOAP fault check
        private Dom.XMLNode getMainDataElem(String xml) {
            Dom.XMLNode bodyElem = getBodyElem(xml);
            if (bodyElem == null) 
            	throw new ResponseException('Failed to process response. Empty bodyElem!');               
            fault = new SOAFault(bodyElem); 
            if (fault.detected) 
            	throw new ResponseException('Fault: '+ fault.info);        
            Dom.XMLNode creditCheckResponseElem = bodyElem.getChildElement('creditCheckResponse', MAN_NS);           
            if (creditCheckResponseElem == null) 
            	throw new ResponseException('Failed to process response. Empty creditCheckResponse!');
            return creditCheckResponseElem;
        }
        
        // Text output of response properties - general display/debug
	    public String getText() {
	    	String rcStr='';
	    	//for(String rc : reasonCodeMap.keySet()) {	//SW CDECISIONS 03/07/2012 - commented out and rewritten the following section to accommodate change from map to list
	    	for(String rc : reasonCodeMap) {
	    		rcStr += '[' + rc + ']';
	    	}
            return 'CreditCheckResponse: creditCheckResultCode=' + creditCheckResultCode + ':' +
            			'contractStrategyCode=' + contractStrategyCode + 
            			'reasonCodes : '+rcStr;
        }
	}

	// Test responses
    private String getCreditCheckTestXml() {
		String resXml='';
    	if (testFault) {
			resXml += '<?xml version="1.0" encoding="UTF-8"?>';
			resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
			  resXml += '<soapenv:Header xmlns:psc="http://soa.o2.co.uk/pscommondevicedata_1" xmlns:man="http://soa.o2.co.uk/managedevicedata_1" xmlns:cor="http://soa.o2.co.uk/coredata_1">';
			    resXml += '<cor:SOATransactionID>9365c927-ff1b-4541-8b6d-51d62ad740ec</cor:SOATransactionID>';
			  resXml += '</soapenv:Header>';
			  resXml += '<soapenv:Body xmlns:psc="http://soa.o2.co.uk/pscommondevicedata_1" xmlns:man="http://soa.o2.co.uk/managedevicedata_1" xmlns:cor="http://soa.o2.co.uk/coredata_1">';
			    resXml += '<soapenv:Fault>';
			      resXml += '<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope">env:Server</faultcode>';
			      resXml += '<faultstring>Input parameter is invalid.</faultstring>';
			      resXml += '<detail>';
			        resXml += '<man:getDeviceProfileFault>';
			          resXml += '<cor:SOAFaultOriginator>MDM Adapter</cor:SOAFaultOriginator>';
			          resXml += '<cor:SOAFaultCode>managedeviceservice-10023-4001-V</cor:SOAFaultCode>';
			          resXml += '<cor:faultDescription>Input parameter is invalid.</cor:faultDescription>';
			          resXml += '<cor:SOATransactionID>9365c927-ff1b-4541-8b6d-51d62ad740ec</cor:SOATransactionID>';
			        resXml += '</man:getDeviceProfileFault>';
			      resXml += '</detail>';
			    resXml += '</soapenv:Fault>';
			  resXml += '</soapenv:Body>';
			resXml += '</soapenv:Envelope>';    	
    	} else {
    		resXml += '<?xml version="1.0" encoding="UTF-8"?>';
			resXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
			  resXml += '<soapenv:Header xmlns:man="http://soa.o2.co.uk/managecreditcheckdata_1" xmlns:psc="http://soa.o2.co.uk/pscommontransact_1">';
			    resXml += '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">a0680aee-4169-4fbb-9090-85ad6b150e23</cor:SOATransactionID>';
			  resXml += '</soapenv:Header>';
			  resXml += '<soapenv:Body xmlns:oug="http://ougwebcomponent.components.oug.osgi.scorex.com/">';
			    resXml += '<man:creditCheckResponse xmlns:man="http://soa.o2.co.uk/managecreditcheckdata_1">';
			      resXml += '<man:applicationDetails>';
			        resXml += '<man:applicationNumber>000680345</man:applicationNumber>';
			        resXml += '<man:applicationLastUpdated>2012-06-26T10:12:16</man:applicationLastUpdated>';
			      resXml += '</man:applicationDetails>';
			      resXml += '<man:decisionDetails>';
			        resXml += '<man:creditCheckResultCode>C</man:creditCheckResultCode>';
			        resXml += '<man:contractStrategyCode>O2</man:contractStrategyCode>';
			        resXml += '<man:reasonCodes>';
			          resXml += '<man:reasonCode>C002</man:reasonCode>';
			          resXml += '<man:reasonCode>C001</man:reasonCode>';
			        resXml += '</man:reasonCodes>';
			      resXml += '</man:decisionDetails>';
			    resXml += '</man:creditCheckResponse>';
			  resXml += '</soapenv:Body>';
			resXml += '</soapenv:Envelope>';
    	}
    	return resXml;
    }
    
    
    // Request methods
    // - returns response object (throws ResponseException on SOAP fault)
    
    public CreditCheckResponse creditCheckResquest(CreditCheckRequest cr) {
    	return creditCheckResquest(cr, null);
    }
    public CreditCheckResponse creditCheckResquest(CreditCheckRequest cr, List<OrderLine> orderLines) {
    	// Initialise SOA service
    	soaBase = new SOAServicesBase();
        
        // Build request xml
        String ns = 'man';
        String ns2 = 'psc';
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement(ns, 'creditCheck', 'http://soa.o2.co.uk/managecreditcheckdata_1');
        
        w.writeStartElement(ns, 'applicationDetails', '');
        writeElement(w, ns, 'buildLevel', cr.applicationDetails.buildLevel);
        writeElement(w, ns, 'applicationNumber', cr.applicationDetails.applicationNumber);
        writeElement(w, ns, 'transactionDateTime', cr.applicationDetails.transactionDateTime);
        writeElement(w, ns, 'transactionType', cr.applicationDetails.transactionType);
        w.writeEndElement(); 
        if(!isEmpty(cr.sourceOfSaleDetails.getText())) {
            w.writeStartElement(ns, 'sourceOfSaleDetails', '');
            writeElement(w, ns, 'code', cr.sourceOfSaleDetails.code);
            writeElement(w, ns, 'userName', cr.sourceOfSaleDetails.userName);
            writeElement(w, ns, 'ipAddress', cr.sourceOfSaleDetails.ipAddress);
            writeElement(w, ns, 'macAddress', cr.sourceOfSaleDetails.macAddress);
            w.writeEndElement(); 
        }        
        w.writeStartElement(ns, 'customerDetails', '');
        w.writeStartElement(ns, 'personalDetails', '');
        writeElement(w, ns, 'title', cr.customerDetails.personalDetails.title);
        writeElement(w, ns, 'foreName', cr.customerDetails.personalDetails.foreName);
        writeElement(w, ns, 'middleName', cr.customerDetails.personalDetails.middleName); 
        writeElement(w, ns, 'surName', cr.customerDetails.personalDetails.surName);
        writeElement(w, ns, 'dateOfBirth', cr.customerDetails.personalDetails.dateOfBirth);
        writeElement(w, ns, 'gender', cr.customerDetails.personalDetails.gender);
        writeElement(w, ns, 'maritalStatus', cr.customerDetails.personalDetails.maritalStatus);
        writeElement(w, ns, 'numberOfCreditCards', cr.customerDetails.personalDetails.numberOfCreditCards);
        writeElement(w, ns, 'numberOfHandsets', cr.customerDetails.personalDetails.numberOfHandsets); 
        writeElement(w, ns, 'residentialStatus', cr.customerDetails.personalDetails.residentialStatus);     
        writeElement(w, ns, 'numberOfDependants', cr.customerDetails.personalDetails.numberOfDependants); 
        writeElement(w, ns, 'bfpoFlag', cr.customerDetails.personalDetails.bfpoFlag);
        writeElement(w, ns, 'totalHouseHoldIncome', cr.customerDetails.personalDetails.totalHouseHoldIncome); 
        writeElement(w, ns, 'monthlyMortgageOrRentPayment', cr.customerDetails.personalDetails.monthlyMortgageOrRentPayment);    
        writeElement(w, ns, 'agreeToCreditCheck', cr.customerDetails.personalDetails.agreeToCreditCheck);    
        writeElement(w, ns, 'currentContractNumber', cr.customerDetails.personalDetails.currentContractNumber); 
        w.writeEndElement();
        w.writeStartElement(ns, 'contactDetails', '');
        writeElement(w, ns, 'landlineNumber', cr.customerDetails.contactDetails.landlineNumber);
        writeElement(w, ns, 'exDirectoryFlag', cr.customerDetails.contactDetails.exDirectoryFlag);
        writeElement(w, ns, 'contactMobilePhoneNumber', cr.customerDetails.contactDetails.contactMobilePhoneNumber);
        writeElement(w, ns, 'o2MobilePhoneNumber', cr.customerDetails.contactDetails.o2MobilePhoneNumber);
        writeElement(w, ns, 'emailAddress', cr.customerDetails.contactDetails.emailAddress);
        w.writeEndElement();
        if(!isEmpty(cr.customerDetails.currentAddress.getText())) {
            w.writeStartElement(ns, 'currentAddress', '');
            writeElement(w, ns, 'flat', cr.customerDetails.currentAddress.flat);
            writeElement(w, ns, 'houseName', cr.customerDetails.currentAddress.houseName);
            writeElement(w, ns, 'houseNumber', cr.customerDetails.currentAddress.houseNumber); 
            writeElement(w, ns, 'street1', cr.customerDetails.currentAddress.street1);
            writeElement(w, ns, 'street2', cr.customerDetails.currentAddress.street2);
            writeElement(w, ns, 'district', cr.customerDetails.currentAddress.district);    
            writeElement(w, ns, 'town', cr.customerDetails.currentAddress.town);
            writeElement(w, ns, 'county', cr.customerDetails.currentAddress.county);
            writeElement(w, ns, 'postcode', cr.customerDetails.currentAddress.postcode);                     
            writeElement(w, ns, 'equifaxAddressReference', cr.customerDetails.currentAddress.equifaxAddressReference); 
            writeElement(w, ns, 'yearsAtAddress', cr.customerDetails.currentAddress.yearsAtAddress); 
            writeElement(w, ns, 'monthsAtAddress', cr.customerDetails.currentAddress.monthsAtAddress); 
            w.writeEndElement(); 
        }
        if(!isEmpty(cr.customerDetails.previousAddress.getText())) {
            w.writeStartElement(ns, 'previousAddress', '');
            writeElement(w, ns, 'flat', cr.customerDetails.previousAddress.prevflat);
            writeElement(w, ns, 'houseName', cr.customerDetails.previousAddress.prevhouseName);
            writeElement(w, ns, 'houseNumber', cr.customerDetails.previousAddress.prevhouseNumber); 
            writeElement(w, ns, 'street1', cr.customerDetails.previousAddress.prevstreet1);
            writeElement(w, ns, 'street2', cr.customerDetails.previousAddress.prevstreet2);
            writeElement(w, ns, 'district', cr.customerDetails.previousAddress.prevdistrict);    
            writeElement(w, ns, 'town', cr.customerDetails.previousAddress.prevtown);
            writeElement(w, ns, 'county', cr.customerDetails.previousAddress.prevcounty);
            writeElement(w, ns, 'postcode', cr.customerDetails.previousAddress.prevpostcode);                     
            writeElement(w, ns, 'equifaxAddressReference', cr.customerDetails.previousAddress.prevequifaxAddressReference); 
            writeElement(w, ns, 'yearsAtAddress', cr.customerDetails.previousAddress.prevyearsAtAddress); 
            writeElement(w, ns, 'monthsAtAddress', cr.customerDetails.previousAddress.prevmonthsAtAddress); 
            w.writeEndElement(); 
        }        
        if(!isEmpty(cr.customerDetails.deliveryAddress.getText())) {
            w.writeStartElement(ns, 'deliveryAddress', '');
            writeElement(w, ns, 'flat', cr.customerDetails.deliveryAddress.delflat);
            writeElement(w, ns, 'houseName', cr.customerDetails.deliveryAddress.delhouseName);
            writeElement(w, ns, 'houseNumber', cr.customerDetails.deliveryAddress.delhouseNumber); 
            writeElement(w, ns, 'street1', cr.customerDetails.deliveryAddress.delstreet1);
            writeElement(w, ns, 'street2', cr.customerDetails.deliveryAddress.delstreet2);
            writeElement(w, ns, 'district', cr.customerDetails.deliveryAddress.deldistrict);    
            writeElement(w, ns, 'town', cr.customerDetails.deliveryAddress.deltown);
            writeElement(w, ns, 'county', cr.customerDetails.deliveryAddress.delcounty);
            writeElement(w, ns, 'postcode', cr.customerDetails.deliveryAddress.delpostcode);                     
            w.writeEndElement(); 
        }     
        if(!isEmpty(cr.customerDetails.currentEmploymentDetails.getText())) {
            w.writeStartElement(ns, 'currentEmploymentDetails', '');
            writeElement(w, ns, 'employmentStatus', cr.customerDetails.currentEmploymentDetails.employmentStatus);
            writeElement(w, ns, 'yearsSinceEmployed', cr.customerDetails.currentEmploymentDetails.yearsSinceEmployed);
            writeElement(w, ns, 'monthsSinceEmployed', cr.customerDetails.currentEmploymentDetails.monthsSinceEmployed);
            w.writeEndElement();
        }
        if(!isEmpty(cr.customerDetails.creditOrDebitCardDetails.getText())) {
            w.writeStartElement(ns, 'creditOrDebitCardDetails', '');
            writeElement(w, ns2, 'cardType', cr.customerDetails.creditOrDebitCardDetails.cardType);
            writeElement(w, ns2, 'cardNumber', cr.customerDetails.creditOrDebitCardDetails.cardNumber);
            writeElement(w, ns2, 'cardHolderName', cr.customerDetails.creditOrDebitCardDetails.cardHolderName);
            writeElement(w, ns2, 'startDate', cr.customerDetails.creditOrDebitCardDetails.startDate);
            writeElement(w, ns2, 'expiryDate', cr.customerDetails.creditOrDebitCardDetails.expiryDate);
            writeElement(w, ns2, 'cvc', cr.customerDetails.creditOrDebitCardDetails.cvc);
            writeElement(w, ns2, 'issueNumber', cr.customerDetails.creditOrDebitCardDetails.issueNumber);
            w.writeEndElement();
        }
        if(!isEmpty(cr.customerDetails.bankingDetails.getText())) {
            w.writeStartElement(ns, 'bankingDetails', '');
            writeElement(w, ns2, 'accountNumber', cr.customerDetails.bankingDetails.accountNumber);
            writeElement(w, ns2, 'sortCode', cr.customerDetails.bankingDetails.sortCode);
            writeElement(w, ns2, 'accountName', cr.customerDetails.bankingDetails.accountName);
            writeElement(w, ns2, 'yearsSinceBankAccount', cr.customerDetails.bankingDetails.yearsSinceBankAccount);
            writeElement(w, ns2, 'monthsSinceBankAccount', cr.customerDetails.bankingDetails.monthsSinceBankAccount);
            w.writeEndElement();
        }        
        if(!isEmpty(cr.customerDetails.additionalInformation.getText())) {
            w.writeStartElement(ns, 'additionalInformation', '');            
            if(!isEmpty(cr.customerDetails.additionalInformation.passport.getText())) {
                w.writeStartElement(ns, 'passport', '');  
                writeElement(w, ns, 'passportCountryOfIssue', cr.customerDetails.additionalInformation.passport.passportCountryOfIssue);
                w.writeStartElement(ns, 'passportNumber', '');
                writeElement(w, ns2, 'passportNumber1', cr.customerDetails.additionalInformation.passport.passportNumber.passportNumber1);
                writeElement(w, ns2, 'passportNumber2', cr.customerDetails.additionalInformation.passport.passportNumber.passportNumber2);
                writeElement(w, ns2, 'passportNumber3', cr.customerDetails.additionalInformation.passport.passportNumber.passportNumber3);
                writeElement(w, ns2, 'passportNumber4', cr.customerDetails.additionalInformation.passport.passportNumber.passportNumber4);
                writeElement(w, ns2, 'passportNumber5', cr.customerDetails.additionalInformation.passport.passportNumber.passportNumber5);
                writeElement(w, ns2, 'passportNumber6', cr.customerDetails.additionalInformation.passport.passportNumber.passportNumber6);
                writeElement(w, ns2, 'passportNumber7', cr.customerDetails.additionalInformation.passport.passportNumber.passportNumber7);
                w.writeEndElement();
                writeElement(w, ns, 'passportExpiryDate', cr.customerDetails.additionalInformation.passport.passportExpiryDate);
                w.writeEndElement();
            }
            if(!isEmpty(cr.customerDetails.additionalInformation.drivingLicence.getText())) {
                w.writeStartElement(ns, 'drivingLicence', ''); 
                w.writeStartElement(ns, 'drivingLicenceNumber', '');
                writeElement(w, ns2, 'drivingLicenceNumber1', cr.customerDetails.additionalInformation.drivingLicence.drivingLicenceNumber.drivingLicenceNumber1);
                writeElement(w, ns2, 'drivingLicenceNumber2', cr.customerDetails.additionalInformation.drivingLicence.drivingLicenceNumber.drivingLicenceNumber2);
                writeElement(w, ns2, 'drivingLicenceNumber3', cr.customerDetails.additionalInformation.drivingLicence.drivingLicenceNumber.drivingLicenceNumber3);
                writeElement(w, ns2, 'drivingLicenceNumber4', cr.customerDetails.additionalInformation.drivingLicence.drivingLicenceNumber.drivingLicenceNumber4);
                w.writeEndElement();
                writeElement(w, ns, 'drivingLicencePostCode', cr.customerDetails.additionalInformation.drivingLicence.drivingLicencePostCode);
                writeElement(w, ns, 'drivingLicenceMailSort', cr.customerDetails.additionalInformation.drivingLicence.drivingLicenceMailSort);
                w.writeEndElement();
            }
            //<!--Optional:-->
            if(!isEmpty(cr.customerDetails.additionalInformation.mothersMaidenName))
            	writeElement(w, ns, 'mothersMaidenName', cr.customerDetails.additionalInformation.mothersMaidenName); 
            if(!isEmpty(cr.customerDetails.additionalInformation.proofOfIdentity.getText())) {
                w.writeStartElement(ns, 'proofOfIdentity', ''); 
                writeElement(w, ns, 'proofOfIdentityType', cr.customerDetails.additionalInformation.proofOfIdentity.proofOfIdentityType);
                writeElement(w, ns, 'proofOfIdentityReference', cr.customerDetails.additionalInformation.proofOfIdentity.proofOfIdentityReference);
                w.writeEndElement();
            }
            if(!isEmpty(cr.customerDetails.additionalInformation.proofOfAddress.getText())) { 
                w.writeStartElement(ns, 'proofOfAddress', ''); 
                writeElement(w, ns, 'proofOfAddressType', cr.customerDetails.additionalInformation.proofOfAddress.proofOfAddressType);
                writeElement(w, ns, 'proofOfAddressDate', cr.customerDetails.additionalInformation.proofOfAddress.proofOfAddressDate);
                w.writeEndElement();
            }        
            if(!isEmpty(cr.customerDetails.additionalInformation.creditOrDebitCardDetails.getText())) { 
                w.writeStartElement(ns, 'creditOrDebitCardDetails', '');
                writeElement(w, ns2, 'cardType', cr.customerDetails.additionalInformation.creditOrDebitCardDetails.cardType);
                writeElement(w, ns2, 'cardNumber', cr.customerDetails.additionalInformation.creditOrDebitCardDetails.cardNumber);
                writeElement(w, ns2, 'cardHolderName', cr.customerDetails.additionalInformation.creditOrDebitCardDetails.cardHolderName);
                writeElement(w, ns2, 'startDate', cr.customerDetails.additionalInformation.creditOrDebitCardDetails.startDate);
                writeElement(w, ns2, 'expiryDate', cr.customerDetails.additionalInformation.creditOrDebitCardDetails.expiryDate);
                writeElement(w, ns2, 'cvc', cr.customerDetails.additionalInformation.creditOrDebitCardDetails.cvc);
                writeElement(w, ns2, 'issueNumber', cr.customerDetails.additionalInformation.creditOrDebitCardDetails.issueNumber);
                w.writeEndElement();
            }  
            w.writeEndElement();      
        }
        w.writeEndElement(); // end customerDetails  
         
        if(orderLines!=null && orderLines.size()>0) {
            w.writeStartElement(ns, 'orderDetails', ''); 
            writeElement(w, ns, 'orderStatus', cr.orderDetails.orderStatus);
            writeElement(w, ns, 'contractNumber', cr.orderDetails.contractNumber);
            writeElement(w, ns, 'totalMonthlyCharge', cr.orderDetails.totalMonthlyCharge);
            writeElement(w, ns, 'totalOneOffCharge', cr.orderDetails.totalOneOffCharge);
            writeElement(w, ns, 'numberOfHandsets', cr.orderDetails.numberOfHandsets);
            writeElement(w, ns, 'numberOfOrderLines', String.valueOf(orderLines.size()));
            writeElement(w, ns, 'paymentMethod', cr.orderDetails.paymentMethod);
            //<!--1 to 60 repetitions:-->
            for(OrderLine ol: orderLines) {
                if(ol.productCode!='') {
                    w.writeStartElement(ns, 'orderLine', ''); 
                    writeElement(w, ns, 'productCode', ol.productCode);
                    writeElement(w, ns, 'productType', ol.productType);
                    writeElement(w, ns, 'productDescription', ol.productDescription);
                    writeElement(w, ns, 'productCharge', ol.productCharge);
                    writeElement(w, ns, 'productPrice', ol.productPrice);
                    writeElement(w, ns, 'contractTerm', ol.contractTerm);
                    writeElement(w, ns, 'quantity', ol.quantity);
                    w.writeEndElement();  
                }          
            }
            w.writeEndElement();
        }                 
        w.writeEndDocument(); // end creditcheck
        
        String xmlOutput = w.getXmlString();
        w.close();

		// Set endpoint and make SOA request
        String endPoint = null;        
        String resXml = null;
        
        if (Test.isRunningTest()) { 
            resXml = getCreditCheckTestXml();
        } else {
            endPoint = SOA_Integration_Settings__c.getValues('ManageCreditCheck_1_0').Endpoint__c;
            System.debug('***endpoint:'+endPoint);
            if (isEmpty(endPoint)) throw new RequiredDataException('endPoint is required!'); 
            
            resXml = soaBase.sendRequest(endPoint, ENVELOPE_XML_MANCC, xmlOutput);            
        }    
        
        // Return response
        System.debug('MCreditCheck resXml'+resXml);
        creditCheckResponse = new CreditCheckResponse(resXml);
        System.debug('creditCheckResponse.getText()='+ creditCheckResponse.getText()); 
        
        return creditCheckResponse;
    }
    
	// HELPER METHODS

	// Check String empty if null or blank
	public static Boolean isEmpty(String str) {
	    if (str == null) {
	    	return true;
	    } else if (str.trim().length() == 0) {
	    	return true;
	    } else {
	    	return false;
	    }
	}
	// String trim - returns blank if null
	public static String sTrim(String str) {
		if (str == null) {
			return '';
		} else {
    		return str.trim();
		}
	}
	// Get element text - return blank if null
    public static String getElemText(Dom.XMLNode node, String nameSapce, String tag) {
    	Dom.XMLNode childNode = node.getChildElement(tag, nameSapce);
    	if (childNode == null) {
    		return '';
    	} else {
    		return childNode.getText();
    	}
    }	 
    // Get Body element from xml response - throws ResponseException if not found
    public static Dom.XMLNode getBodyElem(String xml) {
		if (isEmpty(xml)) throw new RequiredDataException('xml is required!');
		Dom.Document doc = new Dom.Document();
		doc.load(xml);
        Dom.XMLNode rootElem = doc.getRootElement();
		if (rootElem == null) throw new ResponseException('Failed to process response. Empty rootElem!');
        Dom.XMLNode bodyElem = rootElem.getChildElement('Body', ENV_NS);
        return bodyElem;
    }	 
    // Text element write (xml) 
	public void writeElement(XmlStreamWriter w, String ns, String elName, String elValue) {
        if(elValue!='' && elValue!=null) {
            w.writeStartElement(ns, elName, '');
            w.writeCharacters(elValue);
            w.writeEndElement();    
        }
    }
    // Validate integers (no paterrn match required)
    public static String validateField(String fieldName, Long fieldValue, String mandatory, Integer minLen, Integer maxLen) {
    	String fieldValueStr='';
    	if(fieldValue!=null) 
    		fieldValueStr=String.valueOf(fieldValue);
    	return validateField(fieldName, fieldValueStr, mandatory, minLen, maxLen, null, null);
    }
    // Validate strings
    public static String validateField(String fieldName, String fieldValue, String mandatory, Integer minLen, Integer maxLen, String patternStr, String formatDesc) {
    	String resultMsg='';
    	// check if mandatory
    	if(mandatory=='M' && isEmpty(fieldValue)) {
    		resultMsg = fieldName+' is mandatory.';
    	}
    	// If not mandatory and empty then stop now!
    	if(mandatory!='M' && isEmpty(fieldValue)) {
    		return resultMsg;
    	}
    	// check min and max length
    	if(resultMsg=='' && (minLen!=null || maxLen!=null)) {
    		Integer fldLen=sTrim(fieldValue).length();
    		
    		if(minLen!=null && fldLen<minLen) 
    			resultMsg = 'too short';
    		if(maxLen!=null && fldLen>maxLen) 
    			resultMsg = 'too long';
    		
    		if(resultMsg!='') {
	    		String lenStr='';
	    		if(minLen!=null && maxLen!=null) {
		    		if(minLen==1 && minLen==maxLen) 
		    			lenStr='must be a single character.';
		    		else if(minLen==maxLen) 
		    			lenStr='must be '+minLen+' characters long.';
		    		else if(minLen!=null && maxLen!=null) 
		    			lenStr='must be '+minLen+' to '+maxLen+' characters.';
	    		}
	    		else if(maxLen!=null) lenStr='maximum length '+maxLen+' characters.';
	    		else if(minLen!=null) lenStr='minimum length '+minLen+' characters.';
	    		
	    		resultMsg=fieldName+' ['+fieldValue+'] '+resultMsg+', '+lenStr; 
    		}
    	}
    	// check pattern match
    	if(resultMsg=='' && patternStr!=null && patternStr!='' && !Pattern.matches(patternStr, sTrim(fieldValue))) {
    		if(formatDesc!=null && formatDesc!='')
    			resultMsg = fieldName+' ['+fieldValue+'] invalid format, must be '+formatDesc;
    		else
    			resultMsg = fieldName+' ['+fieldValue+'] has an invalid format';
	    }
    	return resultMsg;
    }
    

    // TEST HELPER METHODS
    static testMethod void testHelpers() {
    	
    	// stri
    	System.assert(CreditCheckSOAHandler.sTrim(null).equalsIgnoreCase(''));
    	System.assert(CreditCheckSOAHandler.sTrim('dfd ').equalsIgnoreCase('dfd'));
    	// isEmpty
    	System.assert(CreditCheckSOAHandler.isEmpty(null)==true);
    	System.assert(CreditCheckSOAHandler.isEmpty('')==true);
    	System.assert(CreditCheckSOAHandler.isEmpty('dd')==false);
    	
    	// getElemText
		String xml = '<?xml version="1.0" encoding="utf-8"?><responseblock version="3.67">  <requestreference>X9093110</requestreference>  <response type="ERROR">    <timestamp>2012-03-26 15:09:29</timestamp>    <error>      <message>Invalid field</message>      <code>30000</code>      <data>pan</data>    </error>  </response></responseblock>';
		Dom.Document doc = new Dom.Document();
		doc.load(xml);
		String errorMessage = '';
		Dom.XMLNode responseRootElem = doc.getRootElement();
		for(Dom.XmlNode node1 : responseRootElem.getChildElements()) {
			System.debug(node1.getName());
			if (node1.getName()=='response') {
				if (node1.getAttribute('type', '').equalsIgnoreCase('ERROR')) {
					for(Dom.XmlNode node2 : node1.getChildElements()) {
						if (node2.getName()=='error') {
					        System.assert(CreditCheckSOAHandler.getElemText(node2, null, 'message') == 'Invalid field');
					        System.assert(CreditCheckSOAHandler.getElemText(node2, null, 'notThere') == '');
						}
					}
				}
			}
		}
		
		// writeElement
		CreditCheckSOAHandler cch = new CreditCheckSOAHandler();
        String ns = 'man';
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement(ns, 'testDoc', '');
        cch.writeElement(w, ns, 'testElemName', 'testText');
		w.writeEndElement();              
        w.writeEndDocument(); // end creditcheck
        
        String xmlOutput = w.getXmlString();
        w.close();
        system.debug('***xmlOutput:'+xmlOutput);
        system.assert(xmlOutput.contains('<man:testElemName>testText</man:testElemName>'));
        
        // ValidateField - for strings
        String valResult='';
        valResult=CreditCheckSOAHandler.validateField('Test field',null,'M',3,4,null,null);
        system.assert(valResult.contains('mandatory'));
        valResult=CreditCheckSOAHandler.validateField('Test field',null,null,3,4,null,null);
        system.assertEquals('',valResult); // valid empty field and not mandatory
        
        // check min max boundaries
        valResult=CreditCheckSOAHandler.validateField('Test field','2',null,3,4,null,null);
        system.assert(valResult.contains('too short'));
        valResult=CreditCheckSOAHandler.validateField('Test field','12345','M',3,4,null,null);
        system.assert(valResult.contains('too long'));       
        valResult=CreditCheckSOAHandler.validateField('Test field','123','M',3,4,null,null);
        system.assertEquals('',valResult); // valid min length
        valResult=CreditCheckSOAHandler.validateField('Test field','1234','M',3,4,null,null);
        system.assertEquals('',valResult); // valid max length
        valResult=CreditCheckSOAHandler.validateField('Test field','12345678','M',3,10,null,null);
        system.assertEquals('',valResult); // valid length within bounds
        
        // check min without max, max without min
        valResult=CreditCheckSOAHandler.validateField('Test field','1','M',3,null,null,null);
        system.assert(valResult.contains('too short')); // invalid under min length, no maximum
        valResult=CreditCheckSOAHandler.validateField('Test field','1234567','M',null,5,null,null);
        system.assert(valResult.contains('too long')); // invalid over max length, no minimum
        valResult=CreditCheckSOAHandler.validateField('Test field','1234','M',3,null,null,null);
        system.assertEquals('',valResult); // valid over min length, no maximum
        valResult=CreditCheckSOAHandler.validateField('Test field','1234','M',null,5,null,null);
        system.assertEquals('',valResult); // valid within max length, no minimum

		// check single character inputs
        valResult=CreditCheckSOAHandler.validateField('Test field','1','M',1,1,null,null);
        system.assertEquals('',valResult); // valid single character
        valResult=CreditCheckSOAHandler.validateField('Test field','22','M',1,1,null,null);
        system.assert(valResult.contains('single character')); // invalid input

		// check fixed length input
        valResult=CreditCheckSOAHandler.validateField('Test field','4444','M',4,4,null,null);
        system.assertEquals('',valResult); // valid fixed 4 length
        valResult=CreditCheckSOAHandler.validateField('Test field','55555','M',4,4,null,null);
        system.assert(valResult.contains('4 characters long')); // invalid input
                
        // check pattern match - length checks 'should be' redundant on pattern match
        valResult=CreditCheckSOAHandler.validateField('Test field','2012-15',null,null,null,'^\\d{4}-((0[1-9])|(1[0-2]))$','format yyyy-mm');
        system.assert(valResult.contains('yyyy-mm')); // invalid month - contains passed description
        valResult=CreditCheckSOAHandler.validateField('Test field','2012-0A',null,null,null,'^\\d{4}-((0[1-9])|(1[0-2]))$',null);
        system.assert(valResult.contains('invalid format')); // invalid month - default description
        valResult=CreditCheckSOAHandler.validateField('Test field','2012-12','M',null,null,'^\\d{4}-((0[1-9])|(1[0-2]))$','format yyyy-mm');
        system.assertEquals('',valResult); // valid
        
        // ValidateField - for numbers (for decimals use string method and suitable pattern)
        // Note: Number fields may be passed as strings, therefore a number validator may not be used and the string validateField() should be used.
        valResult=CreditCheckSOAHandler.validateField('Test field',123456789012345L,'M',3,15);
        system.assertEquals('',valResult); // valid length within bounds
        valResult=CreditCheckSOAHandler.validateField('Test field',123456789012345L,'M',3,10);
        system.assert(valResult.contains('too long')); // invalid length 
    }
    
    
    // TEST PUBLIC METHODS

	// Test SOAP fault
    static testMethod void testSOAFault() {
    	String xml = '<bod>test</bod>';
        Dom.XMLNode bodyElem1 = getBodyElem(xml);
        System.assert(bodyElem1 == null);
        xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body xmlns:oug="http://ougwebcomponent.components.oug.osgi.scorex.com/">test</soapenv:Body></soapenv:Envelope>';
        bodyElem1 = getBodyElem(xml);
        System.assert(bodyElem1 != null);
		SOAFault sf1 =  new SOAFault(bodyElem1);
		System.assert(sf1.faultcode == null);
		System.assert(sf1.faultstring == null);
		System.assert(sf1.detected == false);
    	CreditCheckSOAHandler cch = new CreditCheckSOAHandler();
    	cch.testFault = true;
    	xml = cch.getCreditCheckTestXml();
        Dom.XMLNode bodyElem2 = getBodyElem(xml);
		SOAFault sf2 =  new SOAFault(bodyElem2);
		System.assert(sf2.faultcode != null);
		System.assert(sf2.faultstring != null);
		System.assert(sf2.detected == true);
		System.assert(sf2.info.equalsIgnoreCase(sf2.faultstring + ' ('+sf2.faultcode+')'));
    }
	
	// Test Response and Requests 
    static testMethod void testCreditCheck() { 
    	CreditCheckResponse sp = null;
    	
    	Boolean exceptFound = false;
    	String xml = '<bod>test</bod>';
    	try {
    		sp = new CreditCheckResponse(xml);
    	} catch (ResponseException ex) {
    		exceptFound = true;
    	}
    	System.assert(exceptFound == true);
    	
		exceptFound = false;
    	try {
    		sp = new CreditCheckResponse(null);
    	} catch (RequiredDataException ex) {
    		exceptFound = true;
    	}
    	System.assert(exceptFound == true);
    	
    	
    	exceptFound = false;
    	CreditCheckSOAHandler cch = new CreditCheckSOAHandler();
    	cch.testFault = true;
    	xml = cch.getCreditCheckTestXml();
    	try {
    		sp = new CreditCheckResponse(xml);
    	} catch (ResponseException ex) {
    		exceptFound = true;
    	}
    	System.assert(exceptFound == true);
    	
    	
    	exceptFound = false;
    	cch.testFault = false;
    	xml = cch.getCreditCheckTestXml();
    	system.debug('***xml'+xml);
    	try {
    		sp = new CreditCheckResponse(xml);
    	} catch (ResponseException ex) {
    		exceptFound = true;
    	}
    	System.assert(exceptFound == false);
    	System.debug('sp.getText()='+sp.getText()); 
    	
    	// Test request    	
    	CreditCheckRequest cr = new CreditCheckRequest();
    	
    	// check getText() on empty request (from top level down)
    	String crText=cr.getText();
    	system.assertEquals('',crText);

    	// check getText() on request with lowest level value set (from top level down)
    	cr.customerDetails.additionalInformation.creditOrDebitCardDetails.cardNumber='7878';
    	crText=cr.getText();
    	system.assertEquals('7878',crText);
    	
    	// set some fields - where applicable check customized setters
        cr.applicationDetails.buildLevel = '1234';
        cr.sourceOfSaleDetails.code = 'EE029999';
        
        cr.customerDetails.contactDetails.exDirectoryFlag = 'y';
        system.assertEquals(cr.customerDetails.contactDetails.exDirectoryFlag,'Y');
        cr.customerDetails.personalDetails.maritalStatus = 'q';
        system.assertEquals(cr.customerDetails.personalDetails.maritalStatus,'Q');
        cr.customerDetails.personalDetails.agreeToCreditCheck = 'y';
        system.assertEquals(cr.customerDetails.personalDetails.agreeToCreditCheck,'Y');
        cr.customerDetails.currentEmploymentDetails.employmentStatus = 'z';
        system.assertEquals(cr.customerDetails.currentEmploymentDetails.employmentStatus,'Z');
        cr.applicationDetails.transactionDateTime = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss');
        cr.applicationDetails.transactionType='a';
        system.assertEquals(cr.applicationDetails.transactionType,'A');
        cr.customerDetails.personalDetails.foreName = 'Joe';
        cr.customerDetails.personalDetails.surName = 'Bloggs';
        cr.customerDetails.personalDetails.dateOfBirth = '1980-01-01';
        cr.customerDetails.personalDetails.gender='m';
        system.assertEquals(cr.customerDetails.personalDetails.gender,'M');
        cr.customerDetails.personalDetails.residentialStatus=' o ';
        system.assertEquals(cr.customerDetails.personalDetails.residentialStatus,'O');
        cr.customerDetails.currentAddress.postcode = 'BB1 BB2';
        cr.customerDetails.currentAddress.yearsAtAddress = '1';
        cr.customerDetails.currentAddress.monthsAtAddress = '1';
        cr.customerDetails.creditOrDebitCardDetails.cardHolderName = 'JBloggs';
        cr.customerDetails.creditOrDebitCardDetails.cardNumber = '';
        cr.customerDetails.creditOrDebitCardDetails.expiryDate = '2014-10';
        cr.customerDetails.creditOrDebitCardDetails.cvc = '246';
        cr.customerDetails.creditOrDebitCardDetails.cardType = 't';
        system.assertEquals(cr.customerDetails.creditOrDebitCardDetails.cardType,'T');
        cr.customerDetails.bankingDetails.accountNumber = '';
        cr.customerDetails.bankingDetails.sortCode = '912012';
        cr.customerDetails.bankingDetails.accountName = 'JBloggs';
        cr.customerDetails.previousAddress.prevpostcode='hdhd';
        cr.customerDetails.deliveryAddress.delpostcode='okok';
        cr.customerDetails.creditOrDebitCardDetails.cardNumber='7676';
        cr.customerDetails.bankingDetails.accountNumber='876876';
        cr.customerDetails.additionalInformation.passport.passportNumber.passportNumber1='djfjf';
		cr.customerDetails.additionalInformation.drivingLicence.drivingLicencePostCode='jdjd';
 		cr.customerDetails.additionalInformation.mothersMaidenName='kdkkd';
 		cr.customerDetails.additionalInformation.proofOfIdentity.proofOfIdentityReference='ieie';
 		cr.customerDetails.additionalInformation.proofOfAddress.proofOfAddressDate='4949';
 		
    	sp = cch.creditCheckResquest(cr);
    	system.assertNotEquals(null, sp);
    	
    	// set some order lines
        List<OrderLine> orderLines = new List<OrderLine>();
        for(Integer i=0;i<5;i++) {
        	OrderLine ol=new OrderLine();
        	ol.productDescription='orderline';
            orderLines.add(ol);
        }
        cr.orderDetails.orderLines=orderLines;
        // check text content
        String odText=cr.orderDetails.getText();
        system.debug('****odText'+odText+' size:'+cr.orderDetails.orderLines.size());
        system.assert(odText.contains('orderlineorderlineorderlineorderlineorderline'));
        
        // test customized setters
        cr.orderDetails.orderStatus='m';
        system.assertEquals(cr.orderDetails.orderStatus,'M');
        cr.orderDetails.orderLines[0].productCode='b';
        system.assertEquals(cr.orderDetails.orderLines[0].productCode,'B');
        cr.orderDetails.orderLines[0].productType='t';
        system.assertEquals(cr.orderDetails.orderLines[0].productType,'T');

        
        // Test response
		sp = cch.creditCheckResquest(cr, orderLines);
		system.assertNotEquals(null, sp);

		// check validation - at least one check will be invalid
		List<String> validResultList = cr.validate();
		system.assert(validResultList.size()>0);
		for(String str : validResultList) {
			system.debug(str);
		}
    }

		
}