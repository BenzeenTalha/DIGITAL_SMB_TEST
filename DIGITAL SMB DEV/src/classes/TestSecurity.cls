public with sharing class TestSecurity {

    public TestSecurity(ApexPages.StandardController controller) {

    }
    
    public boolean getIsEditable() {
        return Schema.sObjectType.Contact.isUpdateAble();
    }

}