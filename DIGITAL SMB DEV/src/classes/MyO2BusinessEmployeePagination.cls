public with sharing class MyO2BusinessEmployeePagination {
	//
	// Member Variables
	//
	
	// The Standard Set Controller that handles the subscription pagination
	private MyO2BusinessPagination psc {get; set;}  

	// The parameters passed into constructor
	public Integer pageSize {get; set;}

	// The Ids of the subscriptions that have been selected in the UI
	public Integer employeesSelectedCount {get {
		return selectedIds.Size(); 
	} private set;}
	public Set<Id> selectedIds {get {
		if (selectedIds == null) {
			selectedIds = new Set<Id>();
		}
		return selectedIds;
	} private set;}
	
	// the CaseLineItems for all the selected employee rows
	public Map<Id, List<mo2b_CaseLineItem__c>> storedClis {get {
		if (storedClis == null) {
			storedClis = new  Map<Id, List<mo2b_CaseLineItem__c>>();
		}
		return storedClis;	
	} set;}
	
	private Boolean useCli {get; set;}
	
	// The combo boxes to show against each subscriber
	private Map<Id, List<SelectOption>> availableOptions {get {
		if (availableOptions == null) {
			availableOptions = new Map<Id, List<SelectOption>>();
		}
		return availableOptions;	
	} set;
	}
		
	private List<SelectOption> defaultAvailableOptions {get; set;}

	private List<MyO2BusinessServiceRequestController.EmployeeWrapper> ewl {get {
		if (ewl == null) {
			ewl = new List<MyO2BusinessServiceRequestController.EmployeeWrapper>();
		}
		return ewl;
	} set;} 

	// track any unique data and ensure it remains unique
	private MyO2BusinessUtility.NonNullSet uniqueDataForClis {get; set;}
	
	//
	// Code
	//	
	public MyO2BusinessEmployeePagination(String query, Integer aPageSize, List<SelectOption> defaultOptions, Boolean singleCaseLineItemWizard) {
		system.debug('MyO2BusinessEmployeePagination: entry');
		pageSize = aPageSize;
		
		psc = new MyO2BusinessPagination(query, pageSize);
		defaultAvailableOptions = defaultOptions;
		useCli = singleCaseLineItemWizard;
	}

	public MyO2BusinessEmployeePagination(String query, Integer aPageSize, List<SelectOption> defaultOptions, Boolean singleCaseLineItemWizard, Set<Id> previousSelections) {
		system.debug('MyO2BusinessEmployeePagination: entry: with selectedIds');
		pageSize = aPageSize;
		
		psc = new MyO2BusinessPagination(query, pageSize);
		defaultAvailableOptions = defaultOptions;
		useCli = singleCaseLineItemWizard;
		if (previousSelections != null) {
			selectedIds = MyO2BusinessUtility.copySetIds(previousSelections);
		}
	}

	
	public List<MyO2BusinessServiceRequestController.EmployeeWrapper> getRecords() {
		// create empty result
		ewl = new List<MyO2BusinessServiceRequestController.EmployeeWrapper>();

		// get the page of results
		List<mo2b_Subscription__c> ewList = (List<mo2b_Subscription__c>)psc.getRecords();

		// create the wrappers
		Integer i = 0;
		for (mo2b_Subscription__c e:ewList) {
			Boolean sel = selectedIds.contains(e.Id);

			// create the employeewrapper
			MyO2BusinessServiceRequestController.EmployeeWrapper ew = new MyO2BusinessServiceRequestController.EmployeeWrapper(e, sel, i++);			

			// add the available options for this employee
			ew.availableOptions = addAvailableOptions(e.Id);
                        
			// add the case line items for this employee
			ew.clis = getCaseLineItem(e.Id);
			
			// make the first in the list the default cli
			if ((ew.clis != null) && (ew.clis.Size() > 0)) {
				ew.cli = ew.clis[0];				
				system.debug('getRecords: existing cli: '+ew.cli);
			} 
			else {
				ew.cli = new mo2b_CaseLineItem__c();
				ew.cli.mO2b_subscription__c = e.Id;
				system.debug('getRecords: new cli: '+ew.cli);
			}
			ewl.add(ew);
		}

		return ewl;
	}
	
	public void storeRecords(List<MyO2BusinessServiceRequestController.EmployeeWrapper> ewl) {
		// iterate through the current page
		for (MyO2BusinessServiceRequestController.EmployeeWrapper ew:ewl) {
			// check that the pointers are non null
			if ((ew.employee != null) && (ew.employee.Id !=null)) {
				system.debug('ew: id: '+ew.employee.Id+' selected: '+ew.selected + ' cli.start_date__c: '+ ew.cli.start_date__c);
				if (ew.selected) {
					// if selected add to set
					selectedIds.add(ew.employee.Id);
					// if cli has been touched, then store that also
					addCaseLineItem(ew.employee.Id, ew.clis, ew.cli);
				} else {
					// otherwise remove from set
					selectedIds.remove(ew.employee.Id);
					removeCaseLineItems(ew.employee.Id);
				}
				
				system.debug('selectedIds: '+selectedIds);
			}
		}			
	}
	
	private static final Integer RESULTS_LIMIT = 2000;
	public Boolean tooManyResults {get {
		tooManyResults = false;
		if (psc != null) {
			tooManyResults = psc.tooManyResults;
			/* we may want to limit the list further - if so this is how we do it */
			if (tooManyResults == false) {
				if (psc.getTotalResultSize() > RESULTS_LIMIT) {
					tooManyResults = true;
				}
			}
			/**/
		}
		return tooManyResults;
	} set;}
	
	public void deselectId(Id deselectId) {
		system.debug('deselectId: '+deselectId);
		system.debug('deselectId: before selectedIds count:'+selectedIds.Size());
		system.debug('deselectId: before storedClis count:'+storedClis.Size());
		selectedIds.remove(deselectId);		
		storedClis.remove(deselectId);
		system.debug('deselectId: after selectedIds count:'+selectedIds.Size());
		system.debug('deselectId: after storedClis count:'+storedClis.Size());
	}
	
	// store the CaseLineItem for when the user next looks at this page
	private void addCaseLineItem(Id id, List<mo2b_CaseLineItem__c> clis, mo2b_CaseLineItem__c cli) {
		
		system.debug('addCaseLineItem: entry');
		if (clis == null) {
			system.debug('addCaseLineItem: clis null');
			clis = new List<mo2b_CaseLineItem__c>();
			if (cli != null) {
				system.debug('addCaseLineItem: cli not null');
				if (useCli) {
					system.debug('addCaseLineItem: add cli to clis');
					clis.add(cli);
				}
			} 
		}
		
		system.debug('addCaseLineItem: clis: '+clis);
		system.debug('add: before storedClis count:'+storedClis.Size());
		storedClis.put(id, clis);
		system.debug('add: after storedClis count:'+storedClis.Size());
	}
	
	private void removeCaseLineItems(Id id) {
		storedClis.remove(id);		
	}
	
	private List<mo2b_CaseLineItem__c> getCaseLineItem(Id id) {
		List<mo2b_CaseLineItem__c> clis = storedClis.get(id);
		
		return clis;
	}
	
	// take all the selected Id's and produce a string 'Id IN('xyz','abc')' for all the Id's that have been selected 
	public String getIdInClause() {
		String s = null;
		if (selectedIds.Size() > 0) {
			Boolean first = true;
			s = 'Id IN (';
			for (Id id:selectedIds) {
				if (first) {
					first = false;
				} else {
					s = s + ',';
				}
				s = s + '\''+id+'\'';
			}
			s = s + ')';			
		}
		return s;
	}
	
	public MyO2BusinessServiceRequestController.EmployeeWrapper getEmployeeById(Id id) {
		MyO2BusinessServiceRequestController.EmployeeWrapper result = null;
		try {
			for (MyO2BusinessServiceRequestController.EmployeeWrapper ew:ewl) {
				if (ew.employee.Id == id) {
					result = ew;
					break;
				}
			}			
		} catch (Exception e) {
			system.debug('Exception looking for Id in Employees: '+e);
		}
		
		return result;
	}
	
	public void newQuery(String newSqlQuery) {
		psc = new MyO2BusinessPagination(newSqlQuery, pageSize);
	}
	
    // returns the page number of the current page set
    public Integer getPageNumber() {
        return psc.getPageNumber();
    }
 
    // returns the first page of records
    public void first() {
        psc.first();
    }
 
    // returns the last page of records
    public void last() {
        psc.last();
    }
 
    // returns the previous page of records
    public void previous() {
        psc.previous();
    }
 
    // returns the next page of records
    public void next() {
        psc.next();
    }   
    
	// get the total result size
    public Integer getTotalResultSize() {
        return psc.getTotalResultSize();
    }
    
    // get the range start
    public Integer getRangeStart() {
        return psc.getRangeStart();
    }
    
    // get the range end
    public Integer getRangeEnd() {
        return psc.getRangeEnd();
    }    

	// get total number of pages
    public Integer getTotalPageNumber() {
       	return psc.getTotalPageNumber();
    } 	
	
	// private helper methods
	private List<SelectOption> addAvailableOptions(Id id) {
		List<SelectOption> optionList;
		
		if (availableOptions.containsKey(id)) {
			optionList = availableOptions.get(id);
		} else {
			// does not have one, so create
			optionList = defaultAvailableOptions.clone();
		}
		return optionList;
	}
	
	// this method looks at the clis for uniqueness
	private void lookAtClisForUniqueness(Integer op) {
		uniqueDataForClis = new MyO2BusinessUtility.NonNullSet('<>');

		// load the set with the current storedClis
        List<List<mo2b_CaseLineItem__c>> cliListList = storedClis.values();
        for (List<mo2b_CaseLineItem__c> cliList:cliListList) {
            for (mo2b_CaseLineItem__c cli:cliList) {
				String s = makeUniqueString(op,cli);
				if (uniqueDataForClis.add(s) == false) {
					throw new MyO2BusinessTokenException(MyO2BusinessTokenException.Reason.INVALID,'Value must be unique: '+s);
				}
            }
        }
 	}
	
	// what I expect to do here is to make a string of the form <cat|sat|mat>
	// currently we're only interested in New_SIM_Number__C but this needs extending as more unique strings are needed
	private String makeUniqueString(Integer op, mo2b_CaseLineItem__c cli) {
		String s = '';
		// NOT QUITE YET
		//if (op == MyO2BusinessServiceRequestController.OP_SIM_SWAP) {
		//	s = ((cli.New_SIM_Number__c != null) ? cli.New_SIM_Number__c : '');
		//}
		return '<' + s + '>';
	}
	
	// test methods
	static final String OUR_TARIFF = 'OOOOH';
	static final Integer DML_UB = 10000;
	
	static void createSubscriptions(Integer c) {
		Account acc = new Account(Name='test acc');
		insert acc;

		List<mo2b_Subscription__c> subs = new List<mo2b_Subscription__c>();
		for (Integer i=0; i<c; i++) {
			mo2b_Subscription__c s = new mo2b_Subscription__c();
			s.tariffCode__c = OUR_TARIFF;
			s.Account__c = acc.id;
			s.subscriptionId__c = '6669'+i;
			// need to avoid the DML 10,000 limit
			if (i < DML_UB - 1) {
				subs.add(s);
			} 
		}
		insert subs;
	}

	static List<SelectOption> createOptions(Integer c) {
		List<SelectOption> opts = new List<SelectOption>();
		for (Integer i=0; i<c; i++) {
			String s1 = 'opt' + i;
			SelectOption so = new SelectOption(s1,s1);
			opts.add(so);
		}
		
		return opts;
	}

	static void subsCheck(List<MyO2BusinessServiceRequestController.EmployeeWrapper> ewl, Integer base, Integer pageSize, MyO2BusinessEmployeePagination ep, Integer pageNum) {
		system.assertEquals(pageNum, ep.getPageNumber());
		system.assertEquals(base+1, ep.getRangeStart());
		system.assertEquals(base+pageSize, ep.getRangeEnd());
		system.assert(ewl != null);
		system.assertEquals(pageSize, ewl.Size());
		
		Integer x = base;
		for (MyO2BusinessServiceRequestController.EmployeeWrapper ew:ewl) {
			system.debug('ew: '+ew);
			system.assert(ew.employee != null);
			//system.assertEquals('6669'+x, ew.employee.subscriptionId__c);
			x++;
		}
	}

	static void test_it(Integer subCount) {
		createSubscriptions(subCount);

		// query by CreatedDate so we get them back in the order we created them
		String query = 'Select '+MyO2BusinessUtility.getSobjectFields('mo2b_Subscription__c')+' From mo2b_Subscription__c m WHERE m.tariffCode__c=\''+OUR_TARIFF+'\' ORDER BY m.CreatedDate ASC';
		if (subCount > RESULTS_LIMIT) {
			// sneakily use some existing data
			query = 'Select '+MyO2BusinessUtility.getSobjectFields('mo2b_Subscription__c')+' From mo2b_Subscription__c m ORDER BY m.CreatedDate ASC';
		}

		Integer pageSize = 6;
		Integer optsSize = 4;
		Integer expectedPages = (subCount / pageSize == 0) ? (subCount / pageSize) : (subCount / pageSize) + 1;
		List<SelectOption> defaultOptions = createOptions(optsSize);
		system.assert(defaultOptions != null);
		system.assertEquals(optsSize, defaultOptions.Size());

		MyO2BusinessEmployeePagination ep = new MyO2BusinessEmployeePagination(query, pageSize, defaultOptions, true);
		system.assert(ep != null);

		if (subCount < RESULTS_LIMIT) {
			// expecting 4 pages
			system.assertEquals(expectedPages ,ep.getTotalPageNumber());
			// expecting 20 rows
			system.assertEquals(subCount, ep.getTotalResultSize());
		}
		
		// the first getRecords should always return the first page
		List<MyO2BusinessServiceRequestController.EmployeeWrapper> ewl = ep.getRecords();		

		system.debug('ep.tooManyResults: '+ep.tooManyResults);
		// check for the too many rows problem
		if (subCount > RESULTS_LIMIT) {
			system.assert(ep.tooManyResults == true);
			return;
		} else {
			system.assert(ep.tooManyResults == false);			
		}

		subsCheck(ewl, 0, pageSize, ep, 1);
				
		// let's get the first page using the method
		ep.first();
		subsCheck(ewl, 0, pageSize, ep, 1);
		
		// expecting 3 pages of 6 and 1 page of 2
		ep.next();
		ewl = ep.getRecords();	
		subsCheck(ewl, pageSize, pageSize, ep, 2);
		
		ep.next();
		ewl = ep.getRecords();	
		subsCheck(ewl, pageSize*2, pageSize, ep, 3);

		ep.next();
		ewl = ep.getRecords();	
		subsCheck(ewl, pageSize*3, 2, ep, 4);
		
		// now go the other way
		ep.previous();
		ewl = ep.getRecords();	
		subsCheck(ewl, pageSize*2, pageSize, ep, 3);

		ep.previous();
		ewl = ep.getRecords();	
		subsCheck(ewl, pageSize, pageSize, ep, 2);

		ep.previous();
		ewl = ep.getRecords();	
		subsCheck(ewl, 0, pageSize, ep, 1);
		
		// go last
		ep.last();
		ewl = ep.getRecords();	
		subsCheck(ewl, pageSize*3, 2, ep, 4);		

		// test selection!

		// go first
		ep.first();
		ewl = ep.getRecords();
		
		// select 1 + 2 on page 1
		Id p1Id1 = ewl[1].employee.Id;
		Id p1Id2 = ewl[2].employee.Id;
		ewl[1].selected = true;
		ewl[2].selected = true;
		ep.storeRecords(ewl);
		
		// next page
		ep.next();
		ewl = ep.getRecords();

		// select 2 + 3 on page 2
		Id p2Id2 = ewl[2].employee.Id;
		Id p2Id3 = ewl[3].employee.Id;
		ewl[2].selected = true;
		ewl[3].selected = true;
		ep.storeRecords(ewl);

		// prev page
		ep.previous();
		ewl = ep.getRecords();
		
		// select 2 + 3 on page 1
		Id p1Id3 = ewl[3].employee.Id;
		ewl[1].selected = false;
		ewl[2].selected = true;
		ewl[3].selected = true;
		ep.storeRecords(ewl);
		
		// generate the In clause
		String inClause = ep.getIdInClause();
		system.debug('inClause: '+inClause);

		system.assert(inClause.startsWith('Id IN (\''));
		system.assert(inClause.endsWith('\')'));
		system.assert(inClause.contains(p1Id1) == false);
		system.assert(inClause.contains(p1Id2) == true);
		system.assert(inClause.contains(p1Id3) == true);
		system.assert(inClause.contains(p2Id2) == true);
		system.assert(inClause.contains(p2Id3) == true);
		
	}
	
	static testmethod void test_20() {
		test_it(20);
	}
	
	static testmethod void test_RESULTS_LIMIT() {
		test_it(RESULTS_LIMIT+10);
	}	
}