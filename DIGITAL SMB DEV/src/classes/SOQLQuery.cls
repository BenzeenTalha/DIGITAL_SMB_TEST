//
// This helper class is useful when you are changing the SOQL query when using different filters.
//
// Pretty straightforward. The only tricky it is if you have two sub-clauses in the WHERE statement. I allow you to do
// something like (Name='Fred') AND (email='xyz@domain') by supplying wherePart1, whereOperator and wherePart2.
//
// To remove orderBy (or a wherePart1 etc), just set the property to null. 
//
public with sharing class SOQLQuery {
	
	public String columns { get; set;}
	public String table {get; set;}
	public String orderBy { get; set;}
	public String whereClause {get; set;}
	public String searchFilter {get; set;}
	public String filter {get; set;}
	public String whereOperator {get; set;}
	public String limitCount {get; set;}
	
	public void resetWhere() {
		whereClause = null;
		filter = null;
		searchFilter = null;
	}
	
	public String query {get {
		if (filter != null) {
			if ((searchFilter != null) && (whereOperator != null)) {
				whereClause = filter + ' ' + whereOperator + ' ' + searchFilter;				
			} else {
				whereClause = filter;
			}
		} else if (searchFilter != null) {
			whereClause = searchFilter;
		} 
		query = 'SELECT ' + columns + ' FROM ' + table;
		
		if (whereClause != null) {
			query = query + ' WHERE ' + whereClause;
		}
		
		if (orderBy != null) {
			query = query + ' ORDER BY ' + orderBy; 
		}
		
		if (limitCount != null) {
			query = query + ' LIMIT ' +limitCount;
		} 
		system.debug('SOQLQuery.query: '+query);
		return query;
	}	private set;
	}
	
	public SOQLQuery(String myTable) {
		system.debug('SOQLQuery: entry');
		table = myTable;
	}
}