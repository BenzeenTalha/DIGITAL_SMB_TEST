global class O2OnlineMobileController {

    public O2OnlineMainController maincontroller {get;set;}
    public O2OnlineMobileController() {}

    public O2OnlineMobileController(O2OnlineMainController controller) {
        this.maincontroller = controller;
        if (ApexPages.currentPage().getParameters().get('cp')!=null && ApexPages.currentPage().getParameters().get('cp')!='') this.selectedCost = ApexPages.currentPage().getParameters().get('cp');
        if (ApexPages.currentPage().getParameters().get('pm')!=null && ApexPages.currentPage().getParameters().get('pm')!='') this.selectedMinutes = ApexPages.currentPage().getParameters().get('pm');
        if (ApexPages.currentPage().getParameters().get('pc')!=null && ApexPages.currentPage().getParameters().get('pc')!='') this.selectedProductCode = ApexPages.currentPage().getParameters().get('pc');
        if (ApexPages.currentPage().getParameters().get('br')!=null && ApexPages.currentPage().getParameters().get('br')!='') this.selectedBrand = ApexPages.currentPage().getParameters().get('br');
        //if (ApexPages.currentPage().getParameters().get('so')!=null && ApexPages.currentPage().getParameters().get('so')!='') this.selectSimOnly = Boolean.valueOf(ApexPages.currentPage().getParameters().get('so'));
        if (ApexPages.currentPage().getParameters().get('hc')!=null && ApexPages.currentPage().getParameters().get('hc')!='') this.selectedHSClass = ApexPages.currentPage().getParameters().get('hc');
        if (ApexPages.currentPage().getParameters().get('so')!=null && ApexPages.currentPage().getParameters().get('so')!='') this.selectedTariffType = ApexPages.currentPage().getParameters().get('so');
        if (ApexPages.currentPage().getParameters().get('pr')!=null && ApexPages.currentPage().getParameters().get('pr')!='') this.selectedPromo = ApexPages.currentPage().getParameters().get('pr');
        if (ApexPages.currentPage().getParameters().get('pr')!=null && ApexPages.currentPage().getParameters().get('pr')!='') this.selectedPromo = ApexPages.currentPage().getParameters().get('pr');
        if (ApexPages.currentPage().getParameters().get('only4g')!=null && ApexPages.currentPage().getParameters().get('only4g')!='') this.ShowOnly4GPhones = ApexPages.currentPage().getParameters().get('only4g') == '1';
    }

    public class O2OnlineMobileException extends Exception {}

    public O2OnlineMobileController getMobileController() {return this;}

    public boolean ShowOnly4GPhones{
        get {
            if (ShowOnly4GPhones == null)
                return false;
            else
                return ShowOnly4GPhones;
        }
        set;
    }

    public List<O2_Reference_Codes__c> refCodes {
        get {if (refCodes == null) return O2_Reference_Codes__c.getAll().values(); else return refCodes;}
        set;
    }
    public String selectedHSClass {
        get {if (selectedHSClass == null) return defaultHSClass; else return selectedHSClass;}
        set;
    }
    public String defaultHSClass {
        get {
            String retValue = '';
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'DEVICECLASS' && !ref.Inactive__c) {if (defaultHSClass==null && ref.Default__c) retValue = ref.Code__c;}
            }
            return retValue;
        }
        set;
    }
    public List<SelectOption> getHSClasses() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'DEVICECLASS' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {opt.add(new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c));}
        return opt;
    }
    public String selectedCost {
        get {if (selectedCost == null) return ''; else return selectedCost;}
        set;
    }
    public List<SelectOption> getHSCosts() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'TARIFFCOST' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {opt.add(new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c));}
        return opt;
    }
    public String selectedMinutes {
        get {if (selectedMinutes==null) return ''; else return selectedMinutes;}
        set;
    }
    public List<SelectOption> getHSMinutes() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'TARIFFMINUTES' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {opt.add(new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c));}
        return opt;
    }
    public String selectedTexts {
        get {if (selectedTexts==null) return ''; else return selectedTexts;}
        set;
    }
/* TODO - Are getHSTexts() and selectedTexts() required??
    public List<SelectOption> getHSTexts() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'TARIFFTEXTS' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {opt.add(new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c));}
        return opt;
    }*/
    public String selectedData {
        get {if (selectedData==null) return ''; else return selectedData;}
        set;
    }
    public List<SelectOption> getHSData() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'TARIFFDATA' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {
            SelectOption newOpt = new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c);
            newOpt.setEscapeItem(false);
            opt.add(newOpt);
        }
        return opt;
    }
    public List<O2_Reference_Codes__c> getAvailableBoltOns() {
        List<O2_Reference_Codes__c> retCodes = new List<O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {if (ref.Type__c == 'SINGLEBOLTON' && !ref.Inactive__c) retCodes.add(ref);}
        }
        return retCodes;
    }

    //public String[] selectedBoltonFilters = new String[] {};
    //public String[] getSelectedBoltonFilters() {return selectedBoltonFilters;}
    //public void setSelectedboltonFilters(String[] s) {selectedBoltonFilters = s;}

    public static final String TARIFF_SOBJECT_PREFIX = O2_Dise_Map_Mobile__c.SObjectType.getDescribe().getKeyPrefix();
    public static final String DEVICE_SOBJECT_PREFIX = O2_Dise_Map_Handset_Selection__c.SObjectType.getDescribe().getKeyPrefix();
    public static final String BOLTON_SOBJECT_PREFIX = O2_Dise_Map_Mobile_Bolton__c.SObjectType.getDescribe().getKeyPrefix();
    public static final String ACCESSORY_SOBJECT_PREFIX = O2_Dise_Ref_Hardware_Relation__c.SObjectType.getDescribe().getKeyPrefix();

    public List<SelectOption> getFilterBoltons() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                  //System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getFilterBoltons: reference code:'+ref);
                if (ref.Type__c == 'FILTERBOLTON' && !ref.Inactive__c)
                {
                    mpCodes.put(ref.Sequence__c+ref.Code__c, ref);
                      System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getFilterBoltons: ref added to map in key:'+ref.Sequence__c+ref.Code__c+', ref:'+ref);
                  }
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {
            SelectOption newOpt = new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c);
            newOpt.setEscapeItem(false);
            opt.add(newOpt);
              System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getFilterBoltons: creating select option:'+newOpt);
        }
        return opt;
    }

    public String selectedPromo {
        get {if (selectedPromo == null) return ''; else return selectedPromo;}
        set;
    }
    public List<SelectOption> getFilterPromo() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                //If not Sim-Only
                if(selectedTariffType == defaultTariffType){
                    if (ref.Type__c == 'FILTERPROMO' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
                } else {
                    if (ref.Type__c == 'FILTERPROMOSIMONLY' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
                }
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {
            SelectOption newOpt = new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c);
            newOpt.setEscapeItem(false);
            opt.add(newOpt);
        }
        return opt;
    }

    public Boolean selectInsurance {get;set;}
    //public Boolean selectSimOnly {get;set;}
    public String selectedTariffType {
        get {if (selectedTariffType==null) return defaultTariffType; else return selectedTariffType;}
        set;
    }
    public String defaultTariffType {
        get {
            String retValue = '';
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'TARIFFTYPE' && !ref.Inactive__c) {if (defaultTariffType==null && ref.Default__c) retValue = ref.Code__c;}
            }
            return retValue;
        }
        set;
    }
    public List<SelectOption> getTariffTypes() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'TARIFFTYPE' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {
            SelectOption newOpt = new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c);
            newOpt.setEscapeItem(false);
            opt.add(newOpt);
        }
        return opt;
    }

    //### CONSOLIDATING CLASS FOR TARIFF AND DEVICE PRICING DATA ###
