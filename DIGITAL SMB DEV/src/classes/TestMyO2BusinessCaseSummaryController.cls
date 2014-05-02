/**
 * This class contains unit tests for MyO2BusinessCaseSummaryController (bucket case) controller. 
 */
@isTest
private class TestMyO2BusinessCaseSummaryController {
    
  /*
  Given I am viewing the MyO2BusinessCaseSummary component, Homepage charts for example
  When I pass the component a query
  Then I should see the aggregate data
  */    
  static testmethod void testGettingChartData() {
    // setup case data
    List <Case> cases = new List <Case>();
    cases.add (new Case(status='status 1'));
    cases.add (new Case(status='status 2'));
    cases.add (new Case(status='status 2'));
    insert cases;
    // test
    Test.startTest();
    MyO2BusinessCaseSummaryController con = new MyO2BusinessCaseSummaryController();
    con.queryString = 'select status, count(Id) Total from case group by status';
    List<MyO2BusinessCaseSummaryController.ChartGroup> chartGroups = con.getChartData();
    Test.stopTest();
    // verify
    System.assertEquals(chartGroups.size(),2);
    System.assertEquals(chartGroups[0].ctype,'status 1');
    System.assertEquals(chartGroups[0].cval,1);
    System.assertEquals(chartGroups[1].ctype,'status 2');
    System.assertEquals(chartGroups[1].cval,2);    
  }

  /*
  Given I am viewing the MyO2BusinessCaseSummary component, Homepage charts for example
  When I pass the component a query where there are no results
  Then I should see the aggregate data for All = 0
  */   
  static testmethod void testGettingChartDataWithNoResults() {
    // test
    Test.startTest();
    MyO2BusinessCaseSummaryController con = new MyO2BusinessCaseSummaryController();
    con.queryString = 'select status, count(Id) Total from case where id=null group by status';
    List<MyO2BusinessCaseSummaryController.ChartGroup> chartGroups = con.getChartData();
    Test.stopTest();
    // verify
    System.assertEquals(chartGroups.size(),1);
    System.assertEquals(chartGroups[0].ctype,'All');
    System.assertEquals(chartGroups[0].cval,0);
  }  
  
}