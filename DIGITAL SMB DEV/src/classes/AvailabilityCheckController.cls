global with sharing class AvailabilityCheckController {
/*
*       This class is the controller for both the Availability Check page and Availablity Check Results page
*
*       Revision History
*       1.0    10/02/2011  Initial Version
*/
    private static final Integer PAGE_SIZE = 50;
    private Integer totalPageNumber = 0;
    private Id batchJobId;
    public Id jobId {get; set;}
    // The batch job that is in progress
    public Batch_Job__c batchJob {get; set;}
    // Bind to inputFile component
    public Attachment attachment {get; set;}
    // Manually input into screen and used to display results
    public List<Line_Availability__c> lineAvailabilityRequests {get; set;}
    // Add more than one manual row at a time
    public Integer rowsToAdd {get; set;}
    //
    String serviceCheckType = AvailabilityCheckUtils.TYPE_LINE;

    public String getServiceCheckType() {
        return serviceCheckType ;
    }

    public void setServiceCheckType(String t) {
        serviceCheckType = t;
        batchJob.type__c = t;
    }

    // Constructor - for Batch Job Results
    public AvailabilityCheckController() {
        // check to see if we were passed an id parameter
        lineAvailabilityRequests = new List<Line_Availability__c>();
        if(ApexPages.currentPage().getParameters().get('id')!=null) {
            try {
                // we got an id parameter - so get it
                batchJobId = ApexPages.currentPage().getParameters().get('id');
                refreshBatchRecord();
                lineAvailabilityRequests = [SELECT Id, Name FROM Line_Availability__c WHERE Batch_Job__c = :batchJobId];
            } catch(Exception e) {
                // if we get an exception then assume its an invalid id
                // logging a message - is this enough?
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ' The Batch Job Id is not valid'));
            }
        } else {
            // if we were not supplied a parameter then that's bad programming
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ' The Batch Job Id is required in the URL'));
        }
    }

    // Constructor - for Check Request
    public AvailabilityCheckController(ApexPages.StandardController controller) {
            batchJob =  new Batch_Job__c();
            attachment = new Attachment();
            rowsToAdd = 1;
            lineAvailabilityRequests = new List<Line_Availability__c>{new Line_Availability__c()};
    }

    // Returns the list of line availablity result records from the set controller
    public List<Line_Availability__c> lineAvailabilityResponses {get {
        return (List<Line_Availability__c>)con.getRecords();
    } set;}


    // Force a reset of the controller records, so the page number must be set back afterwards
    private void refreshControllerRecords() {
           integer pageNumber = con.getPageNumber();
           con = getController();
           con.setPageNumber(pageNumber);
    }

    // Get the controller - cached version, if not first time
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                con = getController();
            }
            return con;
        }
        set;
    }

    // Get the controller set from querying the batch
    private ApexPages.StandardSetController getController() {
        ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,
                                   Name,
                                   Type__c,
                                   Post_Code__c,
                                   Directory_Number__c,
                                   Service_Type__c,
                                   Billing_Numbers__c,
                                   Single_DDIs__c,
                                   DDI_Ranges__c,
                                   Number_of_Lines__c,
                                   Number_of_Channels__c,
                                   Number_of_Incompatible_Or_Unsupported__c,
                                   Features__c,
                                   Incompatible_Services__c,
                                   Unsupported_Services__c,
                                   Carrier_Pre_Select__c,
                                   Narrowband_Service_Indicator__c,
                                   Processed__c,
                                   Response__c,
                                   LLU_or_IPS_available__c,
                                   isLLUAvailable__c,
                                   btExchangeName__c ,
                                   earthCapacitanceA__c ,
                                   earthCapacitanceB__c ,
                                   contractedPartyName__c ,
                                   contractedPartyNumber__c ,
                                   lineLengthEstimate__c,
                                   predictedDownloadSpeed__c ,
                                   isIPStreamAvailable__c,
                                   accessLineStatus__c,
                                   anfpCategory__c ,
                                   estimatedLineSpeed__c,
                                   reasonCode__c,
                                   Reason_code_short_text__c,
                                   Status__c,
                                   External_Description__c,
                                   Status_Indicator__c,
                                   productList__c,
                                   AggregatedCircuitLineLengthCalculated__c,
                                   BETEnabled__c,
                                   CalculatedDBLoss__c,
                                   CelerityDBLoss__c,
                                   CircuitLineLengthCalculated__c,
                                   CircuitLineLengthEstimate__c,
                                   DP__c,
                                   DPLineLengthEstimate__c,
                                   FTTCAvailable__c,
                                   FTTPAvailable__c,
                                   FVAAvailable__c,
                                   FTTPPercentageCoverage__c,
                                   LastCelerityUpdateDateTime__c,
                                   LastMonthlyUpdateDateTime__c,
                                   LastWeeklyUpdateDateTime__c,
                                   PCPId__c,
                                   Resp1CC__c,
                                   Resp1Txt__c,
                                   Resp1Sev__c,
                                   Resp2CC__c,
                                   Resp2Txt__c,
                                   Resp2Sev__c,
                                   Resp3CC__c,
                                   Resp3Txt__c,
                                   Resp3Sev__c,
                                   Resp4CC__c,
                                   Resp4Txt__c,
                                   Resp4Sev__c,
                                   aggregatedCapacitance__c,
                                   aggregatedDPLineLengthEstimate__c,
                                   aggregatedCircuitLineLengthEstimate__c,
                                   aggregatedCalculatedDBLoss__c,
                                   aggregatedCelerityDBLoss__c,
                                   districtCodeList__c,
                                   BBServiceCompatibility__c,
                                   BBTechnologyCode__c,
                                   BBTechnologyText__c,
                                   btExchangeId__c,
                                   AccessLineID__c,
                                   PSTNTieCableID__c,
                                   FTTCMaximumDownstreamDataBandwidth__c,
                                   FTTCMaximumUpstreamDataBandwidth__c,
                                   predictedUploadSpeed__c,
                                   Annex_M_RAG_Status__c
                    From Line_Availability__c
                    Where Batch_Job__c = : batchJobId
                    Order By Name limit 10000]));

        con.setPageSize(PAGE_SIZE);
        return con;
    }

    // Cancel the running batch job
    public PageReference cancelJob() {
        refreshBatchRecord();
        update batchJob;
        for(Line_Availability__c[] las: [select id, processed__c, response__c from Line_Availability__c where Batch_Job__c = : batchJobId]) {
            for(Line_Availability__c la: las) {
                la.processed__c = true;
                la.response__c = 'Batch Job Cancelled';
            }
            update las;
        }
        batchJob.status__c=AvailabilityCheckUtils.FAILED;
        update batchJob;

        Id parentJobId = batchJob.AsynchJobId__c;
        jobId = parentJobId;

        for(AsyncApexJob job: [select Id From AsyncApexJob where ParentJobId=:parentJobId]) {
            if(job.Id!=null) {
                abortJob(job.Id);
            }
        }
        for(AsyncApexJob job: [select ParentJobId From AsyncApexJob where Id=:parentJobId]) {
            if(job.ParentJobId !=null) {
                abortJob(job.ParentJobId );
            }
        }


        return null;
    }

    @future
    public static void abortJob(Id jobId) {
        System.abortJob(jobId);
    }

    // File upload has been initiated
    public PageReference processCSVFile() {
        Savepoint sp = Database.setSavepoint();
        try {
            batchJob = AvailabilityCheckInputProcessor.processCSVFiles(new List<Attachment>{attachment}, AvailabilityCheckUtils.FILE_UPLOAD, null, serviceCheckType);
            // store the id so we can cancel it if we want
            batchJobId = batchJob.Id;
        } catch (DmlException e) {
            Database.rollback(sp);
            attachment = new Attachment();
            return null;
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Invalid characters present, please check the file is in CSV format. The second and subsequent lines must have the correct number of columns as indicated by the column headers on the first line.'));
            System.debug('Error on processing CSV file: ' + e.getMessage());
            attachment = new Attachment();
            return null;
        }
        Map<Id,Id> jobMap = AvailabilityCheckUtils.processAvailabilityCheck(new List<Id>{batchJob.Id});
        //batchJob.AsynchJobId__c = jobMap.get(batchJob.Id);
        Batch_Job__c bj = new Batch_Job__c(Id = batchJob.Id, AsynchJobId__c = jobMap.get(batchJob.Id));
        update bj;
        // Redirect is needed to flush the viewstate - attachment bind variable seems to cause issues
        PageReference p = Page.AvailabilityCheckResults;
        p.getParameters().put('id', batchJob.Id);
        p.setRedirect(true);
        return p;
    }

    // Line availability checks have been manually entered
    public PageReference submitRows() {
        // Leaving code in case it is determined that postcode validation is needed
        //if ( ! validatePostcodes() ) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'One or more postcodes have been entered in an invalid format. Please check your data and try again.'));
            //return null;
        //}
        for(Line_Availability__c la : lineAvailabilityRequests) {
            if(la.post_code__c!=null && !SOAUtils.isValidPostCode(la.post_code__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'One or more postcodes have been entered in an invalid format. Please check your data and try again.'));
                return null;
            }
            if(la.directory_number__c!=null && !SOAUtils.isValidDirectoryNumber(la.directory_number__c)) {
            	System.debug('******* LA ' + la);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'One or more Directory Numbers have been entered in an invalid format. Please check your data and try again.'));
                return null;
            }
        }

        // Check that the user has entered data
        if (removeEmptyRows(lineAvailabilityRequests).size() == 0) {
            if(serviceCheckType == AvailabilityCheckUtils.TYPE_BROADBAND) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Invalid input. Please enter either a directory number or postcode for the broadband check.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Invalid input. Please enter one directory number and one postcode for the line check.'));
            }
            return null;
        }
        lineAvailabilityRequests = removeEmptyRows(lineAvailabilityRequests);
        //if(lineAvailabilityRequests.size()>10) {
            Savepoint sp = Database.setSavepoint();
            try {
                batchJob = AvailabilityCheckInputProcessor.processLineAvailablityArray(lineAvailabilityRequests, AvailabilityCheckUtils.SCREEN_INPUT, serviceCheckType);
            } catch (DmlException e) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                attachment = new Attachment();
                return null;
            } catch (Exception e) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                attachment = new Attachment();
                return null;
            }
            Map<Id,Id> jobMap = AvailabilityCheckUtils.processAvailabilityCheck(new List<Id>{batchJob.Id});
            //batchJob.AsynchJobId__c = jobMap.get(batchJob.Id);
            Batch_Job__c bj = new Batch_Job__c(Id = batchJob.Id, AsynchJobId__c = jobMap.get(batchJob.Id));
            update bj;
        //}
        // if there are less then 10 to be processed we can process them immediately / synchronously instead of asychronously
        //else if(lineAvailabilityRequests.size()>0 && lineAvailabilityRequests.size()<11) {
        //    batchJob = AvailabilityCheckInputProcessor.processLineAvailablityImmediate(lineAvailabilityRequests, AvailabilityCheckUtils.SCREEN_INPUT, serviceCheckType);
        //}
        // No redirect needed here as attachment bind variable is not set
        PageReference ref = Page.AvailabilityCheckResults;
        ref.getParameters().put('id',batchJob.Id);
        return ref;
    }


    // ActionPoller calls this method to update the list of results
    public PageReference requeryBatchJobAndLineAvailabilities() {
        refreshBatchRecord();
        refreshControllerRecords();
        return null;
    }


    // ActionPoller calls this method to update the list of results
    public PageReference requeryBatchJob() {
        refreshBatchRecord();
        return null;
    }

    // SOQL used to update results page
    private void refreshBatchRecord() {
        batchJob = [Select Id,
                       Incomplete_Requests__c,
                       AsynchJobId__c,
                       Status__c,
                       Type__c,
                       Total_Retries__c
                From Batch_Job__c
                Where Id = : batchJobId limit 1];
    }

    // More manual rows are required
    public PageReference addRows() {
        for (Integer i = 0; i < rowsToAdd; i++ ) {
            lineAvailabilityRequests.add(new Line_Availability__c());
        }
        return null;
    }

    // User may have requested more rows than they wished to enter
    private List<Line_Availability__c> removeEmptyRows(List<Line_Availability__c> lineAvailabilityRequests) {
        List<Line_Availability__c> lineAvailabilityRequestForInsert = new List<Line_Availability__c>();
        for (Line_Availability__c lineAvailabilityRequest : lineAvailabilityRequests) {

            if (serviceCheckType == AvailabilityCheckUtils.TYPE_BROADBAND) {
                if(lineAvailabilityRequest.Post_Code__c!= null || lineAvailabilityRequest.Directory_Number__c!= null) {
                    Line_Availability__c lar = new Line_Availability__c();
                    lar.Directory_Number__c = SOAUtils.cleanDirectoryNumber(lineAvailabilityRequest.Directory_Number__c);
                    lar.Post_Code__c = lineAvailabilityRequest.Post_Code__c;

                    lineAvailabilityRequestForInsert.add(lar);
                }
            } else {
                if (lineAvailabilityRequest.Directory_Number__c != null) {
                    if (lineAvailabilityRequest.Post_Code__c != null) {
                        Line_Availability__c lar = new Line_Availability__c();
                        lar.Directory_Number__c = SOAUtils.cleanDirectoryNumber(lineAvailabilityRequest.Directory_Number__c);
                        lar.Post_Code__c = lineAvailabilityRequest.Post_Code__c;
                        lineAvailabilityRequestForInsert.add(lar);
                    }
                }
            }

        }
        return lineAvailabilityRequestForInsert;
    }

        // NAVIGATION METHODS - START //

    // Availability check is complete - view detail record
    /*
    public PageReference viewCompletedJob() {
        return new ApexPages.StandardController(batchJob).view();
    }*/

    // Navigate user from results back to data entry page
    /*
    public PageReference backToAvailabilityCheck() {
        rowsToAdd  = 1;
        attachment = new Attachment();
        lineAvailabilityRequests = new List<Line_Availability__c>{new Line_Availability__c()};
        return Page.AvailabilityCheck;
    }*/

    // NAVIGATION METHODS - END //

    // STATUS METHODS - START //
    // Information, warning and error messages displayed on results page
    //
    // There are three messages per Status__c (LINE, BROADBAND, LINE+BROADBAND
    // TODO: have not created the label for LINE+BROADBAND yet
    public String pgMessage { get {
        String msg= '';
        if(batchJob!=null) {
            if (batchJob.Status__c.equals(AvailabilityCheckUtils.IN_PROGRESS)) {
                	if (batchJob.Type__c == AvailabilityCheckUtils.TYPE_LINE)
                    	msg = System.Label.LINE_AVAILABILITY_CHECK_IN_PROGRESS;
                	else if (batchJob.Type__c == AvailabilityCheckUtils.TYPE_BROADBAND)
                    	msg = System.Label.LINE_AVAILABILITY_CHECK_IN_PROGRESS_BB;
                	else msg = System.Label.LINE_AVAILABILITY_CHECK_IN_PROGRESS_COMBINED;
            } else if (batchJob.Status__c.equals(AvailabilityCheckUtils.RETRYING) || batchJob.Status__c.equals(AvailabilityCheckUtils.DEFERRED)) {
                if (batchJob.Type__c == AvailabilityCheckUtils.TYPE_LINE)
                    msg = System.Label.LINE_AVAILABILITY_CHECK_DEFERRED;
                else if (batchJob.Type__c == AvailabilityCheckUtils.TYPE_BROADBAND)
                    msg = System.Label.LINE_AVAILABILITY_CHECK_DEFERRED_BB;
                else msg = System.Label.LINE_AVAILABILITY_CHECK_DEFERRED_COMBINED;
            } else if (batchJob.Status__c.equals(AvailabilityCheckUtils.FAILED)) {
                if (batchJob.Type__c == AvailabilityCheckUtils.TYPE_LINE)
                    msg = System.Label.LINE_AVAILABILITY_CHECK_FAILED;
                else if (batchJob.Type__c == AvailabilityCheckUtils.TYPE_BROADBAND)
                    msg = System.Label.LINE_AVAILABILITY_CHECK_FAILED_BB;
                else msg = System.Label.LINE_AVAILABILITY_CHECK_FAILED_COMBINED;
            } else if (batchJob.Status__c.equals(AvailabilityCheckUtils.COMPLETED)) {
                if (batchJob.Type__c == AvailabilityCheckUtils.TYPE_LINE)
                    msg = System.Label.LINE_AVAILABILITY_CHECK_COMPLETED;
                else if (batchJob.Type__c == AvailabilityCheckUtils.TYPE_BROADBAND)
                    msg = System.Label.LINE_AVAILABILITY_CHECK_COMPLETED_BB;
                else msg = System.Label.LINE_AVAILABILITY_CHECK_COMPLETED_COMBINED;
            } else return '';
        }
        return msg;
    }}

    public String pgMessageType { get {
        String msg= '';
        if(batchJob!=null) {
            if (batchJob.Status__c.equals(AvailabilityCheckUtils.IN_PROGRESS) || batchJob.Status__c.equals(AvailabilityCheckUtils.RETRYING)) {
                msg = 'warning';
            } else if (batchJob.Status__c.equals(AvailabilityCheckUtils.DEFERRED) || batchJob.Status__c.equals(AvailabilityCheckUtils.FAILED)) {
                msg = 'error';
            } else if (batchJob.Status__c.equals(AvailabilityCheckUtils.COMPLETED)) {
                msg ='info';
            }
        }
        return msg;
    }}
    // PAGINATION METHODS - END //

        // PAGINATION METHODS - START //

    // returns the page number of the current page set
    public Integer getPageNumber() {
        return con.getPageNumber();
    }

    // returns the first page of records
    public void first() {
        con.first();
    }

    // returns the last page of records
    public void last() {
        con.last();
    }

    // returns the previous page of records
    public void previous() {
        con.previous();
    }

    // returns the next page of records
    public void next() {
        con.next();
    }

    // returns the total number of pages for pagination
    public Integer getTotalPageNumber() {
        if (totalPageNumber == 0) {
            integer resultSize = con.getResultSize();
            totalPageNumber = resultSize / PAGE_SIZE;
            Integer mod = resultSize - (totalPageNumber * PAGE_SIZE);
            if (mod > 0)
            totalPageNumber++;
        }
        return totalPageNumber;
    }

    // returns if the current page has been processed
    public boolean getPageProcessed() {
        boolean pageProcessed = true;
        if(batchJob!=null && !batchJob.Status__c.equals(AvailabilityCheckUtils.COMPLETED)) {
                for(SObject la : (List<SObject>)con.getRecords()) {
                    if(la.get('Processed__c')==false) {
                        pageProcessed = false;
                        break;
                    }
                }
        }
        return pageProcessed ;
    }
    // PAGINATION METHODS - END //

}