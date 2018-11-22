global class Five9LSP implements Database.Batchable<sObject> 
{
	SR_Default_Values__c defaultValues = SR_Default_Values__c.getValues('Campaign Influence Orphan Days');
	SR_Default_Values__c defaultValues2 = SR_Default_Values__c.getValues('Opportunity Closed Lost Days');
	String listId = defaultValues2.Value__c;
	Integer limitNumber = Integer.valueOf(defaultValues.Value__c);

	String query = 'SELECT Id FROM Account WHERE ' +
	'ParentId = null AND RecurSoft__Status__c != \'Active\' AND Account_Sales_Status__c NOT IN (\'Bogus\',\'Duplicate\') ' +
	'and id not in (select five9lsp__Account__c from Five9LSP__Five9_List_Item__c) ' +
	'and recordtype.name not in (\'Affiliate/KOL\',\'Enterprise DHC\',\'PM/EHR Partner\',\'Partner\') LIMIT :limitNumber';	
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
		SObject[] itemsToInsert = new List<SObject>();
		for(Account a : (Account[]) scope)
		{
			Five9LSP__Five9_List_Item__c item = new Five9LSP__Five9_List_Item__c(five9lsp__Account__c = a.Id,
				Five9LSP__Five9_List__c = listId);
			itemsToInsert.add(item);
		}
		insert itemsToInsert;
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		Account[] accts = [SELECT Id FROM Account WHERE 
			ParentId = null AND RecurSoft__Status__c != 'Active' AND Account_Sales_Status__c NOT IN ('Bogus','Duplicate')
			and id not in (select five9lsp__Account__c from Five9LSP__Five9_List_Item__c)
			and recordtype.name not in ('Affiliate/KOL','Enterprise DHC','PM/EHR Partner','Partner') LIMIT :limitNumber];

		Integer nonBatchAsyncApexJobs = [SELECT count() FROM AsyncApexJob WHERE JobType != 'BatchApexWorker' AND JobType != 'BatchApex' AND CreatedDate >= :DateTime.now().addDays(-1)];
		AggregateResult[] ar = [SELECT SUM(JobItemsProcessed) FROM AsyncApexJob WHERE JobType = 'BatchApex' AND CreatedDate >= :DateTime.now().addDays(-1)];
		Integer batchJobItemsProcessed = Integer.valueOf(ar[0].get('expr0'));
		Integer total = nonBatchAsyncApexJobs + batchJobItemsProcessed;

		if(accts.size() > 1000 && total < 300000) 
		{
			Five9LSP batchable = new Five9LSP();
			Database.executeBatch(batchable);
		}		
	}
}