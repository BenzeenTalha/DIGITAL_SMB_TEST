global class massUpdateProdDetail implements Database.Batchable<sObject> {
    global String query;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (scope.size()>0) {
            O2_Product_Detail__c[] prods = new O2_Product_Detail__c[0];
            for (sObject rec: scope) {
                O2_Product_Detail__c prd = (O2_Product_Detail__c) rec;
                System.debug('### OUTPUT >>>>> prd:'+prd);
                prd.Description_of_Technology_Supported__c = String.valueOf(rec.get('Description_of_Technology_Supported__c'));
                prods.add(prd);
            }
            update prods;
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    public static testMethod void testBatchUpdate() {
        //### RETRIEVE REFERENCE DATA TO BE USED IN THE TESTS ###
        RecordType[] lsOpptyRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity'];
        Map<String, Id> opptyRecTypes = new Map<String, Id>();
        for (RecordType r: lsOpptyRecTypes) {opptyRecTypes.put(r.Name, r.Id);}
        RecordType[] lsAccRecTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account'];
        Map<String, Id> accRecTypes = new Map<String, Id>();
        for (RecordType r: lsAccRecTypes) {accRecTypes.put(r.Name, r.Id);}
        //### CREATE TEST SALES DATA ###
        //create a test account record
        Account acc = new Account();
        acc.Name = 'APEXTESTACC001';
        acc.RecordTypeId = accRecTypes.get('Customer Account');
        acc.NumberOfEmployees = 10;
        insert acc;
        String strAccId = acc.Id;
        //create a test opportunity record
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = opptyRecTypes.get('Default');
        opp.Name = 'APEXTESTOPPTY001';
        opp.Type = 'New Business';
        opp.AccountId = strAccId;
        opp.StageName = 'Awareness of Needs';
        opp.CloseDate = Date.today()+1;
        opp.LeadSource = 'Self Generated';
        opp.Use_of_CCV__c = 'CCV Not Used';
        opp.CCV_Not_used_reason__c = 'Other';
        opp.CCV_Not_used_comments__c = 'APEXTESTOPPTY001_CCV_NOT_USED_COMMENTS';
        opp.TotalOpportunityQuantity = 10;
        insert opp;
        String strOpptyId = opp.Id;
        //create multiple test O2 product detail records associated to the Opportunity
        O2_Product_Detail__c[] prods = new O2_Product_Detail__c[0];
        for (integer i=0; i<15; i++) {
            O2_Product_Detail__c prd = new O2_Product_Detail__c();
            prd.Opportunity__c = strOpptyId;
            prd.Product_Category__c = 'Landline & Mobile';
            prd.Product__c = 'Landline';
            prd.Quantity__c = (i+1)*10;
            prd.Length_of_Contract__c = '12 Months';
            prd.Revenue_per_Month__c = (i+1)*5;
            prd.Contribution_Against_Product__c = 30;
            prd.Description_of_Technology_Supported__c = 'APEXTESTO2PRODDETAIL001';
            prd.Total_Contract_Value__c = 100.00;
            prods.add(prd);
        }
        insert prods;
        massUpdateProdDetail rs = new massUpdateProdDetail();
        rs.query = 'SELECT Id, Name, Description_of_Technology_Supported__c FROM O2_Product_Detail__c where Opportunity__c=\''+strOpptyId+'\' LIMIT 50';
        Test.StartTest();
            Database.executeBatch(rs, 50);
        Test.StopTest();
        prods = [SELECT Id, Name FROM O2_Product_Detail__c WHERE Opportunity__c = :strOpptyId];
        System.assertEquals(15, prods.size());
        OpportunityProduct__c[] testOpptyProd = [SELECT Id, Name, Automation_UID__c FROM OpportunityProduct__c WHERE Opportunity__c=:strOpptyId];
        System.assertEquals(15, prods.size());        
    }
}