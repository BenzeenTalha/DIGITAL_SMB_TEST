/*
*   This class is used to store the records in batches for DML
*   It also sets the parent Id of the child objects
*   SO'Halloran - (SFDC)
*   Revision History
*   1.0    16/02/2011  Initial Version
*/  
public with sharing class AvailabilityCheckList {

    List <AvailabilityCheck> availChecks = new List <AvailabilityCheck>();
    
    
    public void add(AvailabilityCheck availCheck) {  
        availChecks.add(availCheck);
    }
    
    public boolean isEmpty() {
    	return availChecks.isEmpty();
    }
        
    public void save(Batch_Job__c batchJob) {
    	upsert batchJob;
        for(AvailabilityCheck availCheck: availChecks) {
            availCheck.lineAvailability.Batch_Job__c = batchJob.Id;
        }
    	this.save();
    }
        
    public void save() {
        
        // Group the data together for batch DML operation
        List <Line_Availability__c> lineAvailabilityList = new List <Line_Availability__c>();    
        List <Line_Availability_CNF__c> cnfs = new List <Line_Availability_CNF__c>();
        List <Line_Availability_Directory__c> directories = new List <Line_Availability_Directory__c>();
        List <Line_Availability_Unsupported_Feature__c> unsupportedFeatures = new List <Line_Availability_Unsupported_Feature__c>();
        List <Line_Availability_Bearer__c> bearers = new List <Line_Availability_Bearer__c>();
        List <Line_Availability_Main_Billing_Number__c> mbns = new List <Line_Availability_Main_Billing_Number__c>();
        List <Line_Availability_Channel__c> channels = new List <Line_Availability_Channel__c>();
        List <Line_Availability_SNDDI__c> SNDDIs = new List <Line_Availability_SNDDI__c>();
        List <Line_Availability_MultSubNum__c> multiSubNumbers = new  List <Line_Availability_MultSubNum__c>();
        List <Line_Availability_DDI_Range__c> ddiRanges = new List <Line_Availability_DDI_Range__c>();
        
        Database.Upsertresult[] ddiRangesSR;
        Database.Upsertresult[] bearersSR;
        Database.Upsertresult[] mbnsSR; 
        Database.Upsertresult[] channelsSR;
        Database.Upsertresult[] multiSubNumbersSR;
        Database.Upsertresult[] SNDDIsSR;
        Database.Upsertresult[] cnfsSR;
        Database.Upsertresult[] unsupportedFeaturesSR;
        Database.Upsertresult[] directoriesSR;
        Database.Upsertresult[] laSR;
        
        // Level 4
        // Write the parent Id and collate type of record for DML
        //for(AvailabilityCheck availCheck: availChecks) {
        //    ddiRanges.addAll(availCheck.getDDIRanges());
        //}
        //if(!ddiRanges.isEmpty()) ddiRangesSR = database.insert(ddiRanges,false);  
 
        
        // Level 1 - Generic Row
        for(AvailabilityCheck availCheck: availChecks) {
            lineAvailabilityList.add(availCheck.lineAvailability);
        }
        
        laSR = database.upsert(lineAvailabilityList,false);
         
        // Level 2 - Bearers & Main Billing Numbers
        // Write the parent Id and collate type of record for DML
        for(AvailabilityCheck availCheck : availChecks) {
            bearers.addAll(availCheck.getBearers());  
            mbns.addAll(availCheck.getMainBillingNumbers());    
        }   
        if(!bearers.isEmpty()) bearersSR = database.upsert(bearers,false);
        if(!mbns.isEmpty()) mbnsSR = database.upsert(mbns,false);        
        
        // Level 3 - Channels
        // Write the parent Ids and collate type of record for DML
        for(AvailabilityCheck availCheck: availChecks) {
            channels.addAll(availCheck.getChannels()); 
            multiSubNumbers.addAll(availCheck.getMultiSubNumbers());   
            SNDDIs.addAll(availCheck.getSNDDIs());      
            cnfs.addAll(availCheck.getCallingAndNetworkFeatures()); 
            unsupportedFeatures.addAll(availCheck.getUnsupportedFeatures()); 
            directories.addAll(availCheck.getDirectories());   
        }         
        
        if(!channels.isEmpty()) channelsSR = database.upsert(channels,false);  
        if(!multiSubNumbers.isEmpty()) multiSubNumbersSR = database.upsert(multiSubNumbers,false);
        if(!SNDDIs.isEmpty()) SNDDIsSR = database.upsert(SNDDIs,false);          
        if(!cnfs.isEmpty()) cnfsSR = database.upsert(cnfs,false);
        if(!unsupportedFeatures.isEmpty())  unsupportedFeaturesSR = database.upsert(unsupportedFeatures,false);        
        if(!directories.isEmpty()) directoriesSR = database.upsert(directories,false);
        
        // Level 4
        // Write the parent Id and collate type of record for DML
        for(AvailabilityCheck availCheck: availChecks) {
            ddiRanges.addAll(availCheck.getDDIRanges());
        }
        if(!ddiRanges.isEmpty()) ddiRangesSR = database.upsert(ddiRanges,false); 
        
        checkResults(laSR);		
        checkResults(ddiRangesSR);
        checkResults(bearersSR);
        checkResults(mbnsSR);
        checkResults(channelsSR);
        checkResults(multiSubNumbersSR);
        checkResults(SNDDIsSR);
        checkResults(cnfsSR);
        checkResults(unsupportedFeaturesSR);
        checkResults(directoriesSR);		
    }
    
    private static void checkResults(Database.UpsertResult[] lsr) {
		if(lsr!=null) {
			for(Database.UpsertResult sr : lsr){
				if(!sr.isSuccess()){
					Database.Error err = sr.getErrors()[0];
					throw new SOAUtils.DMLMethodException(err.getStatusCode() +':'+ err.getMessage());
				}  
			}    
		}
    }
}