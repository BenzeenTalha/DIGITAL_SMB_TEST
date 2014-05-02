//--------------------------------------------------------------------------
// This class is used for writing data for reporting and retrieving
// it when needed in reports.
//--------------------------------------------------------------------------
public with sharing class O2RetailReports {
	//--------------------------------------------------------------------------
	// Adds retail upgrade information to a database
	//--------------------------------------------------------------------------
	public static String addRetailUpgrade
	(
		String storeId,
		String upgradeReferenceNumber,
		String msisdn,
		String companyName,
		String newSimNumber,
		String newImeiNumber,
		String repCode,
		Integer fastTrackUpgradeFee,
		String newTariffDescription,
		Boolean insuranceTaken,
		String newHandsetMake,
		String newHandsetModel,
		Boolean isLeased,
		String newTariffCode,
		String newTermOfContract,
		String insuranceServiceCode
	)
	{
		System.debug
		(
			'O2RetailReports.addRetailUpgrade (' +
			storeId + ', ' +
			upgradeReferenceNumber + ', ' +
			msisdn + ', ' +
			companyName + ', ' +
			newSimNumber + ', ' +
			newImeiNumber + ', ' +
			repCode + ', ' +
			fastTrackUpgradeFee + ', ' +
			newTariffDescription + ', ' +
			insuranceTaken + ', ' +
			newHandsetMake + ', ' +
			newHandsetModel + ', ' +
			isLeased + ', ' + 
			newTariffCode + ', ' + 
			newTermOfContract + ', ' + 
			insuranceServiceCode + 
			')BEGIN'
		);
		String retailUpgradeId = '';
		try
		{
			O2_Retail_Upgrade__c o2RetailUpgrade = new O2_Retail_Upgrade__c();
			o2RetailUpgrade.Store_ID__c = storeId;
			o2RetailUpgrade.Upgrade_Reference_Number__c = upgradeReferenceNumber;
			o2RetailUpgrade.MSISDN__c = msisdn;
			o2RetailUpgrade.Name = companyName != null ? companyName : 'No Name';
			o2RetailUpgrade.New_SIM_Number__c = newSimNumber;
			o2RetailUpgrade.New_IMEI_Number__c = newImeiNumber;
			o2RetailUpgrade.Rep_Code__c = repCode;
			o2RetailUpgrade.Fast_Track_Upgrade_Fee__c = fastTrackUpgradeFee != null ? Decimal.valueOf(fastTrackUpgradeFee) / 100 : 0.00;
			o2RetailUpgrade.New_Tariff_Description__c = newTariffDescription;
			o2RetailUpgrade.Insurance_Taken__c = insuranceTaken;
			o2RetailUpgrade.Date__c = Date.today();
			o2RetailUpgrade.New_Handset_Make__c = newHandsetMake;
			o2RetailUpgrade.New_Handset_Model__c = newHandsetModel;
			o2RetailUpgrade.Is_Leased__c = isLeased;
			o2RetailUpgrade.New_Tariff_Code__c = newTariffCode;
			o2RetailUpgrade.Contract_Length__c = newTermOfContract;
			o2RetailUpgrade.Insurance_Service_Code__c = insuranceServiceCode;
			insert o2RetailUpgrade;
			retailUpgradeId = o2RetailUpgrade.Id;
		}
		catch (Exception e)
		{
			System.debug('Error while inserting retail upgrade: ' + e.getMessage());
		}
		System.debug('O2RetailReports.addRetailUpgrade END');
		return retailUpgradeId;
	}

	//--------------------------------------------------------------------------
	// Retrieves retail upgrades for reports
	// Parameters are:
	//   - store ID
	//   - enquiry date
	// Return value is:
	//   - list of O2 Retail Upgrade custom objects
	//--------------------------------------------------------------------------
	public static List<O2_Retail_Upgrade__c> getRetailUpgrades(String storeId, Date enquiryDate)
	{
		System.debug('O2RetailReports.getRetailUpgrades(' + storeId + ', ' + enquiryDate + ') BEGIN');
		List<O2_Retail_Upgrade__c> reportList =
		[
			SELECT Id, CreatedById, CreatedBy.Username, Date__c, Store_Id__c, Upgrade_Reference_Number__c, MSISDN__c, Name,
			New_SIM_Number__c, New_IMEI_Number__c, Rep_Code__c, Fast_Track_Upgrade_Fee__c, New_Tariff_Description__c, Insurance_Taken__c
			FROM O2_Retail_Upgrade__c
			WHERE Date__c = :enquiryDate and Store_Id__c = :storeId
		];
		System.debug('O2RetailReports.getRetailUpgrades END');
		return reportList;
	}
}