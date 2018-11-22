/**
 * Created by abishop on 11/5/18.
 */

global class  caseChatQueue implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return CasesSelector.newInstance().selectChatCaseQueue();
    }

    global void execute(Database.BatchableContext BC, List<Case> scope)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CasesService.chatCaseQueue(new Map<Id, Case>(scope), uow);
        uow.commitWork();
    }

    global void finish(Database.BatchableContext BC)
    {

    }

    global void execute(SchedulableContext sc)
    {
        caseChatQueue batch = new caseChatQueue();
        Database.executebatch(batch);
    }
}