public class AvailabilityCheckUtils
{

    public static final String IN_PROGRESS  = 'In Progress';
    public static final String RETRYING     = 'Retrying';
    public static final String DEFERRED     = 'Deferred';
    public static final String FAILED       = 'Failed';
    public static final String COMPLETED    = 'Completed';
    public static final String BAD_RESPONSE = 'Bad Response';

    public static final String EMAIL         = 'Email';
    public static final String FILE_UPLOAD   = 'File Upload';
    public static final String SCREEN_INPUT  = 'Screen Input';
    public static final String ONLINE         = 'Online';

    public static final String TYPE_LINE        = 'Line';
    public static final String TYPE_BROADBAND   = 'Broadband';
    public static final String TYPE_LINE_AND_BROADBAND = 'Line&Broadband';
    public static final String TYPE_BROADBAND2  = 'Broadband2';


    public static final String LINE_CHECK_COMPLETED_TEMPLATE_NAME = 'Line_Availability_Check_Completed';
    public static final String LINE_CHECK_DEFERRED_TEMPLATE_NAME = 'Line_Availability_Check_Deferred';
    public static final String LINE_CHECK_FAILED_TEMPLATE_NAME = 'Line_Availability_Check_Failed';

    public static final Integer MAX_BATCH_JOBS_COUNT = 5;

    public static Map<Id, Id> processAvailabilityCheck(List<Id> retryBatchJobIds)
    {
        Map<Id, Id> batchJobMap = new Map<Id, Id>();
        if (retryBatchJobIds != null)
        {
            if (retryBatchJobIds.size() > 0)
            {
                boolean processed = false;
                // Only handle single jobs with @future method
                if(retryBatchJobIds.size()==1)
                {
                    // The max number of callouts per invocation is 10, the number of items to be called must be less than 11
                    integer numOfLines = [select count() from Line_Availability__c where Batch_Job__c=:retryBatchJobIds[0]];
                    if(numOfLines<11 && (Limits.getFutureCalls() < Limits.getLimitFutureCalls()))
                    {
                        AvailabilityCheckBatchAsync.executeFuture(retryBatchJobIds[0]);
                        processed = true;
                    }
                }
                // If the request can't be processed using @future then use batch apex
                if(!processed)
                {    
                    System.debug('getExistingBatchJobCount()=' + getExistingBatchJobCount());
                    System.debug('retryBatchJobIds.size()=' + retryBatchJobIds.size());
                    System.debug('MAX_BATCH_JOBS_COUNT=' + MAX_BATCH_JOBS_COUNT);
                    
                    if ((getExistingBatchJobCount() + retryBatchJobIds.size()) <= MAX_BATCH_JOBS_COUNT)
                    {   
                        // There are batch job slots available
                        Id batchInstanceid = database.executeBatch(new AvailabilityCheckBatchAsync(retryBatchJobIds), 1);
                        batchJobMap.put(retryBatchJobIds[0], batchInstanceid);
                        
                    }
                    else
                    {
                        // Batch jobs cannot be processed now - defer them
                        deferBatchJobs(retryBatchJobIds);
                        List<Batch_Job__c> bj = [SELECT Id, Name, Status__c FROM Batch_Job__c WHERE Id = :retryBatchJobIds[0]];

                    }
                }
            }
        }
        return batchJobMap;
    }

    public static void processAvailabilityCheckCompletion(List<Batch_Job__c> completedBatchJobs, List<Batch_Job__c> deferredBatchJobs, List<Batch_Job__c> failedBatchJobs)
    {
        try
        {
            AvailabilityCheckOutputProcessor.handleCompleted(completedBatchJobs);
            AvailabilityCheckOutputProcessor.handleDeferred(deferredBatchJobs);
            AvailabilityCheckOutputProcessor.handleFailed(failedBatchJobs);
        }
        catch (Exception e)
        {
            insert new Batch_Job_Error__c(Error_Message__c=e.getCause()+' : '+e.getMessage());
        }
    }

    public static Integer getExistingBatchJobCount()
    {
        return [Select Id From AsyncApexJob
            Where Status In ('Queued', 'Processing','Preparing')
            And JobType != 'BatchApexWorker'].size();
    }

    private static void deferBatchJobs(List<Id> batchJobIds)
    {
        List<Batch_Job__c> batchJobsToUpdate = new List<Batch_Job__c>();
        for (Id batchJobId : batchJobIds)
        {
            batchJobsToUpdate.add(new Batch_Job__c(id                   = batchJobId,
                        Flagged_For_Retry__c = false,
                        Retry__c             = false,
                        Status__c            = AvailabilityCheckUtils.DEFERRED));
        }
        update batchJobsToUpdate;
    }


    //--------------------------------------------------------------------------
    // Convert string to integer
    //--------------------------------------------------------------------------
    public static Integer toInteger(String value)
    {
        Integer returnValue = null;
        if (value != null)
        {
            try
            {
                returnValue = Integer.valueOf(value.trim());
            }
            catch (Exception e)
            {
                System.debug('Exception: ' + e.getMessage());
            }
        }

        return returnValue;
    }

}