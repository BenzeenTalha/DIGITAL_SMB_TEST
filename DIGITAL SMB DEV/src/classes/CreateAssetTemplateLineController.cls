public with sharing class CreateAssetTemplateLineController {
	private Asset_Template_Line__c assetTemplateLine;
    //
	// Controller
    public CreateAssetTemplateLineController(ApexPages.StandardController stdController) {
        this.assetTemplateLine = (Asset_Template_Line__c)stdController.getRecord();
        assetTemplateLine.Product_Template__c = ApexPages.currentPage().getParameters().get('productId');
    }
    
    // Add an asset template line
    public PageReference save() {
    	assetTemplateLine.Name = assetTemplateLine.Type__c;
    	insert assetTemplateLine;
    	// ---------------------------------------------------------------
		//
        // Go to the owning product template page
        PageReference productTemplatePage = new PageReference('/'+assetTemplateLine.Product_Template__c);
        productTemplatePage.setRedirect(true);
    	return productTemplatePage;
    }
    
    // Cancel the action
    public PageReference cancel() {
    	// ---------------------------------------------------------------
		//
        // Go to the owning product template page
        PageReference productTemplatePage = new PageReference('/'+assetTemplateLine.Product_Template__c);
        productTemplatePage.setRedirect(true);
    	return productTemplatePage;
    }
}