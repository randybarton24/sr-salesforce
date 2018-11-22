public class ProductSubscriptionsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			RecurSoft__Product_Subscription__c.Id,
			RecurSoft__Product_Subscription__c.Asset__c,
			RecurSoft__Product_Subscription__c.Competitor_Buyout__c,
			RecurSoft__Product_Subscription__c.Free_Month_Setting__c,
			RecurSoft__Product_Subscription__c.Next_Invoice_Date__c,
			RecurSoft__Product_Subscription__c.Number_of_Free_Months__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Account__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Billing_Frequency__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Billing_Status__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Bill_to_Account__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Bill_to_Contact__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Contract_Signed_Date__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Contract_Term_End_Date__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Contract_Term_Months__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Contract_Term_Start_Date__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Opportunity_Product_ID__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Product__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Related_Opportunity__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Renewed_Subscription__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Rev_Rec_Template_Name__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Ship_to_Contact__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Total_Contract_Term__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Total_number_of_periods__c,
			RecurSoft__Product_Subscription__c.RecurSoft__Unit_Price__c,
			RecurSoft__Product_Subscription__c.Trial_End_Date__c,
			RecurSoft__Product_Subscription__c.Trial_Start_Date__c
			 };
	}

	public Schema.SObjectType getSObjectType()
	{
		return RecurSoft__Product_Subscription__c.SObjectType;
	}

	public static ProductSubscriptionsSelector newInstance()
	{
		return (ProductSubscriptionsSelector) Application.Selector.newInstance(RecurSoft__Product_Subscription__c.SObjectType);
	}

	public RecurSoft__Product_Subscription__c[] selectByIdWithRenewedSubscriptions(Set<Id> ids)
	{
		fflib_QueryFactory productSubscriptionQueryFactory = newQueryFactory();

		return (RecurSoft__Product_Subscription__c[]) Database.query(
			productSubscriptionQueryFactory.selectField('RecurSoft__Renewed_Subscription__r.Asset__c').setCondition('Id IN :ids').toSOQL());
	}

	public Database.QueryLocator queryLocatorNewRenewals()
	{
		return Database.getQueryLocator(
			newQueryFactory().
			selectField('RecurSoft__Renewed_Subscription__r.Asset__c').
			setCondition('RecurSoft__Renewed_Subscription__c != null AND Asset__c = null AND RecurSoft__Billing_Frequency__c = \'Monthly\'').
			toSOQL());
	}

	public RecurSoft__Product_Subscription__c selectActiveSRSubscriptionsBySubscriberId(String subscriberId) 
	{
        fflib_QueryFactory productSubscriptionQueryFactory = newQueryFactory();

        new AccountsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r');

        new ManagementSystemsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r.Practice_Management_Software__r');

        new ContactsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r.Office_Contact__r');

        new ContactsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Contact__r');

        new ProductsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Product__r');

        return (RecurSoft__Product_Subscription__c) Database.query(
			productSubscriptionQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setLimit(1)
				.setCondition('RecurSoft__Account__r.Subscriber_Id__c = :subscriberId AND RecurSoft__Product__r.Family = \'SR Platform\' AND RecurSoft__Billing_Status__c = \'Regular Invoicing\'')
				.addOrdering(RecurSoft__Product_Subscription__c.RecurSoft__Contract_Term_End_Date__c, fflib_QueryFactory.SortOrder.DESCENDING)
				.toSOQL());
    }

    public Map<Id, RecurSoft__Product_Subscription__c> selectActiveSRSubscriptionsByOpportunityLineItems(OpportunityLineItem[] opportunityLineItems) 
	{
        Set<Id> ids;
        Map<Id, RecurSoft__Product_Subscription__c> results = new Map<Id, RecurSoft__Product_Subscription__c>();

        for(OpportunityLineItem oppLi : opportunityLineItems)
        {
        	ids.add(oppLi.Opportunity.AccountId);
        }

        fflib_QueryFactory productSubscriptionQueryFactory = newQueryFactory();

        new AccountsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r');

        new ManagementSystemsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r.Practice_Management_Software__r');

        new ContactsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r.Office_Contact__r');

        new ContactsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Contact__r');

        new ProductsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Product__r');

        RecurSoft__Product_Subscription__c[] subscriptions = (RecurSoft__Product_Subscription__c[]) Database.query(
			productSubscriptionQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('RecurSoft__Account__c IN :ids AND RecurSoft__Product__r.Family = \'SR Platform\' AND RecurSoft__Billing_Status__c = \'Regular Invoicing\'')
				.addOrdering(RecurSoft__Product_Subscription__c.RecurSoft__Contract_Term_End_Date__c, fflib_QueryFactory.SortOrder.DESCENDING)
				.toSOQL());
        
        for(RecurSoft__Product_Subscription__c subscription : subscriptions)
        {
        	results.put(subscription.RecurSoft__Account__c, subscription);
        }

        return results;
    }

    public RecurSoft__Product_Subscription__c[] selectActiveSubscriptionsBySubscriberId(String subscriberId) 
	{
        fflib_QueryFactory productSubscriptionQueryFactory = newQueryFactory();

        new AccountsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r');

        new AccountsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Account__r');

        new ManagementSystemsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r.Practice_Management_Software__r');

        new ContactsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Account__r.Office_Contact__r');

        new ContactsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Bill_to_Contact__r');

        new ProductsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Product__r');

        return (RecurSoft__Product_Subscription__c[]) Database.query(
			productSubscriptionQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('RecurSoft__Account__r.Subscriber_Id__c = :subscriberId AND RecurSoft__Billing_Status__c = \'Regular Invoicing\' AND RecurSoft__Product__r.Family != null')
				.addOrdering(RecurSoft__Product_Subscription__c.RecurSoft__Product__c, fflib_QueryFactory.SortOrder.DESCENDING)
				.toSOQL());
    }

    public RecurSoft__Product_Subscription__c[] selectByIdWithOpportunityProductsSchedules(Set<Id> ids) 
	{
        fflib_QueryFactory productSubscriptionQueryFactory = newQueryFactory();

        new OpportunitiesSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Related_Opportunity__r');

        new ProductsSelector().configureQueryFactoryFields(productSubscriptionQueryFactory, 'RecurSoft__Product__r');

        fflib_QueryFactory opportunityLineItemQueryFactory = productSubscriptionQueryFactory.subselectQuery('RecurSoft__RecurSoft_Opportunity_Product3__r')
        	.selectFields(new OpportunityLineItemsSelector().getSObjectFieldList());

        new ProvidersSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Provider__r');

        fflib_QueryFactory revenueScheduleQueryFactory = productSubscriptionQueryFactory.subselectQuery('RecurSoft__RecurSoft_Revenue_Schedules__r')
        	.selectFields(new RevenueSchedulesSelector().getSObjectFieldList());

        return (RecurSoft__Product_Subscription__c[]) Database.query(
			productSubscriptionQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('Id IN :ids')
				.toSOQL());
    }

    public Database.QueryLocator queryLocatorWithSchedules()
	{
		fflib_QueryFactory productSubscriptionQueryFactory = newQueryFactory();
		
		fflib_QueryFactory revenueScheduleQueryFactory = productSubscriptionQueryFactory.subselectQuery('RecurSoft__RecurSoft_Revenue_Schedules__r')
        	.selectFields(new RevenueSchedulesSelector().getSObjectFieldList());

        return Database.getQueryLocator(
			productSubscriptionQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('RecurSoft__Billing_Status__c = \'Regular Invoicing\' AND RecordType.Name = \'Evergreen\'')
				.toSOQL());
	}
}