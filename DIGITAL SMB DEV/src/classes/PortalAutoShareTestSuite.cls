@isTest
private class PortalAutoShareTestSuite {

    static testMethod void testPortalAccountSharing() {
        //### create reference data
        //create/get test partner account and portal user
        User partnerUser = [SELECT Id, Name, AccountId, UserRoleId FROM User WHERE Contact.Account.IsPartner = true AND IsActive = true AND UserRole.PortalType = 'Partner' LIMIT 1];
        System.assertNotEquals(null, partnerUser);
        Account partnerAcc = [SELECT Id, Name, IsPartner, OwnerId FROM Account WHERE Id = :partnerUser.AccountId LIMIT 1];
        System.assertNotEquals(null, partnerAcc);
        
        //get the toplevel partner role group - portal role and subordinates
        UserRole execRole = [SELECT Id, Name FROM UserRole WHERE PortalAccountId=:partnerUser.AccountId AND Name LIKE '%Partner Executive' LIMIT 1];
        System.assertNotEquals(null, execRole);
        Group shareGroup = [SELECT Id, Name, RelatedId, DoesIncludeBosses, OwnerId, Type FROM Group WHERE RelatedId=:execRole.Id AND Type='RoleAndSubordinates' LIMIT 1];
        System.assertNotEquals(null, execRole);
        
        //create a new customer account for the partner user
        Account newCustomerAcc = new Account(Name='APEXTESTACC001', OwnerId=partnerUser.Id);
        insert newCustomerAcc;	//this should create the new manual sharing rule(s)
        String strAccId = newCustomerAcc.Id;
        
        //check that the manual sharing rule has been created for the INSERT
        List<AccountShare> accShares = [SELECT Id, RowCause, UserOrGroupId, AccountId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE UserOrGroupId=:shareGroup.Id AND RowCause='Manual' AND AccountId=:strAccId];
        System.assertNotEquals(null, accShares);
        System.assertEquals(1, accShares.size());  
        
        //remove all manual sharing rules from the new account and check UPDATE operation re-creates it
        List<AccountShare> delShares = [SELECT Id FROM AccountShare WHERE RowCause='Manual' AND AccountId=:strAccId];
        delete delShares;
        update newCustomerAcc;	//this should recreate the manual sharing rule(s)
        List<AccountShare> reShares = [SELECT Id, RowCause, UserOrGroupId, AccountId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE UserOrGroupId=:shareGroup.Id AND RowCause='Manual' AND AccountId=:strAccId];
        System.assertNotEquals(null, reShares);
        System.assertEquals(1, reShares.size());        
    }
}