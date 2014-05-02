//------------------------------------------------------------------------------
// Authorization of Enterprise portal pages
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessAuthorizeExtension
{
    
    public Boolean smbUser{get; set;}
    MyO2BusinessUser businessUser;
    
    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------
    public MyO2BusinessAuthorizeExtension()
    {
        
        
        smbUser = CaseUtils.checkLoginUserSegment();
        
    }

    //--------------------------------------------------------------------------
    // Constructor does nothing
    //--------------------------------------------------------------------------
    public MyO2BusinessAuthorizeExtension(Object controller)
    {
    }

    //--------------------------------------------------------------------------
    // Authorization of current user
    // If user is not authorized return to login page
    //--------------------------------------------------------------------------
    public PageReference authorize()
    {
        PageReference ref = null;
        try
        {
            //
            // If user is guest or not active return login screen
            //
            if (!MyO2BusinessSignOnUtils.authorize())
            {
                ref = Page.MyO2BusinessLogin;
            }
            else {
            	MyO2BusinessUser businessUser = new MyO2BusinessUser();
            	if(businessUser != null && businessUser.getAccountSegment().contains(Label.SMB_ACCOUNT_SEGMENT)){
               		ref = Page.smbhome;
	            }
            }
        }
        catch (Exception e)
        {
            //
            // Unknown exception
            //
            system.debug('authorize: user not identifield: ' + e);
            ref = Page.MyO2BusinessLogin;
        }
        return ref;
    }
    
    //--------------------------------------------------------------------------
    // Live Chat    
    //--------------------------------------------------------------------------

     public String getLiveWebchatEnabled() {   
         if (OnlineGeneralSettings__c.getInstance('Enable Live Chat')!=null) 
             return OnlineGeneralSettings__c.getInstance('Enable Live Chat').Value__c;
         else 
             return ''; 
     }    
}