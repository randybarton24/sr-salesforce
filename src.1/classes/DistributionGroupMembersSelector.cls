public class DistributionGroupMembersSelector extends fflib_SObjectSelector
{
	public Schema.SObjectField[] getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				Distribution_Group_Member__c.Id,
				Distribution_Group_Member__c.Name,
				Distribution_Group_Member__c.User__c,
				Distribution_Group_Member__c.Available__c,
				Distribution_Group_Member__c.Next_Up__c,
				Distribution_Group_Member__c.Load__c,
				Distribution_Group_Member__c.Rep_Limit__c,
				Distribution_Group_Member__c.Total_Open__c,
				Distribution_Group_Member__c.Distribution_Group__c
		};
	}
	
	public Schema.SObjectType getSObjectType()
	{
		return Distribution_Group_Member__c.SObjectType;
	}
	
	public static DistributionGroupMembersSelector newInstance()
	{
		return (DistributionGroupMembersSelector) Application.Selector.newInstance(Distribution_Group_Member__c.SObjectType);
	}
}