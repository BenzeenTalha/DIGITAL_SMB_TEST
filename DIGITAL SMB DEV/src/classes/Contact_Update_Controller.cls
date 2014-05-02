public class Contact_Update_Controller {
	 
	// Contact being controlled
	private Contact con;
	
	// The status of the record - requiring update, updated, not relevant etc etc
	public String updateStatus {get;set;} {this.updateStatus = Label.CHECK_CON_UPDATE;}

	// Constructor
	public Contact_Update_Controller(ApexPages.StandardController stdController) {
	    this.con = (Contact)stdController.getRecord();
	} // end constructor

	// Actions for checking the update status
	public PageReference checkUpdateStatus() {

		// First check to see if the record has been udpdated since last viewed

		if (this.con.recordUpdated__c) {

			// Only continue if there is at least one billing code registered in OAR
			// that has not been handed over
			if (((this.con.account.OAR_Account_Reference_1__c != null) && (this.con.account.OAR_Account_1_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) ||
				((this.con.account.OAR_Account_Reference_2__c != null) && (this.con.account.OAR_Account_2_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) ||
				((this.con.account.OAR_Account_Reference_3__c != null) && (this.con.account.OAR_Account_3_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) ||
				((this.con.account.OAR_Account_Reference_4__c != null) && (this.con.account.OAR_Account_4_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED')))) {

				// If this record has not yet been registered in OAR, then we register it.  Otherwise we update it.
				if (this.con.OAR_Registered_Date__c != null) {
					System.debug('Updating contact');
					this.updateStatus = O2_linkage_utils.updateContact(this.con.Id);
					System.debug('Returning from contact update');
				}
				else {
					this.updateStatus = O2_linkage_utils.createContact(this.con.Id);						
				}
			} // end billing code check if
			else {
				this.updateStatus = Label.NO_OAR_HANDOVER;
			} // end billing code check else
		} // end record updated since last viewed check if
		else {

			this.updateStatus = Label.NO_UPDATE;
		} // end record updated since last viewed check else

		return null;
	} // end checkUpdateStatus
	
		
} // end class