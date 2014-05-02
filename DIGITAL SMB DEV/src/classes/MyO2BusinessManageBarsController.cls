public with sharing class MyO2BusinessManageBarsController {
	public MyO2BusinessManageBarsController() {
		
	}
/* TO BE REMOVED
      public PageReference filter() {
        filterString = '';
        // Prevent SOQL injection        
        String filterNameStr = String.escapeSingleQuotes(filterName);
        String filterNumberStr = String.escapeSingleQuotes(filterNumber);
        //             
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
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        con.setPageSize(PAGE_SIZE);      
        return null;
    }
    
    private static String dtParse(String inDate) {
        String outDate= '';
        for(String dtpt : inDate.split('/')) {
            outDate = dtpt +'-'+ outDate;
        }
        outDate = outDate.substring(0,outDate.length()-1);
        outDate += 'T00:00:00Z';
        return outDate;    
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

    public String filterName { get; set; }
    public String filterNumber { get; set; }
    public String filterItemTo {get; set;}
    public String filterItemFrom { get; set; }
   
    public string sortByField {get; set;}
    public string sortByOrder {get; set;}
    public string searchValue {get; set;}
    public String filter { get; set; }
    
    public String filterString { get; private set;}
        
    static final Integer PAGE_SIZE = 10;
    static final string FIELD_LIST = ' id, selected__c, username__c, primarySerialNumber__c, subscriptionId__c, tariffCode__c, terminated__c, disconnectedDate__c , connectedDate__c, tariffDescription__c, customerCostCentre__c  ';
    
    Integer totalPageNumber = 0;    
    string whereClause = '';
    
    
    string query {get {
        return 'select '+FIELD_LIST+' from mo2b_subscription__c '+whereClause+' order by '+sortByField+' '+getSortByOrder()+' limit 1000';
    }}
        
    public MyO2BusinessManageBarsController () {
        filterString = '';
    }
        
    public PageReference filterResults() {        
        if(filter=='Recently Created Subscriptions') { whereClause = ' where createdDate=THIS_MONTH';  }
        else whereClause= '';
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        con.setPageSize(PAGE_SIZE);  
        return null;
    }
         
    private ApexPages.StandardSetController getController() {
        // init
        subscriptionIds = new Set<String>();
        sortByField = 'username__c';
        sortByOrder = 'DESC';
        searchValue = '';
        ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        con.setPageSize(PAGE_SIZE);
        return con;    
    }
    
    private String getSortByOrder() {
        //if(sortByOrder=='desc') {
        //    sortByOrder='ASC';
        //} else {
        //    sortByOrder='DESC';
        //}
        return sortByOrder;
    }
    
    public PageReference search() {
        if(searchValue.length()>1) {
            List<List<SObject>> searchList = [FIND :searchValue IN ALL FIELDS RETURNING mo2b_subscription__c(id, selected__c, username__c, primarySerialNumber__c, subscriptionId__c, tariffCode__c, disconnectedDate__c , terminated__c, connectedDate__c, tariffDescription__c, customerCostCentre__c   )];
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
        con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
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
    
    public class subscription {
        public subscription (mo2b_subscription__c sub, boolean ck) {
            subs = sub;
            checked = ck;
        }
        public mo2b_subscription__c subs {get; set;}
        public boolean checked {get; set;}
    }
    
    public void setSubscriptions(List<mo2b_subscription__c> subs) {
        subscriptionIds.add('x');
    }
    
    public Set<String> subscriptionIds {get; private set;}
    
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
*/
	private static testMethod void testMyO2BusinessManageBarsController() {
		MyO2BusinessManageBarsController con = new MyO2BusinessManageBarsController();
	}
}