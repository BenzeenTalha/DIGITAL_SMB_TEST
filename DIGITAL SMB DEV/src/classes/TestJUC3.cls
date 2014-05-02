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
private class TestJUC3 {

    static testMethod void DiseMappingBatchAsyncTest1() {
    	
        DiseMappingBatchAsync.checkValue('2', '2', 'equals');
        DiseMappingBatchAsync.checkValue('2', '1', 'equals');
        DiseMappingBatchAsync.checkValue('2', '2', 'is not');
        DiseMappingBatchAsync.checkValue('2', '1', 'is not');
        DiseMappingBatchAsync.checkValue('2', '1', 'is greater than');
        DiseMappingBatchAsync.checkValue('2', '3', 'is greater than');
        DiseMappingBatchAsync.checkValue('2', '1', 'is greater than or equal to');
        DiseMappingBatchAsync.checkValue('2', '3', 'is greater than or equal to');
        DiseMappingBatchAsync.checkValue('2', '1', 'is less than');
        DiseMappingBatchAsync.checkValue('2', '3', 'is less than');
        DiseMappingBatchAsync.checkValue('2', '1', 'is less than or equal to');
        DiseMappingBatchAsync.checkValue('2', '3', 'is less than or equal to');
    }
	
    static testMethod void DiseMappingBatchAsyncTest2() {
        DiseMappingBatchAsync.getBBDiseCodeMap('');
    }

    static testMethod void DiseMappingBatchAsyncTest3() {
        DiseMappingBatchAsync.getCallsOnlyDiseCodeMap('');
    }

    static testMethod void DiseMappingBatchAsyncTest4() {
        DiseMappingBatchAsync.getISDNDiseCodeMap('');
    }

    static testMethod void DiseMappingBatchAsyncTest5() {
        DiseMappingBatchAsync.getLandlineDiseCodeMap('');
    }

    static testMethod void DiseMappingBatchAsyncTest6() {
        DiseMappingBatchAsync.getMinutesDiseCodeMap();
    }

    static testMethod void DiseMappingBatchAsyncTest7() {
        DiseMappingBatchAsync.getNGNDiseCodeMap('');
    }

	static testMethod void DiseMappingBatchAsyncTestProperties() {
		DiseMappingBatchAsync dmba = new DiseMappingBatchAsync();
    	dmba.query = 'SELECT Id From Product2';
    	system.assertEquals('SELECT Id From Product2', dmba.query);
		
		List<sObject> lss = dmba.diseCodeList;
		system.assertEquals(0, lss.size());
	}

	static testMethod void test_getLookupQuery() {
		List<String> lookupQueryIdList = new List<String>();
		Map<String,cscfgc__Lookup_Query__c> mapQuery = DiseMappingBatchAsync.getLookupQuery(lookupQueryIdList);
	}
}