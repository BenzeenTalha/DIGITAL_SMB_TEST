public with sharing class MyO2BusinessRequestBarChangeController {

	/*Properties*/
	//Subscription controller
	MyO2BusinessSubscriptionsController subscriptionController;


	//Sim Swap Case line items
	public List<BarChangeCaseLineItem> barChangeCaseLineItems{get; set;}

	// to store the initial state of the subscriptions
	public List<BarChangeCaseLineItem> oldBarChangeCaseLineItems{get; set;}

	//IsLostStolen
	public boolean IsLostStolen{get; set;}


	//Sort help properties
	public string OrderFieldNameTemp {get; set;}
	public string OrderFieldName {get; set;}
	public string OrderType {get; set;}

	// to set whether teh logged in user is a smb user or not
	public Boolean smbUser{get; set;}
	//public boolean IsEditMode{get; set;}
	//public integer stepNumber{get; set;}

	//Consturctor
	public MyO2BusinessRequestBarChangeController(MyO2BusinessSubscriptionsController controller) {

		//Intitalize controller
		subscriptionController = (MyO2BusinessSubscriptionsController)controller;
		subscriptionController.stepNumber = 2;
		subscriptionController.IsEditMode = true;
		subscriptionController.newCase = new Case();
		subscriptionController.caseLineItems = new List<mo2b_CaseLineItem__c>();
		IsLostStolen = false;
		OrderFieldNameTemp = '';
		OrderFieldName = '';
		OrderType = '';
		IsSubscriptionRefreshed = false;
		smbUser= CaseUtils.checkLoginUserSegment();

	}

	public boolean IsSubscriptionRefreshed{get; set;}

	public void RefreshExtras(){
		boolean result = subscriptionController.GetSubscriptionExtras();
		if (subscriptionController.SubscriptionsSize == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_NO_SUBSCRIPTIONS_AVAILABLE));
		}
		oldBarChangeCaseLineItems = new List<BarChangeCaseLineItem>();
		if(result){
			barChangeCaseLineItems = new List<BarChangeCaseLineItem>();
			for(AC_Subscription_Extra__c selectedSubscription : subscriptionController.selectedExtraSubscriptions) {
				barChangeCaseLineItems.add(new BarChangeCaseLineItem(selectedSubscription));
				oldBarChangeCaseLineItems.add(new BarChangeCaseLineItem(selectedSubscription));
			}
		}



		IsSubscriptionRefreshed = result;
	}


	public PageReference ContinueRequest(){

		boolean flag= false;
		List<Integer> unchangedIndexes = new List<Integer>();
		Integer currIndex = 0;
		for(BarChangeCaseLineItem ali : barChangeCaseLineItems){
			for(BarChangeCaseLineItem oli : oldBarChangeCaseLineItems){
				if(oli.MobileNumber ==ali.MobileNumber){
					if(((oli.Full == true && ali.Full == false) || (oli.Full == false && ali.Full == true)) || 
							((oli.Device == true && ali.Device == false) || (oli.Device == false && ali.Device == true)) ||
							((oli.International == true && ali.International == false) || (oli.International == false && ali.International == true)) ||
							((oli.PremiumCalls == true && ali.PremiumCalls == false) || (oli.PremiumCalls == false && ali.PremiumCalls == true)) ||
							((oli.Roaming == true && ali.Roaming == false) || (oli.Roaming == false && ali.Roaming == true)) ||
							((oli.GPRS == true && ali.GPRS == false) || (oli.GPRS == false && ali.GPRS == true))){
						flag = true;
					} else {
						unchangedIndexes.add(currIndex);
					}
				}
			}
			currIndex++;
		}
		
		for (Integer i = (unchangedIndexes.size()-1); i>=0; i--) {
			barChangeCaseLineItems.remove(unchangedIndexes.get(i));
			oldBarChangeCaseLineItems.remove(unchangedIndexes.get(i));
		}
		
		if(flag){
			subscriptionController.errorExtraSubscriptions.clear();
			subscriptionController.stepNumber = 3;
			subscriptionController.IsEditMode = false;
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MY_O2_BUSINESS_BAR_NOCHANGE_VALIDATION));
		}
		

		return null;

	}

	//Submit
	public PageReference SubmitRequest(){
		Savepoint sp = Database.setSavepoint();
		//try{

		subscriptionController.newCase.Request_Sub_Type__c = CaseUtils.BAR_CHANGE_CASE_REQUEST_SUBTYPE;
		subscriptionController.newCase.Service_Request_Type__c = CaseUtils.CASE_REQUEST_TYPE_CHANGE;
		subscriptionController.newCase.Subject = CaseUtils.BAR_CHANGE_CASE_SUBJECT;

		//Added for SOSL search functionality
		Datetime todayDate = System.today();
		String createdDate = todayDate.format('dd/MM/yyyy');

		subscriptionController.newCase.Created_date__c = createdDate;

		String finalChanges = null;

		//Case line items
		for(BarChangeCaseLineItem ali : barChangeCaseLineItems){

			finalChanges =  requestedBarList(oldBarChangeCaseLineItems, ali);
			if(finalChanges != null){
				mo2b_CaseLineItem__c li = new mo2b_CaseLineItem__c(AC_Subscription__c = ali.SubscriptionExtra.AC_Subscription__c,
						RecordTypeId = Cache.RecordTypeId('mo2b_CaseLineItem__c.' + CaseUtils.BAR_CHANGE_CASE_LINE_ITEM_RECORD_TYPE),
						New_Subscriber_Name__c = ali.Subscriber,
						Add_Remove_Bars__c = true,
						Requested_Bar_Changes__c =finalChanges
				);


				subscriptionController.caseLineItems.add(li);
			}
		}

		if(subscriptionController.caseLineItems.size() > 0){
			system.debug('calling  subscriptionController.CreateCase() ******'+subscriptionController.caseLineItems.size());

			try { //EP 07/11/2-13
				subscriptionController.CreateCase();
			}
			catch (QueryException e) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please try again later 1'));
				return null;
			}
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please try again later'));
				return null;
			}
			system.debug('after calling  subscriptionController.CreateCase() ******');
		}

		/**   } catch (Exception ex){
            System.Debug('My O2 Business - Bar Change - Error Inserting New Case: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
            //Database.rollback(sp);
            //throw(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MY_O2_BUSINESS_BAR_NOCHANGE_VALIDATION));
            return null;
        } */


		PageReference r = null;
		if(smbUser){
			r = Page.SMBRequestConfirmation;
		}else{
			r = Page.MyO2BusinessRequestConfirmation;
		}
		r.getParameters().put('id', subscriptionController.newCase.Id);
		return r;
	}


	public String requestedBarList(List<BarChangeCaseLineItem> oldBarChangeCaseLineItems, BarChangeCaseLineItem ali){

		Set<String> requestedBarChanges = new Set<String>();
		final String MO2B_BAR_ADD_BARS_HS_FOR_CALLS_FROM_OS_UK = 'Add bars h/s for calls from o/s UK';
		final String MO2B_BAR_ADD_PREMIUM_RATE_CALL_BAR = 'Add premium rate call bar';
		final String MO2B_BAR_ADD_INTERNATIONAL_CALL_BAR = 'Add international call bar';
		final String MO2B_BAR_ADD_FULL_BAR_WITH_NO_MESSAGE = 'Add full bar with no message';
		final String MO2B_BAR_ADD_GPRS_BAR = 'Add GPRS Bar';
		final String MO2B_BAR_ADD_IMEI_BAR = 'Add IMEI Bar';
		final String MO2B_BAR_REMOVE_INTERNATIONAL_PREMIUM_ROAM = 'Remove international_premium_roam';
		final String MO2B_BAR_REMOVE_INTERNAT_PREM_ROAM_LOCAL = 'Remove internat+prem+roam+local';
		final String MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR = 'Remove internat & premium call bar';
		final String MO2B_BAR_REMOVE_O2_ONLY_ROAM_BAR = 'Remove O2 Only roam Bar';
		final String MO2B_BAR_REMOVE_BARS_HS_FOR_CALLS_FROM_OS_UK = 'Remove bars h/s for calls from o/s UK';
		final String MO2B_BAR_REMOVE_PREMIUM_RATE_CALL_BAR = 'Remove premium rate call bar';
		final String MO2B_BAR_REMOVE_CHAT_BAR = 'Remove chat bar';
		final String MO2B_BAR_REMOVE_ADULT_BAR = 'Remove adult bar';
		final String MO2B_BAR_REMOVE_ADULT_AND_CHAT_BAR = 'Remove Adult and Chat Bar';
		final String MO2B_BAR_REMOVE_ADD_PREMIUM_ADULT_BAR = 'Remove Add Premium Adult Bar';
		final String MO2B_BAR_REMOVE_INTERNATIONAL_CALL_BAR = 'Remove international call bar';
		final String MO2B_BAR_REMOVE_ADD_FULL_INTERNATIONAL = 'Remove Add full international';
		final String MO2B_BAR_REMOVE_INTERNATIONAL_BAR = 'Remove international bar';
		final String MO2B_BAR_REMOVE_STOLEN_BAR = 'Remove stolen bar';
		final String MO2B_BAR_REMOVE_FULL_BAR_WITH_MESSAGE = 'Remove full bar with message';
		final String MO2B_BAR_REMOVE_FULL_BAR_WITH_NO_MESSAGE = 'Remove full bar with no message';
		final String MO2B_BAR_REMOVE_GRPS_BAR = 'Remove GPRS Bar';
		final String MO2B_BAR_REMOVE_IMEI_BAR = 'Remove IMEI Bar';
		System.debug('requested bar list old = ' + oldBarChangeCaseLineItems);
		System.debug('requested bar list new = ' + ali);
		for(BarChangeCaseLineItem oli : oldBarChangeCaseLineItems){

			if(oli.MobileNumber ==ali.MobileNumber){

				// Device bar
				if(oli.Device == true && ali.Device == false){

					system.debug(' inside ' + MO2B_BAR_REMOVE_IMEI_BAR);
					requestedBarChanges.add(MO2B_BAR_REMOVE_IMEI_BAR);

				}else if(oli.Device == false && ali.Device == true){
					system.debug(' inside ' + MO2B_BAR_ADD_IMEI_BAR);
					requestedBarChanges.add(MO2B_BAR_ADD_IMEI_BAR);   
				}


				// GPRS bar
				if(oli.GPRS == true && ali.GPRS == false){
					system.debug(' inside ' + MO2B_BAR_REMOVE_GRPS_BAR);
					requestedBarChanges.add(MO2B_BAR_REMOVE_GRPS_BAR);

				}else if(oli.GPRS == false && ali.GPRS == true){
					system.debug(' inside ' + MO2B_BAR_ADD_GPRS_BAR);
					requestedBarChanges.add(MO2B_BAR_ADD_GPRS_BAR);

				}

				// SIM/FULL BAR

				if(oli.Full == true && ali.Full== false){

					if(oli.fullBarWithNoMessage == true){
						system.debug(' inside ' + MO2B_BAR_REMOVE_FULL_BAR_WITH_NO_MESSAGE);
						requestedBarChanges.add(MO2B_BAR_REMOVE_FULL_BAR_WITH_NO_MESSAGE);
					}
					if(oli.fullBarWithMessage == true){
						system.debug(' inside ' + MO2B_BAR_REMOVE_FULL_BAR_WITH_MESSAGE);
						requestedBarChanges.add(MO2B_BAR_REMOVE_FULL_BAR_WITH_MESSAGE);
					}
					if(oli.stolenBar == true){
						system.debug(' inside ' + MO2B_BAR_REMOVE_STOLEN_BAR);
						requestedBarChanges.add(MO2B_BAR_REMOVE_STOLEN_BAR);
					}

				}else if(oli.Full  == false && ali.Full == true){
					requestedBarChanges.add(MO2B_BAR_ADD_FULL_BAR_WITH_NO_MESSAGE);                       
				}

				//International BAR

				if(oli.International == true && ali.International== false){
					
					if(oli.internationalBar == true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_BAR);
					}
					if(oli.addFullInternationalAccess == true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_ADD_FULL_INTERNATIONAL);
					}
					if(oli.internationalC == true){      
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_CALL_BAR);          
					}

				}else if (oli.International == false && ali.International== true ){
					requestedBarChanges.add(MO2B_BAR_ADD_INTERNATIONAL_CALL_BAR);  
				}

				//Premium BAR

				if(oli.PremiumCalls == true && ali.PremiumCalls== false){
					if (oli.premiumrateCallBar == true) {
						requestedBarChanges.add(MO2B_BAR_REMOVE_PREMIUM_RATE_CALL_BAR);
					}
					if(oli.addPremiumAdultBar == true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_ADD_PREMIUM_ADULT_BAR);
					}
					if(oli.adultAndChatBar == true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_ADULT_AND_CHAT_BAR);                       
					}
					if(oli.adultBar== true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_ADULT_BAR);   
					}
					if(oli.chatBar== true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_CHAT_BAR);
					}
				}else if (oli.PremiumCalls == false && ali.PremiumCalls== true ){
					system.debug(' inside ' + MO2B_BAR_ADD_PREMIUM_RATE_CALL_BAR);
					requestedBarChanges.add(MO2B_BAR_ADD_PREMIUM_RATE_CALL_BAR);
				}

				//Roaming BAR

				if(oli.Roaming == true && ali.Roaming== false){
					if(oli.BarforcallsfromUK == true){
						system.debug(' inside ' + MO2B_BAR_REMOVE_BARS_HS_FOR_CALLS_FROM_OS_UK);
						requestedBarChanges.add(MO2B_BAR_REMOVE_BARS_HS_FOR_CALLS_FROM_OS_UK);
					}
					if(oli.o2OnlyRoamBar == true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_O2_ONLY_ROAM_BAR);
					}
				}else if (oli.Roaming == false && ali.Roaming== true ){
					system.debug(' inside ' + MO2B_BAR_ADD_BARS_HS_FOR_CALLS_FROM_OS_UK);
					requestedBarChanges.add(MO2B_BAR_ADD_BARS_HS_FOR_CALLS_FROM_OS_UK);
				}

				// Combi Bar - Internat & Premium Call Bar 
				
				if(oli.internetAndPremiumCallBar == true){
					if(ali.International == false && ali.PremiumCalls == false){
						system.debug(' inside ' + MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR);
						System.debug(MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR);

					}else if(ali.International == true && ali.PremiumCalls == false){
						system.debug(' inside ' + MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR);
						System.debug(MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR + ';' + MO2B_BAR_ADD_INTERNATIONAL_CALL_BAR);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR);
						requestedBarChanges.add(MO2B_BAR_ADD_INTERNATIONAL_CALL_BAR);

					}else if(ali.International == false && ali.PremiumCalls == true){
						system.debug(' inside ' + MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR);
						System.debug(MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR + ';' + MO2B_BAR_ADD_PREMIUM_RATE_CALL_BAR);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREMIUM_CALL_BAR);
						requestedBarChanges.add(MO2B_BAR_ADD_PREMIUM_RATE_CALL_BAR);
					}

				}   


				// Combi bar -  international+prem+roam+local or   international+prem+roam

				if(oli.internationaPremRoamBar == true  ||  oli.internationaPremRoamLocal == true){

					if(ali.International == false && ali.PremiumCalls ==false &&ali.Roaming == false){

						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREM_ROAM_LOCAL);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_PREMIUM_ROAM);

					}
					else if(ali.International == true && ali.PremiumCalls ==false &&ali.Roaming == false){

						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREM_ROAM_LOCAL);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_PREMIUM_ROAM);
						requestedBarChanges.add(MO2B_BAR_ADD_INTERNATIONAL_CALL_BAR);

					}else if(ali.International == true && ali.PremiumCalls ==true &&ali.Roaming == false){
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREM_ROAM_LOCAL);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_PREMIUM_ROAM);
						requestedBarChanges.add(MO2B_BAR_ADD_INTERNATIONAL_CALL_BAR);
						requestedBarChanges.add(MO2B_BAR_ADD_PREMIUM_RATE_CALL_BAR);

					}else if(ali.International == true && ali.PremiumCalls ==false &&ali.Roaming == true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREM_ROAM_LOCAL);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_PREMIUM_ROAM);
						requestedBarChanges.add(MO2B_BAR_ADD_INTERNATIONAL_CALL_BAR);
						requestedBarChanges.add(MO2B_BAR_ADD_BARS_HS_FOR_CALLS_FROM_OS_UK);

					}else if(ali.International == false && ali.PremiumCalls ==true &&ali.Roaming == false){
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREM_ROAM_LOCAL);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_PREMIUM_ROAM);
						requestedBarChanges.add(MO2B_BAR_ADD_PREMIUM_RATE_CALL_BAR);


					}else if(ali.International == false && ali.PremiumCalls ==true &&ali.Roaming == true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREM_ROAM_LOCAL);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_PREMIUM_ROAM);
						requestedBarChanges.add(MO2B_BAR_ADD_PREMIUM_RATE_CALL_BAR);
						requestedBarChanges.add(MO2B_BAR_ADD_BARS_HS_FOR_CALLS_FROM_OS_UK);


					}
					else if(ali.International == false && ali.PremiumCalls ==false &&ali.Roaming == true){
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNAT_PREM_ROAM_LOCAL);
						requestedBarChanges.add(MO2B_BAR_REMOVE_INTERNATIONAL_PREMIUM_ROAM);
						requestedBarChanges.add(MO2B_BAR_ADD_BARS_HS_FOR_CALLS_FROM_OS_UK);
					}

				}

			}  

		}

		String finalRequestBarChanges = null;

		for(String requestedChange : requestedBarChanges)
		{
			if(finalRequestBarChanges == null)
			{
				finalRequestBarChanges = requestedChange;
			}
			else
			{
				finalRequestBarChanges = finalRequestBarChanges  + ';' + requestedChange;

			}
		}

		// check for the add or remove BAR
		system.debug('requested bar changes are :' + requestedBarChanges.size() ); 
		system.debug('selected bar changes are :' +  finalRequestBarChanges    ); 

		return finalRequestBarChanges;

	}   


	//Sort
	public void SortList(){
		if(OrderFieldNameTemp != OrderFieldName){
			OrderType = 'ASC';
			OrderFieldName = OrderFieldNameTemp;
		} else {
			OrderType = OrderType != 'ASC' ? 'ASC' : 'DESC';
		}
		for(BarChangeCaseLineItem li : barChangeCaseLineItems){
			li.CompareField = OrderFieldName;
		}
		barChangeCaseLineItems.sort();
		if(OrderType == 'DESC'){
			List<BarChangeCaseLineItem> temp = new List<BarChangeCaseLineItem>();
			for(integer i = barChangeCaseLineItems.size() - 1; i>= 0; i--){
				temp.add(barChangeCaseLineItems[i]);
			}
			barChangeCaseLineItems = temp;
		}
	}




	//Internal class used to store subscriptions
	public class BarChangeCaseLineItem implements Comparable{

		public AC_Subscription_Extra__c SubscriptionExtra{get; set;}

		public string MobileNumber{get; set;}
		public string Subscriber{get; set;}
		public boolean Full{get; set;}
		public boolean Device{get; set;}
		public boolean International{get; set;}
		public boolean PremiumCalls{get; set;}
		public boolean Roaming{get; set;}
		public boolean GPRS{get; set;}
		
		public boolean IMEIBar{get; set;}
		public boolean GPRSBar{get; set;}
		public boolean fullBarWithNoMessage{get; set;}
		public boolean fullBarWithMessage{get; set;}
		public boolean stolenBar{get; set;}

		public boolean addFullInternationalAccess{get; set;}
		public boolean internationalC{get; set;}
		public boolean internetAndPremiumCallBar{get; set;}
		public boolean internationalBar{get; set;}
		public boolean internationaPremRoamLocal{get; set;}
		public boolean internationaPremRoamBar{get; set;}

		public boolean addPremiumAdultBar{get; set;}
		public boolean adultAndChatBar{get; set;}
		public boolean adultBar{get; set;}
		public boolean chatBar{get; set;}
		public boolean premiumrateCallBar{get; set;}
		public boolean o2OnlyRoamBar{get; set;}

		public boolean BarforcallsfromUK{get; set;}


		public string CompareField{get; set;}


		public BarChangeCaseLineItem(AC_Subscription_Extra__c SubscriptionExtra){
			this.SubscriptionExtra = SubscriptionExtra;
			this.CompareField = '';

			this.MobileNumber = SubscriptionExtra.AC_Subscription__r.Network_Serial_No__c;
			this.Subscriber = SubscriptionExtra.AC_Subscription__r.Subscription_Name__c;
			
			this.Full = SubscriptionExtra.Full_Bar__c ;
			this.Device = SubscriptionExtra.Device_Bar__c;
			this.International = SubscriptionExtra.International_Call_Bar_Display__c;
			this.PremiumCalls = SubscriptionExtra.Premium_Call_Bar_Display__c;
			this.Roaming = SubscriptionExtra.Roaming_Call_Bar_Display__c;
			this.GPRS = SubscriptionExtra.GPRS__c;

			this.IMEIBar = SubscriptionExtra.IMEI_Bar__c;
			
			this.fullBarWithNoMessage= SubscriptionExtra.Fullbar_with_no_msg__c;
			this.fullBarWithMessage = SubscriptionExtra.Fullbar_with_msg__c;
			this.stolenBar = SubscriptionExtra.Stolen_Bar__c;


			this.internationalC = SubscriptionExtra.International__c;
			this.addFullInternationalAccess = SubscriptionExtra.Add_full_international_access__c;
			this.internetAndPremiumCallBar = SubscriptionExtra.Internet_premium_call_bar__c;
			this.internationalBar = SubscriptionExtra.International_Bar__c;
			this.internationaPremRoamLocal =SubscriptionExtra.International_prem_roam_local__c;
			this.internationaPremRoamBar = SubscriptionExtra.International_premium_roam__c;


			this.addPremiumAdultBar = SubscriptionExtra.Add_Premium_Adult_Bar__c;
			this.premiumrateCallBar = SubscriptionExtra.Premium_rate_call_bar__c;
			this.adultAndChatBar = SubscriptionExtra.Adult_and_Chat_Bar__c;
			this.adultBar = SubscriptionExtra.Adult_Bar__c;
			this.chatBar = SubscriptionExtra.Chat_Bar__c;

			this.o2OnlyRoamBar = SubscriptionExtra.O2_only_roam_bar__c;
			this.BarforcallsfromUK = SubscriptionExtra.Bars_h_s_for_calls_from_o_s_UK__c;
			
			this.GPRSBar = SubscriptionExtra.GPRS_Bar__c;

			system.debug(this.Full);
			system.debug(this.Device);
			system.debug(this.fullBarWithNoMessage);
			system.debug(fullBarWithMessage);
			system.debug(this.stolenBar);
			system.debug(internationalC);
			system.debug(addFullInternationalAccess);
			system.debug( this.internetAndPremiumCallBar);
			system.debug(this.internationalBar);
			system.debug(this.internationaPremRoamLocal);
			system.debug(this.internationaPremRoamBar);
			system.debug( this.addPremiumAdultBar);
			system.debug(this.premiumrateCallBar);
			system.debug(this.premiumrateCallBar);
			system.debug(this.adultAndChatBar);
			system.debug(this.adultBar);
			system.debug(this.chatBar);
			system.debug(this.o2OnlyRoamBar);
			system.debug(this.BarforcallsfromUK);

		}

		public integer compareTo(Object compareTo){
			BarChangeCaseLineItem otherItem = (BarChangeCaseLineItem)compareTo;
			integer result = 0;
			if(CompareField == 'MobileNumber'){
				result = this.MobileNumber.compareTo(otherItem.MobileNumber);
			} 
			return result;
		}



	}



}