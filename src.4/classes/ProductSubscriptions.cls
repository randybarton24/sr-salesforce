public class ProductSubscriptions extends fflib_SObjectDomain 
{
	public ProductSubscriptions(RecurSoft__Product_Subscription__c[] subscriptions) 
	{
		super(subscriptions);	
		Configuration.disableTriggerCRUDSecurity();
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new ProductSubscriptions(sObjectList);
		}
	}

	public override void onBeforeInsert()
	{
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();

        this.syncSubscriptionWithOpportunityLineItem(uow, sruow);

        uow.registerWork(sruow);
        uow.commitWork();
	}

	public override void onAfterInsert()
	{
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();

        SRUtilities.scheduleAsync(new Map<Id, RecurSoft__Product_Subscription__c>((RecurSoft__Product_Subscription__c[]) Records).keySet(), AsyncMain.TYPE_PRODSUB_AFTERINSERT);

        uow.registerWork(sruow);
        uow.commitWork();
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();

        this.syncSubscriptionWithOpportunityLineItem(uow, sruow);
        
        uow.registerWork(sruow);
        uow.commitWork();
	}

	public void syncSubscriptionWithOpportunityLineItem(fflib_SObjectUnitOfWork uow, SRUtilities.SRUnitOfWork sruow) 
	{
		Map<Id, OpportunityLineItem> oppLiMap = new Map<Id, OpportunityLineItem>(OpportunityLineItemsSelector.newInstance().selectByProductSubscriptions((RecurSoft__Product_Subscription__c[]) Records));

		for(RecurSoft__Product_Subscription__c subscription : (RecurSoft__Product_Subscription__c[]) Records) 
		{
			if(subscription.RecurSoft__Opportunity_Product_ID__c == null || !oppLiMap.containsKey(subscription.RecurSoft__Opportunity_Product_ID__c)) continue;
		
			OpportunityLineItem oppLi = oppLiMap.get(subscription.RecurSoft__Opportunity_Product_ID__c);
				
			if(oppLi.RecurSoft__Product_Subscription__c == null) 
			{	
				oppLi.RecurSoft__Product_Subscription__c = subscription.Id;
				sruow.registerDirtyWithCatch(oppLi);
			}

			if(subscription.Number_of_Free_Months__c == null) 
			{
				subscription.Promotional_Price__c = oppLi.Promotional_Price__c == null ? 0 : oppLi.Promotional_Price__c;
				subscription.Number_of_Free_Months__c = oppLi.Number_of_Free_Months__c;
				subscription.Free_Month_Setting__c = oppLi.Free_Month_Setting__c;
			}

			if(subscription.Competitor_Buyout__c == null) 
			{
				subscription.Competitor_Buyout__c = oppLi.Competitor_Buyout__c;
			}

			if(subscription.Trial_Start_Date__c == null) 
			{
				subscription.Trial_Start_Date__c = oppLi.Trial_End_Date__c != null ? subscription.RecurSoft__Contract_Term_Start_Date__c : null;
			}

			if(subscription.Trial_End_Date__c == null) 
			{
				subscription.Trial_End_Date__c = oppLi.Trial_End_Date__c;
			}
		}
	}
}