/*    global class MobileDeviceTariff {
        public O2_Dise_Map_Mobile__c tariff {get;set;}
        public O2_Dise_Map_Mobile_Bolton__c[] boltons {get;set;}
        public String promo {get;set;}
        public MobileDeviceTariff() {}
        public MobileDeviceTariff(O2_Dise_Map_Mobile__c t, O2_Dise_Map_Mobile_Bolton__c[] d, String s) {
            this.tariff = t;
            this.boltons = d;
            this.promo = s;
        }
    }*/
    //Tariff journey class holding unique tariff rows - with list of tariff names each key maps to
    global class MobileDeviceTariffUnique {
        public String tariff_unique_key {get;set;}
        public O2_Dise_Map_Mobile__c tariff {get;set;}
        public O2_Dise_Map_Mobile_Bolton__c[] boltons {get;set;}
        public O2_DISE_Map_Handset__c handset {get; set;}
        public String[] tariffNames {get; set;}
        public String[] tariffClasses {get; set;}
        public String promo {get;set;}
        public MobileDeviceTariffUnique() {}
        public MobileDeviceTariffUnique(O2_Dise_Map_Mobile__c t, O2_Dise_Map_Mobile_Bolton__c[] d, String s) {
            this.tariff = t;
            this.boltons = d;
            this.tariff_unique_key=t.Price__c +'|'+t.Inclusive_minutes__c +'|'+t.Contract_Length__c +'|'+ t.Core_Data_Bolton__c + '|' + t.Tariff_Code__c;
            this.promo = s;
        }
    }

    //### REMOTING FUNCTION TO RETRIEVE TARIFF AND DEVICE PRICING DATA ###
    @remoteAction
    global static MobileDeviceTariffUnique[] getMobileTariffsUnique(String hsClass, String cost, String mins, String texts, String sData, String tariffCode, String tType, String bonus, String boltOns, String promo, String slimit, boolean only4G) {
        //get current sales tariff codes
        Map<String, O2_Dise_Map_Current_Sales_Tariff__c> currCodes = new Map<String, O2_Dise_Map_Current_Sales_Tariff__c>();
        if (promo!=null && promo!='') {
            promo = '%'+promo+'%';
            for (O2_Dise_Map_Current_Sales_Tariff__c c: [SELECT Tariff_Code__c, Marketing_Message__c FROM O2_Dise_Map_Current_Sales_Tariff__c WHERE Product__c = 'Mobile' AND Marketing_Message__c LIKE :promo]) currCodes.put(c.Tariff_Code__c, c);
        } else {
            for (O2_Dise_Map_Current_Sales_Tariff__c c: [SELECT Tariff_Code__c, Marketing_Message__c FROM O2_Dise_Map_Current_Sales_Tariff__c WHERE Product__c = 'Mobile']) currCodes.put(c.Tariff_Code__c, c);
        }
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: currCodes: '+currCodes.keySet());
        //build query string
        String strQuery = 'SELECT ';
        MobileDeviceTariffUnique[] retTariffs = new MobileDeviceTariffUnique[0];
        MobileDeviceTariffUnique[] retTariffsUnique = new MobileDeviceTariffUnique[0];

        O2_Dise_Map_Mobile__c[] qryTariffs = new O2_Dise_Map_Mobile__c[0];
        Map<String, Schema.sObjectField> mpFields = Schema.sObjectType.O2_Dise_Map_Mobile__c.fields.getMap();
        for (Schema.sObjectField fld: mpFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+=fldName+',';
            }
        }

        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Map_Mobile__c';
        strQuery+=' WHERE Product_Definition__c = \'Business Single\' AND Primary_Additional__c = \'PRIMARY\' AND Handset_Tariff_Class__c <> \'Blackberry BES\'';
        if (currCodes!=null) {Set<String> keyCodes = currCodes.keySet();strQuery+=' AND Tariff_Code__c IN :keyCodes';}
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: strQuery: '+strQuery);

        if(only4G){
            strQuery+=' AND Is_4G__c = true';
        }

        if (hsClass!=null && hsClass!='') {
            if(hsClass.toUpperCase().contains('BLACKBERRY')) {
                strQuery+=' AND Roaming__c = \'--None--\'';
            }
            strQuery+=' AND Handset_Tariff_Class__c LIKE \''+hsClass+'%\'';
        }

        if (cost!=null && cost !='') {
            if (cost.contains(';')) {
                String[] arCrit = cost.split(';');
                for (String s: arCrit) {
                    strQuery+=' AND Price__c '+s;
                }
            }
            else {
                strQuery+=' AND Price__c '+cost;
            }
        }

        if (mins!=null && mins !='') {
            strQuery+=' AND Inclusive_Minutes__c '+mins;
        }

        if (texts!=null && texts !='') {
            strQuery+=' AND Inclusive_Texts__c '+texts;
        }

        if (sData!=null && sData !='') {
            strQuery+=' AND Inclusive_Core_Data__c = '+sData;
        }

        if (tariffCode!=null && tariffCode !='') {
            strQuery+=' AND Tariff_Code__c = \''+tariffCode+'\'';
        }
        /*
        if (simOnly!=null && simOnly !='') {
            if (simOnly == 'true') {
                if (strQuery.contains(' WHERE')) {strQuery+=' AND Contract_Type__c <> \'Handset\'';}
                else {strQuery+=' WHERE Contract_Type__c <> \'Handset\'';}
            }
            else {
                if (strQuery.contains(' WHERE')) {strQuery+=' AND Contract_Type__c = \'Handset\' AND Contract_Length__c = \'24\'';}
                else {strQuery+=' WHERE Contract_Type__c = \'Handset\' AND Contract_Length__c = \'24\'';}
            }
        }
        else {
            if (strQuery.contains(' WHERE')) {strQuery+=' AND ((Contract_Length__c = \'24\' AND Contract_Type__c = \'Handset\') OR (Contract_Type__c <> \'Handset\'))';}
            else {strQuery+=' WHERE ((Contract_Length__c = \'24\' AND Contract_Type__c = \'Handset\') OR (Contract_Type__c <> \'Handset\'))';}
        }*/
        if (tType!=null && tType !='') {
            if (tType.contains(';')) {
                Set<String> sType = new Set<String>(tType.split(';'));
                strQuery+=' AND Contract_Type__c IN :sType';
            }
            else {
                strQuery+=' AND Contract_Type__c = \''+tType+'\'';
                if(tType=='Handset') {
                    strQuery+=' AND Contract_Length__c = \'24\'';
                }
            }
        }

        if (bonus!=null && bonus!='') {
            strQuery+=' AND Promotion__c = \'Bonus\'';
        }

        strQuery +=' ORDER BY Is_4g__c DESC, Sorting_key__c ASC';

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: strQuery: '+strQuery);
        //query for tariff records
        qryTariffs = Database.query(strQuery);

        //get all tariff codes for the resulting tariffs
        Set<String> setTCodes = new Set<String>();
        if (qryTariffs!=null && qryTariffs.size()>0) {
            for (O2_Dise_Map_Mobile__c mob: qryTariffs) {setTCodes.add(mob.Tariff_Code__c);}
            System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: setTCodes: '+setTCodes);
        }
        //get valid bolt on types
        List<String> validBoltOns = new List<String>();
        for (O2_Reference_Codes__c ref: O2_Reference_Codes__c.getAll().values()) {
            if ((ref.Type__c == 'SINGLEBOLTON' || ref.Type__c == 'FILTERBOLTON') && !ref.Inactive__c) {
                validBoltOns.add(ref.Code__c);
                  System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: validBoltOns:'+ref);
            }
        }

        //get corresponding bolton records
        strQuery = 'SELECT ';
        O2_Dise_Map_Mobile_Bolton__c[] qryDevices = new O2_Dise_Map_Mobile_Bolton__c[0];
        Map<String, Schema.sObjectField> mpDeviceFields = Schema.sObjectType.O2_Dise_Map_Mobile_Bolton__c.fields.getMap();
        for (Schema.sObjectField fld: mpDeviceFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+=fldName+',';
            }
        }
        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Map_Mobile_Bolton__c WHERE Tariff_Code__c IN :setTCodes AND Bolt_On_Key__c IN :validBoltOns AND Recurring_OneOff__c = \'Recurring\'';
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: strQuery: '+strQuery);
        qryDevices = Database.query(strQuery);
        Map<String, O2_Dise_Map_Mobile_Bolton__c[]> mpBoltOns = new Map<String, O2_Dise_Map_Mobile_Bolton__c[]>();
        if (qryDevices!=null && qryDevices.size()>0) {
            for (O2_Dise_Map_Mobile_Bolton__c bo: qryDevices) {
                List<O2_Dise_Map_Mobile_Bolton__c> lsBO;
                if (mpBoltOns.containsKey(bo.Tariff_Code__c)) lsBO = mpBoltOns.get(bo.Tariff_Code__c); else lsBO = new List<O2_Dise_Map_Mobile_Bolton__c>();
                lsBO.add(bo);
                mpBoltOns.put(bo.Tariff_Code__c, lsBO);
            }
        }
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: mpBoltOns: '+mpBoltOns);

        //Get the lowest handset prices for each tariff
        Map<string, O2_DISE_Map_Handset__c> lowestPricesMap = new Map<string, O2_DISE_Map_Handset__c>();
        List<AggregateResult> lowestPricesList = [SELECT  Base_Tariff__c Tariff, Min(Discounted_Price__c) Price FROM O2_DISE_Map_Handset__c WHERE Handset_Class__c = :hsClass GROUP BY Base_Tariff__c];
        for(AggregateResult result: lowestPricesList){
            O2_DISE_Map_Handset__c handset = new O2_DISE_Map_Handset__c(Base_Tariff__c = (string)result.get('Tariff'),
                                                                        Discounted_Price__c = (decimal)result.get('Price'),
                                                                        Handset_Class__c = hsClass);
            lowestPricesMap.put(handset.Base_Tariff__c, handset);
        }

        //populate output collection
        if (qryTariffs!=null && qryTariffs.size()>0) {
            for (O2_Dise_Map_Mobile__c mob: qryTariffs) {
                System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: mob: '+mob);
                String strMessage = null;
                if (currCodes!=null && currCodes.size()>0 && currCodes.containsKey(mob.Tariff_Code__c)) {strMessage = currCodes.get(mob.Tariff_Code__c).Marketing_Message__c;}
                System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: boltOns: '+boltOns);
                if (boltOns!=null && boltOns!='') {
                    Set<String> boCriteria = new Set<String>(boltOns.split(','));
                    Set<String> sBOTypes = new Set<String>();
                    // CK 29/04/2012: Case00007585 build list of bolt_on_key not bolt_on_type
                    for (O2_Dise_Map_Mobile_Bolton__c bo: mpBoltOns.get(mob.Tariff_Code__c)) {sBOTypes.add(bo.Bolt_On_Key__c);}
                    System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: sBOTypes: '+sBOTypes);
                    System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffsUnique: boCriteria: '+boCriteria);
                    if (sBOTypes.containsAll(boCriteria)) {
                        MobileDeviceTariffUnique t = new MobileDeviceTariffUnique(mob, (mpBoltOns.containsKey(mob.Tariff_Code__c) ? mpBoltOns.get(mob.Tariff_Code__c) : null), strMessage);
                        t.handset = lowestPricesMap.get(mob.Name);
                        retTariffs.add(t);
                    }
                }
                else {
                    MobileDeviceTariffUnique t = new MobileDeviceTariffUnique(mob, (mpBoltOns.containsKey(mob.Tariff_Code__c) ? mpBoltOns.get(mob.Tariff_Code__c) : null), strMessage);
                    t.handset = lowestPricesMap.get(mob.Name);
                    retTariffs.add(t);
                }
            }
        }

        //*** De-dupe tariffs into unique list ***
        Map<String, String[]> mdtNamesMap=new Map<String, String[]>();
        Map<String, String[]> mdtClassesMap=new Map<String, String[]>();
        for(MobileDeviceTariffUnique mdt : retTariffs) {

            // Collect Tariff Names into a map on the unique row key.
            if(mdtNamesMap.get(mdt.tariff_unique_key)==null) {
                mdtNamesMap.put(mdt.tariff_unique_key, new String[]{mdt.tariff.Name});

            } else {
                //add name to list for this key if not there already
                boolean dupeName=false;
                System.debug(LoggingLevel.INFO,'***for unique key:'+mdt.tariff_unique_key);
                for(String name : mdtNamesMap.get(mdt.tariff_unique_key)) {
                    System.debug(LoggingLevel.INFO,'**tariff name:'+name);
                    if (name==mdt.tariff.Name) {
                        dupeName=true;
                        break;
                    }
                }
                if(!dupeName) mdtNamesMap.get(mdt.tariff_unique_key).add((String)mdt.tariff.Name);
                if(!dupeName) System.debug(LoggingLevel.INFO,'***more than one tariff item in this row key:'+mdt.tariff_unique_key+ ' values:'+mdtNamesMap.get(mdt.tariff_unique_key));
            }

            // Collect Tariff Classes into a map on the unique row key.
            if(mdtClassesMap.get(mdt.tariff_unique_key)==null) {
                mdtClassesMap.put(mdt.tariff_unique_key, new String[]{mdt.tariff.Handset_Tariff_Class__c});
            } else {
                //add name to list for this key if not there already
                boolean dupeName=false;
                System.debug(LoggingLevel.INFO,'***for unique key:'+mdt.tariff_unique_key);
                for(String tclass : mdtClassesMap.get(mdt.tariff_unique_key)) {
                    System.debug(LoggingLevel.INFO,'**tariff class:'+tclass);
                    if (tclass==mdt.tariff.Handset_Tariff_Class__c) {
                        dupeName=true;
                        break;
                    }
                }
                if(!dupeName) mdtClassesMap.get(mdt.tariff_unique_key).add((String)mdt.tariff.Handset_Tariff_Class__c);
                if(!dupeName) System.debug(LoggingLevel.INFO,'***more than one tariff item in this row key:'+mdt.tariff_unique_key+ ' values:'+mdtClassesMap.get(mdt.tariff_unique_key));
            }

            retTariffsUnique.add(mdt);
        }
        System.debug(LoggingLevel.INFO,'****mdtNamesMap'+mdtNamesMap);
        System.debug(LoggingLevel.INFO,'****mdtClassesMap'+mdtClassesMap);

        // Add Tariff Names and Classes for EVERY tariff
        for(MobileDeviceTariffUnique mdt: retTariffsUnique) {
            mdt.tariffNames=mdtNamesMap.get(mdt.tariff_unique_key);
            mdt.tariffClasses=mdtClassesMap.get(mdt.tariff_unique_key);
        }

        return retTariffsUnique;
    }

    //### REMOTING FUNCTION TO RETRIEVE TARIFF AND DEVICE PRICING DATA ###
    @remoteAction
    global static MobileDeviceTariffUnique[] getMobileTariffs(String hsProductCode, String hsClass, String cost, String mins, String texts, String sData, String tariffCode, String tType, String bonus, String boltOns, String promo, String slimit, boolean only4G) {
        //get current sales tariff codes
        Map<String, O2_Dise_Map_Current_Sales_Tariff__c> currCodes = new Map<String, O2_Dise_Map_Current_Sales_Tariff__c>();
        if (promo!=null && promo!='') {
            promo = '%'+promo+'%';
            for (O2_Dise_Map_Current_Sales_Tariff__c c: [SELECT Tariff_Code__c, Marketing_Message__c FROM O2_Dise_Map_Current_Sales_Tariff__c WHERE Product__c = 'Mobile' AND Marketing_Message__c LIKE :promo]) currCodes.put(c.Tariff_Code__c, c);
        } else {
            for (O2_Dise_Map_Current_Sales_Tariff__c c: [SELECT Tariff_Code__c, Marketing_Message__c FROM O2_Dise_Map_Current_Sales_Tariff__c WHERE Product__c = 'Mobile']) currCodes.put(c.Tariff_Code__c, c);
        }
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: currCodes: '+currCodes.keySet());

        // Obtain handset information for tariff matching - RW20120912
        List<O2_DISE_Map_Handset__c> selHandsetList=new List<O2_DISE_Map_Handset__c>();
        Set<String> baseTariffSet= new Set<String>();
        Map<String,O2_DISE_Map_Handset__c> deviceTariffPrices = new Map<String,O2_DISE_Map_Handset__c>();

        if(hsClass!=null && hsProductCode!=null) {
            selHandsetList = [SELECT id, Base_Tariff__c, Bonus_Tariff_Indicator__c, Product_Code__c, Discounted_Price__c
                            FROM O2_DISE_Map_Handset__c
                            WHERE Product_Code__c =:hsProductCode
                                AND Handset_Class__c =:hsClass
                                AND Contract_Term__c = 24
                                AND (Expiry_Date__c > :Date.today() OR Expiry_Date__c=null)];

            for(O2_DISE_Map_Handset__c handset :selHandsetList) {
                System.debug(LoggingLevel.INFO,'***handset/base tariff'+handset.Base_Tariff__c+':'+handset.Bonus_Tariff_Indicator__c+':'+handset.Product_Code__c);
                baseTariffSet.add(handset.Base_Tariff__c);
                deviceTariffPrices.put(handset.Base_Tariff__c, handset);
            }
        }

        //build query string
        String strQuery = 'SELECT ';
        MobileDeviceTariffUnique[] retTariffs = new MobileDeviceTariffUnique[0];
        O2_Dise_Map_Mobile__c[] qryTariffs = new O2_Dise_Map_Mobile__c[0];
        Map<String, Schema.sObjectField> mpFields = Schema.sObjectType.O2_Dise_Map_Mobile__c.fields.getMap();
        for (Schema.sObjectField fld: mpFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+=fldName+',';
            }
        }

        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Map_Mobile__c';
        strQuery+=' WHERE Product_Definition__c = \'Business Single\' AND Primary_Additional__c = \'PRIMARY\' AND Handset_Tariff_Class__c <> \'Blackberry BES\'';
        if (currCodes!=null) {Set<String> keyCodes = currCodes.keySet();strQuery+=' AND Tariff_Code__c IN :keyCodes';}
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: strQuery: '+strQuery);

        // Filter for only those tariffs with handset price point - RW20120912
        strQuery+=' AND Name IN :baseTariffSet';

        if (hsClass!=null && hsClass!='') {
            if(hsClass.toUpperCase().contains('BLACKBERRY')) {
                strQuery+=' AND Roaming__c = \'--None--\'';
            }
            strQuery+=' AND Handset_Tariff_Class__c LIKE \''+hsClass+'%\'';
        }

        if (cost!=null && cost !='') {
            if (cost.contains(';')) {
                String[] arCrit = cost.split(';');
                for (String s: arCrit) {
                    strQuery+=' AND Price__c '+s;
                }
            }
            else {
                strQuery+=' AND Price__c '+cost;
            }
        }

        if (mins!=null && mins !='') {
            strQuery+=' AND Inclusive_Minutes__c '+mins;
        }

        if (texts!=null && texts !='') {
            strQuery+=' AND Inclusive_Texts__c '+texts;
        }

        if (sData!=null && sData !='') {
            strQuery+=' AND Inclusive_Core_Data__c = '+sData;
        }

        if (tariffCode!=null && tariffCode !='') {
            strQuery+=' AND Tariff_Code__c = \''+tariffCode+'\'';
        }

        /*
        if (simOnly!=null && simOnly !='') {
            if (simOnly == 'true') {
                if (strQuery.contains(' WHERE')) {strQuery+=' AND Contract_Type__c <> \'Handset\'';}
                else {strQuery+=' WHERE Contract_Type__c <> \'Handset\'';}
            }
            else {
                if (strQuery.contains(' WHERE')) {strQuery+=' AND Contract_Type__c = \'Handset\' AND Contract_Length__c = \'24\'';}
                else {strQuery+=' WHERE Contract_Type__c = \'Handset\' AND Contract_Length__c = \'24\'';}
            }
        }
        else {
            if (strQuery.contains(' WHERE')) {strQuery+=' AND ((Contract_Length__c = \'24\' AND Contract_Type__c = \'Handset\') OR (Contract_Type__c <> \'Handset\'))';}
            else {strQuery+=' WHERE ((Contract_Length__c = \'24\' AND Contract_Type__c = \'Handset\') OR (Contract_Type__c <> \'Handset\'))';}
        }*/
        if (tType!=null && tType !='') {
            if (tType.contains(';')) {
                Set<String> sType = new Set<String>(tType.split(';'));
                strQuery+=' AND Contract_Type__c IN :sType';
            }
            else {
                strQuery+=' AND Contract_Type__c = \''+tType+'\'';
                if(tType=='Handset') {
                    strQuery+=' AND Contract_Length__c = \'24\'';
                }
            }
        }

        // Set bonus, but overriden by flavour (On & On, 50, 100, Max)
        if (bonus!=null && bonus!='' && bonus=='true') {
            strQuery+=' AND (Promotion__c = \'Bonus\' OR Flavour__c IN (\'On & On\',\'50\',\'100\',\'Max\') )';
        } else {
            strQuery+=' AND (Promotion__c <> \'Bonus\' OR Flavour__c IN (\'On & On\',\'50\',\'100\',\'Max\') )';
        }
        if(only4G){
            strQuery+=' AND Is_4G__c = true';
        }
        strQuery +=' ORDER BY Is_4g__c DESC, Sorting_key__c ASC';


        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: strQuery: '+strQuery);
        //query for tariff records
        qryTariffs = Database.query(strQuery);

        //get all tariff codes for the resulting tariffs
        Set<String> setTCodes = new Set<String>();
        if (qryTariffs!=null && qryTariffs.size()>0) {
            for (O2_Dise_Map_Mobile__c mob: qryTariffs) {setTCodes.add(mob.Tariff_Code__c);}
            System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: setTCodes: '+setTCodes);
        }
        //get valid bolt on types
        List<String> validBoltOns = new List<String>();
        for (O2_Reference_Codes__c ref: O2_Reference_Codes__c.getAll().values()) {
            if ((ref.Type__c == 'SINGLEBOLTON' || ref.Type__c == 'FILTERBOLTON') && !ref.Inactive__c) validBoltOns.add(ref.Code__c);
        }
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: validBoltOns: '+validBoltOns);

        //get corresponding bolton records
        strQuery = 'SELECT ';
        O2_Dise_Map_Mobile_Bolton__c[] qryDevices = new O2_Dise_Map_Mobile_Bolton__c[0];
        Map<String, Schema.sObjectField> mpDeviceFields = Schema.sObjectType.O2_Dise_Map_Mobile_Bolton__c.fields.getMap();
        for (Schema.sObjectField fld: mpDeviceFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+=fldName+',';
            }
        }

        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Map_Mobile_Bolton__c WHERE Tariff_Code__c IN :setTCodes AND Bolt_On_Key__c IN :validBoltOns AND Recurring_OneOff__c = \'Recurring\'';
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: strQuery: '+strQuery);
        qryDevices = Database.query(strQuery);
        Map<String, O2_Dise_Map_Mobile_Bolton__c[]> mpBoltOns = new Map<String, O2_Dise_Map_Mobile_Bolton__c[]>();
        if (qryDevices!=null && qryDevices.size()>0) {
            for (O2_Dise_Map_Mobile_Bolton__c bo: qryDevices) {
                List<O2_Dise_Map_Mobile_Bolton__c> lsBO;
                if (mpBoltOns.containsKey(bo.Tariff_Code__c)) lsBO = mpBoltOns.get(bo.Tariff_Code__c); else lsBO = new List<O2_Dise_Map_Mobile_Bolton__c>();
                lsBO.add(bo);
                mpBoltOns.put(bo.Tariff_Code__c, lsBO);
            }
        }
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: mpBoltOns: '+mpBoltOns);

        //populate output collection
        if (qryTariffs!=null && qryTariffs.size()>0) {
            for (O2_Dise_Map_Mobile__c mob: qryTariffs) {
                System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: tariffCode: '+mob.Tariff_Code__c);
                //get the list of in-package service codes
                Set<String> sSvcCodes = new Set<String>();
                if (mob.InPackage_Service_List__c!=null && mob.InPackage_Service_List__c.contains(',')) {
                    for (String svc: mob.InPackage_Service_List__c.split(',')) {sSvcCodes.add(svc.replace('"', ''));}
                }
                //get the related bolton records
                O2_Dise_Map_Mobile_Bolton__c[] boRecs = (mpBoltOns.containsKey(mob.Tariff_Code__c) ? mpBoltOns.get(mob.Tariff_Code__c) : null);
                //check whether the in-package boltons exist and remove if yes
                System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: sSvcCodes: '+sSvcCodes);
                System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: boRecs before: '+boRecs);
                if (boRecs!=null && boRecs.size()>0) for (Integer i=0; i<boRecs.size(); i++) {if (sSvcCodes.contains(boRecs[i].Service_Code__c)) boRecs.remove(i);}
                System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileTariffs: boRecs after: '+boRecs);
                //add to output
                String strMessage = null;
                if (currCodes!=null && currCodes.size()>0 && currCodes.containsKey(mob.Tariff_Code__c)) {strMessage = currCodes.get(mob.Tariff_Code__c).Marketing_Message__c;}
                if (boltOns!=null && boltOns!='') {
                    Set<String> boCriteria = new Set<String>(boltOns.split(','));
                    Set<String> sBOTypes = new Set<String>();
                    // CK 29/04/2012: Case00007585 build list of bolt_on_key not bolt_on_type
                    if (boRecs!=null && boRecs.size()>0) for (O2_Dise_Map_Mobile_Bolton__c bo: boRecs) {sBOTypes.add(bo.Bolt_On_Key__c);}
                    if (sBOTypes.containsAll(boCriteria)) {
                        retTariffs.add(new MobileDeviceTariffUnique(mob, boRecs, strMessage));
                    }
                }
                else {
                    MobileDeviceTariffUnique t = new MobileDeviceTariffUnique(mob, boRecs, strMessage);
                    O2_DISE_Map_Handset__c handset =  deviceTariffPrices.get(mob.Name);
                    t.handset = handset;
                    retTariffs.add(t);
                }
            }
        }
        return retTariffs;
    }

    public String selectedBrand {
        get {if (selectedBrand==null) return defaultBrand; else return selectedBrand;}
        set;
    }
    public String defaultBrand {
        get {
            String retValue = '';
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'DEVICEBRAND' && !ref.Inactive__c) {if (defaultBrand==null && ref.Default__c) retValue = ref.Code__c;}
            }
            return retValue;
        }
        set;
    }
    public List<SelectOption> getHSBrands() {
        List<SelectOption> opt = new List<SelectOption>();
        //Schema.DescribeFieldResult fld = O2_Dise_Ref_Hardware_Portfolio__c.Brand__c.getDescribe();
        //List<PicklistEntry> pl = fld.getPicklistValues();
        //if (pl!=null && pl.size()>0) {
        //    for (PicklistEntry pe: pl) {opt.add(new SelectOption(pe.value, pe.value));}
        //} //SW CDECISIONS 23/04/2012 - commented out the above in place of a custom setting-driven population
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'DEVICEBRAND' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {
            SelectOption newOpt = new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c);
            newOpt.setEscapeItem(false);
            opt.add(newOpt);
        }
        return opt;
    }
    public String selectedSystem {
        get {if (selectedSystem==null) return defaultSystem; else return selectedSystem;}
        set;
    }
    public String defaultSystem {
        get {
            String retValue = '';
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'DEVICESYSTEM' && !ref.Inactive__c) {if (defaultSystem==null && ref.Default__c) retValue = ref.Code__c;}
            }
            return retValue;
        }
        set;
    }
    public List<SelectOption> getHSSystems() {
        List<SelectOption> opt = new List<SelectOption>();
        //Schema.DescribeFieldResult fld = O2_Dise_Ref_Hardware_Portfolio__c.Operating_System__c.getDescribe();
        //List<PicklistEntry> pl = fld.getPicklistValues();
        //if (pl!=null && pl.size()>0) {
        //    for (PicklistEntry pe: pl) {opt.add(new SelectOption(pe.value, pe.value));}
        //} //SW CDECISIONS 23/04/2012 - commented out the above in place of a custom setting-driven population
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'DEVICESYSTEM' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {
            SelectOption newOpt = new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c);
            newOpt.setEscapeItem(false);
            opt.add(newOpt);
        }
        return opt;
    }
    public String selectedBestFor {
        get {if (selectedBestFor==null) return ''; else return selectedBestFor;}
        set;
    }
    public List<SelectOption> getHSBestFor() {
        List<SelectOption> opt = new List<SelectOption>();
        Schema.DescribeFieldResult fld = O2_Dise_Ref_Hardware_Portfolio__c.Best_For__c.getDescribe();
        List<PicklistEntry> pl = fld.getPicklistValues();
        if (pl!=null && pl.size()>0) {
            for (PicklistEntry pe: pl) {opt.add(new SelectOption(pe.value, pe.value));}
        }
        return opt;
    }

    public String selectedSorting {
        get {if (selectedSorting==null) return defaultSorting; else return selectedSorting;}
        set;
    }
    public String defaultSorting {
        get {
            String retValue='';
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'DEVICESORT' && !ref.Inactive__c) {if (defaultSorting==null && ref.Default__c) retValue = ref.Code__c;}
            }
            return retValue;
        }
        set;
    }
    public List<SelectOption> getHSSorting() {
        List<SelectOption> opt = new List<SelectOption>();
        Map<String, O2_Reference_Codes__c> mpCodes = new Map<String, O2_Reference_Codes__c>();
        if (refCodes!=null && refCodes.size()>0) {
            for (O2_Reference_Codes__c ref: refCodes) {
                if (ref.Type__c == 'DEVICESORT' && !ref.Inactive__c) {mpCodes.put(ref.Sequence__c+ref.Code__c, ref);}
            }
        }
        List<String> sortList = new List<String>(mpCodes.keySet());
        sortList.sort();
        for (String s: sortList) {opt.add(new SelectOption(mpCodes.get(s).Code__c, mpCodes.get(s).Code_Description__c));}
        return opt;
    }

    // To be replaced. Sims to be added to handset selection table. Will use getMobileDevicesTL instead.
    @remoteAction
    global static List<MobileDevice> getSimDevices() {
        String strQuery = 'SELECT Id, Name, Handset_Class__c, Bonus_Handset__c, Handset_Model__c, Handset_Description__c, Stock_Status__c, handset_image_url__c, ';
        O2_Dise_Map_Handset_Selection__c[] qryRes = new O2_Dise_Map_Handset_Selection__c[0];
        MobileDevice[] retDevices = new MobileDevice[0];
        //get dynamic list of fields from HS selection object
        Map<String, Schema.sObjectField> mpHSFields = Schema.sObjectType.O2_Dise_Ref_Hardware_Portfolio__c.fields.getMap();
        for (Schema.sObjectField fld: mpHSFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+='Product_Code__r.'+fldName+',';
            }
        }
        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Map_Handset_Selection__c';
        strQuery+=' WHERE Active__c = true AND Product_Code__c <> \'\' AND Product_Code__r.Hardware_Type__c = \'SIM\' AND Channel__c=\'Online\'';

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileDevices: strQuery: '+strQuery);
        qryRes = Database.query(strQuery);
        if (qryRes!=null && qryRes.size()>0) {
            for (O2_Dise_Map_Handset_Selection__c dev: qryRes) {
                MobileDevice md=new MobileDevice(dev, false, 0);
                md.price=dev.Product_Code__r.Default_Price__c;
                retDevices.add(md);
            }
        }
        return retDevices;
    }

    global class MobileDevice {
        public O2_Dise_Map_Handset_Selection__c device {get;set;}
        public Boolean insure {get;set;}
        public Integer quantity {get;set;}
        public Double price {get;set;}
        public Double insurancePrice {get;set;}
        public MobileDevice() {}
        public MobileDevice(O2_Dise_Map_Handset_Selection__c d, Boolean i, Integer q) {
            this.device = d;
            this.insure = i;
            this.quantity = q;
        }
    }
    @remoteAction
    global static MobileDevice[] getMobileDevicesTL(List<String> tariffNameList, String tariffPromotion, String tariffFlavour, List<String> tariffClassList, String sBrand, String sSystem, String sCategory, String sClass, String sSort, String sLimit) {
        System.debug(LoggingLevel.INFO,'****tariffNameList'+tariffNameList);

        //List<O2_DISE_Map_Handset__c> selHandsetList=new List<O2_DISE_Map_Handset__c>();
        List<O2_DISE_Map_Handset__c> selHandsetList=new List<O2_DISE_Map_Handset__c>();
        Map<String,O2_DISE_Map_Handset__c> hsCodeMap=new Map<String,O2_DISE_Map_Handset__c>();
        Set<String> productCodeSet= new Set<String>();

        // Place tariff classes into a Set.
        Set<String> tariffClassSet=new Set<String>();
        tariffClassSet.addAll(tariffClassList);

        //String tariffKey=this.selectedTariffUniqueKey;
        if(tariffNameList!=null && tariffNameList.size()>0) {
            String bonusIndicatorTariff='false';
            if(tariffPromotion!=null && tariffPromotion=='Bonus') bonusIndicatorTariff='true';

            selHandsetList = [SELECT id, Product_Code__c, Handset_Class__c, Discounted_Price__c, Insurance_Service_Price__c
                            FROM O2_DISE_Map_Handset__c
                            WHERE Bonus_Tariff_Indicator__c =:bonusIndicatorTariff
                                AND Base_Tariff__c IN :tariffNameList
                                AND (Expiry_Date__c > :Date.today() OR Expiry_Date__c=null)];

            for(O2_DISE_Map_Handset__c handset :selHandsetList) {
                if(productCodeSet.contains(handset.Product_Code__c))
                    System.debug(LoggingLevel.INFO,'***pc/price/class'+handset.Product_Code__c+':'+handset.Discounted_Price__c+':'+handset.Handset_Class__c+'+++handset:'+hsCodeMap.get(handset.Product_Code__c));
                productCodeSet.add(handset.Product_Code__c);
                hsCodeMap.put(handset.Product_Code__c, handset);
            }
        }

        System.debug(LoggingLevel.INFO,'****productCodeSet'+productCodeSet);
        System.debug(LoggingLevel.INFO,'****hsCodeMap'+hsCodeMap);

        String strQuery = 'SELECT Id, Handset_Class__c, Bonus_Handset__c, Handset_Model__c, Handset_Description__c, Stock_Status__c, handset_image_url__c, ';
        O2_Dise_Map_Handset_Selection__c[] qryRes = new O2_Dise_Map_Handset_Selection__c[0];
        MobileDevice[] retDevices = new MobileDevice[0];
        //get dynamic list of fields from HS selection object
        Map<String, Schema.sObjectField> mpHSFields = Schema.sObjectType.O2_Dise_Ref_Hardware_Portfolio__c.fields.getMap();
        for (Schema.sObjectField fld: mpHSFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+='Product_Code__r.'+fldName+',';
            }
        }
        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Map_Handset_Selection__c';
        strQuery+=' WHERE Active__c = true AND Product_Code__c <> \'\' AND Product_Code__r.Hardware_Type__c = \'Handset\' AND Channel__c=\'Online\'';

        //for tariff led - we must have product codes
        if(productCodeSet.size()>0) {
            strQuery+=' AND Product_Code__r.Product_Code__c IN :productCodeSet';
        } else {
            return retDevices;
        }

