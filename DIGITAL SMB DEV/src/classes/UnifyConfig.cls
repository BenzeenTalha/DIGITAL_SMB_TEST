/**
*   Class to maintain all Unify 'fixed' configurations
*   @since  26/09/2013
*   @author  emil.puchalski@cloudsensesolutions.com
*   @ivicav	20/11/2013 add MSEC Spain
*/
global class UnifyConfig {

    global UnifyConfig(){

    }

    /**
    *          Common Unify suppliers list
    *     used ie. in ExportSiteSelectionController
    */
    public static Set<String> setSuppliers;
	global static Set<String> setSuppliers(){
		if(setSuppliers == null){
			setSuppliers = new Set<String>();
			Map<String, UnifyConfiguration__c> mCS = UnifyConfiguration__c.getAll();
			if(mCS.size() > 0){
				for(UnifyConfiguration__c c : mCS.values()){
                	if(c.Description__c != null && c.Description__c.toUpperCase() == 'SUPPLIER'){
             			setSuppliers.add(c.Value__c);
                	}
				}
			}
		}
		return setSuppliers;
	}

	/**
	* Map Pillar Name <-> Product Definintion Name
	* @since	21/11/2013
	* @author	Ivan Tadic / CloudSense Ltd
	*/
	private static Map<String, String> mPillars2Name;
    global static Map<String, String> mPillars2Name(){
    	if(mPillars2Name == null){
    		mPillars2Name = new Map<String, String>();
    		Map<String, UnifyConfiguration__c> mCS = UnifyConfiguration__c.getAll();
			for(UnifyConfiguration__c c : mCS.values()){
                if(c.Description__c != null && c.Description__c.toUpperCase() == 'PILLARNAME'){
                    string pillarName = c.Name.replace('PillarName - ', '').trim();
                    mPillars2Name.put(pillarName, c.Value__c);
                }
			}
    	}
    	return mPillars2Name;
    }

	/**
	* Map Solution Name <-> Set Of Supported Pillars - Which pillars can be selected for solution
	* @since	21/11/2013
	* @author	Ivan Tadic / CloudSense Ltd
	*/
	private static Map<string, Set<string>> solution2Pillars;
	global static Map<string, Set<string>> solution2Pillars(){
		if(solution2Pillars == null){
			solution2Pillars = new Map<string, Set<string>>();
			Map<String, UnifyConfiguration__c> mCS = UnifyConfiguration__c.getAll();
			for(UnifyConfiguration__c c : mCS.values()){
                if(c.Description__c != null && c.Description__c.toUpperCase() == 'SOLUTIONPILLARS'){
                    string solutionName = c.Name.replace('SolutionPillars - ', '').trim();
                    string[] pillars = c.Value__c.split(',', 0);
                    set<string> pillarsSet = new set<string>();
                    for(string p : pillars){
                    	pillarsSet.add(p);
                    }
                    solution2Pillars.put(solutionName, pillarsSet);
                }
            }
		}
		return solution2Pillars;
    }


	/**
	* Map COFAD Solution Name <-> SalesForce Solution Name: For different possible values of solutions in COFAD
	* @since	30/09/2013
	* @author	Ivan Tadic / CloudSense Ltd
	*/
    private static Map<String,String> mSolutions2Name;
    global static Map<String,String> mSolutions2Name(){
        if(mSolutions2Name == null){
            mSolutions2Name = new Map<String,String>();
            Map<String, UnifyConfiguration__c> mCS = UnifyConfiguration__c.getAll();
            for(UnifyConfiguration__c c1 : mCS.values()){
                if(c1.Description__c != null && c1.Description__c.toUpperCase() == 'MQF SOLUTION'){
                    mSolutions2Name.put(c1.Name,c1.Value__c);
                }
            }
        }
        return mSolutions2Name;
    }

	/**
	* Map Attribute Name <-> SalesForce Field Name used to copy values from attributes to product configuration fields
	* @since	30/09/2013
	* @author	Ivan Tadic / CloudSense Ltd
	*/
	private static Map<String, UnifyConfiguration__c> mAttName2FieldName;
	global static Map<String, UnifyConfiguration__c>  mAttName2FieldName(){
		if(mAttName2FieldName == null){
			System.debug('***** Reading Unify Config');
			mAttName2FieldName = new Map<String, UnifyConfiguration__c>();
			Map<String, UnifyConfiguration__c> unifyConfigs = UnifyConfiguration__c.getAll();
			for(UnifyConfiguration__c config : unifyConfigs.values()){
                if(config.Description__c != null && config.Description__c.toUpperCase() == 'ATTRIBUTEFIELDMAP'){
                    mAttName2FieldName.put(config.Name, config);
                }
            }
		}
		return mAttName2FieldName;
	}

    /**
    * Value used within RAID managment. The name of field in which sum of RAID risk should be stored on parent object.
    */

    public static final String RAID_RISK_SUM_FIELD_NAME = 'Risk_Sum__c';

    public static final String CENTRAL_SITE_KEY_NAME = 'Central Account Services';

    public static final Integer SITES_COL_NO = 15;
}