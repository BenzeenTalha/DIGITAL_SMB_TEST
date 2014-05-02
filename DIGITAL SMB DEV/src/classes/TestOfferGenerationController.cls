/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

// This class tests the 'CREATE' functions, see TestOfferGenerationController2 for the 'DELETE' functions.
// More efficient to move the delete testing out of this class as the static code is run before EACH test. We don't need it to run to test DELETE.

@isTest(seeAllData=true)
private class TestOfferGenerationController
{
	private static O2_DISE_Map_Mobile__c mapMobile;
	private static O2_DISE_Map_Mobile__c SIMmapMobile;
	private static O2_DISE_Map_Handset__c mapHandset;
	private static O2_DISE_Map_Handset_Selection__c handsetSelection;
	private static O2_DISE_Ref_Hardware_Relation__c refHwRel;
	private static O2_DISE_Map_Mobile_Bolton__c mapMobileBolton;
	private static OfferGenerationController con;

    static
    {
    	//
        // Just going to create one of each and link them together where needed
        //
        create_SIM_O2_DISE_Map_Mobile('10');
        create_O2_DISE_Map_Mobile('10');
        System.debug('mapMobile name'+mapMobile.Name +  ' obj:'+mapMobile);
        create_O2_DISE_Map_Handset('10', mapMobile.Name, mapMobile.Handset_Tariff_Class__c);
        System.debug('mapHandset id'+mapHandset.Id + ' obj:'+mapHandset);
        create_O2_DISE_Map_Handset_Selection(mapHandset.Product_Code__c);
        create_O2_DISE_Ref_Hardware_Relation();
        create_O2_DISE_Map_Mobile_Bolton();
        getController();
        system.debug('****  orders created. mapmobile.id = ' + mapMobile.Id);
    }

	//--------------------------------------------------------------------------
    // Helpers
	//--------------------------------------------------------------------------
    static void getController()
    {
        Test.setCurrentPage(Page.OfferGeneration);
        con = new OfferGenerationController();
        system.assert(con!=null);

        con.limitRows = 'LIMIT 1';
        system.assertEquals('LIMIT 1', con.limitRows);
    }

    static void create_SIM_O2_DISE_Map_Mobile(String name)
    {
        O2_DISE_Map_Mobile__c obj =
        	new O2_DISE_Map_Mobile__c
	        (
	        	Name='sim base tariff name',
	            Contract_Length__c='24', Roaming__c='--None--',
	            Product_Definition__c = 'Business Single',
	            Contract_type__c = 'SIM ONLY',
	            Handset_Tariff_Class__c = 'iPhone X'+name,
	            Primary_Additional__c = 'Primary',
	            Tariff_Code__c = 'QSIM'
	        );
        insert obj;
        system.assert(obj.Id != null);
        String queryString = 'select '+ Utility.getSobjectFields('O2_DISE_Map_Mobile__c') +
                    ' from O2_DISE_Map_Mobile__c where id=\'' + obj.Id + '\'';
        SIMmapMobile = Database.query(queryString);
    }

    static void create_O2_DISE_Map_Mobile(String name)
    {
        O2_DISE_Map_Mobile__c obj =
        	new O2_DISE_Map_Mobile__c
        	(
        		Name='offer base tariff name',
                Contract_Length__c='24', Roaming__c='--None--',
                Product_Definition__c = 'Business Single',
                Contract_type__c = 'Handset',
                Handset_Tariff_Class__c = 'iPhone X'+name,
                Primary_Additional__c = 'Primary',
                Tariff_Code__c = 'QTEST'
            );
        insert obj;
        system.assert(obj.Id != null);
        String queryString = 'select ' + Utility.getSobjectFields('O2_DISE_Map_Mobile__c') +
                    ' from O2_DISE_Map_Mobile__c where id=\'' + obj.Id + '\'';
        mapMobile = Database.query(queryString);
    }

