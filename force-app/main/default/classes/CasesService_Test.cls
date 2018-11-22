/**
 * Created by mschetselaar on 8/21/2018.
 */

@IsTest
private class CasesService_Test {
    @testSetup
    static void testData()
    {
        TestUtilities.newInit();
    }

    @isTest
    static void test_closeCancelledAccountsCases()
    {
        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;
        
        RecurSoft__Product_Subscription__c ps = [SELECT Id, RecurSoft__Contract_Term_Start_Date__c FROM RecurSoft__Product_Subscription__c LIMIT 1];
        ps.RecurSoft__Contract_Term_Start_Date__c = Date.today().addDays(-50);
        update ps;
        
        Cancel_Request__c cr = [SELECT Id, Stage__c, Cancel_Month__c FROM Cancel_Request__c LIMIT 1];
        cr.Stage__c = 'Cancelled';
        cr.Cancel_Month__c = Date.today().toStartOfMonth();
        update cr;

        Id supportCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Id accountCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Accounting').getRecordTypeId();
        Id syncCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sync List Case').getRecordTypeId();
        Id crCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cancel Request').getRecordTypeId();

        List<Case> caseList = new List<Case>();
        for(Integer i = 0; i<4; i++) {
            Case c = new Case(Subject = 'Test Support Case',
                    AccountId = a.Id,
                    Status = 'New',
                    RecordTypeId = i == 0 ? supportCase : i==1 ? accountCase : i == 2 ? syncCase : crCase);
            caseList.add(c);
        }
        insert caseList;

        List<Cancel_Request__c> cros = [
                SELECT
                        Id,
                        Stage__c,
                        Cancel_Month__c,
                        Opportunity__c,
                        Opportunity__r.AccountId,
                        Asset__c,
                        Asset__r.Current_Product_Subscription__r.RecurSoft__Contract_Term_Start_Date__c
                FROM Cancel_Request__c];
        
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Test.startTest();

        CasesService.closeCancelledAccountsCases(cros, uow);
        uow.commitWork();

        Test.stopTest();

        List<Case> updateCaseList = [SELECT Id, Status, Resolution__c, RecordTypeId FROM Case];
        for (Case newCase : updateCaseList)
        {
            if(newCase.RecordTypeId == supportCase || newCase.RecordTypeId == syncCase)
            {
                System.assertEquals('Closed', newCase.Status, 'The Case Was not Closed');
                System.assertEquals('Wont Fix', newCase.Resolution__c);
                System.debug(newCase);
            } else
            {
                System.assertEquals('New', newCase.Status, 'The Case Was not Closed');
                System.debug(newCase);
            }
        }
    }
    
    @isTest
    static void test_closeCancelledAccountsCases_Reactivate()
    {
        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;
        
        RecurSoft__Product_Subscription__c ps = [SELECT Id, RecurSoft__Contract_Term_Start_Date__c FROM RecurSoft__Product_Subscription__c LIMIT 1];
        ps.RecurSoft__Contract_Term_Start_Date__c = Date.today();
        update ps;
        
        Cancel_Request__c cr = [SELECT Id, Stage__c, Cancel_Month__c FROM Cancel_Request__c LIMIT 1];
        cr.Stage__c = 'Cancelled';
        cr.Cancel_Month__c = Date.today().toStartOfMonth().addMonths(-1);
        update cr;
        
        Id supportCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Id accountCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Accounting').getRecordTypeId();
        Id syncCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sync List Case').getRecordTypeId();
        Id crCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cancel Request').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        for(Integer i = 0; i<4; i++) {
            Case c = new Case(Subject = 'Test Support Case',
                    AccountId = a.Id,
                    Status = 'New',
                    RecordTypeId = i == 0 ? supportCase : i==1 ? accountCase : i == 2 ? syncCase : crCase);
            caseList.add(c);
        }
        insert caseList;
    
        List<Cancel_Request__c> cros = [
                SELECT
                        Id,
                        Stage__c,
                        Cancel_Month__c,
                        Opportunity__c,
                        Opportunity__r.AccountId,
                        Asset__c,
                        Asset__r.Current_Product_Subscription__r.RecurSoft__Contract_Term_Start_Date__c
                FROM Cancel_Request__c];
    
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Test.startTest();
            CasesService.closeCancelledAccountsCases(cros, uow);
            uow.commitWork();
        Test.stopTest();
        
