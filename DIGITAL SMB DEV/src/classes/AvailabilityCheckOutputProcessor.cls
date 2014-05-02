public with sharing class AvailabilityCheckOutputProcessor {
   
    private static final String OUTPUT_FILE_NAME = 'output.csv';

    private static EmailTemplate lineCheckCompletedTemplate;
    private static EmailTemplate lineCheckDeferredTemplate;
    private static EmailTemplate lineCheckFailedTemplate;
    private static boolean hasEmailTemplates = false;
    
    public static final String TEST_TIMEOUT =   '441111111111';
    public static final String TEST_INTERRUPT = '441111111112';
    
    public static void getEmailTemplates() { 
        if(hasEmailTemplates) return;
        for (EmailTemplate e : [Select Id,
                                       DeveloperName
                                From EmailTemplate  
                                Where DeveloperName In (:AvailabilityCheckUtils.LINE_CHECK_COMPLETED_TEMPLATE_NAME,
                                                        :AvailabilityCheckUtils.LINE_CHECK_DEFERRED_TEMPLATE_NAME,
                                                        :AvailabilityCheckUtils.LINE_CHECK_FAILED_TEMPLATE_NAME)]) {
            if (e.DeveloperName.equals(AvailabilityCheckUtils.LINE_CHECK_COMPLETED_TEMPLATE_NAME)) {
                lineCheckCompletedTemplate = e;
            } else if (e.DeveloperName.equals(AvailabilityCheckUtils.LINE_CHECK_DEFERRED_TEMPLATE_NAME)) {
                lineCheckDeferredTemplate = e;
            } else if (e.DeveloperName.equals(AvailabilityCheckUtils.LINE_CHECK_FAILED_TEMPLATE_NAME)) {
                lineCheckFailedTemplate = e;
            }
        } 
    }
    
    public static AvailabilityCheckList invokeAvailabilityCheckWS(List<Line_Availability__c> lineAvailabilityRequests) {
        // Data handling is implemented in utility class
        List<SObject> resultList = new List<SObject>();
        AvailabilityCheckDataTranslationUtils dataUtils = new AvailabilityCheckDataTranslationUtils();
        AvailabilityCheckList availCheckList = new AvailabilityCheckList();  
        Map <String,AvailabilityCheck> availChecks = new Map <String,AvailabilityCheck>();
        // List of line availability records to update. Due to SOA gateway limitation only ever contains one record
        List<Line_Availability__c> lineAvailabilityRecordsToUpdate = new List<Line_Availability__c>();
        List <Line_Availability_CNF__c> callingAndNetworkFeatures = new List <Line_Availability_CNF__c>();
        // Loop through all the request records and form the lineparameters for the WS call
        for (Line_Availability__c lineAvailabilityRequest : lineAvailabilityRequests) {
            if(lineAvailabilityRequest.type__c==AvailabilityCheckUtils.TYPE_LINE) {
                availCheckList.add(invokeFixedLineAvailabilityCheckWS(dataUtils,lineAvailabilityRequest));
            }
            else if(lineAvailabilityRequest.type__c==AvailabilityCheckUtils.TYPE_BROADBAND) {
                // Old Broadband Service (Avatar)
                //availCheckList.add(invokeBroadbandAvailabilityCheckWS(dataUtils,lineAvailabilityRequest));                
                // New Broadband Service (EMLC)
                availCheckList.add(invokeBroadbandAvailabilityCheckWS_EMLC(dataUtils,lineAvailabilityRequest));
            }
            else if(lineAvailabilityRequest.type__c==AvailabilityCheckUtils.TYPE_BROADBAND2) {
                System.debug('invokeAvailabilityCheckWS: NEW BROADBAND');
                availCheckList.add(invokeLine2AvailabilityCheckWS(dataUtils,lineAvailabilityRequest));
            }
        }   
        return availCheckList;
    } 
    
    private static AvailabilityCheck invokeFixedLineAvailabilityCheckWS(AvailabilityCheckDataTranslationUtils dataUtils, Line_Availability__c lineAvailabilityRequest) {
        
        List<SOAViewFixedLineAvailabilityData.lineParametersType> lineParameters = dataUtils.getLineParameters((Line_Availability__c)lineAvailabilityRequest);
        SOAViewFixedLineAvailabilityService.ViewFixedLineAvailabilityPort port = new SOAViewFixedLineAvailabilityService.ViewFixedLineAvailabilityPort();
        port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
        port.timeout_x = SoaUtils.SOA_TIMEOUT; 
        port.email = lineAvailabilityRequest.Batch_Job__r.email__c;
        List<SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType> responseList;
        SOAViewFixedLineAvailabilityData.getInstallationDetails_2Response response2;
        try {
            System.debug('WSSecurityUtil.getUserName(): ' + WSSecurityUtil.getUserName());
            System.debug('WSSecurityUtil.getPassword(): ' + WSSecurityUtil.getPassword());
            
            SOAViewFixedLineAvailabilityData.addressType address = null;

            SOAViewFixedLineAvailabilityData.lineParametersType lineParameter = new SOAViewFixedLineAvailabilityData.lineParametersType();
            SOAViewFixedLineAvailabilityData.serviceIdType serviceIdType = new SOAViewFixedLineAvailabilityData.serviceIdType();
            serviceIdType.directoryNumber = lineAvailabilityRequest.Directory_Number__c;
            serviceIdType.directoryNumber = serviceIdType.directoryNumber.replaceAll('^44','0');
            String accessLineId = null;
            String postcode = lineAvailabilityRequest.Post_Code__c;
            String workingLineTakeover = 'N';
            String endUserConsent = 'Y';
            response2 = port.getInstallationDetails_2(address, serviceIdType,  accessLineId, postcode, workingLineTakeover, endUserConsent); 
        } catch (TypeException e) {
            if ( ! e.getMessage().contains('TestMethod') ) {
                throw new SOAUtils.SOATypeException('TypeException', e);
            } else {
                if (Test.isRunningTest()){
                    if ( ((String)lineAvailabilityRequest.get('Directory_Number__c')).equals(TEST_TIMEOUT) ) {
                        throw new SOAUtils.SOATestMethodException('IO Exception: Read timed out', e);
                    } else if ( ((String)lineAvailabilityRequest.get('Directory_Number__c')).equals(TEST_INTERRUPT) ) {
                        throw new SOAUtils.SOATestMethodException('Internal Error', e);
                    } else {
                        SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType response = dataUtils.getResponseForTestMethods((Line_Availability__c)lineAvailabilityRequest);              
                        responseList = new List<SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType>();
                        responseList.add(response);
                    }
                } 
            } 
        } 
        // We only sent one request due to the SOA limitation - there will only be one response in the array         
        AvailabilityCheck availCheck = new AvailabilityCheck((Line_Availability__c)lineAvailabilityRequest);
        System.debug('@@@ responseList: '+responseList);
        System.debug('@@@ availCheck: '+availCheck); 
        availCheck = AvailabilityCheckDataTranslationUtils.processResponse(response2, availCheck);
        return availCheck;   
    }
    
    private static AvailabilityCheck invokeLine2AvailabilityCheckWS(AvailabilityCheckDataTranslationUtils dataUtils, Line_Availability__c lineAvailabilityRequest) {
        system.debug('invokeLine2AvailabilityCheckWS: enter');    
        List<SOAViewFixedLineAvailabilityData.lineParametersType> lineParameters = dataUtils.getLineParameters((Line_Availability__c)lineAvailabilityRequest);
        SOAViewFixedLineAvailabilityService.ViewFixedLineAvailabilityPort port = new SOAViewFixedLineAvailabilityService.ViewFixedLineAvailabilityPort();
        port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
        port.timeout_x = SoaUtils.SOA_TIMEOUT;
        SOAViewFixedLineAvailabilityData.getLineCharacteristics_1Response response;
        try {
            System.debug('WSSecurityUtil.getUserName(): ' + WSSecurityUtil.getUserName());
            System.debug('WSSecurityUtil.getPassword(): ' + WSSecurityUtil.getPassword());
            
            String serviceType = 'All'; //lineAvailabilityRequest.Directory_Number__c;
            String postCode = lineAvailabilityRequest.Post_Code__c;
            system.debug('invokeLine2AvailabilityCheckWS: serviceType = '+serviceType);    
            system.debug('invokeLine2AvailabilityCheckWS: postCode = '+postCode);    
            
            response = port.getLineCharacteristics_1(serviceType, postCode); 
        } catch (TypeException e) {
            if ( ! e.getMessage().contains('TestMethod') ) {
                throw new SOAUtils.SOATypeException('TypeException', e);
            } else {
                if ( ((String)lineAvailabilityRequest.get('Directory_Number__c')).startsWith('timeout') ) {
                    throw new SOAUtils.SOATestMethodException('IO Exception: Read timed out', e);
                } else if ( ((String)lineAvailabilityRequest.get('Directory_Number__c')).startsWith('internal') ) {
                    throw new SOAUtils.SOATestMethodException('Internal Error', e);
                } 
                //else {
                    // not needed just now
                    //SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType response = dataUtils.getResponseForTestMethods((Line_Availability__c)lineAvailabilityRequest);              
                    //responseList = new List<SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType>();
                    //responseList.add(response);
                //} 
            } 
        } 
        // We only sent one request due to the SOA limitation - there will only be one response in the array         
        AvailabilityCheck availCheck = new AvailabilityCheck((Line_Availability__c)lineAvailabilityRequest);
        System.debug('@@@ responseList: '+response);
        System.debug('@@@ availCheck: '+availCheck);
        availCheck = AvailabilityCheckDataTranslationUtils.processResponse(response, availCheck);
        system.debug('invokeLine2AvailabilityCheckWS: exit');    
        return availCheck;   
    }
    
    private static AvailabilityCheck invokeBroadbandAvailabilityCheckWS(AvailabilityCheckDataTranslationUtils dataUtils, Line_Availability__c bbAvailabilityRequest) {
        
        SOABroadbandAvailabilityService.BroadbandAvailabilityPort port = new SOABroadbandAvailabilityService.BroadbandAvailabilityPort();
        port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
        port.timeout_x = SoaUtils.SOA_TIMEOUT;
        //port.email = bbAvailabilityRequest.Batch_Job__r.email__c;
        SOABroadbandAvailabilityData.getBusinessAvailability_1Response res;
        System.debug('@@@@ bbAvailabilityRequest.Directory_Number__c:'+bbAvailabilityRequest.Directory_Number__c);
        System.debug('@@@@ bbAvailabilityRequest.Post_Code__c:'+bbAvailabilityRequest.Post_Code__c);
        try {
            if(bbAvailabilityRequest.Directory_Number__c!=null && bbAvailabilityRequest.Directory_Number__c.length()>0) {
                res = port.getBusinessAvailability_1(bbAvailabilityRequest.Directory_Number__c,null,null,null); 
            } else {
                res = port.getBusinessAvailability_1(null,bbAvailabilityRequest.Post_Code__c,null,null); 
            }
        } catch (TypeException e) {
            //if ( ! e.getMessage().contains('TestMethod') ) {
                throw new SOAUtils.SOATypeException('TypeException', e);
            //} else {
                //if ( ((String)bbAvailabilityRequest.get('Directory_Number__c')).startsWith('timeout') ) {
                //    throw new SOAUtils.SOATestMethodException('IO Exception: Read timed out', e);
                //} else if ( ((String)bbAvailabilityRequest.get('Directory_Number__c')).startsWith('internal') ) {
                //    throw new SOAUtils.SOATestMethodException('Internal Error', e);
                //} else {
                //    res = dataUtils.getBBResponseForTestMethods((Line_Availability__c)bbAvailabilityRequest);              
                //} 
            //} 
        }       
        AvailabilityCheck availCheck = new AvailabilityCheck((Line_Availability__c)bbAvailabilityRequest);
        availCheck = AvailabilityCheckDataTranslationUtils.processResponse(res, availCheck);
        return availCheck;  
    }
    
    private static AvailabilityCheck invokeBroadbandAvailabilityCheckWS_EMLC(AvailabilityCheckDataTranslationUtils dataUtils, Line_Availability__c bbAvailabilityRequest) {                         
        Dom.Document doc;
        bbAvailabilityRequest.Directory_Number__c = SOAUtils.cleanDirectoryNumberEMLC(bbAvailabilityRequest.Directory_Number__c);
        System.debug('**** bbAvailabilityRequest.Directory_Number__c ****'+bbAvailabilityRequest.Directory_Number__c);
        System.debug('**** bbAvailabilityRequest.Post_Code__c ****'+bbAvailabilityRequest.Post_Code__c);        
        BB_EMLCRequest bbReq = new BB_EMLCRequest();
        try{
            doc = bbReq.sendRequest(bbAvailabilityRequest.Directory_Number__c,bbAvailabilityRequest.Post_Code__c);
        }
        catch(Exception e){
            System.debug(Logginglevel.ERROR, ' **** Exception **** '+' Line Number : '+e.getLineNumber()+' Type : '+e.getTypeName()+' Cause : '+e.getCause()+' Message : '+e.getMessage());
            throw new SOAUtils.XMLSendRequestException('XML Send Request Exception',e);         
        }
        AvailabilityCheck availCheck = new AvailabilityCheck((Line_Availability__c)bbAvailabilityRequest);
        try{
            availCheck = BB_EMLCResponse.parse(doc, availCheck);                        
        }
        catch(Exception e){
            System.debug(' **** Exception **** '+' Line Number : '+e.getLineNumber()+' Type : '+e.getTypeName()+' Cause : '+e.getCause()+' Message : '+e.getMessage());
            throw new SOAUtils.XMLParseResponseException('XML Parse Response Exception',e);
        }
        return availCheck;  
    }
    
    public static void handleCompleted(List<Batch_Job__c> completed) {
        // Handle successes
        addAttachmentsToBatchJobs(completed);
        
        sendEmails(completed, AvailabilityCheckUtils.COMPLETED);
    }
    
    public static void handleDeferred(List<Batch_Job__c> deferred) {
        sendEmails(deferred, AvailabilityCheckUtils.DEFERRED);
    }
    
    public static void handleFailed(List<Batch_Job__c> failed) {
        sendEmails(failed, AvailabilityCheckUtils.FAILED);
    }
    
    private static String getBBCSVBodyString(Batch_Job__c batchJob) {
        String resultString = 'PhoneNumber,Postcode,LLU or IPS available,'+
                            'Reason code,'+
                            'Reason code short text,'+
                            'Access Line Status,'+
                            'Estimated Max Line Speed,'+
                            'Estimated Line Length,'+
                            'Predicted download speed,'+
                            'BT Exchange Name,'+
                            'ANFP Category,'+
                            'A-Earth Capacitance,'+
                            'B-Earth Capacitance,'+
                            // simon said remove 'Contracted Party Name,'+
                            // simon said remove 'Contracted Party number,'+
                            'Available product list,'+                          
                            'BT Response,' + // simon said rename 'Transaction Response' to 'BT Response'
                            'BT Response Code,' + // simon said rename 'BT Fault Response' to 'BT Response Code'                           
                            'Transaction Result\n'; // simon said rename'Comment\n'; 
        for (Line_Availability__c request : [Select Id, 
                                                    Directory_Number__c, 
                                                    Post_Code__c, 
                                                    LLU_or_IPS_available__c,
                                                    reasonCode__c,
                                                    Reason_code_short_text__c,
                                                    accessLineStatus__c,
                                                    estimatedLineSpeed__c,
                                                    lineLengthEstimate__c,
                                                    predictedDownloadSpeed__c ,
                                                    btExchangeName__c ,
                                                    anfpCategory__c ,
                                                    earthCapacitanceA__c ,
                                                    earthCapacitanceB__c ,
                                                    // simon said remove contractedPartyName__c ,
                                                    // simon said remove contractedPartyNumber__c ,
                                                    productList__c ,
                                                    External_Description__c,
                                                    Internal_Description__c,
                                                    Response__c,    
                                                    Status__c,
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
                                                    Status_Code__c
                                                    From Line_Availability__c 
                                                    Where Batch_Job__c = : batchJob.Id and type__c=:AvailabilityCheckUtils.TYPE_BROADBAND]) {


            // initialise the string to be the response__c. If blank then use external_description__c
            String transactionResponse = (request.Response__c != null ? request.Response__c:''); 
            system.debug('* response: '+transactionResponse );   
            resultString += '="'+(request.Directory_Number__c != null ? request.Directory_Number__c:'')+'",'+
                                '"'+(request.Post_Code__c != null ? request.Post_Code__c:'')+'",'+
                                '"'+(request.LLU_or_IPS_available__c !=null ? request.LLU_or_IPS_available__c:'')+'",'+
                                '"'+(request.reasonCode__c != null ? request.reasonCode__c:'')+'",'+
                                '"'+(request.Reason_code_short_text__c != null ? request.Reason_code_short_text__c:'')+'",'+
                                '"'+(request.accessLineStatus__c != null ? request.accessLineStatus__c:'')+'",'+
                                '"'+(request.estimatedLineSpeed__c != null ? request.estimatedLineSpeed__c:'')+'",'+
                                '"'+(request.lineLengthEstimate__c != null ? request.lineLengthEstimate__c:'')+'",'+
                                '"'+(request.predictedDownloadSpeed__c != null ? request.predictedDownloadSpeed__c:'')+'",'+
                                '"'+(request.btExchangeName__c != null ? request.btExchangeName__c:'')+'",'+
                                '"'+(request.anfpCategory__c != null ? request.anfpCategory__c:'')+'",'+
                                '"'+(request.earthCapacitanceA__c != null ? request.earthCapacitanceA__c:'')+'",'+
                                '"'+(request.earthCapacitanceB__c != null ? request.earthCapacitanceB__c:'')+'",'+
                                // simon said remove '"'+(request.contractedPartyName__c != null ? request.contractedPartyName__c:'')+'",'+
                                // simon said remove '"'+(request.contractedPartyNumber__c != null ? request.contractedPartyNumber__c:'')+'",'+
                                '"'+(request.productList__c != null ? request.productList__c:'')+'",'+
                                '"'+ transactionResponse +'",'+
                                '"'+(request.Resp1CC__c != null ? request.Resp1CC__c:'')+'",'+
                                '"'+(request.Status_Code__c != null ? 'Success':'Failed'+' '+(request.Resp1CC__c != null ? request.Resp1CC__c:''))+'",'+                                
                                '""\n';
        }
        return resultString;
    
    }
    
    private static String getLineCSVBodyString(Batch_Job__c batchJob) {
        String resultString = 'PhoneNumber,Postcode,Service Type,# Lines,# Channels,Features,IncompatibleServices,UnsupportedServices,BillingNumbers,DDIs,DDIsRanges,CPS,BB,Companyname,Response,Comment\n'; 
        for (Line_Availability__c request : [Select Id, Directory_Number__c, Post_Code__c, Service_Type__c, Number_of_Lines__c, Number_of_Channels__c, Features__c, Incompatible_Services__c, Unsupported_Services__c, Billing_Numbers__c, Single_DDIs__c, DDI_Ranges__c, Carrier_Pre_Select__c, Narrowband_Service_Indicator__c, Company_Name__c, Status_Code__c, Response__c From Line_Availability__c Where Batch_Job__c = : batchJob.Id and type__c=:AvailabilityCheckUtils.TYPE_LINE]) {
            resultString += '="'+(request.Directory_Number__c != null ? request.Directory_Number__c:'')+'",'+
                                '"'+(request.Post_Code__c != null ? request.Post_Code__c:'')+'",'+
                                '"'+(request.Service_Type__c != null ? request.Service_Type__c:'')+'",'+
                                '"'+(request.Number_of_Lines__c != null ? String.valueOf(request.Number_of_Lines__c):'')+'",'+
                                '"'+(request.Number_of_Channels__c != null ? String.valueOf(request.Number_of_Channels__c):'')+'",'+
                                '"'+(request.Features__c != null ? request.Features__c:'')+'",'+
                                '"'+(request.Incompatible_Services__c != null ? request.Incompatible_Services__c:'')+'",'+
                                '"'+(request.Unsupported_Services__c != null ? request.Unsupported_Services__c:'')+'",'+
                                '="'+(request.Billing_Numbers__c != null ? request.Billing_Numbers__c:'')+'",'+
                                '"'+(request.Single_DDIs__c != null ? request.Single_DDIs__c:'')+'",'+
                                '"'+(request.DDI_Ranges__c != null ? request.DDI_Ranges__c:'')+'",'+
                                '"'+(request.Carrier_Pre_Select__c != null ? request.Carrier_Pre_Select__c:'')+'",'+
                                '"'+(request.Narrowband_Service_Indicator__c != null ? request.Narrowband_Service_Indicator__c:'')+'",'+
                                '"'+(request.Company_Name__c != null ? request.company_name__c:'')+'",'+
                                '"'+(request.Response__c != null ? request.Response__c:'')+'",'+
                                '""\n';         
        }
        return resultString;            
    }
    
    private static String getCSVBodyString(Batch_Job__c batchJob, String checkType) {
        String resultString = ''; 
        if(checkType==AvailabilityCheckUtils.TYPE_BROADBAND) {
            resultString = getBBCSVBodyString(batchJob);
        } else {
            resultString = getLineCSVBodyString(batchJob);
        }
        return resultString;    
    }
    
    private static Attachment createAttachment(Batch_Job__c batchJob, String checkType) {
        String resultString = getCSVBodyString(batchJob, checkType);
        Attachment attachment = new Attachment();
        attachment.ParentId = batchJob.Id;
        attachment.Body = Blob.valueOf(resultString);
        attachment.Name = checkType+'_'+OUTPUT_FILE_NAME;
        return attachment;   
    }
    
    private static void addAttachmentsToBatchJobs(List<Batch_Job__c> batchJobs) {
        List<Attachment> attachments = new List<Attachment>();
        for (Batch_Job__c batchJob : batchJobs) {
            if(batchJob.Type__c==AvailabilityCheckUtils.TYPE_LINE_AND_BROADBAND) {
                attachments.add(createAttachment(batchJob, AvailabilityCheckUtils.TYPE_LINE));
                attachments.add(createAttachment(batchJob, AvailabilityCheckUtils.TYPE_BROADBAND));
            } else {
                attachments.add(createAttachment(batchJob, batchJob.Type__c));
            }
        }
        if (attachments.size() > 0) {
            List<Database.SaveResult> results = Database.insert(attachments);
        }
    }
    
    private static void sendEmails(List<Batch_Job__c> batchJobs, String result) {
        system.debug('checked !!!!!');
        getEmailTemplates();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Batch_Job__c batchJob : batchJobs) {
            
            if (result.equals(AvailabilityCheckUtils.COMPLETED)) {
               
                // No emails are sent when the data is manually keyed into the Visualforce page 
                if (batchJob.Channel__c!=null && ! batchJob.Channel__c.equals(AvailabilityCheckUtils.SCREEN_INPUT)) {
                    Messaging.SingleEmailMessage mail = getEmailMessageCompleted(batchJob);
                    if (mail != null) {
                        emails.add(mail);
                    }
                } 
            } else if (result.equals(AvailabilityCheckUtils.DEFERRED)) {
                Messaging.SingleEmailMessage mail = getEmailMessageDeferred(batchJob);
                if (mail != null) {
                    emails.add(mail);
                }
            } else if (result.equals(AvailabilityCheckUtils.FAILED)) {
                Messaging.SingleEmailMessage mail = getEmailMessageFailed(batchJob);
                if (mail != null) {
                    emails.add(mail);
                }
            }
        } 
        if (emails.size() > 0) {
            system.debug('send mail finally called');
            Messaging.sendEmail(emails);
        }
    }
    
    private static Messaging.SingleEmailMessage getEmailMessageCompleted(Batch_Job__c batchJob) {
        Messaging.SingleEmailMessage mail;
        if (batchJob.Channel__c.equals(AvailabilityCheckUtils.FILE_UPLOAD)) {
            mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(lineCheckCompletedTemplate.Id);
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setWhatId(batchJob.Id);
            mail.setSaveAsActivity(false);
        } else if (batchJob.Channel__c.equals(AvailabilityCheckUtils.EMAIL)) {
            mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {batchJob.Email__c};
            mail.setToAddresses(toAddresses);
            mail.setSubject(batchJob.Type__c + ' Availability Check Results');
            mail.setPlainTextBody('Please find attached the results of your '+batchJob.Type__c+' Availability Check.');
            // For emails we attach the output file
            for (Attachment attachment : [Select Id, 
                                                 Name, 
                                                 Body 
                                          From Attachment 
                                          Where ParentId = :batchJob.Id
                                          And Name =: batchJob.Type__c+'_'+OUTPUT_FILE_NAME ]) {
                List<Messaging.EmailFileAttachment> mailAttachmentList = new List<Messaging.EmailFileAttachment>();
                Messaging.EmailFileAttachment mailAttachment = new Messaging.EmailFileAttachment();
                mailAttachment.setFileName(attachment.Name);
                mailAttachment.setBody(attachment.body);
                mailAttachmentList.add(mailAttachment);  
                mail.setFileAttachments(mailAttachmentList);
            }
        }
        return mail;
    }
    
    private static Messaging.SingleEmailMessage getEmailMessageDeferred(Batch_Job__c batchJob) {
        Messaging.SingleEmailMessage mail;
        if ((batchJob.Channel__c.equals(AvailabilityCheckUtils.SCREEN_INPUT)) || (batchJob.Channel__c.equals(AvailabilityCheckUtils.FILE_UPLOAD))) {
            mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(lineCheckDeferredTemplate.Id);
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setWhatId(batchJob.Id);
            mail.setSaveAsActivity(false);
        } else if (batchJob.Channel__c.equals(AvailabilityCheckUtils.EMAIL)) {
            mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {batchJob.Email__c};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Line Availability Check - Deferred');
            mail.setPlainTextBody('Your line availability check could not be processed at this time. It will be re-attempted within the next 24 hours and an email update sent.');
        }
        return mail;
    }
    
    private static Messaging.SingleEmailMessage getEmailMessageFailed(Batch_Job__c batchJob) {
        Messaging.SingleEmailMessage mail;
        if ((batchJob.Channel__c.equals(AvailabilityCheckUtils.SCREEN_INPUT)) || (batchJob.Channel__c.equals(AvailabilityCheckUtils.FILE_UPLOAD))) {
            mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(lineCheckFailedTemplate.Id);
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setWhatId(batchJob.Id);
            mail.setSaveAsActivity(false);
        } else if (batchJob.Channel__c.equals(AvailabilityCheckUtils.EMAIL)) {
            mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {batchJob.Email__c};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Line Availability Check - Failed');
            mail.setPlainTextBody('Your line availability check failed or was cancelled. Please check your data and resubmit. If the error persists contact your system administrator');
        }
        return mail;
    }
    
}