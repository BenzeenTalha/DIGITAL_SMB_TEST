public with sharing class MyO2BusinessSubscribersController {

    public String filterName { get; set; }
    public String filterNumber { get; set; }
   
    public string sortByField {get; set;}
    public string sortByOrder {get; set;}
    public string searchValue {get; set;}
    public String filter { get; set; }
    
    public String filterString { get; private set;}
        
    static final Integer PAGE_SIZE = 10;
    static final string FIELD_LIST = ' id, username__c, primarySerialNumber__c, subscriptionId__c, tariffCode__c, terminated__c, disconnectedDate__c , connectedDate__c, tariffDescription__c, customerCostCentre__c  ';
    
    Integer totalPageNumber = 0;    
    string whereClause = '';
    
    
    public string query {get {
        return 'select '+FIELD_LIST+' from mo2b_subscription__c '+whereClause+' order by '+sortByField+' '+getSortByOrder();
    }}
        
    public MyO2BusinessSubscribersController () {
        filterString = '';
    }
    
  	public PageReference filter() {

        filterString = '';

        String filterNameStr = String.escapeSingleQuotes(filterName);
        String filterNumberStr = String.escapeSingleQuotes(filterNumber);
       
        if(filterName!='') {
            if(filterString!='') filterString+=' AND ';
            filterString+= getWhereClauseCondition('username__c',filterNameStr);
        }
        if(filterNumber!='') {
            if(filterString!='') filterString+=' AND ';
            filterString+= getWhereClauseCondition('primarySerialNumber__c',filterNumberStr);
        }        
        
        if(filterString!='') filterString = ' where '+filterString;
        
        whereClause = filterString;
        if(query.length()>10000) {
            //Display or handle error of query string > 10k characters
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The filter has too many filter items, please refine your query and try again.'));
        }
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query + ' limit 1000'));
        con.setPageSize(PAGE_SIZE);      
        return null;
    }
    
    
    private static String getWhereClauseCondition(String fieldName, String value) {
        // remove any repeating commas
        value = value.replaceAll('(,)\\1+',',');
        // remove any starting or ending commas
        value = value.replaceAll('^,|,$','');
        if(value.length()==0) {
            value = '';
        } else if(value.indexOf(',')>-1) {   
            // remove duplicates
            Set <String> uniqueSet = new Set <String>();
            for(String s : value.split(',')) {
                uniqueSet.add(s);
            }   
            value = ' (';
            Integer i = 0;
            for(String s : uniqueSet) {
                value += fieldName+' like \'%' + s + '%\'';
                i++;
                if(i!=uniqueSet.size()) value += ' OR ';
            }
            value += ')';
        } else {
            value = ' ('+fieldName+' like \'%'+value+'%\')';
        }  
        return value;  
    }
        
    public PageReference filterResults() {        
        if(filter=='Recently Created Subscriptions') { whereClause = ' where createdDate=THIS_MONTH';  }
        else whereClause= '';
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query + ' limit 1000'));
        con.setPageSize(PAGE_SIZE);  
        return null;
    }
         
    public ApexPages.StandardSetController getController() {
        // init
        sortByField = 'username__c';
        sortByOrder = 'DESC';
        searchValue = '';
        ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator(query + ' limit 1000'));
        con.setPageSize(PAGE_SIZE);
        return con;    
    }
    
    private String getSortByOrder() {
        return sortByOrder;
    }
    
    public PageReference search() {
        if(searchValue.length()>1) {
            List<List<SObject>> searchList = [FIND :searchValue IN ALL FIELDS RETURNING mo2b_subscription__c(id, username__c, primarySerialNumber__c, subscriptionId__c, tariffCode__c, disconnectedDate__c , terminated__c, connectedDate__c, tariffDescription__c, customerCostCentre__c   )];
            con = new ApexPages.StandardSetController(((List<mo2b_subscription__c>)searchList[0]));
            con.setPageSize(PAGE_SIZE); 
        } else {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_MIN_SEARCH_STRING_LENGTH));
        }    
        return null;
    }
    
    public PageReference sort() {
        if(sortByOrder=='desc') {
            sortByOrder='ASC';
        } else {
            sortByOrder='DESC';
        }    
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query + ' limit 1000'));
        con.setPageSize(PAGE_SIZE);            
        return null;
    }
    
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                con = getController();
            }
            return con;
        }
        set;
    }     
    
    public List<mo2b_subscription__c> getSubscriptions() {
        return (List<mo2b_subscription__c>)con.getRecords();
    }
    
    // returns the page number of the current page set
    public Integer getPageNumber() {
        return con.getPageNumber();
    }
 
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
 
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
 
    // returns the next page of records
    public void next() {
        con.next();
    }   
    
    // returns the total number of pages for pagination
    public Integer getTotalPageNumber() {
        integer resultSize = con.getResultSize();
        totalPageNumber = resultSize / PAGE_SIZE;
        Integer mod = resultSize - (totalPageNumber * PAGE_SIZE);
        if (mod > 0)
        totalPageNumber++;
        return totalPageNumber;
    } 
    
    /* TEST CODE */
    /*
    private static testMethod void testMyO2BusinessSubscribersControllerFilter() {
        Account a = new Account(name='Test');
        insert a;
        // Create subscriber to search for
        mo2b_subscription__c s = new mo2b_subscription__c(account__c=a.Id,username__c='Mr Adam Clark',primarySerialNumber__c='0123456789', subscriptionId__c='0123456789');
        insert s;
        MyO2BusinessSubscribersController c = new MyO2BusinessSubscribersController();
        // Setup filter criteria
        c.filterName ='Mr Adam Clark,XYZ';
        c.filterNumber = '0123456789,00987654321';
		ApexPages.StandardSetController con = c.con;
		c.filter();
        c.filterResults();
        c.first();
        c.last();
        c.next();
        c.previous();
        c.last();
        c.sort();c.sort();
        c.getTotalPageNumber();
        // Verify the subscriber is found using the filter
        System.assertEquals(1,c.getController().getResultSize());        
        c.searchValue = 'Mr Adam Clark';
        c.getSubscriptions();
        c.getPageNumber();
        c.search();
        // Verify the subscriber is found using the search
        System.assertEquals(1,c.getController().getResultSize());                
    }         */

}