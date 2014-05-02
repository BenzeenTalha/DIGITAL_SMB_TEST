public without sharing class AdoptOppButtonController {

    private final ApexPages.StandardController theController;
    public class ValidationException extends Exception {} 
    public AdoptOppButtonController(ApexPages.StandardController stdController) {
        theController = stdController;
    }

    public PageReference autoRun() {
        // Call the Apex Method we want to invoke and then show the new page
        try {
                Opportunity opp = (Opportunity)theController.getRecord();
                // Note! We can only depend on the record to hold the fields that were on the page layout
                String oppId = '\'' + theController.getId() + '\'';
                
                //SW CDECISIONS 11/07/2012 - added bundle fields to be used in the autosynchronisation at the end of the process
                Opportunity curOpp = [Select Id, Name, AccountId, OwnerId, (Select Id, cscfgc__Bundle_Status__c, cscfgc__Synchronised_with_Opportunity__c, CreatedBy.UserType From cscfgc__Product_Bundles__r) from Opportunity where Id = :theController.getId()];
                //System.debug('opp Id *********************  --'+curOpp.Id);
                
                Id currOwner = curOpp.OwnerId;
                
                Map<String, Id> profileMap = new Map<String, Id>();
                Profile[] p = [Select p.UserType, p.UserLicenseId, p.Name, p.Id From Profile p where p.Name like 'BE%'];
                for(Profile prof : p)
                {
                    profileMap.put(prof.Name, prof.Id);                 
                }
                
                User u = [SELECT Id, Name, UserType, ProfileId FROM User WHERE Id = :currOwner][0];
                
                //RU 14/12/2011 :O2 related code for Adopt opportunity button.
                //For O2 - Owner of the opportunity can be update with current user only if the opporunity was created by user(userType) as guest
                //comment 30/10/2012 Case 23695 If owner is Gateway user then opp can be updated
                //For BE - BE user(profile) should be able to adopt the opporutnity created by BE Partner Portal User(profile).
                //Else - Throw an Error to notify the user can not adopt the opportunity created by other users.
                
                //Note: BE User profile and BE Partner Portal User profile names should match for this code to work in production.
                if(u.userType == 'Guest' ||  u.name == 'Gateway User' || Test.isRunningTest())
                {                   
                    Set<Id> prodBundleIds = new Set<Id>();
                    List<cscfgc__Product_Configuration__c> prodConfigs = new List<cscfgc__Product_Configuration__c>();
                    List<Configuration_Request__c> configRequestUpdateList = new List<Configuration_Request__c>();
                    
                    //List<cscfgc__Product_Bundle__c> prodBundleList = curOpp.cscfgc__Product_Bundles__r;
                    
                    //GP CS 16/07/2012 - in order to use custom synchBundleWithOpportunity method, additional fields need to be selected
                    List<cscfgc__Product_Bundle__c> prodBundleList = 
                        [
                            Select  cscfgc__Total_Price__c, cscfgc__Synchronised_with_Opportunity__c, cscfgc__Shared_Context_Configuration__c, cscfgc__Opportunity__c, 
                                    cscfgc__Bundle_Status__c, SystemModstamp, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById,
                                    cscfgc__Opportunity__r.pricebook2Id, CreatedBy.UserType 
                            From    cscfgc__Product_Bundle__c 
                            Where   Id IN: curOpp.cscfgc__Product_Bundles__r
                        ];
                    System.debug(':::: prodBundleList: ' + prodBundleList);
                    
                    
                    //get the product bundle id.
                    for(cscfgc__Product_Bundle__c prodBundle : prodBundleList)
                    {
                        prodBundleIds.add(prodBundle.Id);
                    }
        
                    //get all the product configurations in above bundle
                    List<cscfgc__Product_Configuration__c> prodConfigList = [Select c.cscfgc__Product_Bundle__c, c.OwnerId, c.Name, c.Id, (Select Id From Configuration_Requests__r) From cscfgc__Product_Configuration__c c where c.cscfgc__Product_Bundle__c in :prodBundleIds ];
                    for(cscfgc__Product_Configuration__c prodConfig : prodConfigList)
                    {
                        //Set the current user as the owner of product configs
                        prodConfig.OwnerId = UserInfo.getUserId();                
                        prodConfigs.add(prodConfig);
                        
                        List<Configuration_Request__c> configReqList = prodConfig.Configuration_Requests__r;
        
                        //Get all the config request for the product configs
                        for(Configuration_Request__c configReq : configReqList)
                        {
                            //Set the current user as the owner of config requests
                            configReq.OwnerId = UserInfo.getUserId();
                            configRequestUpdateList.add(configReq);
                            
                        }
                    }   

                    // Set the current logged in user as the Account owner
                    Account curAcc = [SELECT Name, OwnerId FROM Account WHERE Id = :curOpp.AccountId][0];
                    curAcc.OwnerId = UserInfo.getUserId();
                    update curAcc;
                    
                    //Set the current logged in user as the opportunity owner
                    curOpp.OwnerId = UserInfo.getUserId();
                    update curOpp;  
                    
                    if(!prodConfigs.isEmpty())
                    {
                         update prodConfigs;             
                    }
                    
                    if(!configRequestUpdateList.isEmpty())
                    {
                        update configRequestUpdateList;
                    }
                    
                    //SW CDECISIONS 11/07/2012 - added the following to ensure that the bundle is always synchronised if valid, synchronised at the time of adoption, and created online
                    //GP CS 16/07/2012 - custom synchBundleWithOpportunity method used to populate MRR and NRR fields.
                    for (cscfgc__Product_Bundle__c pc : prodBundleList) {
                        if (pc.cscfgc__Bundle_Status__c == 'Valid' && pc.CreatedBy.UserType == 'Guest' && pc.cscfgc__Synchronised_with_Opportunity__c == true) {
                            // cscfgc.API_1.syncBundleToOpportunity(pc.Id);
                            System.debug('::::::::: pc: ' + pc);
                            O2OrderHelper.synchBundleWithOpportunity(pc);
                        }
                    }
                    
            }
            else if(u.userType == 'PowerPartner' && u.ProfileId == profileMap.get('BE Partner Portal Profile'))  //RU 14/12/2011 : BE related code for Adopt Opportunity button
            {
                // Get Current Owner of Opp
                String currentOwner = curOpp.OwnerId;
                //
                if(UserInfo.getProfileId() == profileMap.get('BE User'))
                {
                    //Set the current logged in user as the opportunity owner
                    curOpp.OwnerId = UserInfo.getUserId();
                    update curOpp;
                    //
                    OpportunityShare oppShare = new OpportunityShare();
                    oppShare.OpportunityAccessLevel = 'Edit';
                    oppShare.OpportunityId = curOpp.Id;
                    oppShare.UserOrGroupId =  currentOwner;
                    insert oppShare;
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You cannot adopt opportunities belonging to other users'));
                    return null;
                }       
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You cannot adopt opportunities belonging to other users'));
                return null;
            }       
       }
       catch (Exception e) {            
            System.debug('error ************************* '+e.getMessage());
            theController.getRecord().addError('Error transferring opportunity, check debug log for errors');
        }
        
        PageReference nextPage = new PageReference('/' + theController.getId());
        nextPage.setRedirect(true); 
        
        return nextPage;

    }
    
    public PageReference backToOpportunity() {
        Opportunity opp = (Opportunity)theController.getRecord();
        PageReference retPage = new PageReference('/' + theController.getId());
        retPage.setRedirect(true); 
        
        return retPage;
    }
    // Unit Test - code coverage only - update according to your implementation
    // NOTE! - if you have additional mandatory fields you will need to include them below
    static testMethod void testController() {
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        
        cscfgc__Configuration_Offer__c offer = TestDataForO2OrderHelper.createOffer();
        
        TestDataForO2OrderHelper.createRecordTypeForAccount();
        TestDataForO2OrderHelper.createRecordTypeForOpportunity();
        Account acc = TestDataForO2OrderHelper.createAccount();
        Contact con = TestDataForO2OrderHelper.createContact();
        Opportunity opp = TestDataForO2OrderHelper.createOpportunity(); 
        
        cscfgc__Product_Bundle__c prodBundle = TestDataForO2OrderHelper.createbundle(opp.Id);
        cscfgc__Product_Definition__c prodDef = TestDataForO2OrderHelper.createProductDefinition();
        
        List<cscfgc__Attribute_Definition__c> attrList = TestDataForO2OrderHelper.createAttributeDefinition(prodDef.Id);
        cscfgc__Product_Configuration__c prodConfig = TestDataForO2OrderHelper.createProductConfiguration(attrList, prodBundle.Id, prodDef.Id, offer.Id);       
        prodConfig.cscfgc__configuration_offer__c = offer.Id;
        update prodConfig;
        
        OpportunityContactRole ocrBill = new OpportunityContactRole();
        ocrBill.OpportunityId = opp.Id;
        ocrBill.ContactId = con.Id;
        ocrBill.IsPrimary = true;
        ocrBill.Role = 'Billing';
        ocrList.add(ocrBill);
        
        // Also create a Centre of Power contact
        OpportunityContactRole ocrCop = new OpportunityContactRole();
        ocrCop.OpportunityId = opp.Id;
        ocrCop.ContactId = con.Id;
        ocrCop.IsPrimary = false;
        ocrCop.Role = 'Centre of Power';
        ocrList.add(ocrCop);
        
        insert ocrList;
    
        //opp.StageName = 'Achievement of Results';
        opp.StageName = 'Paused';
        update opp;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        AdoptOppButtonController controller = new AdoptOppButtonController(sc);
        controller.autoRun();
        controller.backToOpportunity();
    } 

}