public with sharing class BB_EMLCResponse {
    
    static final String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
    static final String dNS = 'urn:com.openreach.LineCharacteristics2v20-0';
    static final String btNS = 'http://www.bt.com/eai/hub/or/GenericCPWSHubService';
    static final String serviceNS = 'http://www.openuri.org/';
            
    public static AvailabilityCheck parse(Dom.Document doc, AvailabilityCheck lar){
        if(doc==Null){
            return lar;
        }       
        //Retrieve the root element for this document
        Dom.XMLNode xnEnvelope = doc.getRootElement();              
        Dom.XMLNode xnBody = xnEnvelope.getChildElement('Body',soapNS);
        Dom.XMLNode xnDS_ManageLineCharacteristicsV2RequestResponse = xnBody.getChildElement('DS_ManageLineCharacteristicsV2RequestResponse',serviceNS);
        Dom.XMLNode xnFault = xnBody.getChildElement('Fault',soapNS);
        if(xnFault!=Null){
        	system.debug('*** Webservice Fault ***');
        	lar.lineAvailability.Resp1CC__c = getElemText(xnFault,'faultcode',Null);
            lar.lineAvailability.Resp1Txt__c = getElemText(xnFault,'faultstring',Null);
        }        
        if(xnDS_ManageLineCharacteristicsV2RequestResponse!=Null){
	        Dom.XMLNode xnGenericCPWSHubService = xnDS_ManageLineCharacteristicsV2RequestResponse.getChildElement('GenericCPWSHubService',btNS);        
	        Dom.XMLNode xnLineCharacteristicsRequestAccepted2 = xnGenericCPWSHubService.getChildElement('LineCharacteristicsRequestAccepted2',dNS);
	        Dom.XMLNode xnLineCharacteristicsRequestRejected2 = xnGenericCPWSHubService.getChildElement('LineCharacteristicsRequestRejected2',dNS); 
	                
	        if(xnLineCharacteristicsRequestAccepted2!=Null){
	            //Request Accepted                      
	            Dom.XmlNode xnQueryResponse = xnLineCharacteristicsRequestAccepted2.getChildElement('QueryResponse',dNS);
	            Dom.XmlNode xnRespondedQueryLine = xnQueryResponse.getChildElement('RespondedQueryLine',dNS);           
	            Dom.XmlNode xnQueryLineItem = xnRespondedQueryLine.getChildElement('QueryLineItem',dNS);
	            Dom.XmlNode xnFeatures = xnQueryLineItem.getChildElement('Features',dNS);
	            Dom.XmlNode xnLineCharacteristicsFeatureSet = xnFeatures.getChildElement('LineCharacteristicsFeatureSet',dNS);
	            Dom.XmlNode xnOutputFeatures = xnLineCharacteristicsFeatureSet.getChildElement('OutputFeatures',dNS);           
	            // LineCharacteristics
	            Dom.Xmlnode xnLineCharacteristics = xnOutputFeatures.getChildElement('LineCharacteristics',dNS);
	            if(xnLineCharacteristics!=Null){                
	                lar.lineAvailability.PCPId__c = getElemText(xnLineCharacteristics,'PCPId',dNS);
	                lar.lineAvailability.DP__c = getElemText(xnLineCharacteristics,'DP',dNS);
	                lar.lineAvailability.districtCodeList__c = getElemText(xnLineCharacteristics,'DistrictCode',dNS)+';';
	                if(lar.lineAvailability.Post_Code__c=='' || lar.lineAvailability.Post_Code__c==Null){
	                    lar.lineAvailability.Post_Code__c = getElemText(xnLineCharacteristics,'RecordedPostCode',dNS);
	                }
	                lar.lineAvailability.earthCapacitanceA__c = getElemText(xnLineCharacteristics,'AECapacitance',dNS);
	                lar.lineAvailability.earthCapacitanceB__c = getElemText(xnLineCharacteristics,'BECapacitance',dNS);
	                lar.lineAvailability.aggregatedCapacitance__c = getElemText(xnLineCharacteristics,'AggregatedCapacitance',dNS);
	                lar.lineAvailability.DPLineLengthEstimate__c = getElemText(xnLineCharacteristics,'DPLineLengthEstimate',dNS);
	                lar.lineAvailability.CircuitLineLengthEstimate__c = getElemText(xnLineCharacteristics,'CircuitLineLengthEstimate',dNS);
	                lar.lineAvailability.CircuitLineLengthCalculated__c = getElemText(xnLineCharacteristics,'CircuitLineLengthCalculated',dNS);
	                lar.lineAvailability.aggregatedDPLineLengthEstimate__c = getElemText(xnLineCharacteristics,'AggregatedDPLineLengthEstimate',dNS);
	                lar.lineAvailability.aggregatedCircuitLineLengthEstimate__c = getElemText(xnLineCharacteristics,'AggregatedCircuitLineLengthEstimate',dNS);
	                lar.lineAvailability.AggregatedCircuitLineLengthCalculated__c = getElemText(xnLineCharacteristics,'AggregatedCircuitLineLengthCalculated',dNS);
	                lar.lineAvailability.anfpCategory__c = getElemText(xnLineCharacteristics,'ANFPCategory',dNS);
	                // Exchange Id and Name
	                lar.lineAvailability.btExchangeId__c = getElemText(xnLineCharacteristics,'MDFSiteId',dNS);
	                lar.lineAvailability.btExchangeName__c = getElemText(xnLineCharacteristics,'MDFSiteName',dNS);
	                if(lar.lineAvailability.btExchangeName__c=='' && lar.lineAvailability.btExchangeId__c!=''){
	                    lar.lineAvailability.btExchangeName__c = BB_Exchange__c.getInstance(lar.lineAvailability.btExchangeId__c).Exchange_Name__c;
	                }
	                // For only postcode checks ExchangeId and Name xml comes in different format
	                if(lar.lineAvailability.btExchangeId__c=='' || lar.lineAvailability.btExchangeId__c==Null){                	
	                	Dom.XmlNode xnListOfMDFSite = xnLineCharacteristics.getChildElement('ListOfMDFSite',dNS);
	                	if(xnListOfMDFSite!=Null){
	                		for(Dom.XmlNode xnMDFSite : xnListOfMDFSite.getChildElements()){
	                			if(lar.lineAvailability.btExchangeId__c=='' || lar.lineAvailability.btExchangeId__c==Null){
	                				lar.lineAvailability.districtCodeList__c = getElemText(xnMDFSite,'DistrictCode',dNS);                 				
	                        		lar.lineAvailability.btExchangeId__c = getElemText(xnMDFSite,'MDFSiteId',dNS);
	                        		lar.lineAvailability.btExchangeName__c = getElemText(xnMDFSite,'MDFSiteName',dNS);
	                    		}	
	                		}
	                	}
	                }
	                lar.lineAvailability.BETEnabled__c = getElemText(xnLineCharacteristics,'BETEnabled',dNS);
	                Dom.Xmlnode xnTieDetails = xnLineCharacteristics.getChildElement('TieDetails',dNS);
	                if(xnTieDetails!=Null){
	                    lar.lineAvailability.PSTNTieCableID__c = getElemText(xnTieDetails,'PSTNTieCableId',dNS);                    
	                }
	                lar.lineAvailability.CelerityDBLoss__c = getElemText(xnLineCharacteristics,'CelerityDBLoss',dNS);
	                lar.lineAvailability.CalculatedDBLoss__c = getElemText(xnLineCharacteristics,'CalculatedDBLoss',dNS);
	                lar.lineAvailability.LastWeeklyUpdateDateTime__c = getElemText(xnLineCharacteristics,'LastWeeklyUpdateDateTime',dNS);
	                lar.lineAvailability.aggregatedCelerityDBLoss__c = getElemText(xnLineCharacteristics,'AggregatedCelerityDBLoss',dNS);
	                lar.lineAvailability.aggregatedCalculatedDBLoss__c = getElemText(xnLineCharacteristics,'AggregatedCalculatedDBLoss',dNS);
	                lar.lineAvailability.LastMonthlyUpdateDateTime__c = getElemText(xnLineCharacteristics,'LastMonthlyUpdateDateTime',dNS);
	                lar.lineAvailability.LastCelerityUpdateDateTime__c = getElemText(xnLineCharacteristics,'LastCelerityUpdateDateTime',dNS);                       
	            }
	            // FTTCAvailability
	            Dom.Xmlnode xnFTTCAvailability = xnOutputFeatures.getChildElement('FTTCAvailability',dNS);
	            if(xnFTTCAvailability!=Null){
	            	// Get FTTC details if needed as per custom setting value
	            	if(BB_Checker_Settings__c.getInstance('Get_FTTC_Details').Value__c){
		                lar.lineAvailability.FTTCAvailable__c = getElemText(xnFTTCAvailability,'FTTCAvailable',dNS);
		                if(lar.lineAvailability.FTTCAvailable__c=='Y' || lar.lineAvailability.FTTCAvailable__c=='y'){
		                    lar.lineAvailability.FTTCMaximumDownstreamDataBandwidth__c = getElemText(xnFTTCAvailability,'MaximumDownstreamDataBandwidth',dNS);
		                    if(lar.lineAvailability.FTTCMaximumDownstreamDataBandwidth__c.contains('Mbit/s')){
		                    	lar.lineAvailability.FTTCMaximumDownstreamDataBandwidth__c = lar.lineAvailability.FTTCMaximumDownstreamDataBandwidth__c.replaceAll('Mbit/s','meg');
		                    }
		                    lar.lineAvailability.FTTCMaximumUpstreamDataBandwidth__c = getElemText(xnFTTCAvailability,'MaximumUpstreamDataBandwidth',dNS);
		                    if(lar.lineAvailability.FTTCMaximumUpstreamDataBandwidth__c.contains('Mbit/s')){
		                    	lar.lineAvailability.FTTCMaximumUpstreamDataBandwidth__c = lar.lineAvailability.FTTCMaximumUpstreamDataBandwidth__c.replaceAll('Mbit/s','meg');
		                    }              
		                }
	            	}
	            }
	            // FTTPAvailability
	            Dom.Xmlnode xnFTTPAvailability = xnOutputFeatures.getChildElement('FTTPAvailability',dNS);
	            if(xnFTTPAvailability!=Null){
	                lar.lineAvailability.FTTPAvailable__c = getElemText(xnFTTPAvailability,'FTTPAvailable',dNS);
	                lar.lineAvailability.FTTPPercentageCoverage__c = getElemText(xnFTTPAvailability,'FTTPPercentageCoverage',dNS);              
	                lar.lineAvailability.FVAAvailable__c = getElemText(xnFTTPAvailability,'FVAAvailable',dNS);
	            }
	            // ListOfServiceCompatibility
	            Dom.Xmlnode xnListOfServiceCompatibility = xnOutputFeatures.getChildElement('ListOfServiceCompatibility',dNS);
	            if(xnListOfServiceCompatibility!=Null){
	                for(Dom.Xmlnode xnServiceCompatibility : xnListOfServiceCompatibility.getChildElements()){
	                    String strService = getElemText(xnServiceCompatibility,'ServiceType',dNS)+' - '+getElemText(xnServiceCompatibility,'CompatibilityIndicator',dNS)+' ; ';     
	                    if(lar.lineAvailability.BBServiceCompatibility__c=='' || lar.lineAvailability.BBServiceCompatibility__c==Null){
	                        lar.lineAvailability.BBServiceCompatibility__c = strService;
	                    }
	                    else{
	                        lar.lineAvailability.BBServiceCompatibility__c += strService;
	                    }
	                }
	            }
	            // ListOfTechnologyMessage
	            Dom.Xmlnode xnListOfTechnologyMessage = xnOutputFeatures.getChildElement('ListOfTechnologyMessage',dNS);
	            if(xnListOfTechnologyMessage!=Null){
	                for(Dom.XmlNode xnTechnologyMessage : xnListOfTechnologyMessage.getChildElements()){
	                    if(lar.lineAvailability.BBTechnologyCode__c=='' || lar.lineAvailability.BBTechnologyCode__c==Null){
	                        lar.lineAvailability.BBTechnologyCode__c = getElemText(xnTechnologyMessage,'TechnologyCode',dNS);	                        
	                        lar.lineAvailability.BBTechnologyText__c = getElemText(xnTechnologyMessage,'TechnologyText',dNS);	                        	                        
	                    }
	                } 
	            }
	            lar.lineAvailability.reasonCode__c = lar.lineAvailability.BBTechnologyCode__c;
	            if(!(lar.lineAvailability.reasonCode__c=='' || lar.lineAvailability.reasonCode__c==Null)){
	            	lar.lineAvailability.Reason_code_short_text__c = BT_Broadband_Reason_Codes__c.getInstance(lar.lineAvailability.reasonCode__c).Description__c;
	            }
	            if(!(lar.lineAvailability.CircuitLineLengthEstimate__c==Null || lar.lineAvailability.CircuitLineLengthEstimate__c=='')){
	            	lar.lineAvailability.lineLengthEstimate__c = lar.lineAvailability.CircuitLineLengthEstimate__c;	
	            }
	            else if(!(lar.lineAvailability.DPLineLengthEstimate__c==Null || lar.lineAvailability.DPLineLengthEstimate__c=='')){
	            	lar.lineAvailability.lineLengthEstimate__c = lar.lineAvailability.DPLineLengthEstimate__c;
	            }
	            else if(!(lar.lineAvailability.CircuitLineLengthCalculated__c==Null || lar.lineAvailability.CircuitLineLengthCalculated__c=='')){
	            	lar.lineAvailability.lineLengthEstimate__c = lar.lineAvailability.CircuitLineLengthCalculated__c;
	            }
	            // ListOfServiceInformation
	            Dom.Xmlnode xnListOfServiceInformation = xnOutputFeatures.getChildElement('ListOfServiceInformation',dNS);
	            if(xnListOfServiceInformation!=Null){
	                for(Dom.XmlNode xnServiceInformation : xnListOfServiceInformation.getChildElements()){
	                    if(lar.lineAvailability.AccessLineID__c=='' || lar.lineAvailability.AccessLineID__c==Null){
	                        lar.lineAvailability.AccessLineID__c = getElemText(xnServiceInformation,'AccessLineId',dNS);
	                        lar.lineAvailability.accessLineStatus__c = getElemText(xnServiceInformation,'AccessLIneStatus',dNS);
	                    }                   
	                    Dom.XmlNode xnProviderParty = xnServiceInformation.getChildElement('ProviderParty',dNS);
	                    if(xnProviderParty!=Null){
	                        Dom.Xmlnode xnParty = xnProviderParty.getChildElement('Party',dNS);
	                        if(xnParty!=Null){
	                            Dom.Xmlnode xnPartyName = xnParty.getChildElement('PartyName',dNS);
	                            if(xnPartyName!=Null){                              
	                                lar.lineAvailability.contractedPartyName__c = getElemText(xnPartyName,'Name',dNS);
	                            }
	                            Dom.Xmlnode xnDetailedContact = xnParty.getChildElement('DetailedContact',dNS);
	                            if(xnDetailedContact!=Null){                                
	                                lar.lineAvailability.contractedPartyNumber__c = getElemText(xnDetailedContact,'Telephone',dNS);                             
	                            }                           
	                        }
	                    }                   
	                }               
	            }           
	            Dom.XmlNode xnQueryLineMessageInfo = xnRespondedQueryLine.getChildElement('QueryLineMessageInfo',dNS);
	            if(xnQueryLineMessageInfo!=Null){
	                Integer i = 1;
	                for(Dom.XmlNode xnMessageInfo : xnQueryLineMessageInfo.getChildElements()){                 
	                    if(i==1){                       
	                        lar.lineAvailability.Resp1CC__c = getElemText(xnMessageInfo,'CompletionCode',dNS);
	                        lar.lineAvailability.Resp1Txt__c = getElemText(xnMessageInfo,'Message',dNS);                        
	                        lar.lineAvailability.Resp1Sev__c = getElemText(xnMessageInfo,'Severity',dNS);
	                    }
	                    i++;
	                }
	            }
	            // After parsing XML get productlist and speed information from helper class
	            // Determine Productlist
                lar.lineAvailability.productList__c = BB_Helper.getProductList(lar.lineAvailability.btExchangeId__c);
	            if(lar.lineAvailability.btExchangeId__c!=''){	                
	                // Determine Download Speed
	                if(lar.lineAvailability.FTTCMaximumDownstreamDataBandwidth__c=='' || lar.lineAvailability.FTTCMaximumDownstreamDataBandwidth__c==Null){
	                    lar.lineAvailability.predictedDownloadSpeed__c = BB_Helper.getDownSpeed(lar.lineAvailability.btExchangeId__c, lar.lineAvailability.anfpCategory__c, lar.lineAvailability.CircuitLineLengthEstimate__c, lar.lineAvailability.DPLineLengthEstimate__c, lar.lineAvailability.CircuitLineLengthCalculated__c, lar.lineAvailability.CelerityDBLoss__c, lar.lineAvailability.CalculatedDBLoss__c);
	                    lar.lineAvailability.estimatedLineSpeed__c = lar.lineAvailability.predictedDownloadSpeed__c;
	                }
	                else{
	                    lar.lineAvailability.predictedDownloadSpeed__c = lar.lineAvailability.FTTCMaximumDownstreamDataBandwidth__c;
	                    lar.lineAvailability.estimatedLineSpeed__c = lar.lineAvailability.FTTCMaximumDownstreamDataBandwidth__c;                    
	                }
	                // Determine Upload Speed
	                if(lar.lineAvailability.FTTCMaximumUpstreamDataBandwidth__c=='' || lar.lineAvailability.FTTCMaximumUpstreamDataBandwidth__c==Null){
	                    lar.lineAvailability.predictedUploadSpeed__c = BB_Helper.getUpSpeed(lar.lineAvailability.btExchangeId__c, lar.lineAvailability.anfpCategory__c, lar.lineAvailability.CircuitLineLengthEstimate__c, lar.lineAvailability.DPLineLengthEstimate__c, lar.lineAvailability.CircuitLineLengthCalculated__c, lar.lineAvailability.CelerityDBLoss__c, lar.lineAvailability.CalculatedDBLoss__c);
	                }
	                else{
	                    lar.lineAvailability.predictedUploadSpeed__c = lar.lineAvailability.FTTCMaximumUpstreamDataBandwidth__c;
	                }
	            }
	            lar.lineAvailability.isLLUAvailable__c = BB_Checker_Settings__c.getInstance('isLLUAvailable__c').Value__c;
	            lar.lineAvailability.isIPStreamAvailable__c = BB_Checker_Settings__c.getInstance('isIPStreamAvailable__c').Value__c;
	            if(lar.lineAvailability.Resp1CC__c=='2150'){
	            	lar.lineAvailability.Status_Code__c = '2000';            	            	
	            }
	            else{
	            	lar.lineAvailability.Status_Code__c = lar.lineAvailability.Resp1CC__c;	
	            }
	        }       
	        if(xnLineCharacteristicsRequestRejected2!=Null){
	            //Request Rejected
	            Dom.XmlNode xnQueryResponse = xnLineCharacteristicsRequestRejected2.getChildElement('QueryResponse',dNS);
	            Dom.XmlNode xnRespondedQueryLine = xnQueryResponse.getChildElement('RespondedQueryLine',dNS);
	            Dom.XmlNode xnQueryLineItem = xnRespondedQueryLine.getChildElement('QueryLineItem',dNS);                        
	            Dom.XmlNode xnQueryLineMessageInfo = xnRespondedQueryLine.getChildElement('QueryLineMessageInfo',dNS);
	            if(xnQueryLineMessageInfo!=Null){
	                Integer i = 1;
	                for(Dom.XmlNode xnMessageInfo : xnQueryLineMessageInfo.getChildElements()){                 
	                    if(i==1){
	                        lar.lineAvailability.Resp1CC__c = getElemText(xnMessageInfo,'CompletionCode',dNS);
	                        lar.lineAvailability.Resp1Txt__c = getElemText(xnMessageInfo,'Message',dNS);
	                        lar.lineAvailability.Resp1Sev__c = getElemText(xnMessageInfo,'Severity',dNS);   
	                    }
	                    i++;
	                }
	            }
	            if(lar.lineAvailability.Resp1CC__c!=Null){            	
	            	lar.lineAvailability.Status_Code__c = lar.lineAvailability.Resp1CC__c;            	
	            }
	            else{
	            	lar.lineAvailability.Status_Code__c = '2151';	
	            }                       
	        }
        }               
        lar.lineAvailability.Processed__c = true;
        if(lar.lineAvailability.Resp1Txt__c!=''){
            lar.lineAvailability.Response__c = lar.lineAvailability.Resp1Txt__c;    
        }       
        return lar;
    }
    
    // Get element text - return blank if null
    public static String getElemText(Dom.XMLNode node, String tag, String nameSpace){
        Dom.XMLNode childNode = node.getChildElement(tag,nameSpace);
        if(childNode == Null){
            return '';
        }
        else{
            system.debug(' *** Node Name-Value *** '+childNode.getName()+' - '+childNode.getText());
            return childNode.getText();
        }
    }

}