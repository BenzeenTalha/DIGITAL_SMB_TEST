/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

// atm (November 2012) there is no framework to create needed data (hansets, offers, etc.) so system data will be used due to closing deadlines
// if such a framewok is developed in the future I strongly recommend these test be rewritten to be data independant

@isTest(SeeAllData=true)
public with sharing class TestO2RetailUpgradeSupportMethods {

	public static testMethod void testHandsetConfigurationBasic()
	{
		try
		{
			O2RetailUpgradeSupportMethods sm = new O2RetailUpgradeSupportMethods();
			sm.getMobileDevicesSO();
			sm.deviceId = sm.devices.get(0).device.id;
			sm.refreshTariffs();
			sm.getMobileDeviceTariffsSO();
			sm.tariffId = sm.tariffs.get(0).tariff.id;
			sm.refreshTariffDetails();
		}
		catch(exception e)
		{
			system.debug('TEST FAIL - testHandsetConfigurationBasic: ' + e.getMessage());
		}
	}

	public static testMethod void testSimOnlyConfigurationBasic()
	{
		try
		{
			O2RetailUpgradeSupportMethods sm = new O2RetailUpgradeSupportMethods();
			sm.upgradeType = O2RetailUpgradeSupportMethods.UPGRADETYPE2;
	    	sm.refreshDevices();
			List<selectOption> options = sm.getSIMOnlyCombosSO();
			sm.chooseSIMOnly = options.get(1).getValue();
			sm.getSIMOnlyCombosSO(sm.chooseSIMOnly);
			sm.refreshTariffs();
			sm.getMobileDeviceTariffsSO();
			sm.tariffId = sm.tariffs.get(0).tariff.id;
			sm.refreshTariffDetails();
		}
		catch(exception e)
		{
			system.debug('TEST FAIL - testSimOnlyConfigurationBasic: ' + e.getMessage());
		}
	}

	public static testMethod void testRecordCreation()
	{
		try
		{
			String str;
			String DISEAccountNumber = '000000';
			Map<String,Object> accFieldMap = new Map<String,Object>();
			str = 'myCompanyTest'; accFieldMap.put('Name',(object) str);
			Account a = O2RetailUpgradeSupportMethods.resolveAccount(DISEAccountNumber,accFieldMap);

			Map<String,Object> conFieldMap = new Map<String,Object>();
			str = 'Testy'; conFieldMap.put('FirstName',(object) str);
	    	str = 'Testson'; conFieldMap.put('LastName',(object) str);
	    	str = 'testy.testson@email.com'; conFieldMap.put('Email',(object) str);
	    	str = '007006005'; conFieldMap.put('Phone',(object) str);
	    	Contact c = O2RetailUpgradeSupportMethods.resolveContact(a.Id,DISEAccountNumber,conFieldMap);

	    	// reselect existing records
	    	accFieldMap.clear();
	    	conFieldMap.clear();
	    	a = O2RetailUpgradeSupportMethods.resolveAccount(DISEAccountNumber,accFieldMap);
	    	c = O2RetailUpgradeSupportMethods.resolveContact(a.Id,DISEAccountNumber,conFieldMap);
		}
		catch(exception e)
		{
			system.debug('TEST FAIL - testRecordCreation: ' + e.getMessage());
		}
	}

	public static testMethod void testValidation()
	{
		try
		{
			O2RetailUpgradeSupportMethods sm = new O2RetailUpgradeSupportMethods();

			sm.validateIMEInumber();
			sm.IMEInumber = '123456789012345';
			sm.validateIMEInumber();

			sm.validateSIMnumber();
			sm.SIMnumber = 'xy';
			sm.validateSIMnumber();
			sm.SIMnumber = '60123456789';
			sm.validateSIMnumber();
		}
		catch(exception e)
		{
			system.debug('TEST FAIL - testValidation: ' + e.getMessage());
		}
	}

	public static testMethod void testBasket2Bundle()
	{
		try
		{
			O2RetailUpgradeSupportMethods sm = new O2RetailUpgradeSupportMethods();

			// configure device
			sm.getMobileDevicesSO();
			sm.deviceId = sm.devices.get(0).device.id;
			sm.refreshTariffs();
			sm.getMobileDeviceTariffsSO();
			sm.tariffId = sm.tariffs.get(0).tariff.id;
			sm.refreshTariffDetails();
			//add boltons - first value is empty
			sm.dataBoltonId = sm.dataBoltonsSO.get(1).getValue();
			sm.faveBoltonId = sm.faveBoltonsSO.get(1).getValue();
			sm.minsBoltonId = sm.minsBoltonsSO.get(1).getValue();
			sm.proceedData();

			// create basket
			sm.createBasket();
			sm.emptyBasket();
			sm.hasValidConfigs();
			sm.createBasket();
			sm.hasValidConfigs();

			// create account and contanct
			String str;
			String DISEAccountNumber = '000000';
			Map<String,Object> accFieldMap = new Map<String,Object>();
			str = 'myCompanyTest'; accFieldMap.put('Name',(object) str);
			Account a = O2RetailUpgradeSupportMethods.resolveAccount(DISEAccountNumber,accFieldMap);

			Map<String,Object> conFieldMap = new Map<String,Object>();
			str = 'Testy'; conFieldMap.put('FirstName',(object) str);
	    	str = 'Testson'; conFieldMap.put('LastName',(object) str);
	    	str = 'testy.testson@email.com'; conFieldMap.put('Email',(object) str);
	    	str = '007006005'; conFieldMap.put('Phone',(object) str);
	    	Contact c = O2RetailUpgradeSupportMethods.resolveContact(a.Id,DISEAccountNumber,conFieldMap);

	    	// create bundle
	    	Map<String,String> opptyFields = new Map<String,String>();
			opptyFields.put('bankBuildingSociety',null);
			opptyFields.put('bankAccountName',null);
			opptyFields.put('bankSortCode','1234');
			opptyFields.put('bankAccountNumber','12345678');
			opptyFields.put('confirmDetails',null);
			opptyFields.put('agreeTerms',null);
			opptyFields.put('ConfirmationEmailAddr',null);
			opptyFields.put('leadSource', 'O2 Retail');
			opptyFields.put('opptyType', 'Existing Business');

			O2RetailUpgradeSupportMethods.bundleBasket(sm.basketController.maincontroller.apiSession.getBasket(),a,c,opptyFields);
			sm.closeSession();
		}
		catch(exception e)
		{
			system.debug('TEST FAIL - testBasket2Bundle: ' + e.getMessage());
		}
	}

	public static testMethod void testAdditional()
	{
		try
		{
			O2RetailUpgradeSupportMethods sm = new O2RetailUpgradeSupportMethods();
			sm.deviceId = sm.devices.get(0).device.id;
			sm.getMobileDevicesSO(sm.deviceId);
			sm.refreshTariffs();
			sm.tariffId = sm.tariffs.get(0).tariff.id;
			sm.getMobileDeviceTariffsSO(sm.tariffId);
			String tc = sm.thisTariff.tariff.Tariff_Code__c;
			String pc = sm.thisTariff.tariff.Package_Code__c;
			sm.getMobileDeviceTariffsSO(null,tc,pc);
			sm.getUPGRADETYPE1();
			sm.getUPGRADETYPE2();
		}
		catch(exception e)
		{
			system.debug('TEST FAIL - testAdditional: ' + e.getMessage());
		}
	}


}