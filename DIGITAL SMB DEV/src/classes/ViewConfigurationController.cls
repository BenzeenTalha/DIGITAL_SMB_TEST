public with sharing class ViewConfigurationController {

    public final Order__c parentOrder;
    public Id orderId;
    public Id configurationId {get; set;}
    public Map<String, cscfgc__Attribute__c> attrMap;
    public cscfgc__Product_Configuration__c config {get; set;}
    public String relatedProductName {get; set;}

    public String attributeName {get; set;}
    public String attributeValue;   //{ get {return attrMap.get(attributeName);} set; }
    private ApexPages.StandardController stdController;
    public ViewConfigurationController getController() {return this;}

    //BB start: Show Holiday exception related products
    public set<Id> holidayProdConfigIds  {get; set;}
    public list<cscfgc__Product_Configuration__c> holidayProdConfigs  {get; set;}
    public list<productConfigIndexWrapper> customHolidayProdConfigsList  {get; set;}
    public map<string,cscfgc__Attribute__c> holidayExceptionMap {get; set;}
    //BB end: Show Holiday exception related products
    //CK start: Show Bolt On related products
    public set<Id> boltOnProdConfigIds  {get; set;}
    public list<cscfgc__Product_Configuration__c> boltOnProdConfigs  {get; set;}
    public list<productConfigIndexWrapper> customBoltOnProdConfigsList  {get; set;}
    public map<string,cscfgc__Attribute__c> boltOnMap {get; set;}
    //CK end: Show Bolt On related products
    //CK start: Show Accessories related products
    public set<Id> accessoriesProdConfigIds  {get; set;}
    public list<cscfgc__Product_Configuration__c> accessoriesProdConfigs  {get; set;}
    public list<productConfigIndexWrapper> customAccessoriesProdConfigsList  {get; set;}
    public map<string,cscfgc__Attribute__c> accessoriesMap {get; set;}
    //CK end: Show Accessories related products
    public String userProfile {
        get { if(userProfile==null) userProfile='FIS'; return userProfile; }
        set;
    }

    public boolean isPClicence {get; private set;}	// determine if user has PC licencs

    public List<SLA__c> slas {get; set;}

   	public final Integer custSettLen = 36;    // custom settings should allow 80 chars for name, but throw error after certain length (?)

    public String getAttributeValue() {
        cscfgc__Attribute__c attr;

        if (attrMap.containsKey(attributeName)) attr = attrMap.get(attributeName);
        String rtnVal = null;

                // If attr displayValue is not null use the display value else use the value
                if (attr != null)
                        if (attr.cscfgc__Display_Value__c != null) rtnVal = attr.cscfgc__Display_Value__c;
                        else rtnVal = attr.cscfgc__Value__c;

        return rtnVal;
    }

    // Default constructor
    public ViewConfigurationController(ApexPages.StandardController stdController) {
                System.debug('@@@ Standard controller');
        //this.parentController = controller;
        this.parentOrder = (Order__c)stdController.getRecord();

        //PC licence
        isPClicence = UserInfo.isCurrentUserLicensed('cscfgc');
        isPClicence = cscfgc__Product_Configuration__c.SObjectType.getDescribe().isAccessible() && UserInfo.isCurrentUserLicensed('cscfgc');

        // Get the Configuration Id and Screen Flow from the URL
        //Map<String, String> params = ApexPages.currentPage().getParameters();
        //orderId = params.get('id');
        orderId = parentOrder.id;

        // initialise lists - they are used in vf page to determine rendering
        customBoltOnProdConfigsList = new list<productConfigIndexWrapper>();
        customAccessoriesProdConfigsList = new list<productConfigIndexWrapper>();

        if (attrMap == null && isPClicence) {
                attrMap = new Map<String, cscfgc__Attribute__c>();
                //BB start: Show Holiday exception related products
                holidayExceptionMap = new map<string,cscfgc__Attribute__c>();
                holidayProdConfigIds = new set<Id>();
                //BB end: Show Holiday exception related products
                //CK start: Show Bolt On related products
                boltOnMap = new map<string,cscfgc__Attribute__c>();
                boltOnProdConfigIds = new set<Id>();
                //CK end: Show Bolt On related products
                //CK start: Show Accessories related products
                accessoriesMap = new map<string,cscfgc__Attribute__c>();
                accessoriesProdConfigIds = new set<Id>();
                //CK end: Show Accessories related products
                loadConfiguration();
        }
        User currentuser=[select id, u.Username, u.Profile.Name, u.Profile.Id, UserType from User u where Id=: UserInfo.getUserId()];
        System.debug('Current user: '+currentuser);
        System.debug('Profile Name is : '+currentuser.profile.Name);

        // Get set of ALU profile names
        List<renderOrderImsiPanel__c> aluProfs=renderOrderImsiPanel__c.getAll().values();
        Set<String> allowedALUProfiles = new Set<String>();
        for(renderOrderImsiPanel__c setting : aluProfs) {
            allowedALUProfiles.add(setting.Name);
        }
        if(allowedALUProfiles.contains(currentuser.Profile.Name)) { // 'JJ Partner Profile - ALU' || currentuser.Profile.Name=='System Administrator') {
            getRadioProvParms();
        }
        userProfile=currentuser.Profile.Name;

        //Read all SLA's
        string slaQuery = 'SELECT ' + Utility.getSobjectFields('SLA__c') + ' FROM SLA__c WHERE Order__c = :orderId AND Tracking_Type__c IN (\'Actual\',\'Target\') ORDER BY Milestone_Order__c';
        slas = Database.query(slaQuery);
    }

    public PageReference loadConfiguration() {

        if (orderId != null) {
            // Also get the Product Configuration details
            Order__c oData = [SELECT
            					Name, Product_Configuration__c
            				  FROM
            				  	Order__c
            				  WHERE
            				  	Id = :orderId][0];
            List<cscfgc__Product_Configuration__c> cfgList = [SELECT
            													Id, Name, cscfgc__Product_Definition__r.Name, cscfgc__Product_Definition__r.cscfgc__Product_Category__r.Name,
            													Unify_Hardware_Bundle__c
            												  FROM
            												  	cscfgc__Product_Configuration__c
            												  WHERE
            												  	Id = :oData.Product_Configuration__c];
            if (cfgList.size() > 0) {
                    config = cfgList[0];
                    configurationId = config.Id;
            }
            else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No attributes exist for this product configuration, the data may have been deleted'));
            }
        }
		//KF 19/AUG
        if (configurationId != null && attrMap!= null && attrMap.isEmpty()) {
            // Populate the map by attribute name
            for (cscfgc__Attribute__c attr : [SELECT Id, Name, cscfgc__Display_Value__c, cscfgc__Value__c
                                                                       FROM cscfgc__Attribute__c
                                                                       WHERE cscfgc__Product_Configuration__c = :configurationId])
            {
                    attrMap.put(attr.Name, attr);
                    System.debug('@@@ attr '+attr.Name+' display value is '+attr.cscfgc__Display_Value__c+' value is '+ attr.cscfgc__Value__c);
            }

            System.debug('@@@RAC attrmap size is '+attrMap.size());

            // Retrieve the related product attributes
            for (cscfgc__Attribute__c relAttr : [SELECT Id, cscfgc__Product_Configuration__c, cscfgc__Product_Configuration__r.Name, Name, cscfgc__Display_Value__c, cscfgc__Value__c
                                                                       FROM cscfgc__Attribute__c
                                                                       WHERE cscfgc__Product_Configuration__r.cscfgc__Parent_Configuration__c = :configurationId])
            {
                    attrMap.put(relAttr.cscfgc__Product_Configuration__r.Name + '|'+relAttr.Name, relAttr);
                    System.debug('@@@ relattr key '+relAttr.cscfgc__Product_Configuration__r.Name + '|' + relAttr.Name+'  '+relAttr.cscfgc__Display_Value__c+' value is '+ relAttr.cscfgc__Value__c);
                    //BB start: Show Holiday exception related products
                    system.debug('+++ relAttr.cscfgc__Product_Configuration__r.Name: ' + relAttr.cscfgc__Product_Configuration__r.Name);
                    if(relAttr.cscfgc__Product_Configuration__r.Name == 'Holiday Exceptions 1')
                    {
                        holidayProdConfigIds.add(relAttr.cscfgc__Product_Configuration__c);
                    }
                    //BB end: Show Holiday exception related products
            }

            //BB start: Show Holiday exception related products
            holidayProdConfigs = [Select cscfgc__Parent_Configuration__c, Name, Id,
                                (Select Name, cscfgc__Product_Configuration__c, cscfgc__Display_Value__c, cscfgc__Value__c From cscfgc__Attributes__r)
                                From cscfgc__Product_Configuration__c
                                where Id IN : holidayProdConfigIds];

            customHolidayProdConfigsList = new list<productConfigIndexWrapper>();
            integer counter = 0;
            for(cscfgc__Product_Configuration__c pc : holidayProdConfigs)
            {
                counter ++;
                customHolidayProdConfigsList.add(new productConfigIndexWrapper(pc,counter));

                for(cscfgc__Attribute__c relAttr : pc.cscfgc__Attributes__r)
                {
                    holidayExceptionMap.put(relAttr.cscfgc__Product_Configuration__c + '|'+relAttr.Name, relAttr);
                }
                system.debug('+++ pc.cscfgc__Attributes__r.size(): ' + pc.cscfgc__Attributes__r.size());
            }

            system.debug('+++ holidayExceptionMap.size(): ' + holidayExceptionMap.size());
            system.debug('+++ holidayProdConfigs.size(): ' + holidayProdConfigs.size());
            system.debug('+++ holidayExceptionMap: ' + holidayExceptionMap);
            system.debug('+++ holidayProdConfigs: ' + holidayProdConfigs);
            //BB end: Show Holiday exception related products

            //CK start: Show Bolt On related products
            String boltOnIds = null;
            cscfgc__Attribute__c attr = attrMap.get('Bolt On');
            if (attr == null)
            {
                attr = attrMap.get('Mobile Broadband Bolt On');
            }
            if (attr != null)
            {
                boltOnIds = attr.cscfgc__Value__c;
                if (boltOnIds!=null && boltOnIds!='')
                   for (string relId : boltOnIds.split(','))
                   {
                       boltOnProdConfigIds.add(relId);
                   }
            }
            boltOnProdConfigs = [Select cscfgc__Parent_Configuration__c, Name, Id,
                                (Select Name, cscfgc__Product_Configuration__c, cscfgc__Display_Value__c, cscfgc__Value__c From cscfgc__Attributes__r)
                                From cscfgc__Product_Configuration__c
                                where Id IN : boltOnProdConfigIds];

            customBoltOnProdConfigsList = new list<productConfigIndexWrapper>();
            counter = 0;
            for(cscfgc__Product_Configuration__c pc : boltOnProdConfigs)
            {
                counter ++;
                customBoltOnProdConfigsList.add(new productConfigIndexWrapper(pc,counter));

                for(cscfgc__Attribute__c relAttr : pc.cscfgc__Attributes__r)
                {
                    boltOnMap.put(relAttr.cscfgc__Product_Configuration__c + '|'+relAttr.Name, relAttr);
                }
                system.debug('+++ pc.cscfgc__Attributes__r.size(): ' + pc.cscfgc__Attributes__r.size());
            }

            system.debug('+++ boltOnMap.size(): ' + boltOnMap.size());
            system.debug('+++ boltOnProdConfigs.size(): ' + boltOnProdConfigs.size());
            system.debug('+++ boltOnMap: ' + boltOnMap);
            system.debug('+++ boltOnProdConfigs: ' + boltOnProdConfigs);
            //CK end: Show Bolt On related products

            //CK start: Show Accessories related products
            cscfgc__Attribute__c accessoriesAttr = attrMap.get('Accessories');
            String accessoriesIds = null;
            if (accessoriesAttr != null)
            {
                accessoriesIds = accessoriesAttr.cscfgc__Value__c;
                if (accessoriesIds!=null && accessoriesIds!='')
                   for (string relId : accessoriesIds.split(','))
                   {
                       accessoriesProdConfigIds.add(relId);
                   }
            }
            accessoriesProdConfigs = [Select cscfgc__Parent_Configuration__c, Name, Id,
                                (Select Name, cscfgc__Product_Configuration__c, cscfgc__Display_Value__c, cscfgc__Value__c From cscfgc__Attributes__r)
                                From cscfgc__Product_Configuration__c
                                where Id IN : accessoriesProdConfigIds];

            customAccessoriesProdConfigsList = new list<productConfigIndexWrapper>();
            counter = 0;
            for(cscfgc__Product_Configuration__c pc : accessoriesProdConfigs)
            {
                counter ++;
                customAccessoriesProdConfigsList.add(new productConfigIndexWrapper(pc,counter));

                for(cscfgc__Attribute__c relAttr : pc.cscfgc__Attributes__r)
                {
                    accessoriesMap.put(relAttr.cscfgc__Product_Configuration__c + '|'+relAttr.Name, relAttr);
                }
                system.debug('+++ pc.cscfgc__Attributes__r.size(): ' + pc.cscfgc__Attributes__r.size());
            }

            system.debug('+++ accessoriesMap.size(): ' + accessoriesMap.size());
            system.debug('+++ accessoriesProdConfigs.size(): ' + accessoriesProdConfigs.size());
            system.debug('+++ accessoriesMap: ' + accessoriesMap);
            system.debug('+++ accessoriesProdConfigs: ' + accessoriesProdConfigs);
            //CK end: Show Accessories related products
        }

        return null;
    }
        //BB start: Show Holiday exception related products
        public class productConfigIndexWrapper
        {
            public cscfgc__Product_Configuration__c pc {get;set;}
            public integer listIndex {get;set;}

            public productConfigIndexWrapper(cscfgc__Product_Configuration__c tmpPc, integer tmpListIndex)
            {
                pc = tmpPc;
                listIndex = tmpListIndex;
            }
        }
        //BB end: Show Holiday exception related products
        public PageReference navBack() {

                return new PageReference('/'+orderId);
        }

