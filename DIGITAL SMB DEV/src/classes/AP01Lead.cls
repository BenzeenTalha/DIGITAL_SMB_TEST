/*
* Lead Assignment Controller Module.
* Run the parameterised modules in the specified order for each Lead.
*
* Revision history
* June 2010 Colin Kenworthy (Radius Technology) - initial version
* July 2010 Colin Kenworthy - limit BRANCH_ALIGNMENT_MAP to just ticked rows. Was blowing test method 500 limit.
* July 2010 Colin Kenworthy - use AND instead of OR in the query to populate MATCHING_SF_ACCOUNTS.
* August 2013 Ivan Tadic (CloudSense) - Excluding users with 'Retail High Volume Customer Portal User' profile from possible owners
*/
public class AP01Lead {

    // static parameters

    // Lead source along with the sequence of tests to apply to find a matching allocation.
    public static Map<String, String[]> TESTS_TO_PERFORM;
    static {
        if (TESTS_TO_PERFORM == null) {
            // load rules into map
            TESTS_TO_PERFORM = new Map<String, String[]>();
            // SOQL for getting rules
            for (Lead_Auto_Assignment_Parameter__c lAAP : [SELECT Id,
                                                                   Test_Entry__c,
                                                                   Lead_Source__c
                                                              FROM Lead_Auto_Assignment_Parameter__c]) {
                // !!! Need to double escape the vertical bar char - \\|
                TESTS_TO_PERFORM.put(lAAP.Lead_Source__c, lAAP.Test_Entry__c.split('\\|' , 0));
            }
            System.Debug('##### AP01Lead ##### Assignment Params loaded:'+TESTS_TO_PERFORM);
        }
    }

    // these leads will be passed around the assignment modules getting flagged as processed if they match a rule.
    public static List<wrapperLead> LEADS_TO_PROCESS;

    // these rows will be used to do the postcode lookups (e.g. AB1, table row for AB1)
    public static Map<String, Postcode_Alignment__c> POSTCODE_ROWS_MAP;

    // these rows will contain the Branch Codes and whether CoE Aligned or not.
    public static Map<String, Boolean> BRANCH_ALIGNMENT_MAP;

    // these rows will contain matching billing codes or matching name + postcodes from AccountValidationTable (populated from DISE)
    public static List<Account_Validation_Table__c> MATCHING_DISE_ACCOUNTS;

    // these rows will contain matching name + postcodes from Account
    public static List<Account> MATCHING_SF_ACCOUNTS;



