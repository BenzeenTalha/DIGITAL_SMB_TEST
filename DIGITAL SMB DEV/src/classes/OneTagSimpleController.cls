public with sharing class OneTagSimpleController {

	public string OTProtocol {
		get{
	 		return OnlineGeneralSettings__c.getInstance('OneTagProtocol').Value__c;
	 	}
	 	private set;
	}

	public string OTDomain {
		get{
	 		return OnlineGeneralSettings__c.getInstance('OneTagDomain').Value__c;
	 	}
	 	private set;
	}

	public string OTPath {
		get{
	 		return OnlineGeneralSettings__c.getInstance('OneTagPath').Value__c;
	 	}
	 	private set;
	}

	public boolean OneTagEnabled{
    	get{
    		return OnlineGeneralSettings__c.getInstance('OneTagEnabled').Value__c == 'Y';
    	}
    	private set;
    }

}