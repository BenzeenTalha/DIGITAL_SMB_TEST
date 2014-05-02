global class DeleteOffice365SalesReport implements Database.Batchable<SObject>,Schedulable, Database.Stateful  
{
	public string mainsqlquery='';
	
	public DeleteOffice365SalesReport()
	{
		mainsqlquery='select Id from Sales_Report_O365__c';
	}
	
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		system.debug('****mainsqlquery=' + mainsqlquery);
		
		return Database.getQueryLocator(mainsqlquery);	
		

	}
	
	global void execute(Database.BatchableContext BC, List<SObject> lstSalesReport)
	{
		list<Sales_Report_O365__c> lstSalesReportDelete = new list<Sales_Report_O365__c>(); 
		
		for(SObject s : lstSalesReport)
		{
			Sales_Report_O365__c tmpSalesReport  = (Sales_Report_O365__c) s;
			lstSalesReportDelete.add(tmpSalesReport);
		}

		system.debug('****lstSalesReportDelete=' + lstSalesReportDelete);

		delete lstSalesReportDelete;
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =
        :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {a.CreatedBy.Email};
        //String[] toAddresses = new String[]{};
        //toAddresses.add('davor.dubokovic@cloudsensesolutions.com');

        List<String> toAddresses = new List<String>();
        BatchSize__c BatchSize = BatchSize__c.getInstance(UserInfo.getUserId());

        if (BatchSize==null)
        {
        	toAddresses.add('davor.dubokovic@cloudsense.com');
        }
        else
        {
        	if (BatchSize.Admin_emails__c=='' || BatchSize.Admin_emails__c==null)
        	{
        		toAddresses.add('davor.dubokovic@cloudsense.com');
        	}
        	else
        	{
        		toAddresses = BatchSize.Admin_emails__c.split(',');
        	}
        }


        mail.setToAddresses(toAddresses);
        mail.setSubject('DeleteOffice365SalesReport - ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });		
        
    }
	
	global void execute(SchedulableContext SC)
	{
		
		BatchSize__c batchSize = BatchSize__c.getInstance(UserInfo.getUserId());
    	integer BatchSizeNo=50;

    	if (batchSize!=null) BatchSizeNo=integer.valueOf(batchSize.DeleteOffice365SalesReport__c);


    	DeleteOffice365SalesReport tmpBatch = new DeleteOffice365SalesReport();
     	database.executebatch(tmpBatch, BatchSizeNo);
     		
	}	
}