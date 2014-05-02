@isTest
private class EnterpriseTeamMappingTest{
    
    private static Account acc1;
    private static Account acc2;
    private static Group team1;
    private static Group team2;
    private static Enterprise_Team_Mapping__c mapping1;
    private static Enterprise_Team_Mapping__c mapping2;
    private static GroupMember member1;
    private static User user1;
    
    static{
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            acc1 = new Account
            (
                name='Acc1'
            );
            insert acc1;
            
            acc2 = new Account
            (
                name = 'Acc2'
            );
            insert acc2;
            
            team1 = new Group
            (
                name = 'team1', type = 'Queue'
            );
            insert team1;
            
            QueuesObject q = new QueuesObject (queueid=team1.id, sobjectType='Case');
            insert q;
            
            QueuesObject q1 = new QueuesObject (queueid=team1.id, sobjectType='CSA_Routing__c');
            insert q1;
        
            team2 = new Group
            (
                name = 'team2', type = 'Queue'
            );
            
            insert team2;
            
            QueuesObject q3 = new QueuesObject (queueid=team2.id, sobjectType='Case');
            insert q3;
            
            QueuesObject q4 = new QueuesObject (queueid=team2.id, sobjectType='CSA_Routing__c');
            insert q4;           
            
            mapping1 = new Enterprise_Team_Mapping__c
            (
                Account__c = acc1.Id, Simple_Cases_Team_Name__c = 'team1', Complex_Cases_Team_Name__c = 'team2'
            );
            
           insert mapping1;
           
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
           
           member1 = new GroupMember
           (
               GroupId = team1.Id, UserOrGroupId = user1.Id
           );
        }
    }
    
   static testMethod void insertCase(){
       
       mapping1 =
       [
           Select
                   Account__c, Simple_Cases_Team_Name__c, Simple_Cases_Team_Id__c,
                   Complex_Cases_Team_Name__c, Complex_Cases_Team_Id__c
           From
                   Enterprise_Team_Mapping__c
           Where
                   Id = : mapping1.Id
       ];
              
       system.assert(mapping1.Simple_Cases_Team_Id__c == team1.Id);
       system.assert(mapping1.Complex_Cases_Team_Id__c == team2.Id);
   }

   static testMethod void updateCase(){
       
       mapping1 =
       [
           Select
                   Account__c, Simple_Cases_Team_Name__c, Simple_Cases_Team_Id__c,
                   Complex_Cases_Team_Name__c, Complex_Cases_Team_Id__c
           From
                   Enterprise_Team_Mapping__c
           Where
                   Id = : mapping1.Id
       ];
              
       system.assert(mapping1.Simple_Cases_Team_Id__c == team1.Id);
       system.assert(mapping1.Complex_Cases_Team_Id__c == team2.Id);
       
       mapping1.Simple_Cases_Team_Name__c = 'team2';
       mapping1.Complex_Cases_Team_Name__c = 'team1';
       update mapping1;
       
       mapping1 =
       [
           Select
                   Account__c, Simple_Cases_Team_Name__c, Simple_Cases_Team_Id__c,
                   Complex_Cases_Team_Name__c, Complex_Cases_Team_Id__c
           From
                   Enterprise_Team_Mapping__c
           Where
                   Id = : mapping1.Id
       ];
       
       system.assert(mapping1.Simple_Cases_Team_Id__c == team2.Id);
       system.assert(mapping1.Complex_Cases_Team_Id__c == team1.Id);
       
   }
   
   static testMethod void testAutoRouting(){
       Case aNewCase = new Case
       (
           Subject = 'Hi', Origin = 'Customer Portal', Complexity__c = 'Simple', AccountId = acc1.Id
       );
       insert aNewCase;
       
       aNewCase =
       [
           Select 
                   Id, OwnerId
           From
                   Case
           Where
                   Id = : aNewCase.Id
       ];
       
       system.debug('aNewCase.OwnerId == user1.Id : ' + aNewCase.OwnerId + ' : ' + user1.Id);
      // system.assert(aNewCase.OwnerId == Team1.Id);
   
   } 

}