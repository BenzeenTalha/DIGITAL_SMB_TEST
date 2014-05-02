/*
    SSOCreateUser - Email Handler for user registration
    Used as a workaround required as it cannot be done using a Custom Secure URL directly from the
    user registration controller
    Author: S O'Halloran
    Created: 12th Dec 2011
*/
global class MyO2BusinessCreateUser implements Messaging.InboundEmailHandler
{

    public static final String USERNAME_SUFFIX = Label.ENTERPRISE_USERNAME_SUFFIX;
    static final String PORTAL_PROFILE_NAME = Label.ENTERPRISE_PROFILE_NAME;
    public static final String SMB_USERNAME_SUFFIX = Label.SMB_USERNAME_SUFFIX;
    
    public String SMB_PORTAL_PROFILE_NAME = Label.SMB_PORTAL_PROFILE_NAME;
  
    static final String CONTACT_ID_PREFIX = '003';
    static final String DO_NOT_SEND_PASSWORD = 'DO_NOT_SEND_PASSWORD';
    static final String NEW_USER_EMAIL_TEMPLATE = 'MyO2BusinessNewUser';
    // Default service providers
    static final String SERVICE_PROVIDER_LIST = 'SSO_SP_Org;';
    
     static final String portalProfileId = [select id from profile where name=:PORTAL_PROFILE_NAME limit 1].Id;
   

    // Implementation of Messaging.InboundEmailHandler.handleInboundEmail
    // Create a result for returning back to our caller
    // Create user based on the email our handler received from the controller that handled the SSORegister page
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        // Subject will have the contact Id only, but for sandbox will also have "Force.com Sandbox:"
        try
        {
            MyO2BusinessCreateUser.createUserFromContact(email);
        }
        catch (Exception e)
        {
            // TODO
            // we may want to return
            // result.success = false;
            // result.message = ‘Oops, I failed.’
        }
        return result;
    }

    // The contact.Id is in the email subject
    // Use it to find the account and then update the account with the UserId that we get from the running context
    // Then call the method to create the user
    private static void createUserFromContact(Messaging.InboundEmail email)
    {
        String contactId = '';
        boolean sendPassword = true;
        if(email.subject.indexOf('003')>-1)
        {
            // Parse contact Id from email subject
            contactId = email.subject.substring(email.subject.indexOf(CONTACT_ID_PREFIX));
            // Parse do not send password from email body
            if(email.plainTextBody.indexOf('DO_NOT_SEND_PASSWORD')>-1) sendPassword=false;
            for(Contact c: [select id, accountId, firstname, lastname, email, description, phone,MobilePhone from contact where id=:contactId limit 1])
            {
                // The account owner needs to changed as a portal user cannot be created on an account owned by a user without a role
                // High volume portal users do not have roles
                // The User account associated with this email handler does have a role - so use it.
                system.debug('c accountid ::'+c.Account.Segment__c);
                Account acc = new Account(id=c.accountId, ownerId=UserInfo.getUserId());
                update acc;
                system.debug('Acc details::'+acc );
                MyO2BusinessCreateUser.createUserFromContact(c, sendPassword);
            }
        }
    }

    //--------------------------------------------------------------------------
    // Take the contact and use its fields to populate a user
    //--------------------------------------------------------------------------
    public static User mapContactToUser(Contact c)
    {
        User u = new User();
        system.debug('c account id::'+c.Account.Segment__c);
        mapContactToUser(c, u);
        u.ContactId = c.Id;
        return u;
    }

    //--------------------------------------------------------------------------
    // Map contact to user
    //--------------------------------------------------------------------------
    public static void mapContactToUser(Contact c, User u)
    {
        String alias = '';
        if (c.firstname.length() > 0)
        {
            alias += c.firstname.substring(0, 1);
        }
        if(c.lastname.length()>0)
        {
            alias += c.lastname.substring(0,Math.min(c.lastname.length(), 7));
        }
        u.Email = c.Email;
       
        u.FederationIdentifier = c.Id;
        String mobilePhone = SOAUtils.cleanDirectoryNumber(c.MobilePhone);
        u.MobilePhone = mobilePhone;
        u.Phone = c.Phone;
        u.FirstName = c.FirstName;
        u.LastName = c.LastName;
        u.Alias = Alias;

        // Set default values
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LocalesIdKey = 'en_GB';
        u.TimezonesIdKey = 'Europe/London';
        
        // check for the user segment to assign the appropiate profile
        
      /**  system.debug('account segment is :' + c.Account.Segment__c);
        
        String profile = null;
        if(c.Account.Segment__c.contains(Label.SMB_ACCOUNT_SEGMENT)){
            profile = Label.SMB_PORTAL_PROFILE_NAME;
      
             
        }else{
            
             profile = Label.ENTERPRISE_PROFILE_NAME;
            
        } */
        
        u.ProfileId = portalProfileId;
        u.username = c.email + USERNAME_SUFFIX;
        
        u.ProfileId = portalProfileId;
        u.SSO_Service_Providers__c = SERVICE_PROVIDER_LIST;
        u.SSO_Registration_State__c = MyO2BusinessUser.ACTIVATION_PENDING;
    }

    // Create the user and send welcome email (if configured)
    // On error add a description to the contact
    public static User createUserFromContact(Contact c, boolean sendEmail)
    {
        String alias = '';
        User u = null;
        if (c.firstname.length() > 0) alias += c.firstname.substring(0, 1);
        if (c.lastname.length() > 0)
        {
            alias += c.lastname.substring(0,Math.min(c.lastname.length(),7));
        }
       system.debug('C Account id Segment::'+c.Account.Segment__c);
        try
        {
            u = mapContactToUser(c);
            insert u;

            // Add Service Providers
            // !!!! DML  not allowed on permission set assignment
            // PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId=u.Id, PermissionSetId=SP_PERMISSION_SET);
            // insert psa;
            //PermissionSet.Name

            // The password send may be deferred, until registration is complete on a Service Provider
            //System.resetPassword(u.Id, sendPassword);
            try
            {
                if(sendEmail) sendNewUserEmail(u);
            }
            catch (Exception e2)
            {
                system.debug('exception2: '+e2);
                // absorb it - the email will have to be resent at a later time - maybe manually
            }
        }
        catch (Exception e)
        {
            system.debug('exception: '+e);
            // TODO: alert admin there was an error
            // Store the error somewhere against the contact
            // Temp store in Contact Description field
            //c.Description = e.getMessage();
            //update c;

            u = null;

            // pass this exception on to the caller for it to handle
            throw e;
        }
        return u;
    }

    // Using a template create the email and send it
    public static void sendNewUserEmail(User u)
    {
        MyO2BusinessSignOnUtils.sendEmail(u.Id, NEW_USER_EMAIL_TEMPLATE);
    }

    //--------------------------------------------------------------------------
    // Send a welcome email to a list of users
    //--------------------------------------------------------------------------
    public static void sendNewUserEmail(User[] users)
    {
        MyO2BusinessSignOnUtils.Emails emails =
            new MyO2BusinessSignOnUtils.Emails();
        for(User u: users)
        {
            emails.add(u.Id, NEW_USER_EMAIL_TEMPLATE);
        }
        emails.send();
    }
}