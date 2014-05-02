///
///	Name:	o2_salesO2CoUk_soapserver
///
///	Author:
///	Michael Kahle
///	H&W Consult GmbH
///	Bäckerstr. 18
///	21244 Buchholz i.d.N.
///	http://www.hundw.com
///
///	Description:
///	
///
///	Used Objects: (Objects, StaticResources, Documents)
///	Account, Contact
///
///	Used Classes: (Classes,Trigger,Pages)
///	o2_salesO2CoUk_soapserver, o2_salesO2CoUk_soapserver.Contact, OARUserListItem, O2_linkage_utils, OARResponse
///
///	Timeline:
///	Name				DateTime					Description
///	? (Rufus Leonard)	?							Creation of Class
///	Mirco Stein			?							Start of modifying class for new Webservice
///	Michael Kahle		2010-02-01 11:20 (GMT+1)	End of modifying class for new Webservice and cleaned of two Webservice classes
///
public class salesO2CoUkChoice
{
	
	
// *******************    New Webservice integration ************************************
		
		public static o2_salesO2CoUk_soapserver.AccountSoap		x_service			=	new o2_salesO2CoUk_soapserver.AccountSoap();
		public static o2_salesO2CoUk_soapserver.ArrayOfContact	x_arrayOfContact	=	new o2_salesO2CoUk_soapserver.ArrayOfContact();
		public static List<o2_salesO2CoUk_soapserver.Contact>	x_ContactObjectList	=	new List<o2_salesO2CoUk_soapserver.Contact>();
		public static Integer x_maxContactsPerCall									=	250;
		
		
		
// *******************    New Webservice integration end ************************************	
	
	
	// Parse the user list response from OAR
	private static List<OARUserListItem> parseUserListResponse(String pResponse) {
		XmlStreamReader xsr = new XmlStreamReader(pResponse);
		List<OARUserListItem> userList = new List<OARUserListItem>();
		while (xsr.hasNext()) {
			if (xsr.getEventType() == XmlTag.START_ELEMENT) {
				if ('Table' == xsr.getLocalName()) {
					OARUserListItem userListItem = parseListItem(xsr);
					userList.add(userListItem);
				} // end check for start tag
			} // end start element check if
			
			// Get in the next part of the stream
        	xsr.next();			
		} // end loop through the xml
		return userList;
	} // end parseUserListResponse


	
	private static OARUserListItem parseListItem(XmlStreamReader pXsr) {
		OARUserListItem userListItem = new OARUserListItem();
		while (pXsr.hasNext()) {
			if (pXsr.getEventType() == XmlTag.START_ELEMENT) {
				if ('idUser' == pXsr.getLocalName()) {
					userListItem.userId = O2_linkage_utils.parseStringItem(pXsr);
				} 
				else {
					if ('FirstName' == pXsr.getLocalName()) {
						userListItem.firstName = O2_linkage_utils.parseStringItem(pXsr);
					}
					else {
						if ('LastName' == pXsr.getLocalName()) {
							userListItem.lastName = O2_linkage_utils.parseStringItem(pXsr);
						}
						else {
							if ('Email' == pXsr.getLocalName()) {
								userListItem.email = O2_linkage_utils.parseStringItem(pXsr);
							}
							else {
								if ('Telephone' == pXsr.getLocalName()) {
									userListItem.telephone = O2_linkage_utils.parseStringItem(pXsr);
								}
							}
						}
					}	
				}
			} // end check for start element if
			else {
				if (pXsr.getEventType() == XmlTag.END_ELEMENT) {
					break;
				}
			}				
			
			// Get in the next part of the stream
        	pXsr.next();			
		} // end loop through the xml
		return userListItem;
	} // end parseListItem
		
	
	// This routine will call the web service to update an OAR account (i.e. specific to our
	// DISE account number/group code
	
/*	******************************************************	METHOD:	UPDATE OAR ACCOUNT **************************************************************	*/	
	
	private static OARResponse updateOARAccount(o2_salesO2CoUk_soapserver.AccountSoap pAccountStub,Account pUpdatedAccount, String pOAR_Account_Reference,String pDISE_Account_Group_Code,Boolean pGroupCode) 
	{
        System.debug('O2_linkage_configuration.TESTING 4: ' + O2_linkage_configuration.TESTING);
		// Set either the account number or group code to the combined input field depending on the 
		// group/account flag
		String DISE_Group_Code = '';
		String DISE_Account_No = '';
		
		if (pGroupCode) 
		{
			DISE_Group_Code = pDISE_Account_Group_Code;
		}
		else 
		{
			DISE_Account_No = pDISE_Account_Group_Code;
		}
		
		// Prevent any null pointer exceptions by checking first !
		// Note that allowed an auto conversion from intvalue to the string gets rid of the decimal point
		// and gets rid of commas that the format call would put in
		String minimumTerm		=	pUpdatedAccount.MinimumTerm__c		== null ? '0' : '' + pUpdatedAccount.MinimumTerm__c.intValue();
		String minimumHolding	=	pUpdatedAccount.Minimum_Holding__c	== null ? '0' : pUpdatedAccount.Minimum_Holding__c.intValue() + '';
		String noEmployees		=	pUpdatedAccount.NumberOfEmployees	== null ? '0' : pUpdatedAccount.NumberOfEmployees + '';

		String contractStartDateString;
		if (pUpdatedAccount.Contract_Start_Date__c != null) 
		{
			contractStartDateString = pUpdatedAccount.Contract_Start_Date__c.day() + O2_linkage_utils.convertToTextMonth(pUpdatedAccount.Contract_Start_Date__c.month()) + pUpdatedAccount.Contract_Start_Date__c.year();
		}
		
		String contractEndDateString;
		if (pUpdatedAccount.Contract_End_Date__c != null) 
		{
			contractEndDateString = pUpdatedAccount.Contract_End_Date__c.day() + O2_linkage_utils.convertToTextMonth(pUpdatedAccount.Contract_End_Date__c.month()) + pUpdatedAccount.Contract_End_Date__c.year();
		}
		
		String effectiveFromDateString;
		if (pUpdatedAccount.Date_Effective_From__c != null) 
		{
			effectiveFromDateString = pUpdatedAccount.Date_Effective_From__c.day() + O2_linkage_utils.convertToTextMonth(pUpdatedAccount.Date_Effective_From__c.month()) + pUpdatedAccount.Date_Effective_From__c.year();
		}
		
        String responseMessage;
        System.debug('Getting this far ' + O2_Linkage_Configuration.TESTING);
        if (O2_linkage_configuration.TESTING) 
        {
            System.debug('Not expecting this');
        	responseMessage = '<Response><Status Value="1" /><Description Value="0" /></Response>';
        } // end TESTING if
        else 
        {
        	System.debug('Expecting this');
        	responseMessage = pAccountStub.updateAccount(	pUpdatedAccount.Id,
															pUpdatedAccount.Tree_Organisation_ID__c, // treeAccountIdentifier,
															pUpdatedAccount.Name, // customerName,
															pUpdatedAccount.Company_Reg_No__c,// companyRegistrationNumber
															pUpdatedAccount.BURN__c,// businessUniqueReferenceNumber,
															pUpdatedAccount.PH_Site_ID__c,// experianNumber
															contractStartDateString,
															contractEndDateString,
															pUpdatedAccount.Contract_Duration__c, // duration ??
															minimumTerm,
															minimumHolding,
															pUpdatedAccount.BillingStreet,
															pUpdatedAccount.BillingCity,																
															pUpdatedAccount.BillingState,
															pUpdatedAccount.BillingCountry,
															' ', // address 5
															' ', // address 6
															pUpdatedAccount.BillingPostalCode,
															DISE_Group_Code,
															DISE_Account_No,
															pUpdatedAccount.Business_Text_Code__c,
															pUpdatedAccount.Desktop_Text_code__c,
															pUpdatedAccount.Managed_Text_Code__c,
															pUpdatedAccount.Mobile_Marketer_Code__c,
															effectiveFromDateString, //dateEffectiveFrom
															noEmployees,
															pUpdatedAccount.O2_Sector__c,
															UserInfo.getUserName());																													
        } // end TESTING else
		return O2_linkage_utils.parseResponse(responseMessage);
	} // end updateOARAccount_Live
			
