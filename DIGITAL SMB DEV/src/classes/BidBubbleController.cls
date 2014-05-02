public with sharing class BidBubbleController {
    
    public String username {get; set;}
    public String password {get; set;}
    
    // Login Action
    public PageReference login() {
        return new PageReference(Site.login(username, password, '/apex/BidBubbleSearch').getUrl().replace('http:','https:'));
    }    
    
    
   
}