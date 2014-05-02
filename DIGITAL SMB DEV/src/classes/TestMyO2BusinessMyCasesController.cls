/**
 * This class contains unit tests for TestMyO2BusinessMyCasesController .
 */
@isTest
private class TestMyO2BusinessMyCasesController {
    
    
     static List<Case>caseListAdded;

     static mo2b_Subscription__c createSubscriber(Account acc, String username, Integer index) {
        String psn = '99'+index;
        mo2b_Subscription__c s = new mo2b_Subscription__c(account__c=acc.id, primarySerialNumber__c=psn, 
                                                          username__c=username, subscriptionId__c=psn);
        //insert s;
        return s;
    }

    static mo2b_CaseLineItem__c createCaseLineItem(Id cId, Id sId, Integer index) {
        mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c(Suspend__c=true, mo2b_subscription__c=sId, 
                                                            New_SIM_Number__c='99',Case__c=cId);
        //insert cli;
        return cli;
    }

    static Case createCase(Account acc, String subj, String descrip, String sts, Integer index) {
        List <Case> cases = new List<Case>();
        List <mo2b_Subscription__c> subs = new List<mo2b_Subscription__c>();
        List <mo2b_CaseLineItem__c> clis = new List<mo2b_CaseLineItem__c>();
        cases.add(new Case(subject='new', description='new', status='new', accountId=acc.Id, resolution_time__c=8.0));
        cases.add(new Case(subject='closed', description='closed', status='closed', accountId=acc.Id, resolution_time__c=8.0));
        cases.add(new Case(subject='In Progress', description='In Progress', status='In Progress', accountId=acc.Id, resolution_time__c=8.0));
        cases.add(new Case(subject='fixed', description='fixed', status='fixed', accountId=acc.Id, resolution_time__c=8.0));
        cases.add(new Case(subject='Waiting on Customer', description='Waiting on Customer', status='Waiting on Customer', accountId=acc.Id, resolution_time__c=8.0));
        insert cases;
        
        for(integer i=0;i<5;i++) {
            subs.add(createSubscriber(acc, cases[i].subject, i+1));
            
        }
        insert subs;
        integer i=0;
        for(mo2b_Subscription__c sub: subs) {
            clis.add(createCaseLineItem(cases[i].Id, sub.Id, i));
            i++;
        }
        insert clis;
        return cases[0];
    }
  
     static void createCases(Account acc) {
        List<Case> caseList = new List<Case>();
        system.assert(caseList != null);
        
        caseList.add(createCase(acc, 'new','new','new', 1));
        // Including the follow causes test to hit governor limits - needs to be bulkified
        //caseList.add(createCase(acc, 'closed','closed','closed', 2));
        //caseList.add(createCase(acc, 'In Progress','In Progress','In Progress', 3));
        //caseList.add(createCase(acc, 'fixed','fixed','fixed', 4));
        //caseList.add(createCase(acc, 'Waiting on Customer','Waiting on Customer','Waiting on Customer',5));
        
        caseListAdded = [SELECT Id, CaseNumber FROM Case WHERE accountId=:acc.Id];
        
        // check they were created OK
        system.assert(caseListAdded != null); 
        //system.assert(caseListAdded.size() == caseList.size());
        
        // now add something for SOSL to find
        Id [] fixedSearchResults= new Id[5];
        for (Integer j=0; j < 5; j++) {
            fixedSearchResults[j] = caseListAdded[j].Id;            
        }
        Test.setFixedSearchResults(fixedSearchResults);        
    }

    static void test_summary(String ctype, Integer expectedCount) {
        // create an account, contact, user and remember what we need to link it to case
        Account acc = TestMyO2BusinessUtility.createPortalAccount('firstName', 'lastName');
        Contact c = TestMyO2BusinessUtility.createPortalContact(acc, 'firstName', 'lastName', 'email@email.emial.com');     
        User u = TestMyO2BusinessUtility.createPortalUser(c);
        // create the cases
        createCases(acc);

        // run as the user so we only see our cases
        System.runAs(u) {
            
            // simulate the page that uses the controller
            Test.setCurrentPage(Page.MyO2BusinessMyCases);
            
            // Add the parameter
            ApexPages.currentPage().getParameters().put('ctype', ctype);

            // create the controller
            MyO2BusinessMyCasesController con = new MyO2BusinessMyCasesController();
            system.assert(con != null);
            
            // TODO system.assertEquals(expectedCount, con.getTotalResultSize());
        }
    }
    
