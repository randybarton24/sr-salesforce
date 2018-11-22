public class CasesSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Case.Id,
			Case.AccountId,
			Case.ContactId,
			Case.HG_Conditions__c,
			Case.HG_PWID__c,
			Case.HG_Procedures__c,
			Case.HG_Specialties__c,
			Case.Origin,
			Case.OwnerId,
			Case.Priority,
			Case.Provider__c,
			Case.RecordTypeId,
			Case.Related_Opportunity__c,
			Case.Resolution__c,
			Case.Status,
			Case.Subject,
			Case.Sugar_Case_Number__c,
            Case.Survey_to_be_Sent__c,
			Case.Sync_Case_Account__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Case.SObjectType;
	}

	public static CasesSelector newInstance()
	{
		return (CasesSelector) Application.Selector.newInstance(Case.SObjectType);
	}

	public Case[] selectByAccountIdWithTasks(Set<Id> accountIds)
	{
		fflib_QueryFactory caseQueryFactory = newQueryFactory();

		fflib_QueryFactory taskQueryFactory = caseQueryFactory.subselectQuery('Tasks')
        	.selectFields(new TasksSelector().getSObjectFieldList());

		return (Case[]) Database.query(
			caseQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('AccountId IN :accountIds AND IsClosed = false AND RecordType.Name = \'Playbook\'')
				.toSOQL());
	}

	public Case[] selectSupportAndSyncCasesByAccounts(Account[] accounts)
	{

        Set<Id> ids = new Set<Id>();
        for (Account a : accounts)
        {
            ids.add(a.Id);
        }
		fflib_QueryFactory caseQueryFactory = newQueryFactory();

		return (Case[]) Database.query(
				caseQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('AccountId IN :ids AND IsClosed = false AND (RecordType.Name = \'Support\' OR RecordType.Name = \'Sync List Case\')')
				.toSOQL());
	}

	public Database.QueryLocator queryLocatorResumedSyncCases()
	{
		Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sync List Case').getRecordTypeId();
		String condition = 'IsClosed = False AND RecordTypeId = :caseRecordTypeId AND Status != \'Resolved\' AND Status!= \'Scheduled\' AND Status != \'Dedicated\'';

		fflib_QueryFactory caseQueryFactory = newQueryFactory();
		new AccountsSelector().configureQueryFactoryFields(caseQueryFactory, 'Account');
		new AccountsSelector().configureQueryFactoryFields(caseQueryFactory, 'Sync_Case_Account__r');
		
		return Database.getQueryLocator(
				caseQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).
						setCondition(condition).
						toSOQL());
	}
	
	public Case[] selectOpenSyncCasesForEnterpriseAccounts(List<Account> accts)
	{
		fflib_QueryFactory caseQueryFactory = newQueryFactory();
		Set<Id> ids = new Set<Id>();
		for(Account a : accts)
		{
			if(a.ParentId != null) ids.add(a.ParentId);
		}
		new AccountsSelector().configureQueryFactoryFields(caseQueryFactory, 'Account');
		
		return (Case[]) Database.query(
				caseQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('ISClosed = false AND RecordType.Name = \'Sync List Case\' AND ' +
						'(AccountId IN :ids OR Sync_Case_Account__c IN :ids)')
				.toSOQL());
	}

	public Database.QueryLocator selectChatCaseQueue ()
	{
		fflib_QueryFactory caseQueryFactory = newQueryFactory();
		Id chatQueueId = (Id) SR_Default_Values__c.getValues('ChatBotQueueId').Value__c;

		return Database.getQueryLocator(
				caseQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
						//setcondition where like in soql
						.setCondition('OwnerId = :chatQueueId')
						.toSOQL());
	}
}