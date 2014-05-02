@isTest
private class TeamControllerTest {
    private static User user1;    
    private static User user2;
    private static User user3;
    private static User user4;
    
    private static Group group1;
    private static Group group2;
    private static Group group3;
    
    private static GroupMember member1;
    private static GroupMember member2;
    private static GroupMember member3;
    private static GroupMember member4;
    private static GroupMember member5;
    
    private static Case case1;
    private static Case case2;
    private static Case case3;
    private static Case case4;

    static{
        Profile pAdmin =
        [
            Select 
                    Id
            From
                    Profile
            Where
                    Name = 'System Administrator'
            Limit 1
        ];
    
        user1 = new User
        (
            firstName = 'Alice', lastName = 'Wonderland', alias = 'aliceW',
            email = 'alice.wonderland@email.com', username = 'alice.w@test.org',
            CommunityNickname='aw', profileId = pAdmin.Id, TimeZoneSidKey = 'Europe/London', 
            LocaleSidKey = 'en_GB', EmailEncodingKey = 'ISO-8859-1', 
            LanguageLocaleKey = 'en_US', CSA_Available__c = false
        );
        insert user1;

        user2 = new User
        (
            firstName = 'Bugs', lastName = 'Bunny', alias = 'bugsB',
            email = 'bugs.bunny@email.com', username = 'bugs.b@test.org',
            CommunityNickname='bb', profileId = pAdmin.Id, TimeZoneSidKey = 'Europe/London', 
            LocaleSidKey = 'en_GB', EmailEncodingKey = 'ISO-8859-1', 
            LanguageLocaleKey = 'en_US'
        );
        insert user2;
        
        user3 = new User
        (
            firstName = 'Casper', lastName = 'Ghost', alias = 'casperG',
            email = 'casper.ghost@email.com', username = 'casper.g@test.org',
            CommunityNickname='cg', profileId = pAdmin.Id, TimeZoneSidKey = 'Europe/London', 
            LocaleSidKey = 'en_GB', EmailEncodingKey = 'ISO-8859-1', 
            LanguageLocaleKey = 'en_US'
        );
        insert user3;
        
        user4 = new User
        (
            firstName = 'Daffy', lastName = 'Duck', alias = 'daffyD',
            email = 'daffy.duck@email.com', username = 'daffy.d@test.org',
            CommunityNickname='dd', profileId = pAdmin.Id, TimeZoneSidKey = 'Europe/London', 
            LocaleSidKey = 'en_GB', EmailEncodingKey = 'ISO-8859-1', 
            LanguageLocaleKey = 'en_US'
        );
        insert user4;
                
        group1 = new Group
        (
            Type = 'Queue', Name = 'group1', DoesIncludeBosses = true
        );
        insert group1;

        group2 = new Group
        (
            Type = 'Queue', Name = 'group2', DoesIncludeBosses = true
        );
        insert group2;
        
        group3 = new Group
        (
            Type = 'Queue', Name = 'group3', DoesIncludeBosses = true
        );
        insert group3;  
        
        //Group 1 has user 1 as member
        member1 = new GroupMember
        (
            UserOrGroupId = user1.Id, GroupId = group1.Id
        );
        insert member1;

       //Group 2 has user 2 as member
        member2 = new GroupMember
        (
            UserOrGroupId = user2.Id, GroupId = group2.Id
        );
        insert member2;
        
       //Group 3 has user 1,2,3 as members
        member3 = new GroupMember
        (
            UserOrGroupId = user1.Id, GroupId = group3.Id
        );
        insert member3;

        member4 = new GroupMember
        (
            UserOrGroupId = user2.Id, GroupId = group3.Id
        );
        insert member4;
        
        member5 = new GroupMember
        (
            UserOrGroupId = user3.Id, GroupId = group3.Id
        );
        insert member5;
        
    }
    
