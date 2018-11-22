/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_agf_ADM_Column_HistoryTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_agf_ADM_Column_HistoryTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new agf__ADM_Column_History__c());
    }
}