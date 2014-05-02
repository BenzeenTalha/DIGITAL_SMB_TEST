@istest
public with sharing class TestUnifyClone {
    
    static testMethod void testSuperClone() {    
        Unify_Hardware__c hb = TestUnifyHelper.createHardwareBundleMasterWithChildren();
        String nId = UnifyClone.cloneHardwareBundleRecord(hb.Id);
        Unify_Hardware__c[] hbs = [select Id, Total_Cost__c from Unify_Hardware__c where Id = :hb.Id or Id = :nId];
        System.assert(hbs.size() == 2);
        System.assert(hbs[0].Total_Cost__c == hbs[1].Total_Cost__c);
    }
    
    static testMethod void testSuperClone2() {    
        Unify_Hardware__c hb = TestUnifyHelper.createHardwareBundleMasterWithChildren();
        List<String> uhi = new List<String>();
        uhi.add('Unify_Hardware_Item__c');
        UnifyClone myClone = new UnifyClone(hb.Id, uhi);
    }
}