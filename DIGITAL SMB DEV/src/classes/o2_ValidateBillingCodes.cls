///
///	Name:	o2_ValidateBillingCodes
///
///	Author:
///	Michael Kahle
///	H&W Consult GmbH
///	Bäckerstr. 18
///	21244 Buchholz i.d.N.
///	http://www.hundw.com
///
///	Description:
///	Class to unburden the Validate_Billing_Codes Trigger which had too many rows
///
///	Used Objects: (Objects, StaticResources, Documents)
///	
///
///	Used Classes: (Classes,Trigger,Pages)
///	
///
///	Timeline:
///	Name				DateTime					Description
///	Michael Kahle		2010-02-01 16:15 (GMT+1)	Creation of Class
///

public class o2_ValidateBillingCodes 
{
	private List<RecordType> x_recordTypes;
	private List<Id> x_recordTypeIdList;
	private List<Account_Validation_Table__c> x_mappingRows		=	new List<Account_Validation_Table__c>();
	private List<Account_Validation_Table__c> x_validationRows	=	new List<Account_Validation_Table__c>();
	private List<Account> x_triggerNewList						=	null;
	private Map<Id,Account> x_triggerOldMap						=	null;
	private List<Account> x_existingCodes						=	new List<Account>();
	
	
	
	// Capture the entered codes
    private Set<String> x_codes									=	new Set<String>();    
    // Track errors against triggered account records
    private Set<Id> x_errors									=	new Set<Id>();
    // Note down updates with changes.  We only process updates if one of the billing codes has changed
    private Set<Id> x_notChanged								=	new Set<Id>();
	
	
	// Constructor
	public o2_ValidateBillingCodes(List<Account> p_newList, Map<Id,Account> p_oldMap)
	{
		
		x_triggerNewList		=	p_newList;
		x_triggerOldMap			=	p_oldMap;
		// Capture the relevant record type ids
		x_recordTypes	 		=	[Select Id From RecordType Where SobjectType = 'Account' And Name in ('Qualified Prospect', 'Accounts', 'Customer Account')];
		x_recordTypeIdList 		=	new List<Id>();
		for (RecordType tmp_recType : x_recordTypes) 
		{
			x_recordTypeIdList.add(tmp_recType.Id);
		} // end loop through record types
		
		System.debug('Captured record type ids: ' + x_recordTypeIdList);
	}
	
	public void Run()
	{
		CheckChanged();
		ReadCodes();
		//GetValidationRows();
		CheckExistingCodes();
		CheckForErrors();
		Rest();
	}
	