//        if (sBrand!=null && sBrand!='') {
//            strQuery+=' AND Product_Code__r.Brand__c LIKE \'%'+sBrand+'%\'';
//        }

//        if (sSystem!=null && sSystem!='') {
//            strQuery+=' AND Product_Code__r.Operating_System__c LIKE \'%'+sSystem+'%\'';
//        }

//        if (sCategory!=null && sCategory!='') {
//            strQuery+=' AND Product_Code__r.Best_For__c LIKE \'%'+sCategory+'%\'';
//        }

        if (sClass!=null && sClass!='') {
            strQuery+=' AND Handset_Class__c  LIKE \''+sClass+'\'';
        }

        // Only restrict devices by bonus if not a flavour of On & On, 50, 100, Max - these override.
        if(tariffFlavour!='On & On' && tariffFlavour!='50' && tariffFlavour!='100' && tariffFlavour!='Max') {
            if(tariffPromotion!=null && tariffPromotion=='Bonus') {
                strQuery+=' AND Bonus_Handset__c  = true';
            } else {
                strQuery+=' AND Bonus_Handset__c  = false';
            }
        }

        if (sSort!=null && sSort!='') {
            strQuery +=' ORDER BY '+sSort+', Product_Code__r.Hardware_Description__c';
        }

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileDevices: strQuery: '+strQuery);
        qryRes = Database.query(strQuery);
        String tClassStr=(' '+tariffClassSet).toUpperCase(); // Convert to string for matching
        if (qryRes!=null && qryRes.size()>0) {
            for (O2_Dise_Map_Handset_Selection__c dev: qryRes) {
                //filter devices for those that have class in the selected tariff handset class list
                if(tClassStr.contains(dev.Handset_Class__c.toUpperCase())) { // Match to tariff class e.g. to match 'Blackberry BIS' to 'BLACKBERRY'
                    MobileDevice md=new MobileDevice(dev, false, 0);

                    if(hsCodeMap.get(dev.Product_Code__r.Product_Code__c)!=null) {
                        System.debug(LoggingLevel.INFO,'****dev.Product_Code__r.Product_Code__c'+dev.Product_Code__r.Product_Code__c+' *** map:'+ hsCodeMap.get(dev.Product_Code__r.Product_Code__c).Discounted_Price__c);
                        md.price=hsCodeMap.get(dev.Product_Code__r.Product_Code__c).Discounted_Price__c;
                        md.insurancePrice=hsCodeMap.get(dev.Product_Code__r.Product_Code__c).Insurance_Service_Price__c;
                    }
                    retDevices.add(md);
                }
            }
        }
        System.debug(LoggingLevel.INFO,'****retDevices'+retDevices);
        System.debug(LoggingLevel.INFO,'***serialized'+JSON.serialize(retDevices));

        return retDevices;
    }

    @remoteAction
    global static MobileDevice[] getMobileDevices(String sBrand, String sSystem, String sCategory, String sClass, String sSort, String sLimit, boolean only4G) {
        String strQuery = 'SELECT Id, Name, Handset_Model__c, Handset_Description__c, Stock_Status__c, handset_image_url__c, Bonus_Handset__c, Handset_Class__c, Price_Condition__c, Promotion__c, Promo_Image_1_URL__c, Promo_Image_2_URL__c, Promo_Message__c, OS_Super_Promotion__c, Brand_Super_Promotion__c, Price_Condition_4G__c, Coremetric_Tag__c,';
        O2_Dise_Map_Handset_Selection__c[] qryRes = new O2_Dise_Map_Handset_Selection__c[0];
        MobileDevice[] retDevices = new MobileDevice[0];
        //get dynamic list of fields from HS selection object
        Map<String, Schema.sObjectField> mpHSFields = Schema.sObjectType.O2_Dise_Ref_Hardware_Portfolio__c.fields.getMap();
        for (Schema.sObjectField fld: mpHSFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+='Product_Code__r.'+fldName+',';
            }
        }
        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Map_Handset_Selection__c';
        strQuery+=' WHERE Active__c = true AND Product_Code__c <> \'\' AND Product_Code__r.Hardware_Type__c = \'Handset\' AND Channel__c=\'Online\'';
        if(only4G){
            strQuery+=' AND Product_Code__r.Is_4G__c = true';
        }

        if (sBrand!=null && sBrand!='') {
            if (sBrand!='Other') {
                strQuery+=' AND Product_Code__r.Brand__c LIKE \'%'+sBrand+'%\'';
            }
            else {
                Set<String> sOtherBrands = new Set<String>();
                for (O2_Reference_Codes__c ref: O2_Reference_Codes__c.getAll().values()) {
                    if (ref.Type__c == 'DEVICEBRAND' && ref.Code__c!='Other' && !ref.Inactive__c) {sOtherBrands.add(ref.Code__c);}
                }
                strQuery+=' AND Product_Code__r.Brand__c NOT IN :sOtherBrands';
            }
        }

        if (sSystem!=null && sSystem!='') {
            if (sSystem!='Other') {
                strQuery+=' AND Product_Code__r.Operating_System__c LIKE \'%'+sSystem+'%\'';
            }
            else {
                Set<String> sOtherSystems = new Set<String>();
                for (O2_Reference_Codes__c ref: O2_Reference_Codes__c.getAll().values()) {
                    if (ref.Type__c == 'DEVICESYSTEM' && ref.Code__c!='Other' && !ref.Inactive__c) {sOtherSystems.add(ref.Code__c);}
                }
                strQuery+=' AND Product_Code__r.Operating_System__c NOT IN :sOtherSystems';
            }
        }

