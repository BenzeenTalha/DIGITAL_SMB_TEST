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
private class TestJUC2 {

    static testMethod void AdoptOrderGroupControllerTest() {
        //
        // Create process template
        //
        CSPOFA__Orchestration_Process_Template__c orchTemp = new CSPOFA__Orchestration_Process_Template__c();
        orchTemp.Name = 'Process for Order Groups';
        orchTemp.CSPOFA__Process_Type__c = 'New Provide';
        insert orchTemp;

        //
        Account newAcc = new Account(Name = 'test Acc');
        insert newAcc;
        Opportunity newOpp = new Opportunity(Name='test Opp', StageName = 'Achievement of Results', CloseDate = Date.Today(), AccountId = newAcc.id);
        insert newOpp;
        Order_Group__c newOG = new Order_Group__c(Opportunity__c = newOpp.id, Order_Group_Status__c = 'In progress');
        insert newOG;
        Order__c newOrder = new Order__c (Opportunity__c = newOpp.id, Order_Group__c = newOG.id, Account__c = newAcc.id, Order_Status__c = '', Order_Status_Reason__c = '');
        insert newOrder;
        //
        // -----------
        PageReference page = new PageReference('/apex/AdoptOrderGroup');
        Test.setCurrentPage(page);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(newOG);
        AdoptOrderGroupController ctrl = new AdoptOrderGroupController(stdController);
        ctrl.adoptOrderGroup();
    }

    static testMethod void OrderAvailabilityCheckControllerTest() {
        //
        // Create process template
        //
        CSPOFA__Orchestration_Process_Template__c orchTemp = new CSPOFA__Orchestration_Process_Template__c();
        orchTemp.Name = 'Process for Order Groups';
        orchTemp.CSPOFA__Process_Type__c = 'New Provide';
        insert orchTemp;

        //
        Account newAcc = new Account(Name = 'test Acc');
        insert newAcc;
        Opportunity newOpp = new Opportunity(Name='test Opp', StageName = 'Achievement of Results', CloseDate = Date.Today(), AccountId = newAcc.id);
        insert newOpp;
        Order_Group__c newOG = new Order_Group__c(Opportunity__c = newOpp.id, Order_Group_Status__c = 'In progress');
        insert newOG;
        //
        Batch_Job__c newJob = new Batch_Job__c(Status__c = 'Completed');
        insert newJob;
        Line_Availability__c lineAvailability = new  Line_Availability__c(Batch_Job__c = newJob.Id, Directory_Number__c = '4418272745232', Post_Code__c = 'W34EL');
        insert lineAvailability;
        //
        Order__c newOrder = new Order__c (Opportunity__c = newOpp.id,
                                          Order_Group__c = newOG.id,
                                          Account__c = newAcc.id,
                                          Order_Status__c = '',
                                          Order_Status_Reason__c = '',
                                          Line_Availability_Check_Result__c = lineAvailability.Id);
        insert newOrder;
        //
        // -----------
        PageReference page = new PageReference('/apex/OrderAvailabilityCheck');
        Test.setCurrentPage(page);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(newOrder);
        OrderAvailabilityCheckController ctrl = new OrderAvailabilityCheckController(stdController);
        ctrl.getNewAvailabilityCheckForOrder();
        //
        Batch_Job__c newJob1 = new Batch_Job__c(Status__c = 'Completed');
        insert newJob1;
        Line_Availability__c lineAvailability1 = new  Line_Availability__c(Batch_Job__c = newJob1.Id, Directory_Number__c = null, Post_Code__c = 'W4 4JY');
        insert lineAvailability1;
        //
        Order__c newOrder1 = new Order__c (Opportunity__c = newOpp.id,
                                          Order_Group__c = newOG.id,
                                          Account__c = newAcc.id,
                                          Order_Status__c = '',
                                          Order_Status_Reason__c = '',
                                          Line_Availability_Check_Result__c = lineAvailability1.Id);
        insert newOrder1;
        //
        // -----------
        PageReference page1 = new PageReference('/apex/OrderAvailabilityCheck');
        Test.setCurrentPage(page1);
        //
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(newOrder1);
        OrderAvailabilityCheckController ctrl1 = new OrderAvailabilityCheckController(stdController1);
        ctrl1.getNewAvailabilityCheckForOrder();
    }

    static testMethod void testProductTemplateDetailController() {
        // -----------
        //
        // Create a product template
        Product_Template__c pTemplate = new Product_Template__c(Name= 'Test',
                                                                Product_Type__c = 'Test');
        insert pTemplate;
        //
        // -----------
        PageReference page = new PageReference('/apex/ProductTemplateDetail');
        Test.setCurrentPage(page);
        //
        ApexPages.StandardController stdController = new ApexPages.StandardController(pTemplate);
        ProductTemplateDetailController ctrl = new ProductTemplateDetailController(stdController);
        ctrl.createAsset();
    }

    static testMethod void UtilityTest() {
        // -----------
        // Test stringToDate
        Utility.stringToDate('09/09');
        Utility.stringToDate('09/09/2009');
        Utility.stringToDate(null);
        // -----------
        // Test getSobjectFields
        Utility.getSobjectFields('Account');
        Utility.getSobjectFields(null);
        // -----------
        // Test getSobjectFields
        Utility.getSubString('Account', 'a', 'u');
        Utility.getSubString('Account', 'j', 'j');
        // -----------
        // Test convertListToString
        List<OpportunityStage> OppStageList =
            new List<OpportunityStage>([select MasterLabel,DefaultProbability from OpportunityStage where IsActive = true]);
        Utility.convertListToString(OppStageList);
        List<String> stringList = new List<String>();
        stringList.add('1');
        stringList.add('2');
        Utility.convertListToString(stringList);
        Set<String> stringSet = new Set<String>();
        stringSet.add('1');
        stringSet.add('2');
        Utility.convertSetToString(stringSet);

    }

    static testMethod void test_UtilityExtra() {
        // ShareCaseManually
        User u  = [select id from User where UserType =: 'Standard' and isActive = true LIMIT 1];
        List<Id> uIds = new List<Id>();
        uIds.add(u.Id);

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Case c = new Case();
            insert c;
            List<Id> cIds = new List<Id>();
            cIds.add(c.Id);

            Utility.ShareCaseManually(cIds, uIds);
        }

    }

    static testMethod void ResultTest() {
        //
        // -----------
        // Create an Account
        Account newAcc = new Account(Name = 'Test Account',
                                     Type = 'Prospect');
        insert newAcc;
        // -----------
        Contact newContact = new Contact(FirstName = 'Jack',
                                         LastName = 'Jones',
                                         email = 'jack.jones@junkmail.yahoo.com.uk',
                                         phone = '07951069913',
                                         AccountId = newAcc.Id);
        insert newContact;
        // -----------
        // Create an Opportunity
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity',
                                             StageName = 'Qualification',
                                             CloseDate = date.today(),
                                             Type = 'New Business',
                                             AccountId = newAcc.Id);
        insert newOpp;
        //
        Result res;
        res = Result.success(newOpp.id);
        res = Result.failure(newOpp.id);
        res.isFailure();
        res.isSuccess();
        res.getValue();
        res.getMessage();
    }

    static testMethod void codeCoverage()
    {
        OrderHelper.doExercise1();
        OrderHelper.doExercise2();
        OrderHelper.doExercise3();
        OrderHelper.doExercise4();
        OrderHelper.doExercise5();
    }

}