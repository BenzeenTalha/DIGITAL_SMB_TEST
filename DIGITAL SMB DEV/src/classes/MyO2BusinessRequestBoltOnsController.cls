public with sharing class MyO2BusinessRequestBoltOnsController {

	/*Properties*/
	//Subscription controller
	MyO2BusinessSubscriptionsController subscriptionController;

	//BoltOns  line items
	//BoltOns  line items
	private Set<String> internationalCodes = new Set<String>();
	private Set<String> editableServiceCodes = new Set<String>();
	private Set<String> editableBoltOnCodes = new Set<String>();
	public List<BoltOnsLineItem> BoltOnsLineItems{get; set;}

	public List<BoltOnWrapper> matchedBoltOns{get; set;}
	public List<ServiceCodeWrapper> legacyBoltOns{get; set;}
	public List<BoltOnWrapper> internationalBoltOns{get; set;}

	public List<BoltOnWrapper> allBoltOnsOld{get; set;}

	public Integer boltOnsLineItemsSize{get; set;}

	public List<BoltOnWrapper> addedTotalCaseLineItems {get; set;}
	public List<BoltOnWrapper> removedTotalCaseLineItems {get; set;}

	public static Boolean BoltOnCLItemFlag = false;

	public Boolean smbUser{get; set;}

	public Boolean IsEditable{get; set;}

	public Map<string, string> serviceCodeMap{get;set;}

	public BoltOnWrapper bolton{get;set;}

	public boolean selectcheckbox{get;set;}

	public String nextInvoiceDate{get;set;}

	public String selectedIntIndex{get;set;}


	//Constructor
	public MyO2BusinessRequestBoltOnsController(MyO2BusinessSubscriptionsController controller) {
		//Initalize controller
		try {
			editableBoltOnCodes = new Set<String>();
			editableBoltOnCodes.addAll(Label.MO2B_EDITABLE_BOLTON_CODES.split(','));
			internationalCodes = new Set<String>();
			internationalCodes.addAll(Label.MO2B_INTERNATIONAL_BOLTON_CODES.split(','));
			editableServiceCodes = new Set<String>();
			editableServiceCodes.addAll(Label.MO2B_EDITABLE_SERVICE_CODES.split(','));
		} catch (Exception e) {
			system.debug('MyO2BusinessRequestBoltOnsController - Unable to fetch codes.');
		}
		subscriptionController = (MyO2BusinessSubscriptionsController)controller;
		subscriptionController.stepNumber = 2;
		subscriptionController.IsEditMode = true;
		subscriptionController.newCase = new Case();
		subscriptionController.caseLineItems = new List<mo2b_CaseLineItem__c>();
		OrderFieldNameTemp = '';
		OrderFieldName = '';
		OrderType = '';
		IsSubscriptionRefreshed = false;
		IsEditable = false;
		boltOnsLineItemsSize = 0;
		system.debug('bolt on controller, constructor, subs ctrl = ' + subscriptionController);
		addedTotalCaseLineItems = new List<BoltOnWrapper>();
		removedTotalCaseLineItems = new List<BoltOnWrapper>();
		smbUser= CaseUtils.checkLoginUserSegment();
	}
	public PageReference smbPageName{get; set;}
	public boolean IsSubscriptionRefreshed{get; set;}

	private String intLPad(Integer intToConvert, Integer length, String paddingChar) {
		String result = String.valueOf(intToConvert);
		while (result.length() < length) {
			result = paddingChar + result;
		}
		return result;
	}
	
	public void RefreshExtras(){

		System.debug('Inside Refresh MyO2BusinessRequestBoltOnsController');
		//String selectedId = ApexPages.currentPage().getParameters().get('id');
		//String selectedExtraId = ApexPages.currentPage().getParameters().get('extraId');
		
		boolean result = subscriptionController.GetSubscriptionExtras();
		
		//System.debug('refresh extras, parameters id = ' + selectedId);
		//System.debug('refresh extras, parameters extra id = ' + selectedExtraId);
		if (subscriptionController.SubscriptionsSize == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_NO_SUBSCRIPTIONS_AVAILABLE));
		}
		internationalBoltOns = new List<BoltOnWrapper>();
		matchedBoltOns = new List<BoltOnWrapper>();
		legacyBoltOns = new List<ServiceCodeWrapper>();
		allBoltOnsOld = new List<BoltOnWrapper>();
		Set<String> nonLegacyCodes = new Set<String>();
		Boolean editableExists = false;
		
		selectcheckbox = true;

		system.debug('result-----'+result);
		if(result){
			BoltOnsLineItems = new List<BoltOnsLineItem>();
			system.debug('subscriptionController.selectedExtraSubscriptions----'+subscriptionController.selectedExtraSubscriptions);

			list<string> corporateList = new list<string>();

			for(AC_Subscription_Extra__c selectedSubscription : subscriptionController.selectedExtraSubscriptions) {
				system.debug('dise code is :' + selectedSubscription.DISE_Account_No__c);
				corporateList.add(selectedSubscription.DISE_Account_No__c);
				BoltOnsLineItems.add(new BoltOnsLineItem(selectedSubscription));
			}


			//fetch invoice date
			Date nextInvoiceTaxDate = null;
			List<AC_Account_Invoice__c> InvoiceObjs = [SELECT Id, Account_ID__c, Next_Invoice_Tax_Date__c, Invoice_ID__c FROM AC_Account_Invoice__c WHERE (Account_ID__c IN : corporateList AND Account_ID__c != null) order by Invoice_ID__c desc   limit 1];
			System.debug('invoice date fetching; corporateList = ' + corporateList);
			if (InvoiceObjs.Size() == 0) {
				nextInvoiceDate = 'unknown';
				System.debug('Invoice Object is not found. Next invoice date set to unknown.');
			}
			else {
				AC_Account_Invoice__c InvoiceObj = InvoiceObjs[0];
				System.debug('**Invoice date in date format**' + InvoiceObj.Next_Invoice_Tax_Date__c);
				nextInvoiceTaxDate = InvoiceObj.Next_Invoice_Tax_Date__c;
				String year = String.valueOf(nextInvoiceTaxDate.year());
				String month = intLPad(nextInvoiceTaxDate.month(), 2, '0');
				String day = intLPad(nextInvoiceTaxDate.day(), 2, '0');
				nextInvoiceDate = day + '/' + month + '/' + year;
				System.debug('**Invoice date in string format**' + nextInvoiceDate);
			}

			IsSubscriptionRefreshed = result;       
			smbPageName = Page.smbhome;

			if (boltOnsLineItems.size() > 0){
				System.debug('mo2br refresh extras boltonslineitems size = '+ boltOnsLineItems.size());
				System.debug('**BoltOnsRequest**'+ boltOnsLineItems[0]);
			}
			if (boltOnsLineItems.size() > 0){
				String tariffCode = boltOnsLineItems[0].tariffCode;
				if (editableBoltOnCodes.contains(tariffCode)){
					IsEditable = true;
				}
				else {
					IsEditable = false;
				}
				if(boltOnsLineItems[0].packageCodeList != null) {
					List<RD_Tariff_Package_Service__c> tarrifPackages = [SELECT Id, Service_Description__c, Service_Price__c ,Service_Code__c,Duration_Months__c,Recurring__c
						                                                  FROM RD_Tariff_Package_Service__c WHERE Tariff_Code__c =: boltOnsLineItems[0].tariffCode
						                                                  AND Package_Code__c =: boltOnsLineItems[0].packageCodeList ORDER BY Service_Code__c];
					system.debug('refresh extras, tarrif packages size = ' + tarrifPackages.size()); 
					
					for(RD_Tariff_Package_Service__c tariffPackage : tarrifPackages){

						if(tariffPackage != null){
							nonLegacyCodes.add(tariffPackage.Service_Code__c);
							System.debug('boltons refresh extras, service with desc map - ' + boltOnsLineItems[0].serviceWithDescMap);
							System.debug('boltons refresh extras, other boltons list - ' + boltOnsLineItems[0].otherBoltOnsList);
							System.debug('boltons refresh extras, tariffPackage - ' + tariffPackage);
							BoltOnWrapper boltOnWrapper = new BoltOnWrapper(tariffPackage);
							BoltOnWrapper boltOnWrapperOld = new BoltOnWrapper(tariffPackage);
							boltOnWrapper.recurring = tariffPackage.Recurring__c;
							boltOnWrapper.description = tariffPackage.Service_Description__c;
							boltOnWrapper.price = tariffPackage.Service_Price__c;
							Date recurringDateLimit = GetRecurringDateForServiceCode(tariffPackage.Service_Code__c);
							system.debug('recurringDateLimit in refresh extras = ' + recurringDateLimit);
							system.debug('refresh extras, editable exists1 = ' + editableExists);
							editableExists = true;
							if(boltOnsLineItems[0].serviceWithDescMap.containsKey(tariffPackage.Service_Code__c)){


								boltOnWrapper.isSelected = true;
								boltOnWrapperOld.isSelected = true;
								system.debug('date today' +  Date.today());
								system.debug('invoice date' +  nextInvoiceTaxDate);
								if (internationalCodes.Contains(tariffPackage.Service_Code__c)) {
									if (Date.today() < recurringDateLimit) {
										system.debug('international true, editable false');
										boltOnWrapper.isEditable = false;
									}
									else {
										system.debug('international true, editable true');
										boltOnWrapper.isEditable = true;
									}
									internationalBoltOns.add(BoltOnWrapper);
								}
								else {
									if (tariffPackage.Recurring__c) {
										system.debug('recurring, selected');
										if (Date.today() < recurringDateLimit) {
											system.debug('recurring true, editable false');
											boltOnWrapper.isEditable = false;
											if (editableServiceCodes.contains(tariffPackage.Service_Code__c)) {
												boltOnWrapper.isEditable = true;
											}
										}
										else {
											system.debug('recurring true, editable true');
											boltOnWrapper.isEditable = true;
										}
									}
									else {
										system.debug('one off, selected');
										if (Date.today() < nextInvoiceTaxDate) {
											system.debug('recurring false, editable false');
											boltOnWrapper.isEditable = false;
											if (editableServiceCodes.contains(tariffPackage.Service_Code__c)) {
												boltOnWrapper.isEditable = true;
											}
										}
										else {
											system.debug('recurring false, editable true');
											boltOnWrapper.isEditable = true;
										}
									}
									matchedBoltOns.add(boltOnWrapper);
								}
							}else{
								if (isEditable) {
									boltOnWrapper.isSelected = false;
									boltOnWrapperOld.isSelected = false;
									if (internationalCodes.Contains(tariffPackage.Service_Code__c)) {
										system.debug('deselected international');
										boltOnWrapper.isEditable = true;
										internationalBoltOns.add(BoltOnWrapper);
									} else {
										system.debug('deselected matched');
										boltOnWrapper.isEditable = true;
										matchedBoltOns.add(boltOnWrapper);
									}
								}
							}
							System.debug('Refresh extras - bolt on wrapper = ' + boltOnWrapper);
							allBoltOnsOld.add(boltOnWrapperOld);
						}
						
					}

					System.debug('refresh extras - matchedBoltOns = '+matchedBoltOns);
					System.debug('refresh extras - internationalBoltOns = '+internationalBoltOns);

				} // end of if(package code list)
				
				for (ServiceCodeWrapper scw: boltOnsLineItems[0].otherBoltOnsList) {
					if (!nonLegacyCodes.contains(scw.serviceCode)) {
						legacyBoltOns.add(scw);
					}
				}
				
			}//end of if (boltonsliteitems.size > 0)
			
			
		}// end of if(result)

	}

	private Date GetRecurringDateForServiceCode(String serviceCode) {
		for (ServiceCodeWrapper scw: boltOnsLineItems[0].otherBoltOnsList) {
			if ((scw.serviceCode == serviceCode)&& (scw.effectiveDate != null)) {
				return scw.effectiveDate.addDays(30);
			}
		}
		return subscriptionController.selectedExtraSubscriptions[0].Effective_Date__c.addDays(30);
	}

	//Internal class used to store subscriptions
	public class BoltOnsLineItem implements Comparable{
		//  public List<string> boltOnsValues {get;set;}
		//  public List<string> otherBoltOnsValues {get;set;}

		public Map<String,String> boltOnsMap {get;set;}
		public Map<String,String> serviceCodeMap {get;set;}
		public List<ServiceCodeWrapper> otherBoltOnsList {get;set;} 
		public Map<String,String> additionalboltOnsMap {get;set;}
		public Map<String,String> serviceWithDescMap {get;set;}
		public string tariffCode{get; set;}
		public string packageCode {get; set;}
		public List<string> packageCodeList {get; set;}
		public AC_Subscription_Extra__c SubscriptionExtra{get; set;}
		public string MobileNumber{get; set;}
		public string Subscriber{get; set;}
		public string CompareField{get; set;}
		public string ContractualBoltOns{get; set;}
		public string OtherBoltOns{get; set;}
		public string additionalboltOns{get; set;}
		public Boolean contractualFlag {get; set;}
		public Boolean otherBoltOnFlag {get; set;}
		public string serviceCode{get;set;}

		public String durationInMonths{get;set;}
		public String servicePrice{get;set;}
		public String serviceDescription{get;set;}
		public String effectiveDate{get;set;}
		public String tariffDescription{get;set;}

		public List<ServiceCodeWrapper> contractualBoltOnList {get;set;}




		public BoltOnsLineItem(AC_Subscription_Extra__c SubscriptionExtra){


			otherBoltOnsList = new List<ServiceCodeWrapper>();
			additionalboltOnsMap = new Map<String , String>();
			serviceWithDescMap = new Map<String , String>();
			serviceCodeMap = new Map<String, String>();
			this.contractualFlag = false;
			this.otherBoltOnFlag = false;
			this.SubscriptionExtra = SubscriptionExtra;
			this.CompareField = '';
			this.MobileNumber = SubscriptionExtra.Mobile_Number__c;
			this.Subscriber = SubscriptionExtra.Subscription_Name__c;
			this.tariffCode = SubscriptionExtra.AC_Subscription__r.Tariff_Code__c;
			this.ContractualBoltOns = SubscriptionExtra.Contractual_Bolt_Ons__c; 
			this.tariffDescription = SubscriptionExtra.AC_Subscription__r.Tariff_Description__c;
			this.OtherBoltOns = SubscriptionExtra.Other_Bolt_Ons__c;
			this.serviceCode = SubscriptionExtra.Service_Code__c;
			this.packageCode =  SubscriptionExtra.Package_Code__c;
			//this.servicePrice = SubscriptionExtra.Service_Price__c;
			this.serviceDescription = null;
			this.effectiveDate= null;
			this.durationInMonths= null;
			this.contractualBoltOnList =  new List<ServiceCodeWrapper>();
			this.boltOnsMap = new Map<String,String>();
			this.additionalboltOnsMap = new Map<String , String>();

			if(packageCode != null){
				packageCodeList = packageCode.split(',');
				this.packageCodeList = packageCodeList;
			}

			if(serviceCode!= null){

				serviceCode = serviceCode.replaceAll('],',']#');

				for (String serviceCodeStr : serviceCode.split('#')){

					if(serviceCodeStr != '' && serviceCodeStr != null) {
						System.debug('>>>>serviceCodeStr: '+serviceCodeStr);
						String ServiceCodeVal = serviceCodeStr.replace('[','');
						ServiceCodeVal = ServiceCodeVal.replace(']','');
						System.debug('>>>>serviceCodeStr: '+serviceCodeStr);
						List<String> ServiceValArray = ServiceCodeVal.split(',');
						System.debug('>>>>ServiceValArray: '+ServiceValArray);
						// description, service code
						this.serviceCodeMap.put(ServiceValArray[1], ServiceValArray[0]);

					}
				}


			}
			System.debug('**packageCodeList**'+packageCodeList);
			System.debug('**ContractualBoltOns**'+ContractualBoltOns);
			if(ContractualBoltOns != null){




				ContractualBoltOns = ContractualBoltOns.replaceAll('],',']#');
				//boltOnsValues = ContractualBoltOns.split(',');
				for (String boltOnStr : ContractualBoltOns.split('#')){


					if(boltOnStr != '' && boltOnStr != null) {
						System.debug('>>>>boltOnStr: '+boltOnStr);
						String boltVal = boltOnStr.replace('[','');
						boltVal = boltVal.replace(']','');
						System.debug('>>>>boltVal: '+boltVal);
						List<String> boltValArray = boltVal.split(',');
						System.debug('>>>>boltValArray: '+boltValArray);
						this.boltOnsMap.put(boltValArray[1],boltValArray[2]);
						ServiceCodeWrapper serviceCodeWrapper = new ServiceCodeWrapper(boltValArray[0],boltValArray[1],boltValArray[2]);
						this.contractualBoltOnList.add(serviceCodeWrapper);
					}
				}

				// system.debug('contractual bolt on list size is :' +this.contractualBoltOnList.size());
				//  this.boltOnsValues = boltOnsValues;
				this.contractualFlag = true;
			}

			System.debug('boltonslineitem constructor **OtherBoltOns**'+OtherBoltOns);
			if(OtherBoltOns != null){
				OtherBoltOns = OtherBoltOns.replaceAll('],',']#');
				//boltOnsValues = ContractualBoltOns.split(',');
				for (String boltOnStrr : OtherBoltOns.split('#')){
					if(boltOnStrr != '' && boltOnStrr != null) {
						System.debug('>>>>boltOnStrr: '+boltOnStrr);
						String boltValue = boltOnStrr.replace('[','');
						boltValue = boltValue.replace(']','');
						System.debug('>>>>boltValue: '+boltValue);
						List<String> otherboltValArray = boltValue.split(',');
						System.debug('>>>>otherboltValArray: '+otherboltValArray);
						if (otherboltValArray.size()==3){
							this.otherBoltOnsList.add(new ServiceCodeWrapper(otherboltValArray[0], otherboltValArray[1], otherboltValArray[2]));
							this.additionalboltOnsMap.put(otherboltValArray[1], otherboltValArray[2]);
						}
						if (otherboltValArray.size()==4){
							this.otherBoltOnsList.add(new ServiceCodeWrapper(otherboltValArray[0], otherboltValArray[1], otherboltValArray[2], otherBoltValArray[3]));
							this.additionalboltOnsMap.put(otherboltValArray[1], otherboltValArray[2]);
						}
						this.serviceWithDescMap.put(otherboltValArray[0], otherboltValArray[1]);
					}
				}
				//  this.otherBoltOnsValues = otherBoltOnsValues;
				this.otherBoltOnFlag = true;
			}


		}


		public integer compareTo(Object compareTo){
			BoltOnsLineItem otherItem = (BoltOnsLineItem)compareTo;
			integer result = 0;
			if(CompareField == 'MOBILE_NUMBER'){
				result = this.MobileNumber.compareTo(otherItem.MobileNumber);
			} else if (CompareField == 'SUBSCRIBER'){
				result = this.Subscriber.compareTo(otherItem.Subscriber);
			} else if (CompareField == 'Bolt_Ons'){
				result = this.ContractualBoltOns.compareTo(otherItem.ContractualBoltOns);
			}
			return result;
		}
	}


	//Sort help properties
	public string OrderFieldNameTemp {get; set;}
	public string OrderFieldName {get; set;}
	public string OrderType {get; set;}

	//Sort
	public void SortList(){
		if(OrderFieldNameTemp != OrderFieldName){
			OrderType = 'ASC';
			OrderFieldName = OrderFieldNameTemp;
		} else {
			OrderType = OrderType != 'ASC' ? 'ASC' : 'DESC';
		}
		for(BoltOnsLineItem li : BoltOnsLineItems){
			li.CompareField = OrderFieldName;
		}
		BoltOnsLineItems.sort();
		if(OrderType == 'DESC'){
			List<BoltOnsLineItem> temp = new List<BoltOnsLineItem>();
			for(integer i = BoltOnsLineItems.size() - 1; i>= 0; i--){
				temp.add(BoltOnsLineItems[i]);
			}
			BoltOnsLineItems = temp;
		}
	}


	public List<BoltOnWrapper> reportBoltOnsToAdd {get;set;}
	public List<BoltOnWrapper> reportBoltOnsToRemove {get;set;}

	public void PrepareSummary() {
		reportBoltOnsToAdd = new List<BoltOnWrapper>();
		reportBoltOnsToRemove = new List<BoltOnWrapper>();
		// Added Boltons
		List<BoltOnWrapper> allBoltOns = new List<BoltOnWrapper>();
		if (matchedBoltOns != null){
			allBoltOns.addAll(matchedBoltOns);
		}
		if (internationalBoltOns != null){
			allBoltOns.addAll(internationalBoltOns);
		}
		System.debug ('prepare summary - all bolt ons size = ' + allBoltOns.size());
		System.debug ('prepare summary - all bolt old ons size = ' + allBoltOnsOld.size());
		if(allBoltOns != null && allBoltOns.size() >=1
				&& allBoltOnsOld != null && allBoltOnsOld.size() >= 1) {
			for (BoltOnWrapper newBoltOn: allBoltOns) {
				for (BoltOnWrapper oldBoltOn: allBoltOnsOld) {
					if (oldBoltOn.tariffPackage.Service_Code__c == newBoltOn.tariffPackage.Service_Code__c) {
						System.debug('prepare summary - new bolt on = ' + newBoltOn);
						System.debug('prepare summary - old bolt on = ' + oldBoltOn);
						if((!oldBoltOn.isSelected && newBoltOn.isSelected)){
							reportBoltOnsToAdd.add(newBoltOn);
						}
						if((oldBoltOn.isSelected && !newBoltOn.isSelected)){
							reportBoltOnsToRemove.add(newBoltOn);
						}
					}
				}
			}
		}
	}

	//Submit
	public PageReference SubmitRequest(){

		subscriptionController.newCase.Request_Sub_Type__c = CaseUtils.BOLT_ON_CHANGE_CASE_REQUEST_SUBTYPE;
		subscriptionController.newCase.Service_Request_Type__c = CaseUtils.CASE_REQUEST_TYPE_CHANGE;
		subscriptionController.newCase.Subject = CaseUtils.BOLT_ON_CHANGE_CASE_SUBJECT;

		// Calculate the created date for SOA in yyyy-mm-dd format

		Datetime todayDate = System.today();
		String createdDate = todayDate.format('yyyy-MM-dd');                
		subscriptionController.newCase.Created_date__c = createdDate;

		String boltOnsToAdd;
		String boltOnsToRemove;
		String boltOnsToAddFormatted;
		String boltOnsToRemoveFormatted;
		String serviceCodeToAdd;
		String serviceCodeToRemove;
		String requestedService;

		List<BoltOnWrapper> allBoltOns = new List<BoltOnWrapper>();
		allBoltOns.addAll(matchedBoltOns);
		allBoltOns.addAll(internationalBoltOns);
		for (BoltOnWrapper addBolton: reportBoltOnsToAdd) {
			if(serviceCodeToAdd != null){
				serviceCodeToAdd = serviceCodeToAdd + ',' + addBolton.tariffPackage.Service_Code__c;
			}else{
				serviceCodeToAdd = addBolton.tariffPackage.Service_Code__c;
			}
			if(boltOnsToAdd!= null){
				boltOnsToAdd = boltOnsToAdd + ',' + addBolton.tariffPackage.Service_Description__c + '_' + (addBolton.tariffPackage.Service_Price__c) * 100;
				boltOnsToAddFormatted = boltOnsToAddFormatted + ',' + addBolton.tariffPackage.Service_Description__c + '_£' + addBolton.tariffPackage.Service_Price__c;
			}else{
				boltOnsToAdd = addBolton.tariffPackage.Service_Description__c + '_' + (addBolton.tariffPackage.Service_Price__c) * 100;
				boltOnsToAddFormatted = addBolton.tariffPackage.Service_Description__c + '_£' + addBolton.tariffPackage.Service_Price__c;
			}
			if(requestedService != null){
				requestedService= requestedService + ',' + Label.SMB_Add;
			}else{
				requestedService = Label.SMB_Add;
			}
		}
		for (BoltOnWrapper removeBolton: reportBoltOnsToRemove) {
			if(serviceCodeToRemove != null){
				serviceCodeToRemove = serviceCodeToRemove + ',' + removeBolton.tariffPackage.Service_Code__c;
			}else{
				serviceCodeToRemove = removeBolton.tariffPackage.Service_Code__c;
			}
			if(boltOnsToRemove != null){
				boltOnsToRemove = boltOnsToRemove + ',' + removeBolton.tariffPackage.Service_Description__c + '_' + (removeBolton.tariffPackage.Service_Price__c) * 100;
				boltOnsToRemoveFormatted = boltOnsToRemoveFormatted + ',' + removeBolton.tariffPackage.Service_Description__c + '_£' + removeBolton.tariffPackage.Service_Price__c;
			}else{
				boltOnsToRemove = removeBolton.tariffPackage.Service_Description__c + '_' + (removeBolton.tariffPackage.Service_Price__c) * 100;
				boltOnsToRemoveFormatted = removeBolton.tariffPackage.Service_Description__c + '_£' + removeBolton.tariffPackage.Service_Price__c;
			}
			if(requestedService != null){
				requestedService = requestedService + ',' + Label.SMB_Remove;
			}else{
				requestedService = Label.SMB_Remove;
			}
		}

		mo2b_CaseLineItem__c li = new mo2b_CaseLineItem__c(AC_Subscription__c = boltOnsLineItems[0].SubscriptionExtra.AC_Subscription__c,
				SOA_Call_Type__c = CaseUtils.BOLT_ON_CHANGE_CALLOUT_TYPE,
				RecordTypeId = Cache.RecordTypeId('mo2b_CaseLineItem__c.' + CaseUtils.BOLT_ON_CHANGE_CASE_LINE_ITEM_RECORD_TYPE),
				Bolt_Ons_to_add__c = boltOnsToAdd,
				Bolt_Ons_to_remove__c = boltOnsToRemove,
				Bolt_Ons_to_Add_Formatted__c = boltOnsToAddFormatted,
				Bolt_Ons_to_Remove_Formatted__c = boltOnsToRemoveFormatted,
				Service_codes_to_add__c = serviceCodeToAdd,
				Service_codes_to_remove__c = serviceCodeToRemove,
				SOA_Last_Amended_Date__c = createdDate); 


		subscriptionController.caseLineItems.add(li);


		if(subscriptionController.caseLineItems.size() > 0){

			system.debug('inside caseLineItems ');
			subscriptionController.CreateCase();
		}

		List<MyO2BusinessBoltOnUpdate__c> servicesModified = new List<MyO2BusinessBoltOnUpdate__c>();
		String diseAccountNo = '';
		if (subscriptionController.selectedExtraSubscriptions.size() > 0) {
			diseAccountNo = boltOnsLineItems[0].SubscriptionExtra.DISE_Account_No__c;
		}
		for(BoltOnWrapper bow: reportBoltOnsToAdd){
			MyO2BusinessBoltOnUpdate__c sm = new MyO2BusinessBoltOnUpdate__c(
					Name = bow.tariffPackage.Service_Code__c,
					Add_Remove__c = 'Add',
					Customer_Request__c = li.Id,
					Description__c = bow.tariffPackage.Service_Description__c,
					Price__c = bow.tariffPackage.Service_Price__c,
					Recurring__c = bow.tariffPackage.Recurring__c,
					DISE_Account_No__c = diseAccountNo
			);
			servicesModified.add(sm);
		}
		for(BoltOnWrapper bow: reportBoltOnsToRemove){
			MyO2BusinessBoltOnUpdate__c sm = new MyO2BusinessBoltOnUpdate__c(
					Name = bow.tariffPackage.Service_Code__c,
					Add_Remove__c = 'Remove',
					Customer_Request__c = li.Id,
					Description__c = bow.tariffPackage.Service_Description__c,
					Price__c = bow.tariffPackage.Service_Price__c,
					Recurring__c = bow.tariffPackage.Recurring__c,
					DISE_Account_No__c = diseAccountNo
			);
			servicesModified.add(sm);
		}
		System.debug('submit request - services modified = ' + servicesModified);
		insert servicesModified; 

		PageReference r = null;
		if(smbUser){
			r = Page.SMBRequestConfirmation;
		}else{
			r = Page.MyO2BusinessRequestConfirmation;
		}

		r.getParameters().put('id', subscriptionController.newCase.Id);
		return r;
	}  

	public PageReference FinishEditBoltons(){
		PrepareSummary();
		if ((reportBoltOnsToAdd.size() == 0) && (reportBoltOnsToRemove.size() == 0)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MY_O2_BUSINESS_BOLTON_NOCHANGE_VALIDATION));
			return null;
		}
		return Page.MyO2BusinessRequestBoltOnsSummary;
	}

	public class BoltOnWrapper {
		public Boolean isSelected {get;set;}
		public Boolean isEditable {get;set;}
		public Boolean recurring {get;set;}
		public String description {get;set;}
		public Decimal price {get;set;}
		public RD_Tariff_Package_Service__c tariffPackage {get;set;}

		public BoltOnWrapper(RD_Tariff_Package_Service__c tariffPackage){
			this.tariffPackage = tariffPackage;
			this.isSelected = false;
			this.isEditable = false;
		}
	} 

	public class ServiceCodeWrapper{

		public String serviceCode{get;set;}
		public String serviceDescription{get;set;}
		public String servicePrice{get;set;}
		public Date effectiveDate{get;set;}


		public ServiceCodeWrapper(String serviceCode, String serviceDescription, String servicePrice){
			this.serviceCode = serviceCode;
			this.serviceDescription= serviceDescription;
			this.servicePrice = servicePrice;
		}

		public ServiceCodeWrapper(String serviceCode, String serviceDescription, String servicePrice, String effectiveDate){
			this.serviceCode = serviceCode;
			this.serviceDescription= serviceDescription;
			this.servicePrice = servicePrice;
			try{
				this.effectiveDate = CaseUtils.parseDateFromString(effectiveDate);
			} catch (Exception e) {
				System.debug('Service code wrapper, unable to parse date from '+ effectiveDate);
			}
		}

	}


}