/**
 * Created by mschetselaar on 9/27/2018.
 */

@IsTest
private class PlaybookControllerApxc_Test
{
    @TestSetup
    static void setup_data()
    {
        TestUtilities.newInit();
        Id playbookTask = SRUtilities.getRecordTypeMap('Task').get('Playbook').getRecordTypeId();
    
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
        insert ca;
    
        Task t = new Task();
        t.RecordTypeId = playbookTask;
        t.Subject = 'Test Task';
        t.Status = 'Scheduled';
        t.Priority = 'Normal';
        t.WhatId = ca.Id;
        t.ActivityDate = Date.today().addDays(5);
        insert t;
    
        Playbook__c pb = new Playbook__c();
        pb.Name = 'Test Playbook';
        pb.Survey_to_be_Sent__c = 'Fast Track Survey';
        pb.Active__c = true;
        insert pb;
    
        List<Task> tasks = new List<Task>();
        
        Task t1 = new Task();
        t1.RecordTypeId = playbookTask;
        t1.Subject = 'Test Task';
        t1.Status = 'Scheduled';
        t1.Priority = 'Normal';
        t1.ActivityDate = Date.today().addDays(5);
        t1.Playbook_Number_of_Days__c = 5;
        t1.Playbook_Before_After__c = 'After';
        t1.Playbook_Reference_Date__c = 'Playbook Add Date1';
        t1.WhatId = pb.Id;
        tasks.add(t1);
        
        Task t2 = new Task();
        t2.RecordTypeId = playbookTask;
        t2.Subject = 'Test Task 2';
        t2.Status = 'Scheduled';
        t2.Priority = 'Normal';
        t2.ActivityDate = Date.today().addDays(5);
        t2.Playbook_Number_of_Days__c = 8;
        t2.Playbook_Before_After__c = 'After';
        t2.Playbook_Reference_Date__c = 'Playbook Add Date1';
        t2.WhatId = pb.Id;
        tasks.add(t2);
        insert tasks;
    
    
    }
    
    @IsTest
    static void test_getPlaybookCaseApx()
    {
        Id acctId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Test.startTest();
            List<Case> cases = PlaybookControllerApxc.getPlaybookCaseApx((String) acctId);
        Test.stopTest();
        
        Case c = [SELECT Id, Subject FROM Case LIMIT 1];
        System.assert(cases.size() > 0);
        System.assertEquals(c.Id, cases[0].Id);
        System.assertEquals(c.Subject, cases[0].Subject);
    }
    
    @IsTest
    static void test_getPlaybookAsList()
    {
        Test.startTest();
            List<PlaybookControllerApxc.PicklistOptions> picklistOptions = PlaybookControllerApxc.getPlaybookAsList();
        Test.stopTest();
        
        Playbook__c pb = [SELECT Id, Name FROM Playbook__c LIMIT 1];
        System.assert(picklistOptions.size() > 0);
        System.assertEquals(pb.Id, picklistOptions[0].value);
        System.assertEquals(pb.Name, picklistOptions[0].label);
    }
    
    @IsTest
    static void test_addPlaybookCaseApx()
    {
        Id acctId = [SELECT Id FROM Account LIMIT 1].Id;
        Id playbookId = [SELECT Id FROM Playbook__c LIMIT 1].Id;
        
        Test.startTest();
            PlaybookControllerApxc.addPlaybookCaseApx(acctId, playbookId);
        Test.stopTest();
    
        Case c = [SELECT Id, Subject, Survey_to_be_Sent__c FROM Case WHERE Playbook__r.Id = :playbookId];
        
        System.assert(c!=null);
        System.assertEquals('Test Playbook', c.Subject);
        System.assertEquals('Fast Track Survey', c.Survey_to_be_Sent__c);

    }
    
    @IsTest
    static void test_AddActivityApx()
    {
        Case c = [SELECT Id, AccountId, ContactId, Subject, RecordTypeId, Status, Survey_to_be_Sent__c FROM Case LIMIT 1];
        Task t1 = [SELECT Id FROM Task WHERE WhatId = :c.Id];
        Task t2 = new Task();
            t2.Subject = 'Test Task';
            t2.ActivityDate = Date.today().addDays(5);
        
        Datetime dt = Datetime.now().addDays(3);
        Event e1 = new Event();
        e1.Activity_Type__c = 'General Training';
        e1.DurationInMinutes = 30;
        e1.StartDateTime = dt;
        e1.Subject = 'Test Event';
        
        
        
        Test.startTest();
            PlaybookControllerApxc.AddActivityApx(t1.Id, true, t2, e1, c.Id);
            PlaybookControllerApxc.AddActivityApx(t1.Id, false, t2, e1, c.Id);
        Test.stopTest();
        
        
        List<Task> tasks = [SELECT Id, Subject, ActivityDate FROM Task WHERE Related_Play__c = :(String)t1.Id];
        List<Event> events = [SELECT Id, Subject, StartDateTime, DurationInMinutes, Activity_Type__c FROM Event WHERE Related_Play__c = :(String)t1.Id];
        
        System.assert(tasks.size()>0);
        System.assert(events.size()>0);
        System.assertEquals('General Training', events[0].Activity_Type__c);
        System.assertEquals('Test Task', tasks[0].Subject);
        
    }
    
