@isTest
private class TestUnifyBatchConfigUpload{

	static testMethod void excelValueTest() {

		Test.startTest();
		string str = UnifyBatchConfigUpload.excelValue('a ');

		System.assert(str=='a');


		str = UnifyBatchConfigUpload.excelValue('');

		System.assert(str=='');

		str = UnifyBatchConfigUpload.excelValue('#N/A');

		System.assert(str=='');
		Test.stopTest();
	}


static testMethod void prepareSiteObjectBasedOnSiteNameTest() {
	 	Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp;

        cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c(Name = 'Bundle', cscfgc__Opportunity__c = opp.Id);
      	insert(bundle);

        Location__c loc = new Location__c();
        loc.Unify_Unique_Site_Name__c = 'test';
        insert loc;

        TestUnifyHelper.setupCustomSettings();

		Test.startTest();

		try{
			UnifyBatchConfigUpload.prepareSiteObjectBasedOnSiteName(opp.Id, '', 'test', bundle.Id);
		} catch (CustomValidationException e){

		}

	}

	static testMethod void processPillarTest() {

		cscfgc__Product_Bundle__c bundle = TestUnifyHelper.createProductBundle();

		Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();
		rec1.Batch_Id__c ='123';
		rec1.Product_Bundle__c = bundle.Id;
		rec1.Single_Record__c='test \t test \t test \t test \t WAN \t test \t Connectivity \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';

		insert rec1;

        TestUnifyHelper.setupCustomSettings();

		Test.startTest();

		UnifyBatchConfigUpload.processPillar(rec1);

		//SingleRecord = null
		rec1.Single_Record__c='';
		update rec1;
		UnifyBatchConfigUpload.processPillar(rec1);

		//fieldsVal  != numberConfCols
		rec1.Single_Record__c='test \t test \t test \t';
		update rec1;
		UnifyBatchConfigUpload.processPillar(rec1);

		//fieldsVal[0] = null
		rec1.Single_Record__c='#N/A\t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
		update rec1;
		UnifyBatchConfigUpload.processPillar(rec1);

		//fieldsVal[4] = null
		rec1.Single_Record__c='test \t test \t test \t test \t #N/A \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
		update rec1;
		UnifyBatchConfigUpload.processPillar(rec1);

		//fieldsVal[4] is bad data
		rec1.Single_Record__c='test \t test \t test \t test \t aaa \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
		update rec1;
		UnifyBatchConfigUpload.processPillar(rec1);

		//fieldsVal[6] = null
		rec1.Single_Record__c='test \t test \t test \t test \t WAN \t test \t #N/A \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
		update rec1;
		UnifyBatchConfigUpload.processPillar(rec1);

		//fieldsVal[6] is bad data
		rec1.Single_Record__c='test \t test \t test \t test \t WAN \t test \t aaa \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
		update rec1;
		UnifyBatchConfigUpload.processPillar(rec1);

		Test.stopTest();
	}


	static testMethod void prepareSiteObjectBasedOnOppLocTest() {

	 	TestUnifyHelper.setupCustomSettings();

	 	Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp;

        Location__c loc = new Location__c();
        loc.Unify_Unique_Site_Name__c = 'test';
        loc.Opportunity__c = opp.Id;
        insert loc;


      	cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c(Name = 'Bundle', cscfgc__Opportunity__c = opp.Id);
      	insert bundle;

		Unify_Opportunity_Location__c uol = new Unify_Opportunity_Location__c(Opportunity__c=opp.Id, Location__c=loc.Id);
		insert uol;

		UnifyBatchConfigUpload.prepareSiteObjectBasedOnOppLoc(uol.Id, 'test' , bundle.Id);

	}

	static testMethod void createHardwarePillar(){

		TestUnifyHelper.setupCustomSettings();

		Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp;

		Location__c loc = new Location__c();
		loc.Unify_Unique_Site_Name__c='test';
        insert loc;

		Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();
		rec1.Batch_Id__c ='123';
		insert rec1;

		Unify_Hardware__c hard = new Unify_Hardware__c();
		hard.Opportunity__c=opp.Id;
		hard.Name='test';

		Unify_Site__c siteRec = new Unify_Site__c();

		cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();
		bundle.cscfgc__Opportunity__c=opp.Id;

		String[] fieldsVals = new List<String>{'test', 'test','test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createHardwarePillar(rec1, fieldsVals, siteRec, TestUnifyHelper.createHardwarePillarProductDefinitionMock(), bundle);

        //fields[25] is ''
		String[] fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','','test','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createHardwarePillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createHardwarePillarProductDefinitionMock(), bundle);

		//fields[24] is ''
		fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','','test','test','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createHardwarePillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createHardwarePillarProductDefinitionMock(), bundle);

