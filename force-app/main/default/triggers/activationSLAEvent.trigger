trigger activationSLAEvent on Event (after insert, after update) {

    Set<Id> ids = new Set<Id>{};
    Event[] events = new List<Event>();

    Id ActivationCaseRecordTypeId = '012i0000001EALw';

    for (Event e : Trigger.new) {
        if(e.WhatId != null){
            if(e.WhatId.getSObjectType() == Case.SObjectType){
                ids.add(e.WhatId);
                events.add(e);
            }
        }
    }
    Map<Id, Case> caseMap = new Map<Id, Case>();
    caseMap.putAll([SELECT Id, Sync_Install_Scheduled__c, Sync_Install_Scheduled_For__c, Sync_Install_Completed__c, Custom_Settings_Scheduled__c, Custom_Settings_Scheduled_For__c, Custom_Settings_Completed__c, Kick_Off_Call__c, Kick_Off_Call_Completed__c, Midway_Decision_Maker_Call__c, Midway_Decision_Maker_Call_Completed__c, Final_Call__c, Final_Call_Completed__c FROM Case WHERE Id in :ids AND RecordTypeId = :ActivationCaseRecordTypeId]);

    for(Event e : events){
        Case c = caseMap.get(e.WhatId);
        if(c == null){
            continue;
        }
        if(e.Activity_Type__c == 'Sync Install'){
            if(c.Sync_Install_Scheduled__c == null){
                c.Sync_Install_Scheduled__c = Datetime.now();
            }
            if(c.Sync_Install_Scheduled_For__c == null){
                c.Sync_Install_Scheduled_For__c = e.StartDateTime;
            }
            if(c.Sync_Install_Completed__c == null && e.Activity_Results__c == 'Completed'){
                c.Sync_Install_Completed__c = Datetime.now();
            }
        }
        if(e.Activity_Type__c == 'Custom Settings'){
            if(c.Custom_Settings_Scheduled__c == null){
                c.Custom_Settings_Scheduled__c = Datetime.now();
            }
            if(c.Custom_Settings_Scheduled_For__c == null){
                c.Custom_Settings_Scheduled_For__c = e.StartDateTime;
            }
            if(c.Custom_Settings_Completed__c == null && e.Activity_Results__c == 'Completed'){
                c.Custom_Settings_Completed__c = Datetime.now();
            }
        }
        if(e.Activity_Type__c == 'Kick Off Call'){
            if(c.Kick_Off_Call__c == null){
                c.Kick_Off_Call__c = e.StartDateTime;
            }
            if(c.Kick_Off_Call_Completed__c == null && e.Activity_Results__c == 'Completed'){
                c.Kick_Off_Call_Completed__c = Datetime.now();
            }
        }
        if(e.Activity_Type__c == 'Midway Decision Maker Call'){
            if(c.Midway_Decision_Maker_Call__c == null){
                c.Midway_Decision_Maker_Call__c = e.StartDateTime;
            }
            if(c.Midway_Decision_Maker_Call_Completed__c == null && e.Activity_Results__c == 'Completed'){
                c.Midway_Decision_Maker_Call_Completed__c = Datetime.now();
            }
        }
        if(e.Activity_Type__c == 'Final Call'){
            if(c.Final_Call__c == null){
                c.Final_Call__c = e.StartDateTime;
            }
            if(c.Final_Call_Completed__c == null && e.Activity_Results__c == 'Completed'){
                c.Final_Call_Completed__c = Datetime.now();
            }
        }
    }

    update caseMap.values();

}