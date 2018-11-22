public class AccountsService
{
	public static Map<Id, Id> accountIdtoOwnerId;
	public static Map<Id, Case> openEntSyncCaseMap;
	
	public static void syncRecordOwners(Map<Id, Id> accountIdToOwnerId, fflib_SObjectUnitOfWork uow)
	{
		Account[] accounts = AccountsSelector.newInstance().selectByIdWithContactsAndOpportunities(accountIdToOwnerId.keySet());
		Task[] tasks = TasksSelector.newInstance().selectByAccountId(accountIdToOwnerId.keySet());
		Contact[] contacts = ContactsSelector.newInstance().selectContactsByAccountId(accountIdToOwnerId.keySet());
		
		for(Account a : accounts)
		{
			Id ownerId = accountIdToOwnerId.get(a.Id);
			if(a.OwnerId == ownerId) continue;
			a.OwnerId = ownerId;
			uow.registerDirty(a);
		}
		
		if(contacts != null && contacts.size() > 0) ContactsService.syncContactOwners(accountIdToOwnerId, contacts, uow);
		if(tasks != null && tasks.size() > 0) TasksService.syncTaskOwners(accountIdToOwnerId, tasks, uow);
	}
	
	public static void processParentChildUpdates(Set<Id> ids, Account[] accts, Parent_Child_Mapping__c[] mappings, fflib_SObjectUnitOfWork uow)
	{
		Map<Id, Account> acctMap = AccountsSelector.newInstance().selectByIdWithContacts(ids);
		
		for(Account a : accts)
		{
			for(Contact c : acctMap.get(a.Id).Contacts)
			{
				for(Parent_Child_Mapping__c mapping : mappings)
				{
					if(mapping.Child_Object__c != 'Contact') continue;
					c.put(mapping.Child_Field_Name__c, a.get(mapping.Parent_Field_Name__c));
					uow.registerDirty(c);
				}
			}
		}
	}
	
	public static void processStampUpdates(Map<Id, Set<String>> acctToStampMap, fflib_SObjectUnitOfWork uow)
	{
		Account[] accts = AccountsSelector.newInstance().selectByIdWithManagerAndVP(acctToStampMap.keySet());
		SRUtilities.processStampUpdates(acctToStampMap, accts, uow);
	}
	
	public static void processNewScorecards(Set<Id> ids, fflib_SObjectUnitOfWork uow)
	{
		Account[] accts = AccountsSelector.newInstance().selectSObjectsById(ids);
		
		for(Account a : accts)
		{
			a.Last_HG_Scorecard_Date__c = Datetime.now();
			uow.registerDirty(a);
		}
	}
	
	public static void createSyncDownCases(Set<Id> ids, fflib_SObjectUnitOfWork uow)
	{
		Account[] accts = AccountsSelector.newInstance().selectSObjectsById(ids);
		List<Account> independentAccounts = new List<Account>();
		List<Account> entAccounts = new List<Account>();
		Id accountRecordTypeId = SRUtilities.getRecordTypeId('Account','Account');
		Id childAccountRecordTypeId = SRUtilities.getRecordTypeId('Account','Child Account');
		for (Account acct : accts)
		{
			if (acct.RecordTypeId == accountRecordTypeId || acct.RecordTypeId == childAccountRecordTypeId)
			{
				independentAccounts.add(acct);
			}
			else
			{
				entAccounts.add(acct);
			}
		}
		createIndependentSyncDownCases(independentAccounts, uow);
		createEntSyncDownCases(entAccounts, uow);
	
	}
	
	public static void createIndependentSyncDownCases(List<Account> accts, fflib_SObjectUnitOfWork uow)
	{
		
		Id distGroupId = SR_Default_Values__c.getValues('IND Sync Dist Group Id').Value__c;
		Distribution_Group__c distGroup = DistributionGroupsSelector.newInstance().selectById(distGroupId);
		
		for(Account a : accts)
		{
			User user = DistributionGroupsService.getNextUserId(distGroup, uow);
			Case c = new Case(AccountId = a.Id,
					Sync_Case_Account__c = a.Id,
					Category__c = 'Technical',
					Description = 'Last Sync Date - ' + Datetime.newInstance(a.Admin_Last_Sync_Date__c, Datetime.now().time()).format('MMMM dd, yyyy','America/Denver'),
					Origin = 'Auto-Created',
					OwnerId = user.Id,
					Product__c = 'SR Sync',
					RecordTypeId = SRUtilities.getRecordTypeId('Case','Sync List Case'),
					Status = 'New',
					Subject = a.tz__Timezone__c + ' Sync Down - ' + Datetime.now().format('MMMM dd, yyyy','America/Denver'));
			uow.registerNew(c);
			DistributionGroupsService.createHistory(distGroup, user, c, uow);
		
		}
	}
	
	public static void createEntSyncDownCases(List<Account> accts, fflib_SObjectUnitOfWork uow)
	{
		if(accountIdtoOwnerId == null) accountIdtoOwnerId = new Map<Id,Id>();
		
		Id distGroupId = SR_Default_Values__c.getValues('ENT Sync Dist Group Id').Value__c;
		Distribution_Group__c distGroup = DistributionGroupsSelector.newInstance().selectById(distGroupId);
		
		Case[] openCases = CasesSelector.newInstance().selectOpenSyncCasesForEnterpriseAccounts(accts);
		for(Case c: openCases)
		{
			accountIdtoOwnerId.put(c.AccountId, c.OwnerId);
			if(openEntSyncCaseMap == null) openEntSyncCaseMap = new Map<Id, Case>();
			openEntSyncCaseMap.put(c.Sync_Case_Account__c, c);
		}
		
		for(Account a : accts)
		{
			if(openEntSyncCaseMap != null) if(openEntSyncCaseMap.containsKey(a.Id)) continue;
			Id caseOwnerId;
			User user;
			Id acctId = a.ParentId == null ? a.Id : a.ParentId;
			
			if(accountIdtoOwnerId.containsKey(acctId))
			{
				caseOwnerId = accountIdtoOwnerId.get(acctId);
				DistributionGroupsService.updateOpenCount(accountIdtoOwnerId.get(acctId), distGroup, uow);
				user = new User(Id = caseOwnerId, AboutMe = 'Assigned to Parent Account Sync Case Owner');
			} else
			{
				user = DistributionGroupsService.getNextUserId(distGroup, uow);
				caseOwnerId = user.Id;
				accountIdtoOwnerId.put(acctId, caseOwnerId);
			}
			
			Case c = new Case(AccountId = acctId,
					Sync_Case_Account__c = a.Id,
					Category__c = 'Technical',
					Description = 'Last Sync Date - ' + Datetime.newInstance(a.Admin_Last_Sync_Date__c, Datetime.now().time()).format('MMMM dd, yyyy','America/Denver') +
							' for ' + a.Name + ' SubscriberId: ' + a.Subscriber_ID__c,
					Origin = 'Auto-Created',
					OwnerId = caseOwnerId,
					Product__c = 'SR Sync',
					RecordTypeId = SRUtilities.getRecordTypeId('Case','Sync List Case'),
					Status = 'New',
					Subject = a.tz__Timezone__c + ' Sync Down - ' + Datetime.now().format('MMMM dd, yyyy','America/Denver'),
					Sugar_Case_Number__c = a.Id);
			
			uow.registerNew(c);
			DistributionGroupsService.createHistory(distGroup, user, c, uow);
		
		}
	}
	
	public static void updateCancelledISBStatus(Cancel_Request__c[] cancelRequests, fflib_SObjectUnitOfWork uow)
	{
		for(Cancel_Request__c cancelRequest : cancelRequests)
		{
			if(cancelRequest.Cancel_Month__c < cancelRequest.Asset__r.Current_Product_Subscription__r.RecurSoft__Contract_Term_Start_Date__c) continue;
			Account a = new Account(Id = cancelRequest.Opportunity__r.AccountId,
					RecurSoft__Status__c = 'Cancelled',
					Do_Not_Support_Sync__c = false,
					Do_Not_Support_Reason__c = null);
			uow.registerDirty(a);
		}
	}
}