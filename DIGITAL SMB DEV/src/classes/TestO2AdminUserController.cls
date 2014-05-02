@isTest(SeeAllData = true)
public class TestO2AdminUserController {

    static testMethod void testQueries() {
		Test.startTest();
		//Set the page reference to product bundle builder page
	    PageReference page = new PageReference('/apex/AdminUserServices');
	    Test.setCurrentPage(page);
	    O2AdminUsercontroller controller = new O2AdminUsercontroller();
	    //render page methods
	    List<SelectOption> lsPortalOptions = controller.getPortalOptions();
	    List<SelectOption> lsPortalProfiles = controller.getPortalProfiles();
	    System.assertNotEquals(null, lsPortalOptions);
	    System.assertNotEquals(null, lsPortalProfiles);
	    controller.selectedPortalId = lsPortalOptions[0].getValue();
	    controller.selectedProfileId = lsPortalProfiles[0].getValue();
	    controller.loadType = 'Query';
	    //create a test portal user
	    List<RecordType> recTypes = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='O2_Retail'];
	    Account portalAccount = new Account(
	    	Name='O2 Retail',
	    	RecordTypeId=recTypes[0].Id,
	    	Status__c = 'O2 Store',
	    	Business_Area__c = 'Retail'
	    );
	    insert portalAccount;
	    //List<Account> portalAccount = new List<Account>();
	    //portalAccount = [SELECT Id, Name FROM Account WHERE IsCustomerPortal = true AND IsPersonAccount=false];
	    System.assertNotEquals(null, portalAccount.Id);
	    //System.assertNotEquals(0, portalAccount.size());
	    Contact portalContact = new Contact(AccountId=portalAccount.Id, FirstName = 'test', LastName = 'tester1');
	    insert portalContact;
	    //query for the contact
	    controller.objectType = 'Contact';
	    controller.queryClause = 'Id = \''+portalContact.Id+'\'';
	    controller.queryRecords();
	    System.assertNotEquals(null, controller.contactList);
	    //create portal user from contact
	    controller.objectType = 'User';
	    User portalUser = new User(
	    	ContactId=portalContact.Id,
	    	FirstName = 'test',
	    	LastName='tester 1',
	    	profileId=controller.selectedProfileId,
	    	Email='test@test.com',
	    	Username='test@tester1.com',
	    	Alias = 'tuser1',
	    	Sales_Channel__c = 'O2 Retail',
	    	TimeZoneSidKey = 'Europe/London',
	    	LocaleSidKey = 'en_GB',
	    	EmailEncodingKey = 'ISO-8859-1',
	    	LanguageLocaleKey = 'en_US',
	    	LAN_ID__c = 'tuser1'
	    );
	    insert portalUser;
	    //query for it
	    controller.queryClause = 'Id = \''+portalUser.Id+'\'';
	    controller.standardEmail = 'test@test.com';
	    controller.standardPassword = 'password123';
	    controller.queryRecords();
	    System.assertNotEquals(null, controller.userList);
	    //update the email address
	    controller.updateUsers();
	    //reset the password
	    controller.setUserPasswords();
	    Test.stopTest();
    }

    static testMethod void testUserLoad() {
    	Test.startTest();
		//Set the page reference to product bundle builder page
	    PageReference page = new PageReference('/apex/AdminUserServices');
	    Test.setCurrentPage(page);
	    O2AdminUsercontroller controller = new O2AdminUsercontroller();
	    //render page methods
	    List<SelectOption> lsPortalOptions = controller.getPortalOptions();
	    List<SelectOption> lsPortalProfiles = controller.getPortalProfiles();
	    System.assertNotEquals(null, lsPortalOptions);
	    System.assertNotEquals(null, lsPortalProfiles);
	    controller.selectedPortalId = lsPortalOptions[0].getValue();
	    controller.selectedProfileId = lsPortalProfiles[0].getValue();
	    controller.loadType = 'Load';
		//get the portal account first
	    List<RecordType> recTypes = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='O2_Retail'];
	    Account portalAccount = new Account(
	    	Name='O2 Retail',
	    	RecordTypeId=recTypes[0].Id,
	    	Status__c = 'O2 Store',
	    	Business_Area__c = 'Retail'
	    );
	    insert portalAccount;
	    //List<Account> portalAccount = new List<Account>();
	    //portalAccount = [SELECT Id, Name FROM Account WHERE IsCustomerPortal = true AND IsPersonAccount=false];
	    System.assertNotEquals(null, portalAccount.Id);
	    //System.assertNotEquals(0, portalAccount.size());
		controller.sampleContact.AccountId = portalAccount.Id;
		//set the user settings fields
		controller.sampleUser.TimeZoneSidKey = 'Europe/London';
	    controller.sampleUser.LocaleSidKey = 'en_GB';
	    controller.sampleUser.EmailEncodingKey = 'ISO-8859-1';
	    controller.sampleUser.LanguageLocaleKey = 'en_US';
	    //create some test data to load
	    String dataToLoad = '"FIRSTNAME","LASTNAME","USERNAME","USERID","PASSWORD","EMAIL","PHONE","ALIAS"\n'+
	    	'"Test","Retail User1","test.retailuser1@o2.com.csv","testretail1","testretail1-2012","test.retailuser1@o2.com","01234567890","o2retusr1"\n' +
	    	'"Test","Retail User2","test.retailuser2@o2.com.csv","testretail2","testretail2-2012","test.retailuser2@o2.com","01234567890","o2retusr2"\n' +
	    	'"Test","Retail User3","test.retailuser3@o2.com.csv","testretail3","testretail3-2012","test.retailuser3@o2.com","01234567890","o2retusr3"\n' +
	    	'"Test","Retail User4","test.retailuser4@o2.com.csv","testretail4","testretail4-2012","test.retailuser4@o2.com","01234567890","o2retusr4"\n' +
	    	'"Test","Retail User5","test.retailuser5@o2.com.csv","testretail5","testretail5-2012","test.retailuser5@o2.com","01234567890","o2retusr5"\n' +
	    	'"Test","Retail User6","test.retailuser6@o2.com.csv","testretail6","testretail6-2012","test.retailuser6@o2.com","01234567890","o2retusr6"\n' +
	    	'"Test","Retail User7","test.retailuser7@o2.com.csv","testretail7","testretail7-2012","test.retailuser7@o2.com","01234567890","o2retusr7"\n' +
	    	'"Test","Retail User8","test.retailuser8@o2.com.csv","testretail8","testretail8-2012","test.retailuser8@o2.com","01234567890","o2retusr8"\n' +
	    	'"Test","Retail User9","test.retailuser9@o2.com.csv","testretail9","testretail9-2012","test.retailuser9@o2.com","01234567890","o2retusr9"\n' +
	    	'"Test","Retail User10","test.retailuser10@o2.com.csv","testretail10","testretail10  2012","test.retailuser10@o2.com","01234567890","o2retusr10"\n' +
	    	'"Test","Retail User11","test.retailuser11@o2.com.csv","testretail11","testretail11-2012","test.retailuser11@o2.com","01234567890","o2retusr11"\n' +
	    	'"Test","Retail User12","test.retailuser12@o2.com.csv","testretail12","testretail12-2012","test.retailuser12@o2.com","01234567890","o2retusr12"\n' +
	    	'"Test","Retail User13","test.retailuser13@o2.com.csv","testretail13","testretail13-2012","test.retailuser13@o2.com","01234567890","o2retusr13"\n' +
	    	'"Test","Retail User14","test.retailuser14@o2.com.csv","testretail14","testretail14-2012","test.retailuser14@o2.com","01234567890","o2retusr14"\n' +
	    	'"Test","Retail User15","test.retailuser15@o2.com.csv","testretail15","testretail15-2012","test.retailuser15@o2.com","01234567890","o2retusr15"\n' +
	    	'"Test","Retail User16","test.retailuser16@o2.com.csv","testretail16","testretail16-2012","test.retailuser16@o2.com","01234567890","o2retusr16"\n' +
	    	'"Test","Retail User17","test.retailuser17@o2.com.csv","testretail17","testretail17-2012","test.retailuser17@o2.com","01234567890","o2retusr17"\n' +
	    	'"Test","Retail User18","test.retailuser18@o2.com.csv","testretail18","testretail18-2012","test.retailuser18@o2.com","01234567890","o2retusr18"\n' +
	    	'"Test","Retail User19","test.retailuser19@o2.com.csv","testretail19","testretail19-2012","test.retailuser19@o2.com","01234567890","o2retusr19"\n' +
	    	'"Test","Retail User20","test.retailuser20@o2.com.csv","testretail20","testretail202012","test.retailuser20@o2.com","01234567890","o2retusr20"\n' +
	    	'"Test","Retail User21","test.retailuser21@o2.com.csv","testretail21","testretail21-2012","test.retailuser21@o2.com","01234567890","o2retusr21"\n' +
	    	'"Test","Retail User22","test.retailuser22@o2.com.csv","testretail22","testretail22-2012","test.retailuser22@o2.com","01234567890","o2retusr22"\n' +
	    	'"Test","Retail User23","test.retailuser23@o2.com.csv","testretail23","testretail23-2012","test.retailuser23@o2.com","01234567890","o2retusr23"\n' +
	    	'"Test","Retail User24","test.retailuser24@o2.com.csv","testretail24","testretail24-2012","test.retailuser24@o2.com","01234567890","o2retusr24"\n' +
	    	'"Test","Retail User25","test.retailuser25@o2.com.csv","testretail25","testretail25-2012","test.retailuser25@o2.com","01234567890","o2retusr25"';
	    Blob blobData = Blob.valueOf(dataToLoad);
	    controller.fileContents = blobData;
	    controller.fileName = 'testDataLoad.csv';
	    controller.uploadInputFile();
	    System.assertNotEquals(null, controller.fileRecords);
	    //load the records into SF
	    controller.createPortalUsers();
	    //misc calls for coverage
	    controller.convertToUsers();
	    controller.doNothing();
	    controller.resetForm();
    	Test.stopTest();
    }
}