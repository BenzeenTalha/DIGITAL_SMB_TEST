@isTest
private class TestSOASendMessage {
    
  @isTest static void testSendSMSSuccess() {
      insert new SOA_Integration_Settings__c(name='Send_Message',Endpoint__c='https://sendSMS');
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('TestSOASendSMSResponseSuccess');
      mock.setHeader('Content-Type', 'text/xml');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
      Test.startTest();
      String responseXML = SOASendMessage.sendSMS(null, '447777777777', 'test message');
      Test.stopTest();
      System.assert(responseXML.contains('<sen:statusCode>SMS0000S</sen:statusCode>'));
  }

  @isTest static void testSendSMSFault() {
      String errorMessage = '';
      insert new SOA_Integration_Settings__c(name='Send_Message',Endpoint__c='https://sendSMS');
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('TestSOASendSMSResponseFault');
      mock.setHeader('Content-Type', 'text/xml');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
      Test.startTest();
      try {
        SOASendMessage.sendSMS(null, '447777777777', 'test message');
      } catch (Exception e) {
        errorMessage = e.getMessage();
      }
      Test.stopTest();
      System.assert(errorMessage.contains('MSISDN provided is not in international format'));
  }
    
}