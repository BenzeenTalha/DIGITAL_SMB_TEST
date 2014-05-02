//------------------------------------------------------------------------------
// Helper functions for searching accounts with MPN
// Using SOA service we get DISE account number and then we search accounts with
// that number
//------------------------------------------------------------------------------
public with sharing class O2AccountHelper
{
    //--------------------------------------------------------------------------
    // Search accounts that use mobile phone number
    //--------------------------------------------------------------------------
    public static List<Account> getAccountsWithMPN(String mobile)
    {
        String DISEAccountNumber = getDISEAccountNumber(mobile);
        //
        // Search accounts with DISE account number
        //
        return getAccountsWithDISEAccountNumber(DISEAccountNumber);
    }

    //--------------------------------------------------------------------------
    // Get DISE account number from mobile phone number
    //--------------------------------------------------------------------------
    public static String getDISEAccountNumber(String mobile)
    {
        String DISEAccountNumber;
        if (String.isNotEmpty(mobile))
        {
            //
            // Call web service to get DISE account number
            //
            String msisdn = SOAUtils.cleanDirectoryNumber(mobile);
            O2RetailUpgradeServicesInterface servicesInterface =
                new O2RetailUpgradeServicesProxy(new O2RetailUpgradeSOAPServices());
            Map<String, Object> returnValues =
                servicesInterface.getSubscriptionDetails(msisdn, new String[]{'BASIC'});
            Map<String, Object> basic = (Map<String, Object>)returnValues.get('BASIC');
            if (basic != null)
            {
                DISEAccountNumber = (String)basic.get('accountNumber');
            }
        }
        system.debug('DISEAccountNumber: ' + DISEAccountNumber);
        return DISEAccountNumber;
    }

    //--------------------------------------------------------------------------
    // Add account ids from container to a set
    //--------------------------------------------------------------------------
    private static void addToSet(Set<Id> accountIds, AC_Container__c container)
    {
        if (container != null)
        {
            addToSet(accountIds, container.CT_Organisation_Container__c);
            addToSet(accountIds, container.MB_Organisation_Container__c);
            addToSet(accountIds, container.SFAccountId__c);
        }
    }

    //--------------------------------------------------------------------------
    // Add account id to a set
    //--------------------------------------------------------------------------
    private static void addToSet(Set<Id> accountIds, Id accountId)
    {
        if (accountId != null)
        {
            accountIds.add(accountId);
        }
    }

    //--------------------------------------------------------------------------
    // Search accounts with DISE account number
    //--------------------------------------------------------------------------
    public static List<Account> getAccountsWithDISEAccountNumber(
            String DISEAccountNumber)
    {
        Set<Id> accountIds =
            getAccountIdsWithDISEAccountNumber(DISEAccountNumber);

        return getAccountsFromIds(accountIds);
    }

    //--------------------------------------------------------------------------
    // Get accounts that have name
    //--------------------------------------------------------------------------
    public static List<Account> getAccountsWithName(String name)
    {
        Set<Id> accountIds = null;
        accountIds = getAccountIdsWithName(name, accountIds);
        return getAccountsFromIds(accountIds);
    }

    //--------------------------------------------------------------------------
    // Get account with postal code
    //--------------------------------------------------------------------------
    public static List<Account> getAccountsWithPostCode(String postCode)
    {
        Set<Id> accountIds = null;
        accountIds = getAccountIdsWithPostCode(postCode, accountIds);
        return getAccountsFromIds(accountIds);
    }

    //--------------------------------------------------------------------------
    // Get accounts with DISE account number and name and postal code
    // Logic
    //   1. Retrieves accounts with DISE account number
    //   2. Retrieves accounts with name on set from step 1
    //      a. If we don't have accounts with criteria we return all set
    //   3. Retrieves accounts with postcode
    //      a. If we don't have accoutns with criteria we return all set
    //--------------------------------------------------------------------------
    public static List<Account> getAccounts(
            String accountNumber,
            String name,
            String postCode)
    {
        Set<Id> accountIds = null;
        accountIds = getAccountIdsWithDISEAccountNumber(accountNumber);
        accountIds = getAccountIdsWithName(name, accountIds);
        accountIds = getAccountIdsWithPostCode(postCode, accountIds);
        return getAccountsFromIds(accountIds);
    }

    //--------------------------------------------------------------------------
    // Get account Ids with DISE account number
    //--------------------------------------------------------------------------
    private static Set<Id> getAccountIdsWithDISEAccountNumber(
            String DISEAccountNumber)
    {
        Set<Id> accountIds = null;
        if (String.isNotBlank(DISEAccountNumber))
        {
            //
            // Search accounts
            //
            accountIds = new Set<Id>();
            
            for(List<SObject> searchList : [
                
                FIND :DISEAccountNumber IN ALL FIELDS RETURNING 
                    Account (
                        Id, DISE_Account_No__c, DISE_Group_Code_Account_No_1__c, DISE_Group_Code_Account_No_2__c, DISE_Group_Code_Account_No_3__c, DISE_Group_Code_Account_No_4__c                        
                    )
            ]){
                
                for(SObject sObj : searchList){
                    
                    Account acc = (Account) sObj;
                    if(
                        acc.DISE_Account_No__c == DISEAccountNumber ||
                        acc.DISE_Group_Code_Account_No_1__c == DISEAccountNumber ||
                        acc.DISE_Group_Code_Account_No_2__c == DISEAccountNumber ||
                        acc.DISE_Group_Code_Account_No_3__c == DISEAccountNumber ||
                        acc.DISE_Group_Code_Account_No_4__c == DISEAccountNumber
                    ){
                        
                        accountIds.add(acc.Id);
                    }
                    
                }
            }
            
            /*
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id
                FROM Account
                WHERE DISE_Account_No__c = :DISEAccountNumber
                OR DISE_Group_Code_Account_No_1__c = :DISEAccountNumber
                OR DISE_Group_Code_Account_No_2__c = :DISEAccountNumber
                OR DISE_Group_Code_Account_No_3__c = :DISEAccountNumber
                OR DISE_Group_Code_Account_No_4__c = :DISEAccountNumber
                LIMIT 1000]);

            accountIds.addAll(accountMap.keySet());
            */
            
            //
            // Search account subscriptions
            //
            List<AC_Subscription__c> accountSubscriptions;
            accountSubscriptions = [
                SELECT Id, Name, DISE_Account_No__c, AC_Container__c,
                AC_Container__r.CT_Organisation_Container__c,
                AC_Container__r.MB_Organisation_Container__c,
                AC_Container__r.SFAccountId__c
                FROM AC_Subscription__c
                WHERE DISE_Account_No__c = :DISEAccountNumber
                LIMIT 1000];
            //
            // Search account containers
            //
            List<AC_Container__c> accountContainers;
            accountContainers = [
                SELECT Id, Name, DISE_Account_No__c,
                CT_Organisation_Container__c, MB_Organisation_Container__c,
                SFAccountId__c
                FROM AC_Container__c
                WHERE DISE_Account_No__c = :DISEAccountNumber
                LIMIT 1000];
            //
            // Merge all accounts
            //
            for (AC_Subscription__c accountSubscription : accountSubscriptions)
            {
                addToSet(accountIds, accountSubscription.AC_Container__r);
            }

            for (AC_Container__c accountContainer : accountContainers)
            {
                addToSet(accountIds, accountContainer);
            }
            //
            // If there is not accounts then it should return null
            //
            if (accountIds.size() == 0)
            {
                accountIds = null;
            }
        }
        return accountIds;
    }

    //--------------------------------------------------------------------------
    // Get account Ids with company name
    //--------------------------------------------------------------------------
    private static Set<Id> getAccountIdsWithName(String name, Set<Id> filter)
    {
        if (String.isNotBlank(name))
        {
            String query = '%' + name + '%';
            Map<Id, Account> accountMap = null;
            if (filter != null)
            {
                accountMap = new Map<Id, Account>([
                    SELECT Id
                    FROM Account
                    WHERE Id IN :filter
                    AND Name LIKE :query]);
            }
            else
            {
                accountMap = new Map<Id, Account>([
                    SELECT Id
                    FROM Account
                    WHERE Name LIKE :query
                    LIMIT 1000]);
            }
            filter = setFilter(filter, accountMap.keySet());
        }
        return filter;
    }

    //--------------------------------------------------------------------------
    // Get account Ids with post code
    //--------------------------------------------------------------------------
    private static Set<Id> getAccountIdsWithPostCode(String postCode, Set<Id> filter)
    {
        if (String.isNotEmpty(postCode))
        {
            String query = '%' + postCode  + '%';
            Map<Id, Account> accountMap = null;
            if (filter != null)
            {
                accountMap = new Map<Id, Account>([
                        SELECT Id
                        FROM Account
                        WHERE Id IN :filter
                        AND BillingPostalCode LIKE :query]);
            }
            else
            {
                accountMap = new Map<Id, Account>([
                        SELECT Id
                        FROM Account
                        WHERE BillingPostalCode LIKE :query]);
            }
            filter = setFilter(filter, accountMap.keySet());
        }
        return filter;
    }

    //--------------------------------------------------------------------------
    // Set filter with values. If filter doesn't exists create new
    // 1. If there is no accounts return old filter
    // 2. Otherwise return retrieved values
    //--------------------------------------------------------------------------
    private static Set<Id> setFilter(Set<Id> filter, Set<Id> accountIds)
    {
        if (accountIds.size() > 0)
        {
            if (filter == null)
            {
                filter = new Set<Id>(accountIds);
            }
            else
            {
                filter.clear();
                filter.addAll(accountIds);
            }
        }
        return filter;
    }

    //--------------------------------------------------------------------------
    // Get accounts from Ids
    //--------------------------------------------------------------------------
    public static List<Account> getAccountsFromIds(Set<Id> accountIds)
    {
        List<Account> accounts = new List<Account>();
        if (accountIds != null)
        {
            //
            // Get accounts all account with account ids            
            //            
            accounts.addAll(
                    [SELECT Id, Name, DISE_Account_No__c, BillingStreet, Owner.Sales_Channel__c, Business_Area__c,
                    BillingCity, BillingCountry, BillingPostalCode,
                    (SELECT Id, Name, FirstName, LastName,
                     Phone, Email FROM Contacts LIMIT 1)
                    FROM Account WHERE Id IN :accountIds]);
        }
        return accounts;
    }
}