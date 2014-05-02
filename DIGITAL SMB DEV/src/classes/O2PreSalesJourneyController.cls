public with sharing class O2PreSalesJourneyController {

    public String selectOperation {get; set;}   // 1 = customer search; 2 = resume order;
    public String ordReqNum {get; set;}
    public Account acc {get; private set;}
    public Contact con {get; private set;}
    public Integer numCRMAccsFound {get; private set;}
    public List<selectOption> foundAccs {get; private set;}
    public Boolean foundInDISE {get; private set;}

    public String MobPhoneNum {get; set;}
    public String CompName {get; set;}
    public String PostCode {get; set;}
    public String oppType {get; set;}
    public Opportunity opp {get; private set;}
    public Boolean DPADetailsConf {get; set;}
    public Id accId {get; set;}
    public transient String errorMessage {get; set;}
    //addded to check in case no customer accounts from dise

    public O2DISEAccountHelper.DISEAccount DiseAcc {get; private set;}
    public O2DISEAccountHelper.DPAChecks DpaChk {get; private set;}

    public O2PreSalesJourneyController()
    {
        foundInDISE = false;
        DPADetailsConf = false;
        opp = new Opportunity();
    }

    /*** make callout to DISE and find SF accounts ***/

    public void searchAccount()
    {
        numCRMAccsFound = null;
        foundInDISE = false;
        DPADetailsConf = false;
        foundAccs = null;
        accId = null;
        acc = null;
        con = null;
        oppType = null;
        opp = new Opportunity();
        List<Account> accs = new List<Account>();

        if(!Test.isRunningTest() && System.Label.O2_PRESALES_JOURNEY_IN_TESTING == 'N')
        {
            if(String.isBlank(MobPhoneNum) && String.isBlank(CompName))
            {
                errorMessage = 'Please enter mobile phone number or company name to enable Customer Search.';
                return;
            }
            DiseAcc = String.isBlank(MobPhoneNum) ? null : O2DISEAccountHelper.getDISEAccount(MobPhoneNum);
            if(DiseAcc != null)
            {
                foundInDISE = true;
                DpaChk = O2DISEAccountHelper.getDPAChecks(DiseAcc.accountNumber);
                accs = O2AccountHelper.getAccounts(DiseAcc.accountNumber, CompName, PostCode);

                // DISE destroys decimal point so correct
                if(DiseAcc.monthlyLineRentalFee != null) DiseAcc.monthlyLineRentalFee = DiseAcc.monthlyLineRentalFee/100.0;
                if(DpaChk.lastInvoiceAmount != null) DpaChk.lastInvoiceAmount = DpaChk.lastInvoiceAmount/100.0;
            }
            else
            {
                errorMessage = 'No match found in DISE.';
                if(String.isNotBlank(CompName) || String.isNotBlank(PostCode))
                {
                    accs = O2AccountHelper.getAccounts(null, CompName, PostCode);
                }
            }
        }

        if(Test.isRunningTest() || System.Label.O2_PRESALES_JOURNEY_IN_TESTING == 'Y')
        {
            Set<id> accIds = new Set<id>();
            if(String.isNotBlank(CompName) || String.isNotBlank(PostCode))
            {
                accs = O2AccountHelper.getAccounts(null, CompName, PostCode);
            }
        }

        numCRMAccsFound = accs.size();

        System.debug('numCRMAccsFound=' + numCRMAccsFound);

        if(numCRMAccsFound == 0)
        {
            acc = new Account(Name = CompName, Mobile__c = MobPhoneNum, BillingPostalCode = PostCode, Type = 'Customer', NumberOfEmployees = 1);
            con = new Contact(Phone = MobPhoneNum);
            if(foundInDISE)
            {
                copyDISEFields();   // if DISE account found/populated, values take precedence over those entered by user
                errorMessage = 'No match found in SFDC.';
            }
            else
            {
                errorMessage = 'Not currently a customer.';
            }
        }
        if(numCRMAccsFound == 1)
        {
            acc = accs.get(0);
            con = acc.Contacts.isEmpty() ? new Contact() : acc.Contacts.get(0);
        }
        if(numCRMAccsFound > 1)
        {
            foundAccs = new List<selectOption>();
            for(Account a : accs)
            {
                foundAccs.add(new selectoption(a.id, '(DISE)' + A.DISE_Account_No__c + ' - ' + a.Name + ', ' + a.BillingStreet + ', ' + a.BillingPostalCode));
            }
        }
    }

    /*** fetch selected account when multiple options ***/

    public void accountSelected()
    {
        if(String.isBlank(accId)) return;
        acc =  O2AccountHelper.getAccountsFromIds(new Set<id>{accId}).get(0);
        con = acc.Contacts.isEmpty() ? new Contact() : acc.Contacts.get(0);
        numCRMAccsFound = 1;
    }

    /*** save data not present in SF and proceede to Opp ***/

    public void saveNew()
    {
        if(!getCheckAccConData()) { errorMessage = 'Please fill out all fields.'; return; }
        if(!allowProgression()) { errorMessage = 'Please confirm DPA details.'; return; }

        insert acc;
        con.AccountId = acc.id;
        insert con;
        if(foundInDISE)
        {
            createTask();
        }
        numCRMAccsFound = 1;
    }

    /*** save data not present in SF and proceede to Case ***/

    public Pagereference saveNewCase()
    {
        saveNew();
        if(String.isNotBlank(errorMessage))
        {
            return null;
        }
        return new Pagereference(caseURL_String());
    }

    /*** Case page progresion ***/

    public Pagereference casePageProgression()
    {
        if(!allowProgression()) { errorMessage = 'Please confirm DPA details.'; return null; }
        return new Pagereference(caseURL_String());
    }

    /*** Case page ***/

    public String caseURL_String()
    {
        return '/500/e?RecordType=' + Cache.RecordTypeId('Case.Customer Request') + '&ent=Case&def_account_id=' + (String) acc.id;
    }

    /*** create task to log DPA check result ***/

    public id createTask()
    {
        Task t = new Task(Description = 'Automated activity indicating if DPA check was completed.',
                            OwnerId = UserInfo.getUserId(),
                            Status = 'Completed',
                            Subject = 'DPA Check Completed',
                            Type = 'Call',
                            WhatID = acc.id,
                            RecordTypeId = Cache.RecordTypeId('Task.Master'));
        insert t;
        return t.id;
    }

    /*** make sure all displayed fields are populated for account and contact ***/

    public Boolean getCheckAccConData()
    {
        // if no account is found in SF, check that all fields have been populated
        return acc.id != null || !(String.isBlank(acc.Name) || String.isBlank(acc.BillingStreet) || String.isBlank(acc.BillingCountry)
                                    || String.isBlank(acc.BillingCity) || String.isBlank(acc.BillingPostalCode)
                                    || String.isBlank(con.FirstName) || String.isBlank(con.LastName) || String.isBlank(con.Email) || String.isBlank(con.Phone));
    }

    /*** find order via order number and redirect to opp page (unless opp near closing - then message) ***/

    public pagereference findOrder()
    {
        if(String.isBlank(ordReqNum))
        {
            errorMessage = 'Please enter order number';
            return null;
        }
        Id oppId;
        for(Order__c o : [select Opportunity__c from Order__c where Order_Number__c = :ordReqNum limit 1]) oppId = o.Opportunity__c;    //this may seem convoluted, but avoids exceptions nicely
        if(oppId != null)
        {
            // stage check not needed anymore
            /*Set<String> lateStatus = new Set<String>{'Achievement of Results', 'Live', 'Completed', 'Cancelled', 'Closed Won', 'Closed Lost', 'Closed - No Opportunity',
                                                        'Disconnection', 'Archived', '4. Closed - Won', '99. Closed - Lost', 'Inactive', 'Active'};
            Opportunity opp = [select id, StageName, Name from Opportunity where id = :oppId];
            if(lateStatus.contains(opp.StageName)) errorMessage = 'This opportunity is in stage "' + opp.StageName + '".<br/>If you still wish to view it, click '
                                                                    + '<a href="/' + (String) oppId + '">here</a>';
            else return new pageReference('/' + (String) oppId);*/
            return new pageReference('/' + (String) oppId);
        }
        else errorMessage = 'No opportunity found.';
        return null;
    }

    /*** redirect user to pages from which they can start configuring product ***/

    public pageReference beginConfig()
    {
        if(!DPADetailsConf)
        {
            errorMessage = 'Please confirm DPA details.';
            return null;
        }
        if(String.isBlank(oppType) || String.isBlank(opp.Name))
        {
            errorMessage = 'Please enter both Type and Short Name / Reference.';
            return null;
        }

        if(oppType == 'simple')
        {
            Id rtId = Cache.RecordTypeId('Opportunity.Default');

            String msUrl = '';
            //List<String> prodCat =  String.isNotBlank(opp.Product_Categories__c) ? opp.Product_Categories__c.split(';') : new List<String>();
            //for(String s : prodCat) msUrl += '&00NW0000000H4qx=' + EncodingUtil.urlEncode(s,'UTF-8');

            /* passing Product Category seems redundant for Deafult opp since it's not even in the page layout, so I have left it out
            / if you need to do it, pagereference will delete repeated appearance of the same parameter :(
            / to resolve, try having a blank commandButton with a onclick javascript window.open, and have this method behave like a string getter */

            return new Pagereference('/006/e?accid=' + (String) acc.id + '&RecordType=' + (string) rtId + '&opp3=' + EncodingUtil.urlEncode(opp.Name,'UTF-8') + '&ent=Opportunity' + msUrl);
        }
        if(oppType == 'complex')
        {
            Id rtId = Cache.RecordTypeId('Opportunity.Configurator');
            opp.RecordTypeId = rtId;
            opp.AccountId = acc.Id;
            opp.StageName = 'Awareness of Needs';
            opp.CloseDate = Date.today().addMonths(1);
            insert opp;

            return new Pagereference('/apex/ProductBundleBuilder?CF00N200000030zhV=' + EncodingUtil.urlEncode(opp.Name,'UTF-8')
                                        + '&CF00N200000030zhV_lkid=' + (string) opp.Id
                                        + '&retURL=%2F' + (string) opp.Id
                                        + '&scontrolCaching=1&sfdc.override=1');
        }
        return null;
    }

    /*** fill out fields for new records with data from DISE ***/

    public void copyDISEFields()
    {
        acc.DISE_Account_No__c = DiseAcc.accountNumber;
        acc.Name = DiseAcc.companyName;
        acc.BillingStreet = DiseAcc.streetAddress;
        acc.BillingCity = DiseAcc.city;
        acc.BillingCountry = DiseAcc.county;
        acc.BillingPostalCode = DiseAcc.postCode;
        con.Title = DiseAcc.contactTitle;
        con.FirstName = DiseAcc.contactFirstName;
        con.LastName = DiseAcc.contactLastName;
        //con.Phone = DiseAcc.contactPhone;
        con.Email = DiseAcc.contactEmail;
    }

    /*** DPA checks status ***/

    public Boolean allowProgression()
    {
        if(!foundInDISE)
        {
            DPADetailsConf = true;      // set as true so we can render rest of page
            return true;
        }
        return DPADetailsConf;
    }

    /*** DPA checks action ***/

    public void allowProgressionAction()
    {
        if(!foundInDISE) DPADetailsConf = true;     // set as true so we can render rest of page
        if(foundInDISE)
        {
            if(!DPADetailsConf) errorMessage = 'Please confirm DPA details.';
            else createTask();
        }
    }

    /*** allow user to select again between all matched accounts when multiple results are found ***/

    public void multipleBack()
    {
        numCRMAccsFound = foundAccs.size();
        accId = null;
        acc = null;
        con = null;
        DPADetailsConf = false;
        oppType = null;
        opp = new Opportunity();
    }

    /*** reset values when toggling between 'search customer'/'resume order' ***/

    public void resetValues()
    {
        ordReqNum = null;
        acc = null;
        con = null;
        numCRMAccsFound = null;
        foundAccs = null;
        foundInDISE = false;

        MobPhoneNum = null;
        CompName = null;
        PostCode = null;
        oppType = null;
        opp = new Opportunity();
        DPADetailsConf = false;
        accId = null;

        DiseAcc = null;
        DpaChk = null;
    }


    /****************  TEST UTIL *******************/

    public void setDiseAccTEST()
    {
        if(Test.isRunningTest())
        {
            DiseAcc = new O2DISEAccountHelper.DISEAccount();
            acc = new Account();
            con = new Contact();
        }
    }
    // I'm also using this as an empty action for actionSupport because its behaviour is faulty :P

}