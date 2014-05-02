@isTest
public with sharing class TestUnifyProductBundleBuilderAsync {
    private static testMethod void testController(){
        cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c();
        Opportunity opp = TestUnifyHelper.createOpportunity();
        ApexPages.StandardController sc = new ApexPages.StandardController(pb);
        ApexPages.currentPage().getParameters().put('opid', opp.Id);
        Test.startTest();
        UnifyProductBundleBuilderAsyncController contr = new UnifyProductBundleBuilderAsyncController(sc);
        contr.approveCommercial();
        contr.save();
        contr.addCentral();
        Unify_Opportunity_Location__c[] ols = [select Id, Location__c, Opportunity__c from Unify_Opportunity_Location__c where Opportunity__c = :opp.Id];
        System.assert(ols.size() == 1);
        String check = UnifyProductBundleBuilderAsyncController.checkConfigNo(ols[0].Id);
        System.assert(check == '0');
        contr.changeOpt();
        contr.getItems();
        contr.approveCommercial();
        contr.sync();
        UnifyProductBundleBuilderAsyncController.removeSite(ols[0].Id);
        contr.configsListRefresh();
        contr.cancel();
        Test.stopTest();
    }

    private static testMethod void testController2(){
        cscfgc__Product_Bundle__c pb = TestUnifyHelper.createProductBundle();
        ApexPages.StandardController sc = new ApexPages.StandardController(pb);
        Test.startTest();
        UnifyProductBundleBuilderAsyncController contr = new UnifyProductBundleBuilderAsyncController(sc);
        pb = [select Id, cscfgc__Opportunity__c, cscfgc__Opportunity__r.AccountId from cscfgc__Product_Bundle__c where Id = :pb.Id];
        TestUnifyHelper.createInstalLocationForAccount(pb.cscfgc__Opportunity__r.AccountId);
        contr.refreshListOfLocs();
        System.assert(contr.getotherSitesExist());
        contr.refreshAll();
        System.assert(!contr.getSitesAdded());
        Test.stopTest();
    }

    private static testMethod void testControllerSitePart(){
        cscfgc__Product_Bundle__c pb = TestUnifyHelper.createProductBundle();
        ApexPages.StandardController sc = new ApexPages.StandardController(pb);
        Test.startTest();
        UnifyProductBundleBuilderAsyncController contr = new UnifyProductBundleBuilderAsyncController(sc);
        pb = [select Id, cscfgc__Opportunity__c, cscfgc__Opportunity__r.AccountId from cscfgc__Product_Bundle__c where Id = :pb.Id];
        Location__c locat1 = TestUnifyHelper.createInstalLocationForAccount(pb.cscfgc__Opportunity__r.AccountId);
        //scenario when user tries to reuse existing location but without selecting any
        contr.addSite();
        contr.saveSite();
        //scenario when user succesfully reuse existing location
        contr.addSite();
        for(UnifyProductBundleBuilderAsyncController.LocationElement l1 : contr.locsList){
            l1.selected = true;
        }
        contr.saveSite();
        //scenario when user tries to create empty location
        contr.addSite();
        contr.getotherSitesExist();
        contr.chosenOpt = 'NEW';
        contr.changeOpt();
        contr.saveSite();
        //scenario when user forgot to add post code
        contr.addSite();
        contr.chosenOpt = 'NEW';
        contr.loc.Unify_Unique_Site_Name__c = 'TEST123Unique';
        contr.saveSite();
        //scenario when user attempts to create manualy central site
        contr.addSite();
        contr.chosenOpt = 'NEW';
        contr.loc.Unify_Unique_Site_Name__c = 'TEST123Unique';
        contr.loc.Unify_Validated_Postcode__c = 'M11AA';
        contr.loc.Unify_Unique_Site_Name__c = UnifyConfig.CENTRAL_SITE_KEY_NAME.toUpperCase();
        contr.saveSite();
        contr.addSite();
        //scenario when user attempts to set wrong post code
        contr.chosenOpt = 'NEW';
        contr.loc.Unify_Unique_Site_Name__c = 'TEST123Unique';
        contr.loc.Unify_Validated_Postcode__c = 'wrong post code';
        contr.loc.Unify_Unique_Site_Name__c = 'TEST123Unique';
        contr.saveSite();
        //scenario when user succesfully adds a new site
        contr.addSite();
        contr.chosenOpt = 'NEW';
        contr.loc.Unify_Unique_Site_Name__c = 'TEST123Unique';
        contr.loc.Unify_Validated_Postcode__c = 'M11AA';
        contr.saveSite();
        //scenario when user tries to add a site with existing site name
        contr.addSite();
        contr.chosenOpt = 'NEW';
        contr.loc.Unify_Unique_Site_Name__c = 'TEST123Unique';
        contr.loc.Unify_Validated_Postcode__c = 'M11AA';
        contr.saveSite();
        //scenario when user tries to update site with empty site name
        contr.selOppLoc = locat1.Id;
        contr.editLoc();
        contr.loc.Unify_Unique_Site_Name__c = '';
        contr.saveSite();
        //scenario when user succesfully updates existing location
        contr.selOppLoc = locat1.Id;
        contr.editLoc();
        contr.loc.Unify_Unique_Site_Name__c = 'TEST123Unique123NEW';
        contr.saveSite();
        contr.sitesListRefresh();
        System.Assert(contr.getSitesAdded());
        //scenario when user succesfully adds second new site
        contr.addSite();
        contr.chosenOpt = 'NEW';
        contr.loc.Unify_Unique_Site_Name__c = 'site2test';
        contr.loc.Unify_Validated_Postcode__c = 'M11AA';
        contr.saveSite();
        //scenario when user tries unsuccesfully update existing location (reuses existing location name)
        contr.selOppLoc = locat1.Id;
        contr.editLoc();
        contr.loc.Unify_Unique_Site_Name__c = 'site2test';
        contr.saveSite();
        contr.exitSite();
        UnifyProductBundleBuilderAsyncController.removeSite('someFakeId');
        Test.stopTest();
    }

    private static testMethod void testControllerSolutionPart(){
        cscfgc__Product_Bundle__c pb = TestUnifyHelper.createProductBundle();
        ApexPages.StandardController sc = new ApexPages.StandardController(pb);
        Test.startTest();
        UnifyProductBundleBuilderAsyncController contr = new UnifyProductBundleBuilderAsyncController(sc);
        Unify_Opportunity_Location__c ol = TestUnifyHelper.createOppLocForSelOpp(pb.cscfgc__Opportunity__c);
        contr.getSolutionItems();
        Opportunity opp = new Opportunity(Id = pb.cscfgc__Opportunity__c, Unify_Solution__c = '');
        update opp;
        sc = new ApexPages.StandardController(pb);
        contr = new UnifyProductBundleBuilderAsyncController(sc);
        contr.getSolutionItems();
        System.assert(contr.getNoProducts());
        contr.getSelSolution();
        Test.stopTest();
    }

     private static testMethod void testControllerConfigurationPart(){
        cscfgc__Product_Bundle__c pb = TestUnifyHelper.createProductBundle();
        ApexPages.StandardController sc = new ApexPages.StandardController(pb);
        TestUnifyHelper.setupCustomSettings();
        TestUnifyHelper.createAllUnifyProdDefs();
        Test.startTest();
        UnifyProductBundleBuilderAsyncController contr = new UnifyProductBundleBuilderAsyncController(sc);
        Unify_Opportunity_Location__c ol = TestUnifyHelper.createOppLocForSelOpp(pb.cscfgc__Opportunity__c);
        System.assert(contr.getNoProducts());
        contr.setSelSolution('MWAN');
        contr.selSiteLine = ol.Id;
        contr.configsListRefresh();
        contr.addProduct();
        contr.selProdLine = '1';
        cscfgc__Product_Definition__c[] pillars = [Select Id, cscfgc__Product_Category__c, cscfgc__Label__c, cscfgc__Product_Category__r.Name, Name From cscfgc__Product_Definition__c where cscfgc__Product_Category__r.Name = 'Unify' and Name = :UnifyConfig.mPillars2Name().get('Maintenance')];
        System.assert(pillars.size() > 0);
        for(UnifyProductBundleBuilderAsyncController.cConfigReq cr1 : contr.configProductList){
            cr1.productSel = pillars[0].Id;
        }
        contr.createConf();
        // - after adding prod
        contr.getNoProducts();
        UnifyProductBundleBuilderAsyncController.checkConfigNo(ol.Id);
        contr.sitesListRefresh();
        for(UnifyProductBundleBuilderAsyncController.cConfigSite c1 : contr.configSitesList){
            c1.getRagFlag();
        }
        //contr.editConf();
        contr.delConf();
        Test.stopTest();
    }
}