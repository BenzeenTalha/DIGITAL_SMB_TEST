public with sharing class TestCSAManagementScreenController {

	static Id profId = [Select Id from Profile where Name='System Administrator' limit 1].id;

	public static testMethod void testCSAManagement()
	{
		User u1 = createUser('test1');
		User u2 = createUser('test2');
		u2.CSA_Available__c = false;
		insert new List<User>{u1,u2};

		Account a = new Account(Name = 'Account0', Customer_Service_Account__c = true);
		insert a;

		Group t1 = createQueue('t1');
		Group t2 = createQueue('t2');
		contextINSERT((List<sObject>) addGMs(t1.id,new List<User>{u1,u2}));

		Test.startTest();

		CSAManagementScreenController con = new CSAManagementScreenController();
		system.assert(con.getTEamOptions().size() > 0);
		con.teamId = t1.id;
		system.assertEquals(con.getCSAOptions().size(),2);
		con.showAll = true;
		con.resetShowAll();
		system.assertEquals(con.getCSAOptions().size(),3);
		con.CSAId = u1.id;

		con.accountLookup1.Enterprise_Account__c = a.id;
		con.addAccount();
		system.assert(con.bottomMessage.contains('green'));
		system.assertEquals([select count() from CSA_Account_Preference__c where Account__c = :a.id and CSA__c = :u1.id],1);
		con.accountLookup1.Enterprise_Account__c = a.id;
		con.addAccount();
		system.assert(con.bottomMessage.contains('red'));
		con.accountLookup1.Enterprise_Account__c = a.id;
		con.removeAccount();
		system.assert(con.bottomMessage.contains('green'));
		system.assertEquals([select count() from CSA_Account_Preference__c where Account__c = :a.id and CSA__c = :u1.id],0);
		con.accountLookup1.Enterprise_Account__c = a.id;
		con.removeAccount();
		system.assert(con.bottomMessage.contains('red'));

		con.accountLookup1.Enterprise_Account__c = a.id;
		con.addAccount();
		con.removeAccountPreference();
		con.getNewTeamOptions();
		con.newTeamId = u2.id;
		con.switchTeams();		// fail scenario
		con.newTeamId = t2.id;
		System.runAs(new User(Id = Userinfo.getUserId()))
		{
			con.switchTeams();
		}
		system.assertEquals([select count() from GroupMember where GroupId = :t2.id and UserOrGroupId = :u1.id],1);
		system.assertEquals([select count() from GroupMember where GroupId = :t1.id and UserOrGroupId = :u1.id],0);

		Test.stopTest();
	}

	public static User createUser(String strId)
	{
		User u = new User();
		u.Firstname ='X';
        u.Lastname ='X' + strId;
        u.Alias = 'TEST';
        u.Email = 'x.x@xy' + strId +'.com';
        u.Username = 'x.x' + strId + '@o2.dev';
        u.CommunityNickname ='x.x' + strId;
        u.ProfileId = profId;
        u.IsActive = true;
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.CSA_Available__c = true;
		return u;
	}

	public static Group createQueue(string qName)
	{
		Group q = new Group(Name = qName, Type = 'Queue');
		insert q;

		List<QueueSobject> qos = new List<QueueSobject>();
		qos.add(new QueueSobject(QueueId = q.Id, sobjectType = 'Case'));
		qos.add(new QueueSobject(QueueId = q.Id, sobjectType = 'CSA_Routing__c'));
		//insert qos;
		contextINSERT(qos);
		return q;
	}

	public static List<GroupMember> addGMs (Id groupId, List<User> users)
	{
		List<GroupMember> gms = new List<GroupMember>();
		for(User u : users) gms.add(new GroupMember(GroupId = groupId, UserOrGroupId = u.id));
		return gms;
	}

	/**
	Handles mixed dml situations in code. It runs the DML operation in different context for Test code only,
	so that conflict between DML on setup and non-setup object is gone.
 	**/
	// DML INSERT HELPER
	public static Database.Saveresult[] contextINSERT (List<sObject> objs) {
	  Database.Saveresult[] res;
	   if (Test.isRunningTest()) {
	        System.runAs(new User(Id = Userinfo.getUserId())) {
	        res = database.insert(objs);
	        }
	      } else {
	      res = database.insert(objs);
	      }
	  return res;
	}
}