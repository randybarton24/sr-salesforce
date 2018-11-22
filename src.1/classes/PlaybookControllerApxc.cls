/**
 * Created by mschetselaar on 8/30/2018.
 */
/*
  __  __       _   _   _                      _____      _          _            _
 |  \/  |     | | | | | |                    / ____|    | |        | |          | |
 | \  / | __ _| |_| |_| |__   _____      __ | (___   ___| |__   ___| |_ ___  ___| | __ _  __ _ _ __
 | |\/| |/ _` | __| __| '_ \ / _ \ \ /\ / /  \___ \ / __| '_ \ / _ \ __/ __|/ _ \ |/ _` |/ _` | '__|
 | |  | | (_| | |_| |_| | | |  __/\ V  V /   ____) | (__| | | |  __/ |_\__ \  __/ | (_| | (_| | |
 |_|  |_|\__,_|\__|\__|_| |_|\___| \_/\_/   |_____/ \___|_| |_|\___|\__|___/\___|_|\__,_|\__,_|_|

                                                                                                     
*/
public without sharing class PlaybookControllerApxc
{
    
//    @AuraEnabled
//    public static Case[] listCases { get; set; }
//
    public class PicklistOptions
    {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }
    
    @AuraEnabled
    public static Case[] getPlaybookCaseApx(String acctId)
    {
        return CasesSelector.newInstance().selectByAccountIdWithTasks(new Set<Id> {(Id) acctId});
    }
    
    @AuraEnabled
    public static List<PicklistOptions> getPlaybookAsList()
    {
        Playbook__c[] options = PlaybooksSelector.newInstance().selectAllActivePlaybooks();
        
        List<PicklistOptions> newList = new List<PicklistOptions>();
        
        for (Playbook__c pb : options)
        {
            PicklistOptions pv = new PicklistOptions();
            pv.label = pb.Name;
            pv.value = pb.Id;
            newList.add(pv);
        
        }
        
        return newList;
    }
    @AuraEnabled
    public static void addPlaybookCaseApx(Id acctId, Id playbookId)
    {
        System.debug('AcctId: ' + acctId + ', playbookId: ' + playbookId);
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        PlaybooksService.addPlaybooks((Id) acctId, new Set<Id>
        {
                (Id) playbookId
        }, uow);
        uow.commitWork();
    }
    
    @AuraEnabled
    public static void AddActivityApx(Id TaskId, Boolean isTask, Task newTask, Event newEvent, Id CaseId)
    {
        if (isTask)
        {
            Task t = newTask;
            t.Related_Play__c = TaskId;
            t.WhatId = CaseId;
            System.debug('Task: ' + t);
            insert t;
        }
        else
        {
            Event e = newEvent;
            e.Related_Play__c = TaskId;
            e.WhatId = CaseId;
            e.DurationInMinutes = Integer.valueOf(newEvent.DurationInMinutes);
            e.ActivityDateTime = newEvent.ActivityDate;
            e.Activity_Results__c = 'Future Event';
            System.debug('Event: ' + e);
            insert e;
        }
    }
    
    @AuraEnabled
    public static Task[] getAllTasksApx(String caseId, String relatedPlay)
    {
        if (relatedPlay != null) return [SELECT Id, Subject, ActivityDate, Status, Play_Type__c, Priority, OwnerId, Owner.Name, Related_Play__c FROM Task WHERE Related_Play__c = :relatedPlay ORDER BY ActivityDate];
        return TasksSelector.newInstance().getAllPlaybookTasksFromCaseId((Id) caseId);
    }
    
    @AuraEnabled
    public static Event[] getAllEventsApx(String caseId, String relatedPlay)
    {
        System.debug('Events: ' + [SELECT Id, Subject, Related_Play__c, StartDateTime FROM Event WHERE Related_Play__c = :relatedPlay]);
        return [SELECT Id, Subject, Related_Play__c, StartDateTime, Activity_Results__c, Activity_Type__c, Owner.Name FROM Event WHERE Related_Play__c = :relatedPlay];
    }
    
    @AuraEnabled
    public static void updateTasksApx(String taskId, Boolean completedStatus)
    {
        Task t = new Task(Id = (Id) taskId);
        t.Status = completedStatus ? 'Completed' : 'Scheduled';
        
        update t;
    }
    
    @AuraEnabled
    public static void updateEventApx(String eventId, Boolean completedStatus)
    {
        Event e = new Event(Id = (Id) eventId);
        e.Activity_Results__c = completedStatus ? 'Completed' : 'Future Event';
        
        update e;
    }
    
    @AuraEnabled
    public static void closePlaybookCaseApx(Id CaseID, String resolution, String resDescription)
    {
        Case c = new Case(Id = CaseID);
        c.Status = 'Closed';
        c.Resolution__c = resolution;
        c.Resolution_Description__c = resDescription;
        update c;
    }
    
}