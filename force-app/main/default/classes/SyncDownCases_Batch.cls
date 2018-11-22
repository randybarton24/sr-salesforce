global class SyncDownCases_Batch implements Database.Batchable<sObject>, Schedulable 
{        
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {    
        return AccountsSelector.newInstance().queryLocatorSyncDown();
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) 
    {            
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        AccountsService.createSyncDownCases(new Map<Id, Account>(scope).keySet(), uow);
        uow.commitWork();
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
    
    global void execute(SchedulableContext sc) 
    {    
        SyncDownCases_Batch batch = new SyncDownCases_Batch();
        Database.executebatch(batch);   
    } 
}