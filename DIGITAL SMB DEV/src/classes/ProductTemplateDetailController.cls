public with sharing class ProductTemplateDetailController {
	private Product_Template__c prodTemplate;
	public String productTemplateId {get; set;} 
    //
	// Controller
    public ProductTemplateDetailController(ApexPages.StandardController stdController) {
        this.prodTemplate = (Product_Template__c)stdController.getRecord();
        productTemplateId = this.prodTemplate.Id;
    }
    
    // Add an asset template line
    public PageReference createAsset() {
    	// ---------------------------------------------------------------
		//
        // Go to the create Asset template Line
        PageReference assetCreatePage = new PageReference('/apex/CreateAssetTemplateLine');
        assetCreatePage.getParameters().put('productId',prodTemplate.Id);
        assetCreatePage.setRedirect(true);
    	return assetCreatePage;
    }
}