/*
    Access and Control methods called from the AC_Container and DISE_ID_Map triggers
*/
public class AC_Container_Sharing {
    //
    // **** Called from AC_Corporate_ID_Map Trigger 
    // Associate or Disassocate containers to accounts - driven from validated Corporate ID Map 
    // This controls access for HVPU licensed users
    public static void linkDISEAccounts(Map<Id, AC_Corporate_ID_Map__c> acCorpIDMap) {
        linkDISEAccounts(acCorpIDMap, true);
    }
    
    public static void linkDISEAccounts(Map<Id, AC_Corporate_ID_Map__c> oldAcCorpIDMap, Map<Id, AC_Corporate_ID_Map__c> acCorpIDMap) {
        Map <String, Id> diseIdMap = new Map <String, Id>();
        for (Id accIdMapKey : acCorpIDMap.keySet()) {
            AC_Corporate_ID_Map__c newRec = acCorpIDMap.get(accIdMapKey);
            AC_Corporate_ID_Map__c oldRec = oldAcCorpIDMap.get(accIdMapKey);
            if((oldRec.Validated_Ind__c != newRec.Validated_Ind__c) ||
                (oldRec.DISE_Account_No__c != newRec.DISE_Account_No__c) ||
                    (oldRec.SFAccountID__c != newRec.SFAccountID__c)) {
                    
                    if(newRec.Validated_Ind__c) {
                        newRec.Validated_By__c = UserInfo.getUserId();
                        newRec.Validated_Date__c = System.now();
                        diseIdMap.put(newRec.DISE_Account_No__c,newRec.SFAccountID__c);
                    } else {
                        newRec.Validated_By__c = null;
                        newRec.Validated_Date__c = null;                        
                        diseIdMap.put(newRec.DISE_Account_No__c,null);
                    }
                    if(oldRec.Validated_Ind__c && oldRec.DISE_Account_No__c != newRec.DISE_Account_No__c) {
                        diseIdMap.put(oldRec.DISE_Account_No__c,null);
                    }
            }
        }
        linkDISEAccounts(diseIdMap);
    }
    
    public static void unlinkDISEAccounts(Map<Id, AC_Corporate_ID_Map__c> acCorpIDMap) {   
        linkDISEAccounts(acCorpIDMap, false);
    }    
    
    private static void linkDISEAccounts(Map <String, Id> diseIdMap) {
        if(!diseIdMap.isEmpty()) {
            for(AC_Container__c[] acs : [select id, SFAccountId__c, DISE_Account_No__c from AC_Container__c 
                                            where DISE_Account_No__c in: diseIdMap.keySet()]) {
                List <AC_Container__c> acsToUpdate = new List <AC_Container__c>();
                for(AC_Container__c ac: acs) {
                    ac.SFAccountId__c = diseIdMap.get(ac.DISE_Account_No__c);                 
                    acsToUpdate.add(ac);                   
                }
                if(!acsToUpdate.isEmpty()) {
                    Database.update (acsToUpdate, true);
                }
            }  
        }  
    }
    
    private static void linkDISEAccounts(Map<Id, AC_Corporate_ID_Map__c> acCorpIDMap, boolean isAdd) {
        Map <String, Id> diseIdMap = new Map <String, Id>();
        for (AC_Corporate_ID_Map__c accIdMap : acCorpIDMap.values()) {
            if(accIdMap.Validated_Ind__c) {
                Id sfId = null;
                if(isAdd) sfId = accIdMap.SFAccountID__c;
                diseIdMap.put(accIdMap.DISE_Account_No__c,sfId);
            }
        }
        linkDISEAccounts(diseIdMap);
    }
    //
    // **** Called from AC_Container__c Trigger 
    // This controls access for Partners and HVPU licensed users
    //
    public static void shareContainersOnInsert(Map<Id, AC_Container__c> acContainers) {
        
        Set <Id> partnerAccountIds = new Set <Id>();
        Set <String> diseAccountNos = new Set <String>();
        for (AC_Container__c acc : acContainers.values()) {
            if(acc.CT_Organisation_Container__c!=null) {
                partnerAccountIds.add(acc.CT_Organisation_Container__c);
            }
            if(acc.MB_Organisation_Container__c!=null) {
                partnerAccountIds.add(acc.MB_Organisation_Container__c);
            }
        }    
        if(!partnerAccountIds.isEmpty()) {
            shareContainers(partnerAccountIds, acContainers.values());
        }
    }
    
