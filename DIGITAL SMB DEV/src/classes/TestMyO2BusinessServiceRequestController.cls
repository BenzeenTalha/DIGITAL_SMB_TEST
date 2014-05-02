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
private class TestMyO2BusinessServiceRequestController {

    // I am going to focus on Sim Swap as it is 

    static final String PREFIX = 'sr con test';
    static final String NUMBER_PREFIX = '78787878';
    static final Integer SUBS_COUNT = 20;
    static final String VALID_SIM_NUMBER = '894456789012345677';
    //static final String VALID_SIM_NUMBER = '994456789012345675';
    static final String DEFAULT_SIM_NUMBER = '9944';

    static Account createAccount() {
        Account acc = new Account(Name = PREFIX+'Account');
        insert acc;
        return acc;     
    }

    static List<mo2b_Subscription__c>  createSubscribers(Account acc, Integer recordCount) {

        Integer i = 0;
        List<mo2b_Subscription__c> subsList = new List<mo2b_Subscription__c>();
        
        for (i=0; i<recordCount; i++) {
            mo2b_Subscription__c sub = new mo2b_Subscription__c();
            sub.username__c = PREFIX + i;
            sub.Account__c = acc.id;
            sub.customerCostCentre__c = 'XYZ';
            sub.primarySerialNumber__c = NUMBER_PREFIX + i;
            sub.subscriptionId__c = NUMBER_PREFIX + i;
            sub.tariffCode__c = 'XYZ';
            sub.tariffDescription__c = 'XYZ desc';
            subsList.add(sub);
        }
        
        insert subsList;
        
        List<mo2b_Subscription__c> orderedList = [SELECT Id, username__c FROM mo2b_Subscription__c WHERE account__c=:acc.Id ORDER BY username__c];
        
        return orderedList;
        
    }

    static MyO2BusinessServiceRequestController createController(PageReference pr, Id accountId) {
        // we do this by AccountId as we just want to know that we have 20 subscriptions
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('id', accountId);

        MyO2BusinessServiceRequestController srcon = new MyO2BusinessServiceRequestController();

        return srcon;
    }

    static void testCreateObjects(Account acc, Integer recordCount) {
        List<Account> accList = [SELECT Id FROM Account WHERE Id=:acc.Id];
        system.assert(accList != null);
        system.assertEquals(1, accList.Size());

        List<mo2b_Subscription__c> subsList = [SELECT Id FROM mo2b_Subscription__c WHERE Account__c=:acc.Id];
        system.assert(subsList != null);
        system.assertEquals(recordCount, subsList.Size());
    }

    static Integer modulus(Integer x, Integer y) {
        Integer a = x / y;
        Integer b = x - (a * y);

        return b;
    }

    static Integer testPaginationBasics(MyO2BusinessServiceRequestController srcon, Integer expectedRecordCount) {
        // calculate the expected pages
        Integer expectedPages = expectedRecordCount / srcon.employeePagination.pageSize;
        if (modulus(expectedRecordCount, srcon.employeePagination.pageSize) != 0) {
            expectedPages++;
        }
        system.assertEquals(expectedPages, srcon.employeePagination.getTotalPageNumber());
        system.assertEquals(expectedRecordCount, srcon.employeePagination.getTotalResultSize());
        
        return expectedPages; 
    }

    static void dumpEmployeeListList(String s, List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList) {
        system.debug('dump: '+s);
        Integer page = 0;
        for (List<MyO2BusinessServiceRequestController.EmployeeWrapper> empList:empListList) {
            Integer line = 0;
            for (MyO2BusinessServiceRequestController.EmployeeWrapper ew:empList) {
                if (ew.employee != null)
                    system.debug('['+page+','+line+'] Id:'+ew.employee.Id+' userName: '+ew.employee.username__c);
                if (ew.cli != null)
                    system.debug('['+page+','+line+'] dtm:'+ew.cli.Start_Date__c+' newSIM: '+ew.cli.New_SIM_Number__c);
                line++;
            }
            page++;
        }
    }

    static List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> testPaginationSetup(MyO2BusinessServiceRequestController srcon, Integer expectedPages, Integer selectedPages) {
        List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList = new List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>>();
        
        // set to first
        srcon.employeePagination.first();
        Integer pageNumber = 0;
        while (pageNumber < expectedPages) {
            List<MyO2BusinessServiceRequestController.EmployeeWrapper> empList = srcon.employeeList;
            // select all the employees on this page
            if (pageNumber < selectedPages) {
                srcon.selectAllEmployees();
            }
            empListList.add(empList);
            pageNumber++;
            srcon.employeePagination.next();
        }
        dumpEmployeeListList('initial', empListList);
        return empListList;
    }

