global without sharing class DailyBillingTeamNotification implements Schedulable {

	public static String CRON_EXP = '0 0 8 ? * MON-FRI *'; //every week day

	global static String scheduleMe() {

      	DailyBillingTeamNotification schedule = new DailyBillingTeamNotification();
      	return System.schedule('Daily Billing Team Notification', CRON_EXP, schedule);

    }

    public static  Map<Id,List<Unify_Site__c>> getSites () {

    	Map<Id,List<Unify_Site__c>> ogSites = new Map<Id,List<Unify_Site__c>>();

    	List <Order_Group__c> ogs = [select Id,Name,(select Id,Billing_Team_Notified__c,Name,Full_Address__c,Solution__c,Order_Group__r.Name from Sites__r where Ready_for_Billing__c = true and Billing_Team_Notified__c = false) from Order_Group__c where Status__c != 'Completed' and Status__c != 'Cancelled' and RecordType.Name = 'Unify' ];
    	boolean empty = true;
		List <Unify_Site__c> sites = new List <Unify_Site__c>();
		
    	for (integer i = 0; i < ogs.size(); ++i) {
    		Order_Group__c og = ogs[i];
			for(List<Unify_Site__c> s : og.Sites__r) {
				if (!s.isEmpty()) {
					ogSites.put(og.Id, s);
					sites.addAll(s);
				}
				else {
					ogs.remove(i);
					--i;
				}
			}
		}
		
		if (!sites.isEmpty()) {
			for (integer i = 0; i < sites.size(); ++i) 
				sites[i].Billing_Team_Notified__c = true;
			update sites;
		}

    	return ogSites;
    }

    public static string generatePlainText (Id og, List <Unify_Site__c> sites) {

    	string plaintext = '';

    	plaintext += 'Dear Billing Team';
    	plaintext += 'The following site(s), related to '+ sites[0].Order_Group__r.Name + ' are now ready for billing.\n\n';

    	for (integer i = 0; i < sites.size(); ++i) {

    		plaintext += sites[i].Name + '\t';
    		plaintext += sites[i].Full_Address__c + '\t';
    		plaintext += sites[i].Solution__c + '\n';
    	}


    	return plaintext;

    }

    public static string generateHtml (Id og, List <Unify_Site__c> sites) {

    	string htmltext = '<!DOCTYPE html><html><body style="font-family:Arial;">';

    	htmltext += '<p>Dear Billing Team</p>';
    	htmltext += '<p>The following site(s), related to <a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+og+'>' + sites[0].Order_Group__r.Name + '</a> are now ready for billing.</p>';
    	htmltext += '<table border="1" cellspacing="0" cellpadding="3" bordercolor="black" style="border-color:black; border-collapse:collapse;font-family:Arial;">';
    	htmltext += '<tr><td><b>Site</b></td><td><b>Full Address</b></td><td><b>Solution</b></td></tr>';

    	for (integer i = 0; i < sites.size(); ++i) {

    		htmltext += '<tr><td><a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+sites[i].Id+'>' + sites[i].Name  + '</a></td>';
    		htmltext += '<td>' + sites[i].Full_Address__c + '</td>';
    		htmltext += '<td>' + sites[i].Solution__c + '</td></tr>';

    	}

    	htmltext += '</table></body></html>';

    	return htmltext;
    }

    public static void sendEmail (Map<Id, List<Unify_Site__c>> ogSites) {

    	Set <Id> ogs = ogSites.keySet();
    	List <Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    	OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where DisplayName = : UnifyConfiguration__c.getInstance('Daily Emails From Address').Value__c limit 1];
    	string toAddress = UnifyConfiguration__c.getInstance('Fixed DISE Billing').Value__c ;

    	for (Id og : ogs) {

    	 	List <Unify_Site__c> sites = ogSites.get(og);

    		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    		email.setSubject('Unify Order Group – Ready for Billing Sites');

    		string plainText = generatePlainText(og, sites);
     		email.setPlainTextBody(plainText);

      		string htmlText = generateHtml(og, sites);
      		email.setHtmlBody(htmlText);

        	email.setToAddresses(new String[] { toAddress });
        	email.setOrgWideEmailAddressId(owea.Id);
      		emails.add(email);

    	}

		Messaging.sendEmail(emails);
    }


	global void execute(SchedulableContext SC) {

    	Map <Id, List<Unify_Site__c>> ogSites = new Map <Id, List<Unify_Site__c>>();
    	ogSites = getSites();

    	if (!ogSites.isEmpty()) {
    		sendEmail(ogSites);
    	}

    	sendRedAmberSiteSlas();
    }

    /**
     * Sends email notification to the Billing Team with all Site SLAs in Red and Amber
     * @author - Ivan Tadic (Cloudsense)
     * @since - 13/01/2014
     */
    public static void sendRedAmberSiteSlas(){
    	//Get all Sites with RAG Red/Amber
    	List<Unify_Site__c> allSites = [SELECT
    										Id, Name, Solution__c, Order_Group__c, Order_Group__r.Name, Added_to_Billing_System_Target_Date__c,
    										Added_to_Billing_System_RAG_Status__c
    									FROM
    										Unify_Site__c
    									WHERE
    										Added_to_Billing_System_RAG_Status__c IN ('Red', 'Amber')];
    	if(allSites.size() == 0)
   			return;
    	List<Unify_Site__c> redSites = new List<Unify_Site__c>();
    	List<Unify_Site__c> amberSites = new List<Unify_Site__c>();
    	for(Unify_Site__c site : allSites){
    		if(site.Added_to_Billing_System_RAG_Status__c == 'Red')
    			redSites.add(site);
    		if(site.Added_to_Billing_System_RAG_Status__c == 'Amber')
    			amberSites.add(site);
    	}

    	//Build email HTML
    	string body = '';
	 	body += '<!DOCTYPE html>';
	 	body += '<html>';
	 	body += '	<body style="font-family:Arial;">';
	 	body += '		Dear Billing team,<br/><br/>';
	 	if(redSites.size() > 0){
	 		body += '	Sites with SLA in Red (Target date has passed):<br/><br/>';
 			body += '		<table border="1" cellspacing="0" cellpadding="3" bordercolor="black" style="border-color:black; border-collapse:collapse;font-family:Arial;">';
			body += '			<tr>';
			body += '				<th>Milestone</th>';
			body += '				<th>Site</th>';
			body += '				<th>Solution</th>';
			body += '				<th>Order Group</th>';
			body += '				<th>Target Date</th>';
			body += '			</tr>';
			for(Unify_Site__c site : redSites){
				body += '		<tr>';
				body += '			<td>Added to Billing System</td>';
				body += '			<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + site.Id + '">' + site.Name + '</a></td>';
				body += '			<td>' + site.Solution__c + '</td>';
				body += '			<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + site.Order_Group__c + '">' + site.Order_Group__r.Name + '</a></td>';
				body += '			<td>' + site.Added_to_Billing_System_Target_Date__c.format('dd/MM/yyyy HH:mm') + '</td>';
				body += '		</tr>';
			}
			body += '		</table><br/><br/>';
	 	}
	 	if(amberSites.size() > 0){
	 		body += '	Sites with SLA in Amber (Target date is about to be breached):<br/>';
 			body += '		<table border="1" cellspacing="0" cellpadding="3" bordercolor="black" style="border-color:black; border-collapse:collapse;font-family:Arial;">';
			body += '			<tr>';
			body += '				<th>Milestone</th>';
			body += '				<th>Site</th>';
			body += '				<th>Solution</th>';
			body += '				<th>Order Group</th>';
			body += '				<th>Target Date</th>';
			body += '			</tr>';
			for(Unify_Site__c site : amberSites){
				body += '		<tr>';
				body += '			<td>Added to Billing System</td>';
				body += '			<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + site.Id + '">' + site.Name + '</a></td>';
				body += '			<td>' + site.Solution__c + '</td>';
				body += '			<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + site.Order_Group__c + '">' + site.Order_Group__r.Name + '</a></td>';
				body += '			<td>' + site.Added_to_Billing_System_Target_Date__c.format('dd/MM/yyyy HH:mm') + '</td>';
				body += '		</tr>';
			}
			body += '		</table><br/><br/>';
	 	}
	 	body += '	</body>';
	 	body += '</html>';

	 	//Send email
	 	OrgWideEmailAddress owea = [SELECT
	 									Id
	 								FROM
	 									OrgWideEmailAddress
	 								WHERE
	 									DisplayName = : UnifyConfiguration__c.getInstance('Daily Emails From Address').Value__c
	 								LIMIT 1];
    	string toAddress = UnifyConfiguration__c.getInstance('Fixed DISE Billing').Value__c ;
		Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
		string subject = 'Unify Sites – SLA\'s in Amber and Red';
		mailMessage.setSubject(subject);
		mailMessage.setOrgWideEmailAddressId(owea.Id);
		String[] toAddresses = new String[] {toAddress};
		mailMessage.setToAddresses(toAddresses);
		mailMessage.setHtmlBody(body);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailMessage });
    }
}