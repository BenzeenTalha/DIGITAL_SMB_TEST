@isTest
public with sharing class TestCaseRouting {

    static Id profId = [Select Id from Profile where Name='System Administrator' limit 1].id;
    static Id defaultQueueId;

    static testMethod void testNegativeCases()  // test cases that the code should not route
    {
        User u0 = createUser('ABCD');   // random user
        User u1 = createUser('EFGH');
        User u2 = createUser('IJKL');
        insert new List<User>{u0,u1,u2};

        Group qa = createQueue('RoutingQueue', new List<String>{'Case','CSA_Routing__c'});
        Group qx = createQueue('NoRoutingQueue', new List<String>{'Case'});

        //insert addGms(qa.id, new List<User>{u1});
        //insert addGms(qx.id, new List<User>{u2});
        List<GroupMember> newGroupMembers = new List<GroupMember>();
        newGroupMembers.addAll(addGms(qa.id, new List<User>{u1}));
        newGroupMembers.addAll(addGms(qx.id, new List<User>{u2}));
        contextINSERT(newGroupMembers);

        Account a0 = new Account(Name = 'Account0', CSA_Preference__c = u0.id);
        insert a0;

        Case c1 = createCase(10);       // owned by single user
        c1.OwnerId__c= u0.id;
        c1.AccountID = a0.id;
        Case c2 = createCase(10);       // no owner
        c2.AccountID = a0.id;
        Case c3 = createCase(10);       // no service_request_type__c
        c3.AccountID = a0.id;
        c3.Service_Request_Type__c = null;
        c3.Request_Sub_Type__c = null;
        c3.OwnerId__c = qa.id;
        
        
        Case c4 = createCase(10);       // status not 'New', 20121128 will be routed
        c4.OwnerId__c = qa.id;
        c4.Status = 'Open';
        c4.AccountID = a0.id;
        Case c5 = createCase(10);       // assigned to queue that doesn't support individual routing
        c5.OwnerId__c = qx.id;
        c5.AccountID = a0.id;
        List<Case> cases = new List<Case>{c1,c2,c3,c4,c5};      // change on list elements reflected on original cases

        Test.startTest();

        CaseRouting.routeCases(cases);

        Test.stopTest();

        // no case should have the original owner changed
        System.assertEquals(cases.get(0).OwnerId__c,u0.id);
        System.assertEquals(cases.get(1).OwnerId__c,null);
        System.assertEquals(cases.get(2).OwnerId__c,qa.id);
        System.assertEquals(cases.get(3).OwnerId__c,u1.id);    // gets routed according to new routing criteria
        System.assertEquals(cases.get(4).OwnerId__c,qx.id);
    }

    static testMethod void testPositiveCaseBatch()  // test various cases that will be routed in a batch of 20
    {
        try // in case somebody forgot to set it up
        {
            defaultQueueId = System.Label.CSA_Default_Queue_Id;
        }
        catch(exception e)
        {
            defaultQueueId = null;
        }

        // START DATA SETUP
        List<sObject> results;

        results = setupRoutingExample();

        User u0 = (User) results.get(0);
        User u1 = (User) results.get(1);
        User u2 = (User) results.get(2);
        User u3 = (User) results.get(3);
        User u4 = (User) results.get(4);
        User u5 = (User) results.get(5);

        Group team0 = (Group) results.get(6);
        Group team1 = (Group) results.get(7);
        Group team2 = (Group) results.get(8);

        List<Case> cases = new List<Case>();
        for(Integer i = 9; i < 29; i++) cases.add((Case) results.get(i));

        system.assertEquals(cases.size(),20);   // assert batch size

        // I will manipulate case weighting because the way that's calculated keeps changing
        cases.get(0).CSA_Weighting__c = 10;
        cases.get(1).CSA_Weighting__c = 45;
        cases.get(2).CSA_Weighting__c = 50;
        cases.get(3).CSA_Weighting__c = 10;
        cases.get(4).CSA_Weighting__c = 25;
        cases.get(5).CSA_Weighting__c = 5;
        cases.get(6).CSA_Weighting__c = 25;
        cases.get(7).CSA_Weighting__c = 5;
        cases.get(8).CSA_Weighting__c = 10;
        cases.get(9).CSA_Weighting__c = 99;
        cases.get(10).CSA_Weighting__c = 99;
        cases.get(11).CSA_Weighting__c = 99;
        cases.get(12).CSA_Weighting__c = 99;
        cases.get(13).CSA_Weighting__c = 10;
        cases.get(14).CSA_Weighting__c = 10;
        cases.get(15).CSA_Weighting__c = 10;
        cases.get(16).CSA_Weighting__c = 10;
        cases.get(17).CSA_Weighting__c = 10;
        cases.get(18).CSA_Weighting__c = 10;
        cases.get(19).CSA_Weighting__c = 10;

        // END DATA SETUP

        Test.startTest();

        CaseRouting.routeCases(cases);

        Test.stopTest();

        //check owners
        //System.assertEquals(cases.get(0).OwnerId__c,u3.id);                                // based on workload
        System.assertEquals(cases.get(1).OwnerId__c,u3.id);                                // based on workload
        System.assertEquals(cases.get(2).OwnerId__c,u2.id);                                // based on workload
        System.assertEquals(cases.get(3).OwnerId__c,u1.id);                                // based on workload
        System.assertEquals(cases.get(4).OwnerId__c,u3.id);                                // based on workload
        System.assertEquals(cases.get(5).OwnerId__c,u1.id);                                // based on workload
        System.assertEquals(cases.get(6).OwnerId__c,u1.id);                                // based on workload
        System.assertEquals(cases.get(7).OwnerId__c,u2.id);                                // based on workload
        System.assertEquals(cases.get(8).OwnerId__c,u2.id);                                // based on workload
        System.assertEquals(cases.get(9).OwnerId__c,u3.id);                                // based on workload
        System.assertEquals(cases.get(10).OwnerId__c,u4.id);                               // based on preference
        System.assertEquals(cases.get(11).OwnerId__c,u5.id);                               // based on preference
        System.assertEquals(cases.get(12).OwnerId__c,u4.id);                               // based on preference
        System.assertEquals(cases.get(13).OwnerId__c,u5.id);                               // based on preference
        System.assertEquals(cases.get(14).OwnerId__c,defaultQueueId);                      // empty team - defualt queue
        System.assertEquals(cases.get(15).OwnerId__c,defaultQueueId);                      // empty team - defualt queue
        System.assertEquals(cases.get(16).OwnerId__c,defaultQueueId);                      // empty team - defualt queue
        System.assertEquals(cases.get(17).OwnerId__c,defaultQueueId);                      // empty team - defualt queue
        System.assertEquals(cases.get(18).OwnerId__c,defaultQueueId);                      // empty team - defualt queue
        System.assertEquals(cases.get(19).OwnerId__c,defaultQueueId);                      // empty team - defualt queue
    }

    static testMethod void preferedCSAUnavailable()
    {
        User u0 = createUser('ABCD');   // unavailable user
        u0.CSA_Available__c = false;
        User u1 = createUser('EFGH');
        insert new List<User>{u0,u1};

        Group team1 = createQueue('Team1', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team1.id, new List<User>{u0,u1}));

        Account a0 = new Account(Name = 'Account0');
        insert a0;
        insert new CSA_Account_Preference__c(Account__c = a0.id, CSA__c = u0.id);
        Case c = createCase(10);
        c.AccountId = a0.id;
        c.OwnerId__c = team1.id;

        Test.startTest();

        CaseRouting.routeCases(new List<Case>{c});

        Test.stopTest();

        System.assertEquals(c.OwnerId__c,u1.id);
    }

    static testMethod void allCSAHaveCases()
    {
        User u1 = createUser('ABCD');
        User u2 = createUser('EFGH');
        User u3 = createUser('IJKL');
        insert new List<User>{u1,u2,u3};

        Group team1 = createQueue('Team1', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team1.id, new List<User>{u1,u2,u3}));

        Case c011 = createCase(30);
        c011.OwnerId = u1.id;
        Case c012 = createCase(30);
        c012.OwnerId = u1.id;
        Case c013 = createCase(30);
        c013.OwnerId = u1.id;
        Case c021 = createCase(20);
        c021.OwnerId = u2.id;
        Case c022 = createCase(20);
        c022.OwnerId = u2.id;
        Case c031 = createCase(10);
        c031.OwnerId = u3.id;
        insert new List<Case>{c011,c012,c013,c021,c022,c031};   // case workload here is achieved by the number of cases for each user

        // check that owner has not been changed by existing case trigger, otherwise test won't work
        System.assertEquals(c011.OwnerId,u1.id);
        System.assertEquals(c021.OwnerId,u2.id);
        System.assertEquals(c031.OwnerId,u3.id);

        List<Case> cases = new List<Case>();
        for(Integer i = 0; i < 3; i++)
        {
            Case c = createCase(99);
            c.OwnerId__c = team1.id;
            cases.add(c);
        }

        Test.startTest();

        CaseRouting.routeCases(cases);

        Test.stopTest();

        System.assertEquals(cases.get(0).OwnerId__c,u3.id);
        System.assertEquals(cases.get(1).OwnerId__c,u2.id);
        System.assertEquals(cases.get(2).OwnerId__c,u1.id);
    }

    static testMethod void allCSADontHaveCases()
    {
        User u1 = createUser('ABCD');
        User u2 = createUser('EFGH');
        User u3 = createUser('IJKL');
        insert new List<User>{u1,u2,u3};

        Group team1 = createQueue('Team1', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team1.id, new List<User>{u1,u2,u3}));

        List<Case> cases = new List<Case>();
        for(Integer i = 0; i < 3; i++)
        {
            Case c = createCase(99);
            c.OwnerId__c = team1.id;
            cases.add(c);
        }

        Test.startTest();

        CaseRouting.routeCases(cases);

        Test.stopTest();

        Set<Id> owners = new Set<Id>{u1.id,u2.id,u3.id};
        // we cannot guarantee the order in which cases were assigned in this test case, just that they WERE assigned
        System.assert(owners.contains(cases.get(0).OwnerId__c));
        System.assert(owners.contains(cases.get(1).OwnerId__c));
        System.assert(owners.contains(cases.get(2).OwnerId__c));
    }

    static testMethod void noAvailableCSAs()
    {
        try // in case somebody forgot to set it up
        {
            defaultQueueId = System.Label.CSA_Default_Queue_Id;
        }
        catch(exception e)
        {
            defaultQueueId = null;
        }

        User u0 = createUser('ABCD');   // unavailable user
        u0.CSA_Available__c = false;
        insert u0;

        Group team0 = createQueue('Team0', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team0.id, new List<User>{u0}));

        Case c = createCase(10);
        c.OwnerId__c = team0.id;

        Test.startTest();

        CaseRouting.routeCases(new List<Case>{c});

        Test.stopTest();

        System.assertEquals(c.OwnerId__c,defaultQueueId);
    }

    static testMethod void noMembers()
    {
        try // in case somebody forgot to set it up
        {
            defaultQueueId = System.Label.CSA_Default_Queue_Id;
        }
        catch(exception e)
        {
            defaultQueueId = null;
        }

        Group team0 = createQueue('Team0', new List<String>{'Case','CSA_Routing__c'});
        Case c = createCase(10);
        c.OwnerId__c = team0.id;
        

        Test.startTest();

        CaseRouting.routeCases(new List<Case>{c});

        Test.stopTest();

        System.assertEquals(c.OwnerId__c,defaultQueueId);
    }

    static testMethod void noAvailableMembers()
    {
        try // in case somebody forgot to set it up
        {
            defaultQueueId = System.Label.CSA_Default_Queue_Id;
        }
        catch(exception e)
        {
            defaultQueueId = null;
        }

        User u0 = createUser('XXXX');
        User u1 = createUser('ABCD');
        u1.CSA_Available__c = false;
        User u2 = createUser('EFGH');
        u2.CSA_Available__c = false;
        User u3 = createUser('IJKL');
        u3.CSA_Available__c = false;
        insert new List<User>{u0,u1,u2,u3};

        Group team1 = createQueue('Team1', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team1.id, new List<User>{u1,u2,u3}));

        Group team0 = createQueue('Team0', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team0.id, new List<User>{u0}));

        Case c = createCase(10);
        c.OwnerId__c = team1.id;

        Test.startTest();

        CaseRouting.routeCases(new List<Case>{c});

        Test.stopTest();

        System.assertEquals(c.OwnerId__c,defaultQueueId);
    }

    static testMethod void testPrefference()
    {
        try // in case somebody forgot to set it up
        {
            defaultQueueId = System.Label.CSA_Default_Queue_Id;
        }
        catch(exception e)
        {
            defaultQueueId = null;
        }

        User u1 = createUser('ABCD');
        User u2 = createUser('EFGH');
        User u3 = createUser('IJKL');
        insert new List<User>{u1,u2,u3};

        Account a1 = new Account(Name = 'Account1');
        insert a1;
        insert new CSA_Account_Preference__c(Account__c = a1.id, CSA__c = u1.id);
        insert new CSA_Account_Preference__c(Account__c = a1.id, CSA__c = u2.id);

        Group team1 = createQueue('Team1', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team1.id, new List<User>{u1,u2,u3}));

        Case c011 = createCase(20);
        c011.OwnerId = u1.id;
        c011.Number_of_Activities__c = 20;  // weight is multiplied by Number_Of_Activities__c
        Case c012 = createCase(30);
        c012.OwnerId = u2.id;
        c012.Number_of_Activities__c = 30;  // weight is multiplied by Number_Of_Activities__c
        insert new List<Case>{c011,c012};

        Case c1 = createCase(20);
        c1.OwnerId__c = team1.id;
        c1.AccountId = a1.Id;
        Case c2 = createCase(20);
        c2.OwnerId__c = team1.id;
        c2.AccountId = a1.Id;
        Case c3 = createCase(20);
        c3.OwnerId__c = team1.id;
        c3.AccountId = a1.Id;
        Case c4 = createCase(20);
        c4.OwnerId__c = team1.id;
        c4.AccountId = a1.Id;

        Test.startTest();

        CaseRouting.routeCases(new List<Case>{c1,c2,c3,c4});

        Test.stopTest();

        System.assertEquals(c1.OwnerId__c,u1.id);
        System.assertEquals(c2.OwnerId__c,u2.id);
        System.assertEquals(c3.OwnerId__c,u1.id);
        System.assertEquals(c4.OwnerId__c,u2.id);
    }

    static testMethod void stressTest()
    {
        try // in case somebody forgot to set it up
        {
            defaultQueueId = System.Label.CSA_Default_Queue_Id;
        }
        catch(exception e)
        {
            defaultQueueId = null;
        }

        List<User> users1 = new List<User>();
        List<User> users2 = new List<User>();
        List<User> users3 = new List<User>();
        for(Integer i=0; i<20; i++)
        {
            if(i<5) users1.add(createUser('STRSSTST' + i.format()));
            else
            {
                if(i>13) users3.add(createUser('STRSSTST' + i.format()));
                else users2.add(createUser('STRSSTST' + i.format()));
            }
        }

        insert users1;
        insert users2;
        insert users3;

        Account a1 = new Account(Name = 'Account1');
        Account a2 = new Account(Name = 'Account2');
        Account a3 = new Account(Name = 'Account3');
        insert new List<Account>{a1,a2,a3};

        Group team1 = createQueue('Team1', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team1.id, users1));
        Group team2 = createQueue('Team2', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team2.id, users2));
        Group team3 = createQueue('Team3', new List<String>{'Case','CSA_Routing__c'});
        contextINSERT(addGms(team3.id, users3));

        List<Case> cases = new List<Case>();
        for(Integer i=0; i<200; i++)
        {
            Case c = createCase(10);
            Integer r = Math.floor(Math.random()*3).intValue();
            if(r == 0) { c.AccountId = a1.Id; c.OwnerId = team1.id; }
            if(r == 1) { c.AccountId = a2.Id; c.OwnerId = team2.id; }
            if(r >= 2) { c.AccountId = a3.Id; c.OwnerId = team3.id; }
        }

        Test.startTest();

        CaseRouting.routeCases(cases);

        Test.stopTest();

        Set<Id> us1 = new Set<Id>(); us1.addAll((new Map<Id,User>(users1)).keySet());
        Set<Id> us2 = new Set<Id>(); us2.addAll((new Map<Id,User>(users2)).keySet());
        Set<Id> us3 = new Set<Id>(); us3.addAll((new Map<Id,User>(users3)).keySet());

        for(Case c : cases)
        {
            if(c.AccountId == a1.Id) System.assert(us1.contains(c.OwnerId));
            if(c.AccountId == a2.Id) System.assert(us2.contains(c.OwnerId));
            if(c.AccountId == a3.Id) System.assert(us3.contains(c.OwnerId));
        }
    }

    // helping functions

    public static List<sobject> setupRoutingExample()
    {
        List<Sobject> results = new List<Sobject>();

        User u0 = createUser('ABCD');   // unavailable user
        u0.CSA_Available__c = false;
        User u1 = createUser('EFGH');
        User u2 = createUser('IJKL');
        User u3 = createUser('MNOP');
        User u4 = createUser('RSTU');
        User u5 = createUser('VXYZ');
        insert new List<User>{u0,u1,u2,u3,u4,u5};
        results.addAll(new List<Sobject>{u0,u1,u2,u3,u4,u5});

        Group team0 = createQueue('Team0', new List<String>{'Case','CSA_Routing__c'});  // empty team just to test that scenario
        Group team1 = createQueue('Team1', new List<String>{'Case','CSA_Routing__c'});
        Group team2 = createQueue('Team2', new List<String>{'Case','CSA_Routing__c'});

        results.addAll(new List<Sobject>{team0,team1,team2});

        List<GroupMember> newGroupMembers = new List<GroupMember>();
        newGroupMembers.addAll(addGms(team1.id, new List<User>{u0,u1,u2,u3}));
        newGroupMembers.addAll(addGms(team2.id, new List<User>{u4,u5}));
        contextINSERT(newGroupMembers);

        Account a0 = new Account(Name = 'SuperGenericAccount');
        Account a1 = new Account(Name = 'Account1');
        Account a2 = new Account(Name = 'Account2');
        Account a3 = new Account(Name = 'Account3');
        insert new List<Account>{a0,a1,a2,a3};
        insert new CSA_Account_Preference__c(Account__c = a2.id, CSA__c = u4.id);
        insert new CSA_Account_Preference__c(Account__c = a3.id, CSA__c = u5.id);


        // existing cases
        Case c011 = createCase(20);
        c011.OwnerId__c = u1.id;
        c011.OwnerId = u1.id;
        c011.AccountId = a0.id;
        c011.Number_of_Activities__c = 20;  // weight is multiplied by Number_Of_Activities__c
        Case c012 = createCase(30);
        c012.OwnerId__c = u1.id;
        c012.OwnerId = u1.id;
        c012.AccountId = a0.id;
        c012.Number_of_Activities__c = 30;  // weight is multiplied by Number_Of_Activities__c
        Case c021 = createCase(20);
        c021.OwnerId__c = u2.id;
        c021.OwnerId = u2.id;
        c021.AccountId = a0.id;
        c021.Number_of_Activities__c = 20;  // weight is multiplied by Number_Of_Activities__c
        insert new List<Case>{c011,c012,c021};

        // check that owner has not been changed by existing case trigger, otherwise test won't work
        System.assertEquals(c011.OwnerId,u1.id);
        System.assertEquals(c012.OwnerId,u1.id);
        System.assertEquals(c021.OwnerId,u2.id);

        List<Case> cases = new List<Case>();
        Case c01 = createCase(10);
        Case c02 = createCase(45);
        Case c03 = createCase(50);
        Case c04 = createCase(10);
        Case c05 = createCase(25);
        Case c06 = createCase(5);
        Case c07 = createCase(25);
        Case c08 = createCase(5);
        Case c09 = createCase(10);
        Case c10 = createCase(15);
        cases.addAll(new List<Case>{c01,c02,c03,c04,c05,c06,c07,c08,c09,c10});
        for(Case c : cases)
        {
            c.AccountId = a1.id;
            c.OwnerId__c = team1.id;
        }

        //new cases
        Case c11 = createCase(99);
        c11.AccountId = a2.id;
        c11.OwnerId__c = team2.id;
        Case c12 = createCase(99);
        c12.AccountId = a3.id;
        c12.OwnerId__c = team2.id;
        Case c13 = createCase(99);
        c13.AccountId = a2.id;
        c13.OwnerId__c= team2.id;
        Case c14 = createCase(99);
        c14.AccountId = a3.id;
        c14.OwnerId__c = team2.id;

        cases.addAll(new List<Case>{c11,c12,c13,c14});
        for(Integer i=0; i < 6; i++)
        {
            Case c = createCase(10);
            c.OwnerId__c = team0.id;
            //c.AccountId = a0.id;
            cases.add(c);
        }
        results.addAll((List<Sobject>) cases);

        return results;
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
        //u.CSA_Case_Type_Preference__c = 'SIM Swap';
        u.CSA_Available__c = true;
        return u;
    }

    public static Case createCase(Integer weighting)
    {
        Case c = new Case();
        c.RecordTypeId = Cache.RecordTypeId('Case.My O2 Business General');
        c.Status = 'New';
        c.Priority = 'Medium';
        c.Case_Submitted_By__c = 'X X';
        c.E_mail__c = 'x.x@o2.com.preprod';
        c.Origin = 'Application';
        c.Subject = 'Test';
        c.Description = 'Test';
        c.Agreement__c = true;
        c.Service_Request_Type__c = 'Contractual Adds / Changes';
        c.Request_Sub_Type__c = 'SIM Swap';     // with the new calculated weight, this will give 1 * (Number_Of_Activities__c == 0 ? 1 Number_Of_Activities__c)
        c.CSA_Weighting__c = weighting;
        c.Number_of_Activities__c = 1;
        return c;
    }

    public static Group createQueue(string qName, List<String> associatedObjects)
    {
        Group q = new Group(Name = qName, Type = 'Queue');
        insert q;

        if(!associatedObjects.isEmpty())
        {
            List<QueueSobject> qos = new List<QueueSobject>();
            for(String ao : associatedObjects)
            {
                qos.add(new QueueSobject(QueueId = q.Id, sobjectType = ao));
            }
            //insert qos;
            contextINSERT(qos);
        }
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