//------------------------------------------------------------------------------
// Controler for authorization of activation process.
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessAuthorizeRegistration
{
    //--------------------------------------------------------------------------
    // Constants
    //--------------------------------------------------------------------------
    public static final String USER_TYPE_GUEST = 'Guest';

    //--------------------------------------------------------------------------
    // Members
    //--------------------------------------------------------------------------
    String token;
    MyO2BusinessToken o2Token;

    public MyO2BusinessAuthorizeRegistration()
    {
        token = ApexPages.currentPage().getParameters().get('tk');
        o2Token = new MyO2BusinessToken(token);
    }
    public boolean NewActivationEmailSent{ get; set; }

    //--------------------------------------------------------------------------
    // Take the token passed into page and check it is valid
    // If not display an error
    // If valid then get the fields, reset the password and logon to the site
    // with the temporary password
    // If token user is loged in redirect to change password page
    //--------------------------------------------------------------------------
    public PageReference authorize()
    {
        PageReference pr = null;
        //
        // If token is valid
        //
        if (o2Token.validate(MyO2BusinessToken.ACTIVATION))
        {
            system.debug('token is valid');
            //
            // Redirect to activation page
            //
            try
            {
                pr = activationPage();
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                     'Different user is in activation process'));
            }
        }
        else
        {
            if (o2Token.validateUserAndOrg()
                && o2Token.validateSingleUse())
            {
                system.debug('token is expired');
                //
                // If user, org and user is in activation pending state
                // goto expiration link
                //
                pr = new PageReference('/apex/MyO2BusinessLinkExpired');
                pr.getParameters().put('tk', token);
                pr.setRedirect(true);
            }
            else
            {
                system.debug('token is invalid');
                //
                // Token is not valid and show error message
                //
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MO2B_TOKEN_INVALID));
            }
        }
        return pr;
    }

    //-----------------------------------------------------------------------------
    // Returns page reference that redirects to change password page
    //-----------------------------------------------------------------------------
    private PageReference activationPage()
    {
        PageReference pr = null;
        String userId = o2Token.getUserId();
        //
        // If user is already logged in
        //
        if (UserInfo.getUserType() == USER_TYPE_GUEST)
        {
            //
            // Reset password and login to cusotmer portal
            //
            String tempPassword = resetUserPassword(userId);
            System.debug('@@@@ userId : ' + userId);
            System.debug('@@@@ userName : ' + user.userName);
            pr = Site.login(o2Token.getUser().getUserName(),
                            tempPassword, null);
        }
        return pr;
    }

    //--------------------------------------------------------------------------
    // Reset user password
    //--------------------------------------------------------------------------
    private String resetUserPassword(String userId)
    {
        system.ResetPasswordResult rpr;
        //
        // Exception can happen different user stucked with activation
        //
        rpr = system.resetPassword(userId, false);
        return rpr.getPassword();
    }

    //-----------------------------------------------------------------------------
    //Sends new activation email
    //-----------------------------------------------------------------------------
    public PageReference resendActivationEmail()
    {
    
        if (o2Token.getUser() != null)
        {

            MyO2BusinessCreateUser.sendNewUserEmail(o2Token.getUser().getUser());
            NewActivationEmailSent = true;
        }
        else
        {
            system.debug('resendActivationEmail: user doesn\'t exist');
            //
            // Token is not valid and show error message
            //
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MO2B_TOKEN_INVALID));
        }
        return null;
    }
}