    static void create_O2_DISE_Map_Handset(String myName, String mapMobileName, String handsetClass)
    {
        O2_DISE_Map_Handset__c obj =
        	new O2_DISE_Map_Handset__c
        	(
        		Name=myName, Base_Tariff__c=mapMobileName, Handset_Class__c=handsetClass,
                Product_Code__c = 'HANDSETA'
            );
        insert obj;
        system.assert(obj.Id != null);
        mapHandset =
        [
	       	select id, Base_Tariff__c, Handset_Class__c, Product_Code__c
	        from O2_DISE_Map_Handset__c where id = :obj.Id
	    ];
    }

    static void create_O2_DISE_Map_Handset_Selection(String productCode)
    {
        O2_DISE_Ref_Hardware_Portfolio__c childHWPort =
        	new O2_DISE_Ref_Hardware_Portfolio__c
        	(
        		Product_Code__c=productCode, Hardware_Type__c='Handset',
        		Hardware_Description__c='Test Description', Operating_System__c='Android'
        	);
        insert childHWPort;
        system.assert(childHWPort.Id != null);

        handsetSelection =
        	new O2_DISE_Map_Handset_Selection__c
        	(
        		Handset_class__c='Phone', active__c=true,
        		channel__c='Online', Product_Code__c=childHWPort.Id
        	);
        insert handsetSelection;
        system.assert(handsetSelection.Id != null);
    }

    static void create_O2_DISE_Ref_Hardware_Relation()
    {
        O2_DISE_Ref_Hardware_Portfolio__c childHWPort =
        	new O2_DISE_Ref_Hardware_Portfolio__c
        	(
        		Hardware_Type__c='Accessory', Hardware_Sub_Type__c='Other',
        		Stock_Status__c='In Stock', Hardware_Description__c='Test Description',
        		Product_Code__c='TestOfferA'
        	);
        insert childHWPort;
        system.assert(childHWPort.Id != null);
        O2_DISE_Ref_Hardware_Portfolio__c parentHWPort =
        	new O2_DISE_Ref_Hardware_Portfolio__c
        	(
        		Hardware_Type__c='Handset', Operating_System__c='Android',
        		Stock_Status__c='In Stock', Hardware_Description__c='Test Description',
        		Product_Code__c='TestOfferH'
        	);
        insert parentHWPort;
        system.assert(parentHWPort.Id != null);

        refHwRel =
        	new O2_DISE_Ref_Hardware_Relation__c
        	(
        		child_product_code__c = childHWPort.Id, // DISE Ref Hardware Portfolio
                parent_product_code__c = parentHWPort.Id, // DISE Ref Hardware Portfolio
                active__c = true
            );
        insert refHwRel;
        system.assert(refHwRel.Id != null);
    }

    static void create_O2_DISE_Map_Mobile_Bolton()
    {
        mapMobileBolton =
        	new O2_DISE_Map_Mobile_Bolton__c
        	(
        		Bolt_On_Type__c='DATA BOLTON',
                Tariff_Description__c = 'Single User'
            );
        insert mapMobileBolton;
        system.assert(mapMobileBolton.Id != null);
    }

	//--------------------------------------------------------------------------
    // Tests
    //--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
    // Accessories
    //--------------------------------------------------------------------------
    static testMethod void testAccessories()
    {
        Test.startTest();
        con.selectedOfferType = 'ACCESSORY';
        con.accessorySKU = '\'TestOfferA\'';
        con.handsetSKU = '\'TestOfferH\'';
        PageReference pr = con.createButtonRouting();
        Test.stopTest();
        system.assert(pr == null);
        List<cscfgc__Product_Configuration__c> configs =
        [
        	select Id from cscfgc__Product_Configuration__c
        	where O2_DISE_Ref_Hardware_Portfolio__c = :refHwRel.child_product_code__c
        ];
        system.assert(configs.size() == 1);  //==3); // Problem with Configurator means we have to use batch size of 1
        List<cscfgc__Configuration_Offer__c> offers =
        [
        	select Id from cscfgc__Configuration_Offer__c
        	where O2_DISE_Ref_Hardware_Portfolio__c = :refHwRel.child_product_code__c
        ];
        system.assert(offers.size() == 3);
    }