	// This routine will call the web service to register an OAR account (i.e. specific to our
	// DISE account number/group code

/*	******************************************************	METHOD:	REGISTER OAR ACCOUNT **************************************************************	*/	

	private static OARResponse registerOARAccount(o2_salesO2CoUk_soapserver.AccountSoap pAccountStub,Account pRelatedAccount, String pOAR_Account_Reference,String pDISE_Account_Group_Code,Boolean pGroupCode) {

		System.debug('Entered registerOARAccount with stub = ' + pAccountStub);
		
		// Set either the account number or group code to the combined input field depending on the 
		// group/account flag
		String DISE_Group_Code = '';
		String DISE_Account_No = '';
		if (pGroupCode) 
		{
			DISE_Group_Code = pDISE_Account_Group_Code;
		}
		else
		{
			DISE_Account_No = pDISE_Account_Group_Code;
		}
		
		System.debug('Set DISE codes');
		
		// Prevent any null pointer exceptions by checking first !
		String minimumTerm		=	pRelatedAccount.MinimumTerm__c		== null ? '0' : '' + pRelatedAccount.MinimumTerm__c.intValue();
		String minimumHolding	=	pRelatedAccount.Minimum_Holding__c	== null ? '0' : pRelatedAccount.Minimum_Holding__c.intValue() + '';
		String noEmployees		=	pRelatedAccount.NumberOfEmployees	== null ? '0' : pRelatedAccount.NumberOfEmployees + '';

		System.debug('Set term values');
				
		// Get the contract start date in an understandable string format
		String contractStartDateString;
		if (pRelatedAccount.Contract_Start_Date__c != null) 
		{
			contractStartDateString = pRelatedAccount.Contract_Start_Date__c.day() + O2_linkage_utils.convertToTextMonth(pRelatedAccount.Contract_Start_Date__c.month()) + pRelatedAccount.Contract_Start_Date__c.year();
		}

		// Get the effective from date in an understandable string format
		String effectiveFromDateString;
		if (pRelatedAccount.Date_Effective_From__c != null) 
		{
			effectiveFromDateString = pRelatedAccount.Date_Effective_From__c.day() + O2_linkage_utils.convertToTextMonth(pRelatedAccount.Date_Effective_From__c.month()) + pRelatedAccount.Date_Effective_From__c.year();
		}

		System.debug('Calling register');
		
        String responseMessage;
        if (O2_linkage_configuration.TESTING) 
		{
        	responseMessage = '<Response><Status Value="1" /><Description Value="44037" /></Response>';
        } // end TESTING if
        else {		

 			responseMessage = pAccountStub.RegisterAccount(	pRelatedAccount.Id,
															pRelatedAccount.Tree_Organisation_ID__c, // treeAccountIdentifier,
															pRelatedAccount.Name, // customerName,
															pRelatedAccount.Company_Reg_No__c,// companyRegistrationNumber
															pRelatedAccount.BURN__c,// businessUniqueReferenceNumber,
															pRelatedAccount.PH_Site_ID__c,// experianNumber
															contractStartDateString,// contractStartDate??
															pRelatedAccount.Contract_Duration__c, // duration ??
															minimumTerm,
															minimumHolding,
															pRelatedAccount.BillingStreet,
															pRelatedAccount.BillingCity,																
															pRelatedAccount.BillingState,
															pRelatedAccount.BillingCountry,
															' ', // address 5
															' ', // address 6
															pRelatedAccount.BillingPostalCode,
															DISE_Group_Code,
															DISE_Account_No,
															pRelatedAccount.Business_Text_Code__c,
															pRelatedAccount.Desktop_Text_code__c,
															pRelatedAccount.Managed_Text_Code__c,
															pRelatedAccount.Mobile_Marketer_Code__c,
															effectiveFromDateString, //dateEffectiveFrom
															noEmployees,
															pRelatedAccount.O2_Sector__c,
															UserInfo.getUserName());
        } // end TESTING else
		System.debug('response from register account = ' + responseMessage);																																
		return O2_linkage_utils.parseResponse(responseMessage);
	} // end registerIndividualAccount
	
	
	// This is the routine to register the account in OAR.  The received parameter
	// is the related opportunity ID or the account (the routing can be called from either the opp)
	// or the account page
	
	//	Rewritten by H&W Consult GmbH 2010-02-01
	
/*	******************************************************	METHOD:	REGISTER ACCOUNT **************************************************************	*/		
	
	
	
	public static String registerAccount(Id pOpportunityId, Id pAccountId) 
	{
		
		x_maxContactsPerCall = webservice_settings__c.getinstance('Default').max_callouts__c.intValue();
		
		System.debug('Class : salesO2CoUkChoice');
		System.debug('Method : registerAccount');
		System.debug('Parameter - Id pOpportunityId : ' + pOpportunityId);
		System.debug('Parameter - Id pAccountId		: ' + pAccountId);
		System.debug('----------------------------------------------');
		
		// Display status - string used to display status to the user
		String displayStatus = '';
		
		Id accId;
		if (pOpportunityId != null) 
		{
			// Select back opportunity fields required for registration
			Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :pOpportunityId];
			accId = opp.AccountId;
		}
		else 
		{
			accId = pAccountId;
		}
									
		// Select back the account fields required for registration
		
		System.debug('registerAccount - Select Account');
		Account relatedAccount = [Select 	Id, 
											OwnerId,
											Name, 
											Company_Reg_No__c,
											BURN__c,
											MinimumTerm__c,
											Minimum_Holding__c,
											Tree_Organisation_ID__c,
											Contract_End_Date__c,
											BillingStreet,
											BillingState,
											BillingCity,
											BillingCountry,
											BillingPostalCode,
											DISE_Group_Code_Account_No_4__c, 
											DISE_Group_Code_Account_No_3__c,
											DISE_Group_Code_Account_No_2__c,
											DISE_Group_Code_Account_No_1__c,
											DISE_4_GROUP__c, 
											DISE_3_GROUP__c,
											DISE_2_GROUP__c,
											DISE_1_GROUP__c,
											NumberOfEmployees,
											O2_Sector__c,
											Business_Text_Code__c,
											PH_Site_ID__c,
											Desktop_Text_code__c,
											Managed_Text_Code__c,
											Mobile_Marketer_Code__c,
											OAR_Account_Reference_1__c,
											OAR_Account_Reference_2__c,
											OAR_Account_Reference_3__c,
											OAR_Account_Reference_4__c,
											Contract_Start_Date__c,
											Contract_Duration__c,
											Date_Effective_From__c										
											From Account Where Id = :accId];
		
		System.debug('registerAccount - Selecting Contacts');
		
	 	List<Contact> contacts = [Select 	Id,
											Salutation,
											FirstName,
											LastName,
											Title,
											Buying_Role__c,
											Phone,
											Email,
											MailingStreet,
											MailingState,
											MailingCity,
											MailingCountry,
											MailingPostalCode,
											OAR_Registered_Date__c,
											CSIOptOut__c,
											CSIOptOutReason__c,
											CSIFurtherInformation__c,
											CLCeNews__c,
											CLCWhitePapers__c,
											CLCResearchForums__c,
											CLCProductWorkshop__c,
											CLCMicrosite__c, 
											CLCMagazine__c,
											CLCEvents__c,
											CLCEndUser__c,
											CLCDirectMail__c,
											OwnerId											
											From Contact Where AccountId = :accId
											Order By CreatedDate];

