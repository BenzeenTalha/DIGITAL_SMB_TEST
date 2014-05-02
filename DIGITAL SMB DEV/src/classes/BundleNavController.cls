/*
    ClassName:      BundleNavController
    Description:    Controller for conditional redirection of users to pages
    
    Change History
    
    Version  Date       Init    Description of Change
    ------- ------      ------  --------------------------------------------
    1.0     08-12-11    RAC     Initial Version

*/
public with sharing class BundleNavController {

    private final ApexPages.StandardController theController;

    public BundleNavController(ApexPages.StandardController stdController) {
        theController = stdController;
    }

    // Determine the page to be invoked
    private PageReference getNextPage() {
    
        PageReference currPage = ApexPages.currentPage();
        PageReference nextPage;
        
        PageNavigationOverride__c overrides = PageNavigationOverride__c.getInstance();
        
        if (currPage != null && overrides != null) {

            String requestUrl = currPage.getUrl();
            if (requestUrl.toLowerCase().contains('productbundleoverrideview')) {
                nextPage = new PageReference('/apex/' + overrides.Product_Bundle_View__c);               
            }
            else if (requestUrl.toLowerCase().contains('productbundleoverrideedit')) {
                if(ApexPages.currentPage().getParameters().get('id') != null){
                    cscfgc__Product_Bundle__c pb = [select Id,Name,cscfgc__Opportunity__r.RecordType.Name from cscfgc__Product_Bundle__c where Id = :ApexPages.currentPage().getParameters().get('id')];
                    if(pb.cscfgc__Opportunity__r.RecordType.Name == 'Unify'){
                       nextPage = new PageReference('/apex/UnifyProductBundleBuilderAsync');   
                    } else {
                        nextPage = new PageReference('/apex/' + overrides.Product_Bundle_Edit__c);  
                    }
                } else {
                    nextPage = new PageReference('/apex/' + overrides.Product_Bundle_Edit__c);
                }               
            }
            else if (requestUrl.toLowerCase().contains('productbundleoverridenew')) {
                nextPage = new PageReference('/apex/' + overrides.Product_Bundle_New__c);               
            }
            else nextPage = new PageReference('/006');    // Use Opportunity Tab when invalid Override used
        }            
        
        return nextPage;
    }


    public PageReference autoRun() {

        PageReference nextPage;
        PageNavigationOverride__c overrides = PageNavigationOverride__c.getInstance();
        // Determine the next page to display and then show the new page
        try {
           
            nextPage = getNextPage();
            // Copy over all the original request parameters to the destination page
            nextPage.getParameters().putAll(ApexPages.currentPage().getParameters());
            nextPage.setRedirect(false); 
    
        }
        catch (Exception e) {
            System.debug('ERROR: Exception while performing Product Bundle Page Override: ' + e.getMessage());
        }

        return nextPage;
    }

    
    // Unit Test
    static testMethod void testController() {

        TestDataForO2OrderHelper.createRecordTypeForAccount();
        TestDataForO2OrderHelper.createRecordTypeForOpportunity();
        Account acc = TestDataForO2OrderHelper.createAccount();
        Opportunity opp = TestDataForO2OrderHelper.createOpportunity();

        // Create New Bundle
        cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();
        bundle.name = 'Unit test BundleNavContoller';
        bundle.cscfgc__Opportunity__c = opp.Id;
        insert bundle;
        
        PageNavigationOverride__c overrides = PageNavigationOverride__c.getInstance();

        Test.startTest();
        
        // Test the New Page
        PageReference testPage = Page.ProductBundleOverrideNew;
        Test.setCurrentPage(testPage);

        ApexPages.StandardController sc = new ApexPages.StandardController(bundle);
        BundleNavController controller = new BundleNavController(sc);
        PageReference retPage = controller.autoRun();
        String rtnUrl = retPage.getUrl();
        if (overrides != null) System.assertEquals('/apex/'+overrides.Product_Bundle_New__c, rtnUrl);
        
        // Test the View Page
        testPage = Page.ProductBundleOverrideView;
        Test.setCurrentPageReference(testPage);
        controller = new BundleNavController(sc);
        rtnUrl = controller.autoRun().getUrl();
        if (overrides != null) System.assertEquals('/apex/'+overrides.Product_Bundle_View__c, rtnUrl);
               
        // Test the Edit Page
        testPage = Page.ProductBundleOverrideEdit;
        Test.setCurrentPage(testPage);
        controller = new BundleNavController(sc);
        rtnUrl = controller.autoRun().getUrl();
        if (overrides != null) System.assertEquals('/apex/'+overrides.Product_Bundle_Edit__c, rtnUrl);
        
        Test.stopTest();
    } 

}