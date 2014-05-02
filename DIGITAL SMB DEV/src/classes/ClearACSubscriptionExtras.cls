global class ClearACSubscriptionExtras implements Schedulable
{
	global void execute(SchedulableContext sc) 
	{
		list<AC_Subscription_Extra__c> subsExtra = [Select Id From AC_Subscription_Extra__c];
		if(!subsExtra.isEmpty())
			delete subsExtra;
	}
	
	
}