public with sharing class BB_Helper {
    
    // Get Productlist
    public static String getProductList(String exchId){        
        String productList = '';
        Boolean wbc = false;
        Double mktCat = 0;              
        if(!(exchId==Null || exchId=='')){
            if(BB_Exchange__c.getInstance(exchId)!=Null){
                // Get 'Market Category' and 'WBC Enabled' information from Exchange__c Custom Setting          
                if(BB_Exchange__c.getInstance(exchId).WBC_ADSL2_Enabled__c!=Null){
                    wbc = BB_Exchange__c.getInstance(exchId).WBC_ADSL2_Enabled__c;          
                }
                if(BB_Exchange__c.getInstance(exchId).Market_Category__c!=Null){
                    mktCat = BB_Exchange__c.getInstance(exchId).Market_Category__c;         
                }
                List<BB_Products__c> pList = [Select Id,Name,WBC__c,Market_Category__c,Product_Id__c,Product_Name__c,Product_Category__c,Product_Sale_Status__c 
                                                     From BB_Products__c Where WBC__c=:wbc and Market_Category__c=:mktCat order by Product_Name__c];
                system.debug('*** Product List ***'+pList.size()+' '+pList);
                if(pList.size()>0){
                    Set<String> productNames = new Set<String>();
                    for(BB_Products__c p : pList){
                        productNames.add(p.Product_Name__c);
                    }
                    for(String pn : productNames){
                        productList += pn + ';';
                    }
                }
                else{
                    // Return none if no products found
                    productList = 'None';   
                }
            }
            else{
                productList = 'None';
            }                                                           
        }
        else{
            productList = 'None';
        }               
        return productList;         
    }
    
    // Get Download Speed
    public static String getDownSpeed(String exchId, String anfp, String circuitLineLengthEstimate, String dpLineLengthEstimate, String circuitLineLengthCalculated, String celerityDBLoss, String calculatedDBLoss){       
        String downSpeed = '';
        Double lineLength = 0;
        Double dbLoss = 0;
        if(!(exchId==Null || exchId=='')){
            if(BB_Exchange__c.getInstance(exchId)!=Null){                           
                if(!(circuitLineLengthEstimate==Null || circuitLineLengthEstimate=='')){
                    lineLength = Double.valueOf(circuitLineLengthEstimate);
                }
                else if(!(dpLineLengthEstimate==Null || dpLineLengthEstimate=='')){
                    lineLength = Double.valueOf(dpLineLengthEstimate);  
                }
                else if(!(celerityDBLoss==Null || celerityDBLoss=='')){
                    dbLoss = Double.valueOf(celerityDBLoss);
                }
                else if(!(circuitLineLengthCalculated==Null || circuitLineLengthCalculated=='')){
                    lineLength = Double.valueOf(circuitLineLengthCalculated);
                }
                else if(!(calculatedDBLoss==Null || calculatedDBLoss=='')){
                    dbLoss = Double.valueOf(calculatedDBLoss);
                }
                // Select row from speed table
                List<BB_Speed__c> bbSpeedList;
                if(lineLength!=0){
                    bbSpeedList = [Select Id,Name,ANFP__c,Line_Length__c,DB_Loss__c,Fibre_Down_Speed__c,Fibre_Up_Speed__c,WBC_ADSL2_Down_Speed__c,WBC_ADSL2_Up_Speed__c,IPS_Down_Speed__c,IPS_Up_Speed__c 
                                   From BB_Speed__c Where Line_Length__c>=:lineLength order by Line_Length__c asc limit 1]; 
                }
                else if(dbLoss!=0){
                    bbSpeedList = [Select Id,Name,ANFP__c,Line_Length__c,DB_Loss__c,Fibre_Down_Speed__c,Fibre_Up_Speed__c,WBC_ADSL2_Down_Speed__c,WBC_ADSL2_Up_Speed__c,IPS_Down_Speed__c,IPS_Up_Speed__c 
                                   From BB_Speed__c Where DB_Loss__c>=:dbLoss order by DB_Loss__c asc limit 1]; 
                }
                if(bbSpeedList!=Null){
                    if(bbSpeedList.size()>0){               
                        BB_Speed__c bbspeed = bbSpeedList[0];
                        // Select column from speed table               
                        // Get producttype (Fibre_FTTC or WBC_ADSL2 or IPStream_SDSL or IPStream_ADSLMax or IPStream_ADSL) in priority order from BB_Exchange__c Custom Setting             
                        BB_Exchange__c exch = BB_Exchange__c.getInstance(exchId);
                        if(exch.WBC_ADSL2_Enabled__c){
                            downSpeed = String.valueOf(bbspeed.WBC_ADSL2_Down_Speed__c)+'meg';   
                        }
                        else if(exch.IPStream_Enabled__c){
                            downSpeed = String.valueOf(bbspeed.IPS_Down_Speed__c)+'meg';
                        }
                    }
                }
            }
        }
        return downSpeed;           
    }
    
    // Get Upload Speed
    public static String getUpSpeed(String exchId, String anfp, String circuitLineLengthEstimate, String dpLineLengthEstimate, String circuitLineLengthCalculated, String celerityDBLoss, String calculatedDBLoss){     
        String upSpeed = '';
        Double lineLength = 0;
        Double dbLoss = 0;
        if(!(exchId==Null || exchId=='')){
            if(BB_Exchange__c.getInstance(exchId)!=Null){                           
                if(!(circuitLineLengthEstimate==Null || circuitLineLengthEstimate=='')){
                    lineLength = Double.valueOf(circuitLineLengthEstimate);
                }
                else if(!(dpLineLengthEstimate==Null || dpLineLengthEstimate=='')){
                    lineLength = Double.valueOf(dpLineLengthEstimate);  
                }
                else if(!(celerityDBLoss==Null || celerityDBLoss=='')){
                    dbLoss = Double.valueOf(celerityDBLoss);
                }
                else if(!(circuitLineLengthCalculated==Null || circuitLineLengthCalculated=='')){
                    lineLength = Double.valueOf(circuitLineLengthCalculated);
                }
                else if(!(calculatedDBLoss==Null || calculatedDBLoss=='')){
                    dbLoss = Double.valueOf(calculatedDBLoss);
                }
                // Select row from speed table
                List<BB_Speed__c> bbSpeedList;
                if(lineLength!=0){
                    bbSpeedList = [Select Id,Name,ANFP__c,Line_Length__c,DB_Loss__c,Fibre_Down_Speed__c,Fibre_Up_Speed__c,WBC_ADSL2_Down_Speed__c,WBC_ADSL2_Up_Speed__c,IPS_Down_Speed__c,IPS_Up_Speed__c 
                                   From BB_Speed__c Where Line_Length__c>=:lineLength order by Line_Length__c asc limit 1]; 
                }
                else if(dbLoss!=0){
                    bbSpeedList = [Select Id,Name,ANFP__c,Line_Length__c,DB_Loss__c,Fibre_Down_Speed__c,Fibre_Up_Speed__c,WBC_ADSL2_Down_Speed__c,WBC_ADSL2_Up_Speed__c,IPS_Down_Speed__c,IPS_Up_Speed__c 
                                   From BB_Speed__c Where DB_Loss__c>=:dbLoss order by DB_Loss__c asc limit 1]; 
                }
                if(bbSpeedList!=Null){
                    if(bbSpeedList.size()>0){               
                        BB_Speed__c bbspeed = bbSpeedList[0];
                        // Select column from speed table               
                        // Get producttype (Fibre_FTTC or WBC_ADSL2 or IPStream_SDSL or IPStream_ADSLMax or IPStream_ADSL) in priority order from BB_Exchange__c Custom Setting             
                        BB_Exchange__c exch = BB_Exchange__c.getInstance(exchId);
                        if(exch.WBC_ADSL2_Enabled__c){
                            upSpeed = String.valueOf(bbspeed.WBC_ADSL2_Up_Speed__c)+'meg';   
                        }
                        else if(exch.IPStream_Enabled__c){
                            upSpeed = String.valueOf(bbspeed.IPS_Up_Speed__c)+'meg';
                        }
                    }
                }
            }
        }   
        return upSpeed;         
    }

}