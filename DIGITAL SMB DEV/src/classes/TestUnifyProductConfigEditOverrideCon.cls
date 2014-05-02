@isTest
private class TestUnifyProductConfigEditOverrideCon {

	static cscfgc__Product_Configuration__c createConfiguration(){
		Opportunity opp = TestUnifyHelper.createOpportunity();
		
		cscfgc__Product_Bundle__c bdl = new cscfgc__Product_Bundle__c(cscfgc__Opportunity__c = opp.Id, cscfgc__Bundle_Status__c = 'Is Valid');
		
		insert bdl;
		
		cscfgc__Product_Configuration__c conf = new cscfgc__Product_Configuration__c(cscfgc__Product_Bundle__c = bdl.Id);
		
		insert conf;
		
		return conf;
	}

    static testMethod void testUnifyBundle() {
		PageReference pageRef = Page.UnifyProductConfigurationEditOverride;
		Test.setCurrentPageReference(pageRef);
		
		ApexPages.StandardController sc = new ApexPages.standardController(createConfiguration());
		UnifyProductConfigurationEditOverrideCon conExt = new UnifyProductConfigurationEditOverrideCon(sc);
        
        PageReference pr = conExt.autoRun();        
    }
    
    static testMethod void testNonUnifyBundle() {
		PageReference pageRef = Page.UnifyProductConfigurationEditOverride;
		Test.setCurrentPageReference(pageRef);
		
		cscfgc__Product_Configuration__c pc = createConfiguration();
		pc = [select Id, cscfgc__Product_Bundle__c from cscfgc__Product_Configuration__c where Id = :pc.Id];
		pc.cscfgc__Product_Bundle__c = null;
		update pc;
		
		ApexPages.StandardController sc = new ApexPages.standardController(createConfiguration());
		UnifyProductConfigurationEditOverrideCon conExt = new UnifyProductConfigurationEditOverrideCon(sc);
        
        PageReference pr = conExt.autoRun();  
    }
    
    static testMethod void testAutoRun() {
        cscfgc__Product_Configuration__c pc = createConfiguration();
        pc = [select Id, cscfgc__Product_Bundle__c, cscfgc__Product_Bundle__r.cscfgc__Opportunity__c from cscfgc__Product_Configuration__c where Id = :pc.Id];
        pc.cscfgc__Product_Bundle__c = null;
        update pc;
        
        RecordType [] rts = [Select Id from RecordType where Name = 'Configurator' and sObjectType = 'Opportunity' limit 1];
        
        if(rts.size() > 0){
	        Opportunity opp = new Opportunity(Id = pc.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c, RecordTypeId = rts[0].Id);
	                            
	        update opp;
	        PageReference pageRef = Page.UnifyProductConfigurationEditOverride;
            Test.setCurrentPageReference(pageRef);
	        ApexPages.StandardController sc = new ApexPages.standardController(pc);
	        UnifyProductConfigurationEditOverrideCon conExt = new UnifyProductConfigurationEditOverrideCon(sc);
	        
	        PageReference pr = conExt.autoRun();
        }  
    }        
}