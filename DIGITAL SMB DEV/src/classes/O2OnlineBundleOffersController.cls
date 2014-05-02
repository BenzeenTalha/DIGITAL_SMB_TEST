public with sharing class O2OnlineBundleOffersController {
		
	public List<O2_DISE_Ref_Hardware_Portfolio__c> Bundles { 
		get; 
		set; 
	}
    
    public List<Attachment> Attachments { 
    	get; 
    	set; 
    }

    public O2OnlineBundleOffersController(O2OnlineMainController controller) {
    	getData();
    }

    public void getData()
    {
    	String product_code = ApexPages.currentPage().getParameters().get('pc');
    	this.Bundles = [Select Id, Name from O2_DISE_Ref_Hardware_Portfolio__c where O2_DISE_Ref_Hardware_Portfolio__c.Product_Code__c = :product_code limit 1];
      	this.Attachments = new List<Attachment>();
      	
      	List<Attachment> tmpAtt;
      	for(O2_DISE_Ref_Hardware_Portfolio__c bundle : Bundles)
      	{
      		tmpAtt = [select Id, IsDeleted, Name, ParentId, ContentType, Body From Attachment where ParentId = :bundle.Id order by LastModifiedDate desc limit 1];
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