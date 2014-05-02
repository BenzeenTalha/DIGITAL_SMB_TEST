public with sharing class SLAHelper {
	
	public static void createSLAs(Order__c ord) {
		
		//this can be avoid
		cscfgc__Product_Configuration__c prconf = [select Id, Unify_Access_Type__c,Unify_Order_Type__c,Unify_Access_Option__c from cscfgc__Product_Configuration__c where Id = : ord.Product_Configuration__c ];
		
		List<SLA_Template__c> slaTemps = new List<SLA_Template__c>();
		List<SLA_Template__c> slaTemps2 = new List<SLA_Template__c>();
		
		// Maintenance, Managed Services, Professional Services, Other
		if (ord.Product_Type__c != 'Hardware' && ord.Product_Type__c != 'Connectivity') {
			slaTemps = [select Id,Order_Status__c,Related_Object__c,Product_Type__c,Milestone_Order__c,Tracking_Type__c,Target_Days__c,Warning_Days__c,Milestone_Description__c from SLA_Template__c where Related_Object__c = 'Order' and Product_Type__c = : ord.Product_Type__c and Tracking_Type__c != 'N/A'];
		}
		
		//Hardware
		else if (ord.Product_Type__c == 'Hardware') {
			slaTemps = [select Id,Order_Status__c,Related_Object__c,Product_Type__c,Order_Type__c,Milestone_Order__c,Tracking_Type__c,Target_Days__c,Warning_Days__c,Milestone_Description__c from SLA_Template__c where Related_Object__c = 'Order' and  Product_Type__c = : ord.Product_Type__c and Order_Type__c includes (:prconf.Unify_Order_Type__c)  and Tracking_Type__c != 'N/A'];
		}
		
		//Connectivity
		else if (prconf.Unify_Access_Type__c!='Digital Link Ethernet' && prconf.Unify_Access_Type__c!='VPN Network' && prconf.Unify_Access_Type__c!='Business Broadband' && prconf.Unify_Access_Type__c!='ISDN2' && prconf.Unify_Access_Type__c!='ISDN30' && prconf.Unify_Access_Type__c!='PSTN'){
			slaTemps = [select Id,Order_Status__c,Milestone_Order__c,Tracking_Type__c,Order_Type__c,Product_Type__c,Target_Days__c,Warning_Days__c,Milestone_Description__c,Connectivity_Access_Type__c from SLA_Template__c where Related_Object__c = 'Order' and Product_Type__c = : ord.Product_Type__c and Order_Type__c includes (:prconf.Unify_Order_Type__c) and Connectivity_Access_Type__c = :prconf.Unify_Access_Type__c  and Tracking_Type__c != 'N/A'];
			if (prconf.Unify_Order_Type__c != 'Novation') {
				slaTemps2 = [select Id,Order_Status__c,Related_Object__c,Tracking_Type__c,Milestone_Order__c,Target_Days__c,Warning_Days__c,Milestone_Description__c from SLA_Template__c where Related_Object__c = 'Order' and Name = 'Customer required date (CRD)'];
			}
		}
		
		//Connectivity - Digital Link Ethernet, VPN Network, Business Broadband, ISDN2, ISDN30, PTSN
		else if (ord.Product_Type__c == 'Connectivity') {
			slaTemps = [select Id,Order_Status__c,Milestone_Order__c,Tracking_Type__c,Order_Type__c,Product_Type__c,Target_Days__c,Warning_Days__c,Milestone_Description__c,Connectivity_Access_Type__c,Connectivity_Product__r.Name from SLA_Template__c where Related_Object__c = 'Order' and  Product_Type__c = : ord.Product_Type__c and Order_Type__c includes (:prconf.Unify_Order_Type__c) and Connectivity_Access_Type__c = :prconf.Unify_Access_Type__c  and Tracking_Type__c != 'N/A' and Connectivity_Product__r.Name = :prconf.Unify_Access_Option__c];
			if (prconf.Unify_Order_Type__c != 'Novation') {
				slaTemps2 = [select Id,Order_Status__c,Related_Object__c,Tracking_Type__c,Milestone_Order__c,Target_Days__c,Warning_Days__c,Milestone_Description__c from SLA_Template__c where Related_Object__c = 'Order' and Name = 'Customer required date (CRD)'];
			}
		}
		
		if (prconf.Unify_Order_Type__c == 'Novation') {
			slaTemps = [select Id,Order_Status__c,Milestone_Order__c,Tracking_Type__c,Order_Type__c,Product_Type__c,Target_Days__c,Warning_Days__c,Milestone_Description__c,Connectivity_Access_Type__c,Connectivity_Product__r.Name from SLA_Template__c where Related_Object__c = 'Order' and Order_Type__c = 'Novation' and Tracking_Type__c != 'N/A'];
		}		
		
		List<SLA__c> slas = new List<SLA__c>();
		
		for (integer i = 0; i < slaTemps.Size(); ++i) {
			
			SLA__c sla = new SLA__c(Name=slaTemps[i].Milestone_Description__c,Order__c=ord.Id,Tracking_Type__c=slaTemps[i].Tracking_Type__c,Milestone_Order__c=slaTemps[i].Milestone_Order__c,Target_Days__c=slaTemps[i].Target_Days__c,Warning_Days__c=slaTemps[i].Warning_Days__c,Order_Status__c=slaTemps[i].Order_Status__c);
			slas.Add(sla);
			
		}
		if (!slaTemps2.isEmpty()) {
			for (integer i = 0; i < slaTemps2.Size(); ++i) {
				SLA__c sla = new SLA__c(Name=slaTemps2[i].Milestone_Description__c,Order__c=ord.Id,Tracking_Type__c=slaTemps2[i].Tracking_Type__c,Milestone_Order__c=slaTemps2[i].Milestone_Order__c,Target_Days__c=slaTemps2[i].Target_Days__c,Warning_Days__c=slaTemps2[i].Warning_Days__c,Order_Status__c=slaTemps2[i].Order_Status__c);
				slas.Add(sla);
			}
		}
		insert slas;
		
	}
	
/*	public static void calculateWarning (SLA__c sNew, SLA__c sOld) {
		
		Order__c ord = [select Id,Order_Placed_Date__c from Order__c where Id = : sNew.Order__c];
		
		if (ord.Order_Placed_Date__c != null && sNew.Warning_Days__c != null && sNew.Target_Date__c != null) {
				
			integer days = sNew.Warning_Days__c.intValue() * (-1);
				
			sNew.Warning_Date__c = PublicHolidayHelper.addDays(sNew.Target_Date__c, days);
				
		}
		
		if (sNew.Target_Date__c == null) {
			sNew.Warning_Date__c = null;
		}
			
	}
	
	public static void setWarningTarget (SLA__c sla) {
		
		Order__c ord = [select Id, Order_Placed_Date__c from Order__c where Id = : sla.Order__c];
		
		if (ord.Order_Placed_Date__c != null && sla.Target_Days__c != null ) {
			sla.Target_Date__c = PublicHolidayHelper.addDays(ord.Order_Placed_Date__c, sla.Target_Days__c.intValue());
		}
		
		if (ord.Order_Placed_Date__c != null && sla.Warning_Days__c != null && sla.Target_Date__c != null) {
			
			integer days = sla.Warning_Days__c.intValue() * (-1);
				
			sla.Warning_Date__c = PublicHolidayHelper.addDays(sla.Target_Date__c, days);
		}
		
	} */
	
	public static void setTargets (Order__c ord) {
		
		List<SLA__c> slas = [select Id,Order__c,Target_Days__c,SLA_RAG_Value__c,SLA_Status__c,Tracking_Type__c from SLA__c where Order__c = : ord.Id and Completed__c = false];
		
		for (integer i = 0; i < slas.Size(); ++i) {
			
			if (slas[i].Target_Days__c != null) {
				
				slas[i].Target_Date__c = PublicHolidayHelper.addDays(ord.Order_Placed_Date__c, slas[i].Target_Days__c.intValue());
				
			}
			
			if (slas[i].Tracking_Type__c == 'Target') {
					slas[i].SLA_RAG_Value__c = 'Green';
					slas[i].SLA_Status__c = 'In Progress';
			}
			
		}
		
		update slas;
		
	} 
	
	public static void pauseSLA (SLA__c sla) {
		
		sla.Paused_Date__c = Datetime.now();
		sla.Pause__c = true;
		sla.SLA_Status__c = 'Paused';
		
	}
	
	public static void unpauseSLA (SLA__c sla) {
		
		Datetime dt = Datetime.now();
		integer difference = integer.ValueOf( dt.getTime() - sla.Paused_Date__c.getTime())/(1000*60*60*24);
		integer secs = integer.ValueOf( dt.getTime() - sla.Paused_Date__c.getTime())/(1000);
		Datetime oldTd = sla.Target_Date__c;
		Datetime oldWd = sla.Warning_Date__c;
		
		sla.Paused_Date__c = null;
		sla.Pause__c = false;
		sla.SLA_Status__c = 'In Progress';
		
		if (oldTd != null) {
			if (difference > 0) sla.Target_Date__c = PublicHolidayHelper.addDays (oldTd, difference);
			sla.Target_Date__c = sla.Target_Date__c.addSeconds(secs);
		}
		
		if (oldWd != null) {
			integer days = sla.Warning_Days__c.intValue() * (-1);
			sla.Warning_Date__c = PublicHolidayHelper.addDays(sla.Target_Date__c, days);
		}
		
		
	}
	
	public static void runOrderStatus (SLA__c sla) {
		
		if (sla.Order_Status__c != null) {
			
			Order__c ord = [select Id,Order_Status__c,Previous_Status__c from Order__c where Id = : sla.Order__c];
			if (ord.Order_Status__c != 'Order complete') ord.Order_Status__c = sla.Order_Status__c;
			
			update ord;
			
		}
		
	}
	
	public static void resetSLA (SLA__c sla) {
		
		sla.Actual_Date__c = null;
		sla.SLA_Status__c = 'In Progress';
		sla.Completed__c = false;
		sla.SLA_RAG_Value__c = 'Green';
		
		if (sla.Order__c != null && sla.Order_Status__c != null) {
			
			Order__c ord = [select Id,Order_Status__c,Previous_Status__c from Order__c where Id = : sla.Order__c];
			ord.Order_Status__c = ord.Previous_Status__c;
			update ord;
		}
		
	}
	
	public static void deleteSLAs (Order__c ord) {
		
		List <SLA__c> slas = [select Id,Target_Date__c,Warning_Date__c,SLA_Status__c,SLA_RAG_Value__c from SLA__c where Order__c = : ord.Id and Tracking_Type__c = 'Target' and Completed__c = false];
		
		for (integer i = 0; i < slas.size(); ++i) {
			
			slas[i].Target_Date__c = null;
			slas[i].Warning_Date__c = null;
			slas[i].SLA_Status__c = 'Not started';
			slas[i].SLA_RAG_Value__c = null;
			
		}
		update slas;
	}
	
	
	
/*	public static void upsertOppSLAs (Opportunity opp) {
		
		boolean exists = false;
		List <SLA__c> slas = [select Id,Name,Target_Date__c,Warning_Date__c,SLA_RAG_Value__c,SLA_Status__c,Actual_Date__c,Completed__c from SLA__c where Opportunity__r.Id = : opp.Id];
		List <SLA__c> sIns = new List <SLA__c>();
		List <Case> c = [select Id from Case where Opportunity__c = : opp.Id limit 1];
		
		if (opp.Pricing_Desk_Start__c != null) {
			if (slas.size() == 0) {
				SLA__c s1 = new SLA__c(Name='Pricing Desk',Target_Date__c=opp.Pricing_Desk_Target__c,Warning_Date__c=opp.Pricing_Desk_Warning__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Opportunity__c=opp.Id);
				if (c.size() > 0) s1.Case__c = c[0].Id;
				sIns.add(s1);
				exists = true;
			}
			else { // slas.size() > 0
				for (integer i = 0; i < slas.size(); ++i) {
					if (slas[i].Name == 'Pricing Desk') {
						slas[i].Actual_Date__c = opp.Pricing_Desk_Completed__c;
						slas[i].Target_Date__c = opp.Pricing_Desk_Target__c;
						slas[i].Warning_Date__c = opp.Pricing_Desk_Warning__c;
						slas[i].SLA_RAG_Value__c = opp.Pricing_Desk_RAG_Value__c;
						if (opp.Pricing_Desk_Status__c == 'Pending' || opp.Pricing_Desk_Status__c == 'Accepted') {
							slas[i].SLA_Status__c = 'In Progress';
						}
						if (opp.Pricing_Desk_Status__c == 'Completed') {
							slas[i].SLA_Status__c = 'Completed';
							slas[i].Completed__c = true;
						}
						if (opp.Pricing_Desk_Status__c == 'Rejected') {
							slas[i].SLA_Status__c = 'Rejected';
							slas[i].Completed__c = true;
						}
						exists = true;
						break;
					}
				}
			}
			if (exists == false) {
				SLA__c s1 = new SLA__c(Name='Pricing Desk',Target_Date__c=opp.Pricing_Desk_Target__c,Warning_Date__c=opp.Pricing_Desk_Warning__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Opportunity__c=opp.Id);
				if (c.size() > 0) s1.Case__c = c[0].Id;
				sIns.add(s1);
			}
		}
		exists = false;
		if (opp.Solution_Desk_Start__c != null) {
			if (slas.size() == 0) {
				SLA__c s2 = new SLA__c(Name='Solution Desk',Target_Date__c=opp.Solution_Desk_Target__c,Warning_Date__c=opp.Solution_Desk_Warning__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Opportunity__c=opp.Id);
				if (c.size() > 0) s2.Case__c = c[0].Id;
				sIns.add(s2);
				exists = true;
			}
			else { // slas.size() > 0
				for (integer i = 0; i < slas.size(); ++i) {
					if (slas[i].Name == 'Solution Desk') {
						slas[i].Actual_Date__c = opp.Solution_Desk_Completed__c;
						slas[i].Target_Date__c = opp.Solution_Desk_Target__c;
						slas[i].Warning_Date__c = opp.Solution_Desk_Warning__c;
						slas[i].SLA_RAG_Value__c = opp.Solution_Desk_RAG_Value__c;
						if (opp.Solution_Desk_Status__c == 'Pending' || opp.Solution_Desk_Status__c == 'Accepted') {
							slas[i].SLA_Status__c = 'In Progress';
						}
						if (opp.Solution_Desk_Status__c == 'Completed') {
							slas[i].SLA_Status__c = 'Completed';
							slas[i].Completed__c = true;
						}
						if (opp.Solution_Desk_Status__c == 'Rejected') {
							slas[i].SLA_Status__c = 'Rejected';
							slas[i].Completed__c = true;
						}
						exists = true;
						break;
					}
				}
			}
			if (exists == false) {
				SLA__c s2 = new SLA__c(Name='Solution Desk',Target_Date__c=opp.Solution_Desk_Target__c,Warning_Date__c=opp.Solution_Desk_Warning__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Opportunity__c=opp.Id);
				if (c.size() > 0) s2.Case__c = c[0].Id;
				sIns.add(s2);
			}
		}
		exists = false;
		if (opp.Order_Management_Team_Start__c != null) {
			if (slas.size() == 0) {
				SLA__c s3 = new SLA__c(Name='Order Management Team',Target_Date__c=opp.Order_Management_Team_Target__c,Warning_Date__c=opp.Order_Management_Team_Warning__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Opportunity__c=opp.Id);
				if (c.size() > 0) s3.Case__c = c[0].Id;
				sIns.add(s3);
				exists = true;
			}
			else { // slas.size() > 0
				for (integer i = 0; i < slas.size(); ++i) {
					if (slas[i].Name == 'Order Management Team') {
						slas[i].Actual_Date__c = opp.Order_Management_Team_Completed__c;
						slas[i].Target_Date__c = opp.Order_Management_Team_Target__c;
						slas[i].Warning_Date__c = opp.Order_Management_Team_Warning__c;
						slas[i].SLA_RAG_Value__c = opp.Order_Management_Team_RAG_Value__c;
						if (opp.Order_Management_Team_Status__c == 'Pending' || opp.Order_Management_Team_Status__c == 'Accepted') {
							slas[i].SLA_Status__c = 'In Progress';
						}
						if (opp.Order_Management_Team_Status__c == 'Completed') {
							slas[i].SLA_Status__c = 'Completed';
							slas[i].Completed__c = true;
						}
						exists = true;
						break;
					}
				}
			}
			if (exists == false) {
				SLA__c s3 = new SLA__c(Name='Order Management Team',Target_Date__c=opp.Order_Management_Team_Target__c,Warning_Date__c=opp.Order_Management_Team_Warning__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Opportunity__c=opp.Id);
				if (c.size() > 0) s3.Case__c = c[0].Id;
				sIns.add(s3);
			}
		}
		exists = false;
		// SLA
		if (slas.size() == 0) {
				SLA__c s4 = new SLA__c(Name='Case Opportunity SLA',Target_Date__c=opp.SLA_Target_Date__c,Warning_Date__c=opp.SLA_Warning_Date__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Opportunity__c=opp.Id);
				if (c.size() > 0) s4.Case__c = c[0].Id;
				sIns.add(s4);
				exists = true;
		}
		else { // slas.size() > 0
				for (integer i = 0; i < slas.size(); ++i) {
					if (slas[i].Name == 'Case Opportunity SLA') {
						slas[i].Actual_Date__c = opp.SLA_Actual_Date__c;
						slas[i].Target_Date__c = opp.SLA_Target_Date__c;
						slas[i].Warning_Date__c = opp.SLA_Warning_Date__c;
						slas[i].SLA_RAG_Value__c = opp.SLA_RAG_Value__c;
						exists = true;
						break;
					}
				}
		}
		if (exists == false) {
			SLA__c s4 = new SLA__c(Name='Case Opportunity SLA',Target_Date__c=opp.SLA_Target_Date__c,Warning_Date__c=opp.SLA_Warning_Date__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Opportunity__c=opp.Id);
			if (c.size() > 0) s4.Case__c = c[0].Id;
				sIns.add(s4);
		}
				
		if (sIns.size() > 0) {
			insert sIns;
		}
		if (slas.size() > 0) {
			update slas;
		}
	}
	
	public static void upsertCaseSLAs (Case c) {
		
		List <SLA__c> slas = [select Id,Name,Target_Date__c,Warning_Date__c,SLA_RAG_Value__c,SLA_Status__c,Actual_Date__c,Completed__c from SLA__c where Case__r.Id = : c.Id];
		List <SLA__c> sIns = new List <SLA__c> ();
		
		
		if (slas.size() == 0) {
				SLA__c s1 = new SLA__c(Name='Case OLA',Target_Date__c=c.OLA_Target_Date__c,Warning_Date__c=c.OLA_Warning_Date__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Case__c = c.Id);
				SLA__c s2 = new SLA__c(Name='Case Opportunity SLA',Target_Date__c=c.SLA_Target_Date__c,Warning_Date__c=c.SLA_Warning_Date__c,SLA_RAG_Value__c='Green',SLA_Status__c='In Progress',Case__c = c.Id);
				if (c.Opportunity__c != null) {
					s1.Opportunity__c = c.Opportunity__c;
					s2.Opportunity__c = c.Opportunity__c;
				}
				sIns.add(s1); sIns.add(s2);
		}
		else { // slas.size() > 0
			for (integer i = 0; i < slas.size(); ++i) {
				if (slas[i].Name == 'Case OLA') {
					slas[i].Actual_Date__c = c.OLA_Actual_Date__c;
					slas[i].Target_Date__c = c.OLA_Target_Date__c;
					slas[i].Warning_Date__c = c.OLA_Warning_Date__c;
					slas[i].SLA_RAG_Value__c = c.OLA_RAG_Value__c;
				}
				if (slas[i].Name == 'Case Opportunity SLA') {
					slas[i].Actual_Date__c = c.SLA_Actual_Date__c;
					slas[i].Target_Date__c = c.SLA_Target_Date__c;
					slas[i].Warning_Date__c = c.SLA_Warning_Date__c;
					slas[i].SLA_RAG_Value__c = c.SLA_RAG_Value__c;
				}
				if (c.Opportunity__c != null) {
					slas[i].Opportunity__c = c.Opportunity__c;
				}
			}
		}
		
		if (sIns.size() > 0) {
			insert sIns;
		}
		if (slas.size() > 0) {
			update slas;
		}
		
	}*/
	
}