public class SalesTargets extends fflib_SObjectDomain 
{
	public Map<Id, User> userMap;
	
	public SalesTargets(Sales_Target__c[] salesTargets) 
	{
		super(salesTargets);
		Configuration.disableTriggerCRUDSecurity();
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new SalesTargets(sObjectList);
		}
	}

	public override	void onBeforeInsert()
	{
		for(Sales_Target__c st : (Sales_Target__c[]) Records) 
		{
			this.setSubTeam(st);
		}
	}

	public override void onAfterInsert()
	{
		Bonus_Commission__c[] newBCs = new List<Bonus_Commission__c>();

		for(Sales_Target__c t : (Sales_Target__c[]) Records) 
		{
			Bonus_Commission__c bc = new Bonus_Commission__c(Sales_Target__c = t.Id,
				OwnerId = t.OwnerId);
			newBCs.add(bc);
		}

		insert newBCs;
	}

	public override	void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		SalesTargetsService.calculateMultiplier((Sales_Target__c[]) Records);
	}

	public void setSubTeam(Sales_Target__c st)
	{
		if(userMap == null) userMap = new Map<Id, User>(UsersSelector.newInstance().selectActiveWithSubTeam());
		if(!userMap.containsKey(st.OwnerId)) return;
		st.Sub_Team__c = userMap.get(st.OwnerId).Sub_Team__c;
	}
}