    static testmethod void test_summary_open() {
        // 5 - closed - waiting on customer = 3
        test_summary('Open',3);
    }
    
    static testmethod void test_summary_in_SLA() {
        // 5 - closed - waiting on customer = 3
        test_summary('In SLA',3);
    }
    
    static testmethod void test_summary_out_of_SLA() {
        // Out of SLA not yet supported so it is always currently 0
        test_summary('Out of SLA',0);
    }
    
    static testmethod void test_summary_something_random() {
        // return all (i.e. 5) for a paramater value we don't know
        test_summary('Waiting on Customer',5);
    }
    static testmethod void test_summary_waiting_on_customer() {
    }
    
    static void test_advanced_filter(MyO2BusinessMyCasesController con, Date dStart, Date dEnd, Integer numCaseNumbers, String numbers, String raisedFor, Integer expected, Boolean bInvalidDate) {
        try {
            String caseNumbers = '';
            if (numCaseNumbers > 0) {
                // make a comma sep list of case numbers e.g. 7878, 7879, 7880
                for (Integer i=0; i < expected; i++) {
                    if (i != 0) {
                        caseNumbers = caseNumbers + ' , ';
                    }
                    caseNumbers = caseNumbers + caseListAdded[i].CaseNumber;
                }           
            } else if (numCaseNumbers == -1) {
                // an error case
                caseNumbers = 'fred, fred';
            }
            
            String dateRange = '';
            if (dStart != null && dEnd != null) {
                dateRange = dStart.format() + '-' + dEnd.format();
            } else if (dStart != null) {
                if (bInvalidDate) {
                    dateRange = 'banana';
                } else {
                    dateRange = dStart.format();
                }
            }
            
    
            con.filterRaisedFor = raisedFor;
            con.filterNumbers = numbers;
            con.filterCaseNumbers = caseNumbers; 
            con.filterDateRange = dateRange;
            
            con.advancedFilter();
           
        } catch (Exception e) {
            // check we expected an exception, if not then throw an error
            system.assertEquals(-1, expected);
                        
        }
        

    }

