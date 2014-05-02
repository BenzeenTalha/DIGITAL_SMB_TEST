//#################################################################################
//# REVISION HISTORY
//#  
//# Date modified       By          Comments
//# 5th July 2010       CPS         Make additions to LineItem to allow
//#                                 Config status to be displayed on summary page
//#  
//# 5th July 2010       CPS         Add functionality for the "Add New Product"
//#                                 button on the ConfigurationBundleDetail page
//# 
//# 2 Sep   2010        CPS         Added Syncd with Bundle Status processing when
//#                                 Linking with opp.
//#################################################################################

global without sharing class ProductBundleController {

    // RU: bundle variable is made public to access it in online shop(email confirmation)
    private cscfgc__Product_Bundle__c bundle;
    private Opportunity opp;
    private Transient List<cscfgc.ProductConfiguration> configurations;
    private List<Quote> linkedQuotes;
    
    public String configId {get; set;}
    public String nohead {get; set;}
    public String bundleId {get; set;}
    public String oppRecTypeName {get; set;}
    public boolean isUnify {get;set;}
    
    global ProductBundleController(ApexPages.StandardController c) {
        
        //String bundleId;
        System.debug('1');
        Object o = c.getRecord();
        System.debug('2');
        if (c.getRecord().getSObjectType() == Quote.sObjectType) {
            String oppId = [select opportunityId from Quote where id =:c.getRecord().id].opportunityId;
            opp = [select name, (select cscfgc__attribute__r.cscfgc__product_configuration__r.cscfgc__product_bundle__c from OpportunityLineItems) from Opportunity where id =:oppId];
            Integer i = 0;
            while (i < opp.opportunityLineItems.size() && bundleId == null) {
                bundleId = opp.opportunityLineItems.get(i++).cscfgc__attribute__r.cscfgc__product_configuration__r.cscfgc__product_bundle__c;
            }
            
        } else {
            bundleId = c.getRecord().id;
        }
        
        bundle = [select name, cscfgc__opportunity__r.RecordType.Name, cscfgc__total_price__c, cscfgc__opportunity__c, cscfgc__opportunity__r.name, cscfgc__Bundle_Status__c,
                         cscfgc__Opportunity__r.RecordType.DeveloperName, cscfgc__opportunity__r.pricebook2Id, cscfgc__opportunity__r.isClosed
                    from cscfgc__Product_Bundle__c
                   where id = :bundleId];
       
       if(bundle.cscfgc__Opportunity__r.RecordType.DeveloperName == 'Unify'){
            isUnify = true;
       } else {
            isUnify = false;
       }
        
        oppRecTypeName = bundle.cscfgc__opportunity__r.RecordType.Name;
        //system.debug('bundle: '+bundle);
        linkedQuotes = [select id, name from Quote where cscfgc__Product_Bundle__c = :bundleId];
        
        //configurations = ProductBundleManager.getConfigurationsForBundle(bundle);
        
        nohead = ApexPages.currentPage().getParameters().get('nohead');
    }
    
    public cscfgc__Product_Bundle__c getBundle() {
        return bundle;
    }
    
    public List<Quote> getLinkedQuotes() {
        return linkedQuotes;
    }
    
    public Boolean getHasLinkedQuotes() {
        return linkedQuotes.size() > 0;
    }
    
    public List<cscfgc.ProductConfiguration> getConfigurations() {
        return configurations;
    }
    
    public List<ConfigWrapper> getAllProductConfigurations() {
        // Get all the config Details
        String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
            ', (select '+Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r where cscfgc__Is_Line_Item__c = True and cscfgc__Price__c <> null order by cscfgc__Line_Item_Sequence__c) '+
            ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \''+bundle.Id+'\' order by cscfgc__Parent_Configuration__c';
            
        List<cscfgc__Product_Configuration__c> configList = Database.query(queryString);

        //#
        //# Need a map of all configs in the bundle by id
        //#        
        map<id,cscfgc__Product_Configuration__c> productConfigurationsMap = new map<id,cscfgc__Product_Configuration__c>();
        for (cscfgc__Product_Configuration__c c: configList) productConfigurationsMap.put(c.Id,c);
        //system.debug('productConfigurationsMap: '+productConfigurationsMap);
        //
        map<String,ConfigWrapper> topLevelConfigMap = new Map<String,ConfigWrapper>();

        for (cscfgc__Product_Configuration__c config : configList) 
        {
            //#
            //# CONTEXT PRODUCT SHOWING UP IN LINE ITEMS ? 
            //# THEN YOU NOW HAVE THE NEW PACKAGE Swap the lines below! CPS
            //#
            // context coming soon!
            //if (!config.cscfgc__product_definition__r.is_shared_context_definition__c && config.cscfgc__Parent_Configuration__c == null) 
            if (config.cscfgc__Parent_Configuration__c == null)
            {
                //#
                //# Root configs always come first because of the order by
                //#
                
                topLevelConfigMap.put(config.Id,new ConfigWrapper(config,
                                                                  config.cscfgc__Attributes__r,
                                                                  config.Monthly_Recurring_Charge__c,
                                                                  config.One_Off_Charge__c,
                                                                  config.Monthly_Recurring_Charge__c+config.One_Off_Charge__c
                                                                  ));
            }  
            else if (config.cscfgc__Parent_Configuration__c != null) 
            {
                //#
                //# Now we're onto non-root configs.
                //#         
                Id topLevelId = getTopLevelConfigId(config,productConfigurationsMap);                               
                cscfgc__Product_Configuration__c topLevelConfig=  productConfigurationsMap.get(topLevelId );
                
                
                //Decimal mrr = topLevelConfigMap.get(rootId ).RecurringCharge;
                //Decimal nrr = topLevelConfigMap.get(rootId ).oneOffCharge;
                //
                Decimal mrr = config.Monthly_Recurring_Charge__c;
                Decimal nrr = config.One_Off_Charge__c;
                Decimal up  = config.Monthly_Recurring_Charge__c + config.One_Off_Charge__c; //config.cscfgc__Unit_Price__c;
                //
                List<cscfgc__Attribute__c> attributeList = new List<cscfgc__Attribute__c>();
                attributeList.addAll(config.cscfgc__Attributes__r);
                //
                if (!topLevelConfigMap.containsKey(topLevelId))
                {
                    //#
                    //# Should never fall into here 
                    //#
                
                    if (topLevelConfig.id != config.id) 
                    {
                        attributeList.addAll(topLevelConfig.cscfgc__Attributes__r);
                        mrr += topLevelConfig.Monthly_Recurring_Charge__c;
                        nrr += topLevelConfig.One_Off_Charge__c ;  
                    } 
                    topLevelConfigMap.put(topLevelId,new ConfigWrapper(topLevelConfig,attributeList,mrr,nrr,up));
                
                }
                else
                {
                    
                    ConfigWrapper cw = topLevelConfigMap.get(topLevelid);
                    cw.attributeList.AddAll(attributeList);
                    cw.recurringCharge += mrr;
                    cw.oneOffCharge += nrr;              
                }
            }
        }
        //
        return topLevelConfigMap.values();
    

        /*
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
        */
    }
    
    
    private static Id getTopLevelConfigId(cscfgc__Product_Configuration__c config, map<id,cscfgc__Product_Configuration__c> allConfigsById)
    {
        Id parentId= config.cscfgc__Parent_Configuration__c;
        Id result = config.Id;
        while (parentId != null)
        {   
            cscfgc__Product_Configuration__c foundConfig = allConfigsById.get(parentId);
            result   = foundConfig.id;
            parentId = foundConfig.cscfgc__Parent_Configuration__c;
        }
        
        return result;
    }   
    
    
    
    public class ConfigWrapper {
        public cscfgc__Product_Configuration__c config {get; set;}
        public List<cscfgc__Attribute__c> attributeList {get; set;}
        public Decimal recurringCharge {get; set;}        
        public Decimal oneOffCharge {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal grandTotal {get; set;}
        public Decimal quantity {get; set;}
        public String status {get; set;}
        private decimal billAmount;
        private decimal childBillAmount = 0;
        
        
        public ConfigWrapper(cscfgc__Product_Configuration__c conf, List<cscfgc__Attribute__c> attList, Decimal mrr, Decimal nrr, Decimal up) {
            config = conf;
            attributeList = attList;
            recurringCharge = mrr;
            oneOffCharge = nrr;
            quantity = config.cscfgc__quantity__c;
            status = config.cscfgc__configuration_status__c;
        }
 
        public decimal getFirstBillingAmount()
        {
            return  config.cscfgc__Quantity__c * (this.getrecurringBillingCharge() + oneOffCharge);
        
        }
        
        
        public Decimal getTotalPrice() {
            return config.cscfgc__total_price__c;
        }
        
        public id getConfigurationId()
        {
            return config.Id; 
        }
        
        public boolean getIsMain()
        {
            return config.cscfgc__Parent_Configuration__c == null; 
        }
        
        public string getConfigStatus()
        {           
            return config.cscfgc__Configuration_Status__c; 
        }

        public string getDescription()
        {
            return config.cscfgc__Description__c;
        }
        
        public void addChildBillingCharge( decimal value)
        {
            childBillAmount += value;
        }

        public decimal getFirstInvoiceValue()
        {
            
            return recurringCharge + oneOffCharge; 
        }
        
        public string getUnitPrice()
        {
            return string.valueOf(config.cscfgc__Unit_Price__c);
        }
        

         
        public Decimal getRecurringBillingCharge()
        {
            if (billAmount == null)
            {
                billAmount = 0;
                if (recurringCharge <> 0 && attributeList!= null && attributeList.Size() > 0)
                {
                    for (cscfgc__Attribute__c a : attributeList)
                    {
                        if (a.cscfgc__Is_Line_Item__c && a.cscfgc__Recurring__c) 
                            billAmount +=  a.cscfgc__Billing_Price__c;
                    } 
                }   
            }
            
            return billAmount + childBillAmount;
        }
    }
    
    
    /************************
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
    */
    
    /**************************
    public List<LineItemWrapper> getAllLineItemWrappers() {
        List<LineItemWrapper> items = new List<LineItemWrapper>();
        
        for (cscfgc.ProductConfiguration config : configurations) {
            cscfgc.Attribute ct = config.getAttribute('Contract Term');
            String contractTermStr = ct == null ? '1' : ct.getValue();
            
            Decimal contractTerm = 1;
            try { if (contractTermStr != null) contractTerm = Decimal.valueOf(contractTermStr); }
            catch (Exception e) { }
            
            Decimal totalMRR = 0;
            Decimal totalNRR = 0;
            LineItemWrapper mainItem = null;
            
            for (cscfgc.LineItem i : getLineItems(config,true)) {
                LineItemWrapper li = new LineItemWrapper(i);
                
                if (i.isMain) {
                    mainItem = li;
                } else {
                    if (i.getPrice() != null) { 
                        if (i.getIsRecurring()) totalMRR += i.getPrice(); 
                        else totalNRR += i.getPrice();
                    }
                }
                
                items.add(li);
            }
            
            if (mainItem != null) mainItem.setTotalContractValue((totalMRR * contractTerm) + totalNRR);
        }
        
        return items;
    }
    
    
    public List<cscfgc.LineItem> getLineItems(cscfgc.ProductConfiguration config, Boolean showMainLineItem) {
        
        List<cscfgc.LineItem> items = new List<cscfgc.LineItem>();
        List<cscfgc.LineItem> subItems = new List<cscfgc.LineItem>();
        
        if (showMainLineItem) items.add(new cscfgc.LineItem(null, config, true));
        
        for (cscfgc.Attribute attr : config.getAttributes()) {
            
            if (attr.getIsLineItem())
                    items.add(new cscfgc.LineItem(attr.getSObject(), config));
            
            cscfgc__Attribute_Definition__c definition = attr.getDefinition();
            if (definition.cscfgc__type__c == cscfgc.Attribute.RELATED_PRODUCT) {
                //
                String relatedIds = attr.getValue();
                if (relatedIds == null) continue;
                Id[] ids = relatedIds.split(',');
                List<cscfgc.ProductConfiguration> configs = ProductBundleManager.getProductConfigurationsByIdList(ids);
        
                for (Integer c = 0; c < configs.size(); c++) {
                    cscfgc.ProductConfiguration relatedConfig = configs.get(c);
                    subItems.addAll(getLineItems(relatedConfig,false));
                }
                //
            }
        }
        
        items = sortLineItems(items);
        items.addAll(subItems);
        
        return items;
    }
    
    public static List<cscfgc.LineItem> sortLineItems(List<cscfgc.LineItem> items) {
        if (items == null || items.size() < 2) return items;

        List<cscfgc.LineItem> sorted = new cscfgc.LineItem[]{};
        
        Map<Decimal, List<cscfgc.LineItem>> liMap = new Map<Decimal, List<cscfgc.LineItem>>();
        
        for(cscfgc.LineItem li : items) {
            if(liMap.get(li.getSequence()) == null) liMap.put(li.getSequence(), new cscfgc.LineItem[]{});
            liMap.get(li.getSequence()).add(li);
        }
        
        List<Decimal> keys = new List<Decimal>(liMap.keySet());
        
        keys.sort();
        
        for (Decimal key : keys) sorted.addAll(liMap.get(key));
        
        return sorted;
    }
    *********************************/
    
    public List<cscfgc__Attribute__c> getAllLineItems() {
        List<cscfgc__Attribute__c> items = new List<cscfgc__Attribute__c>();
        //
        // Get all the config Details
        String queryString = null;
        queryString = 'select cscfgc__product_definition__r.name,'+
                        'cscfgc__product_definition__r.cscfgc__description__c,'+
                        'cscfgc__product_definition__r.cscfgc__name_is_read_only__c,'+
                        'cscfgc__product_definition__r.cscfgc__allow_progress_from_incomplete_screens__c,'+
                        'cscfgc__product_definition__r.cscfgc__opportunity_mapping__c,'+ 
                        'cscfgc__screen_flow__r.name,'+
                        Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                     ', (select cscfgc__attribute_definition__r.name, cscfgc__attribute_definition__r.cscfgc__product_definition__r.name, '+
                         Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r where cscfgc__Is_Line_Item__c = True) '+
            ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \''+bundle.Id+'\' order by cscfgc__Parent_Configuration__c ';
        system.debug('**queryString'+queryString);
        List<cscfgc__Product_Configuration__c> configList = Database.query(queryString);
        //
        for (cscfgc__Product_Configuration__c config : configList) {
            items.addAll(config.cscfgc__Attributes__r);
        }
        
        return items;
    }
    
    public static List<cscfgc__Attribute__c> getAllLineItemsBoostBox(String BundleId) {
        List<cscfgc__Attribute__c> items = new List<cscfgc__Attribute__c>();
        //
        // Get all the config Details
        String queryString = null;
        queryString = 'select cscfgc__product_definition__r.name,'+
                        'cscfgc__product_definition__r.cscfgc__description__c,'+
                        'cscfgc__product_definition__r.cscfgc__name_is_read_only__c,'+
                        'cscfgc__product_definition__r.cscfgc__allow_progress_from_incomplete_screens__c,'+
                        'cscfgc__product_definition__r.cscfgc__opportunity_mapping__c,'+ 
                        'cscfgc__screen_flow__r.name,'+
                        Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                     ', (select cscfgc__attribute_definition__r.name, cscfgc__attribute_definition__r.cscfgc__product_definition__r.name, '+
                         Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r where cscfgc__Is_Line_Item__c = True) '+
            ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \''+BundleId+'\' order by cscfgc__Parent_Configuration__c ';
        system.debug('**queryString'+queryString);
        List<cscfgc__Product_Configuration__c> configList = Database.query(queryString);
        //
        for (cscfgc__Product_Configuration__c config : configList) {
            items.addAll(config.cscfgc__Attributes__r);
        }
        
        return items;
    }
    
    public static List<cscfgc__Attribute__c> getAllLineItemsUnify(String BundleId) {
        List<cscfgc__Attribute__c> items = new List<cscfgc__Attribute__c>();
        //
        // Get all the config Details
        String queryString = null;
        queryString = 'select cscfgc__product_definition__r.name,'+
                        'cscfgc__product_definition__r.cscfgc__description__c,'+
                        'cscfgc__product_definition__r.cscfgc__name_is_read_only__c,'+
                        'cscfgc__product_definition__r.cscfgc__allow_progress_from_incomplete_screens__c,'+
                        'cscfgc__product_definition__r.cscfgc__opportunity_mapping__c,'+ 
                        'cscfgc__screen_flow__r.name,'+
                        Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                     ', (select cscfgc__attribute_definition__r.name, cscfgc__attribute_definition__r.cscfgc__product_definition__r.name, '+
                         Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r where cscfgc__Is_Line_Item__c = True) '+
            ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \''+BundleId+'\' order by cscfgc__Parent_Configuration__c ';
        system.debug('**queryString'+queryString);
        List<cscfgc__Product_Configuration__c> configList = Database.query(queryString);
        //
        for (cscfgc__Product_Configuration__c config : configList) {
            for(cscfgc__Attribute__c a1 : config.cscfgc__Attributes__r){
                //to temporary pass the quantity value without changing the whole class / methods implementation  
                a1.cscfgc__Line_Item_Sequence__c = config.cscfgc__Quantity__c;
                items.add(a1);              
            }
        }
        return items;
    }
    
    
    public PageReference viewConfiguration() {
        return new PageReference('/'+configId);
    }
    
    public PageReference editConfiguration() {
        PageReference p = Page.cscfgc__ConfigureProduct;
        p.getParameters().put('configId', configId);
        //p.getParameters().put('retURL', bundle.id); 16/02/2012 GK Fix P1 case 6786 - Spring12 issue
        p.getParameters().put('retURL', '/' + bundle.id);
        p.setRedirect(true);
        return p;
    }

    //#
    //# New functionality to put behind "add a configuration" to the
    //# the bundle
    //#
    public PageReference addNewConfiguration() {
        PageReference p = Page.cscfgc__ConfigureProduct;            
        //p.getParameters().put('retURL', bundle.id); 16/02/2012 GK Fix P1 case 6786 - Spring12 issue
        p.getParameters().put('retURL', '/' + bundle.id);
        p.setRedirect(true);
        return p;
    }

    public PageReference deleteConfiguration() {
    
        PageReference p= Apexpages.currentPage()    ;   
        p.getParameters().put('Id', bundle.id);
        p.setRedirect(true);

        cscfgc.ProductConfiguration dummyConfig;
        Id configAsId = configId;
        //#
        //# get the config
        //# 
        
        try
        {
            System.debug('Deleting config' + configId + '....');
        
            cscfgc__Product_Configuration__c config =  [select id from cscfgc__Product_Configuration__c 
                                                where cscfgc__Product_Bundle__r.id = :bundle.Id 
                                                AND Id = :configAsId];
        
            //#
            //# delete it
            //#
            delete config;      
            System.debug('DELETED config' + configId);

            //#
            //# Update the bundle status
            //# 
            System.debug('Updating bundle' + bundle.Id + '...');
            bundle.cscfgc__Bundle_Status__c = ProductBundleManager.getBundleStatusForNewConfig(bundle, dummyConfig);
            update bundle;
            System.debug('UPDATED bundle' + bundle.Id);
            
        }
        catch (Exception ex)
        {
            //#
            //# Do stuff here
            //#
            System.debug('ERROR Deleting config:' + ex);
        }       

        return p;
    }


    
    public PageReference syncWithOpportunity() {
        //system.debug('syncWithOpportunity: bundle: '+bundle);
        //system.debug('syncWithOpportunity: bundle: opportunity: '+bundle.cscfgc__opportunity__r);
        if (bundle.cscfgc__opportunity__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No opportunity is associated with this product bundle.'));
            return null;
        }
        
        if (bundle.cscfgc__opportunity__r.isClosed) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The bundle cannot be synchronised with the opportunity because the opportunity is closed.'));
            return null;
        }
        
        if (bundle.cscfgc__Bundle_Status__c != 'Valid') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The bundle cannot be synchronised with the opportunity because it is Incomplete.'));
            return null;
        }
        
        if(isUnify){
            Unify_Upload_Single_Entity__c[] chck = [select Id, Processed__c from Unify_Upload_Single_Entity__c where Product_Bundle__c = :bundleId and Processed__c = false];
            if(chck != null && chck.size() > 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed! Configuration Upload procedure is in progress. You are not allowed to Synchronize data with Opportunity till upload is finished.'));
                return null;
            }           
        }
        
        String pricebookId = bundle.cscfgc__opportunity__r.pricebook2Id; 
        
        if (pricebookId == null) {
            Opportunity opp = [select pricebook2Id from Opportunity where id=:bundle.cscfgc__opportunity__c];
            Pricebook2 standardPricebook = [select id from Pricebook2 where isStandard=true];
            opp.pricebook2Id = standardPricebook.id;
            pricebookId = standardPricebook.id;
            update opp;
        }
        //
        List<cscfgc__Attribute__c> lineItems; 
        if(!isUnify){
            lineItems = getAllLineItems();
        } else {
            lineItems = getAllLineItemsUnify(bundle.Id);
        }
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Map<String,OpportunityLineItem> oliMap = new Map<String,OpportunityLineItem>();
        //
        Map<String,PricebookEntry> pricebookEntryMap = getPriceBookEntryMap(lineItems, pricebookId, bundle);
        system.debug('**********************************>>>>>>>>>>>>>>>'+pricebookEntryMap);
        //
        for (Integer i = lineItems.size() - 1; i >= 0; i--) {
            cscfgc__Attribute__c item = lineItems.get(i);
            if (item.cscfgc__Price__c == null) continue;
            //
            if (item.cscfgc__line_item_description__c == null) continue;
            PricebookEntry pbe = pricebookEntryMap.get(item.cscfgc__line_item_description__c);
            
            Decimal price = item.cscfgc__Price__c;
            
            Decimal quantityToSet = 1;
            
            if(isUnify){
                quantityToSet = item.cscfgc__Line_Item_Sequence__c;
            }
            
            if (price != null) price = Math.round(price*100)/100.0;
            
            //
            OpportunityLineItem oli = new OpportunityLineItem();
            //
            // 10/02/2012 GK Remove <b></b> tags added for Flying start promotions
            String lineitemdescription= item.cscfgc__line_item_description__c;          
                
            pattern myPattern = pattern.compile('<.*?>');
            matcher myMatcher = myPattern.matcher(lineitemdescription);     
            //remove the tags     
            lineitemdescription = myMatcher.replaceAll('');
            ////// END GK
            
            oli = new OpportunityLineItem(
                    opportunityId = bundle.cscfgc__opportunity__c,
                    pricebookentryId = pbe.id,
                    quantity = quantityToSet,
                    //10/02/2012 GK description = item.cscfgc__line_item_description__c, 
                    description = lineitemdescription,
                    cscfgc__attribute__c = item.id,
                    MRR__C = 0.0,
                    NRR__C = 0.0);
            //
            // Check if this line item is the recurring one
            if (item.cscfgc__Recurring__c) {
                if (oli.MRR__c == null) {
                    oli.MRR__c = price; ///item.getConfiguration().getSObject().cscfgc__Recurrence_Frequency__c;
                } else {
                    oli.MRR__c += price; ///item.getConfiguration().getSObject().cscfgc__Recurrence_Frequency__c;
                }
            } else {
                // 10/02/2012 GK: Due to Flying Start we have negative NRRs, which cause the opportunity amount 
                //                to appear as negative as well (as it contains the first billing amount). 
                //                To solve this, if NRR < 0, set it to zero
                //if ((price != null)&&(price<0)) price =0;
                if (oli.NRR__c == null) {
                    oli.NRR__c = price;
                } else {
                    oli.NRR__c += price;
                }
            }
            oli.TotalPrice = oli.quantity * (oli.NRR__c + oli.MRR__c);
            //
            oliList.add(oli);
        }
        //
        cscfgc__Product_Bundle__c[] otherBundles = [select Id 
                                            From cscfgc__Product_Bundle__c
                                            Where cscfgc__Synchronised_with_Opportunity__c = true 
                                            And cscfgc__Opportunity__c = :bundle.cscfgc__Opportunity__c
                                            ];
        for (cscfgc__Product_Bundle__c b: otherBundles) b.cscfgc__Synchronised_with_Opportunity__c = false;
        update otherBundles;                                        
        
        bundle.cscfgc__Synchronised_with_Opportunity__c = true;
        update bundle;

        List<OpportunityLineItem> existingOlis = [select id from OpportunityLineItem where opportunityid = :bundle.cscfgc__opportunity__c];
        delete existingOlis;
        insert oliList;
        //
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The product bundle line items were successfully synchronised with the opportunity.'));
        //
        PageReference p = new PageReference('/' + bundle.cscfgc__opportunity__c);
        p.setRedirect(true);
        //
        return p;
    }   
    
    public static PageReference syncWithOpportunityBoostBox(String bundleId) {
        system.debug('syncWithOpportunity: bundle: '+bundleId);
        cscfgc__Product_Bundle__c bundle = [select Id, cscfgc__Bundle_Status__c, cscfgc__opportunity__r.pricebook2Id, cscfgc__opportunity__c, cscfgc__opportunity__r.isClosed from cscfgc__Product_Bundle__c where id = :bundleId limit 1]; 
        system.debug('syncWithOpportunity: bundle: opportunity: '+bundle.cscfgc__opportunity__r);
        if (bundle.cscfgc__opportunity__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No opportunity is associated with this product bundle.'));
            return null;
        }
        
        if (bundle.cscfgc__opportunity__r.isClosed) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The bundle cannot be synchronised with the opportunity because the opportunity is closed.'));
            return null;
        }
        
        if (bundle.cscfgc__Bundle_Status__c != 'Valid') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The bundle cannot be synchronised with the opportunity because it is Incomplete.'));
            return null;
        }
        
        String pricebookId = bundle.cscfgc__opportunity__r.pricebook2Id; 
        
        if (pricebookId == null) {
            Opportunity opp = [select pricebook2Id from Opportunity where id=:bundle.cscfgc__opportunity__c];
            Pricebook2 standardPricebook = [select id from Pricebook2 where isStandard=true];
            opp.pricebook2Id = standardPricebook.id;
            pricebookId = standardPricebook.id;
            update opp;
        }
        //
        List<cscfgc__Attribute__c> lineItems = getAllLineItemsBoostBox(bundleId);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Map<String,OpportunityLineItem> oliMap = new Map<String,OpportunityLineItem>();
        //
        Map<String,PricebookEntry> pricebookEntryMap = getPriceBookEntryMap(lineItems, pricebookId, bundle);
        system.debug('**********************************>>>>>>>>>>>>>>>'+pricebookEntryMap);
        //
        for (Integer i = lineItems.size() - 1; i >= 0; i--) {
            cscfgc__Attribute__c item = lineItems.get(i);
            if (item.cscfgc__Price__c == null) continue;
            //
            if (item.cscfgc__line_item_description__c == null) continue;
            PricebookEntry pbe = pricebookEntryMap.get(item.cscfgc__line_item_description__c);
            
            Decimal price = item.cscfgc__Price__c;
            
            if (price != null) price = Math.round(price*100)/100.0;
            
            //
            OpportunityLineItem oli = new OpportunityLineItem();
            //
            // 10/02/2012 GK Remove <b></b> tags added for Flying start promotions
            String lineitemdescription= item.cscfgc__line_item_description__c;          
                
            pattern myPattern = pattern.compile('<.*?>');
            matcher myMatcher = myPattern.matcher(lineitemdescription);     
            //remove the tags     
            lineitemdescription = myMatcher.replaceAll('');
            ////// END GK
            
            oli = new OpportunityLineItem(
                    opportunityId = bundle.cscfgc__opportunity__c,
                    pricebookentryId = pbe.id,
                    quantity = 1,
                    //10/02/2012 GK description = item.cscfgc__line_item_description__c, 
                    description = lineitemdescription,
                    cscfgc__attribute__c = item.id,
                    MRR__C = 0.0,
                    NRR__C = 0.0);
            //
            // Check if this line item is the recurring one
            if (item.cscfgc__Recurring__c) {
                if (oli.MRR__c == null) {
                    oli.MRR__c = price; ///item.getConfiguration().getSObject().cscfgc__Recurrence_Frequency__c;
                } else {
                    oli.MRR__c += price; ///item.getConfiguration().getSObject().cscfgc__Recurrence_Frequency__c;
                }
            } else {
                // 10/02/2012 GK: Due to Flying Start we have negative NRRs, which cause the opportunity amount 
                //                to appear as negative as well (as it contains the first billing amount). 
                //                To solve this, if NRR < 0, set it to zero
                if ((price != null)&&(price<0)) price =0;
                if (oli.NRR__c == null) {
                    oli.NRR__c = price;
                } else {
                    oli.NRR__c += price;
                }
            }
            oli.TotalPrice = oli.NRR__c + oli.MRR__c;
            //
            oliList.add(oli);
        }
        //
        cscfgc__Product_Bundle__c[] otherBundles = [select Id 
                                            From cscfgc__Product_Bundle__c
                                            Where cscfgc__Synchronised_with_Opportunity__c = true 
                                            And cscfgc__Opportunity__c = :bundle.cscfgc__Opportunity__c
                                            ];
        for (cscfgc__Product_Bundle__c b: otherBundles) b.cscfgc__Synchronised_with_Opportunity__c = false;
        update otherBundles;                                        
        
        bundle.cscfgc__Synchronised_with_Opportunity__c = true;
        update bundle;

        List<OpportunityLineItem> existingOlis = [select id from OpportunityLineItem where opportunityid = :bundle.cscfgc__opportunity__c];
        delete existingOlis;
        insert oliList;
        //
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The product bundle line items were successfully synchronised with the opportunity.'));
        //
        //PageReference p = new PageReference('/' + bundle.cscfgc__opportunity__c);
        //p.setRedirect(true);
        //
        //return p;
        return null;
    }
    
    // -----------
    // Get a Map of configurations and all their attributes
    public static Map<ID,cscfgc__Product_Configuration__c> getProductConfigurationMap(String productBundleId) {
        //
        // ---------
        // Get a Map of all bundle Configs
        Map<ID,cscfgc__Product_Configuration__c> prodConfigMap = new Map<Id,cscfgc__Product_Configuration__c>(
                                                    [select Id, Name, cscfgc__Parent_Configuration__c, cscfgc__Product_Bundle__c,
                                                     cscfgc__Product_Definition__r.Name, cscfgc__Product_Basket__c, cscfgc__Product_Definition__c, 
                                                     (select Id, cscfgc__Attribute_Definition__r.cscfgc__Type__c, cscfgc__Attribute_Definition__r.Name, 
                                                      cscfgc__is_Line_Item__c, cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c, cscfgc__Recurring__c,
                                                      cscfgc__Line_Item_Description__c, cscfgc__Line_Item_Sequence__c, cscfgc__Price__c, cscfgc__Value__c, 
                                                      cscfgc__Display_Value__c, cscfgc__Product_Configuration__c, cscfgc__Attribute_Definition__r.cscfgc__cascade_value__c
                                                      from cscfgc__Attributes__r 
                                                      order by cscfgc__Line_Item_Sequence__c) from cscfgc__Product_Configuration__c 
                                                      where cscfgc__Product_bundle__c = :productBundleId]);
        //
        // ---------
        // 
        return prodConfigMap;
    }
    
    static Map<String,PricebookEntry> getPriceBookEntryMap(List<cscfgc__Attribute__c> itemList, String pricebookId, cscfgc__Product_Bundle__c bundle) {
        Set<String> itemProductNameSet = new Set<String>();
        for (cscfgc__Attribute__c item : itemList) {
            // Get a set of unique line item product Names
            if (item.cscfgc__line_item_description__c != null)
                itemProductNameSet.add(item.cscfgc__line_item_description__c); 
        }
        system.debug('********--->itemProductNameSet:'+itemProductNameSet);
        //
        // Get the price book entries for the products that already exist in the catalogue
        List<Product2> productList = [select id, name, productCode, description, isActive, family,
                                            (select id from pricebookentries where pricebook2id=:pricebookId)
                                      from Product2
                                      where name in :itemProductNameSet
                                        and isActive = true
                                    ];
        // Get a Map of the found products keyed by name
        Map<String,Product2> productMap = new Map<String,Product2>();
        Map<String,PricebookEntry> pricebookEntryMap = new Map<String,PricebookEntry>();
        for (Product2 product : productList) {
            if (!product.pricebookentries.isEmpty()) {
                productMap.put(product.Name,product);
                pricebookEntryMap.put(product.Name,product.pricebookentries[0]);
            }
        }
        // Get a list of the names that did not match
        List<String> productToBeCreatedList = new List<String>();
        for (String name : itemProductNameSet) {
            if (!productMap.containsKey(name)) {
                productToBeCreatedList.add(name);
            }
        }
        // Loop through all the products requiring creation and create them
        List<Product2> newProductList = new List<Product2>();
        for (String name : productToBeCreatedList) {
            newProductList.add(new Product2(name = name, //item.getDescription(),
                                            productCode = '',
                                            description = '',
                                            //family = '',
                                            isActive = true));
        }
        insert newProductList;
        system.debug('********--->productList:'+productList);
        // Get a map of the newly inserted products keyed by Id
        Map<String,Product2> newProductMap = new Map<String,Product2>();
        for (Product2 product : newProductList) {
            newProductMap.put(product.id,product);
        }
        // Get standard price book id
        Pricebook2 standardPricebook = [select id from Pricebook2 where isStandard=true];
        //
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        for (Product2 product : newProductList) {
            PricebookEntry entry = new PricebookEntry(
                pricebook2id = pricebookId,
                product2Id = product.id,
                unitPrice = 0,
                isActive = true,
                useStandardPrice = false
            );
            priceBookEntryList.add(entry);
        }
        insert priceBookEntryList;
        //
        for (PricebookEntry entry : priceBookEntryList) {
            pricebookEntryMap.put(newProductMap.get(entry.product2Id).Name,entry);
        }
        // 
        return pricebookEntryMap;
    } 
    
    
    static Result findPricebookEntryForLineItem(cscfgc.LineItem item, String pricebookId, cscfgc__Product_Bundle__c bundle) {
        
        //List<Product2> products = getPricebookEntriesForProductNameAndPricebookId(item.getDescription(), pricebookId);    
        List<Product2> products = getPricebookEntriesForProductNameAndPricebookId(item.getDescription(), //getConfiguration().getSObject().cscfgc__Product_Definition__r.Name, 
                                                                                  pricebookId);     
        if (products.size() == 0) return Result.failure('No active products found with name ' + item.getName());
        if (products.get(0).pricebookentries.size() == 0) return Result.success(createPricebookEntriesForProduct((Product2)products.get(0), pricebookId, bundle));
        
        return Result.success(products.get(0).pricebookentries.get(0)); 
    }
    
    static List<Product2> getPricebookEntriesForProductNameAndPricebookId(String productName, String pricebookId) {
        return [
            select  id,
                    name,
                    productCode,
                    description,
                    isActive,
                    family,
                    (select id
                            from pricebookentries
                            where pricebook2id=:pricebookId)
                    from Product2
                    where   name = :productName
                            and isActive = true
        ];
    }
    
    static PricebookEntry createProductAndPricebookEntryForLineItem(cscfgc.LineItem item, String pricebookId, cscfgc__Product_Bundle__c bundle) {
        
        Product2 product = new Product2(
                name = item.getDescription(), //getConfiguration().getSObject().cscfgc__Product_Definition__r.Name,
                productCode = '',
                description = '',
                family = item.getAttribute().cscfgc__attribute_definition__r.cscfgc__product_definition__r.name,
                isActive = true
        );
        
        insert product;
        
        return createPricebookEntriesForProduct(product, pricebookId, bundle);
    }
    
    /**
     * Creates an entry in the Standard pricebook for the supplied product if none exists already, then
     * creates an entry in the specified pricebook.
     */
    static PricebookEntry createPricebookEntriesForProduct(Product2 product, String pricebookId, cscfgc__Product_Bundle__c bundle) {
        
        Pricebook2 standardPricebook = [select id from Pricebook2 where isStandard=true];
        if (pricebookId != standardPricebook.id) {
            List<Product2> products = getPricebookEntriesForProductNameAndPricebookId(product.name, standardPricebook.id);
            if (products.get(0).pricebookentries.size() == 0) createPricebookEntryForProduct(product, standardPricebook.id, bundle);
        }
        
        return createPriceBookEntryForProduct(product, pricebookId, bundle);

    }   

    
    static PricebookEntry createPricebookEntryForProduct(Product2 product, String pricebookId, cscfgc__Product_Bundle__c bundle) {
        
        system.debug('>>>>>>> Creating PricebookEntry for product: ' + product.name + ', pricebookId: ' + pricebookId);
        PricebookEntry entry = new PricebookEntry(
                pricebook2id = pricebookId,
                product2Id = product.id,
                unitPrice = 0,
                isActive = true,
                useStandardPrice = false
        );
        
        insert entry;
         
        return entry;
    }
    
    // -----------
    // Convert date string to date
    public static Date stringToDate(String s){
        if (s != null) {
          //Date String is in the format dd/mm/yyyy
          String[] stringDate = s.split('/');
          if (stringDate.size() == 3) {
            Integer d =  Integer.valueOf(stringDate[0]);
            Integer m = Integer.valueOf(stringDate[1]);
            Integer y = Integer.valueOf(stringDate[2]);
            // Correct a problem introduced by webcom sending back 2 digit years
            if (y < 2000) y += 2000;
            return date.newInstance(y,m,d);
          } else {
            return null;
          }
        } else {
            return null;
        }
    }
 /***
    public class LineItemWrapper {
        
        cscfgc.LineItem item;
        Decimal totalContractValue;
        
        public Boolean isMain {
            get {
                return item != null && item.isMain;
            } 
        }
        
        public LineItemWrapper(cscfgc.LineItem item) {
            this.item = item;
            this.totalContractValue = 0;
        }
        
        public void setTotalContractValue(Decimal value) {
            this.totalContractValue = value;
        }
        
        public String getConfigurationId() {
            return item.getConfigurationId();
        }
        
        public String getConfigStatus() {
            return item.getConfigStatus();
        }
        
        public String getDescription() {
            return item.getDescription();
        }
        
        public Boolean getIsRecurring() {
            return item.getIsRecurring();
        }
        
        public Decimal getPrice() {
            return item.getPrice();
        }
        
        public Decimal getAnnualCost() {
            return item.getAnnualCost();
        }
        
        public Decimal getTotalContractValue() {
            return totalContractValue;
        }
        
        public cscfgc.LineItem getLineItem() {
            return item;
        }
    }
    ***/   
}