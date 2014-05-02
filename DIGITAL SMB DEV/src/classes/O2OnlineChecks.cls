/*
    O2OnlineChecks - Used to perform single and consolidated checks for
    Subscriber, Landland and Broadband. 
    Author: S O'Halloran
    Created: 23rd Nov 2011
*/
public with sharing class O2OnlineChecks {
    
    /*
    // USAGE:
    */
    public static final String INVALID_MSISDN = 'Invalid MSISDN';
    public static final String CORPORATE = 'Corporate';
    public static final String SME ='SME';
    public static final String O2 ='O2';
    
    public static string getCustomLabelByName(String name) {
        if(name!=null) {
            name = name.replaceAll('ONLINE_SHOP_BB_EMLC_TEMP',System.Label.ONLINE_SHOP_BB_EMLC_TEMP); 
            name = name.replaceAll('ONLINE_SHOP_BB_ERROR_INPUT',System.Label.ONLINE_SHOP_BB_ERROR_INPUT);
            name = name.replaceAll('ONLINE_SHOP_BB_ERROR_TECHNICAL',System.Label.ONLINE_SHOP_BB_ERROR_TECHNICAL);
            name = name.replaceAll('ONLINE_SHOP_BB_NO',System.Label.ONLINE_SHOP_BB_NO);
            name = name.replaceAll('ONLINE_SHOP_BB_O2_ERROR',System.Label.ONLINE_SHOP_BB_O2_ERROR);
            name = name.replaceAll('ONLINE_SHOP_BB_O2_NOT',System.Label.ONLINE_SHOP_BB_O2_NOT);
            name = name.replaceAll('ONLINE_SHOP_BB_O2',System.Label.ONLINE_SHOP_BB_O2);
            name = name.replaceAll('ONLINE_SHOP_BB_OK',System.Label.ONLINE_SHOP_BB_OK);
            name = name.replaceAll('ONLINE_SHOP_BB_TRANSFER',System.Label.ONLINE_SHOP_BB_TRANSFER);
            name = name.replaceAll('ONLINE_SHOP_BB_UPGRADE',System.Label.ONLINE_SHOP_BB_UPGRADE);
            name = name.replaceAll('ONLINE_SHOP_LL_ERROR_INPUT',System.Label.ONLINE_SHOP_LL_ERROR_INPUT);
            name = name.replaceAll('ONLINE_SHOP_LL_ERROR_TECHNICAL',System.Label.ONLINE_SHOP_LL_ERROR_TECHNICAL);
            name = name.replaceAll('ONLINE_SHOP_LL_O2_ERROR',System.Label.ONLINE_SHOP_LL_O2_ERROR);
            name = name.replaceAll('ONLINE_SHOP_LL_O2_NOT',System.Label.ONLINE_SHOP_LL_O2_NOT);
            name = name.replaceAll('ONLINE_SHOP_LL_O2',System.Label.ONLINE_SHOP_LL_O2);
            name = name.replaceAll('ONLINE_SHOP_LL_TRANSFER_NOT',System.Label.ONLINE_SHOP_LL_TRANSFER_NOT);
            name = name.replaceAll('ONLINE_SHOP_LL_TRANSFER',System.Label.ONLINE_SHOP_LL_TRANSFER);
            name = name.replaceAll('ONLINE_SHOP_LL_NO',System.Label.ONLINE_SHOP_LL_NO);           
        }
        return name;
    }
    
    //  
    public static CheckResponseType getCheckResponse(String existingNum, String newNum, String newPostcode, String cType, boolean newLineRequest, boolean existingCustomer) {
        CheckResponseType checkResponse = new CheckResponseType();
        String responseCode = '';
        
        if(newLineRequest && cType=='Line') {   
            // Go along line 1 - "1 want a new landline"
            // New landland and not existing customer - then no checks need to be run
            if(!existingCustomer) {
                // I'm not an existing customer
                checkResponse.responseCode = cType+'-A1';
            } else {
                // I am an existing customer looking for a new landline, then just run the subscriber check
                // Perform a subscriber check only
                String subscriberResultCode = performSubscriberCheck(existingNum);
                checkResponse.responseCode = cType+'-'+subscriberResultCode+'1';
            }
        } else {
            // I'm looking to transfer a line or run a broadband check
            // The subsciber check is option depending on wether I'm an existing customer or not
            checkResponse = performCheck(existingNum, newNum, newPostcode, cType, existingCustomer);
        }

        System.debug('>>> responseCode:'+checkResponse.responseCode);
        checkResponse.checkResponseItem = OnlineResponseMatrix__c.getInstance(checkResponse.responseCode);
        return checkResponse;
    }
    
    //  
    public static CheckResponseType getCheckResponse2(String packageType, String existingNum, String newNum, String newPostcode, String cType, boolean newLineRequest, boolean existingCustomer) {
        
        String responseCode = '';
        CheckResponseType checkResponse = new CheckResponseType();
        
        if(newLineRequest && cType == 'Line') {   
            // Go along line 1 - "1 want a new landline"
            // New landland and not existing customer - then no checks need to be run
            if(!existingCustomer) {
                // I'm not an existing customer
                checkResponse.responseCode = cType + '-A1';
            } else {
                // I am an existing customer looking for a new landline, then just run the subscriber check
                // Perform a subscriber check only
                String subscriberResultCode = performSubscriberCheck(existingNum);
                checkResponse.responseCode = cType + '-' + subscriberResultCode + '1';
            }
        } else {
            // I'm looking to transfer a line or run a broadband check
            // The subsciber check is option depending on wether I'm an existing customer or not
            checkResponse = performCheck2(packageType, existingNum, newNum, newPostcode, cType, existingCustomer);
        }

        System.debug('get check response 2, checkResponse='+checkResponse);
        //System.debug('>>> responseCode:'+checkResponse.responseCode);
        checkResponse.checkResponseItem = OnlineResponseMatrix__c.getInstance(checkResponse.responseCode);
        
        return checkResponse;
    }
    
    //  LINE CHECKER
    private static CheckResponseType performCheck(String existingNum, String newNum, String newPostcode, String cType, boolean subscriberCheck) {
        CheckResponseType checkResponse = new CheckResponseType();
        String responseCode = '';
        Batch_Job__c checkJob;
        Line_Availability__c checkRes;
        // If we don't run a subscriber check the code will be 'A' - Customer says they are not O2, so don't perform check
        String subscriberResponseCode = 'A';
        if(subscriberCheck) subscriberResponseCode = performSubscriberCheck(existingNum);   
                        
        try {
            checkJob  = AvailabilityCheckInputProcessor.processLineAvailablityImmediate(newNum, newPostcode, cType, subscriberResponseCode);    
            checkRes = [SELECT Id, Response_Matrix_Value__c, estimatedLineSpeed__c, predictedDownloadSpeed__c, Status__c, reasonCode__c, Service_Type__c 
                                            FROM Line_Availability__c WHERE Batch_Job__c = :checkJob.Id];
            checkResponse.checkResponse = checkRes;
            // A formula on the record returns the response code
            responseCode = checkRes.Response_Matrix_Value__c;
        } catch (Exception ex) {
            // If there is an exception the code will always be '7' - Technical Fault
            system.debug(Logginglevel.ERROR, 'perform check, error = '+ ex.getMessage());
            responseCode = cType+'-'+subscriberResponseCode+'7';
        }
        checkResponse.responseCode = responseCode;
        return checkResponse;                           
    }

	//  LINE CHECKER
    private static CheckResponseType performCheck2(String packageType, String existingNum, String newNum, String newPostcode, String cType, boolean subscriberCheck) {
        Batch_Job__c checkJob;
        Line_Availability__c checkRes;
        String responseCode = '';
        String subscriberResponseCode = 'A';
        CheckResponseType checkResponse = new CheckResponseType();
        
        if(subscriberCheck) {
        	subscriberResponseCode = performSubscriberCheck(existingNum);   
        }
        
        try {
            checkJob  = AvailabilityCheckInputProcessor.processLineAvailablityImmediate(newNum, newPostcode, cType, subscriberResponseCode);    
            checkRes = [SELECT Id, Response_Matrix_Value__c, estimatedLineSpeed__c, predictedDownloadSpeed__c, Status__c, reasonCode__c, Service_Type__c, productList__c 
            			FROM Line_Availability__c 
            			WHERE Batch_Job__c = :checkJob.Id];
            checkResponse.checkResponse = checkRes;
            if(checkRes.productList__c != null && checkRes.productList__c.contains(packageType)) {
            	responseCode = checkRes.Response_Matrix_Value__c;
            }
            else {
            	// If the requested packageType (representing the product name in O2 product definitions/configuratios) is not in the product list, the code will always be '3'
            	responseCode = cType + '-' + subscriberResponseCode + '3';
            }
        } catch (Exception ex) {
            // If there is an exception the code will always be '7' - Technical Fault
            system.debug(Logginglevel.ERROR, 'perform check 2, error = '+ ex.getMessage());
            system.debug(Logginglevel.ERROR, 'perform check 2, error = '+ ex.getStackTraceString());
            responseCode = cType + '-' + subscriberResponseCode + '7';
        }
        
        checkResponse.responseCode = responseCode;
        return checkResponse;                           
    }

    //  SUBSCRIBER CHECKER
    private static String performSubscriberCheck(String strExistNum) {
        String responseCode = 'E';
        SOASubscriberData.subscriberProfileType subscriber;
        if (strExistNum!=null) {
            strExistNum.trim();
            SOASubscriberService.SubscriberPort port = new SOASubscriberService.SubscriberPort();
            port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
            port.timeout_x = SoaUtils.SOA_TIMEOUT;
            try {
                subscriber = port.getSubscriberProfile(strExistNum);  
                if(subscriber.operator==O2 && subscriber.status=='A' && 
                        (subscriber.segment==CORPORATE || subscriber.segment==SME)) { 
                    responseCode = 'B';
                } else {
                    responseCode = 'C';
                } 
            } catch(Exception e) {
                system.debug('>>>>>>>>>> performSubscriberCheck Exception: '+e.getMessage());
                if(e.getMessage().contains(INVALID_MSISDN)) {
                    responseCode = 'D';
                } else {
                    responseCode = 'E';
                }               
            }                          
        }
        system.debug('>>>>>>>>>> subscriberCheck responseCode:'+responseCode);
        return responseCode;
    }
    
    public class CheckResponseType {
        public String responseCode;
        public Line_Availability__c checkResponse;
        public OnlineResponseMatrix__c checkResponseItem;
        public String getDisplayMessage() {
            return O2OnlineChecks.getCustomLabelByName(checkResponseItem.Display_Message__c);
        }
    }
    
    // TEST METHODS
    public static testmethod void testO2OnlineChecksTransferNewCustomer() {
        OnlineResponseMatrix__c cs = new OnlineResponseMatrix__c();
        cs.Name='Line-Z9';
        cs.Type__c='Line';
        cs.Display_Message__c='ONLINE_SHOP_LL_O2';
        insert cs;
        Test.startTest();
        CheckResponseType  cr = getCheckResponse('23432432432','23432432432','AB12 4AB', 'Line',false, false); 
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
        OnlineResponseMatrix__c response = cr.checkResponseItem;
        String displayMessage = getCustomLabelByName(response.Display_Message__c);
        boolean cb = response.Check_Button_Enabled__c;
        boolean cob = response.Continue_Button_Enabled__c;
        String customer = response.O2_Customer__c;
        String pType = response.Provide_Type__c;
        String newotype = response.New_Order_Type__c;
        Test.stopTest();
        System.assertEquals(displayMessage,cr.getDisplayMessage());
        System.assertEquals('Line',response.Type__c);
        System.assertNotEquals(null,cr.responseCode);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
    }
    
    public static testmethod void testO2OnlineChecksNewProvideExistingCustomer() {
        Test.startTest();
        CheckResponseType  cr = getCheckResponse('23432432432','23432432432','AB12 4AB', 'Line',true, true);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
        OnlineResponseMatrix__c response = cr.checkResponseItem;
        Test.stopTest();
        System.assertEquals('Line',response.Type__c);
        System.assertNotEquals(null,cr.responseCode);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
    }
    
    public static testmethod void testO2OnlineChecksNewProvideNewCustomer() {
        Test.startTest();
        CheckResponseType  cr = getCheckResponse('','23432432432','AB12 4AB', 'Line',true, false);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
        OnlineResponseMatrix__c response = cr.checkResponseItem;
        Test.stopTest();
        System.assertEquals('Line-A1',cr.responseCode);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
    }       
    
    public static testmethod void testO2OnlineChecksTransferNewCustomer2() {
        OnlineResponseMatrix__c cs = new OnlineResponseMatrix__c();
        cs.Name='Line-Z9';
        cs.Type__c='Line';
        cs.Display_Message__c='ONLINE_SHOP_LL_O2';
        insert cs;
        Test.startTest();
        CheckResponseType  cr = getCheckResponse2('Home Office Standard', '23432432432','23432432432','AB12 4AB', 'Line',false, false); 
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
        OnlineResponseMatrix__c response = cr.checkResponseItem;
        String displayMessage = getCustomLabelByName(response.Display_Message__c);
        boolean cb = response.Check_Button_Enabled__c;
        boolean cob = response.Continue_Button_Enabled__c;
        String customer = response.O2_Customer__c;
        String pType = response.Provide_Type__c;
        String newotype = response.New_Order_Type__c;
        Test.stopTest();
        System.assertEquals(displayMessage,cr.getDisplayMessage());
        System.assertEquals('Line',response.Type__c);
        System.assertNotEquals(null,cr.responseCode);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
    }
    
    public static testmethod void testO2OnlineChecksNewProvideExistingCustomer2() {
        Test.startTest();
        CheckResponseType  cr = getCheckResponse2('Home Office Standard', '23432432432','23432432432','AB12 4AB', 'Line',true, true);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
        OnlineResponseMatrix__c response = cr.checkResponseItem;
        Test.stopTest();
        System.assertEquals('Line',response.Type__c);
        System.assertNotEquals(null,cr.responseCode);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
    }
    
    public static testmethod void testO2OnlineChecksNewProvideNewCustomer2() {
        Test.startTest();
        CheckResponseType  cr = getCheckResponse2('Home Office Standard','','23432432432','AB12 4AB', 'Line',true, false);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
        OnlineResponseMatrix__c response = cr.checkResponseItem;
        Test.stopTest();
        System.assertEquals('Line-A1',cr.responseCode);
        System.debug('>>>>>>>>>: cr.responseCode: '+cr.responseCode);
    }  
}