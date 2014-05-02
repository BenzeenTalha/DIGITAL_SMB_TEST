public with sharing class AvailabilityCheckDataUtils {

    public AvailabilityCheckDataUtils () {
    }
/*
    // Create line availability request message
    public List<SOAViewFixedLineAvailabilityData.lineParametersType> getLineParameters(Line_Availability__c lineAvailabilityRequest) {
        List<SOAViewFixedLineAvailabilityData.lineParametersType> lineParameters = new List<SOAViewFixedLineAvailabilityData.lineParametersType>();
        SOAViewFixedLineAvailabilityData.lineParametersType lineParameter = new SOAViewFixedLineAvailabilityData.lineParametersType();
        lineParameter.requestersId = lineAvailabilityRequest.Batch_Job__c;
        lineParameter.workingLineTakeover = 'Y';
        lineParameter.endUserConsent = 'Y';
        SOAViewFixedLineAvailabilityData.serviceIdType serviceIdType = new SOAViewFixedLineAvailabilityData.serviceIdType();
        serviceIdType.directoryNumber = lineAvailabilityRequest.Directory_Number__c;
        lineParameter.serviceId = serviceIdType;
        lineParameter.postcode = lineAvailabilityRequest.Post_Code__c;
        lineParameters.add(lineParameter);
        return lineParameters;
    }

    // Parse line availability response
    public Line_Availability__c processResponse(SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType response, Line_Availability__c lineAvailabilityRequest) {
        // Initialise the line availability fields that will be calculated
        lineAvailabilityRequest.Number_Of_Bearers__c = 0;
        lineAvailabilityRequest.Number_Of_Incompatible_Services__c = 0;
        lineAvailabilityRequest.Number_Of_Unsupported_Services__c = 0;
        // Not this one - if zero should be left as null
        //lineAvailabilityRequest.Number_Of_Channels__c = 0;

        List<SOACoreData2.ServiceResultType> retrievalStatusList = response.retrievalStatus;

        for (SOACoreData2.ServiceResultType retrievalStatus : retrievalStatusList) {
            lineAvailabilityRequest.Processed__c = true;
            lineAvailabilityRequest.status_code__c = retrievalStatus.statusCode;
            lineAvailabilityRequest.Response__c = retrievalStatus.externalDescription;
            lineAvailabilityRequest.External_Description__c = retrievalStatus.externalDescription;
            lineAvailabilityRequest.Internal_Description__c = retrievalStatus.internalDescription;
        }
        SOAViewFixedLineAvailabilityData.installationDetailsType installationDetails = response.installationDetails;
        if (installationDetails != null) {
            lineAvailabilityRequest.Service_Type__c = installationDetails.serviceType;
            lineAvailabilityRequest.Line_Type__c = installationDetails.lineType;
            lineAvailabilityRequest.Number_of_Auxilary_Lines__c = installationDetails.auxilaryLineQuantity;
            lineAvailabilityRequest.Carrier_Pre_Select__c = installationDetails.carrierPreSelectPresent;
            lineAvailabilityRequest.Narrowband_Service_Indicator__c = installationDetails.narrowbandServicesIndicator;
            SOAViewFixedLineAvailabilityData.listOfCNFType listOfCallingAndNetworkFeature = installationDetails.listOfCallingAndNetworkFeature;
            if (listOfCallingAndNetworkFeature != null) {
                // Calling and network features
                if (listOfCallingAndNetworkFeature.callingAndNetworkFeature != null) {
                    for (SOAViewFixedLineAvailabilityData.cnfType feature : listOfCallingAndNetworkFeature.callingAndNetworkFeature) {
                        if (lineAvailabilityRequest.Features__c == null) {
                            lineAvailabilityRequest.Features__c = feature.callingNetworkFeatureName;
                        } else {
                            lineAvailabilityRequest.Features__c += '; '+feature.callingNetworkFeatureName;
                        }
                    }
                }
                // Incompatible services
                if (listOfCallingAndNetworkFeature.listOfIncompatibleService != null) {
                    SOAViewFixedLineAvailabilityData.listOfIncompatibleServiceType incompatibleServices = listOfCallingAndNetworkFeature.listOfIncompatibleService;
                    if (incompatibleServices.service != null) {
                        for (SOAViewFixedLineAvailabilityData.serviceType incompatibleService : incompatibleServices.service) {
                            lineAvailabilityRequest.Number_Of_Incompatible_Services__c++;
                            if (lineAvailabilityRequest.Incompatible_Services__c == null) {
                                lineAvailabilityRequest.Incompatible_Services__c = incompatibleService.serviceName;
                            } else {
                                lineAvailabilityRequest.Incompatible_Services__c += '; '+incompatibleService.serviceName;
                            }
                        }
                    }
                }
                // Unsupported services
                if (listOfCallingAndNetworkFeature.listOfUnsupportedService != null) {
                    SOAViewFixedLineAvailabilityData.listOfUnsupportedServiceType unsupportedServices = listOfCallingAndNetworkFeature.listOfUnsupportedService;
                    if (unsupportedServices.service != null) {
                        for (SOAViewFixedLineAvailabilityData.serviceType unsupportedService : unsupportedServices.service) {
                            lineAvailabilityRequest.Number_Of_Unsupported_Services__c++;
                            if (lineAvailabilityRequest.Unsupported_Services__c == null) {
                                lineAvailabilityRequest.Unsupported_Services__c = unsupportedService.serviceName;
                            } else {
                                lineAvailabilityRequest.Unsupported_Services__c += '; '+unsupportedService.serviceName;
                            }
                        }
                    }
                }
            }
            // Used to calculate the number of unique bearer ids
            Set<String> bearerIds = new Set<String>();
            SOAViewFixedLineAvailabilityData.listOfBearerType listOfBearer = installationDetails.listOfBearer;
            if (listOfBearer != null) {
                if (listOfBearer.bearer != null) {
                    for (SOAViewFixedLineAvailabilityData.bearerType bearer : listOfBearer.bearer) {
                        bearerIds.add(bearer.bearerId);
                        // List of channels
                        SOAViewFixedLineAvailabilityData.listOfChannelType listOfChannelType = bearer.listOfChannel;
                        if (listOfChannelType != null) {
                            try {
                                if (lineAvailabilityRequest.Number_Of_Channels__c == null) {
                                    lineAvailabilityRequest.Number_Of_Channels__c = 0;
                                }
                                lineAvailabilityRequest.Number_Of_Channels__c = lineAvailabilityRequest.Number_Of_Channels__c + Integer.valueOf(listOfChannelType.numberOfChannels);
                            } catch (Exception e) {
                            }
                            if (listOfChannelType.channel != null) {
                                for (SOAViewFixedLineAvailabilityData.ChannelType channel : listOfChannelType.channel) {
                                    // Not sure what information we need from here
                                }
                            }
                        }
                    }
                }
            }
            lineAvailabilityRequest.Number_Of_Bearers__c = bearerIds.size();
            SOAViewFixedLineAvailabilityData.listOfMainBillingNumberType listOfMainBillingNumber = installationDetails.listOfMainBillingNumber;
            if (listOfMainBillingNumber != null) {
                List<SOAViewFixedLineAvailabilityData.mainBillingNumberType> mainBillingNumberList = listOfMainBillingNumber.mainBillingNumber;
                for (SOAViewFixedLineAvailabilityData.mainBillingNumberType mainBillingNumber : mainBillingNumberList) {
                    if (lineAvailabilityRequest.Billing_Numbers__c == null) {
                        lineAvailabilityRequest.Billing_Numbers__c = mainBillingNumber.mainBillingNumberCLI;
                    } else {
                        lineAvailabilityRequest.Billing_Numbers__c += '; '+mainBillingNumber.mainBillingNumberCLI;
                    }
                    SOAViewFixedLineAvailabilityData.mainBillingNumberDetailsType mainBillingNumberDetails = mainBillingNumber.mainBillingNumberDetails;
                    if (mainBillingNumberDetails != null) {
                        // DDI Ranges
                        SOAViewFixedLineAvailabilityData.listOfDDIRangeType listOfDirectDialInRange = mainBillingNumberDetails.listOfDirectDialInRange;
                        if (listOfDirectDialInRange != null) {
                            if (listOfDirectDialInRange.directDialInRange != null) {
                                for (SOAViewFixedLineAvailabilityData.ddiRangeType ddiRange : listOfDirectDialInRange.directDialInRange) {
                                    if (lineAvailabilityRequest.DDI_Ranges__c == null) {
                                        lineAvailabilityRequest.DDI_Ranges__c = ddiRange.rangeFrom+' - '+ ddiRange.rangeTo;
                                    } else {
                                        lineAvailabilityRequest.DDI_Ranges__c += '; '+ ddiRange.rangeFrom+' - '+ ddiRange.rangeTo;
                                    }
                                }
                            }
                        }
                        // Single DDIs
                        SOAViewFixedLineAvailabilityData.listOfSNDDIType listOfSingleNumberDirectDialIn = mainBillingNumberDetails.listOfSingleNumberDirectDialIn;
                        if (listOfSingleNumberDirectDialIn != null) {
                            if (listOfSingleNumberDirectDialIn.singleNumberDirectDialIn != null) {
                                for (SOAViewFixedLineAvailabilityData.snddiType singleDDI : listOfSingleNumberDirectDialIn.singleNumberDirectDialIn) {
                                    if (lineAvailabilityRequest.Single_DDIs__c == null) {
                                        lineAvailabilityRequest.Single_DDIs__c = singleDDI.snddiCLI;
                                    } else {
                                        lineAvailabilityRequest.Single_DDIs__c += '; '+ singleDDI.snddiCLI;
                                    }
                                }
                            }
                        }
                        // Calling and network features (ISDN2 and ISDN30)
                        listOfCallingAndNetworkFeature = mainBillingNumberDetails.listOfCallingAndNetworkFeature;
                        if (listOfCallingAndNetworkFeature != null) {
                            if (listOfCallingAndNetworkFeature.callingAndNetworkFeature != null) {
                                for (SOAViewFixedLineAvailabilityData.cnfType feature : listOfCallingAndNetworkFeature.callingAndNetworkFeature) {
                                    if (lineAvailabilityRequest.Features__c == null) {
                                        lineAvailabilityRequest.Features__c = feature.callingNetworkFeatureName;
                                    } else {
                                        lineAvailabilityRequest.Features__c += '; '+feature.callingNetworkFeatureName;
                                    }
                                }
                            }
                        }
                        // List of channels
                        SOAViewFixedLineAvailabilityData.listOfChannelType listOfChannelType = mainBillingNumberDetails.listOfChannel;
                        if (listOfChannelType != null) {
                            try {
                                if (lineAvailabilityRequest.Number_Of_Channels__c == null) {
                                    lineAvailabilityRequest.Number_Of_Channels__c = 0;
                                }
                                lineAvailabilityRequest.Number_Of_Channels__c = lineAvailabilityRequest.Number_Of_Channels__c + Integer.valueOf(listOfChannelType.numberOfChannels);
                            } catch (Exception e) {
                            }
                            if (listOfChannelType.channel != null) {
                                for (SOAViewFixedLineAvailabilityData.ChannelType channel : listOfChannelType.channel) {
                                    // Not sure what information we need from here
                                }
                            }
                        }
                    }
                }
            }
            SOAViewFixedLineAvailabilityData.addressType addressResult = installationDetails.address;
            if (addressResult != null) {
                SOAViewFixedLineAvailabilityData.britishAddressType britishAddress = addressResult.britishAddress;
                if (britishAddress != null)
                    lineAvailabilityRequest.company_name__c = britishAddress.organisationName;
            }
        }
        return lineAvailabilityRequest;
    }

    // Manually construct a response message used in test methods
    public SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType getResponseForTestMethods(String directoryNumber) {
        SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType response;

        response = new SOAViewFixedLineAvailabilityData.respondedInstallationDetailsType();
        SOACoreData2.ServiceResultType retrievalStatus = new SOACoreData2.ServiceResultType();
        retrievalStatus.StatusCode = '2000';
        retrievalStatus.ExternalDescription = 'External Description';
        retrievalStatus.InternalDescription = 'Internal Description';
        response.retrievalStatus = new List<SOACoreData2.ServiceResultType>{retrievalStatus};

        SOAViewFixedLineAvailabilityData.installationDetailsType installationDetails = new SOAViewFixedLineAvailabilityData.installationDetailsType();
        installationDetails.lineType = 'Test';
        installationDetails.auxilaryLineQuantity = 1;
        installationDetails.carrierPreSelectPresent = '';

        SOAViewFixedLineAvailabilityData.listOfCNFType listOfCallingAndNetworkFeature = new SOAViewFixedLineAvailabilityData.listOfCNFType();
        List<SOAViewFixedLineAvailabilityData.cnfType> callingAndNetworkFeatureList = new List<SOAViewFixedLineAvailabilityData.cnfType>();
        SOAViewFixedLineAvailabilityData.cnfType feature = new SOAViewFixedLineAvailabilityData.cnfType();
        feature.callingNetworkFeatureName = 'Test Feature';
        callingAndNetworkFeatureList.add(feature);
        listOfCallingAndNetworkFeature.callingAndNetworkFeature = callingAndNetworkFeatureList;
        installationDetails.listOfCallingAndNetworkFeature = listOfCallingAndNetworkFeature;

        SOAViewFixedLineAvailabilityData.listOfMainBillingNumberType listOfMainBillingNumber = new SOAViewFixedLineAvailabilityData.listOfMainBillingNumberType();
        List<SOAViewFixedLineAvailabilityData.mainBillingNumberType> mainBillingNumberList = new List<SOAViewFixedLineAvailabilityData.mainBillingNumberType>();
        SOAViewFixedLineAvailabilityData.mainBillingNumberType mainBillingNumber = new SOAViewFixedLineAvailabilityData.mainBillingNumberType();
        mainBillingNumber.mainBillingNumberCLI = '1234567890';
        mainBillingNumberList.add(mainBillingNumber);
        listOfMainBillingNumber.mainBillingNumber = mainBillingNumberList;
        installationDetails.listOfMainBillingNumber = listOfMainBillingNumber;

        response.installationDetails = installationDetails;
        return response;

    }
*/
}