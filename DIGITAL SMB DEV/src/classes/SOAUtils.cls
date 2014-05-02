public class SOAUtils {

    public static final Map<String, Map<String, Boolean>> errors = new Map<String, Map<String, Boolean>>
    {
        'Rejected by policy'                                => new Map<String, Boolean>{'markRecordProcessed' => false,  'cancelJob' => false, 'retryJob' => true,  'deferJob' => true},
        'SLM Monitor'                                       => new Map<String, Boolean>{'markRecordProcessed' => false,  'cancelJob' => true,  'retryJob' => true,  'deferJob' => true},
        'IO Exception: Read timed out'                      => new Map<String, Boolean>{'markRecordProcessed' => false,  'cancelJob' => false, 'retryJob' => true,  'deferJob' => true},
        'Internal Error'                                    => new Map<String, Boolean>{'markRecordProcessed' => true,   'cancelJob' => false, 'retryJob' => true,  'deferJob' => true},

        'One or more backend services are not available'    => new Map<String, Boolean>{'markRecordProcessed' => false,   'cancelJob' => true,  'retryJob' => true,  'deferJob' => true},        
        'Service call timed out. Please try again later.'   => new Map<String, Boolean>{'markRecordProcessed' => false,   'cancelJob' => true,  'retryJob' => true,  'deferJob' => true},
        'Internal service error'                            => new Map<String, Boolean>{'markRecordProcessed' => false,   'cancelJob' => true,  'retryJob' => true, 'deferJob' => true},
        'Backend system error has occurred'                 => new Map<String, Boolean>{'markRecordProcessed' => false,   'cancelJob' => true,  'retryJob' => true,  'deferJob' => true},
        'Unknown/Uncaught error has occurred.'              => new Map<String, Boolean>{'markRecordProcessed' => false,   'cancelJob' => true,  'retryJob' => true,  'deferJob' => true},
        
        'WebService returned a SOAP Fault'                  => new Map<String, Boolean>{'markRecordProcessed' => true,   'cancelJob' => false, 'retryJob' => true,  'deferJob' => true}
    }; 
     
    public static final String USER_SOA_FAULT_MESSAGE = 'Backend system error has occurred. Please contact service support for help on this.';
    public static final String USER_SFDC_FAULT_MESSAGE = 'Salesforce save error has occurred. Please contact service support for help on this.';
    public static final String SOA_WRITE_ACCESS_MESSAGE = 'This is a write service which cannot be used on the live gateway';
    public static final String CERTIFICATE_NAME = 'salesforce_juc2'; 
    // This will never change - specific only to O2, used to determine if running in production vs sandbox
    public static final String LIVE_ORG_ID = '00D200000005EuoEAE';
    
    //public static final String ENDPOINT = SOA_Integration_Settings__c.getValues('Line_Availability_Settings').Endpoint_Server__c;   
	public static String ENDPOINT { get {
		if (ENDPOINT == null) {
			if (!Test.IsRunningTest()) {
				ENDPOINT = SOA_Integration_Settings__c.getValues('Line_Availability_Settings').Endpoint_Server__c; 
			} else {
				// sensible default for DEV
				ENDPOINT = 'https://sdpapi.ref.o2.co.uk';
			}
		}
		return ENDPOINT;
		} private set;
	  
	}
    //public static final Integer SOA_TIMEOUT = Integer.valueOf(SOA_Integration_Settings__c.getValues('Line_Availability_Settings').Timeout__c);
	public static Integer SOA_TIMEOUT { get {
			if (SOA_TIMEOUT == null) {
				if (!Test.isRunningTest()) {
					SOA_TIMEOUT = Integer.valueOf(SOA_Integration_Settings__c.getValues('Line_Availability_Settings').Timeout__c); 
				} else {
					// a sensible default
					SOA_TIMEOUT = 60;					
				}
			}
			return SOA_TIMEOUT;
		} private set;
		
	}
    public static final String LIVE_SOA_GATEWAY = 'https://sdpapi.o2.co.uk';
    public class SOATypeAccessException extends Exception {}
    public class SOATypeException extends Exception {}
    public class SOATestMethodException extends Exception {} 
    public class DMLMethodException extends Exception {}
    public class XMLSendRequestException extends Exception {}
    public class XMLParseResponseException extends Exception {} 
    
    // Live write services should be allowed to be called from the production org only
    public static void liveCheckOnWriteServices (String serviceEndpoint) {
        if(serviceEndpoint.contains(LIVE_SOA_GATEWAY) && UserInfo.getOrganizationId()!=LIVE_ORG_ID) {
            throw new SOATypeAccessException(SOA_WRITE_ACCESS_MESSAGE);
        }
    }

    public static boolean isValidPostcode(String postcode) {
        if(postcode==null) return false;
        postcode = postcode.toUpperCase();
        //Pattern postcodePattern = Pattern.compile('[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][ABD-HJLNP-UW-Z]{2}');
        Pattern postcodePattern = Pattern.compile('^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z])))) {0,1}[0-9][A-Za-z]{2})$');        
        Matcher matcher = postcodePattern.matcher(postcode);
        if (matcher.matches()) {
            return true;
        } else {
            return false;
        } 
    }
    
    public static String cleanDirectoryNumber (String directoryNumber) {
        if(directoryNumber==null) return '';
        Pattern numberPattern = Pattern.compile('[^\\d,]');
        String pnumber = numberPattern.matcher(directoryNumber).replaceAll('');
    
        // we are expecting it to start with '0' or '00' or '44'
        // if it doesn't then we should return and not clean it up
        if (pnumber != null) {
            pnumber = pnumber.replaceAll('^0044','44'); 
            pnumber = pnumber.replaceAll('^0','44');
        }   
        return pnumber;   
    }
    
    public static String cleanDirectoryNumberEMLC (String directoryNumber) {
        if(directoryNumber==null) return '';
        Pattern numberPattern = Pattern.compile('[^\\d,]');
        String pnumber = numberPattern.matcher(directoryNumber).replaceAll('');
        // EMLC broadband service which calls directly to BT expect directory number to be prefixed with 0 instead of 44
        if (pnumber != null) { 
            pnumber = pnumber.replaceAll('^44','0');
        }   
        return pnumber;   
    }
    
    public static boolean isValidDirectoryNumber(String directoryNumber) {
        directoryNumber = cleanDirectoryNumber(directoryNumber);
        if(directoryNumber==null) return false;
        if (!directoryNumber.startsWith('44'))
        {
            return false;
        } else if (directoryNumber.startsWith('440')) {
            return false;
        }
        
        // TODO: a 10 or 11 digit number has 9 or 10 digits after removal of '0' then plus 2 (for 44 international dial)
        // makes 11 or 12. I think the value of 13 should be retired as it means a phone number of 12 digits 
        if(directoryNumber.length()==11 || directoryNumber.length()==12) { 
            return true;
        } else {
            return false;
        }
    } 
    
    public static boolean isValidMAC(String MAC) {
        if(MAC==null) return false;
        Pattern MACpattern = Pattern.compile('^(L|OGEA).*');        
        Matcher matcher = MACpattern.matcher(MAC);  
        return matcher.matches();          
    }         

}