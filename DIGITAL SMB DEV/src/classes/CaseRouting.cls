public without sharing class CaseRouting
{
	// all routing is done in a single function due to various arrays and maps used which would make it difficult to pass into other static methods
   
	public static void routeCases(List<Case> cases)
	{
		boolean doDebug = false;

		boolean noCSAsFound = false;

		Id defaultQueueId = null;

		try	// in case somebody forgot to set it up
		{
			defaultQueueId = System.Label.CSA_Default_Queue_Id;
		}
		catch(exception e) {}

		Map<Integer,Id> OwnerIdMap = new Map<Integer,Id>();		// map for cases and owners that satisfy entry criteria
		List<Id> accountIds = new List<Id>();					// pickup preferred CSAs for this account

		for(Integer i = 0; i < cases.size(); i++)
		{
			Case c = cases.get(i);
			
			system.debug('owner id is :' + c.OwnerId__c);
			system.debug('owner id is :' + c.OwnerId);
			
			
			if(c.Request_Sub_Type__c != null && c.OwnerId__c != null && ((String) c.OwnerId__c).substring(0,3).equals('00G'))
			{
				OwnerIdMap.put(i,c.OwnerId__c);		// remember by location in cases list since new cases will not have id
				if(c.AccountId != null) accountIds.add(c.AccountId);
				system.debug('owner id is :' + c.OwnerId__c);
				
			}
		}

		if(OwnerIdMap.isEmpty()) return;

		// gather neccessary data
		Map<Id,User> availableCSAs;
		Map<Id,Set<id>> teamMembers = new Map<Id,Set<id>>();		// since we search for CSA within assigned team, this is a quick way to find team members
		Map<Id,Set<id>> preferredCSAs = new Map<Id,Set<id>>();		// preffered CSAs per account
		{
			Set<Id> teamMembersList = new Set<Id>();

			// get queues that support routing
			Set<id> qIds = new Set<id>();
			for(QueueSobject qs : [select QueueId from queueSObject where sObjectType = 'CSA_Routing__c' and QueueId in :OwnerIdMap.values()])
			{
				qIds.add(qs.QueueId);
			}

			// remove un-routable queues
			Set<Integer> removeElements = new Set<Integer>();
			for(Integer i : OwnerIdMap.keySet())
			{
				if(!qIds.contains(OwnerIdMap.get(i)))
				{
					removeElements.add(i);
				}
			}
			for(Integer re : removeElements)
			{
				OwnerIdMap.remove(re);
			}

			// get ALL members of routable queues
			for(GroupMember gm : [select id, userOrGroupId, GroupId
									from GroupMember
									where GroupId in :qIds])
			{
				if(((String) gm.UserOrGroupId).substring(0,3) == '005')		// if record is user
				{
					teamMembersList.add(gm.UserOrGroupId);
					if(!teamMembers.containsKey(gm.GroupId))
					{
						teamMembers.put(gm.GroupId,new Set<id>());		// will only create entry if team has members
					}
					teamMembers.get(gm.GroupId).add(gm.UserOrGroupId);
				}
			}


			if(!teamMembersList.isEmpty())	// only if any members were found
			{
				// this is in a separate query because I cannot fetch parent data by using userOrGroupId because it's a dual lookup
				availableCSAs = new Map<Id,User>([select id, Name, (select Account__c, CSA__c from CSA_Account_Preferences__r where Account__c in :AccountIds)
													from User where isActive = true and CSA_Available__c = true and Id in :teamMembersList]);

				if(availableCSAs.isEmpty())
				{
					noCSAsFound = true;
				}
				else
				{
					// remove unavailable team members that we sorted into teams before
					for(Id k1 : teamMembers.keySet())
					{
						Set<Id> tmpTeam = new Set<Id>();
						tmpTeam.addAll(teamMembers.get(k1));
						Set<id> tmpSet = teamMembers.get(k1);
						for(Id k2 : tmpSet)
						{
							if(!availableCSAs.containsKey(k2))
							{
								tmpTeam.remove(k2);
							}
						}
						if(tmpTeam.isEmpty()) teamMembers.remove(k1);	// remove any teams which have no available members
						else teamMembers.put(k1,tmpTeam);
					}

					// sort preferred CSA per account
					for(User u : availableCSAs.values())
					{
						for(CSA_Account_Preference__c pref : u.CSA_Account_Preferences__r)	// account will be added only if any CSA from list are preffered for it
						{
							if(!preferredCSAs.containsKey(pref.Account__c))
							{
								preferredCSAs.put(pref.Account__c, new Set<Id>());
							}
							preferredCSAs.get(pref.Account__c).add(pref.CSA__c);
						}
					}
				}
			}
			else
			{
				noCSAsFound = true;
			}
		}

		Map<Id,Decimal> AvailableCSAWorkload = new Map<Id,Decimal>();
		List<Id> CSAsSortedByLoad = new List<Id>();		// a list of ids sorted by workload
		if(!noCSAsFound)
		{
			// find workload
			AggregateResult[] groupedResults = [select OwnerId, sum(CSA_Weighting__c) load
												from Case
												where OwnerId in :availableCSAs.keySet() and CSA_Weighting__c != null and isClosed = false
												group by OwnerId
												order by sum(CSA_Weighting__c) asc];
			for(AggregateResult ar : groupedResults)
			{
				AvailableCSAWorkload.put((Id) ar.get('OwnerId'),(Decimal) ar.get('load'));
				CSAsSortedByLoad.add((Id) ar.get('OwnerId'));
			}
			// if not all CSA covered by previous query
			if(AvailableCSAWorkload.size() < availableCSAs.size())
			{
				for(Id csaId : availableCSAs.keySet())	// put 0 load for any users not acounted for in previous query
				{
					if(!AvailableCSAWorkload.containsKey(csaId))
					{
						AvailableCSAWorkload.put(csaId,0);
						if(CSAsSortedByLoad.isEmpty()) CSAsSortedByLoad.add(csaId);
						else CSAsSortedByLoad.add(0,csaId);							// least loaded first
					}
				}
			}
			if(doDebug) system.debug(AvailableCSAWorkload);
			if(doDebug) system.debug(CSAsSortedByLoad);
		}

		// route cases
		for(Integer j = 0; j < cases.size(); j++)
		{
			Case c = cases.get(j);
			
           
			if(OwnerIdMap.containsKey(j))
			{
				if(noCSAsFound || !teamMembers.containsKey(OwnerIdMap.get(j)))	 // if you didn't find any available CSAs in general or if team is empty
				{
					c.OwnerId__c = defaultQueueId;
				}
				else
				{
					if(doDebug) system.debug('Processing Case: ');
					// find prefered

					Set<id> tms = new Set<Id>();
					tms.addAll(teamMembers.get(OwnerIdMap.get(j)));

					if(preferredCSAs.containsKey(c.AccountId))
					{
						tms.retainAll(preferredCSAs.get(c.AccountId));
						if(tms.isEmpty()) tms.addAll(teamMembers.get(OwnerIdMap.get(j)));	// if no preffered CSAs found in team
					}

					for(Id loadId : CSAsSortedByLoad)
					{
						if(tms.contains(loadId))
						{
							c.OwnerId__c = loadId;
							system.debug('owner id in routingis  :' + c.OwnerId__c);
							
							break;					// because ids are sorted according to load asc we are happy with the first result
						}
					}

					if(availableCSAs.containsKey(c.OwnerId__c))	// if you found a CSA, then increase workload
					{
						Decimal caseWeight = c.CSA_Weighting__c == null ? 0 : c.CSA_Weighting__c;
						if(doDebug) system.debug('Increase Load: '+c.OwnerId__c+': '+AvailableCSAWorkload.get(c.OwnerId__c)+' -> '+ (AvailableCSAWorkload.get(c.OwnerId__c) + caseWeight));
						AvailableCSAWorkload.put(c.OwnerId__c,AvailableCSAWorkload.get(c.OwnerId__c) + caseWeight);
						//resort list
						boolean foundFlag = false;
						for(Integer i = 0; i < CSAsSortedByLoad.size(); i++)
						{
							if(!foundFlag && CSAsSortedByLoad.get(i) == c.OwnerId__c)	// find location in list
							{
								foundFlag = true;
							}
							if(foundFlag)	// re-sort CSAsSortedByLoad - since workload has increased, id needs to be moved towards the "back"
							{
								if(i == CSAsSortedByLoad.size()-1)		// if last index no need to reorder
								{
									break;
								}

								Id id_i = CSAsSortedByLoad.get(i);
								Id id_i1 = CSAsSortedByLoad.get(i+1);
								if(AvailableCSAWorkload.get(id_i) > AvailableCSAWorkload.get(id_i1))	// switch values if true - simple sort
								{
									CSAsSortedByLoad.set(i,id_i1);
									CSAsSortedByLoad.set(i+1,id_i);
								}
								else		// if no more switches - break
								{
									break;
								}
							}
						}
						if(doDebug) system.debug(CSAsSortedByLoad);
					}
					else	// if no CSA found, use default queue
					{
						c.OwnerId__c = defaultQueueId;	// I'm pretty sure this line will never be reached, but I lose nothing by leaving it in :)
					}
				}
			}
		}

	}
	
	
	
	@future
    public static void modifyCaseOwner(Set<ID> caseIds){
        
        List<Case> cases = [Select Id, OwnerId, OwnerId__c from Case where Id IN :caseIds];
        for(Case c : cases){
            
            c.ownerId = c.ownerId__c;
        }
        
        RecursionPreventer.caseRoutingAlreadyFired =  true;
        Database.DMLOptions dmo = new Database.DMLOptions(); 
        dmo.EmailHeader.triggerUserEmail = false; 
        Database.update(cases, dmo); 
    }

}