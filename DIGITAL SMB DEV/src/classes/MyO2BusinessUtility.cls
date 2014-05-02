public with sharing class MyO2BusinessUtility {

  public static void showErrorMsg(String msg) {
    system.debug(msg);
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
    ApexPages.addMessage(myMsg);  
   }
  
	public static void checkAccess() {
		if (UserInfo.getUsertype() == 'GUEST') {
            throw new NoAccessException();
		}
	}

   public static String getSobjectFields(String so) {
        String fieldString;
   
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        if (sot == null) return null;
   
        List<Schema.SObjectField> fields = sot.getDescribe().fields.getMap().values();
       
        fieldString = fields[0].getDescribe().LocalName;
        for (Integer i = 1; i < fields.size(); i++) {
            fieldString += ',' + fields[i].getDescribe().LocalName;
        }
        return fieldString;
    }

	// we allow the user to supply csv data in a textarea
	// this method cleans it up before we start processing
	public static final Integer MAX_SOQL_LENGTH = 9500;
    public static String getWhereClauseCondition(String fieldName, String value, Integer charsLeft) {
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
                value += fieldName+' like \'%' + s + '%\'';
                i++;
                if(i!=uniqueSet.size()) value += ' OR ';
            }
            value += ')';
        } else {
            value = ' ('+fieldName+' like \'%'+value+'%\')';
        }
        // just check we did not blow the limit
        if (value.length() > charsLeft) {
        	// TODO: need an exception of the correct type
        	throw new MyO2BusinessTokenException('Query too big');
        }
          
        system.debug('getWhereClause: value: '+value);  
        return value;  
    }
    
    //builds a picklist of values based upon the passed information
    public static List<selectOption> getPickValues(Sobject object_name, String field_name, String first_val) {
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
      if (first_val != null) { //if there is a first value being provided
         options.add(new selectOption(first_val, first_val)); //add the first option
      }
      Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
       Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
         options.add(new selectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
      }
      return options; //return the List
   }
   
   	public static Set<Id> copySetIds(Set<Id> sourceSetOfIds) {
		Set<Id> targetSetOfIds = new Set<Id>();
		for (Id sourceId:sourceSetOfIds) {
			targetSetOfIds.add(sourceId);
		}
		return targetSetOfIds;
	}
   
   
   // maintain a set of NonNull strings.
   // If you try and add an empty sting it is ignored	
   public class NonNullSet {
  		private Set<String> ss;
  		private String nullString;
  		
  		public NonNullSet(String aNullString) {
  			ss = new Set<String>();
  			nullString = aNullString;
  		}
  		
  		public Boolean add(String s) {
  			system.debug('NonNullSet: entry: add: s='+s);
  			Boolean isNew = true;
  			if (isBlank(s) == false) {
	  			if (ss.contains(s) == false) {
	  				ss.add(s);	
	  			} else isNew = false;				
  			}
  			system.debug('NonNullSet: exit: add: isNew='+isNew);
  			return isNew;
  		}				
  		
  		public void remove(String s) {
  			if (isBlank(s) == false) {
  				ss.remove(s);
  			}
  		}
  		
  		private Boolean isBlank(String s) {
            Boolean b = false;
            if (s == null)
            	b = true;
            else if (s.equals(nullString))
                b = true;
            return b;
        }	
   	}

	//----------------------tests----------------------

  	private static testMethod void test() {
  		Test.setCurrentPage(Page.MyO2BusinessHome);
  		MyO2BusinessUtility.showErrorMsg('hello');
  		system.assert(ApexPages.hasMessages());
  	}
  	
  	private static testMethod void test_getSobjectFields() {
  		// test a non-volatile method?
  		String s = MyO2BusinessUtility.getSobjectFields('Contact');
  		system.assert(s!=null);
  	}
  	
  	private static testMethod void test_getWhereClause() {	
		String field = 'field__c';
  		String s0 = '';
  		String s0a = ',';
  		String s1 = 'alpha';
  		String s2 = 'alpha,bravo';
  		String s3 = 'alpha,bravo,charlie';
  		String s3a = 'alpha,bravo,charlie,';
  		String s3b = '\'alpha\',\'bravo\',\'charlie\'';
  		String s3c = 'alpha;bravo;charlie';
  		
  		String es0 = '';
  		String es0a = '';
  		String es1 = ' (field__c like \'%alpha%\')';
  		String es2 = ' (field__c like \'%alpha%\' OR field__c like \'%bravo%\')'; 		
  		String es3 = ' (field__c like \'%alpha%\' OR field__c like \'%charlie%\' OR field__c like \'%bravo%\')'; 
  		String es3a = es3;
  		String es3b = ' (field__c like \'%\'alpha\'%\' OR field__c like \'%\'bravo\'%\' OR field__c like \'%\'charlie\'%\')'; 
  		String es3c = ' (field__c like \'%alpha;bravo;charlie%\')';
  		
  		system.assertEquals(es0, MyO2BusinessUtility.getWhereClauseCondition(field, s0, MAX_SOQL_LENGTH));
  		system.assertEquals(es0a, MyO2BusinessUtility.getWhereClauseCondition(field, s0a, MAX_SOQL_LENGTH));
  		system.assertEquals(es1, MyO2BusinessUtility.getWhereClauseCondition(field, s1, MAX_SOQL_LENGTH));
  		system.assertEquals(es2, MyO2BusinessUtility.getWhereClauseCondition(field, s2, MAX_SOQL_LENGTH));
  		system.assertEquals(es3, MyO2BusinessUtility.getWhereClauseCondition(field, s3, MAX_SOQL_LENGTH));
  		system.assertEquals(es3a, MyO2BusinessUtility.getWhereClauseCondition(field, s3a, MAX_SOQL_LENGTH));
  		system.assertEquals(es3b, MyO2BusinessUtility.getWhereClauseCondition(field, s3b, MAX_SOQL_LENGTH));
  		system.assertEquals(es3c, MyO2BusinessUtility.getWhereClauseCondition(field, s3c, MAX_SOQL_LENGTH));
  		
  		// finally test the too big exception - try to fit the whole where clause in 1 byte!
  		try {
  			String sException = MyO2BusinessUtility.getWhereClauseCondition(field, s3c, 1);
			system.assertEquals('An exception and got a sting', sException);
  		} catch (Exception e) {
  			// this is what we expected!
  			system.assert(true);
  		}
  	}
  	
  	private static testMethod void  test_getPickValues() {
  		Lead l = new Lead();
  		List<SelectOption> opts = MyO2BusinessUtility.getPickValues(l, 'Rating', null);
  		system.debug('opts: '+opts);
  		// should be hot, warm, cold
  		system.assertEquals(3, opts.Size());
  		Integer hot = 0;
  		Integer warm = 0;
  		Integer cold = 0;
  		
  		for (SelectOption so:opts) {
  			if (so.getLabel().equals('Hot'))
  				hot++;
  			if (so.getLabel().equals('Warm'))
  				warm++;
  			if (so.getLabel().equals('Cold'))
  				cold++;  				
  		}
  		
  		system.assertEquals(1, hot);
  		system.assertEquals(1, warm);
  		system.assertEquals(1, cold);
  		
  	}
  	
  	private static testMethod void test_check_access() {
  		User u = TestMyO2BusinessUtility.createPortalUserAccountContact('firstName', 'lastName', 'email@xyz.tc');
  		system.assert(u != null);
  		
  		System.runAs(u) {
  			MyO2BusinessUtility.checkAccess();
  		}
  	}
  	
  	private static testMethod void test_copy_setIds() {
  		User u1 = TestMyO2BusinessUtility.createPortalUserAccountContact('firstName1', 'lastName1', 'email1@xyz.tc');
  		User u2 = TestMyO2BusinessUtility.createPortalUserAccountContact('firstName2', 'lastName2', 'email2@xyz.tc');
  		Set<Id> srcSet = new Set<Id>();
  		srcSet.add(u1.Id);
  		srcSet.add(u2.id);
  		
  		Set<Id> tgtSet = MyO2BusinessUtility.copySetIds(srcSet);
  		system.assert(tgtSet != null);
  		system.assertEquals(tgtSet.size(), srcSet.size());
  		
  		for (Id tgtId:tgtSet) {
  			system.assert(srcSet.contains(tgtId));
  		}  		
  	}
  	
    private static testMethod void test_non_null_set() {
    	NonNullSet nns = new NonNullSet('albert');
    	system.assert(nns != null);
    	
    	// first add returns true, subsequent adds return false as it already exists
        system.assert(nns.add('bertha') == true);
        system.assert(nns.add('bertha') == false);
        system.assert(nns.add('bertha') == false);
        
        system.assert(nns.add('charlie') == true);
        
        // try some empty values
        nns.add(null);
        nns.add('');
        
    	// now remove 
    	nns.remove('charlie');
    	
    }
}