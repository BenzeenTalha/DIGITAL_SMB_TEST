public class UnifyTaskCloseController {
    String retUrl;
    Task t;
    public UnifyTaskCloseController(ApexPages.StandardController stdController) {
        t = (Task)stdController.getRecord();
        t = [Select Unify_Completed_Date__c, Id from Task where Id = :t.Id][0];
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        if(retUrl == null || retUrl == ''){
            retUrl = '/home/home.jsp';
        }
    }
    public PageReference closeTask(){

        PageReference pr;
        if(t.Unify_Completed_Date__c == null){//current completed date is empty, set default as today
            pr = new PageReference('/' + t.Id + '/e?close=1&nooverride=1&00N20000003jEtJ=' + System.today().format());
        }else{//completed date is already filled, dont overwrite it
            pr = new PageReference('/' + t.Id + '/e?close=1&nooverride=1');
        }
        pr.getParameters().put('retURL', retUrl);
        return pr;
    }
}