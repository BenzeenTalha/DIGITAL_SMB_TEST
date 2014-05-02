global class BoostboxWS {

static public boolean testFault=false;// { get; set; }

    //public BoostboxWS() {
        //testFault=false;
    //}

    WebService static String updateOrderCSR(Id orderId) {

        Order__c parentOrder=[select id, DISE_Order_No__c, CSR_No__c, Product_Configuration__c from Order__c where id=:orderId];
        
        String result='No change required';
        if(parentOrder.DISE_Order_No__c == null || parentOrder.DISE_Order_No__c =='') {
            result='Please enter DISE Order No';
        }
        if (parentOrder.Product_Configuration__c != null && parentOrder.DISE_Order_No__c != null && parentOrder.DISE_Order_No__c.trim().length() > 0) {             
                
            // Load config attributes into map
            Set<Id> configIds = new Set<Id>();
            configIds.add(parentOrder.Product_Configuration__c);
            system.debug('***configIds: '+configIds);
            
            Map<Id, BoostboxHelper.BoostboxDef> configToAttributeMap = BoostboxHelper.getConfigAttrMap(configIds);
            system.debug('***configToAttributeMap'+configToAttributeMap);
            
            // Fetch and update Order CSR number
            try {
                BoostboxHelper.BoostboxDef boostboxDef = configToAttributeMap.get(parentOrder.Product_Configuration__c);
                parentOrder.CSR_No__c=getOrderCSR(parentOrder, boostboxDef, testFault);
                update parentOrder;
                result='Success';
            }
            catch (FemtocellSOAHandler.ResponseException e) {
                System.debug('***ResponseException'+e.getMessage());
                result='Error trying to find the Cell Site Reference Number: ' + e.getMessage();
            } 
            catch (Exception e) {
                System.debug('***Exception'+e.getMessage());
                result='Error updating Order: '+orderId+' Fault:' + e.getMessage();
            }
                        
        }
        System.debug('***returning :'+result);
        return result;
    }
    
    static public String getOrderCSR(Order__c ord, BoostboxHelper.BoostboxDef boostboxDef, boolean testSOAFault) {
        
        FemtocellSOAHandler.Address addr=new FemtocellSOAHandler.Address();
        addr.buildingName=(boostboxDef.Installation_Address_Building_Name!=null ? boostboxDef.Installation_Address_Building_Name : '');
        addr.buildingNumber=(boostboxDef.Installation_Address_Building_Number!=null ? boostboxDef.Installation_Address_Building_Number : '');
        addr.street=(boostboxDef.Installation_Address_Street!=null ? boostboxDef.Installation_Address_Street : '');
        addr.subBuildingName=(boostboxDef.Installation_Address_Sub_Building_Name!=null ? boostboxDef.Installation_Address_Sub_Building_Name : '');
        addr.postTown=(boostboxDef.Installation_Address_Post_Town!=null ? boostboxDef.Installation_Address_Post_Town : '');
        addr.postcode=(boostboxDef.Installation_Address_Postal_Code!=null ? boostboxDef.Installation_Address_Postal_Code : '');
        addr.county=(boostboxDef.Installation_Address_County!=null ? boostboxDef.Installation_Address_County : '');
        
        String orderRef=(ord.DISE_Order_No__c!=null ? ord.DISE_Order_No__c : '');
        String cellType='';
        if(boostboxDef.Boostbox_Type.contains('Standard')) {
            cellType='Home';
        } else if(boostboxDef.Boostbox_Type.contains('Large')) { 
            cellType='Enterprise';
        }
        String operationalMode=(boostboxDef.Closed ? 'C' : 'O');
        String userName=UserInfo.getUserName();
        if(userName.length()>20) userName=userName.substring(0, 20);
        
        FemtocellSOAHandler handler =  new FemtocellSOAHandler();
        if(testSOAFault) handler.testFault=true;
        
        system.debug('***ord and boostboxDef'+ord+' ***:'+boostboxDef);
        handler.provisionRadioParameters_1(orderRef,cellType,operationalMode,userName,addr);
        system.debug('***CellSiteRef'+handler.getMNDCellSiteReferenceNumber());
        
        return handler.getMNDCellSiteReferenceNumber();     
    }

}