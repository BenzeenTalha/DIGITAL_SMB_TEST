public with sharing class MyO2BusinessUserUnlock {
    /*
        This controller unlocks a user by resetting their password only if
        they are locked out 
    */
    public String username {get; set;}
    public boolean isError {get; private set;}
    Pattern domainPattern = Pattern.compile('^.*cs[\\d]*.force.com.*');
    // The reset URL needs to go to the login service either on test.salesforce.com or login.salesforce.com
    String BASE_URL = (domainPattern.matcher(URL.getSalesforceBaseUrl().toExternalForm()).matches() 
        ? 'https://test.salesforce.com': 'https://login.salesforce.com') 
        + System.Label.MO2B_FORGOT_PASSWORD;
    public PageReference resetPassword() {
        isError = false;
        PageReference ref = null;
        List <User> users = [select id from user where username=:username limit 1];
        if(users.size()==0) {
            isError = true;
        } else {
            List <LoginHistory> lh = [select id, userId, LoginTime, Status from loginhistory 
                              where userId=:users[0].Id 
                              order by loginTime desc limit 1];
            if(lh.size()==1 && lh[0].Status!='Success') {
                System.resetPassword(lh[0].userId,false);
            } 
            ref = new PageReference(BASE_URL + EncodingUtil.urlEncode(username, 'UTF-8'));            
        }            
        return ref;
    }    
}