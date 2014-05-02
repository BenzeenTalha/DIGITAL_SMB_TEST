public with sharing class O2OnlineProductCatalogueHelper {

	public O2OnlineProductCatalogueHelper() {}
	
	public static String endpoint = 'http://176.34.205.3:8080/productCatalogue/products/handsets';
	public static String getProductCatalogueHeaders() {
		Http h = new Http();
		
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('GET');
		
		HttpResponse response = new HttpResponse();
		if (!Test.isRunningTest()) {
		    response = h.send(request);
            return response.getBody();
		}
		else return '<html/>';
	}
}