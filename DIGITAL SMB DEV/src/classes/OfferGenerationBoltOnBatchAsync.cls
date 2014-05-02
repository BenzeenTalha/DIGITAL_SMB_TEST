global with sharing class OfferGenerationBoltOnBatchAsync implements Database.Batchable<sObject> {
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
                            ' from cscfgc__Configuration_Offer__c Where Name in (\'Standalone data bolton\',\'Standalone International Favourites bolton\',\'Standalone 4G Access bolton\')';
                List<cscfgc__Configuration_Offer__c> offerToBeDuplicatedList = Database.query(queryString);
                system.debug('****offerToBeDuplicatedList.size():'+offerToBeDuplicatedList.size());
                Map<String,cscfgc__Configuration_Offer__c> offerToBeDuplicatedMap = new Map<String,cscfgc__Configuration_Offer__c>();
                for (cscfgc__Configuration_Offer__c offerRec : offerToBeDuplicatedList) {
                    offerToBeDuplicatedMap.put(offerRec.Name,offerRec);
                    system.debug('***>>>offerRec.Name:'+offerRec.Name);
                    system.debug('***>>>offerRec.cscfgc__Product_Configurations__r.size():'+offerRec.cscfgc__Product_Configurations__r.size());
                }
                system.debug('**>>Map:'+offerToBeDuplicatedMap);
                //
                // --------
                // Get the details of the Bolton associated with this offer:
                queryString = 'select '+Utility.getSobjectFields('O2_DISE_Map_Mobile_Bolton__c')+
                    ' from O2_DISE_Map_Mobile_Bolton__c Where id = \''+offer.O2_DISE_Map_Mobile_Bolton__c+'\'';
                List<O2_DISE_Map_Mobile_Bolton__c> BoltOnList = Database.query(queryString);
                system.debug('****BoltOnList.size():'+BoltOnList.size());
                O2_DISE_Map_Mobile_Bolton__c boltOn = BoltOnList[0];
                //
                // --------
                // Get Config Id of the config to be duplicated
                String ConfigIdToBeDuplicated = null;
                system.debug('****offerToBeDuplicatedMap.containsKey(\'Standalone International Favourites bolton\'):'+offerToBeDuplicatedMap.containsKey('Standalone International Favourites bolton'));
                system.debug('**>>Map:'+offerToBeDuplicatedMap);
                if (boltOn.Bolt_On_Type__c == 'DATA BOLTON') {
                    ConfigIdToBeDuplicated = offerToBeDuplicatedMap.get('Standalone data bolton').cscfgc__Product_Configurations__r[0].id;
                } else if (boltOn.Bolt_On_Type__c == 'INTERNATIONAL FAVOURITES' && offerToBeDuplicatedMap.containsKey('Standalone International Favourites bolton')) {
                    system.debug('****offerToBeDuplicatedMap.containsKey(\'Standalone International Favourites bolton\'):'+offerToBeDuplicatedMap.containsKey('Standalone International Favourites bolton'));
                    ConfigIdToBeDuplicated = offerToBeDuplicatedMap.get('Standalone International Favourites bolton').cscfgc__Product_Configurations__r[0].id;
                } else if (boltOn.Bolt_On_Type__c == 'FOUR G ACCESS') {
                    ConfigIdToBeDuplicated = offerToBeDuplicatedMap.get('Standalone 4G Access bolton').cscfgc__Product_Configurations__r[0].id;
                }
                //
                // --------
                // Clone the product configuration:
                String newConfigId = cscfgc.API_1.cloneConfiguration(new cscfgc__Product_Configuration__c(
                                                                            id = ConfigIdToBeDuplicated),
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
                    config.Insurance__c = offer.Insurance__c;
                    // update all relevant attributes and add them to a single attribute list:
                    for (cscfgc__Attribute__c att : config.cscfgc__Attributes__r) {
                        if (att.Name == 'Select Data Bolt On' && boltOn.Bolt_On_Type__c == 'DATA BOLTON') {
                            att.cscfgc__Value__c = boltOn.Id;
                            att.cscfgc__Display_Value__c = boltOn.Name;
                            attributeToUpdateList.add(att);
                        } else if (att.Name == 'Select International Favourites Bolt On' && boltOn.Bolt_On_Type__c == 'INTERNATIONAL FAVOURITES') {
                            att.cscfgc__Value__c = boltOn.Id;
                            att.cscfgc__Display_Value__c = boltOn.Name;
                            attributeToUpdateList.add(att);
                        } else if (att.Name == 'Select 4G Access Bolt On' && boltOn.Bolt_On_Type__c == 'FOUR G ACCESS') {
                            att.cscfgc__Value__c = boltOn.Id;
                            att.cscfgc__Display_Value__c = boltOn.Name;
                            attributeToUpdateList.add(att);
                        } else if (att.Name == 'Recurring One Off' && boltOn.Bolt_On_Type__c == 'Data bolton') {
                            att.cscfgc__Value__c = boltOn.Recurring_OneOff__c;
                            attributeToUpdateList.add(att);
                        } else if (att.Name == 'Primary Handset Tariff Code') {
                            att.cscfgc__Value__c = boltOn.tariff_code__c;
                            attributeToUpdateList.add(att);
                        } else if (att.Name == 'Quantity') {
                            att.cscfgc__Value__c = '1';
                            attributeToUpdateList.add(att);
                        } else if (att.Name == 'Parent Name') {
                            att.cscfgc__Value__c = 'Bolt On';
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