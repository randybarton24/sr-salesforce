global class ExpireApprovals_Batch implements Database.Batchable<sObject>, Schedulable 
{	
	String query = 'SELECT Id, Approved_Price_Discount__c, Approved_Free_Months__c, Approved_Trial__c, Approved_Term__c ' +
		'FROM OpportunityLineItem ' +
		'WHERE Last_Approved_Date__c != this_month ' + 
		'AND Last_Approved_Date__c != null ' +
		'AND (Approved_Price_Discount__c != null OR Approved_Free_Months__c != null OR Approved_Trial__c != null OR Approved_Term__c != null) ' +
		'AND Opportunity.StageName NOT IN (\'Closed Won\',\'Closed Lost\') ' +
		'AND Opportunity.Owner.Profile.Name LIKE \'%Sales%\'';
		
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope) 
	{
		for(OpportunityLineItem oppLi : scope)
		{
			oppLi.Approved_Price_Discount__c = null;
			oppLi.Approved_Free_Months__c = null;
			oppLi.Approved_Trial__c = null;
			oppLi.Approved_Term__c = null;
		}

		update scope;
	}
			
	global void finish(Database.BatchableContext BC) 
	{

	}

	global void execute(SchedulableContext sc) 
	{	
		ExpireApprovals_Batch batch = new ExpireApprovals_Batch();
		Database.executebatch(batch, 1);
	}
}