public with sharing class BulkOrderLoadController {
	public Attachment attachment {get; set;}
	
	 // Constructor - for Upload Request
    public BulkOrderLoadController() {
            attachment = new Attachment();
    }
    
    public PageReference processCSVFileForBulkOrder() {
    	ApexPages.Message myMsg;
		List<List<String>> records = CSVUtils.parseCSVFile(attachment.body);
		List<Id> bulkOrderIds = CSVUtils.insertCSVRecordsIntoIntermediateObject(records);
		
		ID batchprocessid = BulkOrderBatch.startJob(bulkOrderIds); 
				
		if(batchprocessid != null)
		{		
			myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Loading CSV file ... Once the Opportunity is created, you will be notified by an email.');
		}
		else
		{
			myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error in processing csv file.');
		}
		ApexPages.addMessage(myMsg);

		return null;
		
	}
	
	static testmethod void processCSVFileForBulkOrderTest(){
		// Create an Account
	    Account newAcc = new Account(Name = 'Test Account', Type = 'Prospect');
	                           
	 	insert newAcc;
	 
	    Account testAcc = [Select Id, Name, Type from Account where Id = :newAcc.Id LIMIT 1]; 
	    System.assertEquals(newAcc.Id, testAcc.Id);   
	 
	    //create a contact
	    Contact newContact = new Contact(FirstName = 'Rob',
	                                      LastName = 'Jones',
	                                      email = 'Rob.jones@junkmail.yahoo.com.uk',
	                                      phone = '07951069913',
	                                      AccountId = newAcc.Id);
	       
	       insert newContact;        
	     
	     Contact testContact = [Select Id, Name from Contact where AccountId = :newAcc.Id LIMIT 1]; 
	     System.assertEquals(newContact.Id, testContact.Id);     
	        
	     String fieldValuesForBlob = 'O2 Account Id,Account Name,Account PostCode,O2 Billing Contact Id,Billing Contact Name,Billing Contact Email,Billing Contact Phone,Customer Type,Product Code,Customer Name,Installation Building No,Installation Building Name,Installation Street,Installation City,Installation Postcode,Provide Type,New Order Type,Line Type,Monthly Tariff,Calling & Network Features?,Care Package,Free of Charge offers ?,Installation Work Required,On Site Contact First Name,On Site Contact Last Name,On site contact phone,Termination Type,termination floor,Termination Room,Termination Location,Installation Type,EC Charge Level,TR Charge Band,HSI Notes,Site/Wayleave Notes,Directory Enq Type,Contract Term,Payment Period \n';
	     fieldValuesForBlob += newAcc.Id+ ',' +newAcc.Name+ ',NA,' +newContact.Id+ ',O2 Wifi Sales,pstn@o2wifi.net.uk,44208123456,SMB,Landline,O2,123,,NORTHUMBERLAND STREET,NEWCASTLE-UPON-TYNE,NE1 7AG,New Provide,New Line Provide,Premium Single Line,14.5,Standard - no variation,Level 2,,Yes,Rob,Lister,0191 261 0551,Line Box,1st,GEE123,store,Standard,Band 0,Band 0,Cherry Picker Required for telegraph pole,Obstruction beware,Ex Directory,12,Monthly';
	     
	     Blob CSVfile = Blob.valueof(fieldValuesForBlob);
	     
		 BulkOrderLoadController controller = new BulkOrderLoadController();
		 controller.attachment.body = CSVfile;
		 
		 controller.processCSVFileForBulkOrder();
		 
		 List<Opportunity> opp1 = [Select Id, Name from Opportunity where AccountId = :testAcc.Id];
		 
		 System.assertNotEquals(null, opp1);
		
	}

}