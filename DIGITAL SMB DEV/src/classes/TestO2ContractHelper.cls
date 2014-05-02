@isTest
public class TestO2ContractHelper {
	
	static testMethod void testContractCreation() {
		
		Account account = new Account(
			Name = 'Test'	
		);
		
		insert account;
		
		Opportunity opp = new Opportunity(
			Name = 'O365 Test opportunity',
			AccountId = account.Id,
			StageName = 'Closed/Won',
			CloseDate = Date.newInstance(2013, 1, 1),
			Close_Comment__c = 'Great work team!'
		);
		
		insert opp;
		
		cscfgc__Product_Configuration__c productConfiguration = new cscfgc__Product_Configuration__c(
			Name = 'Test Configuration'	
		);
		
		insert productConfiguration;
		
	    Order__c order = new Order__c(
				Account__c = account.Id,
				Product_Configuration__c = productConfiguration.Id
		);
		
	    insert order;
	    
	    Integer contractTerm = 12;

		cscfgc__Attribute__c attribute = new cscfgc__Attribute__c(
			Name = 'Contract Term',
			cscfgc__Value__c = String.valueOf(contractTerm),
			cscfgc__Product_Configuration__c = productConfiguration.Id
		);

		insert attribute;	    
		
		Date startDate = Date.today();
		Date endDate = startDate.addMonths(contractTerm);
		O2ContractHelper.processOrder(order);
		
		Contract__c contract = [Select Id, Start_Date__c, End_Date__c, Account__c from Contract__c where Account__c = :account.Id limit 1];
			
		System.assertNotEquals(null, contract);
		System.assertEquals(startDate, contract.Start_Date__c);
		System.assertEquals(endDate, contract.End_Date__c);
		System.assertEquals(account.Id, contract.Account__c);	
	}
	
	static testMethod void testContractCreationNoDuration() {
		
		Account account = new Account(
			Name = 'Test'	
		);
		
		insert account;
		
		Opportunity opp = new Opportunity(
			Name = 'O365 Test opportunity',
			AccountId = account.Id,
			StageName = 'Closed/Won',
			CloseDate = Date.newInstance(2013, 1, 1),
			Close_Comment__c = 'Great work team!'
		);
		
		insert opp;
		
		cscfgc__Product_Configuration__c productConfiguration = new cscfgc__Product_Configuration__c(
			Name = 'Test Configuration'	
		);
		
		insert productConfiguration;
		
	    Order__c order = new Order__c(
				Account__c = account.Id,
				Product_Configuration__c = productConfiguration.Id
		);
		
	    insert order;
	    
		Date startDate = Date.today();
		O2ContractHelper.processOrder(order);
		
		Contract__c contract = [Select Id, Start_Date__c, End_Date__c, Account__c from Contract__c where Account__c = :account.Id limit 1];
			
		System.assertNotEquals(null, contract);
		System.assertEquals(startDate, contract.Start_Date__c);
		System.assertEquals(null, contract.End_Date__c);
	}
	
	static testMethod void testContractAssetsCreation() {
		
		Account account = new Account(
			Name = 'Test'	
		);
		
		insert account;
		
		Opportunity opp = new Opportunity(
			Name = 'O365 Test opportunity',
			AccountId = account.Id,
			StageName = 'Closed/Won',
			CloseDate = Date.newInstance(2013, 1, 1),
			Close_Comment__c = 'Great work team!'
		);
		
		insert opp;
		
		String productConfigurationName = 'Test Configuration';
		
		cscfgc__Product_Configuration__c productConfiguration = new cscfgc__Product_Configuration__c(
			Name = productConfigurationName
		);
		
		insert productConfiguration;
		
		List<cscfgc__Attribute__c> attributes = new List<cscfgc__Attribute__c>();
		
		// mapping attribute
		String attributeName = 'Mapping attribute';
		String mappingValue = 'Mapping field value';
		
		attributes.add(new cscfgc__Attribute__c(
			Name = attributeName,
			cscfgc__Is_Line_Item__c = true,
			cscfgc__Value__c = mappingValue,
			cscfgc__Product_Configuration__c = productConfiguration.Id
		));

		insert attributes;
		
	    // appropriate attribute mapping
	   	Order_Conversion_Rule__c conversionRule = new Order_Conversion_Rule__c(
	    	Name = 'Mapping rule',
	    	From__c = productConfigurationName + '.' + attributeName + '.cscfgc__Value__c',
	    	To__c = 'Name',
	    	Group__c = 'test'	    		    
	    );
	    
	    insert conversionRule;
	    
		Order__c order = new Order__c(
				Account__c = account.Id,
				Product_Configuration__c = productConfiguration.Id
		);
		
	    insert order;
	    
		
		O2ContractHelper.processOrder(order);
			
		List<Customer_Asset__c> assets = [Select Id, Name, AC_Subscription__c, Status__c, Reporting_Status__c, Contract__c from Customer_Asset__c];
		System.assert(assets.size() > 0);
		
		Customer_Asset__c asset = assets.get(0);
		
		Contract__c contract = [Select Id from Contract__c where Account__c = :account.Id limit 1];
		System.assertEquals(contract.Id, asset.Contract__c);
		
		System.assertEquals(mappingValue, asset.Name);	
	}
	
