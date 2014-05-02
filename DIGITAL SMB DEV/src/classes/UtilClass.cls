public class UtilClass{
    public static Boolean isSet {get;set;}

    public static void testDummyData(String t){
        isSet = false;
        if (t == 'TEST')
            isSet = true;
    }
}