    static void compareSubs(mo2b_Subscription__c s1, mo2b_Subscription__c s2) {
        system.assert(s1 != null);
        system.assert(s2 != null);

        // we only asked for username and Id on subs
        //system.debug('subscriber: '+s1.username__c+' = '+s2.username__c);
        system.assertEquals(s1.Id,s2.Id);
        system.assertEquals(s1.username__c,s2.username__c);
        
    }

    static void compareAvailableOptions(List<SelectOption> ao1, List<SelectOption> ao2) {
        // not yet implemented
    }

    static void compareCli(mo2b_CaseLineItem__c cli1, mo2b_CaseLineItem__c cli2, Integer pageNo) {
        system.assert(cli1 != null);
        system.assert(cli2 != null);
        
        system.debug('compareCli: cli1.dtm: '+cli1.Start_Date__c);
        system.debug('compareCli: cli2.dtm: '+cli2.Start_Date__c);
        system.assertEquals(cli1.action_1__c, cli2.action_1__c);
        system.assertEquals(cli1.action_2__c, cli2.action_2__c);
        system.assertEquals(cli1.action__c, cli2.action__c);
        system.assertEquals(cli1.bolt_on__c, cli2.bolt_on__c);
        system.assertEquals(cli1.case__c, cli2.case__c);
        system.assertEquals(cli1.end_date__c, cli2.end_date__c);
        system.assertEquals(cli1.id, cli2.id);
        system.assertEquals(cli1.MPN__c, cli2.MPN__c);
        system.assertEquals(cli1.Name, cli2.Name);
        /*
        if (cli2.New_SIM_Number__c.equals(DEFAULT_SIM_NUMBER)) {
            if (cli1.New_SIM_Number__c.equals(DEFAULT_SIM_NUMBER) == false) {
                cli2.New_SIM_Number__c = cli1.New_SIM_Number__c;
            }
        }
        */
        system.assertEquals(cli1.New_SIM_Number__c, cli2.New_SIM_Number__c);
        system.assertEquals(cli1.Old_SIM_Number__c, cli2.Old_SIM_Number__c);
        /*
        if (cli2.Start_Date__c == System.today()) {
            if (cli1.Start_Date__c != System.today()) {
                cli2.Start_Date__c = cli1.Start_Date__c;
            }
        }
        */
        system.assertEquals(cli1.Start_Date__c, cli2.Start_Date__c);
        system.assertEquals(cli1.Subscriber_Name__c, cli2.Subscriber_Name__c);
        system.assertEquals(cli1.Suspend__c, cli2.Suspend__c);
        system.assertEquals(cli1.mO2b_subscription__c, cli2.mO2b_subscription__c);  
    }
    
    static void compareClis(List<mo2b_CaseLineItem__c> clis1, List<mo2b_CaseLineItem__c> clis2, Integer pageNo) {
        if ( (clis1 == null) && (clis2 == null) ) {
            // it is allowable for both to be null
        } else {
            //system.debug('compareClis: clis1: '+clis1);
            //system.debug('compareClis: clis2: '+clis2);
            if (pageNo == 1) {
                system.assert(clis1 != null);
                system.assert(clis2 != null);               
                system.assertEquals(clis1.size(), clis2.size());
                Integer size = clis1.size();
                for (Integer i=0; i< size; i++) {
                    compareCli(clis1[i],clis2[i], pageNo);
                }
            } else if (pageNo == 2) {
                // the first clis will be non null, the second clis may be non null - if both non null- do a compare
                system.assert(clis1 != null);
                if (clis2 != null) {
                    system.assertEquals(clis1.size(), clis2.size());
                    Integer size = clis1.size();
                    for (Integer i=0; i< size; i++) {
                        compareCli(clis1[i],clis2[i], pageNo);
                    }                   
                }                               
            }           
        }
    }

    static void compareEW(MyO2BusinessServiceRequestController.EmployeeWrapper ew1, MyO2BusinessServiceRequestController.EmployeeWrapper ew2, Integer pageNo) {
        system.assert(ew1 != null);
        system.assert(ew2 != null);
        system.assertEquals(ew1.index, ew2.index);
        compareSubs(ew1.employee, ew2.employee);
        system.assertEquals(ew1.selected, ew2.selected);
        compareAvailableOptions(ew1.availableOptions, ew2.availableOptions);
        compareAvailableOptions(ew1.selectableOptions, ew2.selectableOptions);
        compareCli(ew1.cli, ew2.cli, pageNo);
        compareClis(ew1.clis, ew2.clis, pageNo);
        compareClis(ew1.clisNotEmpty, ew2.clisNotEmpty, pageNo);        
        
    }

