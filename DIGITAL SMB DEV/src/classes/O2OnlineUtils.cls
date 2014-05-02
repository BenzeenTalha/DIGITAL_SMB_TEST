public with sharing class O2OnlineUtils {
    public static String getStringFromBlob(Blob b) {
        return b.toString();
    }

    static testmethod void testAll() {
        Blob b = Blob.valueOf('UnitTest');
        O2OnlineUtils.getStringFromBlob(b);
    }
}