public class CaseUtils
{
	//Statuses
    public static final String IN_PROGRESS  		 = 'In Progress';
    public static final String DEFERRED     		 = 'Deferred';
    public static final String FAILED       		 = 'Failed';
    public static final String COMPLETED    		 = 'Completed';
    public static final String PARTIALLYCOMPLETED    = 'Partially Completed';
    public static final String WAITING_ON_CSA		 = 'Waiting on CSA';

    //New case
    public static final string CASE_REQUEST_TYPE_CHANGE 	 = 'Change';
    public static final string CASE_ORIGIN 			 = 'Customer Portal';
    public static final string CASE_RECORD_TYPE 	 = 'My O2 Business General';

    //Sim swap
    public static final string SIM_SWAP_CASE_REQUEST_SUBTYPE = 'SIM Swap';
    public static final string SIM_SWAP_CASE_LINE_ITEM_RECORD_TYPE = 'SIM Swap';
    public static final String UPDATE_SUBSCRIPTION_SERIAL_NUMBERS = 'CaseCallout_SIMSwap';
	public static final string SIM_SWAP_CASE_SUBJECT = 'SIM Swap Request';

	//Admin Changes
	public static final string ADMIN_CHANGE_CASE_REQUEST_SUBTYPE = 'Change subscriber name/cost centre';
    public static final string ADMIN_CHANGE_CASE_LINE_ITEM_RECORD_TYPE = 'Change subscriber name/cost c’tre';
    public static final String ADMIN_CHANGE_CALLOUT_TYPE = 'CaseCallout_AdminChange';
	public static final string ADMIN_CHANGE_CASE_SUBJECT = 'Admin Change Request';
	
	//Bar Changes
	public static final string BAR_CHANGE_CASE_REQUEST_SUBTYPE = 'Bar Management';
    public static final string BAR_CHANGE_CASE_LINE_ITEM_RECORD_TYPE = 'Bar Management';
    //not doing a callout in this phase
    //public static final String BAR_CHANGE_CALLOUT_TYPE = 'CaseCallout_BarChange';
	public static final string BAR_CHANGE_CASE_SUBJECT = 'Bar Management Change Request';
	public static final string BAR_CHANGE_DEFAULT_UNBARRED_DATE = '1899-01-01T00:00:00.000Z';
	
	
	//BoltOn Changes
	public static final string BOLT_ON_CHANGE_CASE_REQUEST_SUBTYPE = 'Add/Remove Boltons';
    public static final string BOLT_ON_CHANGE_CASE_LINE_ITEM_RECORD_TYPE = 'Bolt on Management';
    public static final String BOLT_ON_CHANGE_CALLOUT_TYPE = 'CaseCallout_BoltOnChange';
	public static final string BOLT_ON_CHANGE_CASE_SUBJECT = 'Bolt On Request';
	
	public static  integer subscriptionRefreshMinutes = 0;
	
	
	public static MyO2BusinessSettings__c settings = MyO2BusinessSettings__c.getInstance('Settings');
	
	
	static{
		if(settings == null){
			subscriptionRefreshMinutes= 10;
		
		}else{
			
			subscriptionRefreshMinutes =  Integer.valueOf((settings).SubscriptionRefreshMinutes__c);
		}
		
		
	
	
	
	}
	
	public class SOAFaultException extends Exception
    {
    	public string SOAFaultCode{get;set;}
    	public string faultDescription{get;set;}
    	public string faultTrace{get;set;}

    	public SOAFaultException(string code, string description, string trace)
    	{
    		SOAFaultCode = code;
    		faultDescription = description;
    		faultTrace = trace;
    	}
    }
	
	public class FutureLimitExceededException extends Exception{}
	
	
    public class SOAResponseDetail
    {
    	public string SOAFaultCode {get;set;}
    	public string faultDescription {get;set;}
    	public string faultTrace {get;set;}
    	public string statusCode {get;set;}
    	public string externalDescription {get;set;}
    }
    
