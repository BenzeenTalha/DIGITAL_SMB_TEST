public with sharing class DigitalProductSelectorController
{
    // Initialise
    public List <Device_Digital_Product_Map__c> products {get;set;}
    public String device {get;set;}
    
    // Constructor
    public DigitalProductSelectorController()
    {
        // Initialise
        device = ApexPages.currentPage().getParameters().get('device');
        products = [select id, name, long_id__c, list_price__c, device_name__c, content__c, description__c from device_digital_product_map__c where device_name__c = :device order by name asc];
    }
}