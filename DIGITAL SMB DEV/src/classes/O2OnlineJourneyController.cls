public class O2OnlineJourneyController {

	public String journeyName {get;set;}
	public Boolean showTitle {get {if (showTitle==null) return false; else return showTitle;} set;}
	public String index {get;set;}
	
	public Map<String, O2OnlineJourneySettings__c> journeyMapping {
		get {if(journeyMapping==null) return O2OnlineJourneySettings__c.getAll(); else return journeyMapping;}
		set;
	}
	public List<O2OnlineJourneySettings__c> journeyMapValues {
		get {if (journeyMapValues==null) return O2OnlineJourneySettings__c.getAll().values(); else return journeyMapValues;}
		set;
	}
	
	public List<O2OnlineJourneySettings__c> getjourneySteps() {
		List<O2OnlineJourneySettings__c> retList = new List<O2OnlineJourneySettings__c>();
        Map<String, O2OnlineJourneySettings__c> mpCodes = new Map<String, O2OnlineJourneySettings__c>();
		if (journeyName!=null && journeyName!='') {
			for (O2OnlineJourneySettings__c js: journeyMapValues) {
                if (js.Active__c && js.Type__c==journeyName) {mpCodes.put(js.Sequence__c+js.Name, js);}
			}
	        List<String> sortList = new List<String>(mpCodes.keySet());
	        sortList.sort();
	        for (String s: sortList) {retList.add(mpCodes.get(s));}
		}
		return retList;
	}
}