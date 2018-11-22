public class TasksSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Task.Id,
			Task.AccountId,
			Task.ActivityDate,
			Task.Activity_Results__c,
			Task.Activity_Type__c,
			Task.ADR_Set__c,
			Task.ADR_Set_DQ__c,
			Task.ADR_Set_SR_Revenue__c,
			Task.CreatedById,
			Task.CreatedDate,
			Task.Description,
			Task.IsClosed,
			Task.Lead_Source__c,
			Task.Playbook_Number_of_Days__c,
			Task.Playbook_Before_After__c,
			Task.Playbook_Reference_Date__c,
			Task.Play_Type__c,
			Task.Priority,
			Task.Status,
			Task.Subject,
			Task.OwnerId,
			Task.ROE_Task__c,
			Task.WhatId,
			Task.WhoId			
			 };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Task.SObjectType;
	}

	public static TasksSelector newInstance()
	{
		return (TasksSelector) Application.Selector.newInstance(Task.SObjectType);
	}

	public Task[] selectById(Set<Id> ids)
	{
		fflib_QueryFactory taskQueryFactory = newQueryFactory();

		return (Task[]) Database.query(
			taskQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Task[] selectByIdWithAccount(Set<Id> ids)
	{
		fflib_QueryFactory taskQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(taskQueryFactory, 'Account');

		return (Task[]) Database.query(
			taskQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Map<Id, Task[]> selectADRSetsByAccountId(Contact[] contacts)
	{
		Set<Id> ids = new Set<Id>();
		Map<Id, Task[]> results = new Map<Id, Task[]>();

		for(Contact c : contacts)
		{
			ids.add(c.AccountId);
		}

		fflib_QueryFactory taskQueryFactory = newQueryFactory();

		Task[] taskList = (Task[]) Database.query(
			taskQueryFactory
			.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
			.setCondition('AccountId IN :ids AND ADR_Set__c = true AND ADR_Set_Received__c = false')
			.toSOQL());

		for(Task t : taskList)
		{
			if(results.containsKey(t.AccountId))
			{
				results.get(t.AccountId).add(t);
			}
			else
			{
				results.put(t.AccountId, new List<Task>{t});
			}	
		}

		return results;
	}

	public Task[] selectADRSetsByAccountId(Set<Id> ids)
	{
		fflib_QueryFactory taskQueryFactory = newQueryFactory();

		return (Task[]) Database.query(
			taskQueryFactory
			.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
			.setCondition('AccountId IN :ids AND ADR_Set__c = true AND ADR_Set_Received__c = false')
			.toSOQL());
	}

	public Task[] selectByAccountId(Set<Id> ids)
	{
		fflib_QueryFactory taskQueryFactory = newQueryFactory();

		return (Task[]) Database.query(
			taskQueryFactory
			.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
			.setCondition('AccountId IN :ids')
			.toSOQL());
	}

	public Map<Id, Task> selectByOpportunityAccountId(Opportunity[] opps)
	{
		Set<Id> ids = new Set<Id>();
		Map<Id, Task> results = new Map<Id, Task>();

		for(Opportunity o : opps)
		{
			ids.add(o.AccountId);
		}

		fflib_QueryFactory taskQueryFactory = newQueryFactory();

		Task[] taskList = (Task[]) Database.query(
			taskQueryFactory
				.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('AccountId IN :ids AND ADR_Set__c = true AND Activity_Results__c = \'Spoke with-\'')
				.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true)
				.toSOQL());

		for(Task t : taskList)
		{
			if(results.containsKey(t.AccountId) && t.CreatedDate < results.get(t.AccountId).CreatedDate) continue;

			results.put(t.AccountId, t);
		}

		return results;
	}

	public Task[] getPlaybookTasks(Case[] cases)
	{
		Set<Id> caseIds = new Set<Id>();

		for(Case c : cases)
		{
			caseIds.add(c.Id);
		}

		fflib_QueryFactory taskQueryFactory = newQueryFactory();

		return (Task[]) Database.query(
				taskQueryFactory
				.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('WhatId IN :caseIds and Status != \'Completed\'')
				.toSOQL());
		}
	
	public Task[] getAllPlaybookTasksFromCaseId(Id caseId)
	{
		return [SELECT Id, Subject, ActivityDate, Status, Play_Type__c, Priority, OwnerId, Owner.Name, Related_Play__c FROM Task WHERE WhatId = :caseId AND Related_Play__c = null];
	}
	
}