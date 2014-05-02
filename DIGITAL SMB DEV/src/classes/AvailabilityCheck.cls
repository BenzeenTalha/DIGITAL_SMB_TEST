/*
* 	This class is used to store the object structure to keep state during the response translation and saving of data
*	SO'Halloran - (SFDC)
* 	Revision History
*	1.0    16/02/2011  Initial Version
*/  
public with sharing class AvailabilityCheck { 
	
	public Line_Availability__c lineAvailability = new Line_Availability__c();
	
	public List <Line_Availability_CNF__c> callingAndNetworkFeatures = new List <Line_Availability_CNF__c>();	
    public List <Bearer> bearers = new List <Bearer>();	
    public List <MBN> mbns = new List <MBN>();
    public List <Line_Availability_Directory__c> directories = new List <Line_Availability_Directory__c>();
    public List <Line_Availability_Unsupported_Feature__c> unsupportedFeatures = new List <Line_Availability_Unsupported_Feature__c>();

    // Main Billing Number Structure
    public class MBN {
    	public MBN (Line_Availability_Main_Billing_Number__c mainBillingNumberDetail) {
    		this.mainBillingNumberDetail = mainBillingNumberDetail;
    	}
    	public Line_Availability_Main_Billing_Number__c mainBillingNumberDetail;
    	public List <Line_Availability_CNF__c> callingAndNetworkFeatures = new List <Line_Availability_CNF__c>();
    	public List <Channel> channels = new List <Channel>();	
    	public List <Line_Availability_Unsupported_Feature__c> unsupportedFeatures = new List <Line_Availability_Unsupported_Feature__c>();
   	 	public List <Line_Availability_SNDDI__c> snddis = new List <Line_Availability_SNDDI__c>();
    	public List <Line_Availability_MultSubNum__c> multisubnums = new List <Line_Availability_MultSubNum__c>();
    	public List <Line_Availability_Directory__c> directories = new List <Line_Availability_Directory__c>();
    	public List <Line_Availability_DDI_Range__c> ddiRanges = new List <Line_Availability_DDI_Range__c>();
    }
    
    // Bearer Structure
    public class Bearer {
    	public Bearer (Line_Availability_Bearer__c bearerDetail) {
    		this.bearerDetail = bearerDetail;
    	}
    	public Line_Availability_Bearer__c bearerDetail;
    	public List <Channel> channels = new List <Channel>();
    }
	
	// Channel Structure
    public class Channel {
    	public Channel (Line_Availability_Channel__c channelDetail) {
    		this.channelDetail = channelDetail;
    	}    	
    	public Line_Availability_Channel__c channelDetail;
    	public List <Line_Availability_DDI_Range__c> ddiRanges = new List <Line_Availability_DDI_Range__c>();
    }
    
    // Line availability    
    public AvailabilityCheck (Line_Availability__c lineAvail) {
    	lineAvailability = lineAvail;
    }

	// Navigate the structure to get all channels and write parent ids
    public List <Line_Availability_Channel__c> getChannels () {
		List <Line_Availability_Channel__c> channels = new List <Line_Availability_Channel__c>();
		for(Bearer b : this.bearers) {			
			for(Channel c: b.channels) {
				Line_Availability_Channel__c ch = c.channelDetail;
				ch.Line_Availability__c = lineAvailability.Id;
				ch.Line_Availability_Bearer__c = b.bearerDetail.Id;
				channels.add(ch);
			}
		}     	
		for(MBN m : this.mbns) {
			for(Channel c: m.channels) {
				Line_Availability_Channel__c ch = c.channelDetail;
				ch.Line_Availability__c = lineAvailability.Id;
				ch.Line_Availability_Main_Billing_Number__c = m.mainBillingNumberDetail.Id;
				channels.add(ch);
			}
		}
    	return channels;
   	}      
    
    // Navigate the structure to get all CNFs and write parent ids
    public List <Line_Availability_CNF__c> getCallingAndNetworkFeatures () {
		List <Line_Availability_CNF__c> cnfs = new List <Line_Availability_CNF__c>();
		for(Line_Availability_CNF__c cnf : this.callingAndNetworkFeatures) {			
			cnf.Line_Availability__c = lineAvailability.Id;
			cnfs.add(cnf);
		}     	
		for(MBN m : this.mbns) {
			for(Line_Availability_CNF__c cnf : m.callingAndNetworkFeatures) {
				cnf.Line_Availability__c = lineAvailability.Id;
				cnf.Line_Availability_Main_Billing_Number__c = m.mainBillingNumberDetail.Id;
				cnfs.add(cnf);
			}
		}
    	return cnfs;
   	}    	

	// Navigate the structure to get all Unsupported features and write parent ids
    public List <Line_Availability_Unsupported_Feature__c> getUnsupportedFeatures () {
		List <Line_Availability_Unsupported_Feature__c> usfs = new List <Line_Availability_Unsupported_Feature__c>();
		for(Line_Availability_Unsupported_Feature__c usf : this.unsupportedFeatures) {			
			usf.Line_Availability__c = lineAvailability.Id;
			usfs.add(usf);
		}     	
		for(MBN m : this.mbns) {
			for(Line_Availability_Unsupported_Feature__c usf : m.unsupportedFeatures) {
				usf.Line_Availability__c = lineAvailability.Id;
				usf.Line_Availability_Main_Billing_Number__c = m.mainBillingNumberDetail.Id;
				usfs.add(usf);
			}
		}
    	return usfs;
   	}
 
	// Navigate the structure to get all MSNs and write parent ids   	
    public List <Line_Availability_MultSubNum__c> getMultiSubNumbers () {
		List <Line_Availability_MultSubNum__c> msns = new List <Line_Availability_MultSubNum__c>(); 	
		for(MBN m : this.mbns) {
			for(Line_Availability_MultSubNum__c msn : m.multisubnums) {
				msn.Line_Availability_Main_Billing_Number__c = m.mainBillingNumberDetail.Id;
				msns.add(msn);
			}
		}
    	return msns;
   	}

	// Navigate the structure to get all DDI Ranges and write parent ids  
    public List <Line_Availability_DDI_Range__c> getDDIRanges () {
		List <Line_Availability_DDI_Range__c> ddiRanges = new List <Line_Availability_DDI_Range__c>(); 	
		for(MBN m : this.mbns) {
			for(Line_Availability_DDI_Range__c ddiRange : m.ddiRanges) {
				ddiRange.Line_Availability__c = lineAvailability.Id;
				ddiRange.Line_Availability_Main_Billing_Number__c = m.mainBillingNumberDetail.Id;
				ddiRanges.add(ddiRange);
			}
		}
		for(Bearer b : this.bearers) {			
			for(Channel c: b.channels) {
				for(Line_Availability_DDI_Range__c ddiRange : c.ddiRanges) {
					ddiRange.Line_Availability__c = lineAvailability.Id;
					ddiRange.Line_Availability_Channel__c = c.channelDetail.Id;
				}
			}
		}  	
    	return ddiRanges;
   	}
   	   	
	// Navigate the structure to get all SNDDIs and write parent ids   	   	
    public List <Line_Availability_SNDDI__c> getSNDDIs () {
		List <Line_Availability_SNDDI__c> snddis = new List <Line_Availability_SNDDI__c>(); 	
		for(MBN m : this.mbns) {
			for(Line_Availability_SNDDI__c snddi : m.snddis) {
				snddi.Line_Availability_Main_Billing_Number__c = m.mainBillingNumberDetail.Id;
				snddis.add(snddi);
			}
		}
    	return snddis;
   	}

	// Navigate the structure to get all Directories and write parent ids   	
    public List <Line_Availability_Directory__c> getDirectories () {
		List <Line_Availability_Directory__c> dirs = new List <Line_Availability_Directory__c>();
		for(Line_Availability_Directory__c dir : this.directories) {			
			dir.Line_Availability__c = lineAvailability.Id;
			dirs.add(dir);
		}     	
		for(MBN m : this.mbns) {
			for(Line_Availability_Directory__c dir : m.directories) {
				dir.Line_Availability__c = lineAvailability.Id;
				dir.Line_Availability_Main_Billing_Number__c = m.mainBillingNumberDetail.Id;
				dirs.add(dir);
			}
		}
    	return dirs;
   	}   	
   	      	
	// Navigate the structure to get all Bearers and write parent ids   	   	
    public List <Line_Availability_Bearer__c> getBearers () {
    	List <Line_Availability_Bearer__c> laBearers = new List <Line_Availability_Bearer__c>();
		for(Bearer b : this.bearers) {
			b.bearerDetail.Line_Availability__c = lineAvailability.Id;
			laBearers.add(b.bearerDetail);
		}     	
    	return laBearers;
   	}   
   	
	// Navigate the structure to get all Main Billing Numbers and write parent ids   	
    public List <Line_Availability_Main_Billing_Number__c> getMainBillingNumbers () {
    	List <Line_Availability_Main_Billing_Number__c> laMBN = new List <Line_Availability_Main_Billing_Number__c>();
		for(MBN mbn : this.mbns) {
			mbn.mainBillingNumberDetail.Line_Availability__c = lineAvailability.Id;
			laMBN.add(mbn.mainBillingNumberDetail);
		}     	
    	return laMBN;
   	}       	
}