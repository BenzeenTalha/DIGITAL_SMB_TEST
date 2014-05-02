public with sharing class OfferGenerationController {
    public List<String> FlavourList = new List<String>{'50','100','300','600','1200','Max','On & On'};
    public List<String> PrimaryCoreBoltOnList = new List<String>{'--None--','BASICS','ROUNDER','WORKS'};
    public String limitRows {get; set;}
    public String accessorySKU {get; set;}
    public String handsetSKU {get; set;}
    public String tariffKey {get; set;}
    public String tariffName {get; set;}
    public String tariffClass {get; set;}
    public String simOnlyTariffKey {get; set;}
    public String simOnlyTariffName {get; set;}
    public String simOnlyTariffClass {get; set;}
    public String boltOnTariffKey {get; set;}
    public String boltOnTariffName {get; set;}
    public String boltOnTariffClass {get; set;}

    public List<SelectOption> offerTypes {get;set;}
    public String selectedOfferType {get;set;}

    public List<SelectOption> accessoryTypes {get;set;}
    public String selectedAccessorySKU {get;set;}

    public List<SelectOption> handsetTypes {get;set;}
    public String selectedHandsetSKU {get;set;}

    public List<SelectOption> tariffTypes {get;set;}
    public String selectedTariffKey {get;set;}
    public String selectedTariffName {get;set;}
    public String selectedTariffClass {get;set;}

    public List<SelectOption> simOnlyTariffTypes {get;set;}
    public String selectedSimOnlyTariffKey {get;set;}
    public String selectedSimOnlyTariffName {get;set;}
    public String selectedSimOnlyTariffClass {get;set;}

    public List<SelectOption> boltOnTariffTypes {get;set;}
    public String selectedBoltOnTariffKey {get;set;}
    public String selectedBoltOnTariffName {get;set;}
    public String selectedBoltOnTariffClass {get;set;}


    public OfferGenerationController() {
        //
        // --------
        //
        offerTypes = new List<SelectOption>();
        offerTypes.add(new SelectOption('TARIFFHANDSET','Tariff Handsets'));
        offerTypes.add(new SelectOption('SIMONLY','SIM Only'));
        offerTypes.add(new SelectOption('ACCESSORY','Accessories'));
        offerTypes.add(new SelectOption('BOLTON','Bolt Ons'));
        offerTypes.add(new SelectOption('ALL','All (Delete only)'));
        limitRows = '';
        clearAccessory();
        clearHandset();
        clearTariff();
        clearSimOnlyTariff();
        clearBoltOnTariff();
        String soKey = '';
        String soDescription = '';
        accessoryTypes = new List<SelectOption>();
        for (O2_DISE_Ref_Hardware_Portfolio__c acc : [select id,product_code__c,hardware_description__c from O2_DISE_Ref_Hardware_Portfolio__c where hardware_type__c='Accessory' order by hardware_description__c]) {
            soKey = acc.product_code__c;
            soDescription = acc.hardware_description__c;
            accessoryTypes.add(new SelectOption(soKey , soKey+' '+(soDescription.length()>40?soDescription.substring(0,40)+'...':soDescription)));
        }
        handsetTypes = new List<SelectOption>();
        for (O2_DISE_Ref_Hardware_Portfolio__c hs : [select id,product_code__c,hardware_description__c from O2_DISE_Ref_Hardware_Portfolio__c where hardware_type__c='Handset' order by hardware_description__c]) {
            soKey = hs.product_code__c;
            soDescription = hs.hardware_description__c;
            handsetTypes.add(new SelectOption(soKey , soKey+' '+(soDescription.length()>40?soDescription.substring(0,40)+'...':soDescription)));
        }
        //
        tariffTypes = new List<SelectOption>();
        Set<String> tariffKeySet = new Set<String>();
        for (O2_DISE_Map_Mobile__c tariff : [select Id,Name,Handset_Tariff_Class__c,Flavour__c,Core_Data_Bolton__c,Promotion__c,Tariff_Code__c
                                              from O2_DISE_Map_Mobile__c
                                              where Contract_Length__c = '24' and Roaming__c = '--None--'
                                              and Product_Definition__c = 'Business Single'
                                              and Contract_type__c = 'Handset' and Handset_Tariff_Class__c != 'Blackberry BES' and Primary_Additional__c = 'Primary']) {
            soKey = tariff.Name+':-:'+tariff.Handset_Tariff_Class__c; // +':-:'+tariff.Flavour__c+':-:'+tariff.Core_Data_Bolton__c+':-:'+tariff.Promotion__c;
            tariffKeySet.add(soKey); // dedupe and sort neccessary
        }
        List<String> sortedTariffKeys = new List<String>();
        sortedTariffKeys.addAll(tariffKeySet);
        sortedTariffKeys.sort();
        for (String tariff : sortedTariffKeys) {
            soKey = tariff;
            soDescription = tariff;
            tariffTypes.add(new SelectOption(soKey , (soDescription.length()>45?soDescription.substring(0,45)+'...':soDescription)));
        }
        //
        simOnlyTariffTypes = new List<SelectOption>();
        Set<String> simOnlyTariffKeySet = new Set<String>();
        for (O2_DISE_Map_Mobile__c simOnlyTariff : [select Id,Name,Handset_Tariff_Class__c,Flavour__c,Core_Data_Bolton__c,Promotion__c,Tariff_Code__c
                                              from O2_DISE_Map_Mobile__c
                                              where Roaming__c = '--None--'
                                              and Product_Definition__c = 'Business Single'
                                              and Contract_type__c != 'Handset' and Handset_Tariff_Class__c != 'Blackberry BES' and Primary_Additional__c = 'Primary']) {
            soKey = simOnlyTariff.Name+':-:'+simOnlyTariff.Handset_Tariff_Class__c; // +':-:'+simOnlyTariff.Flavour__c+':-:'+simOnlyTariff.Core_Data_Bolton__c+':-:'+simOnlyTariff.Promotion__c;
            simOnlyTariffKeySet.add(soKey); // dedupe and sort neccessary
        }
        List<String> sortedSimOnlyTariffKeys = new List<String>();
        sortedSimOnlyTariffKeys.addAll(simOnlyTariffKeySet);
        sortedSimOnlyTariffKeys.sort();
        for (String simOnlyTariff : sortedSimOnlyTariffKeys) {
            soKey = simOnlyTariff;
            soDescription = simOnlyTariff;
            simOnlyTariffTypes.add(new SelectOption(soKey , (soDescription.length()>45?soDescription.substring(0,45)+'...':soDescription)));
        }
        //
        boltOnTariffTypes = new List<SelectOption>();
        Set<String> boltOnTariffKeySet = new Set<String>();
        for (O2_DISE_Map_Mobile_Bolton__c boltOnTariff : [select Id,Name,Bolt_On_Type__c,Tariff_Description__c
						                      from O2_DISE_Map_Mobile_Bolton__c
						                      where Bolt_On_Type__c in ('DATA BOLTON','INTERNATIONAL FAVOURITES','FOUR G ACCESS')
						                      and Tariff_Description__c != 'Additional User' and (not Tariff_Description__c  like '%Share%')
						                      and (not Tariff_Description__c  like '%lease%')
						                      and (not Tariff_Description__c  like '%12 Month%') ]) {
            soKey = boltOnTariff.Bolt_On_Type__c+':-:'+boltOnTariff.Tariff_Description__c;
            boltOnTariffKeySet.add(soKey); // dedupe and sort neccessary
        }
        List<String> sortedBoltOnTariffKeys = new List<String>();
        sortedBoltOnTariffKeys.addAll(boltOnTariffKeySet);
        sortedBoltOnTariffKeys.sort();
        for (String boltOnTariff : sortedBoltOnTariffKeys) {
            soKey = boltOnTariff;
            soDescription = boltOnTariff;
            boltOnTariffTypes.add(new SelectOption(soKey , (soDescription.length()>60?soDescription.substring(0,60)+'...':soDescription)));
        }
    }

    // Screen Selection Routing

    // Create Routing
    public PageReference createButtonRouting(){
        if (selectedOfferType=='TARIFFHANDSET') {
            return createOffers();
        } else if (selectedOfferType=='SIMONLY') {
            return createSimOnlyOffers();
        } else if (selectedOfferType=='ACCESSORY') {
            return createAccessoryOffers();
        } else if (selectedOfferType=='BOLTON') {
            return createBoltOnOffers();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid or no selection for Create.'));
        }
        return null;
    }
    // Delete Routing
    public PageReference deleteButtonRouting(){
        if (selectedOfferType=='TARIFFHANDSET') {
            return deleteHandsetOffers();
        } else if (selectedOfferType=='SIMONLY') {
            return deleteSimOnlyOffers();
        } else if (selectedOfferType=='ACCESSORY') {
            return deleteAccessoryOffers();
        } else if (selectedOfferType=='BOLTON') {
            return deleteBoltOnOffers();
        } else if (selectedOfferType=='ALL') {
            return deleteOnlineOffers();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid or no selection for Delete.'));
        }
        return null;
    }


    // Selection Buttons

    // Add Accessory
    public PageReference addAccessory(){
        if (!accessorySKU.contains('\''+selectedAccessorySKU+'\'')) {
            accessorySKU += (String.isEmpty(accessorySKU)?'':',') + '\''+selectedAccessorySKU+'\'';
        }
        return null;
    }
    // Add Handset
    public PageReference addHandset(){
        if (!handsetSKU.contains('\''+selectedHandsetSKU+'\'')) {
            handsetSKU += (String.isEmpty(handsetSKU)?'':',') + '\''+selectedHandsetSKU+'\'';
        }
        return null;
    }
    // Add Tariff
    public PageReference addTariff(){
        String[] tariffFields = selectedTariffKey.split(':-:');
        selectedTariffName = tariffFields[0]; // name
        selectedTariffClass = tariffFields[1]; // class
        if (!tariffKey.contains('\''+selectedTariffKey+'\'')) {
            tariffKey += (String.isEmpty(tariffKey)?'':',') + '\''+selectedTariffKey+'\'';
        }
        if (!tariffName.contains('\''+selectedTariffName+'\'')) {
            tariffName += (String.isEmpty(tariffName)?'':',') + '\''+selectedTariffName+'\'';
        }
        if (!tariffClass.contains('\''+selectedTariffClass+'\'')) {
            tariffClass += (String.isEmpty(tariffClass)?'':',') + '\''+selectedTariffClass+'\'';
        }
        return null;
    }
    // Add Sim Only Tariff
    public PageReference addSimOnlyTariff(){
        String[] simOnlyTariffFields = selectedSimOnlyTariffKey.split(':-:');
        selectedSimOnlyTariffName = simOnlyTariffFields[0]; // name
        selectedSimOnlyTariffClass = simOnlyTariffFields[1]; // class
        if (!simOnlyTariffKey.contains('\''+selectedSimOnlyTariffKey+'\'')) {
            simOnlyTariffKey += (String.isEmpty(simOnlyTariffKey)?'':',') + '\''+selectedSimOnlyTariffKey+'\'';
        }
        if (!simOnlyTariffName.contains('\''+selectedSimOnlyTariffName+'\'')) {
            simOnlyTariffName += (String.isEmpty(simOnlyTariffName)?'':',') + '\''+selectedSimOnlyTariffName+'\'';
        }
        if (!simOnlyTariffClass.contains('\''+selectedSimOnlyTariffClass+'\'')) {
            simOnlyTariffClass += (String.isEmpty(simOnlyTariffClass)?'':',') + '\''+selectedSimOnlyTariffClass+'\'';
        }
        return null;
    }
    // Add Bolt On Tariff
    public PageReference addBoltOnTariff(){
        String[] boltOnTariffFields = selectedBoltOnTariffKey.split(':-:');
        selectedBoltOnTariffName = boltOnTariffFields[0]; // name
        selectedBoltOnTariffClass = boltOnTariffFields[1]; // class
        if (!boltOnTariffKey.contains('\''+selectedBoltOnTariffKey+'\'')) {
            boltOnTariffKey += (String.isEmpty(boltOnTariffKey)?'':',') + '\''+selectedBoltOnTariffKey+'\'';
        }
        if (!boltOnTariffName.contains('\''+selectedBoltOnTariffName+'\'')) {
            boltOnTariffName += (String.isEmpty(boltOnTariffName)?'':',') + '\''+selectedBoltOnTariffName+'\'';
        }
        if (!boltOnTariffClass.contains('\''+selectedBoltOnTariffClass+'\'')) {
            boltOnTariffClass += (String.isEmpty(boltOnTariffClass)?'':',') + '\''+selectedBoltOnTariffClass+'\'';
        }
        return null;
    }
    // Clear Accessory
    public PageReference clearAccessory(){
        accessorySKU = '';
        return null;
    }
    // Clear Handset
    public PageReference clearHandset(){
        handsetSKU = '';
        return null;
    }
    // Clear Tariff
    public PageReference clearTariff(){
        tariffKey = '';
        tariffName = '';
        tariffClass = '';
        return null;
    }
    // Clear Sim Only Tariff
    public PageReference clearSimOnlyTariff(){
        simOnlyTariffKey = '';
        simOnlyTariffName = '';
        simOnlyTariffClass = '';
        return null;
    }
    // Clear Bolt On Tariff
    public PageReference clearBoltOnTariff(){
        boltOnTariffKey = '';
        boltOnTariffName = '';
        boltOnTariffClass = '';
        return null;
    }




    // CREATE methods


    //
    public PageReference createOffers(){
        // Create a query string
        String queryString = null;
        // --------
        // Select all Handset selections that have:
        // Active = True
        // Handset class != SIM
        // Channel = Online
        queryString = 'select '+Utility.getSobjectFields('O2_DISE_Map_Handset_Selection__c')+
                      ' from O2_DISE_Map_Handset_Selection__c '+
                      ' where Handset_class__c != \'SIM\' and active__c = true and Channel__c = \'Online\'';
        system.debug('Running query: '+queryString);
        List<O2_DISE_Map_Handset_Selection__c> handsetSelectionList = Database.query(queryString);
        system.debug('****handsetSelectionList.size():'+handsetSelectionList.size());
        // Create a Map of Handset Selections
        Map<String,O2_DISE_Map_Handset_Selection__c> handsetSelectionByProductRefMap = new Map<String,O2_DISE_Map_Handset_Selection__c>();
        for (O2_DISE_Map_Handset_Selection__c elem : handsetSelectionList) {
            handsetSelectionByProductRefMap.put(elem.Product_Ref__c,elem);
        }
        system.debug('****handsetSelectionByProductRefMap.size():'+handsetSelectionByProductRefMap.keySet().size());
        //
        // --------
        // Select all Mobile Tariffs:
        queryString = 'select '+Utility.getSobjectFields('O2_DISE_Map_Mobile__c')+
                      ' from O2_DISE_Map_Mobile__c '+
                      ' where Contract_Length__c = \'24\' and Roaming__c = \'--None--\''+
                      ' and Product_Definition__c = \'Business Single\''+
                      ' and Contract_type__c = \'Handset\' and Handset_Tariff_Class__c != \'Blackberry BES\' and Primary_Additional__c = \'Primary\'';
        if (!String.isEmpty(tariffKey)) {
            queryString += ' and Name in ('+tariffName+') ';
            queryString += ' and Handset_Tariff_Class__c in ('+tariffClass+') ';
        }
        system.debug('Running query: '+queryString);
        List<O2_DISE_Map_Mobile__c> allMobileTariffList = Database.query(queryString);
        system.debug('****allMobileTariffList.size():'+allMobileTariffList.size());
        //
        Map<String,O2_DISE_Map_Mobile__c> TariffByNameMap = new Map<String,O2_DISE_Map_Mobile__c>();
        for (O2_DISE_Map_Mobile__c tariff : allMobileTariffList) {
            String mapKey = tariff.Name+':-:'+tariff.Handset_Tariff_Class__c+':-:'+tariff.Flavour__c+':-:'+
                            tariff.Core_Data_Bolton__c+':-:'+tariff.Promotion__c;
            if (TariffByNameMap.containsKey(mapKey)) system.debug('*****');
            TariffByNameMap.put(mapKey,tariff);
            system.debug('Tariff object: '+tariff);
            system.debug('mapKey: '+mapKey);
        }
        system.debug('****TariffByNameMap.size():'+TariffByNameMap.keySet().size());
        //
        // --------
        // Select all Handsets:
        queryString = 'select '+Utility.getSobjectFields('O2_DISE_Map_Handset__c')+
                      ' from O2_DISE_Map_Handset__c ';
        if (!String.isEmpty(handsetSKU)) {
            queryString += ' where Product_Code__c in ('+handsetSKU+') ';
        }
        queryString += limitRows;
        system.debug('Running query: '+queryString);
        List<O2_DISE_Map_Handset__c> allHandsetList = Database.query(queryString);
        system.debug('****allHandsetList.size():'+allHandsetList.size());
        //
        List<cscfgc__Configuration_Offer__c> offerToBeCreatedList = new List<cscfgc__Configuration_Offer__c>();
        Integer i = 0;
        for (O2_DISE_Map_Handset__c handset : allHandsetList) {
            String handsetClass = handset.Handset_Class__c;
            if (handsetClass == 'BLACKBERRY') handsetClass = 'Blackberry BIS';
            String mapKey = handset.Base_Tariff__c+':-:'+handsetClass;
            system.debug('>>>>mapKey: '+mapKey);
            for (String key : TariffByNameMap.keySet()) {
                if (key.startsWith(mapKey)) {
                    // We should create an offer for this combination
                    // First without insurance
                    if (handsetSelectionByProductRefMap.containsKey(handset.Product_Code__c)) {
                        offerToBeCreatedList.add(new cscfgc__Configuration_Offer__c(Name='Online Offer '+i,
                                                                                    O2_DISE_Map_Mobile__c = TariffByNameMap.get(key).Id,
                                                                                    O2_DISE_Map_Handset__c = handset.Id,
                                                                                    O2_DISE_Map_Handset_Selection__c = handsetSelectionByProductRefMap.get(handset.Product_Code__c).Id,
                                                                                    Insurance__c = false));
                        i++;
                        // Second with insurance
                        offerToBeCreatedList.add(new cscfgc__Configuration_Offer__c(Name='Online Offer '+i,
                                                                                    O2_DISE_Map_Mobile__c = TariffByNameMap.get(key).Id,
                                                                                    O2_DISE_Map_Handset__c = handset.Id,
                                                                                    O2_DISE_Map_Handset_Selection__c = handsetSelectionByProductRefMap.get(handset.Product_Code__c).Id,
                                                                                    Insurance__c = true));
                        i++;
                        system.debug('>>>>Combination: '+TariffByNameMap.get(key).Id+' - '+handset.Id);
                    }
                }
            }
        }
        system.debug('****offerToBeCreatedList.size():'+offerToBeCreatedList.size());
        insert offerToBeCreatedList;
        system.debug('*>*>*offerToBeCreatedList: '+offerToBeCreatedList);
        //
        // --------
        // Create an Offer Category Association for each offer to 'Bulk Offers':
        queryString = 'select Id '+
                      ' from cscfgc__Product_Category__c '+
                      ' where Name = \'Bulk Offers\' '+
                      ' limit 1 ';
        system.debug('Running query: '+queryString);
        cscfgc__Product_Category__c bulkOffersCategory = Database.query(queryString);
        system.debug('****bulkOffersCategory:'+bulkOffersCategory);
        //
        List<cscfgc__Offer_Category_Association__c> newAssociationsList = new List<cscfgc__Offer_Category_Association__c>();
        for (cscfgc__Configuration_Offer__c offer : offerToBeCreatedList) {
            newAssociationsList.add( new cscfgc__Offer_Category_Association__c( cscfgc__Product_Category__c = bulkOffersCategory.Id,
                                                                                cscfgc__Configuration_Offer__c = offer.Id
                                                                                ));
        }
        system.debug('****newAssociationsList.size():'+newAssociationsList.size());
        insert newAssociationsList;
        system.debug('*>*>*newAssociationsList: '+newAssociationsList);
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationBatchAsync generateOffers = new OfferGenerationBatchAsync();
        //
        // --------
        // Select all Handsets that have:
        // Product Code = a selected handset Selection's Product Ref
        generateOffers.query = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                               ' from cscfgc__Configuration_Offer__c '+
                               ' where O2_DISE_Map_Mobile__c != \'\' and O2_DISE_Map_Handset__c != \'\'';
        if (!String.isEmpty(handsetSKU)) {
            generateOffers.query += ' and O2_DISE_Map_Handset__r.Product_Code__c in ('+handsetSKU+') ';
        }
        if (!String.isEmpty(tariffKey)) {
            generateOffers.query += ' and O2_DISE_Map_Mobile__r.Name in ('+tariffName+') ';
            generateOffers.query += ' and O2_DISE_Map_Mobile__r.Handset_Tariff_Class__c in ('+tariffClass+') ';
        }
        if (Test.isRunningTest()) {
            String str = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                         ' from cscfgc__Configuration_Offer__c Where Id in (';
            for (cscfgc__Configuration_Offer__c co :offerToBeCreatedList) {
                str += '\'' + co.Id + '\',';
            }
            str = str.substring(0, str.length()-1);
            str += ') LIMIT 1'; // Limit to batch size
            generateOffers.query = str;
        }
        system.debug('**>**>**Handset soql passed to batch: '+generateOffers.query);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Creating '+offerToBeCreatedList.size()+' Handset Offers.'));
        Database.executeBatch(generateOffers, 1);
        //
        return null;
    }

    //
    public PageReference createSimOnlyOffers(){
        // Create a query string
        String queryString = null;
        //
        // --------
        queryString = 'select '+Utility.getSobjectFields('O2_DISE_Map_Mobile__c')+
                      ' from O2_DISE_Map_Mobile__c '+
                      ' where Roaming__c = \'--None--\' '+
                      ' and Product_Definition__c = \'Business Single\' '+
                      ' and Contract_type__c != \'Handset\' and Handset_Tariff_Class__c != \'Blackberry BES\' and Primary_Additional__c = \'Primary\' ';
        if (!String.isEmpty(simOnlyTariffKey)) {
            queryString += ' and Name in ('+simOnlyTariffName+') ';
            queryString += ' and Handset_Tariff_Class__c in ('+simOnlyTariffClass+') ';
        }
        queryString += limitrows;
        List<O2_DISE_Map_Mobile__c> allMobileTariffList = Database.query(queryString);
        system.debug('****allMobileTariffList.size():'+allMobileTariffList.size());
        //
        List<cscfgc__Configuration_Offer__c> offerToBeCreatedList = new List<cscfgc__Configuration_Offer__c>();
        Integer i = 0;
        for (O2_DISE_Map_Mobile__c tariff : allMobileTariffList) {
                    // We should create an offer for this combination
                    // First with SIM
                    offerToBeCreatedList.add(new cscfgc__Configuration_Offer__c(Name='Online SIM Only Offer '+i,
                                                                                O2_DISE_Map_Mobile__c = tariff.Id,
                                                                                SIM_Type__c = '24GPUNIN'));
                    i++;
                    // Second with Micro-SIM
                    offerToBeCreatedList.add(new cscfgc__Configuration_Offer__c(Name='Online SIM Only Offer '+i,
                                                                                O2_DISE_Map_Mobile__c = tariff.Id,
                                                                                SIM_Type__c = '24G3FFVN'));
                    i++;
                    // Third with Nano-SIM
                    offerToBeCreatedList.add(new cscfgc__Configuration_Offer__c(Name='Online SIM Only Offer '+i,
                                                                                O2_DISE_Map_Mobile__c = tariff.Id,
                                                                                SIM_Type__c = '24G4FFVN'));
                    system.debug('>>>>Combination: '+tariff.Id);
        }
        system.debug('****offerToBeCreatedList.size():'+offerToBeCreatedList.size());
        insert offerToBeCreatedList;
        system.debug('*>*>*offerToBeCreatedList: '+offerToBeCreatedList);
        //
        // --------
        // Create an Offer Category Association for each offer to 'Bulk Offers':
        queryString = 'select Id '+
                      ' from cscfgc__Product_Category__c '+
                      ' where Name = \'Bulk Offers\' '+
                      ' limit 1 ';
        system.debug('Running query: '+queryString);
        cscfgc__Product_Category__c bulkOffersCategory = Database.query(queryString);
        system.debug('****bulkOffersCategory:'+bulkOffersCategory);
        //
        List<cscfgc__Offer_Category_Association__c> newAssociationsList = new List<cscfgc__Offer_Category_Association__c>();
        for (cscfgc__Configuration_Offer__c offer : offerToBeCreatedList) {
            newAssociationsList.add( new cscfgc__Offer_Category_Association__c( cscfgc__Product_Category__c = bulkOffersCategory.Id,
                                                                                cscfgc__Configuration_Offer__c = offer.Id
                                                                                ));
        }
        system.debug('****newAssociationsList.size():'+newAssociationsList.size());
        insert newAssociationsList;
        system.debug('*>*>*newAssociationsList: '+newAssociationsList);
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationSimOnlyBatchAsync generateSimOnlyOffers = new OfferGenerationSimOnlyBatchAsync();
        //
        // --------
        // Select all Handsets that have:
        // Product Code = a selected handset Selection's Product Ref
        generateSimOnlyOffers.query = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                                      ' from cscfgc__Configuration_Offer__c Where O2_DISE_Map_Mobile__c != \'\' and SIM_Type__c != \'\' ';
        if (!String.isEmpty(simOnlyTariffKey)) {
            generateSimOnlyOffers.query += ' and O2_DISE_Map_Mobile__r.Name in ('+simOnlyTariffName+') ';
            generateSimOnlyOffers.query += ' and O2_DISE_Map_Mobile__r.Handset_Tariff_Class__c in ('+simOnlyTariffClass+') ';
        }
        if (Test.isRunningTest()) {
            String str = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                         ' from cscfgc__Configuration_Offer__c Where Id in (';
            for (cscfgc__Configuration_Offer__c co :offerToBeCreatedList) {
                str += '\'' + co.Id + '\',';
            }
            str = str.substring(0, str.length()-1);
            str += ') LIMIT 1'; // Limit to batch size
            generateSimOnlyOffers.query = str;
        }
        system.debug('**>**>**Sim Only soql passed to batch: '+generateSimOnlyOffers.query);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Creating '+offerToBeCreatedList.size()+' SIM Only Offers.'));
        Database.executeBatch(generateSimOnlyOffers, 1);
        //
        return null;
    }

    //
    public PageReference createAccessoryOffers(){
        // Create a query string
        String queryString = null;
        //
        // --------
        // Select all Accessories that have:
        queryString = 'select '+Utility.getSobjectFields('O2_DISE_Ref_Hardware_Relation__c')+
                      ' from O2_DISE_Ref_Hardware_Relation__c '+
                      ' where active__c = true and child_hardware_type__c = \'Accessory\' ';
        if (!String.isEmpty(accessorySKU)) {
            queryString += ' and Child_Product_Code_Product_Code__c IN ('+accessorySKU+') ';
        }
        if (!String.isEmpty(handsetSKU)) {
            queryString += ' and Parent_Product_Code__r.Product_Code__c IN ('+handsetSKU+') ';
        }
        queryString += limitrows;
        List<O2_DISE_Ref_Hardware_Relation__c> allAccessoryList = Database.query(queryString);
        system.debug('****allAccessoryList.size():'+allAccessoryList.size());
        //
        /*********************************
        Map<String,O2_DISE_Ref_Hardware_Relation__c> AccessoryByProductCodeMap = new Map<String,O2_DISE_Ref_Hardware_Relation__c>();
        for (O2_DISE_Ref_Hardware_Relation__c accessory : allAccessoryList) {
            String mapKey = accessory.Child_Product_Code__c;
            AccessoryByProductCodeMap.put(mapKey,accessory);
        }
        system.debug('****AccessoryByProductCodeMap.size():'+AccessoryByProductCodeMap.keySet().size());
        **********************************/
        //
        List<cscfgc__Configuration_Offer__c> offerToBeCreatedList = new List<cscfgc__Configuration_Offer__c>();
        Integer j = 0;
        for (O2_DISE_Ref_Hardware_Relation__c accessory : allAccessoryList) {
            for (Integer i = 1; i < 4; i++) {
                // We should create an offer for this combination for quantities 1, 2 and 3
                offerToBeCreatedList.add(new cscfgc__Configuration_Offer__c(Name='Online Accessory Offer '+j,
                                                                                O2_DISE_Ref_Hardware_Relation__c = accessory.Id,
                                                                                O2_DISE_Ref_Hardware_Portfolio__c = accessory.Child_Product_Code__c,
                                                                                Quantity_of_Accessory__c = i));
                system.debug('>>>>Combination: '+accessory.Id+':Quantity='+i);
                j++;
            }
        }
        system.debug('****offerToBeCreatedList.size():'+offerToBeCreatedList.size());
        insert offerToBeCreatedList;
        system.debug('*>*>*offerToBeCreatedList: '+offerToBeCreatedList);
        //
        // --------
        // Create an Offer Category Association for each offer to 'Bulk Offers':
        queryString = 'select Id '+
                      ' from cscfgc__Product_Category__c '+
                      ' where Name = \'Bulk Offers\' '+
                      ' limit 1 ';
        system.debug('Running query: '+queryString);
        cscfgc__Product_Category__c bulkOffersCategory = Database.query(queryString);
        system.debug('****bulkOffersCategory:'+bulkOffersCategory);
        //
        List<cscfgc__Offer_Category_Association__c> newAssociationsList = new List<cscfgc__Offer_Category_Association__c>();
        for (cscfgc__Configuration_Offer__c offer : offerToBeCreatedList) {
            newAssociationsList.add( new cscfgc__Offer_Category_Association__c( cscfgc__Product_Category__c = bulkOffersCategory.Id,
                                                                                cscfgc__Configuration_Offer__c = offer.Id
                                                                                ));
        }
        system.debug('****newAssociationsList.size():'+newAssociationsList.size());
        insert newAssociationsList;
        system.debug('*>*>*newAssociationsList: '+newAssociationsList);
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationAccessoriesBatchAsync generateAccessoryOffers = new OfferGenerationAccessoriesBatchAsync();
        //
        // --------
        // Select all Handsets that have:
        // Product Code = a selected handset Selection's Product Ref
        generateAccessoryOffers.query = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                                        ' from cscfgc__Configuration_Offer__c '+
                                        ' where O2_DISE_Ref_Hardware_Relation__c != \'\'';
        if (!String.isEmpty(accessorySKU)) {
            generateAccessoryOffers.query += ' and O2_DISE_Ref_Hardware_Relation__r.Child_Product_Code_Product_Code__c IN ('+accessorySKU+')';
        }
        if (!String.isEmpty(handsetSKU)) {
            generateAccessoryOffers.query += ' and O2_DISE_Ref_Hardware_Relation__r.Parent_Product_Code__r.Product_Code__c IN ('+handsetSKU+')';
        }
        if (Test.isRunningTest()) {
            String str = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                         ' from cscfgc__Configuration_Offer__c Where Id in (';
            for (cscfgc__Configuration_Offer__c co :offerToBeCreatedList) {
                str += '\'' + co.Id + '\',';
            }
            str = str.substring(0, str.length()-1);
            str += ') LIMIT 1'; // Limit to batch size
            generateAccessoryOffers.query = str;
        }
        system.debug('**>**>**Accessory soql passed to batch: '+generateAccessoryOffers.query);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Creating '+offerToBeCreatedList.size()+' Accessory Offers.'));
        Database.executeBatch(generateAccessoryOffers, 1);
        //
        return null;
    }

    //
    public PageReference createBoltOnOffers(){
        // Create a query string
        String queryString = null;
        //
        // --------
        // Select all Bolt Ons:
        queryString = 'select '+Utility.getSobjectFields('O2_DISE_Map_Mobile_Bolton__c')+
                      ' from O2_DISE_Map_Mobile_Bolton__c '+
                      ' where Bolt_On_Type__c in (\'DATA BOLTON\',\'INTERNATIONAL FAVOURITES\',\'FOUR G ACCESS\')'+
                      ' and Tariff_Description__c != \'Additional User\' and (not Tariff_Description__c  like \'%Share%\')'+
                      ' and (not Tariff_Description__c  like \'%lease%\')'+
                      ' and (not Tariff_Description__c  like \'%12 Month%\') ';
        if (!String.isEmpty(boltOnTariffKey)) {
            queryString += ' and Bolt_On_Type__c in ('+boltOnTariffName+') ';
            queryString += ' and Tariff_Description__c in ('+boltOnTariffClass+') ';
        }
        queryString += limitrows;
        system.debug('****queryString: '+queryString);
        List<O2_DISE_Map_Mobile_Bolton__c> allBoltOnList = Database.query(queryString);
        /*****
        List<O2_DISE_Map_Mobile_Bolton__c> allBoltOnList =
                [select Recurring_OneOff__c,Bolt_On_Type__c,Bolt_On_Key__c,Effective_Date__c,
                MultiSelect_Sequence__c,Extra_Shared_Users__c,Price__c,CreatedDate,OwnerId,Extra_Shared_Users_Min__c,
                CreatedById,LastModifiedDate,Distinct_Service_Name__c,Id,Tariff_Code__c,Service_Code__c,IsDeleted,Name,
                Tariff_Description__c,SystemModstamp,Expiry_Date__c,LastModifiedById,Event_Value__c
                from O2_DISE_Map_Mobile_Bolton__c
                Where Bolt_On_Type__c in ('DATA BOLTON','INTERNATIONAL FAVOURITES','OFF PEAK MINUTES')
                and Tariff_Description__c != 'Additional User' and (not Tariff_Description__c  like '%Share%')
                and (not Tariff_Description__c  like '%lease%')and (not Tariff_Description__c  like '%12 Month%') Limit 100];
        *****/
        system.debug('****allBoltOnList.size():'+allBoltOnList.size());
        //
        List<cscfgc__Configuration_Offer__c> offerToBeCreatedList = new List<cscfgc__Configuration_Offer__c>();
        Integer i = 0;
        for (O2_DISE_Map_Mobile_Bolton__c boltOn : allBoltOnList) {
            offerToBeCreatedList.add(new cscfgc__Configuration_Offer__c(Name='Online BoltOn Offer '+i,
                                                                        O2_DISE_Map_Mobile_Bolton__c = boltOn.Id));
            system.debug('>>>>Offer for: '+boltOn.Id);
            i++;
        }
        system.debug('****offerToBeCreatedList.size():'+offerToBeCreatedList.size());
        insert offerToBeCreatedList;
        system.debug('*>*>*offerToBeCreatedList: '+offerToBeCreatedList);
        //
        // --------
        // Create an Offer Category Association for each offer to 'Bulk Offers':
        queryString = 'select Id '+
                      ' from cscfgc__Product_Category__c '+
                      ' where Name = \'Bulk Offers\' '+
                      ' limit 1 ';
        system.debug('Running query: '+queryString);
        cscfgc__Product_Category__c bulkOffersCategory = Database.query(queryString);
        system.debug('****bulkOffersCategory:'+bulkOffersCategory);
        //
        List<cscfgc__Offer_Category_Association__c> newAssociationsList = new List<cscfgc__Offer_Category_Association__c>();
        for (cscfgc__Configuration_Offer__c offer : offerToBeCreatedList) {
            newAssociationsList.add( new cscfgc__Offer_Category_Association__c( cscfgc__Product_Category__c = bulkOffersCategory.Id,
                                                                                cscfgc__Configuration_Offer__c = offer.Id
                                                                                ));
        }
        system.debug('****newAssociationsList.size():'+newAssociationsList.size());
        insert newAssociationsList;
        system.debug('*>*>*newAssociationsList: '+newAssociationsList);
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationBoltOnBatchAsync generateBoltOnOffers = new OfferGenerationBoltOnBatchAsync();
        //
        // --------
        // Select all Handsets that have:
        // Product Code = a selected handset Selection's Product Ref
        generateBoltOnOffers.query = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                                     ' from cscfgc__Configuration_Offer__c Where O2_DISE_Map_Mobile_Bolton__c != \'\' ';
        if (!String.isEmpty(boltOnTariffKey)) {
            generateBoltOnOffers.query += ' and O2_DISE_Map_Mobile_Bolton__r.Bolt_On_Type__c in ('+boltOnTariffName+') ';
            generateBoltOnOffers.query += ' and O2_DISE_Map_Mobile_Bolton__r.Tariff_Description__c in ('+boltOnTariffClass+') ';
        }
        if (Test.isRunningTest()) {
            generateBoltOnOffers.query = 'select '+Utility.getSobjectFields('cscfgc__Configuration_Offer__c')+
                                         ' from cscfgc__Configuration_Offer__c Where Id = \''+offerToBeCreatedList[0].id + '\'';
        }
        system.debug('**>**>**Boltons soql passed to batch: '+generateBoltOnOffers.query);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Creating '+offerToBeCreatedList.size()+' Bolt On Offers.'));
        Database.executeBatch(generateBoltOnOffers, 1);
        //
        return null;
    }



    // DELETE methods


    // Delete ALL Offers (Handset, SIM-only, Accessory, Bolt-on)
    public PageReference deleteOnlineOffers() {
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationDelOnlineOffersBatchAsync deleteAllOffers = new OfferGenerationDelOnlineOffersBatchAsync();
        deleteAllOffers.deleteType = 'ALL';
        //
        // --------
        // Select all Offers that have:
        // an O2_DISE_?? field with a value
        deleteAllOffers.query = 'select id,'+
                            ' (select id from cscfgc__Product_Configurations__r)'+
                            ' from cscfgc__Configuration_Offer__c '+
                            ' where O2_DISE_Map_Mobile__c != \'\' or O2_DISE_Map_Handset__c != \'\''+
                            ' or O2_DISE_Ref_Hardware_Relation__c != \'\' or O2_DISE_Map_Mobile_Bolton__c != \'\' ';
        if (Test.isRunningTest()) {
            deleteAllOffers.query += ' LIMIT 10';
        }
        system.debug('**>**>** deleteOnlineOffers');
        system.debug('**>**>**Handset soql passed to batch: '+deleteAllOffers.query);
        Integer i = Database.countQuery('select count() '+deleteAllOffers.query.substring(deleteAllOffers.query.LastIndexOf(' from ')));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deleting '+i+' Offers.'));
        //if (i > 0)
        Database.executeBatch(deleteAllOffers, 100); // reduce if deleting this many in one go breaks SFDC limits
        //
        return null;
    }

    // Delete HANDSET - can take handset sku(s)
    public PageReference deleteHandsetOffers(){
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationDelOnlineOffersBatchAsync deleteHandsetOffers = new OfferGenerationDelOnlineOffersBatchAsync();
        deleteHandsetOffers.deleteType = 'Handset';
        //
        // --------
        // Select all Handset Offers that have:
        deleteHandsetOffers.query = 'select id,'+
                            ' (select id from cscfgc__Product_Configurations__r)'+
                            ' from cscfgc__Configuration_Offer__c '+
                            ' where O2_DISE_Map_Mobile__c != \'\' and O2_DISE_Map_Handset__c != \'\' ';
        if (!String.isEmpty(handsetSKU)) {
            deleteHandsetOffers.query += ' and O2_DISE_Map_Handset__r.Product_Code__c in ('+handsetSKU+') ';
        }
        if (!String.isEmpty(tariffKey)) {
            deleteHandsetOffers.query += ' and O2_DISE_Map_Mobile__r.Name in ('+tariffName+') ';
            deleteHandsetOffers.query += ' and O2_DISE_Map_Mobile__r.Handset_Tariff_Class__c in ('+tariffClass+') ';
        }
        if (Test.isRunningTest()) {
            deleteHandsetOffers.query += ' LIMIT 10';
        }
        system.debug('**>**>** deleteHandsetOffers');
        system.debug('**>**>**Handset soql passed to batch: '+deleteHandsetOffers.query);
        Integer i = Database.countQuery('select count() '+deleteHandsetOffers.query.substring(deleteHandsetOffers.query.LastIndexOf(' from ')));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deleting '+i+' Handset Offers.'));
        //if (i > 0)
        Database.executeBatch(deleteHandsetOffers, 100); // reduce if deleting this many in one go breaks SFDC limits
        //
        return null;
    }

    // Delete SIM ONLY
    public PageReference deleteSimOnlyOffers(){
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationDelOnlineOffersBatchAsync deleteSimOnlyOffers = new OfferGenerationDelOnlineOffersBatchAsync();
        deleteSimOnlyOffers.deleteType = 'SIM-Only';
        //
        // --------
        // Select all Sim Only Offers that have:
        deleteSimOnlyOffers.query = 'select id,'+
                            ' (select id from cscfgc__Product_Configurations__r)'+
                            ' from cscfgc__Configuration_Offer__c '+
                            ' where O2_DISE_Map_Mobile__c != \'\' and SIM_Type__c != \'\' ';
        if (!String.isEmpty(simOnlyTariffKey)) {
            deleteSimOnlyOffers.query += ' and O2_DISE_Map_Mobile__r.Name in ('+simOnlyTariffName+') ';
            deleteSimOnlyOffers.query += ' and O2_DISE_Map_Mobile__r.Handset_Tariff_Class__c in ('+simOnlyTariffClass+') ';
        }
        if (Test.isRunningTest()) {
            deleteSimOnlyOffers.query += ' LIMIT 10';
        }
        system.debug('**>**>** deleteSimOnlyOffers');
        system.debug('**>**>**Handset soql passed to batch: '+deleteSimOnlyOffers.query);
        Integer i = Database.countQuery('select count() '+deleteSimOnlyOffers.query.substring(deleteSimOnlyOffers.query.LastIndexOf(' from ')));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deleting '+i+' SIM Only Offers.'));
        //if (i > 0)
        Database.executeBatch(deleteSimOnlyOffers, 100); // reduce if deleting this many in one go breaks SFDC limits
        //
        return null;
    }

    // Delete ACCESSORY - can take accessory or handset sku(s)
    public PageReference deleteAccessoryOffers(){
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationDelOnlineOffersBatchAsync deleteAccessoryOffers = new OfferGenerationDelOnlineOffersBatchAsync();
        deleteAccessoryOffers.deleteType = 'Accessory';
        //
        // --------
        // Select all Accessory Offers that have:
        deleteAccessoryOffers.query = 'select id,'+
                            ' (select id from cscfgc__Product_Configurations__r)'+
                            ' from cscfgc__Configuration_Offer__c '+
                            ' where O2_DISE_Ref_Hardware_Relation__c != \'\' ';
        if (!String.isEmpty(accessorySKU)) {
            deleteAccessoryOffers.query += ' and O2_DISE_Ref_Hardware_Relation__r.Child_Product_Code_Product_Code__c IN ('+accessorySKU+') ';
        }
        if (!String.isEmpty(handsetSKU)) {
            deleteAccessoryOffers.query += ' and O2_DISE_Ref_Hardware_Relation__r.Parent_Product_Code__r.Product_Code__c IN ('+handsetSKU+') ';
        }
        if (Test.isRunningTest()) {
            deleteAccessoryOffers.query += ' LIMIT 10';
        }
        system.debug('**>**>** deleteAccessoryOffers');
        system.debug('**>**>**Handset soql passed to batch: '+deleteAccessoryOffers.query);
        Integer i = Database.countQuery('select count() '+deleteAccessoryOffers.query.substring(deleteAccessoryOffers.query.LastIndexOf(' from ')));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deleting '+i+' Accessory Offers.'));
        //if (i > 0)
        Database.executeBatch(deleteAccessoryOffers, 100); // reduce if deleting this many in one go breaks SFDC limits
        //
        return null;
    }

    // Delete BOLT ON
    public PageReference deleteBoltOnOffers(){
        //
        // --------
        // Instantiate the batch class:
        OfferGenerationDelOnlineOffersBatchAsync deleteBoltOnOffers = new OfferGenerationDelOnlineOffersBatchAsync();
        deleteBoltOnOffers.deleteType = 'Bolt-On';
        //
        // --------
        // Select all Bolt-on Offers that have:
        deleteBoltOnOffers.query = 'select id,'+
                            ' (select id from cscfgc__Product_Configurations__r) '+
                            ' from cscfgc__Configuration_Offer__c '+
                            ' where O2_DISE_Map_Mobile_Bolton__c != \'\' ';
        if (!String.isEmpty(boltOnTariffKey)) {
            deleteBoltOnOffers.query += ' and O2_DISE_Map_Mobile_Bolton__r.Bolt_On_Type__c in ('+boltOnTariffName+') ';
            deleteBoltOnOffers.query += ' and O2_DISE_Map_Mobile_Bolton__r.Tariff_Description__c in ('+boltOnTariffClass+') ';
        }
        if (Test.isRunningTest()) {
            deleteBoltOnOffers.query += ' LIMIT 10';
        }
        system.debug('**>**>** deleteBoltOnOffers');
        system.debug('**>**>**Handset soql passed to batch: '+deleteBoltOnOffers.query);
        Integer i = Database.countQuery('select count() '+deleteBoltOnOffers.query.substring(deleteBoltOnOffers.query.LastIndexOf(' from ')));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deleting '+i+' Bolt On Offers.'));
        //if (i > 0)
        Database.executeBatch(deleteBoltOnOffers, 100); // reduce if deleting this many in one go breaks SFDC limits
        //
        return null;
    }

}