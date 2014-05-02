@isTest
private class TestUnifySiteCascadeDeletition {

    static testMethod void test() {
    
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
        
        Unify_Site__c site = new Unify_Site__c();
        site.Opportunity__c=opp.Id;
        insert site;
        
        cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c();
        pb.cscfgc__Opportunity__c=opp.Id;
        insert pb;
        
        
        cscfgc__Product_Configuration__c pc = new cscfgc__Product_Configuration__c();
        pc.cscfgc__product_bundle__c=pb.Id;
        pc.Unify_Site__c=site.Id;
        pc.Unify_Order_Type__c='';
        insert pc;
        
        
        delete site;
        
        System.assert([select id from cscfgc__Product_Configuration__c where id=:pc.Id].size()==0);
        
    }
}