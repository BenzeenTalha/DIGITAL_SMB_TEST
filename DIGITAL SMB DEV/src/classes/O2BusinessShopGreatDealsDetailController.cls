public with sharing class O2BusinessShopGreatDealsDetailController {


    public O2BusinessShopGreatDealsDetailController(O2OnlineMainController controller){

    }

    private string sitePageName{
        get { return ApexPages.currentPage().getParameters().get('d'); }
    }



    public DealDetail getDealDetail() {
        DealDetail deal = new DealDetail();
        Attachment dealAtt = new Attachment();
        String strBody = '';
        try {
            //Get site page
            Site_Page__c sitePage = [SELECT Id FROM Site_Page__c WHERE Name = :sitePageName LIMIT 1];

            //Get attachment
            if(sitePage != null){
                dealAtt = [SELECT Body FROM Attachment WHERE ParentId = :sitePage.Id ORDER BY LastModifiedDate desc LIMIT 1];
            }

            //Return
            if (dealAtt != null) {
                deal.bodyContent = dealAtt.Body.toString();
            }
        } catch (Exception ex) {
            system.debug('********** Error reading Deal JSON attachment. Cause: ' + ex.getCause() + ' Line: ' + ex.getLineNumber() + ' Message: ' + ex.getMessage());
        }
        return deal;
    }

    public class DealDetail {
        public String bodyContent {get;set;}
        public DealDetail() {}
        public DealDetail(String html) {
            this.bodyContent = html;
        }
    }

}