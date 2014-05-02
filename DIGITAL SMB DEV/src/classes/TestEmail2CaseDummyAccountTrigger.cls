@isTest
public with sharing class TestEmail2CaseDummyAccountTrigger {

    public static testMethod void testDummyAccountTrigger()
    {
        Account a = new Account(Name='Account');
        insert a;

        Contact con = new Contact(FirstName = 'Jack',
                                  LastName = 'Jones',
                                  email = 'jack.jones@testtestesttest.com.uk',
                                  phone = '07951069913',
                                  AccountId = a.Id,
                                  Customer_Service_Contact__c = true);
        insert con;

        Case c = TestCaseRouting.createCase(10);
        insert c;

        EmailMessage em = new EmailMessage(subject='test',
                                            textbody='test',
                                            toAddress=System.Label.E2C_SERVICE_INBOX.split(';').get(0),
                                            FromAddress='someone@DummyAddress2.com',
                                            parentId = c.Id);
        insert em;
        system.assertEquals([select AccountId from Case where id = :c.id].AccountId,(id) system.label.UNKNOWN_ACCOUNT);

        //check that a new emailMaessage will not change account
        c.AccountId = a.id;
        update c;
        EmailMessage em1 = new EmailMessage(subject='test1',
                                            textbody='test1',
                                            toAddress=System.Label.E2C_SERVICE_INBOX.split(';').get(0),
                                            FromAddress='someone@DummyAddress2.com',
                                            parentId = c.Id);
        insert em1;
        system.assertEquals([select AccountId from Case where id = :c.id].AccountId,a.id);
    }

    /*public static testMethod void testFoundAccountTrigger()
    {
        Account a = new Account(Name='Account');
        insert a;

        Contact con = new Contact(FirstName = 'Jack',
                                  LastName = 'Jones',
                                  email = 'jack.jones@DummyAddress2.com',
                                  phone = '07951069913',
                                  AccountId = a.Id);

        insert con;

        Case c = TestCaseRouting.createCase(10);
        c.E_mail__c = con.Email;
        insert c;

        EmailMessage em = new EmailMessage(subject='test',
                                            textbody='test',
                                            toAddress=System.Label.E2C_SERVICE_INBOX.split(';').get(0),
                                            FromAddress='jack.jones@DummyAddress2.com',
                                            parentId = c.Id);
        insert em;
        system.assertEquals([select AccountId from Case where id = :c.id].AccountId,a.id);
        system.assertEquals([select ContactId from Case where id = :c.id].ContactId,con.id);
    }*/

    public static testMethod void testFoundAccountTrigger2()
    {
        Account a = new Account(Name='Account',  email_to_case_inbox__c = System.Label.E2C_SERVICE_INBOX.split(';').get(0));
        insert a;
        
        AccountDomainMap__c domain = new AccountDomainMap__c(Account__c = a.id,Domain_Name__c='@DummyAddress2.com');
        insert domain;

        Contact con1 = new Contact(FirstName = 'Jack',
                                  LastName = 'Jones',
                                  email = 'jack.jones@DummyAddress2.com',
                                  phone = '07951069913',
                                  AccountId = a.Id,
                                  Customer_Service_Contact__c = true);
        Contact con2 = new Contact(FirstName = 'Jacky',
                                  LastName = 'Jonesy',
                                  email = 'jack.jones@DummyAddress2.com',
                                  phone = '07951069914',
                                  AccountId = a.Id,
                                  Customer_Service_Contact__c = true);
        insert new List<Contact>{con1,con2};

        Case c = TestCaseRouting.createCase(10);
        c.E_mail__c = con1.Email;
        insert c;

        EmailMessage em = new EmailMessage(subject='test',
                                            textbody='test',
                                            toAddress=System.Label.E2C_SERVICE_INBOX.split(';').get(0),
                                            FromAddress='jack.jones@DummyAddress2.com',
                                            parentId = c.Id);
        insert em;
        //system.assertEquals([select AccountId from Case where id = :c.id].AccountId,a.id);
        //system.assertEquals([select ContactId from Case where id = :c.id].ContactId,con.id);
    }

}