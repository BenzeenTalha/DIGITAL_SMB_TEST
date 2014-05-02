public with sharing class MyO2BusinessLogoutController {

    public String url {get; set;}
    
    // Need to iterate through the SPs to call the logout page in each and also keeps state for the user to move to the next one
    public PageReference redirect()
    {
        PageReference ref = null;
        // don't redirect back to the SP which requested the SLO
        String SP = ApexPages.currentPage().getParameters().get('SP');
        // interate through the logout urls, using the cookie to keep state
        String logoutURL = getNextSession(SP);
        system.debug('logoutURL: ' + logoutURL);
        if(logoutURL == null)
        {
           //url = Site.getCurrentSiteUrl() + '/secur/logout.jsp';
           url = Site.getCurrentSiteUrl() + 'MyO2SMBLogoutPage';
        }
        else
        {
            url = logoutURL;
        }
        ref = new PageReference(url);
        system.debug('ref: ---------' + ref);
        return ref;
    }

    private static SSO_Service_Provider__c getSP(string spName)
    {
        SSO_Service_Provider__c serviceProvider = null;
        for(SSO_Service_Provider__c SP : SSO_Service_Provider__c.getall().values())
        {
            if(SP.name.contains(spName))
            {
                serviceProvider = SP;
                break;
            }
        }
        return serviceProvider;
    }

    // interate through the logout urls
    // but ignore the SP that called us as it has already logged out (or is in process of doing so)
    private String getNextSession(String SP)
    {
        String nextSession = null;
        Set <String> sset = getSessionsSet();

        if(SP != null)
        {
            SSO_Service_Provider__c serviceProvider = getSP(SP);
            system.debug('serviceProvider: ' + serviceProvider);
            sset.remove(serviceProvider.logout_url__c);
        }

        for(String s : sset )
        {
            system.debug('s: ' + s);
            sset.remove(s);
            nextSession = s;
            break;
        }
        Cookie sessions = new Cookie('sessions', JSON.serialize(sset), null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{sessions});
        return nextSession;
    }

    // get list of sessions
    private static Set<String> getSessionsSet()
    {
        Cookie sessions = ApexPages.currentPage().getCookies().get('sessions');
        Set <String> sset = new Set<String>();
        system.debug('sessions: ' + sessions);
        if(sessions != null)
        {
            sset = (Set<String>)JSON.deserialize(sessions.getValue(), Set<String>.class);
        }
        system.debug('sset: ' + sset);
        return sset;
    }
}