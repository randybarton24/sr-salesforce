public class OpportunityContactRolesSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			OpportunityContactRole.Id,
			OpportunityContactRole.ContactId,
			OpportunityContactRole.CreatedDate,
			OpportunityContactRole.OpportunityId,
			OpportunityContactRole.Role
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return OpportunityContactRole.SObjectType;
	}

	public static OpportunityContactRolesSelector newInstance()
	{
		return (OpportunityContactRolesSelector) Application.Selector.newInstance(OpportunityContactRole.SObjectType);
	}

	public Map<String, OpportunityContactRole> selectRoleMapByOpportunityIdWithContact(Set<Id> ids)
	{
		Map<String, OpportunityContactRole> results = new Map<String, OpportunityContactRole>();

		fflib_QueryFactory oppContactRolesQueryFactory = newQueryFactory();

		new ContactsSelector().configureQueryFactoryFields(oppContactRolesQueryFactory, 'Contact');

		OpportunityContactRole[] ocrs = (OpportunityContactRole[]) Database.query(
			oppContactRolesQueryFactory
			.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
			.setCondition('OpportunityId IN :ids')
			.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING)
			.toSOQL());

		for(OpportunityContactRole ocr : ocrs)
		{
			if(!results.containsKey(ocr.Role) || results.get(ocr.Role).CreatedDate < ocr.CreatedDate) results.put(ocr.Role, ocr);
		}

		return results;
	}
}