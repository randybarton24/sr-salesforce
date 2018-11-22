global without sharing class BatchAccountIntacctSync implements Database.Batchable<sObject>, Database.AllowsCallouts
{
	SR_Default_Values__c defaultValues = SR_Default_Values__c.getValues('BatchQueryString');

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(defaultValues.Value__c);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) 
	{
		for(Account a : scope)
		{
			IntacctIntegrationAccountToCustomer acctSync = new IntacctIntegrationAccountToCustomer(a.Id);
			acctSync.syncAccountWithIntacct();
		}
	}
			
	global void finish(Database.BatchableContext BC) 
	{

	}
}