@isTest 
public class TestCaseCallout_GetSubscriptionDetails {
    /*
        TEST : CaseCallout_GetSubscriptionDetails.executeFuture
        Test Scenario:
        Given I have a container record, subscription record and subscription extra record
        When I call the CaseCallout_GetSubscriptionDetails.executeFuture method passing the subscription extra Id
        Then the subscription record and subscription extra record should be populated from service response
        -- The positive mock response is in the static resource: TestResponseForGetSubscriptionDetails
    */
    static testMethod void testGetSubscriptionDetailsSuccess() {
        // Set the service endpoints custom setting
        Test.loadData(SOA_Integration_Settings__c.sObjectType, 'TestSOAIntegrationSettings');
        
        // Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
        
        // Set up the container, subscription and subscription extra records
        AC_Container__c cont = new AC_Container__c(Name = 'Test Container');
        insert cont;
        AC_Subscription__c sub = new AC_Subscription__c(AC_Container__c = cont.Id);
        insert sub;
        AC_Subscription_Extra__c subExtra = new AC_Subscription_Extra__c(AC_Subscription__c=sub.Id, Subscription_ID__c='');
        insert subExtra;
        
        Set<Id> subExtraSet = new Set<Id>();
        subExtraSet.add(subExtra.Id);
        
        // Set up a web service mock
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestSuccessResponseForGetSubscriptionDetails');
        mock.setStatusCode(200);        
        Test.setMock(HttpCalloutMock.class,mock);
        
        // Test
        Test.startTest();
        CaseCallout_GetSubscriptionDetails.executeFuture(subExtraSet);
        Test.stopTest();
        
        // Verify the subscription is updated as expected
        sub = [select id, Agreement_ID__c, Tariff_Code__c, Tariff_Description__c, Contract_ID__c, Subscription_Name__c, Customer_Cost_Centre__c, Network_Serial_No__c from AC_Subscription__c where id=:sub.Id];
        System.assertEquals('3790984',sub.Agreement_ID__c);
        System.assertEquals('POMMBX',sub.Tariff_Code__c);
        System.assertEquals('Mobile Extension',sub.Tariff_Description__c);
        System.assertEquals('10027244',sub.Contract_ID__c);
        System.assertEquals(null,sub.Subscription_Name__c);
        System.assertEquals(null,sub.Customer_Cost_Centre__c);
        System.assertEquals('07801176594',sub.Network_Serial_No__c);
        
                
        // Verify the subscription extra record is updated as expected
        subExtra = [select id, Term_of_Contract__c, Next_Invoice_Date__c, SIM_Number__c, Last_Amended_Date_Serial_Numbers__c, Mobile_Extension_Number__c, IMEI_Number__c, Group_Mobile_Number__c,
        Last_Amended_Date_Customer_Details__c,Last_Callout_Date__c, LastModifiedById, LastModifiedDate,Subscription_ID__c, SystemModstamp,
        Full_Bar__c,International__c,Device_Bar__c,International_Bar__c,Premium_Call_Bar_Display__c,Roaming_Call_Bar_Display__c,GPRS__c,Fullbar_with_no_msg__c,Fullbar_with_msg__c,Stolen_Bar__c,Add_full_international_access__c,Bars_h_s_for_calls_from_o_s_UK__c,
        International_Call_Bar_Display__c,International_prem_roam_local__c,International_premium_roam__c,Add_Premium_Adult_Bar__c,Adult_and_Chat_Bar__c,Adult_Bar__c,Chat_Bar__c,O2_only_roam_bar__c,Premium_rate_call_bar__c,PUK_Code__c,Contractual_Bolt_Ons__c,Other_Bolt_Ons__c,Package_Code__c,Service_Code__c,DISE_Account_No__c
        from AC_Subscription_Extra__c where id=:subExtra.Id];
                    
        System.assertEquals('36',subExtra.Term_of_Contract__c);
        //System.assertEquals('2013-08-05 00:00:00',subExtra.Next_Invoice_Date__c);
        System.assertEquals('8944110065058536294',subExtra.SIM_Number__c);
        System.assertEquals('2010-12-29T05:41:54.000Z',subExtra.Last_Amended_Date_Serial_Numbers__c);
        System.assertEquals('77893,145871,2571',subExtra.Mobile_Extension_Number__c);
        System.assertEquals('332059820180700',subExtra.IMEI_Number__c);
        System.assertEquals('447801176595',subExtra.Group_Mobile_Number__c);
        System.assert(subExtra.Bars_h_s_for_calls_from_o_s_UK__c);
        System.assert(subExtra.Roaming_Call_Bar_Display__c);
        System.assert(subExtra.International_Call_Bar_Display__c);
        System.assert(subExtra.International__c);
        System.assert(subExtra.Fullbar_with_no_msg__c);
        System.assert(subExtra.Full_Bar__c);
    }    
    
    static testMethod void testGetSubscriptionDetailsFault() {
        // Set the service endpoints custom setting
        Test.loadData(SOA_Integration_Settings__c.sObjectType, 'TestSOAIntegrationSettings');
        
        // Set the MyO2Business custom setting
        Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
        
        // Set up the container, subscription and subscription extra records
        AC_Container__c cont = new AC_Container__c(Name = 'Test Container');
        insert cont;
        AC_Subscription__c sub = new AC_Subscription__c(AC_Container__c = cont.Id);
        insert sub;
        AC_Subscription_Extra__c subExtra = new AC_Subscription_Extra__c(AC_Subscription__c=sub.Id, Subscription_ID__c='');
        insert subExtra;
        
        Set<Id> subExtraSet = new Set<Id>();
        subExtraSet.add(subExtra.Id);
        
        // Set up a web service mock
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestFaultResponseForGetSubscriptionDetails');
        mock.setStatusCode(200);        
        Test.setMock(HttpCalloutMock.class,mock);
        
        // Test
        Test.startTest();
        CaseCallout_GetSubscriptionDetails.executeFuture(subExtraSet);
        Test.stopTest();
        
        // Verify the subscription extra record is updated as expected
        subExtra = [select Id, Callout_Error__c from AC_Subscription_Extra__c where id=:subExtra.Id];
        System.assert(true,subExtra.Callout_Error__c);
        
    }    
}