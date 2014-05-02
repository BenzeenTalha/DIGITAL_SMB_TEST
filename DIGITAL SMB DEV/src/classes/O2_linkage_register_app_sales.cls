public class O2_linkage_register_app_sales {
	
	// Opportunity controlled
	public Opportunity opp {private get;private set;}
	
	// Constructor
	public O2_linkage_register_app_sales(ApexPages.StandardController stdController) {
	    this.opp = (Opportunity)stdController.getRecord();
	} // end constructor

	public String status {get;private set;} {status = '';}
	
	// Return the app sales status
	public PageReference appSalesStatus() {
		List<O2_Product_Detail__c> updateAppSales = new List<O2_Product_Detail__c>();
		if (this.opp.StageName == 'Closed Won') {
			List<O2_Product_Detail__c> appSales = [Select Name,Id,Opportunity__r.AccountId,OARApplicationId__c,OARNotes__c,Application_Sale_Date__c,Number_of_Licences__c,Length_of_Contract__c,OARMobSpecId__c,Contract_Reference__c From O2_Product_Detail__c Where Opportunity__c = :this.opp.Id And OARApplicationId__c != null And OARRegisteredDateTime__c = null];
			if (appSales.size() == 0) {
				status = Label.no_app_sales_to_send;
			} // end application sales exist check if
			else {
				for (O2_Product_Detail__c appSale : appSales) {
					String contractLength = appSale.Length_of_Contract__c.replace(' Months','');
					status += ' For app sale name ' + appSale.Name + ' OAR create return = ';
					status += O2_linkage_utils.CreateSale(this.opp.Id,
																appSale.OARApplicationId__c,
																appSale.Application_Sale_Date__c,
																appSale.Number_of_Licences__c,
																appSale.OARMobSpecId__c,
																appSale.Contract_Reference__c,
																contractLength,
																appSale.OARNotes__c,
																appSale.Opportunity__r.AccountId);
					updateAppSales.add(new O2_Product_Detail__c(Id = appSale.Id,OARRegisteredDateTime__c = Datetime.now()));					
				} // end loop through application sales
				if (updateAppSales.size() != 0) update updateAppSales;
			} // end application sales exist check else
		} // end stage closed won check if
		else {
			status = Label.no_check_unless_closed_won;
		} // end stage closed won check else
		return null;
	} // end getAppSalesStatus
} // end class