    static testmethod void testQueueList(){
        Test.startTest();

        List<SelectOption> teamList = new List<SelectOption>();
        TeamController tc = new TeamController();
        
        List<QueueSobject> qs = 
        [
            Select
                         Queue.Name, Id, QueueId 
                 From 
                         QueueSobject 
                 Where 
                         SobjectType = 'CSA_Routing__c'
        ];
        
        teamList.add(new SelectOption('None', 'None'));
        for (QueueSobject g : qs){
            teamList.add(new SelectOption(g.QueueId, g.Queue.Name));
        }
        
        system.assert(tc.teamQueues == teamList);

        Test.stopTest();
    }
    
    static testMethod void testCaseAvailabilityEdit(){
        Test.startTest();
                
        TeamController tc = new TeamController();
        tc.currentUser = user1.Id;
        
        User u = 
        [
            Select
                    Id, CSA_Available__c, CSA_Case_Type_Preference__c
            From
                    User
            Where
                    Id = : user1.Id
        ];
        
        system.assert(!u.CSA_Available__c);
        system.assert(u.CSA_Case_Type_Preference__c == null);
                
        tc.availability = 'true';
        tc.caseType = 'Electrical';
        tc.saveUserDetails();
        
        u = 
        [
            Select
                    Id, CSA_Available__c, CSA_Case_Type_Preference__c
            From
                    User
            Where
                    Id = : user1.Id
        ];
        
        system.assert(u.CSA_Available__c);
        system.assert(u.CSA_Case_Type_Preference__c == 'Electrical');
        
        Test.stopTest();
    }
    
    static testMethod void testEditMode(){
        Test.startTest();

        TeamController tc = new TeamController();
        system.assert(!tc.editMode);
        tc.editUserDetails();
        system.assert(tc.editMode);
        
        Test.stopTest();
    }
    
    static testMethod void testShowTable(){
        Test.startTest();

        TeamController tc = new TeamController();
        system.assert(!tc.showTable);
        tc.retrieveTable();
        system.assert(tc.showTable);

        Test.stopTest();
    }
  /**  
    static testMethod void testNavigation(){
        Test.startTest();
        
        TeamController tc = new TeamController();
        
        system.assert(tc.teamQueues.size() > 1);
        
        tc.selectedUser = user3.Id;
        tc.showUserDetails();
        
        system.assert(tc.workload.size() == 0);
        
        createCases();
        tc.showWorkload();

        Test.stopTest();
    }
    
    */
    
    static testMethod void testTeamMembers(){
        Test.startTest();

        TeamController tc = new TeamController();
        
        tc.selectedTeamId = group3.Id;
        system.debug('tc.teamMembers.size()  : ' + tc.getteamMembers().size() );
        system.assert(tc.getteamMembers().size() == 3);
        
        Test.stopTest();
    }
    
    static testMethod void testCaseTypes(){
        Test.startTest();
        
        TeamController tc = new TeamController();
        system.assert(tc.CaseTypes.size() > 1);
        
        Test.stopTest();
    }
    
    @future
    private static void createCases(){
         //Create Cases - user 1 - 0 case, user 2 - 1 case, user 3 - 3 cases (2 open, 1 closed)
        system.runAs(user2){
            case1 = new Case
            (
                subject = 'Faulty machinery', description = 'Please fix',
                ownerid = user2.Id, status = 'New', origin = 'Email'
            );
            insert case1;
        }
        
        system.runAs(user3){
            case2 = new Case
            (
                subject = 'Bug', description = 'Please fix bug',
                ownerid = user3.Id, status = 'New', origin = 'Email'
            );
            insert case2;
            
            case3 = new Case
            (
                subject = 'Issue', description = 'Unknown',
                ownerid = user3.Id, status = 'New', origin = 'Email'
            );
            insert case3;
            
            case4 = new Case
            (
                subject = 'Various', description = 'Amendments',
                ownerid = user3.Id, status = 'Closed', origin = 'Email', Resolution_Time__c = 200
            );
            insert case4;
        }
        
        system.debug([select Id, subject, owner.Name from Case]);
    }
    
}