@isTest
private class TestUnifyTaskDeleteController {

	static task createTaskEntry(String processStep){
		Task tsk = new Task(Type = 'Call', Subject = 'Test', Status = 'Not Started', Priority = 'Normal', CSPOFA__Process_Step_link__c = processStep);
		
		insert tsk;
		
		return tsk;
	}

    static testMethod void testDelete1() {
		PageReference pageRef = Page.UnifyTaskDelete;
		Test.setCurrentPageReference(pageRef);
		
		ApexPages.StandardController sc = new ApexPages.standardController(createTaskEntry(null));
		UnifyTaskDeleteController conExt = new UnifyTaskDeleteController(sc);
        
        PageReference pr = conExt.deleteTask();
    }
    
    static testMethod void testDelete2() {
    	
    	User[] usr = [select Id from User where Profile.Name = 'JJ Unify' and isActive = true];
    	
    	if(usr.size() > 0){
    		System.RunAs(usr[0]){
				PageReference pageRef = Page.UnifyTaskDelete;
				Test.setCurrentPageReference(pageRef);
				
				ApexPages.StandardController sc = new ApexPages.standardController(createTaskEntry('ABC1234'));
				UnifyTaskDeleteController conExt = new UnifyTaskDeleteController(sc);
		        
		        PageReference pr = conExt.deleteTask();
    		}
    	}
    }    
}