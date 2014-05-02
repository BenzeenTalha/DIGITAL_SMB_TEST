//------------------------------------------------------------------------------
// Copyright (c) 2012 CloudSense Ltd.
// Controller for providing data for a retail upgrade contract
//------------------------------------------------------------------------------
public with sharing class O2RetailUpgradeContractController
{
	// Business Details
    public String businessName { get; set; }
    public String businessAddressLine1 { get; set; }
    public String businessAddressLine2 { get; set; }
    public String businessAddressLine3 { get; set; }
    public String businessAddressLine4 { get; set; }
    public String businessAddressLine5 { get; set; }
    public String businessAddressLine6 { get; set; }
    // Contact Details
    public String contactName { get; set; }
    public String contactTelephone { get; set; }
    // Contract Details
    public String contractNumber { get; set; }
    public String ftuFee { get; set; }
    public String contractStartDate { get; set; }
    public String termOfContract { get; set; }
	public String retailerId { get; set; }
	public String sosCode { get; set; }
	public String salesPerson { get; set; }
	// Upgrade Details
	public String msisdn { get; set; }
	public String account { get; set; }
	public String device { get; set; }
	public String imei { get; set; }
	public String newSIM { get; set; }
	public String tariff { get; set; }
	public String inclusiveData { get; set; }
	public String insurance { get; set; }
	public String additionalData { get; set; }
	public String offPeakCalls { get; set; }
	public String internationalFavourites { get; set; }
	public String totalMonthlyCharge { get; set; }
	public string office365productname { get; set; }
	public boolean office365TCVisible { get; set; }

    //--------------------------------------------------------------------------
    // Constructor map parameter values
    //--------------------------------------------------------------------------
    public O2RetailUpgradeContractController()
    {
		Map<String, String> parameters = ApexPages.currentPage().getParameters();
		businessName = parameters.get('businessName');
		businessAddressLine1 = parameters.get('businessAddressLine1');
		businessAddressLine2 = parameters.get('businessAddressLine2');
		businessAddressLine3 = parameters.get('businessAddressLine3');
		businessAddressLine4 = parameters.get('businessAddressLine4');
		businessAddressLine5 = parameters.get('businessAddressLine5');
		businessAddressLine6 = parameters.get('businessAddressLine6');
		contactName = parameters.get('contactName');
		contactTelephone = parameters.get('contactTelephone');
		contractNumber = parameters.get('contractNumber');
		ftuFee = parameters.get('ftuFee');
		contractStartDate = parameters.get('contractStartDate');
		termOfContract = parameters.get('termOfContract');
		retailerId = parameters.get('retailerId');
		sosCode = parameters.get('sosCode');
		salesPerson = parameters.get('salesPerson');
		msisdn = parameters.get('msisdn');
		account = parameters.get('account');
		device = parameters.get('device');
		imei = parameters.get('imei');
		newSIM = parameters.get('newSIM');
		tariff = parameters.get('tariff');
		inclusiveData = parameters.get('inclusiveData');
		insurance = parameters.get('insurance');
		additionalData = parameters.get('additionalData');
		offPeakCalls = parameters.get('offPeakCalls');
		internationalFavourites = parameters.get('internationalFavourites');
		totalMonthlyCharge = parameters.get('totalMonthlyCharge');
		office365productname= parameters.get('office365product');
		office365TCVisible=true;
		if (office365productname=='' || office365productname==null || office365productname=='-') office365TCVisible=false;
		//
		// If business name is empty we will use contactName
		//
		if (businessName == null
			|| businessName.trim().length() == 0)
		{
			businessName = contactName;
		}
    }
}