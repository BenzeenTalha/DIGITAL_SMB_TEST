//------------------------------------------------------------------------------
// Extension used for sending and validating activation code
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessActivationCodeExtension
{
    //--------------------------------------------------------------------------
    // Constants
    //--------------------------------------------------------------------------
    static final String MT_PROFILE = 'MTProfile';
    static final String ACTIVATION = 'Activation';
    static final String FORGOT_PASSWORD = 'ForgotPassword';

    //--------------------------------------------------------------------------
    // Members
    //--------------------------------------------------------------------------
    public String activationCode { get; set; }
    public String activationCodeTemp { get; set; }
    public Boolean isActivationCodeSent { get; private set; }
    public String sendingCodeErorr { get; private set; }
    public Boolean isActivationCodeValid { get; private set; }
    public String activationCodeError { get; private set; }

    //--------------------------------------------------------------------------
    // Private members
    //--------------------------------------------------------------------------
    MyO2BusinessUserInterface userInterface;
    MyO2BusinessForgotPasswordController forgotPasswordController;

    static final Map<String, String> textMessages = new Map<String, String>
    {
        ACTIVATION => 'Here is your code: {0}\n\nPlease enter this code to activate your O2 account.',
        FORGOT_PASSWORD => 'Here is your code: {0}\n\nPlease enter this code to proceed with forgot password.'
    };

    //--------------------------------------------------------------------------
    // Contructor for MyO2BusinessActivationController
    //--------------------------------------------------------------------------
    public MyO2BusinessActivationCodeExtension(MyO2BusinessActivationController controller)
    {
         userInterface = controller;
         init();
    }

    //--------------------------------------------------------------------------
    // Constructor for MyO2BusinessForgotPasswordController
    //--------------------------------------------------------------------------
    public MyO2BusinessActivationCodeExtension(MyO2BusinessForgotPasswordController controller)
    {
        userInterface = controller;
        init();
    }

    //--------------------------------------------------------------------------
    // Initialize members
    //--------------------------------------------------------------------------
    private void init()
    {
        activationCode = '';
        isActivationCodeValid = false;
        isActivationCodeSent = false;
    }

    //--------------------------------------------------------------------------
    // Send activation code SMS to user mobile phone
    //--------------------------------------------------------------------------
    public PageReference sendActivationCode()
    {
        return sendCode(ACTIVATION);
    }

    //--------------------------------------------------------------------------
    // Send forgot password code SMS to user mobile phone
    //--------------------------------------------------------------------------
    public PageReference sendForgotPasswordCode()
    {
        return sendCode(FORGOT_PASSWORD);
    }

    //--------------------------------------------------------------------------
    // Sending any kind of code
    //--------------------------------------------------------------------------
    private PageReference sendCode(String type)
    {
        MyO2BusinessUser businessUser = userInterface.getBusinessUser();
        //
        // When user doesn't exist we are acting like user has received
        // activation code
        //
        if (businessUser == null)
        {
            isActivationCodeSent = true;
            return null;
        }
        String activationCodeLocal = businessUser.generateActivationCode();
        try
        {
            system.debug('before activation code extension');
            String textMessage = textMessages.get(type);
            String message = textMessage.replaceAll('\\{0\\}', activationCodeLocal);
            sendSMS(businessUser.getMobilePhone(), activationCodeLocal, message);
            system.debug('after activation code extension');
            businessUser.save();
            isActivationCodeSent = true;
            activationCodeTemp = activationCodeLocal;
        }
        catch (Exception e)
        {
            isActivationCodeSent = false;
            sendingCodeErorr = e.getMessage();
        }
        return null;
    }


    //--------------------------------------------------------------------------
    // Validate activation code
    //--------------------------------------------------------------------------
    public PageReference validateActivationCode()
    {
        MyO2BusinessUser businessUser = userInterface.getBusinessUser();
        system.debug('activationCode: ' + activationCode);
        //
        // If user doesn't exist we are pretending that code is invalid
        //
        if (businessUser == null
            || !businessUser.validateActivationCode(activationCode))
        {
            isActivationCodeValid = false;
            activationCodeError = 'That code doesn\'t match the last one we sent to your mobile.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, activationCodeError));
        }
        //
        // Activation code is valid
        //
        else
        {
            isActivationCodeValid = true;
        }

        return null;
    }

    //-----------------------------------------------------------------------------
    // Create and send forgot password SMS
    //-----------------------------------------------------------------------------
    public static void sendSMS(String mobilePhone, String activaitonCode, String textMessage)
    {
        String mtProfile = getMTProfile();
        system.debug('Message: ' + textMessage);
        SOASendMessage.sendSMS(mtProfile, mobilePhone, textMessage);
    }

    //-----------------------------------------------------------------------------
    // Gets MT profile from SSO settings
    //-----------------------------------------------------------------------------
    public static String getMTProfile()
    {
        String returnValue = null;
        SSOSettings__c ssoSettings = SSOSettings__c.getInstance(MT_PROFILE);
        if (ssoSettings != null)
        {
            returnValue = ssoSettings.String__c;
            system.debug('MTProfile: ' + returnValue);
        }
        return returnValue;
    }

}