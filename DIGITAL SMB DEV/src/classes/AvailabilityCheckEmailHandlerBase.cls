global abstract class AvailabilityCheckEmailHandlerBase {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope, String checkType) {

        // Rollback any changes if the email is not processed successfully
        Savepoint sp = Database.setSavepoint();

        // Get the attachments from the inbound email and store them in a list of attachments
        try {
            List<Attachment> attachments = new List<Attachment>();
            if (email.textAttachments != null && email.textAttachments.size() > 0) {
                for (integer i = 0 ; i < email.textAttachments.size() ; i++) {
                    if (email.textAttachments[i].filename != null && email.textAttachments[i].filename.endsWith('.csv')) {
                        Attachment a = new Attachment();
                        a.name = email.textAttachments[i].filename;
                        a.body = Blob.valueof(email.textAttachments[i].body);
                        attachments.add(a);
                    }
                }
            }

            if(email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                    if (email.binaryAttachments[i].filename != null && email.binaryAttachments[i].filename.endsWith('.csv')) {
                        Attachment a = new Attachment();
                        a.name = email.binaryAttachments[i].filename;
                        a.body = email.binaryAttachments[i].body;
                        attachments.add(a);
                    }
                }
            }

            if ( ! attachments.isEmpty() ) {
                Batch_Job__c batchJob = AvailabilityCheckInputProcessor.processCSVFiles(attachments, AvailabilityCheckUtils.EMAIL, email.fromAddress, checkType);
                AvailabilityCheckUtils.processAvailabilityCheck(new List<Id>{batchJob.Id});
            } else {
                // Email user to notify of error
                handleError(email);
            }
        } catch(Exception e) {
            Database.rollback(sp);
            handleError(email);
            System.debug(e);
        }
        // Not used - a utility class will send response
        return null;
    }

    private void handleError(Messaging.InboundEmail email) {
        Batch_Job__c batchJob = new Batch_Job__c();
        batchJob.Channel__c = AvailabilityCheckUtils.EMAIL;
        batchJob.Status__c = AvailabilityCheckUtils.FAILED;
        batchJob.Email__c = email.fromAddress;
        for(User u : [Select Id From User Where IsActive=true and email = :email.fromAddress limit 1]) {
        	batchJob.User__c = u.Id;
        	batchJob.ownerid = u.Id;
        }
        Database.SaveResult result = Database.insert(batchJob);
        AvailabilityCheckOutputProcessor.handleFailed(new List<Batch_Job__c>{batchJob});
    }

}