		// Get the OAR authentication header, created the account stub and add the header to it
		x_service.OARAuthenticationHeader  			=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
		x_service.OARAuthenticationHeader.Username	=	O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
		x_service.OARAuthenticationHeader.Password	=	O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');	 
		
		
		//salesO2CoUk.AccountSoap accountStub	= x_service;

		


		String responseMessage; // XML response from OAR
		String OARAccountRef;	// OAR Account Reference variable
		Account updateAccount			=	new Account(Id = relatedAccount.Id);
		Boolean accountUpdated			=	false;
		List<Contact> updateContacts	=	new List<Contact>();	// Contacts for update
		
		// If the first billing code already has an OAR reference, then do not attempt to re-register it
		if ((relatedAccount.OAR_Account_Reference_1__c == null) && (relatedAccount.DISE_Group_Code_Account_No_1__c != null)) {
				
			// Attempt to register the account
			try {			
		        OARResponse responseObject;

				System.debug('About to call register against first billing code');
				responseObject = registerOARAccount(x_service,relatedAccount,relatedAccount.OAR_Account_Reference_1__c ,relatedAccount.DISE_Group_Code_Account_No_1__c,relatedAccount.DISE_1_GROUP__c);
				
				// Check if the return status is a success
				if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
					
					// No point continuing if the account failed to register
					displayStatus += Label.OAR_ACC_REG_ERR_PREFIX + relatedAccount.DISE_Group_Code_Account_No_1__c + '": ' + responseObject.description + ' ';
					system.debug('#saleso2coukChoice + registerOAR + success? = NO!');
					relatedAccount.Register_Requested__c = false;

				}
				else {
					
					// Add the account success message to the response
					displayStatus += relatedAccount.DISE_Group_Code_Account_No_1__c + ' ' + Label.ACC_REG_SUCCESS + responseObject.description +'\n';
					OARAccountRef = responseObject.description;
					
					// Account for update
					updateAccount.OAR_Account_Reference_1__c = OARAccountRef;
					accountUpdated = true;
					system.debug('#saleso2coukChoice + registerOAR + success? = YES');
				}
			} // end try block
			catch (Exception e) {
				displayStatus +=  Label.ACC_REG + e.getMessage() + '\n';
			}
		} // end check for existing OAR reference else 
		
		// If the second billing code already has an OAR reference, then do not attempt to re-register it, instead
		// add a message indicating this
		if ((relatedAccount.OAR_Account_Reference_2__c == null) && (relatedAccount.DISE_Group_Code_Account_No_2__c != null)) {	
						
			// Attempt to register the account
			try {			
		        OARResponse responseObject;
				responseObject = registerOARAccount(x_service, relatedAccount, relatedAccount.OAR_Account_Reference_2__c , relatedAccount.DISE_Group_Code_Account_No_2__c, relatedAccount.DISE_2_GROUP__c);
				// Check if the return status is a success
				if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
					
					// No point continuing if the account failed to register
					displayStatus += Label.OAR_ACC_REG_ERR_PREFIX + relatedAccount.DISE_Group_Code_Account_No_2__c + '": ' + responseObject.description + ' ';
				}
				else {
					
					// Add the account success message to the response
					displayStatus += relatedAccount.DISE_Group_Code_Account_No_2__c + ' ' + Label.ACC_REG_SUCCESS + responseObject.description +'\n';
					OARAccountRef = responseObject.description;
					
					// Account for update
					updateAccount.OAR_Account_Reference_2__c = OARAccountRef;
					accountUpdated = true;
				}
			} // end try block
			catch (Exception e) {
				displayStatus +=  Label.ACC_REG + e.getMessage() + '\n';
			}
		} // end check for existing OAR reference else 
		
		// If the third billing code already has an OAR reference, then do not attempt to re-register it
		if ((relatedAccount.OAR_Account_Reference_3__c == null) && (relatedAccount.DISE_Group_Code_Account_No_3__c != null)) {
			
			// Attempt to register the account
			try {			
		        OARResponse responseObject;
		        
				responseObject = registerOARAccount(x_service,relatedAccount,relatedAccount.OAR_Account_Reference_3__c ,relatedAccount.DISE_Group_Code_Account_No_3__c,relatedAccount.DISE_3_GROUP__c);

				// Check if the return status is a success
				if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
					
					// No point continuing if the account failed to register
					displayStatus += Label.OAR_ACC_REG_ERR_PREFIX + relatedAccount.DISE_Group_Code_Account_No_3__c + '": ' + responseObject.description + ' ';
				}
				else {
					
					// Add the account success message to the response
					displayStatus += relatedAccount.DISE_Group_Code_Account_No_3__c + ' ' + Label.ACC_REG_SUCCESS + responseObject.description +'\n';
					OARAccountRef = responseObject.description;
					
					// Account for update
					updateAccount.OAR_Account_Reference_3__c = OARAccountRef;
					accountUpdated = true;
					
				}
			} // end try block
			catch (Exception e) {
				displayStatus +=  Label.ACC_REG + e.getMessage() + '\n';
			}
		} // end check for existing OAR reference else 		
		
		// If the forth billing code already has an OAR reference, then do not attempt to re-register it, instead
		// add a message indicating this
		if ((relatedAccount.OAR_Account_Reference_4__c == null) && (relatedAccount.DISE_Group_Code_Account_No_4__c != null)) {
			
			// Attempt to register the account
			try {			
		        OARResponse responseObject;
		        
				responseObject = registerOARAccount(x_service,relatedAccount, relatedAccount.OAR_Account_Reference_4__c ,relatedAccount.DISE_Group_Code_Account_No_4__c,relatedAccount.DISE_4_GROUP__c);

				// Check if the return status is a success
				if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
					
					// No point continuing if the account failed to register
					displayStatus += Label.OAR_ACC_REG_ERR_PREFIX + relatedAccount.DISE_Group_Code_Account_No_4__c + '": ' + responseObject.description + ' ';
				}
				else {
					
					// Add the account success message to the response
					displayStatus += relatedAccount.DISE_Group_Code_Account_No_4__c + ' ' + Label.ACC_REG_SUCCESS + responseObject.description +'\n';
					OARAccountRef = responseObject.description;
					
					// Account for update
					updateAccount.OAR_Account_Reference_4__c = OARAccountRef;
					accountUpdated = true;
					
				}
			} // end try block
			catch (Exception e) {
				displayStatus +=  Label.ACC_REG + e.getMessage() + '\n';
			}
		} // end check for existing OAR reference else 		
		
		System.debug('After all 4 accounts, message = ' + displayStatus);
		
		
		
		try
		{		
			// Now we process the contacts associated with these accounts
	
	
	
	
			o2_salesO2CoUk_soapserver.contact ContactObject;
			
			for (Contact con : contacts)
			{
				ContactObject =	new o2_salesO2CoUk_soapserver.contact();
				
				// Do not attempt to register if the contact already has an OAR registered date
				if (con.OAR_Registered_Date__c != null) 
				{
					displayStatus += Label.CON_REG_ALREADY + con.OAR_Registered_Date__c + '\n';
				}
				else 
				{
					if (con.FirstName == null) 
					{
						displayStatus +=  Label.CON_FIRSTNAME_NULL + '\n';
					}				
					else 
					{
						if (con.Title == null) 
						{
							displayStatus +=  Label.CON_TITLE_NULL + '\n';
						}
						else 
						{
							if (con.OwnerId != relatedAccount.OwnerId) 
							{
								displayStatus += Label.CON_OWNER_NO_MATCH + '\n';
							}		
							else 
							{
								String salutation = (con.Salutation != null ? con.Salutation.replace('.','') : '');	
								
								System.Debug('salesO2CoUKChoice - registerAccount - Adding new Contact to Queue');
								
								ContactObject.SalesForceAccountIdentifier	=	relatedAccount.Id;
								ContactObject.SalesForceContactIdentifier	=	con.Id;
								ContactObject.Title							=	salutation;
								ContactObject.FirstName						=	con.FirstName;
								ContactObject.LastName						= 	con.LastName;
								ContactObject.Role							= 	con.Title;
								ContactObject.Telephone						= 	con.Phone;
								ContactObject.IsCOP							= 	con.Buying_Role__c == 'COP' ? 'true' : 'false';
								ContactObject.IsCOD							= 	con.Buying_Role__c == 'COD' ? 'true' : 'false';
								ContactObject.IsCOR							= 	con.Buying_Role__c == 'COR' ? 'true' : 'false';
								ContactObject.Email							= 	con.Email;
								ContactObject.Address1						= 	con.MailingStreet;
								ContactObject.Address2						= 	con.MailingCity;
								ContactObject.Address3						= 	con.MailingState;
								ContactObject.Address4						= 	con.MailingCountry;
								ContactObject.Address5						= 	' '; // address 5
								ContactObject.Address6						= 	' '; // address 6
								ContactObject.Postcode						= 	con.MailingPostalCode;
								ContactObject.CLCMagazine					= 	con.CLCMagazine__c ? 'true' : 'false';// CLCMagazine
								ContactObject.CLCMicrosite					= 	con.CLCMicrosite__c ? 'true' : 'false';// CLCMicrosite
								ContactObject.CLCeNews						= 	con.CLCeNews__c ? 'true' : 'false';// CLCeNews
								ContactObject.CLCDirectMail					= 	con.CLCDirectMail__c ? 'true' : 'false';// CLCDirectMail
								ContactObject.CLCEvents						= 	con.CLCEvents__c ? 'true' : 'false';// CLCEvents
								ContactObject.CLCWhitePapers				= 	con.CLCWhitePapers__c ? 'true' : 'false';// CLCWhitePapers
								ContactObject.CLCProductWorkshop			= 	con.CLCProductWorkshop__c ? 'true' : 'false';// CLCProductWorkshop
								ContactObject.CLCResearchForums				= 	con.CLCResearchForums__c ? 'true' : 'false';// CLCResearchForums
								ContactObject.CLCEndUser					= 	con.CLCEndUser__c ? 'true' : 'false';// CLCEndUser
								ContactObject.CSIOptOut						= 	con.CSIOptOut__c ? 'true' : 'false';// CSIOptOut
								ContactObject.CSIOptOutReason				= 	con.CSIOptOutReason__c;// CSIOptOutReason
								ContactObject.CSIFurtherInformation			= 	con.CSIFurtherInformation__c;//  CSIFurtherInformation
								
								x_ContactObjectList.add(ContactObject);
							}
						}
					}
				}
			}
			
			
			o2_salesO2CoUk_soapserver.ArrayOfContact tmp_contactCallList	=	new o2_salesO2CoUk_soapserver.ArrayOfContact();
			tmp_contactCallList.Contact										=	new List<o2_salesO2CoUk_soapserver.Contact>();
			Integer tmp_currentContactCount									=	0;
			Integer tmp_currentResponseCount								=	0;
			o2_salesO2CoUk_soapserver.ArrayOfString tmp_response;
			
			
			for(o2_salesO2CoUk_soapserver.contact tmp_contact : x_ContactObjectList)
			{
				tmp_contactCallList.contact.add(tmp_contact);
				tmp_currentContactCount++;
				if(tmp_currentContactCount == x_maxContactsPerCall)
				{
					tmp_currentContactCount	=	0;
					
					try 
					{
						// Making the call to register contacts
						tmp_response = x_service.CreateContacts(tmp_contactCallList);
						system.debug('### RESPONSE TEST : ' + tmp_response);
						for(Integer i = 0; i < tmp_response.string_x.size(); i++)
						{
							
							String tmp_responseString 			=	tmp_response.string_x.get(i);
							o2_salesO2CoUk_soapserver.Contact tmp_con = x_ContactObjectList.get(i + tmp_currentResponseCount);
							//	tmp_currentResponseCount++;   	DELETED FOR TESTING	
							// Get the response and check for a success												
							OARResponse responseObject	= 	O2_linkage_utils.parseResponse(tmp_responseString);
											
							// Add a success or failure message to the display message
							displayStatus += tmp_con.FirstName + ' ' + tmp_con.LastName + ':';
							
							if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) 
							{
								 displayStatus += Label.CON_REG + ' ' + responseObject.description;							 
							}
							else 
							{
								displayStatus += Label.CON_REG_SUCCESS;
								
								// Add a contact object for update with the OAR reference
								updateContacts.add(new Contact(Id = tmp_con.SalesForceContactIdentifier,OAR_Registered_Date__c = Datetime.now()));
							}
							displayStatus += ' ' + responseObject.description + '\n';
						}
					}
					catch (Exception e) 
					{
						for(o2_salesO2CoUk_soapserver.contact tmp_con : tmp_contactCallList.contact)
						{
							displayStatus += tmp_con.FirstName + ' ' + tmp_con.LastName + ':' + Label.CON_REG + e.getMessage() + '\n';
						}
					}
					tmp_currentResponseCount	+=	tmp_response.string_x.size();  // ADDED FOR TESTING
					tmp_contactCallList				=	new o2_salesO2CoUk_soapserver.ArrayOfContact();
					tmp_contactCallList.Contact		=	new List<o2_salesO2CoUk_soapserver.Contact>();
				}
				
			}
			
			
			//	Check the rest
			if(tmp_currentContactCount > 0)
			{
				try 
				{
					tmp_response = x_service.CreateContacts(tmp_contactCallList);
					
					for(Integer i = 0; i < tmp_response.string_x.size(); i++)
					{
						String tmp_responseString 			=	tmp_response.string_x.get(i);
						o2_salesO2CoUk_soapserver.Contact tmp_con = x_ContactObjectList.get(i + tmp_currentResponseCount);
						//	tmp_currentResponseCount++;   	DELETED FOR TESTING	
						// Get the response and check for a success												
						OARResponse responseObject	= 	O2_linkage_utils.parseResponse(tmp_responseString);
										
						// Add a success or failure message to the display message
						displayStatus += tmp_con.FirstName + ' ' + tmp_con.LastName + ':';
						
						if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) 
						{
							displayStatus += Label.CON_REG + ' ' + responseObject.description;							 
						}
						else 
						{
							displayStatus += Label.CON_REG_SUCCESS;
							
							// Add a contact object for update with the OAR reference
							updateContacts.add(new Contact(Id = tmp_con.SalesForceContactIdentifier,OAR_Registered_Date__c = Datetime.now()));
						}
						displayStatus += ' ' + responseObject.description + '\n';
					}
				}
				catch (Exception e) 
				{
					for(o2_salesO2CoUk_soapserver.contact tmp_con : tmp_contactCallList.contact)
					{
						displayStatus += tmp_con.FirstName + ' ' + tmp_con.LastName + ':' + Label.CON_REG + e.getMessage() + '\n';
					}
				}
			}
		}
		finally
		{
			if (accountUpdated)
			{
				update updateAccount;
				displaystatus = 'Account was updated! ' + displaystatus;
			}
			else
			{
				displaystatus = 'Account was NOT updated! ' + displaystatus;	
			}
			
			System.debug('Updating accounts');
			// Update the accounts with the OAR id if necessary
			System.debug('Account object for possible update = ' + updateAccount);
	
			
			// Update any contacts with OAR references
			if (!updateContacts.isEmpty()) 
			{
				update updateContacts;
			}
			System.debug('Leaving O2CoUkChoice register Account');			
		}

		return displayStatus;
	} // end registerAccount
	
		
	// This is the routine to update the account in OAR.  The received parameter
	// is the related opportunity ID


