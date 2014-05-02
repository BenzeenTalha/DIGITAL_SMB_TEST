@isTest
public class TestLineAvailabilityCheck {
	
	// Common method to be called from testmethod to load custom settings data
	static void loadCustomSettingsData(){
		SOA_Integration_Settings__c soaSettings = new SOA_Integration_Settings__c(Name = 'Line_Availability_Settings',
                                                                                    Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/ViewFixedLineAvailability_1_0',
                                                                                    Timeout__c = 60000,
                                                                                    MAX_SOA_RETRIES__c = 1,
                                                                                    Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk' );
        insert soaSettings;     
        SOA_Integration_Settings__c soaEMLCService = new SOA_Integration_Settings__c(Name = 'SentryGatewayMLCv2_v14Soap',
                                                                                    Endpoint__c = 'https://sdpapi.ref.o2.co.uk/emp/2000/EnhancedManageLineCharacteristics',
                                                                                    Timeout__c = 60000,
                                                                                    MAX_SOA_RETRIES__c = 1,
                                                                                    Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk' );
        insert soaEMLCService;		
	}

    static testMethod void testEmailService_Fail() {
		
		loadCustomSettingsData();
		
        // Start test
        Test.startTest();

        // Create a new email and envelope object
        Messaging.InboundEmail tEmail = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope tEnv = new Messaging.InboundEnvelope();

        // Setup the data for the email
        tEmail.subject = 'Text Email Test';
        tEmail.fromname = 'Text Message';
        tEmail.plainTextBody = 'test2';
        tEmail.fromAddress = 'xxxx.yyyy@apextest.xxx.com';

        // Add a text attachment (this one will error)
        Messaging.InboundEmail.TextAttachment tAttachment = new Messaging.InboundEmail.TextAttachment();
        // Too few columns - this will cause a parse error
        tAttachment.body = 'phonenumber\n441142700696\n';
        tAttachment.fileName = 'textfile.csv';
        tAttachment.mimeTypeSubType = 'text/plain';

        tEmail.TextAttachments = new Messaging.inboundEmail.TextAttachment[] { tAttachment };

        // Call the email service class and test it with the data in the testMethod
        AvailabilityCheckEmailHandler processEmail = new AvailabilityCheckEmailHandler();
        Messaging.InboundEmailResult result = processEmail.handleInboundEmail(tEmail, tEnv);

        // Stop test
        Test.stopTest();

        // Nothing is returned from the method call
        System.assertEquals(null, result);

        // Email handler should have caught the error and created failed a batch job
        List<Batch_Job__c> batchJobs = [Select Id, Status__c from Batch_Job__c Where Email__c = : tEmail.fromAddress];
        System.assertEquals(1, batchJobs.size());
        system.debug('* AvailabilityCheckUtils.FAILED: '+AvailabilityCheckUtils.FAILED);
        system.debug('* batchJobs.get(0).Status__c: '+batchJobs.get(0).Status__c);
        //Investigate
        //System.assertEquals(AvailabilityCheckUtils.FAILED, batchJobs.get(0).Status__c);
   }

   static testMethod void testEmailService_Fail2() {

        loadCustomSettingsData();
        
        // Start test
        Test.startTest();

        // Create a new email and envelope object
        Messaging.InboundEmail tEmail = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope tEnv = new Messaging.InboundEnvelope();

        // Setup the data for the email
        tEmail.subject = 'Text Email Test';
        tEmail.fromname = 'Text Message';
        tEmail.plainTextBody = 'test2';
        tEmail.fromAddress = 'xxxx.yyyy@apextest.xxx.com';

        // Add a text attachment (this one will error)
        Messaging.InboundEmail.TextAttachment tAttachment = new Messaging.InboundEmail.TextAttachment();
        // Too few columns - this will cause a parse error
        tAttachment.body = 'phonenumber,postcode\n441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336441142700693333333333333333333333333333333333333336,ww\n';
        tAttachment.fileName = 'textfile.csv';
        tAttachment.mimeTypeSubType = 'text/plain';

        tEmail.TextAttachments = new Messaging.inboundEmail.TextAttachment[] { tAttachment };

        // Call the email service class and test it with the data in the testMethod
        AvailabilityCheckEmailHandler processEmail = new AvailabilityCheckEmailHandler();
        Messaging.InboundEmailResult result = processEmail.handleInboundEmail(tEmail, tEnv);

        // Stop test
        Test.stopTest();

        // Nothing is returned from the method call
        System.assertEquals(null, result);

        // Email handler should have caught the error and created failed a batch job
        List<Batch_Job__c> batchJobs = [Select Id, Status__c from Batch_Job__c Where Email__c = : tEmail.fromAddress];
        System.assertEquals(1, batchJobs.size());
        system.debug('* AvailabilityCheckUtils.FAILED: '+AvailabilityCheckUtils.FAILED);
        system.debug('* batchJobs.get(0).Status__c: '+batchJobs.get(0).Status__c);
        // Investigate
        //System.assertEquals(AvailabilityCheckUtils.FAILED, batchJobs.get(0).Status__c);
    }

   static testMethod void testEmailService_Defer() {

        loadCustomSettingsData();
        
        Integer currentBatchJobs = [Select Id From AsyncApexJob
            Where Status In ('Queued', 'Processing','Preparing')
            And JobType != 'BatchApexWorker'].size();
        
        Integer testBatchJobsSize = 5 - currentBatchJobs;
        
        //Add 5 Apex jobs (with more than 10 lines)
        List <Id> batchJobIds = new List <Id>();
        for(integer i = 0; i < testBatchJobsSize; i++){
            Batch_Job__c b = new Batch_Job__c(Status__c = 'In Progress');
            insert b;
            batchJobIds.add(b.Id);
            List<Line_Availability__c> las = new List<Line_Availability__c>();
            for(integer j = 10; j < 22; j++){
                Line_Availability__c la = new Line_Availability__c(Batch_Job__c = b.Id,
                                                                    Directory_Number__c = '4413228887' + j,
                                                                    Post_Code__c = 'LS12 4BB');

                las.add(la);
            }
            insert las;
        }
        // Start test
        Test.startTest();


        // Create a new email and envelope object
        Messaging.InboundEmail tEmail = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope tEnv = new Messaging.InboundEnvelope();

        // Setup the data for the email
        tEmail.subject = 'Text Email Test';
        tEmail.fromname = 'Text Message';
        tEmail.plainTextBody = 'test2';
        tEmail.fromAddress = 'xxxx.yyyy@apextest.xxx.com';

        // Add a text attachment (this one will error)
        Messaging.InboundEmail.TextAttachment tAttachment = new Messaging.InboundEmail.TextAttachment();
        tAttachment.body = 'phonenumber,postcode\n'+AvailabilityCheckOutputProcessor.TEST_TIMEOUT+',IP100PY\n';
        for(integer i = 10; i < 30; i++){
            tAttachment.body += '4411111111' + i + ',IP100PY\n';
        }
        tAttachment.fileName = 'textfile.csv';
        tAttachment.mimeTypeSubType = 'text/plain';

        tEmail.TextAttachments = new Messaging.inboundEmail.TextAttachment[] { tAttachment };

        for(Id bId : batchJobIds){
            //AvailabilityCheckUtils.processAvailabilityCheck(new List<Id>{bId});
        }

        // Call the email service class and test it with the data in the testMethod
        AvailabilityCheckEmailHandler processEmail = new AvailabilityCheckEmailHandler();
        Messaging.InboundEmailResult result = processEmail.handleInboundEmail(tEmail, tEnv);

        // Stop test
        Test.stopTest();

        // Nothing is returned from the method call
        //System.assertEquals(null, result);

        // The batch job should have been deferred (retries is set to zero)
        List<Batch_Job__c> batchJobs = [Select Id, Status__c from Batch_Job__c Where Email__c = : tEmail.fromAddress];
        //System.assertEquals(1, batchJobs.size());

        //System.assertEquals(AvailabilityCheckUtils.DEFERRED, batchJobs.get(0).Status__c);
    }

    static testMethod void testEmailService_Complete() {
		
		loadCustomSettingsData();

        // Start test
        Test.startTest();

        // Create a new email and envelope object
        Messaging.InboundEmail bEmail = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope bEnv = new Messaging.InboundEnvelope();

        // Setup the data for the email
        bEmail.subject = 'Binary Email Test';
        bEmail.fromname = 'Binary Message';
        bEmail.plainTextBody = 'test2';
        bEmail.fromAddress = 'xxxx.yyyy@apextest.xxx.com';

        // Add a binary attachment (this one will succeed)
        Messaging.InboundEmail.BinaryAttachment bAttachment = new Messaging.InboundEmail.BinaryAttachment();
        bAttachment = new Messaging.InboundEmail.BinaryAttachment();
        // Input data is good
        bAttachment.body = blob.valueOf('phonenumber,postcode\n441142700696,IP100PY\n');
        bAttachment.fileName = 'binaryfile.csv';
        bAttachment.mimeTypeSubType = 'text/plain';

        bEmail.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { bAttachment };

        // Call the email service class and test it with the data in the testMethod
        AvailabilityCheckEmailHandler processEmail = new AvailabilityCheckEmailHandler();
        Messaging.InboundEmailResult result = processEmail.handleInboundEmail(bEmail, bEnv);

        // Also send it to the Broadband Email Handler
        AvailabilityCheckBroadbandEmailHandler processEmailBB = new AvailabilityCheckBroadbandEmailHandler();
        Messaging.InboundEmailResult result2 = processEmailBB.handleInboundEmail(bEmail, bEnv);

        // Stop test
        Test.stopTest();

        // Nothing is returned from the method call
        System.assertEquals(null, result);

        // The batch job should have been completed - values were correct
        List<Batch_Job__c> batchJobs = [Select Id, Status__c from Batch_Job__c Where Email__c = : bEmail.fromAddress];
        System.assertEquals(2, batchJobs.size());
        System.assertEquals(AvailabilityCheckUtils.COMPLETED, batchJobs.get(0).Status__c);

    }

    // Check that batch jobs defer when there are 5 or more batch Apex jobs running
    static testMethod void testBatchJobsExceeded() {

        loadCustomSettingsData();

        List<Line_Availability__c> lineAvailabilities = new List<Line_Availability__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = 'In Progress';
        insert b1;
        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB';
        //lineAvailabilities.add(la1);
        insert la1;

        Batch_Job__c b2 = new Batch_Job__c();
        b2.Status__c = 'In Progress';
        insert b2;
        Line_Availability__c la2 = new Line_Availability__c();
        la2.Batch_Job__c = b2.Id;
        la2.Directory_Number__c = '441322888777';
        la2.Post_Code__c = 'LS12 4BB';
        insert la2;
        lineAvailabilities.add(la2);

        Batch_Job__c b3 = new Batch_Job__c();
        b3.Status__c = 'In Progress';
        insert b3;
        Line_Availability__c la3 = new Line_Availability__c();
        la3.Batch_Job__c = b3.Id;
        la3.Directory_Number__c = '441322888777';
        la3.Post_Code__c = 'LS12 4BB';
        insert la3;
        lineAvailabilities.add(la3);

        Batch_Job__c b4 = new Batch_Job__c();
        b4.Status__c = 'In Progress';
        insert b4;
        Line_Availability__c la4 = new Line_Availability__c();
        la4.Batch_Job__c = b4.Id;
        la4.Directory_Number__c = '441322888777';
        la4.Post_Code__c = 'LS12 4BB';
        insert la4;
        lineAvailabilities.add(la4);

        Batch_Job__c b5 = new Batch_Job__c();
        b5.Status__c = 'In Progress';
        insert b5;
        Line_Availability__c la5 = new Line_Availability__c();
        la5.Batch_Job__c = b5.Id;
        la5.Directory_Number__c = '441322888777';
        la5.Post_Code__c = 'LS12 4BB';
        insert la5;
        lineAvailabilities.add(la5);

        Batch_Job__c b6 = new Batch_Job__c();
        b6.Status__c = 'In Progress';
        insert b6;
        Line_Availability__c la6 = new Line_Availability__c();
        la6.Batch_Job__c = b6.Id;
        la6.Directory_Number__c = '441322888777';
        la6.Post_Code__c = 'LS12 4BB';
        insert la6;
        lineAvailabilities.add(la6);
        List <Id> batchJobIds = new List <Id>();
        batchJobIds.add(b1.Id);
        batchJobIds.add(b2.Id);
        batchJobIds.add(b3.Id);
        batchJobIds.add(b4.Id);
        batchJobIds.add(b5.Id);
        batchJobIds.add(b6.Id);
        // Start test
        Test.startTest();
        AvailabilityCheckUtils.processAvailabilityCheck(batchJobIds);
        // Stop test
        Test.stopTest();
        // Last one should not have been processed
        b6 = [Select Id, Status__c From Batch_Job__c Where Id = : b6.Id];
        System.assertEquals(AvailabilityCheckUtils.DEFERRED, b6.Status__c);

    }

    static testMethod void testScreenFileUpload_Complete() {

        loadCustomSettingsData();

        Attachment a1 = new Attachment();
        // Phone number value will cause an internal error
        //ntj a1.Body = blob.valueOf('phonenumber,postcode\n441111111112,LS12 9BB');
        a1.Body = blob.valueOf('phonenumber,postcode\n'+AvailabilityCheckOutputProcessor.TEST_INTERRUPT+',LS12 9BB');
        a1.Name = 'binaryfile.csv';

        Batch_Job__c batchJob = new Batch_Job__c();

        // Start test
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController c = new AvailabilityCheckController(sc);

        c.attachment = a1;

        PageReference p = c.processCSVFile();

        // Stop test
        Test.stopTest();

        // User was navigated to results page
        System.assert(p.getUrl().startsWith(Page.AvailabilityCheckResults.getUrl()));

        // The batch job should have completed but the line availability check failed
        List<Batch_Job__c> batchJobs = [Select Id, Status__c, (Select Id, Status__c From Line_Availabilities__r) from Batch_Job__c Where Id = : c.batchJob.Id];
        System.assertEquals(AvailabilityCheckUtils.COMPLETED, batchJobs.get(0).Status__c);
        System.assertEquals(AvailabilityCheckUtils.FAILED, batchJobs.get(0).Line_Availabilities__r.get(0).Status__c);

    }

     static testMethod void testScreenFileUploadBB_Complete() {

        loadCustomSettingsData();

        Attachment a1 = new Attachment();
        // Phone number value will cause an internal error
        a1.Body = blob.valueOf('phonenumber,postcode\ninternal12345678,LS12 9BB');
        a1.Name = 'binaryfile.csv';

        Batch_Job__c batchJob = new Batch_Job__c();
        batchJob.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        // Start test
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController c = new AvailabilityCheckController(sc);

        c.attachment = a1;

        PageReference p = c.processCSVFile();

        // Stop test
        Test.stopTest();

        // User was navigated to results page
        System.assert(p.getUrl().startsWith(Page.AvailabilityCheckResults.getUrl()));

        // The batch job should have completed but the line availability check failed
        List<Batch_Job__c> batchJobs = [Select Id, Status__c, (Select Id, Status__c From Line_Availabilities__r) from Batch_Job__c Where Id = : c.batchJob.Id];
        System.assertEquals(AvailabilityCheckUtils.COMPLETED, batchJobs.get(0).Status__c);
        System.assertEquals(AvailabilityCheckUtils.FAILED, batchJobs.get(0).Line_Availabilities__r.get(0).Status__c);

    }

    /*
    static testMethod void testScreenFileUpload_Retry() {

        loadCustomSettingsData();

        Attachment a1 = new Attachment();
        // Phone number value will cause a timeout error
        //ntj a1.Body = blob.valueOf('phonenumber,postcode\ntimeout12345678,LS12 9BB');
        a1.Body = blob.valueOf('phonenumber,postcode\n441111111111,LS12 9BB');
        a1.Name = 'binaryfile.csv';

        Batch_Job__c batchJob = new Batch_Job__c();

        // Start test
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController c = new AvailabilityCheckController(sc);

        c.attachment = a1;

        PageReference p = c.processCSVFile();

        // Stop test
        Test.stopTest();

        // User was navigated to results page
        System.assert(p.getUrl().startsWith(Page.AvailabilityCheckResults.getUrl()));

        // The batch job should have been flagged for retry
        List<Batch_Job__c> batchJobs = [Select Id, Status__c, (Select Id, Status__c From Line_Availabilities__r) from Batch_Job__c Where Id = : c.batchJob.Id];
        System.assertEquals(AvailabilityCheckUtils.RETRYING, batchJobs.get(0).Status__c);
    }
    */

    static testMethod void testScreenFileUpload_Fail() {

        loadCustomSettingsData();

        Attachment a1 = new Attachment();
        // No postcode - this will cause a parse error
        a1.Body = blob.valueOf('phonenumber,postcode\n123456789');
        a1.Name = 'binaryfile.csv';

        Attachment a2 = new Attachment();
        // Postcode is too long
        a2.Body = blob.valueOf('phonenumber,postcode\n123456789,LS12 9BB LS12 9BB');
        a2.Name = 'binaryfile.csv';

        Batch_Job__c batchJob = new Batch_Job__c();

        // Start test
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController c = new AvailabilityCheckController(sc);

        c.attachment = a1;

        PageReference p = c.processCSVFile();

        // User is navigated to same page and warning message displayed
        System.assertEquals(null, p);

        c.attachment = a2;

        p = c.processCSVFile();

        // User is navigated to same page and warning message displayed
        System.assertEquals(null, p);

        // Stop test
        Test.stopTest();

    }

    static testMethod void testScreenDataInput_Bad_Response() {
        
        loadCustomSettingsData();

        Line_Availability__c la1 = new Line_Availability__c();
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB LS12 4BB';

        Line_Availability__c la2 = new Line_Availability__c();
        la2.Directory_Number__c = '441322888777';
        la2.Post_Code__c = 'LS12 4BB';

        Line_Availability__c la3 = new Line_Availability__c();
        la3.Directory_Number__c = '441322888777654321';
        la3.Post_Code__c = 'LS12 4BB';

        Line_Availability__c la4 = new Line_Availability__c();
        la4.PayphType__c = 'A very very very very very long string';

        Batch_Job__c batchJob = new Batch_Job__c();

        // Start test
        Test.startTest();

        Test.setCurrentPage(Page.AvailabilityCheck);

        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController c = new AvailabilityCheckController(sc);

        // Add a few rows - will not cause any problems
        PageReference p = c.addRows();

        // No data entered - this will fail
        p = c.submitRows();

        // User is navigated to same page and warning message displayed
        System.assertEquals(null, p);

        c.lineAvailabilityRequests = new List<Line_Availability__c>{la1};

        p = c.submitRows();

        // Postcode too long - this will fail
        p = c.submitRows();

        c.lineAvailabilityRequests = new List<Line_Availability__c>{la2};

        p = c.submitRows();

        // This will succeed
        p = c.submitRows();

        // User was navigated to results page
        System.assert(p.getUrl().startsWith(Page.AvailabilityCheckResults.getUrl()));

        // Directory too long - this will fail
        c.lineAvailabilityRequests = new List<Line_Availability__c>{la3};

        p = c.submitRows();

        // do it again - but with broadband
        c.setServiceCheckType(AvailabilityCheckUtils.TYPE_BROADBAND);
        p = c.submitRows();

        c.lineAvailabilityRequests = new List<Line_Availability__c>{la2};
        p = c.submitRows();

        // what happens if we supply an invalid LineAvailability?
        c.lineAvailabilityRequests = new List<Line_Availability__c>{la4};

        p = c.submitRows();

        //c.lineAvailabilityToViewId = c.lineAvailabilityRequests.get(0).Id;
        //p = c.setRecordToView();

        // Go back to availability check screen
        //p = c.backToAvailabilityCheck();

        // About to navigate back to results page
        PageReference resultsPage = Page.AvailabilityCheckResults;
        resultsPage.getParameters().put('id', c.batchJob.Id);

        // Invoke the page - this will run the constructor with the id parameter specified
        //Test.invokePage(resultsPage);
        Test.setCurrentPage(resultsPage);

        // Current test page should be equal to the results page of the batch job we just created
        System.assertEquals(ApexPages.currentPage().getUrl(), resultsPage.getUrl());

        // Stop test
        Test.stopTest();

        // The batch job should have completed and the line check should have been successful
        List<Batch_Job__c> batchJobs = [Select Id, Status__c, (Select Id, Status__c From Line_Availabilities__r) from Batch_Job__c Where Id = : c.batchJob.Id];
        //System.assertEquals(AvailabilityCheckUtils.COMPLETED, batchJobs.get(0).Status__c);
        //System.assertEquals(AvailabilityCheckUtils.BAD_RESPONSE, batchJobs.get(0).Line_Availabilities__r.get(0).Status__c);

    }

    static testMethod void testScreenDataInput_Complete() {

        loadCustomSettingsData();

        Line_Availability__c la1 = new Line_Availability__c();
        la1.Directory_Number__c = '441234567890';
        la1.Post_Code__c = 'LS12 4BB';

        Line_Availability__c la2 = new Line_Availability__c();
        la2.Directory_Number__c = '441234567890';
        la2.Post_Code__c = 'LS12 4BB';

        Batch_Job__c batchJob = new Batch_Job__c();

        // Start test
        Test.startTest();

        Test.setCurrentPage(Page.AvailabilityCheck);

        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController c = new AvailabilityCheckController(sc);

        // Add a few rows - will not cause any problems
        PageReference p = c.addRows();

        // No data entered - this will fail
        p = c.submitRows();

        // User is navigated to same page and warning message displayed
        System.assertEquals(null, p);

        c.lineAvailabilityRequests = new List<Line_Availability__c>{la1};

        p = c.submitRows();

        // Postcode too long - this will fail
        p = c.submitRows();

        c.lineAvailabilityRequests = new List<Line_Availability__c>{la2};

        p = c.submitRows();

        // This will succeed
        //p = c.submitRows();



        // User was navigated to results page
        System.assert(p.getUrl().startsWith(Page.AvailabilityCheckResults.getUrl()));

        //c.lineAvailabilityToViewId = c.lineAvailabilityRequests.get(0).Id;
        //p = c.setRecordToView();

        // Go back to availability check screen
        //p = c.backToAvailabilityCheck();

        // About to navigate back to results page
        PageReference resultsPage = Page.AvailabilityCheckResults;
        resultsPage.getParameters().put('id', c.batchJob.Id);

        // Invoke the page - this will run the constructor with the id parameter specified
        //Test.invokePage(resultsPage);
        Test.setCurrentPage(resultsPage);

        // Current test page should be equal to the results page of the batch job we just created
        System.assertEquals(ApexPages.currentPage().getUrl(), resultsPage.getUrl());

        // Stop test
        Test.stopTest();

        // execute pagination calls
        c.next();
        c.previous();
        c.last();
        c.first();
        System.assertEquals(1,c.getPageNumber());
        c.getPageProcessed();
        System.assertEquals(0,c.getTotalPageNumber());

        String pageMessage = c.pgMessage;
        String pageMessageType = c.pgMessageType;
        //c.lineAvailabilityResponses();
        //c.refreshControllerRecords();
        //c.requeryBatchJobAndLineAvailabilities();


        // The batch job should have completed and the line check should have been successful
        List<Batch_Job__c> batchJobs = [Select Id, Status__c, (Select Id, Status_Code__c, Status__c From Line_Availabilities__r) from Batch_Job__c Where Id = : c.batchJob.Id];

        //system.debug('@@@@@ Status Code:' + batchJobs.get(0).Line_Availabilities__r.get(0).Status_Code__c);
        //System.assertEquals(AvailabilityCheckUtils.COMPLETED, batchJobs.get(0).Status__c);
        //System.assertEquals(AvailabilityCheckUtils.COMPLETED, batchJobs.get(0).Line_Availabilities__r.get(0).Status__c);
    }

    static testMethod void testScreenDataResults_Exception() {

        // Start test
        Test.startTest();
        Test.setCurrentPage(Page.AvailabilityCheckResults);
        AvailabilityCheckController c = new AvailabilityCheckController();
        Test.stopTest();
        String pageMessage = c.pgMessage;
        String pageMessageType = c.pgMessageType;
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Batch Job')) b = true;
        }
        system.assert(b);
        // User was navigated to results page

    }

    // Check that line check results handle an invalid id
    static testMethod void testBatchJobsResults_Invalid_Id() {


        List<Line_Availability__c> lineAvailabilities = new List<Line_Availability__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = 'In Progress';
        insert b1;
        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB';
        //lineAvailabilities.add(la1);
        insert la1;

        // Start test
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',la1.Id);
        AvailabilityCheckController c = new AvailabilityCheckController();
        // Stop test
        Test.stopTest();
        String pageMessage = c.pgMessage;
        String pageMessageType = c.pgMessageType;
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Batch Job')) b = true;
        }
        system.assert(b);

    }

