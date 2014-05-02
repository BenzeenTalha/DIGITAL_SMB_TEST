global class CalculateO365SalesReportDefault implements Database.Batchable<SObject>,Schedulable, Database.Stateful 
{
	public string mainsqlquery='';
		
	
	public CalculateO365SalesReportDefault()
	{
		mainsqlquery='select Id, Opportunity__c, Product__c from O2_Product_Detail__c ';
		mainsqlquery+=' where Product__c in (\'Office 365\',\'Office 365 Consultation\',\'Office 365 Professional Services\')';
	}
	 
	global Database.QueryLocator start(Database.BatchableContext BC)
	{ 
		return Database.getQueryLocator(mainsqlquery);	
	}
	
	
	global void execute(Database.BatchableContext BC, List<SObject> lstsObjectO2ProductDetail)
	{
		set<string> setOppId = new set<string>();
		
		for(SObject s : lstsObjectO2ProductDetail)
		{
			O2_Product_Detail__c tmpO2ProductDetail  = (O2_Product_Detail__c) s;
			
			setOppId.add(tmpO2ProductDetail.Opportunity__c);
		}
		
		list<Opportunity> lstOpp = [select Id, AccountId from Opportunity where Id in: setOppId];
		list<O2_Product_Detail__c> lstO2ProductDetail = [select Id, Product__c, Quantity__c, Opportunity__c from O2_Product_Detail__c
			where Opportunity__c in : setOppId];
	
		map<string,List<O2_Product_Detail__c>> mapOppIdlstO2ProductDetail = new map<string,List<O2_Product_Detail__c>>();
		
		for (O2_Product_Detail__c tmpO2ProductDetail : lstO2ProductDetail)
		{
			if (mapOppIdlstO2ProductDetail.containsKey(tmpO2ProductDetail.Opportunity__c))
			{
				List<O2_Product_Detail__c> tmplstO2ProductDetail=mapOppIdlstO2ProductDetail.get(tmpO2ProductDetail.Opportunity__c);
				tmplstO2ProductDetail.add(tmpO2ProductDetail);
			}
			else
			{
				List<O2_Product_Detail__c> tmplstO2ProductDetail=new List<O2_Product_Detail__c>();
				tmplstO2ProductDetail.add(tmpO2ProductDetail);
				mapOppIdlstO2ProductDetail.put(tmpO2ProductDetail.Opportunity__c,tmplstO2ProductDetail);
			}
		}
		
		
		list<Sales_Report_O365__c> lstSalesReport = new list<Sales_Report_O365__c>();
		
		for (Opportunity tmpOpportunity : lstOpp)
		{
			List<O2_Product_Detail__c> tmplstO2ProductDetail=mapOppIdlstO2ProductDetail.get(tmpOpportunity.Id);
			
			for (O2_Product_Detail__c tmpO2ProductDetail : tmplstO2ProductDetail)
			{
				Sales_Report_O365__c tmpSalesReport = new Sales_Report_O365__c();
				tmpSalesReport.Account__c=tmpOpportunity.AccountId;
				tmpSalesReport.Opportunity__c=tmpOpportunity.Id;
				tmpSalesReport.Opportunity_Type__c='Default';
				tmpSalesReport.Quantity__c=integer.valueOf(tmpO2ProductDetail.Quantity__c);
				tmpSalesReport.O2_Product_Detail__c=tmpO2ProductDetail.Id;
				tmpSalesReport.Display_Name__c=tmpO2ProductDetail.Product__c;
				
				lstSalesReport.add(tmpSalesReport);
			}
		}
		
		if (lstSalesReport.size()>0) insert lstSalesReport;
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
        mail.setSubject('CalculateO365SalesReportDefault - ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });		
		
	}
	
	global void execute(SchedulableContext SC)
	{
		BatchSize__c batchSize = BatchSize__c.getInstance(UserInfo.getUserId());
    	integer BatchSizeNo=50;

    	if (batchSize!=null) BatchSizeNo=integer.valueOf(batchSize.CalculateO365SalesReportDefault__c);


    	CalculateO365SalesReportDefault tmpBatch = new CalculateO365SalesReportDefault();
     	database.executebatch(tmpBatch, BatchSizeNo);				
	}
}