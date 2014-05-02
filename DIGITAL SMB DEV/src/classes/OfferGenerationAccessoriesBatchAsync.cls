global with sharing class OfferGenerationAccessoriesBatchAsync implements Database.Batchable<sObject> {
    global String query;
    public List<sObject> diseCodeList = new List<sObject>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<cscfgc__Configuration_Offer__c> offerList = new List<cscfgc__Configuration_Offer__c>();
        //List<cscfgc__Log_Entry__c> logEntryList = new List<cscfgc__Log_Entry__c>();
        //
        //logEntryList = [select id from cscfgc__Log_Entry__c];
        //delete logEntryList;
        //
        if (scope.size()>0) {
            for (sObject rec : scope) {
                // Get a handle on the current record:
                cscfgc__Configuration_Offer__c offer = (cscfgc__Configuration_Offer__c) rec;
                // Create a query string
                String queryString = null;
                //
                // --------
                // Find the offer we want:
                queryString = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                            ' , (select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+' from cscfgc__Product_Configurations__r) '+
                            ' from cscfgc__Configuration_Offer__c Where Name = \'Standalone accessory\' limit 1';
                List<cscfgc__Configuration_Offer__c> offerToBeDuplicatedList = Database.query(queryString);
                system.debug('****offerToBeDuplicatedList.size():'+offerToBeDuplicatedList.size());
                //
                // --------
                // Get the details of the Accessory associated with this offer:
                queryString = 'select '+Utility.getSobjectFields('O2_DISE_Ref_Hardware_Relation__c')+
                    ' from O2_DISE_Ref_Hardware_Relation__c Where id = \''+offer.O2_DISE_Ref_Hardware_Relation__c+'\'';
                List<O2_DISE_Ref_Hardware_Relation__c> accessoryList = Database.query(queryString);
                system.debug('****accessoryList.size():'+accessoryList.size());
                O2_DISE_Ref_Hardware_Relation__c accessory = accessoryList[0];
                //
                // --------
                // Clone the product configuration:
                String newConfigId = cscfgc.API_1.cloneConfiguration(new cscfgc__Product_Configuration__c(
                                                                            id = offerToBeDuplicatedList[0].cscfgc__Product_Configurations__r[0].id),
                                                                            null,
                                                                            null);
                system.debug('****newConfigId:'+newConfigId);
                //
                // --------
                // Get the details of the cloned product configuration:
                queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                            ' , (select '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r) '+
                            ' from cscfgc__Product_Configuration__c Where id = \''+newConfigId+'\' limit 1';
                List<cscfgc__Product_Configuration__c> productConfigList = Database.query(queryString);
                List<cscfgc__Attribute__c> attributeToUpdateList = new List<cscfgc__Attribute__c>();
                //
                // --------
                // Link the configuration to the new offer:
                for (cscfgc__Product_Configuration__c config : productConfigList) { 
                    config.cscfgc__Configuration_Offer__c = offer.Id;
                    config.SIM_Type__c = offer.SIM_Type__c;
                    config.Quantity_of_Accessory__c  = offer.Quantity_of_Accessory__c;
                    config.O2_DISE_Ref_Hardware_Relation__c = offer.O2_DISE_Ref_Hardware_Relation__c;
                    config.O2_DISE_Map_Mobile__c = offer.O2_DISE_Map_Mobile__c;
                    config.O2_DISE_Map_Mobile_Bolton__c = offer.O2_DISE_Map_Mobile_Bolton__c;
                    config.O2_DISE_Map_Handset__c = offer.O2_DISE_Map_Handset__c;
                    config.O2_DISE_Map_Handset_Selection__c = offer.O2_DISE_Map_Handset_Selection__c;
                    config.O2_DISE_Ref_Hardware_Portfolio__c = offer.O2_DISE_Ref_Hardware_Portfolio__c;
                    config.Insurance__c = offer.Insurance__c;
                    // update all relevant attributes and add them to a single attribute list:
                    for (cscfgc__Attribute__c att : config.cscfgc__Attributes__r) { 
                        if (att.Name == 'Select Accessory') { 
                            att.cscfgc__Value__c = accessory.Id;
                            att.cscfgc__Display_Value__c = accessory.Name;
                            attributeToUpdateList.add(att);
                        } else if (att.Name == 'Quantity') { 
                            att.cscfgc__Value__c = offer.Quantity_of_Accessory__c+'';
                            attributeToUpdateList.add(att);
                        }
                    }
                }
                update productConfigList;
                update attributeToUpdateList;
                //
                // --------
                // Start an API session:
                cscfgc.API_1.ApiSession session = cscfgc.API_1.getApiSession(new cscfgc__Product_Configuration__c(id=productConfigList[0].Id)); 
                session.executeRules();
                session.persistConfiguration(true);
                //
                // --------
                // Update the offer description to the product configuration name:
                cscfgc__Product_Configuration__c productConfig = [select Name, Id from cscfgc__Product_Configuration__c where id = :productConfigList[0].Id];
                offer.cscfgc__Description__c = productConfig.Name;
                update offer;
            }
        }
        //upsert logEntryList;
    }
    
    global void finish(Database.BatchableContext BC) {
        // Code to execute at the end of the batch process
    }
}