public with sharing class UnifyAddSiteController {
    
    public Opportunity opp {get; set;}
    public Location__c loc {get;set;}
    public string chosenOpt {get;set;}
    public LocationElement[] locsList {get;set;}
    public boolean hasCentralSite {get;set;}
    
    public class LocationElement{
        public Location__c loc {get;set;}
        public boolean selected {get;set;}
    }
    
    public void refreshListOfLocs(){
        locsList = new LocationElement[]{};
        Unify_Opportunity_Location__c[] oppLoc = [select Id, Name, Location__c, Opportunity__c from Unify_Opportunity_Location__c where Opportunity__c = :opp.Id];
        Set<Id> sLoc = new Set<Id>();
        for(Unify_Opportunity_Location__c opl1 : oppLoc){
            sLoc.add(opl1.Location__c);                             
        }
        Location__c[] locs = [select Id, Name, Type__c, Account__c, Unify_Unique_Site_Name__c, PAF_Postcode__c, PAF_Post_Town__c, Street__c, Unify_Validated_Postcode__c  from Location__c where Account__c = :opp.AccountId and Type__c = 'Installation' and Id not in :sLoc];
        for(Location__c l1 : locs){
            LocationElement le1 = new LocationElement();
            le1.loc = l1; 
            le1.selected = false;
            locsList.add(le1);
        }
    }
    
    public boolean getotherSitesExist(){
        if(locsList != null && locsList.size() > 0){
            return true;
        } else {
            return false;
        }   
    }
    
    public void changeOpt(){
        System.debug('XXXXXXXXX chosenOpt:' + this.chosenOpt);
    }
        
    public UnifyAddSiteController() {
        this.loc = new Location__c(); 
        Map<String, String> mPar = System.currentPageReference().getParameters();
        chosenOpt = 'EXIST';
        
        if(mPar.containsKey('id')){
            this.opp = [select Id, Name, AccountId from Opportunity where Id = :mPar.get('id')]; 
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity not found!'));
            return;         
        }
        
        refreshListOfLocs();
    }
    
    public void saveSite(){
        Savepoint sp = Database.setSavepoint();
        boolean error = false;
        if(chosenOpt == 'NEW'){
            if(loc.Unify_Unique_Site_Name__c == '' || loc.Unify_Unique_Site_Name__c == null){
                loc.Unify_Unique_Site_Name__c.addError('Site Name is required.');
                error = true;
            } else {
                Location__c[] locCheck = [select Id, Unify_Unique_Site_Name__c from Location__c where Unify_Unique_Site_Name__c = :loc.Unify_Unique_Site_Name__c and Account__c = :opp.AccountId];
                if(locCheck != null && locCheck.size() > 0){   
                    loc.Unify_Unique_Site_Name__c.addError('Site identified with this name already exist for this Customer. Please reuse it.');
                    error = true;
                }
            }
            if(!error && (loc.Unify_Validated_Postcode__c == '' || loc.Unify_Validated_Postcode__c == null)){
                loc.Unify_Validated_Postcode__c.addError('Post Code is mandatory.');
                error = true;
            }
            if(!error && (loc.Unify_Unique_Site_Name__c != null && loc.Unify_Unique_Site_Name__c.toUpperCase() == UnifyConfig.CENTRAL_SITE_KEY_NAME.toUpperCase())){
                loc.Unify_Unique_Site_Name__c.addError('You can not create a Central Site manually. To add it use ADD CENTRAL SITE button presented on Product Bundle Builder page.');
                error = true;
            } 
            if(error){
                return ;
            } else {
                try{
                    loc.Account__c = this.opp.AccountId;
                    loc.Type__c = 'Installation';   
                    insert loc;
                    Unify_Opportunity_Location__c opl = new Unify_Opportunity_Location__c();
                    opl.Name = loc.Unify_Unique_Site_Name__c;
                    opl.Location__c = loc.Id;
                    opl.Opportunity__c = this.opp.Id;
                    insert opl; 
                } catch (Exception e){
                    Database.rollback(sp);
                    if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Operation failed: Problem with access rights. \n\nPlease check whether Opportunity is locked or please contact with System Administrator.'));
                    } else {
                        ApexPages.addMessages(e);
                    }
                    //ApexPages.addMessages(e);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
                    return ;
                }
            }    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'New Site [' + loc.Unify_Unique_Site_Name__c + '] has been added.'));
            loc = new Location__c();        
        } else if(chosenOpt == 'EXIST'){
            Unify_Opportunity_Location__c[] ol2ins = new Unify_Opportunity_Location__c[]{};
            integer i = 0;
            for(LocationElement l1 : locsList){
                if(l1.selected){
                    ol2ins.add(new Unify_Opportunity_Location__c(Location__c = l1.loc.Id, Opportunity__c = opp.Id, Name = l1.loc.Unify_Unique_Site_Name__c));
                    i++;
                }
            }
            try {
                if(ol2ins.size() > 0){
                    insert ol2ins;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'No Location has been selected.'));
                    return ;
                }           
            } catch(Exception e){
                Database.rollback(sp);
                if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') || e.getMessage().contains('ENTITY_IS_LOCKED')){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Operation failed: Problem with access rights. \n\nPlease check whether Opportunity is locked or please contact with System Administrator.'));
                } else {
                    ApexPages.addMessages(e);
                }
                //ApexPages.addMessages(e);
                return ;
            }
            refreshListOfLocs();                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + 'Selected ' + i + ' Location(s) has been added to this Opportunity.'));
        }
    }
}