global without sharing class O2RetailUpgradeSupportMethods
{

    public static final boolean DODEBUG = false;
    public static final String UPGRADETYPE1 = 'Connect & HS';
    public static final String UPGRADETYPE2 = 'SIM only';


    public Id deviceId {get; set;}
    public Id tariffId {get; set;}
    public String upgradeType {get; set;}
    public String IMEInumber {get; set;}
    public String SIMnumber {get; set;}
    public Boolean addInsurance {get; set;}
	// insurance price for currently selected tariff
    public Double insurancePrice {get; set;}
	//SW CDECISIONS 31/10/2012 - added to show insurance service code for Torex and reporting
    public String insuranceServiceCode {get;set;}
    public Boolean SIMswap {get; set;}
    public Id dataBoltonId {get; set;}
    public Id faveBoltonId {get; set;}
    public Id minsBoltonId {get; set;}
    	
    public string Office365ProductId {get; set;}  //added by DD
    

    // store selected objects
    // Not used on pages
    public O2OnlineMobileController.MobileDevice thisDevice {get; set;}
    public O2OnlineMobileController.MobileDeviceTariffUnique thisTariff {get; set;}
    // Not used on pages
    public O2_DISE_Map_Mobile_Bolton__c thisDataBolton {get; set;}
    // Not used on pages
    public O2_DISE_Map_Mobile_Bolton__c thisFaveBolton {get; set;}
    // Not used on pages
    public O2_DISE_Map_Mobile_Bolton__c thisMinsBolton {get; set;}

    public List<O2OnlineMobileController.MobileDevice> devices;
    public List<O2OnlineMobileController.MobileDeviceTariffUnique> tariffs;

    public List<SelectOption> dataBoltonsSO {get; private set;}
    public List<SelectOption> faveBoltonsSO {get; private set;}
    public List<SelectOption> minsBoltonsSO {get; private set;}
    
    public List<SelectOption> O365ProductsSO {get; private set;}  //added by DD

    public O2OnlineMobileController basketController {get; private set;}

    public String chooseSIMOnly {get; set;}

    public O2RetailUpgradeSupportMethods()
    {
        upgradeType = UPGRADETYPE1;
        retrieveMobileDevices();
        retrieveMobileTariffs();
        setMobileTariffBoltonsSO();
        insurancePrice = 0;
        addInsurance = false;
        SIMswap = false;
        		
        setOffice365Products(); //added by DD

        O2OnlineMainController mainController = new O2OnlineMainController();
        basketController = new O2OnlineMobileController(mainController);
    }

    // populate devices
    public void retrieveMobileDevices()
    {
        String hardwareType =   (upgradeType == UPGRADETYPE1) ? 'Handset' :
                                (upgradeType == UPGRADETYPE2) ? 'SIM' :
                                '';
        devices = O2OnlineMobileController.getMobileDevicesHT('', '', hardwareType, 'Name ASC');
        if (DODEBUG) system.debug('Found ' + devices.size() + ' devices.');
    }

    // populate traiffs for selected device
    public void retrieveMobileTariffs()
    {
        String tType =  (upgradeType == UPGRADETYPE1) ? 'Handset' :
                        (upgradeType == UPGRADETYPE2) ? 'SIM ONLY;Simplicity' :
                        '';

        if ((upgradeType == UPGRADETYPE1 && deviceId == null) || (upgradeType == UPGRADETYPE2 && (chooseSIMOnly == null || chooseSIMOnly == '')))
        {
            tariffId = null;
            thisTariff = null;
            tariffs = new List<O2OnlineMobileController.MobileDeviceTariffUnique>();
            return;
        }

        // find current device
        if (upgradeType == UPGRADETYPE1)
        {
            for (O2OnlineMobileController.MobileDevice device : devices)
            {
                if (device.device.id == deviceId)
                {
                    thisDevice = device;
                    break;
                }
            }
            if (thisDevice != null) tariffs =
				O2OnlineMobileController.getMobileTariffs(
						thisDevice.device.Product_Code__r.Product_Code__c,
						thisDevice.device.Handset_Class__c,
						'', '', '', '', '',
						tType,
						(thisDevice.device.Bonus_Handset__c ? 'true' : 'false'),
						'', '', '',
						false);
        }

        if (upgradeType == UPGRADETYPE2)
        {
            String deviceName = chooseSIMOnly.split(';').get(0);
            String hsClass = chooseSIMOnly.split(';').get(1);

            for (O2OnlineMobileController.MobileDevice device : devices)
            {
                if (device.device.Name == deviceName)
                {
                    deviceId = device.device.id;
                    thisDevice = device;
                    break;
                }
            }
            if (thisDevice != null) tariffs =
				O2OnlineMobileController.getMobileTariffsUnique(hsClass,
						'', '', '', '', '',
						tType,
						'', '', '', '',
						false);
        }

        if (DODEBUG) system.debug('Found ' + tariffs.size() + ' tariffs.');
    }

    // create select list from devices
    public List<SelectOption> getMobileDevicesSO()
    {
        return getMobileDevicesSO(null);
    }

    // create select list from devices
    public List<SelectOption> getMobileDevicesSO(String myMobileDeviceID)
    {
        if (devices == null) return null;
        if (devices.isEmpty()) return new List<SelectOption>();

        List<SelectOption> retSOL = new List<SelectOption>();
        retSOL.add(new selectoption('', '-- please select --'));
        for (O2OnlineMobileController.MobileDevice device : devices)
        {
            retSOL.add(new SelectOption(device.device.id, device.device.Name));
            if (device.device.id == myMobileDeviceID)
            {
                deviceId = device.device.Id;
                thisDevice = device;
            }
        }

        if (deviceId != null) retSOL.remove(0);  // if preselected, null option not needed

        return retSOL;
    }

    public List<SelectOption> getMobileDeviceTariffsSO()
    {
        return getMobileDeviceTariffsSO(null, null, null);
    }

    public List<SelectOption> getMobileDeviceTariffsSO(Id myTariffId)
    {
        return getMobileDeviceTariffsSO(myTariffId, null, null);
    }

    // create select list from tariffs
    public List<SelectOption> getMobileDeviceTariffsSO(Id myTariffId, String tariffCode, String packageCode)
    {
        if (tariffs == null) return null;
        if (tariffs.isEmpty()) return new List<SelectOption>();
        // this is just for the speed of execution
        boolean setCurrentTariff =
			tariffCode != null && tariffCode != '' && packageCode != null && packageCode != '';
        boolean myTariffSet = myTariffId != null;
        boolean foundUserTariff = false;

        system.debug('### tariff data received (id/tariffCode/PackageCode): ' + myTariffId
				+ '/' + tariffCode + '/' + packageCode);

        List<SelectOption> retSOL = new List<SelectOption>();
        retSOL.add(new selectoption('', '-- please select --'));
        for (O2OnlineMobileController.MobileDeviceTariffUnique tariff : tariffs)
        {
            String tariffDesc = ' ('
                                + O2RetailUpgradeController.formatPrice(tariff.tariff.Price__c)
                                + ')';
            string soLabel = tariff.tariff.Name + tariffDesc;

            if (!foundUserTariff
				&& setCurrentTariff
				&& tariff.tariff.tariff_code__c == tariffCode
				&& tariff.tariff.package_code__c == packageCode)
            {
                soLAbel = '[Current] ' + soLabel;    // label current user tariff
                foundUserTariff = true;
				// myTariffId takes precedence over selecting by tariffCode and PackageCode
                if (!myTariffSet)
                {
                    tariffId = tariff.tariff.id;
                    thisTariff = tariff;
                }
            }
            if (myTariffSet && tariff.tariff.id == myTariffId)
            {
                tariffId = tariff.tariff.id;
                thisTariff = tariff;
            }
            retSOL.add(new SelectOption(tariff.tariff.id, soLabel));
        }

        if ((myTariffSet || setCurrentTariff) && tariffId != null)
		{
			retSOL.remove(0);  // if preselected, null option not needed
		}
        return retSOL;
    }

    // populate bolton select lists
    public void setMobileTariffBoltonsSO()
    {
        dataBoltonId = null;
        faveBoltonId = null;
        minsBoltonId = null;
        thisDataBolton = null;
        thisFaveBolton = null;
        thisMinsBolton = null;

        if (tariffId == null || tariffs == null || tariffs.isEmpty())
        {
            dataBoltonsSO = new List<SelectOption>();
            faveBoltonsSO = new List<SelectOption>();
            minsBoltonsSO = new List<SelectOption>();
            return;
        }

        dataBoltonsSO = new List<SelectOption>(); dataBoltonsSO.add(new SelectOption('', '-- none --'));
        faveBoltonsSO = new List<SelectOption>(); faveBoltonsSO.add(new SelectOption('', '-- none --'));
        minsBoltonsSO = new List<SelectOption>(); minsBoltonsSO.add(new SelectOption('', '-- none --'));
		if(thisTariff.boltons != null){
	        for (O2_DISE_Map_Mobile_Bolton__c bolton : thisTariff.boltons)
	        {
				// TODO: do I compare by bolton type or key?
				if (bolton.Bolt_On_Type__c == 'DATA BOLTON')
				{
					dataBoltonsSO.add(new SelectOption(bolton.id, bolton.Name));
				}
				else if (bolton.Bolt_On_Type__c == 'INTERNATIONAL FAVOURITES')
				{
					faveBoltonsSO.add(new SelectOption(bolton.id, bolton.Name));
				}
				else if (bolton.Bolt_On_Type__c == 'FOUR G ACCESS')
				{
					minsBoltonsSO.add(new SelectOption(bolton.id, bolton.Name));
				}
	        }
		}
    }
    	
    //added by DD - start
    public void setOffice365Products()	
    {
    	Office365ProductId='';
    	O365ProductsSO = new List<SelectOption>(); 
    		
    	O365ProductsSO.add(new SelectOption('', '-- none --'));
    		
    	List<Office_365_Price_list__c> lstOffice365 = lstOffice365Products();
    	    		
    	for (Office_365_Price_list__c tmpOffice : lstOffice365)
    	{
    		O365ProductsSO.add(new SelectOption(tmpOffice.Product_Code__c, tmpOffice.Product_Name__c));
    	}

    }
    	
    	
    public List<Office_365_Price_list__c> lstOffice365Products()
    {
    	List<Office_365_Price_list__c> tmpListOffice365Products = [select Id,Name,Product_Code__c,Product_Name__c
    		from Office_365_Price_list__c order by Name];
    	
    	return tmpListOffice365Products;
 
    }
    	
    public string Ofice365SelectedProductName()
    { 
    	string tmp='-';

    		
    	list<Office_365_Price_list__c> lstOffice = [select Id,Product_Name__c from Office_365_Price_list__c where Product_Code__c = : Office365ProductId];	
    	if (lstOffice.size()>0) tmp=lstOffice[0].Product_Name__c;
    		
    	return tmp;
    }
    
    //added by DD - end

    public void refreshDevices()
    {
        retrieveMobileDevices();
        refreshTariffs();
    }

    public void refreshTariffs()
    {
        refreshTariffs(null, null);
    }

    public void refreshTariffs(String tariffCode, String packageCode)
    {
        tariffId = null; thisTariff = null;
        retrieveMobileTariffs();
        if (tariffCode != null && packageCode != null)
		{
			getMobileDeviceTariffsSO(null, tariffCode, packageCode);
		}	// find tariff that will be preselected based on codes
        refreshTariffDetails();
    }

    public void refreshTariffDetails()
    {
        if (tariffId != null)
        {
            for (O2OnlineMobileController.MobileDeviceTariffUnique tariff : tariffs)
            {
                if (tariff.tariff.id == tariffId)
                {
                    thisTariff = tariff;
                    break;
                }
            }
        }
        setMobileTariffBoltonsSO();
        try
        {
            if (thisDevice != null && thisTariff != null)
            {
                O2_Dise_Map_Handset__c[] insuranceProduct =
					O2OnlineMobileController.getHandsetPricing(thisDevice.device.Product_Code__r.Product_Code__c,
							thisTariff.tariff.Name);
                if (insuranceProduct != null && insuranceProduct.size() > 0)
				{
                    insurancePrice = insuranceProduct.get(0).Insurance_Service_Price__c;
                    insuranceServiceCode = insuranceProduct.get(0).Insurance_Service_Code__c;
                }
            }
            else insurancePrice = 0;
        }
        catch (exception e)
		{
			insurancePrice = null;
		}
    }

    //check that IMEI is a valid alphanumber
    public boolean validateIMEInumber()
    {
        if (IMEInumber == null || IMEInumber.isWhitespace())
		{
			return false;
		}
        return IMEInumber.isNumeric() && IMEInumber.length() == 15;
    }

    //check that SIM is a valid number format
    public boolean validateSIMnumber()
    {
        if (SIMnumber == null || SIMnumber.isWhitespace())
		{
			return false;
		}
        if (SIMnumber.isNumeric())
        {
            if ((SIMnumber.length() == 11 && SIMnumber.startsWith('6'))
				|| (SIMnumber.length() == 19 && SIMnumber.startsWith('894411006')))
            {
                return true;
            }
        }
        return false;
    }

    // clear lists and find selected details
    public void proceedData()
    {
        for (O2OnlineMobileController.MobileDevice device : devices)
        {
            if (device.device.id == deviceId)
            {
                thisDevice = device;
                break;
            }
        }

        for (O2OnlineMobileController.MobileDeviceTariffUnique tariff : tariffs)
        {
            if (tariff.tariff.id == tariffId)
            {
                thisTariff = tariff;
                break;
            }
        }
		if(thisTariff.boltons != null){
	        for (O2_DISE_Map_Mobile_Bolton__c bolton : thisTariff.boltons)
	        {
	            if (bolton.id == dataBoltonId)
	            {
	                thisDataBolton = bolton;
	            }
	            else
	            {
	                if (bolton.id == faveBoltonId)
	                {
	                    thisFaveBolton = bolton;
	                }
	                else
	                {
	                    if (bolton.id == minsBoltonId)
	                    {
	                        thisMinsBolton = bolton;
	                    }
	                }
	            }
	        }
		}

        // delete boltons if blank values was selected on edit details
        if (dataBoltonId == null) thisDataBolton = null;
        if (faveBoltonId == null) thisFaveBolton = null;
        if (minsBoltonId == null) thisMinsBolton = null;

        devices = null;
        tariffs = null;
        dataBoltonsSO = null;
        faveBoltonsSO = null;
        minsBoltonsSO = null;
    }

    // create basket
    public void createBasket()
    {
        if (basketController.selDevicesListNew == null)
		{
			basketController.selDevicesListNew = new List<O2OnlineMobileController.MobileDeviceJS>();
		}
        basketController.selDevicesListNew.clear();
        basketController.selDevicesListNew.add(
				mobileDeviceToJS(thisDevice, addInsurance, tariffId, thisTariff.tariff.Name));
        if (basketController.selTariffsList == null)
		{
			basketController.selTariffsList = new List<O2OnlineMobileController.MobileDeviceTariffUniqueJS>();
		}
        basketController.selTariffsList.clear();
        basketController.selTariffsList.add(mobileTariffToJS(thisTariff));

        basketController.selectedBoltOnIds = (dataBoltonId != null ? (String) dataBoltonId : '');
        basketController.selectedBoltOnIds +=
			(basketController.selectedBoltOnIds != ''
			 ? (faveBoltonId != null ? (', ' + (String) faveBoltonId) : '')
			 : (faveBoltonId != null ? (String) faveBoltonId : ''));
        basketController.selectedBoltOnIds +=
			(basketController.selectedBoltOnIds != ''
			 ? (minsBoltonId != null ? (', ' + (String) minsBoltonId) : '')
			 : (minsBoltonId != null ? (String) minsBoltonId : ''));
        if (basketController.selectedBoltOnIds == '')
		{
			basketController.selectedBoltOnIds = null;
		}

        //basketController.maincontroller.startSession();
        basketController.addProductToSessionBasketTL_General();

        //if no other fix, use this to remove faulty config
        List<cscfgc.ProductConfiguration> configs =
			basketController.maincontroller.apiSession.getConfigsForBasket();
        List<cscfgc__Product_Configuration__c> removePCs = new List<cscfgc__Product_Configuration__c>();
        for (cscfgc.ProductConfiguration pc : configs)
        {
            if (pc.getConfigStatus() != 'Valid')
            {
                cscfgc__Product_Configuration__c pcO = pc.getSObject();
                //basketController.maincontroller.apiSession.removeConfigurationFromBasket(pcO.Id);
                basketController.maincontroller.newAPISession.removeConfigurationFromBasket(pcO.Id);
                removePCs.add(pcO);
            }
        }
        try
        {
            if (!removePCs.isEmpty())
			{
				delete removePCs;  // just in case they are still in the system
			}
        }
        catch (exception e)
		{
			system.debug('*** Deletion not neccessary.');
		}
    }

    public void closeSession()
    {
        if (basketController.maincontroller.apiSession != null)
        {
            basketController.maincontroller.apiSession.close();
        }
        try
        {
            if (basketController.maincontroller.newAPISession != null)
            {
                basketController.maincontroller.newAPISession.close();
            }
        }
        catch (exception e)
		{
		   system.debug(e.getMessage());
		}
    }

    public void emptyBasket()
    {
        if (basketController.maincontroller.apiSession != null)
        {
            if (basketController.maincontroller.sessionbasket == null)
			{
				basketController.maincontroller.sessionbasket =
					basketController.maincontroller.apiSession.getBasket();
			}
            basketController.maincontroller.currentConfigs =
				[
				SELECT Id, Name, cscfgc__Total_Price__c, cscfgc__Recurring_Charge__c,
				cscfgc__Product_Basket__c, cscfgc__One_Off_Charge__c,
                cscfgc__configuration_status__c, cscfgc__Parent_Configuration__c,
				cscfgc__Product_Definition__c, cscfgc__Product_Definition__r.Name, cscfgc__Screen_Flow__r.Name
                FROM cscfgc__Product_Configuration__c
                WHERE cscfgc__Product_Basket__c = :basketController.maincontroller.sessionbasket.Id
				ORDER BY cscfgc__Serial_Number__c DESC
				];
            List<cscfgc__Product_Configuration__c> removePCs =
				basketController.maincontroller.currentConfigs.deepClone(true, true, true);
            if (!basketController.maincontroller.currentConfigs.isEmpty())
			{
				basketController.maincontroller.emptyBasket();
			}
            basketController.maincontroller.currentConfigs = null;
            try
            {
                if (!removePCs.isEmpty()) delete removePCs;  // just in case they are still in the system
            }
            catch (exception e)
			{
				system.debug('*** Deletion error: ' + e.getMessage());
			}
        }
    }

    // when working with SIM Only

    public List<SelectOption> getSIMOnlyCombosSO(String selectSim)
    {
        List<SelectOption> retList = getSIMOnlyCombosSO();
        chooseSIMOnly = selectSim;
        if (selectSim != null && selectSim != null) retList.remove(0);   // we don't need empty option then
        return retList;
    }

    public List<SelectOption> getSIMOnlyCombosSO()
    {
        List<SelectOption> retList = new List<SelectOption>();
        if (upgradeType != UPGRADETYPE2) return retList;
        retList.add(new selectoption('', '-- please select --'));
        List<SelectOption> hsClassList = basketController.getHSClasses();

        for (O2OnlineMobileController.MobileDevice device : devices)
        {
            for (SelectOption so : hsClassList)
            {
                retList.add(
						new SelectOption(device.device.Name + ';' + so.getValue(),
							device.device.Name + ' - ' + so.getLabel()));
            }
        }
        return retList;
    }

	// Used only in unit tests
    public boolean hasValidConfigs()
    {
        try
        {
            List<cscfgc.ProductConfiguration> configs = basketController.maincontroller.apiSession.getConfigsForBasket();
            for (cscfgc.ProductConfiguration pc : configs) if (pc.getConfigStatus() == 'Valid') return true;
        }
        catch (exception e) { }
        return false;
    }

    // getters

    public String getUPGRADETYPE1() { return UPGRADETYPE1; }
    public String getUPGRADETYPE2() { return UPGRADETYPE2; }

    // helpers
    public static O2OnlineMobileController.MobileDeviceJS mobileDeviceToJS(O2OnlineMobileController.MobileDevice md, boolean addInsuranceS, id tariffIdS, String tariffNameS)
    {
        O2OnlineMobileController.MobileDeviceJS retValJS = new O2OnlineMobileController.MobileDeviceJS();
        retValJS.device = md.device.clone(true, true, true, true);
        retValJS.quantity = 1;

        retValJS.insure = addInsuranceS;
        retValJS.tariffID = tariffIdS;

        // set price fields
        try
        {
            O2_DISE_Map_Handset__c handset =
				O2OnlineMobileController.getHandsetPricing(
						md.device.Product_Code__r.Product_Code__c, tariffNameS).get(0);
            retValJS.insurancePrice = handset.Insurance_Service_Price__c;
            retValJS.price = handset.Discounted_Price__c;
        }
        catch (exception e)
        {
            system.debug('***No O2 Handset found. Error: ' + e.getMessage());
        }

        return retValJS;
    }

    public static O2OnlineMobileController.MobileDeviceTariffUniqueJS
		mobileTariffToJS(O2OnlineMobileController.MobileDeviceTariffUnique mt)
    {
        O2OnlineMobileController.MobileDeviceTariffUniqueJS retValJS =
			new O2OnlineMobileController.MobileDeviceTariffUniqueJS();
        retValJS.tariff = mt.tariff.clone(true, true, true, true);
        if(mt.boltons != null){
        	retValJS.boltons = mt.boltons.deepClone(true, true, true);
        }
        return retValJS;
    }

    public static Account resolveAccount(String DISEAccountNumber, Map<String, Object> fieldMap)
    {
        Account a;
        // add account fields in select as needed
        if (DISEAccountNumber != null)
		{
            try
			{
                a = [
					SELECT Name, RecordTypeID, DISE_Account_No__c
					FROM Account
					WHERE DISE_Account_No__c = :DISEAccountNumber
					LIMIT 1
					];
            }
            catch (exception e) {system.debug(e.getMessage());}
        }
        if (a == null)
		{
            system.debug('***Assigning new Account.');
            a = new Account();
            a.RecordTypeId =
				[
				SELECT Id
				FROM RecordType
				WHERE Name = 'Customer Account'
				AND SobjectType = 'Account'
				LIMIT 1
				].Id;
        }

        // assign field values based on map - key is api name of field,
		// and value is field value as OBJECT and can contain any basic data type
        Sobject sobj = a;
        for (String fKey : fieldMap.keySet())
        {
            sobj.put(fKey, (Object) fieldMap.get(fKey));
        }
        if (a.DISE_Account_No__c == null) a.DISE_Account_No__c = DISEAccountNumber;
        upsert a;
        return a;
    }

    public static Contact resolveContact(Id accountId, String DISEAccountNumber, Map<String, Object> fieldMap)
    {
        Contact c;
        // add Contact fields in select as needed
        try
        {
            if (accountId != null || DISEAccountNumber != null)
            {
				c = [
					SELECT Name,
					DISE_Account_No__c,
					FirstName,
				 	LastName,
					Salutation,
					Title,
					Phone,
					OtherPhone,
					Fax,
					Email,
					Date_of_Birth__c
					FROM Contact
				    WHERE AccountId = :accountId
				    OR DISE_Account_No__c = :DISEAccountNumber
				    LIMIT 1
					];
            }
        }
        catch (exception e) { system.debug(e.getMessage()); }
        if (c == null)
        {
            system.debug('***Assigning new Contact.');
            c = new Contact();
        }

        // assign field values based on map - key is api name of field,
		// and value is field value as OBJECT and can contain any basic data type
        Sobject sobj = c;
        for (String fKey : fieldMap.keySet())
        {
            sobj.put(fKey, (Object) fieldMap.get(fKey));
        }
        if (c.AccountId == null) c.AccountId = accountId;
        upsert c;
        return c;
    }

    public static Id bundleBasket(cscfgc__Product_Basket__c currentBasket, Account acc,
			Contact con, Map<String, String> opptyFields)
    {
        // Email address for Email confirmation after checkout
        if (con.Email != null && con.Email != '') opptyFields.put('ConfirmationEmailAddr', con.Email);

        cscfgc__Product_Bundle__c bundle =
			O2OrderHelper.createOpportunityBundle(con.Id, acc, currentBasket, opptyFields);

        Id oppId = bundle.cscfgc__Opportunity__c;

        // don't thingk we need this
        List<Opportunity> orderOpp = new List<Opportunity>();
        orderOpp =
			[
			SELECT Id, Order_Request_Number__c, IMEI_number__c, SIM_number__c,
				   (SELECT id, cscfgc__Bundle_Status__c, cscfgc__Total_Price__c
					FROM cscfgc__Product_Bundles__r
					WHERE Id = :bundle.Id)
			FROM Opportunity
			WHERE Id = :oppId
			];

        if (orderOpp != null && orderOpp.size() > 0
			&& orderOpp[0].cscfgc__Product_Bundles__r != null
			&& orderOpp[0].cscfgc__Product_Bundles__r[0].cscfgc__Bundle_Status__c == 'Valid')
        {
            O2OrderHelper.synchBundleWithOpportunity(bundle);
        }// i don't think we need this, it's covered by createOpportunityBundle

        return oppId;
    }
}