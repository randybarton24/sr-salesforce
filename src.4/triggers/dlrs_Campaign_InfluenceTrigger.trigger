/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Campaign_InfluenceTrigger on Campaign_Influence__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    if(!FlowControl.suppressRollup) dlrs.RollupService.triggerHandler();
}