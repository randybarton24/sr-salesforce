/**
 * File:        IntacctIntegrationScheduler_Test.cls
 * Project:     Sererra 
 * Date:        May 6, 2014
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Test class for IntacctIntegrationScheduler
 * *************************************************************************
 * History:
 */
@isTest
public class IntacctIntegrationScheduler_Test 
{
    private static final String CRON_EXPRESSION = '0 0 1 ? * 1-7 *';
    private static final String JOB_NAME = 'Test SCHEDULE';
    private static testMethod void testScheduledJob() 
    {
        test.StartTest();
        String jobId = System.schedule(JOB_NAME, CRON_EXPRESSION, new IntacctIntegrationScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger  WHERE id = :jobId];
        
        System.assertEquals(CRON_EXPRESSION , ct.CronExpression);
        test.stopTest();
    }
}