        //fields[28] is not money
		fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','Laaaa','L1000','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createHardwarePillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createHardwarePillarProductDefinitionMock(), bundle);
	}

	static testMethod void createConnectivityPillar(){

		TestUnifyHelper.setupCustomSettings();

		Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Waiting for Qualification';
        insert opp;

		Location__c loc = new Location__c();
		loc.Unify_Unique_Site_Name__c='test';
        insert loc;

		Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();
		rec1.Batch_Id__c ='123';
		insert rec1;

		Unify_Opportunity_Location__c uol = new Unify_Opportunity_Location__c();
		uol.Opportunity__c=opp.Id;
		uol.Location__c=loc.Id;
		insert uol;

		Unify_Connectivity__c uc = new Unify_Connectivity__c();
		uc.Resilience__c='test';
		uc.Access_Type__c='test';
		uc.Access_Speed__c='test';
		insert uc;

		Unify_Site__c siteRec = new Unify_Site__c();

		cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();
		bundle.cscfgc__Opportunity__c=opp.Id;

		String[] fieldsVals = new List<String>{'test', 'test','test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createConnectivityPillar(rec1, fieldsVals, siteRec, TestUnifyHelper.createConnectivityPillarProductDefinitionMock(), bundle);

		//fields[10] is ''
		String[] fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createConnectivityPillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createConnectivityPillarProductDefinitionMock(), bundle);

		//fields[25] is ''
		fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','','test','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createConnectivityPillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createConnectivityPillarProductDefinitionMock(), bundle);

		//fields[26] is ''
		fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createConnectivityPillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createConnectivityPillarProductDefinitionMock(), bundle);

		//fields[29] is not money
		fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','Laaaa','L1000','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createConnectivityPillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createConnectivityPillarProductDefinitionMock(), bundle);

		//fields[29] is not money
		fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','Laaaa','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createConnectivityPillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createConnectivityPillarProductDefinitionMock(), bundle);
	}

	static testMethod void createMaintenancePillar(){

		TestUnifyHelper.setupCustomSettings();

		Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();
		rec1.Batch_Id__c ='123';
		insert rec1;

		Unify_Maintenance__c um = new Unify_Maintenance__c();
		um.DISE_Bill_Label__c='test';
		um.Solution__c='MWAN';
		um.Type__c='EP';
		um.Time__c='2';
		um.Availability__c='24X7';
		insert um;

		String[] fieldsVals = new List<String>{'test', 'test','test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		Unify_Site__c siteRec = new Unify_Site__c();
		cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();


		UnifyBatchConfigUpload.createMaintenancePillar(rec1, fieldsVals, siteRec, TestUnifyHelper.createMaintenancePillarProductDefinitionMock(), bundle);

		//fields[29] is not money
		String[] fieldsVals2 = new List<String>{'test', 'test','test','MWAN','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','Laaaa','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createMaintenancePillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createMaintenancePillarProductDefinitionMock(), bundle);
	}

	static testMethod void createManagedServicesPillar(){
		TestUnifyHelper.setupCustomSettings();
		Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();
		rec1.Batch_Id__c ='123';
		insert rec1;

		String[] fieldsVals = new List<String>{'test', 'test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','L10,400','test','test','test','test','test','test','test'};
		Unify_Site__c siteRec = new Unify_Site__c();
		cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();

		UnifyBatchConfigUpload.createManagedServicesPillar(rec1, fieldsVals, siteRec, TestUnifyHelper.createManagedServicesPillarProductDefinitionMock(), bundle);

		//fields[29] is not money
		String[] fieldsVals2 = new List<String>{'test', 'test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','Laaaa','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createManagedServicesPillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createManagedServicesPillarProductDefinitionMock(), bundle);
	}


	static testMethod void createProfessionalServicesPillar(){

		TestUnifyHelper.setupCustomSettings();

		Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();
		rec1.Batch_Id__c ='123';
		insert rec1;

		String[] fieldsVals = new List<String>{'test', 'test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','test','test','test','test','test','test','test','test'};
		Unify_Site__c siteRec = new Unify_Site__c();
		cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();

		UnifyBatchConfigUpload.createProfessionalServicesPillar(rec1, fieldsVals, siteRec, TestUnifyHelper.createProfessionalServicesPillarProductDefinitionMock(), bundle);

		//fields[28] is not money
		String[] fieldsVals2 = new List<String>{'test', 'test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','Laaa','test','test','test','test','test','test','test','test'};
		UnifyBatchConfigUpload.createProfessionalServicesPillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createProfessionalServicesPillarProductDefinitionMock(), bundle);
	}


    static testMethod void processPilarMissingValidationTestsAndProdDef(){

    	TestUnifyHelper.setupCustomSettings();
    	TestUnifyHelper.createMaintenancePillarProductDefinitionMock();
    	TestUnifyHelper.createConnectivityPillarProductDefinitionMock();
    	TestUnifyHelper.createManagedServicesPillarProductDefinitionMock();
    	TestUnifyHelper.createProfessionalServicesPillarProductDefinitionMock();
    	TestUnifyHelper.createHardwarePillarProductDefinitionMock();

    	cscfgc__Product_Bundle__c bundle = TestUnifyHelper.createProductBundle();
        Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();

        Unify_Opportunity_Location__c uol = TestUnifyHelper.createOppLocForSelOpp(bundle.cscfgc__Opportunity__c);

        Test.startTest();

        //if(isExcelFieldNull(fieldsVals[4]))
        rec1 = new Unify_Upload_Single_Entity__c();
        rec1.Batch_Id__c ='123';
        rec1.Product_Bundle__c = bundle.Id;
        rec1.Single_Record__c=uol.Name +'\t test \t test \t test \t\ttest\t\t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
        insert rec1;

        UnifyBatchConfigUpload.processPillar(rec1);

        //if(isExcelFieldNull(fieldsVals[6])){

        rec1 = new Unify_Upload_Single_Entity__c();
        rec1.Batch_Id__c ='123';
        rec1.Product_Bundle__c = bundle.Id;
        rec1.Single_Record__c=uol.Name +'\t test \t test \t test \tWAN\ttest\t\t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';

        insert rec1;

        UnifyBatchConfigUpload.processPillar(rec1);

        //if(isExcelFieldNull(fieldsVals[27])){

        rec1 = new Unify_Upload_Single_Entity__c();
        rec1.Batch_Id__c ='123';
        rec1.Product_Bundle__c = bundle.Id;
        rec1.Single_Record__c=uol.Name +'\t test \t test \t test \tWAN\ttest\tMaintenance\t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t\t\t test \t test \t test \t test \t test \t test';
        insert rec1;

        UnifyBatchConfigUpload.processPillar(rec1);


        //wrong quantity

        rec1 = new Unify_Upload_Single_Entity__c();
        rec1.Batch_Id__c ='123';
        rec1.Product_Bundle__c = bundle.Id;
        rec1.Single_Record__c=uol.Name +'\t test \t test \t test \tWAN\ttest\tMaintenance\t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \twe\tew\t test \t test \t test \t test \t test \t test';
        insert rec1;

        UnifyBatchConfigUpload.processPillar(rec1);

        //matching with prodDef
        for(String pil1 : UnifyConfig.mPillars2Name().keySet()){
            rec1 = new Unify_Upload_Single_Entity__c();
	        rec1.Batch_Id__c ='123';
	        rec1.Product_Bundle__c = bundle.Id;
	        rec1.Single_Record__c=uol.Name +'\t test \t test \t test \tWAN\ttest\t'+ pil1 + '\t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t1\t1\t test \t test \t test \t test \t test';
	        insert rec1;
	        UnifyBatchConfigUpload.processPillar(rec1);
        }

        /*
        rec1 = new Unify_Upload_Single_Entity__c();
        rec1.Batch_Id__c ='123';
        rec1.Product_Bundle__c = bundle.Id;
        rec1.Single_Record__c='test \t test \t test \t test \t WAN \ttest\ttest\t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
        insert rec1;

        UnifyBatchConfigUpload.processPillar(rec1);
        */
    }

    static testMethod void createOtherPillarTest(){
    	TestUnifyHelper.setupCustomSettings();

        Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();
        rec1.Batch_Id__c ='123';
        insert rec1;

        String[] fieldsVals = new List<String>{'test', 'test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','L10,400','test','test','test','test','test','test','test','test'};
        Unify_Site__c siteRec = new Unify_Site__c();
        cscfgc__Product_Bundle__c bundle = new cscfgc__Product_Bundle__c();

        UnifyBatchConfigUpload.createProfessionalServicesPillar(rec1, fieldsVals, siteRec, TestUnifyHelper.createProfessionalServicesPillarProductDefinitionMock(), bundle);

        String[] fieldsVals2 = new List<String>{'test', 'test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','test','123','Laaa','test','test','test','test','test','test','test','test'};
        UnifyBatchConfigUpload.createOtherPillar(rec1, fieldsVals2, siteRec, TestUnifyHelper.createProfessionalServicesPillarProductDefinitionMock(), bundle);
    }

    static testMethod void testBatchProcess(){
    	cscfgc__Product_Bundle__c bundle = TestUnifyHelper.createProductBundle();
        Unify_Upload_Single_Entity__c rec1 = new Unify_Upload_Single_Entity__c();
        Unify_Opportunity_Location__c uol = TestUnifyHelper.createOppLocForSelOpp(bundle.cscfgc__Opportunity__c);

        String bId = '100200';

        rec1 = new Unify_Upload_Single_Entity__c();
        rec1.Batch_Id__c = bId;
        rec1.Product_Bundle__c = bundle.Id;
        rec1.Single_Record__c=uol.Name +'\t test \t test \t test \t\ttest\t\t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test \t test';
        insert rec1;

        Test.startTest();

    	UnifyBatchConfigUpload batch = new UnifyBatchConfigUpload();
        batch.productBundle = bundle.Id;
        batch.batchId = bId;
        batch.submittedBy = System.Userinfo.getUserId();
        ID batchprocessid = Database.executeBatch(batch, 1);

    }
}