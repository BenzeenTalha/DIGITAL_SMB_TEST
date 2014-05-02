public with sharing class O2OnlineOrderController {

/*  General concensus is that this is not used any more

    public cscfgc.API_1.ApiSession apiSession;
    public cscfgc.SessionManager.SessionInfo userSession;

    public static string PACKAGE_PREFIX = 'cscfgc__';
    public static string CONTACT_US = 'O2OnlineContactUsStandard';
    public static final string DN_ERROR = 'dnerror';
    public static final string PC_ERROR = 'pcerror';
    public static final string DN_PC_ERROR = 'dnpcerror';
    public static final string DN_PC_SUCCESS = 'success';
    public String definitionId {get; set;}
    public String definitionRef {get; set;}
    public String offerId {get;set;}
    public String productName {get;set;}
    public String screenFlowName {get; set;}
    public String screenIndex {get; set;}  
	public String screenFlowLandingRef {get {return 'O2BusinessShopLanding3';} set;}
	
    public String removeProductId {get; set;}
    public String editConfigId {get;set;}
    
    public  O2OnlineOrderController() {}     
     
    public O2OnlineOrderController getController() {return this;}

    
    public string getScreenFlowTemplate() {
        return apiSession.getController().getcurrentScreen().cscfgc__screen_flow__r.cscfgc__template_reference__c;
    }

    public cscfgc.ProductConfiguration getConfig() {return apiSession.getConfiguration();}

    public cscfgc.ProductConfiguratorController getConfiguratorController() {return apiSession.getController();}   

    public String getProduct() {
    	String strProdName = '';
        if (apiSession!=null) {strProdName = apiSession.getConfiguration().getsObject().cscfgc__product_definition__r.name;}
        return strProdname;
    }
    
    private String getProvideTypeAttribute() {
    	String attribName = '';
    	
    	if (productName.contains('Landline')) attribName = 'Provide Type';
    	else if (productName.contains('Broadband')) attribName = 'Order Type';
    	
    	return attribName;
    }
    
    private String getDNAttribute() {
    	String attribName = '';
    	
    	if (productName.contains('Landline') || productName.contains('ISDN2')) attribName = 'Existing Telephone Number';
    	else if (productName.contains('Broadband')) attribName = 'Landline Number';
    	else if (productName.contains('Calls Only')) attribName = 'Line Number';
    	
    	return attribName;
    }

    private String getPCAttribute() {
    	String attribName = 'Postcode';

		// Just list the exceptions    	
		if (productName.contains('Broadband')) attribName = 'Install Postcode';
    	
    	return attribName;
    }

    public PageReference startSession() {
        userSession = cscfgc.SessionManager.getSessionInfo();
        sessionbasket = userSession.getSessionBasket();
        return null;
    }
    public PageReference retrieveSession() {
    	apiSession = cscfgc.API_1.getApiSession();
    	userSession = apiSession.loadUserSession(apiSession.getUserSession().usersession.Id);
    	sessionbasket = userSession.getSessionBasket();
    	return null;
    }
    
    public integer getCurrentConfigScreenIndex() {
        return integer.valueOf( getconfig().getCurrentScreen().cscfgc__Index__c);
    }
    
    public PageReference selectProduct() {
        cscfgc__Product_Definition__c def = null;
        
        if (definitionRef != null && definitionRef != '') def = cscfgc.API_1.findProductDefinition(definitionRef);
        else def = new cscfgc__Product_Definition__c(id=definitionId);
    	
    	apiSession = cscfgc.API_1.getApiSession(def);
    	userSession = apiSession.getUserSession();
    	sessionbasket = userSession.getSessionBasket();
        apiSession.setProductToConfigure(def);	//SW ADDED 12/07/2011
        productName = getProduct();
        screenIndex = '0';        
        apiSession.getController().screenFlowName = screenFlowName;
        return selectScreen();
    }

	public String lineCheckReason {get; set;}
	public String lineCheckStatus {get; set;}
	public String lineType {get; set;}
	
	public PageReference landlineCheck() {
		 if (this.provideType == 'Transfer' || getProduct().contains('Calls Only')) {
		 	lineCheckStatus = 'Error';		 	
		 	System.debug('  Running Line Check  ...' + this.transferNumber + ' '+this.transferPostcode);
			Batch_Job__c lineCheck;
			try {
				 lineCheck = AvailabilityCheckInputProcessor.processLineAvailablityImmediate(this.transferNumber, this.transferPostcode, 'Line');
			 	 System.debug('   ... Line Check Completed. Updating with results');
			 	 if (lineCheck != null) {
				 	Line_Availability__c la = [SELECT Id, Service_Type__c, Status__c, reasonCode__c FROM Line_Availability__c WHERE Batch_Job__c = :lineCheck.Id];
				 	lineCheckStatus = la.Status__c;
				 	lineCheckReason = la.reasonCode__c;
					 if (la != null && la.Status__c == 'Completed') {
					 	cscfgc.ProductConfiguration currConfig = apiSession.getConfiguration();	
					 	currConfig = O2OrderHelper.populateConfiguration(getProduct(), currConfig, la.Id);
					 	lineType = currConfig.getAttribute('Line Type').getValue(); 
					 }
				 }
			}
			catch (Exception ex) {
				lineCheckStatus = null;
				lineCheckReason = 'FAIL';
				System.debug('Online Line Check failed: '+ex.getMessage());
			}
		 }
		
		return null;
	}

	private void validateBB() {
		
		
		//query the number of options in the broadband package type
		// If there multiple options display some stuff to the user for information
		// This will be in a section below the Continue button?
		
		// TBC: if it's IPS, display message, change continue button to go to contact us?
		// Or use the error page
		// Behaviour same for all subscriber results
		
		// Reason Code = V or P (TBC) 
		// Message cannot support, change continue button to go to contact us.
		
		// Bad Input
		// 1) They saw they want to transfer but no BB already on that number
		// 2) bad postcode
		// 3) Bad Directory Number (01206768954)
		
		// Technical Error - check failed
		// Display the try again later
	}
	
	private void validateSubscriber() {
		// We need to standardise the response to users as per Adrian's matrix
	}

	public PageReference broadbandCheck() {
		Batch_Job__c lineCheck;
		try {		
		 	System.debug('  Running BB Check  ...' + this.transferNumber + ' '+this.transferPostcode);
			lineCheck = AvailabilityCheckInputProcessor.processLineAvailablityImmediate(this.transferNumber, this.transferPostcode, 'Broadband');
		 	System.debug('   ... BB Check Completed. Updating with results');
		}
		catch (Exception ex) {
			// Temporarily - friendy error handling
			System.debug('BB Availability check exception: '+ex.getMessage());
			ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'We are unable to check BB availability for the details provided');
			ApexPages.addMessage(errMsg);
		}
	 	if (lineCheck != null) {
		 	Line_Availability__c la = [SELECT Id FROM Line_Availability__c WHERE Batch_Job__c = :lineCheck.Id];
			 if (la != null) {
			 	cscfgc.ProductConfiguration currConfig = apiSession.getConfiguration();	
			 	currConfig = O2OrderHelper.populateConfiguration(getProduct(), currConfig, la.Id);
			 }				 	
		}
		
		return selectScreen();
	}


    public PageReference selectScreen() {
            apiSession.getController().screenindex = this.screenIndex;                      
            PageReference p = apiSession.getController().selectScreen();
            
            string url = p.getUrl();
            url = url.replace(PACKAGE_PREFIX, '');
            System.debug('>>>>>>>> URL: ' + url);
            PageReference targetP = new PageReference(url);
            return targetP;
    }
        

    //#############################################
    //### SW CREATED CODE #########################
    //#############################################
    public String provideType;
    public String getprovideType() {return apiSession.getConfiguration().getAttribute(getProvideTypeAttribute()).getValue();}
    public void setprovideType(String s) {
        provideType = s;
        apiSession.getConfiguration().getAttribute(getProvideTypeAttribute()).setValue(provideType);
        if (getProduct().contains('Landline') && provideType=='New Provide') {
        	apiSession.getConfiguration().getAttribute('New Order Type').setValue('New Line Provide');
        	apiSession.getConfiguration().getAttribute('Installation Work Required?').setValue('Yes');
        }
    }   
    
    public String transferNumber;
    public String gettransferNumber() {return apiSession.getConfiguration().getAttribute(getDNAttribute()).getValue();}
    public void settransferNumber(String s) {
        transferNumber = s;
        apiSession.getConfiguration().getAttribute(getDNAttribute()).setValue(transferNumber);

    	// Hard code temporarily
    	if (getProduct().contains('Broadband')) apiSession.getConfiguration().getAttribute('O2 Customer').setValue('No');

    }

    public String transferPostcode;
    public String gettransferPostcode() {return apiSession.getConfiguration().getAttribute(getPCAttribute()).getValue();}
    public void settransferPostcode(String s) {
        transferPostcode = s;
        apiSession.getConfiguration().getAttribute(getPCAttribute()).setValue(transferPostcode);
    }

    public String existingCustomer;
    public String getexistingCustomer() {return existingCustomer;}
    public void setexistingCustomer(String s) {
    	existingCustomer = s;
    	// Hard code temporarily
    	if (getProduct().contains('Broadband')) apiSession.getConfiguration().getAttribute('O2 Customer').setValue('No');
    	else if (getProduct().contains('Landline')) apiSession.getConfiguration().getAttribute('O2 Customer').setValue(s);
    }

    public String existingNumber;
    public String getexistingNumber() {return existingNumber;}
    public void setexistingNumber(String s) {existingNumber = s;}
    
    public String getCurrentScreenName() {return String.valueOf( getconfig().getCurrentScreen().Name);}
    
    //BASKET METHODS AND CODE
    public String numProducts {get;set;}
    public cscfgc__Product_Basket__c sessionbasket;
    public cscfgc__Product_Basket__c getSessionBasket() {
        //sessionbasket = apiSession.getBasket();
        sessionbasket = userSession.getSessionBasket();
        return sessionbasket;
    }
    public PageReference addToBasket() {
		apiSession.getController().updateConfig();
        apiSession.executeRules();
		sessionbasket = apiSession.persistConfiguration(true);
		System.debug('### OUTPUT >>>>> addToBasket: controller.currentConfig: '+apiSession.getController().getConfig());
        System.debug('### OUTPUT >>>>> addToBasket: sessionbasket: '+sessionbasket);
        //insert any new addresses identified for saving
        if (newLocations!=null && newLocations.size()>0) {
        	for (Location__c loc: newLocations) {loc.Product_Configuration__c = apiSession.getController().getConfig().getsObject().Id;}
        	try {insert newLocations;}
        	catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));return null;}
        }
        return goToBasket();
    }
    public PageReference goToBasket() {
        Pagereference p = new Pagereference('/apex/O2OnlineProductPageFinal');
        p.setRedirect(true);
        return p;
    }
    public PageReference continueShopping() {
        Pagereference p = new Pagereference('/apex/'+screenFlowLandingRef);
        p.setRedirect(true);
    	return p;
    }

    //############### NEW RELATED PRODUCTS CODE #############
	public PageReference selectScreen(string theScreenIndex)
	{
		
	// Check if the tariff code is being set - we may have to add an executeRules... on certain
	// page transitions...
		// While this works (to get the tariff code, it takes 9 SECONDS TO EXECUTE and then causes Too Many Script Statements later
		//System.debug('b4 execRules');
		//apiSession.executeRules();
		//System.debug('@@@RAC Tariff Code is '+ apiSession.getConfiguration().getAttribute('Tariff Code').getValue() + '@@@RAC');
		// 
		
	    apiSession.getController().screenindex = theScreenIndex;            
	    PageReference p = apiSession.getController().selectScreen();
	    string url = p.getUrl();
	    url = url.replace(PACKAGE_PREFIX, '');
	    PageReference targetP = new PageReference(url);
	    return apiSession.preparePage(targetP);      
	}
	public string relScreenFlowname {get;set;}
	public String relScreenIndex {get; set;}
	public String relDefinitionId {get; set;}
	public String relDefinitionRef {get; set;} 
	public string relParentAttributeName {get; set;} 
	public string tariff {get; set;} 
	  
	public pagereference addOrSelectRelatedProduct()
	{ 
	  string parentAttributeName = relParentAttributeName;
	  string relatedDefinitionRef = relDefinitionRef;    
	  string relatedProductscreenFlowName = relScreenFlowname;
	  string relatedScreenIndex = relScreenIndex;
	             
	  cscfgc.Attribute att = apiSession.getAttributeForCurrentConfig(parentAttributeName);
	  if (att.getRelatedProducts().size() > 0)
	  {
	    string ref = att.getRelatedProducts()[0].getreference().getAsString();
	    apiSession.setRelatedProductToEdit(ref);      
	  }
	  else
	    addRelatedProduct();   
	    
	  
	  return selectScreen(relScreenIndex);
	}
	
	public cscfgc.ProductConfiguration storeMinuteBoltOnsRelatedProduct()
	{
		//tariff should be set here as well if component is added.	
		tariff = 'Q11ZAX';
		
		if(minutesNumber != '0'){
			cscfgc__Product_Definition__c minuteProdDef = [select Id, Name 
															from cscfgc__Product_Definition__c 
															WHERE Name = 'Fixed Line Minute Bolt On' AND cscfgc__Active__c = true LIMIT 1];
			
			List<O2_DISE_Map_Minutes__c> minuteBoltOns = [SELECT Id, Tariff_Code__c,
															 Minutes_Type__c, Minutes_Number__c, Effective_Date__c 
							    							 From O2_DISE_Map_Minutes__c
							    							 WHERE Minutes_Type__c = :minutesDestinationTypes
							    							 AND  Minutes_Number__c = :minutesNumber
							    							 AND   Tariff_Code__c = :tariff];
							    							 		
			cscfgc.ProductConfiguration relatedConfig = apisession.AddRelatedProduct('Minutes Bolt On', minuteProdDef.Id);	
			if(minuteBoltOns.size() > 1){	
				relatedConfig.getAttribute('Select Extra Minutes Bolt On').setValue(minuteBoltOns[minuteBoltOns.size()-1].Id);
				relatedConfig.getAttribute('Extra Minutes Type').setValue(minuteBoltOns[minuteBoltOns.size()-1].Minutes_Type__c);	
			}
			else {
				relatedConfig.getAttribute('Select Extra Minutes Bolt On').setValue(minuteBoltOns[0].Id);
				relatedConfig.getAttribute('Extra Minutes Type').setValue(minuteBoltOns[0].Minutes_Type__c);
			}
		}
		return null;
	}
	
	public cscfgc.ProductConfiguration addRelatedProduct()
	{
	  string parentAttributeName = relParentAttributeName;
	  string relatedDefinitionRef = relDefinitionRef;    
	  string relatedProductscreenFlowName = relScreenFlowname;
	  cscfgc__Product_definition__c def  = cscfgc.API_1.findProductDefinition(relatedDefinitionRef);
	  Id relatedProductDefinitionId = def.id;
	  apisession.AddRelatedProduct(parentAttributeName, relatedProductDefinitionId, relatedProductscreenFlowName);
	  return apiSession.getConfiguration();
	}
	
	public PageReference storeRelatedProduct()
	{        
	  apiSession.getController().reference = '';    // back up to root level product
	  apiSession.getController().updateConfig();    // use updateAddSelectConfig when you want validation
	  apiSession.getController().selectConfig();    // not required if using updateAddSelectConfig
	  //apiSession.getController().screenFlowName = screenFlowName;
	  
	  // Validate the additional minutes is not for a n/a value
	  // @TODO

	  // Save the Additional Minutes if validation OK
	  storeMinuteBoltOnsRelatedProduct();
	  
	  // Navigate back to the root product
	  apiSession.getController().reference = '';    // back up to root level product
	  apiSession.getController().updateConfig();    // use updateAddSelectConfig when you want validation
	  apiSession.getController().selectConfig();    // not required if using updateAddSelectConfig
	  apiSession.getController().screenFlowName = screenFlowName;
	     	  
	  return selectscreen(screenIndex);
	}
    //############## END NEW RELATED PRODUCTS CODE ###########
  
    public PageReference proceedToCheckout() {return Page.O2OnlineCheckoutPage1;}

	public class O2OnlineException extends Exception {}

	public String isO2Customer {get;set;}
	public String customerType {get;set;}
	public PageReference checkSubscriber() {
		try {
			System.debug('### OUTPUT >>>>> checkSubscriber: sessionbasket: '+sessionbasket);
			SubscriberController subcontroller = new SubscriberController();
			subcontroller.inputNumber = existingNumber;
			isO2Customer = '';
			customerType = '';
			PageReference resPage = subcontroller.getSubscriberProfile();
			isO2Customer = subcontroller.operator;
			customerType = subcontroller.segment;
			System.debug('### OUTPUT >>>>> checkSubscriber: operator & segment: '+isO2Customer+' - '+customerType);
		}
		catch (Exception e) {
			System.debug('### ERROR >>>>> checkSubscriber: ERROR: '+e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
		}
		return null;
	}
	
	public boolean showContactUs {get {if (showContactUs==null) return false; else return showContactUs;} set;}
	public boolean showContinue {get {if (showContinue==null) return true; else return showContinue;} set;}
	public PageReference performChecks() {
		PageReference nextPage = selectScreen();
		try {
			if (provideType != 'New Provide') {
				lineCheckReason = 'SUCCESS';
				showContactUs = false;
				landlineCheck();	//perform checks on landline
				// No Line Check result found
				if (lineCheckStatus == null) {
					// We need to display the Call Back button too
					showContinue = false;
					showContactUs = true;
					throw new O2OnlineException('Sorry, there is a problem our end checking what landline options are available for you. We should have the problem fixed shortly, so try back later.');
					//nextPage = new PageReference(CONTACT_US + '?reason=AvChkFail');
				}
				// Don't allow them to transfer a multiline PSTN
				else if (lineType != null && lineType.contains('Premium Multi')) {
					showContinue = false;
					showContactUs = true;
					throw new O2OnlineException('Sorry we do not support Multi-Line PSTN via our online shop but we can still help you, please Contact Us using the link below');
					//nextPage = new PageReference(CONTACT_US + '?reason=MultiLine');
				}
				// Check the product is an Single Landline
				else if (lineType != null && !lineType.contains('Premium Single')) {
					showContinue = false;
					showContactUs = true;
					throw new O2OnlineException('Sorry, your line type '+ lineType + ' is not supported via our online shop by we can still help, please Contact Us using the link below');
					//nextPage = new PageReference(CONTACT_US + '?reason=notPSTN');
				}
				//
				// Need test data that is not a valid line type but is a 
				// If the Service Type that is returned is not a supported O2 product - redirect to error page with message
				// This is when a featureline or redcare result is obtained 
				//else if (lineType == null) {
				//	showContinue = false;
				//	showContactUs = true;
				//	throw new O2OnlineException('');
				//	
				//}
				//

				// Check the Status Code of the Line Availability Check
				// If it is 2175, 2178, 2251 then we have a DN failure : TBC  - raise exception, allow them to retry; showContinue = false;
				// If it is 2408 we have the wrong postcode/DN combination - raise exception, allow them to retry
				// If it is 2158 we have a Postcode failure : TBC - doesn't seem to occur as 2408 comes up first, raise exception da-de-dah
				String pageAction = null;
				if (lineCheckReason != null && lineCheckReason != 'SUCCESS') pageAction = lineCheckResult(lineCheckReason);

				if (pageAction == DN_ERROR || pageAction == DN_PC_ERROR || pageAction == PC_ERROR) {
					showContinue = true;  // They have to resubmit
					showContactUs = false;
					throw new O2OnlineException('We haven’t been able to use the details you entered. Try entering the postcode or landline number again');
				}
				
			}
			
			if (existingCustomer!='No') {
				checkSubscriber();	//perform checks on existing number
				if (isO2Customer!='nonO2' && customerType!='Consumer') {existingCustomer = 'Yes';}
			}
		}
		catch (Exception e) {
			System.debug('### OUTPUT >>>>> performChecks: '+e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
			nextPage = null;
		}

		return nextPage;
	}
	
	//####### PAF ADDRESS HANDLING/CACHING CODE #######
	
	//### saved session addresses code
	//public String selectedCountry {get;set {selectedCountry = value;}}
	
	//add seperate methods for each install address and router adrres as otherwise it currently resets the incountry and rtcountry. Also set incountry or rtcountry only if incountry/rtcountry != default val
	
	public List<SelectOption> getAddressCountries() {
        List<SelectOption> lsOptions = new List<SelectOption>();
        lsOptions.add(new SelectOption(CountryCodes__c.getInstance().Country_Name__c, CountryCodes__c.getInstance().Country_Name__c));	//set default for ui
        if(CountryCodes__c.getInstance().Country_Name__c != null && CountryCodes__c.getInstance().Country_Name__c != ''){
        	 inCountry =  CountryCodes__c.getInstance().Country_Name__c;
        	 rtCountry = CountryCodes__c.getInstance().Country_Name__c;
        }
        lsOptions.add(new SelectOption('', '-- Select One --'));        
              
        // Find all the countries in the custom setting      
        Map<String, CountryCodes__c> countries = CountryCodes__c.getAll();
                
        // Sort them by name      
        List<String> countryNames = new List<String>();
        countryNames.addAll(countries.keySet());
        countryNames.sort();

        // Create the Select Options.  
    
        for (String countryName : countryNames) {
            CountryCodes__c country = countries.get(countryName);    
            if(country.Country_Name__c != CountryCodes__c.getInstance().Country_Name__c){
            	lsOptions.add(new SelectOption(country.Country_Name__c, country.Country_Name__c));
            }           
        }
        return lsOptions;
    }
	
	public String selectedAddressIndex {get;set;}
	public Map<ID, Location__c> savedLocations = new Map<ID, Location__c>();
	public List<Location__c> newLocations = new List<Location__c>();
	public List<SelectOption> getsavedLocationList() {
		List<Location__c> loclist = [SELECT Id, Name, Number_and_Street__c, Building_Unit_Name__c, PAF_Sub_Building_Name__c, PAF_Building_Name__c, PAF_Building_Number__c, Street__c, 
									 PAF_Post_Town__c, PAF_County__c, PAF_Postcode__c, PAF_Thoroughfare_Name__c, PAF_Thoroughfare_Descriptor__c, Country__c 
									 FROM Location__c WHERE User_Session__c = :userSession.userSession.Id];
		if (loclist!=null && loclist.size()>0) {savedLocations = new Map<ID, Location__c>(loclist);}
		return convertSavedLocationList(loclist);
	} 
	public void selectSavedInstallAddress() {selectAddress(savedLocations.get(selectedAddressIndex), 'installation');}
	public void selectSavedRouterAddress() {selectAddress(savedLocations.get(selectedAddressIndex), 'router');}
	
	//### installation address code
	public Boolean newInstallAddress {get {if (newInstallAddress==null) return true; else return newInstallAddress;} set;}
	
	public String selectedInstallAddress {get;set;}
	public void selectInstallAddress() {saveAndSelectAddress(selectedInstallAddress, 'installation');}
	//individual installation address variables
	public String inBuildingName {
		get {
			if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Premise Name').getValue(); 
			else return apiSession.getConfiguration().getAttribute('Building Name').getValue();
		}
		set {
			if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Premise Name').setValue(value);
			else apiSession.getConfiguration().getAttribute('Building Name').setValue(value);
		}
	}
	public String inBuildingNumber {
		get {
			if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Premise Number').getValue();
			else return apiSession.getConfiguration().getAttribute('Building Number').getValue();}
		set {
			if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Premise Number').setValue(value);
			else apiSession.getConfiguration().getAttribute('Building Number').setValue(value);
		}
	}
	public String inPostcode {
		get {
			if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Postcode').getValue();
			else return apiSession.getConfiguration().getAttribute('Postcode').getValue();
		}
		set {
			if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Postcode').setValue(value);
			else apiSession.getConfiguration().getAttribute('Postcode').setValue(value);
		}
	}
	public String inStreet {
		get {
			if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Street').getValue();
			else return apiSession.getConfiguration().getAttribute('Street').getValue();
		}
		set {
			if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Street').setValue(value);
			else apiSession.getConfiguration().getAttribute('Street').setValue(value);
		}
	}
	public String inTown {
		get {
			if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install City').getValue();
			else return apiSession.getConfiguration().getAttribute('Town').getValue();
		}
		set {
			if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install City').setValue(value);
			else apiSession.getConfiguration().getAttribute('Town').setValue(value);
		}
	}
	public String inCity {
		get {
			if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install City').getValue();
			else return apiSession.getConfiguration().getAttribute('City').getValue();
		}
		set {
			if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install City').setValue(value);
			else apiSession.getConfiguration().getAttribute('City').setValue(value);
		}
	}
	public String inCounty {
		get {
			if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install County').getValue();
			else return apiSession.getConfiguration().getAttribute('County').getValue();
		}
		set {
			if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install County').setValue(value);
			else apiSession.getConfiguration().getAttribute('County').setValue(value);
		}
	}
	public String inCountry {
		
		get {
			if (productName.contains('Broadband')) return apiSession.getConfiguration().getAttribute('Install Country').getValue();
			else return apiSession.getConfiguration().getAttribute('Country').getValue();
		}
		set {
			if (productName.contains('Broadband')) apiSession.getConfiguration().getAttribute('Install Country').setValue(value);
			else apiSession.getConfiguration().getAttribute('Country').setValue(value);
		}
	}



	//perform search for installation address and show results in output selectoptions
	public List<AddressCheckController.Address> installResAddresses;
	public List<selectOption> installationAddresses {get;set;}
	public PageReference searchInstallationAddresses() {
		System.debug('### OUTPUT >>>>> searchInstallationAddresses: method enter: '+inBuildingName+'|'+inBuildingNumber+'|'+inPostcode);
		List<selectOption> outputOptions = new List<selectOption>();
		installResAddresses = findAddresses(inBuildingName, inBuildingNumber, inPostcode);
		if (installResAddresses!=null && installResAddresses.size()>0) {
			//populate selectlist records from results list
			outputOptions.add(new SelectOption('', '-Select address-'));
			for (integer i=0; i<installResAddresses.size(); i++) {
				String strAddr = '';
				if (installResAddresses[i].subBuildingName!=null && installResAddresses[i].subBuildingName!='') strAddr+=installResAddresses[i].subBuildingName+',';
				if (installResAddresses[i].buildingName!=null && installResAddresses[i].buildingName!='') strAddr+=installResAddresses[i].buildingName+',';
				if (installResAddresses[i].buildingNumber!=null && installResAddresses[i].buildingNumber!='') strAddr+=installResAddresses[i].buildingNumber+',';
				if (installResAddresses[i].street!=null && installResAddresses[i].street!='') strAddr+=installResAddresses[i].street+',';
				if (strAddr!='') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-1)));
			}
		}
		else {
			//populate selectlist with 'NO RESULTS' marker
			outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
		}
		installationAddresses = outputOptions;
		
		return null;
	}
	
	//### router address code
	public Boolean newRouterAddress {get { if (newRouterAddress==null) return true; else return newRouterAddress;} set;}
	public String selectedRouterAddress {get;set;}
	public void selectRouterAddress() {saveAndSelectAddress(selectedRouterAddress, 'router');}
	//individual router address variables
	public String rtBuildingName {
		get {return apiSession.getConfiguration().getAttribute('Router Premise Name').getValue();}
		set {apiSession.getConfiguration().getAttribute('Router Premise Name').setValue(value);}
	}
	public String rtBuildingNumber {
		get {return apiSession.getConfiguration().getAttribute('Router Premise Number').getValue();}
		set {apiSession.getConfiguration().getAttribute('Router Premise Number').setValue(value);}
	}
	public String rtPostcode {
		get {return apiSession.getConfiguration().getAttribute('Router Postcode').getValue();}
		set {apiSession.getConfiguration().getAttribute('Router Postcode').setValue(value);}
	}
	public String rtStreet {
		get {return apiSession.getConfiguration().getAttribute('Router Street').getValue();}
		set {apiSession.getConfiguration().getAttribute('Router Street').setValue(value);}
	}
	public String rtCity {
		get {return apiSession.getConfiguration().getAttribute('Router City').getValue();}
		set {apiSession.getConfiguration().getAttribute('Router City').setValue(value);}
	}
	public String rtCounty {
		get {return apiSession.getConfiguration().getAttribute('Router County').getValue();}
		set {apiSession.getConfiguration().getAttribute('Router County').setValue(value);}
	}
	public String rtCountry {
		get {return apiSession.getConfiguration().getAttribute('Router Country').getValue();}
		set {
			cscfgc.Attribute country = apiSession.getConfiguration().getAttribute('Router Country');
			if (country != null) country.setValue(value);
			}
	}

	//perform search for router address and show results in output selectoptions
	public List<AddressCheckController.Address> routerResAddresses;
	public List<selectOption> routerAddresses {get;set;}
	public PageReference searchRouterAddresses() {
		List<selectOption> outputOptions = new List<selectOption>();
		routerResAddresses = findAddresses(rtBuildingName, rtBuildingNumber, rtPostcode);
		if (routerResAddresses!=null && routerResAddresses.size()>0) {
			//populate selectlist records from results list
			outputOptions.add(new SelectOption('', '-Select address-'));
			for (integer i=0; i<routerResAddresses.size(); i++) {
				String strAddr = '';
				if (routerResAddresses[i].subBuildingName!=null && routerResAddresses[i].subBuildingName!='') strAddr+=routerResAddresses[i].subBuildingName+',';
				if (routerResAddresses[i].buildingName!=null && routerResAddresses[i].buildingName!='') strAddr+=routerResAddresses[i].buildingName+',';
				if (routerResAddresses[i].buildingNumber!=null && routerResAddresses[i].buildingNumber!='') strAddr+=routerResAddresses[i].buildingNumber+',';
				if (routerResAddresses[i].street!=null && routerResAddresses[i].street!='') strAddr+=routerResAddresses[i].street+',';
				if (strAddr!='') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-1)));
			}
		}
		else {
			//populate selectlist with 'NO RESULTS' marker
			outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
		}
		routerAddresses = outputOptions;
		return null;
	}
	
	//### generic paf/address utility code
	//PAF search method
	public List<AddressCheckController.Address> findAddresses (String pafBuildingName, String pafBuildingNumber, String pafPostcode) {
		List<AddressCheckController.Address> resAddresses;
		try {
			System.debug('### OUTPUT >>>>> findAddresses: method start');
			AddressCheckController pafcontroller = new AddressCheckController();
			if (pafBuildingName!=null) pafcontroller.buildingName = pafBuildingName;
			if (pafBuildingNumber!=null) pafcontroller.buildingNumber = pafBuildingNumber;
			if (pafPostcode!=null) pafcontroller.postcode = pafPostcode;
			if (pafcontroller.postcode!=null && pafcontroller.postcode!='') {
				PageReference resPage = pafcontroller.addressSearch();
				resAddresses = pafcontroller.addressResults;
			}
		}
		catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));}
		return resAddresses;
	} 
	//method to convert Location__c list to selectoptions list
	public List<SelectOption> convertSavedLocationList(Location__c[] loclist) {
		List<SelectOption> outputOptions = new List<SelectOption>();
		if (loclist!=null && loclist.size()>0) {
			outputOptions.add(new SelectOption('', 'PLEASE SELECT'));
			for (Integer i=0; i<loclist.size(); i++) {
				if (loclist[i].Number_and_Street__c!=null && loclist[i].Number_and_Street__c!='') 
					outputOptions.add(new SelectOption(loclist[i].Id, loclist[i].Number_and_Street__c));
			}
		}
		else {outputOptions.add(new SelectOption('NO ADDRESSES SAVED', 'NO ADDRESSES SAVED'));}
		return outputOptions;
	}
	//method to save selected paf result address to session Locations list, and then select ie. set UI field variables
	public void saveAndSelectAddress(String index, String addrType) {
		if (addrType=='installation') {
			if (installResAddresses!=null && installResAddresses.size()>0 && index!=null && index!='') {
				integer i = Integer.valueOf(index);
				System.debug('### OUTPUT >>>>> setSaveAddress: installAddress:'+installResAddresses[i]);
				Location__c newLoc = createSavedSessionLocation(installResAddresses[i], 'Installation', userSession.userSession.Id);
				selectAddress(newLoc, addrType);
			}
		}
		else if(addrType=='router') {
			if (routerResAddresses!=null && routerResAddresses.size()>0 && index!=null && index!='') {
				System.debug('### OUTPUT >>>>> setSaveAddress: in router...');
				integer i = Integer.valueOf(index);
				System.debug('### OUTPUT >>>>> setSaveAddress: routerAddress:'+routerResAddresses[i]);
				Location__c newLoc = createSavedSessionLocation(routerResAddresses[i], 'Router', userSession.userSession.Id);
				selectAddress(newLoc, addrType);
			}
		}
		else {
			throw new O2OnlineException('Could not determine address type to save. Please use the contact form to notify us of this fault.');
		}
	}
	//method to create session Location record and if successful add to cached locations map
	public Location__c createSavedSessionLocation(AddressCheckController.Address addr, String strType, ID sessId) {
		Location__c newLoc;
		try {
			if (addr!=null && sessId!=null) {
				String strConfigId = apiSession.getConfiguration().getsObject().Id;
				newLoc = new Location__c(
					Type__c = strType,
					Product_Configuration__c = strConfigId,
					User_Session__c = sessId,
					Sync_with_Parent__c = false,
					PAF_Sub_Building_Name__c = addr.subBuildingName,
					PAF_Building_Name__c = addr.buildingName,
					PAF_Building_Number__c = addr.buildingNumber,
					PAF_Organisation_Name__c = addr.organisation,
					PAF_Dependent_Thoroughfare__c = addr.dependentStreet,
					PAF_Dependent_Thoroughfare_Descriptor__c = '',
					PAF_Thoroughfare_Name__c = addr.street,
					PAF_Thoroughfare_Descriptor__c = '',
					PAF_Double_Dependent_Locality__c = addr.dependentLocality,
					PAF_Dependent_Locality__c = addr.locality,
					PAF_Post_Town__c = addr.postTown,
					PAF_County__c = addr.county,
					PAF_Postcode__c = addr.postcode,
					Country__c = getCountryVal(strType)
					
				);
				//insert newLoc;	//insert moved to the AddToBasket method since we will then have a config id to include
				newLocations.add(newLoc);
			}
		}
		catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));}
		return newLoc;
	}
	
	//method to return country value
	public String getCountryVal(String strType){
		String countryVal;
		if(strType == 'installation') return inCountry;
		else return rtCountry;
	}
	//method to set UI field variables
	public void selectAddress(Location__c selectedloc, String strType) {
		if (strType == 'installation' && selectedloc!=null) {
			if (selectedloc.PAF_Building_Name__c!=null) inBuildingName = selectedloc.PAF_Building_Name__c;		
			if (selectedloc.PAF_Sub_Building_Name__c!=null && selectedloc.PAF_Sub_Building_Name__c!='')
			{ 
				if (inBuildingName != null) inBuildingName = selectedloc.PAF_Sub_Building_Name__c+','+inBuildingName;
				else inBuildingName = selectedloc.PAF_Sub_Building_Name__c;//+','+inBuildingName;
			}	
			if (selectedloc.PAF_Building_Number__c!=null) inBuildingNumber = selectedloc.PAF_Building_Number__c;
			if (selectedloc.PAF_Thoroughfare_Name__c!=null) inStreet = selectedloc.PAF_Thoroughfare_Name__c;
			if (selectedloc.PAF_Thoroughfare_Descriptor__c!=null) inStreet += selectedloc.PAF_Thoroughfare_Descriptor__c;
			//if (selectedloc.PAF_Post_Town__c!=null) inCity = selectedloc.PAF_Post_Town__c;
			if (selectedloc.PAF_Post_Town__c!=null) inTown = selectedloc.PAF_Post_Town__c;
			if (selectedloc.PAF_County__c!=null) inCounty = selectedloc.PAF_County__c;
			if (selectedloc.PAF_Postcode__c!=null) inPostcode = selectedloc.PAF_Postcode__c;
			if (selectedloc.Country__c!=null) inCountry = selectedloc.Country__c;			
		}
		else if (strType == 'router' && selectedloc!=null) {
			if (selectedloc.PAF_Building_Name__c!=null) rtBuildingName += selectedloc.PAF_Building_Name__c;
			if (selectedloc.PAF_Sub_Building_Name__c!=null && selectedloc.PAF_Sub_Building_Name__c!='')
			{ 
				if (rtBuildingName != null) rtBuildingName = selectedloc.PAF_Sub_Building_Name__c+','+rtBuildingName;
				else rtBuildingName = selectedloc.PAF_Sub_Building_Name__c;//+','+rtBuildingName;
			}
			if (selectedloc.PAF_Building_Number__c!=null) rtBuildingNumber = selectedloc.PAF_Building_Number__c;
			if (selectedloc.PAF_Thoroughfare_Name__c!=null) rtStreet = selectedloc.PAF_Thoroughfare_Name__c;
			if (selectedloc.PAF_Thoroughfare_Descriptor__c!=null) rtStreet += selectedloc.PAF_Thoroughfare_Descriptor__c;
			if (selectedloc.PAF_Post_Town__c!=null) rtCity = selectedloc.PAF_Post_Town__c;
			if (selectedloc.PAF_County__c!=null) rtCounty = selectedloc.PAF_County__c;
			if (selectedloc.PAF_Postcode__c!=null) rtPostcode = selectedloc.PAF_Postcode__c;
			if (selectedloc.Country__c!=null) rtCountry = selectedloc.Country__c;			
		}
		else if (strType==null || strType=='') {
			throw new O2OnlineException('Could not determine address type to select. Please use the contact form to notify us of this fault.');
		}
	}
	
	//##### END PAF ADDRESS HANDLING/CACHING CODE #####
        
    //#############################################
    //### END SW CREATED CODE #####################
    //#############################################
    
    public PageReference goToContactUs() {
    	return new PageReference(CONTACT_US);
    }
    
    private String lineCheckResult(String reasonCode) {
    	String dnError = '2175,2178,2251';
    	String dnpcError = '2408';
    	String pcError = '2158';
    	
    	String action;
    	if (dnError.contains(reasonCode)) action = DN_ERROR;
    	else if (dnpcError.contains(reasonCode)) action = DN_PC_ERROR;
    	else if (pcError.contains(reasonCode)) action = PC_ERROR;
    	else action = DN_PC_SUCCESS;
    	
    	System.debug('@@@RAC linecheckresult action = '+action + ' reasonCode = ' + reasonCode);

    	return action;
    }
    
    //@deprecated- not in use(can be deleted)
    // Get 
    // NB: This will move into an extension controller
    public Map<String, List<O2_DISE_Map_Minutes__c>> additionalMinutes() {
    	Map<String, List<O2_DISE_Map_Minutes__c>> minMap = new Map<String, List<O2_DISE_Map_Minutes__c>>();
    	
    	String tariff = 'Q11ZAX';
    	// Retrieve each addtl minutes type with their non-FOC values for the current
    	// product tariff
    	minMap.put('UK Landlines', [SELECT Id, Tariff_Code__c, Service_Price__c, 
    									 Service_Bill_Label__c, Minutes_Type__c, 
    									 Minutes_Number__c 
    							  From O2_DISE_Map_Minutes__c
    							  WHERE Minutes_Type__c = 'Calls to UK Landlines'
    							  AND   Tariff_Code__c = :tariff
    							  AND  Service_Price__c > 0.0]);
    	minMap.put('O2 Mobiles', [SELECT Id, Tariff_Code__c, Service_Price__c, 
    									 Service_Bill_Label__c, Minutes_Type__c, 
    									 Minutes_Number__c 
    							  From O2_DISE_Map_Minutes__c
    							  WHERE Minutes_Type__c = 'Calls to O2 Mobiles'
    							  AND   Tariff_Code__c = :tariff
    							  AND  Service_Price__c > 0.0]);
    	minMap.put('UK Landlines & Mobiles', [SELECT Id, Tariff_Code__c, Service_Price__c, 
    									 Service_Bill_Label__c, Minutes_Type__c, 
    									 Minutes_Number__c 
    							  From O2_DISE_Map_Minutes__c
    							  WHERE Minutes_Type__c = 'Calls to UK Landlines and Mobiles'
    							  AND   Tariff_Code__c = :tariff
    							  AND  Service_Price__c > 0.0]);
    	
    	return minMap;
    }
    

    
    //LINE AVAILABILITY CHECKER METHODS AND CODE
    
    public PageReference checkLineResults() {
    	cscfgc.ProductConfiguration currConfig = apiSession.getConfiguration(); 
    	Batch_Job__c batchJob;
    	batchjob = AvailabilityCheckInputProcessor.processLineAvailablityImmediate(
    									gettransferNumber(), 
    									gettransferPostcode(),
    									'Line');
    	if (batchJob != null) {
	    	Line_Availability__c result = [SELECT id FROM Line_Availability__c WHERE batch_job__c = :batchJob.Id LIMIT 1];  
	    	O2OrderHelper.populateConfiguration(O2OrderHelper.PROD_LANDLINE, 
	    										currConfig, 
	    										result.id);
    	}
    	
    	return null;	
    }
    
    //MOBILE NUMBER CHECKER METHODS AND CODE
    public Boolean isO2BusinessMobile(String mpn) {
    	SOASubscriber soaSubCheck = new SOASubscriber();
    	//soaSubCheck.setSubscriberID(mpn);
    	
    	// Until Web Service results hooked up
    	return true;	
    } 
    
    //MINUTE BOLTONS METHODS
    public String minutesDestinationTypes = 'Calls to UK Landlines';
    public String getMinutesDestinationTypes(){return minutesDestinationTypes; }
    public void setMinutesDestinationTypes(String minTypes){
    	minutesDestinationTypes = minTypes;
    }
    
    public String minutesNumber = '0';
    public String getMinutesNumber(){ return minutesNumber;}
    public void setMinutesNumber(String minNum){     	
    	 minutesNumber = minNum;
    }
*/
    static testMethod void test_dummy() {
    	O2OnlineOrderController con = new O2OnlineOrderController();
    }    
}