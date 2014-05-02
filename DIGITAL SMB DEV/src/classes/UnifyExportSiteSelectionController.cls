public with sharing class UnifyExportSiteSelectionController {

    public String chosenSupplier {get;set;}
    public string[] selSolutions {get; set;}
    public List<SelectOption> optionsSuppliersList {get;set;}
    public String exportSystem {get;set;}


    public List<SelectOption> getSolutionItems() {
        List<SelectOption> options = new List<SelectOption>();
        if(opp.Unify_Solution__c != null && opp.Unify_Solution__c != ''){
            List<String> ls = opp.Unify_Solution__c.split(';');
            options.add(new SelectOption('','-please select-'));
            for(String s : ls){
                options.add(new SelectOption(s,s));
            }
        } else {
            options.add(new SelectOption('','-solution not set-'));
        }
        return options;
    }

    /**
    *    Variables for Pillars selection
    */
    public boolean bConnectivity {get;set;}
    public boolean bHardware {get;set;}
    public boolean bMaintanance {get;set;}
    public boolean bMonitoring {get;set;}
    public boolean bProfessionalServices {get;set;}
    public boolean bOther {get;set;}


    /**
    * Export Context variable
    * TRUE for configuration export, FALSE for quotation
    */

    public boolean isConfig {get;set;}

    /*Context variable for exporting from OrderGroup*/
    public boolean isOrderGroup {get;set;}
    public string orderGroupId {get;set;}


    public List<SiteElement> sitesList {get;set;}
    public cscfgc__Product_Bundle__c bundle {get;set;}
    public Opportunity opp {get; set;}

    public class SiteElement {
        public boolean selected {get;set;}
        public Unify_Site__c site {get;set;}
        public Boolean isValid{get;set;}
        public String validationMessage{get;set;}
        public boolean showValidationDetails{get;set;}
        public void showValidation(){
            showValidationDetails = true;
        }
        public void hideValidation(){
            showValidationDetails = false;
        }
        public SiteElement(){
            showValidationDetails = false;
            isValid = true;
        }
    }

    public class exportRequestClass{
        public Id bundleId {get;set;}
        public String  exportType {get;set;}
        public String  supplier {get;set;}
        public List<String> solutions {get;set;}
        public List<String> pillars {get;set;}
        public List<Id> sitesIds {get;set;}
    }

    public UnifyExportSiteSelectionController(ApexPages.StandardController stdController){
        bConnectivity = false;
        bHardware = false;
        bMaintanance = false;
        bMonitoring = false;
        bProfessionalServices = false;
        bOther = false;

        exportSystem = 'DISE';

        selSolutions = new String[]{};

        optionsSuppliersList = new List<SelectOption>();

        this.optionsSuppliersList.add(new SelectOption('', '- choose Supplier -'));
        for(String s1: UnifyConfig.setSuppliers()){
                this.optionsSuppliersList.add(new SelectOption(s1, s1));
        }

        this.bundle = (cscfgc__Product_Bundle__c)stdController.getRecord();
        this.opp = [select Id, Name, Unify_Solution__c from Opportunity where Id = :bundle.cscfgc__Opportunity__c][0];

        this.isConfig = true;
        this.isOrderGroup = false;

        if(ApexPages.currentPage().getParameters().containsKey('context')){
            if(ApexPages.currentPage().getParameters().get('context') == 'quot'){
                this.isConfig = false;
            }
            if(ApexPages.currentPage().getParameters().get('context') == 'ordergroup'){
                this.isOrderGroup = true;
                this.orderGroupId = ApexPages.currentPage().getParameters().get('ogId');
            }
        }
        refreshSitesList();
    }
    public void refreshSitesList(){
    	Map<Id,List<SLA__c>> mapOrdSLAs = new Map<Id,List<SLA__c>>();

        //Get All Sites and their Orders
        string sitesQuery = 'SELECT ' + Utility.getSobjectFields('Unify_Site__c') +
        					', (SELECT ' + Utility.getSobjectFields('Order__c') +' FROM Orders__r) ' +
        					' FROM Unify_Site__c WHERE Product_Bundle__c = \'' + bundle.Id + '\'';
		if(isOrderGroup)
			sitesQuery += ' AND Order_Group__c = \'' + orderGroupId + '\'';
		List<Unify_Site__c> sites = Database.query(sitesQuery);

		//Create Sets:  All Orders, All Product Configurations
		Set<Id> prodConfigSet = new Set<Id>();
		Set<Id> orderSet = new Set<Id>();
		for(Unify_Site__c site : sites){
			for(Order__c o : site.Orders__r){
				orderSet.add(o.Id);
				prodConfigSet.add(o.Product_Configuration__c);
			}
		}

		//Get all Product Configurations with attributes
		List<cscfgc__Product_Configuration__c> prodConfigs = new List<cscfgc__Product_Configuration__c>();
		if(exportSystem == 'DISE'){
			prodConfigs = [SELECT
								Id, Name, cscfgc__Product_Bundle__c,
								cscfgc__Product_Bundle__r.Unify_Commercial_Approved__c,
								cscfgc__Product_Definition__r.cscfgc__Label__c,
								cscfgc__Product_Definition__r.Name,
								cscfgc__Product_Definition__c,
								(SELECT
									Name, cscfgc__Attribute_Definition__c, cscfgc__Attribute_Definition__r.Name,
									cscfgc__Attribute_Definition__r.cscfgc__Label__c,
									cscfgc__Attribute_Definition__r.Unify_DISE_Export_Required__c, cscfgc__Value__c
								 FROM
								 	cscfgc__Attributes__r
								 WHERE
								 	cscfgc__Attribute_Definition__r.Unify_DISE_Export_Required__c = true OR
								 	(cscfgc__Attribute_Definition__r.Name = 'Billing Frequency'))
					  	   FROM
 								cscfgc__Product_Configuration__c
                      	   WHERE
                            	Id IN :prodConfigSet];
		} else if(exportSystem == 'SNOW') {
			prodConfigs = [SELECT
								Id, Name, cscfgc__Product_Bundle__c,
								cscfgc__Product_Bundle__r.Unify_Commercial_Approved__c,
								cscfgc__Product_Definition__r.cscfgc__Label__c,
								cscfgc__Product_Definition__r.Name,
								cscfgc__Product_Definition__c,
								(SELECT
									Name, cscfgc__Attribute_Definition__c, cscfgc__Attribute_Definition__r.Name,
									cscfgc__Attribute_Definition__r.cscfgc__Label__c, cscfgc__Value__c,
									cscfgc__Attribute_Definition__r.Unify_SNOW_Export_Required__c
                    			 FROM
                    			 	cscfgc__Attributes__r
                    			 WHERE
                    			 	cscfgc__Attribute_Definition__r.Unify_SNOW_Export_Required__c = true)
					  	   FROM
 								cscfgc__Product_Configuration__c
                      	   WHERE
                            	Id IN :prodConfigSet];
		}
		Map<Id,cscfgc__Product_Configuration__c> prodConfigsMap = new Map<Id,cscfgc__Product_Configuration__c>(prodConfigs);

		//Get all SLA's
		Map<Id,Order__c> ordersWithSLAsMap = new Map<Id,Order__c>([SELECT Id,(SELECT Id,Actual_Date__c,Name FROM SLAs__r WHERE Name IN ('Billing start date','Order complete date')) FROM Order__c WHERE Id in :orderSet]);

        //Can't export if there is Product Configurations attached to the not approved bundle
        for(cscfgc__Product_Configuration__c conf : prodConfigs){
            if(!conf.cscfgc__Product_Bundle__r.Unify_Commercial_Approved__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Product Bundle is not yet Commercially Approved. You can not perform export.'));
                return;
            }
        }

        //Save data in site elements
        sitesList = new List<SiteElement>();
		for(Unify_Site__c s1 : sites){
            SiteElement n1 = new SiteElement();
	        n1.site = s1;
	        n1.selected = false;
	        n1.isValid = true;
            n1.validationMessage = '';

            //DISE Account Number *
            if(string.isBlank(n1.site.DISE_Account_No__c))
                n1.validationMessage = '<b>*DISE Account No is empty</b><br/>';

            //SNOW - Corporate Code *
	        if(exportSystem == 'SNOW' && string.isBlank(n1.site.Corporate_Code__c))
	          	n1.validationMessage += '<b>*Corporate Code is empty</b><br/>';

	        //Go through all Orders
	        for(Order__c o : n1.site.Orders__r){
				//No validation required for Cancelled Orders
				if(o.Order_Status__c == 'Cancelled')
					continue;

				//Get Product Configuration
				cscfgc__Product_Configuration__c conf;
				if(prodConfigsMap.containsKey(o.Product_Configuration__c))
					conf =prodConfigsMap.get(o.Product_Configuration__c);
				else
					continue;

				//Validate
				boolean slaIsValid = true;
				string slaValidationMessage = '';
				boolean pcIsValid = true;
				string pcValidationMessage = '';

				//SLA's
				slaValidationMessage = '<b>*' + o.Name + '</b> [<a href="/' + o.Id +'" target="_blank" >Go To Order</a>], following milestones are required:<br/>';
				if (exportSystem == 'DISE') {
                	Order__c oWSLA = ordersWithSLAsMap.get(o.Id);
                	if (oWSLA.SLAs__r != null) {
	                    for (SLA__c sla : oWSLA.SLAs__r) {
	                    	if (sla.Actual_Date__c == null) {
	                        	slaValidationMessage += '  - ' + sla.Name + '<br/>';
	                        	slaIsValid = false;
	                        }
	                    }
                	}
                }

				pcValidationMessage += '<b>*' + conf.Name + '</b> [<a href="/apex/cscfgc__ConfigureProduct?configId=' + conf.Id + '&retUrl=' + conf.cscfgc__Product_Bundle__c +'" target="_blank" >Provide Data</a>]';
            	pcValidationMessage += ', following required attributes are empty:<br/>';

				//Check is it recurring service
				boolean isRecurring = false;
                for (cscfgc__Attribute__c attribute : conf.cscfgc__Attributes__r) {
                	if (attribute.Name == 'Billing Frequency') {
                		isRecurring = attribute.cscfgc__Value__c != '--None--' && attribute.cscfgc__Value__c != '0';
                	}
                }

				//Check DISE/SNOW Exportable attributes
				for(cscfgc__Attribute__c attribute : conf.cscfgc__Attributes__r){
					//DISE Export
					if(exportSystem == 'DISE'){
						if(attribute.cscfgc__Attribute_Definition__r.Unify_DISE_Export_required__c == true && String.IsBlank(attribute.cscfgc__Value__c)){
							//Start/End Date are required only for recurring services
							if ((attribute.Name == 'Start Date' || attribute.Name == 'End Date') && !isRecurring)
                        		continue;
                        	if(string.isBlank(attribute.cscfgc__Attribute_Definition__r.cscfgc__Label__c)){
                            	pcValidationMessage += '  - ' + attribute.cscfgc__Attribute_Definition__r.cscfgc__Label__c + '<br/>';
                        	}else{
                            	pcValidationMessage += '  - ' + attribute.cscfgc__Attribute_Definition__r.Name + '<br/>';
                        	}
                        	pcIsValid = false;
						}
					}
            		//SNOW Export
            		if(exportSystem == 'SNOW'){
						if(attribute.cscfgc__Attribute_Definition__r.Unify_SNOW_Export_Required__c == true && String.IsBlank(attribute.cscfgc__Value__c)){
							//Start/End Date are required only for recurring services
							if ((attribute.Name == 'Start Date' || attribute.Name == 'End Date') && !isRecurring)
                        		continue;
                        	if(string.isBlank(attribute.cscfgc__Attribute_Definition__r.cscfgc__Label__c)){
                            	pcValidationMessage += '  - ' + attribute.cscfgc__Attribute_Definition__r.cscfgc__Label__c + '<br/>';
                        	}else{
                            	pcValidationMessage += '  - ' + attribute.cscfgc__Attribute_Definition__r.Name + '<br/>';
                        	}
                        	pcIsValid = false;
						}
					}
				}
				//Add to the Site Validation Message
				if(!slaIsValid)
					n1.validationMessage += slaValidationMessage;
				if(!pcIsValid){
	                n1.validationMessage += pcValidationMessage;
	            }
	        }
	        if(!string.isBlank(n1.validationMessage))
	           	n1.isValid = false;
	        sitesList.add(n1);
		}
    }

    public List<SelectOption> getSystems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('DISE','DISE'));
        options.add(new SelectOption('SNOW','SNOW'));
        return options;
    }

    public PageReference goToExport(String expType){
        exportRequestClass exportReq = new exportRequestClass();
        exportReq.bundleId = bundle.Id;
        exportReq.exportType = expType;
        exportReq.pillars = new List<String>();
        exportReq.solutions = new List<String>();
        exportReq.sitesIds = new List<Id>();
        for(SiteElement s1 : sitesList){
            if(s1.selected) {
                exportReq.sitesIds.add(s1.site.Id);
            }
        }

        if(selSolutions.size() != 0){
            exportReq.solutions.addAll(selSolutions);
        }

        if(bConnectivity)
            exportReq.pillars.add(UnifyConfig.mPillars2Name().get('Connectivity'));
        if(bHardware)
            exportReq.pillars.add(UnifyConfig.mPillars2Name().get('Hardware'));
        if(bMaintanance)
            exportReq.pillars.add(UnifyConfig.mPillars2Name().get('Maintenance'));
        if(bMonitoring)
            exportReq.pillars.add(UnifyConfig.mPillars2Name().get('Monitoring'));
        if(bProfessionalServices)
            exportReq.pillars.add(UnifyConfig.mPillars2Name().get('Professional Services'));
        if(bOther)
            exportReq.pillars.add(UnifyConfig.mPillars2Name().get('Other'));

        if(!this.isConfig){
            exportReq.supplier = chosenSupplier;
        }

        Note n = new Note();
        n.Body = JSON.serialize(exportReq);
        n.ParentId = bundle.Id;
        n.Title = 'Export Request: ' + System.now();
        insert n;
        Pagereference p;
        if(isOrderGroup){
            p = Page.UnifyExportConfigurationXLS;
        }
        p.getParameters().put('id', n.Id);
        p.setRedirect(true);
        return p;
    }


    public PageReference exportConf(){
        return goToExport('conf');
    }


    public PageReference exportQuot(){
        if(chosenSupplier == '' || chosenSupplier == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'You need to specify supplier first.'));
            return null;
        }
        if(selSolutions.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Please select at least one solution.'));
            return null;
        }
        if(bConnectivity == false && bHardware == false && bMaintanance == false && bMonitoring == false &&  bProfessionalServices == false && bOther == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Please select at least one pillar type.'));
            return null;
        }
        boolean siteSel = false;
        for(SiteElement s1 : sitesList){
            if(s1.selected) {
                siteSel = true;
                break;
            }
        }
        if(!siteSel){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'You need to select at least one Site.'));
            return null;
        }
        return goToExport('quot');
    }


    public PageReference exportOrderGroup(){
        Boolean hasSelectedSites = false;
        for(SiteElement s : sitesList){
            if(s.selected){
                hasSelectedSites = true;
                break;
            }
        }
        if(!hasSelectedSites){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Please select at least one Site.'));
            return null;
        }
        return goToExport(exportSystem);
    }

}