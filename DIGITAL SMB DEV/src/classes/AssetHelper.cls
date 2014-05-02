public with sharing class AssetHelper {
    // Get a List of Configuration options related to the specified Asset IDs
    public static List<Asset_Configuration__c> getAssetConfigurationList(Set <String> assetSet) {
        String queryString = null;
        queryString = 'select '+Utility.getSobjectFields('Asset_Configuration__c')+
            ' from Asset_Configuration__c where order_Asset__c in '+Utility.convertSetToString(assetSet);
        List <Asset_Configuration__c> configList = Database.query(queryString);
        return configList;
    }
    //
    // Get a Map of Configuration options related to the specified Asset IDs
    public static Map<ID,Asset_Configuration__c> getAssetConfigurationMap(List <Order_Asset__c> assetList) {
        String queryString = null;
        queryString = 'select Id ,(select '+Utility.getSobjectFields('Asset_Configuration__c')+
            ' from Asset_Configurations__r) from order_asset__c where Id in '+Utility.convertListToString(assetList);
        List <Order_Asset__c> assetDetailList = Database.query(queryString);
        Map<ID,Asset_Configuration__c> assetConfigMap = new Map<ID,Asset_Configuration__c>();
        for (Order_Asset__c svcAsset : assetDetailList) {
        	assetConfigMap.put(svcAsset.Id,svcAsset.Asset_Configurations__r);
        }
        return assetConfigMap;
    }
}