    public static void AutoAssignLeads(List<Lead> theseLeads) {
    //
        // for each lead get the first half of the postcode, billing code and name+postcode.
        Map<String, String> leadPostcodeMap = new Map<String, String>();
        Map<String, String> leadPostcodeAreaMap = new Map<String, String>();
        Set<String> leadBillingCodeSet = new Set<String>();
        Set<String> leadGroupCodeSet = new Set<String>();
        Set<String> leadCompanyNameSet = new Set<String>();
        Set<String> leadPostcodeSet = new Set<String>();
        for (Lead le : theseLeads) {
            if (le.PostalCode <> null) {leadPostcodeMap.put(le.PostalCode, PostcodeUtils.GetFirstHalfOfPostcode(le.PostalCode));}
            if (le.PostalCode <> null) {leadPostcodeAreaMap.put(le.PostalCode, PostcodeUtils.GetAreaOfPostcode(le.PostalCode));}
            if (le.DISE_Account_No__c <> null) {leadBillingCodeSet.add(le.DISE_Account_No__c);}
            if (le.DISE_Group_Code__c <> null) {leadGroupCodeSet.add(le.DISE_Group_Code__c);}
            if (le.Company<> null) {leadCompanyNameSet.add(le.Company);}
            if (le.PostalCode <> null) {leadPostcodeSet.add(le.PostalCode);}
        }

        // SOQL to query postcode alignment object
        if (POSTCODE_ROWS_MAP == null) {
            POSTCODE_ROWS_MAP = PostcodeUtils.GetPostcodeParams(leadPostcodeMap.values());
        }

        // SOQL to query CoE aligned store object
        if (BRANCH_ALIGNMENT_MAP == null) {
            BRANCH_ALIGNMENT_MAP = new Map<String, Boolean>();
            for (CoE_Aligned_Store__c br : [SELECT Id,
                                                   Branch_Code__c,
                                                   CoE_Aligned__c
                                              FROM CoE_Aligned_Store__c
                                             WHERE CoE_Aligned__c = TRUE
                                             LIMIT 1000]) {
                BRANCH_ALIGNMENT_MAP.put(br.Branch_Code__c, br.CoE_Aligned__c);
            }
        }

        // initialise the list of Lead wrappers that will be used
        if (LEADS_TO_PROCESS == null) {
            LEADS_TO_PROCESS = new List<wrapperLead>();
            for (Lead le : TheseLeads) {
                LEADS_TO_PROCESS.add(new wrapperLead(le, leadPostcodeMap.get(le.PostalCode), leadPostcodeAreaMap.get(le.PostalCode)));
            }
        }




        // process each lead through the rules relating to the type of lead
        for (wrapperLead wL : LEADS_TO_PROCESS) {

            // type of lead determination
            // look at lead source to get list of tests to perform
            String[] paramModuleTests = TESTS_TO_PERFORM.get(wL.le.LeadSource);
            if (paramModuleTests == null) {
                paramModuleTests = new String[]{};
            } else {
                // initialise Account Validation Table (DISE) account info
                if (MATCHING_DISE_ACCOUNTS == null) {
                    MATCHING_DISE_ACCOUNTS = [SELECT Id, Name, MPN_s__c, Account_Description__c,
                                                     Account__c, Full_Account__c,Group_Code__c,
                                                     Post_Code__c, SF_Owner_ID__c, Flag__c
                                                FROM Account_Validation_Table__c
                                               WHERE Account__c IN :leadBillingCodeSet
                                                  OR Full_Account__c IN :leadBillingCodeSet
                                                  OR Group_Code__c IN :leadGroupCodeSet
                                                  OR (     Account_Description__c IN :leadCompanyNameSet
                                                       AND Post_Code__c IN :leadPostcodeSet)
                                               LIMIT 1000
                                             ];
                }
                // initialise SF account info
                if (MATCHING_SF_ACCOUNTS == null) {
                    MATCHING_SF_ACCOUNTS = [SELECT Id, OwnerId, Name, Postcode__c
                                                FROM Account
                                               WHERE Name IN :leadCompanyNameSet
                                                 AND Postcode__c IN :leadPostcodeSet
                                               LIMIT 1000
                                           ];
                }
            }
            System.Debug('##### AP01Lead ##### Tests to apply to this Lead:'+paramModuleTests);
            Integer paramCounter = 0;
            String  PARAM = '|';

            // perform tests in order until an assignment is performed.
            if (wL.le.Previous_Auto_Assign_Matches__c == null) {wL.le.Previous_Auto_Assign_Matches__c = ',';}
            while (wL.processed == FALSE && paramCounter < paramModuleTests.size()) {  // if still tests left to perform
                PARAM = paramModuleTests[paramCounter];
                // skip test X if we have previously matched this Lead on test X etc.
                if ( ! wL.le.Previous_Auto_Assign_Matches__c.toUpperCase().contains(','+PARAM.toUpperCase()+',')) {
                    if (PARAM.toUpperCase() == 'FIXED') {
                        AP01TestModule1.RunTest(wL);
                    } else
                    if (PARAM.toUpperCase() == 'EXISTING') {
                        AP01TestModule2.RunTest(wL);
                    } else
                    if (PARAM.toUpperCase() == 'ONLINE') {
                        AP01TestModule3.RunTest(wL);
                    } else
                    if (PARAM.toUpperCase() == 'RETAIL') {
                        AP01TestModule4.RunTest(wL);
                    } else
                    if (PARAM.toUpperCase() == 'DBAM') {
                        AP01TestModule5.RunTest(wL);
                    }
                }
                paramCounter++;  // next test

            }  // while

        } // for



        // Some Lead wrappers will have been given owner names, some actual Ids.
        // Get the ids of any assigned owner names/queues into a map.
        Set<String> nameSet = new Set<String>();
        Map<String, Id> nameIdMap = new Map<String, Id>();
        for (wrapperLead wL : LEADS_TO_PROCESS) {
            if (wL.processed == TRUE && wL.newOwnerName <> '') {
                nameSet.add(wL.newOwnerName);
            }
        }
        if(nameSet.size() > 0) {
            System.Debug('##### AP01Lead ##### Following names will be searched for IDs:'+nameSet);
            for (User usr : [SELECT
            					Id, Name
                             FROM
                             	User
                             WHERE
                             	Name IN :nameSet AND
                             	IsActive = true AND
                             	Profile.Name != 'Retail High Volume Customer Portal User']) {
                nameIdMap.put(usr.Name, usr.Id);
                System.Debug('##### AP01Lead ##### Found User :'+usr.Name);
            }
            nameSet.removeAll(nameIdMap.keySet());
            // not all names were found in User, some of the names must be a Queue name instead
            if(nameSet.size() > 0) {
                for (Group queue : [SELECT Id, Name
                                      FROM Group
                                     WHERE Type = 'Queue'
                                       AND Name IN :nameSet]) {
                    nameIdMap.put(queue.Name, queue.Id);
                    System.Debug('##### AP01Lead ##### Found Queue:'+queue.Name);
                }
            }
            nameSet.removeAll(nameIdMap.keySet());
            // not all the names were found as user or queue names (those leads will fall into the default queue)
            if(nameSet.size() > 0) {
                for (String name : nameSet) {
                    System.Debug('##### AP01Lead ##### Not Found  :'+name);
                }
            }
        }

        // update each processed Lead's values if an Id has been identified
        for (wrapperLead wL : LEADS_TO_PROCESS) {
            // either owner id or owner name will be populated in the wrapper by the called classes.
            if (wL.processed && wL.newOwnerName <> '') {
                wL.newOwnerId = nameIdMap.get(wL.newOwnerName);
            }
            // put wrapper values into Lead
            if (wL.processed && wL.newOwnerId <> null) {
                // can assume this field always ends with a comma
                wL.le.Previous_Auto_Assign_Matches__c = wL.le.Previous_Auto_Assign_Matches__c + wL.matchedRule + ',';
                // all wrappers should now have an Id (or null if problem)
                System.Debug('##### AP01Lead ##### Changing Lead Owner Id. WAS '+wL.le.OwnerId+' NOW '+wL.newOwnerId);
                wL.le.OwnerId = wL.newOwnerId;
            } else if (wL.processed) { // matched a rule but no Id found for owner
                System.Debug('##### AP01Lead ##### Defaulting Lead Owner to the default queue Id. WAS '+wL.le.OwnerId+' NOW '+wL.le.f_Assignment_Rules_Dropout_Queue__c);
                wL.le.OwnerId = wL.le.f_Assignment_Rules_Dropout_Queue__c; // Lead Assignment Drop Outs
            }

            if (wL.le.Previous_Auto_Assign_Matches__c == ',') {
                wL.le.Previous_Auto_Assign_Matches__c = null;
            }
        } // for
    }

