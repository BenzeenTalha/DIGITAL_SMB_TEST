@isTest
private class EmailMessageClosedCaseTriggerTest {

    /***************************************************
     *****    SCENARIO 1: Open Case                *****
     *****    EXPECTED:                            *****
     *****        The EmailMessage should be linked*****
     *****    to the open case.                    *****
     ***************************************************/
      private static Case openCase;
      private static EmailMessage mail1;
      private static EmailMessage mail2;

      static{
            Id currentUserId = UserInfo.getUserId();
            openCase = new Case
            (
                subject = 'Faulty machinery', description = 'Please fix',
                ownerid = currentUserId, status = 'New', origin = 'Email'
            );
            insert openCase;

      }

      static testMethod void emailToOpenCase(){
        AggregateResult[] mailperCase =
        [
            Select
                    count(Id) cnt
            From
                    EmailMessage
            Where
                    ParentId = : openCase.Id
        ];

        Integer emailsBeforeInsert = Integer.ValueOf(mailperCase[0].get('cnt'));

        mail1 = new EmailMessage
        (
            ToAddress='sup.dummycs123@gmail.com', TextBody='Hello there!', Subject='hi',
            ParentId = openCase.Id, FromName='Me', FromAddress='me@cloudsensesolutions.com'
        );
        insert mail1;

        mail1 =
        [
            Select
                    Id, parentId
            From
                    EmailMessage
            Where
                    Id = : mail1.Id
        ];

        mailperCase =
        [
            Select
                    count(Id) cnt
            From
                    EmailMessage
            Where
                    ParentId = : openCase.Id
        ];

        system.assert(Integer.ValueOf(mailperCase[0].get('cnt')) == (emailsBeforeInsert + 1));
        system.assert(mail1.ParentId == opencase.Id);
      }



    /***************************************************
     *****    SCENARIO 2: Closed Case              *****
     *****    EXPECTED:                            *****
     *****        The EmailMessage should be linked*****
     *****    to a new case with the old case as a *****
     *****    parent to the new case.              *****
     ***************************************************/
     /*static testMethod void emailToClosedCase(){
         opencase.status = 'Closed';
         opencase.Resolution_Time__c = 20;
         update opencase;

         AggregateResult[] mailperCase =
        [
            Select
                    count(Id) cnt
            From
                    EmailMessage
            Where
                    ParentId = : openCase.Id
        ];

        Integer emailsBeforeInsert = Integer.ValueOf(mailperCase[0].get('cnt'));

        mail2 = new EmailMessage
        (
            ToAddress='sup.dummycs123@gmail.com', TextBody='Hello there!', Subject='hi',
            ParentId = openCase.Id, FromName='Me', FromAddress='me@cloudsensesolutions.com'
        );
        insert mail2;

        mail2 =
        [
            Select
                    Id, parentId
            From
                    EmailMessage
            Where
                    Id = : mail2.Id
        ];

        mailperCase =
        [
            Select
                    count(Id) cnt
            From
                    EmailMessage
            Where
                    ParentId = : openCase.Id
        ];

        system.assert(Integer.ValueOf(mailperCase[0].get('cnt')) == emailsBeforeInsert);
        system.debug(mail2.ParentId + ' : && :' + opencase.Id);
        system.assert(mail2.ParentId != opencase.Id);
     }*/
}