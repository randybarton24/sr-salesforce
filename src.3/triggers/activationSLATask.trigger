trigger activationSLATask on Task (after insert, after update) {

    Set<Id> ids = new Set<Id>{};
    Task[] tasks = new List<Task>();

    Id activationCaseRecordTypeId = '012i0000001EALw';

    for (Task t : Trigger.new) {
        if(t.WhatId != null){
            if(t.WhatId.getSObjectType() == Case.SObjectType){
                ids.add(t.WhatId);
                tasks.add(t);
            }
        }
    }
    Map<Id, Case> caseMap = new Map<Id, Case>();
    caseMap.putAll([SELECT Id, First_Contact__c, Graphics_Task_Claimed__c, Graphics_Task_Completed__c, Training_Scheduled__c, Training_Scheduled_For__c, Training_Completed__c FROM Case WHERE Id in :ids AND RecordTypeId = :activationCaseRecordTypeId]);

    for(Task t : tasks){
        Case c = caseMap.get(t.WhatId);
        if(c == null){
            continue;
        }
        System.debug('Im here');
           if(c.First_Contact__c == null && t.Activity_Type__c != 'Graphics Setup' && t.Activity_Type__c != 'Administrative/Other' && t.Status == 'Completed'){
            c.First_Contact__c = Datetime.now();
        }
        if(t.Activity_Type__c == 'Graphics Setup'){
            if(c.Graphics_Task_Claimed__c == null){
                c.Graphics_Task_Claimed__c = Datetime.now();
            }
            if(t.Activity_Results__c == 'Completed' && c.Graphics_Task_Completed__c == null){
                c.Graphics_Task_Completed__c = Datetime.now();
            }
        }
        if(t.Activity_Type__c == 'Training'){
            if(c.Training_Scheduled__c == null){
                c.Training_Scheduled__c = Datetime.now();
            }
            if(c.Training_Scheduled_For__c == null){
                c.Training_Scheduled_For__c = t.Training_Date_Time__c;
            }
            if(c.Training_Completed__c == null && t.Activity_Results__c == 'Completed'){
                c.Training_Completed__c = Datetime.now();
            }
        }
    }

    update caseMap.values();
    
}