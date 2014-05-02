public with sharing class QuickCreateContactOnCaseController 
{
	public string caseId {get; set;}
	public Contact con {get; set;}
	public Case theCase {get; set;}
	
	public QuickCreateContactOnCaseController()
	{
        caseId = ApexPages.currentPage().getParameters().get('CaseId');
        theCase = [Select E_mail__c, AccountId, Id, Account.Status__c, Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet
        			 From Case Where Id = :caseId];
        con = new Contact(Email = theCase.E_mail__c,
        				  AccountId = theCase.AccountId,
        				  Buying_Role__c = 'Other',
        				  Title = 'Customer Service Contact'); 
        
        if(theCase.AccountId != null)
        {
        	con.MailingCity = theCase.Account.BillingCity;
        	con.MailingCountry = theCase.Account.BillingCountry;
        	con.MailingPostalCode = theCase.Account.BillingPostalCode;
        	con.MailingState = theCase.Account.BillingState;
        	con.MailingStreet = theCase.Account.BillingStreet;
        }
        
    }
    
    public PageReference saveContact()
    {
    	try
    	{
	    	insert con;
	    	theCase.ContactId = con.Id;
	    	update theCase;
    	}
    	catch (Exception e)
    	{
    		ApexPages.addMessages(e);
            return ApexPages.currentPage();
    	}
    	
    	Pagereference casePage = new PageReference('/' + theCase.Id);
        casePage.setRedirect(true);
		return casePage;
    }
    
    public PageReference cancelContact()
    {
    	Pagereference casePage = new PageReference('/' + theCase.Id);
        casePage.setRedirect(true);
		return casePage;
    }
}