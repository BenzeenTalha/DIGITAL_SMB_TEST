public with sharing class O2FranchiseeSharing {


	public static void manualShare (List<O2_Franchisee__c> o2FranchiseeList) {


		Set<String> torexCodeList = new Set<String>();
		for ( O2_Franchisee__c o2Franchisee : o2FranchiseeList ) {
			torexCodeList.add(o2Franchisee.Torex_Code__c);
		}
	    
	    
		Map<Id,Id> accountParentMap = new Map<Id,Id>();
		Map<String,Id> torexAccountMap = new Map<String,Id>();
	    for ( Account acc : [
	                    select  Id, ParentId, Torex_Code__c //, Name
	                            , Parent.Id, Parent.ParentId //, Parent.Name
	                            , Parent.Parent.Id, Parent.Parent.ParentId //, Parent.Parent.Name
	                            , Parent.Parent.Parent.Id, Parent.Parent.Parent.ParentId //, Parent.Parent.Parent.Name
	                    from    Account
	                    where   Torex_Code__c in :torexCodeList
		]) {
			BuildAccountParentMap(acc, accountParentMap);
			torexAccountMap.put(acc.Torex_Code__c, acc.Id);
	    }
		torexCodeList.clear(); // no longer needed
	    
	    
	    Map<Id,Id> accountUserRoleMap = new Map<Id,Id>();
	    for ( UserRole ur : [
								select  Id, PortalAccountId
								from    UserRole
								where   PortalType = 'Partner'
								and     PortalRole = 'Executive'
								and     PortalAccountId in :accountParentMap.keySet()
	    ]) {
	    	accountUserRoleMap.put(ur.PortalAccountId, ur.Id);
	    }
	    
	    
	    Map<Id,Id> userRoleGroupMap = new Map<Id,Id>();
	    for ( Group gr : [
							select  Id, RelatedId
							from    Group
							where   Type = 'RoleAndSubordinates'
							and     RelatedId in :accountUserRoleMap.values()
	    ]) {
	    	userRoleGroupMap.put(gr.RelatedId, gr.Id);
	    }
	    
	    
	    
	    
	    Id baseAccountId;
	    List<O2_Franchisee__Share> shareList = new List<O2_Franchisee__Share>();
	    for ( O2_Franchisee__c o2Franchisee : o2FranchiseeList ) {
			
			baseAccountId = torexAccountMap.get(o2Franchisee.Torex_Code__c);
			BuildFranchiseeShareList(o2Franchisee, baseAccountId, accountParentMap, accountUserRoleMap, userRoleGroupMap, shareList);
			
		}
		if ( ! shareList.isEmpty() )
			insert shareList;


	}


	private static void BuildFranchiseeShareList (O2_Franchisee__c o2Franchisee, Id accountId, Map<Id,Id> accountParentMap, Map<Id,Id> accountUserRoleMap, Map<Id,Id> userRoleGroupMap, List<O2_Franchisee__Share> shareList) {
		if ( accountId == null )
			return;
		Id userRoleId = accountUserRoleMap.get(accountId);
		if ( userRoleId == null )
			return;
		Id groupId = userRoleGroupMap.get(userRoleId);
		if ( groupId == null )
			return;
		
	    O2_Franchisee__Share share = new O2_Franchisee__Share (
											UserOrGroupId = groupId,
											RowCause = 'Manual',
											ParentId = o2Franchisee.Id,
											AccessLevel = 'Read'
										 );
		shareList.add(share);
		
		// call for as many parent account levels as we have from the soql
	    Id parentAccountId = accountParentMap.get(accountId);
		BuildFranchiseeShareList(o2Franchisee, parentAccountId, accountParentMap, accountUserRoleMap, userRoleGroupMap, shareList);
	}


	private static void BuildAccountParentMap (Account acc, Map<Id,Id> accountParentMap) {
		if ( acc == null )
			return;
		accountParentMap.put(acc.Id, acc.ParentId);
		BuildAccountParentMap(acc.Parent, accountParentMap);
	}

}