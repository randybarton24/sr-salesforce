public class AccountsSelector extends fflib_SObjectSelector 
{	
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Account.Id,
			Account.Account_Sales_Status__c,
			Account.Active_Opportunity__c,
			Account.Admin_Last_Sync_Date__c,
            Account.Admin_FMS__c,
            Account.Admin_Status__c,
			Account.Admin_Sync_Received__c,
			Account.BillingStreet,
			Account.BillingCity,
			Account.BillingState,
			Account.BillingStateCode,
			Account.BillingPostalCode,
			Account.BillingCountry,
			Account.BillingCountryCode,
			Account.Care_Credit_Merchant_ID__c,
			Account.Description,
			Account.Fax,
			Account.Industry,
			Account.IntacctID__c,
			Account.Last_HG_Scorecard_Date__c,
			Account.Last_ROE_Date__c,
			Account.Limelight_URL__c,
			Account.Limelight_URL_for_Healthgrades__c,
			Account.Name,
			Account.Number_of_Active_CI__c,
			Account.Number_of_Locations__c,
			Account.Number_of_Open_NPB_Opps__c,
			Account.Number_of_Providers__c,
            Account.of_Open_Sync_Cases__c,
			Account.Office_Contact__c,
			Account.OwnerId,
			Account.ParentId,
			Account.Phone,
			Account.Probable_Most_Recent_K_Date__c,
			Account.Practice_Management_Software__c,
			Account.RecordTypeId,
			Account.RecurSoft__Billing_Email__c,
			Account.RecurSoft__Status__c,
			Account.Sales_Engineer_Call_Completed__c,
			Account.ShippingStreet,
			Account.ShippingCity,
			Account.ShippingState,
			Account.ShippingStateCode,
			Account.ShippingPostalCode,
			Account.ShippingCountry,
			Account.ShippingCountryCode,
			Account.SR_Price_Book__c,
			Account.SR_Timezone__c,
			Account.Subscriber_ID__c,
			Account.Sub_Vertical__c,
			Account.Timed_Distribution_Group_Date__c,
			Account.tz__Timezone__c,
			Account.Website };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Account.SObjectType;
	}

	public static AccountsSelector newInstance()
	{
		return (AccountsSelector) Application.Selector.newInstance(Account.SObjectType);
	}

	public Account[] selectByBillToContact(Set<Id> ids)
	{
		assertIsAccessible();

		OpportunitiesSelector opportunitiesSelector = new OpportunitiesSelector();
		opportunitiesSelector.assertIsAccessible();

		return Database.query(
			String.format(
				'SELECT {0} ' +
				'FROM {1} WHERE Id IN {2} ORDER BY {3}', 
				new List<String>{ 
					getFieldListString(),
					getSObjectName(),
					'(SELECT AccountId FROM Opportunity WHERE RecurSoft__Billing_Contact__c IN :ids)' ,
					getOrderBy()}));
	}

	public Map<Id, Account> selectAccountByContactWithParentAccount(Contact[] contacts)
	{
		Set<Id> ids = new Set<Id>();

		for(Contact contact : contacts)
		{
			ids.add(contact.AccountId);
		}

		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		fflib_QueryFactory opportunityQueryFactory = new OpportunitiesSelector().addQueryFactorySubselect(accountQueryFactory).setCondition('RecordType.Name IN (\'New Practice Business\',\'Add Product\',\'Enterprise New Business\') AND IsClosed = false');

		fflib_QueryFactory taskQueryFactory = new TasksSelector().addQueryFactorySubselect(accountQueryFactory).setCondition('ADR_Set__c = true AND ADR_Set_Received__c = false');

		new AccountsSelector().configureQueryFactoryFields(accountQueryFactory, 'Parent');

		new UsersSelector().configureQueryFactoryFields(accountQueryFactory, 'Owner');

		new UsersSelector().configureQueryFactoryFields(accountQueryFactory, 'Parent.Owner');

		return new Map<Id, Account>((Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL()));
	}

	public Map<Id, Account> selectParentAccountByAccount(Account[] accounts)
	{
		Set<Id> ids = new Set<Id>();

		for(Account account : accounts)
		{
			if(account.ParentId == null) continue;
			
			ids.add(account.ParentId);
		}

		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		fflib_QueryFactory opportunityQueryFactory = new OpportunitiesSelector().addQueryFactorySubselect(accountQueryFactory).setCondition('RecordType.Name IN (\'New Practice Business\',\'Add Product\',\'Enterprise New Business\') AND IsClosed = false');

		new UsersSelector().configureQueryFactoryFields(accountQueryFactory, 'Owner');

		return new Map<Id, Account>((Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL()));
	}

	public Map<Id, Account> selectAccountByOpportunityWithAssets(Opportunity[] opportunities)
	{
		Set<Id> ids = new Set<Id>();

		for(Opportunity opportunity : opportunities)
		{
			ids.add(opportunity.AccountId);
		}

		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		fflib_QueryFactory assetQueryFactory = new AssetsSelector().addQueryFactorySubselect(accountQueryFactory);

		new ProductsSelector().configureQueryFactoryFields(assetQueryFactory, 'Product2');

		new ProvidersSelector().configureQueryFactoryFields(assetQueryFactory, 'Provider__r');

		return new Map<Id, Account>((Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL()));
	}

	public Account[] selectBySubscriberId(Set<String> subscriberIds)
	{
		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		new ContactsSelector().configureQueryFactoryFields(accountQueryFactory, 'Office_Contact__r');

		new ManagementSystemsSelector().configureQueryFactoryFields(accountQueryFactory, 'Practice_Management_Software__r');

		return Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Subscriber_Id__c IN :subscriberIds').toSOQL());
	}

	public Account[] selectByIdWithAssets(Set<Id> ids)
	{
		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		fflib_QueryFactory assetQueryFactory = new AssetsSelector().addQueryFactorySubselect(accountQueryFactory);

		new ProductsSelector().configureQueryFactoryFields(assetQueryFactory, 'Product2');

		new ProvidersSelector().configureQueryFactoryFields(assetQueryFactory, 'Provider__r');

		return Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Map<Id, Account> selectByOpportunityWithCases(Opportunity[] opportunities)
	{
		Set<Id> ids = new Set<Id>();

		for(Opportunity opportunity : opportunities)
		{
			ids.add(opportunity.AccountId);
		}

		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		fflib_QueryFactory caseQueryFactory = new CasesSelector().addQueryFactorySubselect(accountQueryFactory);

		return new Map<Id, Account>((Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL()));
	}

	public Account[] selectBySubscriptionsWithAssets(RecurSoft__Product_Subscription__c[] subscriptions)
	{
		Set<Id> ids = new Set<Id>();

		for(RecurSoft__Product_Subscription__c subscription : subscriptions)
		{
			ids.add(subscription.RecurSoft__Account__c);
		}

		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		fflib_QueryFactory assetQueryFactory = new AssetsSelector().addQueryFactorySubselect(accountQueryFactory);

		new ProductsSelector().configureQueryFactoryFields(assetQueryFactory, 'Product2');

		new ProvidersSelector().configureQueryFactoryFields(assetQueryFactory, 'Provider__r');

		return (Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Map<Id, Account> selectByIdWithContacts(Set<Id> ids)
	{
		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		fflib_QueryFactory contactQueryFactory = accountQueryFactory.subselectQuery('Contacts')
        	.selectFields(new ContactsSelector().getSObjectFieldList());

		return new Map<Id, Account>((Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL()));
	}

	public Map<Id, Account> selectByIdWithContacts(Case[] cases)
	{
		Set<Id> ids = new Set<Id>();

		for(Case c : cases)
		{
			ids.add(c.AccountId);
		}

		return this.selectByIdWithContacts(ids);
	}

	public Account[] selectByIdWithParentAccount(Set<Id> ids)
	{
		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(accountQueryFactory, 'Parent');

		return (Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Account[] selectByIdWithContactsAndOpportunities(Set<Id> ids)
	{
		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		fflib_QueryFactory contactQueryFactory = accountQueryFactory.subselectQuery('Contacts')
        	.selectFields(new ContactsSelector().getSObjectFieldList());

        fflib_QueryFactory opportunityQueryFactory = accountQueryFactory.subselectQuery('Opportunities')
        	.selectFields(new OpportunitiesSelector().getSObjectFieldList());

        fflib_QueryFactory taskQueryFactory = accountQueryFactory.subselectQuery('Tasks')
        	.selectFields(new TasksSelector().getSObjectFieldList());

		return (Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Account[] selectByIdWithManagerAndVP(Set<Id> ids)
	{
		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		new UsersSelector().configureQueryFactoryFields(accountQueryFactory, 'Owner');

		new UsersSelector().configureQueryFactoryFields(accountQueryFactory, 'Owner.Manager');

		return (Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Map<Id, Account> selectByIdWithDemoRequestReason(Set<Id> ids)
	{
		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		new OpportunitiesSelector().configureQueryFactoryFields(accountQueryFactory, 'Active_Opportunity__r');

		fflib_QueryFactory campaignInfluenceQueryFactory = accountQueryFactory.subselectQuery('Campaign_Influence__r')
        	.selectFields(new CampaignInfluencesSelector().getSObjectFieldList())
        	.setCondition('Campaign__r.Sub_Type__c = \'Demo\'')
        	.addOrdering('Campaign_Add_Date__c', fflib_QueryFactory.SortOrder.DESCENDING)
        	.setLimit(1);

		return new Map<Id, Account>((Account[]) Database.query(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL()));
	}
	
	public Database.QueryLocator queryLocatorSyncDown()
	{
		//String conditionTest = 'Id IN (\'0010Z00001sr1Wy\',\'0010Z00001sr3om\',\'0010Z00001srAIJ\',\'0010Z00001srAvX\' 
		//,\'0010Z00001srM4H\',\'0010Z00001srWw3\',\'0010Z00001srbea\',\'0010Z00001srcZa\',\'0010Z00001srdvY\',\'0010Z00001srfLG\')';
		String condition = 'RecurSoft__Status__c = \'Active\' AND Admin_Sync_Received__c = false ' +
			'AND of_Open_Sync_Cases__c = 0 AND Do_Not_Support_Sync__c = false AND Admin_Last_Sync_Date__c != null';
		
		fflib_QueryFactory accountQueryFactory = newQueryFactory();

		return Database.getQueryLocator(
			accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).
				setCondition(condition).
				toSOQL());
	}
	
	public Map<Id, Account> selectAccountsBySet(Set<Id>ids)
	{
		fflib_QueryFactory accountQueryFactory = newQueryFactory();
		
		return new Map<Id, Account>((Account[]) Database.query(
				accountQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL()));
	}
	
}