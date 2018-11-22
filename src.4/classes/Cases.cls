public class Cases extends fflib_SObjectDomain  {

    public static Map<Id,Account> acctMap;
    public static Task[] playbookTasks;
    public Set<String> casesDistGroup;
    public static  Map <Id, Id> distributionQueue;

    public Cases(Case[] cases)
    {
        super(cases);
        Configuration.disableTriggerCRUDSecurity();

    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Cases(sObjectList);
        }
    }

    public override void onBeforeInsert()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Case c : (Case[]) Records)
        {
            this.createSurvey(c, null, uow);
            this.queueToDistGroup(c, null);
        }

        uow.commitWork();
    }
    
    public override void onAfterInsert()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        for(Case c : (Case[]) Records)
        {
            this.processDistributionGroup(c, null);
        }
        
        if(casesDistGroup != null &&
                !casesDistGroup.isEmpty()) SRUtilities.scheduleAsync(casesDistGroup, 'Case_Process_Dist_Group', uow);
        
        
        
        uow.commitWork();
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Case c : (Case[]) Records)
        {
            Case existingCase = (Case) existingRecords.get(c.Id);
            this.createSurvey(c, existingCase, uow);
            this.closePlaybookTasks(c, existingCase, uow);
            this.queueToDistGroup(c, existingCase);
            this.processDistributionGroup(c, existingCase);
        }
    
        if(casesDistGroup != null &&
                !casesDistGroup.isEmpty()) SRUtilities.scheduleAsync(casesDistGroup, 'Case_Process_Dist_Group', uow);
    
        
        uow.commitWork();
    }
    
    public void processDistributionGroup(Case c, Case existingCase)
    {
        if(c.Distribution_Group__c == null) return;
        if(existingCase != null &&
                existingCase.Distribution_Group__c == c.Distribution_Group__c) return;
        
        Id distGroupId = c.Distribution_Group__c != null ? c.Distribution_Group__c : null;
        if(casesDistGroup == null) casesDistGroup = new Set<String>();
        if(distGroupId != null) casesDistGroup.add(c.Id + '::' + distGroupId + ':' + UserInfo.getUserId());
    }

    public void createSurvey(Case c, Case existingCase, fflib_SObjectUnitOfWork uow)
    {
        if(existingCase != null &&
            existingCase.Status == c.Status) return;
        if(c.ContactId == null) return;
        if(c.AccountId == null) return;
        if(c.Status != 'Closed') return;
        if(c.Resolution__c != 'Fixed') return;
        if(c.Survey_Sent__c) return;
        if(c.OwnerId == '005i0000003I9Ll') return;
        if(c.OwnerId == '00Gi0000003T8Bg') return;

        String surveyType = surveyType(c);
        if(surveyType == 'No Survey') return;

        if(acctMap == null) acctMap = AccountsSelector.newInstance().selectByIdWithContacts((Case[]) Records);
        if(acctMap.get(c.AccountId).Contacts == null) return;
        Map<Id, Contact> conMap = new Map<Id, Contact>(acctMap.get(c.AccountId).Contacts);

        if(!conMap.containsKey(c.ContactId)) return;
        if(conMap.get(c.ContactId).Survey_Opt_Out__c) return;
        if(acctMap.get(c.AccountId).RecurSoft__Status__c != 'Active') return;

        if(surveyType == 'Post Case Survey' && conMap.get(c.ContactId).HasOptedOutOfEmail) return;

        Id surveyRecordTypeId = SRUtilities.getRecordTypeMap('Survey__c').get(surveyType).getRecordTypeId();

        Survey__c newSurvey = new Survey__c();
        newSurvey.RecordTypeId = surveyRecordTypeId;
        newSurvey.Business_Name__c = c.AccountId;
        newSurvey.Contact_Name__c = c.ContactId;
        newSurvey.Case_Number__c = c.Id;
        newSurvey.Case_Subject__c = c.Subject;
        newSurvey.Contact_Email__c = conMap.get(c.ContactId).Email == '' ? acctMap.get(c.AccountId).RecurSoft__Billing_Email__c : conMap.get(c.ContactId).Email;
        newSurvey.Name = surveyType + ': ' + c.Subject_for_Surveys__c;
        newSurvey.Rep_Name__c = c.OwnerId;
        newSurvey.Team_Assignment__c = c.Case_Owner_Team_Assignment__c;

        uow.registerNew(newSurvey);

        c.Survey_Sent__c = true;
        Contact con = new Contact();
        con.Id = c.ContactId;
        con.Last_Survey_Sent_Date__c = Date.today();
        if(con.Phone == '') con.Phone = acctMap.get(c.AccountId).Phone;

        uow.registerDirty(con);

    }

    public String surveyType(Case c)
    {
        Id supportCaseId = SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId();
        Id syncListCaseId = SRUtilities.getRecordTypeMap('Case').get('Sync List Case').getRecordTypeId();
        Id playbookCaseId = SRUtilities.getRecordTypeMap('Case').get('Playbook').getRecordTypeId();

        if(c.RecordTypeId == playbookCaseId && c.Survey_to_be_Sent__c == 'Fast Track Survey') return 'Playbook Case Survey';
        if(c.RecordTypeId == playbookCaseId && c.Survey_to_be_Sent__c == 'EBR Case Survey') return 'EBR Case Survey';

        return c.RecordTypeId == supportCaseId || c.RecordTypeId == syncListCaseId ? 'Post Case Survey' : 'No Survey';
    }

    public void closePlaybookTasks(Case c, Case existingCase, fflib_SObjectUnitOfWork uow)
    {
        Id playbookId = SRUtilities.getRecordTypeMap('Case').get('Playbook').getRecordTypeId();
        
        if(existingCase != null && existingCase.Status == c.Status) return;
        if(c.AccountId == null) return;
        if(c.RecordTypeId != playbookId) return;
        if(c.Status != 'Closed') return;
        if(c.Resolution__c != 'Fixed') return;
    
    
        if(playbookTasks == null) playbookTasks = TasksSelector.newInstance().getPlaybookTasks((Case[]) Records);

        for(Task t : playbookTasks)
        {
            if(t.WhatId == c.Id)
            {
                t.Status = 'Closed - Not Completed';
                uow.registerDirty(t);
            }
        }
    }
    
    public void queueToDistGroup(Case c, Case existingCase)
    {
        if(String.valueOf(c.OwnerId).startsWith('OO5')) return;
        if(existingCase != null && c.OwnerId == existingCase.OwnerId) return;
        if(distributionQueue == null) distributionQueue = DistributionGroupsSelector.getQueueDistributionMap();
        if(!distributionQueue.containsKey(c.OwnerId)) return;
        
        c.Distribution_Group__c = distributionQueue.get(c.OwnerId) ;
    }
    
}