public with sharing class AvailabilityCheckInputProcessor {

    public static Batch_Job__c processCSVFiles(List<Attachment> attachments, String channel, String emailAddress, String jobType) {
        Batch_Job__c batchJob = createBatchJob(channel, emailAddress, jobType);
        List<Line_Availability__c> lineAvailabilityRequests = parseCSVFiles(batchJob, attachments, jobType);
        // Limit of 10000
        if(lineAvailabilityRequests.size()>10000) {
            throw new SOAUtils.DMLMethodException('A maximum of 10,000 Line Availability Checks can be processed in one batch. Please retry with less than 10,000 records.');
        } else if (lineAvailabilityRequests.size()==0) {
            throw new SOAUtils.DMLMethodException('No Availabilabilty Checks could be found in the file, please check the file format and content. The file should contain one header row and a comma separted list of Directory Number and Post Code with each pair on a new line.');
        }
        for (Line_Availability__c la : lineAvailabilityRequests) {
            la = validateLineAvailabilityRequest(la);
        }
        insert lineAvailabilityRequests;
        update batchJob;
        return batchJob;
    }

    public static Batch_Job__c processLineAvailablityArray(List<Line_Availability__c> lineAvailablityRequests, String channel, String jobType) {
        Batch_Job__c batchJob = createBatchJob(channel, null, jobType);
        /*
        if(jobType==AvailabilityCheckUtils.TYPE_LINE_AND_BROADBAND) {
            List<Line_Availability__c> bbChecks = lineAvailablityRequests.deepClone();
            lineAvailablityRequests = setLineAvailabilityRequests(lineAvailablityRequests, batchJob.Id, AvailabilityCheckUtils.TYPE_LINE);
            bbChecks = setLineAvailabilityRequests(bbChecks, batchJob.Id, AvailabilityCheckUtils.TYPE_BROADBAND);
            lineAvailablityRequests.addAll(bbChecks);
        } else {*/
        lineAvailablityRequests = setLineAvailabilityRequests(lineAvailablityRequests, batchJob.Id, jobType);
        //}
        for (Line_Availability__c la : lineAvailablityRequests) {
            la = validateLineAvailabilityRequest(la);
        }
        insert lineAvailablityRequests;
        update batchJob;
        return batchJob;
    }

    private static List<Line_Availability__c> setLineAvailabilityRequests(List<Line_Availability__c> lineAvailablityRequests, Id batchJobId, String jobType) {

        List<Line_Availability__c> returnLAR = new List<Line_Availability__c>();

        for (Line_Availability__c lineAvailabilityRequest : lineAvailablityRequests) {
            if(jobType==AvailabilityCheckUtils.TYPE_LINE_AND_BROADBAND) {
                // Create a line request
                lineAvailabilityRequest.type__c=AvailabilityCheckUtils.TYPE_LINE;
                lineAvailabilityRequest.Batch_Job__c=batchJobId;
                //formatDirectoryNumber(lineAvailabilityRequest);
                returnLAR.add(lineAvailabilityRequest);
                // Create a BB request
                Line_Availability__c bbrequest = lineAvailabilityRequest.clone(false, true);
                bbrequest.type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
                returnLAR.add(bbrequest);

            } else {
                lineAvailabilityRequest.type__c=jobType;
                lineAvailabilityRequest.Batch_Job__c=batchJobId;
                //formatDirectoryNumber(lineAvailabilityRequest);
                returnLAR.add(lineAvailabilityRequest);
            }
        }
        return returnLAR;
    }

    // This is synchronous version of the operation
    // DML cannot happen before the callout as a transaction cannot remain open
    // This method keeps the state until the callout results is returned then the
    // state is stored. Hence the Batch job is created afterwards along with the results
    public static Batch_Job__c processLineAvailablityImmediate(String directoryNumber, String postCode, String jobType) {
        Line_Availability__c lineAvailabilityRequest = new Line_Availability__c();
        // set line request
        lineAvailabilityRequest.type__c=jobType;
        lineAvailabilityRequest.Directory_Number__c=directoryNumber;
        lineAvailabilityRequest.Post_Code__c=postCode;
        return processLineAvailablityImmediate(lineAvailabilityRequest);
    }

    public static Batch_Job__c processLineAvailablityImmediate(String directoryNumber, String postCode, String jobType, String subscriberResponseCode) {
        Line_Availability__c lineAvailabilityRequest = new Line_Availability__c();
        // set line request
        lineAvailabilityRequest.type__c=jobType;
        lineAvailabilityRequest.Directory_Number__c=directoryNumber;
        lineAvailabilityRequest.Post_Code__c=postCode;
        lineAvailabilityRequest.Subscriber_Response_Code__c = subscriberResponseCode;
        return processLineAvailablityImmediate(lineAvailabilityRequest);
    }

    private static Batch_Job__c processLineAvailablityImmediate(Line_Availability__c lineAvailabilityRequest) {
        Batch_Job__c batchJob = new Batch_Job__c();
        List<Line_Availability__c> lars = new List<Line_Availability__c>();
        // set batch job
        batchJob.User__c = UserInfo.getUserId();
        batchJob.ownerid = UserInfo.getUserId();
        batchJob.type__c = lineAvailabilityRequest.type__c;
        batchJob.Status__c = AvailabilityCheckUtils.COMPLETED;
        batchJob.Channel__c = AvailabilityCheckUtils.ONLINE;
        // set line request
        lineAvailabilityRequest = validateLineAvailabilityRequest(lineAvailabilityRequest);
        lars.add(lineAvailabilityRequest);
        // call service
        AvailabilityCheckList resultList = AvailabilityCheckOutputProcessor.invokeAvailabilityCheckWS(lars);
        // save the batch job and results
        resultList.save(batchJob);
        return batchJob;
    }

    public static Batch_Job__c processLineAvailablityImmediate(List<Line_Availability__c> lineAvailReqs, String channel, String jobType) {
        Batch_Job__c batchJob = new Batch_Job__c();
        List<Line_Availability__c> lars = new List<Line_Availability__c>();
        // set batch job
        batchJob.User__c = UserInfo.getUserId();
        batchJob.ownerid = UserInfo.getUserId();
        batchJob.type__c = jobType;
        batchJob.Status__c = AvailabilityCheckUtils.COMPLETED;
        batchJob.Channel__c = channel;
        // set line request
        for(Line_Availability__c lar : lineAvailReqs) {
        	lar.type__c=jobType;
        	lars.add(validateLineAvailabilityRequest(lar));
        }
        // call service
        AvailabilityCheckList resultList = AvailabilityCheckOutputProcessor.invokeAvailabilityCheckWS(lars);
        // save the batch job and results
        resultList.save(batchJob);
        return batchJob;
    }

    private static Batch_Job__c createBatchJob(String channel, String emailAddress, String jobType) {
        Batch_Job__c batchJob = new Batch_Job__c();
        batchJob.type__c = jobType;
        if (channel.equals(AvailabilityCheckUtils.EMAIL)) {
            batchJob.Email__c = emailAddress;
            for(User u : [Select Id From User Where IsActive=true and email = :emailAddress limit 1]) {
                batchJob.User__c = u.Id;
                batchJob.ownerid = u.Id;
            }
        } else {
            User u = [Select Id, Email From User Where Id = :UserInfo.getUserId()];
            batchJob.User__c = u.Id;
            batchJob.Email__c = u.Email;
            batchJob.ownerid = u.Id;
        }
        batchJob.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
        batchJob.Channel__c = channel;
        insert batchJob;
        return batchJob;
    }

    private static List<SObject> parseCSVFiles(Batch_Job__c batchJob, List<Attachment> attachments, String jobType) {
        // Loop through the CSV attachment list and parse the contents
        List<SObject> lineAvailibilityRequests = new List<SObject>();
        Line_Availability__c lineAvailability;
        for (Attachment attachment : attachments) {
            addAttachmentToBatchJob(batchJob, attachment);
            List<List<String>> records = parseCSVFile(attachment.Body);
            // Loop through the records of the current file and store the columns in the object
            for (List<String> fields : records) {
                // debug
                if(jobType==AvailabilityCheckUtils.TYPE_LINE_AND_BROADBAND) {
                    lineAvailability = new Line_Availability__c();
                    lineAvailability.Batch_Job__c = batchJob.Id;
                    lineAvailability.Directory_Number__c = fields[0];
                    lineAvailability.Post_Code__c = fields[1];
                    lineAvailability.Type__c = AvailabilityCheckUtils.TYPE_LINE;
                    lineAvailability = validateLineAvailabilityRequest(lineAvailability);
                    lineAvailibilityRequests.add(lineAvailability);

                    lineAvailability = new Line_Availability__c();
                    lineAvailability.Batch_Job__c = batchJob.Id;
                    lineAvailability.Directory_Number__c = fields[0];
                    lineAvailability.Post_Code__c = fields[1];
                    lineAvailability.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
                    lineAvailability = validateLineAvailabilityRequest(lineAvailability);
                    lineAvailibilityRequests.add(lineAvailability);
                }
                else {
                    lineAvailability = new Line_Availability__c();
                    lineAvailability.Batch_Job__c = batchJob.Id;
                    lineAvailability.Directory_Number__c = fields[0];
                    lineAvailability.Post_Code__c = fields[1];
                    lineAvailability.Type__c = jobType;
                    lineAvailability = validateLineAvailabilityRequest(lineAvailability);
                    lineAvailibilityRequests.add(lineAvailability);
                }
            }
        }
        return lineAvailibilityRequests;
    }

    public static List<List<String>> parseCSVFile(Blob file) {
        List<List<String>> rowList = new List<List<String>>();
        List<String> rowValues = new List<String>();
        String fileString = file.toString();

        // split the string on carriage returns
        // List<String> tmpRowList = fileString.split('\n', -1);
        // Need to limit the size, if not we get a "Regex too complicated" governor limit
        // 300k allows up to 10k line checks as each line will be less than 30 characters long
        //fileString = fileString.replaceAll('[:;+=-_!$£&()*\'?<>|/\\]','');

        Integer maxSize = 300000 > fileString.length()? fileString.length():300000;
        fileString = fileString.substring(0,maxSize);
        // remove non word characters (0-9, a-z, A-Z, ',' space, newline, carriage return)
        Pattern nonWordChar = Pattern.compile('[^\\w\\s,]');
        fileString = nonWordChar.matcher(fileString).replaceAll('');
        List<String> tmpRowList = fileString.split('\n|\r', -1);

        Boolean firstRow = true;
        for (String row : tmpRowList) {
            if (! firstRow) {
                if (row.length() > 0) {
                    rowValues = row.split(',', -1);
                    rowList.add(rowValues);
                }
            } else {
                firstRow = false;
            }
        }
        return rowList;
    }

    public static void addAttachmentToBatchJob(Batch_Job__c batchJob, Attachment attachment) {
        attachment.ParentId = batchJob.Id;
        insert attachment;
    }

    // TODO: use postCodeEmpty/directoryNameEmpty rather than postCodeOk/directoryNameOk to test whether user supplied non-empty strings
    //       then use postCodeOk/directoryNameEmpty to check for errors.
    /*
    ** line must have (postcode and directory name)
    */
    private static Line_Availability__c processLineRequest(Line_Availability__c  la, Boolean postCodeOk, Boolean directoryNameOk,
                                           Boolean postCodeEmpty, Boolean directoryNameEmpty) {
        if (postCodeOk) {
            if (!directoryNameOk) {
                la.Processed__c = true;
                la.response__c = 'Directory number not valid';
            }
        } else {
            if (!directoryNameOk) {
                la.Processed__c = true;
                la.response__c = 'Directory number and postcode not valid';
            } else {
                la.Processed__c = true;
                la.response__c = 'Postcode not valid';
            }
        }
        return la;
    }

    /*
    ** broadband can have (postcode), (directory name), (postcode and directory name)
    */
    private static Line_Availability__c processBroadbandRequest(Line_Availability__c  la, Boolean postCodeOk, Boolean directoryNameOk,
                                           Boolean postCodeEmpty, Boolean directoryNameEmpty) {
        if (!postCodeOk) {
            if (!directoryNameOk) {
                la.Processed__c = true;
                la.response__c = 'Directory number and postcode not valid';                              
            } else if (!postCodeEmpty) {
                la.Processed__c = true;
                la.response__c = 'Postcode not valid'; 
            }
        }
        return la;
    }


    private static Boolean emptyPostCode(Line_Availability__c  la) {
        Boolean ok = true;

        if ((la.Post_Code__c != null) && (la.Post_Code__c != ''))
            ok = false;

        return(ok);
    }

    private static Boolean emptyDirectoryName(Line_Availability__c  la) {
        Boolean ok = true;

        if ((la.Directory_Number__c != null) && (la.Directory_Number__c != ''))
            ok = false;

        return(ok);
    }

    private static Boolean checkPostCode(Line_Availability__c  la) {
        Boolean ok = false;

        if(la.Post_Code__c!=null){
            // it is valid for a BROADBAND operation to not have a Postcode
            if (SOAUtils.isValidPostcode(la.Post_Code__c) ) {
                ok = true;
            }
        }
        return(ok);
    }

    private static Boolean checkDirectoryName(Line_Availability__c  la) {
        Boolean ok = false;

        if(la.Directory_Number__c!=null) {
            // strip spaces
            String normalisedDN = SOAUtils.cleanDirectoryNumber(la.Directory_Number__c);
        	if (SOAUtils.isValidDirectoryNumber(normalisedDN)) {
            	if (normalisedDN.startsWith('0')) {
                	// add country code which is required by service
                	normalisedDN = '44' + normalisedDN.substring(1);
            	}
            	if(la.Type__c=='Broadband'){
        			normalisedDN = SOAUtils.cleanDirectoryNumberEMLC(normalisedDN);
        		}
            	la.Directory_Number__c = normalisedDN;
            	ok = true;
        	}             
        }
        return(ok);
    }
    
    public static Line_Availability__c validateLineAvailabilityRequest(Line_Availability__c la) {
        Boolean postCodeOk = checkPostCode(la);
        Boolean directoryNameOk = checkDirectoryName(la);
        Boolean isEmptyPostCode = emptyPostCode(la);
        Boolean isEmptyDirectoryName = emptyDirectoryName(la);

        if (la.Type__c == AvailabilityCheckUtils.TYPE_LINE) {
            la = processLineRequest(la, postCodeOk, directoryNameOk, isEmptyPostCode, isEmptyDirectoryName);
        } else {
            la = processBroadbandRequest(la, postCodeOk, directoryNameOk, isEmptyPostCode, isEmptyDirectoryName);
        }
        return la;
    }
    /*
    private static Line_Availability__c validateLineAvailabilityRequest(Line_Availability__c la) {
        // debug
        system.debug('line availability=' + la);
        if(la.Directory_Number__c!=null) {
            system.debug('non null directory');
            // strip spaces
            la.Directory_Number__c = SOAUtils.cleanDirectoryNumber(la.Directory_Number__c);
            if((la.Type__c!=AvailabilityCheckUtils.TYPE_BROADBAND && la.Directory_Number__c!='') &&
                !SOAUtils.isValidDirectoryNumber(la.Directory_Number__c)) {
                system.debug('invalid directory');
                la.Processed__c = true;
                la.response__c = 'Directory number not valid';
            }
            else if (la.Directory_Number__c.startsWith('0')) {
                // add country code which is required by service
                la.Directory_Number__c = '44' + la.Directory_Number__c.substring(1);
            }
        }
        if(la.Post_Code__c!=null){
            system.debug('non null postcode');
            // it is valid for a BROADBAND operation to not have a Postcode
            if ((la.Type__c != AvailabilityCheckUtils.TYPE_BROADBAND) && (! SOAUtils.isValidPostcode(la.Post_Code__c) )) {
                if (la.Processed__c) {
                    system.debug('invalid directory + postcode');
                    la.response__c = 'Directory number and postcode not valid';
                } else {
                    system.debug('invalid postcode');
                    la.Processed__c = true;
                    la.response__c = 'Postcode not valid';
                }
            }
        }
        return la;
    }
    */
}