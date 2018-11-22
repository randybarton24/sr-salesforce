/**
 * Created by mschetselaar on 8/23/2018.
 */

@IsTest
private class Cases_Test {

    @TestSetup
    static void testSetup()
    {
        TestUtilities.newInit();
    }
    
    @isTest
    static void test_onBeforeInsert()
    {
        sfab_FabricatedSObject cFab = TestUtilities2.newCases();

        Case ca = (Case) cFab.toSObject();

        Case existingCase = (Case) TestUtilities2.existingCase(cFab).toSObject();

        Cases cases = new Cases(new List<Case>{ ca });
        Cases.onBeforeInsert();

    }

    @isTest
    static void test_onBeforeUpdate()
    {
        sfab_FabricatedSObject cFab = TestUtilities2.newCases();

        Case ca = (Case) cFab.toSObject();

        Case existingCase = (Case) TestUtilities2.existingCase(cFab).toSObject();

        Cases cases = new Cases(new List<Case> { ca});
        Map<Id, SObject> caseMap = new Map<Id, SObject>( new List<Case>{ ca });
        Cases.onBeforeUpdate(caseMap);
    }

    @isTest
    static void test_createSurvey_NoContacts()
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();  
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Account acct = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject cFab = TestUtilities2.newCases()
            .setField(Case.AccountId, acct.Id)
            .setField(Case.Subject, 'Test')
            .setField(Case.RecordTypeId, SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId())
            .setField(Case.Status, 'Closed')
            .setField(Case.Survey_Sent__c, false)
            .setField(Case.Resolution__c, 'Fixed');

        Case c = (Case) cFab.toSObject();

        AccountsSelector mockSelector = (AccountsSelector) mocks.mock(AccountsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
            .thenReturn(Account.SObjectType);
        mocks.when(mockSelector.selectByIdWithContacts(new List<Case>{ c }))
            .thenReturn(new Map<Id, Account>(new List<Account>{ acct }));
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        Cases cases = new Cases(new List<Case>{ c });
        cases.createSurvey(c, null, uow);
        System.assertEquals(0, uow.m_newListByType.get('Survey__c').size());
    }

    @isTest
    static void test_createSurvey_NoStatusChange()
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();  
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        sfab_FabricatedSObject conFab = TestUtilities2.newContact()
            .setField(Contact.FirstName, 'Test')
            .setField(Contact.LastName, 'Last')
            .setField(Contact.Survey_Opt_Out__c, false)
            .setField(Contact.Email, 'test@test.com'); 

        Contact con = (Contact) conFab.toSObject();

        Account acct = (Account) TestUtilities2.newAccount()
            .setField(Account.RecurSoft__Status__c, 'Active')
            .setChildren('Contacts', new List<sfab_FabricatedSObject> { conFab })
            .toSObject();

        sfab_FabricatedSObject cFab = TestUtilities2.newCases()
            .setField(Case.AccountId, acct.Id)
            .setField(Case.ContactId, con.Id)
            .setField(Case.Subject, 'Test')
            .setField(Case.RecordTypeId, SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId())
            .setField(Case.Status, 'Closed')
            .setField(Case.Survey_Sent__c, false)
            .setField(Case.Resolution__c, 'Fixed');

        Case c = (Case) cFab.toSObject();
        Case existingCase = (Case) TestUtilities2.existingCase(cFab)
            .setField(Case.Status, 'Closed')
            .toSObject();

        AccountsSelector mockSelector = (AccountsSelector) mocks.mock(AccountsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
            .thenReturn(Account.SObjectType);
        mocks.when(mockSelector.selectByIdWithContacts(new List<Case>{ c }))
            .thenReturn(new Map<Id, Account>(new List<Account>{ acct }));
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        Cases cases = new Cases(new List<Case>{ c });
        cases.createSurvey(c, existingCase, uow);

        System.assertEquals(0, uow.m_newListByType.get('Survey__c').size());
    }
    @IsTest
    static void test_createSurvey_SupportCase()
    {
//        TestUtilities.newInit();

        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Last';
        con.Survey_Opt_Out__c = false;
        con.AccountId = a.Id;
        con.Email = 'test@test.com';
        insert con;

        Case ca = new Case();
        ca.AccountId = a.Id;
        ca.ContactId = con.Id;
        ca.Subject = 'Test';
        ca.RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId();
        ca.Status = 'New';
        ca.Survey_Sent__c = false;
        insert ca;

        ca.Status = 'Closed';
        ca.Resolution__c = 'Fixed';
        ca.Category__c = 'Sync';
        ca.Product__c = 'Sync Filters';

        Test.startTest();
            Database.SaveResult sr = Database.update(ca);
        Test.stopTest();

        Survey__c[] surveys = [SELECT Id, Business_Name__c, Contact_Name__c, Contact_Email__c, RecordTypeId FROM Survey__c];
        Id postCaseSurvey = SRUtilities.getRecordTypeMap('Survey__c').get('Post Case Survey').getRecordTypeId();

        System.assert(sr.isSuccess());
        System.assertEquals(1,surveys.size());
        System.assertEquals(a.Id,surveys[0].Business_Name__c);
        System.assertEquals(con.Id,surveys[0].Contact_Name__c);
        System.assertEquals('test@test.com', surveys[0].Contact_Email__c);
        System.assertEquals(postCaseSurvey, surveys[0].RecordTypeId);

    }