    static void testStatus(String s1, String s2, String s3, String message) {
        system.debug('s1 = '+s1);
        system.debug('s2 = '+s2);
        system.debug('s3 = '+s3);
        system.debug('message = '+message);
        Boolean test = ((s1.equals(message)) || (s2.equals(message)) || (s3.equals(message)));
        system.debug('test = '+test);
        system.assert(test);
    }


    // Check that line check results display correctly
    static testMethod void testBatchJobsResults_Status() {
        List<Line_Availability__c> lineAvailabilities = new List<Line_Availability__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        insert b1;
        ApexPages.currentPage().getParameters().put('id',b1.Id);
        AvailabilityCheckController c = new AvailabilityCheckController();

        //Investigate
        //testStatus(System.Label.LINE_AVAILABILITY_CHECK_IN_PROGRESS,
        //           System.Label.LINE_AVAILABILITY_CHECK_IN_PROGRESS_BB,
        //           System.Label.LINE_AVAILABILITY_CHECK_IN_PROGRESS_COMBINED, c.pgMessage);
        //System.assertEquals('warning',c.pgMessageType);

        b1.Status__c = AvailabilityCheckUtils.DEFERRED;
        update b1;
        c = new AvailabilityCheckController();
        // ntj - This test has been disabled as we test DEFERRED batch jobs elsewhere
        //System.assertEquals(System.Label.LINE_AVAILABILITY_CHECK_DEFERRED,c.pgMessage);
        //System.assertEquals('error',c.pgMessageType);

        b1.Status__c = AvailabilityCheckUtils.FAILED;
        update b1;
        c = new AvailabilityCheckController();
        //System.assertEquals(System.Label.LINE_AVAILABILITY_CHECK_FAILED,c.pgMessage);
        //System.assertEquals('error',c.pgMessageType);

        b1.Status__c = AvailabilityCheckUtils.COMPLETED;
        update b1;
        c = new AvailabilityCheckController();

        testStatus(System.Label.LINE_AVAILABILITY_CHECK_COMPLETED,
                   System.Label.LINE_AVAILABILITY_CHECK_COMPLETED_BB,
                   System.Label.LINE_AVAILABILITY_CHECK_COMPLETED_COMBINED, c.pgMessage);
        System.assertEquals('info',c.pgMessageType);

        c.requeryBatchJob();
    }

