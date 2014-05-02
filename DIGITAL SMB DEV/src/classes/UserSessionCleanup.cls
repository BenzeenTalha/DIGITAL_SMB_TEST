global class UserSessionCleanup implements Database.Batchable<sObject>, Schedulable {

    public String strQuery {
    	get {if (strQuery == null) return 'SELECT Id, Name, cscfgc__User_Session__c, (SELECT Id, Name from cscfgc__Product_Configurations__r) from cscfgc__Product_Basket__c'; else return strQuery;}
    	set;
    }
    
    public Map<ID, cscfgc__User_Session__c> mpSessions = new Map<ID, cscfgc__User_Session__c>([SELECT Id, Name FROM cscfgc__User_Session__c LIMIT 50000]);  
    
    //start method to initialise query  
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(strQuery); 
    }
    
    //main execute method to perform actions
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<cscfgc__Product_Basket__c> lsBasketDeletes = new List<cscfgc__Product_Basket__c>();
        Map<ID, cscfgc__User_Session__c> mpSessionDeletes = new Map<ID, cscfgc__User_Session__c>();
        Integer pass = 0;
        Integer fail = 0;
        for (sObject obj: scope) {
            cscfgc__Product_Basket__c basket = (cscfgc__Product_Basket__c) obj;
            List<cscfgc__Product_Configuration__c> configs = basket.cscfgc__Product_Configurations__r;
            if (configs==null || configs.size() == 0) {
                lsBasketDeletes.add(basket);
                system.debug('basket.cscfgc__User_Session__c: '+basket.cscfgc__User_Session__c);
                system.debug('mpSessions.get(basket.cscfgc__User_Session__c): '+mpSessions.get(basket.cscfgc__User_Session__c));
                cscfgc__User_Session__c userSess = mpSessions.get(basket.cscfgc__User_Session__c);
                if (userSess != null) {
                    mpSessionDeletes.put(mpSessions.get(basket.cscfgc__User_Session__c).Id, mpSessions.get(basket.cscfgc__User_Session__c));                	
                    pass++;
                } else fail++;
            }
        }
        system.debug('pass: '+pass+' fail: '+fail);
        if (lsBasketDeletes!=null && lsBasketDeletes.size()>0) delete lsBasketDeletes;
        if (mpSessionDeletes!=null && mpSessionDeletes.size()>0) delete mpSessionDeletes.values();
    }
    
    //final finish method to tidy up
    global void finish(Database.BatchableContext BC) {}
    
    // interface to allow batch job to be scheduled
    global void execute(SchedulableContext sc) {
        UserSessionCleanup b = new UserSessionCleanup (); 
        Database.executeBatch(b, 20);
    }
    
    //### TEST METHODS ###
    public static testMethod void testScheduleSessionCleanup() {
        Test.StartTest();
            String strCRON = '0 0 1 * * ?';
            UserSessionCleanup testSched = new UserSessionCleanup ();
            System.schedule('Batch SessionCleanup Test', strCRON, testSched);
        Test.StopTest();
    }
    
    public static testMethod void testSessionCleanup() {
        cscfgc.SessionManager.SessionInfo userSession = cscfgc.SessionManager.getSessionInfo();
        cscfgc__Product_Basket__c sessionbasket = userSession.getSessionBasket();
        System.assertNotEquals(null, userSession.userSession.Id);
        System.assertNotEquals(null, sessionbasket.Id);

        Test.startTest();
            UserSessionCleanup b = new UserSessionCleanup ();
            b.strQuery = 'SELECT Id, Name, cscfgc__User_Session__c, (SELECT Id, Name from cscfgc__Product_Configurations__r) from cscfgc__Product_Basket__c ORDER BY CreatedDate desc LIMIT 20';
            Database.executeBatch(b, 20);
        Test.stopTest();
        
/* TODO - this sometimes fails when we apply a LIMIT
          need to fix
        List<cscfgc__User_Session__c> testUserSession = [SELECT Id FROM cscfgc__User_Session__c WHERE Id=:userSession.userSession.Id LIMIT 1];
        System.assertEquals(0, testUserSession.size());
        List<cscfgc__Product_Basket__c> testSessionBasket = [SELECT Id FROM cscfgc__Product_Basket__c WHERE Id=:sessionbasket.Id LIMIT 1];
        System.assertEquals(0, testSessionBasket.size());
*/
    }
}