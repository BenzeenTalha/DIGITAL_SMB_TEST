public with sharing class ProcessStepHelper {
	
    // Send email
    //@future
    public static void sendEmail(String processId, CSPOFA__Orchestration_Step__c step) {
    	// Get Process Details
    	CSPOFA__Orchestration_Process__c provProcess = [select CSPOFA__Opportunity__c, CSPOFA__Opportunity__r.OwnerId, CSPOFA__Opportunity__r.Owner.ContactId, 
    														   CSPOFA__Opportunity__r.Account.OwnerId, Order_Group__r.Account_Name__c, 
    														   Order_Group__c, Order_Group__r.Provisioning_Agent__c, 
    														   Order__c, Order__r.Account__r.OwnerId, Order__r.Main_contact__c, Order__r.Provisioning_Agent__c
    													from CSPOFA__Orchestration_Process__c where Id = :processId]; 
		
		//
    	// Get a list of all the contacts on the Opportunity
		List<OpportunityContactRole> oppContactRoleList = [Select o.Role, o.OpportunityId, o.IsPrimary, o.Id, o.ContactId From OpportunityContactRole o
        													where o.OpportunityId = :provProcess.CSPOFA__Opportunity__c];
        Map<String,String> oppFieldMap = new Map<String,String>();
        for (OpportunityContactRole oppContactrole : oppContactRoleList) {
        	oppFieldMap.put(oppContactrole.role+' Contact',oppContactrole.ContactId);
        	if (oppContactrole.IsPrimary) 
        		oppFieldMap.put('Primary Contact',oppContactrole.ContactId);
        }
		//
        oppFieldMap.put('Opportunity Owner',''+provProcess.CSPOFA__Opportunity__r.OwnerId);
        oppFieldMap.put('Account Owner',''+provProcess.CSPOFA__Opportunity__r.Account.OwnerId);
	    oppFieldMap.put('Partner Contact',''+provProcess.CSPOFA__Opportunity__r.Owner.ContactId);
        oppFieldMap.put('Opportunity Id',''+provProcess.CSPOFA__Opportunity__c);
        oppFieldMap.put('Order Id',''+provProcess.Order__c);
        oppFieldMap.put('Order Group Id',''+provProcess.Order_Group__c);
        oppFieldMap.put('Order Owner',''+provProcess.Order__r.Account__r.OwnerId);
        oppFieldMap.put('Provisioning Agent',''+provProcess.Order__r.Provisioning_Agent__c);
        oppFieldMap.put('Provisioning Agent - Order Group',''+provProcess.Order_Group__r.Provisioning_Agent__c);
        oppFieldMap.put('Main Contact',''+provProcess.Order__r.Main_contact__c);
        //
        system.debug('****************************provProcess.Order__c='+provProcess.Order__c+'*************oppFieldMap.get(Order Id)'+oppFieldMap.get('Order Id'));
        //
    	// Get the correct template Id depending on the step type
    	String templateUniqueName;
    	templateUniqueName = step.CSPOFA__email_template_name__c;
    	EmailTemplate template = [select Id, Name, Subject from EmailTemplate where DeveloperName = :templateUniqueName]; 
    	//
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTargetObjectId(oppFieldMap.get(step.CSPOFA__send_email_to__c));
		mail.setTemplateId(template.Id);
		mail.SetWhatId(oppFieldMap.get('Order Id'));
		//
		if (!Test.isRunningTest()) {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });		
		}
   }
    
    // Create task
    //@future
    public static void createTask(String processId, CSPOFA__Orchestration_Step__c step) {
    	// Get Process Details
    	CSPOFA__Orchestration_Process__c provProcess = [select CSPOFA__Opportunity__c, CSPOFA__Opportunity__r.OwnerId, CSPOFA__Opportunity__r.Owner.ContactId, 
    														   CSPOFA__Opportunity__r.Account.OwnerId, Order_Group__r.Account_Name__c, 
    														   Order_Group__c, Order_Group__r.Provisioning_Agent__c, 
    														   Order__c, Order__r.Account__r.OwnerId, Order__r.Main_contact__c, Order__r.Provisioning_Agent__c,
    														   Order__r.Account__r.RecordTypeId,  Order__r.Account__r.Name
    													from CSPOFA__Orchestration_Process__c where Id = :processId]; 
		
		//
    	// Get a list of all the contacts on the Opportunity
		List<OpportunityContactRole> oppContactRoleList = [Select o.Role, o.OpportunityId, o.IsPrimary, o.Id, o.ContactId From OpportunityContactRole o
        													where o.OpportunityId = :provProcess.CSPOFA__Opportunity__c];
        Map<String,String> oppFieldMap = new Map<String,String>();
        for (OpportunityContactRole oppContactrole : oppContactRoleList) {
        	oppFieldMap.put(oppContactrole.role+' Contact',oppContactrole.ContactId);
        	if (oppContactrole.IsPrimary) 
        		oppFieldMap.put('Primary Contact',oppContactrole.ContactId);
        }
        
        //RU 21/11/2011: get recordtype for an to differentiate bw BE and Other Orchestration processes
        RecordType accRecordType = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where r.SobjectType = 'Account' and r.DeveloperName = 'BE_Account'];
        
		//
        oppFieldMap.put('Opportunity Owner',''+provProcess.CSPOFA__Opportunity__r.OwnerId);
       
        oppFieldMap.put('Account Owner',''+provProcess.CSPOFA__Opportunity__r.Account.OwnerId);
         if(accRecordType.Id == provProcess.Order__r.Account__r.RecordTypeId)
        {
        	oppFieldMap.put('Account Name',''+provProcess.Order__r.Account__r.Name);
        }
        else
        {
        	oppFieldMap.put('Account Name',''+provProcess.Order_Group__r.Account_Name__c);
        }
	    oppFieldMap.put('Partner Contact',''+provProcess.CSPOFA__Opportunity__r.Owner.ContactId);
        oppFieldMap.put('Opportunity Id',''+provProcess.CSPOFA__Opportunity__c);
        oppFieldMap.put('Order Id',''+provProcess.Order__c);
        oppFieldMap.put('Order Group Id',''+provProcess.Order_Group__c);
        oppFieldMap.put('Order Owner',''+provProcess.Order__r.Account__r.OwnerId);
        oppFieldMap.put('Provisioning Agent',''+provProcess.Order__r.Provisioning_Agent__c);
        oppFieldMap.put('Provisioning Agent - Order Group',''+provProcess.Order_Group__r.Provisioning_Agent__c);
        oppFieldMap.put('Main Contact',''+provProcess.Order__r.Main_contact__c);
        //
    	Task newtask = new Task();
    	//
    	try {
	    	newTask.OwnerId = oppFieldMap.get(step.CSPOFA__task_assigned_to__c);
    		//
	    	if (step.CSPOFA__task_linked_to__c == 'Opportunity') {
	    		newTask.whatId  = oppFieldMap.get('Opportunity Id');
	    	} else if (step.CSPOFA__task_linked_to__c == 'Order') {
	    		newTask.whatId  = oppFieldMap.get('Order Id');
	    	} else if (step.CSPOFA__task_linked_to__c == 'Order Group') {
	    		newTask.whatId  = oppFieldMap.get('Order Group Id');
	    	} else {
	    		newTask.whatId  = step.id;
	    	}
	    	//
	    	newTask.Subject      = oppFieldMap.get('Account Name')+': '+step.CSPOFA__Task_Subject__c;
	    	newTask.Description  = step.CSPOFA__Task_Description__c;
	    	newTask.Status       = step.CSPOFA__Task_Status__c;
	    	newTask.Priority     = step.CSPOFA__Task_Priority__c;
	    	newTask.ActivityDate = step.CSPOFA__Task_Due_Date__c;
	    	newTask.Type         = step.CSPOFA__Task_Type__c;
	    	newTask.CSPOFA__Process_Step_link__c = step.id;
	    	insert newTask;
    	} catch(Exception ex) {
    		system.debug('****************************** Error while creating a task: '+ex);
    	}
		//
    }
    
    // Create Case
    //@future
    public static void createCase(String processId, CSPOFA__Orchestration_Step__c step) {
    	// Get Process Details
    	CSPOFA__Orchestration_Process__c provProcess = [select CSPOFA__Opportunity__c, CSPOFA__Opportunity__r.OwnerId, CSPOFA__Opportunity__r.Owner.ContactId, 
    														   CSPOFA__Opportunity__r.Account.OwnerId, Order_Group__r.Account_Name__c, 
    														   Order_Group__c, Order_Group__r.Provisioning_Agent__c, 
    														   Order__c, Order__r.Account__r.OwnerId, Order__r.Main_contact__c, Order__r.Provisioning_Agent__c
    													from CSPOFA__Orchestration_Process__c where Id = :processId]; 
		
		//
    	// Get a list of all the contacts on the Opportunity
		List<OpportunityContactRole> oppContactRoleList = [Select o.Role, o.OpportunityId, o.IsPrimary, o.Id, o.ContactId From OpportunityContactRole o
        													where o.OpportunityId = :provProcess.CSPOFA__Opportunity__c];
        Map<String,String> oppFieldMap = new Map<String,String>();
        for (OpportunityContactRole oppContactrole : oppContactRoleList) {
        	oppFieldMap.put(oppContactrole.role+' Contact',oppContactrole.ContactId);
        	if (oppContactrole.IsPrimary) 
        		oppFieldMap.put('Primary Contact',oppContactrole.ContactId);
        }
		//
        oppFieldMap.put('Opportunity Owner',''+provProcess.CSPOFA__Opportunity__r.OwnerId);
        oppFieldMap.put('Account Owner',''+provProcess.CSPOFA__Opportunity__r.Account.OwnerId);
	    oppFieldMap.put('Partner Contact',''+provProcess.CSPOFA__Opportunity__r.Owner.ContactId);
        oppFieldMap.put('Opportunity Id',''+provProcess.CSPOFA__Opportunity__c);
        oppFieldMap.put('Order Id',''+provProcess.Order__c);
        oppFieldMap.put('Order Group Id',''+provProcess.Order_Group__c);
        oppFieldMap.put('Order Owner',''+provProcess.Order__r.Account__r.OwnerId);
        oppFieldMap.put('Provisioning Agent',''+provProcess.Order__r.Provisioning_Agent__c);
        oppFieldMap.put('Provisioning Agent - Order Group',''+provProcess.Order_Group__r.Provisioning_Agent__c);
        oppFieldMap.put('Main Contact',''+provProcess.Order__r.Main_contact__c);
        //
    	Case newCase = new Case();
    	//system.debug('oppFieldMap: '+oppFieldMap);
    	newCase.OwnerId     = oppFieldMap.get(step.CSPOFA__case_assigned_to__c);
    	newCase.Subject     = step.CSPOFA__Case_Subject__c;
    	newCase.Description = step.CSPOFA__Case_Description__c;
    	newCase.Status      = 'New';
    	newCase.Type        = step.CSPOFA__Case_Type__c;
    	newCase.Reason      = step.CSPOFA__Case_Reason__c;
    	newCase.CSPOFA__Orchestration_Step__c = step.id;
    	insert newCase;
		//
    }
    
    // Create callout instruction
    public static void createCalloutInstruction(String processId, CSPOFA__Orchestration_Step__c step) {
    	// Get the correct template Id depending on the step type
    	CSPOFA__POF_Callout_Instruction__c newCalloutInstruction = new CSPOFA__POF_Callout_Instruction__c();
    	newCalloutInstruction.CSPOFA__callout_action__c          = step.CSPOFA__type__c;
    	newCalloutInstruction.CSPOFA__Orchestration_Step__c 	 = step.id;
    	newCalloutInstruction.CSPOFA__status__c                  = 'Not Started';
    	insert newCalloutInstruction;
		//
    }
}