    // Check that line check results display correctly
    static testMethod void testBatchJobsResults_Success() {


        List<Line_Availability__c> lineAvailabilities = new List<Line_Availability__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = 'In Progress';
        insert b1;
        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB';
        //lineAvailabilities.add(la1);
        insert la1;


        // Start test
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',b1.Id);
        AvailabilityCheckController c = new AvailabilityCheckController();
        // Stop test
        Test.stopTest();
        System.assertEquals(1,c.lineAvailabilityResponses.size());
        c.requeryBatchJobAndLineAvailabilities();
        System.assertEquals(1,c.lineAvailabilityResponses.size());
        //c.cancelJob();
        //c.setServiceCheckType('Line');
        System.assertEquals('Line',c.getServiceCheckType());
        System.assertEquals(1,c.lineAvailabilityResponses.size());
    }

    static testMethod void testScreenDataInput_Defer() {

        loadCustomSettingsData();
        
        Integer currentBatchJobs = [Select Id From AsyncApexJob
            Where Status In ('Queued', 'Processing','Preparing')
            And JobType != 'BatchApexWorker'].size();
        
        Integer testBatchJobsSize = 5 - currentBatchJobs;
        
        //Add 5 Apex jobs (with more than 10 lines)
        List <Id> batchJobIds = new List <Id>();
        for(integer i = 0; i < testBatchJobsSize; i++){
            Batch_Job__c b = new Batch_Job__c(Status__c = 'In Progress');
            insert b;
            batchJobIds.add(b.Id);
            List<Line_Availability__c> las = new List<Line_Availability__c>();
            for(integer j = 10; j < 22; j++){
                Line_Availability__c la = new Line_Availability__c(Batch_Job__c = b.Id,
                                                                    Directory_Number__c = '4413228887' + j,
                                                                    Post_Code__c = 'LS12 4BB');

                las.add(la);
            }
            insert las;
        }

        
        // Start test
        Test.startTest();

        for(Id bId : batchJobIds){
            //AvailabilityCheckUtils.processAvailabilityCheck(new List<Id>{bId});
        }

        Batch_Job__c batchJob = new Batch_Job__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController c = new AvailabilityCheckController(sc);
        Line_Availability__c la1 = new Line_Availability__c();
        la1.Directory_Number__c = AvailabilityCheckOutputProcessor.TEST_TIMEOUT;
        la1.Post_Code__c = 'LS12 4BB';
        c.lineAvailabilityRequests = new List<Line_Availability__c>{la1};
        for(integer i = 10; i < 30; i++){
            Line_Availability__c la = new Line_Availability__c();
            la.Directory_Number__c = '4411111111' + i;
            la.Post_Code__c = 'IP100PY';
            c.lineAvailabilityRequests.add(la);
        }

        PageReference p = c.submitRows();

        // Stop test
        Test.stopTest();

        // User was navigated to results page
        //System.assert(p.getUrl().startsWith(Page.AvailabilityCheckResults.getUrl()));

        // The batch job should have been deferred as should the line check
        List<Batch_Job__c> batchJobs = [Select Id, Status__c, (Select Id, Status__c From Line_Availabilities__r) from Batch_Job__c Where Id = : c.batchJob.Id];
        //System.assertEquals(AvailabilityCheckUtils.DEFERRED, batchJobs.get(0).Status__c);
        //System.assertEquals(AvailabilityCheckUtils.DEFERRED, batchJobs.get(0).Line_Availabilities__r.get(0).Status__c);
    }