    static void compareLists(List<MyO2BusinessServiceRequestController.EmployeeWrapper> list1, List<MyO2BusinessServiceRequestController.EmployeeWrapper> list2, Integer pageNo) {
        system.assert(list1 != null);
        system.assert(list2 != null);
        
        system.assertEquals(list1.Size(), list2.Size());
        Integer listSize = list1.Size();
        
        for(Integer i=0; i< listSize; i++) {
            //system.debug('compare ['+i+']');
            compareEW(list1[i],list2[i], pageNo);
        }
    }

    static void testPaginationNextPrev(MyO2BusinessServiceRequestController srcon, List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList, Integer expectedPages, Integer selectedPages, Integer pageNo) {
        // first check forwards
        srcon.employeePagination.first();
        Integer pageNumber = 0;
        //system.debug('* next --> test');
        while (pageNumber < expectedPages) {
            List<MyO2BusinessServiceRequestController.EmployeeWrapper> empList = srcon.employeeList;
            //system.debug('next compareList['+pageNumber+']');
            compareLists(empList, empListList[pageNumber], pageNo);

            pageNumber++;
            srcon.employeePagination.next();
        }
        // now check backwards
        srcon.employeePagination.last();
        pageNumber = expectedPages-1;
        //system.debug('* prev <-- test');
        while (pageNumber >= 0) {
            List<MyO2BusinessServiceRequestController.EmployeeWrapper> empList = srcon.employeeList;
            //system.debug('next compareList['+pageNumber+']');
            compareLists(empList, empListList[pageNumber], pageNo);

            pageNumber--;
            srcon.employeePagination.previous();
        }
                
    }

    static void testAddDataEmployee(MyO2BusinessServiceRequestController.EmployeeWrapper checkEw, MyO2BusinessServiceRequestController.EmployeeWrapper ew, Date d1) {
        system.debug('testAddDataEmployee: date='+d1);
        //system.debug('cli: '+ew.cli);
        //system.debug('clis: '+ew.clis);
        //system.debug('ew.Id: '+ew.employee.Id+' ew.username: '+ew.employee.username__c);
        checkEw.cli.Start_Date__c = d1;
        checkEw.cli.New_SIM_Number__c = VALID_SIM_NUMBER;
        ew.cli.Start_Date__c = d1;
        ew.cli.New_SIM_Number__c = VALID_SIM_NUMBER;
    }

    static Integer testAddDataList(List<MyO2BusinessServiceRequestController.EmployeeWrapper> checkEmpList, List<MyO2BusinessServiceRequestController.EmployeeWrapper> empList, Date baseDate, Integer offsetDays) {
        Integer i = offsetDays;
        Integer x = 0;
        for (MyO2BusinessServiceRequestController.EmployeeWrapper ew:empList) {
            testAddDataEmployee(checkEmpList[x], ew, baseDate+i);
            i++;
            x++;
        }
        return i;
    }

    static void testAddDataListList(MyO2BusinessServiceRequestController srcon, List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList, Integer expectedPages, Integer selectedPages, Integer pageNo) {
        system.debug('* testAddingData entry');
        srcon.employeePagination.first();
        Integer pageNumber = 0;
        Integer offsetDays = 0;
        while (pageNumber < expectedPages) {
            List<MyO2BusinessServiceRequestController.EmployeeWrapper> empList = srcon.employeeList;
            List<MyO2BusinessServiceRequestController.EmployeeWrapper> checkEmpList = empListList[pageNumber];

            offsetDays = testAddDataList(checkEmpList, empList, System.today(), offsetDays);
            dumpEmployeeListList('adding ['+pageNumber+']', empListList);
    
            pageNumber++;
            srcon.employeePagination.next();
        }
                
        //system.debug('* testAddingData exit');        
    }

    static void testPage1NextPrev(MyO2BusinessServiceRequestController srcon, List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList, Integer expectedPages, Integer selectedPages) {
        //system.debug('* testPage1NextPrev: entry');
        testPaginationNextPrev(srcon, empListList, expectedPages, selectedPages,1);
        //system.debug('* testPage1NextPrev: exit');
    }

