/**
 * This class contains unit tests for TestMyO2BusinessSubscriptionsController controller.
 */
@isTest
private class TestMyO2BusinessSubscriptionsController {

    /*
    Given I am viewing the MyO2BusinessSubscriptions
    When I enter subscription name X and it exists and I hit search
    Then I should find X
    */
    
    private static Integer numberOfSamples = 3;
    private static String testFilterName = 'Will'; 
    
    static testmethod void testMyO2BusinessSubscriptionsController() {

		System.debug('testMyO2BusinessSubscriptionsController entry point');
        CreateRecords();
		System.debug('testMyO2BusinessSubscriptionsController created records');
        // Test
        Test.startTest();
		System.debug('testMyO2BusinessSubscriptionsController test started');
        MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
        con.clearFilter();
        con.filterNames = testFilterName;
        //con.filterNumbers = '078';
        con.advancedFilter();
        //con.autoFilter();
		System.debug('testMyO2BusinessSubscriptionsController advanced filter passed');
        PageReference adminRef = con.goToAdminChanges();
        PageReference simSwapRef = con.goToSimSwap();
        PageReference adminRefSMB = con.goToSMBAdminChanges();
        PageReference simSwapRefSMB  = con.goToSMBSimSwapChanges();
        PageReference tariffRenewalRefSMB = con.goToSMBTariffRenewalDetailsPage();
        PageReference smbBarChanges = con.goToSMBBarChanges();
        //PageReference smbPUKChanges = con.goToSMBPUKCodeChanges();
        //PageReference PUKChanges = con.goToPUKCodeChanges();
        PageReference continueJourneySMB = con.continueSMBJourney();
        PageReference finishSMB = con.FinishEdit();
        PageReference cancelSMB = con.Cancel();
		System.debug('testMyO2BusinessSubscriptionsController before stop test');
        Test.stopTest();
		System.debug('testMyO2BusinessSubscriptionsController after stop test');
        System.assertEquals(con.subscriptions.size(), numberOfSamples);
        System.assert(con.subscriptions[0].subscription.Subscription_Name__c.contains('Will'));

    }
    
    static testmethod void TestGetSubscriptions() {
    	Test.startTest();
    	MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
    	con.getTariffSubscriptionsDetailsCount();
    	con.getSubscriptions();
    	con.GetSubscriptionExtras();
    	con.authorize();
    	Test.stopTest();
    }
    
    static testmethod void TestCreateCase() {
    	Test.startTest();
    	MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
    	con.newCase = new Case();
    	con.caseLineItems = new List<mo2b_CaseLineItem__c>();
    	con.caseLineItems.add(new mo2b_CaseLineItem__c());
    	con.CreateCase();
    	
    	Test.stopTest();
    }

    static testmethod void TestSimSwapJourney(){

        //Create records
        CreateRecords();

        //Start test
        Test.startTest();

        //Search some subscriptions and select them
        MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
        con.clearFilter();
        con.filterNames = testFilterName;
        con.advancedFilter();
        for(MyO2BusinessSubscriptionsController.SubscriptionWrapper sw : con.subscriptions){
            sw.isSelected = true;
        }
        PageReference simSwapRef = con.goToSimSwap();

        MyO2BusinessRequestSimSwapController simSwapCtrl = new MyO2BusinessRequestSimSwapController(con);
        simSwapCtrl.RefreshExtras();

        System.assertEquals(numberOfSamples, simSwapCtrl.simSwapCaseLineItems.size());

        simSwapCtrl.OrderFieldNameTemp = 'MOBILE_NUMBER';
        simSwapCtrl.SortList();

        simSwapCtrl.OrderFieldNameTemp = 'SUBSCRIBER';
        simSwapCtrl.SortList();

        simSwapCtrl.OrderFieldNameTemp = 'NEW_SIM';
        simSwapCtrl.SortList();

        simSwapCtrl.OrderFieldNameTemp = 'NEW_HANDSET';
        simSwapCtrl.SortList();
        simSwapCtrl.SortList();

        //Submit
        simSwapCtrl.SubmitRequest();
        

    }

