public with sharing class MinuteBoltOnsController {
    
    public O2OnlineMainController parentController {get;set;}
    public List<BoltOnsExt> boltOnsList {get; set;}
    public String tariffCode {get;set;}
    
    public MinuteBoltOnsController() {}
    public MinuteBoltOnsController(O2OnlineMainController maincontroller) {
        this.parentController = maincontroller;
        getBoltOnsValue();
    }
    
    public List<BoltOnsExt> getBoltOns() {
        getBoltOnsValue();
        return boltOnsList;
    }
    public void getBoltOnsValue(){  
            boltOnsList = new List<BoltOnsExt>();
        
            //tariffCode = 'S234BL';    //temporary hack to default the code - MUST BE REMOVED TO RETRIEVE FROM THE CONFIG!!!
            
            Map<Integer, O2_DISE_Map_Minutes__c> mpLLBoltOns = new Map<Integer, O2_DISE_Map_Minutes__c>();      
            Map<Integer, O2_DISE_Map_Minutes__c> mpMobileBoltOns = new Map<Integer, O2_DISE_Map_Minutes__c>();      
            Map<Integer, O2_DISE_Map_Minutes__c> mpLLMobileBoltOns = new Map<Integer, O2_DISE_Map_Minutes__c>(); 
            Map<Integer, Integer> mpMinutesNum = new Map<Integer, Integer>();
            mpMinutesNum.put(Integer.valueOf('0'), Integer.valueOf('0'));
            Date d = system.today();            
                                
            System.debug('### OUTPUT >>>>> getBoltOnsValue: tariffCode: '+tariffCode);                                               
            System.debug('### OUTPUT >>>>> getBoltOnsValue: d: '+String.valueOf(d));                                                 
            List<O2_DISE_Map_Minutes__c> minuteList = [Select name, Service_Price__c, Service_Code__c, Service_Bill_Label__c, Minutes_Type__c, 
                                                             Minutes_Number__c, Effective_Date__c, Destination_Of_Mins__c
                                                             From O2_DISE_Map_Minutes__c 
                                                             where Tariff_Code__c =:tariffCode AND Effective_Date__c < :d 
                                                             and Destination_Of_Mins__c <= 5000
                                                             order by Destination_Of_Mins__c desc, Minutes_Type__c, Effective_Date__c ];
            System.debug('### OUTPUT >>>>> getBoltOnsValue: minuteList: '+minuteList);                                               
            for(O2_DISE_Map_Minutes__c min : minuteList){
                if(min.Minutes_Type__c == 'Calls to O2 Mobiles'){
                    mpMobileBoltOns.put(Integer.valueOf(min.Destination_Of_Mins__c), min);
                }
                else if(min.Minutes_Type__c == 'Calls to UK Landlines'){
                    mpLLBoltOns.put(Integer.valueOf(min.Destination_Of_Mins__c), min);
                }
                else if(min.Minutes_Type__c == 'Calls to UK Landlines and Mobiles'){
                    mpLLMobileBoltOns.put(Integer.valueOf(min.Destination_Of_Mins__c), min);
                }
                mpMinutesNum.put(Integer.valueOf(min.Destination_Of_Mins__c),Integer.valueOf(min.Destination_Of_Mins__c));              
            }
            List<Integer> minutesSort = mpMinutesNum.values();
            minutesSort.sort(); 
            
            for(Integer minNum : minutesSort){
                BoltOnsExt bolts = new BoltOnsExt();
                bolts.minutesNumber = String.valueOf(minNum);
                // RC 13-01-12 : Ensure soBject records for all minute types are included in the boltOnsExt
                bolts.sobjLL = mpLLBoltOns.get(minNum);
                bolts.sobjMobile = mpMobileBoltOns.get(minNum);
                bolts.sobjLLMobile = mpLLMobileBoltOns.get(minNum);
                               
                if(minNum == 0){
                	bolts.ukLandlinesOnly = '0';
                    bolts.o2MobilesOnly = '0';
	                bolts.ukLandlinesAndMobiles = '0';
                }
                else {
                    if(mpLLBoltOns.containskey(minNum)){
                        bolts.ukLandlinesOnly = '£'+getCommaSeperatedIntVal(String.valueOf(mpLLBoltOns.get(minNum).Service_Price__c));                  
                    }
                    else
                    {
                            bolts.ukLandlinesOnly = 'N/A';
                    } 
                    
                    if(mpMobileBoltOns.containskey(minNum)){
                            bolts.o2MobilesOnly = '£'+getCommaSeperatedIntVal(String.valueOf(mpMobileBoltOns.get(minNum).Service_Price__c));
                    }
                    else
                    {
                        bolts.o2MobilesOnly = 'N/A';
                    }
                    
                    if(mpLLMobileBoltOns.containskey(minNum)){
                            bolts.ukLandlinesAndMobiles = '£'+getCommaSeperatedIntVal(String.valueOf(mpLLMobileBoltOns.get(minNum).Service_Price__c));
                    }
                    else
                    {
                        bolts.ukLandlinesAndMobiles = 'N/A';
                    }
                }
                
                boltOnsList.add(bolts);             
            }
    
        }
        
        public List<SelectOption> getMinuteNumberItems() {
            List<SelectOption> minuteOptions = new List<SelectOption>();
            for(BoltOnsExt boltExt : boltOnsList){
                minuteOptions.add(new SelectOption(boltExt.minutesNumber,getCommaSeperatedIntVal(boltExt.minutesNumber)));
            }
            return minuteOptions;
        }
        
        private string getCommaSeperatedIntVal(String value){
            String sepIntVal = '';
            if(value != null && value != '' && value != 'N/A'){
                Boolean dotVal = value.contains('.');
                if(dotVal){         
                    Integer lengthVal =     value.length(); 
                    String tempVal1 = value.substring(0,lengthVal-3);
                    String tempVal2 = value.substring(lengthVal-3, lengthVal);
                    
                    
                    Integer len = tempVal1.length();
                    if(len > 3){
                        tempVal1 = tempVal1.substring(0,len-3) + ',' +tempVal1.substring(len-3, len) +tempVal2;
                    }
                    else
                    {
                        tempVal1 = value;
                    }
                    sepIntVal = tempVal1;
                    
                }
                else
                {
                    Integer len1 = value.length();
                    String temp1;
                    if(len1 > 3){
                        temp1 = value.substring(0,len1-3) + ',' +value.substring(len1-3, len1);
                    }
                    else
                    {
                        temp1 = value;
                    }
                    sepIntVal = temp1;
                    
                } 
            }
            return sepIntVal;           
        }
        
    
    public class BoltOnsExt{
        public O2_DISE_Map_Minutes__c sobjLL {get; set;}
        public O2_DISE_Map_Minutes__c sobjMobile {get; set;}
        public O2_DISE_Map_Minutes__c sobjLLMobile {get; set;}

        public String minutesNumber {get; set;}
        public String ukLandlinesOnly {get; set;}
        public String o2MobilesOnly {get; set;}
        public String ukLandlinesAndMobiles {get; set;}
        
        public BoltOnsExt(){}   
        
    }
    
    static testmethod void testMinuteBoltOnsController(){ 
    	Date dPast = system.today() - 1;  
    	system.debug('dPast: '+dPast); 
 		// test some of the edge case code paths
 		O2_DISE_Map_Minutes__c myMinsGold = new O2_DISE_Map_Minutes__c(Name='My Minutes G', Tariff_Code__c='myTarrif',
 																   Minutes_Type__c='Calls to UK Landlines', Effective_Date__c=dPast);
		insert myMinsGold;
 		O2_DISE_Map_Minutes__c myMinsSilver = new O2_DISE_Map_Minutes__c(Name='My Minutes S', Tariff_Code__c='myTarrif',
 																   Minutes_Type__c='Calls to O2 Mobiles', Effective_Date__c=dPast);
		insert myMinsSilver;

 		O2_DISE_Map_Minutes__c myMinsBronze = new O2_DISE_Map_Minutes__c(Name='My Minutes B', Tariff_Code__c='myTarrif',
 																   Minutes_Type__c='Calls to UK Landlines and Mobiles', Effective_Date__c=dPast);
		insert myMinsBronze;

 		O2_DISE_Map_Minutes__c myMinsCopper = new O2_DISE_Map_Minutes__c(Name='My Minutes C', Tariff_Code__c='myTarrif',
 																   Minutes_Type__c='Calls to Satelite Phones');
		insert myMinsCopper;

        cscfgc__Product_Definition__c prodDef = new cscfgc__Product_Definition__c();
        MinuteBoltOnsController minBoltOns = new MinuteBoltOnsController();
        O2OnlineMainController onlinMainContr = new O2OnlineMainController();
        minBoltOns.parentController = onlinMainContr;

        minBoltOns.getBoltOnsValue();
        List<BoltOnsExt> boe = minBoltOns.getBoltOns();
        minBoltOns.getMinuteNumberItems();
        System.assertEquals(minBoltOns.boltOnsList != null, true);
        
		// do it again with myTarrif
		minBoltOns.tariffCode = 'myTarrif';
		minBoltOns.getBoltOnsValue();

		// test the getCommaSeperatedIntVal method
		system.assertEquals('',minBoltOns.getCommaSeperatedIntVal(null));
		system.assertEquals('',minBoltOns.getCommaSeperatedIntVal(''));
		system.assertEquals('',minBoltOns.getCommaSeperatedIntVal('N/A'));
		system.assertEquals('0.5',minBoltOns.getCommaSeperatedIntVal('0.5'));
		system.assertEquals('0.50',minBoltOns.getCommaSeperatedIntVal('0.50'));
		system.assertEquals('1.50',minBoltOns.getCommaSeperatedIntVal('1.50'));
		system.assertEquals('12.50',minBoltOns.getCommaSeperatedIntVal('12.50'));
		system.assertEquals('123.50',minBoltOns.getCommaSeperatedIntVal('123.50'));
		system.assertEquals('1,234.50',minBoltOns.getCommaSeperatedIntVal('1234.50'));
		system.assertEquals('12,345.50',minBoltOns.getCommaSeperatedIntVal('12345.50'));
		system.assertEquals('123,456.50',minBoltOns.getCommaSeperatedIntVal('123456.50'));
		system.assertEquals('1',minBoltOns.getCommaSeperatedIntVal('1'));
		system.assertEquals('12',minBoltOns.getCommaSeperatedIntVal('12'));
		system.assertEquals('123',minBoltOns.getCommaSeperatedIntVal('123'));
		system.assertEquals('1,234',minBoltOns.getCommaSeperatedIntVal('1234'));
		system.assertEquals('12,345',minBoltOns.getCommaSeperatedIntVal('12345'));
		system.assertEquals('123,456',minBoltOns.getCommaSeperatedIntVal('123456'));

        // test the non-default constructor
        MinuteBoltOnsController mboc = new MinuteBoltOnsController(onlinMainContr);    

		
    }

}