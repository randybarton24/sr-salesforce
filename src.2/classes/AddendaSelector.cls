public class AddendaSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Addendum__c.Id,
			Addendum__c.Account__c,
			Addendum__c.Contract_Term_Months__c,
			Addendum__c.CreatedById,
			Addendum__c.Name,
			Addendum__c.New_Subscription_Needed__c,
			Addendum__c.OwnerId,
			Addendum__c.Price_Book__c,
			Addendum__c.Status__c,
			Addendum__c.Status_Message__c,
			Addendum__c.Subscriber_ID__c		
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Addendum__c.SObjectType;
	}

	public static AddendaSelector newInstance()
	{
		return (AddendaSelector) Application.Selector.newInstance(Addendum__c.SObjectType);
	}

	public Addendum__c[] selectByIdWithAddendumLineItems(Set<Id> ids)
	{
		assertIsAccessible();

		fflib_QueryFactory addendumQueryFactory = newQueryFactory();

		fflib_QueryFactory addendumLineItemQueryFactory = new AddendumLineItemsSelector().addQueryFactorySubselect(addendumQueryFactory);

		new AssetsSelector().configureQueryFactoryFields(addendumLineItemQueryFactory, 'Asset__r');

		return (Addendum__c[]) Database.query(
			addendumQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 
}