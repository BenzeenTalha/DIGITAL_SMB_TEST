global with sharing class ProcessCalloutInstructions implements Schedulable {
    global void execute(SchedulableContext SC) 
    {
        List<CSPOFA__POF_Callout_Instruction__c> callInstructionList = [select Id, CSPOFA__Callout_Action__c, CSPOFA__Orchestration_Step__c, 
                                                                				  CSPOFA__Status__c 
		                                                                  From CSPOFA__POF_Callout_Instruction__c 
		                                                                 where CSPOFA__status__c = 'Not Started'
		                                                                   And (CSPOFA__Callout_Action__c != 'Update Field' OR CSPOFA__Callout_Action__c != 'Monitor Field'
		                                                                  		OR CSPOFA__Callout_Action__c != 'Wait Number Of Days')];
        //
        // Get a list iof all the Step Ids involved in the outstanding callouts
        List<String> stepIdList = new List<String>();
        for (CSPOFA__POF_Callout_Instruction__c rec : callInstructionList) {
            stepIdList.add(rec.CSPOFA__Orchestration_Step__c);
        }
        // 
        // Loop through all the outstanding callout instructions and execute them
        List<String> callOutStepIdList = new List<String>();
        for (CSPOFA__POF_Callout_Instruction__c rec : callInstructionList) {
        	callOutStepIdList.add(rec.Id+':'+rec.CSPOFA__Orchestration_Step__c);
        }
        //
        if (!callOutStepIdList.isEmpty())
        	processSteps(callOutStepIdList);
    }
    
    
    public static void processSteps(List<String> instructionStepIdList) {
    	// Split the incoming list
    	List<String> stepIdList = new List<String>();
    	List<String> instructionIdList = new List<String>();
    	Map<String,String> stepInstructionIdMap = new Map<String,String>();
    	for (String rec : instructionStepIdList) {
    		List<String> recSplitList = rec.split(':');
    		instructionIdList.add(recSplitList[0]);
    		stepIdList.add(recSplitList[1]);
    		stepInstructionIdMap.put(recSplitList[1],recSplitList[0]);
    	} 
    	//
    	List<CSPOFA__Orchestration_Step__c> stepDetailsList = [select id, CSPOFA__message__c, CSPOFA__Status__c, CSPOFA__Progress__c
    													 from CSPOFA__Orchestration_Step__c where id in :stepIdList];
    	List<String> instructionsDoneIdList = new List<String>();
    	for (CSPOFA__Orchestration_Step__c step : stepDetailsList) {
			step.CSPOFA__Status__c = 'Complete';
			step.CSPOFA__Progress__c = 'Complete';
            step.CSPOFA__message__c = 'Completed waiting task on: '+date.today();
            //
            instructionsDoneIdList.add(stepInstructionIdMap.get(step.Id));
    	}
    	update stepDetailsList;
    	//
    	List<CSPOFA__POF_Callout_Instruction__c> instructionDoneList = [select Id, CSPOFA__Status__c from CSPOFA__POF_Callout_Instruction__c where Id = :instructionsDoneIdList];
    	for (CSPOFA__POF_Callout_Instruction__c instruction : instructionDoneList) {
            instruction.CSPOFA__Status__c = 'Done';
    	}
        update instructionDoneList;
    }
}