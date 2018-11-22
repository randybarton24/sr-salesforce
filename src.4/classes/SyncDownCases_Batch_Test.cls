/**
 * Created by mschetselaar on 10/4/2018.
 */

@IsTest
private class SyncDownCases_Batch_Test
{
    @TestSetup
    static void testData()
    {
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child Major Account').getRecordTypeId();
        Id majorAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Major Account').getRecordTypeId();
        Id independentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Account a = TestUtilities.insertBasicAccount(true);
        a.Admin_Last_Sync_Date__c = Date.today().addDays(-5);
        a.Admin_Sync_Received__c  = false;
        a.Do_Not_Support_Sync__c = false;
        a.of_Open_Sync_Cases__c = 0;
        a.RecordTypeId = accountRecordTypeId;
        a.RecurSoft__Status__c = 'Active';
        
        Account pAccount = new Account();
        pAccount.Name = 'Parent Account';
        pAccount.RecordTypeId = majorAccountId;
        pAccount.Industry = 'Dental';
        pAccount.RecurSoft__Intacct_Entity__c = 'a1Ai0000001ctUXEAY';
        
        Account independentAccount = new Account(
                Name = 'Independent Account',
                Industry = 'Dental',
                RecurSoft__Intacct_Entity__c = 'a1Ai0000001ctUXEAY',
                Admin_Last_Sync_Date__c = Date.today().addDays(-5),
                Admin_Sync_Received__c  = false,
                Do_Not_Support_Sync__c = false,
                of_Open_Sync_Cases__c = 0,
                RecordTypeId = independentRecordTypeId,
                RecurSoft__Status__c = 'Active'
        );
        
        Id syncCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sync List Case').getRecordTypeId();
        Case entSyncCase = new Case(
                RecordTypeId = syncCase,
                Subject = 'Test SYnc Case',
                Status = 'Assigned'
        );
        
        insert independentAccount;
        insert pAccount;
        a.ParentId = pAccount.Id;
        entSyncCase.AccountId = pAccount.Id;
        
        update a;
        
        User[] techUsers = [SELECT Id, Name FROM User WHERE UserRole.Name = 'CSR - Tech' AND IsActive = TRUE LIMIT 5];
        Distribution_Group__c ind = new Distribution_Group__c(Name = 'Testing' ,
                Distribution_Type__c = 'Load Balanced',
                Relationship_Criteria__c = 'IsClosed = false',
                ParentObject__c = 'Case',
                Field_to_Distribute__c = 'OwnerId');
        Distribution_Group__c ent = new Distribution_Group__c(Name = 'Testing Ent' ,
                Distribution_Type__c = 'Load Balanced',
                Relationship_Criteria__c = 'IsClosed = false',
                ParentObject__c = 'Case',
                Field_to_Distribute__c = 'OwnerId');
        List<Distribution_Group__c> groups = new List<Distribution_Group__c>();
        groups.add(ind);
        groups.add(ent);
        insert groups;
        
        List<SR_Default_Values__c> srDefaults = new List<SR_Default_Values__c>();
        SR_Default_Values__c indTechReps = new SR_Default_Values__c(Name='IND Sync Dist Group Id', Value__c = '' + ind.Id, Description__c = 'Test for Ind');
        SR_Default_Values__c entTechReps = new SR_Default_Values__c(Name='ENT Sync Dist Group Id', Value__c = '' + ent.Id, Description__c = 'Test for Ent');
        srDefaults.add(indTechReps);
        srDefaults.add(entTechReps);
        insert srDefaults;
        
        List<Distribution_Group_Member__c> members = new List<Distribution_Group_Member__c>();
        Distribution_Group_Member__c r1 = new Distribution_Group_Member__c(Distribution_Group__c = ind.Id,
                User__c = techUsers[0].Id,
                Rep_Limit__c = 5,
                Available__c = true,
                Next_Up__c = true);
        members.add(r1);
        Distribution_Group_Member__c r2 = new Distribution_Group_Member__c(Distribution_Group__c = ind.Id,
                User__c = techUsers[1].Id,
                Rep_Limit__c = 5,
                Available__c = true,
                Next_Up__c = false);
        members.add(r2);
        Distribution_Group_Member__c r3 = new Distribution_Group_Member__c(Distribution_Group__c = ent.Id,
                User__c = techUsers[2].Id,
                Rep_Limit__c = 5,
                Available__c = true,
                Next_Up__c = true);
        members.add(r3);
        Distribution_Group_Member__c r4 = new Distribution_Group_Member__c(Distribution_Group__c = ent.Id,
                User__c = techUsers[3].Id,
                Rep_Limit__c = 5,
                Available__c = true,
                Next_Up__c = false);
        members.add(r4);
        insert members;
        
        entSyncCase.OwnerId = techUsers[3].Id;
        insert entSyncCase;
    }
    
