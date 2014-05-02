public without sharing class CaseSharing 
{
    public static void ShareCaseManually(List<Id> lstCaseId, List<Id> lstuserOrGroupId)
    {
    	
    	List<CaseShare> lstCaseShare = new List<CaseShare>();
    	
    	for (integer i=0;i<lstCaseId.size();++i)
    	{
			CaseShare cs = new CaseShare();
    		cs.Caseid=lstCaseId[i];
    		cs.UserOrGroupId = lstuserOrGroupId[i];
    		cs.CaseAccessLevel='Read';
    		//cs.RowCause='Manual';
    		lstCaseShare.add(cs);
    	}
    	
    	system.debug('**lstCaseShare=' + lstCaseShare);
    	insert lstCaseShare;
    }

}