    public static void processCases(List<Id> retryCaseIds)
    {
    	//try{
        if (retryCaseIds != null) {
        	system.debug('starting in processCases---retryCaseIds-----'+retryCaseIds.size());
        	system.debug('starting in processCases---retryCaseIds-----'+retryCaseIds);
            if (retryCaseIds.size() > 0) {
                boolean processed = false;
				// Only handle single jobs with @future method
            	if(retryCaseIds.size()==1) {
            	   // A single Apex transaction can make a maximum of 10 callouts
            	   // No more than 10 future method calls per Apex invocation is allowed
            	   // We are making 1 callout per case line item so the allowed number of items to be called must be less than or equal to 100
				   // Also check if the limit for the number of future methods allowed has not been hit
				  	list<mo2b_CaseLineItem__c> caseLineItems = new list<mo2b_CaseLineItem__c>();
				  	  try{
		   				if(MyO2BusinessRequestAdminChangeController.AdminChangeFlag){
		   					System.debug('Inside first');
		   					system.debug('case number is :' + retryCaseIds[0]);
		            	   	caseLineItems = [select Id from mo2b_CaseLineItem__c where Case__c =: retryCaseIds[0] and Requested_Subscriber_Change__c = false ];
		   				}else if(MyO2BusinessRequestSimSwapController.simSwapChangeFlag){
		   					caseLineItems = [select Id from mo2b_CaseLineItem__c where Case__c =: retryCaseIds[0] and (New_Device_Details__c = null Or New_Device_Details__c = '')];
		   				}
		   				else{
		   					System.debug('Inside Second');
		   					caseLineItems = [select Id from mo2b_CaseLineItem__c where Case__c =: retryCaseIds[0]];
		   				}
				  	  }catch(Exception e){
				  	  	system.debug('exception while fetching caselineitems---'+e.getMessage());
				  	  }
				  	  	  
		            	   if(caseLineItems.size() <= 100)
		            	   {
		            	   		list<set<Id>> CLISubsets = splitCaseLineItemsIntoSubsets(caseLineItems);
		            	   		System.debug('**processCases CLISubsets**'+CLISubsets);
		            	   		System.debug('**processCases CLISubsets size**'+CLISubsets.size());
		            	   		System.debug('**processCases Limits.getFutureCalls()**'+Limits.getFutureCalls());
		            	   		System.debug('**processCases Limits.getLimitFutureCalls()**'+Limits.getLimitFutureCalls());
		            	   		
		            	   		if(Limits.getFutureCalls() + CLISubsets.size() < Limits.getLimitFutureCalls())
		            	   		{
		            	   			system.debug('iNSIDE IF processCases&&&&&&&&&&&&');
		            	   			for(integer i=0; i<CLISubsets.size(); i++)
		            	   			{	System.debug('processCases Inside Future Call');
		            	   				CaseBatchAsync.executeFuture(CLISubsets[i]);
		            	   			}
		            	   			processed = true;
		            	   		}
		            	   		system.debug('$$$$$$end if condtn pprocesscases $$$$$$$$$$');
		            	   }
				}
				// If the request can't be processed using @future then use batch apex
            	if(!processed) {
            		system.debug('before deferCases method called in processCases---retryCaseIds-----'+retryCaseIds.size());
					// Cases cannot be processed now - defer them
					 deferCases(retryCaseIds);
	            }
            }
        }
     /**} catch(Exception e){
     	system.debug('exception is :' + e.getMessage());
     	throw e;
     } */
    }

	private static void deferCases(List<Id> caseIds)
    {
    	//try{
    	system.debug('deferCases method get called');
        List<Case> casesToUpdate = new List<Case>();
        system.debug('caseIds-size --deferCases method--'+caseIds.size());
        for (Id caseId : caseIds) {
            casesToUpdate.add(new Case(Id                = caseId,
                                       Callout_Status__c = CaseUtils.DEFERRED));
        }
        system.debug('casesToUpdate----size----'+casesToUpdate.size());
        system.debug('casesToUpdate-------'+casesToUpdate);
        update casesToUpdate;
    	/**} catch(Exception e){
     	system.debug('exception is :' + e.getMessage());
     	throw e;
     } */
    }

