@isTest
public class TestUnifyHelper {
    public static void setupO2BObjects(){
        createOrderGroup();
    }
    public static void setupCustomSettings(){
        List<UnifyConfiguration__c> settingsToInsert = new List<UnifyConfiguration__c>();
        settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Other pillar dependency Shadow', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Other_pillar_dependency_Shadow__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Related Configuration Name', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Related_Configuration_Name__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Connectivity Options', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Connectivity_Options__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Other Supplier', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Other_Supplier__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Hardware Type', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Hardware_Type__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Minimum Price RC', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Minimum_Price_RC__c', Field_Type__c='NUMBER'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Service point name', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Service_point_name__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Maximum Price RC', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Maximum_Price_RC__c', Field_Type__c='NUMBER'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Available Other', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Available_Other__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Maximum Price NRC', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Maximum_Price_NRC__c', Field_Type__c='NUMBER'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Minimum Price NRC', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Minimum_Price_NRC__c', Field_Type__c='NUMBER'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Ancillary', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Ancillary__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Access ID', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Access_ID__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Bearer ID', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Bearer_ID__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Channels', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Channels__c', Field_Type__c='NUMBER'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Circuit ID', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Circuit_ID__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'CLI', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_CLI__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Comment', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Comment__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Connectivity Option Name', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Access_Option__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Customer Purchase Order', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Customer_Purchase_Order__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Description', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Description__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ECC Customer PO', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_ECC_Customer_PO__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Etherflow ID', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Etherflow_ID__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Etherway ID', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Etherway_ID__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Order Type', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Order_Type__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Quantity', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Quantity__c', Field_Type__c='NUMBER'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Solution', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Solution__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Supplier', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Supplier__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Supplier Purchase Order', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Supplier_Purchase_Order__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Translation', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Translation__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Type', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Access_Type__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Class', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_CPE_Class__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Device ID', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Device_ID__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Maintainer', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_CPE_Maintainer__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Manufacturer', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Manufacturer__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Part Code', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Part_Code__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Part Code Description', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Part_Code_Description__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Other Name', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Other_Name__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Professional Services Name', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Professional_Services_Name__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'A-End', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Site__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'B-End', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_B_End__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ECC Charge', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_ECC_Charge__c', Field_Type__c='NUMBER'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Hardware Bundle', DESCRIPTION__C = 'AttributeFieldMap', VALUE__C = 'Unify_Hardware_Bundle__c', Field_Type__c='TEXT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Daily Emails From Address', DESCRIPTION__C = 'Display Name for "from address" - DailySLAEmail.cls,DailyBillingTeamNotifications.cls', VALUE__C = 'dontreply@unifysaleforce.o2.com'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Fixed DISE Billing', DESCRIPTION__C = 'Fixed DISE Billing Team email address', VALUE__C = 'nina.katic@cloudsense.com'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Other/VAS', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'MWAN', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MWAN'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'WAN', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MWAN'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'MLAN', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MLAN'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'LAN', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MLAN'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'IPT', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MTEL'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'MIPT', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MTEL'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'MPBX', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MTEL'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PBX', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MTEL'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Security', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MSEC UK'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'General', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'ICTSolution'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Wireless', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'Managed Wireless'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Hosting', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'Managed Hosting'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'MSS Spain', DESCRIPTION__C = 'MQF SOLUTION', VALUE__C = 'MSEC Spain'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PillarName - Managed Hosting', DESCRIPTION__C = 'PillarName', VALUE__C = 'Hosting'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PillarName - Connectivity', DESCRIPTION__C = 'PillarName', VALUE__C = 'Connectivity'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PillarName - Hardware', DESCRIPTION__C = 'PillarName', VALUE__C = 'Hardware'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PillarName - Maintenance', DESCRIPTION__C = 'PillarName', VALUE__C = 'Maintenance'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PillarName - Monitoring', DESCRIPTION__C = 'PillarName', VALUE__C = 'Monitoring'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PillarName - Professional Services', DESCRIPTION__C = 'PillarName', VALUE__C = 'Professional Services'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PillarName - Other/VAS', DESCRIPTION__C = 'PillarName', VALUE__C = 'Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PillarName - Managed Services', DESCRIPTION__C = 'PillarName', VALUE__C = 'Monitoring'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Working Hours', DESCRIPTION__C = 'PublicHolidayHelper.cls', VALUE__C = '12'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Added to Billing System Warning Days', DESCRIPTION__C = 'Site - SLA', VALUE__C = '1'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Added to Billing System Target Days', DESCRIPTION__C = 'Site - SLA', VALUE__C = '5'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - MWAN', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Connectivity,Hardware,Monitoring,Maintenance,Professional Services,Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - MLAN', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Connectivity,Hardware,Monitoring,Maintenance,Professional Services,Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - MTEL', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Hardware,Monitoring,Maintenance,Professional Services,Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - MSEC UK', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Hardware,Monitoring,Maintenance,Professional Services,Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - ICTSolution', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Hardware,Monitoring,Maintenance,Professional Services,Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - MSERV', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Hardware,Monitoring,Maintenance,Professional Services,Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - MSEC Spain', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Hardware,Monitoring,Maintenance,Professional Services,Other'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - Managed Wireless', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Hardware,Monitoring,Maintenance,Professional Services,Other,Connectivity'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'SolutionPillars - Managed Hosting', DESCRIPTION__C = 'SolutionPillars', VALUE__C = 'Hardware,Monitoring,Maintenance,Professional Services,Other,Connectivity'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Cisco', DESCRIPTION__C = 'Supplier', VALUE__C = 'Cisco'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Virgin Media', DESCRIPTION__C = 'Supplier', VALUE__C = 'Virgin Media'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Telefonica Soluciones', DESCRIPTION__C = 'Supplier', VALUE__C = 'Telefonica Soluciones'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Comstor', DESCRIPTION__C = 'Supplier', VALUE__C = 'Comstor'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Ingram', DESCRIPTION__C = 'Supplier', VALUE__C = 'Ingram'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Azlan', DESCRIPTION__C = 'Supplier', VALUE__C = 'Azlan'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'O2', DESCRIPTION__C = 'Supplier', VALUE__C = 'O2'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'BT', DESCRIPTION__C = 'Supplier', VALUE__C = 'BT'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Maintel', DESCRIPTION__C = 'Supplier', VALUE__C = 'Maintel'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Datapoint', DESCRIPTION__C = 'Supplier', VALUE__C = 'Datapoint'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Kcom', DESCRIPTION__C = 'Supplier', VALUE__C = 'Kcom'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'TalkTalk', DESCRIPTION__C = 'Supplier', VALUE__C = 'TalkTalk'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'O2 Ireland', DESCRIPTION__C = 'Supplier', VALUE__C = 'O2 Ireland'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Arrow', DESCRIPTION__C = 'Supplier', VALUE__C = 'Arrow'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'O2 Wifi', DESCRIPTION__C = 'Supplier', VALUE__C = 'O2 Wifi'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Fluidata', DESCRIPTION__C = 'Supplier', VALUE__C = 'Fluidata'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'BT Wholesale', DESCRIPTION__C = 'Supplier', VALUE__C = 'BT Wholesale'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'Capita', DESCRIPTION__C = 'Supplier', VALUE__C = 'Capita'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ContractAdminITPSLA', DESCRIPTION__C = '', VALUE__C = '240'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ContractAdminITPSLAwarning', DESCRIPTION__C = '', VALUE__C = '144'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ContractAdminSLA', DESCRIPTION__C = '', VALUE__C = '24'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ContractAdminSLAwarning', DESCRIPTION__C = '', VALUE__C = '18'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'CPMSLA', DESCRIPTION__C = '', VALUE__C = '24'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'CPMSLAwarning', DESCRIPTION__C = '', VALUE__C = '18'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'OMSLA', DESCRIPTION__C = '', VALUE__C = '24'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'OMSLAwarning', DESCRIPTION__C = '', VALUE__C = '18'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PCOSLA', DESCRIPTION__C = '', VALUE__C = '24'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'PCOSLAwarning', DESCRIPTION__C = '', VALUE__C = '18'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ContractManagerSLA', DESCRIPTION__C = '', VALUE__C = '24'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ContractManagerSLAwarning', DESCRIPTION__C = '', VALUE__C = '18'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'UnifyOpportunityRecordTypeId', DESCRIPTION__C = '', VALUE__C = '012W00000000MSr'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'ORDER_COMPLETED_STATUS', DESCRIPTION__C = '', VALUE__C = 'Order complete'));
		settingsToInsert.add(new UnifyConfiguration__c(NAME = 'BILLING_START_DATE_SLA', DESCRIPTION__C = '', VALUE__C = 'Billing start date'));
        insert settingsToInsert;
    }

    public static Account createAccount(){
        Account newAcc = new Account(Name = 'Test Account');
        insert newAcc;
        return newAcc;
    }

    public static Opportunity createOpportunity(){
        Opportunity[] existing = [SELECT Id, AccountId, CloseDate, StageName, Unify_Solution__c, RecordTypeId FROM Opportunity WHERE RecordType.Name = 'Unify'];
        if(existing.size() > 0){
            return existing[0];
        }
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = createAccount().Id, CloseDate = System.today(), StageName = 'Waiting for Qualification', Unify_Solution__c = 'MWAN; MLAN');
        opp.RecordTypeId = [Select Id
                            from RecordType
                            where Name = 'Unify' and sObjectType = 'Opportunity' limit 1][0].Id;
        insert opp;
        opp = [select Id, AccountId, CloseDate, StageName, Unify_Solution__c, RecordTypeId from Opportunity where Id = :opp.Id];
        return opp;
    }

    public static cscfgc__Product_Bundle__c createProductBundle(){
        Opportunity opp = createOpportunity();
        cscfgc__Product_Bundle__c[] existing = [Select id from cscfgc__Product_Bundle__c];
        if(existing.size() > 0){
            return existing[0];
        }
        cscfgc__Product_Bundle__c pb = new cscfgc__Product_Bundle__c();
        pb.cscfgc__Opportunity__c = opp.Id;
        pb.cscfgc__Synchronised_with_Opportunity__c = true;
        insert pb;
        return pb;
    }

    public static cscfgc__Product_Configuration__c createProductConfiguration(){
        cscfgc__Product_Bundle__c pb = createProductBundle();
        cscfgc__Product_Configuration__c conf = new cscfgc__Product_Configuration__c();
        conf.cscfgc__Product_Bundle__c = pb.Id;

        insert conf;
        conf = [Select Id, cscfgc__Product_Bundle__c, cscfgc__Product_Bundle__r.cscfgc__Synchronised_with_Opportunity__c, cscfgc__Product_Bundle__r.cscfgc__Opportunity__c from cscfgc__Product_Configuration__c where Id = :conf.Id];

        return conf;
    }

    public static Location__c createInstalLocationForAccount(Id accId){
        Location__c loc = new Location__c();
        loc.Account__c = accId;
        loc.Type__c = 'Installation';
        loc.PAF_Postcode__c = 'M11AA';
        loc.Unify_Unique_Site_Name__c = 'TESTuniqueName';
        insert loc;
        return loc;
    }

    public static Unify_Opportunity_Location__c createOppLocForSelOpp(Id oppId){
        Opportunity opp = [select Id, AccountId from Opportunity where Id = :oppId];
        Location__c loc = createInstalLocationForAccount(opp.AccountId);
        Unify_Opportunity_Location__c ol = new Unify_Opportunity_Location__c(Location__c = loc.Id, Opportunity__c = oppId, Name = loc.Unify_Unique_Site_Name__c);
        insert ol;
        return ol;
    }

    public static Order_Group__c createOrderGroup(){
        setupCustomSettings();
        //Insert user
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User u = new User();
        u.email = 'test@test.com';
        u.username = 'unifytest@test.com';
        u.firstname = 'Test';
        u.lastname = 'Test';
        u.alias = 'Test';
        u.languagelocalekey='en_US';
        u.emailencodingkey='UTF-8';
        u.localesidkey='en_GB';
        u.timezonesidkey='Europe/London';
        u.ProfileId = p.Id;
        insert u;

        Order_Group__c og = new Order_Group__c();
        og.Opportunity__c = createOpportunity().Id;
		og.RecordTypeId = [Select Id
                            from RecordType
                            where Name = 'Unify' and sObjectType = 'Order_Group__c' limit 1][0].Id;
        insert og;
        og.Unify_Project_Coordinator__c = u.Id;
        update og;

        return og;
    }
    public static Unify_Hardware__c createHardwareBundleMasterWithChildren(){
        Opportunity opp = createOpportunity();

        Unify_Hardware__c hb = new Unify_Hardware__c();
        hb.RecordTypeId = [select Id from RecordType where SobjectType = 'Unify_Hardware__c' and DeveloperName = 'Hardware_Bundle_Master' limit 1].Id;
        hb.Name = 'Test HB Master';
        hb.Bundle_Description__c= 'test DISE label';
        hb.Opportunity__c = opp.Id;

        insert hb;

        Unify_Hardware_Item__c[] his = new Unify_Hardware_Item__c[]{};
        Unify_Hardware_Item__c hi1 = new Unify_Hardware_Item__c();
        Unify_Hardware_Item__c hi2 = new Unify_Hardware_Item__c();
        hi1.Unify_Hardware_Bundle__c = hb.Id;
        hi2.Unify_Hardware_Bundle__c = hb.Id;
        hi1.Quantity__c = 1;
        hi2.Quantity__c = 2;
        hi1.Description__c = 'desc1';
        hi2.Description__c = 'desc2';
        hi1.Unit_Cost__c = 10;
        hi2.Unit_Cost__c = 20;
        hi1.Name = 'test HI1';
        hi2.Name = 'test HI2';
        his.add(hi1);
        his.add(hi2);
        insert his;

        return hb;
    }

    public static cscfgc__Product_Category__c createUnifyProductCategory(){
        cscfgc__Product_Category__c[] pcs = [select Id, Name from cscfgc__Product_Category__c where Name = 'Unify'];
        if(pcs.size() > 0){
            return pcs[0];
        } else {
            cscfgc__Product_Category__c pc = new cscfgc__Product_Category__c();
            pc.Name = 'Unify';
            insert pc;
            return pc;
        }
    }

    public static cscfgc__Product_Definition__c createMaintenancePillarProductDefinitionMock(){
            cscfgc__Product_Category__c pc = createUnifyProductCategory();

            cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
            pd.cscfgc__Description__c='test';
            pd.cscfgc__Product_Category__c = pc.Id;
            pd.cscfgc__Label__c = UnifyConfig.mPillars2Name().get('Maintenance');
            pd.Name = UnifyConfig.mPillars2Name().get('Maintenance');
            insert pd;

            pd=createCommonAttributes(pd);

            cscfgc__Attribute_Definition__c[] attr2ins = new cscfgc__Attribute_Definition__c[]{};
            cscfgc__Attribute_Definition__c atrtype = new cscfgc__Attribute_Definition__c();
            atrtype.cscfgc__Product_Definition__c = pd.Id;
            atrtype.name='Type';
            attr2ins.add(atrtype);

            cscfgc__Attribute_Definition__c availability = new cscfgc__Attribute_Definition__c();
            availability.cscfgc__Product_Definition__c = pd.Id;
            availability.name='Availability';
            attr2ins.add(availability);

            cscfgc__Attribute_Definition__c timez = new cscfgc__Attribute_Definition__c();
            timez.cscfgc__Product_Definition__c = pd.Id;
            timez.name='Time';
            attr2ins.add(timez);

            cscfgc__Attribute_Definition__c dise = new cscfgc__Attribute_Definition__c();
            dise.cscfgc__Product_Definition__c = pd.Id;
            dise.name='DISE CODE value';
            dise.cscfgc__Default_Value__c='test123';
            attr2ins.add(dise);


            cscfgc__Attribute_Definition__c dise2 = new cscfgc__Attribute_Definition__c();
            dise2.cscfgc__Product_Definition__c = pd.Id;
            dise2.name='DISE CODE';
            dise2.cscfgc__Default_Value__c='test123';
            attr2ins.add(dise2);

            cscfgc__Attribute_Definition__c configId = new cscfgc__Attribute_Definition__c();
            configId.cscfgc__Product_Definition__c = pd.Id;
            configId.name='Configuration Id';
            attr2ins.add(configId);

            insert attr2ins;

            return pd;
        }

        public static cscfgc__Product_Definition__c createProfessionalServicesPillarProductDefinitionMock(){

            cscfgc__Product_Category__c pc = createUnifyProductCategory();

            cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
            pd.cscfgc__Description__c='test';
            pd.cscfgc__Product_Category__c = pc.Id;
            pd.cscfgc__Label__c = UnifyConfig.mPillars2Name().get('Professional Services');
            pd.Name = UnifyConfig.mPillars2Name().get('Professional Services');
            insert pd;

            pd=createCommonAttributes(pd);

			cscfgc__Attribute_Definition__c[] attr2ins = new cscfgc__Attribute_Definition__c[]{};

            cscfgc__Attribute_Definition__c psa = new cscfgc__Attribute_Definition__c();
            psa.cscfgc__Product_Definition__c = pd.Id;
            psa.name='Professional Services Name';
            attr2ins.add(psa);

            cscfgc__Attribute_Definition__c uc = new cscfgc__Attribute_Definition__c();
            uc.cscfgc__Product_Definition__c = pd.Id;
            uc.name='Unit Cost';
            attr2ins.add(uc);

            insert attr2ins;

            return pd;
        }


        public static cscfgc__Product_Definition__c createManagedServicesPillarProductDefinitionMock(){

            cscfgc__Product_Category__c pc = createUnifyProductCategory();

            cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
            pd.cscfgc__Description__c='test';
            pd.cscfgc__Product_Category__c = pc.Id;
            pd.cscfgc__Label__c = UnifyConfig.mPillars2Name().get('Managed Services');
            pd.Name = UnifyConfig.mPillars2Name().get('Managed Services');
            insert pd;

            pd = createCommonAttributes(pd);

			cscfgc__Attribute_Definition__c[] attr2ins = new cscfgc__Attribute_Definition__c[]{};

            cscfgc__Attribute_Definition__c monitoring = new cscfgc__Attribute_Definition__c();
            monitoring.cscfgc__Product_Definition__c = pd.Id;
            monitoring.name = 'Monitoring Name';
            attr2ins.add(monitoring);

			cscfgc__Attribute_Definition__c classDef = new cscfgc__Attribute_Definition__c();
            classDef.cscfgc__Product_Definition__c = pd.Id;
            classDef.name = 'Class';
            classDef.cscfgc__Default_Value__c= '';
            attr2ins.add(classDef);

            insert attr2ins;

            return pd;
        }

        public static cscfgc__Product_Definition__c createHardwarePillarProductDefinitionMock(){

            cscfgc__Product_Category__c pc = createUnifyProductCategory();

            cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
            pd.cscfgc__Description__c='test';
            pd.cscfgc__Product_Category__c = pc.Id;
            pd.cscfgc__Label__c = UnifyConfig.mPillars2Name().get('Hardware');
            pd.Name = UnifyConfig.mPillars2Name().get('Hardware');
            insert pd;

            pd=createCommonAttributes(pd);

            cscfgc__Attribute_Definition__c[] attr2ins = new cscfgc__Attribute_Definition__c[]{};

            cscfgc__Attribute_Definition__c description = new cscfgc__Attribute_Definition__c();
            description.cscfgc__Product_Definition__c = pd.Id;
            description.name='Description';
            attr2ins.add(description);

            cscfgc__Attribute_Definition__c orderType = new cscfgc__Attribute_Definition__c();
            orderType.cscfgc__Product_Definition__c = pd.Id;
            orderType.name='Order Type';
            attr2ins.add(orderType);

            cscfgc__Attribute_Definition__c hBundle = new cscfgc__Attribute_Definition__c();
            hBundle.cscfgc__Product_Definition__c = pd.Id;
            hBundle.name='Hardware Bundle';
            attr2ins.add(hBundle);

            cscfgc__Attribute_Definition__c partCode = new cscfgc__Attribute_Definition__c();
            partCode.cscfgc__Product_Definition__c = pd.Id;
            partCode.name='Part Code';
            attr2ins.add(partCode);

            cscfgc__Attribute_Definition__c partCodeDesc = new cscfgc__Attribute_Definition__c();
            partCodeDesc.cscfgc__Product_Definition__c = pd.Id;
            partCodeDesc.name='Part Code Description';
            attr2ins.add(partCodeDesc);

            cscfgc__Attribute_Definition__c dise = new cscfgc__Attribute_Definition__c();
            dise.cscfgc__Product_Definition__c = pd.Id;
            dise.name='DISE CODE value';
            dise.cscfgc__Default_Value__c='test123';
            attr2ins.add(dise);

            cscfgc__Attribute_Definition__c dise2 = new cscfgc__Attribute_Definition__c();
            dise2.cscfgc__Product_Definition__c = pd.Id;
            dise2.name='DISE CODE';
            dise2.cscfgc__Default_Value__c='test123';
            attr2ins.add(dise2);

            cscfgc__Attribute_Definition__c configId = new cscfgc__Attribute_Definition__c();
            configId.cscfgc__Product_Definition__c = pd.Id;
            configId.name='Configuration Id';
            attr2ins.add(configId);

			cscfgc__Attribute_Definition__c classDef = new cscfgc__Attribute_Definition__c();
            classDef.cscfgc__Product_Definition__c = pd.Id;
            classDef.name='Class';
            classDef.cscfgc__Default_Value__c= '';
            attr2ins.add(classDef);

            insert attr2ins;

            return pd;
        }

        public static cscfgc__Product_Definition__c createConnectivityPillarProductDefinitionMock(){

            cscfgc__Product_Category__c pc = createUnifyProductCategory();

            cscfgc__Product_Definition__c pd = new cscfgc__Product_Definition__c();
            pd.cscfgc__Description__c='test';
            pd.cscfgc__Product_Category__c = pc.Id;
            pd.cscfgc__Label__c = UnifyConfig.mPillars2Name().get('Connectivity');
            pd.Name = UnifyConfig.mPillars2Name().get('Connectivity');
            insert pd;

            pd=createCommonAttributes(pd);

            cscfgc__Attribute_Definition__c[] attr2ins = new cscfgc__Attribute_Definition__c[]{};

            cscfgc__Attribute_Definition__c description = new cscfgc__Attribute_Definition__c();
            description.cscfgc__Product_Definition__c = pd.Id;
            description.name='Description';
            attr2ins.add(description);


            cscfgc__Attribute_Definition__c bend = new cscfgc__Attribute_Definition__c();
            bend.cscfgc__Product_Definition__c = pd.Id;
            bend.name='B-End';
            attr2ins.add(bend);

            cscfgc__Attribute_Definition__c co = new cscfgc__Attribute_Definition__c();
            co.cscfgc__Product_Definition__c = pd.Id;
            co.name='Connectivity Option';
            attr2ins.add(co);

            cscfgc__Attribute_Definition__c typez = new cscfgc__Attribute_Definition__c();
            typez.cscfgc__Product_Definition__c = pd.Id;
            typez.name='Type';
            attr2ins.add(typez);

            cscfgc__Attribute_Definition__c typec = new cscfgc__Attribute_Definition__c();
            typec.cscfgc__Product_Definition__c = pd.Id;
            typec.name='Type Copy';
            attr2ins.add(typec);

            cscfgc__Attribute_Definition__c orderType = new cscfgc__Attribute_Definition__c();
            orderType.cscfgc__Product_Definition__c = pd.Id;
            orderType.name='Order Type';
            attr2ins.add(orderType);

            cscfgc__Attribute_Definition__c ef = new cscfgc__Attribute_Definition__c();
            ef.cscfgc__Product_Definition__c = pd.Id;
            ef.name='EF';
            attr2ins.add(ef);

            cscfgc__Attribute_Definition__c af = new cscfgc__Attribute_Definition__c();
            af.cscfgc__Product_Definition__c = pd.Id;
            af.name='AF';
            attr2ins.add(af);

            cscfgc__Attribute_Definition__c af2 = new cscfgc__Attribute_Definition__c();
            af2.cscfgc__Product_Definition__c = pd.Id;
            af2.name='AF2';
            attr2ins.add(af2);

            cscfgc__Attribute_Definition__c af3 = new cscfgc__Attribute_Definition__c();
            af3.cscfgc__Product_Definition__c = pd.Id;
            af3.name='AF3';
            attr2ins.add(af3);

            cscfgc__Attribute_Definition__c af4 = new cscfgc__Attribute_Definition__c();
            af4.cscfgc__Product_Definition__c = pd.Id;
            af4.name='AF4';
            attr2ins.add(af4);

            cscfgc__Attribute_Definition__c rentalCost = new cscfgc__Attribute_Definition__c();
            rentalCost.cscfgc__Product_Definition__c = pd.Id;
            rentalCost.name='Rental Cost';
            attr2ins.add(rentalCost);

            cscfgc__Attribute_Definition__c marginArc = new cscfgc__Attribute_Definition__c();
            marginArc.cscfgc__Product_Definition__c = pd.Id;
            marginArc.name='Margin ARC';
            attr2ins.add(marginArc);

            cscfgc__Attribute_Definition__c cos = new cscfgc__Attribute_Definition__c();
            cos.cscfgc__Product_Definition__c = pd.Id;
            cos.name='Connectivity Options';
            attr2ins.add(cos);

            cscfgc__Attribute_Definition__c ao = new cscfgc__Attribute_Definition__c();
            ao.cscfgc__Product_Definition__c = pd.Id;
            ao.name='Available Other';
            attr2ins.add(ao);

            cscfgc__Attribute_Definition__c rc = new cscfgc__Attribute_Definition__c();
            rc.cscfgc__Product_Definition__c = pd.Id;
            rc.name='Related Configuration';
            attr2ins.add(rc);

            cscfgc__Attribute_Definition__c rcn = new cscfgc__Attribute_Definition__c();
            rcn.cscfgc__Product_Definition__c = pd.Id;
            rcn.name='Related Configuration Name';
            attr2ins.add(rcn);

            cscfgc__Attribute_Definition__c opds = new cscfgc__Attribute_Definition__c();
            opds.cscfgc__Product_Definition__c = pd.Id;
            opds.name='Other pillar dependency Shadow';
            attr2ins.add(opds);


            insert attr2ins;

            return pd;
        }

		public static cscfgc__Product_Definition__c createOtherPillarProductDefinitionMock(){

            cscfgc__Product_Category__c prodCat = createUnifyProductCategory();

            cscfgc__Product_Definition__c prodDef = new cscfgc__Product_Definition__c(cscfgc__Description__c = 'test',
            																	 cscfgc__Product_Category__c = prodCat.Id,
            																	 cscfgc__Label__c = UnifyConfig.mPillars2Name().get('Other/VAS'),
            																	 Name = UnifyConfig.mPillars2Name().get('Other/VAS'));
            insert prodDef;

            prodDef = createCommonAttributes(prodDef);

			List<cscfgc__Attribute_Definition__c> attrDefs = new List<cscfgc__Attribute_Definition__c>();

            cscfgc__Attribute_Definition__c oName = new cscfgc__Attribute_Definition__c(cscfgc__Product_Definition__c = prodDef.Id, Name = 'Other Name', cscfgc__Default_Value__c = '');
            attrDefs.add(oName);

			cscfgc__Attribute_Definition__c rConf = new cscfgc__Attribute_Definition__c(cscfgc__Product_Definition__c = prodDef.Id, Name = 'Related Configuration', cscfgc__Default_Value__c = '');
            attrDefs.add(rConf);

            cscfgc__Attribute_Definition__c rConfName = new cscfgc__Attribute_Definition__c(cscfgc__Product_Definition__c = prodDef.Id, Name = 'Related Configuration Name', cscfgc__Default_Value__c = '');
            attrDefs.add(rConfName);

            cscfgc__Attribute_Definition__c dCode = new cscfgc__Attribute_Definition__c(cscfgc__Product_Definition__c = prodDef.Id, Name = 'DISE CODE', cscfgc__Default_Value__c = '');
            attrDefs.add(dCode);

            cscfgc__Attribute_Definition__c dCodeVal = new cscfgc__Attribute_Definition__c(cscfgc__Product_Definition__c = prodDef.Id, Name = 'DISE CODE value', cscfgc__Default_Value__c = '');
            attrDefs.add(dCodeVal);

            cscfgc__Attribute_Definition__c cfgId = new cscfgc__Attribute_Definition__c(cscfgc__Product_Definition__c = prodDef.Id, Name = 'Configuration Id', cscfgc__Default_Value__c = '');
            attrDefs.add(cfgId);



            insert attrDefs;
            return prodDef;
        }

        public static cscfgc__Product_Definition__c createCommonAttributes(cscfgc__Product_Definition__c pd){

            cscfgc__Attribute_Definition__c[] attr2ins = new cscfgc__Attribute_Definition__c[]{};

            cscfgc__Attribute_Definition__c aEnd = new cscfgc__Attribute_Definition__c();
            aEnd.cscfgc__Product_Definition__c = pd.Id;
            aEnd.name='A-End';
            attr2ins.add(aEnd);

            cscfgc__Attribute_Definition__c supplier = new cscfgc__Attribute_Definition__c();
            supplier.cscfgc__Product_Definition__c = pd.Id;
            supplier.name='Supplier';
            attr2ins.add(supplier);


            cscfgc__Attribute_Definition__c solution = new cscfgc__Attribute_Definition__c();
            solution.cscfgc__Product_Definition__c = pd.Id;
            solution.name='Solution';
            attr2ins.add(solution);

            cscfgc__Attribute_Definition__c comment = new cscfgc__Attribute_Definition__c();
            comment.cscfgc__Product_Definition__c = pd.Id;
            comment.name='Comment';
            attr2ins.add(comment);

            cscfgc__Attribute_Definition__c quantity = new cscfgc__Attribute_Definition__c();
            quantity.cscfgc__Product_Definition__c = pd.Id;
            quantity.name='Quantity';
            attr2ins.add(quantity);

            cscfgc__Attribute_Definition__c cost = new cscfgc__Attribute_Definition__c();
            cost.cscfgc__Product_Definition__c = pd.Id;
            cost.name='Cost';
            attr2ins.add(cost);


            cscfgc__Attribute_Definition__c margin = new cscfgc__Attribute_Definition__c();
            margin.cscfgc__Product_Definition__c = pd.Id;
            margin.name='Margin';
            attr2ins.add(margin);

            cscfgc__Attribute_Definition__c dise = new cscfgc__Attribute_Definition__c();
            dise.cscfgc__Product_Definition__c = pd.Id;
            dise.name='DISE Bill Label';
            attr2ins.add(dise);

			cscfgc__Attribute_Definition__c bf = new cscfgc__Attribute_Definition__c();
            bf.cscfgc__Product_Definition__c = pd.Id;
            bf.name='Billing Frequency';
            attr2ins.add(bf);

            cscfgc__Attribute_Definition__c marc = new cscfgc__Attribute_Definition__c();
            marc.cscfgc__Product_Definition__c = pd.Id;
            marc.name='Margin ARC';
            marc.cscfgc__Default_Value__c= '';
            attr2ins.add(marc);

            cscfgc__Attribute_Definition__c mnrc = new cscfgc__Attribute_Definition__c();
            mnrc.cscfgc__Product_Definition__c = pd.Id;
            mnrc.name='Margin NRC';
            mnrc.cscfgc__Default_Value__c= '';
            attr2ins.add(mnrc);

            cscfgc__Attribute_Definition__c unitNrc = new cscfgc__Attribute_Definition__c();
            unitNrc.cscfgc__Product_Definition__c = pd.Id;
            unitNrc.name='Unit NRC CAPEX';
            unitNrc.cscfgc__Default_Value__c= '';
            attr2ins.add(unitNrc);

            cscfgc__Attribute_Definition__c unitArc = new cscfgc__Attribute_Definition__c();
            unitArc.cscfgc__Product_Definition__c = pd.Id;
            unitArc.name='Unit ARC OPEX';
            unitArc.cscfgc__Default_Value__c= '';
            attr2ins.add(unitArc);


            insert attr2ins;

            return pd;
        }

        public static void createAllUnifyProdDefs(){
            cscfgc__Product_Definition__c pd1 = createConnectivityPillarProductDefinitionMock();
            createCommonAttributes(pd1);
            cscfgc__Product_Definition__c pd2 = createHardwarePillarProductDefinitionMock();
            createCommonAttributes(pd2);
            cscfgc__Product_Definition__c pd3 = createMaintenancePillarProductDefinitionMock();
            createCommonAttributes(pd3);
            cscfgc__Product_Definition__c pd4 = createProfessionalServicesPillarProductDefinitionMock();
            createCommonAttributes(pd4);
            cscfgc__Product_Definition__c pd5 = createManagedServicesPillarProductDefinitionMock();
            createCommonAttributes(pd5);
        }
}