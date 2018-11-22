public class CampaignInfluencesSelector extends fflib_SObjectSelector 
{

	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Campaign_Influence__c.Id,
			Campaign_Influence__c.Account__c, 
        	Campaign_Influence__c.Campaign__c,
        	Campaign_Influence__c.Campaign_Add_Date__c,
        	Campaign_Influence__c.Contact__c, 
        	Campaign_Influence__c.CreatedDate,
        	Campaign_Influence__c.CreatedFromId__c,
        	Campaign_Influence__c.Demo_Request_Reason__c,
			Campaign_Influence__c.Lead__c, 
        	Campaign_Influence__c.Name, 
        	Campaign_Influence__c.Opportunity__c, 
        	Campaign_Influence__c.Orphaned__c,
        	Campaign_Influence__c.Orphaned_Date__c,
        	Campaign_Influence__c.Source_User__c
        };
	}


	public Schema.SObjectType getSObjectType()
	{
		return Campaign_Influence__c.SObjectType;
	}

	public static CampaignInfluencesSelector newInstance()
	{
		return (CampaignInfluencesSelector) Application.Selector.newInstance(Campaign_Influence__c.SObjectType);
	}

	public override String getOrderBy()
	{
		return 'Campaign_Add_Date__c DESC';
	}

	public Campaign_Influence__c[] selectCisByCreatedById(Set<Id> createdByIds)
	{
		fflib_QueryFactory campaignInfluenceQueryFactory = newQueryFactory();

		return (Campaign_Influence__c[]) Database.query(
			campaignInfluenceQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('CreatedFromId__c IN :createdByIds')
				.toSOQL());
	}

	public Campaign_Influence__c[] selectByIdWithManagerAndVP(Set<Id> ids)
	{
		fflib_QueryFactory campaignInfluenceQueryFactory = newQueryFactory();

		new UsersSelector().configureQueryFactoryFields(campaignInfluenceQueryFactory, 'Source_User__r');

		new UsersSelector().configureQueryFactoryFields(campaignInfluenceQueryFactory, 'Source_User__r.Manager');

		return (Campaign_Influence__c[]) Database.query(
			campaignInfluenceQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Campaign_Influence__c[] selectCisByAccountId(Set<Id> ids)
	{
		fflib_QueryFactory campaignInfluenceQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(campaignInfluenceQueryFactory, 'Account__r');

		new CampaignsSelector().configureQueryFactoryFields(campaignInfluenceQueryFactory, 'Campaign__r');

		new OpportunitiesSelector().configureQueryFactoryFields(campaignInfluenceQueryFactory, 'Account__r.Active_Opportunity__r');

		return (Campaign_Influence__c[]) Database.query(
			campaignInfluenceQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('Account__c IN :ids')
				.toSOQL());
	}

	public Database.QueryLocator queryLocatorContactCIWithoutAccount()
	{
		fflib_QueryFactory campaignInfluenceQueryFactory = newQueryFactory();
		
		new AccountsSelector().configureQueryFactoryFields(campaignInfluenceQueryFactory, 'Account__r');
		
		new ContactsSelector().configureQueryFactoryFields(campaignInfluenceQueryFactory, 'Contact__r');
		
		return Database.getQueryLocator(
			campaignInfluenceQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).
				setCondition('Contact__c != null AND Contact__r.AccountId != null AND Account__c = null').
				toSOQL());
	}
}