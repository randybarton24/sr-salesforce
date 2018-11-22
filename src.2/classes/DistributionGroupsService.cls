public class DistributionGroupsService
{
	public static Map<Id, RoundRobin[]> groupToMembers;
	
	public static User getNextUserId(Distribution_Group_Member__c[] distGroupMembers, Id selectedDistGroup, fflib_SObjectUnitOfWork uow)
	{
		User results;
		Boolean beginAgain = false;
		
		for(Distribution_Group_Member__c distGroupMember : distGroupMembers)
		{
			if(distGroupMember.Next_Up__c && selectedDistGroup == distGroupMember.Distribution_Group__c)
			{
				results = new User(Id = distGroupMember.User__c,
						FirstName = distGroupMember.User__r.FirstName,
						LastName = distGroupMember.User__r.LastName,
						AboutMe = 'Assigned to the next user in the Distribution Group');
				selectedDistGroup = null;
				distGroupMember.Next_Up__c = false;
				uow.registerDirty(distGroupMember);
				beginAgain = true;
			}
			else if(selectedDistGroup != distGroupMember.Distribution_Group__c &&
					!distGroupMember.User__r.AtPipelineLimit__c &&
					!distGroupMember.Next_Up__c)
			{
				distGroupMember.Next_Up__c = true;
				beginAgain = false;
				uow.registerDirty(distGroupMember);
				break;
			}
		}
		if(beginAgain && !distGroupMembers.isEmpty())
		{
			for(Distribution_Group_Member__c distGroupMember : distGroupMembers)
			{
				if(selectedDistGroup != distGroupMember.Distribution_Group__c &&
						!distGroupMember.User__r.AtPipelineLimit__c &&
						!distGroupMember.Next_Up__c)
				{
					distGroupMember.Next_Up__c = true;
					beginAgain = false;
					uow.registerDirty(distGroupMember);
					break;
				}
			}
		}
		return results;
	}
	
	//Load Balanced
	public static User getNextUserId(Distribution_Group__c distGroup, fflib_SObjectUnitOfWork uow)
	{
		if(distGroup.Distribution_Type__c != 'Load Balanced')
		{
			Distribution_Group_Member__c[] distGroupMembers = distGroup.Distribution_Group_Members__r;
			User results = getNextUserId(distGroupMembers, distGroup.Id, uow);
			return results;
		}
		
		if(groupToMembers == null) groupToMembers = new Map<Id, RoundRobin[]>();
		
		if (!groupToMembers.containsKey(distGroup.Id)) groupToMembers.put(distGroup.Id, getRoundRobins(distGroup.Distribution_Group_Members__r,distGroup));
		
		groupToMembers.get(distGroup.Id).sort();
		
		User results = new User(Id = groupToMembers.get(distGroup.Id)[0].userId,
				AboutMe = 'Open Objects: ' + groupToMembers.get(distGroup.Id)[0].openObjects + ', Limit: ' + groupToMembers.get(distGroup.Id)[0].objectLimit + ', Load: ' + groupToMembers.get(distGroup.Id)[0].load);
		
		groupToMembers.get(distGroup.Id)[0].openObjects += 1;
		groupToMembers.get(distGroup.Id)[0].load = (groupToMembers.get(distGroup.Id)[0].openObjects / groupToMembers.get(distGroup.Id)[0].objectLimit) * 100;
		
		updateMembers(groupToMembers, uow);
		
		return results;
	}
	
	public static void resetNextUserAtLimit(fflib_SObjectUnitOfWork uow)
	{
		Distribution_Group__c[] distGroups = ([SELECT Id, Name, Open_Opportunity_Setting__c,
		(SELECT Id, Name, User__c, User__r.Name, User__r.FirstName, User__r.LastName,
				Available__c, Next_Up__c, Distribution_Group__c, User__r.AtPipelineLimit__c
		FROM Distribution_Group_Members__r
		WHERE Available__c = true
		AND User__r.IsActive = true
		ORDER BY User__r.LastName ASC)
		FROM Distribution_Group__c WHERE Id IN
		(SELECT Distribution_Group__c
		FROM Distribution_Group_Member__c
		WHERE User__r.AtPipelineLimit__c = true
		AND Next_Up__c = true)]);
		
		for(Distribution_Group__c distGroup : distGroups)
		{
			DistributionGroupsService.getNextUserId(distGroup.Distribution_Group_Members__r, distGroup.Id, uow);
		}
	}
	
	public static RoundRobin[] getRoundRobins(Distribution_Group_Member__c[] members, Distribution_Group__c distGroup)
	{
		Set<Id> ids = new Set<Id>();
		for(Distribution_Group_Member__c gm : members)
		{
			ids.add(gm.User__c);
		}
		String parentObject = distGroup.ParentObject__c;
		String fieldToDistribute = distGroup.Field_to_Distribute__c == null ? 'OwnerId' : distGroup.Field_to_Distribute__c;
		String whereClause = distGroup.Relationship_Criteria__c == null ? 'WHERE ' + fieldToDistribute + ' IN :ids' :
				'WHERE ' + distGroup.Relationship_Criteria__c + ' AND ' + fieldToDistribute + ' IN :ids';
		String queryString = 'SELECT ' + fieldToDistribute + ', count(Id) open FROM ' + parentObject + ' ' + whereClause + ' GROUP BY ' + fieldToDistribute ;
		System.debug('QueryString: ' + queryString);
		List<AggregateResult> objectList = Database.query(queryString);
		Map<Id,Integer> repToCount = new Map<Id,Integer>();
		for( AggregateResult ar : objectList)
		{
			repToCount.put((Id)ar.get(fieldToDistribute), (Integer)ar.get('open'));
		}
		
		RoundRobin[] roundRobinList = new List<RoundRobin>();
		for(Distribution_Group_Member__c member : members)
		{
			roundRobinList.add(new RoundRobin(member,repToCount.containsKey(member.User__c) ? repToCount.get(member.User__c) : 0));
		}
		
		return roundRobinList;
	}
	
	public static void updateMembers(Map<Id,List<RoundRobin>> groupToMembers, fflib_SObjectUnitOfWork uow)
	{
		Distribution_Group_Member__c[] allMembers = new List<Distribution_Group_Member__c>();
		
		for(List<RoundRobin> roundRobins : groupToMembers.values())
		{
			for(RoundRobin r : roundRobins)
			{
				Distribution_Group_Member__c member = new Distribution_Group_Member__c();
				member.Id = r.groupMember.Id;
				member.Total_Open__c = r.openObjects;
				allMembers.add(member);
			}
		}
		
		uow.registerDirty(allMembers);
	}
	
	public static void updateOpenCount(Id userID, Distribution_Group__c distGroup, fflib_SObjectUnitOfWork uow)
	{
		if(groupToMembers == null) groupToMembers = new Map<Id, RoundRobin[]>();
		
		if (!groupToMembers.containsKey(distGroup.Id)) groupToMembers.put(distGroup.Id, getRoundRobins(distGroup.Distribution_Group_Members__r,distGroup));
		
		for(RoundRobin member : groupToMembers.get(distGroup.Id))
		{
			if(member.userId == userId)
			{
				member.openObjects += 1;
				member.load = (member.openObjects / member.objectLimit) * 100;
				updateMembers(groupToMembers, uow);
				return;
			}
		}
		
		updateMembers(groupToMembers, uow);
	}
	
	public static void createHistory(Distribution_Group__c distGroup, User user, Case c, fflib_SObjectUnitOfWork uow)
	{
		Distribution_Group_History__c history = new Distribution_Group_History__c(Name = distGroup.Name + String.valueOf(Datetime.now()),
				Description__c = user.AboutMe,
				Distribution_Group__c = distGroup.Id,
				User__c = user.Id);
		uow.registerNew(history);
		uow.registerRelationship(history,Schema.Distribution_Group_History__c.Case__c,c);
	}
	
	
	
	
	public class RoundRobin implements Comparable
	{
		public RoundRobin(Distribution_Group_Member__c groupMember, Integer open)
		{
			this.groupMember = groupMember;
			this.openObjects = open;
			this.objectLimit = groupMember.Rep_Limit__c;
			this.load = (open / groupMember.Rep_Limit__c) * 100;
			this.userId = groupMember.User__c;
		}
		
		public Integer compareTo(Object compareTo)
		{
			return Integer.valueOf(load - ((RoundRobin) compareTo).load);
		}
		
		public Distribution_Group_Member__c groupMember;
		public Decimal openObjects;
		public Decimal objectLimit;
		public Decimal load;
		public Id userId;
	}
}