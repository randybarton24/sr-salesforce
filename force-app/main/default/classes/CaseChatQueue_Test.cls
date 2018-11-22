/**
 * Created by abishop on 11/6/18.
 */

@IsTest
public with sharing class CaseChatQueue_Test
{
    @TestSetup static void testSetup()
    {
        Group newGroup = [SELECT Id FROM Group WHERE Name = 'Chat Bot Case Queue' LIMIT 1];

        SR_Default_Values__c srdv = new SR_Default_Values__c();
        srdv.Name = 'ChatBotQueueId';
        srdv.Description__c = 'Test';
        srdv.Value__c = newGroup.Id;
        insert srdv;

        Group csSupport = [SELECT Id FROM Group WHERE Name = 'CS Support Queue' LIMIT 1];
        
        SR_Default_Values__c srdv1 = new SR_Default_Values__c();
        srdv1.Name = 'CS Support Queue';
        srdv1.Description__c = 'Test';
        srdv1.Value__c = csSupport.Id;
        insert srdv1;

        Case c = new Case();
        c.Subject = 'Test';
        c.OwnerId = newGroup.Id;
        insert c;
    }

    @IsTest static void caseChatQueueOwner_Test()
    {
        Test.startTest();
        caseChatQueue batch = new caseChatQueue();
        Database.executeBatch(batch);
        Test.stopTest();

        Case chatCase = [SELECT Id, OwnerId FROM Case LIMIT 1 ];
        Id csSupportQueue  = (Id) SR_Default_Values__c.getValues('CS Support Queue').Value__c;
        System.assertEquals (csSupportQueue, chatCase.OwnerId);
    }

    @isTest static void caseChatQueue_Test_Schedule()
    {

        caseChatQueue schedule = new caseChatQueue();
        Test.startTest();
        System.schedule('Test', '0 0 13 * * ?', schedule);
        Test.stopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size());

    }

}