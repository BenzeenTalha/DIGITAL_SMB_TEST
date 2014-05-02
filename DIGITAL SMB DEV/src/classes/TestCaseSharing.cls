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
private class TestCaseSharing {

	private static Case c1 {get; set;}
	private static Case c2 {get; set;}
	private static List<Id> lstCaseId {get; set;}
	private static List<Id> lstuserOrGroupId {get; set;}
	private static List<User> u12 {get; set;}
	private static Group g1 {get; set;}
	private static GroupMember gm1 {get; set;}
	private static User thisUser {get; set;}

	static void setupData() {

		u12	= [select id from User where UserType =: 'Standard' and isActive = true LIMIT 2];
		g1 = new Group(Name='Case Solvers');
		insert g1;
		system.debug('u12: '+u12);
		system.debug('g1: '+g1);
		
		gm1 = new GroupMember(UserOrGroupId = u12[0].id, groupId = g1.id);
		insert gm1;

		// add a user and a group
    	lstuserOrGroupId = new List<id>();
		lstuserOrGroupId.add(g1.id);
		lstuserOrGroupId.add(u12[1].id);
		
		c1 = new Case();
		c2 = new Case();
		
		thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {
		
			insert c1;
			insert c2;
		}
    	lstCaseId = new List<Id>();
		lstCaseId.add(c1.Id);
		lstCaseId.add(c2.Id);

	}

    static testMethod void myUnitTest() {
    	setupData();
    	
    	Test.startTest();
    	
    	system.debug('lstCaseId: '+lstCaseId);
    	system.debug('lstuserOrGroupId: '+lstuserOrGroupId);
		System.runAs ( thisUser ) {
			CaseSharing.ShareCaseManually(lstCaseId, lstuserOrGroupId);
		}	
		Test.stopTest();
		
		// We see what caseshare objects were created
		Integer c1g1 = [SELECT Count() FROM CaseShare WHERE CaseId=:c1.Id AND UserOrGroupId=:g1.Id];
		Integer c1u2 = [SELECT Count() FROM CaseShare WHERE CaseId=:c1.Id AND UserOrGroupId=:u12[1].Id];
		Integer c2g1 = [SELECT Count() FROM CaseShare WHERE CaseId=:c2.Id AND UserOrGroupId=:g1.Id];
		Integer c2u2 = [SELECT Count() FROM CaseShare WHERE CaseId=:c2.Id AND UserOrGroupId=:u12[1].Id];

		List<CaseShare> c1List = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId=:c1.Id];
		system.debug('c1List: '+c1List);
		List<CaseShare> c2List = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId=:c2.Id];
		system.debug('c2List: '+c2List);
		
		// the case and user/group array are processed one-for-one, i.e. case[0]/usergroup[0] and case[1]/usergroup[1]

		// case 1 and group 1
		system.assertEquals(c1g1,1);
		system.assertEquals(c1u2,0);
		// case 2 and user 2
		system.assertEquals(c2g1,0);
		system.assertEquals(c2u2,1);
    }
}