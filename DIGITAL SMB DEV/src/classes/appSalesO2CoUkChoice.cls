///
///	Name:	appSalesO2CoUkChoice
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
///	
///
///	Used Classes: (Classes,Trigger,Pages)
///	MobilisationSpec, ApplicationSale, appSalesO2CoUk, O2_linkage_utils, O2_linkage_configuration
///
///	Timeline:
///	Name				DateTime					Description
///	? (Rufus Leonard)	?							Creation of Class
///	Michael Kahle		2010-02-01 15:20 (GMT+1)	Cleaned of second Webservice (_live)
///

public class appSalesO2CoUkChoice 
{
			
	// Parse the user list response from OAR
	private static List<MobilisationSpec> parseMobSpecResponse(String pResponse) {
		XmlStreamReader xsr = new XmlStreamReader(pResponse);
		List<MobilisationSpec> mobSpecList = new List<MobilisationSpec>();
		while (xsr.hasNext()) {
			if (xsr.getEventType() == XmlTag.START_ELEMENT) {
				if ('Table' == xsr.getLocalName()) {
					MobilisationSpec mobSpec = parseMobSecialist(xsr);
					mobSpecList.add(mobSpec);
				} // end check for start tag
			} // end start element check if
			
			// Get in the next part of the stream
        	xsr.next();			
		} // end loop through the xml
		return mobSpecList;
	} // end parseUserListResponse
			
