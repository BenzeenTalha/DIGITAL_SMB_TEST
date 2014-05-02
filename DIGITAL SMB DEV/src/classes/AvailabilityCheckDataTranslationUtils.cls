/*
*   This class contains utility functions to translate 
*   the line check service response into the SFDC objects 
*   SO'Halloran - (SFDC)
*   Revision History 
*   1.0    10/02/2011  Initial Version
*/     
public with sharing class AvailabilityCheckDataTranslationUtils {
     
    static final string PREFIX_CNF = 'cnf.';
    static final string PREFIX_INCOMPATIBLE = 'inc.';
    static final string PREFIX_UNSUPPORTED = 'uns.';
    
    public static final string DESC_CAN_ORDER_BB = 'Clear line - can order Broadband products';
    public static final string DESC_CAN_ORDER_BB_IPS = 'Clear line - can order IPS Broadband products';
    public static final string DESC_CAN_ORDER_BB_LLU = 'Clear line - can order LLU Broadband products';
    public static final String DESC_BB_RETRIEVE_OK = 'Broadband service details retrieved successfully.';
    public static final String DESC_BB_RETRIEVE_O2_OK = 'For postcode entered, O2 LLU broadband service is available.';
    public static final String DESC_BB_RETRIEVE_BT_OK = 'For postcode entered, O2 IPS broadband service is available.';
    public static final String DESC_BB_RETRIEVE_NOT_OK = 'No broadband available in supplied postcode.';                   
    public static final String DESC_BB_RETRIEVE_NODNORPC = 'Please supply directory name and/or postcode.';                   
    public static final string DESC_CAN_ORDER_O2_BB = 'Clear line - can order O2 Business BB';
    public static final string DESC_CANNOT_ORDER_O2_BB = 'Cannot order O2 Business BB due to unavailability of service';
   
    static Map <String,String> XMLTextToFieldMap;
    static boolean CNFlineNumberIsOne = false;
    // Create line availability request message
    public List<SOAViewFixedLineAvailabilityData.lineParametersType> getLineParameters(Line_Availability__c lineAvailabilityRequest) {
        List<SOAViewFixedLineAvailabilityData.lineParametersType> lineParameters = new List<SOAViewFixedLineAvailabilityData.lineParametersType>();
        SOAViewFixedLineAvailabilityData.lineParametersType lineParameter = new SOAViewFixedLineAvailabilityData.lineParametersType();
        lineParameter.requestersId = lineAvailabilityRequest.Batch_Job__c;
        lineParameter.workingLineTakeover = 'N';
        lineParameter.endUserConsent = 'Y';
        SOAViewFixedLineAvailabilityData.serviceIdType serviceIdType = new SOAViewFixedLineAvailabilityData.serviceIdType();
        serviceIdType.directoryNumber = lineAvailabilityRequest.Directory_Number__c;
        lineParameter.serviceId = serviceIdType;
        lineParameter.postcode = lineAvailabilityRequest.Post_Code__c;
        lineParameters.add(lineParameter);
        return lineParameters;
    }
    
	private static Boolean isPostCodeOnly(String dn, String pc) {
        return( (String.isEmpty(dn)) && (!String.isEmpty(pc)) );
    }

    private static Boolean isEmptyLookup(String dn, String pc) {
        return( (String.isEmpty(dn)) && (String.isEmpty(pc)) );
    }
    
    public static String getShortDesc(String defaultString, String dn, String pc, String externalDescription, Boolean isLLUAvailable, Boolean isIPStreamAvailable, String reasonCode) {
        String s = defaultString;
    
        if(reasonCode=='Z' || reasonCode=='z') {
            if (isPostcodeOnly(dn, pc)) {
     			
                if (externalDescription.equalsIgnoreCase(DESC_BB_RETRIEVE_OK)) {
                    if (isLLUAvailable) {
                        s = DESC_BB_RETRIEVE_O2_OK;
                    } else if (isIPStreamAvailable) {
                       s = DESC_BB_RETRIEVE_BT_OK;
                    } else {
                        s = DESC_BB_RETRIEVE_NOT_OK;
                    }          
                } else {
                	// was not retrieved ok
                	s = DESC_BB_RETRIEVE_NOT_OK;
                }
                               
            } else if (isEmptyLookup(dn, pc)){
            	s = DESC_BB_RETRIEVE_NODNORPC;
            } else {
            	// must be dn or (dn and pc)
            	if (isLLUAvailable || isIPStreamAvailable)
            		s = DESC_CAN_ORDER_O2_BB;
            	else s = DESC_CANNOT_ORDER_O2_BB;
            }
        }

        return(s);
    }
    
    // Parse line availability response for Broadband
    public static AvailabilityCheck processResponse(SOABroadbandAvailabilityData.getBusinessAvailability_1Response res, AvailabilityCheck lar) {            
        SOACoreData2.ServiceResultType serviceResult = res.serviceResult;
        if(serviceResult!=null) {
            lar.lineAvailability.Status_Code__c = serviceResult.statusCode;
            lar.lineAvailability.Response__c= serviceResult.externalDescription;
            lar.lineAvailability.Internal_Description__c = serviceResult.internalDescription;
            lar.lineAvailability.External_Description__c = serviceResult.externalDescription;
            SOABroadbandAvailabilityData.businessAvailabilityDetailsType businessAvailabilityDetails = res.businessAvailabilityDetails; 
            
            // This needs special handling. SOA is returning "working" on a PostCode search. "Working" only makes sense on a Line Check.
            // Really this is a SOA bug but we filter it out here to make the output more usable
            if (!isPostCodeOnly(lar.lineAvailability.Directory_Number__c, lar.lineAvailability.Post_Code__c)) {
                lar.lineAvailability.accessLineStatus__c = businessAvailabilityDetails.accessLineStatus;            
            } else lar.lineAvailability.accessLineStatus__c = '';
            
            lar.lineAvailability.aggregatedCalculatedDBLoss__c = businessAvailabilityDetails.aggregatedCalculatedDBLoss;
            lar.lineAvailability.aggregatedCapacitance__c = businessAvailabilityDetails.aggregatedCapacitance;
            lar.lineAvailability.aggregatedCelerityDBLoss__c = businessAvailabilityDetails.aggregatedCelerityDBLoss;
            lar.lineAvailability.aggregatedCircuitLineLengthEstimate__c = businessAvailabilityDetails.aggregatedCircuitLineLengthEstimate;
            lar.lineAvailability.aggregatedDPLineLengthEstimate__c = businessAvailabilityDetails.aggregatedDPLineLengthEstimate;
            lar.lineAvailability.anfpCategory__c = businessAvailabilityDetails.anfpCategory;
            lar.lineAvailability.btExchangeCode__c = businessAvailabilityDetails.btExchangeCode;
            lar.lineAvailability.btExchangeId__c = businessAvailabilityDetails.btExchangeId;
            lar.lineAvailability.btExchangeName__c = businessAvailabilityDetails.btExchangeName;
            lar.lineAvailability.contractedPartyName__c = businessAvailabilityDetails.contractedPartyName;
            lar.lineAvailability.contractedPartyNumber__c = businessAvailabilityDetails.contractedPartyNumber;
            if(businessAvailabilityDetails.postCode!=null && businessAvailabilityDetails.postCode.trim().length()>0) lar.lineAvailability.Post_Code__c = businessAvailabilityDetails.postCode;
            
            if(businessAvailabilityDetails.districtCodeList!=null) {
                if(!businessAvailabilityDetails.districtCodeList.districtCode.isEmpty()) {
                    lar.lineAvailability.districtCodeList__c = '';
                    for(String dc : businessAvailabilityDetails.districtCodeList.districtCode) {
                        lar.lineAvailability.districtCodeList__c += dc + ';'; 
                    }
                }
            }
            
            lar.lineAvailability.earthCapacitanceA__c = businessAvailabilityDetails.earthCapacitanceA;
            lar.lineAvailability.earthCapacitanceB__c = businessAvailabilityDetails.earthCapacitanceB;
            lar.lineAvailability.estimatedLineSpeed__c = businessAvailabilityDetails.estimatedLineSpeed;
            
            if(businessAvailabilityDetails.fixedRate!=null) {
                lar.lineAvailability.fr_capacity__c = businessAvailabilityDetails.fixedRate.capacity;
                lar.lineAvailability.fr_exchState__c = businessAvailabilityDetails.fixedRate.exchState;
                lar.lineAvailability.fr_maxRange__c = businessAvailabilityDetails.fixedRate.maxRange;
                lar.lineAvailability.fr_minRange__c = businessAvailabilityDetails.fixedRate.minRange;
                lar.lineAvailability.fr_rag__c = businessAvailabilityDetails.fixedRate.rag;
                lar.lineAvailability.fr_readyDate__c = businessAvailabilityDetails.fixedRate.readyDate;
                lar.lineAvailability.fr_speed__c = businessAvailabilityDetails.fixedRate.speed;
            }
            
            lar.lineAvailability.isIPStreamAvailable__c = businessAvailabilityDetails.isIPStreamAvailable;
            lar.lineAvailability.isLLUAvailable__c = businessAvailabilityDetails.isLLUAvailable;
            
            lar.lineAvailability.lineLengthEstimate__c = businessAvailabilityDetails.lineLengthEstimate;
            
            lar.lineAvailability.predictedDownloadSpeed__c = businessAvailabilityDetails.predictedDownloadSpeed;
            
            if(businessAvailabilityDetails.productList!=null) {
                if(businessAvailabilityDetails.productList.product!=null) {
                    if(!businessAvailabilityDetails.productList.product.isEmpty()) {
                        lar.lineAvailability.productList__c = '';
                        
                        for(SOABroadbandPSCommonAvatar.productType product : businessAvailabilityDetails.productList.product) {
                            lar.lineAvailability.productList__c += product.productName + ';'; 
                        }                       
                    }
                }
            }
            
            if(businessAvailabilityDetails.rateAdaptive!=null) {
                lar.lineAvailability.ra_capacity__c = businessAvailabilityDetails.rateAdaptive.capacity;
                lar.lineAvailability.ra_exchState__c = businessAvailabilityDetails.rateAdaptive.exchState;
                lar.lineAvailability.ra_maxRange__c = businessAvailabilityDetails.rateAdaptive.maxRange;
                lar.lineAvailability.ra_minRange__c = businessAvailabilityDetails.rateAdaptive.minRange;
                lar.lineAvailability.ra_rag__c = businessAvailabilityDetails.rateAdaptive.rag;
                lar.lineAvailability.ra_readyDate__c = businessAvailabilityDetails.rateAdaptive.readyDate;
                lar.lineAvailability.ra_speed__c = businessAvailabilityDetails.rateAdaptive.speed;
            }
            
            lar.lineAvailability.reasonCode__c = businessAvailabilityDetails.reasonCode;
            if(businessAvailabilityDetails.reasonCode !=null && BT_Broadband_Reason_Codes__c.getInstance(businessAvailabilityDetails.reasonCode)!=null) {
                lar.lineAvailability.Reason_code_short_text__c = BT_Broadband_Reason_Codes__c.getInstance(businessAvailabilityDetails.reasonCode).Description__c;
            }
            lar.lineAvailability.Reason_code_short_text__c = getShortDesc(lar.lineAvailability.Reason_code_short_text__c,
                                                                          lar.lineAvailability.Directory_Number__c,
                                                                          lar.lineAvailability.Post_Code__c,
                                                                          serviceResult.externalDescription, 
                                                                          lar.lineAvailability.isLLUAvailable__c,
                                                                          lar.lineAvailability.isIPStreamAvailable__c,
                                                                          lar.lineAvailability.reasonCode__c);
            
            lar.lineAvailability.serviceType__c = businessAvailabilityDetails.serviceType;
            lar.lineAvailability.systemActivationDate__c = businessAvailabilityDetails.systemActivationDate;
            lar.lineAvailability.vpContention__c = businessAvailabilityDetails.vpContention;
            
            if(businessAvailabilityDetails.wbc!=null) {
                lar.lineAvailability.wbc_capacity__c = businessAvailabilityDetails.wbc.capacity;
                lar.lineAvailability.wbc_exchState__c = businessAvailabilityDetails.wbc.exchState;
                lar.lineAvailability.wbc_maxRange__c = businessAvailabilityDetails.wbc.maxRange;
                lar.lineAvailability.wbc_minRange__c = businessAvailabilityDetails.wbc.minRange;
                lar.lineAvailability.wbc_rag__c = businessAvailabilityDetails.wbc.rag;
                lar.lineAvailability.wbc_readyDate__c = businessAvailabilityDetails.wbc.readyDate;
                lar.lineAvailability.wbc_speed__c = businessAvailabilityDetails.wbc.speed;          
            }
            lar.lineAvailability.Processed__c = true;
        }
        return lar;
    }
    
    // Parse line availability response for Fixed Line
    public static AvailabilityCheck processResponse(SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType response, AvailabilityCheck lar) {            
        // Init
        double numOfLines = 0;
        CNFlineNumberIsOne = false;
        lar.lineAvailability.Number_Of_Channels__c = 0;
        lar.lineAvailability.Number_Of_Incompatible_Services__c=0;
        lar.lineAvailability.Number_Of_Unsupported_Services__c=0;       
        lar.lineAvailability.Number_of_Auxilary_Lines__c=0;
        lar.lineAvailability.Number_Of_Bearers__c=0;
        
        // Status information
        lar = processStatus(response, lar);             
        SOAViewFixedLineAvailabilityData.installationDetailsType installationDetails = response.installationDetails;
        // response -> installation details     
        if(installationDetails!=null) {          
            // Service Attributes       
            lar = processService (installationDetails, lar);                
            // Site Attributes
            lar = processSite (installationDetails, lar);                                   
            // CNF  (Mapping of matching text found with checkbox field)
            lar = processCNFs(installationDetails.listOfCallingAndNetworkFeature, lar, null);                       
            // Bearer Attributes
            lar = processBearers(installationDetails.listOfBearer, lar);                             
            // MBN Attributes 
            lar = processMBNs(installationDetails.listOfMainBillingNumber, lar);                            
            // Directory Attributes
            lar = processDirectories(installationDetails.listOfDirectoryInfo, lar, null);
            // Order Attributes
            lar = processOrders(installationDetails.listOfPendingOrder, lar);   
            
            // Set VarbyLine__c to "Y" if the line number is 1 and the number of lines (TotLine) is greater than 1          
            if(lar.lineAvailability.Service_Type__c!=null) {
                if(lar.lineAvailability.Service_Type__c.contains('PSTN')) {
                    numOfLines = lar.lineAvailability.Number_Of_Auxilary_Lines__c+1;
                } else if (lar.lineAvailability.Service_Type__c.contains('ISDN2')) {
                    numOfLines = lar.lineAvailability.Number_Of_Channels__c / 2;
                } else if (lar.lineAvailability.Service_Type__c.contains('ISDN 30') || lar.lineAvailability.Service_Type__c.contains('ISDN30')) {
                    numOfLines = lar.lineAvailability.Number_Of_Bearers__c;
                }
            }
            if(numOfLines > 1 && CNFlineNumberIsOne) {
                lar.lineAvailability.VarbyLine__c = true;
            }
        
        }
        return lar;
    }
    
    // Parse line availability response for Fixed Line
    public static AvailabilityCheck processResponse(SOAViewFixedLineAvailabilityData.getInstallationDetails_2Response response, AvailabilityCheck lar) {            
        // Init
        double numOfLines = 0;
        CNFlineNumberIsOne = false;
        lar.lineAvailability.Number_Of_Channels__c = 0;
        lar.lineAvailability.Number_Of_Incompatible_Services__c=0;
        lar.lineAvailability.Number_Of_Unsupported_Services__c=0;       
        lar.lineAvailability.Number_of_Auxilary_Lines__c=0;
        lar.lineAvailability.Number_Of_Bearers__c=0;
        
        // Status information
        lar = processStatus2(response, lar);             
        SOAViewFixedLineAvailabilityData.installationDetailsType2 installationDetails = response.installationDetails;
        // response -> installation details     
        if(installationDetails!=null) {          
            // Service Attributes       
            lar = processService2 (installationDetails, lar);                
            // Site Attributes 
            lar = processSite2 (installationDetails, lar);                                   
            // CNF  (Mapping of matching text found with checkbox field)
            lar = processCNFs(installationDetails.listOfCallingAndNetworkFeature, lar, null);                       
            // Bearer Attributes
            lar = processBearers(installationDetails.listOfBearer, lar);                             
            // MBN Attributes 
            lar = processMBNs(installationDetails.listOfMainBillingNumber, lar);                            
            // Directory Attributes
            lar = processDirectories(installationDetails.listOfDirectoryInfo, lar, null);
            // Order Attributes
            lar = processOrders(installationDetails.listOfPendingOrder, lar);   
            
            // Set VarbyLine__c to "Y" if the line number is 1 and the number of lines (TotLine) is greater than 1          
            if(lar.lineAvailability.Service_Type__c!=null) {
                if(lar.lineAvailability.Service_Type__c.contains('PSTN')) {
                    numOfLines = lar.lineAvailability.Number_Of_Auxilary_Lines__c+1;
                } else if (lar.lineAvailability.Service_Type__c.contains('ISDN2')) {
                    numOfLines = lar.lineAvailability.Number_Of_Channels__c / 2;
                } else if (lar.lineAvailability.Service_Type__c.contains('ISDN 30') || lar.lineAvailability.Service_Type__c.contains('ISDN30')) {
                    numOfLines = lar.lineAvailability.Number_Of_Bearers__c;
                }
            }
            if(numOfLines > 1 && CNFlineNumberIsOne) {
                lar.lineAvailability.VarbyLine__c = true;
            }
        
        }
        return lar;
    }        
  
    private static AvailabilityCheck processStatus2(SOAViewFixedLineAvailabilityData.getInstallationDetails_2Response response, AvailabilityCheck lar) {
        // Status information
        SOACoreData2.ServiceResultType retrievalStatus = response.status;
        lar.lineAvailability.Processed__c = true;
        if(lar.lineAvailability.status_code__c==null) { 
            lar.lineAvailability.status_code__c=retrievalStatus.statusCode;
        } else {
            lar.lineAvailability.status_code__c +=  '; ' + retrievalStatus.statusCode;
        }
        if(lar.lineAvailability.Response__c==null) { 
            lar.lineAvailability.Response__c=retrievalStatus.externalDescription;
        } else {
            lar.lineAvailability.Response__c +=  '; ' + retrievalStatus.externalDescription;
        }           
        if(lar.lineAvailability.External_Description__c==null) { 
            lar.lineAvailability.External_Description__c=retrievalStatus.externalDescription;
        } else {
            lar.lineAvailability.External_Description__c +=  '; ' + retrievalStatus.externalDescription;
        }
        if(lar.lineAvailability.Internal_Description__c==null) { 
            lar.lineAvailability.Internal_Description__c=retrievalStatus.internalDescription;
        } else {
            lar.lineAvailability.Internal_Description__c +=  '; ' + retrievalStatus.internalDescription;
        }                                           
        lar.lineAvailability.put('Resp1CC__c',retrievalStatus.statusCode);
        lar.lineAvailability.put('Resp1Txt__c',retrievalStatus.externalDescription);
        lar.lineAvailability.put('Resp1Sev__c',retrievalStatus.internalDescription);
        return lar;
    }
    
      // Parse line availability response for Fixed Line
    public static AvailabilityCheck processResponse(SOAViewFixedLineAvailabilityData.getLineCharacteristics_1Response response, AvailabilityCheck lar) {            
        System.debug('processResponse: enter');
        // Init
        double numOfLines = 0;
        CNFlineNumberIsOne = false;
        lar.lineAvailability.Number_Of_Channels__c = 0;
        lar.lineAvailability.Number_Of_Incompatible_Services__c=0;
        lar.lineAvailability.Number_Of_Unsupported_Services__c=0;       
        lar.lineAvailability.Number_of_Auxilary_Lines__c=0;
        lar.lineAvailability.Number_Of_Bearers__c=0;
        
        /* new implementation */
        SOAViewFixedLineAvailabilityData.lineCharacteristicsType lineCharacteristics = response.lineCharacteristics;
        System.debug('processResponse: is lineCharacteristics null');
        if(lineCharacteristics != null) {
            System.debug('processResponse: is lineCharacteristics null');
            lar.lineAvailability.aggregatedCapacitance__c = lineCharacteristics.aggregatedCapacitance;
            lar.lineAvailability.aggregatedDPLineLengthEstimate__c = lineCharacteristics.aggregatedDPLineLengthEstimate;
            lar.lineAvailability.aggregatedCircuitLineLengthEstimate__c = lineCharacteristics.aggregatedCircuitLineLengthEstimate;
            // aggregatedCircuitLineLengthCalculated
            lar.lineAvailability.aggregatedCelerityDBLoss__c = lineCharacteristics.aggregatedCelerityDBLoss;
            lar.lineAvailability.aggregatedCalculatedDBLoss__c = lineCharacteristics.aggregatedCalculatedDBLoss;
            // lastMonthlyUpdatedDate
            
            System.debug('processResponse: is mdfSiteList null');
            if(lineCharacteristics.mdfSiteList != null) {
                System.debug('processResponse: is mdfSite empty');
                if(!lineCharacteristics.mdfSiteList.mdfSite.isEmpty()) {
                    System.debug('processResponse: loop coming...');
                    lar.lineAvailability.districtCodeList__c = '';
                    for(SOAViewFixedLineAvailabilityData.mdfSiteType siteType : lineCharacteristics.mdfSiteList.mdfSite) {
                         System.debug('processResponse: loop iteration');
                         lar.lineAvailability.districtCodeList__c += siteType.districtCode + ';'; 
                    }
                }
            }
        }
        System.debug('processResponse: exit');
        return lar;
    }
        
    private static AvailabilityCheck processOrders (SOAViewFixedLineAvailabilityData.listOfPendingOrderType listOfPendingOrderInfo, AvailabilityCheck lar) {
        // Pending Order Info
        if(listOfPendingOrderInfo!=null) {
            
            if(listOfPendingOrderInfo.pendingOrder!=null) {         
                Integer i = 1;
                for(SOAViewFixedLineAvailabilityData.pendingOrderType pendingOrder : listOfPendingOrderInfo.pendingOrder) {
                    if(i>4) {
                        lar.lineAvailability.MoreOrds__c=true;
                        break;
                    }                       
                    lar.lineAvailability.put('O'+i+'PenOrdTyp__c',pendingOrder.pendingOrderType);
                    lar.lineAvailability.put('O'+i+'3rdPty__c',pendingOrder.isThirdParty);
                    lar.lineAvailability.put('O'+i+'CompDTM__c',pendingOrder.completedDate);
                    i++;
                }
                lar.lineAvailability.TotOrds__c = listOfPendingOrderInfo.pendingOrder.size();
            }
        }   
        return lar;
    }       

    private static AvailabilityCheck processDirectories(SOAViewFixedLineAvailabilityData.listOfDirectoryInfoType listOfDirectoryInfo, AvailabilityCheck lar, AvailabilityCheck.MBN mbn) {
        // Directory information
        if(listOfDirectoryInfo!=null) {
            if(listOfDirectoryInfo.directory!=null) {
                for(SOAViewFixedLineAvailabilityData.directoryType directory : listOfDirectoryInfo.directory) {
                    Line_Availability_Directory__c dirObj = new Line_Availability_Directory__c();   
                    dirObj.Name = directory.directoryEntryLine;
                    dirObj.DirLine__c = directory.directoryEntryLine;
                    dirObj.DirTitle__c = directory.directoryTitle;
                    dirObj.DirSName__c = directory.tradingTitleSurname;
                    dirObj.DirBusNam__c = directory.businessName;
                    dirObj.DirBusDesc__c = directory.businessDescription;
                    dirObj.DirInitial__c = directory.initial;
                    dirObj.DirType__c = directory.directoryEntryType;
                    dirObj.DirList__c = directory.directoryEntryListing;
                    dirObj.DirDrMed__c = directory.doctorOfMedicine;
                    dirObj.DirPartAdd__c = directory.partialAddressRequired;
                    dirObj.DirGroup__c = directory.groupListingRequired;
                    dirObj.DirNonInst__c = directory.listNonInstallationAddress;
                    dirObj.DirFaxMin__c = directory.faxMinicom;
                    if(mbn!=null) { 
                        mbn.directories.add(dirObj);
                    } else {
                        lar.directories.add(dirObj);    
                    }                   
                }
            }
        }
        return lar;
    }
         
    private static AvailabilityCheck processStatus(SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType response, AvailabilityCheck lar) {
        // Status information
        Integer i = 1;
        for (SOACoreData2.ServiceResultType retrievalStatus : response.retrievalStatus) {
            lar.lineAvailability.Processed__c = true;
            if(lar.lineAvailability.status_code__c==null) { 
                lar.lineAvailability.status_code__c=retrievalStatus.statusCode;
            } else {
                lar.lineAvailability.status_code__c +=  '; ' + retrievalStatus.statusCode;
            }
            if(lar.lineAvailability.Response__c==null) { 
                lar.lineAvailability.Response__c=retrievalStatus.externalDescription;
            } else {
                lar.lineAvailability.Response__c +=  '; ' + retrievalStatus.externalDescription;
            }           
            if(lar.lineAvailability.External_Description__c==null) { 
                lar.lineAvailability.External_Description__c=retrievalStatus.externalDescription;
            } else {
                lar.lineAvailability.External_Description__c +=  '; ' + retrievalStatus.externalDescription;
            }
            if(lar.lineAvailability.Internal_Description__c==null) { 
                lar.lineAvailability.Internal_Description__c=retrievalStatus.internalDescription;
            } else {
                lar.lineAvailability.Internal_Description__c +=  '; ' + retrievalStatus.internalDescription;
            }                       
            if(i>4) { 
                lar.lineAvailability.MoreResps__c=true;
                break;
            }                       
            lar.lineAvailability.put('Resp'+i+'CC__c',retrievalStatus.statusCode);
            lar.lineAvailability.put('Resp'+i+'Txt__c',retrievalStatus.externalDescription);
            lar.lineAvailability.put('Resp'+i+'Sev__c',retrievalStatus.internalDescription);
            i++;            
        }   
        return lar;
    }
     
    private static AvailabilityCheck processService(SOAViewFixedLineAvailabilityData.installationDetailsType installationDetails, AvailabilityCheck lar) {
        // Service Attributes        
        lar.lineAvailability.Service_Type__c = installationDetails.serviceType;
        lar.lineAvailability.ServID__c = installationDetails.serviceId;
        lar.lineAvailability.NRA__c = installationDetails.numberRetentionAllowed;
        lar.lineAvailability.InstType__c = installationDetails.installationType;
        lar.lineAvailability.SMC__c = installationDetails.smcContactRequired;
        lar.lineAvailability.Owner__c = installationDetails.ownershipConfirmation;
        lar.lineAvailability.CCSDB__c = installationDetails.cssDatabaseCode;
        lar.lineAvailability.SDC__c = installationDetails.districtCode;
        lar.lineAvailability.Exchange__c = installationDetails.exchangeGroupCode;
        lar.lineAvailability.ExchType__c = installationDetails.cssExchangeType; 
        lar.lineAvailability.Debt__c = installationDetails.debtManagementIndicator;
        lar.lineAvailability.BusCont__c = installationDetails.businessContinuityFlag;
        lar.lineAvailability.AuxQty__c = installationDetails.auxilaryLineQuantity;
        lar.lineAvailability.Narrowband_Service_Indicator__c = installationDetails.narrowbandServicesIndicator;
        lar.lineAvailability.Line_Type__c = installationDetails.lineType;
        lar.lineAvailability.PayphType__c = installationDetails.payphoneType;
        lar.lineAvailability.CareLvl__c = installationDetails.careLevel;
        lar.lineAvailability.TempStruc__c = installationDetails.tempStructure;
        lar.lineAvailability.CPSP__c = installationDetails.carrierPreSelectPresent;
        lar.lineAvailability.Carrier_Pre_Select__c = installationDetails.carrierPreSelectPresent;
        lar.lineAvailability.TermType__c = installationDetails.terminationType;
        lar.lineAvailability.Standby__c = installationDetails.standByPowerRequired;
        lar.lineAvailability.AccessTyp__c = installationDetails.accessTypeConfiguration;        
        // Totals
        lar.lineAvailability.Number_of_Auxilary_Lines__c = installationDetails.auxilaryLineQuantity;
        return lar; 
    }
    
    private static AvailabilityCheck processService2(SOAViewFixedLineAvailabilityData.installationDetailsType2 installationDetails, AvailabilityCheck lar) {
        // Service Attributes        
        lar.lineAvailability.Service_Type__c = installationDetails.serviceType;
        lar.lineAvailability.ServID__c = installationDetails.serviceId;
        lar.lineAvailability.NRA__c = installationDetails.numberRetentionAllowed;
        lar.lineAvailability.InstType__c = installationDetails.installationType; 
        lar.lineAvailability.SMC__c = installationDetails.smcContactRequired;
        lar.lineAvailability.Owner__c = installationDetails.ownershipConfirmation;
        lar.lineAvailability.CCSDB__c = installationDetails.cssDatabaseCode;
        lar.lineAvailability.SDC__c = installationDetails.districtCode;
        lar.lineAvailability.Exchange__c = installationDetails.exchangeGroupCode;
        lar.lineAvailability.ExchType__c = installationDetails.cssExchangeType; 
        lar.lineAvailability.Debt__c = installationDetails.debtManagementIndicator;
        lar.lineAvailability.BusCont__c = installationDetails.businessContinuityFlag;
        lar.lineAvailability.AuxQty__c = installationDetails.auxiliaryLineQuantity;
        lar.lineAvailability.Narrowband_Service_Indicator__c = installationDetails.narrowbandServicesIndicator;
        lar.lineAvailability.Line_Type__c = installationDetails.lineType;
        lar.lineAvailability.PayphType__c = installationDetails.payphoneType;
        lar.lineAvailability.CareLvl__c = installationDetails.careLevel;
        lar.lineAvailability.TempStruc__c = installationDetails.tempStructure;
        lar.lineAvailability.CPSP__c = installationDetails.carrierPreSelectPresent;
        lar.lineAvailability.Carrier_Pre_Select__c = installationDetails.carrierPreSelectPresent;
        lar.lineAvailability.TermType__c = installationDetails.terminationType;
        lar.lineAvailability.Standby__c = installationDetails.standByPowerRequired;
        lar.lineAvailability.AccessTyp__c = installationDetails.accessTypeConfiguration;        
        // Totals
        lar.lineAvailability.Number_of_Auxilary_Lines__c = installationDetails.auxiliaryLineQuantity;
        return lar; 
    }    
    
    private static AvailabilityCheck processSite(SOAViewFixedLineAvailabilityData.installationDetailsType installationDetails, AvailabilityCheck lar) {
        if(installationDetails.address!=null) {
            if(installationDetails.address.addressReference!=null) {
                lar.lineAvailability.ALK__c = installationDetails.address.addressReference.addressKey;
                lar.lineAvailability.ADC__c = installationDetails.address.addressReference.districtCode;                    
            }
            if (installationDetails.address.britishAddress != null) {
                lar.lineAvailability.company_name__c = installationDetails.address.britishAddress.organisationName;
            }               
        }
        if(installationDetails.site!=null) {
            if(installationDetails.site.location!=null) {
                lar.lineAvailability.Floor__c = installationDetails.site.location.floor;
                lar.lineAvailability.Room__c = installationDetails.site.location.room;
                lar.lineAvailability.Pos__c = installationDetails.site.location.position;
            }
        }   
        return lar; 
    }

    private static AvailabilityCheck processSite2(SOAViewFixedLineAvailabilityData.installationDetailsType2 installationDetails, AvailabilityCheck lar) {
        if(installationDetails.address!=null) {
            if(installationDetails.address.addressReference!=null) {
                lar.lineAvailability.ALK__c = installationDetails.address.addressReference.addressKey;
                lar.lineAvailability.ADC__c = installationDetails.address.addressReference.districtCode;                    
            }
            if (installationDetails.address.britishAddress != null) {
                lar.lineAvailability.company_name__c = installationDetails.address.britishAddress.organisationName;
            }               
        }
        if(installationDetails.location!=null) {
            lar.lineAvailability.Floor__c = installationDetails.location.floor;
            lar.lineAvailability.Room__c = installationDetails.location.room;
            lar.lineAvailability.Pos__c = installationDetails.location.position;
        }
    return lar; 
    }

    private static AvailabilityCheck processCNFs(SOAViewFixedLineAvailabilityData.listOfCNFType listOfCallingAndNetworkFeature, AvailabilityCheck lar, AvailabilityCheck.MBN mbn) {
        Line_Availability__c lineAvailabilityRequest = lar.lineAvailability;
        // response -> installation datails ->list of CNF
        if (listOfCallingAndNetworkFeature != null) {
            // response -> installation datails ->list of CNF
            boolean varByLine = false;
            if(listOfCallingAndNetworkFeature.callingAndNetworkFeature !=null) {
                for(SOAViewFixedLineAvailabilityData.cnfType cnf: listOfCallingAndNetworkFeature.callingAndNetworkFeature) {                        
                    if (lar.lineAvailability.Features__c == null) {
                        lar.lineAvailability.Features__c = cnf.callingNetworkFeatureName;
                    } else {
                        lar.lineAvailability.Features__c += '; '+cnf.callingNetworkFeatureName; 
                    }                   
                    lar = setCheckBox(PREFIX_CNF + cnf.callingNetworkFeatureName,lar);
                    // CNF Object Population
                    // Set to "Y" if, for any occurrence of a CNF, the  line number (cnfType.lineNumber) is any value other than 0 or 1
                    if(cnf.lineNumber!=null && (cnf.lineNumber!='0' && cnf.lineNumber!='1')) {
                        varByLine = true;
                    }
                    if(cnf.lineNumber=='1') {
                        CNFlineNumberIsOne = true;
                    }
                    
                    Line_Availability_CNF__c cnfObj = new Line_Availability_CNF__c();                   
                    cnfObj.Line_Availability__r = lineAvailabilityRequest;
                    cnfObj.CNFPIN__c = cnf.callingNetworkFeaturePin;
                    cnfObj.FeatCLI__c = cnf.featureCLI;
                    cnfObj.FromCLI__c = cnf.fromCLI;
                    cnfObj.ToCLI__c = cnf.toCLI;
                    cnfObj.Name__c = cnf.callingNetworkFeatureName;
                    if(cnf.callingNetworkFeatureName!=null && cnf.callingNetworkFeatureName.length()>80) {
                        cnfObj.Name = cnf.callingNetworkFeatureName.substring(0,80);
                    } else {
                        cnfObj.Name = cnf.callingNetworkFeatureName;
                    }
                    cnfObj.LineNum__c = cnf.lineNumber;
                    cnfObj.CRType__c = cnf.callerRedirectionType; 
                    if(mbn!=null) {
                        mbn.callingAndNetworkFeatures.add(cnfObj);
                    } else {
                        lar.callingAndNetworkFeatures.add(cnfObj);  
                    }               
                }
                lar.lineAvailability.VarbyLine__c = varByLine;
                
            }
            // response -> installation datails ->list of CNF -> list of unsupported services
            if (listOfCallingAndNetworkFeature.listOfUnsupportedService != null) {                  
                lar = processServices(PREFIX_UNSUPPORTED, listOfCallingAndNetworkFeature.listOfUnsupportedService.service, lar, mbn);
                if(listOfCallingAndNetworkFeature.listOfUnsupportedService.service!=null) {
                    lineAvailabilityRequest.Number_Of_Unsupported_Services__c+=listOfCallingAndNetworkFeature.listOfUnsupportedService.service.size();
                    system.debug('ntj: unsupported services ='+lineAvailabilityRequest.Number_Of_Unsupported_Services__c);
                }
            }
            // response -> installation datails ->list of CNF -> list of incompatible services
            if (listOfCallingAndNetworkFeature.listOfIncompatibleService != null) {
                lar = processServices(PREFIX_INCOMPATIBLE, listOfCallingAndNetworkFeature.listOfIncompatibleService.service, lar, mbn);
                if(listOfCallingAndNetworkFeature.listOfIncompatibleService.service!=null) {
                    lar.lineAvailability.Number_Of_Incompatible_Services__c+=listOfCallingAndNetworkFeature.listOfIncompatibleService.service.size();
                    system.debug('ntj: incompatible services ='+lar.lineAvailability.Number_Of_Incompatible_Services__c);
                 }
            }
            
        }
        return lar;
    }


         
    private static AvailabilityCheck processBearers(SOAViewFixedLineAvailabilityData.listOfBearerType listOfBearer, AvailabilityCheck lar) {
        // List of bearers
        // Used to calculate the number of unique bearer ids
        Set<String> bearerIds = new Set<String>();
        if (listOfBearer != null) { 
            if (listOfBearer.bearer != null) {
                for (SOAViewFixedLineAvailabilityData.bearerType bearer : listOfBearer.bearer) {
                    bearerIds.add(bearer.bearerId); 
                    Line_Availability_Bearer__c laBearer = new Line_Availability_Bearer__c();
                    laBearer.Name = bearer.bearerId;
                    laBearer.BearerSequenceNumber__c = bearer.bearerSequenceNumber;
                    laBearer.NumChan__c = bearer.listOfChannel.numberOfChannels;
                    AvailabilityCheck.Bearer br = new AvailabilityCheck.Bearer(laBearer);
                    lar.bearers.add(br);
                    // List of channels
                    lar = processChannels(bearer.listOfChannel, lar, null, br);
                }
            }
            lar.lineAvailability.Number_Of_Bearers__c += listOfBearer.bearer.size();
        }               
        return lar;
    } 
        
        
    private static AvailabilityCheck processMBNs(SOAViewFixedLineAvailabilityData.listOfMainBillingNumberType listOfMainBillingNumber, AvailabilityCheck lar) {
        if (listOfMainBillingNumber != null) {
            for (SOAViewFixedLineAvailabilityData.mainBillingNumberType mainBillingNumber : listOfMainBillingNumber.mainBillingNumber) {
                if (lar.lineAvailability.Billing_Numbers__c == null) {
                    lar.lineAvailability.Billing_Numbers__c = mainBillingNumber.mainBillingNumberCLI;
                } else {
                    lar.lineAvailability.Billing_Numbers__c += '; '+mainBillingNumber.mainBillingNumberCLI;
                }      
                
                Line_Availability_Main_Billing_Number__c mbnObj = new Line_Availability_Main_Billing_Number__c();
                mbnObj.Name = mainBillingNumber.mainBillingNumberSequenceNumber;
                mbnObj.MBNSeq__c = mainBillingNumber.mainBillingNumberSequenceNumber;
                mbnObj.MBNNRA__c = mainBillingNumber.numberRetentionAllowed;
                mbnObj.MBNCLI__c = mainBillingNumber.mainBillingNumberCLI;
                mbnObj.MBNRef__c = mainBillingNumber.mainBillingNumberReference;
                mbnObj.MBNDebt__c = mainBillingNumber.mainBillingNumberDetails.debtManagementIndicator;
                mbnObj.MBNCPS__c = mainBillingNumber.mainBillingNumberDetails.carrierPreSelectPresent;
                if(mainBillingNumber.mainBillingNumberDetails.listOfMultiSubscriberNumber!=null) {
                    mbnObj.NumMSNs__c = mainBillingNumber.mainBillingNumberDetails.listOfMultiSubscriberNumber.numberOfMultiSubscriberNumbers;
                    mbnObj.MSNRA__c = mainBillingNumber.mainBillingNumberDetails.listOfMultiSubscriberNumber.numberRetentionAllowed;
                }
                if(mainBillingNumber.mainBillingNumberDetails.listOfDirectDialInRange!=null) {
                mbnObj.NumDDIR__c = mainBillingNumber.mainBillingNumberDetails.listOfDirectDialInRange.numberOfDirectDialInRanges;
                mbnObj.DDIRNRA__c = mainBillingNumber.mainBillingNumberDetails.listOfDirectDialInRange.numberRetentionAllowed;
                }
                if(mainBillingNumber.mainBillingNumberDetails.listOfSingleNumberDirectDialIn!=null) {
                    mbnObj.NumSNDDIs__c = mainBillingNumber.mainBillingNumberDetails.listOfSingleNumberDirectDialIn.numberOfSNDDIs;
                    mbnObj.SNDDINRA__c = mainBillingNumber.mainBillingNumberDetails.listOfSingleNumberDirectDialIn.numberRetentionAllowed;
                }
                AvailabilityCheck.MBN mbn = new AvailabilityCheck.MBN(mbnObj);
                                        
                SOAViewFixedLineAvailabilityData.mainBillingNumberDetailsType mainBillingNumberDetails = mainBillingNumber.mainBillingNumberDetails;
           
                if (mainBillingNumberDetails != null) {               
                    // DDI Ranges
                    lar = processDDIRanges(mainBillingNumberDetails.listOfDirectDialInRange, lar, mbn, null);
                    // Single DDIs
                    lar = processSNDDIs(mainBillingNumberDetails.listOfSingleNumberDirectDialIn, lar, mbn);
                    // Calling and network features (ISDN2 and ISDN30)                  
                    lar = processCNFs(mainBillingNumberDetails.listOfCallingAndNetworkFeature, lar, mbn);   
                    // List of channels
                    lar = processChannels(mainBillingNumberDetails.listOfChannel, lar, mbn, null);                    
                    // Directory Attributes
                    lar = processDirectories(mainBillingNumberDetails.listOfDirectoryInfo, lar, mbn);
                    // Multi Subscription Numbers
                    lar = processMSNs(mainBillingNumberDetails.listOfMultiSubscriberNumber, lar, mbn);
                }
                lar.mbns.add(mbn);                              
            }
        }   
        return lar;
    }
    
    private static AvailabilityCheck processMSNs(SOAViewFixedLineAvailabilityData.listOfMSNType listOfMSN, AvailabilityCheck lar, AvailabilityCheck.MBN mbn) {
        if(lar.lineAvailability.TotMSN__c==null) 
            lar.lineAvailability.TotMSN__c=0;
        if(listOfMSN!=null) {
            if(listOfMSN.numberOfMultiSubscriberNumbers!=null) 
                lar.lineAvailability.TotMSN__c += AvailabilityCheckUtils.toInteger(listOfMSN.numberOfMultiSubscriberNumbers);
            for (SOAViewFixedLineAvailabilityData.msnType msn : listOfMSN.multiSubscriberNumber) {
                if(msn!=null) {
                    Line_Availability_MultSubNum__c laMSN = new Line_Availability_MultSubNum__c();
                    laMSN.name = msn.msnNumberSequenceNumber;
                    laMSN.MSNSeq__c  = msn.msnNumberSequenceNumber;
                    laMSN.msnNumber__c = msn.msnNumber;
                    mbn.multisubnums.add(laMSN); 
                }
            }
        }
        return lar;
    }
    
    private static AvailabilityCheck processSNDDIs (SOAViewFixedLineAvailabilityData.listOfSNDDIType listOfSingleNumberDirectDialIn, AvailabilityCheck lar, AvailabilityCheck.MBN mbn) {
        if (listOfSingleNumberDirectDialIn != null) {
            if(lar.lineAvailability.TotSNDDI__c==null) lar.lineAvailability.TotSNDDI__c=0;
            if(listOfSingleNumberDirectDialIn.numberOfSNDDIs!=null) lar.lineAvailability.TotSNDDI__c += AvailabilityCheckUtils.toInteger(listOfSingleNumberDirectDialIn.numberOfSNDDIs);
            
            if (listOfSingleNumberDirectDialIn.singleNumberDirectDialIn != null) {
                for (SOAViewFixedLineAvailabilityData.snddiType singleDDI : listOfSingleNumberDirectDialIn.singleNumberDirectDialIn) {
                    if (lar.lineAvailability.Single_DDIs__c == null) {
                        lar.lineAvailability.Single_DDIs__c = singleDDI.snddiCLI;
                    } else {
                        lar.lineAvailability.Single_DDIs__c += '; '+ singleDDI.snddiCLI;
                    }
                    Line_Availability_SNDDI__c laSNDDI = new Line_Availability_SNDDI__c();
                    laSNDDI.Name = singleDDI.snddiCLISequenceNumber;
                    laSNDDI.SNDDISeq__c = singleDDI.snddiCLISequenceNumber;
                    laSNDDI.SNDDICLI__c = singleDDI.snddiCLI;                   
                    mbn.snddis.add(laSNDDI); 
                }
            }
        }   
        return lar;
    } 
    
             
    private static AvailabilityCheck processChannels(SOAViewFixedLineAvailabilityData.listOfChannelType listOfChannelType, AvailabilityCheck lar, AvailabilityCheck.MBN mbn, AvailabilityCheck.Bearer bearer) {
        // List of channels
        if (listOfChannelType != null) {
            try {
                if (lar.lineAvailability.Number_Of_Channels__c == null) lar.lineAvailability.Number_Of_Channels__c = 0;             
                if (listOfChannelType.numberOfChannels!=null) lar.lineAvailability.Number_Of_Channels__c += AvailabilityCheckUtils.toInteger(listOfChannelType.numberOfChannels);
            } catch (Exception e) {             }
            if (listOfChannelType.channel != null) {
                for (SOAViewFixedLineAvailabilityData.ChannelType channel : listOfChannelType.channel) {
                    Line_Availability_Channel__c channelObj = new Line_Availability_Channel__c();
                    channelObj.Name = channel.channelNumber;
                    channelObj.ChanNum__c = channel.channelNumber; 
                    channelObj.Stroke__c = channel.strokeNumber;
                    channelObj.Direction__c = channel.direction; 
                    if(channel.listOfDirectDialInRange!=null) {
                        channelObj.NumDDIR__c = channel.listOfDirectDialInRange.numberOfDirectDialInRanges; 
                        channelObj.DDIRNRA__c = channel.listOfDirectDialInRange.numberRetentionAllowed;
                    }
                    AvailabilityCheck.Channel laChannel = new AvailabilityCheck.Channel(channelObj);
                    if(mbn!=null) mbn.channels.add(laChannel);
                    if(bearer!=null) bearer.channels.add(laChannel);
                    lar = processDDIRanges(channel.listOfDirectDialInRange, lar, null, laChannel);
                }
            }           
        }
        return lar;
    } 
      
    private static AvailabilityCheck processDDIRanges(SOAViewFixedLineAvailabilityData.listOfDDIRangeType listOfDirectDialInRange, AvailabilityCheck lar, AvailabilityCheck.MBN mbn, AvailabilityCheck.Channel channel) {
        // List of DDI Ranges       
        if (listOfDirectDialInRange != null) {
            if(lar.lineAvailability.TotDDIR__c==null) 
                lar.lineAvailability.TotDDIR__c = 0;
            if(listOfDirectDialInRange.numberOfDirectDialInRanges!=null) 
                lar.lineAvailability.TotDDIR__c += AvailabilityCheckUtils.toInteger(listOfDirectDialInRange.numberOfDirectDialInRanges);         
            if (listOfDirectDialInRange.directDialInRange != null) {                
                for (SOAViewFixedLineAvailabilityData.ddiRangeType ddiRange : listOfDirectDialInRange.directDialInRange) {
                    if(lar.lineAvailability.TotDDI__c==null) 
                        lar.lineAvailability.TotDDI__c=0;
                    if(ddiRange!=null) {
                        if(ddiRange.numberOfDirectDialIns!=null) 
                            lar.lineAvailability.TotDDI__c += AvailabilityCheckUtils.toInteger(ddiRange.numberOfDirectDialIns);
                        if(ddiRange.rangeFrom!=null || ddiRange.rangeTo!=null) {
                            if (lar.lineAvailability.DDI_Ranges__c == null) {
                                lar.lineAvailability.DDI_Ranges__c = ddiRange.rangeFrom+' - '+ ddiRange.rangeTo;
                            } else {
                                lar.lineAvailability.DDI_Ranges__c += '; '+ ddiRange.rangeFrom+' - '+ ddiRange.rangeTo;
                            }
                        }
                        Line_Availability_DDI_Range__c laDDI = new Line_Availability_DDI_Range__c();
                        laDDI.name = ddiRange.rangeSequenceNumber;
                        laDDI.DDIRSeq__c = ddiRange.rangeSequenceNumber;
                        laDDI.NumDDIs__c = ddiRange.numberOfDirectDialIns;
                        laDDI.DDIFrom__c = ddiRange.rangeFrom;  
                        laDDI.DDITo__c = ddiRange.rangeTo;
    
                        if(mbn!=null) mbn.ddiRanges.add(laDDI);
                        if(channel!=null) channel.ddiRanges.add(laDDI);
                    }
                }
            }
        }       
        return lar;
    }
    
    // Process the unsupported / incompatible service checkbox options
    private static AvailabilityCheck processServices(String prefix, SOAViewFixedLineAvailabilityData.serviceType[] services, AvailabilityCheck lar, AvailabilityCheck.MBN mbn) {
        if (services != null) {     
            for (SOAViewFixedLineAvailabilityData.serviceType service : services) {
                if(service!=null) {
                    lar = setCheckBox(prefix + service.serviceName,lar);
                    Line_Availability_Unsupported_Feature__c unsObj = new Line_Availability_Unsupported_Feature__c();
                    unsObj.Name__c = service.serviceName;
                    if(service.serviceName.length()>80) {
                        unsObj.Name = service.serviceName.substring(0,80);
                    } else {
                        unsObj.Name = service.serviceName;
                    }
                    unsObj.UnsupportedIncompatible__c = prefix.substring(1).toUpperCase();
    
                    if(mbn!=null) {
                        mbn.unsupportedFeatures.add(unsObj);
                    } else {
                        lar.unsupportedFeatures.add(unsObj);    
                    }
                    
                    if(prefix==PREFIX_UNSUPPORTED) {
                        if (lar.lineAvailability.Unsupported_Services__c == null) {
                            lar.lineAvailability.Unsupported_Services__c = service.serviceName;
                        } else {
                            lar.lineAvailability.Unsupported_Services__c += '; '+service.serviceName; 
                        }   
                    } else if(prefix==PREFIX_INCOMPATIBLE) {
                        if (lar.lineAvailability.Incompatible_Services__c == null) {
                            lar.lineAvailability.Incompatible_Services__c = service.serviceName;
                        } else {
                            lar.lineAvailability.Incompatible_Services__c += '; '+service.serviceName; 
                        }                       
                    }                   
                }
                                
            }   
        }   
        return lar;
     }       
     
     // Set a check box when a matching value is found in a lookup setting
     private static AvailabilityCheck setCheckBox(String xmlValue, AvailabilityCheck lar) {
        String fieldName = null;
        if(xmlValue!=null) {
            fieldName = getFieldName(xmlValue); 
            if(fieldName!=null) {
                // Set field using dyanmic DML
                lar.lineAvailability.put(fieldName,true);   
            } else {
                lar.lineAvailability.CNFNotSpec__c = true;
            }
        }
        return lar;     
     }
    
    // Lookup the field name for a matching xml value
    private static String getFieldName (String xmlValue) {
        String fieldName = null;
        List<LineAvailabilityTransformationMap__c> latms;
        if(XMLTextToFieldMap==null) {
            latms = LineAvailabilityTransformationMap__c.getall().values();
            XMLTextToFieldMap = new Map <String,String>();
            for(LineAvailabilityTransformationMap__c latm: latms) {
                XMLTextToFieldMap.put(latm.full_name__c, latm.field_name__c);
            }       
        }
        fieldName = XMLTextToFieldMap.get(xmlValue);
        return fieldName;    
     }
     
    // Manually construct a response message used in test methods
    public SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType getResponseForTestMethods(Line_Availability__c lineAvailabilityRequest) {
        
        boolean unsupportedAttributes = true;
        if(lineAvailabilityRequest.Directory_Number__c=='1111111111') unsupportedAttributes = false;
        
        SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType response;
        
        response = new SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType();
        SOACoreData2.ServiceResultType retrievalStatus = new SOACoreData2.ServiceResultType();
        retrievalStatus.StatusCode = '2000';
        retrievalStatus.ExternalDescription = 'External Description';
        retrievalStatus.InternalDescription = 'Internal Description';
        response.retrievalStatus = new List<SOACoreData2.ServiceResultType>();
        response.retrievalStatus.add(retrievalStatus);
                
        SOAViewFixedLineAvailabilityData.installationDetailsType installationDetails = new SOAViewFixedLineAvailabilityData.installationDetailsType();
        installationDetails.lineType = 'Test';
        installationDetails.serviceType = 'PSTN';
        installationDetails.auxilaryLineQuantity = 1;
        installationDetails.carrierPreSelectPresent = '';
        installationDetails.accessTypeConfiguration = '';
        
        // Address container
        SOAViewFixedLineAvailabilityData.addressReferenceType addressRef = new SOAViewFixedLineAvailabilityData.addressReferenceType();
        addressRef.addressKey='1';
        addressRef.districtCode='1';
        SOAViewFixedLineAvailabilityData.britishAddressType addressBR = new SOAViewFixedLineAvailabilityData.britishAddressType();
        addressBR.organisationName = 'TestCompany';
        
        SOAViewFixedLineAvailabilityData.addressType address = new SOAViewFixedLineAvailabilityData.addressType();
        address.addressReference = addressRef;
        address.britishAddress = addressBR;
        
        installationDetails.address = address;
        
        // Site
        SOAViewFixedLineAvailabilityData.siteType site = new SOAViewFixedLineAvailabilityData.siteType();
        SOAViewFixedLineAvailabilityData.locationType location = new SOAViewFixedLineAvailabilityData.locationType();
        location.floor = '1';
        location.room = '2';
        location.position = '1';
        site.location = location;
        installationDetails.site = site;
        

        // CNFs
        SOAViewFixedLineAvailabilityData.listOfCNFType listOfCallingAndNetworkFeature = new SOAViewFixedLineAvailabilityData.listOfCNFType();
        List<SOAViewFixedLineAvailabilityData.cnfType> callingAndNetworkFeatureList = new List<SOAViewFixedLineAvailabilityData.cnfType>();
        //feature.
        SOAViewFixedLineAvailabilityData.cnfType feature = new SOAViewFixedLineAvailabilityData.cnfType();        
        feature.callingNetworkFeatureName = 'Test Feature';
        SOAViewFixedLineAvailabilityData.cnfType feature2 = new SOAViewFixedLineAvailabilityData.cnfType();        
        feature2.callingNetworkFeatureName = 'Anonymous Call Reject';        
        // service
        SOAViewFixedLineAvailabilityData.serviceType service = null;
        if(unsupportedAttributes) {
            service = new SOAViewFixedLineAvailabilityData.serviceType();
            service.serviceName = 'x';
        } 
        
        listOfCallingAndNetworkFeature.callingAndNetworkFeature = new List<SOAViewFixedLineAvailabilityData.cnfType>();
        //listOfCallingAndNetworkFeature.callingAndNetworkFeature.add(feature);
        
        if(unsupportedAttributes) {
            listOfCallingAndNetworkFeature.listOfUnsupportedService = new SOAViewFixedLineAvailabilityData.listOfUnsupportedServiceType();
            listOfCallingAndNetworkFeature.listOfUnsupportedService.service = new List<SOAViewFixedLineAvailabilityData.serviceType>();
            listOfCallingAndNetworkFeature.listOfUnsupportedService.service.add(service);
            listOfCallingAndNetworkFeature.listOfIncompatibleService = new SOAViewFixedLineAvailabilityData.listOfIncompatibleServiceType();
            listOfCallingAndNetworkFeature.listOfIncompatibleService.service = new List<SOAViewFixedLineAvailabilityData.serviceType>();    
            listOfCallingAndNetworkFeature.listOfIncompatibleService.service.add(service);
        }
        
        listOfCallingAndNetworkFeature.callingAndNetworkFeature.add(feature);
        listOfCallingAndNetworkFeature.callingAndNetworkFeature.add(feature2);
        installationDetails.listOfCallingAndNetworkFeature = listOfCallingAndNetworkFeature;

        // DDI range
        SOAViewFixedLineAvailabilityData.ddiRangeType ddiRange = new SOAViewFixedLineAvailabilityData.ddiRangeType();
        ddiRange.rangeFrom = '11111111';
        ddiRange.rangeTo = '22222222';
        ddiRange.rangeSequenceNumber = '1';
        ddiRange.numberOfDirectDialIns = '1';

        // Channel
        SOAViewFixedLineAvailabilityData.channelType channel = new SOAViewFixedLineAvailabilityData.channelType();
        channel.channelNumber = '1';
        channel.direction = 'x';
        channel.bearerSequenceNumber = '1';
        channel.strokeNumber = '1';
        channel.listOfDirectDialInRange = new SOAViewFixedLineAvailabilityData.listOfDDIRangeType();
        channel.listOfDirectDialInRange.numberOfDirectDialInRanges='1';
        channel.listOfDirectDialInRange.numberRetentionAllowed='Y';
        channel.listOfDirectDialInRange.directDialInRange = new List<SOAViewFixedLineAvailabilityData.ddiRangeType>();
        channel.listOfDirectDialInRange.directDialInRange.add(ddiRange);
     
        // SNDDI
        SOAViewFixedLineAvailabilityData.snddiType snddi = new SOAViewFixedLineAvailabilityData.snddiType();
        snddi.snddiCLI='1';
        snddi.snddiCLISequenceNumber='1';
        
        // MSN
        SOAViewFixedLineAvailabilityData.msnType msn = new SOAViewFixedLineAvailabilityData.msnType();
        msn.msnNumber='1';
        msn.msnNumberSequenceNumber='1';
        
        // Directory
        SOAViewFixedLineAvailabilityData.directoryType directory = new SOAViewFixedLineAvailabilityData.directoryType();
        directory.businessDescription='1';
        directory.businessName='1';
        directory.directoryEntryLine='1';
        directory.directoryEntryListing='1';
        directory.directoryEntryType='1';
        installationDetails.listOfDirectoryInfo = new SOAViewFixedLineAvailabilityData.listOfDirectoryInfoType();
        installationDetails.listOfDirectoryInfo.directory = new List<SOAViewFixedLineAvailabilityData.directoryType>();
        installationDetails.listOfDirectoryInfo.directory.add(directory);
                
        // Bearer
        SOAViewFixedLineAvailabilityData.bearerType bearer = new SOAViewFixedLineAvailabilityData.bearerType();
        bearer.bearerSequenceNumber = '1';
        bearer.bearerId = '1';
        bearer.listOfChannel = new SOAViewFixedLineAvailabilityData.listOfChannelType();
        bearer.listOfChannel.numberOfChannels='1';
        bearer.listOfChannel.channel = new List<SOAViewFixedLineAvailabilityData.channelType>();
        bearer.listOfChannel.channel.add(channel);
        installationDetails.listOfBearer = new SOAViewFixedLineAvailabilityData.listOfBearerType();
        installationDetails.listOfBearer.bearer = new List<SOAViewFixedLineAvailabilityData.bearerType>();
        installationDetails.listOfBearer.bearer.add(bearer);
                
        // Main Billing Address
        SOAViewFixedLineAvailabilityData.mainBillingNumberType mbn = new SOAViewFixedLineAvailabilityData.mainBillingNumberType();
        mbn.mainBillingNumberCLI='11111111';
        mbn.numberRetentionAllowed='Y';
        mbn.mainBillingNumberReference='1111';
        mbn.mainBillingNumberSequenceNumber='11111';
        mbn.mainBillingNumberDetails = new SOAViewFixedLineAvailabilityData.mainBillingNumberDetailsType();
        mbn.mainBillingNumberDetails.carrierPreSelectPresent='Y';
        mbn.mainBillingNumberDetails.debtManagementIndicator='Y';
        mbn.mainBillingNumberDetails.listOfChannel = new SOAViewFixedLineAvailabilityData.listOfChannelType();
        mbn.mainBillingNumberDetails.listOfChannel.numberOfChannels='1';
        mbn.mainBillingNumberDetails.listOfChannel.channel = new List<SOAViewFixedLineAvailabilityData.channelType>();
        mbn.mainBillingNumberDetails.listOfChannel.channel.add(channel);
        
        mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature = new SOAViewFixedLineAvailabilityData.listOfCNFType();
        mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature.callingAndNetworkFeature = new List<SOAViewFixedLineAvailabilityData.cnfType>();
        mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature.callingAndNetworkFeature.add(feature);
            
        if(unsupportedAttributes) {
            mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature.listOfUnsupportedService = new SOAViewFixedLineAvailabilityData.listOfUnsupportedServiceType();
            mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature.listOfUnsupportedService.service = new List<SOAViewFixedLineAvailabilityData.serviceType>();
            mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature.listOfIncompatibleService = new SOAViewFixedLineAvailabilityData.listOfIncompatibleServiceType();
            mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature.listOfIncompatibleService.service = new List<SOAViewFixedLineAvailabilityData.serviceType>();
            mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature.listOfUnsupportedService.service.add(service);
            mbn.mainBillingNumberDetails.listOfCallingAndNetworkFeature.listOfIncompatibleService.service.add(service);        
        }
               
        mbn.mainBillingNumberDetails.listOfDirectDialInRange = new SOAViewFixedLineAvailabilityData.listOfDDIRangeType();
        mbn.mainBillingNumberDetails.listOfDirectDialInRange.numberOfDirectDialInRanges='1';
        mbn.mainBillingNumberDetails.listOfDirectDialInRange.numberRetentionAllowed='Y';
        mbn.mainBillingNumberDetails.listOfDirectDialInRange.directDialInRange = new List<SOAViewFixedLineAvailabilityData.ddiRangeType>();
        mbn.mainBillingNumberDetails.listOfDirectDialInRange.directDialInRange.add(ddiRange);
        mbn.mainBillingNumberDetails.listOfDirectoryInfo = new SOAViewFixedLineAvailabilityData.listOfDirectoryInfoType();
        mbn.mainBillingNumberDetails.listOfDirectoryInfo.directory = new List<SOAViewFixedLineAvailabilityData.directoryType>();
        mbn.mainBillingNumberDetails.listOfDirectoryInfo.directory.add(directory);
        
        mbn.mainBillingNumberDetails.listOfMultiSubscriberNumber = new SOAViewFixedLineAvailabilityData.listOfMSNType();
        mbn.mainBillingNumberDetails.listOfMultiSubscriberNumber.numberOfMultiSubscriberNumbers='1';
        mbn.mainBillingNumberDetails.listOfMultiSubscriberNumber.numberRetentionAllowed='Y';
        mbn.mainBillingNumberDetails.listOfMultiSubscriberNumber.multiSubscriberNumber = new List<SOAViewFixedLineAvailabilityData.msnType>();
        mbn.mainBillingNumberDetails.listOfMultiSubscriberNumber.multiSubscriberNumber.add(msn);
        
        mbn.mainBillingNumberDetails.listOfSingleNumberDirectDialIn = new SOAViewFixedLineAvailabilityData.listOfSNDDIType();
        mbn.mainBillingNumberDetails.listOfSingleNumberDirectDialIn.numberOfSNDDIs='1';
        mbn.mainBillingNumberDetails.listOfSingleNumberDirectDialIn.numberRetentionAllowed='Y';
        mbn.mainBillingNumberDetails.listOfSingleNumberDirectDialIn.singleNumberDirectDialIn = new List<SOAViewFixedLineAvailabilityData.snddiType>();
        mbn.mainBillingNumberDetails.listOfSingleNumberDirectDialIn.singleNumberDirectDialIn.add(snddi);
        mbn.mainBillingNumberDetails.listOfSingleNumberDirectDialIn.singleNumberDirectDialIn.add(snddi);
        
        installationDetails.listOfMainBillingNumber = new SOAViewFixedLineAvailabilityData.listOfMainBillingNumberType();
        installationDetails.listOfMainBillingNumber.mainBillingNumber = new List<SOAViewFixedLineAvailabilityData.mainBillingNumberType>();
        installationDetails.listOfMainBillingNumber.mainBillingNumber.add(mbn);   
        installationDetails.listOfMainBillingNumber.mainBillingNumber.add(mbn); 
        
        // Orders
        SOAViewFixedLineAvailabilityData.pendingOrderType pendingOrder = new SOAViewFixedLineAvailabilityData.pendingOrderType();
        pendingOrder.pendingOrderType='X';
        pendingOrder.isThirdParty='N';
        installationDetails.listOfPendingOrder = new SOAViewFixedLineAvailabilityData.listOfPendingOrderType();
        installationDetails.listOfPendingOrder.pendingOrder = new List<SOAViewFixedLineAvailabilityData.pendingOrderType> ();
        installationDetails.listOfPendingOrder.pendingOrder.add(pendingOrder);
        installationDetails.listOfPendingOrder.pendingOrder.add(pendingOrder);
        installationDetails.listOfPendingOrder.pendingOrder.add(pendingOrder);
        installationDetails.listOfPendingOrder.pendingOrder.add(pendingOrder);
        installationDetails.listOfPendingOrder.pendingOrder.add(pendingOrder);       
        response.installationDetails = installationDetails;
        return response;
    }
            
}