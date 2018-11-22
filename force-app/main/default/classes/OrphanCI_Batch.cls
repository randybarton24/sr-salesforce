global class OrphanCI_Batch implements Database.Batchable<sObject>, Schedulable 
{	
	SR_Default_Values__c defaultValues = SR_Default_Values__c.getValues('Campaign Influence Orphan Days');
	Integer cutOffDays = Integer.valueOf(defaultValues.Value__c);
	Datetime cutOff = Datetime.now().addDays(-cutOffDays);

	String query = 'SELECT Id, Orphaned__c, CreatedDate, Orphaned_Date__c, ' +
		'Lead__c, Lead__r.Number_of_Active_CI__c, Lead__r.Last_ROE_Task_Date__c, ' +
		'Account__c, Account__r.Number_of_Active_CI__c, Account__r.Last_ROE_Date__c ' +
		'FROM Campaign_Influence__c ' +
		'WHERE (Account__r.Last_ROE_Date__c != LAST_N_DAYS:' + cutOffDays + ' OR Account__r.Last_ROE_Date__c = null) ' +
		'AND CreatedDate != LAST_N_DAYS:' + cutOffDays +
		'AND (Orphaned__c = false OR Orphaned_Date__c = null) ' +
		'AND Account__r.RecurSoft__Status__c != \'Active\' ';
		
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Campaign_Influence__c> scope) 
	{
      	fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(Campaign_Influence__c ci : scope) 
		{
			Boolean isOrphan = false;
			Datetime orphanDate;

			if((ci.Orphaned__c && ci.Orphaned_Date__c != null) || (ci.Account__c == null)) continue;

			if(ci.Account__c != null) 
			{
				if(ci.Account__r.Last_Roe_Date__c != null && ci.CreatedDate < ci.Account__r.Last_Roe_Date__c) 
				{
					isOrphan = true;
					orphanDate = ci.Account__r.Last_Roe_Date__c.addDays(cutOffDays);
					ci.Orphaned__c = true;
					ci.Orphaned_Date__c = orphanDate.date();
					uow.registerDirty(ci);
				} 
				else if(ci.CreatedDate < cutOff) 
				{
					isOrphan = true;
					orphanDate = ci.CreatedDate.addDays(cutOffDays);
					ci.Orphaned__c = true;
					ci.Orphaned_Date__c = orphanDate.date();
					uow.registerDirty(ci);
				}
				if(ci.Account__r.Number_of_Active_CI__c != 0 && isOrphan) 
				{
					Account a = new Account(Id = ci.Account__c);
					a.Number_of_Active_CI__c = 0;
					uow.registerDirty(a);	
				}
			} 
		}

		uow.commitWork();
	}
			
	global void finish(Database.BatchableContext BC) 
	{	
		CIRecalculateLead_Batch batch = new CIRecalculateLead_Batch();
		Database.executebatch(batch);
	}

	global void execute(SchedulableContext sc) 
	{	
		OrphanCI_Batch batch = new OrphanCI_Batch();
		Database.executebatch(batch);
	}
}