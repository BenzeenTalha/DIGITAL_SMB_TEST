/*
	WSSecurityUtil - Used to retrieve credentials for SOA Gateway	
	Author: D Sabey
	Created: 
	Modified: 6-12-2011 / S O'Halloran 
				Updated to support multiple credentials, as the credentials can vary by endpoint.
				A new field endpoint__c is added to the object wsSecurity__c
				If an endpoint is passed to the getUserName or getPassword methods the matching set of 
				credentials are retrieved.
				To support existing calls, if only one credential exists it will always be returned, 
				so the endpoint in that case does not need to be passed.
			 
*/
public class WSSecurityUtil {
	
	private static map<String, credential> crs =  new map<String, credential>();
	
	private class credential {
    	private String userName;
    	private String password;
    	private String endpoint;
	}
    
    public static String getUserName() {
    	return getUserName(null);
    }

    public static String getPassword() {
    	return getPassword(null);
    }
        
    public static String getUserName(String endpoint) {
		return getCredential(endpoint).userName;
    }
       
    public static String getPassword(String endpoint) {      
        return getCredential(endpoint).password;
    }

    private static credential getCredential(String endpoint) {
    	credential cr = null;
        if (crs.isEmpty()) {
        	getFieldValues();
        } 
    	if(crs.size()>0) {
    		if(crs.size()!=1) { 
    			for(String ep : crs.keySet()) {
    				if(endpoint!=null && ep!=null && endpoint.contains(ep)) {
    					cr = crs.get(ep); 
    				}
    			}
    		}
    		if(cr==null || crs.size()==1) {
    			cr = crs.values()[0];
    		}
    	}
    	return cr;
    } 
            
    private static void getFieldValues() {
        for(wsSecurity__c wss : [Select Username__c, 
                                    Password__c,
                                    Endpoint__c 
                             From wsSecurity__c
                             Order By CreatedDate desc]) {
            
            credential c = new credential();
            c.username = wss.Username__c;
            c.password = wss.Password__c;  
            c.endpoint = wss.Endpoint__c;           	
            crs.put(wss.Endpoint__c, c);
        }
    }
    
    
    static testMethod void testWSSecurityUtilRegression() {
 		for(wsSecurity__c[] wsss: [select id from wsSecurity__c]) {
 			delete wsss;
 		}
 		wsSecurity__c wss = new wsSecurity__c(Username__c='jbloggs',Password__c='secret');
 		insert wss;
 		Test.startTest();
 		String un = WSSecurityUtil.getUserName();
 		String pwd = WSSecurityUtil.getPassword();
		String yun = WSSecurityUtil.getUserName('y');
		String ypwd = WSSecurityUtil.getPassword('y'); 		
 		Test.stopTest();
 		system.assertEquals('jbloggs',un);
 		system.assertEquals('secret',pwd);
 		system.assertEquals('jbloggs',yun);
 		system.assertEquals('secret',ypwd); 		
    }   
        
    static testMethod void testWSSecurityUtilNew() {
 		for(wsSecurity__c[] wsss: [select id from wsSecurity__c]) {
 			delete wsss;
 		}
 		wsSecurity__c wss = new wsSecurity__c(Username__c='x-un',Password__c='x-pwd');
 		insert wss;
 		wsSecurity__c wss2 = new wsSecurity__c(Username__c='y-un',Password__c='y-pwd',Endpoint__c='y');
 		insert wss2;
 		wsSecurity__c wss3 = new wsSecurity__c(Username__c='z-un',Password__c='z-pwd',Endpoint__c='z');
 		insert wss3;
		Test.startTest();
		String xun = WSSecurityUtil.getUserName();
		String xpwd = WSSecurityUtil.getPassword();
		String yun = WSSecurityUtil.getUserName('y');
		String ypwd = WSSecurityUtil.getPassword('y');
		String zun = WSSecurityUtil.getUserName('z');
		String zpwd = WSSecurityUtil.getPassword('z');
		Test.stopTest();
 		system.assertEquals('x-un',xun);
 		system.assertEquals('x-pwd',xpwd);
 		system.assertEquals('y-un',yun);
 		system.assertEquals('y-pwd',ypwd); 	
 		system.assertEquals('z-un',zun);
 		system.assertEquals('z-pwd',zpwd);  			
    }     
}