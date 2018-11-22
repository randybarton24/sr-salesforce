@isTest
private class tst_activationSLATaskEvent {
    
    @isTest static void noWhatTask() {
        generateData();
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Task t = new Task();
        t.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Support Task' and SobjectType = 'Task' LIMIT 1].Id;
        t.Subject = 'Testing no what id';
        t.ActivityDate = Date.today();
        t.WhoId = c.Id;
        insert t;
    }
    
    @isTest static void wrongWhatTask() {
        generateData();
        Account a = [SELECT Id FROM Account LIMIT 1];
        Task t = new Task();
        t.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Support Task' and SobjectType = 'Task' LIMIT 1].Id;
        t.Subject = 'Testing wrong what id';
        t.ActivityDate = Date.today();
        t.WhatId = a.Id;
        insert t;
    }

    @isTest static void graphics() {
        generateData();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Task t = new Task();
        t.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Support Task' and SobjectType = 'Task' LIMIT 1].Id;
        t.Subject = 'Testing graphics';
        t.ActivityDate = Date.today();
        t.WhatId = c.Id;
        t.Activity_Type__c = 'Graphics Setup';
        insert t;
        c = [SELECT Id, First_Contact__c, Graphics_Task_Claimed__c FROM Case WHERE Id = :c.Id];
        System.assertEquals(c.First_Contact__c, null);
        System.assertNotEquals(c.Graphics_Task_Claimed__c, null);
        t.Activity_Results__c = 'Completed';
        update t;
        c = [SELECT Id, Graphics_Task_Completed__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Graphics_Task_Completed__c, null);
    }
    
    @isTest static void training() {
        generateData();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Task t = new Task();
        t.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Support Task' and SobjectType = 'Task' LIMIT 1].Id;
        t.Subject = 'Testing training';
        t.ActivityDate = Date.today();
        t.Training_Date_Time__c = Datetime.now();
        t.WhatId = c.Id;
        t.Activity_Type__c = 'Training';
        insert t;
        c = [SELECT Id, Training_Scheduled__c, Training_Scheduled_For__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Training_Scheduled__c, null);
        System.assertNotEquals(c.Training_Scheduled_For__c, null);
        t.Activity_Results__c = 'Completed';
        update t;
        c = [SELECT Id, Training_Completed__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Training_Completed__c, null);
    }

    @isTest static void firstContact() {
        generateData();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Task t = new Task();
        t.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Support Task' and SobjectType = 'Task' LIMIT 1].Id;
        t.Subject = 'Testing first contact';
        t.ActivityDate = Date.today();
        t.WhatId = c.Id;
        t.Activity_Type__c = 'Outbound Call';
        t.Status = 'Completed';
        insert t;
        c = [SELECT Id, First_Contact__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.First_Contact__c, null);
    }
    
    
    @isTest static void noWhatEvent() {
        generateData();
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Event e = new Event();
        e.WhoId = c.Id;
        e.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Support Event' and SobjectType = 'Event' LIMIT 1].Id;
        e.Subject = 'Event no what id';
        e.StartDateTime = Datetime.now();
        e.EndDateTime = Datetime.now().addMinutes(60);
        insert e;
    }
    
    @isTest static void wrongWhatEvent() {
        generateData();
        Account a = [SELECT Id FROM Account LIMIT 1];
        Event e = new Event();
        e.WhatId = a.Id;
        e.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Support Event' and SobjectType = 'Event' LIMIT 1].Id;
        e.Subject = 'Event no what id';
        e.StartDateTime = Datetime.now();
        e.EndDateTime = Datetime.now().addMinutes(60);
        insert e;
    }

    @isTest static void syncInstall() {
        generateData();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Event e = new Event();
        e.WhatId = c.Id;
        e.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Onboarding Event' and SobjectType = 'Event' LIMIT 1].Id;
        e.Subject = 'Event sync';
        e.StartDateTime = Datetime.now();
        e.EndDateTime = Datetime.now().addMinutes(60);
        e.Activity_Type__c = 'Sync Install';
        insert e;
        c = [SELECT Id, Sync_Install_Scheduled__c, Sync_Install_Scheduled_For__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Sync_Install_Scheduled__c, null);
        System.assertNotEquals(c.Sync_Install_Scheduled_For__c, null);
        e.Event_Status__c = 'Completed';
        e.Activity_Results__c = 'Completed';
        update e;
        c = [SELECT Id, Sync_Install_Completed__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Sync_Install_Completed__c, null);
    }
    
