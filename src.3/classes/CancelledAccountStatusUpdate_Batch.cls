global class CancelledAccountStatusUpdate_Batch implements Database.Batchable<sObject>, Schedulable 
{        
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {    
        return CancelRequestsSelector.newInstance().queryLocatorCancelledAccounts();
    }
    
    global void execute(Database.BatchableContext BC, List<Cancel_Request__c> scope)
    {            
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        AccountsService.updateCancelledISBStatus(scope, uow);
        CasesService.closeCancelledAccountsCases(scope, uow);

        uow.commitWork();
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
    
    global void execute(SchedulableContext sc) 
    {    
        CancelledAccountStatusUpdate_Batch batch = new CancelledAccountStatusUpdate_Batch();
        Database.executebatch(batch);   
    } 
}