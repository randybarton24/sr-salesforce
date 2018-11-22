public class PlaybooksService 
{
    public static void addPlaybooks(Id accountId, Set<Id> playbookIds, fflib_SObjectUnitOfWork uow)
    {
        Playbook__c[] playbooks = PlaybooksSelector.newInstance().selectByIdWithTasks(playbookIds);
        Map<Id, Account> accountMap = AccountsSelector.newInstance().selectByIdWithContacts(new Set<Id>{accountId});
//        System.debug(accountMap);

        for(Playbook__c playbook : playbooks)
        {
            Case c = new Case();
            c.Subject = playbook.Name;
            c.RecordTypeId = SRUtilities.getRecordTypeId('Case', 'Playbook');
            c.Playbook__c = playbook.Id;
            c.ContactId = accountMap.get(accountId).Office_Contact__c;
            c.AccountId = accountId;
            c.Survey_to_be_Sent__c = playbook.Survey_to_be_Sent__c;
            uow.registerNew(c);

            for(Task playbookTask : playbook.Tasks)
            {
                Task caseTask = playbookTask.clone(false);
                caseTask.ActivityDate = Date.today().addDays(Integer.valueOf(playbookTask.Playbook_Number_of_Days__c));
                caseTask.WhoId = c.ContactId;
                caseTask.OwnerId = UserInfo.getUserId();
                caseTask.Status = 'Scheduled';
                uow.registerNew(caseTask, Task.WhatId, c);
            }
        }
    }
}