    public static Boolean BranchIsCoEAligned(String branchCode) {
        Boolean coeAligned = BRANCH_ALIGNMENT_MAP.get(branchCode);
        if (coeAligned == null) {coeAligned = FALSE;}
        return coeAligned;
    }
    public static String GetAccountManagerNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.AM__c;}
        return retVal;
    }
    public static String GetAquisitionNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.Acquisition__c;}
        return retVal;
    }
    public static String GetCoEAlignedNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.COE_Aligned__c;}
        return retVal;
    }
    public static String GetCoENonAlignedNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.COE_Non_Aligned__c;}
        return retVal;
    }
    public static String GetCorporateNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.Corp__c;}
        return retVal;
    }
    public static String GetDBAMNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.DBAM__c;}
        return retVal;
    }
    public static String GetDMUNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.DMU__c;}
        return retVal;
    }
    public static String GetFieldAccountManagerNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.FAM__c;}
        return retVal;
    }
    public static String GetFranchiseNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.Franchise__c;}
        return retVal;
    }
    public static String GetRegionalTechnologyPartnerNameForPostcode(String halfPostcode) {
        Postcode_Alignment__c pA = POSTCODE_ROWS_MAP.get(halfPostcode);
        String retVal = '';
        if (pA <> null) {retVal = pA.RTP__c;}
        return retVal;
    }

    // helper class that will hold the lead and various attributes as the leads are assigned.
    // the attributes are applied in a loop at the end.
    public class wrapperLead {

        public Lead    le;
        public Boolean processed;
        public String  halfPostcode;
        public String  areaPostcode;
        public String  matchedRule;
        public String  newOwnerName;
        public Id      newOwnerId;

        // constructor
        public wrapperLead(Lead pLead, String pHalfPostcode, String pAreaPostcode) {
            le = pLead;
            processed = FALSE;
            halfPostcode = pHalfPostcode;
            areaPostcode = pAreaPostcode;
            matchedRule = '0';
            newOwnerName = '';
        }

    }

}