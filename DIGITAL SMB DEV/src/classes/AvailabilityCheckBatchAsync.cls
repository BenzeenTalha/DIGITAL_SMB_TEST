/*
*   This class contains the batch asynch implementation for 
*   the Line Checker Web Service call outs
*
*  D Sabey, SO'Halloran - (SFDC)
*   Revision History 
*  1.0    10/02/2011  Initial Version
*/   
global class AvailabilityCheckBatchAsync implements Database.Batchable<sObject>, 
                                                    Database.AllowsCallouts, 
                                                    Database.Stateful, 
                                                    Schedulable {
    
    // Max retries for SOA callouts
    SOA_Integration_Settings__c lineAvailabilitySettings;
    
    // Class can be called for specific batch job records
    private List<Id> batchJobIds;
    
    // Member variables - class implements stateful interface
    public Batch_Job__c batchJob;
    public Line_Availability__c lineAvailability;
    
    private DateTime calloutStartTime;
    private DateTime calloutEndTime;
    private DateTime jobStartTime = System.now();
    private DateTime jobEndTime;
    private Boolean batchJobActive;
    private Boolean attemptRetry;
    private Boolean deferJob;
    private Integer numberOfRetryErrors;
    
    // Maintains a list of the batch jobs that have already been processed
    private Map<Id, Batch_Job__c> processedBatchJobs;
    
    // Interface required for scheduled sweep process
    global void execute(SchedulableContext sc) {
        AvailabilityCheckBatchAsync b = new AvailabilityCheckBatchAsync(); 
        Database.executeBatch(b, 1);
    }
   
    // No argument constructor required for scheduler process
    global AvailabilityCheckBatchAsync () {
        lineAvailabilitySettings = SOA_Integration_Settings__c.getValues('Line_Availability_Settings');
        processedBatchJobs = new Map<Id, Batch_Job__c>();
    }
    
    // Constructor used by Visualforce controller and email handler class
    global AvailabilityCheckBatchAsync (List<Id> bIds) {
        batchJobIds = bIds;
        lineAvailabilitySettings = SOA_Integration_Settings__c.getValues('Line_Availability_Settings');
        processedBatchJobs = new Map<Id, Batch_Job__c>();
    }
    
    // QueryLocator depends on method of class invocation
    global Database.QueryLocator start(Database.BatchableContext BC){
        if (batchJobIds == null) {
            return Database.getQueryLocator([Select Id,
                                                    Post_Code__c, 
                                                    Directory_Number__c,
                                                    Type__c,
                                                    Batch_Job__r.Name,
                                                    Batch_Job__r.Email__c,
                                                    Batch_Job__r.Status__c,
                                                    Batch_Job__r.Last_Run_Error_Count__c,
                                                    Batch_Job__r.Number_Of_Retries__c,
                                                    Batch_Job__r.Total_Retries__c  
                                             From Line_Availability__c 
                                             Where CreatedDate >= LAST_WEEK 
											 And Batch_Job__r.Status__c = :AvailabilityCheckUtils.DEFERRED
                                             And Processed__c = false
                                             Order By Batch_Job__c]);
        } else {
            return Database.getQueryLocator([Select Id, 
                                                    Post_Code__c, 
                                                    Directory_Number__c,
                                                    Type__c,
                                                    Batch_Job__r.Name,
                                                    Batch_Job__r.Email__c,
                                                    Batch_Job__r.Status__c,
                                                    Batch_Job__r.Last_Run_Error_Count__c,
                                                    Batch_Job__r.Number_Of_Retries__c,
                                                    Batch_Job__r.Total_Retries__c 
                                             From Line_Availability__c 
                                             Where Batch_Job__c In :batchJobIds
                                             And Processed__c = false
                                             Order By Batch_Job__c]);
        }
    }

    // Execute method iterates through line availability records - sometimes for different batch jobs
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        // The execute scope is a line availability record
        for (SObject obj : scope) {
            // For each line availability record
            lineAvailability = (Line_Availability__c) obj;
            // Batch job may be different - need to update the logging fields if it has changed 
            if ( ! processedBatchJobs.containsKey(lineAvailability.Batch_Job__c )) {
                Batch_Job__c completedBatchJob = processCompletedBatchJob(batchJob);
                // Batch job will be null for first record
                if (completedBatchJob != null) {
                    processedBatchJobs.put(completedBatchJob.Id, completedBatchJob);
                }
                // Proceed with the next batch job record
                resetBatchJob(lineAvailability.Batch_Job__r);
            }
            // Certain SOAP errors will cancel line availability checks for the batch job
            if ( ! batchJobActive ) {
                batchJob.Last_Run_Error_Count__c++;
                return;
            }
            // If the job is still active then make the callout
            try {
                calloutStartTime = System.now(); 
                //throw new SOAUtils.SOATypeException('IO Exception: Read timed out');
                //AvailabilityCheckOutputProcessor outputProcessor = new AvailabilityCheckOutputProcessor();
                AvailabilityCheckList resultList = AvailabilityCheckOutputProcessor.invokeAvailabilityCheckWS(new List<Line_Availability__c>{lineAvailability});
                resultList.save();
                calloutEndTime = System.now();
            } catch (Exception e) {
                handleError(e);
            }
            updateLineAvailability();
        }
        // Add the last batch job to the map
        Batch_Job__c completedBatchJob = processCompletedBatchJob(batchJob);
        if (completedBatchJob != null) {
            processedBatchJobs.put(completedBatchJob.Id, completedBatchJob);
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Batch jobs are updated in bulk
        updateBatchJobs(processedBatchJobs.values());
    }

    private void resetBatchJob(Batch_Job__c nextBatchJob) {
        jobStartTime = System.now();
        batchJobActive = true;
        attemptRetry = false;
        deferJob = false;
        numberOfRetryErrors = 0;
        batchJob = nextBatchJob;
        batchJob.Last_Run_Error_Count__c = 0;
        if ( ! batchJob.Status__c.equals(AvailabilityCheckUtils.RETRYING) ) {
            batchJob.Number_Of_Retries__c = 0;
        }
    }
    
    public Batch_Job__c processCompletedBatchJob(Batch_Job__c batchJob) {
        Batch_Job__c completedBatchJob;
        if (batchJob == null) {
            //system.debug('ntj: processCompletedBatchJob: batch job was null');
            return completedBatchJob;
        } else {
            completedBatchJob = new Batch_Job__c(id=batchJob.Id);
            completedBatchJob.Last_Run_Error_Count__c = batchJob.Last_Run_Error_Count__c;
            //system.debug('ntj: processCompletedBatchJob: Last_Run_Error_Count__c = '+completedBatchJob.Last_Run_Error_Count__c);
            completedBatchJob.Number_Of_Retries__c = batchJob.Number_Of_Retries__c;
            //system.debug('ntj: processCompletedBatchJob: Number_Of_Retries__c = '+completedBatchJob.Number_Of_Retries__c);
            completedBatchJob.Total_Retries__c = batchJob.Total_Retries__c;
            //system.debug('ntj: processCompletedBatchJob: Total_Retries__c = '+completedBatchJob.Total_Retries__c);
        }
        //system.debug('ntj: processCompletedBatchJob: numberOfRetryErrors ='+numberOfRetryErrors);
        if (numberOfRetryErrors > 0) {
             //system.debug('ntj: processCompletedBatchJob: more than zero retries');
             if (batchJob.Number_Of_Retries__c < lineAvailabilitySettings.MAX_SOA_RETRIES__c && attemptRetry) {
                //system.debug('ntj: processCompletedBatchJob: less than retries');
                completedBatchJob.Number_Of_Retries__c++;
                completedBatchJob.Total_Retries__c++;
                completedBatchJob.Flagged_For_Retry__c = true;
                completedBatchJob.Retry__c = false;
                completedBatchJob.Retry_Date_Time__c = System.now();
                completedBatchJob.Status__c = AvailabilityCheckUtils.RETRYING;
            } else if (deferJob) {
                //system.debug('ntj: processCompletedBatchJob: defer job');
                completedBatchJob.Flagged_For_Retry__c = false;
                completedBatchJob.Retry__c = false;
                completedBatchJob.Status__c = AvailabilityCheckUtils.DEFERRED;
            } else {
                //system.debug('ntj: processCompletedBatchJob: failed job');
                completedBatchJob.Flagged_For_Retry__c = false;
                completedBatchJob.Retry__c = false;
                completedBatchJob.Status__c = AvailabilityCheckUtils.FAILED;
            }
        } else {
            //system.debug('ntj: processCompletedBatchJob: zero retries');
            completedBatchJob.Flagged_For_Retry__c = false;
            completedBatchJob.Retry__c = false;
            completedBatchJob.Status__c = AvailabilityCheckUtils.COMPLETED;
        }
        jobEndTime = System.now();
        completedBatchJob.Last_Run_Duration__c = jobEndTime.getTime() - jobStartTime.getTime();
        return completedBatchJob;
    }

    public void handleError(Exception e) {
    
        Boolean SOAFault = false;
        Boolean markAsProcessed = false;
        Boolean cancel = true;
        Boolean retry = true;
        Boolean defer = true;

        batchJob.Last_Run_Error_Count__c++;
        calloutEndTime = System.now();
                
        for (String error : SOAUtils.errors.keyset()) {
            if (e.getMessage().contains(error)) {
                Map<String, Boolean> behaviour = SOAUtils.errors.get(error);
                markAsProcessed = behaviour.get('markRecordProcessed');
                cancel = behaviour.get('cancelJob');
                retry = behaviour.get('retryJob');
                defer = behaviour.get('deferJob');       
                SOAFault = true;
            }
        }
        
        if(!SOAFault) {
          markAsProcessed = true;
          cancel = false;
          retry = false;
          defer = false;
          lineAvailability.Status_Code__c = null;
          lineAvailability.Response__c = SOAUtils.USER_SFDC_FAULT_MESSAGE;
        } else {    
               
           if (( batchJobActive ) && ( cancel )) {
              batchJobActive = false;
          }
          
          if (( ! attemptRetry ) && ( retry )) {
              attemptRetry = true;
          }
  
          if (( ! deferJob ) && ( defer )) {
              deferJob = true;
          }
          
          if ( ! markAsProcessed ) {
              numberOfRetryErrors++;
          }
                  
          lineAvailability.Response__c = SOAUtils.USER_SOA_FAULT_MESSAGE;
          lineAvailability.Response__c = e.getMessage();
        }
        lineAvailability.Internal_Description__c = e.getMessage();
        lineAvailability.Processed__c = markAsProcessed;
        lineAvailability.SOA_Fault__c = e.getMessage();      

    }
    
    private void updateLineAvailability() {
        Long duration = calloutEndTime.getTime() - calloutStartTime.getTime();
        lineAvailability.Callout_Duration__c = duration;
        Database.SaveResult result = Database.update(lineAvailability);     
    }
    
    private void updateBatchJobs(List<Batch_Job__c> batchJobs) {
        List<Database.SaveResult> results = Database.update(batchJobs);     
    }
    
    @Future (callout=true)
    public static void executeFuture(Id batchJobId) {
    	Datetime jobStartTime = System.now(); 
    	Batch_Job__c completedBatchJob = new Batch_Job__c(id=batchJobId);
    	List <AvailabilityCheckList> results = new List <AvailabilityCheckList>();
    	Integer errorCount = 0;
    	Boolean deferJob = false;
        Line_Availability__c[] las = [Select Id, 
                                                    Post_Code__c, 
                                                    Directory_Number__c,
                                                    Type__c,
                                                    Batch_Job__r.Name,
                                                    Batch_Job__r.Email__c,
                                                    Batch_Job__r.Status__c,
                                                    Batch_Job__r.Last_Run_Error_Count__c,
                                                    Batch_Job__r.Number_Of_Retries__c,
                                                    Batch_Job__r.Total_Retries__c 
                                             From Line_Availability__c 
                                             Where Batch_Job__c =:batchJobId
                                             And Processed__c = false
                                             Order By Batch_Job__c];
        if(las.size()>0) {
	        for (Line_Availability__c lineAvailability : las) {
	            Datetime calloutStartTime = System.now(); 
	            try {
	                AvailabilityCheckList resultList = AvailabilityCheckOutputProcessor.invokeAvailabilityCheckWS(new List<Line_Availability__c>{lineAvailability});
	                results.add(resultList);
	            } catch (Exception e) {
	            	errorCount++;
	            	lineAvailability = handleErrorOnLineAvailability(e, lineAvailability);
	            }
	            lineAvailability.Callout_Duration__c = System.now().getTime() - calloutStartTime.getTime();
	       }
	       for(AvailabilityCheckList result: results) {
	        result.save();
	       }
	       Database.update(las);
	       completedBatchJob = las[0].Batch_Job__r;
	       completedBatchJob.Last_Run_Error_Count__c=errorCount;
	       completedBatchJob.Last_Run_Duration__c = System.now().getTime() - jobStartTime.getTime();
	       if (errorCount == 0) {
	            completedBatchJob.Flagged_For_Retry__c = false;
	            completedBatchJob.Retry__c = false;
	            completedBatchJob.Status__c = AvailabilityCheckUtils.COMPLETED;
	       }       
	       Database.update(completedBatchJob); 
       }
    }
   
    private static Line_Availability__c handleErrorOnLineAvailability(Exception e, Line_Availability__c lineAvailability) {
    
        Boolean SOAFault = false;
        Boolean markAsProcessed = false;
        Boolean cancel = true;
        Boolean retry = true;
        Boolean defer = true;
        Boolean deferJob = false;
       
        for (String error : SOAUtils.errors.keyset()) {
            if (e.getMessage().contains(error)) {
                Map<String, Boolean> behaviour = SOAUtils.errors.get(error);
                markAsProcessed = behaviour.get('markRecordProcessed');
                cancel = behaviour.get('cancelJob');
                retry = behaviour.get('retryJob');
                defer = behaviour.get('deferJob');       
                SOAFault = true;
            }
        }
        
        if(!SOAFault) {
          markAsProcessed = true;
          cancel = false;
          retry = false;
          defer = false;
          lineAvailability.Status_Code__c = null;
          lineAvailability.Response__c = SOAUtils.USER_SFDC_FAULT_MESSAGE;
        } else {
  
          if (( ! deferJob ) && ( defer )) {
              deferJob = true;
          }
             	
          //lineAvailability.Response__c = SOAUtils.USER_SOA_FAULT_MESSAGE;
          lineAvailability.Response__c = e.getMessage();
        }
        
        Batch_Job__c completedBatchJob = lineAvailability.Batch_Job__r;
        if (completedBatchJob.Number_Of_Retries__c < SOA_Integration_Settings__c.getValues('Line_Availability_Settings').MAX_SOA_RETRIES__c) {
                //system.debug('ntj: processCompletedBatchJob: less than retries');
                completedBatchJob.Number_Of_Retries__c++;
                completedBatchJob.Total_Retries__c++;
                completedBatchJob.Flagged_For_Retry__c = true;
                completedBatchJob.Retry__c = false;
                completedBatchJob.Retry_Date_Time__c = System.now();
                completedBatchJob.Status__c = AvailabilityCheckUtils.RETRYING;
        } else if (deferJob) {
                //system.debug('ntj: processCompletedBatchJob: defer job');
                completedBatchJob.Flagged_For_Retry__c = false;
                completedBatchJob.Retry__c = false;
                completedBatchJob.Status__c = AvailabilityCheckUtils.DEFERRED;
        } else {
                //system.debug('ntj: processCompletedBatchJob: failed job');
                completedBatchJob.Flagged_For_Retry__c = false;
                completedBatchJob.Retry__c = false;
                completedBatchJob.Status__c = AvailabilityCheckUtils.FAILED;
        }
        
        lineAvailability.Internal_Description__c = e.getMessage();
        lineAvailability.Processed__c = markAsProcessed;
        lineAvailability.SOA_Fault__c = e.getMessage();      
        return lineAvailability;
    }
        
 }