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
private class TestUnifyAddMassHardwareItemsController {
    private static string colDelimeter {get;set;}
    private static string rowDelimeter {get;set;}
    
    static testMethod void AddMassHardwareItemsControllerTest() {
        colDelimeter = '\t';
        rowDelimeter = '\r';
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp; 
        
        Unify_Hardware__c hb = new Unify_Hardware__c();
        hb.Name = 'test ' + System.now();
        hb.Opportunity__c = opp.Id;
        hb.Bundle_Description__c = 'DISE CODE 123';
        insert hb; 
        
        Unify_Hardware_Item__c hi = new Unify_Hardware_Item__c();
        hi.Name = 'Test1 ' + System.now();
        hi.Unify_Hardware_Bundle__c = hb.Id;
        hi.Unit_Cost__c = 100;
        hi.Quantity__c = 5;
        hi.Description__c = 'Test0101';
        insert hi;
        
        /*
        string excelContent = hb.Name + colDelimeter + 'Description123' + colDelimeter + '1' + colDelimeter + '2' + rowDelimeter;
        excelContent = excelContent + 'Product' + colDelimeter + 'Description' + colDelimeter + 'Quantity ' + colDelimeter + 'UnitCost' + rowDelimeter;
        excelContent = excelContent + hi.name + colDelimeter + 'SomeNewDescr' + colDelimeter + '5' + colDelimeter + '10' + rowDelimeter;
        excelContent = excelContent + 'NewHardwareItem' + colDelimeter + 'NewHIdesc' + colDelimeter + '1' + colDelimeter + '100' + rowDelimeter;*/
        
        string excelContent = hb.Name + colDelimeter + 'Description123' + colDelimeter + '1' + colDelimeter + '2' + rowDelimeter;
        excelContent = excelContent + hi.name + colDelimeter + 'SomeNewDescr' + colDelimeter + '5' + colDelimeter + '10' + rowDelimeter;
        excelContent = excelContent + 'NewHardwareItem' + colDelimeter + 'NewHIdesc' + colDelimeter + '1' + colDelimeter + '100' + rowDelimeter;
        
        Test.startTest();

        ApexPages.Standardcontroller sc = new ApexPages.StandardController(hb);      
        UnifyAddMassHardwareItemsController uahic = new UnifyAddMassHardwareItemsController(sc);
        uahic.tarea = excelContent;
        uahic.Add();     
        uahic.Exit();   
        
        Test.stopTest();

    }
}