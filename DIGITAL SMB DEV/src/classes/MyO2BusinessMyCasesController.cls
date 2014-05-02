public with sharing class MyO2BusinessMyCasesController {

	public String filterCaseNumbers { get; set; }
	public String filterNumbers { get; set; }
	public String filterRaisedFor { get; set; }
	public String filterDateRange { get; set; } 
	public String filterMyCases { get; set; } 
	public string sortByField {get; set;}
	public string sortByOrder {get; set;}
	public string searchValue {get; set;}    
	public String filterString { get; private set;}
	private List<String> enterpriseExcSubType = new List<String>{'Add/Remove Boltons', 'Bolt on subscriber name'};
	Integer totalPageNumber = 0;    
	public Boolean smbUser{get; set;}

	static final Integer PAGE_SIZE = 10;
	static final string FIELD_LIST = ' id, subject,Origin, casenumber, external_reference__c, contactId, service_request_type__c,Request_Sub_Type__c, mO2b_status__c, createdbyId, createddate';

	String MyCasesPara, AllCasesPara, caseOrigin;
	String allCasesFilterString,myCasesDateQueryStr;

	public string query {get {
		query = 'select '+FIELD_LIST+' from case '+filterString+' order by '+sortByField+' '+getSortByOrder()+' nulls last limit 1000'; 
		system.debug('query: '+query);
		return query;
	} private set;}

	private String paramCType {get; set;}                
	private Boolean casesToDisplay {get; set;}   
	private Boolean allCasesFilterFlag;     

	public MyO2BusinessMyCasesController() {
		paramCType = ApexPages.currentPage().getParameters().get('ctype');
		String paramType = ApexPages.currentPage().getParameters().get('type');
		String paramStatus = ApexPages.currentPage().getParameters().get('status');
		casesToDisplay = true;
		allCasesFilterString = '';

		User userRecord = [SELECT Id, Profile.Name FROM User WHERE Id =:userInfo.getUserId()];
		String userProfile = userRecord.Profile.Name ;
		//if (paramType != null) {

		// init
		sortByField = 'casenumber';
		sortByOrder = 'DESC';
		searchValue = '';
		filterMyCases = '';
		smbUser = CaseUtils.checkLoginUserSegment();

		if(smbUser){
			system.debug('Smb User');
			allCasesFilterFlag = true;
			filterString= ' where Service_Request_Type__c!=null AND Origin = \'Customer Portal\' AND createddate>=LAST_N_DAYS:30';  
		}else {
			system.debug('Not Smb User');
			filterString= ' where Service_Request_Type__c!=null AND Request_Sub_Type__c NOT IN :enterpriseExcSubType AND createddate>=LAST_N_DAYS:30';  
		}
		if(paramType!=null) filterString+= ' AND Request_Sub_Type__c = \'' + String.escapeSingleQuotes(paramType=='None'?'':paramType) + '\'';
		if(paramStatus!=null) filterString+= ' AND mo2b_Status_value__c = \'' + String.escapeSingleQuotes(paramStatus=='None'?'':paramStatus) + '\'';

		allCasesFilterString = filterString;
		/*
            if (processParameter()) {
                if (searchValue != null) {
                search();                       
                }
            } else {*/
		runQuery();
		//}
		//}
	}

	private Boolean processParameter() {
		Boolean doSearch = false;
		if (paramCType != null) {
			if (paramCType.equals('Open')) {
				filterString = 'WHERE mO2b_status__c != \'Closed\' AND mO2b_status__c != \'Waiting on Customer\'';
			} else if (paramCType.equals('In SLA')) {
				// not really supported yet. Just return all
				filterString = 'WHERE mO2b_status__c != \'Closed\' AND mO2b_status__c != \'Waiting on Customer\'';
			} else if (paramCType.equals('Out of SLA')) {
				// not really supported yet. Just return nothing.
				filterString = 'WHERE subject=\'Out of SLA\'';
			} else {
				searchValue = paramCType;
				doSearch = true;
			}
		}
		// don't do it again
		paramCType = null;

		return doSearch;
	}

	// inner class for filter string creation    
	class filter {
		String filter;
		public filter() { 
			system.debug('Constr filter called');
			filter = '';
			system.debug('afetre construc---filter---'+filter);
		}
		public void clear() {
			filter = '';
		}
		public String get() { 
			system.debug('get of filter class before------'+filter);
			if(filter!='') {
				filter = ' where Service_Request_Type__c!=null AND '+filter;
			}
			system.debug('get of after filter class ----'+filter);
			return filter; 
		}
		public void add(String input) {
			system.debug('filter.add: filter: '+filter);
			system.debug('filter.add: input: '+input);
			if(filter!='') filter+=' AND ';
			filter+=input;
		}
	}

	private enum State {SOQL_INJECTION, DATE_RANGE, CASE_NUMBER, MPN_AND_NAME, MPN, NAMES, CREATED_BY, QUERY_CALL}
	private class ParseFilterException extends Exception {}

	private String parseFilterString (String attr, String source) {
		String value = parseCSVintoWhereClause(attr, source);
		if (value == null) {
			throw new ParseFilterException();
		}
		if (value.equals('')) {
			throw new ParseFilterException();
		}

		return value;
	}

	// run filter
	public PageReference advancedFilter() {
		system.debug('advancedFilter called----query------->'+query);
		allCasesFilterFlag = false;
		MyCasesPara = '';
		AllCasesPara ='';
		myCasesDateQueryStr = '';

		MyCasesPara = ApexPages.CurrentPage().getParameters().get('MyCases');
		AllCasesPara = ApexPages.CurrentPage().getParameters().get('AllCases');
		system.debug('AllCasesPara-------------'+AllCasesPara);
		system.debug('MyCasesPara-------------'+MyCasesPara);

		State myState = State.SOQL_INJECTION;
		String part = null;
		try {
			if(AllCasesPara == 'AllCases'){
				system.debug('allCasesFilterString-------------------->'+allCasesFilterString);
				filterString = allCasesFilterString;
			} else if(MyCasesPara == 'MyCases'){
				MyO2BusinessUser businessUser = new MyO2BusinessUser();
				Id userId = businessUser.getUserId();
				filterString = allCasesFilterString + ' AND CreatedBy.Id = \'' +  userId+'\'';
				system.debug('myCasesFilterString-------------------->'+filterString);
			}else{
				filter f = new filter();

				// Prevent SOQL injection
				String filterDateRangeStr = String.escapeSingleQuotes(filterDateRange); 
				String filterRaisedForStr = String.escapeSingleQuotes(filterRaisedFor);
				String filterNumbersStr = cleanNumbers(String.escapeSingleQuotes(filterNumbers));
				String filterCaseNumbersStr = cleanNumbers(String.escapeSingleQuotes(filterCaseNumbers));

				system.debug('filterDateRange---'+filterDateRange);
				system.debug('filterRaisedFor---'+filterRaisedFor);
				system.debug('filterNumbers---'+filterNumbers);
				system.debug('filterNumbers---'+filterNumbers);
				if(smbUser){
					f.add(' Origin = \'Customer Portal\'');
				} else {
					f.add(' Request_Sub_Type__c NOT IN :enterpriseExcSubType');
				}
				f.add(' Service_Request_Type__c!=null ');
				myState = State.DATE_RANGE;         
				// parse dates
				if(filterDateRangeStr!='') {
					//if(filterString!='') filterString+=' AND ';
					List<String> dates = filterDateRangeStr.trim().split('-');
					// validate dates
					for(String dt: dates) {
						Date d = date.valueOf(dtParse(dt));
					}
					if(dates.size()==2) {
						f.add('createdDate >= ' + dtParse(dates[0]) + 'T00:00:00Z' + 
								' AND createdDate <= ' + dtParse(dates[1]) + 'T23:59:59Z');
						myCasesDateQueryStr = 'createdDate >= '+dtParse(dates[0])+ 'T00:00:00Z' + 
							' AND createdDate <= ' + dtParse(dates[1]) + 'T23:59:59Z';
					} else {
						f.add('createdDate >= ' + dtParse(filterDateRangeStr.trim()) + 'T00:00:00Z' +
								' AND createdDate <= ' + dtParse(filterDateRangeStr.trim()) + 'T23:59:59Z');
						myCasesDateQueryStr = 'createdDate >= ' + dtParse(filterDateRangeStr.trim()) + 'T00:00:00Z' +
							' AND createdDate <= ' + dtParse(filterDateRangeStr.trim()) + 'T23:59:59Z';
					}

					system.debug('$$$VALUE myCasesDateQueryStr ---'+myCasesDateQueryStr);
				}
				String filterBuilder = '';
				if (filterRaisedForStr!='') {
					myState = State.NAMES;
					filterBuilder += parseFilterString('ac_subscription__r.Subscription_Name__c',filterRaisedForStr);
				}
				if (filterNumbersStr!='') {
					myState = State.MPN;
					if (filterBuilder != '') {
						filterBuilder += ' AND ';
					}
					filterBuilder += parseFilterString('ac_subscription__r.Network_Serial_No__c',filterNumbersStr);
				}
				if (filterCaseNumbersStr !='') {
					if (filterBuilder != '') {
						filterBuilder += ' AND ';
					}
					myState = State.CASE_NUMBER;
					filterBuilder += parseFilterString('case__r.caseNumber',filterCaseNumbersStr);
				}
				if (filterBuilder != '') {
					filterBuilder = ' Id in (select case__c from mo2b_CaseLineItem__c where ' + filterBuilder + ')';
					f.add(filterBuilder);
				}
				
				myState = State.QUERY_CALL;       
				filterString = f.get();
				system.debug('filterString::::::: '+filterString);
			}
			runQuery();  
		} catch (Exception ex) {
			String msg = 'Problem building filter';
			if (myState == State.DATE_RANGE) {
				msg = 'Date or date range not in a valid date format';
			} else if (myState == State.CASE_NUMBER) {
				msg = 'Service Request not in a valid number format';
			} else if (myState == State.MPN_AND_NAME) {
				msg = 'Mobile Phone Number or Subscriber not in a valid format';
			} else if (myState == State.MPN) {
				msg = 'Mobile Phone Number not in a valid phone number format';
			} else if (myState == State.NAMES) {
				msg = 'Subscriber not in a valid string format';
			} else if (myState == State.CREATED_BY) {
				msg = 'Created By not in a valid string format';                
			} else if (myState == State.QUERY_CALL) {
				msg = 'Problem executing query for specified filter';
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,msg));
		}                   
		return null;
	}  

	private void runQuery() {
		if(query.length()>10000) {
			//Display or handle error of query string > 10k characters
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The filter has too many filter items, please refine your query and try again.'));
		}
		system.debug('query in runquery method----------'+query);
		con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
		con.setPageSize(PAGE_SIZE);  
		system.debug('runQuery con.getResultSize()------'+con.getResultSize());
		casesToDisplay = (con.getResultSize() > 0);    
	}

	public PageReference clearFilter() {
		filterRaisedFor='';
		filterNumbers='';
		filterCaseNumbers='';
		advancedFilter();
		return null;
	}

	public PageReference search() {

		try {     
			Id caseCreatedById;
			system.debug('searchValue------'+searchValue);  

			String value, finalSearchVal;
			if(searchValue.contains('/')){
				value = searchValue;
			}
			if(value != null){
				String[] splittedVal = value.split(' ');
				for (String val : splittedVal){
					if(val.contains('/')){
						finalSearchVal = val;
					}
				}
			}
			if(finalSearchVal != null){
				searchValue =  finalSearchVal;
			}  
			if (searchValue != null) {
				searchValue = searchValue.trim();
			}
			System.debug('cases search search value final = ' + finalSearchVal);
			system.debug('search method AllCasesPara-------------'+AllCasesPara);
			system.debug('search method MyCasesPara-------------'+MyCasesPara);
			system.debug('myCasesDateQueryStr------'+myCasesDateQueryStr);
			caseOrigin = '';
			//if(AllCasesPara != null || allCasesFilterFlag){
			Date createdDateRange1 = null;
			Date createdDateRange2 = null;
			String stdFilter = ' AND Service_Request_Type__c!=null ';
			caseOrigin = 'Customer Portal';
			if(smbUser){
				stdFilter = ' AND Service_Request_Type__c!=null AND Origin =: caseOrigin';
			} else {
				stdFilter = ' AND Service_Request_Type__c!=null AND Request_Sub_Type__c NOT IN :enterpriseExcSubType';
			}
			Date lowRangeDate = Date.today().addDays(-30);
			String dateFilter = '';
			if(MyCasesPara != null){
				system.debug('Insidde search method MyCasesPara chk');
				String filterDateRangeStr = String.escapeSingleQuotes(filterDateRange); 
				System.debug('my cases search - filter date range string=' + filterDateRangeStr);
				if(filterDateRangeStr!='') {
					List<String> dates = filterDateRangeStr.trim().split('-');
					for(String dt: dates) {
						Date d = date.valueOf(dtParse(dt));
					}

					if(dates.size()==2) {
						createdDateRange1 = Date.valueOf(dtParse(dates[0]));
						createdDateRange2 = Date.valueOf(dtParse(dates[1]));
						// f.add('DAY_ONLY(createdDate)>='+dtParse(dates[0])+' AND DAY_ONLY(createdDate)<='+dtParse(dates[1]));
					} else {
						createdDateRange1 = Date.valueOf(dtParse(filterDateRangeStr.trim()));
						// f.add('DAY_ONLY(createdDate)='+dtParse(filterDateRangeStr.trim()));
					}

					system.debug('$$$VALUE myCasesDateQueryStr ---'+myCasesDateQueryStr);
				}

				caseCreatedById = UserInfo.getUserId();

				if(createdDateRange1 != null){
					if(createdDateRange2 != null){
						system.debug('Inside if condtn of createdDateRange2 ');
						dateFilter = ' and createdDate >= :createdDateRange1 and createdDate <= :createdDateRange2';
					}else{
						system.debug('Inside else of createdDateRange2 if condtn');
						dateFilter = ' and createdDate >= :createdDateRange1';
					}
				}
				system.debug('Inside MyCasesPara chk---');
			} else{
				dateFilter = ' and createdDate >= :lowRangeDate';
				system.debug('Inside else of mycasespara chk, searchValue = ' + searchValue);
			}

			List<Case> newSearchList = new List<Case>();
			String wildcardSearchValue = '%' + searchValue + '%';
			String searchString = 'SELECT Id FROM Case ' +
			'WHERE (CaseNumber LIKE :wildcardSearchValue ' + 
			'OR External_Reference__c LIKE :wildcardSearchValue ' +
			'OR CreatedBy.Name LIKE :wildcardSearchValue ' +
			'OR Service_Request_Type__c LIKE :wildcardSearchValue ' +
			'OR Request_Sub_Type__c LIKE :wildcardSearchValue ' + 
			'OR Status LIKE :wildcardSearchValue ' +
			'OR Subject LIKE :wildcardSearchValue)' + 
			stdFilter + dateFilter; 
			System.debug('my cases search - query = ' + searchString);
			newSearchList = Database.query(searchString);
			Set<Id> filteredCases = new Set<Id>();
			for (Case c: newSearchList){
				filteredCases.Add(c.Id);
			}

			String[] splitDateTime = searchValue.split(' ');
			String[] splittedDate = splitDateTime[0].split('/');
			Integer date0 = 0;
			Integer date1 = 0;
			Integer date2 = 0;
			System.debug('cases search, splittedDate = ' + splittedDate);
			if (splittedDate.size() == 1) {
				System.debug('cases search, splitted size = 1');
				try {
					date0 = Integer.valueOf(splittedDate[0]);  
					searchString = 'SELECT Id FROM Case ' + 
					'WHERE (CALENDAR_YEAR(CreatedDate) =:date0 ' +
					'OR CALENDAR_MONTH(CreatedDate) =:date0 ' +
					'OR DAY_IN_MONTH(CreatedDate) =:date0)' + 
					stdFilter + dateFilter;
					System.debug('my cases search - query = ' + searchString);
					newSearchList = Database.query(searchString);
				}
				catch (Exception e){}
			}

			if (splittedDate.size() == 2) {
				System.debug('cases search, splitted size = 2');
				try {
					date0 = Integer.valueOf(splittedDate[0]);
					date1 = Integer.valueOf(splittedDate[1]);
					searchString = 'SELECT Id FROM Case ' + 
					'WHERE DAY_IN_MONTH(CreatedDate) = :date0 ' +
					'AND CALENDAR_MONTH(CreatedDate) = :date1' +
					stdFilter + dateFilter;
					System.debug('my cases search - query = ' + searchString);
					newSearchList = Database.query(searchString);
				}
				catch (Exception e){}
			}

			if (splittedDate.size() == 3) {
				System.debug('cases search, splitted size = 3');
				try {
					date0 = Integer.valueOf(splittedDate[0]);
					date1 = Integer.valueOf(splittedDate[1]);
					date2 = Integer.valueOf(splittedDate[2]);
					searchString = 'SELECT Id FROM Case ' + 
					'WHERE DAY_IN_MONTH(CreatedDate) =:date0 ' +
					'AND CALENDAR_MONTH(CreatedDate) =:date1 ' +
					'AND CALENDAR_YEAR(CreatedDate) =:date2' + 
					stdFilter + dateFilter;
					System.debug('my cases search - query = ' + searchString);
					newSearchList = Database.query(searchString);
				}
				catch (Exception e){}
			}

			for (Case c: newSearchList){
				filteredCases.Add(c.Id);
			}

			system.debug('filtered cases----'+filteredCases);
			system.debug('filtered cases size----'+filteredCases.size());
			casesToDisplay = (filteredCases.Size() > 0);
			if (casesToDisplay) {
				filterString = 'where id in (';
				Boolean firstId = true;
				for(String s: filteredCases) {
					if (firstId) {
						firstId = false;
					} else {
						filterString += ',';
					}
					filterString += '\''+ s + '\'';
				}    
				filterString += ')'; 
				system.debug('$$$$$$filterString--------'+filterString); 
				runQuery();
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_NO_ROWS_FOUND));                   
			}

		} catch(Exception e) {
			System.debug('search exception: ' + e.getMessage());
			System.debug('search exception: ' + e.getStackTraceString());

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.MO2B_MIN_SEARCH_STRING_LENGTH));
		}    
		return null;
	}      

	private static String cleanNumbers (String numbers) { 
		// replace new line and return characters with a comma, as pasting from excel uses the new line character as a separator
		numbers = numbers.replaceAll('\n|\r',','); 
		// remove non digits except commas  
		Pattern numberPattern = Pattern.compile('[^\\d,]');
		String pnumber = numberPattern.matcher(numbers).replaceAll('');
		return pnumber;   
	}

	private static String dtParse(String inDate) {
		String outDate= '';
		for(String dtpt : inDate.trim().split('/')) {
			outDate = dtpt +'-'+ outDate;
		}
		outDate = outDate.substring(0,outDate.length()-1);

		return outDate;    
	}   

	private static String parseCSVintoWhereClause(String fieldName, String value) {
		// replace new line and return characters with a comma, as pasting from excel uses the new line character as a separator
		value = value.replaceAll('\n|\r',',');    
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
				value += fieldName+' like \'%' + s.trim() + '%\'';
				i++;
				if(i!=uniqueSet.size()) value += ' OR ';
			}
			value += ')';
		} else {
			value = ' ('+fieldName+' like \'%'+value.trim()+'%\')';
		}  
		return value;  
	}

	private void initSearch() {
		// init
		sortByField = 'casenumber';
		sortByOrder = 'DESC';
		searchValue = '';
		filterMyCases = '';
		filterString= ' where Service_Request_Type__c!=null && createddate>=LAST_N_DAYS:30';          
	}     

	private ApexPages.StandardSetController getController() {
		initSearch();
		ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
		con.setPageSize(PAGE_SIZE);
		system.debug('getController method--con.getResultSize()--------------'+con.getResultSize());	
		return con;    
	}

	private String getSortByOrder() {
		return sortByOrder;
	}

	public PageReference sort() {
		if(sortByOrder=='desc') {
			sortByOrder='ASC';
		} else {
			sortByOrder='DESC';
		}  
		con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
		con.setPageSize(PAGE_SIZE);            
		system.debug('sort method con.getResultSize()--------------------------------'+con.getResultSize());
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

	public List<case> getCases() {
		List<case> caseList = null;
		if (casesToDisplay) {
			caseList = new List<case>();
			system.debug('getCases method con.getResultSize()------------------'+con.getResultSize());
			caseList = (List<Case>)con.getRecords();  
			system.debug('after caseList------'+caseList.size());          
		} else {
			caseList = new List<Case>();
		}
		return caseList;
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

	// returns the previous page of  records
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
		return ((con.getPageNumber()-1) * PAGE_SIZE)+1;
	}

	public Integer getRangeEnd() {
		Integer endRange = con.getPageNumber() * PAGE_SIZE;
		if(endRange>con.getResultSize()) endRange=con.getResultSize();
		return endRange;
	}

	// returns the total number of pages for pagination
	public Integer getTotalPageNumber() {
		// if we have no cases to display, ensure we don't accidentally do a search with no filter.
		// we need to show the pagination for zero pages
		if (casesToDisplay) {
			integer resultSize = con.getResultSize();
			totalPageNumber = resultSize / PAGE_SIZE;
			Integer mod = resultSize - (totalPageNumber * PAGE_SIZE);
			if (mod > 0)
				totalPageNumber++;
		} else {
			totalPageNumber = 0;
		}
		return totalPageNumber;
	}      

	/* ---------------------- test methods ---------------------- */
	/*
    private static List<Case>caseListAdded;

    private static mo2b_Subscription__c createSubscriber(Account acc, String username, Integer index) {
        String psn = '99'+index;
        mo2b_Subscription__c s = new mo2b_Subscription__c(account__c=acc.id, primarySerialNumber__c=psn, 
                                                          username__c=username, subscriptionId__c=psn);
        //insert s;
        return s;
    }

    private static mo2b_CaseLineItem__c createCaseLineItem(Id cId, Id sId, Integer index) {
        mo2b_CaseLineItem__c cli = new mo2b_CaseLineItem__c(Suspend__c=true, mo2b_subscription__c=sId, 
                                                            New_SIM_Number__c='99',Case__c=cId);
        //insert cli;
        return cli;
    }

    private static Case createCase(Account acc, String subj, String descrip, String sts, Integer index) {
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

    private static void createCases(Account acc) {
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

    private static void test_summary(String ctype, Integer expectedCount) {
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

    private static testmethod void test_summary_open() {
        // 5 - closed - waiting on customer = 3
        test_summary('Open',3);
    }

    private static testmethod void test_summary_in_SLA() {
        // 5 - closed - waiting on customer = 3
        test_summary('In SLA',3);
    }

    private static testmethod void test_summary_out_of_SLA() {
        // Out of SLA not yet supported so it is always currently 0
        test_summary('Out of SLA',0);
    }

    private static testmethod void test_summary_something_random() {
        // return all (i.e. 5) for a paramater value we don't know
        test_summary('Waiting on Customer',5);
    }
    private static testmethod void test_summary_waiting_on_customer() {
    }

    private static void test_advanced_filter(MyO2BusinessMyCasesController con, Date dStart, Date dEnd, Integer numCaseNumbers, String numbers, String raisedFor, Integer expected, Boolean bInvalidDate) {
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
            // the test can only be executed when we expect some data
            // if we don't expect data then we test whether we got an error
            if (expected != -1) {
                system.assertEquals(expected, con.getTotalResultSize());                        
                system.assertEquals(false, ApexPages.hasMessages());
            }
            else {
                system.assertEquals(true, ApexPages.hasMessages());
            }
        } catch (Exception e) {
            // check we expected an exception, if not then throw an error
            system.assertEquals(-1, expected);

        }


    }

    private static testmethod void test_main() {
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
                system.assertEquals(5, con.getTotalResultSize());

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
                system.assertEquals(5, con.getTotalResultSize());

                // TODO
                // filterMyCases
                // exceptions in advancedFilter

                con.searchValue = 'Waiting on Customer';            
                con.search();
                con.searchValue = '99';         
                con.search();
            }
            Test.StopTest();

    }*/

}