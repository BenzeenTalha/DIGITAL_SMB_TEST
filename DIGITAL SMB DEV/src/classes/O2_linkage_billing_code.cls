public class O2_linkage_billing_code {
	public String accGrpCode {get;private set;}
	public String accountResponse {get;private set;}
	public String handoverStatus {get;private set;}
	public DateTime handoverApproved {get;private set;}
	public String reference {get;private set;}

	public O2_linkage_billing_code(String pAccGrpCode, String pAccountResponse, String pHandoverStatus, DateTime pHandoverApproved, String pReference) {
		this.accGrpCode = pAccGrpCode;
		this.accountResponse = pAccountResponse;
		this.handoverStatus = pHandoverStatus;
		this.handoverApproved = pHandoverApproved;
		this.reference = pReference;
	} // end constructor
	

} // end class