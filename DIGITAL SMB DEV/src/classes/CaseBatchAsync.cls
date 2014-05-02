//
//This class contains the batch asynch and future implementation for the update subscription call outs
//

global class CaseBatchAsync implements Database.Batchable<sObject>, 
                                       Database.AllowsCallouts, 
                                       Database.Stateful, 
                                       Schedulable{
            
    
    // Max retries for SOA callouts
    SOA_Integration_Settings__c manageBusinessSubscriptions;
    
    // Class can be called for specific batch job records
    private List<Id> batchJobIds;
    
    // Member variables - class implements stateful interface
    public Case batchJob;
    public mo2b_CaseLineItem__c caseLineItem;
    
    private DateTime calloutStartTime;
    private DateTime calloutEndTime;
    private DateTime jobStartTime = System.now();
    private DateTime jobEndTime;
    private Integer numberOfErrors;
    private Integer numberOfCLIsForManualProcessing;
    
    
    // Maintains a list of the batch jobs that have already been processed
    private Map<Id, Case> processedBatchJobs;
    
    // Interface required for scheduled sweep process
    global void execute(SchedulableContext sc) {
        CaseBatchAsync b = new CaseBatchAsync (); 
        Database.executeBatch(b, 1);
    }
   
    
    // No argument constructor required for scheduler process
    global CaseBatchAsync () {
        manageBusinessSubscriptions = SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0');
        processedBatchJobs = new Map<Id, Case>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
            return Database.getQueryLocator([Select AC_Subscription__c,
                                                    AC_Subscription__r.Subscription_ID__c,
                                                    Subscriber_Name__c, 
                                                    Start_Date__c, 
                                                    Processed__c,
                                                    Case__c, 
                                                    Case__r.Callout_Status__c,
                                                    Case__r.No_of_Case_Line_Items__c,
                                                    Case__r.Status,
                                                    Old_SIM_Number__c, 
                                                    New_SIM_Number__c, 
                                                    Name, 
                                                    Id, 
                                                    Callout_Status__c,
                                                    Callout_Response__c,
                                                    Callout_Duration__c,
                                                    Callout_Status_Code__c, 
                                                    Callout_Error_Details__c,
                                                    SOA_Call_Type__c,
                                                    SOA_Last_Amended_Date__c,
                                                    New_Subscriber_Name__c,
                                                    New_Cost_Centre__c,
                                                    Old_Cost_Centre__c,
                                                    Service_Code__c,
                                                    Service_Price__c,
                                                    AddRequest__c,
                                                    Bolt_Ons_to_add__c,
                                                    Bolt_Ons_to_remove__c,
                                                    Service_codes_to_add__c,
                                                    Service_codes_to_remove__c,
                                                    BoltOnCalloutResponse__c,
                                                    BoltOnCalloutStatusCode__c
                                             From mo2b_CaseLineItem__c
                                             Where Case__r.Callout_Status__c = :CaseUtils.DEFERRED
                                             Order By Case__c]);
       
    }
    
    // Execute method iterates through case line item records - sometimes for different batch jobs 
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        // The execute scope is a case line item record
        for (SObject obj : scope) {
            // For each case line item record
            caseLineItem = (mo2b_CaseLineItem__c) obj;
            
            // Batch job may be different - need to update the logging fields if it has changed 
            if ( ! processedBatchJobs.containsKey(caseLineItem.Case__c )) {
                Case completedBatchJob = processCompletedBatchJob(batchJob);
                // Batch job will be null for first record
                if (completedBatchJob != null) {
                    processedBatchJobs.put(completedBatchJob.Id, completedBatchJob);
                }
                // Proceed with the next batch job record
                resetBatchJob(caseLineItem.Case__r);
            }
            
            if(caseLineItem.Callout_Status__c != CaseUtils.WAITING_ON_CSA)
            {
	            // If the job is still active then make the callout
	            try {
	                calloutStartTime = System.now(); 
	                
	                //class is instantiated at runtime based on the value in the SOA Call Type field 
	                Type t = Type.forName(caseLineItem.SOA_Call_Type__c);
	                CalloutForCaseLineItem callout = (CalloutForCaseLineItem) t.newInstance();
	                //call the web service
	                caseLineItem = callout.invokeWS(caseLineItem);
	                System.debug('**WebCall Response'+caseLineItem);
	                calloutEndTime = System.now();
	                caseLineItem.Callout_Status__c = CaseUtils.COMPLETED; 
	             
	            } catch(CaseUtils.SOAFaultException ex) {
	            	handleError(ex);     
	            
	            } catch (Exception e) {
	                handleError(e);
	            }
	            updateCaseLineItem(); 
        	}
        	else
        	{
        		numberOfCLIsForManualProcessing ++;
        	}
        }
        // Add the last batch job to the map
        Case completedBatchJob = processCompletedBatchJob(batchJob);
        if (completedBatchJob != null) {
            processedBatchJobs.put(completedBatchJob.Id, completedBatchJob);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Batch jobs are updated in bulk
        updateBatchJobs(processedBatchJobs.values());
    }
    
    public Case processCompletedBatchJob(Case batchJob) 
    {
        Case completedBatchJob;
        if (batchJob == null) 
        {
            return completedBatchJob;
        } 
        else 
        {
            completedBatchJob = new Case(id=batchJob.Id);
            //completedBatchJob.Last_Run_Error_Count__c = batchJob.Last_Run_Error_Count__c;
        }
        
        integer numberOfUnprocessedCLIs = numberOfErrors + numberOfCLIsForManualProcessing;
        System.debug('process completed batch job - number of errors: ' + numberOfErrors);
        System.debug('process completed batch job - number of CLIs for manual processing: ' + numberOfCLIsForManualProcessing);
        
        if (numberOfErrors == 0 && numberOfCLIsForManualProcessing == 0) 
        {
             completedBatchJob.Callout_Status__c = CaseUtils.COMPLETED;
        } 
        else if(numberOfUnprocessedCLIs == batchJob.No_of_Case_Line_Items__c)
        {
            completedBatchJob.Callout_Status__c = CaseUtils.FAILED;
        }
        else
        {
        	completedBatchJob.Callout_Status__c = CaseUtils.PARTIALLYCOMPLETED;
        }
        
        //jobEndTime = System.now();
        //completedBatchJob.Last_Run_Duration__c = jobEndTime.getTime() - jobStartTime.getTime();
        return completedBatchJob;
    }
    
    private void resetBatchJob(Case nextBatchJob) 
    {
        //jobStartTime = System.now();
        numberOfErrors = 0;
        numberOfCLIsForManualProcessing = 0; 
        batchJob = nextBatchJob;
        //batchJob.Last_Run_Error_Count__c = 0;
    }
    
    

    public void handleError(Exception e) 
    {
        //batchJob.Last_Run_Error_Count__c++;
        numberOfErrors ++;
        calloutEndTime = System.now();
        caseLineItem.Callout_Status__c = CaseUtils.FAILED;
        
        if(e.getTypeName() == 'CaseUtils.SOAFaultException')
        {
        	CaseUtils.SOAFaultException sfe = (CaseUtils.SOAFaultException) e;
        	caseLineItem.Callout_Status_Code__c   = sfe.SOAFaultCode;
        	caseLineItem.Callout_Response__c 	  = sfe.faultDescription;
        	caseLineItem.Callout_Error_Details__c = sfe.faultTrace;
        }
        else
        {
        	caseLineItem.Callout_Response__c = e.getCause() + ': ' +e.getMessage(); 
        }
        
    }
    
    private void updateCaseLineItem() 
    {
        Long duration = calloutEndTime.getTime() - calloutStartTime.getTime();
        caseLineItem.Callout_Duration__c = duration;
        
        System.debug('**caseLineItem**'+caseLineItem);
        Database.SaveResult result = Database.update(caseLineItem);    
        
        system.debug('**result**'+result); 
    }
    
    private void updateBatchJobs(List<Case> batchJobs) 
    {
        //for all cases with Callout Status = Completed, close the case
        for(Case c : batchJobs)
        {
        	if(c.Callout_Status__c == CaseUtils.COMPLETED)
        	{
        		c.Status = 'Closed';
        	}
        }
        List<Database.SaveResult> results = Database.update(batchJobs);     
    }
    
/****************************************************************************************************************************************************/    
    
    @future (callout=true)
	public static void executeFuture(set<Id> caseLineItemIds)
	{
		Datetime jobStartTime = System.now();
		//Case processedCase = new Case();
		Integer errorCount = 0;
		Integer numberOfCLIsForManualProcessing = 0;
		System.debug('**caseLineItemIds**'+caseLineItemIds);
		
		list<mo2b_CaseLineItem__c> caseLineItems =[Select AC_Subscription__c,
													AC_Subscription__r.Subscription_ID__c,
                                                    Subscriber_Name__c, 
                                                    Start_Date__c, 
                                                    Processed__c,
                                                    Case__c, 
                                                    Old_SIM_Number__c, 
                                                    New_SIM_Number__c, 
                                                    Name, 
                                                    Id, 
                                                    Callout_Status__c,
                                                    Callout_Response__c,
                                                    Callout_Duration__c,
                                                    Callout_Status_Code__c, 
                                                    Callout_Error_Details__c,
                                                    SOA_Call_Type__c,
                                                    SOA_Last_Amended_Date__c,
                                                    New_Subscriber_Name__c,
                                                    New_Cost_Centre__c,
                                                    Old_Cost_Centre__c,
                                                    Service_Code__c,
                                                    Service_Price__c,
                                                    AddRequest__c,
                                                    Bolt_Ons_to_add__c,
                                                    Bolt_Ons_to_remove__c,
                                                    Service_codes_to_add__c,
                                                    Service_codes_to_remove__c,
                                                    BoltOnCalloutResponse__c,
                                                    BoltOnCalloutStatusCode__c
                                             From mo2b_CaseLineItem__c
                                             Where Id IN :caseLineItemIds
                                             Order By Case__c];
                                             
		system.debug('**caseLineItems**'+caseLineItems);
		if(caseLineItems.size()>0) 
		{
			for(mo2b_CaseLineItem__c caseLineItem : caseLineItems)
			{
				if(caseLineItem.Callout_Status__c != CaseUtils.WAITING_ON_CSA)
				{
					Datetime calloutStartTime = System.now(); 
					try {
						//class is instantiated at runtime based on the value in the SOA Call Type field 
						Type t = Type.forName(caseLineItem.SOA_Call_Type__c);
						CalloutForCaseLineItem callout = (CalloutForCaseLineItem) t.newInstance();
						
						//call the web service
						System.debug('WebCall');
						caseLineItem.Callout_Status__c = null;
						caseLineItem = callout.invokeWS(caseLineItem);
						System.debug('WebCallResponse'+ caseLineItem);
						//if it has not failed
						if (caseLineItem.Callout_Status__c == null) {
							caseLineItem.Callout_Status__c = CaseUtils.COMPLETED;
						}
					 
					} catch(CaseUtils.SOAFaultException ex) {
						errorCount ++;
						caseLineItem = handleErrorOnCaseLineItem(ex, caseLineItem);     
					
					} catch (Exception e) {
						errorCount ++;
						caseLineItem = handleErrorOnCaseLineItem(e, caseLineItem);
					}
					caseLineItem.Callout_Duration__c = System.now().getTime() - calloutStartTime.getTime();
				}
				else
	        	{
	        		numberOfCLIsForManualProcessing ++;
	        	}
	        	caseLineItem.Processed__c = true;
	        }
			
			system.debug('**Before Update**'+caseLineItems);
			Database.update(caseLineItems,false);
			system.debug('**After Update**'+caseLineItems);
			
		}
	}
    private static mo2b_CaseLineItem__c handleErrorOnCaseLineItem(Exception e, mo2b_CaseLineItem__c caseLineItem) 
    {
        caseLineItem.Callout_Status__c = CaseUtils.FAILED;
        
        if(e.getTypeName() == 'CaseUtils.SOAFaultException')
        {
        	CaseUtils.SOAFaultException sfe = (CaseUtils.SOAFaultException) e;
        	caseLineItem.Callout_Status_Code__c   = sfe.SOAFaultCode;
        	caseLineItem.Callout_Response__c 	  = sfe.faultDescription;
        	caseLineItem.Callout_Error_Details__c = sfe.faultTrace;
        	
        	caseLineItem.BoltOnCalloutStatusCode__c   = sfe.SOAFaultCode;
        	caseLineItem.BoltOnCalloutResponse__c 	  = sfe.faultDescription;
        }
        else
        {
        	caseLineItem.Callout_Response__c = e.getCause() + ': ' +e.getMessage(); 
        	caseLineItem.BoltOnCalloutResponse__c = e.getCause() + ': ' +e.getMessage(); 
        }
    	System.debug('case line item exception: ' + e.getCause() + ': ' +e.getMessage());
    	System.debug(e.getStackTraceString());
        
        return caseLineItem;
    }
    
    
}