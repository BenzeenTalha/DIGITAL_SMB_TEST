@isTest
private class TestAllSLATriggers {

    static testMethod void testInsertUpdate() {

		TestUnifyHelper.setupCustomSettings();

		//Insert SLA Templates
		List<SLA_Template__c> slaTemplates = new List<SLA_Template__c>();
		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Change-Delivered to warehouse', Milestone_Description__c = 'Delivered to warehouse',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Change', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Existing-Delivered to warehouse', Milestone_Description__c = 'Delivered to warehouse',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Existing', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-New-Delivered to warehouse', Milestone_Description__c = 'Delivered to warehouse',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'New', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Transformation-Delivered to warehouse', Milestone_Description__c = 'Delivered to warehouse',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Transformation', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'N/A', Warning_Days__c = 1, Target_Days__c =2 , Solution_Type__c = 'Unify'));


		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Change-Pre-stage complete', Milestone_Description__c = 'Pre-stage complete',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Change', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Existing-Pre-stage complete', Milestone_Description__c = 'Pre-stage complete',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Existing', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-New-Pre-stage complete', Milestone_Description__c = 'Pre-stage complete',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'New', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Transformation-Pre-stage complete', Milestone_Description__c = 'Delivered to warehouse',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Transformation', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'N/A', Warning_Days__c = 1, Target_Days__c =2 , Solution_Type__c = 'Unify'));


		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Change-Delivered to site', Milestone_Description__c = 'Delivered to site',
											 Milestone_Order__c = 1, Order_Status__c = 'Delivered to site', Order_Type__c = 'Change', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Existing-Delivered to site', Milestone_Description__c = 'Delivered to site',
											 Milestone_Order__c = 1, Order_Status__c = 'Delivered to site', Order_Type__c = 'Existing', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-New-Delivered to site', Milestone_Description__c = 'Delivered to site',
											 Milestone_Order__c = 1, Order_Status__c = 'Delivered to site', Order_Type__c = 'New', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Transformation-Delivered to site', Milestone_Description__c = 'Delivered to site',
											 Milestone_Order__c = 1, Order_Status__c = 'Delivered to site', Order_Type__c = 'Transformation', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'N/A', Warning_Days__c = 1, Target_Days__c =2 , Solution_Type__c = 'Unify'));


		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Change-Hardware configured', Milestone_Description__c = 'Hardware configured',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Change', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Existing-Hardware configured', Milestone_Description__c = 'Hardware configured',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Existing', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-New-Hardware configured', Milestone_Description__c = 'Hardware configured',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'New', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Transformation-Hardware configured', Milestone_Description__c = 'Hardware configured',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Transformation', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'N/A', Warning_Days__c = 1, Target_Days__c =2 , Solution_Type__c = 'Unify'));


		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Change-Order complete date', Milestone_Description__c = 'Order complete date',
											 Milestone_Order__c = 1, Order_Status__c = 'Order complete date', Order_Type__c = 'Change', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Existing-Order complete date', Milestone_Description__c = 'Order complete date',
											 Milestone_Order__c = 1, Order_Status__c = 'Order complete date', Order_Type__c = 'Existing', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-New-Order complete date', Milestone_Description__c = 'Order complete date',
											 Milestone_Order__c = 1, Order_Status__c = 'Order complete date', Order_Type__c = 'New', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Transformation-Order complete date', Milestone_Description__c = 'Order complete date',
											 Milestone_Order__c = 1, Order_Status__c = 'Order complete date', Order_Type__c = 'Transformation', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'N/A', Warning_Days__c = 1, Target_Days__c =2 , Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Change-Billing start date', Milestone_Description__c = 'Billing start date',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Change', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Existing-Billing start date', Milestone_Description__c = 'Billing start date',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Existing', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-New-Billing start date', Milestone_Description__c = 'Billing start date',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'New', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'Target', Warning_Days__c = 1, Target_Days__c = 2, Solution_Type__c = 'Unify'));

		slaTemplates.add(new SLA_Template__c(Name = 'Hardware-Transformation-Billing start date', Milestone_Description__c = 'Billing start date',
											 Milestone_Order__c = 1, Order_Status__c = '', Order_Type__c = 'Transformation', Product_Type__c = 'Hardware',
											 Related_Object__c = 'Order', Tracking_Type__c = 'N/A', Warning_Days__c = 1, Target_Days__c =2 , Solution_Type__c = 'Unify'));

		insert slaTemplates;




		Account acc = new Account (Name = 'First Acc');
		insert acc;

		Unify_Site__c site = new Unify_Site__c (Name='First Site',Post_Code__c='SW193RQ');
		insert site;

		cscfgc__Product_Configuration__c prconf = new cscfgc__Product_Configuration__c(Name='First Config', Unify_Order_Type__c = 'New');
		insert prconf;

		Order_Group__c og = TestUnifyHelper.createOrderGroup();

		Test.startTest();

		//SLA's should be autocreated
    	Order__c ord = new Order__c(Name='First Order', Account__c=acc.Id, Unify_Site__c=site.Id, Order_Group__c = og.Id,
    	 							Product_Configuration__c=prconf.Id, Order_Placed_Date__c=Datetime.now(), Product_Type__c='Hardware');
    	insert ord;

    	//Check number of inserted SLA records
    	List<SLA__c> slas = [SELECT Id, Name, Target_Date__c, Warning_Date__c, Order__c, Milestone_Order__c, SLA_Status__c FROM SLA__c WHERE Order__c = :ord.Id ORDER BY Milestone_Order__c];
    	System.debug('>>>>>>>>> SLAS ' + slas);
    	System.assertEquals(6,slas.size());

		slas[0].Target_Date__c = DateTime.now().addDays(1);
		update slas[0];
    	slas[0].Actual_Date__c = DateTime.now();
    	update slas[0];
    	slas[0].SLA_Status__c = 'In Progress';
    	update slas[0];
    	slas[0].SLA_Status__c = 'Completed';
    	update slas[0];
		slas[1].Actual_Date__c = DateTime.now();
    	update slas[1];
    	slas[2].Actual_Date__c = DateTime.now();
    	update slas[2];
		slas[3].Actual_Date__c = DateTime.now();
    	update slas[3];
    	slas[4].Actual_Date__c = DateTime.now();
    	update slas[4];
		slas[5].Actual_Date__c = DateTime.now();
    	update slas[5];





    	/*SLAHelper.createSLAs(ord);

    	SLA__c sla1 = new SLA__c(Name='First SLA',Target_Days__c=12,Warning_Days__c=1,Target_Date__c=Datetime.newInstance(2013,5,4),Warning_Date__c=Datetime.newInstance(2013,5,2),Order__c=ord.Id);
    	insert sla1;

	    sla1.Target_Date__c = Datetime.now();
	    update sla1;

	    sla1.Target_Days__c = 17;
	   	sla1.Pause__c = true;

		update sla1;

	    sla1.Pause__c = false;
	    sla1.SLA_Status__c = 'Completed';

	    update sla1;*/

    	Test.stopTest();
    }

}