	private static list<set<Id>> splitCaseLineItemsIntoSubsets(list<mo2b_CaseLineItem__c> caseLineItems)
    {
        integer CLISubsetsSize = math.mod(caseLineItems.size(),10) == 0	? 	caseLineItems.size()/10 : (caseLineItems.size()/10) + 1;
        list<set<Id>> CLISubsets = new list<set<Id>>();

        for(integer i=0; i<CLISubsetsSize; i++)
        {
        	CLISubsets.add(new set<Id>());
        }

        for(integer i=0; i<caseLineItems.size(); i++)
        {
        	integer j = i/10;
        	CLISubsets[j].add(caseLineItems[i].Id);
        }

        return CLISubsets;
	}

	private static list<set<Id>> splitSubscriptionsExtraIntoSubsets(list<AC_Subscription_Extra__c> subsExtra)
    {
        integer SubsetsSize = math.mod(subsExtra.size(),10) == 0	? 	subsExtra.size()/10 : (subsExtra.size()/10) + 1;
        list<set<Id>> subExtraSubsetIds = new list<set<Id>>();
        System.debug('**SubsetsSize**'+SubsetsSize);

        for(integer i=0; i<SubsetsSize; i++)
        {
        	subExtraSubsetIds.add(new set<Id>());
        }
		
		System.debug('**subExtraSubsetIds**'+subExtraSubsetIds);
		System.debug('**subsExtra**'+subsExtra);
		
		//Added priyanka
		if(subsExtra != null && subsExtra.size() >=0 && subExtraSubsetIds != null && subExtraSubsetIds.size() >=0){
	        for(integer i=0; i<subsExtra.size(); i++)
	        {
	        	integer j = i/10;
	        	if(subExtraSubsetIds[j] != null && subsExtra[i] != null ){
	        		
	        		subExtraSubsetIds[j].add(subsExtra[i].Id);
	        	}
	        	
	        	
	        		
	        }
		}
        return subExtraSubsetIds;
	}

