public class CampaignsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Campaign.Id,
			Campaign.Sub_Type__c, 
        	Campaign.Type
        };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Campaign.SObjectType;
	}

	public static CampaignsSelector newInstance()
	{
		return (CampaignsSelector) Application.Selector.newInstance(Campaign.SObjectType);
	}
}