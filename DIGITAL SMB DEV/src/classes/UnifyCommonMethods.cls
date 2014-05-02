/**
*   Class contains common methods widely used by other Unify classes / methods
*   @since   25/10/2012
*   @author  emil.puchalski@cloudsensesolutions.com
*	@author  lukasz.skrodzki@cloudsensesolutions.com
*/
global class UnifyCommonMethods {
    global static Map<Id,String> productConfigurationIdToName = new Map<Id, String>();

    /**
    *   Method used to create Central Site (Location__c) entry in context of pointed Opportunity
    *   It checks whether such record has been previously created in context of this Customer and reuses it or created new one
    *   Based on Location it links it Opportunity through  Unify_Opportunity_Location__c object
    *   Method invoked from Bundle Builder page (UnifyProductBundleBuilderAsync) and Opportunity Detail page (ADD CENTRAL SITE button in the section with Sites related list)
    *   @param opportunityId passed opportunity Id for which Central Site needs to be created
    *   @return result of the transaction: OK for success, all other values contains error messages.
    */
    Webservice static string addCentralSite(string opportunityId){
        Unify_Opportunity_Location__c[] ol = [select Id from Unify_Opportunity_Location__c where Opportunity__c = :opportunityId and Location__r.Unify_Central_Site__c = true];
        if(ol.size() > 0){
            return('There is already an existing Central Site record below this Opportunity.');
        } else {
            Opportunity opp = [select Id, AccountId from Opportunity where Id = :opportunityId];
            Location__c[] locs = [select Id, Key__c from Location__c where Account__c = :opp.AccountId and Unify_Central_Site__c = true];

            Unify_Opportunity_Location__c uol = new Unify_Opportunity_Location__c();
            uol.Opportunity__c = opportunityId;
            uol.Name = UnifyConfig.CENTRAL_SITE_KEY_NAME;
            if(locs.size() > 0){
                uol.Location__c = locs[0].Id;
            } else {
                locs.add(new Location__c(Account__c = opp.AccountId, Unify_Unique_Site_Name__c = UnifyConfig.CENTRAL_SITE_KEY_NAME, Type__c = 'Installation', Unify_Central_Site__c = true));
                insert locs;
                uol.Location__c = locs[0].Id;
            }
            insert uol;
        }
        return 'OK';
    }

    /**
    *   Method used to create Order Group and trigger Batch process to create connected Orders
    *   @param oppId	Id of Opportunity for which Order Group should be created
    */
    global static void createOrderGroup(Id oppId) {

        Opportunity opp = [SELECT
        						ID, OwnerId, Name, Account.Name
        				   FROM
        				   		Opportunity
        				   WHERE
        				   		Id = :oppId
        				   	LIMIT 1];

        cscfgc__Product_Bundle__c bundle = [SELECT
        										ID, Name
        									FROM
        										cscfgc__Product_Bundle__c
        									WHERE
        										cscfgc__Opportunity__c = :oppId AND
        										cscfgc__Synchronised_with_Opportunity__c = true
        									LIMIT 1];
        string orderGroupName = 'OG: ' + opp.Account.Name + ' : ' + opp.Name + ' : ' + bundle.Name;

        Order_Group__c orderGroup = new Order_Group__c(Name = orderGroupName,
        											   OwnerId = opp.OwnerId,
        											   Unify_Project_Coordinator_Required__c = true,
        											   Opportunity__c = oppId,
        											   RecordTypeId = CreateServiceHelper.getOrderGroupRecordTypeMap().get('Unify'));
        insert orderGroup;
        UnifyCreateOrdersBatch batch = new UnifyCreateOrdersBatch();
        batch.orderGroupId = orderGroup.Id;
        batch.oppId= oppId;
        batch.sessionId = UserInfo.getSessionId();

        if(!Test.isRunningTest()){
            Database.executeBatch(batch, 1);
        }
    }

    /**
    *   Cancels Orders and create task for Manual steps for Project Coordinator
    *   @param orderId	Id of Order which should be cancelled
    * 	@result 		Result of Order cancellation which contains error or success information
    */
  	Webservice static List<String> cancelOrder(String orderId){
        List<String> result = new List<String>();
        Order__c[] ord = [SELECT
        					Id,Order_Group__r.Unify_Project_Coordinator__c, Order_Status__c
        				  FROM
        				  	Order__c
        				  WHERE
        				  	Id = :orderId];
        if(ord.size() == 0){
            result.add('ERROR');
            result.add('No Order found.');
        } else {
            ord[0].Order_Status__c = 'Cancelled';
            update ord[0];
            /*
            Task newTask = new Task();
            newTask.Status = 'Not Started';
            newTask.Subject = 'Process Order Cancellation';
            newTask.WhatId = ord[0].Id;
            newTask.OwnerId = ord[0].Order_Group__r.Unify_Project_Coordinator__c;
            newTask.Description = 'Order has been cancelled.';
            newTask.ActivityDate = System.today().addDays(5);
            insert newTask;
            */
            //Delete all not completed tasks created from Orchestration
            //!!!Residual From Unify R1
            Task[] tasksToDelete = [SELECT
           								Id
           							FROM
           								Task
           							WHERE
           								WhatId = :ord[0].Id AND
           								Status != 'Completed' AND
           								CSPOFA__Process_Step_link__c != ''];
            if(tasksToDelete.size() > 0)
                delete tasksToDelete;

            //Cancel orchestration related to the Order
            //!!!Residual From Unify R1
            CSPOFA__Orchestration_Process__c[] processes = [SELECT
            													Id
            												FROM
            													CSPOFA__Orchestration_Process__c
            												WHERE
            													Order__c = :ord[0].Id];
            if(processes.size() > 0){
                for(CSPOFA__Orchestration_Process__c p : processes){
                    p.CSPOFA__Status__c = 'Complete';
                }
                update processes;
                CSPOFA__Orchestration_Step__c[] steps = [SELECT
                											Id
                										FROM
                											CSPOFA__Orchestration_Step__c
                										WHERE
                											CSPOFA__Status__c != 'Complete' AND
                											CSPOFA__Orchestration_Process__c in :processes];
                for(CSPOFA__Orchestration_Step__c step : steps){
                    step.CSPOFA__Status__c = 'Cancelled';
                    step.CSPOFA__Progress__c = 'Complete';
                }
                update steps;
                CSPOFA__POF_Callout_Instruction__c[] callouts = [SELECT
                													Id
                    											 FROM
                    											 	CSPOFA__POF_Callout_Instruction__c
                    											 WHERE
                    											 	CSPOFA__Orchestration_Step__c in :steps];

                for(CSPOFA__POF_Callout_Instruction__c callout : callouts){
                    callout.CSPOFA__Status__c = 'Done';
                }
                update callouts;
            }
            result.add('OK');
        }
        return result;
    }

    /**
    *   Method for delivered xls file content specifies used line delimeter
    *   Method invoked from UnifyUploadExcelDataController and UnifyAddMassHardwareItemsController classes
    *   @param contents copied XLS file content
    *   @return			returns characters used as a line delimeter in order to split content to particular lines
    */
    public static string setLineDelimeter(string contents){
        if (contents.contains('\r') && contents.contains('\n'))
        {
            contents = contents.replace('\r', '');
            return '\n';
        }
        // Linux
        else if (contents.contains('\n'))
        {
            return '\n';
        }
        // Mac OS
        else
        {
            return '\r';
        }
    }

    /**
    *   Method converts passed excel column value into proper decimal
    *   Method used within UnifyUploadExcelDataController and UnifybatchConfigUpload classes
    *   @param excelValue	excel field value that needs to be converted into decimal
    *   @return				converted value
    */
    public static decimal covertAmount2decimal(string excelValue){
        if(excelValue == '' || excelValue == null){
            return 0;
        } else {
            return decimal.valueOf(cleanNumberNotation(excelValue));
        }
    }

    /**
    *   Method processes passed excel field value and removes irrelevant special characters
    *   It is also responsible for proper interpretation of used decimal and thousand seperators
    *   Method used within covertAmount2decimal method and UnifybatchConfigUpload class
    *   @param excelValue	excel field value that needs to be processed
    *   @return				processed value
    */
    public static string cleanNumberNotation(string excelValue){
        if(excelValue == '' || excelValue == null){
            return '';
        } else {
            string decimalSeparator = '.';
            string thousandSeparator = ',';
            String s = excelValue.replace('£','').replace(' ','').replace('%','').replace('$','').trim();
            if(s.length() > 3){
                string foundDecSep = s.substring(s.length()-3, s.length()-2);
                if(foundDecSep == ','){
                    decimalSeparator = foundDecSep;
                    thousandSeparator = '.';
                }
            }
            //make sure that only separator which is used is decimal one, and before it is passed to conversion methods it uses proper form;
            s = s.replace(thousandSeparator,'');
            return s.replace(decimalSeparator,'.').trim();
        }
    }

    /**
    *   Technical method that removes delivered value form multipicklist string
    *   Method used within UnifyRaidTrigger
    *   @param val - value that needs to be removed from passed msPicklist
    *   @param msPicklist	multipicklist values represented in one string that needs to be processed
    *   @return				multipicklist string after its processing
    */
    public static string removeValueFromMultiPicklist(string val, string msPicklist){
        if(msPicklist == null || msPicklist == ''){
            return '';
        } else {
            if(!msPicklist.contains(val)){
                return msPicklist;
            } else {
                String[] vals = new String[]{};
                vals = msPicklist.split(';');
                string result ='';
                for(string s1 : vals){
                    if(s1 == val){
                        continue;
                    } else {
                        result = result==''?s1: (result + ';' + s1);
                    }
                }
                return result;
            }
        }
    }
}