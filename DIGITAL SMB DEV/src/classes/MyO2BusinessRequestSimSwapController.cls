public with sharing class MyO2BusinessRequestSimSwapController {

	/*Constants*/
	private static final string NEW_SIM_NUMBER_START = '894411';

	/*Properties*/
	//Subscription controller
	MyO2BusinessSubscriptionsController subscriptionController;

	//Sim Swap Case line items
	public List<SimSwapCaseLineItem> simSwapCaseLineItems{get; set;}
	public static List<mo2b_CaseLineItem__c> cli {get; set;}
	//IsLostStolen
	public boolean IsLostStolen{get; set;}
	public static Boolean simSwapChangeFlag = false;
	public static Boolean smsFlag = true;
	
	public static List<mo2b_CaseLineItem__c> smsStatusList {get; set;}

	// to set whether teh logged in user is a smb user or not
	public Boolean smbUser{get; set;}
	
	 public String mtProfile{get;set;} 


	//Consturctor
	public MyO2BusinessRequestSimSwapController(MyO2BusinessSubscriptionsController controller) {

		//Intitalize controller
		subscriptionController = (MyO2BusinessSubscriptionsController)controller;
		subscriptionController.stepNumber = 2;
		subscriptionController.IsEditMode = true;
		subscriptionController.newCase = new Case();
		subscriptionController.caseLineItems = new List<mo2b_CaseLineItem__c>();
		smsStatusList = new List<mo2b_CaseLineItem__c>();
		cli=  subscriptionController.caseLineItems;
		IsLostStolen = false;
		OrderFieldNameTemp = '';
		OrderFieldName = '';
		OrderType = '';
		IsSubscriptionRefreshed = false;
		smbUser= CaseUtils.checkLoginUserSegment();
		mtProfile = MyO2BusinessActivationCodeExtension.getMTProfile();
	}

	public String newSimNumberStart{get;set;}

	public void InitData() {
		newSimNumberStart =  NEW_SIM_NUMBER_START;
		RefreshExtras();
	}

	public boolean IsSubscriptionRefreshed{get; set;}
	
	
	//  Call to sendSMS () method for SIM Swap SMS Notification

	public static void sendSMS(String mtProfile, String networkCode, String message)
	{

		system.debug('network code is :' + networkCode);
		
		String smsMessage = message;
		try {
			String resXml =SOASendMessage.sendSMS(mtProfile, networkCode, smsMessage);
			
			Dom.XMLNode sendSMSResponseElem = SOASendMessage.getMainDataElem(resXml);
			if(sendSMSResponseElem == null){
				
				smsFlag = false;
			}
			system.debug('sms response is :' + sendSMSResponseElem);
		} catch (Exception ex) {
			system.debug('send sms, exception = ' + ex.getMessage());
			smsFlag = false;
		}
		

	}
	
	/*public class SMSResponseWrapper {
		private String MPN;
		private String response;
		public SMSResponseWrapper (String MPN, String response) {
			this.MPN = MPN;
			this.response = response;
		}
		
	}
	
	public List<SMSResponseWrapper> smsFlags {get;set;} */
	public Set<String> acceptedMPNSMS {get;set;}
	
	public void bulkSendSMS(String mtProfile, List<String> networkCodes, String message)
	{
		acceptedMPNSMS = new Set<String>();
		system.debug('network codes are :' + networkCodes);
		try{
			String smsMessage = message;
		
			String resXml =SOASendMessage.bulkSendSMS(mtProfile, networkCodes, smsMessage);
			
			Dom.XMLNode sendSMSResponseElem = SOASendMessage.getMainDataElem(resXml);
			Dom.XMLNode result = sendSMSResponseElem.getChildElement('result', SOASendMessage.SEN_NS);
			Dom.XMLNode messageReceipt = result.getChildElement('messageReceipt', SOASendMessage.SEN_NS);
			Dom.XMLNode[] msisdnStatuses = messageReceipt.getChildElements();
			
			for (Dom.XMLNode msisdnStatus: msisdnStatuses){
				
				Dom.XMLNode status = msisdnStatus.getChildElement('status', SOASendMessage.SEN_NS);
				Dom.XMLNode msisdn = msisdnStatus.getChildElement('msisdn', SOASendMessage.SEN_NS);
				
				system.debug('bulk send SMS, mpn = ' + msisdn.getText());
				system.debug('bulk send SMS, status = ' + status.getText());
				
				if (status.getText()=='ACCEPTED') {
					acceptedMPNSMS.add(msisdn.getText());
				}
			}
			
		} catch (Exception ex) {
			system.debug('send bulk sms, exception = ' + ex.getMessage());
		}

	}
	
	
	public void RefreshExtras(){
		boolean result = subscriptionController.GetSubscriptionExtras();
		if (subscriptionController.SubscriptionsSize == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_NO_SUBSCRIPTIONS_AVAILABLE));
		}
		if(result){
			simSwapCaseLineItems = new List<SimSwapCaseLineItem>();
			for(AC_Subscription_Extra__c selectedSubscription : subscriptionController.selectedExtraSubscriptions) {
				simSwapCaseLineItems.add(new SimSwapCaseLineItem(selectedSubscription));
			}
		}
		IsSubscriptionRefreshed = result;
	}

	public PageReference FinishEditSIM(){
		system.debug('FinishEditSIM---method called-');
		List<Integer> unchangedSIMIndexes = new List<Integer>();
		Integer currIndex = 0;
		for(SimSwapCaseLineItem sli : simSwapCaseLineItems){
			if ((sli.NewSimUnformated == null) 
				|| (sli.NewSimUnformated == '') 
				|| (sli.NewSimUnformated == NEW_SIM_NUMBER_START)) {
				unchangedSIMIndexes.add(currIndex);
			}
			currIndex++;
		}
		System.debug ('SIM swap - Finish edit - removing indexes = ' + unchangedSIMIndexes);
		for (Integer i = (unchangedSIMIndexes.size()-1); i>=0; i--) {
			SimSwapCaseLineItems.remove(unchangedSIMIndexes.get(i));
		}
		subscriptionController.errorExtraSubscriptions.clear();
		subscriptionController.IsEditMode = false;
		subscriptionController.stepNumber = 3;
		return null;
	}

	//Submit
	public PageReference SubmitRequest(){
		//Send SMS before creating cases (SalesForce limitations)
		Set<String> SIMacceptedSMS = new Set<String>();
		List<String> MPNs = new List<String>(); 
		for(SimSwapCaseLineItem sli : simSwapCaseLineItems){
			if(sli.NewSimUnformated != null 
				//&& (sli.NewSimUnformated != sli.SubscriptionExtra.SIM_Number__c)
				&& (sli.NewSimUnformated != '')
				&& (sli.NewSimUnformated != NEW_SIM_NUMBER_START)){
					if(!Test.isRunningTest()){
						MPNs.add(sli.MobileNumber);
					}
			}
		}
		if(!Test.isRunningTest()){
			if (MPNs.size() != 0){
				bulkSendSMS(mtProfile,MPNs,System.Label.MY_O2_BUSINESS_SIM_SWAP_NOTIFICATION_SMS);
			}
		}
		system.debug('sim swap submit request accepted MPNs' + acceptedMPNSMS);
		Savepoint sp = Database.setSavepoint();

		try{

			subscriptionController.newCase.Request_Sub_Type__c = CaseUtils.SIM_SWAP_CASE_REQUEST_SUBTYPE;
			subscriptionController.newCase.Service_Request_Type__c = CaseUtils.CASE_REQUEST_TYPE_CHANGE;
			subscriptionController.newCase.Subject = CaseUtils.SIM_SWAP_CASE_SUBJECT;

			//Added for SOSL search functionality
			Datetime todayDate = System.today();
			String createdDate = todayDate.format('dd/MM/yyyy');

			subscriptionController.newCase.Created_date__c = createdDate;




			//Case line items
			for(SimSwapCaseLineItem sli : simSwapCaseLineItems){
				if(sli.NewSimUnformated != null 
					//&& (sli.NewSimUnformated != sli.SubscriptionExtra.SIM_Number__c)
					&& (sli.NewSimUnformated != '')
					&& (sli.NewSimUnformated != NEW_SIM_NUMBER_START)){
					String nofiticationStatus = System.Label.MY_O2_BUSINESS_SIM_SWAP_NOTIFICATION_NOTACCEPTED;
					String cleanMPN = SOAUtils.cleanDirectoryNumber(sli.MobileNumber);
					system.debug('sim swap submit, mobile number = ' + sli.MobileNumber);
					system.debug('sim swap submit, mobile number = ' + cleanMPN);
					if (acceptedMPNSMS.contains(cleanMPN)) {
						nofiticationStatus = System.Label.MY_O2_BUSINESS_SIM_SWAP_NOTIFICATION_ACCEPTED;
					}
					mo2b_CaseLineItem__c li = new mo2b_CaseLineItem__c(AC_Subscription__c = sli.SubscriptionExtra.AC_Subscription__c,
							New_SIM_Number__c = sli.NewSimUnformated,
							SOA_Call_Type__c = CaseUtils.UPDATE_SUBSCRIPTION_SERIAL_NUMBERS,
							New_Device_Details__c = sli.NewHandset,
							RecordTypeId = Cache.RecordTypeId('mo2b_CaseLineItem__c.' + CaseUtils.SIM_SWAP_CASE_LINE_ITEM_RECORD_TYPE),
							Old_SIM_Number__c = sli.SubscriptionExtra.SIM_Number__c,
							Network_Serial_No__c = sli.MobileNumber,
							SMS_Notification_Status__c = nofiticationStatus);
					subscriptionController.caseLineItems.add(li);
				}
			}
			simSwapChangeFlag = true;
			if(subscriptionController.caseLineItems.size() > 0){
				cli = subscriptionController.caseLineItems;
				system.debug('cli size is :' + cli.size());
				subscriptionController.CreateCase();
			}

		} catch (Exception ex){
			System.Debug('My O2 Business - SIM Swap - Error Inserting New Case: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MO2B_ERROR_GUIDED_JOURNY));
			Database.rollback(sp);
			//throw(ex);
			return null;
		}
		
		PageReference r = null;
		if(smbUser){
			r = Page.SMBRequestConfirmation;
		}else{
			r = Page.MyO2BusinessRequestConfirmation;
		}

		r.getParameters().put('id', subscriptionController.newCase.Id);

		return r;
	}

	//Internal class used to store subscriptions
	public class SimSwapCaseLineItem implements Comparable{

		public AC_Subscription_Extra__c SubscriptionExtra{get; set;}
		public string[] NewSim{get; set;}
		public string NewHandset{get; set;}
		public string MobileNumber{get; set;}
		public string Subscriber{get; set;}
		public string NewSimFormated{
			get{
				return NewSim[0] + ' ' + NewSim[1] + ' ' + NewSim[2] + ' ' + NewSim[3];
			}
		}
		public string NewSimUnformated{
			get{
				return NewSim[0] + NewSim[1] + NewSim[2] + NewSim[3];
			}
		}

		public SimSwapCaseLineItem(AC_Subscription_Extra__c SubscriptionExtra){
			this.SubscriptionExtra = SubscriptionExtra;
			this.NewSim = new string[4];
			this.NewSim[0] = NEW_SIM_NUMBER_START;
			this.NewSim[1] = this.NewSim[2] = this.NewSim[3] = '';
			this.MobileNumber = SubscriptionExtra.AC_Subscription__r.Network_Serial_No__c;
			this.Subscriber = SubscriptionExtra.AC_Subscription__r.Subscription_Name__c;            
			this.NewHandset = '';
			this.CompareField = '';
		}

		public string CompareField{get; set;}
		public integer compareTo(Object compareTo){
			SimSwapCaseLineItem otherItem = (SimSwapCaseLineItem)compareTo;
			integer result = 0;
			if(CompareField == 'MOBILE_NUMBER'){
				result = this.SubscriptionExtra.AC_Subscription__r.Network_Serial_No__c.compareTo(otherItem.SubscriptionExtra.AC_Subscription__r.Network_Serial_No__c);
			} else if (CompareField == 'SUBSCRIBER'){

				if(this.SubscriptionExtra.AC_Subscription__r.Subscription_Name__c != null && otherItem.SubscriptionExtra.AC_Subscription__r.Subscription_Name__c != null){
					result = this.SubscriptionExtra.AC_Subscription__r.Subscription_Name__c.compareTo(otherItem.SubscriptionExtra.AC_Subscription__r.Subscription_Name__c);
				}
			} else if (CompareField == 'NEW_SIM'){
				result = this.NewSimUnformated.compareTo(otherItem.NewSimUnformated);
			} else if (CompareField == 'NEW_HANDSET'){
				result = this.NewHandset.compareTo(otherItem.NewHandset);
			}
			return result;
		}
	}

	//Sort
	public void SortList(){
		if(OrderFieldNameTemp != OrderFieldName){
			OrderType = 'ASC';
			OrderFieldName = OrderFieldNameTemp;
		} else {
			OrderType = OrderType != 'ASC' ? 'ASC' : 'DESC';
		}
		for(SimSwapCaseLineItem li : simSwapCaseLineItems){
			li.CompareField = OrderFieldName;
		}
		simSwapCaseLineItems.sort();
		if(OrderType == 'DESC'){
			List<SimSwapCaseLineItem> temp = new List<SimSwapCaseLineItem>();
			for(integer i = simSwapCaseLineItems.size() - 1; i>= 0; i--){
				temp.add(simSwapCaseLineItems[i]);
			}
			simSwapCaseLineItems = temp;
		}
	}

	//Sort help properties
	public string OrderFieldNameTemp {get; set;}
	public string OrderFieldName {get; set;}
	public string OrderType {get; set;}


}