	private void CheckChanged()
	{
		// If the validation override flag is set, then mark the record as not changed so that
        // no validation will take place
        for (Account tmp_account : x_triggerNewList)//Integer i=0; i<Trigger.new.size();i++) 
        {
        	if (tmp_account.Validation_Override__c) 
        	{
        		x_notChanged.add(tmp_account.Id);
        		System.debug('Validation override has been set on the record: ' + tmp_account);
        	}
        	else 
        	{
        		System.debug('Validation override has NOT been set on the record: ' + tmp_account);
        	}
        } // end loop through accounts
        
        // Mark any unchanged records so we do not bother to process these later on!
        if (Trigger.isUpdate) 
        {
        	System.debug('Trigger is for UPDATE');
            for (Account tmp_account : x_triggerNewList)//Integer i=0; i<Trigger.new.size();i++) {
			{
                // For an updated record, mark as not changed if none of the billing codes have changed (we do not wish to process these)
                if ((x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_1__c == tmp_account.DISE_Group_Code_Account_No_1__c) &&
                    (x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_2__c == tmp_account.DISE_Group_Code_Account_No_2__c) &&
                    (x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_3__c == tmp_account.DISE_Group_Code_Account_No_3__c) &&
                    (x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_4__c == tmp_account.DISE_Group_Code_Account_No_4__c)) 
                {
                    x_notChanged.add(tmp_account.Id);
                    System.debug('Marked as not changed');
                } // end not changed check if
                
                // If this is an update and the user is attempted to change a billing code but the record has already been
                // registered in OAR, then disallow this
                if (x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_1__c != tmp_account.DISE_Group_Code_Account_No_1__c && tmp_account.OAR_Account_Reference_1__c != null &&
                	x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_1__c != null) 
                {
                	tmp_account.DISE_Group_Code_Account_No_1__c 	= x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_1__c;
                	System.debug('Changing back value billing code 1');
                }
                
                if (x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_2__c != tmp_account.DISE_Group_Code_Account_No_2__c && tmp_account.OAR_Account_Reference_2__c != null &&
                	x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_2__c != null) 
                {
                	tmp_account.DISE_Group_Code_Account_No_2__c = x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_2__c;
                	System.debug('Changing back value billing code 2');
                }
                
                if ((x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_3__c != tmp_account.DISE_Group_Code_Account_No_3__c) && 
                	(tmp_account.OAR_Account_Reference_3__c 		!= null) &&
                	(x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_3__c != null)) 
                {
                	tmp_account.DISE_Group_Code_Account_No_3__c = x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_3__c;
                	System.debug('Changing back value billing code 3');
                }
                
                if ((x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_4__c != tmp_account.DISE_Group_Code_Account_No_4__c) && 
                	(tmp_account.OAR_Account_Reference_4__c 		!= null) &&
                	(x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_4__c != null)) 
                {
                	tmp_account.DISE_Group_Code_Account_No_4__c = x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_4__c;
                	System.debug('Changing back value billing code 4');
                }                
            } // end loop through 
        } // end updating check if
	}
	
