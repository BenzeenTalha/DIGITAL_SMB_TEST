public class UnifyTaskDeleteController {

	public Id taskId;
	public ID profileId;
	public Task objTask;
	public String returnURL;

	public UnifyTaskDeleteController(ApexPages.StandardController stdController) {
        Task t = (Task)stdController.getRecord();
        taskId = t.Id; 
        
        objTask = [select Id, CSPOFA__Process_Step_link__c from Task where Id =: taskId];
        
        Profile[] pr = [select Id from Profile where Name = 'JJ Unify'];
        
        profileId = null;
        if(pr.size() > 0){
        	profileId = pr[0].Id;
        }
        
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
        
        if(returnURL == null){
        	returnURL = '/home/home.jsp';
        }
    }
    
    public PageReference deleteTask(){
    	PageReference pr = new PageReference(returnURL);
    	
    	if(UserInfo.getProfileId() == profileId && objTask.CSPOFA__Process_Step_link__c != null && objTask.CSPOFA__Process_Step_link__c != ''){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'This Task is part of Orchestration Process and you are not allowed to delete it. \nIn order to delete this Task, please, contact Administrator. (<a href="' + pr.getUrl() + '">back to previous page</a>)'));
    		return null;
    	} else {
    		delete objTask;
    		return pr;
    	}
    }
}