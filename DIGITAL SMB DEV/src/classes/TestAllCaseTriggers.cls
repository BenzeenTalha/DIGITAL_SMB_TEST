@isTest
private class TestAllCaseTriggers
{
    static Id profId = [Select Id from Profile where Name='System Administrator' limit 1].id;
    
    static void setupSetupObjects(User tmpUser, User tmpUser1, User tmpUser2) {
        Profile tmpProfile=[Select Id,Name from Profile where Name='JJ Sales Project Team - Limited Edition plus Line Checker Pilot' limit 1];

        UserRole tmpRole=new UserRole();
        tmpRole.Name='Test Role';
        insert tmpRole;

        tmpUser.Firstname='X';
        tmpUser.Lastname='X';
        tmpUser.Alias='XABC';
        tmpUser.Email='x.x@xy.com';
        tmpUser.Username='x2.x2@o2.com.preprod';
        tmpUser.CommunityNickname='x2.x2';
        tmpUser.UserRoleId=tmpRole.Id;
        tmpUser.ProfileId=tmpProfile.Id;
        tmpUser.IsActive=true;
        tmpUser.LocaleSidKey='en_US';
        tmpUser.TimeZoneSidKey='America/Los_Angeles';
        tmpUser.EmailEncodingKey='UTF-8';
        tmpUser.LanguageLocaleKey='en_US';
        insert tmpUser;

        tmpProfile=[Select Id,Name from Profile where Name='JJ Business Sales Super User' limit 1];

        tmpUser1.Firstname='Y';
        tmpUser1.Lastname='Y';
        tmpUser1.Alias='YABC';
        tmpUser1.Email='y.y@xy.com';
        tmpUser1.Username='y.y@o2.com.preprod';
        tmpUser1.CommunityNickname='y.y';
        tmpUser1.UserRoleId=tmpRole.Id;
        tmpUser1.ProfileId=tmpProfile.Id;
        tmpUser1.IsActive=true;
        tmpUser1.LocaleSidKey='en_US';
        tmpUser1.TimeZoneSidKey='America/Los_Angeles';
        tmpUser1.EmailEncodingKey='UTF-8';
        tmpUser1.LanguageLocaleKey='en_US';
        insert tmpUser1;

        tmpProfile=[Select Id,Name from Profile where Name='JJ Sales Project Team - Limited Edition plus Line Checker Pilot' limit 1];
        //UserRole tmpRole2=[Select Id from UserRole where Name='ADSI Partner Executive'];
        tmpUser2.Firstname='Y';
        tmpUser2.Lastname='Y';
        tmpUser2.Alias='YABC';
        tmpUser2.Email='y.y@xy.com';
        tmpUser2.Username='z.z@o2.com.preprod';
        tmpUser2.CommunityNickname='z.z';
        tmpUser2.UserRoleId=tmpRole.Id;
        tmpUser2.ProfileId=tmpProfile.Id;
        tmpUser2.IsActive=true;
        tmpUser2.LocaleSidKey='en_US';
        tmpUser2.TimeZoneSidKey='America/Los_Angeles';
        tmpUser2.EmailEncodingKey='UTF-8';
        tmpUser2.LanguageLocaleKey='en_US';
        insert tmpUser2;
    }

    static void setupNonSetupObjects(Id userId, Id userId1, Id userId2) {
        User tmpUser = [SELECT Id FROM User WHERE Id=:userId];
        User tmpUser1 = [SELECT Id FROM User WHERE Id=:userId1];
        User tmpUser2 = [SELECT Id FROM User WHERE Id=:userId2];

        Case tmpCase = new Case();

        System.runAs(tmpUser)
        {


            tmpCase.RecordTypeId=Cache.RecordTypeId('Case.Support');
            tmpCase.Status='New';
            tmpCase.Priority='P4-Information';
            tmpCase.Case_Submitted_By__c='X X';
            tmpCase.E_mail__c='x.x@o2.com.preprod';
            tmpCase.Origin='Application';
            tmpCase.Subject='Test';
            tmpCase.Description='Test';
            tmpCase.Agreement__c=true;
            insert tmpCase;
        }

        System.runAs(tmpUser1)
        {
            tmpCase.Category__c='General Salesforce Product Support';
            update tmpCase;
        }

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Account newAcc = new Account(Name = 'test Acc') ;
            insert newAcc ;

            Contact newContact = new Contact(FirstName = 'Jack',
                                             LastName = 'Jones',
                                             email = 'jack.jones@junkmail.yahoo.com.uk',
                                             phone = '07951069913',
                                             AccountId = newAcc.Id);
            insert newContact;
        }

