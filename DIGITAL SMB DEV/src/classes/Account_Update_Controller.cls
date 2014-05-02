/*****************************************************************************/
/* Paul Tarpey (paul.tarpey@saaspoint.com)                                   */
/* This is the controller for the account checking visulforce inline page    */
/* that checks if an OAR update needs to take place and makes the call if    */
/* necessary                                                                 */  
/*                                                                           */
/* Revision History                                                          */
/* 0.1    11/02/2009  Initial Version                                        */
/*                                                                           */
/*                                                                            */
/*****************************************************************************/
public class Account_Update_Controller {

	// Account being controlled
	private Account acct;
	
	// The status of the record - requiring update, updated, not relevant etc etc
	public String updateStatus {get;private set;} {updateStatus = Label.CHECK_AA_UPDATE;}
	
	// Actions for checking the update status
	public PageReference checkUpdateStatus() {

		// Only continue if there is at least one billing code registered in OAR
		// that has not been handed over
		if (((this.acct.OAR_Account_Reference_1__c != null) && (this.acct.OAR_Account_1_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) ||
			((this.acct.OAR_Account_Reference_2__c != null) && (this.acct.OAR_Account_2_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) ||
			((this.acct.OAR_Account_Reference_3__c != null) && (this.acct.OAR_Account_3_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED'))) ||
			((this.acct.OAR_Account_Reference_4__c != null) && (this.acct.OAR_Account_4_Handover_Status__c != O2_linkage_configuration.getParam('HANDOVER_ACCEPTED')))) {
					
			// Check to see if the record has been udpdated since last viewed
			if (this.acct.recordUpdated__c) {		
							
				// We need to update the record in OAR
				this.updateStatus = O2_linkage_utils.updateAccount(this.acct.Id);
				
				// Unset the edit flag
				Account updateAccount = new Account(Id = this.acct.Id,
													recordUpdated__c = false);
				update updateAccount;
			} // end billing code check if
			else {
				this.updateStatus = Label.NO_UPDATE;
			} // end billing code check else
		} // end record updated since last viewed check if
		else {
			this.updateStatus = Label.NO_OAR_HANDOVER;
		} // end record updated since last viewed check else
		return null;
	} // end checkUpdateStatus
	
	// Constructor
	public Account_Update_Controller(ApexPages.StandardController stdController) {
	    this.acct = (Account)stdController.getRecord();
	} // end constructor
	
	
} // end Account_Update_Controller