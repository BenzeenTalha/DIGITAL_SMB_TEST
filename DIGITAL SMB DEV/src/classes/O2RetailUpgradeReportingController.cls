public with sharing class O2RetailUpgradeReportingController {
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	private static final String NO_STORE_ID_MESSAGE = 'There is no store ID';
	//--------------------------------------------------------------------------
	// Getters and setters
	//--------------------------------------------------------------------------
	public String todayDate { get { return Date.today().format(); } }
	public String errorMessage { get; set; }
	public String storeId { get; set; }
	public String storeName { get; set; }
	public O2_Retail_Upgrade__c getO2RetailUpgrade()
	{
		return o2RetailUpgrade;
	}
	public List<O2_Retail_Upgrade__c> getReportList()
	{
		return reportList;
	}

	//--------------------------------------------------------------------------
	// Members
	//--------------------------------------------------------------------------
	public List<O2_Retail_Upgrade__c> reportList;
	private O2_Retail_Upgrade__c o2RetailUpgrade = new O2_Retail_Upgrade__c();

	//--------------------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------------------
	public O2RetailUpgradeReportingController()
	{
		//
		// Retrieve store ID
		//
		String context = ApexPages.currentPage().getParameters().get('context');
		if (context != null)
		{
			List<String> parameters = context.split('\\|');
			if (parameters.size() > 0) storeId = parameters[0];
			if (parameters.size() > 1) storeName = parameters[1];
		}

		o2RetailUpgrade.Date__c = Date.today();
	}

	//--------------------------------------------------------------------------
	// Generating report for date
	//--------------------------------------------------------------------------
	public PageReference generateReport()
	{
		//
		// Check if we have storeId
		//
		if (storeId == null)
		{
			errorMessage = NO_STORE_ID_MESSAGE;
			return null;
		}
		//
		// Retrieve data for report
		//
		reportList = O2RetailReports.getRetailUpgrades(storeId, o2RetailUpgrade.Date__c);

		//
		// Open pdf document in the same window
		//
		return Page.O2RetailUpgradeReportPDF;
	}
}