public class OpportunityLineItemsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			OpportunityLineItem.Id,
			OpportunityLineItem.Approval_Level_Required__c,
			OpportunityLineItem.Approval_Level_Required_Free_Months__c,
			OpportunityLineItem.Approval_Level_Required_Price_Discount__c,
			OpportunityLineItem.Approval_Level_Required_Term__c,
			OpportunityLineItem.Approval_Level_Required_Trial__c,
			OpportunityLineItem.Approved_Price_Discount__c,
			OpportunityLineItem.Base_Contract_Term__c,
			OpportunityLineItem.Competitor_Buyout__c,
			OpportunityLineItem.Co_Terminate__c,
			OpportunityLineItem.Current_SR_Subscription__c,
			OpportunityLineItem.Free_Month_Setting__c,
			OpportunityLineItem.Is_Promo_Item__c,
			OpportunityLineItem.ListPrice,
			OpportunityLineItem.List_Price_Override__c,
			OpportunityLineItem.Modified_Subscription__c,
			OpportunityLineItem.Number_of_Free_Months__c,
			OpportunityLineItem.OpportunityId,
			OpportunityLineItem.Override_Current_SR_Subscription__c,
			OpportunityLineItem.Override_Modified_Subscription__c,
			OpportunityLineItem.PricebookEntryId,
			OpportunityLineItem.Product_Terms__c,
			OpportunityLineItem.Provider__c,
			OpportunityLineItem.Promotional_Price__c,
			OpportunityLineItem.Quantity,
			OpportunityLineItem.RecurSoft__Contract_Term1__c,
			OpportunityLineItem.RecurSoft__Contract_Term_End_Date_Editable__c,
			OpportunityLineItem.RecurSoft__Contract_Term_Setting__c,
			OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c,
			OpportunityLineItem.RecurSoft__Product_Subscription__c,
			OpportunityLineItem.RecurSoft__Renewal_Rule__c,
			OpportunityLineItem.SR_Conversations_Phone_Number__c,
			OpportunityLineItem.Total_Contract_Term__c,
			OpportunityLineItem.TotalPrice,
			OpportunityLineItem.Trial__c,
			OpportunityLineItem.Trial_End_Date__c,
			OpportunityLineItem.UnitPrice };
	}

	public Schema.SObjectType getSObjectType()
	{
		return OpportunityLineItem.SObjectType;
	}

	public static OpportunityLineItemsSelector newInstance()
	{
		return (OpportunityLineItemsSelector) Application.Selector.newInstance(OpportunityLineItem.SObjectType);
	}

	public OpportunityLineItem[] selectByProductSubscriptions(RecurSoft__Product_Subscription__c[] subscriptions)
	{
		Set<Id> ids = new Set<Id>();

		for(RecurSoft__Product_Subscription__c subscription : subscriptions)
		{
			ids.add(subscription.RecurSoft__Opportunity_Product_ID__c);
		}

		fflib_QueryFactory opportunityLineItemQueryFactory = newQueryFactory();

		new PricebookEntriesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PricebookEntry');

		new ProductsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PricebookEntry.Product2');

		new ProvidersSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Provider__r');

		return (OpportunityLineItem[]) Database.query(
			opportunityLineItemQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public OpportunityLineItem[] selectByIdWithAccountOpportunityProductPricebookEntry(Set<Id> ids)
	{
		fflib_QueryFactory opportunityLineItemQueryFactory = newQueryFactory();

		new OpportunitiesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Opportunity');

		new AccountsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Opportunity.Account');

		new PricebookEntriesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PricebookEntry');

		new ProductsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Product2');

		return (OpportunityLineItem[]) Database.query(
			opportunityLineItemQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public OpportunityLineItem[] selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(Set<Id> ids)
	{
		fflib_QueryFactory opportunityLineItemQueryFactory = newQueryFactory();

		new OpportunitiesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Opportunity');

		new AccountsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Opportunity.Account');

		new PricebookEntriesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PricebookEntry');

		new PricebooksSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PricebookEntry.Pricebook2');

		new ProductsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Product2');

		return (OpportunityLineItem[]) Database.query(
			opportunityLineItemQueryFactory
			.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
			.setCondition('OpportunityId IN :ids')
			.toSOQL());
	}

	public Map<Id, Date> getAccountIdToSRContractEndDateMap(OpportunityLineItem[] oppLis)
	{
		Set<Id> ids = new Set<Id>();
		for(OpportunityLineItem oppLi : oppLis)
		{
			ids.add(oppLi.OpportunityId);
		}

		Map<Id, Date> resultMap = new Map<Id, Date>();
		AggregateResult[] aggregateResults = Database.query('SELECT RecurSoft__Account__c, Max(RecurSoft__Contract_Term_End_Date__c) contractEndDate ' +
			'FROM RecurSoft__Product_Subscription__c ' +
			'WHERE RecurSoft__Product__r.Family = \'SR Platform\' ' +
			'AND RecurSoft__Billing_Status__c = \'Regular Invoicing\' ' +
			'AND RecurSoft__Account__c IN (SELECT AccountId FROM Opportunity WHERE Id IN :ids) ' +
			'GROUP BY RecurSoft__Account__c');

		for(AggregateResult result :aggregateResults)
		{
			resultMap.put((Id) result.get('RecurSoft__Account__c'), (Date) result.get('contractEndDate'));
		}

		return resultMap;
	}

	public Database.QueryLocator queryLocatorUpdateContractTermDate_Batch()
	{
		fflib_QueryFactory opportunityLineItemQueryFactory = newQueryFactory();

		new OpportunitiesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Opportunity');

		new PricebooksSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PricebookEntry.Pricebook2');

		new PricebookEntriesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PricebookEntry');

		new ProductsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Product2');

		return Database.getQueryLocator(
			opportunityLineItemQueryFactory
				.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('Opportunity.IsClosed != true AND Opportunity.RecordType.Name = \'Add Product\' AND Opportunity.RecurSoft__Contract_Signed_Date__c = null')
				.toSOQL());
	}
}