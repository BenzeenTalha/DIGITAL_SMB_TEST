/*
*Class Description: To create a PDF with sorted QuoteLineItems.
*Created By: RU 14/12/2011
*(Mainly to address BE issues on Quote Appearances)
***************************************************
*/
public with sharing class QuoteLineItemPDFExtension {
    ApexPages.StandardController controller;
    public Quote quote {get;set;}
    private Quote currentQuote; 
    private Opportunity opp;
    private String bundleId {get; set;}
      
    public Integer[] lastQuoteItemIndices {get;set;}
      
    public List<cscfgc__Product_Configuration__c> configurationList;
    public List<cscfgc__Product_Configuration__c> configAllAtributeList;
    
    public QuoteLineItemPDFExtension(ApexPages.StandardController stdController){
        controller = stdController;
        quote = (Quote) stdController.getRecord();      
    }
    
    
    public List<List<QuoteLineItemWrapper>> getQuoteLineItemList(){
        List<List<QuoteLineItemWrapper>> out = new List<List<QuoteLineItemWrapper>>();
        List<QuoteLineItemWrapper> x = null;
        lastQuoteItemIndices = new List<Integer>();
        String configNos = null;
        Decimal recurVal;
        Decimal oneOffVal;   
        
        
        // Prepare a list of list based on the ConfigNumber__c
        for(QuoteLineItem qli : getQuoteLineItem()){
            
            system.debug('attribute value is :' + qli.cscfgc__Attribute__r.cscfgc__Value__c);        
            system.debug('attribute name is :' + qli.cscfgc__Attribute__r.Name);
            
            // AC 06-08-2012: set recurVal and oneOffVal to 0.0 to prevent prices being repeated
            recurVal = 0.0;
            oneOffVal = 0.0;
            
            if (configNos == null) {
                configNos = qli.ConfigNumber__c;
                x = new List<QuoteLineItemWrapper>(); 
                if (Integer.valueOf(qli.Recurring__c) == 1)
                    recurVal = qli.cscfgc__Attribute__r.cscfgc__Price__c;
                else
                    oneOffVal = qli.cscfgc__Attribute__r.cscfgc__Price__c;
                    
                x.add(new QuoteLineItemWrapper(qli, qli.LineNumber, qli.PricebookEntry.Name, qli.UnitPrice, oneOffVal, recurVal));
                
            } else if (configNos != null && configNos == qli.ConfigNumber__c) {
                if (Integer.valueOf(qli.Recurring__c) == 1)
                        recurVal = qli.cscfgc__Attribute__r.cscfgc__Price__c;
                else
                        oneOffVal = qli.cscfgc__Attribute__r.cscfgc__Price__c;
                        
                x.add(new QuoteLineItemWrapper(qli, qli.LineNumber, qli.PricebookEntry.Name, qli.UnitPrice, oneOffVal, recurVal));      
                configNos = qli.ConfigNumber__c;
            } else {
                out.add(x);
                x = new List<QuoteLineItemWrapper>(); 
                if (Integer.valueOf(qli.Recurring__c) == 1)
                    recurVal = qli.cscfgc__Attribute__r.cscfgc__Price__c;
                else
                    oneOffVal = qli.cscfgc__Attribute__r.cscfgc__Price__c;
                    
                x.add(new QuoteLineItemWrapper(qli, qli.LineNumber, qli.PricebookEntry.Name, qli.UnitPrice, oneOffVal, recurVal));
                configNos = qli.ConfigNumber__c;
            }
            
        }// end of for loop
        
        out.add(x);
        
        for(List<QuoteLineItemWrapper> y :out ){
            system.debug('list size is :' + out.size());
            
            // to fetch the list length for showing the Reference on the pages
            // This will change once we finalize the product configuration        
            //lastQuoteItemIndex = y.size() -1;
            lastQuoteItemIndices.add(y.size() -1);
            
            
        }
        return out;
    }

    public List<QuoteLineItem> getQuoteLineItem(){
        
        //Query for the all QuoteLineItems for a Quote
        String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('QuoteLineItem') +                      
                      ' , cscfgc__Attribute__r.cscfgc__Price__c,cscfgc__Attribute__r.Name,cscfgc__Attribute__r.cscfgc__Value__c, PricebookEntry.Name,PricebookEntry.Product2Id from QuoteLineItem where QuoteId = \''+quote.Id+'\' order by ConfigNumber__c, LineItemSequence__c';
 
        System.Debug('queryString ::: ' + queryString);
 
        List<QuoteLineItem> quoteLineItemList = Database.query(queryString);
        
        return quoteLineItemList;
    } 
    
    public PageReference createPDFAttachment(){
                
            String pageName = null;
            String productName = null;
            String productId = null;
            Product2 product = null;
            String queryString = null;
            
            List<QuoteLineItem> quoteLineItemList = getQuoteLineItem();
        
            if(quoteLineItemList != null){
                QuoteLineItem quoteLine =quoteLineItemList.get(0);
                productId= quoteLine.PricebookEntry.Product2Id ;
                system.debug('product id is :' +productId);
                if(productId != null){
                    
                    product =[select family from Product2 where id =:productId];
                    
                    if(product != null){
                        productName = product.Family;
                        system.debug('product name is :' +productName);
                    }
                }
            
            }
            
            // Check for different product type to generate diferent pdfs
            if (productName == 'O2 Wholesale Ethernet') {
                pageName ='QuotePDFForBEWholesale';
            } else if (productName == 'O2 Wholesale High Speed Internet Service') {
                pageName ='QuotePDFForBEHighSpeedIS';
            } else if (productName == 'O2 Wholesale Interconnect') {
                pageName ='QuotePDFForBEInterconnect';
            } else if (productName == 'Excess Construction Costs') {
                pageName ='QuotePDFForBEAddCharges';
            } else if (productName == 'Custom Product Description') {
                pageName ='QuotePDFForBECustomProduct';
            }
        
            // set the page name    
            PageReference  pdf = new PageReference('/apex/'+pageName+'?id='+quote.id);
            pdf.setRedirect(true);
          
            system.debug('quote id is :' +quote.id);
            system.debug('page name  is :' +pageName);
          
         
         
            //Create a PDF in QuotePDF related list of Quote.
            QuoteDocument quoteDoc = new QuoteDocument(QuoteId = quote.id, Document = pdf.getContent());

            insert quoteDoc;        
            return null; 
    }
    
    //Inner class
    public class QuoteLineItemWrapper{
        public QuoteLineItem quoteLineObj{get; set;} 
        public String lineNumber{get; set;}
        public String productName{get; set;}
        public Decimal unitprice{get; set;}
        public Decimal recurring{get; set;}
        public Decimal oneOff{get; set;}
        public String postCode{get; set;}
        
        public QuoteLineItemWrapper(QuoteLineItem quoteLine, String line, String prodName, Decimal unitpriceVal, Decimal oneOffVal, Decimal recurringVal){
            quoteLineObj = quoteLine;
            lineNumber = line;
            productName = prodName;
            unitprice = unitpriceVal;
            recurring = recurringVal;
            oneOff = oneOffVal;
            
            //Query for the all QuoteLineItems for a Quote
        String queryString = null;
        queryString = 'select  cscfgc__Attribute__r.Name,cscfgc__Attribute__r.cscfgc__Value__c from cscfgc__Attribute__c where QuoteId = \''+quote.Id+'\' order by ConfigNumber__c, LineItemSequence__c';
 
        System.Debug('queryString ::: ' + queryString);
                
        }
    }
    
    //Test method
    public static testmethod void testQuoteLineItemPDFExtension(){
        List<QuoteLineItem> quoteLines = new List<QuoteLineItem>();
        List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> priceEntryList = new List<PricebookEntry>();
        
        Product2 p1 = new Product2(Name='Test BE product1');
        prodList.add(p1);
        Product2 p2 = new Product2(Name='Test BE product2');
        prodList.add(p2); 
        insert prodList;    

        Pricebook2 pricebookStd = [Select Name, Id, IsStandard from Pricebook2 where IsStandard=true];      
        
        PricebookEntry priceEntry1 = new PricebookEntry( Product2Id=p1.Id, Pricebook2Id=pricebookStd.Id, UnitPrice=75.0, UseStandardPrice=false, IsActive=true);
        PricebookEntry priceEntry2 = new PricebookEntry( Product2Id=p2.Id, Pricebook2Id=pricebookStd.Id, UnitPrice=75.0, UseStandardPrice=false, IsActive=true);
        
        priceEntryList.add(priceEntry1);
        priceEntryList.add(priceEntry2);
        
        insert priceEntryList;
        
        Opportunity opp = new Opportunity(Name='tqc', CloseDate=System.today(), StageName = 'Awareness of Needs', credit_ref_number__c ='2BORNOT2B');
        opp.TotalOpportunityQuantity = 0; //satisfy validation
        insert opp;  
        
        // Create a new Bundle for this Opportunity Id
        cscfgc__Product_Bundle__c test_bundle = new cscfgc__Product_Bundle__c();
        Datetime d = system.now();
        String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');
        test_bundle.Name = 'Test Order ' + strDatetime;
        
        test_bundle.cscfgc__Opportunity__c = opp.Id;
        test_bundle.cscfgc__Synchronised_with_Opportunity__c = true;
        insert test_bundle;
        
        cscfgc__Product_Definition__c def;
        try{
        
             def = [Select c.cscfgc__Active__c, c.Name, c.Id, (Select Id, Name, cscfgc__Product_Definition__c, cscfgc__Is_Line_Item__c, cscfgc__Line_Item_Sequence__c, cscfgc__Recurring__c From cscfgc__Attribute_Definitions__r) From cscfgc__Product_Definition__c c where c.Name = 'BE Wholesale Ethernet'];
        }
        catch(Exception e)
        {
            //Assuming the org contains the BE product definition, else will throw an error.
            return;
        }   
        
        List<cscfgc__Attribute_Definition__c> attdefs = def.cscfgc__Attribute_Definitions__r;
        
        //create new configuration
        String strBunId = test_bundle.Id;
        String strDefId = def.Id;
        
        cscfgc__Product_Configuration__c config = new cscfgc__Product_Configuration__c();
        config.cscfgc__Product_Bundle__c = strBunId;
        config.cscfgc__Product_Definition__c = strDefId;        
        config.cscfgc__Configuration_Status__c = 'Valid';
        config.cscfgc__Unit_Price__c = 10;
        config.cscfgc__Quantity__c = 1;
        config.cscfgc__Recurrence_Frequency__c = 12;
        insert config;
        String strConfigId = config.Id;
        
        cscfgc__Attribute__c[] attribs = new cscfgc__Attribute__c[0];
        for (integer i=0; i<attdefs.size(); i++) {
            if (attdefs[i].cscfgc__is_Line_Item__c) {
                cscfgc__Attribute__c att = new cscfgc__Attribute__c();
                att.cscfgc__Product_Configuration__c = strConfigId;
                att.cscfgc__Attribute_Definition__c = attdefs[i].Id;
                att.Name = attdefs[i].Name;
                att.cscfgc__is_Line_Item__c = attdefs[i].cscfgc__is_Line_Item__c;
                if (attdefs[i].Name=='Customer Order Reference') {
                    att.cscfgc__line_item_Description__c = 'test1';
                    att.cscfgc__Line_Item_Sequence__c = 3;
                    att.cscfgc__Value__c = '1'; 
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Price__c = 25;
                }
                else if (attdefs[i].Name=='Contract Term') {
                    att.cscfgc__line_item_Description__c = 'test2';
                    att.cscfgc__Line_Item_Sequence__c = 4;
                    att.cscfgc__Recurring__c = false;
                    att.cscfgc__Value__c = '25.00'; 
                    att.cscfgc__Price__c = 200;
                }
                else if (attdefs[i].Name=='Install Fee') {
                    att.cscfgc__line_item_Description__c = 'test3';
                    att.cscfgc__Line_Item_Sequence__c = 2;
                    att.cscfgc__Recurring__c = false;
                    att.cscfgc__Value__c = '24';
                    att.cscfgc__Price__c = 100;                  
                }
                else if (attdefs[i].Name=='Annual Recurring Revenue') {
                    att.cscfgc__line_item_Description__c = 'test4';
                    att.cscfgc__Line_Item_Sequence__c = 1;
                    att.cscfgc__Recurring__c = true;
                    att.cscfgc__Value__c = 'New Provide';
                    att.cscfgc__Price__c = 25*12;                   
                }
                att.cscfgc__is_Active__c = true;
                attribs.add(att);
            }
        }
        insert attribs;
        
        List<OpportunityLineItem> oli = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = priceEntry1.Id;
        oli1.cscfgc__Attribute__c = attribs.get(0).Id;
        oli1.Quantity = 1.0;
        oli1.TotalPrice = 75;
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = priceEntry2.Id;
        oli2.cscfgc__Attribute__c = attribs.get(1).Id;
        oli2.Quantity = 1.0;
        oli2.TotalPrice = 75;
        
        oli.add(oli1);
        oli.add(oli2);
        insert oli;
            
        Quote q = new Quote(Name='Quote of the Day', OpportunityId=opp.Id, Pricebook2Id=pricebookStd.Id);
        insert q;
                
        QuoteLineItem quoteLine1 = new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=priceEntry1.Id, Quantity=1.0, UnitPrice=75.0, cscfgc__Attribute__c=attribs.get(0).Id);
        insert quoteLine1;
        
        
        Test.startTest();
        
        ApexPages.StandardController quoteLineItemPDFExtension = new ApexPages.StandardController(q);
        QuoteLineItemPDFExtension controller = new QuoteLineItemPDFExtension(quoteLineItemPDFExtension);       
        
        controller.quote = q;        
        
        System.assertEquals(controller.quote.Id, q.Id);
        controller.getQuoteLineItemList();
        controller.createPDFAttachment();
        
        Test.stopTest();        
    }

}