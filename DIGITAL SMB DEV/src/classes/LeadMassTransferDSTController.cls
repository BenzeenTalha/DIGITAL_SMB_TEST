public class LeadMassTransferDSTController 
{
	
	private string selectedUserId;
	private Boolean SendEmail;
	private List<string> lstLeadId;
	private string selectedRecordIds;
	private string returl;
	
	
	public LeadMassTransferDSTController() 
	{
		SendEmail=true;
		selectedRecordIds = ApexPages.currentPage().getParameters().get('selectedRecords');
		returl = ApexPages.currentPage().getParameters().get('retURL');
		if (selectedRecordIds==null)
		{
			lstLeadId=new List<string>();
		}
		else
		{
			lstLeadId = selectedRecordIds.split(',');
		}
	}
	
	
	public List<SelectOption> getDSTUsers() 
	{
        List<SelectOption> options = new List<SelectOption>();
        
        string ProfileId =[select Id from Profile where Name='DST Account Partner Profile'][0].Id;
        
        		
        List<User> lstUser =[select Id,Name from User where IsActive=true and ProfileId =: ProfileId];
        for (User tmpUser : lstUser)
        {
        	 options.add(new SelectOption(tmpUser.Id,tmpUser.Name));
        }
        		
        return options;
    }
    	
    public string getSelecteduserId()
    {
    	return selectedUserId;
   	}
   	
   	public void setSelecteduserId(string tmpUserId)
   	{
   		selectedUserId=tmpUserId;
   	}
   	
   	
   	public pagereference Save()
   	{
   		
   		List<Lead> lstLead =[select Id,OwnerId from Lead where Id in : lstLeadId];
   		
   		for (Lead tmpLead : lstLead)
   		{
   			tmpLead.OwnerId=selectedUserId;
   		}
   		
   		if (lstLead.size()>0) 
   		{	
   			update lstLead;
   			SendEmailToOwner();
   			
   		}
   		
		PageReference pageRef = new PageReference(returl);
		pageRef.setRedirect(true);
		return pageRef;   		

   	}
   	
   	public pagereference Cancel()
   	{
		PageReference pageRef = new PageReference(returl);
		pageRef.setRedirect(true);
		return pageRef;   		
   	}
   	
   	
   	public Boolean getSendEmail()
   	{
		return SendEmail;   		
   	}
   	
   	public void setSendEmail(Boolean tmpSendEmail)
   	{
   		SendEmail=tmpSendEmail;
   	}
   	
   	public integer getRecordNo()
   	{
   		return lstLeadId.size();
   	}
   	
   	public Boolean getButtonDisabled()
   	{
   		if (lstLeadId.size()==0)
   			return true;
   		else
   			return false;
   	}
   	
   	private void SendEmailToOwner()
   	{
   		
   		string subject;
   		string body;
   		
   		User NewOwner =[select Id,Email from User where Id = : selectedUserId][0];
   		List<String> toAddresses = new List<String>();
   		toAddresses.add(NewOwner.Email);
   		
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        if (lstLeadId.size()==1)
        {
        	subject='Lead has been transfered to you';
        	body='One Lead has been transfered to you. Please check.';
        }
        else
        {
        	subject='Some Leads have been transfered to you';	
        	body=string.valueOf(lstLeadId.size()) + 'Leads have been transfered to you. Please check.';
        }
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   		
   		
   	}
   	
}