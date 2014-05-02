@isTest
private class TestUnifyCreateOrdersBatch {

    static testMethod void testBatch() {


		cscfgc__Product_Configuration__c conf = TestUnifyHelper.createProductConfiguration();
		Order_Group__c og = TestUnifyHelper.createOrderGroup();
		Unify_Opportunity_Location__c oppLoc = TestUnifyHelper.createOppLocForSelOpp(og.Opportunity__c);
		Unify_Site__c site = UnifyBatchConfigUpload.prepareSiteObjectBasedOnOppLoc(oppLoc.Id, 'MWAN', conf.cscfgc__Product_Bundle__c);
		conf.Unify_Solution__c = 'MWAN';
		conf.Unify_Site__c = site.Id;
		update conf;
		cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c(Id = conf.cscfgc__Product_Bundle__c, cscfgc__Synchronised_with_Opportunity__c = true);
		update pb;
		Test.startTest();
		Test.setMock(WebServiceMock.class, new TestUnifyPartnerAPI.create_MockImpl());
		UnifyCreateOrdersBatch batch = new UnifyCreateOrdersBatch();
		batch.orderGroupId = og.Id;
		batch.oppId = og.Opportunity__c;
		Database.executeBatch(batch);
		Test.stopTest();
    }
}