/*	******************************************************	METHOD:	UPDATE ACCOUNT **************************************************************	*/		

	public static String updateAccount(Id pAccountId) { 
		System.debug('This is the account id ' + pAccountId);
		System.debug('O2_linkage_configuration.TESTING 1: ' + O2_linkage_configuration.TESTING);
		// Display status - string used to display status to the user
		String displayStatus = '';
									
		// Select back the account fields required for registration
		Account updatedAccount = [Select 	Id, 
											Name, 
											Company_Reg_No__c,
											BURN__c,
											MinimumTerm__c,
											Minimum_Holding__c,
											Tree_Organisation_ID__c,
											Contract_End_Date__c,
											BillingStreet,
											BillingState,
											BillingCity,
											BillingCountry,
											BillingPostalCode,
											DISE_Group_Code_Account_No_4__c, 
											DISE_Group_Code_Account_No_3__c,
											DISE_Group_Code_Account_No_2__c,
											DISE_Group_Code_Account_No_1__c,
											DISE_4_GROUP__c, 
											DISE_3_GROUP__c,
											DISE_2_GROUP__c,
											DISE_1_GROUP__c,
											NumberOfEmployees,
											O2_Sector__c,
											Business_Text_Code__c,
											PH_Site_ID__c,
											Desktop_Text_code__c,
											Managed_Text_Code__c,
											Mobile_Marketer_Code__c,
											OAR_Account_Reference_1__c,
											OAR_Account_Reference_2__c,
											OAR_Account_Reference_3__c,
											OAR_Account_Reference_4__c,
											OAR_Account_1_Handover_Status__c,
											OAR_Account_2_Handover_Status__c,
											OAR_Account_3_Handover_Status__c,
											OAR_Account_4_Handover_Status__c,
											Contract_Duration__c,
											Contract_Start_Date__c,
											Date_Effective_From__c					
											From Account Where Id = :pAccountId];
		System.debug('updatedAccount ' + updatedAccount);
		System.debug('O2_linkage_configuration.TESTING 2: ' + O2_linkage_configuration.TESTING);
		// Get the OAR authentication header, create the account stub and add the header
		
		// Get the OAR authentication header, created the account stub and add the header to it
		x_service.OARAuthenticationHeader  			=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
		x_service.OARAuthenticationHeader.Username	=	O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
		x_service.OARAuthenticationHeader.Password	=	O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');	

		String responseMessage; // XML response from OAR
		String OARAccountRef;	// OAR Account Reference variable
		
		// If this is a SFDC account that has not been handed over but has been registered in OAR, then
		// update it in OAR
		if ((updatedAccount.OAR_Account_Reference_1__c != null) && (updatedAccount.OAR_Account_1_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) {

			// Attempt to update the account
			try {			
				System.debug('O2_linkage_configuration.TESTING 3: ' + O2_linkage_configuration.TESTING);
		        OARResponse responseObject;
	        	responseObject = updateOARAccount(	x_service,
													updatedAccount, 
													updatedAccount.OAR_Account_Reference_1__c ,
													updatedAccount.DISE_Group_Code_Account_No_1__c,
													updatedAccount.DISE_1_GROUP__c);

                System.debug('O2_linkage_configuration.TESTING 5: ' + O2_linkage_configuration.TESTING);
				// Check if the return status is a success
				if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
					
					// No point continuing if the account failed to register
					displayStatus += responseObject.description;
				}
				else {
					
					// Add the account success message to the response
					displayStatus += Label.ACC_UPD_SUCCESS + ' ' + updatedAccount.OAR_Account_Reference_1__c + '\n';
				}
			} // end try block
			catch (Exception e) {
				displayStatus +=  Label.ACC_UPD + e.getMessage() + '\n';
			}
		} // end check for existing OAR reference if
		
		if ((updatedAccount.OAR_Account_Reference_2__c != null) && (updatedAccount.OAR_Account_2_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) {

			// Attempt to update the account
			try {			
		        OARResponse responseObject;

		        	responseObject = updateOARAccount(	x_service,
														updatedAccount, 
														updatedAccount.OAR_Account_Reference_2__c ,
														updatedAccount.DISE_Group_Code_Account_No_2__c,
														updatedAccount.DISE_2_GROUP__c);


				// Check if the return status is a success
				if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
					
					// No point continuing if the account failed to register
					displayStatus += responseObject.description;
				}
				else {
					
					// Add the account success message to the response
					displayStatus += Label.ACC_UPD_SUCCESS + ' ' + updatedAccount.OAR_Account_Reference_2__c + '\n';
				}
			} // end try block
			catch (Exception e) {
				displayStatus +=  Label.ACC_UPD + e.getMessage() + '\n';
			}
		} // end check for existing OAR reference if
		
		if ((updatedAccount.OAR_Account_Reference_3__c != null) && (updatedAccount.OAR_Account_3_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) {

			// Attempt to update the account
			try {			
		        OARResponse responseObject;
		        	responseObject = updateOARAccount(	x_service,
														updatedAccount, 
														updatedAccount.OAR_Account_Reference_3__c ,
														updatedAccount.DISE_Group_Code_Account_No_3__c,
														updatedAccount.DISE_3_GROUP__c);


				// Check if the return status is a success
				if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
					
					// No point continuing if the account failed to register
					displayStatus += responseObject.description;
				}
				else {
					
					// Add the account success message to the response
					displayStatus += Label.ACC_UPD_SUCCESS + ' ' + updatedAccount.OAR_Account_Reference_3__c + '\n';
				}
			} // end try block
			catch (Exception e) {
				displayStatus +=  Label.ACC_UPD + e.getMessage() + '\n';
			}
		} // end check for existing OAR reference if
		
		if ((updatedAccount.OAR_Account_Reference_4__c != null) && (updatedAccount.OAR_Account_4_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) {

			// Attempt to update the account
			try {			
		        OARResponse responseObject;
		        
	        	responseObject = updateOARAccount(	x_service,
													updatedAccount, 
													updatedAccount.OAR_Account_Reference_4__c ,
													updatedAccount.DISE_Group_Code_Account_No_4__c,
													updatedAccount.DISE_4_GROUP__c);


				// Check if the return status is a success
				if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
					
					// No point continuing if the account failed to register
					displayStatus += responseObject.description;
				}
				else {
					
					// Add the account success message to the response
					displayStatus += Label.ACC_UPD_SUCCESS + ' ' + updatedAccount.OAR_Account_Reference_4__c + '\n';
				}
			} // end try block
			catch (Exception e) {
				displayStatus +=  Label.ACC_UPD + e.getMessage() + '\n';
			}
		} // end check for existing OAR reference if		
		return displayStatus;
	} // end updateAccount
	
	
	// Web service to get back a list of OAR users for the given string
	public static List<OARUserListItem> getOARUserList(String pSearchString) {
		System.debug('In getOARUserList');
		List<OARUserListItem> userList;
		String OARUserList;
		
		// Get the OAR authentication header, created the account stub and add the header to it
		x_service.OARAuthenticationHeader  			=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
		x_service.OARAuthenticationHeader.Username	=	O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
		x_service.OARAuthenticationHeader.Password	=	O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');	
		
		if (O2_linkage_configuration.TESTING) {
    		OARUserList = '<Response><Status /><Description /><NewDataSet><Table><idUser>15019</idUser><FirstName>Abbas</FirstName><LastName>Hasnain</LastName><Email>shussain@o2.com</Email><Telephone>02088138621</Telephone></Table><Table><idUser>16365</idUser><FirstName>Annabelle</FirstName><LastName>Hyman</LastName><Email>annabelle.hyman@o2.com</Email></Table><Table><idUser>6813</idUser><FirstName>Barnaby</FirstName><LastName>Black</LastName><Email>Barnaby.black@o2.com</Email></Table><Table><idUser>8598</idUser><FirstName>Elizabeth</FirstName><LastName>Ponsford</LastName><Email>elizabeth.ponsford@o2.com</Email><Telephone>07786 330261</Telephone></Table><Table><idUser>8598</idUser><FirstName>Elizabeth</FirstName><LastName>Ponsford</LastName><Email>elizabeth.ponsford@o2.com</Email><Telephone>07786 330261</Telephone></Table><Table><idUser>22</idUser><FirstName>Julie</FirstName><LastName>Abbey</LastName><Email>julie.abbey@o2.com</Email><Telephone>0113 202 3105</Telephone></Table><Table><idUser>22</idUser><FirstName>Julie</FirstName><LastName>Abbey</LastName><Email>julie.abbey@o2.com</Email><Telephone>0113 202 3105</Telephone></Table><Table><idUser>6768</idUser><FirstName>Sainabou</FirstName><LastName>Janha</LastName><Email>sainabou.janha@o2.com</Email><Telephone>01753 563061</Telephone></Table></NewDataSet></Response>';
    	} // end TESTING if
    	else {			
    		System.debug('not testing so making call');	
			OARUserList = x_service.UserSearch(UserInfo.getUserName(),pSearchString);
			System.debug('Return user list = ' + OARUserList);
    	}

		userList = parseUserListResponse(OARUserList);
		System.debug('Exiting getOARUserList');
		return userList;
	} // end getOARUsers	
		
		
	// Procedure to hand over account to OAR
	
