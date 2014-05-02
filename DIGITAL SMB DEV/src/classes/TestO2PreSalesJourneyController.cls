@isTest
public with sharing class TestO2PreSalesJourneyController {

	public static testMethod void found0Account()
	{
		Test.startTest();

		O2PreSalesJourneyController o2 = new O2PreSalesJourneyController();
		o2.selectOperation = '1';
		o2.CompName = 'My account';
		o2.PostCode = 'xyz';
		o2.searchAccount();
		o2.acc.BillingStreet = 'lalala';
		o2.acc.BillingCity = 'lolololol';
		o2.acc.BillingCountry = 'lilililili';
		o2.con.FirstName = 'test';
		o2.con.LastName = 'test';
		o2.con.Email = 'email@email.com';
		o2.con.Phone = '78787888787';
		o2.DPADetailsConf = true;
		o2.saveNew();
		o2.oppType = 'simple';
		o2.opp.Name = 'test';
		o2.beginConfig();

		Test.stopTest();
	}

	public static testMethod void found1Account()
	{
		Account a = new Account(Name='My account', BillingPostalCode='xyz');
		insert a;
		Contact c = new Contact(FirstName='Test',LastName='Testy', AccountId=a.id);
		insert c;

		Test.startTest();

		O2PreSalesJourneyController o2 = new O2PreSalesJourneyController();
		o2.selectOperation = '1';
		o2.CompName = 'My account';
		o2.PostCode = 'xyz';
		o2.searchAccount();
		o2.DPADetailsConf = true;
		o2.oppType = 'complex';
		o2.opp.Name = 'test';
		o2.beginConfig();

		Test.stopTest();
	}

	public static testMethod void found2Account()
	{
		Account a1 = new Account(Name='My account', BillingPostalCode='xyz');
		insert a1;
		Contact c1 = new Contact(FirstName='Test1',LastName='Testy1', AccountId=a1.id);
		insert c1;

		Account a2 = new Account(Name='My account', BillingPostalCode='xyz');
		insert a2;
		Contact c2 = new Contact(FirstName='Test2',LastName='Testy2', AccountId=a2.id);
		insert c2;


		Test.startTest();

		O2PreSalesJourneyController o2 = new O2PreSalesJourneyController();
		o2.selectOperation = '1';
		o2.CompName = 'My account';
		o2.PostCode = 'xyz';
		o2.searchAccount();
		o2.accId = a1.id;
		o2.accountSelected();
		o2.multipleBack();
		o2.accId = a2.id;
		o2.accountSelected();
		o2.DPADetailsConf = true;
		o2.beginConfig();

		Test.stopTest();
	}

	public static testMethod void findOrder()
	{
		Test.startTest();

		O2PreSalesJourneyController o2 = new O2PreSalesJourneyController();
		o2.selectOperation = '1';
		o2.resetValues();
		o2.selectOperation = '2';
		o2.findOrder();
		o2.ordReqNum = '123';
		o2.findOrder();

		Test.stopTest();
	}

	public static testMethod void testDISEcopy()
	{
		Test.startTest();

		O2PreSalesJourneyController o2 = new O2PreSalesJourneyController();
		o2.setDiseAccTEST();
		o2.copyDISEFields();

		Test.stopTest();
	}

}