    static List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> testPage2NextPrev(MyO2BusinessServiceRequestController srcon, List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList, Integer expectedPages, Integer selectedPages) {
        //system.debug('* testPage2NextPrev: entry');
        PageReference pr = srcon.nextStep();

        PageReference prExpected = Page.MyO2BusinessRequestSimSwap2;
        system.assert(prExpected.getUrl().equalsIgnoreCase(pr.getUrl()));

        testPaginationNextPrev(srcon, empListList, expectedPages, selectedPages,2);
        testAddDataListList(srcon, empListList, expectedPages, selectedPages,2);
        dumpEmployeeListList('p2 data added', empListList);

        // now lets waltz thru the list a few time
        testPaginationNextPrev(srcon, empListList, expectedPages, selectedPages,2);
        dumpEmployeeListList('p2 one nextprev', empListList);
        testPaginationNextPrev(srcon, empListList, expectedPages, selectedPages,2);
        testPaginationNextPrev(srcon, empListList, expectedPages, selectedPages,2);

        //system.debug('* testPage2NextPrev: exit');
        return empListList;
    }

    static void testPage3(MyO2BusinessServiceRequestController srcon, List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList, Integer expectedPages, Integer selectedPages) {
        srcon.nextStep();
        
        Date dBase = system.today();
        Integer offset = 0;
        srcon.employeePagination.first();
        for (Integer i=0; i < expectedPages; i++) {
            List<MyO2BusinessServiceRequestController.EmployeeWrapper> employeeList = srcon.employeeList;
            srcon.employeePagination.next();            
        }
        
        
    }

    static testMethod void test_pagination() {
        
        Account acc = createAccount();
        List<mo2b_Subscription__c> subsList = createSubscribers(acc, SUBS_COUNT);
        testCreateObjects(acc, SUBS_COUNT);
        
        MyO2BusinessServiceRequestController srcon = createController(Page.MyO2BusinessRequestSimSwap1, acc.Id);
        
        Test.startTest();
            // just get the employees for this account that we just created the subscribers for
            srcon.accountId = acc.Id;
            
            // get the first page of employees
            List<MyO2BusinessServiceRequestController.EmployeeWrapper> employeeList = srcon.employeeList;
            
            Integer expectedPages = testPaginationBasics(srcon, SUBS_COUNT);
            
            // the test wants all the pages (apart from the last) to have it's subscribers selected
            List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList = testPaginationSetup(srcon, expectedPages, expectedPages - 1);
            
            // now simulate page 1 move forward and backwards through the pages and check that the selections are ok
            testPage1NextPrev(srcon, empListList, expectedPages, expectedPages - 1);
         
            // now simulate moving to page 2, expectedPages decreases by 1 as we didn't select any employees on last page
            List<List<MyO2BusinessServiceRequestController.EmployeeWrapper>> empListList2 = testPage2NextPrev(srcon, empListList, expectedPages-1, expectedPages - 1);
                
            testPage3(srcon, empListList, expectedPages, expectedPages - 1);
                
        Test.stopTest();
    }
    
    static void test_case2Boltons(MyO2BusinessServiceRequestController srcon, List<mo2b_Subscription__c> subsList) {
        system.assert(srcon.case2Boltons != null);
        mo2b_CaseLineItem__c cli1 = new mo2b_CaseLineItem__c();
        
        MyO2BusinessServiceRequestController.Case2BoltonsWrapper bw1 = new MyO2BusinessServiceRequestController.Case2BoltonsWrapper(cli1, 'Suspend Number', subslist[0].Id, 'Mary Scott', '07777887766');
        srcon.case2Boltons.add(bw1);
        
        srcon.drillId = subsList[0].Id;
        
        system.assert(srcon.case2BoltonsForX != null);
        system.assert(srcon.case2BoltonsForX.size() == 1);
            
    }
    
    static void test_searchPanel(MyO2BusinessServiceRequestController srcon) {
        srcon.enableSearchPanel();
        system.assert(srcon.showSearchPanel == true);
        srcon.disableSearchPanel();
        system.assert(srcon.showSearchPanel == false);
    }
    
    static testmethod void test_properties() {
        Account acc = createAccount();
        List<mo2b_Subscription__c> subsList = createSubscribers(acc, SUBS_COUNT);
        testCreateObjects(acc, SUBS_COUNT);
        
        MyO2BusinessServiceRequestController srcon = createController(Page.MyO2BusinessRequestSimSwap1, acc.Id);
    
        test_case2Boltons(srcon, subsList);
        test_searchPanel(srcon);

    }
    