/*	******************************************************	METHOD:	HANDOVER ACCOUNT **************************************************************	*/			
	
	public static OARResponse handoverAccount(Id pSalesForceAccountIdentifier,String pOARUserId,String pMessage,Date pEffectiveFromDate) 
	{
		String responseMessage;
		String effectiveFromDate = pEffectiveFromDate.day() + O2_linkage_utils.convertToTextMonth(pEffectiveFromDate.month()) + pEffectiveFromDate.year();
		
		// Get the OAR authentication header, created the account stub and add the header to it
		x_service.OARAuthenticationHeader  			=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
		x_service.OARAuthenticationHeader.Username	=	O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
		x_service.OARAuthenticationHeader.Password	=	O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');
		
		if (O2_linkage_configuration.TESTING) {
			responseMessage = '<Response><Status Value="1" /><Description Value="1" /></Response>';
		} // end TESTING if
		else {										
			responseMessage = x_service.HandOverAccount(pSalesForceAccountIdentifier,UserInfo.getUserName(),pOARUserId,pMessage,effectiveFromDate);
		}

		// Get the XML response as an apex object
		OARResponse responseObject = O2_linkage_utils.parseResponse(responseMessage);		
		return responseObject;
	} // end handoverAccount
	
	
	// This is the routine to update a contact via OAR
	
