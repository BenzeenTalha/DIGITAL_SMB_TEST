@isTest
private class TestUnifyQuoteCreationBlockade {

    static testMethod void myUnitTest() {
    	Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        opp.Unify_Solution__c='test;test';
        opp.UNIFY_Opportunity_Size__c='Medium';
        insert opp; 
        
        cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c();
    	pb.cscfgc__Opportunity__c=opp.Id;
    	
    	insert pb;
        
        Quote q = new Quote();
        q.Name='test';
        q.OpportunityId=opp.Id;
        try{
        	insert q;	
        } catch(Exception e){
        	
        }
        
        pb.cscfgc__Synchronised_with_Opportunity__c=true;
        update pb;

        try{
        	insert q;	
        } catch(Exception e){
        	
        }        
        
    	pb.Unify_Commercial_Approved__c=true;
    	update pb;
    	
    	insert q;
        
    }
}