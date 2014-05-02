public class MyO2BusinessCrypto {
/*
    private static final String SEP = '_'; 
    private static final String DEFAULT_SUGAR = 'sugar';
    private static final Integer EXPECTED_TOKENS = 5;
    private static final Long MS_PER_HOUR = 1000 * 60 * 60;
    */
    private static final String TOKEN_CONFIGURATION = 'Default'; 
    //private static final String prkey = SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).key__c;
    //private static final boolean isSingleUseToken = SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).single_use_token__c;
    //private static final boolean tokenExpires = SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).token_expires__c;
    //private static final Decimal expirationHours = SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).Validity_After_Creation_In_Hours__c;
    
    private static String prkey { get 
        {
            if (prkey == null) {
                if (!Test.isRunningTest()) {
                    prkey = SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).key__c;              
                } else {
                    prKey = 'vuCpj7/FaQdFoSiZ8e0T8UaY0tR0xHRkCXu10mrvPXI=';
                }
            }
            return prkey;   
        } private set;
    }
    private static boolean isSingleUseToken { get 
        {
            if (isSingleUseToken == null) {
                if (!Test.isRunningTest()) {
                    isSingleUseToken = SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).single_use_token__c;
                } else {
                    isSingleUseToken = true;
                }
            }
            return isSingleUseToken;    
        } private set;
    }                   
    private static boolean tokenExpires { get 
        {
            if (tokenExpires == null) {
                if (!Test.isRunningTest()) {
                    tokenExpires = SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).token_expires__c;
                } else {
                    tokenExpires = false;
                }
            }
            return tokenExpires;    
        } private set;
    }
    private static Decimal expirationHours { get 
        {
            if (expirationHours == null) {
                if (!Test.isRunningTest()) {
                    expirationHours = SSOTokenProperties__c.getInstance(TOKEN_CONFIGURATION).Validity_After_Creation_In_Hours__c;
                } else {
                    expirationHours = 24;
                }
            }
            return expirationHours; 
        } private set;
    }
    // the idea is to create a token that proves that the guy who opens the URL is the one that we sent the email to
    // The token is constructed by:
    //
    // - the orgId
    // - the userId 
    // - the date and time of the construction of the crypto key
    // - a prefix (sugar)
    // - a checksum digit on the time to stop people fiddling with it

    
    private static Blob getKey() {
        return EncodingUtil.base64Decode(prkey);
    }
    
    private static String getIdentifier(String input) {
        return JSON.serialize(getIdentifierMap(input));
    }
    
    private static Map<String, String> getIdentifierMap(String input) {
        // Create the data map elements for encryption
        Map<String, String> idMap = new Map<String, String>();
        idMap.put('uId',input);
        idMap.put('oId',UserInfo.getOrganizationId());
        idMap.put('c',String.valueOf(Crypto.getRandomInteger()).substring(2,6));
        idMap.put('dt',String.valueOfGmt(System.now()));
        return idMap;    
    }
        
    public static string getToken(String input) {
        return encryptAES(getIdentifier(input));
    }

    public static string getSMSCode(String token) {
        Map<String, String> decryptedMap = (Map<String, String>)JSON.deserialize(decryptAES(token), Map<String, String>.class);
        return(decryptedMap.get('c'));
    }
        
    public static boolean validateSMSCode(String token, String smsCode) {
        boolean validCode = false;
        if (token != null) {        
            Map<String, String> decryptedMap = (Map<String, String>)JSON.deserialize(decryptAES(token), Map<String, String>.class);    
            validCode = decryptedMap.get('c')==smsCode;
        }
        return validCode;
    }
    
    // validate a token 
    public static boolean validateToken(String token) {
        boolean validToken = false;
        boolean isSingleUseValid = false;
        boolean isExpirationTimeValid = false;
        if (token != null) {
            system.debug('validateToken: token: '+token);
            Map<String, String> currentMap = new Map<String, String>();
            Map<String, String> decryptedMap = new Map<String, String>();
            // decrypt it
            String decryptedString = decryptAES(token);
            // deserialize it
            decryptedMap = (Map<String, String>)JSON.deserialize(decryptedString, Map<String, String>.class);
            // generate a new map from the Id attribute which was used to generate the original token
            currentMap = getIdentifierMap((String)decryptedMap.get('uId'));
            //
            if(isSingleUseToken) {
                system.debug('validateToken: isSingleUseToken');
                DateTime lastLoginDateTime = [select lastlogindate from user where id=:(String)decryptedMap.get('uId')].lastlogindate;
                isSingleUseValid = lastLoginDateTime == null 
                        || (lastLoginDateTime < dateTime.valueOfGmt(decryptedMap.get('dt')));
            } else {
                system.debug('validateToken: isSingleUseToken false');
                isSingleUseValid = true;
            }
            
            if(tokenExpires) {
                system.debug('validateToken: tokenExpires true');
                isExpirationTimeValid = dateTime.valueOfGmt(decryptedMap.get('dt')).addHours(expirationHours.intValue()) 
                               > dateTime.valueOfGmt(currentMap.get('dt'));
            } else {
                system.debug('validateToken: tokenExpires false');
                isExpirationTimeValid = true;
            }
            // compare the maps
            // verify the timestamp is not too old on the token version
            if(decryptedMap.get('uId') == currentMap.get('uId') &&
                decryptedMap.get('oId') == currentMap.get('oId') &&
                       // verify the timestamp is not too old on the token version 
                       isExpirationTimeValid  &&
                        // verify that that token has not been used before successfully - if the user hasn't logged in or hasn't logged in before the token was issued then it's OK 
                       isSingleUseValid) {
                system.debug('validateToken: validToken');
                validToken = true;
            }           
        }
        
        return validToken;
    }
    
    // Get the Id attribute from a token
    // 1) decrypt, 2) deserialize, 3) read map value
    public static String getId(String token) {
        Map<String, String> decryptedMap = new Map<String, String>();
        String decryptedString = decryptAES(token);
        decryptedMap = (Map<String, String>)JSON.deserialize(decryptedString, Map<String, String>.class);
        system.debug('decryptedMap: '+decryptedMap);
        String uid = decryptedMap.get('uId');
        system.debug('uid: '+uid);
        return uid;
    }
       
    private static string decryptAES(string encryptedString) {
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', getKey(), EncodingUtil.base64Decode(encryptedString));
        return decryptedData.toString();
    }
     
    private static string encryptAES(string plainString) {
        //Blob cryptoKey = Crypto.generateAesKey(256);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', getKey(), Blob.valueOf(plainString));
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    private static testMethod void test_getToken() {
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Roger', 'Roger', 'rr@rr.rr.rr.edu');
        String sourceClear = null;
        String sourceEncrypt = null;
        String targetClear = null;
        
        Test.StartTest();
            sourceClear = u.Id;
            sourceEncrypt = MyO2BusinessCrypto.getToken(u.Id);
            targetClear = MyO2BusinessCrypto.getId(sourceEncrypt);
        Test.StopTest();

        system.assertEquals(targetClear,sourceClear);

    }   
    
    private static testMethod void test_validateToken() {
    User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Roger', 'Roger', 'rr@rr.rr.rr.edu');
        String sourceClear = null;
        String sourceEncrypt = null;
        Boolean bGood;
        Boolean bBad;
        
        Test.StartTest();
            sourceClear = u.Id;
            sourceEncrypt = MyO2BusinessCrypto.getToken(u.Id);
            bGood = MyO2BusinessCrypto.validateToken(sourceEncrypt);
            try {
                bBad = MyO2BusinessCrypto.validateToken('rubbish');
                // if it is True then it's an error (false)
                // if it is False then it's passed (true)
                bBad = !bBad;
            } catch (Exception e) {
                bBad = true;
            }
        Test.StopTest();

        system.assert(bGood);
        system.assert(bBad);
        
    }    

/* TODO - this needs to be fixed
    static testmethod void test_sms() {
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Roger', 'Roger', 'rrr@rr.rr.rr.edu');
        String sourceClear = null;
        String sourceEncrypt = null;
        Boolean bGood;
        Boolean bBad;
        
        Test.StartTest();
            sourceClear = u.Id;
            sourceEncrypt = MyO2BusinessCrypto.getToken(u.Id);
            String smsCode = getSMSCode(sourceEncrypt);
            system.assert(validateSMSCode(sourceEncrypt, smsCode));
        Test.StopTest();

        system.assert(bGood);
        system.assert(bBad);
        
    }
*/
    //
    /*
    String checkDigit;
    String orgId;
    String userId;
    
    DateTime dtm;
    String sugar;

    // Use generateAesKey to generate the private key     
    Blob key;


    public MyO2BusinessCrypto(String userSuppliedSugar) {
        if (userSuppliedSugar.contains(SEP)) 
            sugar = DEFAULT_SUGAR;
        else sugar = userSuppliedSugar;
        
        // generate the key for crypto
        key = Crypto.generateAesKey(128);
    }
    
    // wish there was a modulus operator!
    // this takes a number like 12345678 and adds each digit together. At each add the sum is modulus 10. So...
    // we also add 2 for each digit we encounter to fool smart people who realise this is a checksum
    // 8 + 7 + (1) = 16 -> 6 
    // 6 + 6 + (1) = 13 -> 3 
    // 3 + 5 + (1) = 9
    // 9 + 4 + (1) = 14 -> 4
    // 4 + 3 + (1) = 8
    // 8 + 2 + (1) = 11 -> 1
    // 1 + 1 + (1) = 3
    private Long checkDigit(Long x) {
        Long checkDigit = 0;
        Long part;
        final Long digit = 1;

        while (x > 0) {
          part = x - ((x / 10) *10);
          x -= part;
          checkDigit += (part + digit);
          checkDigit = checkDigit - ((checkDigit / 10) * 10);
          x /= 10;
        }
        system.debug('sum: '+checkDigit);  
        return checkDigit;
    }
    
    private String nowAsString() {
        DateTime dtDtm = system.now();
        Long lDtm = dtDtm.getTime();
        return String.valueOf(lDtm) + String.valueOf(checkDigit(lDtm)); 
    }
    
    private String lengthAsString(String s) {
        Integer length = s.length();
        String lengthBytes = String.valueOf(length);
        system.debug('lengthBytes: '+lengthBytes);
        return lengthBytes;     
    }
    
    // <length>$<rest of string>
    // Therefore expected length is the value of token + seperator + rest of string length
    private void testLength(String token, String s, String errorMsg) {
        Integer expectedLength = Integer.valueOf(token) + 1 + token.length();
        Integer strLength = s.length();
        system.debug('strLength: '+strLength);
        system.debug('expectedLength: '+expectedLength);
        if (strLength != expectedLength)
            throw (new MyO2BusinessTokenException(MyO2BusinessTokenException.Reason.LENGTH, errorMsg));
    }
    
    private void testString(String token, String s, String errorMsg) {
        if (!token.equals(s))
            throw (new MyO2BusinessTokenException(MyO2BusinessTokenException.Reason.INVALID, errorMsg));
    }

    private void testDateTime(String token, DateTime nowDtm, String errorMsg) {
        Long lDtm = Long.valueOf(token);
        system.debug('dtm token was: '+lDtm);

        // check digit is last digit of token
        Long lCheckDigit = lDtm - ((lDtm / 10) * 10);
        // remove check digit to leave real date and time
        lDtm = (lDtm - lCheckDigit) / 10;
        
        system.debug('check digit: '+lCheckDigit);
        system.debug('dtm really: '+lDtm);
        // check that the date and time was not tampered with
        if (lCheckDigit != checkDigit(lDtm)) {
            throw (new MyO2BusinessTokenException(MyO2BusinessTokenException.Reason.CRC, errorMsg));
        }
        
        DateTime tokenDtm = DateTime.newInstance(lDtm);
        system.debug('testDateTime: token: '+tokenDtm.format());
        system.debug('testDateTime: now: '+nowDtm.format());
        
        // get the setting
        List<SSOTokenProperties__c> validity = [SELECT s.Validity_After_Creation_In_Hours__c FROM SSOTokenProperties__c s WHERE s.Name='Default'];
        system.debug('validity: '+validity);
        if (validity.size() == 1) {
            Integer incr = Integer.valueOf(validity[0].Validity_After_Creation_In_Hours__c);
            system.debug('incr: '+incr);
            lDtm += (MS_PER_HOUR * incr);
            tokenDtm = DateTime.newInstance(lDtm);
            system.debug('testDateTime: token plus validity: '+tokenDtm.format());
        }
        else (new MyO2BusinessTokenException(MyO2BusinessTokenException.Reason.CONFIG, 'Missing Default Properties'));
        
        lDtm = tokenDtm.getTime();
        Long lNow = nowDtm.getTime();
        
        system.debug('lDtm: '+lDtm);
        system.debug('lNow: '+lNow);
        if (lDtm < lNow)
            throw (new MyO2BusinessTokenException(MyO2BusinessTokenException.Reason.EXPIRED, errorMsg));          
        system.debug('testDateTime: exit');
    }

    private String[] getTokens(String s) {
        String[] tokens = s.split(SEP, 0);      
        system.debug('getTokens: '+tokens);
        if (tokens.size() != EXPECTED_TOKENS)
            throw (new MyO2BusinessTokenException(MyO2BusinessTokenException.Reason.LENGTH, 'Invalid part count'));
        return tokens;
    }
    
    public String scramble(String unencoded) {
        // TODO temp code
        //String encoded = unencoded;
        
        system.debug('scramble: in: '+unencoded);

        // unencoded is 'fred'

       // Generate the data to be encrypted as a BLOB     
        Blob data = Blob.valueof(unencoded);
        system.debug('scramble: data: '+data);

        // Encrypt and decrypt the data     
        system.debug('scramble: key: '+key);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);

        // convert to base64 so we can use it
        system.debug('scramble: encryptedData: '+encryptedData);
        String encoded = EncodingUtil.base64Encode(encryptedData);
        
        system.debug('scramble: out: '+encoded);
        return encoded;
    }

    public String unscramble(String encoded) {
        // TODO temp code
        //String unencoded = encoded;

        system.debug('unscramble: in: '+encoded);

        // Convert it to a BLOB so we can decrypt it
        Blob encryptedData = EncodingUtil.base64Decode(encoded);

        system.debug('unscramble: encryptedData: '+encryptedData);
        system.debug('unscramble: key: '+key);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', key, encryptedData);
        String unencoded = decryptedData.toString();       
        system.debug('unscramble: out: '+unencoded);

        return unencoded;
    }

    public String encrypt(String currentOrgId, String currentUserId) {
        // build the token by adding all the parts

        String unencryptedToken = sugar + SEP + currentOrgId + SEP + currentUserId + SEP + nowAsString();

        // add the length
        String lengthBytes = lengthAsString(unencryptedToken);
        unencryptedToken =  lengthBytes + SEP + unencryptedToken;
        
        system.debug('encryptedToken: '+unencryptedToken);
        
        // TODO: scramble the token 
        return(scramble(unencryptedToken));
        //return(unencryptedToken);
    }
    
    // This method indirectly throws MyO2BusinessTokenException
    public Boolean decrypt(String currentOrgId, String currentUserId, String encryptedToken) {
        Boolean matches = false;
        
        try {
            // TODO:decrypt token
            String unencryptedToken = unscramble(encryptedToken); 
            //String unencryptedToken = encryptedToken; 
                            
            // tokenize
            String[] tokens = getTokens(unencryptedToken);
            
            testLength(tokens[0], unencryptedToken, 'Invalid Part 0');
            testString(tokens[1], sugar, 'Invalid Part 1');
            testString(tokens[2], currentOrgId, 'Invalid Part 2');
            testString(tokens[3], currentUserId, 'Invalid Part 3');
            testDateTime(tokens[4], system.now(), 'Invalid Part 4');
            
            matches = true;
            
        } catch (MyO2BusinessTokenException ssote) {
            throw ssote;
        } catch (Exception e) {
            throw (new MyO2BusinessTokenException(MyO2BusinessTokenException.Reason.INVALID, e.getMessage()));
        }

        return matches;
    }
    
    static testMethod void test_crypto() {
        MyO2BusinessCrypto c = new MyO2BusinessCrypto('test');
        
        String currentOrgId     = '00DW00000004Zol';
        String currentUserId    = '005W0000000HiFAIA0';
        
        String badOrgId = 'badorgid';
        String badUserId = 'badUserId';
        
        String encrypted = c.encrypt(currentOrgId, currentUserId);
        String decrypted = null;
        
        // this one should return true and NOT an exception
        try {
            system.assert(c.decrypt(currentOrgId, currentUserId, encrypted));           
        } catch (MyO2BusinessTokenException te) {
            system.assertEquals('No exception', te.getMessage());
        } catch (Exception e) {
            system.assertEquals('No exception', e.getMessage());            
        }
 
        // this should return an exception because of bad org id
        try {
            system.assert(!c.decrypt(badOrgId, currentUserId, encrypted));          
        } catch (MyO2BusinessTokenException te) {
            system.assertEquals(MyO2BusinessTokenException.Reason.INVALID, te.getReason());
            system.assertEquals('Invalid Part 2', te.getMessage());
        } catch (Exception e) {
            system.assert(true);            
        }
        
        // this should return an exception because of bad user id
        try {
            system.assert(!c.decrypt(currentOrgId, badUserId, encrypted));          
        } catch (MyO2BusinessTokenException te) {
            system.assertEquals(MyO2BusinessTokenException.Reason.INVALID, te.getReason());
            system.assertEquals('Invalid Part 3', te.getMessage());
        } catch (Exception e) {
            system.assert(true);            
        }
        
        // now try to set the expiry date to 0
        List<SSOTokenProperties__c> validity = [SELECT s.Validity_After_Creation_In_Hours__c FROM SSOTokenProperties__c s WHERE s.Name='Default'];
        system.assert(validity.size() == 1);
        
        validity[0].Validity_After_Creation_In_Hours__c = 0;
        update validity;
        
        // this one should return true but it the token has expired and should throw an exception
        try {
            system.assert(c.decrypt(currentOrgId, currentUserId, encrypted));           
        } catch (SSOTokenException te) {
            system.assertEquals(SSOTokenException.Reason.EXPIRED, te.getReason());
            system.assertEquals('Invalid Part 4', te.getMessage());
        } catch (Exception e) {
            system.assertEquals('No exception', e.getMessage());            
        }
 
        // 1 + 3 + 2 = 6
        // 5 + 2 + 1 = 8
        // 8 + 4 + 1 = 13 -> 3
        // 3 + 4 + 1 = 8
        // 8 + 7 + 1 = 16 -> 6
        // 6 + 3 + 1 = 10 -> 0
        // 0 + 6 + 1 = 7
        // 7 + 9 + 1 = 17 -> 7
        // 7 + 2 + 1 = 10 -> 0
        // 0 + 4 + 1 = 5
        // 5 + 1 + 1 = 7
        // 7 + 9 + 1 = 17 -> 7
        Long l = Long.valueof('1324473692419');
        system.assertEquals(8, c.checkDigit(l));
        
        // test crypto
        String s1 = 'abcdefghijklmnopqrstuvwxyz';
        String s2 = c.scramble(s1);
        String s3 = c.unscramble(s2);
        system.assertEquals(s1,s3);
        
    }
    */
}