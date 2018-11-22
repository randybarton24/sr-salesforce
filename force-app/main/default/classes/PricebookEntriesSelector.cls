public class PricebookEntriesSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			PricebookEntry.Id,
			PricebookEntry.Approval_Level_to_Enforce__c,
			PricebookEntry.Auto_Add__c,
			PricebookEntry.Auto_Add_Free_Months__c,
			PricebookEntry.Auto_Add_Free_Month_Setting__c,
			PricebookEntry.Auto_Add_Price__c,
			PricebookEntry.Auto_Add_Promotional_Price__c,
			PricebookEntry.Auto_Add_Quantity__c,
			PricebookEntry.Auto_Add_Trial__c,
			PricebookEntry.Enforce_Limits_Free_Months__c,
			PricebookEntry.Enforce_Limits_Price_Discount__c,
			PricebookEntry.Enforce_Limits_Term__c,
			PricebookEntry.Enforce_Limits_Trial__c,
			PricebookEntry.Free_Months_Floor__c,
			PricebookEntry.IsActive,
			PricebookEntry.Level_0_Limit_Free_Months__c,
			PricebookEntry.Level_0_Limit_Price_Discount__c,
			PricebookEntry.Level_0_Limit_Term__c,
			PricebookEntry.Level_0_Limit_Trial__c,
			PricebookEntry.Level_1_Limit_Free_Months__c,
			PricebookEntry.Level_1_Limit_Price_Discount__c,
			PricebookEntry.Level_1_Limit_Term__c,
			PricebookEntry.Level_1_Limit_Trial__c,
			PricebookEntry.Level_2_Limit_Free_Months__c,
			PricebookEntry.Level_2_Limit_Price_Discount__c,
			PricebookEntry.Level_2_Limit_Term__c,
			PricebookEntry.Level_2_Limit_Trial__c,
			PricebookEntry.Name,
			PricebookEntry.UnitPrice,
			PricebookEntry.Pricebook2Id,
			PricebookEntry.Price_Discount_Floor__c,
			PricebookEntry.Product2Id,
	    	PricebookEntry.ProductCode,
	    	PricebookEntry.Trial_Period_Floor__c };
	}

	public Schema.SObjectType getSObjectType()
	{
		return PricebookEntry.SObjectType;
	}

	public override String getOrderBy()
	{
		return 'Auto_Add__c DESC, Auto_Add_Price__c DESC';
	}

	public static PricebookEntriesSelector newInstance()
	{
		return (PricebookEntriesSelector) Application.Selector.newInstance(PricebookEntry.SObjectType);
	}

	public PricebookEntry[] selectByPricebookId(String pricebookId) 
	{
        fflib_QueryFactory pricebookEntriesQueryFactory = newQueryFactory();

        new ProductsSelector().configureQueryFactoryFields(pricebookEntriesQueryFactory, 'Product2');

        return (PricebookEntry[]) Database.query(
			pricebookEntriesQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('Pricebook2Id = :pricebookId')
				.toSOQL());
    }

	public PricebookEntry[] selectByOpportunityLineItems(OpportunityLineItem[] opportunityLineItems)
	{
		Set<Id> ids = new Set<Id>();
		
		for(OpportunityLineItem oppLi : opportunityLineItems) 
		{	
			ids.add(oppLi.PricebookEntryId);
		}

		fflib_QueryFactory pricebookEntryQueryFactory = newQueryFactory();

		return (PricebookEntry[]) Database.query(
			pricebookEntryQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}
}