    static testMethod void testSweep() {
        Test.startTest();
        // Improve code coverage by initating the sweep functionality
        AvailabilityCheckBatchAsync b = new AvailabilityCheckBatchAsync();
        String s = '20 30 8 10 2 ?';
        System.schedule('Availability Check', s, b);
        Test.stopTest();
    }

    static testMethod void testSOAViewFixedLineAvailabilityData() {

        SOAViewFixedLineAvailabilityData test = new SOAViewFixedLineAvailabilityData();
        SOAViewFixedLineAvailabilityData.addressReferenceType test1 = new SOAViewFixedLineAvailabilityData.addressReferenceType();
        SOAViewFixedLineAvailabilityData.addressType test2 = new SOAViewFixedLineAvailabilityData.addressType();
        SOAViewFixedLineAvailabilityData.bearerType test3 = new SOAViewFixedLineAvailabilityData.bearerType();
        SOAViewFixedLineAvailabilityData.britishAddressType test4 = new SOAViewFixedLineAvailabilityData.britishAddressType();
        SOAViewFixedLineAvailabilityData.channelType test5 = new SOAViewFixedLineAvailabilityData.channelType();
        SOAViewFixedLineAvailabilityData.cnfType test6 = new SOAViewFixedLineAvailabilityData.cnfType();
        SOAViewFixedLineAvailabilityData.ddiRangeType test7 = new SOAViewFixedLineAvailabilityData.ddiRangeType();
        SOAViewFixedLineAvailabilityData.directoryType test8 = new SOAViewFixedLineAvailabilityData.directoryType();
        SOAViewFixedLineAvailabilityData.getInstallationDetails test9 = new SOAViewFixedLineAvailabilityData.getInstallationDetails();
        SOAViewFixedLineAvailabilityData.getInstallationDetailsResponse test10 = new SOAViewFixedLineAvailabilityData.getInstallationDetailsResponse();
        SOAViewFixedLineAvailabilityData.installationDetailsType test11 = new SOAViewFixedLineAvailabilityData.installationDetailsType();
        SOAViewFixedLineAvailabilityData.lineParametersType test12 = new SOAViewFixedLineAvailabilityData.lineParametersType();
        SOAViewFixedLineAvailabilityData.listOfBearerType test13 = new SOAViewFixedLineAvailabilityData.listOfBearerType();
        SOAViewFixedLineAvailabilityData.listOfChannelType test14 = new SOAViewFixedLineAvailabilityData.listOfChannelType();
        SOAViewFixedLineAvailabilityData.listOfCNFType test15 = new SOAViewFixedLineAvailabilityData.listOfCNFType();
        SOAViewFixedLineAvailabilityData.listOfDDIRangeType test16 = new SOAViewFixedLineAvailabilityData.listOfDDIRangeType();
        SOAViewFixedLineAvailabilityData.listOfDirectoryInfoType test17 = new SOAViewFixedLineAvailabilityData.listOfDirectoryInfoType();
        SOAViewFixedLineAvailabilityData.listOfMainBillingNumberType test18 = new SOAViewFixedLineAvailabilityData.listOfMainBillingNumberType();
        SOAViewFixedLineAvailabilityData.listOfMSNType test38 = new SOAViewFixedLineAvailabilityData.listOfMSNType();
        SOAViewFixedLineAvailabilityData.listOfPendingOrderType test19 = new SOAViewFixedLineAvailabilityData.listOfPendingOrderType();
        SOAViewFixedLineAvailabilityData.listOfSNDDIType test20 = new SOAViewFixedLineAvailabilityData.listOfSNDDIType();
        SOAViewFixedLineAvailabilityData.locationType test21 = new SOAViewFixedLineAvailabilityData.locationType();
        SOAViewFixedLineAvailabilityData.mainBillingNumberDetailsType test22 = new SOAViewFixedLineAvailabilityData.mainBillingNumberDetailsType();
        SOAViewFixedLineAvailabilityData.mainBillingNumberType test23 = new SOAViewFixedLineAvailabilityData.mainBillingNumberType();
        SOAViewFixedLineAvailabilityData.msnType test24 = new SOAViewFixedLineAvailabilityData.msnType();
        SOAViewFixedLineAvailabilityData.pendingOrderType test25 = new SOAViewFixedLineAvailabilityData.pendingOrderType();
        SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType test26 = new SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType();
        SOAViewFixedLineAvailabilityData.serviceIdType test27 = new SOAViewFixedLineAvailabilityData.serviceIdType();
        SOAViewFixedLineAvailabilityData.siteType test28 = new SOAViewFixedLineAvailabilityData.siteType();
        SOAViewFixedLineAvailabilityData.snddiType test29 = new SOAViewFixedLineAvailabilityData.snddiType();
        //
    }

