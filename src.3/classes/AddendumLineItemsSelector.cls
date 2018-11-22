public class AddendumLineItemsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Addendum_Line_Item__c.Id,
			Addendum_Line_Item__c.Addendum__c,
			Addendum_Line_Item__c.Asset__c,
			Addendum_Line_Item__c.Asset_Type__c,
			Addendum_Line_Item__c.Change_MSF__c,
			Addendum_Line_Item__c.CreatedById,
			Addendum_Line_Item__c.Current_Next_Invoice_Date__c,
			Addendum_Line_Item__c.Current_Renewal_Date__c,
			Addendum_Line_Item__c.Current_Trial_End_Date__c,
			Addendum_Line_Item__c.Current_Price__c,
			Addendum_Line_Item__c.Defer_Billing__c,
			Addendum_Line_Item__c.Deferred_Months__c,
			Addendum_Line_Item__c.Extend_Satisfaction_Period__c,
			Addendum_Line_Item__c.New_Contract_Start_Date__c,
			Addendum_Line_Item__c.New_Contract_Term_Months__c,
			Addendum_Line_Item__c.New_Free_Months__c,
			Addendum_Line_Item__c.New_Free_Month_Setting__c,
			Addendum_Line_Item__c.New_MSF__c,
			Addendum_Line_Item__c.New_Next_Invoice_Date__c,
			Addendum_Line_Item__c.New_Price__c,
			Addendum_Line_Item__c.New_Quantity__c,
			Addendum_Line_Item__c.New_Renewal_Date__c,
			Addendum_Line_Item__c.New_Trial_Period_Days__c,
			Addendum_Line_Item__c.New_Trial_End_Date__c,
			Addendum_Line_Item__c.NewTerm__c,
			Addendum_Line_Item__c.NewTerm_Months__c,
			Addendum_Line_Item__c.Original_Agreement_Date__c,
			Addendum_Line_Item__c.PriceBookEntryId__c,
			Addendum_Line_Item__c.Pricebook_Entry_Id__c,
			Addendum_Line_Item__c.PriceBookEntry_Contract_Name__c,
			Addendum_Line_Item__c.PriceBookEntry_Name__c,
			Addendum_Line_Item__c.PriceBookEntry_Price__c,
			Addendum_Line_Item__c.PriceBookEntry_Product_Family__c,
			Addendum_Line_Item__c.Product_Name__c,
			Addendum_Line_Item__c.Trial_End_Date__c,
			Addendum_Line_Item__c.Waive_Billing__c,
			Addendum_Line_Item__c.Waived_Months__c
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Addendum_Line_Item__c.SObjectType;
	}

	public static AddendumLineItemsSelector newInstance()
	{
		return (AddendumLineItemsSelector) Application.Selector.newInstance(Addendum_Line_Item__c.SObjectType);
	}

	public Addendum_Line_Item__c[] selectByAddendumId(Addendum_Line_Item__c[] addendumLineItems)
	{
		Set<Id> ids = new Set<Id>();

		for(Addendum_Line_Item__c addendumLineItem : addendumLineItems)
		{			
			ids.add(addendumLineItem.Addendum__c);
		}

		fflib_QueryFactory addendumLineItemQueryFactory = newQueryFactory();
		new AddendaSelector().configureQueryFactoryFields(addendumLineItemQueryFactory, 'Addendum__r');	
		
		return (Addendum_Line_Item__c[]) Database.query(
				addendumLineItemQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Addendum__c IN :ids').toSOQL());
	}

	public Map<String, String> getSnippetMap()
	{
		Map<String, String> snipMap = new Map<String, String>();
		
		Addendum_Snippet__c[] snips = [SELECT Id, Name, Snippet_Text__c FROM Addendum_Snippet__c];

		for(Addendum_Snippet__c snip : snips)
		{
			snipMap.put(snip.Name, snip.Snippet_Text__c);
		}

		return snipMap;
	}

	public Addendum_Line_Item__c[] selectByAddendumIds(Set<Id> ids)
	{		
		fflib_QueryFactory addendumLineItemQueryFactory = newQueryFactory();

		new AddendaSelector().configureQueryFactoryFields(addendumLineItemQueryFactory, 'Addendum__r');	
				
		new AssetsSelector().configureQueryFactoryFields(addendumLineItemQueryFactory, 'Asset__r');
	
		return (Addendum_Line_Item__c[]) Database.query(
				addendumLineItemQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Addendum__c IN :ids').toSOQL());
	}

	public Addendum_Line_Item__c[] selectAddProductsByAddendumId(Set<Id> ids)
	{				
		fflib_QueryFactory addendumLineItemQueryFactory = newQueryFactory();		
				
		return (Addendum_Line_Item__c[]) Database.query(
				addendumLineItemQueryFactory
					.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
					.setCondition('Addendum__c IN :ids AND Asset__c = null').toSOQL());
	} 
}