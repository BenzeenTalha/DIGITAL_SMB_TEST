// Class: O2OrderHelper
// Description: Helper class of static methods for creating a completed Opportunity
// supports both online and partner API transactions
public without sharing class O2OrderHelper {

    public static final string CUSTOMER_SMB = 'SMB';
    public static final string CUSTOMER_ENTERPRISE = 'Enterprise';
    public static final string PROD_BROADBAND = 'Business Broadband';
    public static final string PROD_LANDLINE = 'Landline';
    public static final string PROD_CALLS_ONLY = 'Calls Only';
    public static final string PROD_ISDN2 = 'ISDN2';
    public static final string PROD_ISDN30_ETSI = 'ISDN30 ETSI';
    public static final string PROD_ISDN30_DASS = 'ISDN30 DASS';
    public static final string PROD_LANDLINE_BOLT_ONS = 'Landline Bolt Ons';
    public static final string PROD_BOLT_ONS = 'Bolt Ons';
    public static final string TELEMARKETING = 'Telemarketing One to One';
    public static final string BUSINESS_BROADBAND = 'Business Broadband';
    public static final string BUSINESS_SINGLE_TARIFF = 'Single Tariff';
    public static final string BUSINESS_SHARER_TARIFF = 'Sharer Tariff';
    public static final string BE_BROADBAND = 'BE ';		// This is to escape out all BE products
    public static final string MOBILE_BROADBAND = 'Mobile Broadband';
    public static final string BOOSTBOX = 'Boostbox';

   // Get the current laCheckResult for a given Line Availability Id
    public static Line_Availability__c getlaCheckResults(String laId) {
        String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('Line_Availability__c') +
                      ', (select ' + Utility.getSobjectFields('Line_Availability_DDI_Range__c') +
                      ' from Line_Availability_DDI_Ranges__r)' +
                      ' from Line_Availability__c where ID = \''+laId+'\' LIMIT 1';

        Line_Availability__c laCheckResult = Database.query(queryString);

        return laCheckResult;
    }


    // Given an Availability Check and ProductConfiguration copy the values to the appropriate attributes
    // NOTE! This will update the config passed!
    public static cscfgc.ProductConfiguration populateConfiguration(String productName, cscfgc.ProductConfiguration config, Id laId) {
        Line_Availability__c laCheckResult = new Line_Availability__c();
        if (laId != null)
            laCheckResult = getlaCheckResults(laId);

        // Get the line type and product type mappings
        Map <String,Line_Type_Map__c> lineTypeMap = new Map <String,Line_Type_Map__c>();
        List<Line_Type_Map__c> lineTypeMapList;
        lineTypeMapList = Line_Type_Map__c.getall().values();
        for(Line_Type_Map__c lTMap: lineTypeMapList) {
            lineTypeMap.put(lTMap.Name, lTMap);
        }

        // Based on product type populate the configuration but check the line check was successful
        if (laCheckResult != null)
            if (productName.contains(PROD_LANDLINE)) {
                config.getAttribute('Existing Telephone Number').setValue(laCheckResult.Directory_Number__c);
                if (laCheckResult.Service_Type__c != null && lineTypeMap.containsKey(laCheckResult.Service_Type__c)) {
                    config.getAttribute('Line Type').setValue(''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Line_Type_Value__c);
                }
                if (laCheckResult.CareLvl__c != null) {
                    if (laCheckResult.CareLvl__c == '1') laCheckResult.CareLvl__c = '2';
                    config.getAttribute('Care Package').setValue('Level '+laCheckResult.CareLvl__c);
                }
                if (laCheckResult.Number_Of_Lines__c != null)
                    config.getAttribute('Number of Lines').setValue(''+laCheckResult.Number_Of_Lines__c);
                if (laCheckResult.Post_Code__c != null)
                    config.getAttribute('Postcode').setValue(''+laCheckResult.Post_Code__c);
                if (laCheckResult.TermType__c != null)
                    config.getAttribute('Termination Type').setValue(''+laCheckResult.TermType__c);
                if (laCheckResult.InstType__c != null)
                    config.getAttribute('Installation Type').setValue(''+laCheckResult.InstType__c);
            }
            else if (productName.contains(PROD_CALLS_ONLY)) {
				system.debug('laCheckResult='+laCheckResult);
				system.debug('lineTypeMap='+lineTypeMap);
                config.getAttribute('Line Number').setValue(laCheckResult.Directory_Number__c);
                if (laCheckResult.Service_Type__c != null && lineTypeMap.containsKey(laCheckResult.Service_Type__c)) {
                    config.getAttribute('Primary Product Type').setValue(''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Product_Type_Value__c);
                    config.getAttribute('Line Type').setValue(''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Line_Type_Value__c);
                }
                if (laCheckResult.CareLvl__c != null)
                    config.getAttribute('Care Package').setValue('Level '+laCheckResult.CareLvl__c);
                if (laCheckResult.Number_Of_Lines__c != null)
                    config.getAttribute('Number of Lines').setValue(''+laCheckResult.Number_Of_Lines__c);
                if (laCheckResult.Post_Code__c != null)
                    config.getAttribute('Postcode').setValue(''+laCheckResult.Post_Code__c);
                if (laCheckResult.Carrier_Pre_Select__c != null)
                    config.getAttribute('CPS Present').setValue(''+laCheckResult.Carrier_Pre_Select__c);
                if (laCheckResult.Directory_Number__c != null)
                    config.getAttribute('Line Number').setValue(''+laCheckResult.Directory_Number__c);
                if (laCheckResult.Number_Of_Channels__c != null)
                    config.getAttribute('Number of Channels').setValue(''+laCheckResult.Number_Of_Channels__c);
            }
            else if (productName.contains(PROD_ISDN2)) {
                config.getAttribute('Existing Telephone Number').setValue(laCheckResult.Directory_Number__c);
                if (laCheckResult.CareLvl__c != null)
                    config.getAttribute('Care Package').setValue('Level '+laCheckResult.CareLvl__c);
                if (laCheckResult.Post_Code__c != null)
                    config.getAttribute('Postcode').setValue(''+laCheckResult.Post_Code__c);
                if (laCheckResult.TermType__c != null)
                    config.getAttribute('Termination Type').setValue(''+laCheckResult.TermType__c);

                Integer rangeNo = 0;
                if (laCheckResult.TotDDIR__c > 0) {
                    List<Line_Availability_DDI_Range__c> lineAvailChannelResults = laCheckResult.Line_Availability_DDI_Ranges__r;
                    if (lineAvailChannelResults.size() > 0) {
                        for (SObject obj : lineAvailChannelResults) {
                            rangeNo++;
                            Line_Availability_DDI_Range__c ladr = (Line_Availability_DDI_Range__c) obj;
                            if (laCheckResult.DDI_Ranges__c != null && rangeNo < 6)
                                config.getAttribute('DDI Range ' + rangeNo).setValue(''+ladr.NumDDIs__c);
                        }
                    }
                }

                // Only worth checking for SNDDIs if we haven't filled all the slots
                if (rangeNo < 6) {
                    // The Main Billing Number contains a summary of the number of single number DDIs, we don't need to iterate through the child records
                    // In fact, the TotSNDDI on the LineAvailability record tells us all we need to know, how many SINGLE numbers
                    if (laCheckResult.TotSNDDI__c != null && laCheckResult.TotSNDDI__c > 0) {
                        for (Integer i = 0; i < laCheckResult.TotSNDDI__c.intValue(); i++) {
                            rangeNo++;
                            config.getAttribute('DDI Range ' + rangeNo).setValue('1');
                        }
                    }
                }

                if (laCheckResult.InstType__c != null)
                    config.getAttribute('Installation Type').setValue(''+laCheckResult.InstType__c);
                if (laCheckResult.TotDDI__c != null)
                    config.getAttribute('Number of DDI Ranges').setValue(''+laCheckResult.TotDDIR__c);
                if (laCheckResult.TotMSN__c != null)
                    config.getAttribute('Number of MSNs').setValue(''+laCheckResult.TotMSN__c);
            }
            else if (productName.contains(PROD_ISDN30_ETSI)) {
            	if (laCheckResult.Directory_Number__c != null)
            		config.getAttribute('Existing Telephone Number').setValue(laCheckResult.Directory_Number__c);
                if (laCheckResult.CareLvl__c != null)
                    config.getAttribute('Care Package').setValue('Level '+laCheckResult.CareLvl__c);
                if (laCheckResult.Post_Code__c != null)
                    config.getAttribute('Postcode').setValue(''+laCheckResult.Post_Code__c);

                // The service can have a mixture of DDI Ranges or Single Numbers but only 5 DDI slots
                // NB: This assumes that the order of the 5 DDI lines is irrelevant for the product configuration
                Integer rangeNo = 0;
                if (laCheckResult.TotDDIR__c > 0) {
                    //List<SObject> lineAvailChannelResults = getlaCheckResultChildData(laCheckResult.Id, 'Line_Availability_DDI_Range__c');
                    List<Line_Availability_DDI_Range__c> lineAvailChannelResults = laCheckResult.Line_Availability_DDI_Ranges__r;
                    if (lineAvailChannelResults.size() > 0) {
                        for (SObject obj : lineAvailChannelResults) {
                            rangeNo++;
                            Line_Availability_DDI_Range__c ladr = (Line_Availability_DDI_Range__c) obj;
                            if (laCheckResult.DDI_Ranges__c != null && rangeNo < 6)
                                config.getAttribute('DDI Range ' + rangeNo).setValue(''+ladr.NumDDIs__c);
                        }
                    }
                }

                // Only worth checking for SNDDIs if we haven't filled all the slots
                if (rangeNo < 6) {
                    // The Main Billing Number contains a summary of the number of single number DDIs, we don't need to iterate through the child records
                    //List<SObject> laMainBilling = getlaCheckResultChildData(lineAvailabilitytCheckResult.Id, 'Line_Availability_Main_Billing_Number__c');

                    // In fact, the TotSNDDI on the LineAvailability record tells us all we need to know, how many SINGLE numbers
                    if (laCheckResult.TotSNDDI__c != null && laCheckResult.TotSNDDI__c > 0) {
                        for (Integer i = 0; i < laCheckResult.TotSNDDI__c.intValue(); i++) {
                            rangeNo++;
                            config.getAttribute('DDI Range ' + rangeNo).setValue('1');
                        }
                    }
                }

                if (laCheckResult.InstType__c != null)
                    config.getAttribute('Installation Type').setValue(''+laCheckResult.InstType__c);
                if (laCheckResult.TotDDI__c != null)
                    config.getAttribute('Number of DDI Ranges').setValue(''+laCheckResult.TotDDIR__c);
                if (laCheckResult.BusCont__c != null && laCheckResult.BusCont__c == 'Y')
                    config.getAttribute('Business Continuity Required?').setValue('Yes');

                //Total Bearers & Display Bearers
                if (laCheckResult.Number_Of_Bearers__c != null) {
                    config.getAttribute('Number of Bearers').setValue(''+laCheckResult.Number_Of_Bearers__c);
                    // Display Number of Bearers is a Calculation, so not mapped
                    //config.getAttribute('Display Number of Bearers').setValue(''+laCheckResult.Number_Of_Bearers__c);
                }
                //Total Channels
                if (laCheckResult.Number_Of_Channels__c != null)
                        config.getAttribute('Number of Channels').setValue(''+laCheckResult.Number_Of_Channels__c);

            }
            else if (productName.contains(PROD_ISDN30_DASS)) {
                //newProductConfig.getAttribute('Provide Type').setValue(configRequest.Provide_Type__c);
            }
            else if (productName.contains(PROD_LANDLINE_BOLT_ONS)) {
                //null;
            }
            else if (productName.contains(PROD_BROADBAND)) {
                // Predicted download speed. The results are inconsistent in format but we cater for the most frequent format
                if (laCheckResult.predictedDownloadSpeed__c != null) {
                    Pattern p = Pattern.compile('[a-zA-Z]');
                    String speedConversion = p.matcher(laCheckResult.predictedDownloadSpeed__c).replaceAll('');
                    /* 
                    if (Double.valueOf(speedConversion) > 8)
                        config.getAttribute('Download Speed').setValue('20');
                    else if (Double.valueOf(speedConversion) <= 8)
                        config.getAttribute('Download Speed').setValue('8');
                    */
					Integer speedConversionVal = Double.valueOf(speedConversion).intValue();
                    config.getAttribute('Download Speed').setValue(String.valueOf(speedConversionVal));
                }

                // Predicated upload speed
                /* There is no such attribute in the product definition or lineavailability object */

                // Estimated Line Length
                if (laCheckResult.lineLengthEstimate__c != null)
                    config.getAttribute('Line Length').setValue(''+laCheckResult.lineLengthEstimate__c);

                // DN
                if (laCheckResult.Directory_Number__c != null)
                config.getAttribute('Landline Number').setValue(laCheckResult.Directory_Number__c);

                // Postcode
                if (laCheckResult.Post_Code__c != null)
                    config.getAttribute('Install Postcode').setValue(''+laCheckResult.Post_Code__c);
            }
            else {
                System.debug('Error: No such product mapping for product name '+productName);
            }

            return config;
        }


         //##########################################################################################
         //# Revised overload of old method that does NOT INCLUDE PROVIDE_TYPE
         //#
         public static cscfgc__Product_Configuration__c populateConfiguration(Id configId, String laId)
         {
         	return populateConfiguration(configId,laId, null);
         }


        /* This method uses offers to create product configs and its attributes. Now used in Product Bundle Builder Controller */
         public static cscfgc__Product_Configuration__c populateConfiguration(Id configId, String laId,string provideType) {

        Map<String, cscfgc__Attribute__c> attributeMap = new Map<String, cscfgc__Attribute__c>();
        cscfgc__Product_Configuration__c config = [Select c.Name, c.Id, (Select Name, cscfgc__Value__c From cscfgc__Attributes__r) From cscfgc__Product_Configuration__c c where Id = :configId];

        List<cscfgc__Attribute__c> attribute = config.cscfgc__Attributes__r;
        for(cscfgc__Attribute__c attr : attribute){
            attributeMap.put(attr.Name, attr);

        }
        String productName = config.Name;

        System.Debug(logginglevel.info,'################ O2 Order Builder Populate Configuration - Product Name is:' + productName);


        Line_Availability__c laCheckResult = new Line_Availability__c();
        if (laId != null)
            laCheckResult = getlaCheckResults(laId);

		System.debug(LoggingLevel.info,'###### @@@RAC:  laId='+laId+' laCheckResult='+(laCheckResult != null));

        // Get the line type and product type mappings
        Map <String,Line_Type_Map__c> lineTypeMap = new Map <String,Line_Type_Map__c>();
        List<Line_Type_Map__c> lineTypeMapList;
        lineTypeMapList = Line_Type_Map__c.getall().values();
        for(Line_Type_Map__c lTMap: lineTypeMapList) {
            lineTypeMap.put(lTMap.Name, lTMap);
        }

        // Based on product type populate the configuration but check the line check was successful
        if (laCheckResult != null)
System.debug('@@@RAC:  Setting values based on line check results');
            if (productName.contains(PROD_LANDLINE)) {
                //config.getAttribute('Existing Telephone Number').setValue(laCheckResult.Directory_Number__c);
                if(attributeMap.containskey('Existing Telephone Number'))
                    attributeMap.get('Existing Telephone Number').cscfgc__Value__c = laCheckResult.Directory_Number__c;

                if (laCheckResult.Service_Type__c != null && lineTypeMap.containsKey(laCheckResult.Service_Type__c)) {
                    //config.getAttribute('Line Type').setValue(''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Line_Type_Value__c);
                    if(attributeMap.containskey('Line Type'))
                        attributeMap.get('Line Type').cscfgc__Value__c = ''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Line_Type_Value__c;

                }
                if (laCheckResult.CareLvl__c != null){
                    //config.getAttribute('Care Package').setValue('Level '+laCheckResult.CareLvl__c);
                    if(attributeMap.containskey('Care Package'))
                        attributeMap.get('Care Package').cscfgc__Value__c = 'Level '+laCheckResult.CareLvl__c;

                }
                if (laCheckResult.Number_Of_Lines__c != null){
                    //config.getAttribute('Number of Lines').setValue(''+laCheckResult.Number_Of_Lines__c);
                    if(attributeMap.containskey('Number of Lines'))
                        attributeMap.get('Number of Lines').cscfgc__Value__c = ''+laCheckResult.Number_Of_Lines__c;
                }
                if (laCheckResult.Post_Code__c != null){
                    //config.getAttribute('Postcode').setValue(''+laCheckResult.Post_Code__c);
                    if(attributeMap.containskey('Postcode'))
                        attributeMap.get('Postcode').cscfgc__Value__c = ''+laCheckResult.Post_Code__c;

                }
                if (laCheckResult.TermType__c != null){
                    //config.getAttribute('Termination Type').setValue(''+laCheckResult.TermType__c);
                    if(attributeMap.containskey('Termination Type'))
                        attributeMap.get('Termination Type').cscfgc__Value__c = ''+laCheckResult.TermType__c;
                }
                if (laCheckResult.InstType__c != null){
                    //config.getAttribute('Installation Type').setValue(''+laCheckResult.InstType__c);
                    if(attributeMap.containskey('Installation Type'))
                        attributeMap.get('Installation Type').cscfgc__Value__c = ''+laCheckResult.InstType__c;
                }
System.debug('@@@RAC:  Landline values set: DN='+laCheckResult.Directory_Number__c);

            }
            else if (productName.contains(PROD_CALLS_ONLY)) {
                //config.getAttribute('Line Number').setValue(laCheckResult.Directory_Number__c);
                if(attributeMap.containskey('Line Number'))
                        attributeMap.get('Line Number').cscfgc__Value__c = laCheckResult.Directory_Number__c;

                if (laCheckResult.Service_Type__c != null && lineTypeMap.containsKey(laCheckResult.Service_Type__c)) {
                    //config.getAttribute('Primary Product Type').setValue(''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Product_Type_Value__c);
                    //config.getAttribute('Line Type').setValue(''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Line_Type_Value__c);

                    if(attributeMap.containskey('Primary Product Type'))
                        attributeMap.get('Primary Product Type').cscfgc__Value__c = ''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Product_Type_Value__c;

                    if(attributeMap.containskey('Line Type'))
                        attributeMap.get('Line Type').cscfgc__Value__c = ''+lineTypeMap.get(laCheckResult.Service_Type__c).Configurator_Line_Type_Value__c;
                }
                if (laCheckResult.CareLvl__c != null){
                    //config.getAttribute('Care Package').setValue('Level '+laCheckResult.CareLvl__c);
                    if(attributeMap.containskey('Care Package'))
                        attributeMap.get('Care Package').cscfgc__Value__c = 'Level '+laCheckResult.CareLvl__c;
                }
                if (laCheckResult.Number_Of_Lines__c != null){
                    //config.getAttribute('Number of Lines').setValue(''+laCheckResult.Number_Of_Lines__c);
                    if(attributeMap.containskey('Number of Lines'))
                        attributeMap.get('Number of Lines').cscfgc__Value__c = ''+laCheckResult.Number_Of_Lines__c;
                }
                if (laCheckResult.Post_Code__c != null){
                    //config.getAttribute('Postcode').setValue(''+laCheckResult.Post_Code__c);
                    if(attributeMap.containskey('Postcode'))
                        attributeMap.get('Postcode').cscfgc__Value__c = ''+laCheckResult.Post_Code__c;
                }
                if (laCheckResult.Carrier_Pre_Select__c != null){
                    //config.getAttribute('CPS Present').setValue(''+laCheckResult.Carrier_Pre_Select__c);
                    if(attributeMap.containskey('CPS Present'))
                        attributeMap.get('CPS Present').cscfgc__Value__c = ''+laCheckResult.Carrier_Pre_Select__c;
                }
                if (laCheckResult.Directory_Number__c != null){
                    //config.getAttribute('Line Number').setValue(''+laCheckResult.Directory_Number__c);
                    if(attributeMap.containskey('Line Number'))
                        attributeMap.get('Line Number').cscfgc__Value__c = ''+laCheckResult.Directory_Number__c;
                }
                if (laCheckResult.Number_Of_Channels__c != null){
                    //config.getAttribute('Number of Channels').setValue(''+laCheckResult.Number_Of_Channels__c);
                    if(attributeMap.containskey('Number of Channels'))
                        attributeMap.get('Number of Channels').cscfgc__Value__c = ''+laCheckResult.Number_Of_Channels__c;
                }
            }
            else if (productName.contains(PROD_ISDN2)) {
                //config.getAttribute('Existing Telephone Number').setValue(laCheckResult.Directory_Number__c);
                if(attributeMap.containskey('Existing Telephone Number'))
                    attributeMap.get('Existing Telephone Number').cscfgc__Value__c = laCheckResult.Directory_Number__c;

                if (laCheckResult.CareLvl__c != null){
                    //config.getAttribute('Care Package').setValue('Level '+laCheckResult.CareLvl__c);
                    if(attributeMap.containskey('Care Package'))
                        attributeMap.get('Care Package').cscfgc__Value__c = 'Level '+laCheckResult.CareLvl__c;
                }
                if (laCheckResult.Post_Code__c != null){
                    //config.getAttribute('Postcode').setValue(''+laCheckResult.Post_Code__c);
                    if(attributeMap.containskey('Postcode'))
                        attributeMap.get('Postcode').cscfgc__Value__c = ''+laCheckResult.Post_Code__c;
                }
                if (laCheckResult.TermType__c != null){
                    //config.getAttribute('Termination Type').setValue(''+laCheckResult.TermType__c);
                    if(attributeMap.containskey('Termination Type'))
                        attributeMap.get('Termination Type').cscfgc__Value__c = ''+laCheckResult.TermType__c;
                }

                Integer rangeNo = 0;
                if (laCheckResult.TotDDIR__c > 0) {
                    List<Line_Availability_DDI_Range__c> lineAvailChannelResults = laCheckResult.Line_Availability_DDI_Ranges__r;
                    if (lineAvailChannelResults.size() > 0) {
                        for (SObject obj : lineAvailChannelResults) {
                            rangeNo++;
                            Line_Availability_DDI_Range__c ladr = (Line_Availability_DDI_Range__c) obj;
                            if (laCheckResult.DDI_Ranges__c != null && rangeNo < 6){
                                //config.getAttribute('DDI Range ' + rangeNo).setValue(''+ladr.NumDDIs__c);
                                if(attributeMap.containskey('DDI Range ' + rangeNo))
                                    attributeMap.get('DDI Range ' + rangeNo).cscfgc__Value__c = ''+ladr.NumDDIs__c;
                            }
                        }
                    }
                }

                // Only worth checking for SNDDIs if we haven't filled all the slots
                if (rangeNo < 6) {
                    // The Main Billing Number contains a summary of the number of single number DDIs, we don't need to iterate through the child records
                    // In fact, the TotSNDDI on the LineAvailability record tells us all we need to know, how many SINGLE numbers
                    if (laCheckResult.TotSNDDI__c != null && laCheckResult.TotSNDDI__c > 0) {
                        for (Integer i = 0; i < laCheckResult.TotSNDDI__c.intValue(); i++) {
                            rangeNo++;
                            //config.getAttribute('DDI Range ' + rangeNo).setValue('1');
                            if(attributeMap.containskey('DDI Range ' + rangeNo))
                                    attributeMap.get('DDI Range ' + rangeNo).cscfgc__Value__c = '1';

                        }
                    }
                }

                if (laCheckResult.InstType__c != null){
                    //config.getAttribute('Installation Type').setValue(''+laCheckResult.InstType__c);
                    if(attributeMap.containskey('Installation Type'))
                        attributeMap.get('Installation Type').cscfgc__Value__c = ''+laCheckResult.InstType__c;
                }
                if (laCheckResult.TotDDI__c != null){
                    //config.getAttribute('Number of DDI Ranges').setValue(''+laCheckResult.TotDDIR__c);
                    if(attributeMap.containskey('Number of DDI Ranges'))
                        attributeMap.get('Number of DDI Ranges').cscfgc__Value__c = ''+laCheckResult.TotDDIR__c;
                }
                if (laCheckResult.TotMSN__c != null){
                    //config.getAttribute('Number of MSNs').setValue(''+laCheckResult.TotMSN__c);
                    if(attributeMap.containskey('Number of MSNs'))
                        attributeMap.get('Number of MSNs').cscfgc__Value__c = ''+laCheckResult.TotMSN__c;
                }
            }
            else if (productName.contains(PROD_ISDN30_ETSI)) {
				// FJF - 25012012:
				// Added the Existing phone number to the mappings by request from Ricky
            	if(attributeMap.containskey('Existing Telephone Number'))
                    attributeMap.get('Existing Telephone Number').cscfgc__Value__c = laCheckResult.Directory_Number__c;
                if (laCheckResult.CareLvl__c != null){
                    //config.getAttribute('Care Package').setValue('Level '+laCheckResult.CareLvl__c);
                    if(attributeMap.containskey('Care Package'))
                        attributeMap.get('Care Package').cscfgc__Value__c = 'Level '+laCheckResult.CareLvl__c;
                }
                if (laCheckResult.Post_Code__c != null){
                    //config.getAttribute('Postcode').setValue(''+laCheckResult.Post_Code__c);
                    if(attributeMap.containskey('Postcode'))
                        attributeMap.get('Postcode').cscfgc__Value__c = ''+laCheckResult.Post_Code__c;
                }

                // The service can have a mixture of DDI Ranges or Single Numbers but only 5 DDI slots
                // NB: This assumes that the order of the 5 DDI lines is irrelevant for the product configuration
                Integer rangeNo = 0;
                if (laCheckResult.TotDDIR__c > 0) {
                    //List<SObject> lineAvailChannelResults = getlaCheckResultChildData(laCheckResult.Id, 'Line_Availability_DDI_Range__c');
                    List<Line_Availability_DDI_Range__c> lineAvailChannelResults = laCheckResult.Line_Availability_DDI_Ranges__r;
                    if (lineAvailChannelResults.size() > 0) {
                        for (SObject obj : lineAvailChannelResults) {
                            rangeNo++;
                            Line_Availability_DDI_Range__c ladr = (Line_Availability_DDI_Range__c) obj;
                            if (laCheckResult.DDI_Ranges__c != null && rangeNo < 6){
                                //config.getAttribute('DDI Range ' + rangeNo).setValue(''+ladr.NumDDIs__c);
                                if(attributeMap.containskey('DDI Range ' + rangeNo))
                                    attributeMap.get('DDI Range ' + rangeNo).cscfgc__Value__c = ''+ladr.NumDDIs__c;
                            }
                        }
                    }
                }

                // Only worth checking for SNDDIs if we haven't filled all the slots
                if (rangeNo < 6) {
                    // The Main Billing Number contains a summary of the number of single number DDIs, we don't need to iterate through the child records
                    //List<SObject> laMainBilling = getlaCheckResultChildData(lineAvailabilitytCheckResult.Id, 'Line_Availability_Main_Billing_Number__c');

                    // In fact, the TotSNDDI on the LineAvailability record tells us all we need to know, how many SINGLE numbers
                    if (laCheckResult.TotSNDDI__c != null && laCheckResult.TotSNDDI__c > 0) {
                        for (Integer i = 0; i < laCheckResult.TotSNDDI__c.intValue(); i++) {
                            rangeNo++;
                            //config.getAttribute('DDI Range ' + rangeNo).setValue('1');
                            if(attributeMap.containskey('DDI Range ' + rangeNo))
                                    attributeMap.get('DDI Range ' + rangeNo).cscfgc__Value__c = '1';
                        }
                    }
                }

                if (laCheckResult.InstType__c != null){
                    //config.getAttribute('Installation Type').setValue(''+laCheckResult.InstType__c);
                    if(attributeMap.containskey('Installation Type'))
                        attributeMap.get('Installation Type').cscfgc__Value__c = ''+laCheckResult.InstType__c;
                }
                if (laCheckResult.TotDDI__c != null){
                    //config.getAttribute('Number of DDI Ranges').setValue(''+laCheckResult.TotDDIR__c);
                    if(attributeMap.containskey('Number of DDI Ranges'))
                        attributeMap.get('Number of DDI Ranges').cscfgc__Value__c = ''+laCheckResult.TotDDIR__c;
                }
                if (laCheckResult.BusCont__c != null && laCheckResult.BusCont__c == 'Y'){
                    //config.getAttribute('Business Continuity Required?').setValue('Yes');
                    if(attributeMap.containskey('Business Continuity Required?'))
                        attributeMap.get('Business Continuity Required?').cscfgc__Value__c = 'Yes';
                }

                //Total Bearers & Display Bearers
                if (laCheckResult.Number_Of_Bearers__c != null) {
                    //config.getAttribute('Number of Bearers').setValue(''+laCheckResult.Number_Of_Bearers__c);
                    if(attributeMap.containskey('Number of Bearers'))
                        attributeMap.get('Number of Bearers').cscfgc__Value__c = ''+laCheckResult.Number_Of_Bearers__c;
                    // Display Number of Bearers is a Calculation, so not mapped
                    //config.getAttribute('Display Number of Bearers').setValue(''+laCheckResult.Number_Of_Bearers__c);
                    if(attributeMap.containskey('Display Number of Bearers'))
                        attributeMap.get('Display Number of Bearers').cscfgc__Value__c = ''+laCheckResult.Number_Of_Bearers__c;

                }
                //Total Channels
                if (laCheckResult.Number_Of_Channels__c != null){
                        //config.getAttribute('Number of Channels').setValue(''+laCheckResult.Number_Of_Channels__c);
                        if(attributeMap.containskey('Number of Channels'))
                            attributeMap.get('Number of Channels').cscfgc__Value__c = ''+laCheckResult.Number_Of_Channels__c;
                }
            }
            else if (productName.contains(PROD_ISDN30_DASS)) {
                //newProductConfig.getAttribute('Provide Type').setValue(configRequest.Provide_Type__c);
            }
            else if (productName.contains(PROD_BOLT_ONS)) {
                //null;
            }
            else if (productName.contains(TELEMARKETING)) {
                //null;
            }
            else if (productName.contains(BUSINESS_BROADBAND)) {


                System.Debug(logginglevel.info,'################ WE ARE BUILDING BROADBAND WITH: ' + laCheckResult);


                // Predicted download speed. The results are inconsistent in format but we cater for the most frequent format
                if (laCheckResult.predictedDownloadSpeed__c != null && attributeMap.containsKey('Download Speed')) {
                    Pattern p = Pattern.compile('[a-zA-Z]');
                    String speedConversion = p.matcher(laCheckResult.predictedDownloadSpeed__c).replaceAll('');
                    if (Double.valueOf(speedConversion) > 8)
                        attributeMap.get('Download Speed').cscfgc__Value__c = '20';
                    else if (Double.valueOf(speedConversion) <= 8)
                        attributeMap.get('Download Speed').cscfgc__Value__c = '8';

                }

                // Predicated upload speed
                /* There is no such attribute in the product definition or lineavailability object */

                // Estimated Line Length
                if (laCheckResult.lineLengthEstimate__c != null && attributeMap.containsKey('Line Length'))
                    attributeMap.get('Line Length').cscfgc__Value__c = ''+laCheckResult.lineLengthEstimate__c;

                // DN
                if (laCheckResult.Directory_Number__c != null && attributeMap.containsKey('Landline Number'))
                attributeMap.get('Landline Number').cscfgc__Value__c = laCheckResult.Directory_Number__c;

                // Postcode
                if (laCheckResult.Post_Code__c != null && attributeMap.containsKey('Install Postcode'))
                    attributeMap.get('Install Postcode').cscfgc__Value__c = ''+laCheckResult.Post_Code__c;
            }
            else if (productName.contains(MOBILE_BROADBAND)) {
                //null
            }
            else if (productName.contains(BUSINESS_SINGLE_TARIFF) || productName.contains(BUSINESS_SHARER_TARIFF)) {
                //null;
            }
            else if (productName.contains(BE_BROADBAND)) {
                //null;
            }
            else if (productName.contains(BOOSTBOX)) {
                //null;
            }
            else {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The chosen product definition does not exist in the configurator'));
                return config;
            }



            //################################## TACTICAL CHANGE - CHANGE THE DEFINITION #########################
            //# Finally, massage some Online related Attributes that are mandatory, but set off by a rule.
            //# These should be sorted by Execute rules, but it is not the case, so we can put them in here for now
            //#
            //# The product definition should be changed, and the Execute Rules method on the cfgr API
            //# should be fixed to execute these rules correctly. However, to get through this short sprint
            //# we can manually set the values here.
            //#
            if(attributeMap.containskey('Date Validation'))
            	attributeMap.get('Date Validation').cscfgc__Value__c = 'Yes';
            if(attributeMap.containskey('Online On-Site Contact First Name'))
            	attributeMap.get('Online On-Site Contact First Name').cscfgc__Value__c = 'NA';
            if(attributeMap.containskey('Online On-Site Contact Last Name'))
            	attributeMap.get('Online On-Site Contact Last Name').cscfgc__Value__c = 'NA';
            if(attributeMap.containskey('Online On-Site Contact Telephone Number'))
            	attributeMap.get('Online On-Site Contact Telephone Number').cscfgc__Value__c = 'NA';
            //#
            //#
            //################################# END TACTICAL CHANGE ###############################################


			//# PROVIDE TYPE PASSED IN VIA NEW PARAM ?
			if (provideType != null && attributeMap.containskey('Provide Type'))
            	attributeMap.get('Provide Type').cscfgc__Value__c = provideType;



            if(!attributeMap.isEmpty()){
                List<cscfgc__Attribute__c> attrList = attributeMap.values();
                update attrList;
            }

            return config;
        }



    // Create a product bundle object from a basket and link the configuration items
    public static cscfgc__Product_Bundle__c createBundle(Id oppId, cscfgc__Product_Basket__c basket) {

        // Create a new Bundle for this Opportunity Id
        cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();
        Datetime d = system.now();
        String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');
        bundle.Name = 'Order ' + strDatetime;

        bundle.cscfgc__Opportunity__c = oppId;
        //bundle.cscfgc__Bundle_Status__c = basket.cscfgc__Basket_Status__c;
        //bundle.cscfgc__Total_Price__c = basket.cscfgc__Total_Price__c;

        insert bundle;

        // Retrieve the configurations for the basket
        List<cscfgc__Product_Configuration__c> configs = [SELECT Id, cscfgc__Product_Bundle__c, cscfgc__Screen_Flow__c
                                                          FROM cscfgc__Product_Configuration__c
                                                          WHERE cscfgc__Product_Basket__c = :basket.Id];

        // @TODO: If we don't get any results raise a Custom Exception

        // Update the configurations for the basket
        for (cscfgc__Product_Configuration__c pc : configs) {
            pc.cscfgc__Product_Bundle__c = bundle.id;
            pc.cscfgc__Screen_Flow__c = null;
        }
        update configs;
		system.debug('configs: '+configs);

        return bundle;
    }


    // Create a new Opportunity and Product Bundle from a Basket
    // Pre-requisites: An Account and Contact must have been created or existing value defined
    public static cscfgc__Product_Bundle__c createOpportunityBundle(Id contactId, Account acc, cscfgc__Product_Basket__c basket, Map<String, String> flds) {
        SavePoint sp = Database.setSavePoint();
        cscfgc__Product_Bundle__c bundle;
        try {
            System.debug('### OUTPUT >>>>> createOpportunityBundle: flds: '+flds);
            String strRecTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' AND Name='Configurator' LIMIT 1].Id;
            Opportunity opp = new Opportunity();

            // Set the mandatory fields
            String strDatetime = system.now().format('yyyy-MM-dd HH:mm:ss');
            if (flds.containsKey('leadSource') && flds.get('leadSource')=='O2 Retail') {
            	opp.Name = 'Retail Order: ' + acc.Name + ' ' + strDateTime;
            	opp.LeadSource = 'O2 Retail';
            	if (flds.containsKey('opptyType') && flds.get('opptyType')!=null) opp.Type = flds.get('opptyType');
            }
            else opp.Name = 'Online Order: ' + acc.Name + ' ' + strDateTime;
            opp.AccountId = acc.Id;
            if (strRecTypeId!=null) opp.RecordTypeId = strRecTypeId;
            opp.CloseDate = System.today();
            opp.StageName = 'Assessment of Alternatives';   //@TODO - This should be a configuration
            //SW CDECISIONS 20/12/2011 - changed above line stageName from 'Awareness of Needs' since validation rule fails mandating number of employees on account
            // We may have some rules to apply about the owner later
            //opp.Owner = custom setting for default Opp Owner ?
            //SW 21-07-2011 - ADDED Payment details field setting
            if (flds.containsKey('bankBuildingSociety') && flds.get('bankBuildingSociety')!=null) opp.Bank_or_Building_Society__c = flds.get('bankBuildingSociety');
            if (flds.containsKey('bankAccountName') && flds.get('bankAccountName')!=null) opp.Bank_Account_Name__c = flds.get('bankAccountName');
            if (flds.containsKey('bankSortCode') && flds.get('bankSortCode')!=null) opp.Bank_Sort_Code__c = flds.get('bankSortCode');
            if (flds.containsKey('bankAccountNumber') && flds.get('bankAccountNumber')!=null) opp.Bank_Account_Number__c = flds.get('bankAccountNumber');
            if (flds.containsKey('confirmDetails') && flds.get('confirmDetails')!=null) opp.Account_Details_Confirmed__c = flds.get('confirmDetails').equals('true');
            if (flds.containsKey('agreeTerms') && flds.get('agreeTerms')!=null) opp.Terms_and_Conditions_Agreement__c = flds.get('agreeTerms').equals('true');
            if (flds.containsKey('ConfirmationEmailAddr') && flds.get('ConfirmationEmailAddr')!=null) opp.Confirmation_Email_Address__c = flds.get('ConfirmationEmailAddr');

            //KK 10/10/2012 - added for retail upgrade
            if(flds.containsKey('IMEInumber') && flds.get('IMEINumber')!=null) opp.IMEI_number__c = flds.get('IMEInumber');
            if(flds.containsKey('SIMnumber') && flds.get('SIMnumber')!=null) opp.SIM_number__c = flds.get('SIMnumber');
            if(flds.containsKey('SIMswap') && flds.get('SIMswap')!=null) opp.SIM_Swap__c = flds.get('SIMswap').equals('true');
            if(flds.containsKey('OwnerId') && flds.get('OwnerId')!=null) opp.OwnerId = (Id) flds.get('OwnerId');
            system.debug('### OUTPUT >>>>> createOpportunityBundle: opp before insert: '+opp);

            insert opp;

			system.debug('### OUTPUT >>>>> createOpportunityBundle: opp after insert: '+opp);
            system.debug('###currentuser: ' + UserInfo.getUserId());

            //update basket with opportunity id
            if (opp.id!=null) basket.cscfgc__Opportunity__c = opp.id;
            update basket;
            //create the bundle from the basket
            bundle = createBundle(opp.Id, basket);
            bundle.Name = 'Bundle for '+ acc.Name + ' order';
            //create contact roles
            addContactRoles(opp.Id, contactId);
            // Synchronise the Product Bundle with the Opportunity
            // RC 04/11/2011: Make this conditional on a boolean parameter - we should only synch valid bundles
            if (bundle.cscfgc__Bundle_Status__c == 'Valid') synchBundleWithOpportunity(bundle);


            //Create the Configuration Request records to allow the config to be amended internally - if needed
            //ISSUE: This does not retain the results of the line checks
            ConfigurationRequestUtils.createConfigurationRequest(bundle.id);

            // Update the Opportunity to create the Order
            opp.StageName = 'Decision';
            update opp;
        }
        catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));system.debug('###PLACE ORDER: '+e.getMessage());Database.rollback(sp);}
        return bundle;
    }

    // Create default Contact Roles for the Opportunity based on the
    public static void addContactRoles(Id oppId, Id contactId) {
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();

        // Create a primary billing contact
        OpportunityContactRole ocrBill = new OpportunityContactRole();
        ocrBill.OpportunityId = oppId;
        ocrBill.ContactId = contactId;
        ocrBill.IsPrimary = true;
        ocrBill.Role = 'Billing';
        ocrList.add(ocrBill);

        // Also create a Centre of Power contact
        OpportunityContactRole ocrCop = new OpportunityContactRole();
        ocrCop.OpportunityId = oppId;
        ocrCop.ContactId = contactId;
        ocrCop.IsPrimary = false;
        ocrCop.Role = 'Centre of Power';
        ocrList.add(ocrCop);

        insert ocrList;
    }

    /* RAC - The following has been taken from ProductBundleController - once working it should be incorporated back into the controller */

    public static void synchBundleWithOpportunity(cscfgc__Product_Bundle__c bundle) {

        String pricebookId = bundle.cscfgc__opportunity__r.pricebook2Id;

        if (pricebookId == null) {
            Opportunity opp = [select pricebook2Id from Opportunity where id=:bundle.cscfgc__opportunity__c];
            Pricebook2 standardPricebook = [select id from Pricebook2 where isStandard=true];
            opp.pricebook2Id = standardPricebook.id;
            pricebookId = standardPricebook.id;
            update opp;
        }

        //
        List<cscfgc__Attribute__c> lineItems = getAllLineItems(bundle);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Map<String,OpportunityLineItem> oliMap = new Map<String,OpportunityLineItem>();
        //
        Map<String,PricebookEntry> pricebookEntryMap = getPriceBookEntryMap(lineItems, pricebookId, bundle);

        //
        for (Integer i = lineItems.size() - 1; i >= 0; i--) {
            cscfgc__Attribute__c item = lineItems.get(i);
            if (item.cscfgc__Price__c == null) continue;
            //
            if (item.cscfgc__line_item_description__c == null) continue;
            PricebookEntry pbe = pricebookEntryMap.get(item.cscfgc__line_item_description__c);

            Decimal price = item.cscfgc__Price__c;
            if (price != null) price = Math.round(price*100)/100.0;
            //
            OpportunityLineItem oli = new OpportunityLineItem();
            //
            oli = new OpportunityLineItem(
                    opportunityId = bundle.cscfgc__opportunity__c,
                    pricebookentryId = pbe.id,
                    quantity = 1,
                    description = item.cscfgc__line_item_description__c,
                    cscfgc__attribute__c = item.id,
                    MRR__C = 0.0,
                    NRR__C = 0.0);
            //
            // Check if this line item is the recurring one
            if (item.cscfgc__Recurring__c) {
                if (oli.MRR__c == null) {
                    oli.MRR__c = price;
                } else {
                    oli.MRR__c += price;
                }
            } else {
                if (oli.NRR__c == null) {
                    oli.NRR__c = price;
                } else {
                    oli.NRR__c += price;
                }
            }
            oli.TotalPrice = oli.NRR__c + oli.MRR__c;
            //
            oliList.add(oli);
        }
        //
        cscfgc__Product_Bundle__c[] otherBundles = [select Id
                                            From cscfgc__Product_Bundle__c
                                            Where cscfgc__Synchronised_with_Opportunity__c = true
                                            And cscfgc__Opportunity__c = :bundle.cscfgc__Opportunity__c
                                            ];
        for (cscfgc__Product_Bundle__c b: otherBundles) b.cscfgc__Synchronised_with_Opportunity__c = false;
        update otherBundles;

        bundle.cscfgc__Synchronised_with_Opportunity__c = true;
        update bundle;

        List<OpportunityLineItem> existingOlis = [select id from OpportunityLineItem where opportunityid = :bundle.cscfgc__opportunity__c];
        delete existingOlis;
        insert oliList;
        /*  THIS NEEDS TO STAY IN THE PRODUCTBUNDLECONTROLLER
        //
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The product bundle line items were successfully synchronised with the opportunity.'));
        //
        PageReference p = new PageReference('/' + bundle.cscfgc__opportunity__c);
        p.setRedirect(true);
        //
        return p;
        */
    }

    // -----------
    // Get a Map of configurations and all their attributes
    public static Map<ID,cscfgc__Product_Configuration__c> getProductConfigurationMap(String productBundleId) {
        //
        // ---------
        // Get a Map of all bundle Configs
        Map<ID,cscfgc__Product_Configuration__c> prodConfigMap = new Map<Id,cscfgc__Product_Configuration__c>(
                                                    [select Id, Name, cscfgc__Parent_Configuration__c, cscfgc__Product_Bundle__c,
                                                     cscfgc__Product_Definition__r.Name, cscfgc__Product_Basket__c, cscfgc__Product_Definition__c,
                                                     (select Id, cscfgc__Attribute_Definition__r.cscfgc__Type__c, cscfgc__Attribute_Definition__r.Name,
                                                      cscfgc__is_Line_Item__c, cscfgc__Attribute_Definition__r.cscfgc__output_mapping__c, cscfgc__Recurring__c,
                                                      cscfgc__Line_Item_Description__c, cscfgc__Line_Item_Sequence__c, cscfgc__Price__c, cscfgc__Value__c,
                                                      cscfgc__Display_Value__c, cscfgc__Product_Configuration__c, cscfgc__Attribute_Definition__r.cscfgc__cascade_value__c
                                                      from cscfgc__Attributes__r
                                                      order by cscfgc__Line_Item_Sequence__c) from cscfgc__Product_Configuration__c
                                                      where cscfgc__Product_bundle__c = :productBundleId]);
        return prodConfigMap;
    }

    static Map<String,PricebookEntry> getPriceBookEntryMap(List<cscfgc__Attribute__c> itemList, String pricebookId, cscfgc__Product_Bundle__c bundle) {
        Set<String> itemProductNameSet = new Set<String>();
        for (cscfgc__Attribute__c item : itemList) {
            // Get a set of unique line item product Names
            if (item.cscfgc__line_item_description__c != null)
                itemProductNameSet.add(item.cscfgc__line_item_description__c);
        }
        system.debug('********--->itemProductNameSet:'+itemProductNameSet);
        //
        // Get the price book entries for the products that already exist in the catalogue
        List<Product2> productList = [select id, name, productCode, description, isActive, family,
                                            (select id from pricebookentries where pricebook2id=:pricebookId)
                                      from Product2
                                      where name in :itemProductNameSet
                                        and isActive = true
                                    ];
        // Get a Map of the found products keyed by name
        Map<String,Product2> productMap = new Map<String,Product2>();
        Map<String,PricebookEntry> pricebookEntryMap = new Map<String,PricebookEntry>();
        for (Product2 product : productList) {
            if (!product.pricebookentries.isEmpty()) {
                productMap.put(product.Name,product);
                pricebookEntryMap.put(product.Name,product.pricebookentries[0]);
            }
        }
        // Get a list of the names that did not match
        List<String> productToBeCreatedList = new List<String>();
        for (String name : itemProductNameSet) {
            if (!productMap.containsKey(name)) {
                productToBeCreatedList.add(name);
            }
        }
        // Loop through all the products requiring creation and create them
        List<Product2> newProductList = new List<Product2>();
        for (String name : productToBeCreatedList) {
            newProductList.add(new Product2(name = name, //item.getDescription(),
                                            productCode = '',
                                            description = '',
                                            //family = '',
                                            isActive = true));
        }
        insert newProductList;
        system.debug('********--->productList:'+productList);
        // Get a map of the newly inserted products keyed by Id
        Map<String,Product2> newProductMap = new Map<String,Product2>();
        for (Product2 product : newProductList) {
            newProductMap.put(product.id,product);
        }
        // Get standard price book id
        Pricebook2 standardPricebook = [select id from Pricebook2 where isStandard=true];
        //
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        for (Product2 product : newProductList) {
            PricebookEntry entry = new PricebookEntry(
                pricebook2id = pricebookId,
                product2Id = product.id,
                unitPrice = 0,
                isActive = true,
                useStandardPrice = false
            );
            priceBookEntryList.add(entry);
        }
        insert priceBookEntryList;
        //
        for (PricebookEntry entry : priceBookEntryList) {
            pricebookEntryMap.put(newProductMap.get(entry.product2Id).Name,entry);
        }
        //
        return pricebookEntryMap;
    }