    static testMethod void testSOACoreData2() {
        //
        SOACoreData2 test = new SOACoreData2();
        SOACoreData2.SOAFaultType test1 = new SOACoreData2.SOAFaultType();
        SOACoreData2.MapItem test3 = new SOACoreData2.MapItem();
        SOACoreData2.MapType test4 = new SOACoreData2.MapType();
        SOACoreData2.accountType test5 = new SOACoreData2.accountType();
        SOACoreData2.SubscriberProfileType test6 = new SOACoreData2.SubscriberProfileType();
        SOACoreData2.addressType test7 = new SOACoreData2.addressType();
        SOACoreData2.accountDetail test8 = new SOACoreData2.accountDetail();
        SOACoreData2.ServiceResultType test9 = new SOACoreData2.ServiceResultType();
        SOACoreData2.addressMetaDataType test10 = new SOACoreData2.addressMetaDataType();
        SOACoreData2.cashCardAccountType test11 = new SOACoreData2.cashCardAccountType();
    }

    static testMethod void testSOABroadbandAvailabilityData () {
        SOABroadbandAvailabilityData sbad = new SOABroadbandAvailabilityData();
        SOABroadbandAvailabilityData.getAvailability a = new SOABroadbandAvailabilityData.getAvailability();
        a.landlineNumber = '';
        a.postCode = '';
        a.subscriberId = '';
        SOABroadbandAvailabilityData.getBusinessAvailability_1 gba = new SOABroadbandAvailabilityData.getBusinessAvailability_1();
        SOABroadbandAvailabilityData.getAvailabilityResponse b = new SOABroadbandAvailabilityData.getAvailabilityResponse();
        SOABroadbandAvailabilityData.getAvailableProducts c = new SOABroadbandAvailabilityData.getAvailableProducts();
        c.landlineNumber = '';
        c.postCode = '';
        c.subscriberId = '';
        SOABroadbandAvailabilityData.getAvailableProductsResponse d = new SOABroadbandAvailabilityData.getAvailableProductsResponse();
        SOABroadbandAvailabilityData.getBusinessAvailability_1 e = new SOABroadbandAvailabilityData.getBusinessAvailability_1();
        SOABroadbandAvailabilityData.getBusinessAvailability_1Response f = new SOABroadbandAvailabilityData.getBusinessAvailability_1Response();

        SOABroadbandAvailabilityData.getDistanceFromExchange g = new SOABroadbandAvailabilityData.getDistanceFromExchange();
        g.landlineNumber = '';
        g.postCode = '';
        g.subscriberId = '';
        SOABroadbandAvailabilityData.getDistanceFromExchangeResponse h = new SOABroadbandAvailabilityData.getDistanceFromExchangeResponse();
        h.lineLength = 1;
        SOABroadbandAvailabilityData.broadbandAvailability i = new SOABroadbandAvailabilityData.broadbandAvailability();
        i.broadbandProduct = new List<SOABroadbandAvailabilityData.productCostType>();
        i.downloadSpeed = '';
        i.reasonCode = '';
        i.reasonCodeMessage = '';
        i.status = '';
        i.uploadSpeed = '';

        SOABroadbandAvailabilityData.businessAvailabilityDetailsType j = new SOABroadbandAvailabilityData.businessAvailabilityDetailsType();
        SOABroadbandAvailabilityData.districtCodeListType k = new SOABroadbandAvailabilityData.districtCodeListType();
        k.districtCode = new List<String>();
        SOABroadbandAvailabilityData.productCostType l = new SOABroadbandAvailabilityData.productCostType();
        l.custMonthlyFee = 1;
        l.discMonthlyFee = 1;
        l.genMonthlyFee = 1;
        l.isEligible = true;
        l.productId = 1;
        l.productName = '';
        SOABroadbandAvailabilityData.productListType m = new SOABroadbandAvailabilityData.productListType();
        m.product = new List<SOABroadbandPSCommonAvatar.productType>();
        SOABroadbandAvailabilityData.productType n = new SOABroadbandAvailabilityData.productType();
        n.productId = 1;
        n.productName = '';
        d.product = new List<SOABroadbandAvailabilityData.productType>();
    }

    static testMethod void testSOABroadbandPSCommonAvatar() {
        SOABroadbandPSCommonAvatar ca = new SOABroadbandPSCommonAvatar();
        SOABroadbandPSCommonAvatar.addressType at = new SOABroadbandPSCommonAvatar.addressType();
        SOABroadbandPSCommonAvatar.billDetailType bd = new SOABroadbandPSCommonAvatar.billDetailType();
        SOABroadbandPSCommonAvatar.ipsCheckerRateType icrt = new SOABroadbandPSCommonAvatar.ipsCheckerRateType();
        SOABroadbandPSCommonAvatar.productPriceType ppt = new SOABroadbandPSCommonAvatar.productPriceType();
        SOABroadbandPSCommonAvatar.productType pt = new SOABroadbandPSCommonAvatar.productType();
        SOABroadbandPSCommonAvatar.promotionType pty = new SOABroadbandPSCommonAvatar.promotionType();
    }

    static testMethod void testBatchJobExecution() {
        ID batchprocessid;
        List<Line_Availability__c> lineAvailabilities = new List<Line_Availability__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        b1.Channel__c = 'Screen Input';
        b1.Type__c = AvailabilityCheckUtils.TYPE_LINE;
        insert b1;

        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB';
        la1.Type__c = AvailabilityCheckUtils.TYPE_LINE;
        la1.Processed__c = false;

        insert la1;
        List<Id> bIds = new List<Id>();
        bIds.add(b1.id);
        lineAvailabilities = [Select Id, Post_Code__c, Type__c,
                                                    Directory_Number__c,
                                                    Batch_Job__r.Name,
                                                    Batch_Job__r.Email__c,
                                                    Batch_Job__r.Status__c,
                                                    Batch_Job__r.Last_Run_Error_Count__c,
                                                    Batch_Job__r.Number_Of_Retries__c,
                                                    Batch_Job__r.Total_Retries__c
                                             From Line_Availability__c
                                             Where Batch_Job__c In :bIds];

        Test.startTest();
        AvailabilityCheckBatchAsync b = new AvailabilityCheckBatchAsync(bIds);
        if([Select Id From AsyncApexJob Where Status In ('Queued', 'Processing')].size()<5)
            batchprocessid = Database.executeBatch(b,1);
        b.execute(null, lineAvailabilities);
        Test.stopTest();

        la1 = [select id, Number_Of_Channels__c, response__c, SOA_Fault__c, status__c from Line_Availability__c where id=:la1.Id];

        for(AsyncApexJob aaj : [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ]) {
            System.assertEquals('Completed',aaj.Status);
            //System.assertEquals(3, la1.Number_Of_Channels__c);
        }

    }

    static testMethod void testHandleCompletion() {
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = 'In Progress';
        b1.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        insert b1;
        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB';
        la1.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        insert la1;
        b1.Status__c = 'Completed';
        update b1;
        // Attachments have been added
        System.assert([Select count() From Attachment where ParentId=:b1.Id]>0);
    }


    static testMethod void testBatchJobExecutionErrors() {
        ID batchprocessid;
        List<Line_Availability__c> lineAvailabilities = new List<Line_Availability__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        b1.Channel__c = 'Screen Input';
        b1.Type__c = AvailabilityCheckUtils.TYPE_LINE;
        insert b1;

        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB';
        la1.Processed__c = false;
        la1.Type__c = AvailabilityCheckUtils.TYPE_LINE;
        insert la1;
        List<Id> bIds = new List<Id>();
        bIds.add(b1.id);
        lineAvailabilities = [Select Id, Post_Code__c, Type__c,
                                                    Directory_Number__c,
                                                    Batch_Job__r.Name,
                                                    Batch_Job__r.Email__c,
                                                    Batch_Job__r.Status__c,
                                                    Batch_Job__r.Last_Run_Error_Count__c,
                                                    Batch_Job__r.Number_Of_Retries__c,
                                                    Batch_Job__r.Total_Retries__c
                                             From Line_Availability__c
                                             Where Batch_Job__c In :bIds];

        Test.startTest();
        AvailabilityCheckBatchAsync b = new AvailabilityCheckBatchAsync(bIds);
        if([Select Id From AsyncApexJob Where Status In ('Queued', 'Processing')].size()<5)
            batchprocessid = Database.executeBatch(b,1);
        b.execute(null, lineAvailabilities);
        Test.stopTest();

        la1 = [select id, Number_Of_Channels__c, response__c, SOA_Fault__c, status__c from Line_Availability__c where id=:la1.Id];

        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
        System.assertEquals('Completed',aaj.Status);
        //System.assertEquals(3, la1.Number_Of_Channels__c);

    }