/*	******************************************************	METHOD:	UPDATE CONTACT **************************************************************	*/			
	
	public static String updateContact(Id contactId) 
	{	
		System.debug('In update contact');	
		String displayStatus = '';
	
		Contact con = [Select 	Id,
								Salutation,
								FirstName,
								LastName,
								Title,
								Phone,
								Email,
								Buying_Role__c,
								MailingStreet,
								MailingState,
								MailingCity,
								MailingCountry,
								MailingPostalCode,
								OAR_Registered_Date__c,
								CSIOptOut__c,
								CSIOptOutReason__c,
								CSIFurtherInformation__c,
								CLCeNews__c,
								CLCWhitePapers__c,
								CLCResearchForums__c,
								CLCProductWorkshop__c,
								CLCMicrosite__c, 
								CLCMagazine__c,
								CLCEvents__c,
								CLCEndUser__c,
								CLCDirectMail__c,
								Account.OwnerId,
								OwnerId										
								From Contact Where Id = :contactId];
								
		// First check that the contact firstname is not null - cannot do this with
		// SFDC validation rules as it prevents appexchange downloads for apps that
		// use contacts
		if (con.FirstName == null) {
			displayStatus +=  Label.CON_FIRSTNAME_NULL + '\n';
		}
		else {
			if (con.Title == null) {
				displayStatus +=  Label.CON_TITLE_NULL + '\n';
			}
			else {
				if (con.OwnerId != con.Account.OwnerId) {
					displayStatus += Label.CON_OWNER_NO_MATCH + '\n';
				}
				else {
					
					// Get the OAR authentication header, created the account stub and add the header to it
					x_service.OARAuthenticationHeader  			=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
					x_service.OARAuthenticationHeader.Username	=	O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
					x_service.OARAuthenticationHeader.Password	=	O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');	

					String conResponse = ''; // XML response from OAR	
					String salutation = con.Salutation.replace('.','');
					
					try 
					{	
						System.debug('Calling update contact in stub');		
						if (O2_linkage_configuration.TESTING) {
							conResponse = '<Response><Status Value="1" /><Description Value="1" /></Response>';
						} // end TESTING if
						else {	
							conResponse = x_service.UpdateContact(	contactId,
																		salutation,
																		con.FirstName,
																		con.LastName,
																		con.Title,
																		con.Phone,
																		con.Buying_Role__c == 'COP' ? 'true' : 'false',
																		con.Buying_Role__c == 'COD' ? 'true' : 'false',
																		con.Buying_Role__c == 'COR' ? 'true' : 'false',
																		con.Email,
																		con.MailingStreet,
																		con.MailingCity,
																		con.MailingState,
																		con.MailingCountry,
																		' ', // address 5
																		' ', // address 6
																		con.MailingPostalCode,
																		con.CLCMagazine__c ? 'true' : 'false',// CLCMagazine
																		con.CLCMicrosite__c ? 'true' : 'false',// CLCMicrosite
																		con.CLCeNews__c ? 'true' : 'false',// CLCeNews
																		con.CLCDirectMail__c ? 'true' : 'false',// CLCDirectMail
																		con.CLCEvents__c ? 'true' : 'false',// CLCEvents
																		con.CLCWhitePapers__c ? 'true' : 'false',// CLCWhitePapers
																		con.CLCProductWorkshop__c ? 'true' : 'false',// CLCProductWorkshop
																		con.CLCResearchForums__c ? 'true' : 'false',// CLCResearchForums
																		con.CLCEndUser__c ? 'true' : 'false',// CLCEndUser
																		con.CSIOptOut__c ? 'true' : 'false',// CSIOptOut
																		con.CSIOptOutReason__c,// CSIOptOutReason
																		con.CSIFurtherInformation__c);//  CSIFurtherInformation
							}
							System.debug('contact update response = ' + conResponse);
						
									
							// Get the response and check for a success												
							OARResponse responseObject = O2_linkage_utils.parseResponse(conResponse);
											
							// Add a success or failure message to the display message
							if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
								 displayStatus += Label.CON_UPD + ' ' + responseObject.description;
							}
							else {
								displayStatus += Label.CON_UPD_SUCCESS;
								Contact updateContact = new Contact(	Id = con.Id,
																		recordUpdated__c = false);
								update updateContact;				
							}
							displayStatus += '\n';										
						}
						catch (Exception e) {
							displayStatus +=  Label.CON_UPD + e.getMessage() + '\n';
						}
						
				} // end title null check if
			} // end contact firstname null check if
		} // owner id check if
		return displayStatus;
	} // end updateContact
		
	// This is the routine to create a contact in OAR
	
