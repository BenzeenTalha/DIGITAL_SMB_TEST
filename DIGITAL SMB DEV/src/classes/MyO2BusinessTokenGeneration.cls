public class MyO2BusinessTokenGeneration
{
	//--------------------------------------------------------------------------
	// Generated token
	//--------------------------------------------------------------------------
    public String token {get; private set;}

	//--------------------------------------------------------------------------
	// Configuration
	//--------------------------------------------------------------------------
	public String configuration
	{
		get
		{
			if (configuration == null)
			{
				return MyO2BusinessToken.ACTIVATION;
			}
			else
			{
				return configuration;
			}
		}

		set;
	}

	//--------------------------------------------------------------------------
    // User id for token generation
	//--------------------------------------------------------------------------
    public Id userId
    {
        get;
        set
        {
            if (token == null)
            {
                token = MyO2BusinessToken.make(value, configuration);
            }
        }
    }

    private static final String dummyUrl = 'http://businessshop.preprod.cs13.force.com/MyO2Business/';

	//--------------------------------------------------------------------------
	// Site URL
	//--------------------------------------------------------------------------
    public static String siteURL
    {
        get
        {
            if (siteURL == null)
            {
                if (!Test.isRunningTest())
                {
                    siteURL = SSO_URL__c.getInstance('Default').SiteURL__c;
                }
                else
                {
                    // default to the live service (currently preprod)
                    siteURL = dummyUrl;
                }
            }
            return siteURL;
        }
        private set;
    }
}