global class TaskHistoryDelete_Batch implements Database.Batchable<sObject>, Schedulable 
{	
	SR_Default_Values__c defaultValues = SR_Default_Values__c.getValues('TaskHistoryDeleteDays');
	Date cutOff = Date.today().addDays(-Integer.valueOf(defaultValues.Value__c));
	String query = 'SELECT Id, CreatedDate FROM Task_History__c WHERE CreatedDate < :cutOff LIMIT 50000';

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Task_History__c> scope) 
	{
		delete scope;
	}
			
	global void finish(Database.BatchableContext BC) 
	{	
		Task_History__c[] remaining = [SELECT Id FROM Task_History__c WHERE CreatedDate < :cutOff LIMIT 1];

		if(!remaining.isEmpty()) 
		{
			TaskHistoryDelete_Batch batch = new TaskHistoryDelete_Batch();
			Database.executebatch(batch);
		}
	}

	global void execute(SchedulableContext sc) 
	{	
		TaskHistoryDelete_Batch batch = new TaskHistoryDelete_Batch();
		Database.executebatch(batch);
	}
}