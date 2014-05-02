@isTest
private class TestUnifySiteTrigger {

    static testMethod void test() {
    	Order_Group__c og = TestUnifyHelper.createOrderGroup();
    	
    	Unify_Site__c site = new Unify_Site__c();
    	site.Opportunity__c=og.Opportunity__c;
    	site.Order_Group__c=og.Id;
    	insert site;
    	
    	Unify_Site__c site2 = new Unify_Site__c();
    	site2.Opportunity__c=og.Opportunity__c;
    	site2.Order_Group__c=og.Id;
    	site2.Installation_Status__c='Completed';
    	insert site2;
        
        cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c();
    	pb.cscfgc__Opportunity__c=og.Opportunity__c;
    	insert pb;
   		
        
      	cscfgc__Product_Configuration__c pc = new cscfgc__Product_Configuration__c();
    	pc.cscfgc__product_bundle__c=pb.Id;
    	pc.Unify_Site__c=site.Id;
    	pc.Unify_Order_Type__c='';
    	insert pc;
    	
    	
    	site.Ready_for_Billing__c = true;
    	site.Installation_Status__c='Completed';
    	site.Added_to_Billing_System_Status__c = 'In Progress';
    	update site;
    }
}