    public static void shareContainersOnUpdate(Map<Id, AC_Container__c> oldAcContainers, Map<Id, AC_Container__c> acContainers){
        
        Set <Id> partnerAccountIds = new Set <Id>();
        Set <Id> oldContainerCTPartners = new Set <Id>();
        Set <Id> oldContainerMBPartners = new Set <Id>();
        for (AC_Container__c acc : acContainers.values()) {
            if(acc.CT_Organisation_Container__c!=null) {
                partnerAccountIds.add(acc.CT_Organisation_Container__c);
            }
            if(acc.MB_Organisation_Container__c!=null) {
                partnerAccountIds.add(acc.MB_Organisation_Container__c);
            }
            if(oldAcContainers.get(acc.Id).CT_Organisation_Container__c!=null && acc.CT_Organisation_Container__c!=oldAcContainers.get(acc.Id).CT_Organisation_Container__c) {
                oldContainerCTPartners.add(acc.Id);
            }
            if(oldAcContainers.get(acc.Id).MB_Organisation_Container__c!=null && acc.MB_Organisation_Container__c!=oldAcContainers.get(acc.Id).MB_Organisation_Container__c) {
                oldContainerMBPartners.add(acc.Id);
            }                                             
        }    
        if(!oldContainerCTPartners.isEmpty() || !oldContainerMBPartners.isEmpty()) {
            deleteShares(oldContainerCTPartners,oldContainerMBPartners);
        }
        if(!partnerAccountIds.isEmpty()) {
            shareContainers(partnerAccountIds, acContainers.values());
        }
    }

    
    public static void linkAccounts(Map <Id, AC_Container__c> oldAcContainers, List <AC_Container__c> acContainers) {
        Set <String> diseAccountNos = new Set <String>();
        Map <String, Id> diseAccountMap = new Map <String, Id>();
        
        for (AC_Container__c acc : acContainers) {
            
            // If DISE no not null and inserted or updated
            //if(acc.DISE_Account_No__c!=null && (oldAcContainers==null || oldAcContainers.get(acc.Id).DISE_Account_No__c!=acc.DISE_Account_No__c)) {
                diseAccountNos.add(acc.DISE_Account_No__c);
            //}
                 
        }

        if(!diseAccountNos.isEmpty()) {
            for(AC_Corporate_ID_Map__c accMap : [select id, DISE_Account_No__c, SFAccountID__c 
                                                    from AC_Corporate_ID_Map__c 
                                                    where DISE_Account_No__c in: diseAccountNos 
                                                     and Validated_Ind__c=true]) {
                diseAccountMap.put(accMap.DISE_Account_No__c, accMap.SFAccountID__c);
            }
        }
        for (AC_Container__c acc : acContainers) {
            // insert
            if(oldAcContainers==null && acc.DISE_Account_No__c!=null) {
                acc.SFAccountId__c = diseAccountMap.get(acc.DISE_Account_No__c);
            
            } else if (oldAcContainers!=null) {
                //if(acc.DISE_Account_No__c!=oldAcContainers.get(acc.Id).DISE_Account_No__c) {
                    if(acc.DISE_Account_No__c==null) {
                        acc.SFAccountId__c = null;
                    } else {
                        acc.SFAccountId__c = diseAccountMap.get(acc.DISE_Account_No__c);
                    }
                //} 
            }
        
        }

    }
    
    private static void shareContainers(Set<Id> partnerAccountIds, List<AC_Container__c> acContainers) {  
        
        List <AC_Container__Share> containerShares = new List<AC_Container__Share> ();           
        Map <Id, Id> partnerGroupMap = getPartnerGroups(partnerAccountIds);        
        if(!partnerGroupMap.isEmpty()) {
            for (AC_Container__c acc : acContainers) {
                if(acc.CT_Organisation_Container__c!=null && partnerGroupMap.get(acc.CT_Organisation_Container__c)!=null)
                    containerShares.add(createShare(acc.Id, 
                        partnerGroupMap.get(acc.CT_Organisation_Container__c), 
                        Schema.AC_Container__Share.RowCause.Contracted_To__c, 'Edit'));
                
                if(acc.MB_Organisation_Container__c!=null && partnerGroupMap.get(acc.MB_Organisation_Container__c)!=null)
                    containerShares.add(createShare(acc.Id, 
                        partnerGroupMap.get(acc.MB_Organisation_Container__c), 
                        Schema.AC_Container__Share.RowCause.Managed_By__c, 'Edit'));     
            } 
            if(!containerShares.isEmpty()) {           
                Database.SaveResult[] containerSharesResult = Database.insert(containerShares, true);
            }
        }         
    }
    
    private static Map<Id, Id> getPartnerGroups(Set<Id> partnerAccountIds) {
        
        Map <Id, Id> partnerRoleMap = new Map <Id, Id>(); 
        Map <Id, Id> roleGroupMap = new Map <Id, Id>();
        Map <Id, Id> partnerGroupMap = new Map <Id, Id>();
        
        for(UserRole ur : [SELECT Id,PortalAccountId FROM UserRole WHERE PortalType = 'Partner' 
                                AND PortalRole = 'Worker' 
                                AND PortalAccountId in :partnerAccountIds]) {
            partnerRoleMap.put(ur.PortalAccountId, ur.Id);    
        }  
        
        if(!partnerRoleMap.isEmpty()) {
            for(Group g : [SELECT Id, relatedId FROM Group WHERE relatedId in: partnerRoleMap.values()]) {
                roleGroupMap.put(g.relatedId, g.Id);
            }  
            for(Id accId : partnerRoleMap.keySet()) {
                partnerGroupMap.put(accId, roleGroupMap.get(partnerRoleMap.get(accId)));
            }
        }
        return partnerGroupMap;
    }
    
    private static AC_Container__Share createShare(Id accountId, Id groupId, String reason, String accessLevel) {
        
        AC_Container__Share accShare = new AC_Container__Share();
        accShare.AccessLevel = accessLevel;
        accShare.ParentId = accountId;
        accShare.UserOrGroupId = groupId;
        accShare.RowCause = reason;
        return accShare;
    }
    
    private static void deleteShares(Set <Id> oldContainerCTPartners, Set <Id> oldContainerMBPartners) {
        
        for (List <AC_Container__Share> sharesToDel : [select id, parentId, RowCause from AC_Container__Share 
                                where (parentId in:oldContainerCTPartners 
                                AND RowCause =: Schema.AC_Container__Share.RowCause.Contracted_To__c)
                                OR (parentId in:oldContainerMBPartners
                                AND RowCause =: Schema.AC_Container__Share.RowCause.Managed_By__c)]) {
            Database.DeleteResult[] containerSharesResult = Database.delete(sharesToDel, true);
        }    
    }
}