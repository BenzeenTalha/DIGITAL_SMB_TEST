public with sharing class O2OnlineLeaseMobilePhones {
	
	public List<O2_DISE_Ref_Hardware_Portfolio__c> Devices { 
		get; 
		set; 
	}
    
    public List<Attachment> Attachments { 
    	get; 
    	set; 
    }

    public O2OnlineLeaseMobilePhones(O2OnlineMainController controller) {
    	getData();
    }

    public void getData()
    {
    	this.Devices = [Select Id, Name from O2_DISE_Ref_Hardware_Portfolio__c where Name = 'PHONE_LEASING_CONTAINER' limit 1];
      	this.Attachments = new List<Attachment>();
      	
      	List<Attachment> tmpAtt;
      	for(O2_DISE_Ref_Hardware_Portfolio__c dev : devices)
      	{
      		tmpAtt = [select Id, IsDeleted, Name, ParentId, ContentType, Body From Attachment where ParentId = :dev.Id order by LastModifiedDate desc limit 1];
      		this.Attachments.addAll(tmpAtt);
      	}
    }

    public string getJsonArray
    {
        get {
        	string retArray = '';
            for(Attachment att : Attachments) {
            	if(retArray != '')
                	retArray += ',';
                    retArray += att.body.toString();

           	}
            
            return retArray;
        }
    }
}