	private void ReadCodes()
	{
		// Loop through the inserted rows and store the entered codes (ignore for lines flagged as errors)
        // For updates don't need anything special here - just use the new image
        for (Account tmp_account : x_triggerNewList)//Integer i=0; i<Trigger.new.size(); i++) 
        {
            if (!x_errors.contains(tmp_account.Id) && !x_notChanged.contains(tmp_account.Id)) 
            {
                if (tmp_account.DISE_Group_Code_Account_No_1__c != null) 
                {
                    tmp_account.DISE_Group_Code_Account_No_1__c = tmp_account.DISE_Group_Code_Account_No_1__c.toUpperCase();
                    x_codes.add(tmp_account.DISE_Group_Code_Account_No_1__c);
                }
                if (tmp_account.DISE_Group_Code_Account_No_2__c != null)
                {
                    tmp_account.DISE_Group_Code_Account_No_2__c = tmp_account.DISE_Group_Code_Account_No_2__c.toUpperCase();
                    x_codes.add(tmp_account.DISE_Group_Code_Account_No_2__c);
                }
                if (tmp_account.DISE_Group_Code_Account_No_3__c != null)
                {
                    tmp_account.DISE_Group_Code_Account_No_3__c = tmp_account.DISE_Group_Code_Account_No_3__c.toUpperCase();
                    x_codes.add(tmp_account.DISE_Group_Code_Account_No_3__c);
                }
                if (tmp_account.DISE_Group_Code_Account_No_4__c != null)
                {
                    tmp_account.DISE_Group_Code_Account_No_4__c = tmp_account.DISE_Group_Code_Account_No_4__c.toUpperCase();
                   	x_codes.add(tmp_account.DISE_Group_Code_Account_No_4__c);
                }
            }
        } // end loop through triggered accounts
        
        System.debug('Codes list = ' + x_codes);
        
        // Pull back the rows containing available codes that match our codes.
        // Do not do the full table scan if there are no codes in the set !
        
        if (!x_codes.isEmpty()) 
        {
        	System.debug('Querying validation rows');
	        x_mappingRows = [SELECT Group_Code__c, Account__c FROM Account_Validation_Table__c WHERE Account__c in :x_codes ];
        }
        
        System.debug('Rows for mapping billcode to group code = ' + x_mappingRows); 
        
        // Create a map of account number to billing code for those used
        Map <String,String> accToGroup = new Map<String,String>();
        
        // Loop through the validation rows with account or group codes in our set
        for (Account_Validation_Table__c mappingRow : x_mappingRows) 
        {            
            // Loop through our set of discovered codes
            for (String code : x_codes) 
            {                
                // If the discovered code is for this account, then store the group code mapping
                if (code == mappingRow.Account__c) 
                {
                    accToGroup.put(code,mappingRow.Group_Code__c);
                } // end account match      
            } // end loop through codes
        } // end loop through validation rows
                                    
        System.debug('Account to group mapping rows = ' + accToGroup);
                                                                
        // Now we loop through our triggered set again, changing any account numbers with group codes
        // into their group codes - provided they are not flagged with errors.  Nothing special needed 
        // for updates - just use the new image
        for (Account tmp_account : x_triggerNewList)//Integer i=0; i<Trigger.new.size(); i++) 
        {
           
            // Process if no error
            if (!x_errors.contains(tmp_account.Id) && !x_notChanged.contains(tmp_account.Id)) 
            {
                String tmp_corresGroup = accToGroup.get(tmp_account.DISE_Group_Code_Account_No_1__c);
                if (tmp_corresGroup != null) 
                {
                    tmp_account.DISE_Group_Code_Account_No_1__c = tmp_corresGroup;
                    
                    // Ensure the group we changed to is in the set of codes (for further validation)
                    x_codes.add(tmp_corresGroup);
                    System.debug('Changed bill code 1 account no to group code: ');
                } // end check there is an entry if
                
                tmp_corresGroup = accToGroup.get(tmp_account.DISE_Group_Code_Account_No_2__c);
                if (tmp_corresGroup != null) 
                {
                    tmp_account.DISE_Group_Code_Account_No_2__c = tmp_corresGroup;
                    x_codes.add(tmp_corresGroup);
                    System.debug('Changed bill code 2 account no to group code: ');
                } // end check there is an entry if     
                
                tmp_corresGroup = accToGroup.get(tmp_account.DISE_Group_Code_Account_No_3__c);
                if (tmp_corresGroup != null)
                {
                    tmp_account.DISE_Group_Code_Account_No_3__c = tmp_corresGroup;
                    x_codes.add(tmp_corresGroup);
                    System.debug('Changed bill code 3 account no to group code: ');
                } // end check there is an entry if 
                
                tmp_corresGroup = accToGroup.get(tmp_account.DISE_Group_Code_Account_No_4__c);
                if (tmp_corresGroup != null)
                {
                    tmp_account.DISE_Group_Code_Account_No_4__c = tmp_corresGroup;
                    x_codes.add(tmp_corresGroup);
                    System.debug('Changed bill code 4 account no to group code: ');
                } // end check there is an entry if 
            } // end error check if
        } // end loop through the triggered set
        
        System.debug('Altered codes list = ' + x_codes);
	}
/*	
	private void GetValidationRows()
	{
		// Pull back the rows containing available codes that match our codes.  This includes
        // the codes we have manipulated above.  Do not do the query if there are no codes
        
        
        if (!x_codes.isEmpty()) {
        	System.debug('querying validation rows');
        	x_validationRows = [SELECT SF_User_ID__c, Group_Code__c, Account__c FROM Account_Validation_Table__c WHERE Account__c in :x_codes OR Group_Code__c in :x_codes];
        }
        
        System.debug('Validation rows = ' + x_validationRows);
	}
*/	
	private void CheckExistingCodes()
	{
		// Get a list of those accounts/group codes that have been registered already by looking at
        // existing Salesforce account records.  For an update we do not want to look at records in
        // the triggered batch though as we may well find duplicates then !
        List<Id> tmp_existingAccounts = new List<Id>();
        if (Trigger.isUpdate) 
        {
            for (Account rec : x_triggerOldMap.values()) 
            {
                tmp_existingAccounts.add(rec.Id);
            }
        } // end check for trigger update
    
        
        
        if (!x_codes.isEmpty())
        {
        	System.debug('tmp_existingAccounts: ' + tmp_existingAccounts);
        	System.debug('x_codes: ' + x_codes);
        	System.debug('x_recordTypeIdList: ' + x_recordTypeIdList);
        	x_existingCodes = [ Select  	Id,
	                                    DISE_Group_Code_Account_No_4__c,
	                                    DISE_Group_Code_Account_No_3__c,
	                                    DISE_Group_Code_Account_No_2__c,
	                                    DISE_Group_Code_Account_No_1__c
	                            From    Account
	                            Where   Id not in :tmp_existingAccounts
								And 	Status__c = 'Customer'
								And		RecordTypeId in :x_recordTypeIdList
	                            And     ((DISE_Group_Code_Account_No_1__c in :x_codes)
	                            Or      (DISE_Group_Code_Account_No_2__c in :x_codes)
	                            Or      (DISE_Group_Code_Account_No_3__c in :x_codes)
	                            Or      (DISE_Group_Code_Account_No_4__c in :x_codes))];
        }
                        
		System.debug('Existing codes in other accounts: ' + x_existingCodes);
		

	}
	