	public static void processSubscriptions (list<AC_Subscription__c> selectedSubs)
	{
		System.debug('**selectedSubsID**'+selectedSubs);
		system.debug('PUKCodeFlag in processSubscription'+MyO2BusinessSubscriptionsController.PUKCodeFlag);
		//group AC_Subscriptions by SubscriptionID
		map<string, AC_Subscription__c> ACSubsMap = new map<string, AC_Subscription__c>();
		for (AC_Subscription__c sub : selectedSubs)
		{
			ACSubsMap.put(sub.Subscription_ID__c, sub);
		}
		
		System.debug('ACCMap'+ACSubsMap.keySet());
		//select all AC_Subscriptions_Extra that have the same SubscriptionID
		list<AC_Subscription_Extra__c> ACSubsExtra = [Select Term_of_Contract__c,
															 Tariff_Description__c,
															 Subscription_Name__c,
															 Subscription_ID__c,
															 SIM_Number__c,
															 Name,
															 Mobile_Number__c,
															 Last_Amended_Date_Serial_Numbers__c,
															 Last_Amended_Date_Customer_Details__c,
															 Last_Callout_Date__c,
															 LastModifiedDate,
															 Id,
															 Customer_Cost_Centre__c,
															 Agreement_Number__c,
															 PUK_Code_Flag__c,
															 BoltOns_Flag__c,
															 DISE_Account_No__c,
															 AC_Subscription__c
													 From AC_Subscription_Extra__c
													 Where  Subscription_ID__c IN : ACSubsMap.keyset()
													 ];
		System.debug('**ACSubsExtra**'+ACSubsExtra);
		//group AC_Subscriptions_Extra by SubscriptionID
		map<string, AC_Subscription_Extra__c> ACSubsExtraMap = new map<string, AC_Subscription_Extra__c>();
		for (AC_Subscription_Extra__c subExtra : ACSubsExtra)
		{
			ACSubsExtraMap.put(subExtra.Subscription_ID__c, subExtra);
		}
		//list of AC_Subscriptions_Extra that need to be updated
		list<AC_Subscription_Extra__c> subsExtraForCallout = new list<AC_Subscription_Extra__c>();
		//list of AC_Subscriptions_Extra that need to be created and updated
		list<AC_Subscription_Extra__c> subsExtraForCalloutAndInsert = new list<AC_Subscription_Extra__c>();
		//list<AC_Subscription_Extra__c> subsExtraForCalloutAndupdate = new list<AC_Subscription_Extra__c>();

		for(string subID : ACSubsMap.keySet())
		{
			//if AC_Subscription_Extra exists but not updated within last hour
		//	if(ACSubsExtraMap.containsKey(subID) && ACSubsExtraMap.get(subID).Last_Callout_Date__c < system.now().addMinutes(-1 * subscriptionRefreshMinutes))
		 //    {

				subsExtraForCallout.add(ACSubsExtraMap.get(subID));
		   //  }
			
			System.debug('case utils, process subscriptions, subs extra for callout'+subsExtraForCallout);
			System.debug('case utils, process subscriptions, subs extra map'+ACSubsExtraMap);
			System.debug('case utils, process subscriptions, sub id'+subID);
			//if AC_Subscription_Extra does not exist
			 if(!ACSubsExtraMap.containsKey(subID))
			{

				AC_Subscription_Extra__c subExtra = new AC_Subscription_Extra__c(AC_Subscription__c = ACSubsMap.get(subID).Id,
																				 Subscription_ID__c = ACSubsMap.get(subID).Subscription_ID__c);
				subsExtraForCalloutAndInsert.add(subExtra);
			}
		}

		if(!subsExtraForCalloutAndInsert.isEmpty())
			insert subsExtraForCalloutAndInsert;
		subsExtraForCallout.addAll(subsExtraForCalloutAndInsert);
		try{
			processSubsCallout(subsExtraForCallout);
		}catch(Exception e){
			throw e;
		}
			
			System.debug('**subsExtraForCallout**'+subsExtraForCallout);
	
	}
	
