public with sharing class UnifyProductConfigurationEditOverrideCon{
    private final ApexPages.StandardController theController;
    public cscfgc__Product_Configuration__c pc {get;set;}

    public UnifyProductConfigurationEditOverrideCon(ApexPages.StandardController stdController) {
        theController = stdController;
        this.pc = (cscfgc__Product_Configuration__c)stdController.getRecord();
        this.pc = [select  Id, cscfgc__Product_Definition__r.Name, cscfgc__Product_Bundle__r.cscfgc__Opportunity__r.RecordType.Name from cscfgc__Product_Configuration__c where Id = :pc.Id];
    }

    public PageReference autoRun() {
        PageReference nextPage;
        if(pc.cscfgc__Product_Bundle__c != null && pc.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c != null && pc.cscfgc__Product_Bundle__r.cscfgc__Opportunity__r.RecordType.Name == 'Unify'){
            return null;   
        } else {
            nextPage = new PageReference('/' + pc.Id + '/e?nooverride=1');
            nextPage.getParameters().putAll(ApexPages.currentPage().getParameters());
	        nextPage.setRedirect(false);
	        return nextPage;
        }
    }
}