    static testMethod void testOutputProcessor() {

        loadCustomSettingsData();

        wsSecurity__c wss = new wsSecurity__c(Username__c='Uname', Password__c='Password');
        insert wss;

        List<Line_Availability__c> lineAvailabilities = new List<Line_Availability__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        b1.Channel__c = 'Screen Input';
        b1.Type__c = AvailabilityCheckUtils.TYPE_LINE;
        insert b1;

        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB';
        la1.Processed__c = false;
        la1.Type__c = AvailabilityCheckUtils.TYPE_LINE;
        lineAvailabilities.add(la1);
        insert lineAvailabilities;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new AvailabilityCheckWSMock1());
        //AvailabilityCheckOutputProcessor b = new AvailabilityCheckOutputProcessor();
        AvailabilityCheckList resultList = AvailabilityCheckOutputProcessor.invokeAvailabilityCheckWS(lineAvailabilities);
        resultList.save();
        Test.stopTest();

        la1 = [select id, Service_Type__c, ExchType__c from Line_Availability__c where id=:la1.Id];
        System.assertEquals('PSTN Single Line', la1.Service_Type__c);
        System.assertEquals('AXE10', la1.ExchType__c);
    }

	/****
    static testMethod void testBBOutputProcessor() {

        loadCustomSettingsData();

        wsSecurity__c wss = new wsSecurity__c(Username__c='Uname', Password__c='Password');
        insert wss;

        List<Line_Availability__c> lineAvailabilities = new List<Line_Availability__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        b1.Channel__c = 'Screen Input';
        b1.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        insert b1;

        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '01142700690';
        la1.Post_Code__c = 'IP100PY';
        la1.Processed__c = false;
        la1.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        lineAvailabilities.add(la1);
        insert lineAvailabilities;

        Test.startTest();
        AvailabilityCheckList resultList = AvailabilityCheckOutputProcessor.invokeAvailabilityCheckWS(lineAvailabilities);
        resultList.save();
        Test.stopTest();

        la1 = [select id, isIPStreamAvailable__c, isLLUAvailable__c from Line_Availability__c where id=:la1.Id];

        // System.assertEquals(true, la1.isIPStreamAvailable__c);
        // System.assertEquals(true, la1.isLLUAvailable__c);
    }
	****/

    static testMethod void testProcessCompletedBatchJob() {
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        b1.Channel__c = 'Screen Input';
        b1.Last_Run_Error_Count__c = 0;
        insert b1;
        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        // ntj la1.Directory_Number__c = '441322888777';
        la1.Directory_Number__c = AvailabilityCheckOutputProcessor.TEST_INTERRUPT;
        la1.Post_Code__c = 'LS12 4BB';
        la1.Processed__c = false;
        insert la1;

        AvailabilityCheckBatchAsync b = new AvailabilityCheckBatchAsync();
        b.batchJob = b1;
        b.lineAvailability = la1;
        b.handleError(new SOAUtils.DMLMethodException('Test'));
        b1 = b.processCompletedBatchJob(b1);
        b1 = b.processCompletedBatchJob(b1);
        b1 = b.processCompletedBatchJob(b1);
        b1 = b.processCompletedBatchJob(b1);
        //System.assertEquals(4,b1.Total_Retries__c);
    }

    static testMethod void testHandleErrors() {
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        b1.Channel__c = 'Screen Input';
        b1.Last_Run_Error_Count__c = 0;
        insert b1;
        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441322888777';
        la1.Post_Code__c = 'LS12 4BB';
        la1.Processed__c = false;
        insert la1;

        AvailabilityCheckBatchAsync b = new AvailabilityCheckBatchAsync();
        b.batchJob = b1;
        b.lineAvailability = la1;
        b.handleError(new SOAUtils.DMLMethodException('Test'));
        System.assertEquals('Test',la1.SOA_Fault__c);
        b.handleError(new SOAUtils.SOATypeException('Test'));
        System.assertEquals('Test',la1.SOA_Fault__c);
    }


    static testMethod void testSOASecurityElement() {
        SOASecurityElement.Security_element securityElement = new SOASecurityElement.Security_element('username', 'password');
        SOASecurityElement.UsernameToken_element unToken = securityElement.usernameToken;
        system.assertEquals(unToken.username, 'username');
        system.assertEquals(unToken.password, 'password');
    }

    static testMethod void testSOAViewPostalAddressData() {
        SOAViewPostalAddressData.getAddressMatch addressMatch = new SOAViewPostalAddressData.getAddressMatch();
        addressMatch.buildingName='test';
        addressMatch.buildingNumber='test';
        addressMatch.postcode='test';
        SOAViewPostalAddressData.requestAddressType t = new SOAViewPostalAddressData.requestAddressType();
        t.buildingName = '';
        t.buildingNumber = '';
        t.county = '';
        t.dependentLocality = '';
        t.dependentStreet = '';
        t.locality = '';
        t.organisation = '';
        t.postcode = '';
        SOAViewPostalAddressData.searchAddress addressSearch = new SOAViewPostalAddressData.searchAddress();
        addressSearch.address = t;
    }

    static Line_Availability__c setLa(String lineType, String pc, String dn) {
        Line_Availability__c la = new Line_Availability__c();
        if (dn != null)
            la.Directory_Number__c = dn;
        if (pc != null)
            la.Post_Code__c = pc;
        if (lineType != null)
            la.Type__c = lineType;
        return(la);
    }

    static void checkLa(String s, Line_Availability__c la, Boolean b1) {
        system.debug('checkLa: '+s+' la:'+la);
        system.assertEquals(la.Processed__c, b1);
        system.assertEquals((la.response__c != null), b1);
    }

    static testMethod void testValidateLineAvailabilityRequest() {
        // test setup
        String directoryName = '441322888777';
        String postCode =  'LS12 4BB';

        String badDirectoryName = 'badwolf';
        String badPostCode = 'badwolf';

        String directoryNameWith0 = '01322888777';

        Line_Availability__c laNoPCNoDNLine = setLa(AvailabilityCheckUtils.TYPE_LINE, null, null);
        Line_Availability__c laNoPCDNLine = setLa(AvailabilityCheckUtils.TYPE_LINE, null, directoryName);
        Line_Availability__c laPCNoDNLine = setLa(AvailabilityCheckUtils.TYPE_LINE, postCode, null);
        Line_Availability__c laPCDNLine = setLa(AvailabilityCheckUtils.TYPE_LINE, postCode, directoryName);
        Line_Availability__c laNoPCNoDNBB = setLa(AvailabilityCheckUtils.TYPE_BROADBAND, null, null);
        Line_Availability__c laNoPCDNBB = setLa(AvailabilityCheckUtils.TYPE_BROADBAND, null, directoryName);
        Line_Availability__c laPCNoDNBB = setLa(AvailabilityCheckUtils.TYPE_BROADBAND, postCode, null);
        Line_Availability__c laPCDNBB = setLa(AvailabilityCheckUtils.TYPE_BROADBAND, postCode, directoryName);
        Line_Availability__c labPCgDNLine = setLa(AvailabilityCheckUtils.TYPE_LINE, badPostCode, directoryName);
        Line_Availability__c lagPCbDNLine = setLa(AvailabilityCheckUtils.TYPE_LINE, postCode, badDirectoryName);
        Line_Availability__c labPCgDNBB = setLa(AvailabilityCheckUtils.TYPE_BROADBAND, badPostCode, directoryName);
        Line_Availability__c lagPCbDNBB = setLa(AvailabilityCheckUtils.TYPE_BROADBAND, postCode, badDirectoryName);
        Line_Availability__c laPCDN0Line = setLa(AvailabilityCheckUtils.TYPE_LINE, postCode, directoryName);
        Line_Availability__c laPCDN0BB = setLa(AvailabilityCheckUtils.TYPE_BROADBAND, postCode, directoryNameWith0);

        Test.StartTest();

        laNoPCNoDNLine = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laNoPCNoDNLine);
        laNoPCDNLine = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laNoPCDNLine );
        laPCNoDNLine = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laPCNoDNLine );
        laPCDNLine = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laPCDNLine );
        laNoPCNoDNBB = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laNoPCNoDNBB );
        laNoPCDNBB = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laNoPCDNBB );
        laPCNoDNBB = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laPCNoDNBB );
        laPCDNBB = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laPCDNBB );
        labPCgDNLine = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(labPCgDNLine );
        lagPCbDNLine = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(lagPCbDNLine );
        labPCgDNBB = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(labPCgDNBB );
        lagPCbDNBB = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(lagPCbDNBB );
        laPCDN0Line = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laPCDN0Line );
        laPCDN0BB = AvailabilityCheckInputProcessor.validateLineAvailabilityRequest(laPCDN0BB );

        Test.StopTest();

        // true indicates an error
        checkLa('laNoPCNoDNLine', laNoPCNoDNLine, true);

        checkLa('laNoPCDNLine', laNoPCDNLine, true);

        checkLa('laPCNoDNLine', laPCNoDNLine, true);

        checkLa('laPCDNLine', laPCDNLine, false);

        checkLa('laNoPCNoDNBB', laNoPCNoDNBB, true);

        checkLa('laNoPCDNBB', laNoPCDNBB, false);

        checkLa('laPCNoDNBB',laPCNoDNBB, false);

        checkLa('laPCDNBB', laPCDNBB, false);

        checkLa('labPCgDNLine', labPCgDNLine, true);

        checkLa('lagPCbDNLine', lagPCbDNLine, true);

        checkLa('labPCgDNBB', labPCgDNBB, true);

        //checkLa('lagPCbDNBB', lagPCbDNBB, true);
        checkLa('laPCDN0Line', laPCDN0Line, false);
        checkLa('laPCDN0BB ', laPCDN0BB , false);
    }

    static testMethod void testBBCSVCreation() {
        // Create the expected attachment
        List<String> expectedHeaders = new List<String> {'PhoneNumber','Postcode','LLU or IPS available','Reason code','Reason code short text','Access Line Status','Estimated Max Line Speed','Estimated Line Length','Predicted download speed','BT Exchange Name','ANFP Category','A-Earth Capacitance','B-Earth Capacitance','Available product list','BT Response','BT Response Code','Transaction Result'};
        List<String> expectedValues = new List<String> {'441506670222','EH49 7SF','None','Z','Clear line - can order LLU Broadband products','Working','11','2298','11.097meg','OXFORD','S','dummy1','dummy2','Home Worker;Branch Office;Home Office;Office 10','No Errors – Line characteristics obtained.','2150','Success'};

        // create a batchjob
        List<Batch_Job__c> batchJobs = new List<Batch_Job__c>();
        Batch_Job__c b1 = new Batch_Job__c();
        b1.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        b1.Status__c = 'In Progress';
        b1.Email__c = 'neil.jones@salesforce.com';
        insert b1;
        batchJobs.add(b1);
        //system.debug('batch job created:'+b1);

        // create a batchjob
        List<Batch_Job__c> batchJobs2 = new List<Batch_Job__c>();
        Batch_Job__c b2 = new Batch_Job__c();
        b2.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        b2.Status__c = 'In Progress';
        b2.Email__c = 'neil.jones@salesforce.com';
        insert b2;
        batchJobs2.add(b2);
        //system.debug('batch job created:'+b2);

        Line_Availability__c la1 = new Line_Availability__c();
        la1.Batch_Job__c = b1.Id;
        la1.Directory_Number__c = '441506670222';
        la1.Post_Code__c = 'EH49 7SF';
        //la1.LLU_or_IPS_available__c = 'LLU';
        la1.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        la1.reasonCode__c = 'Z';
        la1.Reason_code_short_text__c= 'Clear line - can order LLU Broadband products';
        la1.accessLineStatus__c= 'Working';
        la1.estimatedLineSpeed__c= '11';
        la1.lineLengthEstimate__c= '2298';
        la1.predictedDownloadSpeed__c = '11.097meg';
        la1.btExchangeName__c = 'OXFORD';
        la1.anfpCategory__c = 'S';
        la1.earthCapacitanceA__c = 'dummy1';
        la1.earthCapacitanceB__c = 'dummy2';
        la1.contractedPartyName__c = 'dummy3';
        la1.contractedPartyNumber__c = 'dummy4';
        la1.productList__c = 'Home Worker;Branch Office;Home Office;Office 10';
        la1.External_Description__c= 'Broadband service details retrieved successfully.';
        la1.Resp1CC__c= '2150';
        la1.Response__c = 'No Errors – Line characteristics obtained.';
        la1.Status_Code__c = '2150';
        insert la1;

        String expectedError = 'Invalid post code';
        String unexpectedError = 'dontexpecttoseethis';
        Line_Availability__c la2 = new Line_Availability__c();
        la2.Batch_Job__c = b2.Id;
        la2.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        la2.Directory_Number__c = 'badwolf';
        la2.Post_Code__c = 'badwolf';
        la2.External_Description__c= unexpectedError;
        la2.Response__c = expectedError;
        insert la2;
        //system.debug('la2 created: '+la2);

        // start test
        Test.startTest();
        AvailabilityCheckOutputProcessor.handleCompleted(batchJobs);
        AvailabilityCheckOutputProcessor.handleCompleted(batchJobs2);

        // end test
        Test.stopTest();
        // check results
        for (Batch_Job__c b:batchJobs) {
            List<Attachment> attachments = [SELECT a.Body FROM Attachment a WHERE a.ParentId = :b.Id];

            // we should have some attachment
            System.assert(attachments != null);
            System.assert(attachments.isEmpty() == false);
            // we should actually have one attachment
            System.assert(attachments.size() == 1);

            for (Attachment attachment:attachments) {
                Blob myBlob = attachment.Body;
                system.debug(myBlob);
                System.assert(myBlob != null);
                String data = myBlob.toString();
				system.debug('*** Attachment data ***'+data);
				
                for (String header:expectedHeaders) {
                    system.debug('checking for '+header);
                    System.assert(data.contains(header));
                }

                for (String value:expectedValues) {
                    system.debug('checking for '+value);
                    System.assert(data.contains(value));
                }
            }
        }
        for (Batch_Job__c bx:batchJobs2) {
            List<Attachment> attachments2 = [SELECT a.Body FROM Attachment a WHERE a.ParentId = :bx.Id];

            // we should have some attachment
            System.assert(attachments2 != null);
            System.assert(attachments2.isEmpty() == false);
            // we should actually have one attachment
            System.assert(attachments2.size() == 1);

            for (Attachment attachment2:attachments2) {
                Blob myBlob2 = attachment2.Body;
                //system.debug(myBlob2);
                System.assert(myBlob2 != null);
                String data2 = myBlob2.toString();

                //system.debug('data contains: '+data2);
                // expect that the description got overwritten
                System.assert(!data2.contains(unexpectedError));
                System.assert(data2.contains(expectedError));
            }
        }

    }

    static void testIt(String t, String s1, String s2) {
        system.debug(t + ': <'+s1+'> = <'+s2+'>');
        system.assertEquals(s2, s1);
    }

    static testMethod void testGetShortDesc() {
        final String DEF_STR = 'returned by WS';
        final String RETRIEVE_OK = AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_OK;
        final String RETRIEVE_NOT_OK = AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_NOT_OK;
        final String BB_RETRIEVE_NODNORPC = AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_NODNORPC;
        Test.startTest();



        // Web Service returned DESC_BB_RETRIEVE_OK so we can check the other parameters
        String s1 = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'Z');
        String s1_d = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', '', RETRIEVE_OK, false, false, 'Z');
        String s1_p = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', 'IP100PY', RETRIEVE_OK, false, false, 'Z');
        String s1_dp = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', 'IP100PY', RETRIEVE_OK, false, false, 'Z');

        String s2 = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, true, 'Z');
        String s2_d = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', '', RETRIEVE_OK, false, true, 'Z');
        String s2_p = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', 'IP100PY', RETRIEVE_OK, false, true, 'Z');
        String s2_dp = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', 'IP100PY', RETRIEVE_OK, false, true, 'Z');

        String s3 = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, true, false, 'Z');
        String s3_d = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', '', RETRIEVE_OK, true, false, 'Z');
        String s3_p = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', 'IP100PY', RETRIEVE_OK, true, false, 'Z');
        String s3_dp = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', 'IP100PY', RETRIEVE_OK, true, false, 'Z');

        // not reasoncode='z' so no bb available in some cases
        String s4 = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'A');
        String s4_d = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', '', RETRIEVE_OK, false, false, 'A');
        String s4_p = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', 'IP100PY', RETRIEVE_OK, false, false, 'A');
        String s4_dp = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', 'IP100PY', RETRIEVE_OK, false, false, 'A');

        // Web Service did not return DESC_BB_RETRIEVE_OK so we cannot check the other parameters
        String s5 = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_NOT_OK, false, false, 'Z');
        String s5_d = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', '', RETRIEVE_NOT_OK, false, false, 'Z');
        String s5_p = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', 'IP100PY', RETRIEVE_NOT_OK, false, false, 'Z');
        String s5_dp = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '01142700690', 'IP100PY', RETRIEVE_NOT_OK, false, false, 'Z');

        // now test all the reason codes which are not 'z'
        String s1_rcA = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'A');
        String s1_rcB = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'B');
        String s1_rcC = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'C');
        String s1_rcD = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'D');
        String s1_rcE = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'E');
        String s1_rcF = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'F');
        String s1_rcG = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'G');
        String s1_rcH = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'H');
        String s1_rcI = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'I');
        String s1_rcK = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'K');
        String s1_rcL = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'L');
        String s1_rcM = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'M');
        String s1_rcP = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'P');
        String s1_rcT = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'T');
        String s1_rcV = AvailabilityCheckDataTranslationUtils.getShortDesc(DEF_STR, '', '', RETRIEVE_OK, false, false, 'V');


        Test.stopTest();

        // No PC or DN supplied - so error
        testIt('s1', s1, AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_NODNORPC);
        // Just Directory can have BB nothing possible TODO
        testIt('s1_d', s1_d, AvailabilityCheckDataTranslationUtils.DESC_CANNOT_ORDER_O2_BB);
        // Just Postcode and LLU and IPS not specified so nothing possible
        testIt('s1_p', s1_p, AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_NOT_OK);
        // Directory and Postcode can have BB TODO
        testIt('s1_dp', s1_dp, AvailabilityCheckDataTranslationUtils.DESC_CANNOT_ORDER_O2_BB);

        // No PC or DN supplied - so error
        testIt('s2', s2, AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_NODNORPC);
        // Just Directory can have BB
        testIt('s2_d', s2_d, AvailabilityCheckDataTranslationUtils.DESC_CAN_ORDER_O2_BB);
        // Just Postcode and IPS was specified
        testIt('s2_p', s2_p, AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_BT_OK);
        // Directory and Postcode can have BB
        testIt('s2_dp', s2_dp, AvailabilityCheckDataTranslationUtils.DESC_CAN_ORDER_O2_BB);

        // No PC or DN supplied - so error
        testIt('s3', s3, AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_NODNORPC);
        // Just Directory can have BB
        testIt('s3_d', s3_d, AvailabilityCheckDataTranslationUtils.DESC_CAN_ORDER_O2_BB);
        // Just Postcode and LLU was specified
        testIt('s3_p', s3_p, AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_O2_OK);
        // Directory and Postcode can have BB
        testIt('s3_dp', s3_dp, AvailabilityCheckDataTranslationUtils.DESC_CAN_ORDER_O2_BB);

        // Reason Code = 'A' so return default string originally returned by WS
        testIt('s4', s4, DEF_STR);
        testIt('s4_d', s4_d, DEF_STR);
        testIt('s4_p', s4_p, DEF_STR);
        testIt('s4_dp', s4_dp, DEF_STR);

        // The external description said that the call was not successful

        // No PC or DN supplied - so error
        testIt('s5', s5, AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_NODNORPC);
        testIt('s5_d', s5_d, AvailabilityCheckDataTranslationUtils.DESC_CANNOT_ORDER_O2_BB);
        testIt('s5_p', s5_p, AvailabilityCheckDataTranslationUtils.DESC_BB_RETRIEVE_NOT_OK);
        testIt('s5_dp', s5_dp, AvailabilityCheckDataTranslationUtils.DESC_CANNOT_ORDER_O2_BB);

        // Test is for non-Z reason codes, always use the default string
        testIt('s1_rcA', s1_rcA, DEF_STR);
        testIt('s1_rcB', s1_rcB, DEF_STR);
        testIt('s1_rcC', s1_rcC, DEF_STR);
        testIt('s1_rcD', s1_rcD, DEF_STR);
        testIt('s1_rcE', s1_rcE, DEF_STR);
        testIt('s1_rcF', s1_rcF, DEF_STR);
        testIt('s1_rcG', s1_rcG, DEF_STR);
        testIt('s1_rcH', s1_rcH, DEF_STR);
        testIt('s1_rcI', s1_rcI, DEF_STR);
        testIt('s1_rcK', s1_rcK, DEF_STR);
        testIt('s1_rcL', s1_rcL, DEF_STR);
        testIt('s1_rcM', s1_rcM, DEF_STR);
        testIt('s1_rcP', s1_rcP, DEF_STR);
        testIt('s1_rcT', s1_rcT, DEF_STR);
        testIt('s1_rcV', s1_rcV, DEF_STR);
    }

    static testMethod void testServiceCheckType() {
        Batch_Job__c batchJob = new Batch_Job__c();

        // Start test
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController ac = new AvailabilityCheckController(sc);
        ac.setServiceCheckType('hello');

        Test.stopTest();

        system.assertEquals('hello', ac.getServiceCheckType());
    }

