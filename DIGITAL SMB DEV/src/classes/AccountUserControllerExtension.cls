public without sharing class AccountUserControllerExtension{

    private final Opportunity opp;

    private final User owner;

    // The extension constructor initializes the private member
    // variable opp by using the getRecord method from the standard
    // controller.
    public AccountUserControllerExtension(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        this.owner = [SELECT Name, Title, Email, phone, ManagerId, Manager.Name, Manager.LastName, Sales_Channel__c  from User where id =: opp.OwnerId];
    }

    public string ownerName { get {return this.owner.Name;}}
    public string ownerTitle { get {return this.owner.Title;}}
    public string ownerEmail { get {return this.owner.Email;}}
    public string ownerPhone { get {return this.owner.phone;}}
    public string ownerManager { get {return this.owner.Manager.Name + this.owner.Manager.LastName;}}
    public string ownerSalesChannel { get {return this.owner.Sales_Channel__c;}}
}