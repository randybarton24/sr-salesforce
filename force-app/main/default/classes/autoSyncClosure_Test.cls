@isTest
private class autoSyncClosure_Test {
    
    @testSetup
    static void testData()
    {
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Account a = TestUtilities.insertBasicAccount(true);
        a.Admin_Last_Sync_Date__c = Date.today().addDays(-1);
        a.Admin_Sync_Received__c  = true;
        a.RecordTypeId = accountRecordTypeId;
        update a;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sync List Case').getRecordTypeId();
        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' limit 1].Id;
    
        Case cUser = new Case(AccountId = a.Id,
                Sync_Case_Account__c = a.Id,
                RecordTypeId = caseRecordTypeId,
                Subject = 'Sync Down',
                Status = 'New');
        insert cUser;
    
        Case qUser = new Case(AccountId = a.Id,
                OwnerId = queueId,
                RecordTypeId = caseRecordTypeId,
                Subject = 'Sync Down',
                Status = 'New');
        insert qUser;
    }
    
    @isTest
    static void autoSyncClosureTestBatch()
    {
        Test.startTest();
        
        autoSyncClosure batch = new autoSyncClosure();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        Case[] caseList = [SELECT Id, OwnerId, Last_Sync_Date__c, Account.Admin_Last_Sync_Date__c,IsClosed FROM Case];
        for(Case c : caseList)
        {
            if(c.OwnerId.getSObjectType() == User.SObjectType) System.assert(c.IsClosed);
            if(c.OwnerId.getSObjectType() == Group.SObjectType) System.assert(!c.IsClosed);
        }
    }
    
    @isTest static void autoSyncClosureTestSchedule()
    {
        Test.startTest();
            autoSyncClosure schedule= new autoSyncClosure();
            System.schedule('Test', '0 0 13 * * ?', schedule);
        Test.stopTest();
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size());
    }
    
}