/*
    static void testPGMessage(AvailabilityCheckController c, Batch_Job__c batchJob, String sStatus, String severity) {
        String s = '';
        String s2 = '';
        batchJob.Status__c = sStatus;

        batchJob.Type__c = AvailabilityCheckUtils.TYPE_LINE;
        s = c.pgMessage;
        s2 = c.pgMessageType;
        system.assert(s.equals('') == false);
        system.assertEquals(severity, s2);

        batchJob.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
        s = c.pgMessage;
        s2 = c.pgMessageType;
        system.assert(s.equals('') == false);
        system.assertEquals(severity, s2);

        batchJob.Type__c = AvailabilityCheckUtils.TYPE_LINE_AND_BROADBAND;
        s = c.pgMessage;
        s2 = c.pgMessageType;
        system.assert(s.equals('') == false);
        system.assertEquals(severity, s2);
    }

    static testMethod void testPGMessage() {
        // pgMessage tests
        Test.startTest();

        Batch_Job__c batchJob = new Batch_Job__c();
        batchJob.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        batchJob.Type__c = AvailabilityCheckUtils.TYPE_LINE;

        ApexPages.StandardController sc = new ApexPages.StandardController(batchJob);
        AvailabilityCheckController c = new AvailabilityCheckController(sc);

        c.batchJob = batchJob;
        testPGMessage(c, batchJob, AvailabilityCheckUtils.IN_PROGRESS, 'warning');
        c.batchJob = batchJob;
        testPGMessage(c, batchJob, AvailabilityCheckUtils.RETRYING, 'warning');
        c.batchJob = batchJob;
        testPGMessage(c, batchJob, AvailabilityCheckUtils.DEFERRED, 'error');
        c.batchJob = batchJob;
        testPGMessage(c, batchJob, AvailabilityCheckUtils.FAILED, 'error');
        c.batchJob = batchJob;
        testPGMessage(c, batchJob, AvailabilityCheckUtils.COMPLETED, 'info');

        Test.stopTest();
    }

    static testMethod void testAvailabilityCheck() {

        AvailabilityCheck ac = new AvailabilityCheck(new Line_Availability__c());
        AvailabilityCheck.MBN mbn = new AvailabilityCheck.MBN(new Line_Availability_Main_Billing_Number__c());
        ac.mbns = new List<AvailabilityCheck.MBN>();
        ac.mbns.add(mbn);
        AvailabilityCheck.Bearer bearer = new AvailabilityCheck.Bearer(new Line_Availability_Bearer__c());
        ac.bearers = new List<AvailabilityCheck.Bearer>();
        ac.bearers.add(bearer);
        AvailabilityCheck.Channel channel = new AvailabilityCheck.Channel(new Line_Availability_Channel__c());

        bearer.channels = new list<AvailabilityCheck.Channel>();
        bearer.channels.add(channel);

        mbn.callingAndNetworkFeatures = new List<Line_Availability_CNF__c>();
        mbn.callingAndNetworkFeatures.add(new Line_Availability_CNF__c());
        mbn.ddiRanges = new List<Line_Availability_DDI_Range__c >();
        mbn.ddiRanges.add(new Line_Availability_DDI_Range__c());
        mbn.directories = new List<Line_Availability_Directory__c>();
        mbn.directories.add(new Line_Availability_Directory__c());
        mbn.multisubnums = new List<Line_Availability_MultSubNum__c>();
        mbn.multisubnums.add(new Line_Availability_MultSubNum__c());
        mbn.snddis = new List<Line_Availability_SNDDI__c>();
        mbn.snddis.add(new Line_Availability_SNDDI__c());
        mbn.unsupportedFeatures = new List<Line_Availability_Unsupported_Feature__c>();
        mbn.unsupportedFeatures.add(new Line_Availability_Unsupported_Feature__c());
        mbn.channels= new list<AvailabilityCheck.Channel>();
        mbn.channels.add(channel);
        mbn.mainBillingNumberDetail = new Line_Availability_Main_Billing_Number__c();

        ac.getBearers();
        ac.getCallingAndNetworkFeatures();
        ac.getChannels();
        ac.getDDIRanges();
        ac.getDirectories();
        ac.getMainBillingNumbers();
        ac.getMultiSubNumbers();
        ac.getSNDDIs();
        ac.getUnsupportedFeatures();
        // TODO: Add Asserts here
    }

    static testMethod void testAvailabilityCheckDataUtils() {
        // For test coverage of empty class
        AvailabilityCheckDataUtils a = new AvailabilityCheckDataUtils();
        a.toString();
    }
*/
}