    @isTest static void customSettings() {
        generateData();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Event e = new Event();
        e.WhatId = c.Id;
        e.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Onboarding Event' and SobjectType = 'Event' LIMIT 1].Id;
        e.Subject = 'Event settings';
        e.StartDateTime = Datetime.now();
        e.EndDateTime = Datetime.now().addMinutes(60);
        e.Activity_Type__c = 'Custom Settings';
        insert e;
        c = [SELECT Id, Custom_Settings_Scheduled__c, Custom_Settings_Scheduled_For__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Custom_Settings_Scheduled__c, null);
        System.assertNotEquals(c.Custom_Settings_Scheduled_For__c, null);
        e.Event_Status__c = 'Completed';
        e.Activity_Results__c = 'Completed';
        update e;
        c = [SELECT Id, Custom_Settings_Completed__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Custom_Settings_Completed__c, null);
    }
    
       @isTest static void kickoff() {
        generateData();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Event e = new Event();
        e.WhatId = c.Id;
        e.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Onboarding Event' and SobjectType = 'Event' LIMIT 1].Id;
        e.Subject = 'Kickoff Call';
        e.StartDateTime = Datetime.now();
        e.EndDateTime = Datetime.now().addMinutes(60);
        e.Activity_Type__c = 'Kick Off Call';
        insert e;
        c = [SELECT Id, Kick_Off_Call__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Kick_Off_Call__c, null);
        e.Event_Status__c = 'Completed';
        e.Activity_Results__c = 'Completed';
        update e;
        c = [SELECT Id, Kick_Off_Call__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Kick_Off_Call__c, null);
    }
    
       @isTest static void midway() {
        generateData();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Event e = new Event();
        e.WhatId = c.Id;
        e.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Onboarding Event' and SobjectType = 'Event' LIMIT 1].Id;
        e.Subject = 'Midway Call';
        e.StartDateTime = Datetime.now();
        e.EndDateTime = Datetime.now().addMinutes(60);
        e.Activity_Type__c = 'Midway Decision Maker Call';
        insert e;
        c = [SELECT Id, Midway_Decision_Maker_Call__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Midway_Decision_Maker_Call__c, null);
        e.Event_Status__c = 'Completed';
        e.Activity_Results__c = 'Completed';
        update e;
        c = [SELECT Id, Midway_Decision_Maker_Call_Completed__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Midway_Decision_Maker_Call_Completed__c, null);
    }
    
        @isTest static void finalcall() {
        generateData();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Event e = new Event();
        e.WhatId = c.Id;
        e.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Onboarding Event' and SobjectType = 'Event' LIMIT 1].Id;
        e.Subject = 'Final Call';
        e.StartDateTime = Datetime.now();
        e.EndDateTime = Datetime.now().addMinutes(60);
        e.Activity_Type__c = 'Final Call';
        insert e;
        c = [SELECT Id, Final_Call__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Final_Call__c, null);
        e.Event_Status__c = 'Completed';
        e.Activity_Results__c = 'Completed';
        update e;
        c = [SELECT Id, Final_Call_Completed__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(c.Final_Call_Completed__c, null);
    }

    static void generateData(){
        Management_System__c soft = new Management_System__c();
        soft.name = 'Test Software';
        insert soft;

        Account a = new Account();
        a.Name = 'Test Company';
        a.Practice_Management_Software__c = soft.Id;
        a.Industry = 'Dental';
        a.Implementation_Rep__c = UserInfo.getUserId();
        insert a;

        Contact c = new Contact();
        c.firstName = 'Jason';
        c.lastName = 'Fletcher';
        c.AccountId = a.Id;
        c.Email = 'test@test.test';
        c.Phone = '3859854468';
        insert c;

        Case ca = new Case();
        ca.AccountId = a.Id;
        ca.RecordTypeId = '012i0000001EALw';//This is the activation case record type id
        insert ca;
    }
    
}