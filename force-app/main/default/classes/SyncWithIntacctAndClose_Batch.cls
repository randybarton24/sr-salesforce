global class SyncWithIntacctAndClose_Batch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts 
{
	Set<Id> ids;
	Boolean closeOpp;
	String query = 'SELECT Id FROM Opportunity WHERE Id IN :ids';	
	
	global SyncWithIntacctAndClose_Batch(Set<Id> opps, Boolean closeOpp) 
	{
		this.ids = opps;
		this.closeOpp = closeOpp;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
		IntacctIntegrationSyncHandler intacctSyncHandler = new IntacctIntegrationSyncHandler(ids);
		IntacctIntegrationSyncHandler.closeOpp = closeOpp;
        intacctSyncHandler.startIntegrationSR();
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		
	}

	global void execute(SchedulableContext sc) 
	{    
        SyncWithIntacctAndClose_Batch batchable = new SyncWithIntacctAndClose_Batch(ids, closeOpp);
        Database.executeBatch(batchable, 1);  
        System.abortJob(sc.getTriggerID());
    } 
}