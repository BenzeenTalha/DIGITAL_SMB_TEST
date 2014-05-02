public class tswRufusleonardComChoice {
	
	// Headers and stubs for both live and sandbox.  This class deals with checking
	// which system we are on and using the correct ones
	private tswRufusleonardCom.SingleSignOnAuthenticationHeader sandboxHeader;
	private tswRufusleonardCom_Live.SingleSignOnAuthenticationHeader liveHeader;
	private tswRufusleonardCom.SingleSignOnSoap sandboxStub;
	private tswRufusleonardCom_Live.SingleSignOnSoap liveStub;
	
	// Constructor - takes the header username and password
	public tswRufusleonardComChoice (String un, String pw) {
		
		// If we are on production then set up live web service classes
		if (O2_linkage_configuration.getCurrentSystem() == Label.Production_String) {
			this.liveHeader = new tswRufusleonardCom_Live.SingleSignOnAuthenticationHeader();
			this.liveHeader.Username = un;
			this.liveHeader.Password = pw;
			this.liveStub = new tswRufusleonardCom_Live.SingleSignOnSoap();	
			this.liveStub.SingleSignOnAuthenticationHeader = this.liveHeader;	
			System.debug('Set up production stub = ' + this.liveStub);	
		} // end check for production system if
		else {
			if (O2_linkage_configuration.getCurrentSystem() == Label.Sandbox_String) {
				this.sandboxHeader = new tswRufusleonardCom.SingleSignOnAuthenticationHeader();
				this.sandboxHeader.Username = un;
				this.sandboxHeader.Password = pw;
				this.sandboxStub = new tswRufusleonardCom.SingleSignOnSoap();	
				this.sandboxStub.SingleSignOnAuthenticationHeader = this.sandboxHeader;		
				System.debug('Set up sandbox stub = ' + this.sandboxStub);		
			} // end check for sandbox system if		
		} // end check for production system else
	} // end constructor
	
	// Get the security token
	public String GetSecurityToken(Integer idPartner,String tswUsername,String deepURL) {
		if (O2_linkage_configuration.getCurrentSystem() == Label.Production_String) {
			System.debug('Returning live token');
			if (O2_linkage_configuration.TESTING) {
				return 'abcd12345';
			}
			return liveStub.GetSecurityToken(idPartner, tswUsername, deepURL);
		} // end check production system if

		if (O2_linkage_configuration.getCurrentSystem() == Label.Sandbox_String) {
			System.debug('Returning sandbox token');
			if (O2_linkage_configuration.TESTING) {
				return 'abcd12345';
			}			
			return sandboxStub.GetSecurityToken(idPartner, tswUsername, deepURL);
		} // end check sandbox system if			
		
		// Should never reach here
		return null;
	} // end get security token
} // end class