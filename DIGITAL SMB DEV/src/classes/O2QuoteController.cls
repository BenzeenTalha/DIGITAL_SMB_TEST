public with sharing class O2QuoteController {
    //
    private cscfgc__Product_Bundle__c bundle;
    private Opportunity opp;
    public List<cscfgc__Product_Configuration__c> configurationList;
    public List<cscfgc__Product_Configuration__c> configAllAtributeList;
    private String bundleId {get; set;}
    //
    public String configId {get; set;}
    //
    public Quote currentQuote {get; set;}
    //
    // Controller
    public O2QuoteController(ApexPages.StandardController c) {

        System.debug('RECORDTYPE: ' + c.getRecord().getSObjectType());

        if (c.getRecord().getSObjectType() == Quote.sObjectType) {
    		currentQuote = [SELECT
                            	Id, QuoteNumber, TotalPrice, GrandTotal, Opportunity.Account.Name, Contact.Name,
                            	BillingStreet, BillingPostalCode, BillingCity, BillingState, ExpirationDate, Period_Of_Validity__c,
                            	Customer_Reference_Number__c, Quotation_Request_Reference_Number__c, Description, Quote_Type__c
                          	FROM
                          		Quote
                          	WHERE
                          		Id = :c.getId()];
      		String oppId = [SELECT
          						opportunityId
          				  	FROM
          				  		Quote
          				  	WHERE
          				  		id =:c.getRecord().id].opportunityId;
        	opp = [SELECT
          				Id, Name, SyncedQuoteId,
          				(SELECT
          					cscfgc__attribute__r.cscfgc__product_configuration__r.cscfgc__product_bundle__c
          	   	   		FROM
          					OpportunityLineItems)
          	  	   FROM
          				Opportunity
          	  	WHERE
          	  		id =:oppId];
        	Integer i = 0;
			while (i < opp.opportunityLineItems.size() && bundleId == null) {
          		bundleId = opp.opportunityLineItems.get(i++).cscfgc__attribute__r.cscfgc__product_configuration__r.cscfgc__product_bundle__c;
        	}
		}

        //
        String queryString = null;
        queryString = 'SELECT cscfgc__Product_Definition__r.Name, ' + Utility.getSobjectFields('cscfgc__Product_Configuration__c') +
                	  ', (SELECT cscfgc__Attribute_Definition__r.Name, ' + Utility.getSobjectFields('cscfgc__Attribute__c') + ' FROM cscfgc__Attributes__r where cscfgc__Is_Line_Item__c = True) '+
            		  ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \'' + bundleId +'\' order by cscfgc__Parent_Configuration__c';
        configurationList = Database.query(queryString);

        //
        queryString = 'select cscfgc__Product_Definition__r.Name, ' + Utility.getSobjectFields('cscfgc__Product_Configuration__c') +
                ', (select cscfgc__Attribute_Definition__r.Name, ' + Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r) ' +
                ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \''+bundleId+'\' order by cscfgc__Parent_Configuration__c';
        configAllAtributeList = Database.query(queryString);
        }
    /**
    public List<cscfgc__Product_Configuration__c> getConfigs() {
            List<cscfgc__Product_Configuration__c> ConfigList = [select Name,cscfgc__Unit_Price__c, cscfgc__Quantity__c, cscfgc__Total_Price__c,
                                                                                                                                     Monthly_Recurring_Charge__c, One_Off_Charge__c, Directory_Number__c,
                                                                                                                            (select Name, cscfgc__Line_Item_Description__c, cscfgc__Line_Item_Sequence__c,
                                                                                                                                            cscfgc__Recurring__c,
                                                                                                                                            cscfgc__Annualised_Price__c, cscfgc__Price__c from cscfgc__Attributes__r
                                                                                                                                            where cscfgc__Is_Line_Item__c = true)
                                                                                                                            from cscfgc__Product_Configuration__c where cscfgc__Product_Bundle__c = :bundleId];
            //
            return ConfigList;
    }
    ***/


    public List<ConfigWrapper> getAllProductConfigurations() {
        // Get all the config Details
        String queryString = null;
            queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                    ', (select '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r where cscfgc__Is_Line_Item__c = True) '+
                        ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \''+bundleId+'\' order by cscfgc__Parent_Configuration__c';
            system.debug('**queryString'+queryString);
            List<cscfgc__Product_Configuration__c> configList = Database.query(queryString);
            //
            Map<String,ConfigWrapper> topLevelConfigMap = new Map<String,ConfigWrapper>();
            for (cscfgc__Product_Configuration__c config : configList) {
                    if (config.cscfgc__Parent_Configuration__c == null) {
                            topLevelConfigMap.put(config.Id,new ConfigWrapper(config,
                                                                                                                              config.cscfgc__Attributes__r,
                                                                                                                              config.Monthly_Recurring_Charge__c,
                                                                                                                              config.One_Off_Charge__c,
                                                                                                                              config.Monthly_Recurring_Charge__c+config.One_Off_Charge__c));
                    } else if (config.cscfgc__Parent_Configuration__c != null && topLevelConfigMap.containsKey(config.cscfgc__Parent_Configuration__c)) {
                            Decimal mrr = topLevelConfigMap.get(config.cscfgc__Parent_Configuration__c).monthlyRecurringCharge;
                            Decimal nrr = topLevelConfigMap.get(config.cscfgc__Parent_Configuration__c).oneOffCharge;
                            cscfgc__Product_Configuration__c parentConfig = topLevelConfigMap.get(config.cscfgc__Parent_Configuration__c).config;
                            //
                            mrr += config.Monthly_Recurring_Charge__c;
                            nrr += config.One_Off_Charge__c;
                            //
                            List<cscfgc__Attribute__c> attributeList = new List<cscfgc__Attribute__c>();
                            attributeList.addAll(parentConfig.cscfgc__Attributes__r);
                            attributeList.addAll(config.cscfgc__Attributes__r);
                            //
                            topLevelConfigMap.put(config.cscfgc__Parent_Configuration__c,new ConfigWrapper(parentConfig,attributeList,mrr,nrr,mrr+nrr));
                    }
            }
            //
            return topLevelConfigMap.values();
    }

    public class ConfigWrapper {
        public cscfgc__Product_Configuration__c config {get; set;}
        public List<cscfgc__Attribute__c> attributeList {get; set;}
        public Decimal monthlyRecurringCharge {get; set;}
        public Decimal oneOffCharge {get; set;}
        public Decimal totalContractValue {get; set;}

        public ConfigWrapper(cscfgc__Product_Configuration__c conf, List<cscfgc__Attribute__c> attList, Decimal mrr, Decimal nrr, Decimal total) {
            config = conf;
            attributeList = attList;
            monthlyRecurringCharge = mrr;
            oneOffCharge = nrr;
            totalContractValue = total;
        }
    }

    public Boolean getIsLandline() {
        //
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB Landline') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise Landline')) {
                            return true;
                    }
            }
            //
            return false;
    }

    public String getNumberLandline() {
        //
        Integer numberOfLines = 0;
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB Landline') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise Landline')) {
                        for (cscfgc__Attribute__c att : config.cscfgc__Attributes__r) {
                                if (att.cscfgc__Attribute_Definition__r.Name == 'Number of Lines') {
                                        numberOfLines += Integer.ValueOf(att.cscfgc__Value__c);
                                }
                                }
                    }
            }
            //
            String lineStr = ' Lines';
            if (numberOfLines == 1) lineStr = ' Line';
            return ''+numberOfLines+lineStr;
    }

    public Boolean getIsCallsOnly() {
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB Calls Only') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise Calls Only')) {
                            return true;
                    }
            }
            //
            return false;
    }

    public String getNumberCallsOnly() {
        //
        Integer i = 0;
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB Calls Only') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise Calls Only')) {
                            i++;
                    }
            }
            //
            return ''+i;
    }

    public Boolean getIsIsdn2() {
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB ISDN2') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise ISDN2')) {
                            return true;
                    }
            }
            //
            return false;
    }

    public String getNumberIsdn2() {
        //
        Integer numberOfLines = 0;
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB ISDN2') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise ISDN2')) {
                        for (cscfgc__Attribute__c att : config.cscfgc__Attributes__r) {
                                if (att.cscfgc__Attribute_Definition__r.Name == 'Number of Lines') {
                                        numberOfLines += Integer.ValueOf(att.cscfgc__Value__c);
                                }
                                }
                    }
            }
            //
            String lineStr = ' Lines';
            if (numberOfLines == 1) lineStr = ' Line';
            return ''+numberOfLines+lineStr;
    }

    public Boolean getIsIsdn30() {
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB ISDN30 ETSI') || config.cscfgc__Product_Definition__r.Name.startsWith('SMB ISDN30 DASS') ||
                            config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise ISDN30 ETSI') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise ISDN30 DASS')) {
                            return true;
                    }
            }
            //
            return false;
    }

    public String getNumberIsdn30() {
        //
        Integer numberOfChannels = 0;
        for (cscfgc__Product_Configuration__c config : configAllAtributeList) {
                if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB ISDN30 ETSI') || config.cscfgc__Product_Definition__r.Name.startsWith('SMB ISDN30 DASS') ||
                        config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise ISDN30 ETSI') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise ISDN30 DASS')) {
                        for (cscfgc__Attribute__c att : config.cscfgc__Attributes__r) {
                        if (att.cscfgc__Attribute_Definition__r.Name == 'Number of Channels') {
                                numberOfChannels += Integer.ValueOf(att.cscfgc__Value__c);
                        }
                        }
                }
        }
        //
        String lineStr = ' Channels';
        if (numberOfChannels == 1) lineStr = ' Channel';
        return ''+numberOfChannels+lineStr;
    }

    public Boolean getIsBB() {
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB Business Broadband') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise Business Broadband')) {
                            return true;
                    }
            }
            //
            return false;
    }

    public String getNumberBB() {
        //
        Integer i = 0;
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB Business Broadband') || config.cscfgc__Product_Definition__r.Name.startsWith('Enterprise Business Broadband')) {
                            i++;
                    }
            }
            //
            String lineStr = ' Lines';
            if (i == 1) lineStr = ' Line';
            return ''+i+lineStr;
    }

    public Boolean getIsMinuteBoltOns() {
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('Minute Bolt Ons')) {
                            return true;
                    }
            }
            //
            return false;
    }

    public Boolean getIsTeleMarketing() {
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB Telemarketing Divert Plan') || config.cscfgc__Product_Definition__r.Name.startsWith('SMB Telemarketing One to One Plan')) {
                            return true;
                    }
            }
            //
            return false;
    }

    public String getNumberTeleMarketing() {
        //
        Integer i = 0;
            for (cscfgc__Product_Configuration__c config : configurationList) {
                    if (config.cscfgc__Product_Definition__r.Name.startsWith('SMB Telemarketing Divert Plan') || config.cscfgc__Product_Definition__r.Name.startsWith('SMB Telemarketing One to One Plan')) {
                            i++;
                    }
            }
            //
            return ''+i;
    }

    public String getContractTerm() {
        //
        String contractTerm = '';
        for (cscfgc__Product_Configuration__c config : configAllAtributeList) {
                for (cscfgc__Attribute__c att : config.cscfgc__Attributes__r) {
                        if (att.cscfgc__Attribute_Definition__r.Name == 'Contract Term') {
                                contractTerm = att.cscfgc__Display_Value__c;
                        }
                }
        }
        //
        return contractTerm;
    }

    public Account getAccount() {
            String oppId = [select opportunityId from Quote where id =:currentQuote.id].opportunityId;
            opp = [select Id, AccountId from Opportunity where id =:oppId];
            Account currentAccount = [select Name, Company_Reg_No__c, Phone, Fax, BillingStreet, BillingPostalCode from Account where Id = :opp.AccountId];
            //
            return currentAccount;
    }

    public Quote getQuote() {
            Quote currentQuote = [select Id, Name, Contact.Name, Contact.Email, Contact.Phone, Contact.Job_Function__c, Contact.Title from Quote where id =:currentQuote.id];
            //
            return currentQuote;
    }

    public String getOpportunityOwner() {
            Quote currentQuote = [select Opportunity.Owner.Name from Quote where id =:currentQuote.id];
            //
            return currentQuote.Opportunity.Owner.Name;
    }

    public Opportunity getOpportunity() {
            String oppId = [select opportunityId from Quote where id =:currentQuote.id].opportunityId;
            opp = [select Id, Name, AccountId, Type, Credit_Ref_Number__c from Opportunity where id =:oppId];
            //
            return opp;
    }

    public User getOwner() {
            Quote currentQuote = [select Opportunity.OwnerId from Quote where id =:currentQuote.id];
            User owner = [select Id, Name, Title, Phone, MobilePhone, Email,Sales_Channel__c from User where id = :currentQuote.Opportunity.OwnerId];
            //
            return owner;
    }

    public Double getbundleTotal() {
            Double total = [select cscfgc__Total_Price__c from cscfgc__Product_Bundle__c where id = :bundleId].cscfgc__Total_Price__c;

            //
            return total;
    }

    public List<QuoteLineItem> getQuoteLineItems() {
        List<QuoteLineItem> items = [SELECT
                                        Id, Description, cscfgc__Attribute__r.cscfgc__Product_Configuration__r.Unify_Solution__c,
                                        cscfgc__Attribute__r.cscfgc__Product_Configuration__r.cscfgc__Product_Definition__r.Name,
                                        cscfgc__Attribute__r.cscfgc__Recurring__c, Quantity, UnitPrice, TotalPrice,
                                        cscfgc__Attribute__r.cscfgc__Product_Configuration__r.Unify_Site__r.Name
                                     FROM QuoteLineItem
                                     WHERE QuoteId= :currentQuote.Id];
        return items;
    }
}