        // test change of owner on update, also test superuser code
        System.runAs(tmpUser1)
        {
            tmpCase.OwnerId = userId;
            tmpCase.Super_User__c = userId2;
            update tmpCase;
            tmpCase.OwnerId = userId1;
            update tmpCase;
        }

    }

    static testMethod void Test_SuperUserTag()
    {
        User tmpUser = new User();
        User tmpUser1 = new User();
        User tmpUser2 = new User();

        setupSetupObjects(tmpUser, tmpUser1, tmpUser2);

        Test.StartTest();
            setupNonSetupObjects(tmpUser.Id, tmpUser1.Id, tmpUser2.Id);
        Test.stopTest();
    }

    /*
        These testmethods will test that governing limits are not hit while processing a batch.
        They will not use validation tests (i.e. assert any output results of case routing) because:
        a) Validation tests for case routing are done in TestTestCaseRouting.class for the functionality in TestCaseRouting.class ONLY.
        b) If there are other processes determining case owner assignment, inside and outside of the trigger, they may change the results of case routing.
           Also, any new routing functionality could cause a validation test to fail and would require the testmethods to be rewritten.
    */

    static testMethod void runInsertBatch()
    {
        List<sObject> results;

        results = TestCaseRouting.setupRoutingExample();

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

        Test.startTest();
        insert cases;
        Test.stopTest();
    }

    static testMethod void runUpdateBatch()
    {
        List<sObject> results;

        results = TestCaseRouting.setupRoutingExample();

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

        List<Id> ownerIds = new List<Id>();
        List<String> subtypes = new List<String>();
        for(Case c : cases) // this way we want to skip the routing functionality
        {
            subtypes.add(c.Request_Sub_Type__c);
            c.Request_Sub_Type__c = null;
            c.OwnerId__c = c.OwnerId;
            ownerIds.add(c.OwnerId);
        }
        insert cases;

        for(Integer i = 0; i < cases.size(); i++)
        {
            cases.get(i).Request_Sub_Type__c = subtypes.get(i);
            cases.get(i).OwnerId__c = ownerIds.get(i);  // re-assign Owners just to be sure
            
        }

        system.assertEquals(cases.size(),20);   // assert batch size

        Test.startTest();
        update cases;
        Test.stopTest();
    }

    static testMethod void runEntitlementAutoAssignement()
    {
        Account newAcc = new Account(Name = 'test Acc') ;
        insert newAcc ;

        BusinessHours bh = [select id from BusinessHours limit 1];

        list<Entitlement> entsForInsert = new list<Entitlement>();
        Entitlement ent1 = new Entitlement(AccountId = newAcc.Id,
                                           Name = 'test ent 1',
                                           Type = 'Standard - 24/7',
                                           BusinessHoursId = bh.id);        // just one entry as to achieve code coverage
        entsForInsert.add(ent1);

        Entitlement ent2 = new Entitlement(AccountId = newAcc.Id,
                                           Name = 'test ent 2',
                                           Type = 'Standard - Business Hours');
        entsForInsert.add(ent2);

        Account newAcc2 = new Account(Name = 'test Acc2') ;
        insert newAcc2 ;

        Entitlement ent3 = new Entitlement(AccountId = newAcc2.Id,
                                           Name = 'test ent 3',
                                           Type = 'Bespoke - Business Hours');
        entsForInsert.add(ent3);

        Entitlement ent4 = new Entitlement(AccountId = newAcc2.Id,
                                           Name = 'test ent 4',
                                           Type = 'Bespoke - 24/7');
        entsForInsert.add(ent4);
        insert entsForInsert;

        list<Case> casesForInsert = new list<Case>();
        Case tmpCase = new Case();
        tmpCase.RecordTypeId=Cache.RecordTypeId('Case.My O2 Business General');
        tmpCase.AccountId = newAcc.Id;
        tmpCase.Status='New';
        tmpCase.Priority='Medium';
        tmpCase.Case_Submitted_By__c='X X';
        tmpCase.E_mail__c='x.x@o2.com.preprod';
        tmpCase.Origin='Application';
        tmpCase.Subject='Test';
        tmpCase.Description='Test';
        casesForInsert.add(tmpCase);

        Case tmpCase2 = new Case();
        tmpCase2.RecordTypeId=Cache.RecordTypeId('Case.My O2 Business General');
        tmpCase2.AccountId = newAcc.Id;
        tmpCase2.Status='New';
        tmpCase2.Priority='Medium';
        tmpCase2.Case_Submitted_By__c='X X';
        tmpCase2.E_mail__c='x.x@o2.com.preprod';
        tmpCase2.Origin='Application';
        tmpCase2.Service_Request_Type__c='Enquiries';
        tmpCase2.Request_Sub_Type__c='Lost/Stolen';
        tmpCase2.Subject='Test';
        tmpCase2.Description='Test';
        casesForInsert.add(tmpCase2);

        insert casesForInsert;

        list<Case> casesForUpdate = new list<Case>();
        tmpCase.AccountId = newAcc2.Id;
        casesForUpdate.add(tmpCase);
        tmpCase2.AccountId = newAcc2.Id;
        casesForUpdate.add(tmpCase2);
        update casesForUpdate;
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
    
    public static List<GroupMember> addGMs (Id groupId, List<User> users)
    {
        List<GroupMember> gms = new List<GroupMember>();
        for(User u : users) gms.add(new GroupMember(GroupId = groupId, UserOrGroupId = u.id));
        return gms;
    }
    
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
    
    public static List<Sobject> setupRRoutingExample(){
        List<Sobject> results = new List<Sobject>();

        User u0 = createUser('u0');   // unavailable user
        u0.CSA_Available__c = false;
        User u1 = createUser('u1');
        User u2 = createUser('u2');
        User u3 = createUser('u3');
        User u4 = createUser('u4');
        User u5 = createUser('u5');
        insert new List<User>{u0,u1,u2,u3,u4,u5};
        results.addAll(new List<Sobject>{u0,u1,u2,u3,u4,u5});
        
        system.debug('u1=' + u1.Id);
        system.debug('u2=' + u2.Id);
        system.debug('u3=' + u3.Id);
        
        Group team0 = createQueue('Team0', new List<String>{'Case','CSA_Routing__c'});  // empty team just to test that scenario
        Group team1 = createQueue('Team1', new List<String>{'Case','CSA_Routing__c'});
        Group team2 = createQueue('Team2', new List<String>{'Case','CSA_Routing__c'});
        Group team3 = createQueue('Team3', new List<String>{'Case','CSA_Routing__c'});
        
        system.debug('team0-----------'+team0);
        system.debug('team1-----------'+team1);
        system.debug('team2-----------'+team2);
        system.debug('team2-----------'+team3);
        results.addAll(new List<Sobject>{team0,team1,team2,team3});

        List<GroupMember> newGroupMembers = new List<GroupMember>();
        newGroupMembers.addAll(addGms(team1.id, new List<User>{u0,u1,u2,u3}));
        newGroupMembers.addAll(addGms(team2.id, new List<User>{u4,u5}));
        contextINSERT(newGroupMembers);

        Account a0 = new Account(Name = 'SuperGenericAccount');
        Account a1 = new Account(Name = 'Account1');
        insert new List<Account>{a0,a1};
       
        system.debug('Account a0--------'+a0);
        system.debug('Account a1--------'+a1);
        
        List<Enterprise_Team_Mapping__c> mappings = new List<Enterprise_Team_Mapping__c>();
        mappings.add(new Enterprise_Team_Mapping__c(
            Account__c = a1.Id,
            Simple_Cases_Team_Id__c = team2.Id,
            Simple_Cases_Team_Name__c = 'Team2',
            Complex_Cases_Team_Id__c = team1.Id,
            Complex_Cases_Team_Name__c = 'Team1'
        )); 
        
        mappings.add(new Enterprise_Team_Mapping__c(
            Account__c = a0.Id,
            Simple_Cases_Team_Id__c = team0.Id,
            Simple_Cases_Team_Name__c = 'Team0',
            Complex_Cases_Team_Id__c = team3.Id,
            Complex_Cases_Team_Name__c = 'Team3'
        ));   
        
        insert mappings;    
        
        system.debug('mappings--------------'+mappings);
        
        List<Case> cases = new List<Case>();
        
        Case c011 = createCase(20);
        c011.OwnerId = u1.id;
        c011.AccountId = a0.id;
        c011.Number_of_Activities__c = 20;  // weight is multiplied by Number_Of_Activities__c
        insert c011;
       
        cases.addAll(new List<Case>{c011});
        //cases.add(c011);
        results.addAll((List<Sobject>) cases);
         
        results.addAll(new List<Sobject>{a0,a1});

        return results;
    }
    
    public static Case createCase(Integer weighting)
    {
        Case c = new Case();
        c.RecordTypeId = Cache.RecordTypeId('Case.My O2 Business General');
        c.Status = 'New';
        c.Priority = 'Medium';
        c.Case_Submitted_By__c = 'X X';
        c.E_mail__c = 'x.x@o2.com.preprod';
        c.Origin = 'Email';
        c.Subject = 'Test';
        c.Description = 'Test';
        c.Agreement__c = true;
        c.CSA_Weighting__c = weighting;
        c.Number_of_Activities__c = 1;
        return c;
    }
/*   
    static testMethod void testUpdateCaseTeamScenario1()  // test various cases that will be routed in a batch of 20
    {
        // START DATA SETUP
        List<sObject> results;
        results = setupRRoutingExample();

        User u0 = (User) results.get(0);
        User u1 = (User) results.get(1);
        User u2 = (User) results.get(2);
        User u3 = (User) results.get(3);
        User u4 = (User) results.get(4);
        User u5 = (User) results.get(5);
        Map<Id, User> users = new Map<Id, User>([Select Id, Name from User]);
        
        Group team0 = (Group) results.get(6);
        Group team1 = (Group) results.get(7);
        Group team2 = (Group) results.get(8);

        List<Case> cases = new List<Case>();
        cases.add((Case) results.get(10));
        
        system.debug('cases finallyy----'+cases);
        
        Case caseToBeUpdate = (Case) results.get(10);
        system.debug('RESULTS---'+results);
        
        Account a11 = (Account) results.get(12);
        system.debug('a11-------'+a11);
        
        caseToBeUpdate.Request_Sub_Type__c = 'New connections';
        caseToBeUpdate.Service_Request_Type__c = 'Add';
        caseToBeUpdate.complexity__c = 'Standard';
        caseToBeUpdate.AccountId = a11.Id;
        
        system.debug('Before update case%%%%%%%%%%%%%%%%%%%%');
        update caseToBeUpdate;
        system.debug('caseToBeUpdate-------updated--'+caseToBeUpdate);
        
        Account a01 = (Account) results.get(11);
        system.debug('a11-------'+a11);
        
        caseToBeUpdate.Request_Sub_Type__c = 'New connections';
        caseToBeUpdate.Service_Request_Type__c = 'Add';
        caseToBeUpdate.complexity__c = 'Standard';
        caseToBeUpdate.AccountId = a01.Id;
        
        system.debug('Before update case $$$$$$$$$$$ %%%%%%%%');
        update caseToBeUpdate;
        system.debug('caseToBeUpdate-------updated--'+caseToBeUpdate);
    } 
    
     static testMethod void testUpdateCaseTeamScenario2()  // test various cases that will be routed in a batch of 20
    {
        // START DATA SETUP
        List<sObject> results;
        results = setupRRoutingExample();

        User u0 = (User) results.get(0);
        User u1 = (User) results.get(1);
        User u2 = (User) results.get(2);
        User u3 = (User) results.get(3);
        User u4 = (User) results.get(4);
        User u5 = (User) results.get(5);
        Map<Id, User> users = new Map<Id, User>([Select Id, Name from User]);
        
        Group team0 = (Group) results.get(6);
        Group team1 = (Group) results.get(7);
        Group team2 = (Group) results.get(8);

        List<Case> cases = new List<Case>();
         cases.add((Case) results.get(10));
        
        system.debug('cases finallyy----'+cases);
        
        Case caseToBeUpdate = (Case) results.get(10);
        system.debug('caseToBeUpdate---------'+caseToBeUpdate);
        
        system.debug('RESULTS---'+results);
        
        Account a11 = (Account) results.get(12);
        system.debug('a11-------'+a11);
        
        caseToBeUpdate.Request_Sub_Type__c = 'New connections';
        caseToBeUpdate.Service_Request_Type__c = 'Add';
        caseToBeUpdate.complexity__c = 'Standard';
        caseToBeUpdate.AccountId = a11.Id;
        
        system.debug('Before update case normal%%%%%%%%%%%%%%%%%%%%');
        update caseToBeUpdate;
        system.debug('caseToBeUpdate-------updated--'+caseToBeUpdate);
        
        caseToBeUpdate.complexity__c = 'Complex';
        system.debug('Before update case- complex%%%%%%%%%%%%%%%%%%%%');
        update caseToBeUpdate;
        system.debug('caseToBeUpdate-------updated--'+caseToBeUpdate);
    } 
*/
}