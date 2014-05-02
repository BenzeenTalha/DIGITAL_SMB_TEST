global without sharing class DailySLAEmail implements Schedulable {
	
	public static String CRON_EXP = '0 0 8 ? * MON-FRI *'; //every week day

	global static String scheduleMe() {
			
      	DailySLAEmail schedule = new DailySLAEmail();
      	return System.schedule('Daily Scheduled Amber and Red SLAs', CRON_EXP, schedule);
    
    }
   
    public static Map<Id,List<SLA__c>> getAmberRedSLAs() { 
    	
    	Datetime dt = Datetime.now();
    	map<Id,List<SLA__c>> userSLA = new map<Id,List<SLA__c>>();
    	
    	List <User> users = [select Id,FirstName,LastName,Email,(select Id,Assignee_Full_Name__c,Assignee_Email__c,Order__r.Product_Configuration__r.Unify_Solution__c,Order__r.Name,Name,Target_Date__c,Order__r.Order_Group__r.Name,Order__r.Unify_Site__r.Name,Warning_Date__c from SLAs__r where Completed__c = false and Order__r.Order_Status__c != 'Not Provisioned' and Order__r.Order_Status__c != 'Cancelled' and SLA_RAG_Value__c != 'Green' and (Target_Date__c <= : dt or Warning_Date__c <= : dt)) from User where Id in (select SLA__c.Assignee__c from SLA__c where SLA__c.Completed__c = false and SLA__c.SLA_RAG_Value__c!='Green' and SLA__c.Order__r.Order_Status__c != 'Not Provisioned' and SLA__c.Order__r.Order_Status__c != 'Cancelled' and (SLA__c.Target_Date__c <= : dt or SLA__c.Warning_Date__c <= : dt))];
    	for(User u : users) { 
			for(List<SLA__c> sla : u.SLAs__r) { 
				userSLA.put(u.Id, sla); 
			} 
		} 
    
    	return userSLA;
    	
    }
    
    public static string generatePlainText(Id u, List <SLA__c> slas) {
    	
    	string plaintext = '';
    	
    	Datetime dt = Datetime.now();
    	
    	List <SLA__c> red = new List <SLA__c>();
    	List <SLA__c> amber = new List <SLA__c>();
    	
    	for (integer i = 0; i < slas.Size(); ++i) {
    		
    		if (slas[i].Target_Date__c <= dt) {
    			
    			red.Add(slas[i]);
    			
    		}
    		else if (slas[i].Warning_Date__c <= dt) {
    			amber.Add(slas[i]);
    		}
    	
    	}


    	if (!red.isEmpty()) {
    		
    		plaintext += 'Dear' + red[0].Assignee_Full_Name__c + '\n';
    		plaintext += 'Orders with SLA in Red (Target date has passed):\n';
    		plaintext += 'Milestone\t';
    		plaintext += 'Order\t';
    		plaintext += 'Solution\t';
    		plaintext += 'Site\t';
    		plaintext += 'Order Group\t';
    		plaintext += 'Target Date\n';
    		
 
    		for (integer i = 0; i < red.Size(); ++i) {
    			
    			plaintext += red[i].Name + '\t';
    			plaintext += red[i].Order__r.Name + '\t';
    			plaintext += red[i].Order__r.Order_Group__r.Name + '\t';
    			plaintext += red[i].Order__r.Product_Configuration__r.Unify_Solution__c + '\t';
    			plaintext += red[i].Order__r.Unify_Site__r.Name + '\t';
    			plaintext += red[i].Target_Date__c +'\n';
    			
    		}
    		
    		plaintext += '\n';
    		
    	}
    	if (!amber.isEmpty()) {
    		
    		if (red.isEmpty()) {
    			plaintext += 'Dear' + amber[0].Assignee_Full_Name__c + '\n';
    		}
    		plaintext += 'Orders with SLA in Amber (Target date is about to be breached):\n';
    		plaintext += 'Milestone\t';
    		plaintext += 'Order\t';
    		plaintext += 'Solution\t';
    		plaintext += 'Site\t';
    		plaintext += 'Order Group\t';
    		plaintext += 'Target Date\n';
    		
    		for (integer i = 0; i < amber.Size(); ++i) {
    			
    			plaintext += amber[i].Name + '\t';
    			plaintext += amber[i].Order__r.Name + '\t';
    			plaintext += amber[i].Order__r.Product_Configuration__r.Unify_Solution__c + '\t';
    			plaintext += amber[i].Order__r.Order_Group__r.Name + '\t';
    			plaintext += amber[i].Order__r.Unify_Site__r.Name + '\t';
    			plaintext += amber[i].Target_Date__c +'\n';
    			
    			
    		}
    		
    	}
    	
    	return plaintext;
    
    }
    
    public static string generateHtml (Id u, List <SLA__c> slas) {
    	
    	string htmltext = '';
    	
    	Datetime dt = Datetime.now();
    	
    	List <SLA__c> red = new List <SLA__c>();
    	List <SLA__c> amber = new List <SLA__c>();
    	
    	for (integer i = 0; i < slas.Size(); ++i) {
    		
    		if (slas[i].Target_Date__c <= dt) {
    			
    			red.Add(slas[i]);
    			
    		}
    		else if (slas[i].Warning_Date__c <= dt) {
    			amber.Add(slas[i]);
    		}
    	}
    	
    	
    	if (!red.isEmpty()) {
    		
    		htmltext += '<p>Dear ' + red[0].Assignee_Full_Name__c + ',</p>';
    		htmltext += '<p>Orders with SLA in Red (Target date has passed):</p>';
    		htmltext += '<table border = "1">';
    		htmltext += '<tr><td><b>Milestone</b></td><td><b>Order</b></td><td><b>Solution</b></td><td><b>Site</b></td><td><b>Order Group</b></td><td><b>Target Date</b></td></tr>';
    		
    		for (integer i = 0; i < red.Size(); ++i) {
    			
    			htmltext += '<tr><td>' + red[i].Name + '</td>';
    			htmltext += '<td><a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+red[i].Order__r.Id+'>' + red[i].Order__r.Name + '</a></td>';
    			htmltext += '<td>' + red[i].Order__r.Product_Configuration__r.Unify_Solution__c + '</td>';
    			htmltext += '<td>' + red[i].Order__r.Unify_Site__r.Name + '</td>';
    			htmltext += '<td>' + red[i].Order__r.Order_Group__r.Name + +'</td>';
    			htmltext += '<td>' + red[i].Target_Date__c + '</td></tr>';
    			
    		
    		}
    		
    		htmltext += '</table><br />';
    		
    	}
    	
    	if (!amber.isEmpty()) {
    		
    		if (red.isEmpty()) {
    			htmltext += '<p>Dear ' + amber[0].Assignee_Full_Name__c + ',</p>';
    		}
    		htmltext += '<p>Orders with SLA in Amber (Target date is about to be breached):</p>';
    		htmltext += '<table border = "1">';
    		htmltext += '<tr><td><b>Milestone</b></td><td><b>Order</b></td><td><b>Solution</b></td><td><b>Site</b></td><td><b>Order Group</b></td><td><b>Target Date</b></td></tr>';
    		
    		for (integer i = 0; i < amber.Size(); ++i) {
    			
    			htmltext += '<tr><td>' + amber[i].Name + '</td>';
    			htmltext += '<td><a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+amber[i].Order__r.Id+'>' + amber[i].Order__r.Name + '</a></td>';
    			htmltext += '<td>' + amber[i].Order__r.Product_Configuration__r.Unify_Solution__c + '</td>';
    			htmltext += '<td>' + amber[i].Order__r.Unify_Site__r.Name + '</td>';
    			htmltext += '<td>' + amber[i].Order__r.Order_Group__r.Name + +'</td>';
    			htmltext += '<td>' + amber[i].Target_Date__c + '</td></tr>';
    			
    	
    		}
    		
    		htmltext += '</table><br />';
    		
    	}
    	
    	return htmltext;
    }
    
    public static void sendEmail(Map<Id, List<SLA__c>> userSLA) {
    	
    	
    	Set <Id> users = userSLA.keySet();
    	List <Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    	OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where DisplayName = : UnifyConfiguration__c.getInstance('Daily Emails From Address').Value__c limit 1];
    	
    	for (Id u : users) {
    		
    	 	List <SLA__c> slas = userSLA.get(u);
    		
    		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    		email.setSubject('Unify Orders – SLA\'s in Amber and Red');
   		
    		string plainText = generatePlainText(u, slas);
     		email.setPlainTextBody(plainText);

      		string htmlText = generateHtml(u, slas);
      		email.setHtmlBody(htmlText);
      		
        	email.setToAddresses(new String[]{slas[0].Assignee_Email__c});
        	email.setOrgWideEmailAddressId(owea.Id);
      		emails.add(email);
    		
    	}
    		
		Messaging.sendEmail(emails);
    }
	
	global void execute(SchedulableContext SC) {

    	Map <Id, List <SLA__c>> userSLA = new Map <Id, List <SLA__c>>();
    	userSLA = getAmberRedSLAs();
    	
    	if (!userSLA.isEmpty()) {
    		sendEmail(userSLA);
    	}
    }
	 
}