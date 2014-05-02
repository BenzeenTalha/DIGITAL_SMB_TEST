public with sharing class UnifySiteController {

	public static void checkQualityChecks (Unify_Site__c site) {
		
		boolean quality = false;
		
		List <Unify_Site__c> sites = [select Id,Order_Group__r.Id,Quality_Check_Actual_Date__c from Unify_Site__c where Order_Group__r.Id = : site.Order_Group__c and Id != : site.Id];
		
		for (integer i = 0; i < sites.size(); ++i) {
			
			if (sites[i].Quality_Check_Actual_Date__c == null) {
				quality = true;
			}
		}
		
		
		if (quality == false) {
			
			Order_Group__c og = [select Id,Status__c from Order_Group__c where Id = : site.Order_Group__c];
			og.Status__c = 'Completed';
			update og;
			
		}
	}
	
	public static void createSiteSLAs (Unify_Site__c site) {
		
		site.Ready_for_Billing__c = true;
		site.Ready_for_Billing_Date__c = Datetime.now();
		site.Added_to_Billing_System_Target_Date__c = PublicHolidayHelper.addDays (site.Ready_for_Billing_Date__c, integer.valueOf(UnifyConfiguration__c.getInstance('Added to Billing System Target Days').Value__c));
		integer val = integer.valueOf(UnifyConfiguration__c.getInstance('Added to Billing System Warning Days').Value__c) * (-1);
		site.Added_to_Billing_System_Warning_Date__c = PublicHolidayHelper.addDays (site.Added_to_Billing_System_Target_Date__c, val);
		site.Added_to_Billing_System_RAG_Status__c = 'Green'; 
		site.Added_to_Billing_System_Status__c = 'In Progress';
		
	} 
	
	public static void upsertSLAs (Unify_Site__c site) {
		
		List <SLA__c> slas = [select Id,Name,Target_Date__c,Warning_Date__c,SLA_RAG_Value__c,SLA_Status__c,Actual_Date__c from SLA__c where Site__r.Id = : site.Id];
		
		if (slas.size() == 0) {
			List <SLA__c> s = new List <SLA__c>();
			SLA__c s1 = new SLA__c(Name='Added to Billing System',Target_Date__c=site.Added_to_Billing_System_Target_Date__c,Warning_Date__c=site.Added_to_Billing_System_Warning_Date__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Site__c=site.Id);
			SLA__c s2 = new SLA__c(Name='Quality Check Complete',SLA_Status__c = 'In Progress',Site__c = site.Id);
			s.add(s1);
			s.add(s2);
			insert s;
		}
		else { //slas.size() > (0 -cannot be < 0)
			if (slas[0].Name == 'Quality Check Complete') {
				slas[0].Actual_Date__c = site.Quality_Check_Actual_Date__c;
				slas[1].Actual_Date__c = site.Added_to_Billing_System_Actual_Date__c;
				slas[1].Target_Date__c = site.Added_to_Billing_System_Target_Date__c;
				slas[1].Warning_Date__c = site.Added_to_Billing_System_Warning_Date__c;
				slas[1].SLA_Status__c = site.Added_to_Billing_System_Status__c;
				slas[1].SLA_RAG_Value__c = site.Added_to_Billing_System_RAG_Status__c;
			}
			else {
				slas[1].Actual_Date__c = site.Quality_Check_Actual_Date__c;
				slas[0].Actual_Date__c = site.Added_to_Billing_System_Actual_Date__c;
				slas[0].Target_Date__c = site.Added_to_Billing_System_Target_Date__c;
				slas[0].Warning_Date__c = site.Added_to_Billing_System_Warning_Date__c;
				slas[0].SLA_Status__c = site.Added_to_Billing_System_Status__c;
				slas[0].SLA_RAG_Value__c = site.Added_to_Billing_System_RAG_Status__c;
			}
			update slas;
		}
	}
	
	public static void pauseSiteSLA (Unify_Site__c site) {
		
		site.Paused_Date__c = Datetime.now();
		
	}
	
	public static void unpauseSiteSLA (Unify_Site__c site) {
		
		Datetime dt = Datetime.now();
		integer difference = integer.ValueOf( dt.getTime() - site.Paused_Date__c.getTime())/(1000*60*60*24);
		integer secs = integer.ValueOf( dt.getTime() - site.Paused_Date__c.getTime())/(1000);
		Datetime oldTd = site.Added_to_Billing_System_Target_Date__c;
		Datetime oldWd = site.Added_to_Billing_System_Warning_Date__c;
		
		site.Paused_Date__c = null;
		site.Added_to_Billing_System_Status__c = 'In Progress';
		
		if (oldTd != null) {
			if (difference > 0) site.Added_to_Billing_System_Target_Date__c = PublicHolidayHelper.addDays (oldTd, difference);
			site.Added_to_Billing_System_Target_Date__c = site.Added_to_Billing_System_Target_Date__c.addSeconds(secs);
		}
		
		if (oldWd != null) {
			integer days = integer.valueOf(UnifyConfiguration__c.getInstance('Added to Billing System Warning Days').Value__c) * (-1);
			site.Added_to_Billing_System_Warning_Date__c = PublicHolidayHelper.addDays(site.Added_to_Billing_System_Target_Date__c, days);
		}
		
		
	}
	
	public static void resetWarning (Unify_Site__c site) {
		
		integer days = integer.valueOf(UnifyConfiguration__c.getInstance('Added to Billing System Warning Days').Value__c) * (-1);
		site.Added_to_Billing_System_Warning_Date__c = PublicHolidayHelper.addDays(site.Added_to_Billing_System_Target_Date__c, days);
		
	}
	
	public static void resetSiteSLA (Unify_Site__c site) {
		
		site.Added_to_Billing_System_Actual_Date__c = null;
		site.Added_to_Billing_System_Status__c = 'In Progress';
		site.Added_to_Billing_System_RAG_Status__c = 'Green';
		
		
	}
	
}