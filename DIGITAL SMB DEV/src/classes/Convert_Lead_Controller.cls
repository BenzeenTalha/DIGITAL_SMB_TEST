// Created: 17-Jun-2010
// By: Darren Sabey
// ======Requirement======
// When a lead is converted allow the user to see all accounts that might be duplicates of the lead company.
// additionally override the standard convert page to enforce the selection of the duplicate account.   
    
// Not with sharing - does not respect sharing setting and rules by design
public class Convert_Lead_Controller {

    // Private member variables
    private Lead lead;
    private List<SelectableAccount> accountMatches;
    private List<SelectOption> accountSelectOptions;
    private List<SelectOption> convertedLeadStatuses;
    
    // Public bind variables used as part of lead conversion
    public Account account {get; set;}
    public Task task {get; set;}
    public String matchedAccountId {get; set;}    
    public String opportunityName {get; set;}
    public String convertedLeadStatus {get; set;}    
    public Boolean sendEmailToOwner {get; set;}
    public Boolean doNotCreateOpportunity {get; set;}    
    public Boolean sendNotificationEmail {get; set;}
    public Boolean reminderRequired {get; set;}
    
    // Controls command button appearance on convert page
    public Boolean showBackButton {get; set;}
    
    // Constructor
    public Convert_Lead_Controller(ApexPages.StandardController sc) {
        this.lead = [Select Id, Name, Company, PostalCode From Lead Where Id = : sc.getId()];
        this.account = new Account(OwnerId=UserInfo.getUserId());
        this.task = new Task();
        this.opportunityName = this.lead.Company + '-';
        this.sendEmailToOwner = true;
    }
         
    public List<SelectableAccount> getAccountMatches() {
        if (accountMatches == null) {
            accountMatches = new List<SelectableAccount>();        
            String companySearchTerm = '%' + this.lead.Company + '%';
            String postcodeSearchTerm = '%' + this.lead.PostalCode + '%'; 
            for (Account acc : [Select Id, Name, BillingStreet, BillingCity, BillingPostalCode, Owner.Name, IsPersonAccount From Account Where Name Like :companySearchTerm And BillingPostalCode Like :postcodeSearchTerm Order By Name]) {
                accountMatches.add(new SelectableAccount(acc));
            }
        }
        return accountMatches;
    }

    public List<SelectOption> getAccountSelectOptions() {
        accountSelectOptions = new List<SelectOption>();
        accountSelectOptions.add(new SelectOption(this.lead.Id, 'Create New Customer: ' + this.lead.Company));
        if (accountMatches != null) {
            for (SelectableAccount sa : accountMatches) {
                if (sa.selected) {
                    accountSelectOptions.add(new SelectOption(sa.account.Id, 'Attach to Existing: ' + sa.account.Name));
                    matchedAccountId = sa.account.Id;
                }
            }
        }
        return accountSelectOptions;
    }
    
    public List<SelectOption> getConvertedLeadStatuses() {
        // Possible lead converted statuses to display in picklist
        if (convertedLeadStatuses == null) {
            convertedLeadStatuses = new List<SelectOption>();
            for (LeadStatus ls : [Select Id, MasterLabel From LeadStatus Where IsConverted = true]) {
                convertedLeadStatuses.add(new SelectOption(ls.MasterLabel, ls.Masterlabel));
            }
        }
        return convertedLeadStatuses;
    }
    
