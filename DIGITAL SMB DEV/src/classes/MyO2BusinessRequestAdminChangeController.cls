public with sharing class MyO2BusinessRequestAdminChangeController {

    /*Properties*/
    //Subscription controller
    MyO2BusinessSubscriptionsController subscriptionController;

    //Sim Swap Case line items
    public List<AdminChangeCaseLineItem> adminChangeCaseLineItems{get; set;}
    
     // to set whether teh logged in user is a smb user or not
    public Boolean smbUser{get; set;}
    
    //Consturctor
    public MyO2BusinessRequestAdminChangeController(MyO2BusinessSubscriptionsController controller) {

        //Initalize controller
        subscriptionController = (MyO2BusinessSubscriptionsController)controller;
        subscriptionController.stepNumber = 2;
        subscriptionController.IsEditMode = true;
        subscriptionController.newCase = new Case();
        subscriptionController.caseLineItems = new List<mo2b_CaseLineItem__c>();
        OrderFieldNameTemp = '';
        OrderFieldName = '';
        OrderType = '';
        IsSubscriptionRefreshed = false;
        IsSameCostCenter = false;
        smbUser= CaseUtils.checkLoginUserSegment();
        
    }

    public boolean IsSubscriptionRefreshed{get; set;}
    public static Boolean AdminChangeFlag = false;
    public void RefreshExtras(){
        boolean result = subscriptionController.GetSubscriptionExtras();
        if (subscriptionController.SubscriptionsSize == 0) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_NO_SUBSCRIPTIONS_AVAILABLE));
        }
        if(result){
            adminChangeCaseLineItems = new List<AdminChangeCaseLineItem>();
            for(AC_Subscription_Extra__c selectedSubscription : subscriptionController.selectedExtraSubscriptions) {
                adminChangeCaseLineItems.add(new AdminChangeCaseLineItem(selectedSubscription));
            }
        }
        IsSubscriptionRefreshed = result;
    }
	
	public PageReference FinishEditAdmin(){
		system.debug('FinishEditAdmin---method called-');
		List<Integer> unchangedIndexes = new List<Integer>();
		Integer currIndex = 0;
		for(AdminChangeCaseLineItem acli : adminChangeCaseLineItems){
			System.debug('FinishEditAdmin - case line item: ' + acli);
			System.debug('FinishEditAdmin - costcenter old: ' + acli.CostCenter);
			System.debug('FinishEditAdmin - costcenter new: ' + acli.StartCostCenter);
			System.debug('FinishEditAdmin - subscriber old: ' + acli.oldsubscriber);
			System.debug('FinishEditAdmin - subscriber new: ' + acli.Subscriber);
			if ((acli.CostCenter == acli.StartCostCenter) 
				&& (acli.Subscriber == acli.oldsubscriber)) {
				unchangedIndexes.add(currIndex);
			}
			currIndex++;
		}
		System.debug ('Admin change - Finish edit - removing indexes = ' + unchangedIndexes);
		for (Integer i = (unchangedIndexes.size()-1); i>=0; i--) {
			adminChangeCaseLineItems.remove(unchangedIndexes.get(i));
		}
		if (adminChangeCaseLineItems.size() == 0){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MY_O2_BUSINESS_ADMIN_NOCHANGE_VALIDATION));
			return null;
		}
		subscriptionController.errorExtraSubscriptions.clear();
		subscriptionController.IsEditMode = false;
		subscriptionController.stepNumber = 3;
		return null;
	}
	
    //Submit
    public PageReference SubmitRequest(){
    	System.debug('Inside submit');
        Savepoint sp = Database.setSavepoint();
        try{

            subscriptionController.newCase.Request_Sub_Type__c = CaseUtils.ADMIN_CHANGE_CASE_REQUEST_SUBTYPE;
            subscriptionController.newCase.Service_Request_Type__c = CaseUtils.CASE_REQUEST_TYPE_CHANGE;
            subscriptionController.newCase.Subject = CaseUtils.ADMIN_CHANGE_CASE_SUBJECT;
            subscriptionController.newCase.Specific_Case_Instructions__c = true;
            
            Datetime todayDate = System.today();
            String createdDate = todayDate.format('dd/MM/yyyy');
                        
            subscriptionController.newCase.Created_date__c = createdDate;
            
            system.debug('Inside Try');
            //Case line items
            for(AdminChangeCaseLineItem ali : adminChangeCaseLineItems){
            
            System.debug('**Old Subscriber**'+ali.oldsubscriber);  
            if(((ali.CostCenter != null) && (ali.StartCostCenter != ali.CostCenter)) || ((ali.Subscriber != null) && (ali.oldsubscriber != ali.Subscriber))){
            	System.debug('Inside case Line Itme Addition condition');
	            mo2b_CaseLineItem__c li = new mo2b_CaseLineItem__c(AC_Subscription__c = ali.SubscriptionExtra.AC_Subscription__c,
	                                                                   SOA_Call_Type__c = CaseUtils.ADMIN_CHANGE_CALLOUT_TYPE,
	                                                                   RecordTypeId = Cache.RecordTypeId('mo2b_CaseLineItem__c.' + CaseUtils.ADMIN_CHANGE_CASE_LINE_ITEM_RECORD_TYPE),
	                                                                   SOA_Last_Amended_Date__c = ali.SubscriptionExtra.Last_Amended_Date_Customer_Details__c,
	                                                                   New_Cost_Centre__c = ali.CostCenter,
	                                                                   New_Subscriber_Name__c = ali.Subscriber,
	                                                                   Old_Cost_Centre__c = ali.StartCostCenter,
	                                                                  Requested_Subscriber_Change__c = ali.changeSubscriber); 
	                                                         
	                subscriptionController.caseLineItems.add(li);
            	}
            }
            System.debug('**subscriptionController.caseLineItems**'+subscriptionController.caseLineItems);
			AdminChangeFlag = true;
			if(subscriptionController.caseLineItems.size() > 0){
            	subscriptionController.CreateCase();
            	
		}
        } catch (Exception ex){
            System.Debug('My O2 Business - Admin Change - Error Inserting New Case: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
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
    public class AdminChangeCaseLineItem implements Comparable{

        public AC_Subscription_Extra__c SubscriptionExtra{get; set;}
        public string OldCostCenter{get; set;}
        public string StartCostCenter{get; set;}
        public string CostCenter{get; set;}
        public string MobileNumber{get; set;}
        public string Subscriber{get; set;}
        public string CompareField{get; set;}
        public Boolean changeSubscriber{get; set;}
        public string oldsubscriber{get; set;}
        public AdminChangeCaseLineItem(AC_Subscription_Extra__c SubscriptionExtra){
            this.SubscriptionExtra = SubscriptionExtra;
            this.OldCostCenter = '';
            this.CompareField = '';
            this.CostCenter = SubscriptionExtra.AC_Subscription__r.Customer_Cost_Centre__c;
            if (this.CostCenter == null) {
            	this.CostCenter = '';
            }
            this.StartCostCenter = SubscriptionExtra.AC_Subscription__r.Customer_Cost_Centre__c;
            if (this.StartCostCenter == null) {
            	this.StartCostCenter = '';
            }
            this.MobileNumber = SubscriptionExtra.AC_Subscription__r.Network_Serial_No__c;
            this.Subscriber = SubscriptionExtra.AC_Subscription__r.Subscription_Name__c;
            if (this.Subscriber == null) {
            	this.Subscriber = '';
            }
            this.oldsubscriber = SubscriptionExtra.AC_Subscription__r.Subscription_Name__c;
            if (this.oldsubscriber == null) {
            	this.oldsubscriber = '';
            }
            this.changeSubscriber = false;             
        }

        public integer compareTo(Object compareTo){
            AdminChangeCaseLineItem otherItem = (AdminChangeCaseLineItem)compareTo;
            integer result = 0;
            System.debug('**otherItem**'+otherItem);
            if(CompareField == 'MOBILE_NUMBER'){
                result = this.MobileNumber.compareTo(otherItem.MobileNumber);
                System.debug('**Mobile Compare**'+result);
            } else if (CompareField == 'SUBSCRIBER'){
                result = this.Subscriber.compareTo(otherItem.Subscriber);
                System.debug('**SUBSCRIBER Compare**'+result);
            } else if (CompareField == 'COST_CENTRE'){
                result = this.CostCenter.compareTo(otherItem.CostCenter);
                System.debug('**COST_CENTRE Compare**'+result);
            }
            System.debug('**Final Result**'+result);
            return result;
        }
    }

    //Same cost center
    public boolean IsSameCostCenter{get; set;}
    public void SetSameCostCenter(){
    	system.debug('SetSameCostCenter called');
    	system.debug('adminChangeCaseLineItems-------------'+adminChangeCaseLineItems);
        
        if(IsSameCostCenter){
            for(AdminChangeCaseLineItem li: adminChangeCaseLineItems){
            	system.debug('SetSameCostCenter li---'+li);
                li.OldCostCenter = li.CostCenter;
                li.CostCenter = adminChangeCaseLineItems[0].CostCenter;
                system.debug('li.OldCostCenter------------'+li.OldCostCenter);
                system.debug(' li.CostCenter ------------'+ li.CostCenter);
            }
        }else{
        	system.debug('inside else part-----');
            for(AdminChangeCaseLineItem li: adminChangeCaseLineItems){
                li.CostCenter = li.OldCostCenter;
                system.debug('li.CostCenter------'+li.CostCenter);
            }
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
        for(AdminChangeCaseLineItem li : adminChangeCaseLineItems){
            li.CompareField = OrderFieldName;
        }
        adminChangeCaseLineItems.sort();
        if(OrderType == 'DESC'){
            List<AdminChangeCaseLineItem> temp = new List<AdminChangeCaseLineItem>();
            for(integer i = adminChangeCaseLineItems.size() - 1; i>= 0; i--){
                temp.add(adminChangeCaseLineItems[i]);
            }
            adminChangeCaseLineItems = temp;
        }
    }

    //Sort help properties
    public string OrderFieldNameTemp {get; set;}
    public string OrderFieldName {get; set;}
    public string OrderType {get; set;}

}