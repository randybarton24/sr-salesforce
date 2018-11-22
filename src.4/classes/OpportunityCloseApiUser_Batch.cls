global class OpportunityCloseApiUser_Batch implements Database.Batchable<sObject>,Schedulable 
{	
	global OpportunityCloseApiUser_Batch() 
	{
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return OpportunitiesSelector.newInstance().queryOpportunityCloseApiUser_Batch();
	}

   	global void execute(Database.BatchableContext BC, List<Opportunity> scope) 
   	{        
   		for (Opportunity o :scope)
		{
			o.StageName = 'Closed Lost';
			o.Reason_for_closing__c = 'Auto Close';
		}
		update scope;		
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		
	}

	global void execute(SchedulableContext sc) 
	{    
	    OpportunityCloseApiUser_Batch batchable = new OpportunityCloseApiUser_Batch();
	    Database.executeBatch(batchable, 1);  
	} 	
}