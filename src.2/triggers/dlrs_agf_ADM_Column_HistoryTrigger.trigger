/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_agf_ADM_Column_HistoryTrigger on agf__ADM_Column_History__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(agf__ADM_Column_History__c.SObjectType);
}