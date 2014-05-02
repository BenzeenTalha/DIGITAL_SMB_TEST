/*
*       This class is used to exposed the Subscriber Profile Web Service for a JaJa prototype
*		The service takes a directory number as an input and returns "O2" or "Not O2", depending if the number is in the O2 network or not
*       SO'Halloran - (SFDC)
*       Revision History 
*       1.0    10/03/2011  Initial Version
*/   
global class SubscriberWS {

    // Exposed Web Service for Jaja prototype
         
    webService static String getSubscriberProfile(String inputNumber) {
        String operator = '';
        SOASubscriberService.SubscriberPort port = new SOASubscriberService.SubscriberPort();
        port.clientCertName_x = SOAUtils.CERTIFICATE_NAME;
        port.timeout_x = SoaUtils.SOA_TIMEOUT;
        SOASubscriberData.subscriberProfileType profile = port.getSubscriberProfile(inputNumber);                
        if(profile!=null && profile.operator!=null) operator=profile.operator;
        return operator;  
    }
    
    static testMethod void testSubscriberWS() {
    	String output = SubscriberWS.getSubscriberProfile('012345678910');
    	System.assertEquals('',output);
    }

}