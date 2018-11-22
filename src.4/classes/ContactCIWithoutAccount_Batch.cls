global class ContactCIWithoutAccount_Batch implements Database.Batchable<sObject>, Schedulable 
{		
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return CampaignInfluencesSelector.newInstance().queryLocatorContactCIWithoutAccount();
	}

	global void execute(Database.BatchableContext BC, List<Campaign_Influence__c> scope) 
	{
      	fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(Campaign_Influence__c ci : scope) 
		{
			if(ci.Contact__c == null) continue;
			if(ci.Account__c != null) continue;
			if(ci.Contact__r.AccountId == null) continue;

			ci.Account__c = ci.Contact__r.AccountId;
			uow.registerDirty(ci);
		}

		uow.commitWork();
	}
			
	global void finish(Database.BatchableContext BC) 
	{	
		OrphanCI_Batch batch = new OrphanCI_Batch();
		Database.executebatch(batch);
	}

	global void execute(SchedulableContext sc) 
	{	
		ContactCIWithoutAccount_Batch batch = new ContactCIWithoutAccount_Batch();
		Database.executebatch(batch);
	}
}