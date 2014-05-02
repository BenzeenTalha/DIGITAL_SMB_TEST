///////////////////////////////////////////////////
// This class is used to dynamically retrieve handset prices from the handset mapping table
// The class is used on mobile product definitions which require dynamically displaying handset prices dependant on the voice
// tariff.
// Created on September 6th, base code by Alex Fuller and further changes by Guy Keshet 	
///////////////////////////////////////////////////
public class HandsetTariffPriceDisplayController {
/*
    // Direct pricing calculation globals
    final static integer contributionSpend = 40;
    final static decimal lowContribution = 0.4;
    final static decimal highContribution = 0.3;
    final static decimal termPercentage = 0.9167;
    final static decimal margin = 0.7966;
    final static integer rlpUpToPrice = 99;
    final static integer rlpUpToUplift = 5;
    final static integer rlpAboveUplift = 20;
    
    decimal price;
    integer contractTerm;
    double monthlySpend; 
    Boolean NoRecordsFound = true ;
    
    public List<O2_Dise_Map_Handset__c> handsets {get; set;}
    public List<O2_Dise_Map_Handset_Selection__c> selection {get; set;}
    O2_Dise_Map_Mobile__c diseMobile;
    String pageContext;
    String attrIndex='';
    String handsetDescription;
    String voiceTariff;
    String channel;
    
    public HandsetTariffPriceDisplayController() {
        handsetDescription = ApexPages.currentPage().getParameters().get('handsetDescription');
        voiceTariff        = ApexPages.currentPage().getParameters().get('voiceTariff');
        pageContext        = ApexPages.currentPage().getParameters().get('pageContext');
        channel            = ApexPages.currentPage().getParameters().get('channel'); 
        if (pageContext=='Secondary') {
            attrIndex = ApexPages.currentPage().getParameters().get('attrIndex');
            contractTerm = 24;
        } else {
            contractTerm = integer.valueof((ApexPages.currentPage().getParameters().get('contractTerm')));
            attrIndex='\'N/A\''; 
        }
        
        if ((channel == 'Direct') && (pageContext !='Secondary'))
        {
            monthlySpend   = Double.valueOf(ApexPages.currentPage().getParameters().get('monthlySpend'));
            if (monthlySpend<0) monthlySpend=0;
        }
        
        System.debug('**************** Accepted parameters: handsetDescription:'+handsetDescription+ ' voiceTariff: '+voiceTariff +' pageContext: '+pageContext +' channel: '+channel +' attrIndex: '+attrIndex +' contractTerm: '+contractTerm +' monthlySpend: '+monthlySpend);
        //Populate Handsets    
        queryMapHandsets();
        //System.debug('**************** Handsets values are: ' +handsets[0]);
        //Populate HandsetURL
        queryHandsetSelection();
        
		
    } 
    
    public void queryMapHandsets(){
  
        if (channel == 'Direct') 
        {
            handsets = [
                    select  handset_description__c,
                            discounted_price__c, 
                            additions_price__c,
                            discount_threshold__c,
                            product_code__c,
                            Replacement_Price__c,
                            Handset_Class__c
                     from   O2_Dise_Map_Handset__c
                     where  handset_description__c = :handsetDescription
                       and  Channel__c = 'Direct'
                       and  band_logic__c = TRUE
                       and  Contract_Term__c = :contractTerm
        ];
        }
        else
        {
            handsets = [
                    select  handset_description__c,
                            discounted_price__c, 
                            additions_price__c,
                            discount_threshold__c,
                            product_code__c,
                            Replacement_Price__c,
                            Handset_Class__c,
                            Insurance_Service_Price__c,
                            Insurance_Service_Code__c,
                            Insurance_Service_Bill_Label__c
                     from   O2_Dise_Map_Handset__c
                     where  handset_description__c = :handsetDescription
                       and  base_tariff__c = :voiceTariff
                       and  band_logic__c = FALSE
                       and  Channel__c != 'Direct'
                       and  Contract_Term__c = :contractTerm
        ];
        }
        if (handsets.isEmpty()) this.NoRecordsFound = true; 
        else this.NoRecordsFound = false;
    }
    
    public void queryHandsetSelection(){
        selection = [Select Handset_Image_URL__c from O2_Dise_Map_Handset_Selection__c 
                     where handset_description__c = :handsetDescription ];
    }
    
    public Boolean getNoRecordsFound(){return NoRecordsFound;}
    public String getHandsetDescription(){
    	if (NoRecordsFound) return '\'NoRecords\'';
        else return String.valueOf(handsets[0].handset_description__c);
    }
    
    public String getHandsetURL(){
    	if (selection[0].Handset_Image_URL__c != null)
        	return String.valueOf(selection[0].Handset_Image_URL__c);
        else return '';
    }
    
    public String getInsuranceSrvCode(){
    	if (NoRecordsFound) return '\'NoRecords\'';
    	else	return '\''+handsets[0].Insurance_Service_Code__c+'\'';
    	
    		}
    public String getInsurancePrice(){
    	if (NoRecordsFound) return '\'NoRecords\'';
    	else	return '\''+handsets[0].Insurance_Service_Price__c+'\'';
    	
    		}
    public String getDiscountedPrice(){
        if (NoRecordsFound) return '-1';
        integer subsidy = 0;
        if (channel == 'Direct')
        {
            if (handsets[0].Handset_Class__c == 'iPhone')
            {   //calculate iPhone subsidy
                if (this.monthlySpend <= 35) subsidy = 216;
                else if (this.monthlySpend <= 65) subsidy = 300;
                     else subsidy =350;
                // subsidy above is for 24 month contract, it should be halved for a 12 month contract      
                if (this.contractTerm == 12) subsidy = subsidy/2;
                else if (this.contractTerm != 24) subsidy = 0;
            }
            else
            {       
                //setting the minimal customer contribution based on monthly spend
                double minContribution = (monthlySpend<contributionSpend)?lowContribution:highContribution;
                //setting price according to formula (rlp - calculated subsidy based on contract spend)
                subsidy = (math.round(monthlySpend*contractTerm*termPercentage*margin)-math.round(monthlySpend*contractTerm*termPercentage*minContribution));
            }
            price = calcReplacmentListPrice() - subsidy;
            price = (price<0)?0:price.setScale(0); //ensuring minimal price is zero 
            return String.valueOf(price);   
        }
        else return String.valueOf(handsets[0].discounted_price__c);
    }
    
    public String getAdditionsPrice(){
    	if (NoRecordsFound) return '-1';
        if (channel == 'Direct') return String.valueOf(calcReplacmentListPrice());
        else return String.valueOf(handsets[0].additions_price__c);
    }
    
    public integer calcReplacmentListPrice(){
    	if (NoRecordsFound) return -1;
        // O2 delivery version 2.2.4, 29/9/11
        // RLP for direct channel is based on cost (Saved as 'discounted price') plus an uplift value
        if (channel == 'Direct') {
            if (handsets[0].discounted_price__c > rlpUpToPrice)
                return math.round(handsets[0].discounted_price__c+rlpAboveUplift);
            else
                return math.round(handsets[0].discounted_price__c+rlpUpToUplift);
        }
        else 
            if (handsets[0].Replacement_Price__c != null)
                return math.round(handsets[0].Replacement_Price__c);
            else 
                { // If RLP is null, this either means the handset mapping table value is missing, or that this handset
                  // should not be sold as SIM Only. To avoid a 'no argument' error, return a -1
                    return -1;
                }
    }
    
    public String getReplacmentListPrice(){
    	if (NoRecordsFound) return '-1';
    	else
            return String.valueOf(calcReplacmentListPrice());
    }
    // Return price acording to context: discounted price for 'with handset' deals, return additons price
    // for secondary handsets and RLP for 'SIM Only' deals. 
    public String getPriceByContext(){
        if (pageContext=='Handset') {return getDiscountedPrice();}
        else if (pageContext=='SIM Only' || pageContext=='Simplicity') {return getReplacmentListPrice();}
        else if (pageContext=='Secondary') {return getAdditionsPrice();}
        else {return 'Context not applicable';}
    }
    public String getPageContext(){
        return pageContext;
    }
    public String getAttrIndex(){
        return attrIndex;
    }
        
    //test method
    public static testmethod void testHandsetTariffPriceDisplayController(){
        ApexPages.currentPage().getParameters().put('handsetDescription','APPLE iPHONE 4 16GB BK');
        ApexPages.currentPage().getParameters().put('voiceTariff','Business Single 300');
        ApexPages.currentPage().getParameters().put('pageContext','Handset');
        ApexPages.currentPage().getParameters().put('channel','ORT');  
        ApexPages.currentPage().getParameters().put('contractTerm','24'); 
        
        HandsetTariffPriceDisplayController htpdIPhone = new HandsetTariffPriceDisplayController();
        /*
        system.assertEquals(htpdIPhone.getDiscountedPrice(), '156.00', 'The discounted price is not equal.');   
        system.assertEquals(htpdIPhone.getPriceByContext(), '156.00', 'The discounted price is not equal.');   
        system.assertEquals(htpdIPhone.handsets[0].product_code__c, 'MC603B/A', 'The product code price is not equal.');    
        system.assertEquals(htpdIPhone.getAttrIndex(), '\'N/A\'', 'The index is not equal.');
        system.assertEquals(htpdIPhone.getPageContext(), 'Handset', 'The Page Context is not equal.');
        //system.assertEquals(htpdIPhone.getHandsetURL(), 'http://businessshop.o2.co.uk/img/0apple_iphone_4_black_thumb.png', 'The URL is not equal.');
		system.assertEquals(htpdIPhone.getHandsetURL(),'','');

        ApexPages.currentPage().getParameters().put('handsetDescription','APPLE iPHONE 4 16GB BK');
        ApexPages.currentPage().getParameters().put('voiceTariff','Business Share 500');
        ApexPages.currentPage().getParameters().put('pageContext','Secondary');
        ApexPages.currentPage().getParameters().put('attrIndex','1');
        ApexPages.currentPage().getParameters().put('channel','ORT');
          
        HandsetTariffPriceDisplayController htpdIPhoneSec = new HandsetTariffPriceDisplayController();
   /*        
        system.assertEquals(htpdIPhoneSec.getPriceByContext(), '282.00', 'The discounted price is not equal.');
        system.assertEquals(htpdIPhoneSec.getAdditionsPrice(), '282.00', 'The addtions price is not equal.');   
        system.assertEquals(htpdIPhoneSec.handsets[0].product_code__c, 'MC603B/A', 'The product code price is not equal.'); 
        system.assertEquals(htpdIPhoneSec.getAttrIndex(), '1', 'The	 index is not equal.');
        system.assertEquals(htpdIPhoneSec.getPageContext(), 'Secondary', 'The Page Context is not equal.');
        /* No direct data exists in release 2.2.3 */
   /*      ApexPages.currentPage().getParameters().put('handsetDescription','Apple iPhone 4 16GB Black');
        ApexPages.currentPage().getParameters().put('voiceTariff','Business Single 300');
        ApexPages.currentPage().getParameters().put('pageContext','SIM Only');
        ApexPages.currentPage().getParameters().put('channel','Direct');
        ApexPages.currentPage().getParameters().put('contractTerm','24');
        ApexPages.currentPage().getParameters().put('monthlySpend','25.00');
        
        HandsetTariffPriceDisplayController htpdIPhoneSim = new HandsetTariffPriceDisplayController();
        system.assertEquals(htpdIPhoneSim.getNoRecordsFound(), true,'');
        
        system.assertEquals(htpdIPhoneSim.getDiscountedPrice(), '-1', 'The discounted price is not equal.');    
        system.assertEquals(htpdIPhoneSim.getPriceByContext(), '-1', 'The discounted price is not equal.');
        system.assertEquals(htpdIPhoneSim.getReplacmentListPrice(), '-1', 'The rlp price is not equal.');   
        system.assertEquals(htpdIPhoneSim.getAttrIndex(), '\'N/A\'', 'The index is not equal.');
        system.assertEquals(htpdIPhoneSim.getPageContext(), 'SIM Only', 'The Page Context is not equal.');
        system.assertEquals(htpdIPhoneSim.getInsuranceSrvCode(), 'NoRecords', 'Insurance Code mismatch.');
        system.assertEquals(htpdIPhoneSim.calcReplacmentListPrice(),-1,'RLP mismatch.');
       
        system.assertEquals(htpdIPhoneSim.getDiscountedPrice(), '204', 'The discounted price is not equal.');    
        system.assertEquals(htpdIPhoneSim.getPriceByContext(), '420', 'The discounted price is not equal.');
        system.assertEquals(htpdIPhoneSim.getReplacmentListPrice(), '420', 'The rlp price is not equal.');   
        system.assertEquals(htpdIPhoneSim.handsets[0].product_code__c, 'MC603B/A', 'The product code price is not equal.'); 
        system.assertEquals(htpdIPhoneSim.getAttrIndex(), '\'N/A\'', 'The index is not equal.');
        system.assertEquals(htpdIPhoneSim.getPageContext(), 'SIM Only', 'The Page Context is not equal.');
        
        ApexPages.currentPage().getParameters().put('handsetDescription','Apple iPhone 4 16GB Black');
        ApexPages.currentPage().getParameters().put('voiceTariff','Business Single 300');
        ApexPages.currentPage().getParameters().put('pageContext','Handset');
        ApexPages.currentPage().getParameters().put('channel','Direct');
        ApexPages.currentPage().getParameters().put('contractTerm','12');
        ApexPages.currentPage().getParameters().put('monthlySpend','75.00');
        
        HandsetTariffPriceDisplayController htpdIPhonedirect = new HandsetTariffPriceDisplayController();
        
        system.assertEquals(htpdIPhonedirect.getDiscountedPrice(), '245', 'The discounted price is not equal.');    
        system.assertEquals(htpdIPhonedirect.getPriceByContext(), '245', 'The discounted price is not equal.');
        system.assertEquals(htpdIPhonedirect.getReplacmentListPrice(), '420', 'The rlp price is not equal.');   
        system.assertEquals(htpdIPhonedirect.handsets[0].product_code__c, 'MC603B/A', 'The product code price is not equal.'); 
        system.assertEquals(htpdIPhonedirect.getAttrIndex(), '\'N/A\'', 'The index is not equal.');
        system.assertEquals(htpdIPhonedirect.getPageContext(), 'Handset', 'The Page Context is not equal.');
        
        ApexPages.currentPage().getParameters().put('handsetDescription','Apple iPhone 4 16GB Black');
        ApexPages.currentPage().getParameters().put('voiceTariff','Business Single 300');
        ApexPages.currentPage().getParameters().put('pageContext','Handset');
        ApexPages.currentPage().getParameters().put('channel','Direct');
        ApexPages.currentPage().getParameters().put('contractTerm','12');
        ApexPages.currentPage().getParameters().put('monthlySpend','55.00');
        
        HandsetTariffPriceDisplayController htpdIPhonedirect2 = new HandsetTariffPriceDisplayController();
        
        system.assertEquals(htpdIPhonedirect2.getDiscountedPrice(), '270', 'The discounted price is not equal.');    
        system.assertEquals(htpdIPhonedirect2.getPriceByContext(), '270', 'The discounted price is not equal.');
        system.assertEquals(htpdIPhonedirect2.getReplacmentListPrice(), '420', 'The rlp price is not equal.');   
        system.assertEquals(htpdIPhonedirect2.handsets[0].product_code__c, 'MC603B/A', 'The product code price is not equal.'); 
        system.assertEquals(htpdIPhonedirect2.getAttrIndex(), '\'N/A\'', 'The index is not equal.');
        system.assertEquals(htpdIPhonedirect2.getPageContext(), 'Handset', 'The Page Context is not equal.');
      
        
        ApexPages.currentPage().getParameters().put('handsetDescription','MOTOROLA ES400 EXTENDED BATTERY VERSION');
        ApexPages.currentPage().getParameters().put('voiceTariff','Business Single 300');
        ApexPages.currentPage().getParameters().put('pageContext','Handset');
        ApexPages.currentPage().getParameters().put('channel','Direct');
        ApexPages.currentPage().getParameters().put('contractTerm','12');
        ApexPages.currentPage().getParameters().put('monthlySpend','55.00');
        
        HandsetTariffPriceDisplayController htpdIPhonedirect3 = new HandsetTariffPriceDisplayController();
        
        system.assertEquals(htpdIPhonedirect3.getDiscountedPrice(), '139', 'The discounted price is not equal.');    
        system.assertEquals(htpdIPhonedirect3.getPriceByContext(), '139', 'The discounted price is not equal.');
        system.assertEquals(htpdIPhonedirect3.getReplacmentListPrice(), '439', 'The rlp price is not equal.');   
        system.assertEquals(htpdIPhonedirect3.handsets[0].product_code__c, '1MOES4EN', 'The product code price is not equal.'); 
        system.assertEquals(htpdIPhonedirect3.getAttrIndex(), '\'N/A\'', 'The index is not equal.');
        system.assertEquals(htpdIPhonedirect3.getPageContext(), 'Handset', 'The Page Context is not equal.');  
    }*/
}