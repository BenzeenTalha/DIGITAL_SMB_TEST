public class PostcodeUtils {

    // Will return the first half of the postcode when given a full postcode e.g. L23 4AY will return L23
    public static String GetFirstHalfOfPostcode(String fullPostcode){
        // return value - remove any blanks at start and end
        String postcodeFirstHalf = fullPostcode.trim().toUpperCase();
        
        // If postcode ends with number-letter-letter then we can just remove the last 3 chars and trim it again
        if (Pattern.matches('..+[0-9][A-Z][A-Z]$', postcodeFirstHalf)) {
            Integer lenToExtract = postcodeFirstHalf.length()-3;
            postcodeFirstHalf = postcodeFirstHalf.substring(0, lenToExtract).trim();
        }
        
        return postcodeFirstHalf;
    }

    // Will return the first one or two letters of the postcode e.g. EC1Y 4AY will return EC
    public static String GetAreaOfPostcode(String fullPostcode){
        // return value - remove any blanks at start and end
        String postcodeArea = fullPostcode.trim().toUpperCase();
        
        // If postcode starts with letter-number then we can just keep the first char
        if (Pattern.matches('^[A-Z][0-9].*', postcodeArea)) {
            postcodeArea = postcodeArea.substring(0, 1);
        } else
        // If postcode starts with letter-letter-number then we can just keep the first two chars
        if (Pattern.matches('^[A-Z][A-Z][0-9].*', postcodeArea)) {
            postcodeArea = postcodeArea.substring(0, 2);
        }
        
        return postcodeArea;
    }

    // Will return all the postcode table rows matching the input string array
    public static Map<String, Postcode_Alignment__c> GetPostcodeParams(String[] postcodeFirstHalfValues){
        
        // SOQL to query postcode table object
        Map<String, Postcode_Alignment__c> PostcodeRowsMap = new Map<String, Postcode_Alignment__c>();
        for (Postcode_Alignment__c pA : [SELECT Town_City__c, Short_Code__c, Region__c, RTP__c, Postcode__c, Name, Franchise__c, FAM__c, DMU__c, DBAM__c, Corp__c, COE_Non_Aligned__c, COE_Aligned__c, Acquisition__c, AM__c 
               FROM Postcode_Alignment__c
              WHERE Name IN :postcodeFirstHalfValues]) {
            PostcodeRowsMap.put(pA.Name, pA);
            System.Debug('##### PostcodeUtils ##### Loading Code: '+pA.Name);
        }
        
        return PostcodeRowsMap;
    }


//**********************************************************************************************
//*
//*     TEST METHODS
//*
//**********************************************************************************************
    public static testMethod void Test01() {
        
        String postCode = 'BT1 1AA';
        System.assertEquals('BT1', PostcodeUtils.GetFirstHalfOfPostcode(postCode) );
        
        postCode = 'bt1 1aa';
        System.assertEquals('BT1', PostcodeUtils.GetFirstHalfOfPostcode(postCode) );
        
        postCode = 'bt11aa';
        System.assertEquals('BT1', PostcodeUtils.GetFirstHalfOfPostcode(postCode) );
        
        postCode = 'bt11';
        System.assertEquals('BT11', PostcodeUtils.GetFirstHalfOfPostcode(postCode) );
        
        postCode = ' bt111aa ';
        System.assertEquals('BT11', PostcodeUtils.GetFirstHalfOfPostcode(postCode) );
        
        postCode = 'ec1m 2xy';
        System.assertEquals('EC1M', PostcodeUtils.GetFirstHalfOfPostcode(postCode) );
        
        postCode = 'ec1m2xy';
        System.assertEquals('EC1M', PostcodeUtils.GetFirstHalfOfPostcode(postCode) );
        
        postCode = 'ec1m';
        System.assertEquals('EC1M', PostcodeUtils.GetFirstHalfOfPostcode(postCode) );
    }

    public static testMethod void Test02() {
        
        String postCode = 'BT1 1AA';
        System.assertEquals('BT', PostcodeUtils.GetAreaOfPostcode(postCode) );
        
        postCode = 'bt1 1aa';
        System.assertEquals('BT', PostcodeUtils.GetAreaOfPostcode(postCode) );
        
        postCode = 'bt11aa';
        System.assertEquals('BT', PostcodeUtils.GetAreaOfPostcode(postCode) );
        
        postCode = 'bt11';
        System.assertEquals('BT', PostcodeUtils.GetAreaOfPostcode(postCode) );
        
        postCode = ' bt111aa ';
        System.assertEquals('BT', PostcodeUtils.GetAreaOfPostcode(postCode) );
        
        postCode = 'ec1m 2xy';
        System.assertEquals('EC', PostcodeUtils.GetAreaOfPostcode(postCode) );
        
        postCode = 'ec1m2xy';
        System.assertEquals('EC', PostcodeUtils.GetAreaOfPostcode(postCode) );
        
        postCode = 'ec1m';
        System.assertEquals('EC', PostcodeUtils.GetAreaOfPostcode(postCode) );
        
        postCode = 'l1';
        System.assertEquals('L', PostcodeUtils.GetAreaOfPostcode(postCode) );
    }

    public static testMethod void Test03() {
        
        String[] postCodes = new String[]{'BT1','EC1M','AB11','L1','M11'};
        Map<String, Postcode_Alignment__c> postcodeMap = PostcodeUtils.GetPostcodeParams(postCodes);
        System.assertEquals(5, postcodeMap.size() );
    }

}