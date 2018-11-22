public class AssetsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Asset.Id,
			Asset.AccountId,
			Asset.Active__c,
			Asset.Name,
			Asset.Current_Product_Subscription__c,
			Asset.Most_Recent_Cancel_Request_Date__c,
			Asset.Most_Recent_Cancel_Request_Stage__c,
			Asset.Most_Recent_Competitor_Buyout__c,
			Asset.Most_Recent_Contract_Signed_Date__c,
			Asset.Most_Recent_Contract_Term_Start_Date__c,
			Asset.Most_Recent_Number_of_Free_Months__c,
			Asset.Most_Recent_Termination_Date__c,
			Asset.Provider__c,
			Asset.Product2Id
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Asset.SObjectType;
	}

	public static AssetsSelector newInstance()
	{
		return (AssetsSelector) Application.Selector.newInstance(Asset.SObjectType);
	}

	public Asset[] selectByIdWithAccountAndProduct(Set<Id> ids)
	{
		fflib_QueryFactory assetQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(assetQueryFactory, 'Account');

		new ProductsSelector().configureQueryFactoryFields(assetQueryFactory, 'Product2');

		return (Asset[]) Database.query(
			assetQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Asset[] selectByCancelRequestsWithAccountAndProduct(Cancel_Request__c[] cancelRequests)
	{
		Set<Id> ids = new Set<Id>();

		for (Cancel_Request__c cro : cancelRequests)
		{
			ids.add(cro.Asset__c);
		}

		fflib_QueryFactory assetQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(assetQueryFactory, 'Account');

		new ProductsSelector().configureQueryFactoryFields(assetQueryFactory, 'Product2');

		return (Asset[]) Database.query(
			assetQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Map<String, Id> selectCurrentSubscriptionsByOpportunityLineItems(OpportunityLineItem[] opportunityLineItems)
	{
		Set<Id> ids = new Set<Id>();
		Map<String, Id> currentSubscriptionMap = new Map<String, Id>();
		
		for(OpportunityLineItem oppLi : opportunityLineItems) 
		{	
			ids.add(oppLi.Opportunity.AccountId);
		}

		fflib_QueryFactory assetQueryFactory = newQueryFactory();

		new ProductsSelector().configureQueryFactoryFields(assetQueryFactory, 'Product2');

		Asset[] assets = (Asset[]) Database.query(
			assetQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('AccountId IN :ids').toSOQL());

		for(Asset asset : assets) 
		{
			if(asset.Current_Product_Subscription__c == null) continue;
			currentSubscriptionMap.put(String.valueOf(asset.AccountId) + asset.Product2.Family + asset.Provider__c, asset.Current_Product_Subscription__c);
		}

		return currentSubscriptionMap;
	}

	public Map<String, Id> selectCurrentSubscriptionsByCancelRequests(Cancel_Request__c[] cancelRequests)
	{
		Set<Id> ids = new Set<Id>();
		Map<String, Id> currentSubscriptionMap = new Map<String, Id>();
		
		for (Cancel_Request__c cro : cancelRequests)
		{
			ids.add(cro.Asset__c);
		}

		fflib_QueryFactory assetQueryFactory = newQueryFactory();

		new ProductsSelector().configureQueryFactoryFields(assetQueryFactory, 'Product2');

		Asset[] assets = (Asset[]) Database.query(
			assetQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());

		for(Asset asset : assets) 
		{
			if(asset.Current_Product_Subscription__c == null) continue;
			currentSubscriptionMap.put(String.valueOf(asset.AccountId) + asset.Product2.Family + asset.Provider__c, asset.Current_Product_Subscription__c);
		}

		return currentSubscriptionMap;
	}
	
	public Asset[] selectActiveAssetsByAddendum(Addendum__c[] addenda)
	{				
		Set<Id> ids = new Set<Id>();
		for(Addendum__c a : addenda)
		{
			ids.add(a.Account__c);
		}

		fflib_QueryFactory assetQueryFactory = newQueryFactory();
		
		new AccountsSelector().configureQueryFactoryFields(assetQueryFactory, 'Account');	
				
		Asset[] assets = (Asset[]) Database.query(
				assetQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('AccountId IN :ids AND Current_Product_Subscription__c != null').toSOQL());
		
		return assets;
	} 
}