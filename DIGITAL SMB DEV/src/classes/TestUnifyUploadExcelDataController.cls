@isTest
private class TestUnifyUploadExcelDataController {

    static testMethod void uploadHBsTest() {

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp;

        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('context', 'hb');
        mPar.put('id', opp.Id);

        UnifyUploadExcelDataController controller = new UnifyUploadExcelDataController();
        controller.excelContent='test \t test \t test \t test \n test \t test \t test \t test \n test \t test \t 1 \t £100.00 \n';
        controller.uploadHBs();


        //no excel content
        controller.excelContent=null;
        controller.uploadHBs();

        //row[1]column[1] > 30 chars
        controller.excelContent='very  still to short \t very long test desciption used for test to fail the code and make a rollback and is the text still to short ?? \t test \t test \n test \t test \t test \t test \n test \t test \t 1 \t £100.00 \n';
        controller.uploadHBs();

        //5 columns selected
        controller.excelContent='test \t test \t test \t test \t test5 \n test \t test \t test \t test \t test5 \n test \t test \t 1 \t £100.00 \test5 \n';
        controller.uploadHBs();

        //bad data
        controller.excelContent='test';
        controller.uploadHBs();
    }

      static testMethod void uploadConfigs() {

        cscfgc__Product_Bundle__c pb = TestUnifyHelper.createProductBundle();

        Map<String, String> mPar = System.currentPageReference().getParameters();
        mPar.put('context', 'config');
        mPar.put('id', pb.Id);

        UnifyUploadExcelDataController controller = new UnifyUploadExcelDataController();
        controller.excelContent='test \t test \t test \t test \t WAN \t test \t Connectivity \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';

        controller.uploadConfigs();

        //no data
        controller.excelContent=null;
        controller.uploadConfigs();
    }

     static testMethod void uploadSites() {

        Opportunity opp = TestUnifyHelper.createOpportunity();

        Map<String, String> mPar = System.currentPageReference().getParameters();

        mPar.put('context', 'site');
        mPar.put('id', opp.Id);

        UnifyUploadExcelDataController controller = new UnifyUploadExcelDataController();
        controller.excelContent='CENTRAL ACCOUNT SERVICES \t \t \t \t \t  \t  \t  \t  \t  \t  \t  \t  \t  \t  \n Site1 \t test \t test \t test \t test \t test \t test \t test \t test \t test \t M11AA \t test \t test \t test \t aaa2@test.com \n Site2 \t test \t test \t test \t test \t test \t test \t test \t test \t test \t M11AA \t test \t test \t test \t aaa@test.com';
        controller.uploadSites();

        controller.excelContent='CENTRAL ACCOUNT SERVICES \t \t \t \t \t  \t  \t  \t  \t  \t  \t  \t  \t  \t  \n Site1 \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \n Site2 \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
        controller.uploadSites();

        controller.excelContent='CENTRAL ACCOUNT SERVICES \t \t \t \t \t  \t  \t  \t  \t  \t  \t  \t  \t  \t  \n Site1 \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \n Site2 \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
        controller.uploadSites();

        //no data
        controller.excelContent=null;
        controller.uploadSites();

        //number of fields != 15
        controller.excelContent='test \t test \n test \t test \n test \t test \n';
        controller.uploadSites();

        //bad data
        controller.excelContent='\n \n \n';
        controller.uploadSites();

       //siteName = null
        controller.excelContent=' \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \n test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \n';
        controller.uploadSites();

        //CENTRAL ACCOUNT SERVICES fields contain data
        controller.excelContent='CENTRAL ACCOUNT SERVICES \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \n test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \n';
        controller.uploadSites();

        //page name already used
        controller.excelContent='test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \n test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \n';
        controller.uploadSites();

    }

    static testMethod void constructorTest() {
        UnifyUploadExcelDataController controller = new UnifyUploadExcelDataController();
	}

}