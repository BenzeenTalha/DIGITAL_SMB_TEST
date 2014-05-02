@isTest
global class AvailabilityCheckWSMock1 implements WebServiceMock {
   
    global void doInvoke (
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
		
        SOAViewFixedLineAvailabilityData.getInstallationDetails_2Response respElement = 
            new SOAViewFixedLineAvailabilityData.getInstallationDetails_2Response();
        
        SOACoreData2.ServiceResultType status = new SOACoreData2.ServiceResultType();
        status.statusCode = 'viewfixedlineavailability-36890-0002-S';
        status.externalDescription = 'Installation details retrieved successfully.';
        status.internalDescription = '2000 : Request Successful';
        respElement.status = status;
        
        SOAViewFixedLineAvailabilityData.installationDetailsType2 installationDetails =
            new SOAViewFixedLineAvailabilityData.installationDetailsType2();
        installationDetails.serviceType = 'PSTN Single Line';
        installationDetails.installationType = 'Standard';
        installationDetails.numberRetentionAllowed = 'N';
        installationDetails.lineType = 'Basic';
        installationDetails.ownershipConfirmation = 'N';
        installationDetails.districtCode = 'SL';
        installationDetails.exchangeGroupCode = 'IPSW3';
        installationDetails.cssExchangeType = 'AXE10';
        installationDetails.auxiliaryLineQuantity = 0;
        installationDetails.narrowbandServicesIndicator = 'N';
        installationDetails.careLevel = '1';
        installationDetails.tempStructure = 'N';
        installationDetails.carrierPreSelectPresent = 'N';
        installationDetails.wholesaleCallsPresent = 'N';
        installationDetails.terminationType = 'NTE';
        respElement.installationDetails = installationDetails; 
               
        response.put('response_x', respElement); 
   }
    
}