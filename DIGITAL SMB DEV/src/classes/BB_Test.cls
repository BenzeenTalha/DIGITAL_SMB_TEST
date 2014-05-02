@isTest
public class BB_Test {
	
	// Common method to be called from testmethod to load custom settings data
	public static void loadCustomSettingsData(){     
        
        SOA_Integration_Settings__c soaEMLCService = new SOA_Integration_Settings__c(Name = 'SentryGatewayMLCv2_v14Soap',
                                                                                    Endpoint__c = 'https://sdpapi.ref.o2.co.uk/emp/2000/EnhancedManageLineCharacteristics',
                                                                                    Timeout__c = 60000,
                                                                                    MAX_SOA_RETRIES__c = 1,
                                                                                    Endpoint_Server__c = 'https://sdpapi.ref.o2.co.uk' );
        insert soaEMLCService;
        
        List<BB_Checker_Settings__c> lstbbCheckerSettings = new List<BB_Checker_Settings__c>();
        BB_Checker_Settings__c bbCheckerSettings1 = new BB_Checker_Settings__c(Name='Get_FTTC_Details',Value__c=true);
		lstbbCheckerSettings.add(bbCheckerSettings1);
		BB_Checker_Settings__c bbCheckerSettings2 = new BB_Checker_Settings__c(Name='isIPStreamAvailable__c',Value__c=true);
		lstbbCheckerSettings.add(bbCheckerSettings2);
		BB_Checker_Settings__c bbCheckerSettings3 = new BB_Checker_Settings__c(Name='isLLUAvailable__c',Value__c=false);
		lstbbCheckerSettings.add(bbCheckerSettings3);
		insert lstbbCheckerSettings;
		
		List<BB_Exchange__c> lstBBExchange = new List<BB_Exchange__c>();
		BB_Exchange__c bbExchange1 = new BB_Exchange__c(Name='SLIPSW3',Exchange_Name__c='Ipswich 3',County__c='Ipswich',Market_Category__c=3.0,Fibre_FTTC_Enabled__c=true,WBC_ADSL2_Enabled__c=true,IPStream_Enabled__c=true);
		lstBBExchange.add(bbExchange1);
		BB_Exchange__c bbExchange2 = new BB_Exchange__c(Name='NSTHU',Exchange_Name__c='THURSO',County__c='THURSO',Market_Category__c=3.0,Fibre_FTTC_Enabled__c=true,WBC_ADSL2_Enabled__c=true,IPStream_Enabled__c=true);
		lstBBExchange.add(bbExchange2);
		BB_Exchange__c bbExchange3 = new BB_Exchange__c(Name='NSWTT',Exchange_Name__c='WATTEN',County__c='WATTEN',Market_Category__c=3.0,Fibre_FTTC_Enabled__c=true,WBC_ADSL2_Enabled__c=true,IPStream_Enabled__c=true);
		lstBBExchange.add(bbExchange3);
		BB_Exchange__c bbExchange4 = new BB_Exchange__c(Name='CLHOL',Exchange_Name__c='HOLBORN TE (in Covent Garden TE OECP)',County__c='',Market_Category__c=3.0,Fibre_FTTC_Enabled__c=true,WBC_ADSL2_Enabled__c=true,IPStream_Enabled__c=true);
		lstBBExchange.add(bbExchange4);
		BB_Exchange__c bbExchange5 = new BB_Exchange__c(Name='CLWAP',Exchange_Name__c='WAPPING TE',County__c='',Market_Category__c=3.0,Fibre_FTTC_Enabled__c=true,WBC_ADSL2_Enabled__c=true,IPStream_Enabled__c=true);
		lstBBExchange.add(bbExchange5);
		insert lstBBExchange;       
        
        List<BT_Broadband_Reason_Codes__c> lstBBRCs = new List<BT_Broadband_Reason_Codes__c>();        
        BT_Broadband_Reason_Codes__c bbRC1 = new BT_Broadband_Reason_Codes__c(Name='Z',Description__c='O2 Business Broadband can be ordered on this line');
        lstBBRCs.add(bbRC1);
        insert lstBBRCs;
        
        List<BB_Products__c> lstBBProducts = new List<BB_Products__c>();
        BB_Products__c bbProd1 = new BB_Products__c(Name='1',Market_Category__c=3.0,WBC__c=true,Product_Id__c='ENTP006',Product_Name__c='Home Worker Standard',Product_Category__c='ENTERPRISE',Product_Sale_Status__c='On Sale');
        lstBBProducts.add(bbProd1);
        BB_Products__c bbProd12 = new BB_Products__c(Name='10',Market_Category__c=3.0,WBC__c=true,Product_Id__c='SMBP001',Product_Name__c='Home Office Standard',Product_Category__c='SMB',Product_Sale_Status__c='On Sale');
        lstBBProducts.add(bbProd12);
        BB_Products__c bbProd3 = new BB_Products__c(Name='16',Market_Category__c=3.0,WBC__c=false,Product_Id__c='SMBP005',Product_Name__c='Access Regional',Product_Category__c='SMB',Product_Sale_Status__c='On Sale');        
        lstBBProducts.add(bbProd3);
        insert lstBBProducts;
        
        List<BB_Speed__c> lstBBSpeed = new List<BB_Speed__c>(); 
        BB_Speed__c bbSpeed1 = new BB_Speed__c(Name='250',ANFP__c='U',Line_Length__c=250,DB_Loss__c=3.00,WBC_ADSL2_Down_Speed__c=19.0,WBC_ADSL2_Up_Speed__c=1.0,IPS_Down_Speed__c=8.0,IPS_Up_Speed__c=1.0);
        lstBBSpeed.add(bbSpeed1);
        BB_Speed__c bbSpeed2 = new BB_Speed__c(Name='99999',ANFP__c='L',Line_Length__c=99999,DB_Loss__c=9999.00,WBC_ADSL2_Down_Speed__c=0.0,WBC_ADSL2_Up_Speed__c=0.0,IPS_Down_Speed__c=0.0,IPS_Up_Speed__c=0.0);
        lstBBSpeed.add(bbSpeed2);
        insert lstBBSpeed;
        		
	}
	