	//--------------------------------------------------------------------------
    // Data Bolt On
    //--------------------------------------------------------------------------
    static testMethod void testBoltOnData()
    {
        Test.startTest();
        con.selectedOfferType = 'BOLTON';
        con.boltOnTariffKey = 'Test';
        con.boltOnTariffName = '\'DATA BOLTON\'';
        con.boltOnTariffClass = '\'Single User\'';
        PageReference pr = con.createButtonRouting();
        Test.stopTest();
        system.assert(pr == null);
        List<cscfgc__Product_Configuration__c> configs =
        [
        	select Id
        	from cscfgc__Product_Configuration__c
        	where O2_DISE_Map_Mobile_Bolton__c = :mapMobileBolton.Id
        ];
        system.assert(configs.size() == 1);
        List<cscfgc__Configuration_Offer__c> offers =
        [
        	select Id
        	from cscfgc__Configuration_Offer__c
        	where O2_DISE_Map_Mobile_Bolton__c = :mapMobileBolton.Id
        ];
        system.assert(offers.size() == 1);
    }

	//--------------------------------------------------------------------------
	// International Favourites Bolt On
	//--------------------------------------------------------------------------
    static testMethod void testBoltOnIntFav()
    {
        mapMobileBolton.Bolt_On_Type__c='INTERNATIONAL FAVOURITES';
        update mapMobileBolton;

        Test.startTest();
        con.selectedOfferType='BOLTON';
        con.boltOnTariffKey = 'Test';
        con.boltOnTariffName = '\'INTERNATIONAL FAVOURITES\'';
        con.boltOnTariffClass = '\'Single User\'';
        PageReference pr = con.createButtonRouting();
        Test.stopTest();
        system.assert(pr == null);
        List<cscfgc__Product_Configuration__c> configs =
        [
        	select Id from cscfgc__Product_Configuration__c
        	where O2_DISE_Map_Mobile_Bolton__c = :mapMobileBolton.Id
        ];
        system.assert(configs.size() == 1);
        List<cscfgc__Configuration_Offer__c> offers =
        [
        	select Id from cscfgc__Configuration_Offer__c
        	where O2_DISE_Map_Mobile_Bolton__c = :mapMobileBolton.Id
        ];
        system.assert(offers.size()==1);
    }

	//--------------------------------------------------------------------------
	// FOUR G ACCESS Bolt On
	//--------------------------------------------------------------------------
    /*static testMethod void testBoltOnOffPeakMin()
    {
        mapMobileBolton.Bolt_On_Type__c='FOUR G ACCESS';
        update mapMobileBolton;

        Test.startTest();
        con.selectedOfferType='BOLTON';
        con.boltOnTariffKey = 'Test';
        con.boltOnTariffName = '\'FOUR G ACCESS\'';
        con.boltOnTariffClass = '\'Single User\'';
        PageReference pr = con.createButtonRouting();
        Test.stopTest();
        system.assert(pr == null);
        List<cscfgc__Product_Configuration__c> configs =
        [
        	select Id
        	from cscfgc__Product_Configuration__c
        	where O2_DISE_Map_Mobile_Bolton__c = :mapMobileBolton.Id
        ];
        system.assert(configs.size() == 1);
        List<cscfgc__Configuration_Offer__c> offers =
        [
        	select Id
        	from cscfgc__Configuration_Offer__c
        	where O2_DISE_Map_Mobile_Bolton__c = :mapMobileBolton.Id
        ];
        system.assert(offers.size() == 1);
    }*/