    @IsTest
    static void test_SyncDownCases_Batch()
    {
        Test.startTest();
        SyncDownCases_Batch batch = new SyncDownCases_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        Id majorAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Major Account').getRecordTypeId();
        Id independentAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Case[] cases = [SELECT Id, AccountId, Account.ParentId, Status, OwnerId FROM Case WHERE Account.RecordTypeId = :majorAccountId AND Status = 'New'];
        Case[] casesIndependent = [SELECT Id, AccountId, Account.ParentId, Status, OwnerId FROM Case WHERE Account.RecordTypeId = :independentAccountId];
        Account acct = [SELECT Id FROM Account WHERE RecordTypeId = :majorAccountId LIMIT 1];
        Account acct2 = [SELECT Id FROM Account WHERE RecordTypeId = :independentAccountId LIMIT 1];
        
        Id DistId = (Id)[SELECT Value__c FROM SR_Default_Values__c WHERE Name = 'IND Sync Dist Group Id' LIMIT 1].Value__c;
        Distribution_Group_Member__c[] roundRobinsInd = [SELECT Id,
                User__c,
                Load__c,
                Distribution_Group__r.Name,
                Name
        FROM Distribution_Group_Member__c
        WHERE Distribution_Group__c = :DistId
        ORDER BY Load__c];
        Id entDistId = (Id)[SELECT Value__c FROM SR_Default_Values__c WHERE Name = 'ENT Sync Dist Group Id' LIMIT 1].Value__c;
        Distribution_Group_Member__c[] roundRobinsEnt = [SELECT Id,
                User__c,
                Load__c,
                Distribution_Group__c,
                Name
        FROM Distribution_Group_Member__c
        WHERE Distribution_Group__c = :entDistId
        ORDER BY Load__c];
        
        Distribution_Group__c dg = [SELECT Id, Name, Distribution_Type__c FROM Distribution_Group__c WHERE Id = :roundRobinsEnt[0].Distribution_Group__c];
        
        System.assert(cases.size()>0);
        System.assertEquals(acct.Id, cases[0].AccountId);
        System.assertEquals((Id)roundRobinsEnt[1].User__c,cases[0].OwnerId);
        System.assert(casesIndependent.size()>0);
        System.assertEquals(acct2.Id, casesIndependent[0].AccountId);
        System.assertEquals((Id)roundRobinsInd[1].User__c,casesIndependent[0].OwnerId);
    }
    
    @IsTest
    static void test_SyncDownCases_Batch_New_Account()
    {
        List<Case> syncCases = [SELECT Id FROM Case];
        delete syncCases;
        
        Test.startTest();
        SyncDownCases_Batch batch = new SyncDownCases_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        Id majorAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Major Account').getRecordTypeId();
        Case[] cases = [SELECT Id, AccountId, Account.ParentId, Status, OwnerId FROM Case WHERE Account.RecordTypeId = :majorAccountId AND Status = 'New'];
        Id entDistId = (Id)[SELECT Value__c FROM SR_Default_Values__c WHERE Name = 'ENT Sync Dist Group Id' LIMIT 1].Value__c;
        Distribution_Group_Member__c[] roundRobinsEnt = [SELECT Id,
                User__c,
                Load__c,
                Distribution_Group__c,
                Name
        FROM Distribution_Group_Member__c
        WHERE Distribution_Group__c = :entDistId
        ORDER BY Load__c];
        System.assert(cases.size()>0);
        System.assertEquals(roundRobinsEnt[1].User__c,cases[0].OwnerId);
    
    }
    
    @IsTest static void test_SyncDownCases_Batch_existing_Account()
    {
        Case syncCase = [SELECT Id, OwnerId FROM Case LIMIT 1];
        Id entDistId = (Id)[SELECT Value__c FROM SR_Default_Values__c WHERE Name = 'ENT Sync Dist Group Id' LIMIT 1].Value__c;
        Distribution_Group_Member__c[] roundRobinsEnt = [SELECT Id,
                User__c,
                Load__c,
                Distribution_Group__c,
                Name
        FROM Distribution_Group_Member__c
        WHERE Distribution_Group__c = :entDistId
        ORDER BY Load__c];
        syncCase.OwnerId = roundRobinsEnt[1].User__c;
        
        update syncCase;
        
        Test.startTest();
        SyncDownCases_Batch batch = new SyncDownCases_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        Id majorAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Major Account').getRecordTypeId();
        Case[] cases = [SELECT Id, AccountId, Account.ParentId, Status, OwnerId FROM Case WHERE Account.RecordTypeId = :majorAccountId AND Status = 'New'];
        
        System.assert(cases.size()>0);
        System.assertEquals(roundRobinsEnt[1].User__c,cases[0].OwnerId);
    
    }
    
    @isTest static void SyncDownCases_Batch_Test_Schedule()
    {
        
        SyncDownCases_Batch schedule = new SyncDownCases_Batch();
        Test.startTest();
        System.schedule('Test', '0 0 13 * * ?', schedule);
        Test.stopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size());
    
    }
}