@isTest
private class BB_HelperTest {

    static testMethod void testProductList(){
    	BB_Test.loadCustomSettingsData();
        Profile p = [Select Id,Name From Profile Where Name='System Administrator'];
        User u = new User(alias='sysAdmin', username='sfdcsysadmin@o2.co.uk', firstname='Admin', lastname='o2', email='sfdcsysadmin@o2.co.uk',
                          emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid=p.Id, country='United States', timezonesidkey='Europe/London');
        insert u;       
        system.runAs(u){
            String productList1 = BB_Helper.getProductList('CLHOL');
            system.debug('*** productList1 ***'+productList1);
            String productList2 = BB_Helper.getProductList('CLWAP');
            system.debug('*** productList2 ***'+productList2);
            String productList3 = BB_Helper.getProductList('');
            system.debug('*** productList3 ***'+productList3);
            String productList4 = BB_Helper.getProductList(Null);
            system.debug('*** productList4 ***'+productList4);
        }
    }
    
    static testMethod void testDownloadSpeed(){
    	BB_Test.loadCustomSettingsData();
        Profile p = [Select Id,Name From Profile Where Name='System Administrator'];
        User u = new User(alias='sysAdmin', username='sfdcsysadmin@o2.co.uk', firstname='Admin', lastname='o2', email='sfdcsysadmin@o2.co.uk',
                          emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid=p.Id, country='United States', timezonesidkey='Europe/London');
        insert u;       
        system.runAs(u){    
            String downloadSpeed1 = BB_Helper.getDownSpeed('CLHOL', 'L', '5100', Null, Null, '70', Null);
            system.debug('*** downloadSpeed1 ***'+downloadSpeed1);
            String downloadSpeed2 = BB_Helper.getDownSpeed('CLWAP', 'M', Null, '4100', Null, Null, '56');
            system.debug('*** downloadSpeed2 ***'+downloadSpeed2);
            String downloadSpeed3 = BB_Helper.getDownSpeed('CLHOL', 'L', Null, Null, Null, '70', Null);
            system.debug('*** downloadSpeed3 ***'+downloadSpeed3);
            String downloadSpeed4 = BB_Helper.getDownSpeed('CLWAP', 'M', Null, '4100', Null, Null, Null);
            system.debug('*** downloadSpeed4 ***'+downloadSpeed4);
        }
    }
    
    static testMethod void testUploadSpeed(){
    	BB_Test.loadCustomSettingsData();
        Profile p = [Select Id,Name From Profile Where Name='System Administrator'];
        User u = new User(alias='sysAdmin', username='sfdcsysadmin@o2.co.uk', firstname='Admin', lastname='o2', email='sfdcsysadmin@o2.co.uk',
                          emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid=p.Id, country='United States', timezonesidkey='Europe/London');
        insert u;       
        system.runAs(u){
            String uploadSpeed1 = BB_Helper.getUpSpeed('CLHOL', 'X', '1600', Null, Null, '70', Null);
            system.debug('*** uploadSpeed1 ***'+uploadSpeed1);
            String uploadSpeed2 = BB_Helper.getUpSpeed('CLWAP', 'S', Null, '2600', Null, Null, '56');
            system.debug('*** uploadSpeed2 ***'+uploadSpeed2);
            String uploadSpeed3 = BB_Helper.getUpSpeed('CLHOL', 'X', Null, Null, Null, '70', Null);
            system.debug('*** uploadSpeed3 ***'+uploadSpeed3);
            String uploadSpeed4 = BB_Helper.getUpSpeed('CLWAP', 'S', Null, '2600', Null, Null, Null);
            system.debug('*** uploadSpeed4 ***'+uploadSpeed4);
        }
    }

}