/*	******************************************************	METHOD:	CREATE CONTACT **************************************************************	*/			
	
	public static String createContact(Id contactId) 
	{		
		String displayStatus = '';
		
		Contact con = [Select 	Id,
								AccountId,
								Salutation,
								FirstName,
								LastName,
								Buying_Role__c,
								Title,
								Phone,
								Email,
								MailingStreet,
								MailingState,
								MailingCity,
								MailingCountry,
								MailingPostalCode,
								OAR_Registered_Date__c,
								CSIOptOut__c,
								CSIOptOutReason__c,
								CSIFurtherInformation__c,
								CLCeNews__c,
								CLCWhitePapers__c,
								CLCResearchForums__c,
								CLCProductWorkshop__c,
								CLCMicrosite__c, 
								CLCMagazine__c,
								CLCEvents__c,
								CLCEndUser__c,
								CLCDirectMail__c,
								Account.OwnerId,
								OwnerId							
								From Contact Where Id = :contactId];
								
		// First check that the contact firstname is not null - cannot do this with
		// SFDC validation rules as it prevents appexchange downloads for apps that
		// use contacts
		if (con.FirstName == null) {
			displayStatus +=  Label.CON_FIRSTNAME_NULL + '\n';
		}
		else {
			if (con.Title == null) {
				displayStatus +=  Label.CON_TITLE_NULL + '\n';
			}
			else {
				if (con.OwnerId != con.Account.OwnerId) {
					displayStatus += Label.CON_OWNER_NO_MATCH + '\n';
				}
				else {
					// Get the OAR authentication header, created the account stub and add the header to it
					x_service.OARAuthenticationHeader  			=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
					x_service.OARAuthenticationHeader.Username	=	O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
					x_service.OARAuthenticationHeader.Password	=	O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');	
					
					String conResponse = ''; // XML response from OAR	
					String salutation = con.Salutation.replace('.','');
					try 
					{
						System.debug('Sending salutation of :' + salutation + ':');
						if (O2_linkage_configuration.TESTING) 
						{
							if (O2_linkage_configuration.FAIL_TEST) 
							{
								conResponse = '<Response><Status Value="5" /><Description Value="Test Fail !" /></Response>';
							}
							else 
							{
								conResponse = '<Response><Status Value="1" /><Description Value="1" /></Response>';
							}
						} // end TESTING if
						else 
						{	
							conResponse =  x_service.CreateContact(	con.AccountId,
																	con.Id,
																	salutation,
																	con.FirstName,
																	con.LastName,
																	con.Title,
																	con.Phone,
																	con.Buying_Role__c == 'COP' ? 'true' : 'false',
																	con.Buying_Role__c == 'COD' ? 'true' : 'false',
																	con.Buying_Role__c == 'COR' ? 'true' : 'false',
																	con.Email,
																	con.MailingStreet,
																	con.MailingCity,
																	con.MailingState,
																	con.MailingCountry,
																	' ', // address 5
																	' ', // address 6
																	con.MailingPostalCode,
																	con.CLCMagazine__c ? 'true' : 'false',// CLCMagazine
																	con.CLCMicrosite__c ? 'true' : 'false',// CLCMicrosite
																	con.CLCeNews__c ? 'true' : 'false',// CLCeNews
																	con.CLCDirectMail__c ? 'true' : 'false',// CLCDirectMail
																	con.CLCEvents__c ? 'true' : 'false',// CLCEvents
																	con.CLCWhitePapers__c ? 'true' : 'false',// CLCWhitePapers
																	con.CLCProductWorkshop__c ? 'true' : 'false',// CLCProductWorkshop
																	con.CLCResearchForums__c ? 'true' : 'false',// CLCResearchForums
																	con.CLCEndUser__c ? 'true' : 'false',// CLCEndUser
																	con.CSIOptOut__c ? 'true' : 'false',// CSIOptOut
																	con.CSIOptOutReason__c,// CSIOptOutReason
																	con.CSIFurtherInformation__c);//  CSIFurtherInformation
						}
						System.debug('Response from create contact = ' + conResponse);																		
		
								
						// Get the response and check for a success												
						OARResponse responseObject = O2_linkage_utils.parseResponse(conResponse);
										
						// Add a success or failure message to the display message
						if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
							displayStatus += Label.CON_REG + ' ' + responseObject.description;
						}
						else {
							displayStatus += Label.CON_REG_SUCCESS;
							Contact updateContact = new Contact(	Id = con.Id,
																	recordUpdated__c = false,
							 										OAR_Registered_Date__c = Datetime.now());
							update updateContact;
						}
						displayStatus += '\n';										
					}
					catch (Exception e) {
						displayStatus +=  Label.CON_REG + e.getMessage() + '\n';
					}
				} // end contact title null check else
			} // end contact firstname null check else
		} // end owner id match check

		return displayStatus;
	} // end createContact
	
	
	// This forces an account handover.  OAR is informed of the new Salesforce.com user owning the record
	
/*	******************************************************	METHOD:	FORCE HANDOVER ACCOUNT **************************************************************	*/		
	
	public static XMLDom forceHandOverAccount(Id pAccId, String previousUser, String newUser) {
		String displayStatus = '';
		
		// Get the OAR authentication header, created the account stub and add the header to it
		x_service.OARAuthenticationHeader  			=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
		x_service.OARAuthenticationHeader.Username	=	O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
		x_service.OARAuthenticationHeader.Password	=	O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');	
		
		String forceResponse = ''; // XML response from OAR	
		
		Date effectiveDate = Date.today();
		String effectiveFromDateString = effectiveDate.day() + O2_linkage_utils.convertToTextMonth(effectiveDate.month()) + effectiveDate.year();
			 
		// Check the testing flag.  If we are testing return a bogus response as we cannot make
		// web service calls outs in tests			 
		if (O2_linkage_configuration.TESTING) 
		{
			forceResponse = '<Response><Status Value="1" /><Description Value="Handover failed. Either The SalesForce User Id does not exist or the Salesforce Account Id does not exist in OAR." /></Response>';
		} // end testing check if
		else 
		{
			forceResponse =  x_service.ForceHandOverAccount(pAccId,	previousUser, newUser, effectiveFromDateString);
			System.debug(forceResponse);																
		} // end testing check else	
		return new XMLDom(forceResponse);
	} // end forceHandOverAccount	
	
	
