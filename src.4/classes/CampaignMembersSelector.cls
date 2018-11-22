public class CampaignMembersSelector extends fflib_SObjectSelector 
{

	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			CampaignMember.Id,
        	CampaignMember.CreatedDate
        };
	}


	public Schema.SObjectType getSObjectType()
	{
		return CampaignMember.SObjectType;
	}

	public static CampaignMembersSelector newInstance()
	{
		return (CampaignMembersSelector) Application.Selector.newInstance(CampaignMember.SObjectType);
	}

	public Database.QueryLocator queryLocatorCampaignMemberWithoutCI(String dateRange)
	{
		fflib_QueryFactory campaignMemberQueryFactory = newQueryFactory();
		
		return Database.getQueryLocator(
			campaignMemberQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).
				setCondition('CreatedDate = ' + dateRange).
				toSOQL());
	}
}