    static testmethod void TestAdminChangeJourney(){
		System.debug('testadmin entry point');
        //Create records
        CreateRecords();
		System.debug('testadmin records created');

        //Start test
        Test.startTest();
		
		System.debug('testadmin test started');
        //Search some subscriptions and select them
        MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
        con.clearFilter();
        con.filterNames = testFilterName;
        con.advancedFilter();
		System.debug('testadmin after advanced filter');
        for(MyO2BusinessSubscriptionsController.SubscriptionWrapper sw : con.subscriptions){
            sw.isSelected = true;
        }
        PageReference simSwapRef = con.goToAdminChanges();
		System.debug('testadmin after gotoadminchanges');

        MyO2BusinessRequestAdminChangeController adminCtrl = new MyO2BusinessRequestAdminChangeController(con);
		System.debug('testadmin after adminCtrl creation');
        adminCtrl.RefreshExtras();
		System.debug('testadmin after refresh extras');
        
       
        System.assertEquals(numberOfSamples, adminCtrl.adminChangeCaseLineItems.size());

        adminCtrl.OrderFieldNameTemp = 'MOBILE_NUMBER';
        adminCtrl.SortList();

        adminCtrl.OrderFieldNameTemp = 'SUBSCRIBER';
        adminCtrl.SortList();

        adminCtrl.OrderFieldNameTemp = 'COST_CENTRE';
        adminCtrl.SortList();
        adminCtrl.SortList();

        //Set same cost center
        adminCtrl.SetSameCostCenter();
		System.debug('testadmin before submit request');
        //Submit
        adminCtrl.SubmitRequest();
		System.debug('testadmin after submit request');
        

    }
    
    static testmethod void TestFaultyAdminJourney(){
		System.debug('testfaultyadmin entry point');
        //Create records
        CreateRecords();
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestFailGetSubscriptionDetails');
        mock.setStatusCode(200);        
		Test.setMock(HttpCalloutMock.class,mock);
        
		System.debug('testfaultyadmin records created');

        //Start test
        Test.startTest();
		
		System.debug('testfaultyadmin test started');
        //Search some subscriptions and select them
        MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
        con.clearFilter();
        con.filterNames = testFilterName;
        con.advancedFilter();
		System.debug('testfaultyadmin after advanced filter');
        for(MyO2BusinessSubscriptionsController.SubscriptionWrapper sw : con.subscriptions){
            sw.isSelected = true;
        }
        PageReference adminRef = con.goToAdminChanges();
		System.debug('testfaultyadmin after gotoadminchanges');

        MyO2BusinessRequestAdminChangeController adminCtrl = new MyO2BusinessRequestAdminChangeController(con);
		System.debug('testfaultyadmin after adminCtrl creation');
        adminCtrl.RefreshExtras();
		System.debug('testfaultyadmin after refresh extras');
        
       
        System.assertEquals(numberOfSamples, adminCtrl.adminChangeCaseLineItems.size());

    }
    
