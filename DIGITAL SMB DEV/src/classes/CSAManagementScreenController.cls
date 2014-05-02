public without sharing class CSAManagementScreenController {

	public Id teamId {get; set;}
	public Id newTeamId {get; set;}
	public Id CSAId {get; set;}
	public Boolean showAll {get; set;}
	//public Contact accountLookup {get; set;}
	public CSA_Routing__c accountLookup1 {get; set;}
	public Map<Id,teamContent> CSATeams;
	public List<CSA_Account_Preference__c> accountList {get; private set;}
	public String topMessage {get; set;}
	public String bottomMessage {get; set;}
	public Boolean removedAccounts {get; set;}

	public CSAManagementScreenController()
	{
		showAll = false;
		removedAccounts = false;
		accountLookup1 = new CSA_Routing__c();
		init();
	}

	public void init()
	{
		// get queues that support routing
		List<Group> teams = new List<Group>();
		Set<id> Ids = new Set<id>();
		for(QueueSobject qs : [select Queue.Id, Queue.Name from queueSObject where sObjectType = 'CSA_Routing__c'])
		{
			Ids.add(qs.QueueId);
			teams.add(qs.Queue);
		}

		//get members
		Map<Id,List<Id>> membership = new Map<Id,List<Id>>();
		for(GroupMember gm : [select id, userOrGroupId, GroupId	from GroupMember where GroupId in :Ids])
		{
			if(((String) gm.UserOrGroupId).substring(0,3) == '005')		// if record is user
			{
				if(!membership.containsKey(gm.GroupId))
				{
					membership.put(gm.GroupId,new List<Id>());		// will only create entry if team has members
				}
				membership.get(gm.GroupId).add(gm.userOrGroupId);
				Ids.add(gm.userOrGroupId);
			}
		}
		Map<Id,User> csas = new Map<Id,User>([select id, Name, CSA_Available__c, isActive from User where isActive = true and Id in :Ids]);

		// create ful map
		CSATeams = new Map<Id,teamContent>();
		for(Group t : teams)
		{
			if(membership.containsKey(t.Id))
			{
				List<User> Users = new List<User>();
				List<Id> userIds = membership.get(t.id);
				for(Id uid : userIds)
				{
					if(csas.containsKey(uid)) users.add(csas.get(uid));
				}
				CSATeams.put(t.id,new teamContent(t,users));
			}
			else
			{
				CSATeams.put(t.id,new teamContent(t));
			}
		}
	}

	public List<selectOption> getTeamOptions()
	{
		List<selectOption> options = new List<selectOption>{new selectOption('','--select team--')};
		List<teamContent> tcs = CSATeams.values();
		for(teamContent tc : tcs) options.add(new selectOption(tc.team.id,tc.team.Name));
		return options;
	}

	public List<selectOption> getCSAOptions()
	{
		List<selectOption> options = new List<selectOption>{new selectOption('','--select CSA--')};
		List<User> usrs = showAll ? CSATeams.get(teamId).getAllUserList() : CSATeams.get(teamId).getAvailableUserList();
		for(User usr : usrs) options.add(new selectOption(usr.id,(showAll && !usr.CSA_Available__c? '- ' : '') + usr.Name));
		return options;
	}

	public List<selectOption> getNewTeamOptions()
	{
		List<selectOption> options = new List<selectOption>{new selectOption('','--select team--')};
		List<teamContent> tcs = CSATeams.values();
		for(teamContent tc : tcs) if(tc.team.id != teamId) options.add(new selectOption(tc.team.id,tc.team.Name));
		return options;
	}

	public void resetTeam()
	{
		bottomMessage = null;
		topMessage = null;
		CSAId = null;
		showAll = false;
		resetCsa();
	}

	public void resetCSA()
	{
		bottomMessage = null;
		topMessage = null;
		accountLookup1 = new CSA_Routing__c();
		findAccounts();
		newTeamId = null;
		removedAccounts = false;
	}

	public void resetShowAll()
	{
		CSAId = null;
		resetCSA();
	}

	public void addAccount()
	{
		bottomMessage = null;
		if(accountLookup1.Enterprise_Account__c != null)
		{
			if([select count() from CSA_Account_Preference__c where CSA__c = :CsaId and Account__c = :accountLookup1.Enterprise_Account__c] == 0)
			{
				CSA_Account_Preference__c cap = new CSA_Account_Preference__c(CSA__c = CsaId, Account__c = accountLookup1.Enterprise_Account__c);
				insert cap;
				bottomMessage = '<font color="green">CSA is now preferred for this account.</font>';
			}
			else
			{
				bottomMessage = '<font color="red">CSA is already preferred for this account.</font>';
			}
		}
		accountLookup1 = new CSA_Routing__c();
		findAccounts();
	}

	public void removeAccount()
	{
		bottomMessage = null;
		if(accountLookup1.Enterprise_Account__c != null)
		{
			List<CSA_Account_Preference__c> prefs = [select id from CSA_Account_Preference__c where CSA__c = :CsaId and Account__c = :accountLookup1.Enterprise_Account__c];
			if(!prefs.isEmpty())
			{
				delete prefs;
				bottomMessage = '<font color="green">Account removed from CSA preference.</font>';
			}
			else
			{
				bottomMessage = '<font color="red">Account not associated with CSA.</font>';
			}
		}
		accountLookup1 = new CSA_Routing__c();
		findAccounts();
	}

	public void findAccounts()
	{
		if(CSAId != null)
		{
			accountList = [select Account__c, Account__r.Name, CSA__c from CSA_Account_Preference__c where CSA__c = :CSAId order by Account__r.Name];
		}
	}

	public pageReference switchTeams()
	{
		try
		{
			topMessage = null;
			if(newTeamId != null && removedAccounts)
			{
				List<GroupMember> gms = [select id from GroupMember where GroupId = :teamId and UserorGroupId = :CSAId];
				delete gms;

				GroupMember gm = new GroupMember(GroupId = newTeamId, UserorGroupId = CSAId);
				insert gm;

				String CSAname = CSATeams.get(teamId).CSAs.get(CSAId).Name;
				String oldTeam = CSATeams.get(teamId).team.Name;
				String newTeam = CSATeams.get(newTeamId).team.Name;
				teamId = null;
				resetTeam();
				init();
				topMessage = '<font color="green">CSA <b>' + CSAname + '</b> moved from <b>' + oldTeam + '</b> to <b>' + newTeam +'</b>.</font>';
			}
		}
		catch(exception e)
		{
			topMessage = '<font color="red">Operation failed. Reason: ' + e.getMessage() + '</font>';
		}
		return null;
	}

	public void removeAccountPreference()
	{
		List<CSA_Account_Preference__c> caps = [select id from CSA_Account_Preference__c where CSA__c = :CSAId];
		if(!caps.isEmpty()) database.delete(caps);
		removedAccounts = true;
	}




	public class teamContent
	{
		public Group team {get; set;}
		public Map<Id,User> CSAs {get; set;}

		public teamContent(Group team)
		{
			this.team = team;
			CSAs = new Map<Id,User>();
		}
		public teamContent(Group team, List<User> Users)
		{
			this.team = team;
			CSAs = Users.isEmpty() ? new Map<Id,User>() : new Map<Id,User>(Users);
		}

		public List<User> getAllUserList()
		{
			return CSAs.values();
		}
		public List<User> getAvailableUserList()
		{
			List<User> users = CSAs.values();
			List<User> usersRet = new List<User>();
			for(User u : users)
			{
				if(u.CSA_Available__c) usersRet.add(u);
			}
			return usersRet;
		}
	}

}