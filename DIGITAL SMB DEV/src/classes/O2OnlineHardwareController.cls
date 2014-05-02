/* changes
 * AJ:2012-02-28:updated the handset descripiton and URL to hardware
 */

public class O2OnlineHardwareController {

    public String productCode {get;set;}
    public String detailType {get;set;}
    public String channel {get {if (channel==null) return 'Online'; else return channel;}set;}

    public class ProductDetail {
        public String bodyContent {get;set;}
        public O2_Dise_Map_Handset_Selection__c item {get;set;}
        public ProductDetail() {}
        public ProductDetail(String html, O2_Dise_Map_Handset_Selection__c p) {
            this.bodyContent = html;
            this.item = p;
        }
    }

    /*
    @remoteAction
    public static ProductDetail getProduct(String sType, String sCode) {
        O2_Dise_Ref_Hardware_Portfolio__c[] retProd = new O2_Dise_Ref_Hardware_Portfolio__c[0];
        String strQuery = 'SELECT Id, Parent.Id, Parent.Product_code__c, Parent.Name, Parent.Hardware_Description__c, Body ' +
                            ' FROM Attachment ' +
                            ' WHERE Name LIKE \'%'+sType+'%\' AND Product_Code__c = \''+sCode+'\'' +
                            ' ORDER BY LastModifiedDate desc LIMIT 1)' +
	}
    */
    public String getLiveTrackingEnabled() {
                if (OnlineGeneralSettings__c.getInstance('Enable Live Tracking')!=null)
                        return OnlineGeneralSettings__c.getInstance('Enable Live Tracking').Value__c;
                else return '';
        }

    public ProductDetail getProductDetail() {
        ProductDetail retProd = new ProductDetail();
        List<O2_Dise_Map_Handset_Selection__c> device = new List<O2_Dise_Map_Handset_Selection__c>();
        List<Attachment> deviceAtt = new List<Attachment>();
        String strBody = '';
        //perform queries
        device = [SELECT
        			Id, Price_Condition__c, Handset_Image_URL__c, Stock_Status__c, Handset_Model__c, Handset_Description__c,
        			Product_Code__r.Product_Code__c, Product_Code__r.Hardware_Image_URL__c, Product_Code__r.Hardware_Description__c,
        			Product_Code__r.Available_for_PreOrder__c, Product_Code__r.Name
                  FROM
                  	O2_Dise_Map_Handset_Selection__c
                  WHERE
                  	Product_Code__r.Product_Code__c = :productCode AND
                  	Channel__c = :channel
                  ORDER BY LastModifiedDate DESC
                  LIMIT 1];
        if (device!=null && device.size()>0) {
            retProd.item = device[0];
            //String strLike = '%'+detailType+'%';
            String strLike = '%device-%';
            deviceAtt = [SELECT Body FROM Attachment WHERE Name LIKE :strLike AND ParentId = :device[0].Product_Code__c ORDER BY LastModifiedDate desc LIMIT 1];
        }
        if (deviceAtt!=null && deviceAtt.size()>0) {
            retProd.bodyContent = deviceAtt[0].Body.toString();
        }
        return retProd;
    }

}