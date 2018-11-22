public class PricebooksSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Pricebook2.Id,
			Pricebook2.AppAdmin_Plan_Name__c,
			Pricebook2.Contract_Start_Date_Offset__c,
			Pricebook2.Default_Term__c,
			Pricebook2.IsActive,
			Pricebook2.Name,
			Pricebook2.Number_of_Providers_Included__c,
			Pricebook2.Number_of_PRT_Included__c };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Pricebook2.SObjectType;
	}

	public static PricebooksSelector newInstance()
	{
		return (PricebooksSelector) Application.Selector.newInstance(Pricebook2.SObjectType);
	}

	public Pricebook2[] selectAllWithPricebookEntries()
	{
		fflib_QueryFactory pricebookQueryFactory = newQueryFactory();

		fflib_QueryFactory pricebookEntryQueryFactory = pricebookQueryFactory.subselectQuery('PricebookEntries')
        	.selectFields(new PricebookEntriesSelector().getSObjectFieldList());

		new ProductsSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Product2');

		new PricebooksSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Pricebook2');

		return (Pricebook2[]) Database.query(
			pricebookQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).toSOQL());
	} 

	public Pricebook2[] selectAllActiveWithPricebookEntries()
	{
		fflib_QueryFactory pricebookQueryFactory = newQueryFactory();

		fflib_QueryFactory pricebookEntryQueryFactory = pricebookQueryFactory.subselectQuery('PricebookEntries')
        	.selectFields(new PricebookEntriesSelector().getSObjectFieldList());

		new ProductsSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Product2');

		new PricebooksSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Pricebook2');

		return (Pricebook2[]) Database.query(
			pricebookQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('IsActive = TRUE').toSOQL());
	}

	public Pricebook2[] selectByIdWithPricebookEntries(Set<Id> ids)
	{
		fflib_QueryFactory pricebookQueryFactory = newQueryFactory();

		fflib_QueryFactory pricebookEntryQueryFactory = pricebookQueryFactory.subselectQuery('PricebookEntries')
        	.selectFields(new PricebookEntriesSelector().getSObjectFieldList());

		new ProductsSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Product2');

		new PricebooksSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Pricebook2');

		return (Pricebook2[]) Database.query(
			pricebookQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Pricebook2[] selectByTypeWithPricebookEntries(Set<String> type)
	{
		fflib_QueryFactory pricebookQueryFactory = newQueryFactory();

		fflib_QueryFactory pricebookEntryQueryFactory = pricebookQueryFactory.subselectQuery('PricebookEntries')
        	.selectFields(new PricebookEntriesSelector().getSObjectFieldList()).addOrdering('Product2.Family',fflib_QueryFactory.SortOrder.DESCENDING, true);

		new ProductsSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Product2');

		new PricebooksSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Pricebook2');

		return (Pricebook2[]) Database.query(
			pricebookQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Type__c IN :type').toSOQL());
	}

	public Pricebook2[] selectByNameWithPricebookEntries(Set<String> names)
	{
		fflib_QueryFactory pricebookQueryFactory = newQueryFactory();

		fflib_QueryFactory pricebookEntryQueryFactory = pricebookQueryFactory.subselectQuery('PricebookEntries')
        	.selectFields(new PricebookEntriesSelector().getSObjectFieldList());

		new ProductsSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Product2');

		new PricebooksSelector().configureQueryFactoryFields(pricebookEntryQueryFactory, 'Pricebook2');

		return (Pricebook2[]) Database.query(
			pricebookQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Name IN :names').toSOQL());
	}
}