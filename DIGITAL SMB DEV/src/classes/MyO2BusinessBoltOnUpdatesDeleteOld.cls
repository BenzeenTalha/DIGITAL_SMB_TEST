global without sharing class MyO2BusinessBoltOnUpdatesDeleteOld implements Schedulable {
	
	public static String CRON_EXP = '0 0 2 1 * ?';
	
	global static String scheduleMe() {
			
      	MyO2BusinessBoltOnUpdatesDeleteOld schedule = new MyO2BusinessBoltOnUpdatesDeleteOld();
      	return System.schedule('Delete old Business Bolt On Updates', CRON_EXP, schedule);
    
    }
	global void execute(SchedulableContext SC) {
		Date deleteRange = Date.today().addMonths(-1);
    	System.debug('deleting MyO2BusinessBoltOnUpdates - date range = ' + deleteRange);
    	List<MyO2BusinessBoltOnUpdate__c> mo2bBoltonUpdates  = [Select Id, CreatedDate From MyO2BusinessBoltOnUpdate__c Where CreatedDate < :deleteRange];
    	System.debug('deleting MyO2BusinessBoltOnUpdates - size = ' + mo2bBoltonUpdates.size());
    	System.debug('deleting MyO2BusinessBoltOnUpdates - data = ' + mo2bBoltonUpdates);
    	delete mo2bBoltonUpdates;
    }
}