	private void CheckForErrors()
	{
		// Create a map of those billing codes/group codes that have been used.  If they 
        // are used, they appear with the used account id
        Map <String,Id> codeUsedMap = new Map<String,Id>();
        
        // Loop through triggered account set
        for (Account existingCode : x_existingCodes) 
        {
            if (x_codes.contains(existingCode.DISE_Group_Code_Account_No_1__c))
            {
                codeUsedMap.put(existingCode.DISE_Group_Code_Account_No_1__c,existingCode.Id);
            } // end check 1st DISE code if
            if (x_codes.contains(existingCode.DISE_Group_Code_Account_No_2__c))
            {
                codeUsedMap.put(existingCode.DISE_Group_Code_Account_No_2__c,existingCode.Id);
            } // end check 2nd DISE code if
            if (x_codes.contains(existingCode.DISE_Group_Code_Account_No_3__c)) 
            {
                codeUsedMap.put(existingCode.DISE_Group_Code_Account_No_3__c,existingCode.Id);
            } // end check 3rd DISE code if
            if (x_codes.contains(existingCode.DISE_Group_Code_Account_No_3__c))
            {
                codeUsedMap.put(existingCode.DISE_Group_Code_Account_No_4__c,existingCode.Id);
            } // end check 4th DISE code if
        } // end loop through triggered account set
		
		// Go through adding errors if necessary
        for (Account tmp_account : x_triggerNewList)//Integer i=0; i<Trigger.new.size(); i++) 
        {
            if (!x_errors.contains(tmp_account.Id) && !x_notChanged.contains(tmp_account.Id)) 
            {
                Id usedCodeId = codeUsedMap.get(tmp_account.DISE_Group_Code_Account_No_1__c);
                if (usedCodeId != null) 
                {
                    tmp_account.DISE_Group_Code_Account_No_1__c.addError('Billing code ' + tmp_account.DISE_Group_Code_Account_No_1__c + ' already in use in account ' + usedCodeId);
                    x_errors.add(tmp_account.Id);
                }
                
                usedCodeId = codeUsedMap.get(tmp_account.DISE_Group_Code_Account_No_2__c);
                if (usedCodeId != null) 
                {
                    tmp_account.DISE_Group_Code_Account_No_2__c.addError('Billing code ' + tmp_account.DISE_Group_Code_Account_No_2__c + ' already in use in account ' + usedCodeId);
                    x_errors.add(tmp_account.Id);
                }
                
                usedCodeId = codeUsedMap.get(tmp_account.DISE_Group_Code_Account_No_3__c);
                if (usedCodeId != null) 
                {
                    tmp_account.DISE_Group_Code_Account_No_3__c.addError('Billing code ' + tmp_account.DISE_Group_Code_Account_No_3__c + ' already in use in account ' + usedCodeId);
                    x_errors.add(tmp_account.Id);
                }
                usedCodeId = codeUsedMap.get(tmp_account.DISE_Group_Code_Account_No_4__c);
                if (usedCodeId != null) 
                {
                    tmp_account.DISE_Group_Code_Account_No_4__c.addError('Billing code ' + tmp_account.DISE_Group_Code_Account_No_4__c + ' already in use in account ' + usedCodeId);
                    x_errors.add(tmp_account.Id);
                }
            }
        } // end loop through triggered batch
    
        System.debug('Error list = ' + x_errors);
	}
	
