/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestOrderGroupTrigger {

    static Order_Group__c createOrderGroup(String name, Id accountID, Integer numberOfOrders, List<Id> orderIDs) {
        system.debug('Create Order Group: '+name);

        Opportunity opp = new Opportunity(Name='The Order Group'+numberOfOrders, CloseDate=System.today(), StageName = 'Awareness of Needs');
        opp.TotalOpportunityQuantity = 0; // satisfy validation rule
        insert opp;

        Order_Group__c orderGroup = new Order_Group__c(Name=name, Opportunity__c=opp.Id);
        insert orderGroup;
        system.debug(orderGroup);

        List<Order__c> orders = new List<Order__c>();
        for (Integer i = 0; i < numberOfOrders; i++) {
            system.debug('Create Order: '+name+i);
            Order__c anOrder = new Order__c(Name=name+'_'+i, Account__c=accountID, Order_Group__c=orderGroup.Id);
            system.debug(anOrder);
            orders.add(anOrder);
        }
        insert orders;
        for (Order__c anOrder:orders) {
            orderIDs.add(anOrder.Id);
        }

        return orderGroup;
    }

    static void testOrderDeleted(String test, List<Id> orders, Integer expected) {
        system.debug('testOrderDeleted: '+test+' list:'+orders);
        Integer totalCount = 0;
        for (Order__c anOrder : [SELECT Id FROM Order__c WHERE Id=:orders]) {
            system.debug('Counting Order: '+test+' ID:'+anOrder.Id);
            totalCount++;
        }
        system.assertEquals(expected, totalCount);
    }

    static void testOrderGroupDeleted(String test, Id anOrderGroupId, Integer expected) {
        Integer orderGroupCount = [SELECT Count() FROM Order_Group__c WHERE Id=:anOrderGroupId];
        system.debug('Counting Order Group: '+test+' Id: '+anOrderGroupId);
        system.assertEquals(expected, orderGroupCount);
    }

    static void deleteOrders(List<Id> orders, Integer howMany) {
        Integer i = 0;
        for (Id anOrderId: orders) {
            if (i < howMany) {
                Order__c anOrder = new Order__c(Id=anOrderId);
                delete anOrder;
                i++;
            }
        }
    }

    static testMethod void test0() {
        List<Id> o0 = new List<Id>();
        List<Order_Group__c> og0 = new List<Order_Group__c>();
        Order_Group__c og;

        og = setupTest(0, o0, og0);
        runTest(og);
        testTest(0, 0, og, o0);
    }

    static testMethod void test1() {
        List<Id> o1 = new List<Id>();
        List<Order_Group__c> og1 = new List<Order_Group__c>();
        Order_Group__c og;

        og = setupTest(1, o1, og1);
        runTest(og);
        testTest(0, 0, og, o1);
    }

    // This is a test to check we can delete an individual order
    //
    static testMethod void test2() {
        List<Id> o2 = new List<Id>();
        List<Order_Group__c> og2 = new List<Order_Group__c>();
        Order_Group__c og;

        og = setupTest(2, o2, og2);
        runTestSingleOrder(o2, 1);
        testTest(1, 1, og, o2);
    }

    static testMethod void test20() {
        List<Id> o20 = new List<Id>();
        List<Order_Group__c> og20 = new List<Order_Group__c>();
        Order_Group__c og;

        og = setupTest(0, o20, og20);
        runTest(og);
        testTest(0, 0, og, o20);
    }

    static testMethod void testMultipleOrderGroupDelete1() {
        List<Id> o2M = new List<Id>();
        List<Order_Group__c> og20 = new List<Order_Group__c>();
        Order_Group__c og2a = setupTest(2, o2M, og20);

        runTestMultiple(og20);
        testTest(0, 0, og2a, o2M);
     }

    static Order_Group__c setupTest(Integer orderCount, List<Id> orderIds, List<Order_Group__c> orderGroups) {
        final String ACCOUNT_NAME = 'Order Group Trigger Inc' + orderCount;

        // prepare test data
        Account account = new Account(Name=ACCOUNT_NAME+orderCount);
        insert account;

        //
        // Create orchestration process template id that is needed in AllOrderGroupTriggers
        //
        CSPOFA__Orchestration_Process_Template__c orchTemp;
        orchTemp = new CSPOFA__Orchestration_Process_Template__c();
        orchTemp.Name = 'Process for Order Groups';
        orchTemp.CSPOFA__Process_Type__c = 'New Provide';
        insert orchTemp;

        // Order Group with no Orders
        Order_Group__c orderGroup = createOrderGroup('o'+orderCount, account.Id, orderCount, orderIds);
        orderGroups.add(orderGroup );
        return orderGroup ;

    }

    static void runTest(Order_Group__c orderGroup) {
        // run test
        Test.startTest();

        delete orderGroup;

        Test.stopTest();
    }

    static void runTestMultiple(List<Order_Group__c> orderGroups) {
        // run test
        Test.startTest();

        delete orderGroups;

        Test.stopTest();
    }

    static void runTestSingleOrder(List<Id> orders, Integer orderCountToDelete) {
        // run test
        Test.startTest();

        deleteOrders(orders, orderCountToDelete);

        Test.stopTest();
    }

    static void testTest(Integer orderGroupCount, Integer orderCount, Order_Group__c orderGroup, List<Id> orders) {
        testOrderGroupDeleted('og'+orderCount, orderGroup.Id, orderGroupCount);
        testOrderDeleted('og'+orderCount, orders, orderCount);
    }

    static testMethod void testRejectedOrderGroup() {
        List<Id> oRej = new List<Id>();
        List<Order_Group__c> ogRej = new List<Order_Group__c>();
        Order_Group__c og;

        og = setupTest(1, oRej, ogRej);
        og.Order_Group_Status__c = 'Rejected';
        update og;


    }
}