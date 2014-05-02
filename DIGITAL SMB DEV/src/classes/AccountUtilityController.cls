public with sharing class AccountUtilityController {

        public ApexPages.StandardController accntController;
        public Account accnt;
        public String strAccId;
        public AccountUtilityController (ApexPages.StandardController controller) {
                this.accntcontroller = controller;
                this.accnt = (Account)controller.getRecord();
                this.strAccId = accnt.Id;
        }
        
        public class DiscountedProductLineItem {
                
                public BE_Discount_Item__c discountlineitem;
                public Decimal listprice;
                public Decimal discprice;
                public String product;
                
                public DiscountedProductLineItem(String p, BE_Discount_Item__c d, Decimal lp, Decimal dp) {
                        this.product = p;
                        this.discountlineitem = d;
                        this.listprice = lp;
                        this.discprice = dp;
                }
                
                public String getproduct() {return product;}
                public BE_Discount_Item__c getdiscountlineitem() {return discountlineitem;}
                public Decimal getlistprice() {return listprice;}
                public Decimal getdiscprice() {return discprice;}
                
        }
        
        public Account getAccount() {return accnt;}
        
        public DiscountedProductLineItem[] getProductPrices() {
        	
                DiscountedProductLineItem[] output = new DiscountedProductLineItem[0];
                List<BE_Discount_Item__c> discounts = new List<BE_Discount_Item__c>();
                
                discounts = [SELECT b.Id, b.Name, b.Discount_Amount__c, b.BE_Discount__r.Account__c, b.Quantity_Min__c, b.Quantity_Max__c, b.Product__c, 
                					b.BE_Discount__c From BE_Discount_Item__c b WHERE b.BE_Discount__r.Account__c=:strAccId and b.BE_Discount__r.Active__c = true ORDER BY b.Product__c];
                
                List<PricebookEntry> products = new List<PricebookEntry>();
                products = [SELECT Product2.Name, Pricebook2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2.Name='BE Price Book' ORDER BY Product2.Name];
              
                
                for (PricebookEntry prod: products) {
                	
                        Decimal price = prod.UnitPrice;
                        Decimal discprice = price;
                      	String prd = '';
                        
                        List<BE_Discount_Item__c> disclineitems = new List<BE_Discount_Item__c>();
	                    for (BE_Discount_Item__c d: discounts) {
		                    if (prod.Product2.Name == d.Product__c) {
		                    	disclineitems.add(d);
		                    }
                        }
                        
                        if(disclineitems.isEmpty()){
                        	prd = prod.Product2.Name;
                        	DiscountedProductLineItem discLineItemProd = new DiscountedProductLineItem(prd, null, price, discprice);
                        	output.add(discLineItemProd);
                        }
                        else{
                        	for(BE_Discount_Item__c item : disclineitems){
                        		prd = item.Product__c;
                        		discprice = price + item.Discount_Amount__c;
                        		DiscountedProductLineItem discLineItemProd = new DiscountedProductLineItem(prd, item, price, discprice);
                        		output.add(discLineItemProd);
                        	}
                        	
                        }
         
                }
                return output;               
        }
        
        //########################################################
        //##################### TEST METHODS #####################
        //########################################################
		static TestMethod void testAccountUtilityController() {
			Test.StartTest();
				//get static data
				RecordType accType = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND Name='Customer Account' LIMIT 1];
				//create the account object record
				Account testAccnt = new Account(Name='APEXTESTACC001', RecordTypeId=accType.Id);
				insert testAccnt;
				String strAccId = testAccnt.Id;
				//create discount records
				BE_Discount__c[] testDiscs = new BE_Discount__c[0];
				testDiscs.add(new BE_Discount__c(Account__c=strAccId, Active__c=false, Status__c= 'Unapproved'));
				insert testDiscs;
				
				List<BE_Discount__c> checkDiscs = new List<BE_Discount__c>();
				checkDiscs = [SELECT Id, Name, Account__c, Active__c, Status__c	FROM BE_Discount__c WHERE Account__c=:strAccId];
				System.assertNotEquals(null, checkDiscs);
				
				BE_Discount_Item__c[] testDiscItems = new BE_Discount_Item__c[0];
				
				Decimal disAmnt = -2.00;
				
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Value', Quantity_Min__c=1, Quantity_Max__c=10, Discount_Amount__c= -2.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Value', Quantity_Min__c=10, Quantity_Max__c=20, Discount_Amount__c= -4.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Value', Quantity_Min__c=20, Quantity_Max__c=30, Discount_Amount__c= -6.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Value', Quantity_Min__c=30, Quantity_Max__c=50, Discount_Amount__c= -8.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Unlimited', Quantity_Min__c=0, Quantity_Max__c=100, Discount_Amount__c= -2.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Unlimited', Quantity_Min__c=100, Quantity_Max__c=200, Discount_Amount__c= -4.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Unlimited', Quantity_Min__c=200, Quantity_Max__c=500, Discount_Amount__c= -6.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Pro', Quantity_Min__c=0, Quantity_Max__c=20, Discount_Amount__c= -1.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Pro', Quantity_Min__c=20, Quantity_Max__c=40, Discount_Amount__c= -2.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Pro', Quantity_Min__c=40, Quantity_Max__c=60, Discount_Amount__c= -4.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Pro', Quantity_Min__c=60, Quantity_Max__c=80, Discount_Amount__c= -8.00));
				testDiscItems.add(new BE_Discount_Item__c(	BE_Discount__c=checkDiscs[0].Id, Product__c='BE Pro', Quantity_Min__c=80, Quantity_Max__c=100, Discount_Amount__c= -8.00));
				
				insert testDiscItems;
				
				List<BE_Discount_Item__c> checkDiscItems = new List<BE_Discount_Item__c>();
				checkDiscItems = [SELECT Id, Name, BE_Discount__c, Product__c, Discount_Amount__c, Quantity_Min__c, Quantity_Max__c 
								FROM BE_Discount_Item__c WHERE BE_Discount__c=:checkDiscs[0].Id];
				System.assertNotEquals(null, checkDiscItems);
				System.assertEquals(12, checkDiscItems.size());   
				
				//test invokation of the page and controller
				PageReference newPage = Page.AccountDiscountedProducts;
				Test.setCurrentPage(newPage);
				System.currentPageReference().getParameters().put('id', strAccId);
				ApexPages.StandardController accntcontroller = new ApexPages.StandardController(testAccnt);
				AccountUtilityController controller = new AccountUtilityController(accntcontroller);
				System.assertEquals(strAccId, controller.getAccount().Id);
				
				//test retrieval of the aggregated discounts with products
				DiscountedProductLineItem[] testDiscProds = new DiscountedProductLineItem[0];
				testDiscProds = controller.getProductPrices();
				PricebookEntry[] prodprices = [SELECT Id, Product2.Name, Pricebook2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'BE Price Book'];
				for (Integer i=0; i<testDiscProds.size(); i++) {
					System.assertNotEquals('', testDiscProds[i].getproduct());
					System.assertNotEquals(null, testDiscProds[i].getlistprice());
					if (testDiscProds[i].getdiscountlineitem()!=null) {
						System.assertNotEquals(null, testDiscProds[i].getdiscprice());
					}
				}
			
			Test.StopTest();
		}
}