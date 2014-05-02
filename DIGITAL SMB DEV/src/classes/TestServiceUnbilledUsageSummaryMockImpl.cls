/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
global class TestServiceUnbilledUsageSummaryMockImpl implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req)
    {
        HTTPResponse response = new Httpresponse();

        string requestBody = req.getBody();
        string responseBody;

        if(requestBody.contains('man:getSubscriptionDetails_1'))
        {
            responseBody  = '<?xml version="1.0" encoding="UTF-8"?>';
            responseBody += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            responseBody +=   '<soapenv:Header xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1"> </soapenv:Header>';
            responseBody +=   '<soapenv:Body xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1" xmlns:man="http://soa.o2.co.uk/managebusinesssubscriptionsdata_1">';
            responseBody +=     '<man:getSubscriptionDetails_1Response>';
            responseBody +=       '<man:basicDetails> <man:subscriptionNumber>12341234</man:subscriptionNumber> <man:groupNumber>XXXXXX</man:groupNumber> <man:subscriptionStatus>Normal</man:subscriptionStatus> <man:tariffCode>XXXX12</man:tariffCode> <man:tariffDescription>500MB Ipad - UK + Roaming</man:tariffDescription> </man:basicDetails>';
            responseBody +=       '<man:customerDetails> <man:userName>JOHN DOE</man:userName> <man:customerCostCentre>123456</man:customerCostCentre> </man:customerDetails>';
            responseBody +=       '<man:contractAndSalesDetails> <man:lastInvoiceDate>2013-01-01</man:lastInvoiceDate> <man:nextInvoiceDate>2013-02-01</man:nextInvoiceDate> </man:contractAndSalesDetails>';
            responseBody +=     '</man:getSubscriptionDetails_1Response>';
            responseBody +=   '</soapenv:Body>';
            responseBody += '</soapenv:Envelope>';
      
            response.setStatusCode(200);
            response.setBody(responseBody);
        }
        else if(requestBody.contains('view:getUnbilledUsage'))
        {
            responseBody  = '<?xml version="1.0" encoding="UTF-8"?>';
            responseBody += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            responseBody +=   '<soapenv:Header xmlns:view="http://soa.o2.co.uk/viewbusinesscustomerusagedata_2" xmlns:psc="http://soa.o2.co.uk/dise/pscommondisedata_1">';
            responseBody +=     '<cor:SOATransactionID xmlns:cor="http://soa.o2.co.uk/coredata_1">01cbd3bd-e5c4-43d1-8563-56fd01b24545</cor:SOATransactionID>';
            responseBody +=   '</soapenv:Header>';
            responseBody +=   '<soapenv:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
            responseBody +=     '<view:getUnbilledUsageResponse xmlns:view="http://soa.o2.co.uk/viewbusinesscustomerusagedata_2">';
            responseBody +=       '<view:statusCode>viewbusinesscustomerusage-36560-0000-S</view:statusCode>';
            responseBody +=       '<view:totalAmount>0</view:totalAmount>';
            responseBody +=       '<view:unbilledUnits>';
            responseBody +=         '<view:unbilledUnit> <view:callStatus>Awaiting Invoice</view:callStatus> <view:dialledNumber>447777111111</view:dialledNumber> <view:unitOfMeasure>Sec</view:unitOfMeasure> <view:unitsUsed>945</view:unitsUsed> <view:classificationCode>P143</view:classificationCode>';
            responseBody +=          '<view:classificationDescription>Calls to O2 Mobiles</view:classificationDescription> <view:bundleCallStatus>No</view:bundleCallStatus> <view:preBundlePrice>0</view:preBundlePrice> <view:discountPrice>0</view:discountPrice> <view:callPrice>0</view:callPrice> </view:unbilledUnit>';
            responseBody +=         '<view:unbilledUnit> <view:callStatus>Awaiting Invoice</view:callStatus> <view:dialledNumber>447777111111</view:dialledNumber> <view:unitOfMeasure>Sec</view:unitOfMeasure> <view:unitsUsed>789</view:unitsUsed> <view:classificationCode>P2519</view:classificationCode>';
            responseBody +=          '<view:classificationDescription>iCUG Call Made to Zone 1</view:classificationDescription> <view:bundleCallStatus>No</view:bundleCallStatus> <view:preBundlePrice>0</view:preBundlePrice> <view:discountPrice>0</view:discountPrice> <view:callPrice>0</view:callPrice> </view:unbilledUnit>';
            responseBody +=         '<view:unbilledUnit> <view:callStatus>Awaiting Invoice</view:callStatus> <view:dialledNumber>447777111111</view:dialledNumber> <view:unitOfMeasure>Sec</view:unitOfMeasure> <view:unitsUsed>120</view:unitsUsed> <view:classificationCode>8160</view:classificationCode>';
            responseBody +=          '<view:classificationDescription>Call Bck to UK frm Z1 O2Travel</view:classificationDescription> <view:bundleCallStatus>No</view:bundleCallStatus> <view:preBundlePrice>0</view:preBundlePrice> <view:discountPrice>0</view:discountPrice> <view:callPrice>0</view:callPrice> </view:unbilledUnit>';
            responseBody +=         '<view:unbilledUnit> <view:callStatus>Awaiting Invoice</view:callStatus> <view:dialledNumber>447777111111</view:dialledNumber> <view:unitOfMeasure>Unit</view:unitOfMeasure> <view:unitsUsed>1200</view:unitsUsed> <view:classificationCode>P040</view:classificationCode>';
            responseBody +=          '<view:classificationDescription>Media Messages</view:classificationDescription> <view:bundleCallStatus>No</view:bundleCallStatus> <view:preBundlePrice>0</view:preBundlePrice> <view:discountPrice>0</view:discountPrice> <view:callPrice>0</view:callPrice> </view:unbilledUnit>';
            responseBody +=         '<view:unbilledUnit> <view:callStatus>Awaiting Invoice</view:callStatus> <view:dialledNumber>447777111111</view:dialledNumber> <view:unitOfMeasure>Unit</view:unitOfMeasure> <view:unitsUsed>74</view:unitsUsed> <view:classificationCode>P2002</view:classificationCode>';
            responseBody +=          '<view:classificationDescription>Text to International Number</view:classificationDescription> <view:bundleCallStatus>No</view:bundleCallStatus> <view:preBundlePrice>0</view:preBundlePrice> <view:discountPrice>0</view:discountPrice> <view:callPrice>0</view:callPrice> </view:unbilledUnit>';
            responseBody +=         '<view:unbilledUnit> <view:callStatus>Awaiting Invoice</view:callStatus> <view:dialledNumber>447777111111</view:dialledNumber> <view:unitOfMeasure>Unit</view:unitOfMeasure> <view:unitsUsed>20</view:unitsUsed> <view:classificationCode>EW5173</view:classificationCode>';
            responseBody +=          '<view:classificationDescription>Roamed Text Message Zone 1</view:classificationDescription> <view:bundleCallStatus>No</view:bundleCallStatus> <view:preBundlePrice>0</view:preBundlePrice> <view:discountPrice>0</view:discountPrice> <view:callPrice>0</view:callPrice> </view:unbilledUnit>';
            responseBody +=         '<view:unbilledUnit> <view:callStatus>Awaiting Invoice</view:callStatus> <view:dialledNumber>idata.o2.co.uk</view:dialledNumber> <view:unitOfMeasure>KB</view:unitOfMeasure> <view:unitsUsed>51200</view:unitsUsed> <view:classificationCode>P800</view:classificationCode>';
            responseBody +=          '<view:classificationDescription>O2 Data Service</view:classificationDescription> <view:bundleCallStatus>No</view:bundleCallStatus> <view:preBundlePrice>0</view:preBundlePrice> <view:discountPrice>0</view:discountPrice> <view:callPrice>0</view:callPrice> </view:unbilledUnit>';
            responseBody +=         '<view:unbilledUnit> <view:callStatus>Awaiting Invoice</view:callStatus> <view:dialledNumber>idata.o2.co.uk</view:dialledNumber> <view:unitOfMeasure>KB</view:unitOfMeasure> <view:unitsUsed>55000</view:unitsUsed> <view:classificationCode>EHW800</view:classificationCode>';
            responseBody +=          '<view:classificationDescription>O2 Data Service whilst Roaming</view:classificationDescription> <view:bundleCallStatus>No</view:bundleCallStatus> <view:preBundlePrice>0</view:preBundlePrice> <view:discountPrice>0</view:discountPrice> <view:callPrice>0</view:callPrice> </view:unbilledUnit>';
            responseBody +=       '</view:unbilledUnits>';
            responseBody +=     '</view:getUnbilledUsageResponse>';
            responseBody +=   '</soapenv:Body>';
            responseBody += '</soapenv:Envelope>';
            
            response.setStatusCode(200);
            response.setBody(responseBody);
        }
        else
        {
            System.assert(false);
        }

        return response;
    }
}