	public static void processSubsCallout(list<AC_Subscription_Extra__c> subsExtraForCallout)
	{		
			list<AC_Subscription_Extra__c> subsExtraForCalloutAndupdate = new list<AC_Subscription_Extra__c>();
			System.debug('**subsExtraForCallout**'+subsExtraForCallout);
			system.debug('PUKCodeFlag in processCallOut'+MyO2BusinessSubscriptionsController.PUKCodeFlag);
		//the allowed limit of subscriptions that can be selected in the portal is 50, this is just an additional check
		if(subsExtraForCallout.size() <= 100)
	    {
	   		list<set<Id>> subExtraSubsetIds = splitSubscriptionsExtraIntoSubsets(subsExtraForCallout);
	   		//check daily future limit has not been reached
	   		system.debug('*** Limits.getFutureCalls(): ' + Limits.getFutureCalls());
	   		system.debug('*** subExtraSubsetIds.size(): ' + subExtraSubsetIds.size());
	   		system.debug('*** Limits.getLimitFutureCalls(): ' + Limits.getLimitFutureCalls());
	   		system.debug('first Size Limit'+(Limits.getFutureCalls() + subExtraSubsetIds.size()));
	   		System.debug('**subsExtraForCallout**'+subsExtraForCallout);
	   		if(MyO2BusinessSubscriptionsController.PUKCodeFlag){
	   			
				for(AC_Subscription_Extra__c accSubsExtra : subsExtraForCallout){
					System.debug('**accSubsExtra**'+accSubsExtra);
					System.debug('**accSubsExtra**'+accSubsExtra);
					if(accSubsExtra != null ){
						System.debug('**Initial PUK Value1**'+accSubsExtra.PUK_Code_Flag__c);
						accSubsExtra.PUK_Code_Flag__c = true;
						subsExtraForCalloutAndupdate.add(accSubsExtra);
					}
				}
			}else if(MyO2BusinessSubscriptionsController.BoltOnsFlag){
	   			
				for(AC_Subscription_Extra__c accSubsExtra : subsExtraForCallout){
					System.debug('**accSubsExtra**'+accSubsExtra);
					//System.debug('**Initial PUK Value1**'+accSubsExtra.PUK_Code_Flag__c);
					System.debug('**accSubsExtra**'+accSubsExtra);
					if(accSubsExtra != null ){
						accSubsExtra.BoltOns_Flag__c = true;
						subsExtraForCalloutAndupdate.add(accSubsExtra);
					}
				}
			}else {
				for(AC_Subscription_Extra__c accSubsExtra : subsExtraForCallout){
					//System.debug('**Initial PUK Value2**'+accSubsExtra.PUK_Code_Flag__c);
					
					system.debug('**SubscriptionExtraRecords'+accSubsExtra);
					System.debug('**accSubsExtra**'+accSubsExtra);
					if(accSubsExtra != null ){
						accSubsExtra.BoltOns_Flag__c = false;
						accSubsExtra.PUK_Code_Flag__c = false;
						subsExtraForCalloutAndupdate.add(accSubsExtra);
					}
				}
			}
			
			if(!subsExtraForCalloutAndupdate.isEmpty())
			database.update(subsExtraForCalloutAndupdate,false);
			
			system.debug('**subExtraSubsetIds**'+subExtraSubsetIds);
			   		
	   		if(Limits.getFutureCalls() + subExtraSubsetIds.size() < Limits.getLimitFutureCalls())
	   		{
	   			for(integer i=0; i<subExtraSubsetIds.size(); i++)
	   			{
	   				CaseCallout_GetSubscriptionDetails.executeFuture(subExtraSubsetIds[i]);
	   			}
	   		} else {
	   			throw new FutureLimitExceededException();
	   		}
		}
	}
	
	
	// Get element text - return blank if null
    public static String getElemText(Dom.XMLNode node, String tag, String nameSpace) 
    {
    	Dom.XMLNode childNode = node.getChildElement(tag, nameSpace);
    	if (childNode == null) 
    	{
    		return '';
    	} 
    	else 
    	{
    		return childNode.getText();
    	}
    }
    
    public static Date parseDateFromString(string elemText)
    {
    	integer year  = integer.valueOf(elemText.split('-')[0]);
    	integer month = integer.valueOf(elemText.split('-')[1]);
    	integer day   = integer.valueOf(elemText.split('-')[2]);
    	
    	Date elemDate = Date.newInstance(year, month, day);
    	
    	return elemDate;
    }
    
    public static string changeNumberFormat(string mobileNumber)
    {
    	//remove first two digits
    	if(mobileNumber.startsWith('44'))
    	{
    		mobileNumber = '0' + mobileNumber.removeStart('44');
    	}
    	return mobileNumber;
    }
    
    // To check whether the logged customer portal user is a smb user or enterprise user.
    
    public static boolean checkLoginUserSegment(){
    	
    	boolean smbUser;
    	try{
    		
    		 MyO2BusinessUser businessUser = new MyO2BusinessUser();
    	 system.debug('label is : ' + Label.SMB_ACCOUNT_SEGMENT);
    	  system.debug('account segment  is : ' + businessUser.getAccountSegment());
	       if(businessUser.getAccountSegment() == Label.SMB_ACCOUNT_SEGMENT){
	       	 // if(businessUser.getAccountSegment().contains(Label.SMB_ACCOUNT_SEGMENT)){
	            smbUser = true;
	        }else{
	            smbUser = false;
	        }
	        
      
    		
    	}catch(Exception e){
    		
    	}
    	
    	 return smbUser;
    }
	
}