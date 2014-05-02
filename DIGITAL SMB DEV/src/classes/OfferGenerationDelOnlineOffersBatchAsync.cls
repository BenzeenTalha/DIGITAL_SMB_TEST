global with sharing class OfferGenerationDelOnlineOffersBatchAsync implements Database.Batchable<sObject> {
    global String query;
    public string deleteType;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        // get a handle on the Offers
        List<cscfgc__Configuration_Offer__c> offerList = (List<cscfgc__Configuration_Offer__c>) scope;
        List<cscfgc__Product_Configuration__c> prodConfigList = new List<cscfgc__Product_Configuration__c>();
        //List<cscfgc__Log_Entry__c> logEntryList = new List<cscfgc__Log_Entry__c>();
        //
        //logEntryList = [select id from cscfgc__Log_Entry__c];
        //delete logEntryList;
        //
        // get lists of the Offers and Product Configs to delete
        if (offerList.size()>0) {
            system.debug('****offerList.size(): '+offerList.size());
            for (cscfgc__Configuration_Offer__c offer: offerList) {
                system.debug('****ProductConfigurations.size(): '+offer.cscfgc__Product_Configurations__r.size());
                for (cscfgc__Product_Configuration__c prod : offer.cscfgc__Product_Configurations__r) {
                    prodConfigList.add(prod);
                }
            }
            delete offerList;
            delete prodConfigList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Code to execute at the end of the batch process
        
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, CompletedDate,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
        
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch '+ deleteType +' Offers Deletion ' + a.Status + ' at ' + a.CompletedDate);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}