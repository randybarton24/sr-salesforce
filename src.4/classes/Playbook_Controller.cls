public with sharing class Playbook_Controller extends WebFormsUtilityClass
{
    public Account a { get; set; }
    public Case[] listCases { get; set; }
    public Boolean renderAddRemove { get; set; }
    public Id acctId { get; set; }
    public Id playbookId { get; set; }
        
    public Playbook_Controller(ApexPages.StandardController stdController) 
    {        
            this.a = (Account)stdController.getRecord();
            this.acctId = stdController.getId();
            renderAddRemove = false;
            listCases = CasesSelector.newInstance().selectByAccountIdWithTasks(new Set<Id>{acctId});
    }

    public SelectOption[] getPlaybooks() 
    {
        SelectOption[] options = new List<SelectOption>();

        for(Playbook__c p : PlaybooksSelector.newInstance().selectAllActivePlaybooks()) 
        {    
            SelectOption so = new SelectOption(p.Id, p.Name);
            options.add(so);
        }

        return options;
    }

    public PageReference addRemove() 
    {
            renderAddRemove = true;
            return null;
    }

    public PageReference cancel() 
    {
            renderAddRemove = false;
            return null;
    }

    public PageReference saveAddRemove() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        PlaybooksService.addPlaybooks(acctId, new Set<Id>{playbookId}, uow);
        uow.commitWork();
        return null;
    }
}