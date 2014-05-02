public class OARRegistrationController {
	
	// Opportunity controlled
	private Opportunity opp;
	
	// Related account
	private Account relatedAcc;
	
	// Registered Status Message
	public String registeredStatus {get;private set;} {this.registeredStatus = Label.INIT_REG_STAT;}
	
	// Constructor
	public OARRegistrationController(ApexPages.StandardController stdController) {
	    this.opp = (Opportunity)stdController.getRecord();
	    this.relatedAcc = [	Select 	Id,
	    							DISE_Group_Code_Account_No_4__c,
	    							DISE_Group_Code_Account_No_3__c, 
	    							DISE_Group_Code_Account_No_2__c, 
	    							DISE_Group_Code_Account_No_1__c,
	    							OAR_Account_Reference_1__c,
	    							OAR_Account_Reference_4__c,
	    							OAR_Account_Reference_3__c,
	    							OAR_Account_Reference_2__c
	    					From Account Where Id = :this.opp.accountId];
	} // end constructor
	
	// Check to see if the record is registered or not
	public PageReference checkOARRegistered() {
			
		// Only relevant if stage name is correct
		if (this.opp.Register_Acc_on_OAR__c == 'Yes') {
			
			// Only attempt to register if there is a DISE billing code with no
			// corresponding OAR reference
			if (((this.relatedAcc.OAR_Account_Reference_1__c == null) && (this.relatedAcc.DISE_Group_Code_Account_No_1__c != null)) ||
				((this.relatedAcc.OAR_Account_Reference_2__c == null) && (this.relatedAcc.DISE_Group_Code_Account_No_2__c != null)) ||
				((this.relatedAcc.OAR_Account_Reference_3__c == null) && (this.relatedAcc.DISE_Group_Code_Account_No_3__c != null)) ||
				((this.relatedAcc.OAR_Account_Reference_4__c == null) && (this.relatedAcc.DISE_Group_Code_Account_No_4__c != null))) {
					
				// Attempt to register 
				String returnStatus = O2_linkage_utils.registerAccount(this.opp.Id,null);
				this.registeredStatus = Label.REG_RET_IS + returnStatus;
			}
			else {
				this.registeredStatus = Label.ALREADY_REG;
			}
		} // end stage name check if
		else {
			this.registeredStatus = Label.NO_NEED_REG;
		} // end stage name check else

		return null;
	} // end checkOARRegistered
	

} // end class