public with sharing class UnifySearchController {

	public List<SelectOption> attSelectList = new List<SelectOption>();
	public static List<SelectOption> operatorSelectList = new List<SelectOption>();
	public static List<SelectOption> logicSelectList = new List<SelectOption>();
	public List<SelectOption> prodDefSelectList = new List<SelectOption>();
	public Id prodDefSelected{get; set;}
	public Map<String, cscfgc__Attribute_Definition__c> attNameMap = new Map<String, cscfgc__Attribute_Definition__c>();
	public Map<Id, List<cscfgc__Attribute_Definition__c>> attsByProdDefs = new Map<Id, List<cscfgc__Attribute_Definition__c>>();

	public String logic {get; set;}
	public List<QueryResult> pagedResults = new List<QueryResult>();

	private final Set<String> numberDataTypes = new Set<String>{'Double', 'Decimal', 'Integer'};

	private final static String STARTS_WITH = 'starts with';
	private final static String ENDS_WITH = 'ends with';
	private final static String CONTAINS = 'contains';
	private final static String NOT_CONTAINS = 'does not contain';

	private final static String LOGIC_AND = 'AND';
	private final static String LOGIC_OR = 'OR';

	static{
		 operatorSelectList.add(new SelectOption('=', 'equals'));
		 operatorSelectList.add(new SelectOption('!=', 'not equals'));
		 operatorSelectList.add(new SelectOption('>', 'greater than'));
		 operatorSelectList.add(new SelectOption('<', 'lower than'));
		 operatorSelectList.add(new SelectOption(STARTS_WITH, STARTS_WITH));
		 operatorSelectList.add(new SelectOption(CONTAINS, CONTAINS));
		 operatorSelectList.add(new SelectOption(NOT_CONTAINS, NOT_CONTAINS));

		 logicSelectList.add(new SelectOption(LOGIC_AND, LOGIC_AND));
		 logicSelectList.add(new SelectOption(LOGIC_OR, LOGIC_OR));
	}

	public UnifySearchController() {
		 criterionList = new List<Criterion>();

         selectedRowIndex = '0';

         List<cscfgc__Attribute_Definition__c> attrDefs = [SELECT
         														Name, cscfgc__Label__c, cscfgc__Data_Type__c,
         														cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name
         												   FROM
         												   		cscfgc__Attribute_Definition__c
         												   WHERE
         												   		cscfgc__Product_Definition__r.cscfgc__Product_Category__r.Name = 'Unify' AND
         												   		cscfgc__Product_Definition__r.cscfgc__Active__c = true AND Unify_Searchable__c = true
         												   ORDER BY cscfgc__Label__c];

		 for(cscfgc__Attribute_Definition__c attDef : attrDefs) {
		 	List<cscfgc__Attribute_Definition__c> attList = attsByProdDefs.get(attDef.cscfgc__Product_Definition__c);
		 	if(attList == null) {
		 		attList = new List<cscfgc__Attribute_Definition__c>();
		 		prodDefSelectList.add(new SelectOption(attDef.cscfgc__Product_Definition__c, attDef.cscfgc__Product_Definition__r.Name));
		 	}
		 	attList.add(attDef);
		 	attsByProdDefs.put(attDef.cscfgc__Product_Definition__c, attList);
		 }

		 if(prodDefSelectList != null && prodDefSelectList.size() > 0) {
		 	addMore();
		 	prodDefSelected = prodDefSelectList[0].getValue();
		 	prodDefChanged();
		 }

	}

	public PageReference prodDefChanged() {
		attSelectList.clear();
		attNameMap.clear();
		for(cscfgc__Attribute_Definition__c attDef : attsByProdDefs.get(prodDefSelected)) {
			attDef.cscfgc__Label__c = (attDef.cscfgc__Label__c != null && attDef.cscfgc__Label__c != '') ? attDef.cscfgc__Label__c : attDef.Name;
			attSelectList.add(new SelectOption(attDef.Name, attDef.cscfgc__Label__c));
			attNameMap.put(attDef.Name, attDef);
		}
		return null;
	}

	public List<SelectOption> getProdDefSelectList() {
		return prodDefSelectList;
	}

	public Boolean getHasResults() {
		return !pagedResults.isEmpty();
	}

	public List<SelectOption> getAttSelectList() {
		return attSelectList;
	}

	public List<SelectOption> getLogicSelectList() {
		return logicSelectList;
	}

	public List<SelectOption> getOperatorSelectList() {
		return operatorSelectList;
	}

	public List<QueryResult> getPagedResults() {
		return pagedResults;
	}

	public Integer getCriteriaSize() {
		return criterionList.size();
	}

	//list of the inner class
	public List<Criterion> criterionList{get;set;}

	public String selectedRowIndex{get;set;}

	//no. of rows added/records in the inner class list
	public Integer counter = 1;
	//{get;set;}

	public PageReference SearchConfigurations()
	{
		pagedResults.clear();
		List<String> whereClauses = createWhereClauses();

		String attSelectQuery = 'SELECT Id, Name, cscfgc__Product_Bundle__r.cscfgc__Opportunity__r.Name, cscfgc__Product_Bundle__r.cscfgc__Opportunity__r.Id, ' +
		      					'cscfgc__Product_Bundle__r.Name, cscfgc__Product_Bundle__r.Id, ' +
		      					'Unify_Site__r.Name, Unify_Site__r.Id, ' +
		      					'(SELECT Id, Name FROM Orders__r), ' +
								'(SELECT Unify_Searchable_Value__c, Name, cscfgc__Product_Configuration__c FROM cscfgc__Attributes__r WHERE ';
		for(String whereClause : whereClauses) {
			attSelectQuery += whereClause + ' OR ';
		}
		attSelectQuery = attSelectQuery.substring(0, attSelectQuery.length() - 4);
		attSelectQuery += ') FROM cscfgc__Product_Configuration__c ' +
						'WHERE cscfgc__Product_Bundle__r.cscfgc__Opportunity__r.RecordType.Name LIKE \'%unify%\' ' +
						'AND cscfgc__Product_Definition__c = \'' + prodDefSelected + '\'';
		system.debug('Query attributes : ' + attSelectQuery);
		List<cscfgc__Product_Configuration__c> attList = Database.query(attSelectQuery);

		List<cscfgc__Product_Configuration__c> resultList = new List<cscfgc__Product_Configuration__c>();
		for(cscfgc__Product_Configuration__c prodConf : attList) {
			List<cscfgc__Attribute__c> atts = prodConf.cscfgc__Attributes__r;
			if(atts != null && logic == LOGIC_AND && atts.size() >= whereClauses.size()) {
				resultList.add(prodConf);
			} else if(atts != null && logic.equals(LOGIC_OR) && atts.size() > 0) {
				resultList.add(prodConf);
			}
		}

		Integer i = 1;
		for(cscfgc__Product_Configuration__c conf : resultList) {
			QueryResult result = new QueryResult(i, conf);
			pagedResults.add(result);
			i++;
		}

		return null;
	}

	private List<String> createWhereClauses() {
		List<String> attWhereClauses = new List<String>();
		for(Criterion criteria : criterionList) {
			String whereClause;
			cscfgc__Attribute_Definition__c attDef = attNameMap.get(criteria.attName);
			if(criteria.operator == CONTAINS) {
				whereClause = '(Name = \'' + criteria.attName + '\' AND Unify_Searchable_Value__c LIKE \'%' + criteria.attValue + '%\')';
			} else if(criteria.operator == NOT_CONTAINS) {
				whereClause = '(Name = \'' + criteria.attName + '\' AND (NOT (Unify_Searchable_Value__c LIKE \'%' + criteria.attValue + '%\')))';
			} else if(criteria.operator == STARTS_WITH) {
				whereClause = '(Name = \'' + criteria.attName + '\' AND Unify_Searchable_Value__c LIKE \'' + criteria.attValue + '%\')';
			} else if(criteria.operator == ENDS_WITH) {
				whereClause = '(Name = \'' + criteria.attName + '\' AND Unify_Searchable_Value__c LIKE \'%' + criteria.attValue + '\')';
			} else {
				if(numberDataTypes.contains(attDef.cscfgc__Data_Type__c)) {
					whereClause = '(Name = \'' + criteria.attName + '\' AND Unify_Searchable_Number_Value__c ' + criteria.operator + ' ' + criteria.attValue + ')';
				} else {
					whereClause = '(Name = \'' + criteria.attName + '\' AND Unify_Searchable_Value__c ' + criteria.operator + ' \'' + criteria.attValue + '\')';
				}

			}
			attWhereClauses.add(whereClause);
		}

		return attWhereClauses;
	}

	//add one more row
	public void Add()
	{
		counter = counter+1;
		addMore();
	}

	public void addMore()
	{
		//call to the iner class constructor
		Criterion objCriterion = new Criterion(counter, '', '', '');

		//add the record to the inner class list
        criterionList.add(objCriterion);
        system.debug('criterionList---->'+criterionList);
    }

	public void Del()
	{
		system.debug('selected row index---->'+selectedRowIndex);
		criterionList.remove(Integer.valueOf(selectedRowIndex)-1);
		counter = counter - 1;
		for(Criterion c : criterionList){
			if(Integer.valueOf(selectedRowIndex) < c.seqNo){
				c.seqNo--;
			}
		}

	}

	public class Criterion
	{
		public Integer seqNo{get;set;}
		public String attName{get;set;}
		public String attValue{get;set;}
		public String operator{get;set;}

		/*Inner Class Constructor*/
		public Criterion(Integer counter, String attName, String attValue, String operator)
		{
			seqNo = counter;
			this.attName = attName;
			this.attValue = attValue;
			this.operator = operator;
		}
	}

	public class QueryResult
	{
		public String seqNo{get;set;}
		public cscfgc__Product_Configuration__c Configuration{get; set;}
		/*Inner Class Constructor*/
		public QueryResult(Integer counter, cscfgc__Product_Configuration__c conf)
		{
			seqNo = String.valueof(counter);
			Configuration = conf;
		}
	}

}