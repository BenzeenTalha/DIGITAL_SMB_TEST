public with sharing class O2Online4GMobilePhones {

    public List<O2_DISE_Ref_Hardware_Portfolio__c> Devices { get; set; }
    public List<Attachment> JSON_atts {get; set; }

    public O2Online4GMobilePhones(O2OnlineMainController controller) {
                GetData();
    }

    public void GetData()
    {
      Devices = [Select Id, Name from O2_DISE_Ref_Hardware_Portfolio__c where Category_Device_Detail__c = true order by Name limit 6];
      JSON_atts = new List<Attachment>();
      List<Attachment> tmpAtt;
      for(O2_DISE_Ref_Hardware_Portfolio__c dev : devices)
      {
      tmpAtt = [select Id, IsDeleted, Name, ParentId, ContentType, Body From Attachment where ParentId = :dev.Id order by LastModifiedDate desc limit 1];
      JSON_atts.addAll(tmpAtt);
      }
    }

    public string getJsonArray

    {
        get{
                string retArray = '';
                for(Attachment att : JSON_atts)
                {
                        if(retArray != '')
                                retArray += ',';
                        retArray += att.body.toString();

                }
                return retArray;
        }
    }


}