/* Moved to test class TestViewConfigurationController
        public static testmethod void testController() {
                Order__c ord = new Order__c();
                cscfgc__Product_Configuration__c pc = new cscfgc__Product_Configuration__c();
                cscfgc__Product_Definition__c pd = [SELECT Id, (Select Id From cscfgc__Attribute_Definitions__r WHERE name = 'Postcode' LIMIT 1) from cscfgc__Product_Definition__c WHERE Name like '%Landline%' LIMIT 1];
                Account a = [SELECT Id from Account LIMIT 1];
                insert pc;
                cscfgc__Attribute__c attr = new cscfgc__Attribute__c();
                attr.cscfgc__Product_Configuration__c = pc.Id;
                insert attr;

                ord.Product_Configuration__c = pc.Id;
                ord.Account__c = a.Id;
                insert ord;

                ApexPages.StandardController stc = new ApexPages.StandardController(ord);
                ViewConfigurationController testcontroller = new ViewConfigurationController(stc);

                Test.setCurrentPage(Page.ProvisioningViewConfiguration);
                testcontroller.orderId = ord.Id;
                testcontroller.loadConfiguration();

                //testcontroller.getController();
                testcontroller.attributeName = 'Postcode';
                String result = testcontroller.getAttributeValue();
                testcontroller.navBack();
        }
*/

    // BOOSTBOX
    public String lac {get; set;}
    public String sac {get; set;}
    public String rac {get; set;}
    public String lat {get; set;}
    public String longi {get; set;}
    public String zc {get; set;}

    public String imsiListStr {get; set;}
    public List<String> imsiList {
        get;// {if (imsiList == null) return new List<String>(); else return imsiList;}
        set;
    }
    public boolean showIMSI {
        get { if(showIMSI==null)  showIMSI=false; return showIMSI; }
        set;
    }

    public Integer totalAccessListSize {get; set;}
    public Integer moreIMSI {get; set;}
    public Integer totalFetched {get; set;}

    public Set<String> anSet = new Set<String>();
    public Set<String> anProcessedSet = new Set<String>();
    public boolean testSOAFault=false;

    public PageReference processAccessList() {
        cscfgc__Attribute__c attr = new cscfgc__Attribute__c();

        try {
            if (attrMap.containsKey('Access List')) attr = attrMap.get('Access List');
            String accessListRaw = attr.cscfgc__Value__c;

            system.debug('***accessListRaw:'+ accessListRaw);

            anSet.clear();
            anProcessedSet.clear();
            totalFetched=0;
            imsiList = new List<String>();

            if (accessListRaw != null && accessListRaw != '') {
                if (accessListRaw.contains(',')) {

                    for (String anRaw: accessListRaw.split(',')) {
                        system.debug('***anRaw(loop):'+ anRaw);
                        BoostBoxWizController.AccessNumber an=new BoostBoxWizController.AccessNumber(anRaw, true);
                        String anClean=an.clean;
                        anSet.add(anClean);
                    }
                } else {
                    BoostBoxWizController.AccessNumber an=new BoostBoxWizController.AccessNumber(accessListRaw, true);
                    String anClean=an.clean;
                    anSet.add(anClean);
                }
                system.debug('***anSet:'+ anSet);

                totalAccessListSize=anSet.size();

                fetchIMSIs();
                system.debug('***imsiList:'+ imsiList);
            }
        }
        catch (Exception e) {
            System.debug('***Exception: '+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }

        return null;
    }

    public PageReference fetchIMSIMore() {
        try {
            fetchIMSIs();
        }
        catch (Exception e) {
            System.debug('***Exception: '+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
        return null;
    }

    public void fetchIMSIs() {

        if(imsiList==null || anSet==null) return;
        String imsi='';
        String imei='';
        String brand='';
        String model='';
        String displayBrand='';
        String displayModel='';
        Integer soaCallCount=0;

        FemtocellSOAHandler handler =  new FemtocellSOAHandler();
        if(testSOAFault) handler.testFault=true;

        for(String msisdn :anSet) {
            system.debug('***msisdn:'+ msisdn);
            if(anProcessedSet.contains(msisdn)) continue;

            soaCallCount++;
            if(soaCallCount>Limits.getLimitCallouts()) break;
            //if(soaCallCount>1) break;

            anProcessedSet.add(msisdn);
            try {
                FemtocellSOAHandler.DeviceProfile prof = handler.getDeviceProfile(msisdn, imsi, imei, brand, model, displayBrand, displayModel, null);
                System.debug('***device profile: '+prof.getText());
                //Add to display list
                imsiList.add(prof.imsi);
            }
            catch (FemtocellSOAHandler.ResponseException e) {
                System.debug('***FAILED MSISDN: '+msisdn+' : '+e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MSISDN: '+ msisdn +' : '+e.getMessage()));
            }
        }
        imsiListStr='';
        for(Integer i=0; i<imsiList.size(); i++) {
            if(i==imsiList.size()-1) {
                imsiListStr+=imsiList[i];
            } else {
                imsiListStr+=imsiList[i]+', ';
            }
        }
        system.debug('***anProcessedSet:'+ anProcessedSet);
        system.debug('***totalAccessListSize:'+totalAccessListSize+' imsiList.size:'+imsiList.size());

        moreIMSI=totalAccessListSize-anProcessedSet.size();
        totalFetched=imsiList.size();
        if(imsiList.size()>0) showIMSI=true;
        else showIMSI=false;

        system.debug('***showIMSI:'+showIMSI+' moreIMSI:'+moreIMSI);
    }

    public void getRadioProvParms() {
        if (parentOrder.CSR_No__c != null && parentOrder.CSR_No__c.trim().length() > 0) {
            try {
                FemtocellSOAHandler.RadioProvisioningParmameters provParms=getOrderRadioProvParms(parentOrder.CSR_No__c);
                lac = provParms.locationAreaCode;
                sac = provParms.serviceAreaCode;
                rac = provParms.regionAreaCode;
                lat = provParms.easting;
                longi = provParms.northing;
                //zc = provParms.femtoRegion;
            } catch (Exception e) {
                if(e.getMessage().contains('Internal Error')) {
                    BoostboxHelper.addMsg('Unable to get Radio Parameters for this CSR!', false);
                } else if(e.getMessage().contains('No records found')) {
                    BoostboxHelper.addMsg('No Radio Parameters for this CSR!', false);
                } else {
                    BoostboxHelper.addMsg('An unexpected error occurred. Please try again later or contact service support. (' + e + ')', true);
                }
            }
        }
    }

    public FemtocellSOAHandler.RadioProvisioningParmameters getOrderRadioProvParms(String csr) {

        String cellSiteReferenceNumber=(csr!=null ? csr : '');
        String orderReferenceNumber='';
        String buildingDetails='';
        String postCode='';

        FemtocellSOAHandler handler =  new FemtocellSOAHandler();
        if(testSOAFault) handler.testFault=true;
        system.debug('***getOrderRadioProvParms CSR: '+cellSiteReferenceNumber);
        FemtocellSOAHandler.RadioProvisioningParmameters parms = handler.getRadioProvisioningParameters_1(cellSiteReferenceNumber,orderReferenceNumber, buildingDetails, postCode, null, null);

        System.debug('***radio prov parms: '+handler.radioProvisioningParmameters.getText());
        return parms;//handler.radioProvisioningParmameters;

    }
    // GK 3/7/2012 replace rendering restriction by hard coding profile name, to using a custom setting
    // HideOrderPageRelatedLists__c: The custom setting specifies profiles for which the related lists on the order page should be hidden
    // renderOrderImsiPanel__c: The custom setting specifies profiles for which the imsiPanel should be rendered
    public Boolean RenderOrderPageRelatedLists {
        get {
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        if (HideOrderPageRelatedLists__c.getInstance(usrProfileName.length() > custSettLen ? usrProfileName.substring(0,custSettLen) : usrProfileName) != null ) {return false;}
        else
            return true;
        }
    }
    public Boolean RenderImsiPanel {
        get {
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        if (renderOrderImsiPanel__c.getInstance(usrProfileName.length() > custSettLen ? usrProfileName.substring(0,custSettLen) : usrProfileName) != null ) {return true;}
        else
            return false;
        }// End GK 3/7/2012
    }

    public String getBoostboxInstallationType() {
        String instType = null;
        String needsAccessList='';
        cscfgc__Attribute__c attr = attrMap.get('Needs Access List');
        if (attr != null)
        {
            needsAccessList = attr.cscfgc__Value__c;
        }
        if(needsAccessList.toUpperCase()=='TRUE')
            instType='Closed';
        else
            instType='Open';
        return instType;
    }

    public boolean IsUserOrchLicensed{
        get{
            return UserInfo.isCurrentUserLicensed('CSPOFA') && CSPOFA__Orchestration_Process__c.SObjectType.getDescribe().isAccessible();
        }
    }
}