	/*
	static testMethod void testPreexistingOrderGroupContractDurationUpdate() {
		
		Account account = new Account(
			Name = 'Test'	
		);
		
		insert account;
		
		Opportunity opp = new Opportunity(
			Name = 'O365 Test opportunity',
			AccountId = account.Id,
			StageName = 'Closed/Won',
			CloseDate = Date.newInstance(2013, 1, 1),
			Close_Comment__c = 'Great work team!'
		);
		
		insert opp;
		
		cscfgc__Product_Configuration__c productConfiguration1 = new cscfgc__Product_Configuration__c(
			Name = 'Test Configuration 1'
		);
		
		insert productConfiguration1;
		
		cscfgc__Product_Configuration__c productConfiguration2 = new cscfgc__Product_Configuration__c(
			Name = 'Test Configuration 2'
		);
		
		insert productConfiguration2;
		
		Order_Group__c orderGroup = new Order_Group__c(
			Opportunity__c = opp.Id
		);
		insert orderGroup;
		
		Order__c order1 = new Order__c(
			Account__c = account.Id,
			Product_Configuration__c = productConfiguration1.Id,
			Order_Group__c = orderGroup.Id
		);
		
		insert order1;
		
		Order__c order2 = new Order__c(
			Account__c = account.Id,
			Product_Configuration__c = productConfiguration2.Id,
			Order_Group__c = orderGroup.Id
		);
		
		insert order2;
		
		Integer shorterTerm = 12;
		Integer longerTerm = 24;
		
		List<cscfgc__Attribute__c> attributes = new List<cscfgc__Attribute__c>();
		
		attributes.add(new cscfgc__Attribute__c(
			Name = 'Contract Term',
			cscfgc__Value__c = String.valueOf(shorterTerm),
			cscfgc__Product_Configuration__c = productConfiguration1.Id
		));
		
		attributes.add(new cscfgc__Attribute__c(
			Name = 'Contract Term',
			cscfgc__Value__c = String.valueOf(longerTerm),
			cscfgc__Product_Configuration__c = productConfiguration2.Id
		));
		
		insert attributes;
		
	    O2ContractHelper.processOrder(order1);
	    
	    List<Contract__c> contracts = [Select Id, Order_Group__c, Start_Date__c, End_Date__c, Account__c from Contract__c where Account__c = :account.Id limit 1];
	    
	    System.assertEquals(1, contracts.size());
	    Contract__c contract = contracts.get(0);

		System.assertEquals(orderGroup.Id, contract.Order_Group__c);
		System.assertEquals(null, contract.Order__c);
	    
	    Date startDate = Date.today();
	    Date endDate = startDate.addMonths(shorterTerm);
	    System.assertEquals(endDate, contract.End_Date__c);
	    
	    // now proces the second order from the same order gruop
	    O2ContractHelper.processOrder(order2);
	    
	    List<Contract__c> updatedContracts = [Select Id, Order_Group__c, Start_Date__c, End_Date__c, Account__c from Contract__c where Account__c = :account.Id];
	    
	    // both orders belong to the same order group
	    System.assertEquals(1, updatedContracts.size());
	    Contract__c updatedContract = contracts.get(0);
	    
	    endDate = startDate.addMonths(longerTerm);
	    System.assertEquals(endDate, updatedContract.End_Date__c);

   		System.assertEquals(orderGroup.Id, updatedContract.Order_Group__c);
		System.assertEquals(null, updatedContract.Order__c);
	}
	*/
}