/*****************************************************************************/
/* Paul Tarpey (paul.tarpey@saaspoint.com)                                   */
/* Provides utility apex functions for the O2 Salesforce to OAR Linkage      */
/* project                                                                   */
/*                                                                           */
/* Revision History                                                          */
/* 0.1    12/01/2009  Initial Version                                        */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

// Global for web service exposure
global class O2_linkage_utils {
	
	// Exception to report any connection failure
	public class OARConnectException extends Exception {}
	
	// Exception to report lack of deep URL configuration
	public class DeepURLException extends Exception {}
		
	// Returns the month as a string
	public static String convertToTextMonth(Integer pMonth) {
		String [] months = new String[]{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
		return months[pMonth-1];
	}// end convertToTextMonth
		
	// Parse the response and return 
	public static OARResponse parseResponse(String pResponse) {
		System.debug('Response = ' + pResponse);
		XmlStreamReader xsr = new XmlStreamReader(pResponse);
		OARResponse response = new OARResponse();
		
		// Parse the xml elements
		while(xsr.hasNext()) {
			if (xsr.getEventType() == XmlTag.START_ELEMENT) {
				if ('Status' == xsr.getLocalName()) {
					response.statusValue = xsr.getAttributeValueAt(0);
				}
				if ('Description' == xsr.getLocalName()) {
					response.description = xsr.getAttributeValueAt(0);
				}
				if ((response.description != null) && (response.statusValue != null)) break;	
			} // check for a start element tag
			
			// Get in the next part of the stream
        	xsr.next();
		} // more xml elements while
		return response;
	} // end parseResponse function
			
	public static String parseStringItem(XmlStreamReader pXsr) {
		String retVal;
		while (pXsr.hasNext()) {
			if (pXsr.getEventType() == XmlTag.CHARACTERS) {
				retVal = pXsr.getText();
			}
			else {
				if (pXsr.getEventType() == XmlTag.END_ELEMENT) {
					break;
				}				
			}
			
			// Get in the next part of the stream
        	pXsr.next();				
		} // end hasnext check while
		return retVal;
	} // end parseStringItem
					
	/*
	 * This webservice will call OAR and generate the appropriate redirect
	 * URL and return it to the caller
	 */
	webService static String getOARLink(String deepURLName) {

		String returnToken;
		
		// Variables for accessing the web service
		Integer partnerId = Integer.valueOf(O2_linkage_configuration.getParam('PARTNER_ID'));
		String username = O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
		String password = O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');
		
		// Need to get the deep url.  This is the url of the OAR page we wish to access.
		List<O2_OAR_Deep_URL__c> deepURLs = [Select Deep_URL__c From O2_OAR_Deep_URL__c Where Applicable_Servers__c in ('All',:O2_linkage_configuration.getCurrentSystem()) And Name = :deepURLName Limit 1];
		if (deepURLs.size() != 1) {
			System.debug('No deepURLName found - check configuration');
			throw new DeepURLException(Label.DEEP_URL_ERROR);
		}
		
		String deepUrl = deepURLs[0].Deep_URL__c;
		
		// Create a single sign on stub
		tswRufusleonardComChoice singleSignOnChoice = new tswRufusleonardComChoice(username,password);
		
		// Call ws to get our single sign on token - note we pass the current SF user name
		// Catch any exception from the webservice and hand it back
		System.debug('Calling GetSecurityToken');
		try {
			if (O2_linkage_configuration.TESTING) {
				returnToken = '123456789abcdefg';
			}
			else {
				returnToken = singleSignOnChoice.GetSecurityToken(partnerId,UserInfo.getUserName(),deepUrl);
				System.debug('Returned from GetSecurityToken with token = ' + returnToken);
			}
		}
		catch (Exception e) {
			System.debug('Exception from OAR as follows: ' + e);
			throw new OARConnectException(Label.OAR_SEC_TOK_ERR,e);
		}
		
		return O2_linkage_configuration.getParam('OAR_SIGNON_URL_PREFIX') + returnToken;
	} // end getOARLink function
	
	public static String registerAccount(Id pOpportunityId, Id pAccountId) {
		System.debug('in linkage utils, registerAccount');	
		return salesO2CoUkChoice.registerAccount(pOpportunityId, pAccountId);
	} // end registerAccount
	
	// This is the routine to update the account in OAR.  The received parameter
	// is the related opportunity ID
	public static String updateAccount(Id pAccountId) {
		return salesO2CoUkChoice.updateAccount(pAccountId);
	} // end updateAccount
	
	// Web service to get back a list of OAR users for the given string
	public static List<OARUserListItem> getOARUserList(String pSearchString) {
		System.debug('In O2_linkage_utils.getOARUserList');
		return salesO2CoUkChoice.getOARUserList(pSearchString);
	} // end getOARUsers
	
	// Procedure to hand over account to OAR
	public static OARResponse handoverAccount(Id pSalesForceAccountIdentifier,String pOARUserId,String pMessage,Date pEffectiveFromDate) {
		return salesO2CoUkChoice.handoverAccount(pSalesForceAccountIdentifier, pOARUserId, pMessage, pEffectiveFromDate);
	} // end handoverAccount
	
	// This is the routine to update a contact via ORA
	public static String updateContact(Id contactId) {		
		System.debug('In o2_linkage_utils.updateContact');
		return salesO2CoUkChoice.updateContact(contactId);
	} // end updateContact
	
	// This is the routine to create a contact in OAR
	public static String createContact(Id contactId) {		
		return salesO2CoUkChoice.createContact(contactId);
	} // end createContact
	
	// Routine to retrieve the application sales from OAR
	public static List<ApplicationSale> getApplicationSales() {
		return appSalesO2CoUkChoice.getApplicationSales();
	} // end getApplicationSales
	
	// Get the mobalisation specialists from OAR
	public static List<MobilisationSpec> getMobilisationSpecialists() {
		return appSalesO2CoUkChoice.getMobilisationSpecialists();
	} // end getMobilisationSpecialists
	
	// Routine to create the sale in OAR
	public static String createSale(Id pOppId, 
									String pAppSaleId, 
									Date pSaleDate, 
									Double pSalesVol,
									String pMobSpecialist,
									String pConRef,
									String pTerms,
									String pNotes,
									Id pAccountId ) {
										
		return appSalesO2CoUkChoice.createSale(	pOppId, 
												pAppSaleId, 
												pSaleDate, 
												pSalesVol,
												pMobSpecialist,
												pConRef,
												pTerms,
												pNotes,
												pAccountId);
	} // end createSale
	
	// This forces an account handover.  OAR is informed of the new Salesforce.com user owning the record
	public static XMLDom forceHandOverAccount(Id pAccId, String previousUser, String newUser) {
		return salesO2CoUkChoice.forceHandOverAccount(pAccId, previousUser, newUser);
	} // end forceHandOverAccount
} // end O2_linkage_utils class