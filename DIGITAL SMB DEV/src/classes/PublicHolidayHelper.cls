public with sharing class PublicHolidayHelper {

	public static integer noOfHolidays (Datetime startD, Datetime endD) {

		Date startDate = startD.date();
		Date endDate = endD.date();
		integer i;
		
		if (startDate == endDate) {

			if (isHoliday(startDate)) return 1;
			else return 0;
		}

		else if (startDate < endDate) {
			
			i = [select COUNT() from Public_Holiday__c where Holiday__c > : startDate and Holiday__c <= : endDate];
			
		}
		else { //startDate > endDate
			
			i = [select COUNT() from Public_Holiday__c where Holiday__c < : startDate and Holiday__c >= : endDate];
			
		}

		return i;
	}
	
	public static boolean isHoliday (Date d) {
		
		integer i = [select COUNT() from Public_Holiday__c where Holiday__c = : d];
		
		if (i >= 0) return true;
		else return false;
		
	}
	
	public static Datetime skipWeekend (Datetime dt) {
		
		if (dt.format('E') == 'Sat') return dt.addDays(2);
		if (dt.format('E') == 'Sun') return dt.addDays(1);
		return dt;
		
	}

	public static Datetime addDays (Datetime startD, integer days) {

		startD = skipWeekend (startD);
		
		Datetime dt, dt2, d1, d2;
		integer noh;
		boolean isBefore = false;
		
		Businesshours bh = [select Id from Businesshours where Name = 'Unify' limit 1];

	    dt = Businesshours.add(bh.Id, startD, days * integer.valueof(UnifyConfiguration__c.getInstance('Working Hours').Value__c) * 60 * 60 * 1000L);
		dt2 = dt;

		noh = noOfHolidays(startD,dt);

		while (noh > 0) {
			
			if (startD > dt) noh *= -1;
	
			dt2 = Businesshours.add(bh.Id, dt, noh * integer.valueof(UnifyConfiguration__c.getInstance('Working Hours').Value__c) * 60 * 60 * 1000L);

			if (integer.valueof(UnifyConfiguration__c.getInstance('Working Hours').Value__c) < 24 && startD.hour() >= integer.valueof(UnifyConfiguration__c.getInstance('Working Hours').Value__c)) {
				integer h = integer.valueof(UnifyConfiguration__c.getInstance('Working Hours').Value__c) * (-1);
			
				if (startD < dt2) {
					d2 = dt2.addHours(h);
					d2 = d2.addHours(startD.hour());
					d2 = d2.addMinutes(startD.minute());
					d2 = d2.addSeconds(startD.second());
				}
				else {
					d2 = dt2.addHours(startD.hour());
					d2 = d2.addMinutes(startD.minute());
					d2 = d2.addSeconds(startD.second());
				}
				if (startD < dt) {
					d1 = dt.addHours(h);
					d1 = d1.addHours(startD.hour());
					d1 = d1.addMinutes(startD.minute());
					d1 = d1.addSeconds(startD.second());
				}
				else {
					d1 = dt.addHours(startD.hour());
					d1 = d1.addMinutes(startD.minute());
					d1 = d1.addSeconds(startD.second());
				}
				
				noh = noOfHolidays(d1, d2);
			}
			else {
				noh = noOfHolidays(dt,dt2);
			}
			
			dt = dt2;
		}
		
		if (integer.valueof(UnifyConfiguration__c.getInstance('Working Hours').Value__c) < 24 && startD.hour() >= integer.valueof(UnifyConfiguration__c.getInstance('Working Hours').Value__c)) {
			
			integer h = integer.valueof(UnifyConfiguration__c.getInstance('Working Hours').Value__c) * (-1);
			
			if (startD < dt2) {
				d2 = dt2.addHours(h);
				d2 = d2.addHours(startD.hour());
				d2 = d2.addMinutes(startD.minute());
				d2 = d2.addSeconds(startD.second());
			}
			else {
				d2 = dt2.addHours(startD.hour());
				d2 = d2.addMinutes(startD.minute());
				d2 = d2.addSeconds(startD.second());
			}
			return d2;
		}
		return dt2;

	}
	
}