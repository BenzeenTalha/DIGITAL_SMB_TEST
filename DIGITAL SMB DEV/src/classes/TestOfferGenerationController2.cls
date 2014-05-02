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

// Delete testing moved here from TestOfferGenerationController since it didn't need the overhead of all the preparation.

@isTest(SeeAllData=true)
private class TestOfferGenerationController2 {
    private static OfferGenerationController con;

    static {
        getController();
    }


    // helpers

    static void getController() {
        Test.setCurrentPage(Page.OfferGeneration);
        con = new OfferGenerationController();
        system.assert(con!=null);

        con.limitRows = 'LIMIT 1';
        system.assertEquals('LIMIT 1', con.limitRows);
    }


    // tests

    static testMethod void testScreenOptions() {
        con.selectedTariffKey = 'My Tariff:-:SMART';
        con.addTariff();
        system.assert(con.tariffKey == '\'My Tariff:-:SMART\'');
        system.assert(con.tariffName == '\'My Tariff\'');
        system.assert(con.tariffClass == '\'SMART\'');
        con.selectedHandsetSKU = '1ABC123';
        con.addHandset();
        system.assert(con.handsetSKU == '\'1ABC123\'');
        con.selectedAccessorySKU = 'XYZ123Z';
        con.addAccessory();
        system.assert(con.accessorySKU == '\'XYZ123Z\'');
        
        con.deleteButtonRouting();
    }
    
    static testMethod void testDeleteOnlineOffers() {
        con.selectedOfferType='ALL';
        PageReference pr = con.deleteButtonRouting();
        system.assert(pr == null);
    }
    
    static testMethod void testDeleteHandsetOffers() {
        con.selectedTariffKey = con.tariffTypes.get(0).getValue();
        con.addTariff();
        con.selectedHandsetSKU = con.handsetTypes.get(0).getValue();
        con.addHandset();
    	con.selectedOfferType='TARIFFHANDSET';
        PageReference pr = con.deleteButtonRouting();
        system.assert(pr == null);
    }
    
    static testMethod void testDeleteSimOnlyOffers() {
        con.selectedOfferType='SIMONLY';
        PageReference pr = con.deleteButtonRouting();
        system.assert(pr == null);
    }
    
    static testMethod void testDeleteAccessoryOffers() {
        con.selectedAccessorySKU = con.accessoryTypes.get(0).getValue();
        con.addAccessory();
//        con.selectedHandsetSKU = con.handsetTypes.get(0).getValue();
//        con.addHandset();
        con.selectedOfferType='ACCESSORY';
        PageReference pr = con.deleteButtonRouting();
        system.assert(pr == null);
    }
    
    static testMethod void testDeleteBoltOnOffers() {
        con.selectedOfferType='BOLTON';
        PageReference pr = con.deleteButtonRouting();
        system.assert(pr == null);
    }
    
    static testMethod void testFlavourList() {
        List<String> flavours = con.FlavourList;
        system.assert(flavours != null);
    }
    
    static testMethod void testPrimaryCoreBoltons() {
        List<String> boltons = con.PrimaryCoreBoltOnList;
        system.assert(boltons != null);
    }
}