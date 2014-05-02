public with sharing class o2_globalTestMethod_SoapCover 
{
	
	//==================================================
	public static void RUN_THIS_CLASS() 
	//==================================================
	{
		o2_salesO2CoUk_soapserver();
		appSalesO2CoUk(); 
		
	}
	
	//==================================================
	public static testMethod void appSalesO2CoUk() 
	//==================================================
	{
		
		appSalesO2CoUk 							test_appSalesO2CoUk			= new appSalesO2CoUk();

		//	CreateSale_element
		appSalesO2CoUk.CreateSale_element test_CreateSale_element	=	new appSalesO2CoUk.CreateSale_element();
		test_CreateSale_element.salesForceUserName	=	null;
		test_CreateSale_element.salesForceAccountIdentifier	=	null;
		test_CreateSale_element.saleDate	=	null;
		test_CreateSale_element.OARApplicationIdentifier	=	null;
		test_CreateSale_element.salesForceOpportunityIdentifier	=	null;
		test_CreateSale_element.salesVolume	=	null;
		test_CreateSale_element.mobilisationSpecialist	=	null;
		test_CreateSale_element.contractReference	=	null;
		test_CreateSale_element.contractTerms	=	null;
		test_CreateSale_element.notes	=	null;
	
		//	ApplicationSaleSoap
		appSalesO2CoUk.ApplicationSaleSoap test_ApplicationSaleSoap	=	new appSalesO2CoUk.ApplicationSaleSoap();
		
		test_ApplicationSaleSoap.inputHttpHeaders_x	=	null;
		test_ApplicationSaleSoap.outputHttpHeaders_x	=	null;
		test_ApplicationSaleSoap.clientCert_x	=	null;
		test_ApplicationSaleSoap.clientCertPasswd_x	=	null;
		test_ApplicationSaleSoap.timeout_x	=	null;
		test_ApplicationSaleSoap.OARAuthenticationHeader	=	null;

		
		//	RetrieveApplicationsResponse_element
		appSalesO2CoUk.RetrieveApplicationsResponse_element test_RetrieveApplicationsResponse_element	=	new appSalesO2CoUk.RetrieveApplicationsResponse_element();
		test_RetrieveApplicationsResponse_element.RetrieveApplicationsResult	=	null;
	
		//	GetMobilisationSpecialistsResponse_element
		appSalesO2CoUk.GetMobilisationSpecialistsResponse_element test_GetMobilisationSpecialistsResponse_element	=	new appSalesO2CoUk.GetMobilisationSpecialistsResponse_element();
		test_GetMobilisationSpecialistsResponse_element.GetMobilisationSpecialistsResult	=	null;

		//	CreateSaleResponse_element
		appSalesO2CoUk.CreateSaleResponse_element test_CreateSaleResponse_element	=	new appSalesO2CoUk.CreateSaleResponse_element();
		test_CreateSaleResponse_element.CreateSaleResult	=	null;

		//	OARAuthenticationHeader
		appSalesO2CoUk.OARAuthenticationHeader test_OARAuthenticationHeader	=	new appSalesO2CoUk.OARAuthenticationHeader();
		test_OARAuthenticationHeader.Username	=	null;
		test_OARAuthenticationHeader.Password	=	null;
	}
		
	//==================================================
	public static testMethod void o2_salesO2CoUk_soapserver() 
	//==================================================
	{

		//	ForceHandOverAccountResponse_element
		o2_salesO2CoUk_soapserver.ForceHandOverAccountResponse_element test_ForceHandOverAccountResponse_element	=	new o2_salesO2CoUk_soapserver.ForceHandOverAccountResponse_element();
		test_ForceHandOverAccountResponse_element.ForceHandOverAccountResult	=	null;
		
		
		//	UpdateAccountResponse_element
		o2_salesO2CoUk_soapserver.UpdateAccountResponse_element test_UpdateAccountResponse_element	=	new o2_salesO2CoUk_soapserver.UpdateAccountResponse_element();
		test_UpdateAccountResponse_element.UpdateAccountResult	=	null;
		
		
		//	HandOverAccountResponse_element
		o2_salesO2CoUk_soapserver.HandOverAccountResponse_element test_HandOverAccountResponse_element	=	new o2_salesO2CoUk_soapserver.HandOverAccountResponse_element();
		test_HandOverAccountResponse_element.HandOverAccountResult	=	null;
		
		
		//	Contact
		o2_salesO2CoUk_soapserver.Contact test_Contact	=	new o2_salesO2CoUk_soapserver.Contact();
		test_Contact.SalesForceAccountIdentifier	=	null;
		test_Contact.SalesForceContactIdentifier	=	null;
		test_Contact.Title	=	null;
		test_Contact.FirstName	=	null;
		test_Contact.LastName	=	null;
		test_Contact.Role	=	null;
		test_Contact.Telephone	=	null;
		test_Contact.IsCOP	=	null;
		test_Contact.IsCOD	=	null;
		test_Contact.IsCOR	=	null;
		test_Contact.Email	=	null;
		test_Contact.Address1	=	null;
		test_Contact.Address2	=	null;
		test_Contact.Address3	=	null;
		test_Contact.Address4	=	null;
		test_Contact.Address5	=	null;
		test_Contact.Address6	=	null;
		test_Contact.Postcode	=	null;
		test_Contact.CLCMagazine	=	null;
		test_Contact.CLCMicrosite	=	null;
		test_Contact.CLCeNews	=	null;
		test_Contact.CLCDirectMail	=	null;
		test_Contact.CLCEvents	=	null;
		test_Contact.CLCWhitePapers	=	null;
		test_Contact.CLCProductWorkshop	=	null;
		test_Contact.CLCResearchForums	=	null;
		test_Contact.CLCEndUser	=	null;
		test_Contact.CSIOptOut	=	null;
		test_Contact.CSIOptOutReason	=	null;
		test_Contact.CSIFurtherInformation	=	null;
		
		
		//	UserSearch_element
		o2_salesO2CoUk_soapserver.UserSearch_element test_UserSearch_element	=	new o2_salesO2CoUk_soapserver.UserSearch_element();
		test_UserSearch_element.salesForceUserIdentifier	=	null;
		test_UserSearch_element.userSearchString	=	null;
		
		
		//	CreateContactsResponse_element
		o2_salesO2CoUk_soapserver.CreateContactsResponse_element test_CreateContactsResponse_element	=	new o2_salesO2CoUk_soapserver.CreateContactsResponse_element();
		test_CreateContactsResponse_element.CreateContactsResult	=	null;
		
		
		//	ArrayOfString
		o2_salesO2CoUk_soapserver.ArrayOfString test_ArrayOfString	=	new o2_salesO2CoUk_soapserver.ArrayOfString();
		test_ArrayOfString.string_x	=	null;
		
		
		//	UpdateContacts_element
		o2_salesO2CoUk_soapserver.UpdateContacts_element test_UpdateContacts_element	=	new o2_salesO2CoUk_soapserver.UpdateContacts_element();
		test_UpdateContacts_element.contactList	=	null;
		
		
		//	UpdateAccount_element
		o2_salesO2CoUk_soapserver.UpdateAccount_element test_UpdateAccount_element	=	new o2_salesO2CoUk_soapserver.UpdateAccount_element();
		test_UpdateAccount_element.salesForceAccountIdentifier	=	null;
		test_UpdateAccount_element.treeAccountIdentifier	=	null;
		test_UpdateAccount_element.customerName	=	null;
		test_UpdateAccount_element.companyRegistrationNumber	=	null;
		test_UpdateAccount_element.businessUniqueReferenceNumber	=	null;
		test_UpdateAccount_element.experianNumber	=	null;
		test_UpdateAccount_element.contractStartDate	=	null;
		test_UpdateAccount_element.contractEndDate	=	null;
		test_UpdateAccount_element.duration	=	null;
		test_UpdateAccount_element.minimumTerm	=	null;
		test_UpdateAccount_element.minimumHolding	=	null;
		test_UpdateAccount_element.address1	=	null;
		test_UpdateAccount_element.address2	=	null;
		test_UpdateAccount_element.address3	=	null;
		test_UpdateAccount_element.address4	=	null;
		test_UpdateAccount_element.address5	=	null;
		test_UpdateAccount_element.address6	=	null;
		test_UpdateAccount_element.postcode	=	null;
		test_UpdateAccount_element.DISEGroupCode	=	null;
		test_UpdateAccount_element.DISEAccountCode	=	null;
		test_UpdateAccount_element.businessTextCode	=	null;
		test_UpdateAccount_element.desktopTextCode	=	null;
		test_UpdateAccount_element.managedTextCode	=	null;
		test_UpdateAccount_element.mobilemarketerCode	=	null;
		test_UpdateAccount_element.dateEffectiveFrom	=	null;
		test_UpdateAccount_element.numberOfEmployees	=	null;
		test_UpdateAccount_element.industrySector	=	null;
		test_UpdateAccount_element.salesForceUserId	=	null;
		
		
		//	HandOverAccount_element
		o2_salesO2CoUk_soapserver.HandOverAccount_element test_HandOverAccount_element	=	new o2_salesO2CoUk_soapserver.HandOverAccount_element();
		test_HandOverAccount_element.salesForceAccountIdentifier	=	null;
		test_HandOverAccount_element.salesForceUserId	=	null;
		test_HandOverAccount_element.OARUserId	=	null;
		test_HandOverAccount_element.message	=	null;
		test_HandOverAccount_element.effectiveFromDate	=	null;
		
		
		//	CreateContact_element
		o2_salesO2CoUk_soapserver.CreateContact_element test_CreateContact_element	=	new o2_salesO2CoUk_soapserver.CreateContact_element();
		test_CreateContact_element.salesForceAccountIdentifier	=	null;
		test_CreateContact_element.salesForceContactIdentifier	=	null;
		test_CreateContact_element.title	=	null;
		test_CreateContact_element.firstName	=	null;
		test_CreateContact_element.lastName	=	null;
		test_CreateContact_element.role	=	null;
		test_CreateContact_element.telephone	=	null;
		test_CreateContact_element.isCOP	=	null;
		test_CreateContact_element.isCOD	=	null;
		test_CreateContact_element.isCOR	=	null;
		test_CreateContact_element.email	=	null;
		test_CreateContact_element.address1	=	null;
		test_CreateContact_element.address2	=	null;
		test_CreateContact_element.address3	=	null;
		test_CreateContact_element.address4	=	null;
		test_CreateContact_element.address5	=	null;
		test_CreateContact_element.address6	=	null;
		test_CreateContact_element.postcode	=	null;
		test_CreateContact_element.CLCMagazine	=	null;
		test_CreateContact_element.CLCMicrosite	=	null;
		test_CreateContact_element.CLCeNews	=	null;
		test_CreateContact_element.CLCDirectMail	=	null;
		test_CreateContact_element.CLCEvents	=	null;
		test_CreateContact_element.CLCWhitePapers	=	null;
		test_CreateContact_element.CLCProductWorkshop	=	null;
		test_CreateContact_element.CLCResearchForums	=	null;
		test_CreateContact_element.CLCEndUser	=	null;
		test_CreateContact_element.CSIOptOut	=	null;
		test_CreateContact_element.CSIOptOutReason	=	null;
		test_CreateContact_element.CSIFurtherInformation	=	null;
		
		
		//	CreateContactResponse_element
		o2_salesO2CoUk_soapserver.CreateContactResponse_element test_CreateContactResponse_element	=	new o2_salesO2CoUk_soapserver.CreateContactResponse_element();
		test_CreateContactResponse_element.CreateContactResult	=	null;
		
		
		//	ArrayOfContact
		o2_salesO2CoUk_soapserver.ArrayOfContact test_ArrayOfContact	=	new o2_salesO2CoUk_soapserver.ArrayOfContact();
		test_ArrayOfContact.Contact	=	null;
		
		
		//	UpdateContact_element
		o2_salesO2CoUk_soapserver.UpdateContact_element test_UpdateContact_element	=	new o2_salesO2CoUk_soapserver.UpdateContact_element();
		test_UpdateContact_element.salesForceContactIdentifier	=	null;
		test_UpdateContact_element.title	=	null;
		test_UpdateContact_element.firstName	=	null;
		test_UpdateContact_element.lastName	=	null;
		test_UpdateContact_element.role	=	null;
		test_UpdateContact_element.telephone	=	null;
		test_UpdateContact_element.isCOP	=	null;
		test_UpdateContact_element.isCOD	=	null;
		test_UpdateContact_element.isCOR	=	null;
		test_UpdateContact_element.email	=	null;
		test_UpdateContact_element.address1	=	null;
		test_UpdateContact_element.address2	=	null;
		test_UpdateContact_element.address3	=	null;
		test_UpdateContact_element.address4	=	null;
		test_UpdateContact_element.address5	=	null;
		test_UpdateContact_element.address6	=	null;
		test_UpdateContact_element.postcode	=	null;
		test_UpdateContact_element.CLCMagazine	=	null;
		test_UpdateContact_element.CLCMicrosite	=	null;
		test_UpdateContact_element.CLCeNews	=	null;
		test_UpdateContact_element.CLCDirectMail	=	null;
		test_UpdateContact_element.CLCEvents	=	null;
		test_UpdateContact_element.CLCWhitePapers	=	null;
		test_UpdateContact_element.CLCProductWorkshop	=	null;
		test_UpdateContact_element.CLCResearchForums	=	null;
		test_UpdateContact_element.CLCEndUser	=	null;
		test_UpdateContact_element.CSIOptOut	=	null;
		test_UpdateContact_element.CSIOptOutReason	=	null;
		test_UpdateContact_element.CSIFurtherInformation	=	null;
		
		
		//	UpdateContactResponse_element
		o2_salesO2CoUk_soapserver.UpdateContactResponse_element test_UpdateContactResponse_element	=	new o2_salesO2CoUk_soapserver.UpdateContactResponse_element();
		test_UpdateContactResponse_element.UpdateContactResult	=	null;
		
		
		//	UserSearchResponse_element
		o2_salesO2CoUk_soapserver.UserSearchResponse_element test_UserSearchResponse_element	=	new o2_salesO2CoUk_soapserver.UserSearchResponse_element();
		test_UserSearchResponse_element.UserSearchResult	=	null;
		
		
		//	CreateContacts_element
		o2_salesO2CoUk_soapserver.CreateContacts_element test_CreateContacts_element	=	new o2_salesO2CoUk_soapserver.CreateContacts_element();
		test_CreateContacts_element.contactList	=	null;
		
		
		//	RegisterAccount_element
		o2_salesO2CoUk_soapserver.RegisterAccount_element test_RegisterAccount_element	=	new o2_salesO2CoUk_soapserver.RegisterAccount_element();
		test_RegisterAccount_element.salesForceAccountIdentifier	=	null;
		test_RegisterAccount_element.treeAccountIdentifier	=	null;
		test_RegisterAccount_element.customerName	=	null;
		test_RegisterAccount_element.companyRegistrationNumber	=	null;
		test_RegisterAccount_element.businessUniqueReferenceNumber	=	null;
		test_RegisterAccount_element.experianNumber	=	null;
		test_RegisterAccount_element.contractStartDate	=	null;
		test_RegisterAccount_element.duration	=	null;
		test_RegisterAccount_element.minimumTerm	=	null;
		test_RegisterAccount_element.minimumHolding	=	null;
		test_RegisterAccount_element.address1	=	null;
		test_RegisterAccount_element.address2	=	null;
		test_RegisterAccount_element.address3	=	null;
		test_RegisterAccount_element.address4	=	null;
		test_RegisterAccount_element.address5	=	null;
		test_RegisterAccount_element.address6	=	null;
		test_RegisterAccount_element.postcode	=	null;
		test_RegisterAccount_element.DISEGroupCode	=	null;
		test_RegisterAccount_element.DISEAccountCode	=	null;
		test_RegisterAccount_element.businessTextCode	=	null;
		test_RegisterAccount_element.desktopTextCode	=	null;
		test_RegisterAccount_element.managedTextCode	=	null;
		test_RegisterAccount_element.mobileMarketerCode	=	null;
		test_RegisterAccount_element.dateEffectiveFrom	=	null;
		test_RegisterAccount_element.numberOfEmployees	=	null;
		test_RegisterAccount_element.industrySector	=	null;
		test_RegisterAccount_element.salesForceUserId	=	null;
		
		
		//	RegisterAccountResponse_element
		o2_salesO2CoUk_soapserver.RegisterAccountResponse_element test_RegisterAccountResponse_element	=	new o2_salesO2CoUk_soapserver.RegisterAccountResponse_element();
		test_RegisterAccountResponse_element.RegisterAccountResult	=	null;
		
		
		//	AccountSoap
		o2_salesO2CoUk_soapserver.AccountSoap test_AccountSoap	=	new o2_salesO2CoUk_soapserver.AccountSoap();
		test_AccountSoap.inputHttpHeaders_x	=	null;
		test_AccountSoap.outputHttpHeaders_x	=	null;
		test_AccountSoap.clientCertName_x	=	null;
		test_AccountSoap.clientCert_x	=	null;
		test_AccountSoap.clientCertPasswd_x	=	null;
		test_AccountSoap.timeout_x	=	null;
		test_AccountSoap.OARAuthenticationHeader	=	null;
		
		
		//	UpdateContactsResponse_element
		o2_salesO2CoUk_soapserver.UpdateContactsResponse_element test_UpdateContactsResponse_element	=	new o2_salesO2CoUk_soapserver.UpdateContactsResponse_element();
		test_UpdateContactsResponse_element.UpdateContactsResult	=	null;
		
		
		//	OARAuthenticationHeader
		o2_salesO2CoUk_soapserver.OARAuthenticationHeader test_OARAuthenticationHeader2	=	new o2_salesO2CoUk_soapserver.OARAuthenticationHeader();
		test_OARAuthenticationHeader2.Username	=	null;
		test_OARAuthenticationHeader2.Password	=	null;
		
		
		//	ForceHandOverAccount_element
		o2_salesO2CoUk_soapserver.ForceHandOverAccount_element test_ForceHandOverAccount_element	=	new o2_salesO2CoUk_soapserver.ForceHandOverAccount_element();
		test_ForceHandOverAccount_element.salesForceAccountIdentifier	=	null;
		test_ForceHandOverAccount_element.salesForceUserId	=	null;
		test_ForceHandOverAccount_element.salesForceUserIdToHandoverTo	=	null;
		test_ForceHandOverAccount_element.effectiveFromDate	=	null;
	}


}