	// Parse a mobilisation specialist envelope and return an object
	private static MobilisationSpec parseMobSecialist(XmlStreamReader pXsr) {
		MobilisationSpec mobSpec = new MobilisationSpec();
		while (pXsr.hasNext()) {
			if (pXsr.getEventType() == XmlTag.START_ELEMENT) {
				if ('idUser' == pXsr.getLocalName()) {
					mobSpec.Id = O2_linkage_utils.parseStringItem(pXsr);
				} 
				else {
					if ('FullName' == pXsr.getLocalName()) {
						mobSpec.fullname = O2_linkage_utils.parseStringItem(pXsr);
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
		return mobSpec;
	} // end parseListItem
			
	// Parse the application sales response from OAR
	private static List<ApplicationSale> parseApplicationSalesResponse(String pResponse) 
	{
		XmlStreamReader xsr 			= new XmlStreamReader(pResponse);
		List<ApplicationSale> salesList = new List<ApplicationSale>();
		while (xsr.hasNext()) 
		{
			if (xsr.getEventType() == XmlTag.START_ELEMENT) 
			{
				if ('Application' == xsr.getLocalName()) 
				{
					ApplicationSale applicationSale		=	new ApplicationSale();
					applicationSale.Id					=	xsr.getAttributeValue(null,'ID');
					applicationSale.Name				=	xsr.getAttributeValue(null,'Name');
					salesList.add(applicationSale);
				} // end check for start tag
			} // end start element check if
			
			// Get in the next part of the stream
        	xsr.next();			
		} // end loop through the xml
		System.debug(salesList);
		return salesList;
	} // end parseApplicationSalesResponse
		
	// This routine returns the OAR header containing the username and password.  This is used in various web
	// service calls into OAR for application sales.  This routine is for the sandbox.
	private static appSalesO2CoUk.OARAuthenticationHeader getSalesOARHeader() 
	{
		System.debug('Getting OAR header for sandbox');
		// Get the OAR header username and password and put them in a header object
		String username = O2_linkage_configuration.getParam('OAR_HEADER_USERNAME');
		String password = O2_linkage_configuration.getParam('OAR_HEADER_PASSWORD');	 
		appSalesO2CoUk.OARAuthenticationHeader header = new appSalesO2CoUk.OARAuthenticationHeader();
		header.Username = username;
		header.Password = password;
		return header;
	} // end getAppSalesOARHeader
	
	// Routine to retrieve the application sales from OAR.  It takes into account
	// whether we are running on live or on a sandbox.
	public static List<ApplicationSale> getApplicationSales() {
		List<ApplicationSale> salesFromOAR;
		

		System.debug('getting sales oar header');
		appSalesO2CoUk.OARAuthenticationHeader header 	= getSalesOARHeader();
	
		// Create the account stub and add the header
		appSalesO2CoUk.ApplicationSaleSoap appSalesStub = new appSalesO2CoUk.ApplicationSaleSoap();
		appSalesStub.OARAuthenticationHeader 			= header;	
		
		String appsResponse;
		if (O2_linkage_configuration.TESTING) 
		{
			appsResponse = '<Response><Status Value="1" /><Description Value="1" /><Applications><Application ID="1" Name="Aeroprise" /><Application ID="5" Name="Cantor" /><Application ID="6" Name="CMS" /><Application ID="3" Name="e-first" /><Application ID="2" Name="Lone Worker" /><Application ID="7" Name="Mobile Workflow - Cognito" /></Applications></Response>';
		}
		else 
		{
			appsResponse = appSalesStub.RetrieveApplications();
		}
		
		
		System.debug('App Sales list = ' + appsResponse);
		salesFromOAR = parseApplicationSalesResponse(appsResponse);

		return salesFromOAR;
	} // end getApplicationSales	
	
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
		String displayStatus = '';
		Boolean foundError = false;	
					 	
		if (!foundError) 
		{
				// Get the OAR authentication header
				appSalesO2CoUk.OARAuthenticationHeader header = getSalesOARHeader();
				
				// Create the account stub and add the header
				appSalesO2CoUk.ApplicationSaleSoap appSalesStub = new appSalesO2CoUk.ApplicationSaleSoap();
				appSalesStub.OARAuthenticationHeader = header;
				
				String salesVol = pSalesVol.intValue() + '';
				String mobSpec = pMobSpecialist == null ? '' : pMobSpecialist;
				String saleDate = pSaleDate.day() + O2_linkage_utils.convertToTextMonth(pSaleDate.month()) + pSaleDate.year();
				try {
					String responseMessage;
					if (O2_linkage_configuration.TESTING) {
						responseMessage = '<Response><Status Value="1" /><Description Value="0" /></Response>';
					}		
					else {
			        	responseMessage = appSalesStub.CreateSale(	UserInfo.getUserName(),
			        												pAccountId ,
			        												saleDate,
			        												pAppSaleId,
			        												pOppId,
			        												salesVol,
			        												mobSpec,
			        												pConRef,
			        												pTerms,
			        												pNotes);
					}
					OARResponse responseObject = O2_linkage_utils.parseResponse(responseMessage);	      
			  		if (responseObject.statusValue != O2_linkage_configuration.getParam('OAR_RESP_SUCCESS')) {
						displayStatus += Label.SALE_REG + ' ' + responseObject.description;
					}
					else {
						displayStatus += Label.SALE_REG_SUCCESS;														
					}       												
				}
				catch (Exception e) {
					displayStatus +=  Label.CREATE_SALE_ERR + e.getMessage() + '\n';
				}

		} // end error not found check if								
				
		return displayStatus;
	} // end createSale	
	
	// Get the mobalisation specialists from OAR
	public static List<MobilisationSpec> getMobilisationSpecialists() {
		List<MobilisationSpec> mobSpecs;
		String mobSpecResponse;
		
		// Get the OAR authentication header
		appSalesO2CoUk.OARAuthenticationHeader header = getSalesOARHeader();
		
		// Create the account stub and add the header
		appSalesO2CoUk.ApplicationSaleSoap appSalesStub = new appSalesO2CoUk.ApplicationSaleSoap();
		appSalesStub.OARAuthenticationHeader = header;	
		
		if (O2_linkage_configuration.TESTING) {
			mobSpecResponse = '<Response><Status /><Description /><NewDataSet><Table><idUser>4068</idUser><FullName>Chris Willmott</FullName></Table><Table><idUser>10670</idUser><FullName>Colin MacDonald</FullName></Table><Table><idUser>10618</idUser><FullName>David Kavanagh</FullName></Table><Table><idUser>1886</idUser><FullName>Gareth Howard</FullName></Table><Table><idUser>10292</idUser><FullName>Gavin Thomas</FullName></Table><Table><idUser>2924</idUser><FullName>Jazbir Pangli</FullName></Table><Table><idUser>1659</idUser><FullName>Kevin Harbisher</FullName></Table><Table><idUser>1045</idUser><FullName>Matthew Denby</FullName></Table><Table><idUser>3590</idUser><FullName>Michael Steed</FullName></Table><Table><idUser>10483</idUser><FullName>Richard Brailsford</FullName></Table><Table><idUser>539</idUser><FullName>Russell Bryant</FullName></Table><Table><idUser>3252</idUser><FullName>Shaun Robins</FullName></Table><Table><idUser>10646</idUser><FullName>Steve Tingey</FullName></Table><Table><idUser>15403</idUser><FullName>Steven Rowell</FullName></Table><Table><idUser>9878</idUser><FullName>Tim Hooper</FullName></Table><Table><idUser>2411</idUser><FullName>Tom MacAllister</FullName></Table></NewDataSet></Response>';
		}
		else {
			mobSpecResponse = appSalesStub.GetMobilisationSpecialists();
		}
		
		System.debug('paul mob specs = ' + mobSpecResponse);

		mobSpecs = parseMobSpecResponse(mobSpecResponse);
		return mobSpecs;
	} // end getMobilisationSpecialists	
} // end class