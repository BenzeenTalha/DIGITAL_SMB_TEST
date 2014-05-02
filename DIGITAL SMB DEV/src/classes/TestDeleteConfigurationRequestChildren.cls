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
@isTest
private class TestDeleteConfigurationRequestChildren {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Location__c tLoc = new Location__c();
        //tLoc.Location_UID__c = 'a1rR000000090zI_installation';
        tLoc.Type__c = 'Installation';
        tLoc.PAF_Building_Number__c = '50';
        tLoc.PAF_Thoroughfare_Name__c = 'Eastcastle Street';
        tLoc.PAF_Post_Town__c = 'London';
        tLoc.PAF_Postcode__c = 'W1W 8EA';
        //insert tLoc;
        
        Configuration_Request__c cf = new Configuration_Request__c();
        cf.Directory_Number__c = '442075806685';
        cf.Post_Code__c = 'W1W 8EA';
        cf.Product_Category__c = 'SMB Fixed Line';
        insert cf;
        
        tLoc.Location_UID__c = cf.Id + '_installation';
        tLoc.Configuration_Request__c = cf.Id;
        
        insert tLoc;
        
        delete cf;
        
    }
}