    @IsTest
    static void test_getAllTasksApx()
    {
        Case c = [SELECT Id, AccountId, ContactId, Subject, RecordTypeId, Status, Survey_to_be_Sent__c FROM Case LIMIT 1];
        Task t = [SELECT Id FROM Task WHERE WhatId = :c.Id];
        Task t2 = new Task();
        t2.Subject = 'Test Task';
        t2.ActivityDate = Date.today().addDays(5);
        t2.Related_Play__c = (String) t.Id;
        t2.WhatId = c.Id;
        insert t2;
        
        Test.startTest();
            List<Task> tasks = PlaybookControllerApxc.getAllTasksApx('' + c.Id,'');
            List<Task> tasks2 = PlaybookControllerApxc.getAllTasksApx('' + c.Id,'' + t.Id);
        Test.stopTest();
        
        Task t1 = [SELECT Id, Subject, Related_Play__c, ActivityDate FROM Task WHERE WhatId = :c.Id AND Related_Play__c = NULL LIMIT 1];
        Task subT1 = [SELECT Id, Subject, Related_Play__c, ActivityDate FROM Task WHERE WhatId = :c.Id AND Related_Play__c = :t1.Id LIMIT 1];
        
        System.assert(t1 != null);
        System.assert(subT1 != null);
        System.assertEquals(t1.Subject,tasks[0].Subject);
        System.assertEquals(subT1.Subject,tasks2[0].Subject);
        System.assertEquals(t1.Id,tasks[0].Id);
        System.assertEquals(subT1.Id,tasks2[0].Id);
        
    }
    
    @IsTest
    static void test_getAllEventsApx()
    {
        Case c = [SELECT Id, AccountId, ContactId, Subject, RecordTypeId, Status, Survey_to_be_Sent__c FROM Case LIMIT 1];
        Task t = [SELECT Id FROM Task WHERE WhatId = :c.Id];
        Event e = new Event();
        e.Subject = 'Test Task';
        e.StartDateTime = DateTime.Now().addDays(5);
        e.DurationInMinutes = 30;
        e.Related_Play__c = (String) t.Id;
        e.WhatId = c.Id;
        insert e;
        
        Test.startTest();
            List<Event> events = PlaybookControllerApxc.getAllEventsApx('' + c.Id, '' + t.Id);
        Test.stopTest();
        
        System.assert(events.size() > 0);
        System.assertEquals(e.Id, events[0].Id);
        System.assertEquals((String) t.Id, events[0].Related_Play__c);
    }
    
    @IsTest
    static void test_updateTasksApx()
    {
        Case c = [SELECT Id, AccountId, ContactId, Subject, RecordTypeId, Status, Survey_to_be_Sent__c FROM Case LIMIT 1];
        Task t = [SELECT Id FROM Task WHERE WhatId = :c.Id];
        
        Test.startTest();
            PlaybookControllerApxc.updateTasksApx('' + t.Id, true);
        Test.stopTest();
        
        Task t1 = [Select Id, Status, WhatId FROM Task LIMIT 1];
        
        System.assertEquals('Completed', t1.Status);
        System.assertEquals(c.Id, t1.WhatId);
    }
    
    @IsTest
    static void test_updateEventApx()
    {
        Case c = [SELECT Id, AccountId, ContactId, Subject, RecordTypeId, Status, Survey_to_be_Sent__c FROM Case LIMIT 1];
        Task t = [SELECT Id FROM Task WHERE WhatId = :c.Id];
        Event e = new Event();
        e.Subject = 'Test Task';
        e.StartDateTime = DateTime.Now().addDays(5);
        e.DurationInMinutes = 30;
        e.Related_Play__c = (String) t.Id;
        e.WhatId = c.Id;
        e.Activity_Results__c = 'Future Event';
        insert e;
        
        Test.startTest();
            PlaybookControllerApxc.updateEventApx('' + e.Id, true);
        Test.stopTest();
        
        Event e1 = [SELECT Id, Activity_Results__c, WhatId FROM Event LIMIT 1];
        
        System.assertEquals('Completed', e1.Activity_Results__c);
        System.assertEquals(c.Id, e1.WhatId);
    }
    
    @IsTest
    static void test_closePlaybookCaseApx()
    {
        Case c = [SELECT Id, AccountId, ContactId, Subject, RecordTypeId, Status, Resolution__c, Resolution_Description__c, Survey_to_be_Sent__c FROM Case LIMIT 1];
        
        Test.startTest();
            PlaybookControllerApxc.closePlaybookCaseApx(c.Id, 'Fixed', 'This should close this case');
        Test.stopTest();
    
        Case c2 = [SELECT Id, AccountId, ContactId, Subject, RecordTypeId, Status, Resolution__c, Resolution_Description__c, Survey_to_be_Sent__c FROM Case LIMIT 1];

        System.assertEquals('Fixed', c2.Resolution__c);
        System.assertEquals('This should close this case', c2.Resolution_Description__c);
        System.assertEquals('Closed', c2.Status);

    }
    
}