    static testmethod void test_main() {
        // create an account, contact, user and remember what we need to link it to case
        Account acc = TestMyO2BusinessUtility.createPortalAccount('firstName', 'lastName');
        Contact c = TestMyO2BusinessUtility.createPortalContact(acc, 'firstName', 'lastName', 'email@email.emial.com');     
        User u = TestMyO2BusinessUtility.createPortalUser(c);
        // create the cases
        createCases(acc);

        Test.StartTest();
       // run as the user so we only see our cases
            System.runAs(u) {
                 
                // simulate the page that uses the controller
                Test.setCurrentPage(Page.MyO2BusinessMyCases);
                
                // create the controller
                MyO2BusinessMyCasesController con = new MyO2BusinessMyCasesController();
                system.assert(con != null);
                // check we can see all the cases
                //system.assertEquals(5, con.getTotalResultSize());
                
                // Running this test method in summer (GMT+1) between 00:00BST and 01:00BST would break the asserts, since
                // the filter is comparing a datetime (CreatedDate) to a date. Had to change to use the GMT date rather
                // than the BST date.
                
                // set the date filter to yesterday, we should get to see no entries
                Date todayGmt = system.now().dateGmt();
                Date yestGmt = todayGmt - 1;

                // test myCases
                //con.filterMyCases = 'yes please';
                //test_advanced_filter(con, yestGmt, yestGmt, 0, '', '', 0, false);

                test_advanced_filter(con, yestGmt, yestGmt, 0, '', '', 0, false);
                Integer totalPageNumber0 = con.getTotalPageNumber();
                
                // from yesterday to today we should see all
                test_advanced_filter(con, yestGmt, todayGmt, 0, '', '', 5, false);
                
                // wonder what happens if I switch the dates around? Should get 0
                test_advanced_filter(con, todayGmt, yestGmt, 0, '', '', 0, false);
                
                // test just a day
                test_advanced_filter(con, yestGmt, null, 0, '', '', 0, false);
                test_advanced_filter(con, todayGmt, null, 0, '', '', 5, false);
            
                // now do some case numbers based on the case we created
                test_advanced_filter(con, null, null, 1, '', '', 1, false);
                test_advanced_filter(con, null, null, 2, '', '', 2, false);
                test_advanced_filter(con, null, null, 3, '', '', 3, false);
                test_advanced_filter(con, null, null, 4, '', '', 4, false);
                test_advanced_filter(con, null, null, 5, '', '', 5, false);
                
                // now some based on mpn
                test_advanced_filter(con, null, null, 0, '991', '', 1, false);
                test_advanced_filter(con, null, null, 0, '991, 992', '', 2, false);
                test_advanced_filter(con, null, null, 0, '991, 992, 993', '', 3, false);
                test_advanced_filter(con, null, null, 0, '991, 992, 993, 994', '', 4, false);
                test_advanced_filter(con, null, null, 0, '991, 992, 993, 994, 995', '', 5, false);
                
                // finally for a subscriber
                // with spaces between commas
                test_advanced_filter(con, null, null, 0, '', 'new', 1, false);
                test_advanced_filter(con, null, null, 0, '', 'new, closed', 2, false);
                test_advanced_filter(con, null, null, 0, '', 'new, closed, In Progress', 3, false);
                // without spaces between commas
                test_advanced_filter(con, null, null, 0, '', 'new', 1, false);
                test_advanced_filter(con, null, null, 0, '', 'new,closed', 2, false);
                test_advanced_filter(con, null, null, 0, '', 'new,closed,In Progress', 3, false);
                
               // now try permutations to get one case back
                // date + subs
                test_advanced_filter(con, yestGmt, todayGmt, 0, '', 'new', 1, false);
                
                // date + mpn
                test_advanced_filter(con, yestGmt, todayGmt, 0, '991', '', 1, false);
                
                // date + case
                test_advanced_filter(con, yestGmt, todayGmt, 1, '', '', 1, false);
     
                // subs + mpn
                test_advanced_filter(con, null, null, 0, '991', 'new', 1, false);
     
                // subs + case
                test_advanced_filter(con, null, null, 0, '', 'new', 1, false);
     
                // mpn + case
                test_advanced_filter(con, null, null, 0, '991', '', 1, false);
     
                // date + subs + mpn
                test_advanced_filter(con, yestGmt, todayGmt, 0, '991', 'new', 1, false);
    
                // date + subs + case
                test_advanced_filter(con, yestGmt, todayGmt, 0, '', 'new', 1, false);
    
                // subs + mpn + case
                test_advanced_filter(con, null, null, 0, '991', 'new', 1, false);
    
                // date + subs + mpn + case
                test_advanced_filter(con, yestGmt, todayGmt, 0, '991', 'new', 1, false);
        
                // do a sort
                con.sortByField = 'casenumber';
                con.sortByOrder='desc';
                con.sort();
                con.sortByField = 'casenumber';
                con.sortByOrder='asc';
                con.sort();

                // try to get some of the exceptions to throw
                // invalid date
                test_advanced_filter(con, yestGmt, null, 0, '', '', -1, true);
                // invalid number
                test_advanced_filter(con, null, null, 0, 'fred,fred', '', -1, false);
                // invalid case number
                test_advanced_filter(con, null, null, -1, '', '', -1, false);
         
                // misc tests
                
                
                List<Case> caseList = con.getCases();
                Integer pageNumber = con.getPageNumber();
                con.first();
                con.next();
                con.previous();
                con.last();
                Integer rangeStart = con.getRangeStart();
                Integer rangeEnd = con.getRangeEnd();
                Integer totalPageNumber = con.getTotalPageNumber();
                
                // method to clear the filters and refresh the display  
                con.clearFilter();
                system.assert(con.filterRaisedFor.equals(''));  
                system.assert(con.filterNumbers.equals(''));    
                system.assert(con.filterCaseNumbers.equals(''));    
                system.assertEquals(0, con.getTotalResultSize());
    
                // TODO
                // filterMyCases
                // exceptions in advancedFilter
    
                con.searchValue = 'Waiting on Customer';            
                con.search();
                con.searchValue = '99';         
                con.search();
            }
            Test.StopTest();

    }
    
     
    static testmethod void testMyO2BusinessMyCasesController () {
       CreateRecords();
       Test.startTest();
       MyO2BusinessMyCasesController con = new MyO2BusinessMyCasesController ();
       
      con.clearFilter();
      con.filterDateRange = '23-06-1988';
      con.filterRaisedFor = 'ABC';
      con.filterNumbers = '123,2(3)4';
      con.filterCaseNumbers = '11111';
      con.advancedFilter();
      con.search();
      /* con.clearFilter();
       con.filterNames = 'Will';
       con.advancedFilter();
       for(MyO2BusinessMyCasesController .SubscriptionWrapper sw : con.subscriptions){   
        sw.isSelected = true;  
       }
       */

      // PageReference cancel = pukCon.Cancel();
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