/**
 * This class contains unit tests for TestSMBManageSearchController.
 */
@isTest
private class TestSMBManageSearchController{

    static testmethod void testSMBManageSearchController() {
       CreateRecords();
       Test.startTest();
       MyO2BusinessSubscriptionsController con = new MyO2BusinessSubscriptionsController();
       con.clearFilter();
       con.filterNames = 'Will';
       con.advancedFilter();
       for(MyO2BusinessSubscriptionsController.SubscriptionWrapper sw : con.subscriptions){   
        sw.isSelected = true;  
       }
       SMBManageSearchController smbCon = new SMBManageSearchController (con);
       Test.stopTest();

    }
    
    static void CreateRecords(){

        //Custom settings
        SOA_Integration_Settings__c soaSettings = new SOA_Integration_Settings__c(Name = 'ManageBusinessSubscriptions_1_0',
                                                                                  Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/ManageBusinessSubscriptions_1_0',
                                                                                  Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk',
                                                                                  MAX_SOA_RETRIES__c = 1,
                                                                                  Timeout__c = 60000);
        insert soaSettings;
        
        SOA_Integration_Settings__c soaSettings2 = new SOA_Integration_Settings__c(Name = 'Subscriber',
                                                                                  Endpoint__c = 'https://sdpapi.ref.o2.co.uk/services/Subscriber_2_0',
                                                                                  Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk',
                                                                                  MAX_SOA_RETRIES__c = 1,
                                                                                  Timeout__c = 60000);
        insert soaSettings2;

        MyO2BusinessSettings__c myO2BusinessSettings = new MyO2BusinessSettings__c(Name = 'Settings',
                                                                                   SubscriptionRefreshCheckFrequency__c = 2000,
                                                                                   SubscriptionRefreshMinutes__c = 60,
                                                                                   SubscriptionRefreshTimeout__c = 60000);
        insert myO2BusinessSettings;

        AC_Container__c acc = new AC_Container__c();
        insert acc;

        List<AC_Subscription__c> subscriptions = new List<AC_Subscription__c>();

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
                                                        Customer_Cost_Centre__c = '',
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
                                                                    GPRS_Bar__c = false);

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
                                                                    GPRS_Bar__c = false);

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
                                                                    GPRS_Bar__c = true);
                                                                     
                                                                                                                                  
       
      
                                                                     
                                                                     
        

        subscriptionsExtra.add(ace1);
        subscriptionsExtra.add(ace2);
        subscriptionsExtra.add(ace3);
        
        insert(subscriptionsExtra);

    }

}