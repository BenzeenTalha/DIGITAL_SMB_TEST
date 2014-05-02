public with sharing class TestAllDiseMapMinutes {

	static testmethod void testAll() {
		O2_DISE_Map_Minutes__c dmm = new O2_DISE_Map_Minutes__c();
		dmm.Attribute_Name__c ='test';
		dmm.Attribute_Value__c ='100';
		
		insert dmm;
	}


}