    static testmethod void test_actions() {
        Account acc = createAccount();
        List<mo2b_Subscription__c> subsList = createSubscribers(acc, SUBS_COUNT);
        testCreateObjects(acc, SUBS_COUNT);
        
        MyO2BusinessServiceRequestController srcon = createController(Page.MyO2BusinessRequestSimSwap1, acc.Id);

        srcon.createEmployeeList();
        system.assert(srcon.employeeList != null);

        system.assertEquals(null,srcon.empPageFirst());
        system.assertEquals(null,srcon.empPageNext());
        system.assertEquals(null,srcon.empPagePrevious());
        system.assertEquals(null,srcon.empPageLast());
        
        srcon.checkBoxChanged();
        
        srcon.getSelectedCount();
    }

    
    static void setPage(String url) {
        Test.setCurrentPage(new PageReference(url));
    }
    
    static void test_page1(String wizard, MyO2BusinessServiceRequestController con, List<mo2b_Subscription__c> subsList, Account acc) {
        // set the page
        setPage(wizard+'1');
        PageReference pr = ApexPages.currentPage();
        system.assert(pr.getUrl().contains(wizard));

        // select/deselect all the employees on this page
        con.selectAllEmployees();
        con.deselectAllEmployees();

        // try the number/name areas
        con.nameTextArea = 'jones';
        con.numberTextArea = '0781';
        con.clearNameArea();
        con.clearNumberArea();
        con.nameTextArea = 'jones';
        con.numberTextArea = '0781';
        con.createEmployeeList();
        con.clearAllAreas();
        con.createEmployeeList();
        
        // now select all the employees on the page
        con.selectAllEmployees();
        system.debug('+++con.employeesSelected: ' + con.employeesSelected);
        system.assert(con.employeesSelected.contains('1'));
        
        con.nextStep();
    }

    static void test_page2_bolton(String wizard, MyO2BusinessServiceRequestController con, List<mo2b_Subscription__c> subsList, Account acc) {
        for (MyO2BusinessServiceRequestController.EmployeeWrapper ew:con.employeeList) {
            // can do it this way
            ew.cli.Start_Date__c = System.today();
            ew.cli.Bolt_On__c = 'Unlimited Text';
            
            // or this way
            con.drillId = ew.employee.Id;
            con.newBoltonRequest.Bolt_On__c = 'Unlimited Text';
            con.newBoltonRequest.Start_Date__c = system.today();
            con.newBoltonRequest.Start_Date__c = system.today() + 7;
            con.createBoltonRequest();
            // delete it - as we need to test that also
            con.deleteBoltonRequest2();
            // then re-add it
            con.createBoltonRequest();
        }       
        system.assertEquals(1, con.caseLineItemBoltonCount);       
    }
    static void test_page2_simswap(String wizard, MyO2BusinessServiceRequestController con, List<mo2b_Subscription__c> subsList, Account acc) {
        for (MyO2BusinessServiceRequestController.EmployeeWrapper ew:con.employeeList) {
            ew.cli.New_SIM_Number__c = VALID_SIM_NUMBER;
            ew.cli.Start_Date__c = System.today();
        }
        system.assertEquals(1, con.caseLineItemSIMCount);      
    }
    static void test_page2_suspendnumber(String wizard, MyO2BusinessServiceRequestController con, List<mo2b_Subscription__c> subsList, Account acc) {
        for (MyO2BusinessServiceRequestController.EmployeeWrapper ew:con.employeeList) {
            ew.cli.Suspend__c = true;
            ew.cli.Start_Date__c = System.today();
        }
        system.assertEquals(1, con.caseLineItemSuspendCount);      
    }

    static void test_page2(String wizard, MyO2BusinessServiceRequestController con, List<mo2b_Subscription__c> subsList, Account acc) {
        setPage(wizard+'2');
        if (wizard.equals('MyO2BusinessRequestBoltOn')) {
            test_page2_bolton(wizard, con, subsList, acc);
        } else if (wizard.equals('MyO2BusinessRequestSimSwap')) {
            test_page2_simswap(wizard, con, subsList, acc);
        } else if (wizard.equals('MyO2BusinessRequestSuspendNumber')) {
            test_page2_suspendnumber(wizard, con, subsList, acc);
        }
        con.externalReference = 'ZZZZ';
        con.caseDescription = 'DDDD';
        con.nextStep();     
    }

