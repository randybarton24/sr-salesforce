global class UpdateContractTermDate_Batch implements Database.Batchable<sObject>,Schedulable 
{
	global UpdateContractTermDate_Batch() 
	{
		
	}

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return OpportunityLineItemsSelector.newInstance().queryLocatorUpdateContractTermDate_Batch();
	}

	global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope) 
	{
		OpportunityLineItems oppLi = new OpportunityLineItems (scope);
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Set<Id> updateAllOpplisOnOppContractDates_Batch = new Set<Id>();
		
		for (OpportunityLineItem o :scope)
		{
			updateAllOpplisOnOppContractDates_Batch.add(o.OpportunityId);
		}

		oppLi.updateAllOpplisOnOppContractDates = updateAllOpplisOnOppContractDates_Batch;
        oppLi.updateContractDates(scope, uow);
		
		for (Id oppId : oppLi.opportunityIdToContractEndDateMap.keySet())
		{
			Opportunity opp = new Opportunity(Id=oppId,
				RecurSoft__Initial_Contract_Term__c= Date.today().monthsBetween(oppLi.opportunityIdToContractEndDateMap.get(oppId)));
			uow.registerDirty(opp);
		}

     	uow.commitWork();
	}

	global void finish(Database.BatchableContext BC) 
	{
		
	}

	global void execute(SchedulableContext sc) 
	{    
	    UpdateContractTermDate_Batch batchable = new UpdateContractTermDate_Batch();
	    Database.executeBatch(batchable, 1);  
	} 
}