/*
    static Result findPricebookEntryForLineItem(cscfgc.LineItem item, String pricebookId, cscfgc__Product_Bundle__c bundle) {

        //List<Product2> products = getPricebookEntriesForProductNameAndPricebookId(item.getDescription(), pricebookId);
        List<Product2> products = getPricebookEntriesForProductNameAndPricebookId(item.getDescription(), //getConfiguration().getSObject().cscfgc__Product_Definition__r.Name,
                                                                                  pricebookId);
        if (products.size() == 0) return Result.failure('No active products found with name ' + item.getName());
        if (products.get(0).pricebookentries.size() == 0) return Result.success(createPricebookEntriesForProduct((Product2)products.get(0), pricebookId, bundle));

        return Result.success(products.get(0).pricebookentries.get(0));
    }
*/
    static List<Product2> getPricebookEntriesForProductNameAndPricebookId(String productName, String pricebookId) {
        return [
            select  id,
                    name,
                    productCode,
                    description,
                    isActive,
                    family,
                    (select id
                            from pricebookentries
                            where pricebook2id=:pricebookId)
                    from Product2
                    where   name = :productName
                            and isActive = true
        ];
    }

    static PricebookEntry createProductAndPricebookEntryForLineItem(cscfgc.LineItem item, String pricebookId, cscfgc__Product_Bundle__c bundle) {

        Product2 product = new Product2(
                name = item.getDescription(), //getConfiguration().getSObject().cscfgc__Product_Definition__r.Name,
                productCode = '',
                description = '',
                family = item.getAttribute().cscfgc__attribute_definition__r.cscfgc__product_definition__r.name,
                isActive = true
        );

        insert product;

        return createPricebookEntriesForProduct(product, pricebookId, bundle);
    }

    /**
     * Creates an entry in the Standard pricebook for the supplied product if none exists already, then
     * creates an entry in the specified pricebook.
     */
    static PricebookEntry createPricebookEntriesForProduct(Product2 product, String pricebookId, cscfgc__Product_Bundle__c bundle) {

        Pricebook2 standardPricebook = [select id from Pricebook2 where isStandard=true];
        if (pricebookId != standardPricebook.id) {
            List<Product2> products = getPricebookEntriesForProductNameAndPricebookId(product.name, standardPricebook.id);
            if (products.get(0).pricebookentries.size() == 0) createPricebookEntryForProduct(product, standardPricebook.id, bundle);
        }

        return createPriceBookEntryForProduct(product, pricebookId, bundle);

    }


    static PricebookEntry createPricebookEntryForProduct(Product2 product, String pricebookId, cscfgc__Product_Bundle__c bundle) {

        system.debug('>>>>>>> Creating PricebookEntry for product: ' + product.name + ', pricebookId: ' + pricebookId);
        PricebookEntry entry = new PricebookEntry(
                pricebook2id = pricebookId,
                product2Id = product.id,
                unitPrice = 0,
                isActive = true,
                useStandardPrice = false
        );

        insert entry;

        return entry;
    }

    // -----------
    // Convert date string to date
    public static Date stringToDate(String s){
        if (s != null) {
          //Date String is in the format dd/mm/yyyy
          String[] stringDate = s.split('/');
          if (stringDate.size() == 3) {
            Integer d =  Integer.valueOf(stringDate[0]);
            Integer m = Integer.valueOf(stringDate[1]);
            Integer y = Integer.valueOf(stringDate[2]);
            // Correct a problem introduced by webcom sending back 2 digit years
            if (y < 2000) y += 2000;
            return date.newInstance(y,m,d);
          } else {
            return null;
          }
        } else {
            return null;
        }
    }

    // NB: RAC - Note change to method signature to pass the bundle rather than reference a member variable
    public static List<cscfgc__Attribute__c> getAllLineItems(cscfgc__Product_Bundle__c bundle) {
        List<cscfgc__Attribute__c> items = new List<cscfgc__Attribute__c>();
        //
        // Get all the config Details
        String queryString = null;
        queryString = 'select cscfgc__product_definition__r.name,'+
                        'cscfgc__product_definition__r.cscfgc__description__c,'+
                        'cscfgc__product_definition__r.cscfgc__name_is_read_only__c,'+
                        'cscfgc__product_definition__r.cscfgc__allow_progress_from_incomplete_screens__c,'+
                        'cscfgc__product_definition__r.cscfgc__opportunity_mapping__c,'+
                        'cscfgc__screen_flow__r.name,'+
                        Utility.getSobjectFields('cscfgc__Product_Configuration__c')+
                     ', (select cscfgc__attribute_definition__r.name, cscfgc__attribute_definition__r.cscfgc__product_definition__r.name, '+
                         Utility.getSobjectFields('cscfgc__Attribute__c')+' from cscfgc__Attributes__r where cscfgc__Is_Line_Item__c = True) '+
            ' from cscfgc__Product_Configuration__c where cscfgc__product_bundle__c = \''+bundle.Id+'\' order by cscfgc__Parent_Configuration__c ';
        system.debug('**queryString'+queryString);
        List<cscfgc__Product_Configuration__c> configList = Database.query(queryString);
        //
        for (cscfgc__Product_Configuration__c config : configList) {
            items.addAll(config.cscfgc__Attributes__r);
        }

        return items;
    }

	//######################################################################################################
	//#
	//# NEW WAY TO POPULATE CONFIG ADDRESS FROM A PAF ADDRESS OBJECT
	//# CPS 23/11/11
	//#
    public static cscfgc.ProductConfiguration populateConfigurationAddress(String productName, cscfgc.ProductConfiguration config, AddressCheckController.Address address)
	{

		//#
		//# LAND LINE MAPPING
		//#
		//if (productName.contains(PROD_LANDLINE))
		//{
			config.getAttribute('Building Name').setValue(address.buildingName);
			config.getAttribute('Building Number').setValue(address.buildingNumber);
			config.getAttribute('Street').setValue(address.street);
			config.getAttribute('Town').setValue(address.postTown);
			config.getAttribute('City').setValue(address.locality);
			config.getAttribute('County').setValue(address.county);
			config.getAttribute('Postcode').setValue(address.postcode);
		//}

		//if (productName.contains(PROD_BROADBAND))
		//{
			config.getAttribute('Install Premise Name').setValue(address.organisation);
			config.getAttribute('Install Building Name').setValue(address.buildingName);
			config.getAttribute('Install Premise Number').setValue(address.buildingNumber);
			config.getAttribute('Install Street').setValue(address.street);
			config.getAttribute('Install City').setValue(address.postTown);
			config.getAttribute('Install County').setValue(address.county);
			//config.getAttribute('Install Country').setValue(address.locality);
			config.getAttribute('Install Postcode').setValue(address.postcode);
		//}

		return config;


	}

	//######################################################################################################
	//#
	//# UPDATE CONFIG ADDRESS IF YOU DON'T
	//#
	public static cscfgc__Product_Configuration__c populateConfigurationAddress(Id configId, AddressCheckController.Address address)
	{
		Map<String, cscfgc__Attribute__c> attributeMap = new Map<String, cscfgc__Attribute__c>();
        cscfgc__Product_Configuration__c config = [Select c.Name, c.Id, c.cscfgc__Product_bundle__c,(Select Name, cscfgc__Value__c From cscfgc__Attributes__r) From cscfgc__Product_Configuration__c c where Id = :configId];

        List<cscfgc__Attribute__c> attribute = config.cscfgc__Attributes__r;
        for(cscfgc__Attribute__c attr : attribute)
            attributeMap.put(attr.Name, attr);

        String productName = config.Name;
		System.Debug(LoggingLevel.info, '################ Populating Product: ' + productName);
		System.Debug(LoggingLevel.info, '################ with attributes: ' + attributeMap.keyset());
		System.Debug(LoggingLevel.info, '################ using address: ' + address);


		//if (productName.contains(PROD_LANDLINE))
		//{
			setAttFromMapIfExists(attributeMap, 'Building Name', address.buildingName);
			setAttFromMapIfExists(attributeMap, 'Building Number', address.buildingNumber);
			setAttFromMapIfExists(attributeMap, 'Street', address.street);
			setAttFromMapIfExists(attributeMap, 'Town',address.postTown);
			setAttFromMapIfExists(attributeMap, 'City',address.locality);
			setAttFromMapIfExists(attributeMap, 'County',address.county);
			setAttFromMapIfExists(attributeMap, 'Postcode',address.postcode);


			/*
			System.debug('####################### Attributes are now: ');
			for (cscfgc__Attribute__c att :attributeMap.values() )
			{
				System.debug('####################### : ' + att.name + ' - ' + att.cscfgc__value__c );
			}
			*/
		//}

		//if (productName.contains(PROD_BROADBAND))
		//{
			setAttFromMapIfExists(attributeMap, 'Install Premise Name', address.organisation);
			setAttFromMapIfExists(attributeMap, 'Install Building Name',address.buildingName);
			setAttFromMapIfExists(attributeMap, 'Install Premise Number',address.buildingNumber);
			setAttFromMapIfExists(attributeMap, 'Install Street',address.street);
			setAttFromMapIfExists(attributeMap, 'Install City',address.postTown);
			setAttFromMapIfExists(attributeMap, 'Install County',address.county);
			//config.getAttribute('Install Country').setValue(address.locality);
			setAttFromMapIfExists(attributeMap, 'Install Postcode',address.postcode);
		//}

		//#
		//# Update the attributes in the DB.
		//#
	    if(!attributeMap.isEmpty())
            update attributeMap.values();

		return config;

	}

	public static void setAttFromMapIfExists(Map<String, cscfgc__Attribute__c> attributeMap, string key, string value)
	{
		if(attributeMap.containskey(key)) attributeMap.get(key).cscfgc__value__c = value;
	}




	static testMethod void testPrivateMethods() {
		// this method is not called by anything so it needs to be tested here
		//PricebookEntry pe = createProductAndPricebookEntryForLineItem(item, pricebookId, bundle);
	}





}