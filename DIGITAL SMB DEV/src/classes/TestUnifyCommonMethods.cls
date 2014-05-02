@isTest
public class TestUnifyCommonMethods {

	static testMethod void testCentralSite() {
        Opportunity opp1 = TestUnifyHelper.createOpportunity();

        /*create central site*/
        UnifyCommonMethods.addCentralSite(opp1.Id);

        /*site already exists*/
        UnifyCommonMethods.addCentralSite(opp1.Id);

        Account acc = TestUnifyHelper.createAccount();
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test';
        opp2.AccountId = acc.Id;
        opp2.CloseDate = System.today();
        opp2.StageName = 'Waiting for Qualification';
        opp2.Unify_Solution__c = 'MWAN; MLAN';
        opp2.RecordTypeId = [Select Id
        					from RecordType
        					where Name = 'Unify' and sObjectType = 'Opportunity' limit 1][0].Id;

        insert opp2;

        Location__c loc = new Location__c(Account__c = acc.Id, Unify_Central_Site__c = true);
        insert loc;

        /*create central site*/
        UnifyCommonMethods.addCentralSite(opp2.Id);
    }

    static testMethod void testOrderGroup() {
        cscfgc__Product_Bundle__c pb = TestUnifyHelper.createProductBundle();

        TestUnifyHelper.setupCustomSettings();

        Test.startTest();

        /*create order group*/
        UnifyCommonMethods.createOrderGroup(pb.cscfgc__Opportunity__c);

        /*order group already exists*/
        UnifyCommonMethods.createOrderGroup(pb.cscfgc__Opportunity__c);

        Test.stopTest();
    }

    static testMethod void testLineDelimeter() {
        String s1 = 'line1 \r\nline2';
        String s2 = UnifyCommonMethods.setLineDelimeter(s1);

        s1 = 'line1 \nline2';
        s2 = UnifyCommonMethods.setLineDelimeter(s1);

        s1 = 'line1';
        s2 = UnifyCommonMethods.setLineDelimeter(s1);
    }

    static testMethod void testCovertAmount2decimal() {
    	UnifyCommonMethods.covertAmount2decimal(null);
    	UnifyCommonMethods.cleanNumberNotation(null);
    	System.assert(UnifyCommonMethods.covertAmount2decimal('$ 11,11') == 11.11);
    	System.assert(UnifyCommonMethods.covertAmount2decimal('$ 100,000.01') == 100000.01);
    }

    static testMethod void testCancelOrder() {
    	UnifyCommonMethods.cancelOrder(null);
    	Order_Group__c og = TestUnifyHelper.createOrderGroup();
    	Order__c ord = new Order__c();
    	ord.Order_Group__c = og.Id;
    	ord.Account__c = TestUnifyHelper.createAccount().Id;
    	insert ord;
    	UnifyCommonMethods.cancelOrder(ord.Id);
    }

    static testMethod void testRAIDTrigger(){
    	UNIFY_RAID__c r = new UNIFY_RAID__c(Name = 'Test');
    	insert r;
    }

}