	//--------------------------------------------------------------------------
    // Handset Tariff
    //--------------------------------------------------------------------------
    static testMethod void testOffers()
    {
        Test.startTest();
        con.selectedOfferType='TARIFFHANDSET';
        con.tariffKey = 'Test';
        con.tariffName = '\'offer base tariff name\'';
        con.tariffClass = '\'iPhone X10\'';
        con.handsetSKU = '\'HANDSETA\'';
        PageReference pr = con.createButtonRouting();
        Test.stopTest();
        system.assert(pr == null);
        List<cscfgc__Product_Configuration__c> configs=
        [
        	select Id from cscfgc__Product_Configuration__c
            where O2_DISE_Map_Mobile__c = :mapMobile.Id
            and O2_DISE_Map_Handset__c = :mapHandset.Id
            and O2_DISE_Map_Handset_Selection__c = :handsetSelection.Id
        ];
        system.assert(configs.size() == 1);  //==2); // Problem with Configurator means we have to use batch size of 1
        List<cscfgc__Configuration_Offer__c> offers =
        [
        	select Id from cscfgc__Configuration_Offer__c
            where O2_DISE_Map_Mobile__c = :mapMobile.Id
            and O2_DISE_Map_Handset__c = :mapHandset.Id
            and O2_DISE_Map_Handset_Selection__c = :handsetSelection.Id
        ];
        system.assert(offers.size() == 2);
    }

	//--------------------------------------------------------------------------
	// Handset Tariff with Bonus
	//--------------------------------------------------------------------------
    static testMethod void testBonusOffers()
    {
        mapMobile.Promotion__c='BONUS';
        mapMobile.Handset_Tariff_Class__c = 'Blackberry BIS';
        update mapMobile;
        mapHandset.Handset_Class__c='Blackberry BIS';
        update mapHandset;

        Test.startTest();
        con.selectedOfferType='TARIFFHANDSET';
        con.tariffKey = 'Test';
        con.tariffName = '\'offer base tariff name\'';
        con.tariffClass = '\'Blackberry BIS\'';
        con.handsetSKU = '\'HANDSETA\'';
        PageReference pr = con.createButtonRouting();
        Test.stopTest();
        system.assert(pr == null);
        List<cscfgc__Product_Configuration__c> configs =
        [
        	select Id from cscfgc__Product_Configuration__c
            where O2_DISE_Map_Mobile__c = :mapMobile.Id
            and O2_DISE_Map_Handset__c = :mapHandset.Id
            and O2_DISE_Map_Handset_Selection__c = :handsetSelection.Id
        ];
        system.assert(configs.size() == 1);  //==2); // Problem with Configurator means we have to use batch size of 1
        List<cscfgc__Configuration_Offer__c> offers =
        [
        	select Id from cscfgc__Configuration_Offer__c
            where O2_DISE_Map_Mobile__c = :mapMobile.Id
            and O2_DISE_Map_Handset__c = :mapHandset.Id
            and O2_DISE_Map_Handset_Selection__c = :handsetSelection.Id
         ];
        system.assert(offers.size() == 2);
    }

	//--------------------------------------------------------------------------
    // SIM Only Tariff
    //--------------------------------------------------------------------------
    static testMethod void testSimOnlyOffers()
    {
        Test.startTest();
        con.selectedOfferType = 'SIMONLY';
        con.simOnlyTariffKey = 'Test';
        con.simOnlyTariffName = '\'sim base tariff name\'';
        con.simOnlyTariffClass = '\'iPhone X10\'';
        PageReference pr = con.createButtonRouting();
        Test.stopTest();
        system.assert(pr == null);
        List<cscfgc__Product_Configuration__c> configs=[select Id from cscfgc__Product_Configuration__c where O2_DISE_Map_Mobile__c=:SIMmapMobile.Id];
        system.assert(configs.size() == 1);  //==2); // Problem with Configurator means we have to use batch size of 1
        List<cscfgc__Configuration_Offer__c> offers =
        [
        	select Id from cscfgc__Configuration_Offer__c
        	where O2_DISE_Map_Mobile__c = :SIMmapMobile.Id
        ];
        system.assert(offers.size() == 3);
    }
}