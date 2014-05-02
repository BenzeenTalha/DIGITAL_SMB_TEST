public with sharing class MyO2BusinessCaseSummaryController {
    
    public String queryString {get; set;}
    
    private static Map<String, List<AggregateResult>> resultsCache = new Map<String, List<AggregateResult>>();
    
    public class ChartGroup {
        public String ctype {get; set;}
        public Integer cval {get; set;}
        public ChartGroup(String ctype, Integer cval){
            this.ctype = ctype;
            this.cval = cval;
        }
        public ChartGroup(AggregateResult ar) {
            this.ctype=ar.get('status')==null?'None':(String)ar.get('status');
            this.cval=(Integer)ar.get('Total');
        }
    }
    
    public List<ChartGroup> getChartData() {
        List<ChartGroup> cg = new List<ChartGroup>();
        List<AggregateResult> aggRes;
       
        System.debug('**query**'+queryString );
        queryString = queryString.replaceAll('#','\'');
        System.debug('>>>>query**'+queryString );
        if(queryString == null) queryString = 'select mo2b_Status_value__c status, count(Id) Total from case where Service_Request_Type__c !=null  AND createddate >= LAST_N_DAYS:30 group by mo2b_Status_value__c order by mo2b_Status_value__c desc';  
               
              
        if(!resultsCache.containsKey(queryString)) {
            aggRes = database.query(queryString);
            resultsCache.put(queryString,aggRes);
        }
        for(AggregateResult ar : resultsCache.get(queryString)) {
            cg.add(new ChartGroup(ar));
        }
        // show a total of 0 if no cases exist
        if(cg.size()==0) {
            cg.add(new ChartGroup('All',0));        
        }
        return cg;
    }    
    
}