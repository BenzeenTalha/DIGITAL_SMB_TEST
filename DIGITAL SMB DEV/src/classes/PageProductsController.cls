public with sharing class PageProductsController {

    public String siteNameValue {get; set;}
    public String siteName {get; set;}
    public String productName {get; set;}
    public String styleClassValue {get;set;}
    public String buttonLabelValue {get; set;}
    public Boolean silentValue {get; set;}
    public String showIndexesValue {get;set;}

    public List<PageProductWrapper> products {
    	get {if (products==null || products.size()==0) return queryProducts(); else return products;}
    	set;
    }
    public List<PageProductWrapper> queryProducts() {
        List<Site_Page__c> sitePage = [select id from Site_Page__c where name=:siteNameValue LIMIT 1];
        if (siteName == 'Landline Extras') {
        	sitePage = [select id from Site_Page__c where name=:siteName LIMIT 1];
        }
        if (sitePage == null || sitePage.size()==0) {
        	
         	return new PageProductWrapper[]{};
        }
        String strQuery = 'select id, Name, product_definition__c, product_definition__r.Name, offer__c, Offer__r.O2_DISE_Map_Mobile_Data__r.Is_4G__c, Offer__r.O2_DISE_Map_Mobile__r.Is_4G__c, Target_Page__c, screen_flow__c, screen_flow__r.name, html__c, product_category_name__c, type__c, sequence__c, Scrollable__c from Page_Product__c '
        				+ 'where site_page__c = \''+sitePage[0].id+'\' and Active__c=true ';
        System.debug('### OUTPUT >>>>> queryProducts: showIndexesValue: '+showIndexesValue);
        if (showIndexesValue!=null && showIndexesValue!='') {
        	showIndexesValue=showIndexesValue.trim();
        	Set<Integer> indexes = new Set<Integer>();
        	if (showIndexesValue.contains(',')) {for (String s: showIndexesValue.split(',')) {indexes.add(Integer.valueOf(s));}}
        	else indexes.add(Integer.valueOf(showIndexesValue));
        	if (indexes!=null && indexes.size()>0) strQuery+='and Sequence__c IN :indexes ';
        }
        strQuery+= 'order by sequence__c';
        system.debug('page products controller query products, query = ' + strQuery);
        Page_Product__c[] ps = Database.query(strQuery);
        PageProductWrapper[] result = new PageProductWrapper[]{};
        for (Page_Product__c p : ps) {
        	result.add(new PageProductWrapper(p));
        }
        if (result.size() > 0)
        	result[result.size() - 1].Split = true;

        products=result;
        return result;
    }

    public Page_Product__c getProduct() {
        Site_Page__c sitePage = [select id from Site_Page__c where name=:siteNameValue];
        if (sitePage == null) return null;

        return [select id, Name, product_definition__c, product_definition__r.Name, offer__c, Target_Page__c, screen_flow__c, screen_flow__r.name, html__c, product_category_name__c, sequence__c, Scrollable__c from Page_Product__c where site_page__c=:sitePage.id and name=:productName];
    }

    public Boolean getHasScrollableContent() {
    	Boolean retValue = false;
    	if (products!=null) {
    		for (PageProductWrapper p: products) {if (p.PageProduct.Scrollable__c) retValue=true;}
    	}
    	return retValue;
    }


    public class PageProductWrapper
    {
    	public Page_Product__c PageProduct { get; set; }
    	public boolean Split { get; set; }

    	public PageProductWrapper(Page_Product__c p)
    	{
    		this.PageProduct = p;
    		this.Split = false;
    	}
    	public PageProductWrapper(Page_Product__c p, boolean split)
    	{
    		this.PageProduct = p;
    		this.Split = split;
    	}
    }

}