public with sharing class FieldHelperComponentController {

    public String attribName {get;set;}
    public String helpText;
    public void setHelpText(String s) {helpText = s;}
    
    public FieldHelperComponentController() {}
    
    public String getHelpText() {
        //get the Custom Setting for attribute help text(s)
        if (OnlineConfiguratorSettings__c.getInstance() != null) {
            List<OnlineConfiguratorSettings__c> settingFields = OnlineConfiguratorSettings__c.getAll().values();
            System.debug('### OUTPUT >>>>> getHelpText: settingFields: '+settingFields);
            for (OnlineConfiguratorSettings__c fld: settingFields) {
                if (fld.Attribute_Name__c.equals(attribName)) {
                    helpText = fld.Help_Text__c;
                }
            }
         }
         System.debug('### OUTPUT >>>>> getHelpText: helpText: '+helpText);
        return helpText; 
    }
    
    static testmethod void testAll() {
        FieldHelperComponentController controller = new FieldHelperComponentController();
        controller.attribName = '';
        controller.getHelpText();
    }
}