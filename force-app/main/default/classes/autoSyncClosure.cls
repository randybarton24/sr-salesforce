global class autoSyncClosure implements Database.Batchable<sObject>, Schedulable {


    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //return Database.getQueryLocator(query);

        return CasesSelector.newInstance().queryLocatorResumedSyncCases();
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope) {

        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        CasesService.autoCloseSyncCases(scope, uow);

        uow.commitWork();
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        
        autoSyncClosure batch = new autoSyncClosure();
        Database.executebatch(batch);   
    } 
}