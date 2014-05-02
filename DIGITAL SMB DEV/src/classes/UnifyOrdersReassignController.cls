public with sharing class UnifyOrdersReassignController {

	//Help Order Groups
	public Order__c o1 {get; set;}
	public Order__c o2 {get; set;}
	public List<OrderWrapper> allOrders {get; set;}
	public boolean allSelected {get; set;}
	public boolean ordersExist {get; set;}
	public boolean ordersCalled {get; set;}
	public string sortKey {get; set;}
	public string sortKeyOld {get; set;}
	public string sortDirection {get; set;}

	public UnifyOrdersReassignController(ApexPages.StandardController controller){
		o1 = new Order__c();
		o2 = new Order__c();
	}

	/*
	 * Shows orders assigned to Existing Assignee
	 */
	public PageReference ShowOrders(){
		if(string.IsBlank(o1.Assignee__c)) {
			AddPageMessage(ApexPages.severity.ERROR, 'Please enter Existing Assignee');
			return null;
		}
		ordersCalled = true;
		allSelected = false;
		List<Order__c> orders = [SELECT
									Id, Name, Assignee__c, Assignee__r.Name, Order_Status__c, Product_Type__c, Unify_RAG_Value__c, Order_Group__c, Order_Group__r.Name,
									Product_Configuration__r.Unify_Solution__c, Product_Configuration__r.Unify_Site__r.Name, Opportunity__c, Opportunity__r.Name,
									CreatedDate, LastModifiedDate
								 FROM
									Order__c
								 WHERE
										RecordType.Name = 'Unify' AND
										Assignee__c = :o1.Assignee__c AND
										Order_Status__c NOT IN ('Active', 'Cancelled')];
		allOrders = new List<OrderWrapper>();
		for(Order__c o : orders)
			allOrders.add(new OrderWrapper(o, false));
		ordersExist = allOrders.size() > 0;
		return null;
	}

	public PageReference SortOrders(){
		if(sortKey != sortKeyOld){
			sortDirection = 'ASC';
		} else {
			sortDirection = sortDirection != 'ASC' ? 'ASC' : 'DESC';
		}
		for(OrderWrapper ow : allOrders){
			ow.sortKey = sortKey;
			ow.sortDirection = sortDirection;
		}
		allOrders.sort();
		sortKeyOld = sortKey;
		return null;
	}

	public PageReference Reassign(){
		try {
			//Validate

			//Check if users have been entered
			boolean hasErrors = false;
			if(string.IsBlank(o1.Assignee__c)) {
				hasErrors = true;
				AddPageMessage(ApexPages.severity.ERROR, 'Please enter Existing Assignee');
			}

			if(string.IsBlank(o2.Assignee__c)) {
				hasErrors = true;
				AddPageMessage(ApexPages.severity.ERROR, 'Please enter New Assignee');
			}

			if(hasErrors)
				return null;

			//Check if users are same
			if(o1.Assignee__c == o2.Assignee__c){
				hasErrors = true;
				AddPageMessage(ApexPages.severity.ERROR, 'You can\'t reassign to the same user.');
			}

			if(hasErrors)
				return null;

			//Check if users are below in the hierarchy or if old user is current user
			Set<Id> userIds = new Set<Id>();
			userIds.add(UserInfo.getUserId());
			userIds.add(o1.Assignee__c);
			userIds.add(o2.Assignee__c);
			Map<Id,User> allUsers = new Map<Id,User>([SELECT Id, Name, UserRoleId, Email FROM User WHERE Id IN :userIds]);
			User curentUser = allUsers.get(UserInfo.getUserId());
			User assignee1 = allUsers.get(o1.Assignee__c);
			User assignee2 = allUsers.get(o2.Assignee__c);
			if(curentUser.Id != assignee1.Id){
				if(!CheckRoleHierarchy(curentUser.UserRoleId, assignee1.UserRoleId)){
					AddPageMessage(ApexPages.severity.ERROR, 'You can\'t reassign Orders assigned to ' + assignee1.Name + '. This user is in higher hierarchy level (role) than you.');
					hasErrors = true;
				}
			}
			if(curentUser.Id != assignee2.Id){
				if(!CheckRoleHierarchy(curentUser.UserRoleId, assignee2.UserRoleId)){
					AddPageMessage(ApexPages.severity.ERROR, 'You can\'t assign Orders to ' + assignee2.Name + '. This user is in higher hierarchy level (role) than you.');
					hasErrors = true;
				}
			}

			if(hasErrors)
				return null;

			//Assign Orders
			List<Order__c> ordersToUpdate = new List<Order__c>();
			for(OrderWrapper ow : allOrders){
				if(ow.IsSelected){
					ow.Order.Assignee__c = assignee2.Id;
					ordersToUpdate.add(ow.Order);
				}
			}
			if(ordersToUpdate.size() > 0)
				update ordersToUpdate;

			AddPageMessage(ApexPages.severity.INFO, 'Orders reassigned: <b>' + ordersToUpdate.size() + '</b>');

			if(ordersToUpdate.size() > 0){
				//Send email to: Current User, Old User and New User
				string subject = 'Unify Orders Reassigned';
				Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
				mailMessage.setSubject(subject);
				String[] toAddresses = new String[] {assignee1.Email, assignee2.Email, curentUser.Email};
				mailMessage.setToAddresses(toAddresses);
				mailMessage.setHtmlBody(GetEmailBody(ordersToUpdate, assignee1, assignee2, curentUser));
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailMessage });
			}

			//Refresh orders
			List<Order__c> orders = [SELECT
										Id, Name, Assignee__c, Assignee__r.Name, Order_Status__c, Product_Type__c, Unify_RAG_Value__c, Order_Group__c, Order_Group__r.Name,
										Product_Configuration__r.Unify_Solution__c, Product_Configuration__r.Unify_Site__r.Name, Opportunity__c, Opportunity__r.Name,
										CreatedDate, LastModifiedDate
									 FROM
										Order__c
									 WHERE
											RecordType.Name = 'Unify' AND
											Assignee__c = :o1.Assignee__c AND
											Order_Status__c NOT IN ('Active', 'Cancelled')];
			allOrders = new List<OrderWrapper>();
			for(Order__c o : orders)
				allOrders.add(new OrderWrapper(o, false));
			ordersExist = allOrders.size() > 0;
		} catch (Exception ex) {
			AddExceptionMessage(ex);
		}
		return null;
	}


	private Map<Id, UserRole> allRolesMap{
		get{
			if(allRolesMap == null){
				allRolesMap = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId FROM UserRole]);
			}
			return allRolesMap;
		}

		set;
	}

	/**
	 * Checks if Parent Role is higher or equal in the hierarchy than the Child Role.
	 *
	 * @param	ParentRoleId	Parent Role Id
	 * @param	ChildRoleId		Child Role Id
	 * @return					True if Parent Role is higher or equal in the hierarchy, false otherwise
	 */
	private Boolean CheckRoleHierarchy(Id ParentRoleId, Id ChildRoleId){
		if(string.IsBlank(ParentRoleId) || string.IsBlank(ChildRoleId))
			return false;

		UserRole ChildRole = allRolesMap.get(ChildRoleId);

		if(ChildRole.ParentRoleId == ParentRoleId || ChildRoleId == ParentRoleId){
			return true;
		}

		return CheckRoleHierarchy(ParentRoleId, ChildRole.ParentRoleId);
	}

	/**
	 * Adds message to the page
	 *
	 * @param	Severity	Message Severity
	 * @param	Message		Message
	 */
	private void AddPageMessage(ApexPages.severity Severity, String Message){
		ApexPages.addmessage(new ApexPages.message(Severity, Message));
	}

	/**
	 * Adds exception message to the page
	 *
	 * @param	ex	Exception
	 */
	private void AddExceptionMessage(Exception ex){
		AddPageMessage(ApexPages.severity.ERROR, ex.getMessage() + '<br/>' + ex.getStackTraceString());
	}

	/**
	 * Creates email HTML body that will be sent to all relevant parties
	 *
	 * @param	orders			List of reassinged orders
	 * @param	oldAssignee		Existing Orders assignee
	 * @param	newAssignee		New Orders assignee
	 * @param	sender			Current user
	 */
	private string GetEmailBody(List<Order__c> orders, User oldAssignee, User newAssignee, User sender){
	 	string body = '';
	 	body += '<!DOCTYPE html>';
	 	body += '<html>';
	 	body += '	<body style="font-family:Arial;">';
	 	body += '		Hello,<br/><br/>';
	 	body += '		Following Unify Orders have been reassigned from ' + oldAssignee.Name + ' to ' + newAssignee.Name + '.<br/><br/>';
 		body += '		Orders reassigned: <b>' + orders.size() + '</b>';
	 	if(orders.size() > 0){
	 		body += '		<table border="1" cellspacing="0" cellpadding="3" bordercolor="black" style="border-color:black; border-collapse:collapse;font-family:Arial;">';
			body += '			<tr>';
			body += '				<th>Order</th>';
			body += '				<th>Order Status</th>';
			body += '				<th>Solution</th>';
			body += '				<th>Site Name</th>';
			body += '				<th>Order Group</th>';
			body += '				<th>Opportunity</th>';
			body += '				<th>Created Date</th>';
			body += '			</tr>';
			for(Order__c o : orders){
				string oLink = '<a href="' + GetLink(o.Id) +'">' + o.Name + '</a>';
				string ogLink = '<a href="' + GetLink(o.Order_Group__c) +'">' + o.Order_Group__r.Name + '</a>';
				string oppLink = '<a href="' + GetLink(o.Opportunity__c) +'">' + o.Opportunity__r.Name + '</a>';
				body += '			<tr>';
				body += '				<td>' + oLink + '</td>';
				body += '				<td>' + o.Order_Status__c + '</td>';
				body += '				<td>' + o.Product_Configuration__r.Unify_Solution__c + '</td>';
				body += '				<td>' + o.Product_Configuration__r.Unify_Site__r.Name + '</td>';
				body += '				<td>' + ogLink + '</td>';
				body += '				<td>' + oppLink + '</td>';
				body += '				<td>' + o.CreatedDate.format('dd/MM/yyyy HH:mm') + '</td>';
				body += '			</tr>';
			}
	 		body += '		</table>';
	 	}
	 	body += '		<br/><br/>';
	 	body += '		Regards,<br/>';
	 	body += '		' + sender.Name;
	 	body += '	</body>';
	 	body += '</html>';
		return body;
	}

	/**
	 * Creates public URL of the record
	 *
	 * @param	RecordId	Id of the record
	 * @return	Full URL to the record
	 */
	private string GetLink(string RecordId){
		return URL.getSalesforceBaseUrl().toExternalForm() + '/' + RecordId;
	}

	/**
	 * Class used as a wrapper. Enables selection of an Order on the page
	 */
	private class OrderWrapper implements Comparable{
		public boolean IsSelected {get; set;}
		public Order__c Order {get; set;}
		public string sortKey {get; set;}
		public string sortDirection {get; set;}

		//Constructor
		public OrderWrapper(Order__c Order, boolean IsSelected){
			this.IsSelected = IsSelected;
			this.Order = Order;
		}

		public Integer compareTo(Object compareTo){
			OrderWrapper compareToOrder = (OrderWrapper)compareTo;
			integer result = 0;
			try {
				if(this.sortKey == 'Status'){
					result = this.Order.Order_Status__c.compareTo(compareToOrder.Order.Order_Status__c);
				} else if(this.sortKey == 'Solution') {
					result = this.Order.Product_Configuration__r.Unify_Solution__c.compareTo(compareToOrder.Order.Product_Configuration__r.Unify_Solution__c);
				} else if(this.sortKey == 'Site') {
					result = this.Order.Product_Configuration__r.Unify_Site__r.Name.compareTo(compareToOrder.Order.Product_Configuration__r.Unify_Site__r.Name);
				} else if(this.sortKey == 'OrderGroup') {
					result = this.Order.Order_Group__r.Name.compareTo(compareToOrder.Order.Order_Group__r.Name);
				} else if(this.sortKey == 'Opportunity') {
					result = this.Order.Opportunity__r.Name.compareTo(compareToOrder.Order.Opportunity__r.Name);
				} else if(this.sortKey == 'CreatedDate') {
					result = this.Order.CreatedDate.getTime() > compareToOrder.Order.CreatedDate.getTime() ? 1 : -1;
				} else if(this.sortKey == 'LastModifiedDate') {
					result = this.Order.LastModifiedDate.getTime() > compareToOrder.Order.LastModifiedDate.getTime() ? 1 : -1;
				} else {
					result = this.Order.Name.compareTo(compareToOrder.Order.Name);
				}
			} catch (Exception ex) {
				result = -1;
			}
			if(this.sortDirection == 'DESC')
				result = result * (-1);
			return result;
		}

	}
}