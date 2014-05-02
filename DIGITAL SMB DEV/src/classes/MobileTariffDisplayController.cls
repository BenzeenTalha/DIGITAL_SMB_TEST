public with sharing class MobileTariffDisplayController {
	/*
	public List<O2_Dise_Map_Mobile__c> tariffs {get; set;}
	public O2_Dise_Map_Mobile__c selectedTariff {get; set;}
	decimal price;

    public Boolean NoRecordsFound {get; set;}  
    String contractTerm, pageContext, voiceTariff, coreDataBoltOn, contractType, handsetClass, primaryAdditional, productDefinition, promotion, roaming;
	
	//Date myDate = Date.Today();
	static  O2_Dise_Map_Mobile__c  testRecord;	
		
	public MobileTariffDisplayController() {
        
        //voiceTariff        = ApexPages.currentPage().getParameters().get('voiceTariff');
        //pageContext        = ApexPages.currentPage().getParameters().get('pageContext');
        contractTerm 	   = ApexPages.currentPage().getParameters().get('contractTerm');
        contractType	   = ApexPages.currentPage().getParameters().get('contractType');
		coreDataBoltOn	   = ApexPages.currentPage().getParameters().get('coreDataBoltOn');
		handsetClass	   = ApexPages.currentPage().getParameters().get('handsetClass');
		productDefinition  = ApexPages.currentPage().getParameters().get('productDefinition');
		promotion		   = ApexPages.currentPage().getParameters().get('promotion');
		roaming			   = ApexPages.currentPage().getParameters().get('roaming');
		
        if (productDefinition=='Secondary Sharer') {
            primaryAdditional = 'Additional';
        } else {
			primaryAdditional = 'Primary';
        }
        
        System.debug('**************** Accepted parameters: ' +pageContext+' '+contractTerm+' '+contractType+' '+coreDataBoltOn+' '
        +handsetClass+' '+productDefinition+' '+promotion+ ' ***********');
        //Populate Handsets    
        queryMapMobile();
	}
	
	public void queryMapMobile(){

            tariffs = [
                    Select Id, Name, Calls_10_UK_landlines__c, Calls_to_O2_Mobiles__c, Contract_Length__c, 
                    Contract_Type__c, Core_Data_Bolton__c, Data_Summary__c, Email_Browsing__c, Handset_Tariff_Class__c, 
                    Inclusive_Minutes__c, Inclusive_Texts__c, 
                    Minutes_to_Europe__c, Package_Code__c, Price__c, Primary_Additional__c, 
                    Product_Definition__c, Promotion__c, Tariff_Code__c, Voicemail_901__c, Maximum_Users__c, Minimum_Users__c, 
                    Roaming__c, Effective_Date__c, Expiry_Date__c FROM O2_DISE_Map_Mobile__c 
                     where  Contract_Length__c = :contractTerm and Roaming__c = :roaming
                       and  Contract_Type__c = :contractType
                       and  Core_Data_Bolton__c = :coreDataBoltOn     
                       and  Handset_Tariff_Class__c = :handsetClass
                       and  Primary_Additional__c = :primaryAdditional
                       and  Product_Definition__c = :productDefinition                
                       and  Promotion__c = :promotion
                       and (Effective_Date__c = null OR Effective_Date__c >= TODAY)
					   and (Expiry_Date__c = null   OR Expiry_Date__c <= TODAY)
        ];
        
        if (tariffs.isEmpty()) this.NoRecordsFound = true; 
        else this.NoRecordsFound = false;
	}
	
	//test method
    public static testmethod void MobileTariffDisplayController(){
    	
    	testRecord = new O2_Dise_Map_Mobile__c( Name = 'Sample record', Contract_Length__c = '24', 
                    Contract_Type__c = 'Handset', Core_Data_Bolton__c = 'WORKS', 
                    Handset_Tariff_Class__c = 'SMART', 
                    Primary_Additional__c = 'Primary', 
                    Product_Definition__c = 'Business Single', Promotion__c = 'Standard', Roaming__c = 'guy'  
                    );
    	insert testRecord;
    	
        ApexPages.currentPage().getParameters().put('contractTerm','24');
        ApexPages.currentPage().getParameters().put('contractType','Handset');
        ApexPages.currentPage().getParameters().put('coreDataBoltOn','WORKS');
        ApexPages.currentPage().getParameters().put('handsetClass','SMART');  
        //ApexPages.currentPage().getParameters().put('pageContext','Primary');
        ApexPages.currentPage().getParameters().put('productDefinition','Business Single');
        ApexPages.currentPage().getParameters().put('promotion','Standard');
        ApexPages.currentPage().getParameters().put('roaming','guy');

        MobileTariffDisplayController testObj = new MobileTariffDisplayController();
        //if (!testObj.NoRecordsFound) 
        	system.assertEquals(testObj.tariffs[0].Name, 'Sample record', 'The record name is not equal.');  
        
        ApexPages.currentPage().getParameters().put('contractTerm','24');
        ApexPages.currentPage().getParameters().put('contractType','Handset');
        ApexPages.currentPage().getParameters().put('coreDataBoltOn','WORKS');
        ApexPages.currentPage().getParameters().put('handsetClass','SMART');  
        //ApexPages.currentPage().getParameters().put('pageContext','Secondary');
        ApexPages.currentPage().getParameters().put('productDefinition','Business Single');
        ApexPages.currentPage().getParameters().put('promotion','Standard');
        ApexPages.currentPage().getParameters().put('roaming','guy');

        MobileTariffDisplayController testObj2 = new MobileTariffDisplayController();
        }
        */
}