/*	+++++ ONLY FOR TESTING +++++ *******************	METHOD:	TESTING CALL  *********************************************** +++++ ONLY FOR TESTING +++++	*/			
	
	public void TestingCall(Boolean isTest)
	{
	
		x_service.isTest													=	true;
		Account tmp_acc 													=	[Select 	Id, 
																						OwnerId,
																						Name, 
																						Company_Reg_No__c,
																						BURN__c,
																						MinimumTerm__c,
																						Minimum_Holding__c,
																						Tree_Organisation_ID__c,
																						Contract_End_Date__c,
																						BillingStreet,
																						BillingState,
																						BillingCity,
																						BillingCountry,
																						BillingPostalCode,
																						DISE_Group_Code_Account_No_4__c, 
																						DISE_Group_Code_Account_No_3__c,
																						DISE_Group_Code_Account_No_2__c,
																						DISE_Group_Code_Account_No_1__c,
																						DISE_4_GROUP__c, 
																						DISE_3_GROUP__c,
																						DISE_2_GROUP__c,
																						DISE_1_GROUP__c,
																						NumberOfEmployees,
																						O2_Sector__c,
																						Business_Text_Code__c,
																						PH_Site_ID__c,
																						Desktop_Text_code__c,
																						Managed_Text_Code__c,
																						Mobile_Marketer_Code__c,
																						OAR_Account_Reference_1__c,
																						OAR_Account_Reference_2__c,
																						OAR_Account_Reference_3__c,
																						OAR_Account_Reference_4__c,
																						Contract_Start_Date__c,
																						Contract_Duration__c,
																						Date_Effective_From__c										
																						From Account LIMIT 1];
													
		
		Contact	tmp_con													=	[SELECT Id,
																						AccountId,
																						Salutation,
																						FirstName,
																						LastName,
																						Buying_Role__c,
																						Title,
																						Phone,
																						Email,
																						MailingStreet,
																						MailingState,
																						MailingCity,
																						MailingCountry,
																						MailingPostalCode,
																						OAR_Registered_Date__c,
																						CSIOptOut__c,
																						CSIOptOutReason__c,
																						CSIFurtherInformation__c,
																						CLCeNews__c,
																						CLCWhitePapers__c,
																						CLCResearchForums__c,
																						CLCProductWorkshop__c,
																						CLCMicrosite__c, 
																						CLCMagazine__c,
																						CLCEvents__c,
																						CLCEndUser__c,
																						CLCDirectMail__c,
																						Account.OwnerId,
																						OwnerId
																
																						FROM Contact WHERE AccountId = :tmp_acc.Id ];
																						
		x_service.OARAuthenticationHeader  								=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
		x_service.OARAuthenticationHeader.Username						=	O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
		x_service.OARAuthenticationHeader.Password						=	O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');	
		o2_salesO2CoUk_soapserver.ArrayOfContact tmp_contactCallList	=	new o2_salesO2CoUk_soapserver.ArrayOfContact();
		o2_salesO2CoUk_soapserver.ArrayOfString tmp_response			=	new o2_salesO2CoUk_soapserver.ArrayOfString();

		String minimumTerm		=	tmp_acc.MinimumTerm__c		== null ? '0' : '' + tmp_acc.MinimumTerm__c.intValue();
		String minimumHolding	=	tmp_acc.Minimum_Holding__c	== null ? '0' : tmp_acc.Minimum_Holding__c.intValue() + '';
		String noEmployees		=	tmp_acc.NumberOfEmployees	== null ? '0' : tmp_acc.NumberOfEmployees + '';
		
		String contractStartDateString;
		
		if (tmp_acc.Contract_Start_Date__c != null) 
		{
			contractStartDateString = tmp_acc.Contract_Start_Date__c.day() + O2_linkage_utils.convertToTextMonth(tmp_acc.Contract_Start_Date__c.month()) + tmp_acc.Contract_Start_Date__c.year();
		}

															
		x_service.RegisterAccount(							tmp_acc.Id,
															tmp_acc.Tree_Organisation_ID__c, // treeAccountIdentifier,
															tmp_acc.Name, // customerName,
															tmp_acc.Company_Reg_No__c,// companyRegistrationNumber
															tmp_acc.BURN__c,// businessUniqueReferenceNumber,
															tmp_acc.PH_Site_ID__c,// experianNumber
															contractStartDateString,// contractStartDate??
															tmp_acc.Contract_Duration__c, // duration ??
															minimumTerm,
															minimumHolding,
															tmp_acc.BillingStreet,
															tmp_acc.BillingCity,																
															tmp_acc.BillingState,
															tmp_acc.BillingCountry,
															' ', // address 5
															' ', // address 6
															tmp_acc.BillingPostalCode,
															' ', //DISE_Group_Code,
															' ', //DISE_Account_No,
															tmp_acc.Business_Text_Code__c,
															tmp_acc.Desktop_Text_code__c,
															tmp_acc.Managed_Text_Code__c,
															tmp_acc.Mobile_Marketer_Code__c,
															'10-22-09', //effectiveFromDateString, //dateEffectiveFrom
															noEmployees,
															tmp_acc.O2_Sector__c,
															UserInfo.getUserName());




		o2_salesO2CoUk_soapserver.Contact			tmp_contact			=	new o2_salesO2CoUk_soapserver.Contact();
		List<o2_salesO2CoUk_soapserver.Contact>		tmp_contactList		=	new List<o2_salesO2CoUk_soapserver.Contact>();	
		String salutation = tmp_con.Salutation.replace('.','');
														
		tmp_contact.SalesForceAccountIdentifier		=	tmp_acc.Id;
		tmp_contact.SalesForceContactIdentifier		=	tmp_con.Id;
		tmp_contact.Title							=	salutation;
		tmp_contact.FirstName						=	tmp_con.FirstName;
		tmp_contact.LastName						= 	tmp_con.LastName;
		tmp_contact.Role							= 	'Mr'; //tmp_con.Title;
		tmp_contact.Telephone						= 	tmp_con.Phone;
		tmp_contact.IsCOP							= 	tmp_con.Buying_Role__c == 'COP' ? 'true' : 'false';
		tmp_contact.IsCOD							= 	tmp_con.Buying_Role__c == 'COD' ? 'true' : 'false';
		tmp_contact.IsCOR							= 	tmp_con.Buying_Role__c == 'COR' ? 'true' : 'false';
		tmp_contact.Email							= 	tmp_con.Email;
		tmp_contact.Address1						= 	tmp_con.MailingStreet;
		tmp_contact.Address2						= 	tmp_con.MailingCity;
		tmp_contact.Address3						= 	tmp_con.MailingState;
		tmp_contact.Address4						= 	tmp_con.MailingCountry;
		tmp_contact.Address5						= 	' '; // address 5
		tmp_contact.Address6						= 	' '; // address 6
		tmp_contact.Postcode						= 	tmp_con.MailingPostalCode;
		tmp_contact.CLCMagazine						= 	tmp_con.CLCMagazine__c ? 'true' : 'false';// CLCMagazine
		tmp_contact.CLCMicrosite					= 	tmp_con.CLCMicrosite__c ? 'true' : 'false';// CLCMicrosite
		tmp_contact.CLCeNews						= 	tmp_con.CLCeNews__c ? 'true' : 'false';// CLCeNews
		tmp_contact.CLCDirectMail					= 	tmp_con.CLCDirectMail__c ? 'true' : 'false';// CLCDirectMail
		tmp_contact.CLCEvents						= 	tmp_con.CLCEvents__c ? 'true' : 'false';// CLCEvents
		tmp_contact.CLCWhitePapers					= 	tmp_con.CLCWhitePapers__c ? 'true' : 'false';// CLCWhitePapers
		tmp_contact.CLCProductWorkshop				= 	tmp_con.CLCProductWorkshop__c ? 'true' : 'false';// CLCProductWorkshop
		tmp_contact.CLCResearchForums				= 	tmp_con.CLCResearchForums__c ? 'true' : 'false';// CLCResearchForums
		tmp_contact.CLCEndUser						= 	tmp_con.CLCEndUser__c ? 'true' : 'false';// CLCEndUser
		tmp_contact.CSIOptOut						= 	tmp_con.CSIOptOut__c ? 'true' : 'false';// CSIOptOut
		tmp_contact.CSIOptOutReason					= 	tmp_con.CSIOptOutReason__c;// CSIOptOutReason
		tmp_contact.CSIFurtherInformation			= 	tmp_con.CSIFurtherInformation__c;//  CSIFurtherInformation																								
														
														
														
		
		tmp_contactList.add(tmp_contact);
		tmp_contactCallList.Contact										=	tmp_contactList;	
		
		tmp_response = x_service.CreateContacts(tmp_contactCallList);
		System.debug('### TESTING : ' + tmp_response);
	}
	 
	
		
} // end class