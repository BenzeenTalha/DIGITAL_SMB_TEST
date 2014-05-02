/*
	SOASecurityElement - Used to pass credentials to SOA Gateway Sevices	
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

public class SOASecurityElement {

    public class Security_element{
	    public Security_element(String username, String password) {
	      usernameToken = new UsernameToken_element(username,password);
	    }
	    public Security_element() {
	      usernameToken = new UsernameToken_element(WSSecurityUtil.getUserName(),WSSecurityUtil.getPassword());
	    }	 
	    public Security_element(String endpoint) {
	      usernameToken = new UsernameToken_element(WSSecurityUtil.getUserName(endpoint),WSSecurityUtil.getPassword(endpoint));
	    }		       
	    public UsernameToken_element usernameToken;
	    private String[] usernameToken_type_info = new String[]{'UsernameToken','http://www.w3.org/2001/XMLSchema','element','1','1','false'};
	    private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
	    private String[] field_order_type_info = new String[]{'usernameToken'};
    }

    public class SOAConsumerTransactionID_element {
    	private String email;
    	public SOAConsumerTransactionID_element(String email) { this.email = email; }
        public String SOAConsumerTransactionID='SFDC-' + System.now().format('yyyyMMddHHmmssSSSZ') + ':' + UserInfo.getOrganizationId() + '-' + UserInfo.getUserId()+ '-' + UserInfo.getUserName() + '-' + email;
        private String[] SOAConsumerTransactionID_type_info = new String[]{'SOAConsumerTransactionID','http://www.w3.org/2001/XMLSchema','SOAConsumerTransactionIDType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soa.o2.co.uk/coredata_1','true','false'};
        private String[] field_order_type_info = new String[]{'SOAConsumerTransactionID'};   
    }     

    public class UsernameToken_element {
	    public UsernameToken_element(String username, String password) {
	      this.username = username;
	      this.password = password;	    
	    }
	    public UsernameToken_element() {
	      this.username = WSSecurityUtil.getUserName();
	      this.password = WSSecurityUtil.getPassword();	    
	    }	    
	    public String username;
	    public String password;
        private String[] username_type_info = new String[]{'Username','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'username','password'};
    }
    
    static testMethod void testSOASecurityElement() {
 		for(wsSecurity__c[] wsss: [select id from wsSecurity__c]) {
 			delete wsss;
 		}
 		wsSecurity__c wss = new wsSecurity__c(Username__c='x-un',Password__c='x-pwd');
 		insert wss;
 		wsSecurity__c wss2 = new wsSecurity__c(Username__c='y-un',Password__c='y-pwd',Endpoint__c='y');
 		insert wss2;
 		Test.startTest();    	
    	SOASecurityElement.SOAConsumerTransactionID_element transactionId = new SOASecurityElement.SOAConsumerTransactionID_element('test@test.com');
    	SOASecurityElement.UsernameToken_element unToken = new SOASecurityElement.UsernameToken_element();
    	SOASecurityElement.Security_element securityElementX = new  SOASecurityElement.Security_element();
    	SOASecurityElement.Security_element securityElementY = new  SOASecurityElement.Security_element('y');
    	SOASecurityElement.Security_element securityElementZ = new  SOASecurityElement.Security_element('z-un','z-pwd');
    	SOASecurityElement.UsernameToken_element usernameTokenX = securityElementX.usernameToken;
    	SOASecurityElement.UsernameToken_element usernameTokenY = securityElementY.usernameToken;
    	SOASecurityElement.UsernameToken_element usernameTokenZ = securityElementZ.usernameToken;
		String wun = unToken.username;
		String wpwd = unToken.password;
		String xun = usernameTokenX.username;
		String xpwd = usernameTokenX.password;
		String yun = usernameTokenY.username;
		String ypwd = usernameTokenY.password;  
		String zun = usernameTokenZ.username;
		String zpwd = usernameTokenZ.password;			
    	Test.stopTest();
   		system.assertEquals('x-un',wun);
 		system.assertEquals('x-pwd',wpwd);    	
   		system.assertEquals('x-un',xun);
 		system.assertEquals('x-pwd',xpwd);
 		system.assertEquals('y-un',yun);
 		system.assertEquals('y-pwd',ypwd);  
 		system.assertEquals('z-un',zun);
 		system.assertEquals('z-pwd',zpwd);  		   	
    }
}