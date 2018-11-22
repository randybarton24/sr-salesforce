global class SRUtilities_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts
{	
	global Database.Querylocator Start(Database.BatchableContext bc) 
	{
		return Database.getQueryLocator('SELECT Id, Subscriber_Id__c, Admin_Account_Id__c FROM Account WHERE Subscriber_Id__c != null AND Admin_Account_Id__c = null');
	}

	global void Execute(Database.BatchableContext BC, Account[] scope) 
	{
		for(Account a : scope)
		{
			a = AppAdminAPIClass.getAccountNumberAndUsername(a);
		}
		
		update scope;
	}

	global void Finish(Database.BatchableContext BC) 
	{
		
	}
}