	private void Rest()
	{
		// Create a set of the matching values with the corresponding Salesforce user
        Map<String,String> validCodes		= new Map<String,String>();
        Map<String,Boolean> codeTypeGroup	= new Map<String,Boolean>();
    
        if (!x_codes.isEmpty()) 
        {
        	System.debug('querying validation rows');

	        for (List<Account_Validation_Table__c> validationTableList : [SELECT SF_User_ID__c, Group_Code__c, Account__c FROM Account_Validation_Table__c WHERE Account__c in :x_codes OR Group_Code__c in :x_codes]) 
	        {
		    	for(Account_Validation_Table__c validationRow : validationTableList) 	
		    	{      
		            for (String code : x_codes) 
		            {
		                if (code == validationRow.Group_Code__c) 
		                {
		                    if (validationRow.SF_User_ID__c != null) validCodes.put(code,validationRow.SF_User_ID__c);
		                    codeTypeGroup.put(code,true);
		                } // end group code match   
		                	
		                if (code == validationRow.Account__c) 
		                {
		                    if (validationRow.SF_User_ID__c != null) validCodes.put(code,validationRow.SF_User_ID__c);
		                    codeTypeGroup.put(code,false);
		                } // end account match      
		            } // end loop through codes
		    	}
	        } // end loop through validation rows        
        }
     
/*
        for (Account_Validation_Table__c validationRow : x_validationRows) 
        {
            for (String code : x_codes) 
            {
                if (code == validationRow.Group_Code__c) 
                {
                    if (validationRow.SF_User_ID__c != null) validCodes.put(code,validationRow.SF_User_ID__c);
                    codeTypeGroup.put(code,true);
                } // end group code match   
                
                if (code == validationRow.Account__c) 
                {
                    if (validationRow.SF_User_ID__c != null) validCodes.put(code,validationRow.SF_User_ID__c);
                    codeTypeGroup.put(code,false);
                } // end account match      
            } // end loop through codes
        } // end loop through validation rows
*/
        
        System.debug('Values to Salesforce User Id = ' + validCodes);
        System.debug('Type of codes = ' + codeTypeGroup);
        
        // Loop through the triggered set.  If the code is not found in our map, then
        // mark it as invalid.  Raise an error if it has already been registered too
        for (Account tmp_account: x_triggerNewList)//Integer i=0; i<Trigger.new.size();i++)
        {
            if (!x_errors.contains(tmp_account.Id) && !x_notChanged.contains(tmp_account.Id)) 
            {
                Boolean isGroup;
                if (tmp_account.DISE_Group_Code_Account_No_1__c != null) 
                {
                    isGroup = codeTypeGroup.get(tmp_account.DISE_Group_Code_Account_No_1__c);
                    if (isGroup == null) {
                        tmp_account.DISE_Group_Code_Account_No_1__c.addError(Label.NOT_VALID_ACC_GROUP);
                        x_errors.add(tmp_account.Id);
                    } // end group null check if
                    else 
                    {
                        
                        // Raise error if this has been registered - i.e an email exists in the validation table 
                        // If this code has not changed (in an update) then do not do this check because if successfully
                        // registered, an email will now exist in the validation table
                        if (Trigger.isInsert || (tmp_account.DISE_Group_Code_Account_No_1__c != x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_1__c)) 
                        {
	                        String userName = validCodes.get(tmp_account.DISE_Group_Code_Account_No_1__c);
	                        if (userName != null) 
	                        {
	                            tmp_account.DISE_Group_Code_Account_No_1__c.addError('Billing Code "' + tmp_account.DISE_Group_Code_Account_No_1__c + '" Already registered to: ' + userName);
	                            x_errors.add(tmp_account.Id);
	                        }
                        }
                    } // end group null check else
                } // end check group code check null check if
                
                if (tmp_account.DISE_Group_Code_Account_No_2__c != null) 
                {          
                    isGroup = codeTypeGroup.get(tmp_account.DISE_Group_Code_Account_No_2__c);
                    if (isGroup == null) 
                    {
                        tmp_account.DISE_Group_Code_Account_No_2__c.addError(Label.NOT_VALID_ACC_GROUP);
                        x_errors.add(tmp_account.Id);
                    } // end group null check if
                    else 
                    {
                        
                        // Raise error if this has been registered - i.e an email exists in the validation table 
                        if (Trigger.isInsert || (tmp_account.DISE_Group_Code_Account_No_2__c != x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_2__c)) 
                        {
	                        String userName = validCodes.get(tmp_account.DISE_Group_Code_Account_No_2__c);
	                        if (userName != null) 
	                        {
	                            tmp_account.DISE_Group_Code_Account_No_2__c.addError('Billing Code "' + tmp_account.DISE_Group_Code_Account_No_2__c + '" Already registered to: ' + userName);
	                            x_errors.add(tmp_account.Id);
	                        }    
                        }       
                    } // end group null check else
                } // end billing code 2 check if
                
                if (tmp_account.DISE_Group_Code_Account_No_3__c != null) 
                {          
                    isGroup = codeTypeGroup.get(tmp_account.DISE_Group_Code_Account_No_3__c);
                    if (isGroup == null) 
                    {
                        tmp_account.DISE_Group_Code_Account_No_3__c.addError(Label.NOT_VALID_ACC_GROUP);
                        x_errors.add(tmp_account.Id);
                    } // end group null check if
                    else 
                    {
                        
                        // Raise error if this has been registered - i.e an email exists in the validation table 
                        if (Trigger.isInsert || (tmp_account.DISE_Group_Code_Account_No_3__c != x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_3__c)) 
                        {                        
	                        String userName = validCodes.get(tmp_account.DISE_Group_Code_Account_No_3__c);
	                        if (userName != null) 
	                        {
	                            tmp_account.DISE_Group_Code_Account_No_3__c.addError('Billing Code "' + tmp_account.DISE_Group_Code_Account_No_3__c + '" Already registered to: ' + userName);
	                            x_errors.add(tmp_account.Id);
	                        }          
                        } 
                    } // end group null check else
                } // end billing code 3 check if
                
                if (tmp_account.DISE_Group_Code_Account_No_4__c != null) 
                {
                    isGroup = codeTypeGroup.get(tmp_account.DISE_Group_Code_Account_No_4__c);
                    if (isGroup == null) 
                    {
                        tmp_account.DISE_Group_Code_Account_No_4__c.addError(Label.NOT_VALID_ACC_GROUP);
                        x_errors.add(tmp_account.Id);
                    } // end group null check if
                    else {
                        
                        // Raise error if this has been registered - i.e an email exists in the validation table 
                        if (Trigger.isInsert || (tmp_account.DISE_Group_Code_Account_No_4__c != x_triggerOldMap.get(tmp_account.Id).DISE_Group_Code_Account_No_4__c)) 
                        {                        
	                        String userName = validCodes.get(tmp_account.DISE_Group_Code_Account_No_4__c);
	                        if (userName != null) 
	                        {
	                            tmp_account.DISE_Group_Code_Account_No_4__c.addError('Billing Code "' + tmp_account.DISE_Group_Code_Account_No_4__c + '" Already registered to: ' + userName);
	                            x_errors.add(tmp_account.Id);
	                        }     
                        }                      
                    } // end group null check else
                } // end billing code 4 null check if
            } // end error on this record check if
        } // end loop through triggered batch
        
        // Remove blank entries and duplicates                          
        for (Account tmp_account: x_triggerNewList)//Integer i=0; i<Trigger.new.size();i++)
        {
            
            // This map will control the order and duplicates of the billing codes.  We store all
            // associated fields (as a O2_linkage_billing_code) to ensure we don't move the billing
            // code away from its related data
            List<O2_linkage_billing_code> codeList = new List<O2_linkage_billing_code>();               
            
            // Do nothing if this record caused an error previously
            if (!x_errors.contains(tmp_account.Id) && !x_notChanged.contains(tmp_account.Id)) 
            {

                // Put the first billing code details into the list (unless it is null)
                if (tmp_account.DISE_Group_Code_Account_No_1__c != null) 
                {
                    codeList.add(new O2_linkage_billing_code(tmp_account.DISE_Group_Code_Account_No_1__c,tmp_account.OAR_Account_1_Response__c,tmp_account.OAR_Account_1_Handover_Status__c,tmp_account.OAR_Account_1_Handover_Approved_Date__c, tmp_account.OAR_Account_Reference_1__c));
                } // end code 1 null check if
                
                // Put the second billing code details into the list (unless it is null or is the same as the first code)
                if (tmp_account.DISE_Group_Code_Account_No_2__c != null) {
                    if (tmp_account.DISE_Group_Code_Account_No_2__c != tmp_account.DISE_Group_Code_Account_No_1__c) 
                    {
                        codeList.add(new O2_linkage_billing_code(tmp_account.DISE_Group_Code_Account_No_2__c,tmp_account.OAR_Account_2_Response__c,tmp_account.OAR_Account_2_Handover_Status__c,tmp_account.OAR_Account_2_Handover_Approved_Date__c, tmp_account.OAR_Account_Reference_2__c));
                    }
                } // end code 2 null check if
                
                // Put the third billing code details into the list (unless it is null or is the same as the first or second code)
                if (tmp_account.DISE_Group_Code_Account_No_3__c != null)
				{
                    if ((tmp_account.DISE_Group_Code_Account_No_3__c != tmp_account.DISE_Group_Code_Account_No_1__c) && (tmp_account.DISE_Group_Code_Account_No_3__c != tmp_account.DISE_Group_Code_Account_No_2__c))
                    {
                        codeList.add(new O2_linkage_billing_code(tmp_account.DISE_Group_Code_Account_No_3__c,tmp_account.OAR_Account_3_Response__c,tmp_account.OAR_Account_3_Handover_Status__c,tmp_account.OAR_Account_3_Handover_Approved_Date__c, tmp_account.OAR_Account_Reference_3__c));
                    }
                } // end code 3 null check if
                
                // Put the forth billing code details into the list (unless it is null or is the same as the first, second or thirdcode)
                if (tmp_account.DISE_Group_Code_Account_No_4__c != null) 
                {
                    if ((tmp_account.DISE_Group_Code_Account_No_4__c != tmp_account.DISE_Group_Code_Account_No_1__c) && (tmp_account.DISE_Group_Code_Account_No_4__c != tmp_account.DISE_Group_Code_Account_No_2__c) && (tmp_account.DISE_Group_Code_Account_No_4__c != tmp_account.DISE_Group_Code_Account_No_3__c))
                    {
                        codeList.add(new O2_linkage_billing_code(tmp_account.DISE_Group_Code_Account_No_4__c,tmp_account.OAR_Account_4_Response__c,tmp_account.OAR_Account_4_Handover_Status__c,tmp_account.OAR_Account_4_Handover_Approved_Date__c, tmp_account.OAR_Account_Reference_4__c));
                    }
                } // end code 4 null check if
                
                System.debug('codeList = ' + codeList);
                
                // Blank all fields before bringing them in
                tmp_account.DISE_Group_Code_Account_No_1__c				= null;
                tmp_account.OAR_Account_1_Response__c					= null;
                tmp_account.OAR_Account_1_Handover_Status__c			= null;
                tmp_account.OAR_Account_1_Handover_Approved_Date__c		= null;
                tmp_account.OAR_Account_Reference_1__c					= null;

                tmp_account.DISE_Group_Code_Account_No_2__c				= null;
                tmp_account.OAR_Account_2_Response__c					= null;
                tmp_account.OAR_Account_2_Handover_Status__c			= null;
                tmp_account.OAR_Account_2_Handover_Approved_Date__c		= null;
                tmp_account.OAR_Account_Reference_2__c					= null;

                tmp_account.DISE_Group_Code_Account_No_3__c				= null;
                tmp_account.OAR_Account_3_Response__c					= null;
                tmp_account.OAR_Account_3_Handover_Status__c			= null;
                tmp_account.OAR_Account_3_Handover_Approved_Date__c		= null;
                tmp_account.OAR_Account_Reference_3__c					= null;

                tmp_account.DISE_Group_Code_Account_No_4__c				= null;
                tmp_account.OAR_Account_4_Response__c					= null;
                tmp_account.OAR_Account_4_Handover_Status__c			= null;
                tmp_account.OAR_Account_4_Handover_Approved_Date__c		= null;
                tmp_account.OAR_Account_Reference_4__c					= null;

                
                // Fill back from our list
                Integer nextCodeToFill = 1;
                for (O2_linkage_billing_code code : codeList)  
                {
                    if (nextCodeToFill == 1) 
                    {
                        tmp_account.DISE_Group_Code_Account_No_1__c = code.accGrpCode;
                        tmp_account.OAR_Account_1_Response__c = code.accountResponse;
                        tmp_account.OAR_Account_1_Handover_Status__c = code.handoverStatus;
                        tmp_account.OAR_Account_1_Handover_Approved_Date__c = code.handoverApproved;
                        tmp_account.OAR_Account_Reference_1__c = code.reference;
                        tmp_account.DISE_1_GROUP__c = codeTypeGroup.get(code.accGrpCode);
                        nextCodeToFill ++;
                        System.debug('tmp_account1: ' + tmp_account);
                    }
                    else 
                    {
                        if (nextCodeToFill == 2) 
                        {
                            tmp_account.DISE_Group_Code_Account_No_2__c = code.accGrpCode;
                            tmp_account.OAR_Account_2_Response__c = code.accountResponse;
                            tmp_account.OAR_Account_2_Handover_Status__c = code.handoverStatus;
                            tmp_account.OAR_Account_2_Handover_Approved_Date__c = code.handoverApproved;
                            tmp_account.OAR_Account_Reference_2__c = code.reference;
                            tmp_account.DISE_2_GROUP__c = codeTypeGroup.get(code.accGrpCode);
                            nextCodeToFill ++;
                            System.debug('tmp_account2: ' + tmp_account);
                        }
                        else 
                        {
                            if (nextCodeToFill == 3) 
                            {
                                tmp_account.DISE_Group_Code_Account_No_3__c = code.accGrpCode;
                                tmp_account.OAR_Account_3_Response__c = code.accountResponse;
                                tmp_account.OAR_Account_3_Handover_Status__c = code.handoverStatus;
                                tmp_account.OAR_Account_3_Handover_Approved_Date__c = code.handoverApproved;
                                tmp_account.OAR_Account_Reference_3__c = code.reference;
                                tmp_account.DISE_3_GROUP__c = codeTypeGroup.get(code.accGrpCode);
                                nextCodeToFill ++;
                            }
                            else 
                            {
                                if (nextCodeToFill == 4) 
                                {
                                    tmp_account.DISE_Group_Code_Account_No_4__c = code.accGrpCode;
                                    tmp_account.OAR_Account_4_Response__c = code.accountResponse;
                                    tmp_account.OAR_Account_4_Handover_Status__c = code.handoverStatus;
                                    tmp_account.OAR_Account_4_Handover_Approved_Date__c = code.handoverApproved;
                                    tmp_account.OAR_Account_Reference_4__c = code.reference;
                                    tmp_account.DISE_4_GROUP__c = codeTypeGroup.get(code.accGrpCode);
                                }   
                            }
                        }
                    } // end 1 else     
                } // end loop through account codes 
            } // end error check if
        } // end loop through triggered set
	}
	
}