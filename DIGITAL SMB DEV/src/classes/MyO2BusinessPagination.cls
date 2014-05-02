public with sharing class MyO2BusinessPagination {
    
    private ApexPages.StandardSetController con {
        get {
            if(con == null) {
                con = getController();
            }
            return con;
        }
        set;
    }     

    String query;
    Integer pageSize;
    public Boolean tooManyResults {get; set;}
    
    public MyO2BusinessPagination(String aQuery, Integer aPageSize) {
        system.debug('MyO2BusinessPagination: entry');
        query = aQuery;
        pageSize = aPageSize;
    }
    
    private static final Integer RESULT_LIMIT_INTEGER = 1000;
    private static final String RESULT_LIMIT_STRING = ' LIMIT '+RESULT_LIMIT_INTEGER;
    
    private ApexPages.StandardSetController getController() {
        // init
        // temp fix to limit rows as governor limit being reached
        // TODO, show warning to user if > 10k rows
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(Database.getQueryLocator(query + RESULT_LIMIT_STRING));        
        ssc.setPageSize(pageSize);
		tooManyResults = !ssc.getCompleteResult();
		if (!tooManyResults) {
			tooManyResults = (ssc.getResultSize() >= RESULT_LIMIT_INTEGER);
		}
		system.debug('tooManyResults: '+tooManyResults);
        return ssc; 
    }
    
    public List<SObject> getRecords() {
        return con.getRecords();
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
    
    public Integer getTotalResultSize() {
        return con.getResultSize();
    }
    
    public Integer getRangeStart() {
        return ((con.getPageNumber()-1) * pageSize)+1;
    }
    
    public Integer getRangeEnd() {
        Integer endRange = con.getPageNumber() * pageSize;
        if(endRange>con.getResultSize()) endRange=con.getResultSize();
        return endRange;
    }    
    
    // returns the total number of pages for pagination
    public Integer getTotalPageNumber() {
        Integer resultSize = con.getResultSize();
        Integer totalPageNumber = resultSize / pageSize;
        Integer mod = resultSize - (totalPageNumber * pageSize);
        if (mod > 0)
        totalPageNumber++;
        return totalPageNumber;
    }      
}