    @IsTest
    static void test_createSurvey_FastTrackCase()
    {
//        TestUtilities.newInit();

        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Last';
        con.Survey_Opt_Out__c = false;
        con.AccountId = a.Id;
        con.Email = 'test@test.com';
        insert con;

        Case ca = new Case();
        ca.AccountId = a.Id;
        ca.ContactId = con.Id;
        ca.Subject = 'Test';
        ca.RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Playbook').getRecordTypeId();
        ca.Status = 'New';
        ca.Survey_Sent__c = false;
        ca.Survey_to_be_Sent__c = 'Fast Track Survey';
        insert ca;

        ca.Status = 'Closed';
        ca.Resolution__c = 'Fixed';

        Test.startTest();
        Database.SaveResult sr = Database.update(ca);
        Test.stopTest();

        Survey__c[] surveys = [SELECT Id, Business_Name__c, Contact_Name__c, Contact_Email__c, RecordTypeId FROM Survey__c];
        Id postCaseSurvey = SRUtilities.getRecordTypeMap('Survey__c').get('Playbook Case Survey').getRecordTypeId();

        System.assert(sr.isSuccess());
        System.assertEquals(1,surveys.size());
        System.assertEquals(a.Id,surveys[0].Business_Name__c);
        System.assertEquals(con.Id,surveys[0].Contact_Name__c);
        System.assertEquals('test@test.com', surveys[0].Contact_Email__c);
        System.assertEquals(postCaseSurvey, surveys[0].RecordTypeId);

    }

    @IsTest
    static void test_createSurvey_EBRCase()
    {
//        TestUtilities.newInit();

        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Last';
        con.Survey_Opt_Out__c = false;
        con.AccountId = a.Id;
        con.Email = 'test@test.com';
        insert con;

        Case ca = new Case();
        ca.AccountId = a.Id;
        ca.ContactId = con.Id;
        ca.Subject = 'Test';
        ca.RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Playbook').getRecordTypeId();
        ca.Status = 'New';
        ca.Survey_Sent__c = false;
        ca.Survey_to_be_Sent__c = 'EBR Case Survey';
        insert ca;

        ca.Status = 'Closed';
        ca.Resolution__c = 'Fixed';

        Test.startTest();
            Database.SaveResult sr = Database.update(ca);
        Test.stopTest();

        Survey__c[] surveys = [SELECT Id, Business_Name__c, Contact_Name__c, Contact_Email__c, RecordTypeId FROM Survey__c];
        Id postCaseSurvey = SRUtilities.getRecordTypeMap('Survey__c').get('EBR Case Survey').getRecordTypeId();

        System.assert(sr.isSuccess());
        System.assertEquals(1,surveys.size());
        System.assertEquals(a.Id,surveys[0].Business_Name__c);
        System.assertEquals(con.Id,surveys[0].Contact_Name__c);
        System.assertEquals('test@test.com', surveys[0].Contact_Email__c);
        System.assertEquals(postCaseSurvey, surveys[0].RecordTypeId);

    }

    @IsTest
    static void test_closePlaybookTasks()
    {
        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;
        
        Case ca = new Case();
        ca.AccountId = a.Id;
        ca.Subject = 'Test';
        ca.RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Playbook').getRecordTypeId();
        ca.Status = 'New';
        ca.Survey_Sent__c = false;
        insert ca;
    
        Id playbookTask = SRUtilities.getRecordTypeMap('Task').get('Playbook').getRecordTypeId();
        Task t = new Task();
        t.RecordTypeId = playbookTask;
        t.Subject = 'Test Task';
        t.Status = 'Scheduled';
        t.Priority = 'Normal';
        t.WhatId = ca.Id;
        t.ActivityDate = Date.today().addDays(5);
        insert t;
    
        ca.Status = 'Closed';
        ca.Resolution__c = 'Fixed';
        
        Test.startTest();
            Database.SaveResult sr = Database.update(ca);
        Test.stopTest();
        
        Task t1 = [SELECT Id, Subject, Status FROM Task LIMIT 1];
    
        System.assert(sr.isSuccess());
        System.assertEquals('Closed - Not Completed', t1.Status);
    }
}