//        if (sCategory!=null && sCategory!='') {
//            strQuery+=' AND Product_Code__r.Best_For__c LIKE \'%'+sCategory+'%\'';
//        }

//        if (sClass!=null && sClass!='') {
//            strQuery+=' AND Handset_Class__c  = \''+sClass+'\'';
//        }

        if (sSort!=null && sSort!='') {
            strQuery +=' ORDER BY '+sSort+', Product_Code__r.Hardware_Description__c';
        }

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileDevices: strQuery: '+strQuery);
        qryRes = Database.query(strQuery);
        if (qryRes!=null && qryRes.size()>0) {
            for (O2_Dise_Map_Handset_Selection__c dev: qryRes) {
                retDevices.add(new MobileDevice(dev, false, 0));
            }
        }
        return retDevices;
    }

    // KK: cloned function because old version could not fetch SIM devices du to condition Product_Code__r.Hardware_Type__c = \'Handset\'
    @remoteAction
    global static MobileDevice[] getMobileDevicesHT(String sBrand, String sSystem, String sHardwareType, String sSort) {
        String strQuery = 'SELECT Id, Name, Handset_Model__c, Handset_Description__c, Stock_Status__c, handset_image_url__c, Bonus_Handset__c, Handset_Class__c, Price_Condition__c, ';
        O2_Dise_Map_Handset_Selection__c[] qryRes = new O2_Dise_Map_Handset_Selection__c[0];
        MobileDevice[] retDevices = new MobileDevice[0];
        //get dynamic list of fields from HS selection object
        Map<String, Schema.sObjectField> mpHSFields = Schema.sObjectType.O2_Dise_Ref_Hardware_Portfolio__c.fields.getMap();
        for (Schema.sObjectField fld: mpHSFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+='Product_Code__r.'+fldName+',';
            }
        }

        sHardwareType = (sHardwareType == null && sHardwareType == '') ? 'Handset' : sHardwareType;

        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Map_Handset_Selection__c';
        strQuery+=' WHERE Active__c = true AND Product_Code__c <> \'\' AND Product_Code__r.Hardware_Type__c = \'' + sHardwareType + '\' AND Channel__c=\'Online\'';

        if (sBrand!=null && sBrand!='') {
            if (sBrand!='Other') {
                strQuery+=' AND Product_Code__r.Brand__c LIKE \'%'+sBrand+'%\'';
            }
            else {
                Set<String> sOtherBrands = new Set<String>();
                for (O2_Reference_Codes__c ref: O2_Reference_Codes__c.getAll().values()) {
                    if (ref.Type__c == 'DEVICEBRAND' && ref.Code__c!='Other' && !ref.Inactive__c) {sOtherBrands.add(ref.Code__c);}
                }
                strQuery+=' AND Product_Code__r.Brand__c NOT IN :sOtherBrands';
            }
        }

        if (sSystem!=null && sSystem!='') {
            if (sSystem!='Other') {
                strQuery+=' AND Product_Code__r.Operating_System__c LIKE \'%'+sSystem+'%\'';
            }
            else {
                Set<String> sOtherSystems = new Set<String>();
                for (O2_Reference_Codes__c ref: O2_Reference_Codes__c.getAll().values()) {
                    if (ref.Type__c == 'DEVICESYSTEM' && ref.Code__c!='Other' && !ref.Inactive__c) {sOtherSystems.add(ref.Code__c);}
                }
                strQuery+=' AND Product_Code__r.Operating_System__c NOT IN :sOtherSystems';
            }
        }

        if (sSort!=null && sSort!='') {
            strQuery +=' ORDER BY '+sSort+', Product_Code__r.Hardware_Description__c';
        }

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getMobileDevices: strQuery: '+strQuery);
        qryRes = Database.query(strQuery);
        if (qryRes!=null && qryRes.size()>0) {
            for (O2_Dise_Map_Handset_Selection__c dev: qryRes) {
                retDevices.add(new MobileDevice(dev, false, 0));
            }
        }
        return retDevices;
    }

    public String selectedProductCode {get;set;}
    public void doNothing() {}
    public String selectedProductId {get;set;}
    public String selectedProductQty {get;set;}

    public O2_Dise_Map_Handset_Selection__c selectedHandset {
        get {
            if ((selectedProductId!=null || selectedProductCode!=null) && selectedHandset==null) return getSelectedDevice(selectedProductId, selectedProductCode);
            else return selectedHandset;
        }
        set;
    }
    public O2_Dise_Map_Handset__c handset {
        get {
            if (selectedProductCode!=null) return getDiseHandset(selectedProductCode);
            else return getDiseHandset(selectedHandset.Product_Code__r.Product_Code__c);
        }
        set;
    }
    public PageReference selectDevice() {
        try {
            System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> selectDevice: selectedProductId: '+selectedProductId);
            System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> selectDevice: selectInsurance: '+selectInsurance);
            //if (selectedProductId==null) throw new O2OnlineMobileException('No product selected');
        }
        catch(Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));return null;}
        if (ApexPages.hasMessages()) return null;
        else return new PageReference('/apex/O2BusinessShopMobileTariffSelection');
    }
    public static O2_Dise_Map_Handset_Selection__c getSelectedDevice(String prodId, String prodCode) {
        O2_Dise_Map_Handset_Selection__c hsSelection = new O2_Dise_Map_Handset_Selection__c();
        String strQuery = 'SELECT Id, Handset_Model__c, Handset_Description__c, Stock_Status__c, handset_image_url__c, Bonus_Handset__c, Handset_Class__c, ';
        Map<String, Schema.sObjectField> mpHSFields = Schema.sObjectType.O2_Dise_Ref_Hardware_Portfolio__c.fields.getMap();
        for (Schema.sObjectField fld: mpHSFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+='Product_Code__r.'+fldName+',';
            }
        }
        strQuery = strQuery.substring(0, strQuery.length() - 1);

        if (prodId!=null && prodId!='') {strQuery+=' FROM O2_Dise_Map_Handset_Selection__c WHERE Id=\''+prodId+'\' LIMIT 1';}
        else if (prodCode!=null && prodCode!='') {strQuery+=' FROM O2_Dise_Map_Handset_Selection__c WHERE Product_Code__r.Product_Code__c=\''+prodCode+'\' LIMIT 1';}

        hsSelection = Database.query(strQuery);
        return hsSelection;
    }
    public static O2_Dise_Map_Handset__c getDiseHandset(String prodCode) {
        O2_Dise_Map_Handset__c hs = new O2_Dise_Map_Handset__c();
        String strQuery = 'SELECT Id, Insurance_Service_Price__c';
        strQuery+=' FROM O2_Dise_Map_Handset__c WHERE Product_Code__c=\''+prodCode+'\' LIMIT 1';
        // TODO do we need to check effective and expiry dates?
        hs = Database.query(strQuery);
        return hs;
    }

    @remoteAction
    global static MobileDevice[] getSelectedHandsetJSON(String strProdId, String strProdCode) {
        MobileDevice[] retDevice = new MobileDevice[0];
        retDevice.add(new MobileDevice(getSelectedDevice(strProdId, strProdCode), false, 1));
        return retDevice;
    }

    public PageReference saveTariff() { return null; }
    public String selectedTariffId {get;set;}
    public String selectedTariffUniqueKey {get;set;}
    public String selectedBoltOnIds {get;set;}

    // Javascript JSON object string storage
    private String tariffDynList;
    public String getTariffDynList() {
        return tariffDynList;
    }
    public void setTariffDynList(String json) {
        tariffDynList=json;
        System.debug(LoggingLevel.INFO,'### OUTPUT *** setting tariffDynList:--'+tariffDynList);
    }

    private String deviceDynList;
    public String getDeviceDynList() {
        return deviceDynList;
    }
    public void setDeviceDynList(String json) {
        deviceDynList=json;
        System.debug(LoggingLevel.INFO,'### OUTPUT *** setting deviceDynList:--'+deviceDynList);
    }

    private String accessoryDynList;
    public String getAccessoryDynList() {
        return accessoryDynList;
    }
    public void setAccessoryDynList(String json) {
        accessoryDynList=json;
    }

    // Apex class/object storage for JSON string
    public class MobileDeviceTariffUniqueJS {
        public String tariff_unique_key {get;set;}
        public O2_Dise_Map_Mobile__c tariff {get;set;}
        public O2_Dise_Map_Mobile_Bolton__c[] boltons {get;set;}
        public O2_DISE_Map_Handset__c handset {get; set;}
        public String[] tariffNames {get; set;}
        public String[] tariffClasses {get; set;}
        public String promo {get;set;}
    }

    public class MobileDeviceJS {
        public O2_Dise_Map_Handset_Selection__c device {get;set;}
        public Boolean insure;
        public Double price;
        public Double insurancePrice;
        public Integer quantity;
        public String tariffId;
    }

    public class MobileAccessoryJS {
        public O2_Dise_Ref_Hardware_Relation__c accessory {get;set;}
        public Integer quantity {get;set;}
        public String deviceId {get;set;}
    }

    public List<MobileDeviceJS> selDevicesList=new List<MobileDeviceJS>();
    public List<MobileDeviceJS> selDevicesListNew=new List<MobileDeviceJS>();
    public List<MobileDeviceTariffUniqueJS> selTariffsList=new List<MobileDeviceTariffUniqueJS>();
    public List<MobileAccessoryJS> selAccessoriesList = new List<MobileAccessoryJS>();

    public String formatJSON(String json) {
        System.debug(LoggingLevel.INFO,'***tariff sobject prefix:'+TARIFF_SOBJECT_PREFIX);
        System.debug(LoggingLevel.INFO,'***device sobject prefix:'+DEVICE_SOBJECT_PREFIX);
        System.debug(LoggingLevel.INFO,'***bolton sobject prefix:'+BOLTON_SOBJECT_PREFIX);
        System.debug(LoggingLevel.INFO,'***accessory sobject prefix:'+ACCESSORY_SOBJECT_PREFIX);

        json=json.trim();
        json=json.replaceAll('"' + TARIFF_SOBJECT_PREFIX + '([a-z]|[A-Z]|[0-9]){15}":','');  // replace sfid prefix on each record
        json=json.replaceAll('"' + DEVICE_SOBJECT_PREFIX + '([a-z]|[A-Z]|[0-9]){15}":','');  // replace sfid prefix on each record
        json=json.replaceAll('"' + BOLTON_SOBJECT_PREFIX + '([a-z]|[A-Z]|[0-9]){15}":','');  // replace sfid prefix on each record - bolton
        json=json.replaceAll('"' + ACCESSORY_SOBJECT_PREFIX + '([a-z]|[A-Z]|[0-9]){15}":','');  // replace sfid prefix on each record - accessory
        System.debug(LoggingLevel.INFO,'***json 1'+json);
        json=json.substring(json.indexOf('{')+1, json.lastIndexOf('}'));  // remove surrounding braces
        json='['+json+']';      // add surrounding squared brackets
        System.debug(LoggingLevel.INFO,'***json parsed'+json);
        return json;
    }

    public void parse() {
        if (deviceDynList!=null && deviceDynList!='') {
            String json=formatJSON(deviceDynList);
            selDevicesList=(List<MobileDeviceJS>) System.JSON.deserialize(json, List<MobileDeviceJS>.class);
            System.debug(LoggingLevel.INFO,'***selDevicesList:'+ selDevicesList);
            selDevicesListNew=selDevicesList.clone();
            System.debug(LoggingLevel.INFO,'***selDevicesListNew:'+ selDevicesListNew);
        }
        if (tariffDynList!=null && tariffDynList!='') {
            String json=formatJSON(tariffDynList);
            selTariffsList=(List<MobileDeviceTariffUniqueJS>) System.JSON.deserialize(json, List<MobileDeviceTariffUniqueJS>.class);
            System.debug(LoggingLevel.INFO,'***selTariffsList:'+ selTariffsList);
        }
    }
    public void parseAccessories() {
        if (accessoryDynList!=null && accessoryDynList!='') {
            String json=formatJSON(accessoryDynList);
            selAccessoriesList=(List<MobileAccessoryJS>) System.JSON.deserialize(json, List<MobileAccessoryJS>.class);
            System.debug(LoggingLevel.INFO,'***selAccessoriesList:'+ selAccessoriesList);
        }
    }
    


    //### STRUCTURAL SUBCLASS FOR ACCESSORY DATA AND QTY ###
    global class MobileDeviceAccessory {
        public O2_Dise_Ref_Hardware_Relation__c accessory {get;set;}
        public Integer quantity {get;set;}
        public String deviceId {get;set;}
        public MobileDeviceAccessory() {}
        public MobileDeviceAccessory(O2_Dise_Ref_Hardware_Relation__c a, Integer q) {
            this.accessory = a;
            this.quantity = q;
        }
    }
    //### REMOTE WRAPPER FOR ACCESSORY QUERY METHOD ###
    @remoteAction
    global static MobileDeviceAccessory[] getJSDeviceAccessories(String prodId, String prodCode) {
        return getDeviceAccessories(prodId, prodCode);
    }
    //### CORE ACCESSORY QUERY METHOD ###
    public static MobileDeviceAccessory[] getDeviceAccessories(String prodId, String prodCode) {
        String strQuery = 'SELECT Id, ';
        MobileDeviceAccessory[] retAccessories = new MobileDeviceAccessory[0];
        O2_Dise_Ref_Hardware_Relation__c[] qryRes = new O2_Dise_Ref_Hardware_Relation__c[0];
        //get dynamic list of fields from HS selection object
        Map<String, Schema.sObjectField> mpHSFields = Schema.sObjectType.O2_Dise_Ref_Hardware_Portfolio__c.fields.getMap();
        for (Schema.sObjectField fld: mpHSFields.values()) {
            String fldName=fld.getDescribe().getName();
            if(fld.getDescribe().getType()!=Schema.DisplayType.Date && fld.getDescribe().getType()!=Schema.DisplayType.DateTime) {
                strQuery+='Child_Product_Code__r.'+fldName+',';
            }
        }
        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery+=' FROM O2_Dise_Ref_Hardware_Relation__c WHERE Child_Product_Code__r.Hardware_Type__c = \'Accessory\'';

        if (prodId!=null && prodId!='') {
            strQuery+=' AND Parent_Product_Code__c = \''+prodId+'\'';
        }

        if (prodCode!=null && prodCode!='') {
            strQuery+=' AND Parent_Product_Code__r.Product_Code__c = \''+prodCode+'\'';
        }

        strQuery+=' ORDER BY CreatedDate';

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getDeviceAccessories: strQuery: '+strQuery);
        qryRes = Database.query(strQuery);
        if (qryRes!=null && qryRes.size()>0) {
            for (O2_Dise_Ref_Hardware_Relation__c device: qryRes) {
                retAccessories.add(new MobileDeviceAccessory(device, 0));
            }
        }

        return retAccessories;
    }
    //Array to store selected accessories - populated using actionFunction when quantity is incremented/decremented/amended
    public MobileDeviceAccessory[] availableAccessories;
    public MobileDeviceAccessory[] getAvailableAccessories() {
        if (availableAccessories==null || availableAccessories.size()==0) {
            if ((selectedProductId!=null || selectedProductCode!=null) && selectedHandset==null) {selectedHandset = getSelectedDevice(selectedProductId, selectedProductCode);}
            if (selectedHandset!=null) availableAccessories = getDeviceAccessories(selectedHandset.Product_Code__c, selectedHandset.Product_Code__r.Product_Code__c);
        }
        return availableAccessories;
    }
    //limit of number of allowed accessories each from custom setting
    public Integer maxAccessories {
        get {if (maxAccessories==null) return Integer.valueOf(OnlineGeneralSettings__c.getInstance('maxPerAccessory').Value__c); else return maxAccessories;}
        set;
    }

    @remoteAction
    global static O2_Dise_Map_Handset__c[] getHandsetPricing(String sProdCodes, String sTariffs) {
        O2_Dise_Map_Handset__c[] retPricing = new O2_Dise_Map_Handset__c[0];
        String strQuery = 'SELECT Product_Code__c, Base_Tariff__c, Handset_Model__c, Handset_Description__c, Discounted_Price__c, Insurance_Service_Price__c, Insurance_Service_Code__c' +
                          ' FROM O2_Dise_Map_Handset__c';
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getHandsetPricing: sProdCodes: '+sProdCodes);
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getHandsetPricing: sTariffs: '+sTariffs);
        if (sProdCodes != null && sProdCodes != '') {
            Set<String> sCodes = new Set<String>();
            if (sProdCodes.contains(',')) {
                for (String s: sProdCodes.split(',')) {sCodes.add(s);}
                if (strQuery.contains(' WHERE')) {strQuery+=' AND Product_Code__c IN :sCodes';}
                else {strQuery+=' WHERE Product_Code__c IN :sCodes';}
            } else {
                if (strQuery.contains(' WHERE')) {strQuery+=' AND Product_Code__c = \''+sProdCodes+'\'';}
                else {strQuery+=' WHERE Product_Code__c = \''+sProdCodes+'\'';}
            }
        }

        if (sTariffs != null && sTariffs != '') {
            Set<String> sNames = new Set<String>();
            if (sTariffs.contains(',')) {
                for (String s: sTariffs.split(',')) {sNames.add(s);}
                if (strQuery.contains(' WHERE')) {strQuery+=' AND Base_Tariff__c IN :sNames';}
                else {strQuery+=' WHERE Base_Tariff__c IN :sNames';}
            } else {
                if (strQuery.contains(' WHERE')) {strQuery+=' AND Base_Tariff__c = \''+sTariffs+'\'';}
                else {strQuery+=' WHERE Base_Tariff__c = \''+sTariffs+'\'';}
            }
        }
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> getHandsetPricing: strQuery: '+strQuery);
        retPricing = Database.query(strQuery);
        return retPricing;
    }

    public PageReference goToBasket() {
        return maincontroller.goToBasket();
    }

    private Map<Id, MobileDeviceJS> hsMap = new Map<Id, MobileDeviceJS>(); // map handset selection id to ordered device
    private Map<String, Id> simMap = new Map<String, Id>(); // map sim product ref to handset_selection id
    private Set<String> hsProcessedSet=new Set<String>();
    private Set<String> boSet = new Set<String>();
    private Set<String> simSet = new Set<String>();
    private Set<String> hsSet = new Set<String>();

    public PageReference addProductToSessionBasketTLThenGotoBasket() {
        addProductToSessionBasketTL();
        return goToBasket();
    }

    public PageReference addProductToSessionBasketTL() {

        PageReference pgSAVE_ERROR = Page.O2OnlineExceptionPage;

        if (maincontroller.apiSession != null) {
            maincontroller.newApiSession = maincontroller.apiSession;
        } else {
            maincontroller.initSession();
        }
        if (maincontroller.newAPISession != null && maincontroller.newUserSession == null) {
            maincontroller.newUserSession = maincontroller.newApiSession.getUserSession();
        } else if (maincontroller.newApiSession != null && maincontroller.newUserSession != null) {
            maincontroller.newUserSession = maincontroller.newApiSession.loadUserSession(maincontroller.newApiSession.getUserSession().usersession.Id);
        }
        if (maincontroller.newUserSession == null) {
            maincontroller.newUserSession = cscfgc.SessionManager.getSessionInfo();
        }
        if (maincontroller.userSession == null) {
            maincontroller.userSession = maincontroller.newUserSession;
        }

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: new session variables: userSession--'+maincontroller.newUserSession);
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: new session variables: apiSession--'+maincontroller.newApiSession);
        //maincontroller.productName = maincontroller.getProduct();
        //System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket2: product name: --'+maincontroller.productName);
        if (maincontroller.apiSession == null) maincontroller.newApiSession = maincontroller.apiSession = cscfgc.API_1.getApiSession();

        System.debug(LoggingLevel.INFO,'***newApiSession:'+maincontroller.newApiSession);
        System.debug(LoggingLevel.INFO,'***apiSession:'+maincontroller.apiSession);

        // Parse our dynamic summary JSON into objects
        parse();
        parseAccessories();
        System.debug(LoggingLevel.INFO,'***selDevicesList'+selDevicesListNew);
        System.debug(LoggingLevel.INFO,'***deviceDynList'+deviceDynList);
        System.debug(LoggingLevel.INFO,'***accessoryDynList'+accessoryDynList);
        System.debug(LoggingLevel.INFO,'***selectedBoltOnIds'+selectedBoltOnIds);

        // Create maps and sets of object IDs for which we want Offers
        hsMap.clear();
        simMap.clear();
        boSet.clear();
        hsSet.clear();
        simSet.clear();
        Integer deviceTotal=0;  // device total should match eventual number of parent product_configurations
        for(MobileDeviceJS dev : selDevicesListNew) {
            if (dev.quantity<1) { // ignore zero quantity hs - Configurator rejects them anyway
                continue;
            }
            hsMap.put(dev.device.id, dev);
            if(dev.device.Handset_Class__c=='SIM') {
                simSet.add(dev.device.Product_Code__r.Product_Code__c);
                simMap.put(dev.device.Product_Code__r.Product_Code__c, dev.device.id);
            } else {
                hsSet.add(dev.device.id);
            }
            deviceTotal += dev.quantity;
        }
        Set<Id> acSet=new Set<Id>();
        for(MobileAccessoryJS acc : selAccessoriesList) {
//          acSet.add(acc.accessory.child_product_code__c);
            acSet.add(acc.accessory.id);
        }
        if (selectedBoltOnIds != null && selectedBoltOnIds != '') {
            if (selectedBoltOnIds.contains(',')) {
                for (String s: selectedBoltOnIds.split(',')) {boSet.add(s);}
            } else {
                boSet.add(selectedBoltOnIds);
            }
        }
        System.debug(LoggingLevel.INFO,'***hsMap'+hsMap);
        System.debug(LoggingLevel.INFO,'***hsSet'+hsSet);
        System.debug(LoggingLevel.INFO,'***simSet'+simSet);
        System.debug(LoggingLevel.INFO,'***boSet'+boSet);
        System.debug(LoggingLevel.INFO,'***acSet'+acSet);
        // Get all the Configurations we need to clone. Note: will contain extras as we need to filter quantities
        List<cscfgc__Product_Configuration__c> templateConfigs =
                [select id, Name, O2_DISE_Map_Mobile__c, O2_DISE_Map_Handset_Selection__c, Insurance__c,
                            O2_DISE_Ref_Hardware_Relation__c, O2_DISE_Ref_Hardware_Portfolio__c, O2_DISE_Map_Mobile_Bolton__c, Quantity_of_Accessory__c,
                            SIM_Type__c
                    from cscfgc__Product_Configuration__c
                    where ((O2_DISE_Map_Mobile__c=:selTariffsList[0].tariff.id and O2_DISE_Map_Handset_Selection__c IN :hsSet
                        AND O2_DISE_Ref_Hardware_Relation__c=null AND O2_DISE_Map_Mobile_Bolton__c=null)
                        OR (O2_DISE_Ref_Hardware_Relation__c IN :acSet AND O2_DISE_Map_Mobile__c=null AND O2_DISE_Map_Handset_Selection__c=null)
                        OR (O2_DISE_Map_Mobile_Bolton__c IN :boSet AND O2_DISE_Map_Mobile__c=null AND O2_DISE_Map_Handset_Selection__c=null)
                        OR (SIM_Type__c IN :simSet AND O2_DISE_Map_Mobile__c=:selTariffsList[0].tariff.id AND O2_DISE_Map_Handset_Selection__c=null AND O2_DISE_Ref_Hardware_Relation__c=null AND O2_DISE_Map_Mobile_Bolton__c=null))
                        AND cscfgc__Configuration_Offer__c<>null
                        AND cscfgc__Configuration_Status__c = 'Valid'];

        // Build ALL config copy requests
        List<cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest> copyRequestList = new List<cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest>();

        // initialise hs set - to track each is processed only once
        hsProcessedSet.clear();

        for (cscfgc__Product_Configuration__c config : templateConfigs) {
            Integer qty=1;

            System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: config:--'+config);
            // check if handset
            if(config.O2_DISE_Map_Handset_Selection__c!=null) {
                MobileDeviceJS handset=matchHandsetConfig(config);
                if(handset!=null)
                    qty=handset.quantity;
                else
                    continue;
            } else {
                // check if accessory
                if(config.O2_Dise_Ref_Hardware_Relation__c!=null) {
                    List<MobileAccessoryJS> accList = matchAccessoryConfig(config);
                    if(accList.isEmpty()) continue; // accessory we don't want, e.g. wrong quantity
                    qty = accList.size();
                } else {
                    // check if bolt-on
                    if(config.O2_DISE_Map_Mobile_Bolton__c!=null) {
                        qty=deviceTotal; // Bolt-on will be added to every parent config
                    } else {
                        // check if SIM
                        if(config.SIM_Type__c!=null) {
                            MobileDeviceJS sim=matchSIMConfig(config);
                            if(sim!=null)
                                qty=sim.quantity;
                            else
                                continue;
                        } else {
                            continue; // A Config we don't want!
                        }
                    }
                }
            }
            // Add to copy list
            system.debug(LoggingLevel.INFO,'****requesting:'+qty+' of '+config.Name);
            copyRequestList.add(new cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest(config.id, qty));
        }
        system.debug(LoggingLevel.INFO,'****copyRequestList:'+copyRequestList);

        if(copyRequestList.isEmpty()) {
            system.debug(LoggingLevel.INFO,'*** Empty copyRequestList check soql query (on cscfgc__Product_Configuration__c) for requested items in hsSet, simSet, boSet and acSet (listed above)! ***');
            throw new O2OnlineMobileException('None of your products have been found for your tariff: ' + selTariffsList[0].tariff.Name);
        }


        //////// Copy to the actual configurations to use ////////
        List<Id> ids = cscfgc.ProductConfigurationHelper.copyConfigurations(copyRequestList, null, maincontroller.newAPISession.getBasket().Id);


        // Get the new configs we just made
        List<cscfgc__Product_Configuration__c> configs = [
            select id, name, cscfgc__configuration_status__c,
                cscfgc__Root_Configuration__c, cscfgc__Parent_Configuration__c,
                O2_DISE_Map_Handset_Selection__c,
                O2_DISE_Ref_Hardware_Relation__c,
                O2_DISE_Ref_Hardware_Portfolio__c,
                O2_DISE_Map_Mobile_Bolton__c,
                Quantity_of_Accessory__c,
                SIM_Type__c,
                cscfgc__Configuration_Offer__c
            from cscfgc__Product_Configuration__c where id in :ids]; // and cscfgc__parent_configuration__c = null];


        system.debug(LoggingLevel.INFO,'****new Ids:'+ids);
        system.debug(LoggingLevel.INFO,'****new configs:'+configs);

        //sort configs into types
        List<cscfgc__Product_Configuration__c> topConfigList = new List<cscfgc__Product_Configuration__c>();
        List<cscfgc__Product_Configuration__c> acConfigList = new List<cscfgc__Product_Configuration__c>();
        Map<Id, List<cscfgc__Product_Configuration__c>> boConfigMap = new Map<Id, List<cscfgc__Product_Configuration__c>>();
        Set<String> topConfigIds = new Set<String>();


        for(cscfgc__Product_Configuration__c config : configs) {

            system.debug(LoggingLevel.INFO,'****process config:'+config);

            //remove parent Offer from all our new product configurations
            config.cscfgc__Configuration_Offer__c=null;

            if(config.O2_DISE_Map_Handset_Selection__c!=null || config.SIM_Type__c!=null) {
                topConfigList.add(config);
                topConfigIds.add(config.id);
            }
            if(config.O2_DISE_Ref_Hardware_Relation__c!=null) {
                acConfigList.add(config);
            }
            if(config.O2_DISE_Map_Mobile_Bolton__c!=null) {
                List<cscfgc__Product_Configuration__c> boConfigList=new List<cscfgc__Product_Configuration__c>();
                if(boConfigMap.containsKey(config.O2_DISE_Map_Mobile_Bolton__c)) {
                    boConfigList.addAll(boConfigMap.get(config.O2_DISE_Map_Mobile_Bolton__c));
                }
                boConfigList.add(config);
                boConfigMap.put(config.O2_DISE_Map_Mobile_Bolton__c, boConfigList);
            }
        }

        update configs;


        // Map bolt on and accessories attributes for top-level configs
        List<cscfgc__Attribute__c> attrList = [SELECT Id, Name, cscfgc__Value__c , cscfgc__Product_Configuration__c
                FROM cscfgc__Attribute__c
                WHERE cscfgc__Product_Configuration__c IN :topConfigIds
                AND (Name='Bolt On' OR Name='Accessories')];

        Map<Id, cscfgc__Attribute__c> acConfigAttrMap = new Map<Id, cscfgc__Attribute__c>();
        Map<Id, cscfgc__Attribute__c> boConfigAttrMap = new Map<Id, cscfgc__Attribute__c>();
        for(cscfgc__Attribute__c attr : attrList) {
            if(attr.Name=='Bolt On') {  // bolt-ons go on every parent (related to tariff)
                boConfigAttrMap.put(attr.cscfgc__Product_Configuration__c, attr);
            }
            if(attr.Name=='Accessories') {  // accessories go on every parent (related to handset)
                acConfigAttrMap.put(attr.cscfgc__Product_Configuration__c, attr);
            }
        }

        // Process each parent(top-level config) setting fields as required
        List<cscfgc__Attribute__c> attrUpdateList=new List<cscfgc__Attribute__c>();
        List<cscfgc__Product_Configuration__c> relConfigUpdateList=new List<cscfgc__Product_Configuration__c>();
        List<MobileAccessoryJS> accProcessList = new List<MobileAccessoryJS>();
        accProcessList.addAll(selAccessoriesList);
        set<Id> processedAccConfigSet = new set<Id>();

        for(cscfgc__Product_Configuration__c topConfig : topConfigList) {

            // Bolt-ons

            // loop thru bolton configs for this device relating each to this parent (topConfig). e.g. 'interntional favourites' or 'data bolt on'
            cscfgc__Attribute__c boAttr = boConfigAttrMap.get(topConfig.Id);
            boAttr.cscfgc__Value__c = ''; //initialise value
            for(Id boId : boConfigMap.keySet()) {
                // get next child config
                cscfgc__Product_Configuration__c boConf = boConfigMap.get(boId).get(0);

                //set child on parent
                //if (boConfigMap.get(boId).size()==1) boAttr.cscfgc__Value__c+=boConf.Id;
                //else
                boAttr.cscfgc__Value__c += boConf.Id + ',';

                //set parent on child
                boConf.cscfgc__Parent_Configuration__c = topConfig.Id;
                boConf.cscfgc__Root_Configuration__c = topConfig.Id;
                relConfigUpdateList.add(boConf);

                // remove this child config from this list so we don't process it again
                boConfigMap.get(boId).remove(0);
            }
            //if attribute set add to update list and remove last comma
            if(boAttr!=null && boAttr.cscfgc__Value__c!=null && boAttr.cscfgc__Value__c!='')  {
                boAttr.cscfgc__Value__c = boAttr.cscfgc__Value__c.substring(0, boAttr.cscfgc__Value__c.length()-1);
                attrUpdateList.add(boAttr);
            }

            // Accessories

            //get all accessories we have for this device that HAVE NOT been processed
            List<MobileAccessoryJS> accList = new List<MobileAccessoryJS>();
            for(MobileAccessoryJS acc : accProcessList) {
                if(acc.deviceId==topConfig.O2_DISE_Map_Handset_Selection__c) {
                    accList.add(acc);
                }
            }

            for(MobileAccessoryJS acc : accList) {  // remove so we don't add them again
                for(Integer i=accProcessList.size()-1; i>=0; i--) {
                    if(acc.accessory.id==accProcessList.get(i).accessory.id &&
                            acc.deviceid==accProcessList.get(i).deviceid &&
                            acc.quantity==accProcessList.get(i).quantity)
                        accProcessList.remove(i);
                }
            }

            cscfgc__Attribute__c acAttr = acConfigAttrMap.get(topConfig.Id);
            acAttr.cscfgc__Value__c = ''; //initialise value
            for(MobileAccessoryJS acc : accList) {
                for(cscfgc__Product_Configuration__c accConf : acConfigList) {

                    // ignore if we have used this before
                    if (processedAccConfigSet.contains(accConf.Id))
                        continue;
//                  if(acc.accessory.child_product_code__c==accConf.O2_DISE_Ref_Hardware_Portfolio__c &&
                    if(acc.accessory.id==accConf.O2_DISE_Ref_Hardware_Relation__c &&
                            acc.quantity==accConf.Quantity_of_Accessory__c) {

                        //set child on parent
                        acAttr.cscfgc__Value__c += accConf.Id + ',';

                        //set parent on child
                        accConf.cscfgc__Parent_Configuration__c = topConfig.Id;
                        accConf.cscfgc__Root_Configuration__c = topConfig.Id;
                        relConfigUpdateList.add(accConf);
                        processedAccConfigSet.add(accConf.Id);
                        // matched this accesssory - go to next accessory
                        break;

                    }
                }
            }
            //if attribute set add to update list and remove last comma
            if(acAttr!=null && acAttr.cscfgc__Value__c!=null && acAttr.cscfgc__Value__c!='') {
                acAttr.cscfgc__Value__c = acAttr.cscfgc__Value__c.substring(0, acAttr.cscfgc__Value__c.length()-1);
                attrUpdateList.add(acAttr);
            }
        }
        //topConfigList.addAll(relConfigUpdateList);
        for (cscfgc__Product_Configuration__c pConf : relConfigUpdateList) {
            system.debug(LoggingLevel.INFO,'****relConfigUpdateList:'+pConf);
        }
        update relConfigUpdateList;
        update attrUpdateList;


        return null;
    }

    // this version of the method does not get it's data from the JSON, so the lists need to be prepopulated beforehand
    // populate beforehand: selDevicesListNew, selTariffsList, selAccessoriesList, selectedBoltOnIds
    public PageReference addProductToSessionBasketTL_General() {

        PageReference pgSAVE_ERROR = Page.O2OnlineExceptionPage;

        if (maincontroller.apiSession != null) {
            maincontroller.newApiSession = maincontroller.apiSession;
        } else {
            //maincontroller.initSession();
            maincontroller.newApiSession = maincontroller.apiSession = cscfgc.API_1.getApiSession();
        }
        if (maincontroller.newAPISession != null && maincontroller.newUserSession == null) {
            maincontroller.newUserSession = maincontroller.newApiSession.getUserSession();
        } else if (maincontroller.newApiSession != null && maincontroller.newUserSession != null) {
            maincontroller.newUserSession = maincontroller.newApiSession.loadUserSession(maincontroller.newApiSession.getUserSession().usersession.Id);
        }
        if (maincontroller.newUserSession == null) {
            maincontroller.newUserSession = cscfgc.SessionManager.getSessionInfo();
        }
        if (maincontroller.userSession == null) {
            maincontroller.userSession = maincontroller.newUserSession;
        }

        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: new session variables: userSession--'+maincontroller.newUserSession);
        System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: new session variables: apiSession--'+maincontroller.newApiSession);
        //maincontroller.productName = maincontroller.getProduct();
        //System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket2: product name: --'+maincontroller.productName);

        System.debug(LoggingLevel.INFO,'***newApiSession:'+maincontroller.newApiSession);
        System.debug(LoggingLevel.INFO,'***apiSession:'+maincontroller.apiSession);

        System.debug(LoggingLevel.INFO,'***selDevicesList'+selDevicesListNew);
        System.debug(LoggingLevel.INFO,'***deviceDynList'+deviceDynList);
        System.debug(LoggingLevel.INFO,'***accessoryDynList'+accessoryDynList);
        System.debug(LoggingLevel.INFO,'***selectedBoltOnIds'+selectedBoltOnIds);
        System.debug(LoggingLevel.INFO,'***selTariffsList'+selTariffsList);

        // Create maps and sets of object IDs for which we want Offers
        hsMap.clear();
        simMap.clear();
        boSet.clear();
        hsSet.clear();
        simSet.clear();
        Integer deviceTotal=0;  // device total should match eventual number of parent product_configurations
        for(MobileDeviceJS dev : selDevicesListNew) {
            if (dev.quantity<1) { // ignore zero quantity hs - Configurator rejects them anyway
                continue;
            }
            hsMap.put(dev.device.id, dev);
            if(dev.device.Handset_Class__c=='SIM') {
                simSet.add(dev.device.Product_Code__r.Product_Code__c);
                simMap.put(dev.device.Product_Code__r.Product_Code__c, dev.device.id);
            } else {
                hsSet.add(dev.device.id);
            }
            deviceTotal += dev.quantity;
        }
        Set<Id> acSet=new Set<Id>();
        for(MobileAccessoryJS acc : selAccessoriesList) {
//          acSet.add(acc.accessory.child_product_code__c);
            acSet.add(acc.accessory.id);
        }
        if (selectedBoltOnIds != null && selectedBoltOnIds != '') {
            if (selectedBoltOnIds.contains(',')) {
                for (String s: selectedBoltOnIds.split(',')) {boSet.add(s);}
            } else {
                boSet.add(selectedBoltOnIds);
            }
        }
        System.debug(LoggingLevel.INFO,'***hsMap'+hsMap);
        System.debug(LoggingLevel.INFO,'***hsSet'+hsSet);
        System.debug(LoggingLevel.INFO,'***simSet'+simSet);
        System.debug(LoggingLevel.INFO,'***boSet'+boSet);
        System.debug(LoggingLevel.INFO,'***acSet'+acSet);
        // Get all the Configurations we need to clone. Note: will contain extras as we need to filter quantities
        List<cscfgc__Product_Configuration__c> templateConfigs =
                [select id, Name, O2_DISE_Map_Mobile__c, O2_DISE_Map_Handset_Selection__c, Insurance__c,
                            O2_DISE_Ref_Hardware_Relation__c, O2_DISE_Ref_Hardware_Portfolio__c, O2_DISE_Map_Mobile_Bolton__c, Quantity_of_Accessory__c,
                            SIM_Type__c
                    from cscfgc__Product_Configuration__c
                    where ((O2_DISE_Map_Mobile__c=:selTariffsList[0].tariff.id and O2_DISE_Map_Handset_Selection__c IN :hsSet
                        AND O2_DISE_Ref_Hardware_Relation__c=null AND O2_DISE_Map_Mobile_Bolton__c=null)
                        OR (O2_DISE_Ref_Hardware_Relation__c IN :acSet AND O2_DISE_Map_Mobile__c=null AND O2_DISE_Map_Handset_Selection__c=null)
                        OR (O2_DISE_Map_Mobile_Bolton__c IN :boSet AND O2_DISE_Map_Mobile__c=null AND O2_DISE_Map_Handset_Selection__c=null)
                        OR (SIM_Type__c IN :simSet AND O2_DISE_Map_Mobile__c=:selTariffsList[0].tariff.id AND O2_DISE_Map_Handset_Selection__c=null AND O2_DISE_Ref_Hardware_Relation__c=null AND O2_DISE_Map_Mobile_Bolton__c=null))
                        AND cscfgc__Configuration_Offer__c<>null
                        AND cscfgc__Configuration_Status__c = 'Valid'];

        // Build ALL config copy requests
        List<cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest> copyRequestList = new List<cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest>();

        // initialise hs set - to track each is processed only once
        hsProcessedSet.clear();

        for (cscfgc__Product_Configuration__c config : templateConfigs) {
            Integer qty=1;

            System.debug(LoggingLevel.INFO,'### OUTPUT >>>>> addProductToSessionBasket: config:--'+config);
            // check if handset
            if(config.O2_DISE_Map_Handset_Selection__c!=null) {
                MobileDeviceJS handset=matchHandsetConfig(config);
                if(handset!=null)
                    qty=handset.quantity;
                else
                    continue;
            } else {
                // check if accessory
                if(config.O2_Dise_Ref_Hardware_Relation__c!=null) {
                    List<MobileAccessoryJS> accList = matchAccessoryConfig(config);
                    if(accList.isEmpty()) continue; // accessory we don't want, e.g. wrong quantity
                    qty = accList.size();
                } else {
                    // check if bolt-on
                    if(config.O2_DISE_Map_Mobile_Bolton__c!=null) {
                        qty=deviceTotal; // Bolt-on will be added to every parent config
                    } else {
                        // check if SIM
                        if(config.SIM_Type__c!=null) {
                            MobileDeviceJS sim=matchSIMConfig(config);
                            if(sim!=null)
                                qty=sim.quantity;
                            else
                                continue;
                        } else {
                            continue; // A Config we don't want!
                        }
                    }
                }
            }
            // Add to copy list
            system.debug(LoggingLevel.INFO,'****requesting:'+qty+' of '+config.Name);
            copyRequestList.add(new cscfgc.ProductConfigurationHelper.ConfigurationCopyRequest(config.id, qty));
        }
        system.debug(LoggingLevel.INFO,'****copyRequestList:'+copyRequestList);

        if(copyRequestList.isEmpty()) {
            system.debug(LoggingLevel.INFO,'*** Empty copyRequestList check soql query (on cscfgc__Product_Configuration__c) for requested items in hsSet, simSet, boSet and acSet (listed above)! ***');
            throw new O2OnlineMobileException('None of your products have been found for your tariff: ' + selTariffsList[0].tariff.Name);
        }


        //////// Copy to the actual configurations to use ////////
        List<Id> ids = cscfgc.ProductConfigurationHelper.copyConfigurations(copyRequestList, null, maincontroller.newAPISession.getBasket().Id);


        // Get the new configs we just made
        List<cscfgc__Product_Configuration__c> configs = [
            select id, name, cscfgc__configuration_status__c,
                cscfgc__Root_Configuration__c, cscfgc__Parent_Configuration__c,
                O2_DISE_Map_Handset_Selection__c,
                O2_DISE_Ref_Hardware_Relation__c,
                O2_DISE_Ref_Hardware_Portfolio__c,
                O2_DISE_Map_Mobile_Bolton__c,
                Quantity_of_Accessory__c,
                SIM_Type__c,
                cscfgc__Configuration_Offer__c
            from cscfgc__Product_Configuration__c where id in :ids]; // and cscfgc__parent_configuration__c = null];


        system.debug(LoggingLevel.INFO,'****new Ids:'+ids);
        system.debug(LoggingLevel.INFO,'****new configs:'+configs);

        //sort configs into types
        List<cscfgc__Product_Configuration__c> topConfigList = new List<cscfgc__Product_Configuration__c>();
        List<cscfgc__Product_Configuration__c> acConfigList = new List<cscfgc__Product_Configuration__c>();
        Map<Id, List<cscfgc__Product_Configuration__c>> boConfigMap = new Map<Id, List<cscfgc__Product_Configuration__c>>();
        Set<String> topConfigIds = new Set<String>();


        for(cscfgc__Product_Configuration__c config : configs) {

            system.debug(LoggingLevel.INFO,'****process config:'+config);

            //remove parent Offer from all our new product configurations
            config.cscfgc__Configuration_Offer__c=null;

            if(config.O2_DISE_Map_Handset_Selection__c!=null || config.SIM_Type__c!=null) {
                topConfigList.add(config);
                topConfigIds.add(config.id);
            }
            if(config.O2_DISE_Ref_Hardware_Relation__c!=null) {
                acConfigList.add(config);
            }
            if(config.O2_DISE_Map_Mobile_Bolton__c!=null) {
                List<cscfgc__Product_Configuration__c> boConfigList=new List<cscfgc__Product_Configuration__c>();
                if(boConfigMap.containsKey(config.O2_DISE_Map_Mobile_Bolton__c)) {
                    boConfigList.addAll(boConfigMap.get(config.O2_DISE_Map_Mobile_Bolton__c));
                }
                boConfigList.add(config);
                boConfigMap.put(config.O2_DISE_Map_Mobile_Bolton__c, boConfigList);
            }
        }

        update configs;


        // Map bolt on and accessories attributes for top-level configs
        List<cscfgc__Attribute__c> attrList = [SELECT Id, Name, cscfgc__Value__c , cscfgc__Product_Configuration__c
                FROM cscfgc__Attribute__c
                WHERE cscfgc__Product_Configuration__c IN :topConfigIds
                AND (Name='Bolt On' OR Name='Accessories')];

        Map<Id, cscfgc__Attribute__c> acConfigAttrMap = new Map<Id, cscfgc__Attribute__c>();
        Map<Id, cscfgc__Attribute__c> boConfigAttrMap = new Map<Id, cscfgc__Attribute__c>();
        for(cscfgc__Attribute__c attr : attrList) {
            if(attr.Name=='Bolt On') {  // bolt-ons go on every parent (related to tariff)
                boConfigAttrMap.put(attr.cscfgc__Product_Configuration__c, attr);
            }
            if(attr.Name=='Accessories') {  // accessories go on every parent (related to handset)
                acConfigAttrMap.put(attr.cscfgc__Product_Configuration__c, attr);
            }
        }

        // Process each parent(top-level config) setting fields as required
        List<cscfgc__Attribute__c> attrUpdateList=new List<cscfgc__Attribute__c>();
        List<cscfgc__Product_Configuration__c> relConfigUpdateList=new List<cscfgc__Product_Configuration__c>();
        List<MobileAccessoryJS> accProcessList = new List<MobileAccessoryJS>();
        accProcessList.addAll(selAccessoriesList);
        set<Id> processedAccConfigSet = new set<Id>();

        for(cscfgc__Product_Configuration__c topConfig : topConfigList) {

            // Bolt-ons

            // loop thru bolton configs for this device relating each to this parent (topConfig). e.g. 'interntional favourites' or 'data bolt on'
            cscfgc__Attribute__c boAttr = boConfigAttrMap.get(topConfig.Id);
            boAttr.cscfgc__Value__c = ''; //initialise value
            for(Id boId : boConfigMap.keySet()) {
                // get next child config
                cscfgc__Product_Configuration__c boConf = boConfigMap.get(boId).get(0);

                //set child on parent
                //if (boConfigMap.get(boId).size()==1) boAttr.cscfgc__Value__c+=boConf.Id;
                //else
                boAttr.cscfgc__Value__c += boConf.Id + ',';

                //set parent on child
                boConf.cscfgc__Parent_Configuration__c = topConfig.Id;
                boConf.cscfgc__Root_Configuration__c = topConfig.Id;
                relConfigUpdateList.add(boConf);

                // remove this child config from this list so we don't process it again
                boConfigMap.get(boId).remove(0);
            }
            //if attribute set add to update list and remove last comma
            if(boAttr!=null && boAttr.cscfgc__Value__c!=null && boAttr.cscfgc__Value__c!='')  {
                boAttr.cscfgc__Value__c = boAttr.cscfgc__Value__c.substring(0, boAttr.cscfgc__Value__c.length()-1);
                attrUpdateList.add(boAttr);
            }

            // Accessories

            //get all accessories we have for this device that HAVE NOT been processed
            List<MobileAccessoryJS> accList = new List<MobileAccessoryJS>();
            for(MobileAccessoryJS acc : accProcessList) {
                if(acc.deviceId==topConfig.O2_DISE_Map_Handset_Selection__c) {
                    accList.add(acc);
                }
            }

            for(MobileAccessoryJS acc : accList) {  // remove so we don't add them again
                for(Integer i=accProcessList.size()-1; i>=0; i--) {
                    if(acc.accessory.id==accProcessList.get(i).accessory.id &&
                            acc.deviceid==accProcessList.get(i).deviceid &&
                            acc.quantity==accProcessList.get(i).quantity)
                        accProcessList.remove(i);
                }
            }

            cscfgc__Attribute__c acAttr = acConfigAttrMap.get(topConfig.Id);
            acAttr.cscfgc__Value__c = ''; //initialise value
            for(MobileAccessoryJS acc : accList) {
                for(cscfgc__Product_Configuration__c accConf : acConfigList) {

                    // ignore if we have used this before
                    if (processedAccConfigSet.contains(accConf.Id))
                        continue;
//                  if(acc.accessory.child_product_code__c==accConf.O2_DISE_Ref_Hardware_Portfolio__c &&
                    if(acc.accessory.id==accConf.O2_DISE_Ref_Hardware_Relation__c &&
                            acc.quantity==accConf.Quantity_of_Accessory__c) {

                        //set child on parent
                        acAttr.cscfgc__Value__c += accConf.Id + ',';

                        //set parent on child
                        accConf.cscfgc__Parent_Configuration__c = topConfig.Id;
                        accConf.cscfgc__Root_Configuration__c = topConfig.Id;
                        relConfigUpdateList.add(accConf);
                        processedAccConfigSet.add(accConf.Id);
                        // matched this accesssory - go to next accessory
                        break;

                    }
                }
            }
            //if attribute set add to update list and remove last comma
            if(acAttr!=null && acAttr.cscfgc__Value__c!=null && acAttr.cscfgc__Value__c!='') {
                acAttr.cscfgc__Value__c = acAttr.cscfgc__Value__c.substring(0, acAttr.cscfgc__Value__c.length()-1);
                attrUpdateList.add(acAttr);
            }
        }
        //topConfigList.addAll(relConfigUpdateList);
        for (cscfgc__Product_Configuration__c pConf : relConfigUpdateList) {
            system.debug(LoggingLevel.INFO,'****relConfigUpdateList:'+pConf);
        }
        update relConfigUpdateList;
        update attrUpdateList;


        return null;
    }

    public MobileDeviceJS matchSIMConfig(cscfgc__product_configuration__c config) {
        Id hsId=simMap.get(config.SIM_Type__c);

        //get the handset from our order
        MobileDeviceJS sim=hsMap.get(hsId);

        //if processed before ignore
        if(hsProcessedSet.contains(sim.device.id)) return null;

        //check other config fields correct
        if(config.insurance__c!=sim.insure) return null;

        //add handset to processed list so we don't process it again
        hsProcessedSet.add(sim.device.id);
        return sim;
    }

    public MobileDeviceJS matchHandsetConfig(cscfgc__product_configuration__c config) {
        //get the handset from our order
        MobileDeviceJS handset=hsMap.get(config.O2_DISE_Map_Handset_Selection__c);

        //if processed before ignore
        if(hsProcessedSet.contains(handset.device.id)) return null;

        //check other config fields correct
        if(config.insurance__c!=handset.insure) return null;

        //add handset to processed list so we don't process it again
        hsProcessedSet.add(handset.device.id);
        return handset;
    }

    public List<MobileAccessoryJS> matchAccessoryConfig(cscfgc__product_configuration__c config) {
        // check our accessory config
        List<MobileAccessoryJS> matchedAccList = new List<MobileAccessoryJS>();
        for(MobileAccessoryJS acc : selAccessoriesList) {
//          if(acc.accessory.Child_Product_Code__c==config.O2_Dise_Ref_Hardware_Portfolio__c &&
            if(acc.accessory.id==config.O2_Dise_Ref_Hardware_Relation__c &&
                    acc.quantity==config.Quantity_of_Accessory__c) {
                matchedAccList.add(acc);
            }
        }
        return matchedAccList;
    }

    public String getDisableStandardForPhoneTariffs() {
            if (OnlineGeneralSettings__c.getInstance('Disable Standard For Phone Tariffs')!=null)
                    return OnlineGeneralSettings__c.getInstance('Disable Standard For Phone Tariffs').Value__c;
            else return '';
    }

    @remoteAction
    global static string GetHardwareJSON(string HardwareId){
        string result = '';
        Attachment hardwareAtt = [SELECT Body FROM Attachment WHERE ParentId = :HardwareId ORDER BY LastModifiedDate desc LIMIT 1];
        if (hardwareAtt != null) {
            result = hardwareAtt.Body.toString();
        }
        return result;
    }
    
    @remoteAction
    global static O2_Reference_Codes__c[] getPromotions(string tariffType){
        List<O2_Reference_Codes__c> filters = new List<O2_Reference_Codes__c>();
        if(tariffType == 'Handset'){
            filters = [SELECT Type__c, Code__c, Code_Description__c, Sequence__c
                       FROM O2_Reference_Codes__c 
                       WHERE Type__c = 'FILTERPROMO' AND Inactive__c = false
                       ORDER BY Sequence__c];
        } else {
            filters = [SELECT Type__c, Code__c, Code_Description__c, Sequence__c
                       FROM O2_Reference_Codes__c 
                       WHERE Type__c = 'FILTERPROMOSIMONLY' AND Inactive__c = false
                       ORDER BY Sequence__c];
        }
        return filters;
    }

}