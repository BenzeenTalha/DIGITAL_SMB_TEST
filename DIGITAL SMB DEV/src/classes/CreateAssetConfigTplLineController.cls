public with sharing class CreateAssetConfigTplLineController {
    private Asset_Config_Template_Line__c assetConfigTemplateLine;
    //
    // Constructor
    public CreateAssetConfigTplLineController(ApexPages.StandardController stdController) {
        // Get the passed in record
        this.assetConfigTemplateLine = (Asset_Config_Template_Line__c)stdController.getRecord();
        // If a new config line is required set some defaul values
        if (assetConfigTemplateLine.Id == null) {
	        String assetId = ApexPages.currentPage().getParameters().get('AssetId');
	        Asset_Template_Line__c assetTpl = [select id, type__c, product_template__c from Asset_Template_Line__c where id = :assetId];
	        assetConfigTemplateLine.Product_Template__c = assetTpl.product_template__c;
	        assetConfigTemplateLine.Asset_Type__c = assetTpl.Type__c;
        }
    }
    // Add an asset config template line
    public PageReference save() {
        // set the name of the configuration line to be the same as the configuration type 
        assetConfigTemplateLine.Name = assetConfigTemplateLine.Type__c;
        // upsert the config line
        upsert assetConfigTemplateLine;
        // ---------------------------------------------------------------
        //
        // Go to the owning product template page
        PageReference productTemplatePage = new PageReference('/'+assetConfigTemplateLine.Product_Template__c);
        productTemplatePage.setRedirect(true);
        return productTemplatePage;
    }
}