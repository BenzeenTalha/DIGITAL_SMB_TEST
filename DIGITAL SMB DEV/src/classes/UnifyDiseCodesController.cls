/**
*   Class used for retrieving first available DISE code from group of available DISE codes based on used DISE codes.
*	Prevents usage of duplicate DISE codes under same SITE and Product Configuration
*   @since   25/10/2012
*   @author  mateusz.gutowski@cloudsensesolutions.com
*/
public class UnifyDiseCodesController {
  /**
   *   Name of Attributes for which re-duplication and availability should be checked
   */
 public static final List<String> AttributeNames = new List<String>{'DISE CODE'};
    /**
     *	ID, Site, Product Bundle and Product Definition of analyzed Product Configuration
     *	@param configId Id of analyzed Product Cofiguration
     *	@return cscfgc__Product_Configuration__c analyzed Product Cofiguration
     */
    public static List<cscfgc__Product_Configuration__c> getUConfig(Id configId ){
        return [SELECT Id, Unify_Site__c, cscfgc__Product_Bundle__c, cscfgc__Product_Definition__c,
                                                   (SELECT Id, Name, cscfgc__Value__c FROM cscfgc__Attributes__r WHERE Name = :AttributeNames )
                                                   FROM cscfgc__Product_Configuration__c
                                                   WHERE Id = :configId LIMIT 1];
    }
    /**
     *  Lists all Configurations under same Site, Product Bundle and Product Definition as analyzed Product Configuration
     *	@param configId Id of analyzed Product Cofiguration
     *	@return cscfgc__Product_Configuration__c List of all Configurations
     */
    public static List<cscfgc__Product_Configuration__c> getConfigs(Id configId){
        List<cscfgc__Product_Configuration__c> UCofig = getUConfig(configId);
        if(UCofig.size() > 0){
        return [SELECT Id, Name, (SELECT Id, Name, cscfgc__Value__c FROM cscfgc__Attributes__r WHERE Name IN :AttributeNames )
                      FROM cscfgc__Product_Configuration__c
                      WHERE Unify_Site__c= :UCofig[0].Unify_Site__c
                      AND cscfgc__Product_Definition__c= :UCofig[0].cscfgc__Product_Definition__c
                      AND cscfgc__Product_Bundle__c= :UCofig[0].cscfgc__Product_Bundle__c ];
        }
        return null;
    }
    /**
     *  Converts String of Available Dise Codes to List
     *	@param AvailableDiseCodesStr String of Available Dise Codes
     *	@return AvailableDiseCodes List of Available Dise Codes
     */
    public static List<String> getAvailableDiseCodes(String AvailableDiseCodesStr){
        List<String> AvailableDiseCodes = new List<String>();
        if (AvailableDiseCodesStr != null && AvailableDiseCodesStr != ''){
        	AvailableDiseCodesStr = AvailableDiseCodesStr.replaceAll('\n','');
            AvailableDiseCodes.addAll(AvailableDiseCodesStr.split(';',0));
        }AvailableDiseCodes.sort();

    return AvailableDiseCodes;
    }
    /**
     *  Gets already Used Dise Codes from list of all Configurations and removes Dise Code of analyzed Product Configuration from it
     *	@param configId Id of analyzed Product Cofiguration
     *	@return UsedDiseCodes List of Used Dise Codes
     */
    public static Set<String> getUsedDiseCodes(Id configId){
        Set<String> UsedDiseCodes = new Set<String>();
        List<cscfgc__Product_Configuration__c> configList = getConfigs(configId);
        List<cscfgc__Product_Configuration__c> UCofig = getUConfig(configId);
        String CurrentDiseCode = '';
        if(configList != null){
         CurrentDiseCode = UCofig[0].cscfgc__Attributes__r[0].cscfgc__Value__c;
            for(cscfgc__Product_Configuration__c myConfig : configList ){
                for(cscfgc__Attribute__c myAttr : myConfig.cscfgc__Attributes__r){
                    if(myAttr.Name == 'DISE CODE')
                    UsedDiseCodes.add(myAttr.cscfgc__Value__c);
                }
            }
         UsedDiseCodes.remove(CurrentDiseCode);
         }
     return UsedDiseCodes;
    }
    /**
     *  Returns FINAL result of correct DISE code for analyzed Product Configuration based on passed variables of Cinfiguration Id and Available Dise Codes
     *	@return getResultDiseCode String of Result Dise Code
     */
    public String getResultDiseCode (){

        Id configId = System.currentPageReference().getParameters().get('configId');
        String AvailableDiseCodesStr = System.currentPageReference().getParameters().get('AvailableDiseCodesStr');
        return getResultDiseCode (configId, AvailableDiseCodesStr );
    }
    /**
     *  Returns first Available Dise Code that is not Used Dise Code
     *	@return ResultDiseCode available Dise Code
     */
    public static String getResultDiseCode (Id configId, String AvailableDiseCodesStr){
        String ResultDiseCode = '';

        List<String> AvailableDiseCodes = getAvailableDiseCodes(AvailableDiseCodesStr);
        Set<String> UsedDiseCodes = getUsedDiseCodes(configId);
        for(String avail_code : AvailableDiseCodes){
        	if(UsedDiseCodes.contains(avail_code.replaceAll('\n','').trim())){
        		continue;
        	} else if(ResultDiseCode  == ''){
                ResultDiseCode =  avail_code.replaceAll('\n','').trim();
                break;
        	}
        }
        return ResultDiseCode;
    }
}