    public PageReference convertLead() {
        // Set savepoint in case we need to rollback
        Savepoint sp = Database.setSavepoint();
        // Used to determine whether updates are needed to contact and opportunity
        Boolean mergeExistingAccount = false;
        // Code to covert the lead
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        // Owner id will either be existing owner or current user (depends if we are merging existing account)
        lc.setOwnerId(account.OwnerId);
        // Set account id to merge with if applicable
        if (matchedAccountId != null) {
            if (matchedAccountId.startsWith('001')) {
                lc.setAccountId(matchedAccountId);
                mergeExistingAccount = true;
            } 
        }
        // Determine whether we need to create an opportunity
        if (doNotCreateOpportunity) {
            lc.setDoNotCreateOpportunity(true);
        } else {
            lc.setDoNotCreateOpportunity(false);
            lc.setOpportunityName(opportunityName);
        }
        lc.setConvertedStatus(convertedLeadStatus);
        lc.setSendNotificationEmail(sendEmailToOwner);
        Database.LeadConvertResult lcr;
        try {
            // Call database method to convert lead
            lcr = Database.convertLead(lc);
        } catch (Exception e) {
            // There was an exception so display the error message to the user
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            Database.rollback(sp);              
            return null;
        }
        if (lcr.isSuccess()) {
            // Update the owner of the contact and opportunity if we merged into existing account
            if (mergeExistingAccount) {
                if ( ! updateOwnerFields(lcr, sp) ) {
                    return null;
                }
            }
            // Create task using data entered into form fields
            //createTask(lcr);
            // Navigate the user to the new account
            return new PageReference ('/' + lcr.getAccountId());                    
        } else {
            // Navigate the user to the lead convert screen displaying the error message
            for (Database.Error error : lcr.getErrors()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, error.getMessage()));              
            }   
            return null;
        }
    }
    
    private Boolean updateOwnerFields(Database.LeadConvertResult lcr, Savepoint sp) {
        // Add sharing rule to give portal user read only access to account
        if (account.OwnerId != UserInfo.getUserId()) {
            AccountShare accShare = new AccountShare();
            accShare.AccountId = lcr.getAccountId();
            accShare.UserOrGroupId = UserInfo.getUserId();
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            Account at = [Select Id, OwnerId from Account where id = :lcr.getAccountId()];
            try {
                Database.SaveResult result = Database.insert(accShare);
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
                Database.rollback(sp);
                return false;
            }
        }
        // Make portal user owner of new contact
        Contact c = new Contact(id=lcr.getContactId());
        c.OwnerId = UserInfo.getUserId();
        try {
            Database.SaveResult result = Database.update(c);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return false;
        }
        // Make portal user owner of new opportunity
        if ( lcr.getOpportunityId() != null ) {
            Opportunity o = new Opportunity(id=lcr.getOpportunityId());
            o.OwnerId = UserInfo.getUserId();
            // Hack - required to work around custom validation rule
            o.TotalOpportunityQuantity = 0;
            try {
                Database.SaveResult result = Database.update(o);
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
                Database.rollback(sp);
                return false;
            }       
        }
        return true;
    }
    /*
    private void createTask(Database.LeadConvertResult lcr) {
        // Create task and associate with contact and account
        Task t = new Task();
        t.Type = task.Type;
        t.Subject = task.Subject;
        t.ActivityDate = task.ActivityDate;
        t.First_Level__c = task.First_Level__c;
        t.Second_Level_Reason__c = task.Second_Level_Reason__c;
        t.Description = task.Description;
        t.Status = task.Status;
        t.Priority = task.Priority;
        t.ReminderDateTime = task.ReminderDateTime;
        t.IsReminderSet = task.IsReminderSet;
        t.WhoId = lcr.getContactId();
        t.OwnerId = UserInfo.getUserId();
        Database.SaveResult result = Database.insert(t);
    }
    */
    public PageReference determineLandingPage() {
        // If there are no account matches navigate directly to convert lead page
        accountMatches = this.getAccountMatches();
        if (accountMatches.size() == 0) {
            PageReference p = Page.Convert_Lead;
            p.getParameters().put('id', lead.Id);
            p.setRedirect(true);
            return p;
        } else {
            // Matches exist so allow the default navigation to the search page
            showBackButton = true;
            return null;
        }
    }
    
    public PageReference navigateToConvertLead() {
        // If an account has been selected then set account to existing account (OwnerId is key field)
        for (SelectableAccount sa : accountMatches) {
            if (sa.selected) {
                account = sa.account;
            }
        }
        // Navigate to the convert lead page
        return Page.Convert_Lead;   
    }
    
    public PageReference navigateToSearch() {
        // Navigate back to search page
        return Page.Convert_Lead_Search;
    }
    
    public class SelectableAccount {
        public Account account {get; set;}
        public Boolean selected {get; set;}
        public SelectableAccount(Account acc) {
            this.account = acc;
        }
    }
    
    private static testMethod void testNewAccount() {
        
        // Set up the data
        Lead lead1 = new Lead();
        lead1.FirstName = 'TESTFIRSTNAMEXXX';
        lead1.LastName = 'TESTLASTNAMEXXX';
        lead1.Company = 'TESTCOMPANYXXX';
        insert lead1;
        
        // Set start page
        Test.setCurrentPage(Page.Convert_Lead_Search);
        
        // Instantiate the controllers
        ApexPages.StandardController sc = new ApexPages.StandardController(lead1);
        Convert_Lead_Controller c = new Convert_Lead_Controller(sc);
        
        // Number of matching accounts should be zero
        List<SelectableAccount> matchedAccounts = c.getAccountMatches();
        System.assertEquals(0, matchedAccounts.size());
        
        // Search page should be skipped
        PageReference p = c.determineLandingPage();
        System.assert( ! p.getUrl().contains('Convert_Lead_Search?') );
        
        // Set next page to be convert lead page
        Test.setCurrentPage(Page.Convert_Lead);
        
        // Check that options were returned for the status field
        List<SelectOption> statusOptions = c.getConvertedLeadStatuses();
        System.assertNotEquals(0, statusOptions.size());
        
        // Check that options were returned for the account picklist
        List<SelectOption> acccountOptions = c.getAccountSelectOptions();
        System.assertEquals(1, acccountOptions.size());
        
        // Required lead fields
        c.doNotCreateOpportunity = false;
        c.sendNotificationEmail = true;
        c.sendEmailToOwner = true;
        SelectOption status = statusOptions.get(0);
        c.convertedLeadStatus = status.getLabel();
        
        // Required task fields
        c.task.Status = 'Completed';
        c.task.Priority = 'High';
        
        // Convert lead
        p = c.convertLead();
        // User should be navigated to the account page
        System.assertNotEquals(null, p.getUrl());
    }
    
    private static testMethod void testMergeAccount() {
        
        // Set up the data
        Profile pr = [Select Id From profile Where name='Standard User']; 
        User u = new User(alias = 'standt', email='standarduser@testorgO2Courtesy.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = pr.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser@testorgO2Courtesy.com');
        insert u;
        // Account needs to be owned by a different user or the account share rule will fail
        System.runAs(u) {
            Account a1 = new Account();
            a1.Name = 'TESTCOMPANYXXX';
            a1.BillingStreet = 'Street';
            a1.BillingCity = 'City';
            a1.BillingPostalCode = 'PC1 1PC';
            insert a1;
        }
        // Create lead
        Lead lead1 = new Lead();
        lead1.FirstName = 'TESTFIRSTNAMEXXX';
        lead1.LastName = 'TESTLASTNAMEXXX';
        lead1.Company = 'TESTCOMPANYXXX';
        lead1.PostalCode = 'PC1 1PC';
        insert lead1;
        
        // Set start page
        Test.setCurrentPage(Page.Convert_Lead_Search);
        
        // Instantiate the controllers
        ApexPages.StandardController sc = new ApexPages.StandardController(lead1);
        Convert_Lead_Controller c = new Convert_Lead_Controller(sc);
        
        // Number of matching accounts should be one
        List<SelectableAccount> matchedAccounts = c.getAccountMatches();
        System.assertEquals(1, matchedAccounts.size());
        
        // Search page should displayed
        PageReference p = c.determineLandingPage();
        System.assertEquals(p, null);
        
        // Increase code coverage...
        c.navigateToSearch();
        
        // Set next page to be convert page
        Test.setCurrentPage(Page.Convert_Lead);
        
        // Select an account
        SelectableAccount account = matchedAccounts.get(0);
        account.selected = true;
        c.navigateToConvertLead();
        
        // Check that options were returned for the status field
        List<SelectOption> statusOptions = c.getConvertedLeadStatuses();
        System.assertNotEquals(0, statusOptions.size());
        
        // Check that options were returned for the account picklist
        List<SelectOption> acccountOptions = c.getAccountSelectOptions();
        System.assertEquals(2, acccountOptions.size());
        
        // Select the account to merge
        c.matchedAccountId = account.account.Id;
        
        // Required lead fields
        c.doNotCreateOpportunity = false;
        c.sendNotificationEmail = true;
        c.sendEmailToOwner = true;
        SelectOption status = statusOptions.get(0);
        c.convertedLeadStatus = status.getLabel();
        
        // Required task fields
        c.task.Status = 'Completed';
        c.task.Priority = 'High';
        
        // Convert lead
        p = c.convertLead();
        // User should be navigated to the account page
        System.assertNotEquals(null, p.getUrl());
    }
}