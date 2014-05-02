@isTest(SeeAllData=true)
private class TestServiceUnbilledUsageSummary {
    
    /*
      Given I have a MSISDN 447777111111 which has an item call price of 20 and an item call price of 10
      When I call the REST Service: getUnbilledUsageSummary() with this MSISDN
      Then it should return the approxNextInvoiceAmount as 30
     */
    @isTest static void testApproxNextInvoiceAmountIs30() {
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource(SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0').Endpoint__c, 'TestXMLSubscriptionDetailsResponse1');
        mock.setStaticResource(SOA_Integration_Settings__c.getValues('ViewBusinessCustomerUsage_2_0').Endpoint__c, 'TestXMLUnbilledUsageResponse1');
        mock.setHeader('Content-Type', 'text/xml');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String GROUP_CODE = 'XXXXXX';
        System.RestContext.request = new System.RestRequest();
        RestContext.request.addParameter('applicationNumber', '00000');
        RestContext.request.addParameter('MSISDN', '447595685017');
        RestContext.request.addParameter('groupCode', GROUP_CODE);
        ServiceUnbilledUsageSummary.UnbilledUsageSummaryResponse res = ServiceUnbilledUsageSummary.getUnbilledUsageSummary();
        Test.stopTest();
        System.assertEquals(30, res.approxNextInvoiceAmount);         
    } 

    @isTest static void testInvalidMSISDNStructure() {
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource(SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0').Endpoint__c, 'TestXMLSubscriptionDetailsResponse1');
        mock.setStaticResource(SOA_Integration_Settings__c.getValues('ViewBusinessCustomerUsage_2_0').Endpoint__c, 'TestXMLUnbilledUsageResponse1');
        mock.setHeader('Content-Type', 'text/xml');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String GROUP_CODE = 'XXXXXX';
        System.RestContext.request = new System.RestRequest();
        RestContext.request.addParameter('applicationNumber', '00000');
        RestContext.request.addParameter('MSISDN', '7595685017');
        RestContext.request.addParameter('groupCode', GROUP_CODE);
        ServiceUnbilledUsageSummary.UnbilledUsageSummaryResponse res = ServiceUnbilledUsageSummary.getUnbilledUsageSummary();
        Test.stopTest();
        System.assertEquals('Invalid MSISDN structure', res.responseDetails.responseCodeDescription);         
    } 


    @isTest static void testViewBusinessCustomerUsage_2_0SOAPFault() {
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource(SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0').Endpoint__c, 'TestXMLSubscriptionDetailsResponse1');
        mock.setStaticResource(SOA_Integration_Settings__c.getValues('ViewBusinessCustomerUsage_2_0').Endpoint__c, 'TestXMLUnbilledUsageResponseFault');
        mock.setHeader('Content-Type', 'text/xml');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String GROUP_CODE = 'XXXXXX';
        System.RestContext.request = new System.RestRequest();
        RestContext.request.addParameter('applicationNumber', '00000');
        RestContext.request.addParameter('MSISDN', '447595685017');
        RestContext.request.addParameter('groupCode', GROUP_CODE);
        ServiceUnbilledUsageSummary.UnbilledUsageSummaryResponse res = ServiceUnbilledUsageSummary.getUnbilledUsageSummary();
        Test.stopTest();
        System.assertEquals('Service not available; try later', res.responseDetails.responseCodeDescription);         
    }

    @isTest static void testManageBusinessSubscriptions_1_0SOAPFault() {
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource(SOA_Integration_Settings__c.getValues('ManageBusinessSubscriptions_1_0').Endpoint__c, 'TestFaultResponseForGetSubscriptionDetails');
        mock.setStaticResource(SOA_Integration_Settings__c.getValues('ViewBusinessCustomerUsage_2_0').Endpoint__c, 'TestXMLUnbilledUsageResponseFault');
        mock.setHeader('Content-Type', 'text/xml');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String GROUP_CODE = 'XXXXXX';
        System.RestContext.request = new System.RestRequest();
        RestContext.request.addParameter('applicationNumber', '00000');
        RestContext.request.addParameter('MSISDN', '447595685017');
        RestContext.request.addParameter('groupCode', GROUP_CODE);
        ServiceUnbilledUsageSummary.UnbilledUsageSummaryResponse res = ServiceUnbilledUsageSummary.getUnbilledUsageSummary();
        Test.stopTest();
        System.assertEquals('MSISDN entered is invalid', res.responseDetails.responseCodeDescription);         
    }          


}