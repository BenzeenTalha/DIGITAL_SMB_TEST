/**
 * This class contains unit tests for bulk order upload. 
 */
@isTest
private class TestBulkOrderBatch{
	static testMethod void createBulkOrderTest(){

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
     List<List<String>> records = CSVUtils.parseCSVFile(CSVfile);
     List<String> records2 = CSVUtils.parseCSVFileRecord(CSVfile);
     List<Id> bulkOrderIds = CSVUtils.insertCSVRecordsIntoIntermediateObject(records);
     List<String> sLine = CSVUtils.parseCSVLine('apple,banana,cabbage'); 
        
     Test.startTest();
    
     Id batchprocessid = BulkOrderBatch.startJob(bulkOrderIds);
     
     Test.stopTest();
         
     AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];    
     System.assertEquals(aaj.NumberOfErrors==0, true, 'Errors are thrown.');
	}
	
	static testMethod void test_getFileSize() {
		Blob myBlob1 = Blob.valueOf('test');
		Blob myBlob2 = Blob.valueOf('a,b\nc,d\ne,f');
		
		system.assertEquals(1,CSVUtils.getFileSize(myBlob1));
		system.assertEquals(3,CSVUtils.getFileSize(myBlob2));		
	}
	
	static testMethod void testConstructor() {
		BulkOrderBatch bob = new BulkOrderBatch();
	}

}