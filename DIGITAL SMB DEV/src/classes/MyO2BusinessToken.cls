//------------------------------------------------------------------------------
// Token generation and validations.
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessToken
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	public static final String ACTIVATION = 'Activation';
	public static final String EMAIL_CONFIRMATION = 'Email_Confirmation';
	public static final String FORGOT_PASSWORD = 'Forgot_Password';
	private static final String TOKEN_KEY = 'Token_Key';

	//--------------------------------------------------------------------------
	// Members
	//--------------------------------------------------------------------------
	private Map<String, String> tokenMap;
	private MyO2BusinessUser user;
	private String tokenConfiguration;

	//--------------------------------------------------------------------------
	// Getters / setters
	//--------------------------------------------------------------------------
	public String getUserId()
	{
		String uid = tokenMap.get('uId');
		system.debug('uid: ' + uid);
		return uid;
	}

	//--------------------------------------------------------------------------
	// Get configuration type
	//--------------------------------------------------------------------------
	public String getConfiguration()
	{
		String cfg = tokenMap.get('cfg');
		system.debug('cfg: ' + cfg);
		return cfg;
	}

	//--------------------------------------------------------------------------
	// Get user
	//--------------------------------------------------------------------------
	public MyO2BusinessUser getUser()
	{
		return user;
	}

	//--------------------------------------------------------------------------
	// Constructor
	// Generates token map from token
	// 1. Decrypts token by base64 decoding and AES256 decryption
	// 2. JSON deserialize to token map
	//--------------------------------------------------------------------------
	public MyO2BusinessToken(String token)
	{
		if (token != null)
		{
			try
			{
				String plainString = decryptAES(token);
				tokenMap = (Map<String, String>)JSON.deserialize(plainString, Map<String, String>.class);
				tokenConfiguration = tokenMap.get('cfg');
				user = new MyO2BusinessUser((Id)tokenMap.get('uId'));

			}
			catch (Exception e)
			{
				tokenMap = new Map<String, String>();
			}
		}
		else
		{
			tokenMap = new Map<String, String>();
		}
	}

	//--------------------------------------------------------------------------
	// Validate a token
	// Checks organization id, single use, and expiration time
	//--------------------------------------------------------------------------
	public Boolean validate(String configurationType)
	{
		Boolean validToken = false;
		//
		// Check organization Id and token validations
		//
		if (configurationType == getConfiguration()
			&& validateUserAndOrg()
			&& validateExpiration()
			&& validateSingleUse())
		{
			system.debug('validateToken: validToken');
			validToken = true;
		}
		return validToken;
	}

	//--------------------------------------------------------------------------
	// Validate user and organization in token
	//--------------------------------------------------------------------------
	public Boolean validateUserAndOrg()
	{
		Boolean isUserAndOrgValid = true;
		if (user == null
			|| tokenMap.get('oId') != UserInfo.getOrganizationId())
		{
			isUserAndOrgValid = false;
		}
		return isUserAndOrgValid;
	}

	//--------------------------------------------------------------------------
	// Validates token for single use
	// If user is in the state activation pending than it is valid
	//--------------------------------------------------------------------------
	public Boolean validateSingleUse()
	{
		Boolean isSingleUseValid = true;
		if (isSingleUseToken())
		{
			system.debug('validateToken: isSingleUseToken true');
			//
			// If user doesnt exist or user is not in activation pending
			//
			if (user == null || !user.isActivationPending())
			{
				isSingleUseValid = false;
			}
		}
		return isSingleUseValid;
	}

	//--------------------------------------------------------------------------
	// Validates if token expired
	// If token expires validate that it is stil valid
	//--------------------------------------------------------------------------
	public Boolean validateExpiration()
	{
		Boolean isExpirationTimeValid = true;
		if (getTokenExpires())
		{
			system.debug('validateToken: tokenExpires true');
			DateTime tokenDateTime = Datetime.valueOfGmt(tokenMap.get('dt'));
			isExpirationTimeValid =
				tokenDateTime.addHours(getExpirationHours().intValue()) > system.now();
		}
		return isExpirationTimeValid;
	}

	//--------------------------------------------------------------------------
	// Get token configuration
	//--------------------------------------------------------------------------
	private SSOTokenProperties__c getTokenProperties()
	{
		return SSOTokenProperties__c.getInstance(tokenConfiguration);
	}

	//--------------------------------------------------------------------------
	// Is single use token
	//--------------------------------------------------------------------------
	private Boolean isSingleUseToken()
	{
		Boolean isSingleUseToken = true;
		if (getTokenProperties() != null)
		{
			isSingleUseToken = getTokenProperties().single_use_token__c;
		}
		return isSingleUseToken;
	}

	//--------------------------------------------------------------------------
	// Token expires
	//--------------------------------------------------------------------------
	private Boolean getTokenExpires()
	{
		Boolean tokenExpires = true;
		if (getTokenProperties() != null)
		{
			tokenExpires = getTokenProperties().token_expires__c;
		}
		return tokenExpires;
	}

	//--------------------------------------------------------------------------
	// Token expiration hours
	//--------------------------------------------------------------------------
	private Decimal getExpirationHours()
	{
		Decimal expirationHours = 24;
		if (getTokenProperties() != null)
		{
			expirationHours = getTokenProperties().Validity_After_Creation_In_Hours__c;
		}
		return expirationHours;
	}

	//--------------------------------------------------------------------------
	// Static functions
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	// Make token from user id
	//--------------------------------------------------------------------------
	public static String make(String uId, String configuration)
	{
		String plainString = JSON.serialize(createTokenMap(uId, configuration));
		return encryptAES(plainString);
	}

	//--------------------------------------------------------------------------
	// Create token map using user id
	// Returns:
	//   uId - user id
	//   cfg - configuration
	//   oId - organization id
	//   dt  - creation datetime
	//--------------------------------------------------------------------------
	private static Map<String, String> createTokenMap(String uId, String configuration)
	{
		// Create the data map elements for encryption
		Map<String, String> idMap = new Map<String, String>();
		idMap.put('uId', uId);
		idMap.put('cfg', configuration);
		idMap.put('oId', UserInfo.getOrganizationId());
		idMap.put('dt', String.valueOfGmt(system.now()));
		return idMap;
	}

	//--------------------------------------------------------------------------
	// Decrypts encrypted string
	// 1. Base64 decoding
	// 2. AES256 decrption
	//--------------------------------------------------------------------------
	private static String decryptAES(String encryptedString)
	{
		Blob decryptedData = Crypto.decryptWithManagedIV('AES256',
														 getKey(),
														 EncodingUtil.base64Decode(encryptedString));
		return decryptedData.toString();
	}

	//--------------------------------------------------------------------------
	// Encrypts plain string
	// 1. AES256 encryption
	// 2. Base64 encoding
	//--------------------------------------------------------------------------
	private static String encryptAES(String plainString)
	{
		Blob encryptedData =
			Crypto.encryptWithManagedIV('AES256',
										getKey(),
										Blob.valueOf(plainString));
		return EncodingUtil.base64Encode(encryptedData);
	}


	//--------------------------------------------------------------------------
	// Get encoding key
	//--------------------------------------------------------------------------
	private static String getPrKey()
	{
		String key = 'vuCpj7/FaQdFoSiZ8e0T8UaY0tR0xHRkCXu10mrvPXI=';

		SSOEncryptionKeys__c encryptionKey = SSOEncryptionKeys__c.getInstance(TOKEN_KEY);
		if (encryptionKey != null)
		{
			key = encryptionKey.Key__c;
		}
		return key;
	}

	//--------------------------------------------------------------------------
	// Gets encryption key
	//--------------------------------------------------------------------------
	private static Blob getKey()
	{
		return EncodingUtil.base64Decode(getPrKey());
	}

}