    static void test_page3(String wizard, MyO2BusinessServiceRequestController con, List<mo2b_Subscription__c> subsList, Account acc) {
        setPage(wizard+'3');
        
        // just test going back to page 1
        con.prevStep();
        con.prevStep();
        
        // and then all the way back again
        con.nextStep();
        con.nextStep();
        
        // phew! back to where we were - now commit the changes
        con.nextStep();             
    }

    static Id test_confirm(String wizard, MyO2BusinessServiceRequestController con, List<mo2b_Subscription__c> subsList, Account acc) {
        String caseNumber = '0';
        setPage(wizard+'Confirm');
        
        system.assert(con.theCase !=null);
        system.assert(con.theCase.CaseNumber !=null);
        
        PageReference pr = con.goServiceRequests();
        //system.assertEquals(Page.MyO2BusinessMyCases, pr);
        
        return (con.theCase.Id);
    }

    static void test_case(String wizard, MyO2BusinessServiceRequestController con, List<mo2b_Subscription__c> subsList, Account acc, Id caseId) {
        List<Case> cs = [Select c.External_Reference__c, c.Description, c.CaseNumber From Case c WHERE c.Id=:caseId];
        system.assert(cs != null);
        system.assert(cs.size() == 1);
        system.assertEquals('ZZZZ', cs[0].External_Reference__c);
        system.assertEquals('DDDD', cs[0].Description);
        
        // also check there are 10 case line items
        List<mo2b_CaseLineItem__c> clis = [Select m.Name, m.MPN__c From mo2b_CaseLineItem__c m where case__c=:caseId];
        system.assert(clis != null);
        system.assertEquals(1, clis.size());
        
        con.goBackToCaller();
    }

    static testmethod void test_simSwap() {
        Account acc = createAccount();
        //commented out because we can only have one call to the batch apex in a test method
        //List<mo2b_Subscription__c> subsList = createSubscribers(acc, SUBS_COUNT);
        //testCreateObjects(acc, SUBS_COUNT);
        List<mo2b_Subscription__c> subsList = createSubscribers(acc, 1);
        testCreateObjects(acc, 1);
        
        MyO2BusinessServiceRequestController srcon = createController(Page.MyO2BusinessRequestSimSwap1, acc.Id);
        String testName = 'MyO2BusinessRequestSimSwap';

        Test.startTest();
            test_page1(testName, srcon, subsList, acc);
            test_page2(testName, srcon, subsList, acc);
            
            test_page3(testName, srcon, subsList, acc);
            Id caseId = test_confirm(testName, srcon, subsList, acc);
            test_case(testName, srcon, subsList, acc, caseId);
        Test.stopTest();
        
    }
    
    static testmethod void test_blockNumber() {
       Account acc = createAccount();
        //commented out because we can only have one call to the batch apex in a test method
        //List<mo2b_Subscription__c> subsList = createSubscribers(acc, SUBS_COUNT);
        //testCreateObjects(acc, SUBS_COUNT); 
        List<mo2b_Subscription__c> subsList = createSubscribers(acc, 1);
        testCreateObjects(acc, 1);
        
        MyO2BusinessServiceRequestController srcon = createController(Page.MyO2BusinessRequestSimSwap1, acc.Id);
        String testName = 'MyO2BusinessRequestSuspendNumber';

        Test.startTest();
            test_page1(testName, srcon, subsList, acc);
            test_page2(testName, srcon, subsList, acc);
            test_page3(testName, srcon, subsList, acc);
            Id caseId = test_confirm(testName, srcon, subsList, acc);
            test_case(testName, srcon, subsList, acc, caseId);
        Test.stopTest();
        
    }

    static testmethod void test_manageBoltons() {
       Account acc = createAccount();
        //commented out because we can only have one call to the batch apex in a test method
        //List<mo2b_Subscription__c> subsList = createSubscribers(acc, SUBS_COUNT);
        //testCreateObjects(acc, SUBS_COUNT);
        List<mo2b_Subscription__c> subsList = createSubscribers(acc, 1);
        testCreateObjects(acc, 1);
        
        MyO2BusinessServiceRequestController srcon = createController(Page.MyO2BusinessRequestSimSwap1, acc.Id);
        String testName = 'MyO2BusinessRequestBoltOn';

        Test.startTest();
            test_page1(testName, srcon, subsList, acc);
            test_page2(testName, srcon, subsList, acc);
            test_page3(testName, srcon, subsList, acc);
            Id caseId = test_confirm(testName, srcon, subsList, acc);
            test_case(testName, srcon, subsList, acc, caseId);
        Test.stopTest();        
    }

    
}