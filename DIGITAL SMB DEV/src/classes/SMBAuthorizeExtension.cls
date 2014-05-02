public with sharing class SMBAuthorizeExtension {
   
    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------
    public SMBAuthorizeExtension()
    {
    	
    }

    //--------------------------------------------------------------------------
    // Constructor does nothing
    //--------------------------------------------------------------------------
    public SMBAuthorizeExtension(Object controller)
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

}