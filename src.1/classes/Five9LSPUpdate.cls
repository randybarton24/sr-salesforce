global class Five9LSPUpdate implements Database.Batchable<sObject> 
{
	SR_Default_Values__c defaultValues = SR_Default_Values__c.getValues('Campaign Influence Orphan Days');
	Integer limitNumber = Integer.valueOf(defaultValues.Value__c);
	String query = 'SELECT Id, Five9LSP__Sync_Status__c FROM Five9LSP__Five9_List_Item__c WHERE Five9LSP__Sync_Status__c = \'Pending\' LIMIT :limitNumber';	
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
		delete scope;
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		Five9LSP__Five9_List_Item__c[] items = [SELECT Id, Five9LSP__Sync_Status__c 
			FROM Five9LSP__Five9_List_Item__c WHERE Five9LSP__Sync_Status__c = 'Pending' LIMIT :limitNumber];

		Integer nonBatchAsyncApexJobs = [SELECT count() FROM AsyncApexJob WHERE JobType != 'BatchApexWorker' AND JobType != 'BatchApex' AND CreatedDate >= :DateTime.now().addDays(-1)];
		AggregateResult[] ar = [SELECT SUM(JobItemsProcessed) FROM AsyncApexJob WHERE JobType = 'BatchApex' AND CreatedDate >= :DateTime.now().addDays(-1)];
		Integer batchJobItemsProcessed = Integer.valueOf(ar[0].get('expr0'));
		Integer total = nonBatchAsyncApexJobs + batchJobItemsProcessed;

		if(items.size() > 1000 && total < 300000) 
		{
			Five9LSPUpdate batchable = new Five9LSPUpdate();
			Database.executeBatch(batchable, 1);
		}		
	}
}