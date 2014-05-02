@isTest
private class TestUnifyExportConfigurationController {

    static testMethod void testExportSnow() {
        TestUnifyHelper.setupCustomSettings();
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp; 
        
        cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c();
        pb.cscfgc__Opportunity__c=opp.Id;
        insert pb;
        
        Unify_Site__c site = new Unify_Site__c();
        site.Opportunity__c=opp.Id;
        insert site;
        
        cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
        pd.cscfgc__Description__c='test';
        insert pd; 
        
        cscfgc__Product_Configuration__c pc = new cscfgc__Product_Configuration__c();
        pc.cscfgc__product_bundle__c=pb.Id;
        pc.Unify_Site__c=site.Id;
        pc.Unify_Order_Type__c='';
        insert pc;
        
        cscfgc__Attribute_Definition__c atr1Def = new cscfgc__Attribute_Definition__c();
        atr1Def.Unify_SNOW_exportable__c=true;
        atr1Def.cscfgc__Product_Definition__c=pd.Id;
        insert atr1Def; 
        
        cscfgc__Attribute__c atr1= new cscfgc__Attribute__c();
        atr1.cscfgc__Product_Configuration__c=pc.Id;
        atr1.cscfgc__Attribute_Definition__c=atr1Def.Id;
        insert atr1;
        
        UnifyExportSiteSelectionController.exportRequestClass exR = new UnifyExportSiteSelectionController.exportRequestClass();
        exR.bundleId=pb.Id;
        exR.exportType='SNOW';
        exR.pillars = new List<String>();
        exR.solutions = new List<String>();
        exR.sitesIds = new List<Id>();
        exR.sitesIds.add(site.Id);
        
        Note note = new Note();
        note.Title='test';
        note.ParentId=pb.Id;
        note.Body=Json.serialize(exR);
        insert note;
        
        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('id', note.Id);
        
        UnifyExportConfigurationController contrl = new UnifyExportConfigurationController();
        
    }
    
    static testMethod void testExportDISE() {
    
        TestUnifyHelper.setupCustomSettings();
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp; 
        
        cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c();
        pb.cscfgc__Opportunity__c=opp.Id;
        insert pb;
        
        Unify_Site__c site = new Unify_Site__c();
        site.Opportunity__c=opp.Id;
        insert site;
        
        cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
        pd.cscfgc__Description__c='test';
        insert pd; 
        
        cscfgc__Product_Configuration__c pc = new cscfgc__Product_Configuration__c();
        pc.cscfgc__product_bundle__c=pb.Id;
        pc.Unify_Site__c=site.Id;
        pc.Unify_Order_Type__c='';
        insert pc;
        
        cscfgc__Attribute_Definition__c atr1Def = new cscfgc__Attribute_Definition__c();
        atr1Def.Unify_DISE_exportable__c=true;
        atr1Def.cscfgc__Product_Definition__c=pd.Id;
        insert atr1Def; 
        
        cscfgc__Attribute__c atr1= new cscfgc__Attribute__c();
        atr1.cscfgc__Product_Configuration__c=pc.Id;
        atr1.cscfgc__Attribute_Definition__c=atr1Def.Id;
        insert atr1;
        
        UnifyExportSiteSelectionController.exportRequestClass exR = new UnifyExportSiteSelectionController.exportRequestClass();
        exR.bundleId=pb.Id;
        exR.exportType='DISE';
        exR.pillars = new List<String>();
        exR.solutions = new List<String>();
        exR.sitesIds = new List<Id>();
        exR.sitesIds.add(site.Id);
        
        Note note = new Note();
        note.Title='test';
        note.ParentId=pb.Id;
        note.Body=Json.serialize(exR);
        insert note;
        
        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('id', note.Id);
        
        UnifyExportConfigurationController contrl = new UnifyExportConfigurationController();
        
    }
}