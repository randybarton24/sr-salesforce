public class UsersSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			User.Id,
			User.Approval_Exempt__c,
			User.AtPipelineLimit__c,
			User.AtStagingLimit__c,
			User.Email,
			User.FirstName,
			User.LastName,
			User.Limit_Pipeline_Opps__c,
			User.Limit_Staging_Opps__c,
			User.ManagerId,
			User.Name,
			User.Number_of_Pipeline_Opps__c,
			User.Number_of_Staging_Opps__c,
			User.Sub_Team__c,
			User.UserRoleId };
	}

	public Schema.SObjectType getSObjectType()
	{
		return User.SObjectType;
	}

	public static UsersSelector newInstance()
	{
		return (UsersSelector) Application.Selector.newInstance(User.SObjectType);
	}

	public User[] selectOwnersByOpportunity(Opportunity[] opportunities)
	{
		Set<Id> ids = new Set<Id>();

		for(Opportunity opportunity : opportunities)
		{
			ids.add(opportunity.OwnerId);
		}

		fflib_QueryFactory userQueryFactory = newQueryFactory();

		return (User[]) Database.query(
			userQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public User[] selectActiveWithSubTeam()
	{
		fflib_QueryFactory userQueryFactory = newQueryFactory();

		return (User[]) Database.query(
			userQueryFactory
				.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('Sub_Team__c != null and IsActive = true')
				.toSOQL());
	}
}