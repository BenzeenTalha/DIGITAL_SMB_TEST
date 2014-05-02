public with sharing class O2OnlineContactUsExtension {
    
    //public variables/properties
    public ApexPages.StandardController leadController;
    public Lead newlead {get;set;}
    
    public String firstName     {get;set;}
    public String surname       {get;set;}
    public String phone         {get;set;}
    public String email         {get;set;}
    public String interestedIn  {get;set;}
    
    //get link from custom setting O2OnlineContactUs
    String customSettingLink = (O2OnlineContactUs__c.getInstance('All')!=null ? O2OnlineContactUs__c.getInstance('All').O2OnlineContactUsField__c : null);
        
    //constructor methods
    public O2OnlineContactUsExtension(ApexPages.StandardController controller) {
        this.newlead = (Lead)controller.getRecord();
        this.leadController = controller;
    }
    
    public O2OnlineContactUsExtension() {}
    
    public O2OnlineContactUsExtension(O2OnlineMainController controller) {
        this.newlead = new Lead();
        this.leadcontroller = new ApexPages.StandardController(newlead);
    }

    //subclasses
    public class O2OnlineException extends Exception {}
    
    //action methods
    public PageReference saveRecord() {
        try {
            

            newlead.LeadSource = Apexpages.currentPage().getParameters().get('LeadSource');
            //newlead.LeadSource = 'Fixed Lead';
            
            //check required fields
            /*if (newlead.Existing_Customer__c && (newlead.DISE_Account_No__c==null || newlead.DISE_Account_No__c=='') && (newlead.DISE_Group_Code__c==null || newlead.DISE_Group_Code__c=='')) {
                throw new O2OnlineException('Account Number or Mobile Number are required. Please enter either your Account Number or your Mobile Phone Number.');
            }
            if (newlead.Mobiles__c && (newlead.Voice_Connections__c==null || newlead.Voice_Connections__c < 0)) {
                throw new O2OnlineException('Number of Mobiles is required. Please enter a numeric value.');
            }*/
            
            Database.Dmloptions dmlopt = new Database.Dmloptions();
            dmlopt.assignmentRuleHeader.useDefaultRule = true;
            dmlopt.emailHeader.triggerAutoResponseEmail = true;
            newlead.setOptions(dmlopt);
            newlead.O2_Sector__c = 'Other';
            insert newlead;
        }
        catch (O2OnlineException e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));return null;}
        catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));return null;}
        return Page.O2OnlineContactUsResult;
    }
    
    
    //#
    //# Insert "All In" Lead
    //# 
    public PageReference allInLead() 
    {
        
        try 
        {
             
            //# 
            //# Custom validation process (because of the radio buttons we can not use standard SF validation check)
            //#
            
            if (interestedIn == null)                   newLead.addError('I\'m interested in: You must enter a value');
            else newlead.Products_of_Interest__c = interestedIn;
            
            if (firstName == null || firstName == '')   newLead.addError('Name: You must enter a value');
            else newlead.FirstName = firstName;
            
            if (surname == null || surname == '')       newLead.addError('Surname: You must enter a value');
            else newlead.LastName = surname;
            
            if (phone == null || phone == '')           newLead.addError('Phone number: You must enter a value');
            else newlead.Phone = phone;
            
            if (email == null || email == '')           newLead.addError('Email address: You must enter a value');
            else newlead.Email = email;
            
            //# 
            //# If all fields are entered, continue with the Lead insertion. 
            //# If that is not the case than display error messages.
            //#             
            if(newlead.Products_of_Interest__c != null && newlead.FirstName != null && newlead.LastName != null && newlead.Phone != null && newlead.Email != null)
            {

                try
                {
                    HttpRequest req = new HttpRequest();
                    if (customSettingLink!=null) req.setEndpoint(customSettingLink);
                    req.setMethod('GET');
                 
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                 
                    System.debug('****body=' + res.getBody());
                }
                catch(exception E)
                {
                    System.debug('****req error= ' + e.getMessage());
                }            
            
                newlead.LeadSource = 'All In - Online';
                
                Database.Dmloptions dmlopt                  = new Database.Dmloptions();
                dmlopt.assignmentRuleHeader.useDefaultRule  = true;
                dmlopt.emailHeader.triggerAutoResponseEmail = true;
                newlead.setOptions(dmlopt);
                // newlead.O2_Sector__c = 'Other';
                
                insert newlead;
                
                /*
                    //PageReference pageRef = new PageReference('http://view.atdmt.com/action/zo2bsm_SMECallBackclick_1');
                    PageReference pageRef = new PageReference('http://www.google.com');
                    pageRef.setRedirect(false);
                    pageRef.getContent();
                */
                
                
                return Page.O2OnlineContactUsResult;
            }
            else return null;

        }
        catch (O2OnlineException e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));return null;}
        catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));return null;}
        
    }
    
    
    /*
    public PageReference saveSharerLead() {
        try {
            newlead.LeadSource = 'Fixed Lead';
            //check required fields
            if (newlead.Salutation==null || newlead.Salutation=='') addError('Salutation is required. Please enter either your Salutation');
            if (newlead.FirstName==null || newlead.FirstName=='') addError('First Name is required. Please enter either your First Name');
            
            Database.Dmloptions dmlopt = new Database.Dmloptions();
            dmlopt.assignmentRuleHeader.useDefaultRule = true;
            dmlopt.emailHeader.triggerAutoResponseEmail = true;
            newlead.setOptions(dmlopt);
            newlead.O2_Sector__c = 'Other';
            if (ApexPages.hasMessages()){
                 return null;
            }
            else {
            insert newlead;
            }
        }
        catch (O2OnlineException e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));return null;}
        catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));return null;}
        return Page.O2OnlineContactUsResult;
    }
    public void addError(String strError) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
    }
    */
    //added check to see whether live tracking should be enabled
    public String getLiveTrackingEnabled() {
            if (OnlineGeneralSettings__c.getInstance('Enable Live Tracking')!=null)
                    return OnlineGeneralSettings__c.getInstance('Enable Live Tracking').Value__c;
            else return '';
    }
    
    
    //# 
    //# Create "Product of Interest" options
    //#
    public List<SelectOption> getProductsOfInterest() 
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('All In with Smart Phone', '£52.97 with a smartphone')); 
        options.add(new SelectOption('All In with SIM',         '£38.86 with a sim card'));    
        
        return options;
    }

}