        List<Case> updateCaseList = [SELECT Id, Status, Resolution__c, RecordTypeId, RecordType.Name FROM Case];
        for (Case newCase : updateCaseList)
        {
            System.assertEquals('New', newCase.Status, 'The Case Was Closed');
        }
    }

    @IsTest
    static void test_autoCloseSyncCases()
    {
        Account a = [SELECT Id, RecurSoft__Status__c, Admin_Last_Sync_Date__c, Admin_Sync_Received__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        a.Admin_Last_Sync_Date__c = Date.today().addDays(-1);
        a.Admin_Sync_Received__c = true;
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

        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Case> caseList = [SELECT Id, OwnerId, RecordTypeId, Subject, Status, Sync_Case_Account__c, Sync_Case_Account__r.Admin_Last_Sync_Date__c, Sync_Case_Account__r.Admin_Sync_Received__c FROM Case];


        Test.startTest();
            CasesService.autoCloseSyncCases(caseList, uow);
            uow.commitWork();
        Test.stopTest();


        Case[] newCaseList = [SELECT Id, OwnerId, Last_Sync_Date__c, Sync_Case_Account__r.Admin_Last_Sync_Date__c,IsClosed FROM Case];
        for(Case c : newCaseList)
        {
            if(c.OwnerId.getSObjectType() == User.SObjectType) System.assert(c.IsClosed);
            if(c.OwnerId.getSObjectType() == Group.SObjectType) System.assert(!c.IsClosed);
        }
    }
    
    @IsTest
    static void test_autoCloseSyncCases_Enterprise()
    {
        Id childMajorAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child Major Account').getRecordTypeId();
        Id majorAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Major Account').getRecordTypeId();
        Account a = [SELECT Id, RecurSoft__Status__c, Admin_Last_Sync_Date__c, Admin_Sync_Received__c FROM Account LIMIT 1];
        a.RecordTypeId = childMajorAccountId;
        a.RecurSoft__Status__c = 'Active';
        a.Admin_Last_Sync_Date__c = Date.today().addDays(-1);
        a.Admin_Sync_Received__c = true;
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent Account';
        parentAccount.RecordTypeId = majorAccountId;
//        parentAccount.Practice_Management_Software__c = 'a00i000000Mq9oBAAR';
        parentAccount.Industry = 'Dental';
        parentAccount.RecurSoft__Intacct_Entity__c = 'a1Ai0000001ctUXEAY';
        
        insert parentAccount;
        a.ParentId = parentAccount.Id;
        update a;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sync List Case').getRecordTypeId();
        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' limit 1].Id;
        
        Case cUser = new Case(AccountId = parentAccount.Id,
                RecordTypeId = caseRecordTypeId,
                Subject = 'Sync Down',
                Status = 'New',
                Sync_Case_Account__c = a.Id);
        insert cUser;
        
        Case qUser = new Case(AccountId = parentAccount.Id,
                OwnerId = queueId,
                RecordTypeId = caseRecordTypeId,
                Subject = 'Sync Down',
                Status = 'New',
                Sync_Case_Account__c = a.Id);
        insert qUser;
        
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Case> caseList = [SELECT Id, OwnerId, RecordTypeId, Subject, Status, Sync_Case_Account__c, Sync_Case_Account__r.Admin_Last_Sync_Date__c, Sync_Case_Account__r.Admin_Sync_Received__c FROM Case];
        
        
        Test.startTest();
            CasesService.autoCloseSyncCases(caseList, uow);
            uow.commitWork();
        Test.stopTest();
        
        
        Case[] newCaseList = [SELECT Id, OwnerId, Last_Sync_Date__c, Sync_Case_Account__r.Admin_Last_Sync_Date__c,IsClosed FROM Case];
        for(Case c : newCaseList)
        {
            if(c.OwnerId.getSObjectType() == User.SObjectType) System.assert(c.IsClosed);
            if(c.OwnerId.getSObjectType() == Group.SObjectType) System.assert(!c.IsClosed);
        }
    }
}