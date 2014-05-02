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
private class TestAllTaskTriggers {

	static testMethod void test_AllTaskTriggers() {
		
		
		List<Task> taskList = new List<Task>();
		
		Account accnt = new Account(Name = 'test Account 123');
        insert accnt ;
        
        Opportunity oppty = new Opportunity(Name='test Opportunity 123', StageName = 'Achievement of Results', CloseDate = Date.Today(), AccountId = accnt.id);
        insert oppty;
        
        Opportunity oppty2 = new Opportunity(Name='test Opportunity 123', StageName = 'Achievement of Results', CloseDate = Date.Today(), AccountId = accnt.id);
        insert oppty2;
        
        Task task = new Task(subject = 'Contract / Order Details Test',
                                    Description =  'Test task description',
                                    Priority = 'Normal',
                                    Status = 'Not Started',
                                    IsReminderSet = true,
                                    ReminderDateTime = System.now()-1,
                                    WhatId =  oppty.id);
		taskList.add(task);
		
		Task task2 = new Task(subject = 'Customer approval',
                                    Description =  'Test task description 2',
                                    Priority = 'Normal',
                                    Status = 'Not Started',
                                    IsReminderSet = true,
                                    ReminderDateTime = System.now()-1,
                                    WhatId =  oppty.id);
		taskList.add(task2);
        
        Task task3 = new Task(subject = 'Customer rejection',
                                    Description =  'Test task description 3',
                                    Priority = 'Normal',
                                    Status = 'Not Started',
                                    IsReminderSet = true,
                                    ReminderDateTime = System.now()-1,
                                    WhatId =  oppty2.id);
        taskList.add(task3);
        
        insert taskList;

	}
}