/**
*   Class to support Batch upload of pillars configuration
*    Main assumption is that only one pillar configuration
*       will be created within single batch execution
*   @since   24/10/2012
*   @author  emil.puchalski@cloudsensesolutions.com
*/

global class UnifyBatchConfigUpload implements Database.Batchable<sObject>{

    public class CustomException extends Exception {}

    string query;
    global string productBundle;
    global string batchId;
    global String submittedBy;

    global static integer numberConfCols = 34;

    /**
    *   Batch initializing method
    *   It gets all splitted Excel rows (represented as Unify_Upload_Single_Entity__c entries) related to this specific batch process
    */

    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Product_Bundle__c, Single_Record__c, Batch_Id__c FROM Unify_Upload_Single_Entity__c WHERE Batch_Id__c = \'' + batchId + '\'';
        return Database.getQueryLocator(query);
    }

    /**
    *   Batch execution method
    *   For every excel row (Unify_Upload_Single_Entity__c entry) it runs processPillar method
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Unify_Upload_Single_Entity__c[] toProcess = new Unify_Upload_Single_Entity__c[]{};
        for(Sobject s : scope){
            Unify_Upload_Single_Entity__c c = (Unify_Upload_Single_Entity__c)s;
            toProcess.add(c);
        }
        for(Unify_Upload_Single_Entity__c e1 : toProcess){
            processPillar(e1);
        }
    }

    /**
    *   Batch finalization method
    *   It prepares process summary and triggers UnifyUploadNotification workflow by updating Unify_Notification__c field
    */
    global void finish(Database.BatchableContext BC){
        User u = [SELECT Id, Email, FirstName, LastName FROM User WHERE Id = :submittedBy];
        Unify_Upload_Single_Entity__c[] uploaded = [SELECT Id, Success__c, Product_Bundle__c, Product_Bundle__r.cscfgc__Opportunity__c, Single_Record__c, Batch_Id__c, Processed__c, Error_Log__c FROM Unify_Upload_Single_Entity__c WHERE Batch_Id__c = :batchId];
        Unify_Upload_Single_Entity__c[] errors = new Unify_Upload_Single_Entity__c[]{};
        Id oppId = null;
        for(Unify_Upload_Single_Entity__c u1 : uploaded){
            if(!u1.Success__c){
                errors.add(u1);
            }
            oppId = u1.Product_Bundle__r.cscfgc__Opportunity__c;
        }

        String emailBody = '';

        emailBody += 'Delivered ' + uploaded.size() + ' configurations has been processed.\n';
        emailBody += '\n';
        emailBody += 'Successes: ' + (uploaded.size() - errors.size()) + '\n';
        emailBody += 'Failures:  ' + errors.size() + '\n';
        emailBody += '\n';
        emailBody += '\n';
        if(errors.size() > 0){
            emailBody += 'Error report:';
            emailBody += '\n--------------------------\n';
            for(Unify_Upload_Single_Entity__c e1 : errors){
                emailBody += 'ROW:\n' + e1.Single_Record__c;
                emailBody += '\nERROR:\n' + e1.Error_Log__c + '\n--------------------------\n';
            }
        }

        delete uploaded;
        update new Opportunity(Id = oppId, Confirmation_Email_Address__c = u.email, Unify_Notification_Content__c = emailBody.length() > 32000 ? emailBody.substring(0, 32000) : emailBody, Unify_Notification__c = 'Data Upload Summary', Unify_Product_Bundle_Id__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + productBundle);
    }

    /**
    *   Generic method invoked by every batch execution
    *   It provides common validation for all possible pillars and then splits executions for proper methods
    */
    global static void processPillar(Unify_Upload_Single_Entity__c rec1){
        cscfgc__Product_Bundle__c[] bundle = [SELECT
                                                c.cscfgc__Total_Price__c, c.cscfgc__Synchronised_with_Opportunity__c, c.cscfgc__Shared_Context_Configuration__c,
                                                c.cscfgc__Opportunity__c, c.cscfgc__Bundle_Status__c, c.Unify_Commercial_Approved__c, c.SystemModstamp,
                                                c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById,
                                                c.cscfgc__Opportunity__r.Unify_Solution__c
                                              FROM
                                                cscfgc__Product_Bundle__c c
                                              WHERE
                                                Id = :rec1.Product_Bundle__c];
        String[] oppSolutionsList = bundle[0].cscfgc__Opportunity__r.Unify_Solution__c.split(';', -1);
        Set<string> oppSolutionsSet = new Set<string>();
        for(string s : oppSolutionsList){
            oppSolutionsSet.add(s.trim());
        }
        try{
            if(!rec1.Single_Record__c.contains('\t')){
                saveErrorMessage(rec1,'Incorrect row structure. Column delimiters (TAB) not found.');
                return;
            }
            String[] fieldsVals = rec1.Single_Record__c.split('\t');
            if(fieldsVals.size() != numberConfCols){
                saveErrorMessage(rec1,'Incorrect row structure. Number of columns should equal ' + numberConfCols + ', found: ' + fieldsVals.size());
                return;
            }
            if(isExcelFieldNull(fieldsVals[0])){
                saveErrorMessage(rec1,'Reference to Site element not found.');
                return;
            }

            if(isExcelFieldNull(fieldsVals[4])){
                saveErrorMessage(rec1,'Manadatory Solution / Product value is missing.');
                return;
            }
            if(!UnifyConfig.mSolutions2Name().containsKey(fieldsVals[4].trim())){
                saveErrorMessage(rec1,'Solution / Product value is not supported. Supported ones are: ' + UnifyConfig.mSolutions2Name().keySet());
                return;
            }

            string translatedSolution = UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim());
            if(!oppSolutionsSet.contains(translatedSolution)){
                saveErrorMessage(rec1, 'Opportunity is not supporting this type of solution. Supported ones are: ' + oppSolutionsSet);
                return;
            }

            if(isExcelFieldNull(fieldsVals[6])){
                saveErrorMessage(rec1,'Manadatory Solution pillar value is missing.');
                return;
            }

            if(!UnifyConfig.mPillars2Name().containsKey(fieldsVals[6].trim())){
                saveErrorMessage(rec1,'Used Solution pillar name [' + fieldsVals[6] + ']is not supported. Currently supported values are: ' + UnifyConfig.mPillars2Name().keySet());
                return;
            }

            Unify_Site__c siteRec = new Unify_Site__c();
            try{
                siteRec = prepareSiteObjectBasedOnSiteName(bundle[0].cscfgc__Opportunity__c, fieldsVals[0].trim(), UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()), bundle[0].Id);
            } catch(Exception e){
                saveErrorMessage(rec1,e.getMessage());
                return;
            }

            cscfgc__Product_Definition__c[] prodDef = [Select Id, cscfgc__Product_Category__c, cscfgc__Product_Category__r.Name, Name From cscfgc__Product_Definition__c where cscfgc__Product_Category__r.Name = 'Unify' and Name = :UnifyConfig.mPillars2Name().get(fieldsVals[6].trim())];
            if(prodDef == null || prodDef.size () == 0){
                saveErrorMessage(rec1,'Solution pillar name not been found in SFDC Product Catalog. Please contact with system administrator.');
                return;
            }
            if(isExcelFieldNull(fieldsVals[27])){
                saveErrorMessage(rec1,'Mandatory Quantity value is missing.');
                return;
            }
            try{
                integer i = integer.valueOf(fieldsVals[27]);
            } catch (Exception e){
                saveErrorMessage(rec1,'Delivered Quantity value is not an integer value.');
                return;
            }

            if(fieldsVals[6].trim() == 'Connectivity'){
                createConnectivityPillar(rec1, fieldsVals, siteRec, prodDef[0], bundle[0]);
            } else if(fieldsVals[6].trim() == 'Hardware'){
                createHardwarePillar(rec1, fieldsVals, siteRec, prodDef[0], bundle[0]);
            } else if(fieldsVals[6].trim() == 'Maintenance'){
                createMaintenancePillar(rec1,fieldsVals, siteRec, prodDef[0], bundle[0]);
            } else if(fieldsVals[6].trim() == 'Managed Services'){
                createManagedServicesPillar(rec1,fieldsVals, siteRec, prodDef[0], bundle[0]);
            } else if(fieldsVals[6].trim() == 'Professional Services'){
                createProfessionalServicesPillar(rec1, fieldsVals, siteRec, prodDef[0], bundle[0]);
            } else if(fieldsVals[6].trim() == 'Other/VAS'){
                createOtherPillar(rec1, fieldsVals, siteRec, prodDef[0], bundle[0]);
            }
        } catch (Exception e){
            saveErrorMessage(rec1, 'Unknown problem encountered during pre-processing. Error details: ' + e.getMessage()  + '. Line no: ' + e.getLineNumber());
            return;
        }
    }

    /**
    *   Generic method invoked by other processing methods to save encountered problem
    *   @param  rec1 - passed excel row, representing single pillar configuration for which error message needs to be saved
    *   @param  errorMess - enountered error message that needs to be stored
    */
    global static void saveErrorMessage(Unify_Upload_Single_Entity__c rec1, string errorMess){
        rec1.Processed__c = true;
        rec1.Success__c = false;
        rec1.Error_Log__c = errorMess;
        update rec1;
    }

    /**
    *   Method invoked from common processPillar method
    *   It transform passed Excel row (stored in Unify_Upload_Single_Entity__c) into Hardware Pillar Configuration and saves it
    *   @param  rec1 - passed excel row, representing single hardware pillar configuration which needs to be saved
    *   @param  fieldsVals - splitted content of excel row columns with values to be used within the configuration
    *   @param  siteRec - passed Unify_Site__c record to which configuration needs to be attatched
    *   @param  prodDef - passed Hardware pillar definition which is required for CS Configurator API engine
    *   @param  bundle - passed cscfgc__Product_Bundle__c record in relation to which configuration needs to be created
    */
    global static void createHardwarePillar(Unify_Upload_Single_Entity__c rec1,String[] fieldsVals, Unify_Site__c siteRec, cscfgc__Product_Definition__c prodDef, cscfgc__Product_Bundle__c bundle){
        try{
            cscfgc.API_1.ApiSession apiSession = cscfgc.API_1.getApiSession(prodDef);
            apiSession.setBundle(bundle);
            cscfgc.ProductConfiguration config = apiSession.getRootConfiguration();
            if(config.containsAttribute('Override Rate Card'))
    			config.getAttribute('Override Rate Card').setValue('YES');
            config.getAttribute('A-End').setValue(siteRec.Id);
            config.getAttribute('A-End').setDisplayValue(siteRec.Name);
            string solution = UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim());
            config.getAttribute('Solution').setValue(solution);
            //Check if supplier exists
            string supplier = fieldsVals[5].trim();
            if(!UnifyConfig.setSuppliers().contains(supplier)){
                saveErrorMessage(rec1, 'Used Supplier (' + supplier + ') not found in SFDC.');
                return;
            }
            config.getAttribute('Supplier').setValue(fieldsVals[5].trim());
            config.getAttribute('Comment').setValue(fieldsVals[8].trim());
            config.getAttribute('Quantity').setValue(fieldsVals[27].trim());
            config.getAttribute('Description').setValue(fieldsVals[7].trim());

            //Class
            if(solution == 'MTEL'){
                string subSolution = fieldsVals[4].trim();
                if(subSolution.contains('IPT')){
                    config.getAttribute('Class').setValue('IP Telephony');
                } else if (subSolution.contains('PBX')){
                    config.getAttribute('Class').setValue('PBX');
                }
            }

            //If Unit ARC OPEX is entered
            Decimal arcOpex = 0;
            try{
                arcOpex = UnifyCommonMethods.covertAmount2decimal(fieldsVals[29]);
            } catch (Exception e){ }
            if(arcOpex > 0){
                //config.getAttribute('Unit ARC OPEX').setValue(String.valueOf(arcOpex));
                config.getAttribute('Billing Frequency').setValue('12');
                if(!isExcelFieldNull(fieldsVals[33])){
                    config.getAttribute('Margin ARC').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[33]));
                }
            } else {
                if(!isExcelFieldNull(fieldsVals[28])){
                    Decimal d;
                    try{
                        d = UnifyCommonMethods.covertAmount2decimal(fieldsVals[28]);
                    } catch(Exception e){
                        saveErrorMessage(rec1, 'Incorrect decimal value in column AC: ' + fieldsVals[28]);
                        return;
                    }
                    //config.getAttribute('Unit NRC CAPEX').setValue(String.valueOf(d));
                }
                if(!isExcelFieldNull(fieldsVals[32])){
                    config.getAttribute('Margin NRC').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[32]));
                }
            }

            config.getAttribute('Order Type').setValue(fieldsVals[9].trim());

            if(!isExcelFieldNull(fieldsVals[24])){
                if(!isExcelFieldNull(fieldsVals[25])){
                    Unify_Hardware__c[] hardware = [select Id, Name from Unify_Hardware__c where Opportunity__c = :bundle.cscfgc__Opportunity__c and Name = :fieldsVals[25].trim()];
                    if(hardware == null || hardware.size() == 0){
                        saveErrorMessage(rec1, 'Used Hardware Bundle reference (' + fieldsVals[25].trim() + ') not found in SFDC.');
                        return;
                    } else {
                        config.getAttribute('Hardware Bundle').setValue(hardware[0].Id);
                        config.getAttribute('Hardware Bundle').setDisplayValue(hardware[0].Name);
                    }
                } else {
                    saveErrorMessage(rec1, 'Inconsistent entry found. When column Y is set, then Hardware Bundle (column Z) needs to be pointed.');
                    return;
                }
            } else {
                config.getAttribute('Part Code').setValue(fieldsVals[25].trim());
                config.getAttribute('Part Code Description').setValue(fieldsVals[26].trim());
            }

            apiSession.executeRules();
            apiSession.executeRules();

            List<cscfgc.Attribute> attributes = config.getAttributes();
            for (cscfgc.Attribute attr : attributes) {
                string attName = attr.getName().toLowerCase();
                if(attName.contains('cost') || attName.contains('price') || attName.contains(' rc') || attName.contains(' nrc') || attName.contains(' arc') || attName.contains(' charge')){
                    if (attr.getIsActive() && attr.getValue() != null)
                    {
                        try{
                            Decimal attValue = Decimal.valueOf(attr.getValue());
                            if(attName.contains('total') || attName.contains('opex') || attName.contains('capex')
                            	|| attName.contains('margin') || attName.contains('ecc') || attName.contains('maximum') || attName.contains('minimum'))
                            	attValue = attValue.setScale(2);
                            else
                            	attValue = attValue.setScale(2);
                            attr.setPrice(attValue);
                            attr.setValue(string.valueOf(attValue));
                        } catch (Exception exc) { }
                    }
                }
            }
            apiSession.persistConfiguration(true);
            sobject sconf = apiSession.getConfiguration().getSObject();

            sconf.put('Unify_Site__c',siteRec.Id);
            sconf.put('cscfgc__product_bundle__c', bundle.Id);
            sconf.put('Unify_Solution__c', UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            update sconf;

            String possibleDiseCodes = config.getAttribute('DISE CODE value').getValue();
            String dise2assign = UnifyDiseCodesController.getResultDiseCode(sconf.Id,possibleDiseCodes);
            config.getAttribute('DISE CODE').setValue(dise2assign);
            //set product configuration id parameter - required for DISE calculation for Hardware pillar
            config.getAttribute('Configuration Id').setValue(sconf.Id);
            apiSession.persistConfiguration(true);

            sconf.put('Name',  config.getAttribute('DISE Bill Label').getValue());
            update sconf;

        } catch (Exception e){
            saveErrorMessage(rec1, 'Unknown problem encounter during pillar processing. Error details: ' + e.getMessage() + '. Line no: ' + e.getLineNumber());
            return;
        }
        rec1.Processed__c = true;
        rec1.Success__c = true;
        update rec1;
    }

    /**
    *   Method invoked from common processPillar method
    *   It transform passed Excel row (stored in Unify_Upload_Single_Entity__c) into Connectivity Pillar Configuration and saves it
    *   @param  rec1 - passed excel row, representing single connectivity pillar configuration which needs to be saved
    *   @param  fieldsVals - splitted content of excel row columns with values to be used within the configuration
    *   @param  siteRec - passed Unify_Site__c record to which configuration needs to be attatched
    *   @param  prodDef - passed Connectivity pillar definition which is required for CS Configurator API engine
    *   @param  bundle - passed cscfgc__Product_Bundle__c record in relation to which configuration needs to be created
    */

    global static void createConnectivityPillar(Unify_Upload_Single_Entity__c rec1,String[] fieldsVals, Unify_Site__c siteRec, cscfgc__Product_Definition__c prodDef, cscfgc__Product_Bundle__c bundle){
        try{
            cscfgc.API_1.ApiSession apiSession = cscfgc.API_1.getApiSession(prodDef);
            apiSession.setBundle(bundle);
            cscfgc.ProductConfiguration config = apiSession.getRootConfiguration();
            if(config.containsAttribute('Override Rate Card'))
    			config.getAttribute('Override Rate Card').setValue('YES');
            config.getAttribute('A-End').setValue(siteRec.Id);
            config.getAttribute('A-End').setDisplayValue(siteRec.Name);
            config.getAttribute('Solution').setValue(UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            //Check if supplier exists
            string supplier = fieldsVals[5].trim();
            if(!UnifyConfig.setSuppliers().contains(supplier)){
                saveErrorMessage(rec1, 'Used Supplier (' + supplier + ') not found in SFDC.');
                return;
            }
            config.getAttribute('Supplier').setValue(fieldsVals[5].trim());
            config.getAttribute('Comment').setValue(fieldsVals[8].trim());
            config.getAttribute('Quantity').setValue(fieldsVals[27].trim());
            config.getAttribute('Description').setValue(fieldsVals[7].trim());

            //Hosting Exceptions
            //TODO - Remvoe hardocded
            boolean hostingException = false;
            string partcode = fieldsVals[25].trim().toLowerCase();
            if(fieldsVals[4].trim() == 'Hosting' && (partcode.contains('dedicated') || partcode.contains('shared'))){
                hostingException = true;
                config.getAttribute('Connectivity Options').setValue('Hosting Connectivity Option');
                if(partcode.contains('dedicated')){
                    config.getAttribute('Type').setValue('Dedicated');
                    config.getAttribute('Type Copy').setValue('Dedicated');
                } else {
                    config.getAttribute('Type').setValue('Shared');
                    config.getAttribute('Type Copy').setValue('Shared');
                }
                Unify_Connectivity__c[] hucon = [SELECT
                                                    Id
                                                FROM
                                                    Unify_Connectivity__c
                                                WHERE
                                                    Access_Type__c = :config.getAttribute('Type').getValue() AND
                                                    Billing_Frequency_Shadow__c = '12'];
                if(hucon != null && hucon.size() > 0){
                    config.getAttribute('Connectivity Option').setValue(hucon[0].Id);
                }
            }

            if(!isExcelFieldNull(fieldsVals[13])){
                Unify_Opportunity_Location__c[] bEnd = [select Id, Name, Location__r.Unify_Unique_Site_Name__c from Unify_Opportunity_Location__c where Opportunity__c = :bundle.cscfgc__Opportunity__c and Location__r.Unify_Unique_Site_Name__c = :fieldsVals[13].trim()];
                if(bEnd == null || bEnd.size() == 0){
                    saveErrorMessage(rec1,'ERROR: used site reference [' + fieldsVals[13].trim() + '] does not exist on SFDC side.');
                    return;
                }
                config.getAttribute('B-End').setValue(bEnd[0].Id);
                config.getAttribute('B-End').setDisplayValue(bEnd[0].Name);
            }

            if(isExcelFieldNull(fieldsVals[10]) && !hostingException){
                saveErrorMessage(rec1, '"Access Connectivity Category [K]" column is mandatory for Connectivity pillar!');
                return;
            }

            if(isExcelFieldNull(fieldsVals[25]) && !hostingException){
                saveErrorMessage(rec1, '"Partcode [Z]" column is mandatory for Connectivity pillar!');
                return;
            }

            if(isExcelFieldNull(fieldsVals[26])){
                saveErrorMessage(rec1, '"Description [AA]" column is mandatory for Connectivity pillar!');
                return;
            }

            if(!hostingException){
                Unify_Connectivity__c[] ucon = [Select Name, Resilience__c, Id, Access_Type__c, Access_Speed__c From Unify_Connectivity__c where Resilience__c = :fieldsVals[26].trim() and Access_Type__c = :fieldsVals[10].trim() and Access_Speed__c = :fieldsVals[25].trim()];

                if(ucon == null || ucon.size() == 0){
                    saveErrorMessage(rec1, 'For provided parameters (Access Type, Access Speed and Resilience) no matching Connectivity Option found!');
                    return;
                }
                config.getAttribute('Connectivity Option').setValue(ucon[0].Id);
                config.getAttribute('Connectivity Option').setDisplayValue(ucon[0].Name);
                config.getAttribute('Type').setValue(fieldsVals[10].trim());
                config.getAttribute('Type Copy').setValue(fieldsVals[10].trim());
            }

            config.getAttribute('Order Type').setValue(fieldsVals[9].trim());
            config.getAttribute('EF').setValue(fieldsVals[14].trim());
            config.getAttribute('AF').setValue(fieldsVals[15].trim());
            config.getAttribute('AF2').setValue(fieldsVals[16].trim());
            config.getAttribute('AF3').setValue(fieldsVals[17].trim());
            config.getAttribute('AF4').setValue(fieldsVals[18].trim());

            if(!isExcelFieldNull(fieldsVals[28])){
                Decimal d;
                try{
                    d = UnifyCommonMethods.covertAmount2decimal(fieldsVals[28]);
                } catch(Exception e){
                    saveErrorMessage(rec1, 'Incorrect decimal value in column AC: ' + fieldsVals[28]);
                    return;
                }
                config.getAttribute('Unit NRC CAPEX').setValue(String.valueOf(d));
            }

            if(!isExcelFieldNull(fieldsVals[29])){
                Decimal d;
                try{
                    d = UnifyCommonMethods.covertAmount2decimal(fieldsVals[29]);
                } catch(Exception e){
                    saveErrorMessage(rec1, 'Incorrect decimal value in column AD: ' + fieldsVals[29]);
                    return;
                }
                //delivered values is annual, and in SFDC is monthly; therefore value needs to be divided by 12
                config.getAttribute('Unit ARC OPEX').setValue(String.valueOf(d));
            }

            if(!isExcelFieldNull(fieldsVals[32])){
                config.getAttribute('Margin NRC').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[32]));
            }

            if(!isExcelFieldNull(fieldsVals[33])){
                config.getAttribute('Margin ARC').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[33]));
            }

            apiSession.executeRules();

            //Related configuration (For now only Other)
            string availableOther = '%' + config.getAttribute('Available Other').getValue() + '%';
            boolean relatedFound = false;
            List<cscfgc__Product_Configuration__c> relatedConfigs = [SELECT
                                                                        Id, Name
                                                                     FROM
                                                                        cscfgc__Product_Configuration__c
                                                                     WHERE
                                                                        cscfgc__Product_Definition__r.Name LIKE '%other%' AND
                                                                        Unify_Other_Name__c LIKE :availableOther AND
                                                                        Unify_Site__c = :siteRec.Id];
            if(relatedConfigs.size() > 0){
                config.getAttribute('Related Configuration').setValue(relatedConfigs[0].Id);
                config.getAttribute('Related Configuration').setDisplayValue(relatedConfigs[0].Name);
                config.getAttribute('Related Configuration Name').setValue(relatedConfigs[0].Name);
                relatedFound = true;
            }

            apiSession.executeRules();
            apiSession.executeRules();

            List<cscfgc.Attribute> attributes = config.getAttributes();
            for (cscfgc.Attribute attr : attributes) {
                string attName = attr.getName().toLowerCase();
                if(attName.contains('cost') || attName.contains('price') || attName.contains(' rc') || attName.contains(' nrc') || attName.contains(' arc') || attName.contains(' charge')){
                    if (attr.getIsActive() && attr.getValue() != null)
                    {
                        try{
                            Decimal attValue = Decimal.valueOf(attr.getValue());
                            if(attName.contains('total') || attName.contains('opex') || attName.contains('capex')
                            	|| attName.contains('margin') || attName.contains('ecc') || attName.contains('maximum') || attName.contains('minimum'))
                            	attValue = attValue.setScale(2);
                            else
                            	attValue = attValue.setScale(2);
                            attr.setPrice(attValue);
                            attr.setValue(string.valueOf(attValue));
                        } catch (Exception exc) { }
                    }
                }
            }

            apiSession.persistConfiguration(true);

            //This Product Configuration as a related configuration
            string q = 'SELECT ' + Utility.getSobjectFields('cscfgc__Product_Configuration__c') +
                            ' , (SELECT ' + Utility.getSobjectFields('cscfgc__Attribute__c') + ' FROM cscfgc__Attributes__r WHERE ' +
                            ' Name IN (\'Related Configuration\',\'Related Configuration Name\')) ' +
                            ' FROM cscfgc__Product_Configuration__c WHERE ' +
                            ' cscfgc__Product_Definition__r.Name LIKE \'%other%\' AND ' +
                            ' Unify_Site__c = \'' + siteRec.Id + '\'';
            string otherShadow = config.getAttribute('Other pillar dependency Shadow').getValue();
            relatedConfigs = database.query(q);
            List<cscfgc__Attribute__c> attsForUpdate = new List<cscfgc__Attribute__c>();
            List<cscfgc__Product_Configuration__c> consForUpdate = new List<cscfgc__Product_Configuration__c>();
            for(cscfgc__Product_Configuration__c relatedConfig : relatedConfigs){
                if(!string.isBlank(otherShadow) && otherShadow.contains(relatedConfig.Unify_Other_Name__c)){
                    relatedConfig.cscfgc__Configuration_Status__c = 'Incomplete';
                    consForUpdate.add(relatedConfig);
                    for(cscfgc__Attribute__c att : relatedConfig.cscfgc__Attributes__r){
                        if(att.Name == 'Related Configuration'){
                            att.cscfgc__Value__c = config.getId();
                            att.cscfgc__Display_Value__c = config.getName();
                            attsForUpdate.add(att);
                        }
                        if(att.Name == 'Related Configuration Name'){
                            att.cscfgc__Value__c = config.getName();
                            attsForUpdate.add(att);
                        }
                    }
                }
            }
            if(attsForUpdate.size() > 0)
                update(attsForUpdate);

            if(consForUpdate.size() > 0)
                update(consForUpdate);

            sobject sconf = apiSession.getConfiguration().getSObject();
            sconf.put('Unify_Site__c',siteRec.Id);
            sconf.put('cscfgc__product_bundle__c', bundle.Id);
            sconf.put('Unify_Solution__c', UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            sconf.put('Name',  config.getAttribute('DISE Bill Label').getValue());
            if(relatedFound)
                sconf.put('cscfgc__Configuration_Status__c', 'Incomplete');
            update sconf;
        } catch (Exception e){
            saveErrorMessage(rec1, 'Unknown problem encounter during pillar processing. Error details: ' + e.getMessage() + '. Line no: ' + e.getLineNumber());
            return;
        }
        rec1.Processed__c = true;
        rec1.Success__c = true;
        update rec1;
    }

    /**
    *   Method invoked from common processPillar method
    *   It transform passed Excel row (stored in Unify_Upload_Single_Entity__c) into Maintenance Pillar Configuration and saves it
    *   @param  rec1 - passed excel row, representing single Maintenance pillar configuration which needs to be saved
    *   @param  fieldsVals - splitted content of excel row columns with values to be used within the configuration
    *   @param  siteRec - passed Unify_Site__c record to which configuration needs to be attatched
    *   @param  prodDef - passed Maintenance pillar definition which is required for CS Configurator API engine
    *   @param  bundle - passed cscfgc__Product_Bundle__c record in relation to which configuration needs to be created
    */
    global static void createMaintenancePillar(Unify_Upload_Single_Entity__c rec1,String[] fieldsVals, Unify_Site__c siteRec, cscfgc__Product_Definition__c prodDef, cscfgc__Product_Bundle__c bundle){
        try{
            cscfgc.API_1.ApiSession apiSession = cscfgc.API_1.getApiSession(prodDef);
            apiSession.setBundle(bundle);
            cscfgc.ProductConfiguration config = apiSession.getRootConfiguration();
            if(config.containsAttribute('Override Rate Card'))
    			config.getAttribute('Override Rate Card').setValue('YES');
            config.getAttribute('A-End').setValue(siteRec.Id);
            config.getAttribute('A-End').setDisplayValue(siteRec.Name);
            config.getAttribute('Solution').setValue(UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            //Check if supplier exists
            string supplier = fieldsVals[5].trim();
            if(!UnifyConfig.setSuppliers().contains(supplier)){
                saveErrorMessage(rec1, 'Used Supplier (' + supplier + ') not found in SFDC.');
                return;
            }
            config.getAttribute('Supplier').setValue(fieldsVals[5].trim());
            config.getAttribute('Comment').setValue(fieldsVals[8].trim());
            config.getAttribute('Quantity').setValue(fieldsVals[27].trim());

            //Set<String> avDiseCodes = new Set<String>();
            if(!isExcelFieldNull(fieldsVals[26])){
                Unify_Maintenance__c[] maintConf = [Select u.Type__c, u.Time__c, u.Id, u.DISE_Bill_Label__c, u.Availability__c, u.DISE_CODE__c From Unify_Maintenance__c u where COFAD_Mapping__c = :fieldsVals[26].trim() and Solution__c includes(:UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim())) limit 1];
                if(maintConf.size() > 0){
                    config.getAttribute('Type').setValue(maintConf[0].Type__c);
                    config.getAttribute('Availability').setValue(maintConf[0].Availability__c);
                    config.getAttribute('Time').setValue(maintConf[0].Time__c);
                    //avDiseCodes.addAll(maintConf[0].DISE_CODE__c.split(';'));
                } else {
                    saveErrorMessage(rec1, 'Used Maintenance Description [' + fieldsVals[26].trim() + '] not supported by SFDC.');
                    return;
                }
            }

            if(!isExcelFieldNull(fieldsVals[29])){
                Decimal d;
                try{
                    d = UnifyCommonMethods.covertAmount2decimal(fieldsVals[29]);
                } catch(Exception e){
                    saveErrorMessage(rec1, 'Incorrect decimal value in column AD: ' + fieldsVals[29]);
                    return;
                }
                //delivered values is annual, and in SFDC is monthly; therefore value needs to be divided by 12
                config.getAttribute('Unit ARC OPEX').setValue(String.valueOf(d));
            }

            if(!isExcelFieldNull(fieldsVals[33])){
                config.getAttribute('Margin ARC').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[33]));
            }
            apiSession.executeRules();
            apiSession.executeRules();

            List<cscfgc.Attribute> attributes = config.getAttributes();
            for (cscfgc.Attribute attr : attributes) {
                string attName = attr.getName().toLowerCase();
                if(attName.contains('cost') || attName.contains('price') || attName.contains(' rc') || attName.contains(' nrc') || attName.contains(' arc') || attName.contains(' charge')){
                    if (attr.getIsActive() && attr.getValue() != null)
                    {
                        try{
                            Decimal attValue = Decimal.valueOf(attr.getValue());
                            if(attName.contains('total') || attName.contains('opex') || attName.contains('capex')
                            	|| attName.contains('margin') || attName.contains('ecc') || attName.contains('maximum') || attName.contains('minimum'))
                            	attValue = attValue.setScale(2);
                            else
                            	attValue = attValue.setScale(2);
                            attr.setPrice(attValue);
                            attr.setValue(string.valueOf(attValue));
                        } catch (Exception exc) { }
                    }
                }
            }
            apiSession.persistConfiguration(true);

            sobject sconf = apiSession.getConfiguration().getSObject();

            //set product configuration id parameter - required for DISE calculation for Maintenance pillar

            sconf.put('Unify_Site__c',siteRec.Id);
            sconf.put('cscfgc__product_bundle__c', bundle.Id);
            sconf.put('Unify_Solution__c', UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            update sconf;

            String possibleDiseCodes = config.getAttribute('DISE CODE value').getValue();
            String dise2assign = UnifyDiseCodesController.getResultDiseCode(sconf.Id,possibleDiseCodes);
            config.getAttribute('DISE CODE').setValue(dise2assign);
            config.getAttribute('Configuration Id').setValue(sconf.Id);
            apiSession.persistConfiguration(true);

            sconf.put('Name',  config.getAttribute('DISE Bill Label').getValue());
            update sconf;
        } catch (Exception e){
            saveErrorMessage(rec1, 'Unknown problem encounter during pillar processing. Error details: ' + e.getMessage() + '. Line no: ' + e.getLineNumber());
            return;
        }
        rec1.Processed__c = true;
        rec1.Success__c = true;
        update rec1;
    }

    /**
    *   Method invoked from common processPillar method
    *   It transform passed Excel row (stored in Unify_Upload_Single_Entity__c) into Managed Services Pillar Configuration and saves it
    *   @param  rec1 - passed excel row, representing single Managed Services pillar configuration which needs to be saved
    *   @param  fieldsVals - splitted content of excel row columns with values to be used within the configuration
    *   @param  siteRec - passed Unify_Site__c record to which configuration needs to be attatched
    *   @param  prodDef - passed Managed Services pillar definition which is required for CS Configurator API engine
    *   @param  bundle - passed cscfgc__Product_Bundle__c record in relation to which configuration needs to be created
    */
    global static void createManagedServicesPillar(Unify_Upload_Single_Entity__c rec1,String[] fieldsVals, Unify_Site__c siteRec, cscfgc__Product_Definition__c prodDef, cscfgc__Product_Bundle__c bundle){
        try{
            cscfgc.API_1.ApiSession apiSession = cscfgc.API_1.getApiSession(prodDef);
            apiSession.setBundle(bundle);
            cscfgc.ProductConfiguration config = apiSession.getRootConfiguration();
            if(config.containsAttribute('Override Rate Card'))
    			config.getAttribute('Override Rate Card').setValue('YES');
            config.getAttribute('A-End').setValue(siteRec.Id);
            config.getAttribute('A-End').setDisplayValue(siteRec.Name);
            string solution = UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim());
            config.getAttribute('Solution').setValue(solution);
            //Check if supplier exists
            string supplier = fieldsVals[5].trim();
            if(!UnifyConfig.setSuppliers().contains(supplier)){
                saveErrorMessage(rec1, 'Used Supplier (' + supplier + ') not found in SFDC.');
                return;
            }
            config.getAttribute('Supplier').setValue(fieldsVals[5].trim());
            config.getAttribute('Comment').setValue(fieldsVals[8].trim());
            config.getAttribute('Quantity').setValue(fieldsVals[27].trim());
            config.getAttribute('Monitoring Name').setValue(fieldsVals[26].trim());

            //Class
            if(solution == 'MTEL'){
                string subSolution = fieldsVals[4].trim();
                if(subSolution.contains('IPT')){
                    config.getAttribute('Class').setValue('IP Telephony');
                } else if (subSolution.contains('PBX')){
                    config.getAttribute('Class').setValue('PBX');
                }
            }

            if(!isExcelFieldNull(fieldsVals[29])){
                Decimal d;
                try{
                    d = UnifyCommonMethods.covertAmount2decimal(fieldsVals[29]);
                } catch(Exception e){
                    saveErrorMessage(rec1, 'Incorrect decimal value in column AD: ' + fieldsVals[29]);
                    return;
                }
                //delivered values is annual, and in SFDC is monthly; therefore value needs to be divided by 12
                config.getAttribute('Unit ARC OPEX').setValue(String.valueOf(d));
            }

            if(!isExcelFieldNull(fieldsVals[33])){
                config.getAttribute('Margin ARC').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[33]));
            }

            apiSession.executeRules();
            apiSession.executeRules();

            List<cscfgc.Attribute> attributes = config.getAttributes();
            for (cscfgc.Attribute attr : attributes) {
                string attName = attr.getName().toLowerCase();
                if(attName.contains('cost') || attName.contains('price') || attName.contains(' rc') || attName.contains(' nrc') || attName.contains(' arc') || attName.contains(' charge')){
                    if (attr.getIsActive() && attr.getValue() != null)
                    {
                        try{
                            Decimal attValue = Decimal.valueOf(attr.getValue());
                            if(attName.contains('total') || attName.contains('opex') || attName.contains('capex')
                            	|| attName.contains('margin') || attName.contains('ecc') || attName.contains('maximum') || attName.contains('minimum'))
                            	attValue = attValue.setScale(2);
                            else
                            	attValue = attValue.setScale(2);
                            attr.setPrice(attValue);
                            attr.setValue(string.valueOf(attValue));
                        } catch (Exception exc) { }
                    }
                }
            }

            apiSession.persistConfiguration(true);
            sobject sconf = apiSession.getConfiguration().getSObject();

            sconf.put('Unify_Site__c',siteRec.Id);
            sconf.put('cscfgc__product_bundle__c', bundle.Id);
            sconf.put('Unify_Solution__c', UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            sconf.put('Name',  config.getAttribute('DISE Bill Label').getValue());
            update sconf;
        } catch (Exception e){
            saveErrorMessage(rec1, 'Unknown problem encounter during pillar processing. Error details: ' + e.getMessage() + '. Line no: ' + e.getLineNumber());
            return;
        }
        rec1.Processed__c = true;
        rec1.Success__c = true;
        update rec1;
    }

    /**
    *   Method invoked from common processPillar method
    *   It transform passed Excel row (stored in Unify_Upload_Single_Entity__c) into Professional Services Pillar Configuration and saves it
    *   @param  rec1 - passed excel row, representing single Professional Services pillar configuration which needs to be saved
    *   @param  fieldsVals - splitted content of excel row columns with values to be used within the configuration
    *   @param  siteRec - passed Unify_Site__c record to which configuration needs to be attatched
    *   @param  prodDef - passed Professional Services pillar definition which is required for CS Configurator API engine
    *   @param  bundle - passed cscfgc__Product_Bundle__c record in relation to which configuration needs to be created
    */
    global static void createProfessionalServicesPillar(Unify_Upload_Single_Entity__c rec1,String[] fieldsVals, Unify_Site__c siteRec, cscfgc__Product_Definition__c prodDef, cscfgc__Product_Bundle__c bundle){
        try{
            cscfgc.API_1.ApiSession apiSession = cscfgc.API_1.getApiSession(prodDef);
            apiSession.setBundle(bundle);
            cscfgc.ProductConfiguration config = apiSession.getRootConfiguration();
            if(config.containsAttribute('Override Rate Card'))
    			config.getAttribute('Override Rate Card').setValue('YES');
            config.getAttribute('A-End').setValue(siteRec.Id);
            config.getAttribute('A-End').setDisplayValue(siteRec.Name);
            config.getAttribute('Solution').setValue(UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            //Check if supplier exists
            string supplier = fieldsVals[5].trim();
            if(!UnifyConfig.setSuppliers().contains(supplier)){
                saveErrorMessage(rec1, 'Used Supplier (' + supplier + ') not found in SFDC.');
                return;
            }
            config.getAttribute('Supplier').setValue(fieldsVals[5].trim());
            config.getAttribute('Comment').setValue(fieldsVals[8].trim());
            config.getAttribute('Quantity').setValue(fieldsVals[27].trim());
            config.getAttribute('Professional Services Name').setValue(fieldsVals[26].trim());

            if(!isExcelFieldNull(fieldsVals[28])){
                Decimal d;
                try{
                    d = UnifyCommonMethods.covertAmount2decimal(fieldsVals[28]);
                } catch(Exception e){
                    saveErrorMessage(rec1, 'Incorrect decimal value in column AC: ' + fieldsVals[28]);
                    return;
                }
                config.getAttribute('Unit Cost').setValue(String.valueOf(d));
            }

            if(!isExcelFieldNull(fieldsVals[32])){
                config.getAttribute('Margin').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[32]));
            }

            apiSession.executeRules();
            apiSession.executeRules();

            List<cscfgc.Attribute> attributes = config.getAttributes();
            for (cscfgc.Attribute attr : attributes) {
                string attName = attr.getName().toLowerCase();
                if(attName.contains('cost') || attName.contains('price') || attName.contains(' rc') || attName.contains(' nrc') || attName.contains(' arc') || attName.contains(' charge')){
                    if (attr.getIsActive() && attr.getValue() != null)
                    {
                        try{
                            Decimal attValue = Decimal.valueOf(attr.getValue());
                            if(attName.contains('total') || attName.contains('opex') || attName.contains('capex')
                            	|| attName.contains('margin') || attName.contains('ecc') || attName.contains('maximum') || attName.contains('minimum'))
                            	attValue = attValue.setScale(2);
                            else
                            	attValue = attValue.setScale(2);
                            attr.setPrice(attValue);
                            attr.setValue(string.valueOf(attValue));
                        } catch (Exception exc) { }
                    }
                }
            }

            apiSession.persistConfiguration(true);

            sobject sconf = apiSession.getConfiguration().getSObject();

            sconf.put('Unify_Site__c',siteRec.Id);
            sconf.put('cscfgc__product_bundle__c', bundle.Id);
            sconf.put('Unify_Solution__c', UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            sconf.put('Name',  config.getAttribute('DISE Bill Label').getValue());
            update sconf;
        } catch (Exception e){
            saveErrorMessage(rec1, 'Unknown problem encounter during pillar processing. Error details: ' + e.getMessage() + '. Line no: ' + e.getLineNumber());
            return;
        }
        rec1.Processed__c = true;
        rec1.Success__c = true;
        update rec1;
    }

    /**
    *   Method template to process Other pillar
    *   Its structure / mechanism has not been agreed therefore it is currently not supported
    *   @param  rec1 - passed excel row, representing single OTHER pillar configuration which needs to be saved
    *   @param  fieldsVals - splitted content of excel row columns with values to be used within the configuration
    *   @param  siteRec - passed Unify_Site__c record to which configuration needs to be attatched
    *   @param  prodDef - passed OTHER pillar definition which is required for CS Configurator API engine
    *   @param  bundle - passed cscfgc__Product_Bundle__c record in relation to which configuration needs to be created
    */
    global static void createOtherPillar(Unify_Upload_Single_Entity__c rec1,String[] fieldsVals, Unify_Site__c siteRec, cscfgc__Product_Definition__c prodDef, cscfgc__Product_Bundle__c bundle){
        try{
            cscfgc.API_1.ApiSession apiSession = cscfgc.API_1.getApiSession(prodDef);
            apiSession.setBundle(bundle);
            cscfgc.ProductConfiguration config = apiSession.getRootConfiguration();
            if(config.containsAttribute('Override Rate Card'))
    			config.getAttribute('Override Rate Card').setValue('YES');
            config.getAttribute('A-End').setValue(siteRec.Id);
            config.getAttribute('A-End').setDisplayValue(siteRec.Name);
            config.getAttribute('Solution').setValue(UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            //Check if supplier exists
            string supplier = fieldsVals[5].trim();
            if(!UnifyConfig.setSuppliers().contains(supplier)){
                saveErrorMessage(rec1, 'Used Supplier (' + supplier + ') not found in SFDC.');
                return;
            }
            config.getAttribute('Supplier').setValue(fieldsVals[5].trim());
            config.getAttribute('Description').setValue(fieldsVals[7].trim());
            config.getAttribute('Comment').setValue(fieldsVals[8].trim());
            config.getAttribute('Other Name').setValue(fieldsVals[26].trim());
            config.getAttribute('Other Name Copy').setValue(fieldsVals[26].trim());
            config.getAttribute('Quantity').setValue(fieldsVals[27].trim());

            Decimal arcOpex = 0;
            try{
                arcOpex = UnifyCommonMethods.covertAmount2decimal(fieldsVals[29]);
            } catch (Exception e){ }
            if(arcOpex > 0){

                config.getAttribute('Unit ARC OPEX').setValue(String.valueOf(arcOpex));
                config.getAttribute('Billing Frequency').setValue('12');
                if(!isExcelFieldNull(fieldsVals[33])){
                    config.getAttribute('Margin ARC').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[33]));
                }
            } else {
                if(!isExcelFieldNull(fieldsVals[28])){
                    Decimal d;
                    try{
                        d = UnifyCommonMethods.covertAmount2decimal(fieldsVals[28]);
                    } catch(Exception e){
                        saveErrorMessage(rec1, 'Incorrect decimal value in column AC: ' + fieldsVals[28]);
                        return;
                    }
                    config.getAttribute('Unit NRC CAPEX').setValue(String.valueOf(d));
                }
                if(!isExcelFieldNull(fieldsVals[32])){
                    config.getAttribute('Margin NRC').setValue(UnifyCommonMethods.cleanNumberNotation(fieldsVals[32]));
                }
            }

            apiSession.executeRules();

            //Related configuration (For now only Connectivity)
            string otherName = config.getAttribute('Other Name').getValue();
            boolean relatedFound = false;
            List<cscfgc__Product_Configuration__c> relatedConfigs = [SELECT
                                                                        Id, Name, Other_pillar_dependency_Shadow__c
                                                                     FROM
                                                                        cscfgc__Product_Configuration__c
                                                                     WHERE
                                                                        cscfgc__Product_Definition__r.Name LIKE '%connectivity%' AND
                                                                        Unify_Site__c = :siteRec.Id AND
                                                                        cscfgc__Product_Bundle__c = :bundle.Id];

            for(cscfgc__Product_Configuration__c relatedConfig : relatedConfigs){
                if(!string.isBlank(relatedConfig.Other_pillar_dependency_Shadow__c) &&
                	relatedConfig.Other_pillar_dependency_Shadow__c.contains(otherName)){
                    config.getAttribute('Related Configuration').setValue(relatedConfigs[0].Id);
                    config.getAttribute('Related Configuration').setDisplayValue(relatedConfigs[0].Name);
                    config.getAttribute('Related Configuration Name').setValue(relatedConfigs[0].Name);
                    relatedFound = true;
                    break;
                }
            }

            apiSession.executeRules();
            apiSession.executeRules();
            List<cscfgc.Attribute> attributes = config.getAttributes();
            for (cscfgc.Attribute attr : attributes) {
                string attName = attr.getName().toLowerCase();
                if(attName.contains('cost') || attName.contains('price') || attName.contains(' rc') || attName.contains(' nrc') || attName.contains(' arc') || attName.contains(' charge')){
                    if (attr.getIsActive() && attr.getValue() != null)
                    {
                        try{
                            Decimal attValue = Decimal.valueOf(attr.getValue());
                            if(attName.contains('total') || attName.contains('opex') || attName.contains('capex')
                            	|| attName.contains('margin') || attName.contains('ecc') || attName.contains('maximum') || attName.contains('minimum'))
                            	attValue = attValue.setScale(2);
                            else
                            	attValue = attValue.setScale(2);
                            attr.setPrice(attValue);
                            attr.setValue(string.valueOf(attValue));
                        } catch (Exception exc) { }
                    }
                }
            }
            apiSession.persistConfiguration(true);

            //This Product Configuration as a related configuration
            otherName = config.getAttribute('Other Name').getValue();
            string q = 'SELECT ' + Utility.getSobjectFields('cscfgc__Product_Configuration__c') +
                            ' , (SELECT ' + Utility.getSobjectFields('cscfgc__Attribute__c') + ' FROM cscfgc__Attributes__r WHERE ' +
                            ' Name IN (\'Related Configuration\',\'Related Configuration Name\')) ' +
                            ' FROM cscfgc__Product_Configuration__c WHERE ' +
                            ' cscfgc__Product_Definition__r.Name LIKE \'%connectivity%\' AND ' +
                            ' Available_Other__c != \'\' AND ' +
                            ' Unify_Site__c = \'' + siteRec.Id + '\' AND ' +
                            ' cscfgc__Product_Bundle__c = \'' + bundle.Id + '\'';
            relatedConfigs = database.query(q);
            List<cscfgc__Attribute__c> attsForUpdate = new List<cscfgc__Attribute__c>();
            List<cscfgc__Product_Configuration__c> consForUpdate = new List<cscfgc__Product_Configuration__c>();
            if(relatedConfigs.size() > 0){
                for(cscfgc__Product_Configuration__c relatedConfig : relatedConfigs){
                    if(relatedConfig.Available_Other__c.contains(otherName)){
                        relatedConfig.cscfgc__Configuration_Status__c = 'Incomplete';
                        consForUpdate.add(relatedConfig);
                        for(cscfgc__Attribute__c att : relatedConfig.cscfgc__Attributes__r){
                            if(att.Name == 'Related Configuration'){
                                att.cscfgc__Value__c = config.getId();
                                att.cscfgc__Display_Value__c = config.getName();
                                attsForUpdate.add(att);
                            }
                            if(att.Name == 'Related Configuration Name'){
                                att.cscfgc__Value__c = config.getName();
                                attsForUpdate.add(att);
                            }
                        }
                        break;
                    }
                }
            }

            if(attsForUpdate.size() > 0)
                update(attsForUpdate);

            if(consForUpdate.size() > 0)
                update(consForUpdate);

            sobject sconf = apiSession.getConfiguration().getSObject();
            String possibleDiseCodes = config.getAttribute('DISE CODE value').getValue();
            String dise2assign = UnifyDiseCodesController.getResultDiseCode(sconf.Id, possibleDiseCodes);
            config.getAttribute('DISE CODE').setValue(dise2assign);
            config.getAttribute('Configuration Id').setValue(sconf.Id);
            apiSession.persistConfiguration(true);

			sconf = apiSession.getConfiguration().getSObject();
			sconf.put('Unify_Site__c',siteRec.Id);
            sconf.put('cscfgc__product_bundle__c', bundle.Id);
            sconf.put('Unify_Solution__c', UnifyConfig.mSolutions2Name().get(fieldsVals[4].trim()));
            sconf.put('Name',  config.getAttribute('DISE Bill Label').getValue());
            update sconf;


        } catch (Exception e){
            saveErrorMessage(rec1, 'Unknown problem encounter during pillar processing. Error details: ' + e.getMessage() + '. Line no: ' + e.getLineNumber());
            return;
        }
        rec1.Processed__c = true;
        rec1.Success__c = true;
        update rec1;
    }

    /**
    *   Method invoked from common processPillar method
    *   It finds proper Opportunity Location for required for Site and Configuration creation and invokes prepareSiteObjectBasedOnOppLoc which created Site element
    *   @param opportunityId - parent Opportunity Id in context of which Site needs to be prepared
    *   @param siteName - Unique Location name passed from MQF Excel which should be represented as a Location__c on SFDC side, it also references the Location for which Site needs to be created
    *   @param solutionName - name of the Solution in which configuration is created;
    *   @return Unify_Site__c - prepared site record to be used afterwards by proper pillar creation mechanism
    */
    global static Unify_Site__c prepareSiteObjectBasedOnSiteName(Id opportunityId, string siteName, string solutionName, Id bundleId){
        if(isExcelFieldNull(siteName)){
            throw new CustomValidationException('Site Name is mandatory!');
        }
        List<Unify_Site__c> sites = [SELECT
        								Id, Name
        							 FROM
        								Unify_Site__c
        							 WHERE
	        							Opportunity__c = :opportunityId AND
	        							Solution__c = :solutionName AND
	        							Location__r.Unify_Unique_Site_Name__c = :siteName AND
	        							Product_Bundle__c = :bundleId AND
	        							Order_Group__c = ''];
        if(sites != null && sites.size() > 0){
            return sites[0];
        } else {
            List<Unify_Opportunity_Location__c> ols = [SELECT
            												Id, Location__c
            									  	   FROM
            									  			Unify_Opportunity_Location__c
            									  	   WHERE
            									  			Opportunity__c = :opportunityId AND
            									  			Location__r.Unify_Unique_Site_Name__c = :siteName];
            if(ols == null || ols.size() == 0){
                throw new CustomValidationException('Site: ' + siteName + ' does not exist.');
            } else {
                return prepareSiteObjectBasedOnOppLoc(ols[0].Id, solutionName, bundleId);
            }
        }
    }

    /**
    *   Method invoked from common prepareSiteObjectBasedOnSiteName method and UnifyProductBundleBuilderAsyncController
    *   It prepares (creates or finds) proper Site element (equivalent of DISE Subscription) required for new configuration creation
    *   Sites are distinguished based on Solution (technology) and related Location
    *   @param oppLoc - parent Opportunity Id in context of which Site needs to be prepared
    *   @param solutionName - name of the Solution in which configuration is created;
    *   @return Unify_Site__c - prepared site record to be used afterwards by proper pillar creation mechanism
    */
    global static Unify_Site__c prepareSiteObjectBasedOnOppLoc(Id oppLoc, string solutionName, Id bundleId){
        List<Unify_Opportunity_Location__c> ols = [SELECT
        												Id, Opportunity__c, Location__c, Location__r.Unify_Unique_Site_Name__c,
        												(SELECT
        													Id, Opportunity_Location__c, Name, Solution__c, Opportunity__c, Location__c
        												 FROM
        												 	Sites__r
        												 WHERE
        												 	Solution__c = :solutionName AND
        												 	Product_Bundle__c = :bundleId AND
        												 	Order_Group__c = '')
        										   FROM
        										   		Unify_Opportunity_Location__c
        										   WHERE
        										   	 	Id = :oppLoc];
        if(ols == null || ols.size() == 0){
            throw new CustomValidationException('Internal Error: Opportunity Location with id: ' + oppLoc + ' not found!');
        } else if(ols[0].Sites__r != null && ols[0].Sites__r.size() > 0){
            return ols[0].Sites__r[0];
        } else {
            Unify_Site__c us = new Unify_Site__c();
            us.Location__c = ols[0].Location__c;
            us.Opportunity__c = ols[0].Opportunity__c;
            us.Solution__c = solutionName;
            us.Name = ols[0].Location__r.Unify_Unique_Site_Name__c;
            us.Opportunity_Location__c = oppLoc;
            us.Product_Bundle__c = bundleId;
            insert us;
            return us;
        }
    }

    /**
    *   Generic method widely used by pillar creation methods
    *   It checks whther delivered excel column value is set or not
    *   @param s - passed excel column value which needs to be verified
    *   @return boolean - result of the check
    */
    global static boolean isExcelFieldNull(string s){
        string s1 = s == null ? '' : s.trim();
        return (s == '' || s == '#N/A');
    }


    /**
    *   Generic method widely used by pillar creation methods
    *   Returns value of passed column that no longer contains any leading or trailing white space characters
    *   @param s - passed excel column content which needs to be processed
    *   @return string - processed column value without empty spaces
    */
    global static string excelValue(string s){
        if(isExcelFieldNull(s)){
            return '';
        } else {
            return s.trim();
        }
    }
}