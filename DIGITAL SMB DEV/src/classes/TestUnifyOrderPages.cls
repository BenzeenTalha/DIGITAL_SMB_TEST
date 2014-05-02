@isTest
private class TestUnifyOrderPages {

	private static List<Order__c> CreateOrders(integer numOfOrders){

		//Insert Opportunity
		Opportunity opp = TestUnifyHelper.createOpportunity();

		//Insert Order Group
		Order_Group__c og = new Order_Group__c(Name = 'Test Order Group', Opportunity__c = opp.Id);
		insert og;

		//Insert Orders
		List<Order__c> orders = new List<Order__c>();
		for(integer i = 0; i < numOfOrders; i++) {
			Order__c o = new Order__c(Name = 'Test Order ' + i,
									  RecordTypeId = Cache.RecordTypeId('Order__c.Unify'),
									  Account__c = opp.AccountId,
									  Opportunity__c = opp.Id,
									  Order_Group__c = og.Id);
			orders.add(o);
		}
		insert orders;

		//Insert SLA's
		List<SLA__c> slas = new List<SLA__c>();
		for(integer i = 0; i < 3; i++){
			for(Order__c o : orders){
				SLA__c sla = new SLA__c(Name = 'SLA' + i,
										Order__c = o.Id);
				slas.add(sla);
			}
		}
		insert slas;
		return orders;
	}

	private static User CreateUser(string Username, boolean withRole, boolean isSysAdmin){
		string profileName = isSysAdmin ? 'System Administrator' : '%Unify%';
		Profile p = [SELECT Id FROM Profile WHERE Name LIKE :profileName LIMIT 1];
        User u = new User();
        u.email = username;
        u.username = username;
        u.firstname = 'Test';
        u.lastname = 'User';
        u.alias = 'Test';
        u.languagelocalekey='en_US';
        u.emailencodingkey='UTF-8';
        u.localesidkey='en_GB';
        u.timezonesidkey='Europe/London';
        u.ProfileId = p.Id;
        if(withRole){
        	UserRole unifyRole = [SELECT Id FROM UserRole WHERE Name = 'System Admin' LIMIT 1];
        	u.UserRoleId = unifyRole.Id;
        }
        insert u;
        return u;
	}

	static testMethod void testUnifyOrderEdit() {
		TestUnifyHelper.setupCustomSettings();
        Order__c o = CreateOrders(1)[0];

        test.startTest();

        UnifyOrderEditExtension ctrl = new UnifyOrderEditExtension(new ApexPages.StandardController(o));

        //Cancel
        ctrl.Cancel();

        //Save
        ctrl.Save();
    }

    static testMethod void testUnifyOrderRessign1() {
    	User u1 = CreateUser('unifytestuser1@unify.com',false,false);
    	User u2 = CreateUser('unifytestuser2@unify.com',false,false);
    	List<Order__c> orders = CreateOrders(2);
    	orders[0].Assignee__c = u1.Id;
    	orders[1].Assignee__c = u1.Id;
    	update orders;

    	test.startTest();
    	UnifyOrdersReassignController ctrl = new UnifyOrdersReassignController(new ApexPages.StandardController(orders[0]));

    	//No users
    	ctrl.o1 = new Order__c();
    	ctrl.o2 = new Order__c();
    	ctrl.ShowOrders();
    	ctrl.Reassign();
    	Order__c oTest = [SELECT Id, Assignee__c FROM Order__c WHERE Id = :orders[0].Id];
    	System.assertEquals(oTest.Assignee__c, u1.Id);

    	//Same user
    	ctrl.o1.Assignee__c = u1.Id;
    	ctrl.o2.Assignee__c = u1.Id;
    	ctrl.ShowOrders();
    	ctrl.allOrders[0].IsSelected = true;
    	ctrl.Reassign();
    	oTest = [SELECT Id, Assignee__c FROM Order__c WHERE Id = :orders[0].Id];
    	System.assertEquals(oTest.Assignee__c, u1.Id);

    	//Different users, no role
    	ctrl.o1.Assignee__c = u1.Id;
    	ctrl.o2.Assignee__c = u2.Id;
    	ctrl.ShowOrders();
    	ctrl.allOrders[0].IsSelected = true;
    	ctrl.Reassign();
    	oTest = [SELECT Id, Assignee__c FROM Order__c WHERE Id = :orders[0].Id];
    	System.assertEquals(oTest.Assignee__c, u1.Id);

    	//Sort
  		ctrl.o1.Assignee__c = u2.Id;
  		ctrl.ShowOrders();
  		ctrl.sortKey = 'Order';
  		ctrl.SortOrders();
    }

    static testMethod void testUnifyOrderRessign2() {
    	User sysAdmin = CreateUser('unifytestuseradmin@unify.com',true,true);
    	User u1 = CreateUser('unifytestuser1@unify.com',true,false);
    	User u2 = CreateUser('unifytestuser2@unify.com',true,false);

		System.runAs(sysAdmin){
	    	test.startTest();
	    	List<Order__c> orders = CreateOrders(2);
	    	orders[0].Assignee__c = u1.Id;
	    	orders[1].Assignee__c = u1.Id;
	    	update orders;

	    	UnifyOrdersReassignController ctrl = new UnifyOrdersReassignController(new ApexPages.StandardController(orders[0]));

	    	//No users
	    	ctrl.o1 = new Order__c();
	    	ctrl.o2 = new Order__c();
	    	ctrl.ShowOrders();
	    	ctrl.Reassign();
	    	Order__c oTest = [SELECT Id, Assignee__c FROM Order__c WHERE Id = :orders[0].Id];
	    	System.assertEquals(oTest.Assignee__c, u1.Id);

	    	//Same user
	    	ctrl.o1.Assignee__c = u1.Id;
	    	ctrl.o2.Assignee__c = u1.Id;
	    	ctrl.ShowOrders();
	    	ctrl.allOrders[0].IsSelected = true;
	    	ctrl.Reassign();
	    	oTest = [SELECT Id, Assignee__c FROM Order__c WHERE Id = :orders[0].Id];
	    	System.assertEquals(oTest.Assignee__c, u1.Id);

	    	//Different users with roles
	    	ctrl.o1.Assignee__c = u1.Id;
	    	ctrl.o2.Assignee__c = u2.Id;
	    	ctrl.ShowOrders();
	    	ctrl.allOrders[0].IsSelected = true;
	    	ctrl.Reassign();
	    	oTest = [SELECT Id, Assignee__c FROM Order__c WHERE Id = :orders[0].Id];
	    	System.assertEquals(oTest.Assignee__c, u2.Id);

	  		//Sort
	  		ctrl.o1.Assignee__c = u2.Id;
	  		ctrl.ShowOrders();
	  		ctrl.sortKey = 'Order';
	  		ctrl.SortOrders();
	  		ctrl.SortOrders();
		}
    }


}