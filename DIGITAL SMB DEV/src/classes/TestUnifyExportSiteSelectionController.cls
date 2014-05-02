@isTest
private class TestUnifyExportSiteSelectionController {

    static testMethod void testSiteElement() {
        UnifyExportSiteSelectionController.SiteElement se = new UnifyExportSiteSelectionController.SiteElement();
        se.hideValidation();
        se.showValidation();


        UnifyExportSiteSelectionController.exportRequestClass erc = new UnifyExportSiteSelectionController.exportRequestClass();

    }

    static testMethod void testUnifyExportSiteSelectionController() {
    
        TestUnifyHelper.setupCustomSettings();

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        opp.Unify_Solution__c='test;test';
        insert opp;

        Order_Group__c og = new Order_Group__c();
        og.Name = 'testOG';
        og.Opportunity__c = opp.Id;
        insert og;

        Unify_Site__c site = new Unify_Site__c();
        site.Opportunity__c=opp.Id;
        site.Order_Group__c = og.Id;
        insert site;

        cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c();
        pb.cscfgc__Opportunity__c=opp.Id;
        pb.Unify_Commercial_Approved__c = true;
        insert pb;

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
        atr1Def.Unify_SNOW_exportable__c=true;
        atr1Def.cscfgc__Product_Definition__c=pd.Id;
        insert atr1Def;

        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('context', 'quot');

        ApexPages.StandardController sc = new ApexPages.StandardController(pb);
        UnifyExportSiteSelectionController controller = new UnifyExportSiteSelectionController(sc);

        controller.getSystems();
        controller.getSolutionItems();
        controller.exportQuot();

        controller.exportSystem='SNOW';
        controller.refreshSitesList();

        //controller.exportConf();

        //context = ordergroup
        mPar.put('context', 'ordergroup');
        ApexPages.currentPage().getParameters().put('ogId', og.Id);
        controller = new UnifyExportSiteSelectionController(sc);
        controller.getSolutionItems();
        controller.exportOrderGroup();
        controller.exportConf();

        //solution not set
        opp.Unify_Solution__c=null;
        update opp;
        controller = new UnifyExportSiteSelectionController(sc);
        controller.getSolutionItems();


    }
}