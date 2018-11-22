global with sharing class LinkRenewalSubscriptionsToAssets_Batch implements System.Schedulable, Database.Batchable<SObject> 
{
	global void execute(SchedulableContext sc)
	{
		Database.executeBatch(new LinkRenewalSubscriptionsToAssets_Batch());
	}

	global Database.QueryLocator start(Database.BatchableContext context)
	{
		return new ProductSubscriptionsSelector().queryLocatorNewRenewals();
	}

	global void execute(Database.BatchableContext context, RecurSoft__Product_Subscription__c[] scope)
	{
		System.debug(scope);
		try
		{
			fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			Set<Id> ids = new Map<Id, SObject>(scope).keySet();
			ProductSubscriptionsService.linkHGRenewalToAsset(ids, uow);
			uow.commitWork();
		}
		catch(Exception e)
		{
			System.debug(e);
		}
	}

	global void finish(Database.BatchableContext context)
	{

	}
}