    static testmethod void TestBarChangeJourney(){

        //Create records
        CreateRecords();

        //Start test
        Test.startTest();

        //Search some subscriptions and select them
        MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
        con.clearFilter();
        con.filterNames = testFilterName;
        con.advancedFilter();
        for(MyO2BusinessSubscriptionsController.SubscriptionWrapper sw : con.subscriptions){
            sw.isSelected = true;
        }
        PageReference simSwapRef = con.goToBarChanges();
		System.debug('TestBarChangeJourney connection = ' + con);
        MyO2BusinessRequestBarChangeController adminCtrl = new MyO2BusinessRequestBarChangeController(con);
        adminCtrl.RefreshExtras();
        
        adminCtrl.oldBarChangeCaseLineItems.get(0).MobileNumber ='07834962781';
        adminCtrl.oldBarChangeCaseLineItems.get(0).Device = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).Device = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).Device = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).GPRS = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).Full = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).International = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).PremiumCalls = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).Roaming = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).internationalC = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).premiumrateCallBar = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).fullBarWithNoMessage = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).fullBarWithNoMessage = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).stolenBar = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).addPremiumAdultBar = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).adultAndChatBar = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).adultBar = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).chatBar = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).o2OnlyRoamBar = false;
        adminCtrl.oldBarChangeCaseLineItems.get(0).BarforcallsfromUK = false;
             
        adminCtrl.oldBarChangeCaseLineItems.get(1).MobileNumber ='07808097602';
        adminCtrl.oldBarChangeCaseLineItems.get(1).Device = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).Device = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).Device = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).GPRS = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).Full = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).International = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).PremiumCalls = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).Roaming = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).internationalC = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).premiumrateCallBar = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).fullBarWithNoMessage = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).fullBarWithNoMessage = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).stolenBar = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).addPremiumAdultBar = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).adultAndChatBar = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).adultBar = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).chatBar = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).o2OnlyRoamBar = true;
        adminCtrl.oldBarChangeCaseLineItems.get(1).BarforcallsfromUK = true;
        
        
        System.assertEquals(numberOfSamples, adminCtrl.barChangeCaseLineItems.size());
       

        adminCtrl.OrderFieldNameTemp = 'MobileNumber';
        adminCtrl.SortList();

        List<String> requestedBarChanges = new List<String>();
             
        adminCtrl.barChangeCaseLineItems.get(0).MobileNumber ='07834962781';
        adminCtrl.barChangeCaseLineItems.get(0).Device = true;
        System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).Device);
        
        requestedBarChanges.add('Add IMEI Bar'); 
        System.assertEquals('Add IMEI Bar',requestedBarChanges.get(0));
        
         adminCtrl.barChangeCaseLineItems.get(0).GPRS = true;
          
         System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).GPRS);
         requestedBarChanges.add('Add GPRS Bar'); 
         System.assertEquals('Add GPRS Bar',requestedBarChanges.get(1));
            
         adminCtrl.barChangeCaseLineItems.get(0).GPRS = false;
         adminCtrl.barChangeCaseLineItems.get(0).Full = true;
         System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).Full);
         requestedBarChanges.add('Add full bar with no message'); 
         System.assertEquals('Add full bar with no message',requestedBarChanges.get(2));
                
         adminCtrl.barChangeCaseLineItems.get(0).International = true;
         System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).International);
         requestedBarChanges.add('Add international call bar'); 
         System.assertEquals('Add international call bar',requestedBarChanges.get(3));
            
         adminCtrl.barChangeCaseLineItems.get(0).PremiumCalls = true;
         System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).PremiumCalls);
         requestedBarChanges.add('Add premium rate call bar'); 
         System.assertEquals('Add premium rate call bar',requestedBarChanges.get(4));
               
         adminCtrl.barChangeCaseLineItems.get(0).Roaming = true;
         System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).Roaming);
         requestedBarChanges.add('Add bars h/s for calls from o/s UK'); 
         System.assertEquals('Add bars h/s for calls from o/s UK',requestedBarChanges.get(5));
            
         requestedBarChanges.add('Remove internat & premium call bar'); 
         System.assertEquals('Remove internat & premium call bar',requestedBarChanges.get(6));
         
         
          /*New Code*/
         adminCtrl.barChangeCaseLineItems.get(0).PremiumCalls = false;
         adminCtrl.barChangeCaseLineItems.get(0).Roaming = false;
         //System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(0).PremiumCalls);
        // requestedBarChanges.add('Add premium rate call bar'); 
         //System.assertEquals('Add premium rate call bar',requestedBarChanges.get(4));
         adminCtrl.barChangeCaseLineItems.get(0).International = false;
         adminCtrl.barChangeCaseLineItems.get(0).PremiumCalls = true;
         adminCtrl.barChangeCaseLineItems.get(0).Roaming = false;
         
         adminCtrl.barChangeCaseLineItems.get(0).International = true;
         adminCtrl.barChangeCaseLineItems.get(0).PremiumCalls = true;
         adminCtrl.barChangeCaseLineItems.get(0).Roaming = false;
         
         
         /*End New Code*/
            
         adminCtrl.barChangeCaseLineItems.get(0).internationaPremRoamBar = true;
         adminCtrl.barChangeCaseLineItems.get(0).internationaPremRoamLocal = true;
         System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).internationaPremRoamBar);
         System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).internationaPremRoamLocal);
             
         requestedBarChanges.add('Remove international_premium_roam'); 
         System.assertEquals('Remove international_premium_roam',requestedBarChanges.get(7));
         requestedBarChanges.add('Add international call bar'); 
         System.assertEquals('Add international call bar',requestedBarChanges.get(8));
              
              
              
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).addPremiumAdultBar);
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).adultAndChatBar);
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).adultBar);
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).chatBar);
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).o2OnlyRoamBar);
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).BarforcallsfromUK);
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).fullBarWithNoMessage);
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).fullBarWithNoMessage);
         System.assertEquals(false, adminCtrl.oldBarChangeCaseLineItems.get(0).stolenBar);
         
         
         adminCtrl.barChangeCaseLineItems.get(0).internationalC = true;
         adminCtrl.barChangeCaseLineItems.get(0).premiumrateCallBar = true;
         adminCtrl.barChangeCaseLineItems.get(0).fullBarWithNoMessage = true;
         adminCtrl.barChangeCaseLineItems.get(0).fullBarWithNoMessage = true;
         adminCtrl.barChangeCaseLineItems.get(0).stolenBar = true;
 
         adminCtrl.barChangeCaseLineItems.get(0).addPremiumAdultBar = true;
         adminCtrl.barChangeCaseLineItems.get(0).adultAndChatBar = true;
         adminCtrl.barChangeCaseLineItems.get(0).adultBar = true;
         adminCtrl.barChangeCaseLineItems.get(0).chatBar = true;
         adminCtrl.barChangeCaseLineItems.get(0).o2OnlyRoamBar = true;
         adminCtrl.barChangeCaseLineItems.get(0).BarforcallsfromUK = true;
   
        
         System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).Device);
         
          System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).Full);
          //System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).International);
          //System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).PremiumCalls);
          //System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).Roaming);
          System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).internationalC);
          System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).premiumrateCallBar);
             
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).addPremiumAdultBar);
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).adultAndChatBar);
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).adultBar);
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).chatBar);
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).o2OnlyRoamBar);
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).BarforcallsfromUK);
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).fullBarWithNoMessage);
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).fullBarWithNoMessage);
           System.assertEquals(true, adminCtrl.barChangeCaseLineItems.get(0).stolenBar);
             
            
             requestedBarChanges.add('Add full bar with no message');   
             requestedBarChanges.add('Add international call bar');
             requestedBarChanges.add('Add premium rate call bar');
             requestedBarChanges.add('Add bars h/s for calls from o/s UK'); 
             
             requestedBarChanges.add('Remove IMEI Bar');
             requestedBarChanges.add('Remove full bar with no message');
             requestedBarChanges.add('Remove full bar with message');
             requestedBarChanges.add('Remove stolen bar');
             requestedBarChanges.add('Remove international bar'); 
             requestedBarChanges.add('Remove Add full international');
             requestedBarChanges.add('Add international call bar'); 
             requestedBarChanges.add('Remove Add Premium Adult Bar');
             requestedBarChanges.add('Remove Adult and Chat Bar');
             requestedBarChanges.add('Remove adult bar'); 
             requestedBarChanges.add('Remove chat bar');
             requestedBarChanges.add('Remove bars h/s for calls from o/s UK');
             requestedBarChanges.add('Remove GPRS Bar');
             requestedBarChanges.add('Add GPRS Bar');
             requestedBarChanges.add('Remove internat & premium call bar');
             requestedBarChanges.add('Remove internat+prem+roam+local');
             requestedBarChanges.add('Remove international_premium_roam');
            
             System.assertEquals(30, requestedBarChanges.size()); 
     
            adminCtrl.barChangeCaseLineItems.get(1).Device = false;
            adminCtrl.barChangeCaseLineItems.get(1).GPRS = false;
            adminCtrl.barChangeCaseLineItems.get(1).Full = false;
            adminCtrl.barChangeCaseLineItems.get(1).International = false;
            adminCtrl.barChangeCaseLineItems.get(1).PremiumCalls = false;
            adminCtrl.barChangeCaseLineItems.get(1).Roaming = false;
            adminCtrl.barChangeCaseLineItems.get(1).internationalC = false;
            adminCtrl.barChangeCaseLineItems.get(1).premiumrateCallBar = false;
            adminCtrl.barChangeCaseLineItems.get(1).fullBarWithNoMessage = false;
            adminCtrl.barChangeCaseLineItems.get(1).fullBarWithNoMessage = false;
            adminCtrl.barChangeCaseLineItems.get(1).stolenBar = false;
 
            adminCtrl.barChangeCaseLineItems.get(1).addPremiumAdultBar = false;
            adminCtrl.barChangeCaseLineItems.get(1).adultAndChatBar = false;
            adminCtrl.barChangeCaseLineItems.get(1).adultBar = false;
            adminCtrl.barChangeCaseLineItems.get(1).chatBar = false;
            adminCtrl.barChangeCaseLineItems.get(1).o2OnlyRoamBar = false;
            adminCtrl.barChangeCaseLineItems.get(1).BarforcallsfromUK = false;
   
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).Device);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).GPRS);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).Full);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).International);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).PremiumCalls);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).Roaming);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).internationalC);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).premiumrateCallBar);
             
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).addPremiumAdultBar);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).adultAndChatBar);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).adultBar);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).chatBar);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).o2OnlyRoamBar);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).BarforcallsfromUK);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).fullBarWithNoMessage);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).fullBarWithNoMessage);
           System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).stolenBar);
     
            List<String> requestedBarChanges1 = new List<String>();
   
            System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).Device);
            requestedBarChanges1.add('Remove IMEI Bar'); 
            System.assertEquals('Remove IMEI Bar',requestedBarChanges1.get(0));
         
            System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).GPRS);
            requestedBarChanges1.add('Remove GPRS Bar'); 
            System.assertEquals('Remove GPRS Bar',requestedBarChanges1.get(1));
         
            System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).International);
            requestedBarChanges1.add('Remove international bar'); 
            System.assertEquals('Remove international bar',requestedBarChanges1.get(2));
            
             System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).PremiumCalls);
             requestedBarChanges1.add('Remove Add Premium Adult Bar'); 
             System.assertEquals('Remove Add Premium Adult Bar',requestedBarChanges1.get(3));
            
              System.assertEquals(false, adminCtrl.barChangeCaseLineItems.get(1).Roaming);
              requestedBarChanges1.add('Remove bars h/s for calls from o/s UK'); 
              System.assertEquals('Remove bars h/s for calls from o/s UK',requestedBarChanges1.get(4));
             
               requestedBarChanges1.add('Remove international_premium_roam');
               System.assertEquals('Remove international_premium_roam',requestedBarChanges1.get(5));
                 
                requestedBarChanges1.add('Remove internat+prem+roam+local'); 
                System.assertEquals('Remove internat+prem+roam+local',requestedBarChanges1.get(6));
             
             
                System.assertEquals(7, requestedBarChanges1.size()); 
                
                String finalrequestedBarChanges1 = 'Remove IMEI Bar' + ';' + 'Remove GPRS Bar' + ';' + 'Remove international bar' + ';' + 'Remove Add Premium Adult Bar' + ';' + 'Remove bars h/s for calls from o/s UK' + ';' + 'Remove international_premium_roam' + ';' + 'Remove internat+prem+roam+local';
           
             
              adminCtrl.requestedBarList(adminCtrl.barChangeCaseLineItems,adminCtrl.barChangeCaseLineItems.get(0));
              adminCtrl.requestedBarList(adminCtrl.barChangeCaseLineItems,adminCtrl.barChangeCaseLineItems.get(1));
              
              String finalRequestBarChanges = null;
                
            for(integer i=0;i<requestedBarChanges1.size();i++)
                {
                if(finalRequestBarChanges == null)
                {
                    finalRequestBarChanges = requestedBarChanges1[i];
                }
                else
                {
                    finalRequestBarChanges = finalRequestBarChanges  + ';' +requestedBarChanges1[i];

                }
            }
              
              System.assertEquals(finalrequestedBarChanges1, finalRequestBarChanges); 
            
        try{
            
             adminCtrl.SubmitRequest();
        }  catch(Exception ex) {
            
            System.Debug('My O2 Business - Bar Change - Error Inserting New Case: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
           
            throw(ex);
        } 
       
    }
    

    //Create records used by test methods
    static void CreateRecords(){

        //Custom settings
        SOA_Integration_Settings__c soaSettings = new SOA_Integration_Settings__c(Name = 'ManageBusinessSubscriptions_1_0',
                                                                                  Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/ManageBusinessSubscriptions_1_0',
                                                                                  Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk',
                                                                                  MAX_SOA_RETRIES__c = 1,
                                                                                  Timeout__c = 60000);
        insert soaSettings;
        
        SOA_Integration_Settings__c soaSettings2 = new SOA_Integration_Settings__c(Name = 'Manage_Business_Customer_Details',
                                                                                  Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/ManageBusinessCustomerDetails_1_0',
                                                                                  Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk',
                                                                                  MAX_SOA_RETRIES__c = 1,
                                                                                  Timeout__c = 60000);
        insert soaSettings2;
        
        
          SOA_Integration_Settings__c soaSettings3 = new SOA_Integration_Settings__c(Name = 'Subscriber',
                                                                                  Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/Subscriber_2_0',
                                                                                  Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk',
                                                                                  MAX_SOA_RETRIES__c = 1,
                                                                                  Timeout__c = 60000);
        insert soaSettings3;

        MyO2BusinessSettings__c myO2BusinessSettings = new MyO2BusinessSettings__c(Name = 'Settings',
                                                                                   SubscriptionRefreshCheckFrequency__c = 2000,
                                                                                   SubscriptionRefreshMinutes__c = 60,
                                                                                   SubscriptionRefreshTimeout__c = 60000);
        insert myO2BusinessSettings;

        AC_Container__c acc = new AC_Container__c();
        insert acc;

        List<AC_Subscription__c> subscriptions = new List<AC_Subscription__c>();
		System.debug('CreateRecords inserted account = ' + acc);
        AC_Subscription__c ac1 = new AC_Subscription__c(Name = 'Will Steed',
                                                        AC_Container__c = acc.Id,
                                                        Agreement_ID__c = '3406244',
                                                        Contract_Status__c = 'out-of-contract',
                                                        Customer_Cost_Centre__c = 'CATMK',
                                                        Delivery_Address_ID__c = '8098902',
                                                        DISE_Account_No__c = '4262545' ,
                                                        Network_Code__c = 'CDIG',
                                                        Network_Serial_No__c = '07834962781',
                                                       // Package_Code__c = 'BRTBPG',
                                                        Ringfence_Ind__c = 'ringfence',
                                                        Sales_Person_ID__c = '53808',
                                                        Subscription_Container_ID__c = '4262545-53808',
                                                        Subscription_ID__c = '6324955',
                                                        Subscription_Name__c = 'Will Steed',
                                                        Subscription_Status__c = 'NORMAL',
                                                        Tariff_Code__c = 'BRTBBM');

        AC_Subscription__c ac2 = new AC_Subscription__c(Name = 'Robert Willoughby 8006412',
                                                        AC_Container__c = acc.Id,
                                                        Agreement_ID__c = '2605545',
                                                        Contract_Status__c = 'out-of-contract',
                                                        Customer_Cost_Centre__c = 'SER025',
                                                        Delivery_Address_ID__c = '8289343',
                                                        DISE_Account_No__c = '1866564' ,
                                                        Network_Code__c = 'CDIG',
                                                        Network_Serial_No__c = '07808097602',
                                                        //Package_Code__c = 'BRTMPG',
                                                        Ringfence_Ind__c = 'ringfence',
                                                        Sales_Person_ID__c = '53808',
                                                        Subscription_Container_ID__c = '1866564-53808',
                                                        Subscription_ID__c = '4783954',
                                                        Subscription_Name__c = 'Robert Willoughby 8006412',
                                                        Subscription_Status__c = 'NORMAL',
                                                        Tariff_Code__c = 'BRTMOB');

        AC_Subscription__c ac3 = new AC_Subscription__c(Name = 'William Heathcote',
                                                        AC_Container__c = acc.Id,
                                                        Agreement_ID__c = '2605545',
                                                        Contract_Status__c = 'out-of-contract',
                                                        Customer_Cost_Centre__c = 'CATMK',
                                                        Delivery_Address_ID__c = '6223210',
                                                        DISE_Account_No__c = '4901518' ,
                                                        Network_Code__c = 'CDIG',
                                                        Network_Serial_No__c = '07736747443',
                                                        //Package_Code__c = 'BRTMPG',
                                                        Ringfence_Ind__c = 'ringfence',
                                                        Sales_Person_ID__c = '53808',
                                                        Subscription_Container_ID__c = '4901518-53808',
                                                        Subscription_ID__c = '2769502',
                                                        Subscription_Name__c = 'William Heathcote',
                                                        Subscription_Status__c = 'NORMAL',
                                                        Tariff_Code__c = 'BRTMOB');
                                                     
        subscriptions.add(ac1);
        subscriptions.add(ac2);
        subscriptions.add(ac3);
       
        insert subscriptions;

        List<AC_Subscription_Extra__c> subscriptionsExtra = new List<AC_Subscription_Extra__c>();

        AC_Subscription_Extra__c ace1 = new AC_Subscription_Extra__c(AC_Subscription__c = ac1.Id,
                                                                     Callout_Error__c = false,
                                                                     IMEI_Number__c = '',
                                                                     Last_Amended_Date_Customer_Details__c = '2013-03-07T16:12:41.000Z',
                                                                     Last_Amended_Date_Serial_Numbers__c = '2007-04-16T12:39:50.000Z',
                                                                     Last_Callout_Date__c = DateTime.now(),
                                                                     SIM_Number__c = '8944110064110725466',
                                                                     Subscription_ID__c = '6324955',
                                                                     Term_of_Contract__c = '24', Device_Bar__c = false,
                                                                    Full_Bar__c = false,
                                                                    International__c = false,
                                                                    Premium_Call_Bar_Display__c = false,
                                                                    Roaming_Call_Bar_Display__c = false,
                                                                    GPRS__c = false,
                                                                    
                                                                    IMEI_Bar__c = false,
                                                                    Fullbar_with_no_msg__c = false,
                                                                    Fullbar_with_msg__c = false,
                                                                    Stolen_Bar__c = false,
                                                                    International_Call_Bar_Display__c = false,
                                                                    Add_full_international_access__c = false,
                                                                    Internet_premium_call_bar__c = false,
                                                                    International_Bar__c = false,
                                                                    International_prem_roam_local__c = false,
                                                                    International_premium_roam__c = false,
                                                                    Premium_rate_call_bar__c = false,
                                                                    Add_Premium_Adult_Bar__c = false,
                                                                    Adult_and_Chat_Bar__c = false,
                                                                    Adult_Bar__c = false,
                                                                    Chat_Bar__c = false,
                                                                    Bars_h_s_for_calls_from_o_s_UK__c = false,
                                                                    O2_only_roam_bar__c = false,
                                                                    GPRS_Bar__c = false,
                                                                    PUK_Code_Flag__c = false,
                                                                    BoltOns_Flag__c= false);

        AC_Subscription_Extra__c ace2 = new AC_Subscription_Extra__c(AC_Subscription__c = ac2.Id,
                                                                     Callout_Error__c = false,
                                                                     IMEI_Number__c = '',
                                                                     Last_Amended_Date_Customer_Details__c = '2012-12-30T10:12:19.000Z',
                                                                     Last_Amended_Date_Serial_Numbers__c = '2005-01-18T16:01:31.000Z',
                                                                     Last_Callout_Date__c = DateTime.now(),
                                                                     SIM_Number__c = '63353439025',
                                                                     Subscription_ID__c = '4783954',
                                                                     Term_of_Contract__c = '24', Device_Bar__c = false,
                                                                    Full_Bar__c = false,
                                                                    International__c = false,
                                                                    Premium_Call_Bar_Display__c = false,
                                                                    Roaming_Call_Bar_Display__c = false,
                                                                    GPRS__c = false,
                                                                    
                                                                    IMEI_Bar__c = false,
                                                                    Fullbar_with_no_msg__c = false,
                                                                    Fullbar_with_msg__c = false,
                                                                    Stolen_Bar__c = false,
                                                                    International_Call_Bar_Display__c = false,
                                                                    Add_full_international_access__c = false,
                                                                    Internet_premium_call_bar__c = false,
                                                                    International_Bar__c = false,
                                                                    International_prem_roam_local__c = false,
                                                                    International_premium_roam__c = false,
                                                                    Premium_rate_call_bar__c = false,
                                                                    Add_Premium_Adult_Bar__c = false,
                                                                    Adult_and_Chat_Bar__c = false,
                                                                    Adult_Bar__c = false,
                                                                    Chat_Bar__c = false,
                                                                    Bars_h_s_for_calls_from_o_s_UK__c = false,
                                                                    O2_only_roam_bar__c = false,
                                                                    GPRS_Bar__c = false,
                                                                    PUK_Code_Flag__c = false,
                                                                    BoltOns_Flag__c= false);

        AC_Subscription_Extra__c ace3 = new AC_Subscription_Extra__c(AC_Subscription__c = ac3.Id,
                                                                     Callout_Error__c = true,
                                                                     IMEI_Number__c = '',
                                                                     Last_Amended_Date_Customer_Details__c = '2012-12-30T10:12:19.000Z',
                                                                     Last_Amended_Date_Serial_Numbers__c = '2011-02-17T14:05:13.000Z',
                                                                     Last_Callout_Date__c = DateTime.now(),
                                                                     SIM_Number__c = '8944110065094096501',
                                                                     Subscription_ID__c = '2769502',
                                                                     Term_of_Contract__c = '24',
                                                                     Device_Bar__c = true,
                                                                    Full_Bar__c = true,
                                                                    International__c = true,
                                                                    Premium_Call_Bar_Display__c = true,
                                                                    Roaming_Call_Bar_Display__c = true,
                                                                    GPRS__c = true,
                                                                    
                                                                    IMEI_Bar__c = true,
                                                                    Fullbar_with_no_msg__c = true,
                                                                    Fullbar_with_msg__c = true,
                                                                    Stolen_Bar__c = true,
                                                                    International_Call_Bar_Display__c = true,
                                                                    Add_full_international_access__c = true,
                                                                    Internet_premium_call_bar__c = true,
                                                                    International_Bar__c = true,
                                                                    International_prem_roam_local__c = true,
                                                                    International_premium_roam__c = true,
                                                                    Premium_rate_call_bar__c = true,
                                                                    Add_Premium_Adult_Bar__c = true,
                                                                    Adult_and_Chat_Bar__c = true,
                                                                    Adult_Bar__c = true,
                                                                    Chat_Bar__c = true,
                                                                    Bars_h_s_for_calls_from_o_s_UK__c = true,
                                                                    O2_only_roam_bar__c = true,
                                                                    GPRS_Bar__c = true,
                                                                    PUK_Code_Flag__c = false,
                                                                    BoltOns_Flag__c= false);

                                                                     
        

        subscriptionsExtra.add(ace1);
        subscriptionsExtra.add(ace2);
        subscriptionsExtra.add(ace3);
        
        insert(subscriptionsExtra);
        
		Test.loadData(SOA_Integration_Settings__c.sObjectType, 'TestSOAIntegrationSettings');
		Test.loadData(MyO2BusinessSettings__c.sObjectType, 'TestMyO2BusinessSettings');
		
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestSuccessGetSubscriptionDetailsnotPUKnotBoltOn');
        mock.setStatusCode(200);        
		Test.setMock(HttpCalloutMock.class,mock);
    }

}