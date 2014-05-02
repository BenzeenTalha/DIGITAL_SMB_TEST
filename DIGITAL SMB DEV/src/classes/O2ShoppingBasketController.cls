public with sharing class O2ShoppingBasketController {

    public O2OnlineOrderController sessionController {get; set;}
    
    public O2ShoppingBasketController(Object o) {
        
    }
    
    public String getBasketSizeDescription() {
        //cscfgc__Product_Basket__c basket = sessionController.getSession().getSessionBasket();
        cscfgc__Product_Basket__c basket = cscfgc.SessionManager.getSessionInfo().getSessionBasket();
        if (basket.cscfgc__product_configurations__r.size() == 0) return 'Empty';
        if (basket.cscfgc__product_configurations__r.size() == 1) return '1 item';
        return basket.cscfgc__product_configurations__r.size() + ' items';
    }
}