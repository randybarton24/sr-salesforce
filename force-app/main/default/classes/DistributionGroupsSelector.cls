public class DistributionGroupsSelector extends fflib_SObjectSelector
{
	public static Map<Id, Id> distributionQueue;
	
	public Schema.SObjectField[] getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				Distribution_Group__c.Id,
				Distribution_Group__c.Name,
				Distribution_Group__c.Open_Opportunity_Setting__c,
				Distribution_Group__c.CampaignId__c,
				Distribution_Group__c.Customer_Setting__c,
				Distribution_Group__c.Distribution_Type__c,
				Distribution_Group__c.Field_to_Distribute__c,
				Distribution_Group__c.ParentObject__c,
				Distribution_Group__c.Relationship_Criteria__c,
				Distribution_Group__c.Relationship_Criteria_Fields__c,
				Distribution_Group__c.Timed_Distribution_Group_Hours__c,
				Distribution_Group__c.Major_Accounts__c
		};
	}
	
	public Schema.SObjectType getSObjectType()
	{
		return Distribution_Group__c.SObjectType;
	}
	
	public static DistributionGroupsSelector newInstance()
	{
		return (DistributionGroupsSelector) Application.Selector.newInstance(Distribution_Group__c.SObjectType);
	}
	
	public Distribution_Group__c[] selectById(Set<Id> ids)
	{
		fflib_QueryFactory distGroupQueryFactory = newQueryFactory();
		
		fflib_QueryFactory distGroupMemberQueryFactory = distGroupQueryFactory.subselectQuery('Distribution_Group_Members__r')
				.selectFields(new DistributionGroupMembersSelector().getSObjectFieldList()).setCondition('Available__c = true and User__r.AtPipelineLimit__c = false and User__r.IsActive = true');
		
		new UsersSelector().configureQueryFactoryFields(distGroupMemberQueryFactory, 'User__r');
		
		return (Distribution_Group__c[]) Database.query(
				distGroupQueryFactory
						.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
						.setCondition('Id IN :ids')
						.toSOQL());
	}
	
	public Distribution_Group__c selectById(Id id)
	{
		fflib_QueryFactory distGroupQueryFactory = newQueryFactory();
		
		fflib_QueryFactory distGroupMemberQueryFactory = distGroupQueryFactory.subselectQuery('Distribution_Group_Members__r')
				.selectFields(new DistributionGroupMembersSelector().getSObjectFieldList()).setCondition('Available__c = true and User__r.IsActive = true');
		
		new UsersSelector().configureQueryFactoryFields(distGroupMemberQueryFactory, 'User__r');
		
		return (Distribution_Group__c) Database.query(
				distGroupQueryFactory
						.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
						.setCondition('Id = :id')
						.toSOQL());
	}
	
	public static Map<Id,Id> getQueueDistributionMap()
	{
		distributionQueue = new Map <Id, Id>();
		for (Distribution_Group__c dg : [SELECT Id, Queue_Id__c FROM Distribution_Group__c WHERE Queue_Id__c != '' AND Active__c = true])
		{
			distributionQueue.put((Id)dg.Queue_Id__c, dg.Id);
		}
		return distributionQueue;
	}
}