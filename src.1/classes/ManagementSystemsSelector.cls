public class ManagementSystemsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Management_System__c.Id,
			Management_System__c.Limelight_Available__c,
			Management_System__c.Name,
			Management_System__c.Sales_Engineer_Call_Needed__c,
			Management_System__c.Version__c
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Management_System__c.SObjectType;
	}

	public static ManagementSystemsSelector newInstance()
	{
		return (ManagementSystemsSelector) Application.Selector.newInstance(Management_System__c.SObjectType);
	}

	public Map<String, Id> selectNameToIdMap()
	{
		Map<String, Id> results = new Map<String, Id>();

		fflib_QueryFactory managementSystemQueryFactory = newQueryFactory();

		Management_System__c[] allPms = Database.query(
			managementSystemQueryFactory
			.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
			.addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
			.toSOQL());

		for(Management_System__c pm : allPms)
		{
			results.put(pm.Name, pm.Id);
		}

		return results;
	}

	public List<Management_System__c> selectNonBlacklistedManagementSystems()
	{
		fflib_QueryFactory managementSystemQueryFactory = newQueryFactory();

		return (Management_System__c[]) Database.query(
				managementSystemQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('SYNC_Availability__c != \'Blacklist - DO NOT SELL\'').toSOQL());
	}

}