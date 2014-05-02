public with sharing class BibBubbleSearchController {

    public String searchString {get;set;}
    public String executeSearchString {get; set;}
    
    private final String path = 'sfc/#search';
    
    public PageReference search() {
        String queryString = '';
       //build the query string
        if (searchString != null && searchString.length() > 0){
            queryString = 'searchTerm=' + EncodingUtil.urlEncode(searchString, 'UTF-8');
            queryString = queryString.replace('+', '%20');
        }
        executeSearchString = path + '?' + queryString;
        
        return null;
   }
}