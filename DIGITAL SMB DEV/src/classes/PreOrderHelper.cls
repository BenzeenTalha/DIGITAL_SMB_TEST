/*
Created by:		 Ivor Goreta
Date:			 29.11.2012
Referenced from: AllOpportunityTriggers AfterUpdate
Ticket-Number:	 T-00672
Ticket-URL:		 https://na13.salesforce.com/a4za0000000TOJh?srPos=0&srKp=a4z
Purpose:		 When Opportunity.Stage changes to Achievement of Results go through all Handset Configurations inside Synchronised bundle.
				 For each handset portfolio with AvailableForPreOrder==true decrease PreOrder_Stock_Level by 1.
Implementation:	 Code collects IDs of all Opportunities which Opportunity.Stage changed to Achievement of Results.
                 Inner SOQL is used to retreive IDs of all Synchronised Bundles that reference these Opportunuties.
                 Outer SOQL is used to retreive Handset Configurations which reference these Bundle IDs.
                 With each configuration child Handset Selection and grand chils Hardware Portfolio are fetched.
                 For each Portfolio which is with AvailableForPreOrder==true PreOrder_Stock_Level is decrease by 1.
                 List is created from these Portfolio which is then updated into DB.
Object Structure:Opportunity [1:M] Product Bundle [1:M] Product Configuration [1:1] Handset Selection [1:1] Portfolio
Problems:		 Trigger is not executed when Opportunity.Stage changes to Achievement of Results?
				 So currently it executes when Opportunity.Stage changes to Decision.

*/

public with sharing class PreOrderHelper {

	//USED TO PREVENT TRIGGER EXECUTION AFTER WORKFLOWS.
	public static boolean triggerWasAlreadyExecuted = false;

	public static String DecreasePreOrderStockLevel(List<Opportunity> opportunitiesOld, List<Opportunity> opportunitiesNew) {

		//DO NOT EXECUTE TRIGGER AFTER WORKFLOWS
		if (triggerWasAlreadyExecuted == true ) { return 'TRIGGER NOT EXECUTED'; }
		triggerWasAlreadyExecuted = true;

		//GET IDS OF OPPORTUNITIES WHICH WENT TO Achievement of Results.
		Set<id> ids = new Set<id>();
		for (integer i=0 ; i<opportunitiesNew.size() ; i++) {
			String stageOld = opportunitiesOld[i].StageName;
			String stageNew = opportunitiesNew[i].StageName;
			if (!stageOld.equals('Achievement of Results') && stageNew.equals('Achievement of Results')) { ids.add(opportunitiesNew[i].id); }
		}

		//GET ALL PRODUCT CONFIGURATIONS.
		List<cscfgc__Product_Configuration__c> configurations = [
			select 	id,
					name,

					O2_DISE_Map_Handset_Selection__c,
					O2_DISE_Map_Handset_Selection__r.id,
					O2_DISE_Map_Handset_Selection__r.Product_Code__c,
					O2_DISE_Map_Handset_Selection__r.Name,
					O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_Preorder__c,
					O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_Backorder__c,
					O2_DISE_Map_Handset_Selection__r.Product_Code__r.PreOrder_Stock_Level__c,
					cscfgc__Product_Bundle__c,
					cscfgc__Product_Bundle__r.cscfgc__Opportunity__c

			from 	cscfgc__Product_Configuration__c
			where 	O2_DISE_Map_Handset_Selection__c != null
			and		cscfgc__Product_Bundle__c in (
						select 	id
						from 	cscfgc__Product_Bundle__c
						where 	cscfgc__Opportunity__c                   in : ids
						and		cscfgc__Synchronised_with_Opportunity__c = true
					)
		];

		//CRATE LIST OF CHANGED PORTFOLIOS.
		Map<id, O2_DISE_Ref_Hardware_Portfolio__c> portfolios = new Map<id, O2_DISE_Ref_Hardware_Portfolio__c>();
		for(cscfgc__Product_Configuration__c config : configurations ) {
			Boolean AvailableForPreOrder = config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_Preorder__c;
			Boolean AvailableForBackOrder = config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.Available_for_Backorder__c;
			Decimal PreOrderStockLevel   = config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.PreOrder_Stock_Level__c;
			if(AvailableForPreOrder == true) {
				config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.PreOrder_Stock_Level__c = PreOrderStockLevel-1;
				portfolios.put(config.O2_DISE_Map_Handset_Selection__r.Product_Code__c, config.O2_DISE_Map_Handset_Selection__r.Product_Code__r);
			}
			if(AvailableForBackOrder == true) {
				config.O2_DISE_Map_Handset_Selection__r.Product_Code__r.PreOrder_Stock_Level__c = PreOrderStockLevel-1;
				portfolios.put(config.O2_DISE_Map_Handset_Selection__r.Product_Code__c, config.O2_DISE_Map_Handset_Selection__r.Product_Code__r);
			}
		}

		//UPDATE PORTOFOLIOS LIST.
		List<O2_DISE_Ref_Hardware_Portfolio__c> portfoliosList = new List<O2_DISE_Ref_Hardware_Portfolio__c>();
		portfoliosList =  portfolios.values();
		update(portfoliosList);

		/*
		* Update Opportunity.Preorders__c, Opportunity.Backorders__c with list of phones
		* @author:	Ivan Tadic
		* @date:	30/08/2013
		*/
		Map<Id, List<O2_DISE_Map_Handset_Selection__c>> oppSelectionsMap = new Map<Id, List<O2_DISE_Map_Handset_Selection__c>>();
		for(cscfgc__Product_Configuration__c config: configurations){
			if(!oppSelectionsMap.containsKey(config.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c)){
				oppSelectionsMap.put(config.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c, new List<O2_DISE_Map_Handset_Selection__c>());
			}
			List<O2_DISE_Map_Handset_Selection__c> oppSelections = oppSelectionsMap.get(config.cscfgc__Product_Bundle__r.cscfgc__Opportunity__c);
			oppSelections.add(config.O2_DISE_Map_Handset_Selection__r);
		}
		List<Opportunity> opps = new List<Opportunity>();
		for(Id oppId : oppSelectionsMap.keySet()){
			string preOrders = '';
			string backOrders = '';
			for(O2_DISE_Map_Handset_Selection__c selection : oppSelectionsMap.get(oppId)){
				if(selection.Product_Code__r.Available_for_BackOrder__c){
					backOrders += selection.Name + '\n';
				}
				if(selection.Product_Code__r.Available_for_Preorder__c){
					preOrders += selection.Name + '\n';
				}
			}
			Opportunity opp = new Opportunity(Id 			= oppId,
											  Preorders__c 	= preOrders,
											  Backorders__c = backOrders);
			opps.add(opp);

		}

		update opps;
		/*
		* End Update Opportunity.Preorders__c, Opportunity.Backorders__c
		*/


		//TRIGGER SHOULD BE EXECUTED ONLY ONCE, BEFORE WORKFLOWS.
		return 'TRIGGER EXECUTED';
	}


}