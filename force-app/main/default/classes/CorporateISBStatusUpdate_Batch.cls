global class CorporateISBStatusUpdate_Batch implements Database.Batchable<sObject>, Schedulable 
{	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return AccountsSelector.newInstance().queryCorporateISBStatusUpdate_Batch();
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) 
   	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

   		for(Account a :scope)
		{
			Account parentAccount = new Account(Id = a.ParentId,
				RecurSoft__Status__c= 'Active');
			uow.registerDirty(parentAccount);
		}
		uow.commitWork();	
	}
	
	global void finish(Database.BatchableContext BC)
    {
		
	}
	global void execute(SchedulableContext sc) 
	{    
	    CorporateISBStatusUpdate_Batch batchable = new CorporateISBStatusUpdate_Batch();
	    Database.executeBatch(batchable, 200);  
	} 	
}