    static testMethod void testBBAcceptResponse(){
    	loadCustomSettingsData();
        Profile p = [Select Id,Name From Profile Where Name='System Administrator'];
        User u = new User(alias='sysAdmin', username='sfdcsysadmin@o2.co.uk', firstname='Admin', lastname='o2', email='sfdcsysadmin@o2.co.uk',
                          emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid=p.Id, country='United States', timezonesidkey='Europe/London');
        insert u;       
        system.runAs(u){    
            Batch_Job__c batchJob1 = new Batch_Job__c();
            batchJob1.Channel__c = 'Screen Input';
            batchJob1.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
            batchJob1.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
            batchJob1.User__c = u.Id;
            batchJob1.OwnerId = u.Id;
            batchJob1.Email__c = u.Email;
            insert batchJob1;           
            Line_Availability__c bbLineAvailRequest1 = new Line_Availability__c(Batch_Job__c=batchJob1.Id, Directory_Number__c='01142700690', Post_Code__c='IP100PY', Type__c=AvailabilityCheckUtils.TYPE_BROADBAND);
            insert bbLineAvailRequest1;
                        
            Test.startTest();           
            Test.setMock(HttpCalloutMock.class, new BB_HttpMock('Accept'));
            AvailabilityCheckList resultList1 = AvailabilityCheckOutputProcessor.invokeAvailabilityCheckWS(new List<Line_Availability__c>{bbLineAvailRequest1});
            resultList1.save();         
            Test.stopTest();
            
            bbLineAvailRequest1 = [Select Id,Service_Type__c,Type__c,AccessLineID__c,accessLineStatus__c,Resp1CC__c,Resp1Txt__c,Resp1Sev__c From Line_Availability__c Where Id=:bbLineAvailRequest1.Id];
            System.assertEquals('01142700690', bbLineAvailRequest1.AccessLineID__c);
            System.assertEquals('Working', bbLineAvailRequest1.accessLineStatus__c);
        }        
    }
    
    static testMethod void testBBRejectResponse(){
    	loadCustomSettingsData();
        Profile p = [Select Id,Name From Profile Where Name='System Administrator'];
        User u = new User(alias='sysAdmin', username='sfdcsysadmin@o2.co.uk', firstname='Admin', lastname='o2', email='sfdcsysadmin@o2.co.uk',
                          emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid=p.Id, country='United States', timezonesidkey='Europe/London');
        insert u;       
        system.runAs(u){                
            Batch_Job__c batchJob2 = new Batch_Job__c();
            batchJob2.Channel__c = 'Screen Input';
            batchJob2.Type__c = AvailabilityCheckUtils.TYPE_BROADBAND;
            batchJob2.Status__c = AvailabilityCheckUtils.IN_PROGRESS;
            batchJob2.User__c = u.Id;
            batchJob2.OwnerId = u.Id;
            batchJob2.Email__c = u.Email;
            insert batchJob2;           
            Line_Availability__c bbLineAvailRequest2 = new Line_Availability__c(Batch_Job__c=batchJob2.Id, Directory_Number__c='441142700690', Post_Code__c='IP100PY', Type__c=AvailabilityCheckUtils.TYPE_BROADBAND);
            insert bbLineAvailRequest2;
            
            Test.startTest();           
            Test.setMock(HttpCalloutMock.class, new BB_HttpMock('Reject'));
            AvailabilityCheckList resultList2 = AvailabilityCheckOutputProcessor.invokeAvailabilityCheckWS(new List<Line_Availability__c>{bbLineAvailRequest2});
            resultList2.save();
            Test.stopTest();
                        
            bbLineAvailRequest2 = [Select Id,Service_Type__c,Type__c,AccessLineID__c,accessLineStatus__c,Resp1CC__c,Resp1Txt__c,Resp1Sev__c From Line_Availability__c Where Id=:bbLineAvailRequest2.Id];
            System.assertEquals('Telephone Number not recognised format', bbLineAvailRequest2.Resp1Txt__c);
            System.assertEquals('2152', bbLineAvailRequest2.Resp1CC__c);        
        }        
    }
}