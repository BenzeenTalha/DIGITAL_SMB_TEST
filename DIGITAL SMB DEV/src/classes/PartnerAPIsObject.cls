public class PartnerAPIsObject {
	public PartnerAPIsObject(){

	}
    public virtual class sObject_x {
        public String type_x;
        public String[] fieldsToNull;
        public String Id;
        private String[] type_x_type_info = new String[]{'type','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] fieldsToNull_type_info = new String[]{'fieldsToNull','http://www.w3.org/2001/XMLSchema','string','0','-1','true'};
        private String[] Id_type_info = new String[]{'Id','urn:partner.soap.sforce.com','ID','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:sobject.partner.soap.sforce.com','true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fieldsToNull','Id','AccountId'};
    }
    public class orchestrationProcessSobject extends sObject_x{
        public String type_x;
        public String[] fieldsToNull;
        public String id;
        public String orderId;
        public String siteId;
        public String name;
        public String processType;
        public String accountId;
        public String ownerId;
        private String[] type_x_type_info = new String[]{'type','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] fieldsToNull_type_info = new String[]{'fieldsToNull','http://www.w3.org/2001/XMLSchema','string','0','-1','true'};
        private String[] id_type_info = new String[]{'Id','urn:partner.soap.sforce.com','ID','1','1','true'};
		private String[] orderId_type_info = new String[]{'Order__c','urn:partner.soap.sforce.com','ID','1','1','true'};
		private String[] siteId_type_info = new String[]{'Site__c','urn:partner.soap.sforce.com','ID','1','1','true'};
		private String[] processType_type_info = new String[]{'CSPOFA__Process_Type__c','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
		private String[] name_type_info = new String[]{'Name','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
		private String[] accountId_type_info = new String[]{'CSPOFA__Account__c','urn:partner.soap.sforce.com','ID','1','1','true'};
		private String[] ownerId_type_info = new String[]{'OwnerId','urn:partner.soap.sforce.com','ID','1','1','true'};
		private String[] apex_schema_type_info = new String[]{'urn:sobject.partner.soap.sforce.com','true','false'};
		private String[] field_order_type_info = new String[]{'type_x','fieldsToNull','id','orderId','siteId','name', 'processType','accountId'};
    }
}