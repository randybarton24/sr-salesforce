public class Accounts extends fflib_SObjectDomain
{
    public Map<Id, Account> parentChildUpdates;
    public Parent_Child_Mapping__c[] mappings;
    public Set<String> stampUpdates;
    public Stamp_Field_Mapping__c[] stampMappings;
    public Set<String> syncOwners;
    public Map<Id, Case> supportAndSyncCasesMap;

    public Accounts(Account[] accounts)
    {
        super(accounts);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Accounts(sObjectList);
        }
    }

    public override void onApplyDefaults()
    {
        RecurSoft__Intacct_Entity__c[] intacctEntities = [SELECT Id, Name FROM RecurSoft__Intacct_Entity__c WHERE Name = 'SR001' LIMIT 1];

        if(intacctEntities.size() != 1) return;

        for(Account a : (Account[]) Records)
        {
            a.RecurSoft__Intacct_Entity__c = intacctEntities[0].Id;
        }
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Account a : (Account[]) Records)
        {
            Account existingAccount = (Account) existingRecords.get(a.Id);

            this.validateAccountOwnerChange(a, existingAccount);
            this.processParentChildUpdates(a, existingAccount);
            this.processStampUpdates(a, existingAccount);
        }

        if(parentChildUpdates != null &&
            !parentChildUpdates.isEmpty()) AccountsService.processParentChildUpdates(parentChildUpdates.keySet(), parentChildUpdates.values(), mappings, uow);

        if(syncOwners != null &&
                !syncOwners.isEmpty()) SRUtilities.scheduleAsync(syncOwners, 'Sync_Owners', uow);

        if(stampUpdates != null &&
                !stampUpdates.isEmpty()) SRUtilities.scheduleAsync(stampUpdates, 'Stamp_Updates', uow);

        uow.commitWork();
    }

	public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for (Account a : (Account[]) Records) {
			Account existingAccount = (Account) existingRecords.get(a.Id);

			this.closeOpenSupportAndSyncCases(a, existingAccount, uow);

		}

		uow.commitWork();
	}

    public void checkForSyncOwners(Account a, Account existingAccount)
    {
        if(existingAccount != null &&
                existingAccount.OwnerId == a.OwnerId) return;

        if(syncOwners == null) syncOwners = new Set<String>();
        syncOwners.add(a.Id + ':' + a.OwnerId);
    }
    public void processParentChildUpdates(Account a, Account existingAccount)
    {
        if(mappings == null) mappings = [SELECT Id, Active__c, Child_Object__c, Child_Field_Name__c, Parent_Object__c, Parent_Field_Name__c
        FROM Parent_Child_Mapping__c
        WHERE Parent_Object__c = 'Account'
        AND Active__c = true];

        for(Parent_Child_Mapping__c mapping : mappings)
        {
            if(existingAccount != null &&
                    existingAccount.get(mapping.Parent_Field_Name__c) == a.get(mapping.Parent_Field_Name__c)) continue;
            if(parentChildUpdates == null) parentChildUpdates = new Map<Id, Account>();
            parentChildUpdates.put(a.Id, a);
        }
    }

    public void processStampUpdates(Account a, Account existingAccount)
    {
        if(stampMappings == null) stampMappings = [SELECT Id, Field_Changed__c, Field_Changed_Value__c
        FROM Stamp_Field_Mapping__c
        WHERE Stamp_To_Object__c = 'Account'
        AND Active__c = true];

        String stampUpdateString = SRUtilities.processStampUpdates(a, existingAccount, stampMappings);

        if(stampUpdateString == null) return;
        if(stampUpdates == null) stampUpdates = new Set<String>();
        stampUpdates.add(stampUpdateString);
    }

    public void validateAccountOwnerChange(Account a, Account existingAccount)
    {
        if(System.isBatch()) return;
        if(existingAccount == null) return;
        if(existingAccount.OwnerId == a.OwnerId ||
                existingAccount.OwnerId == SR_Default_Values__c.getInstance('jennyPoolUserId').Value__c) return;

        if (SR_Default_Values__c.getInstance('noStealingProfiles').Value__c.contains(String.valueOf(UserInfo.getProfileId()) ) )
            a.addError(SR_Default_Values__c.getInstance('acctChangeOwnerErrorMessage').Value__c);

    }

	public void closeOpenSupportAndSyncCases(Account a, Account existingAccount, fflib_SObjectUnitOfWork uow) {
		if (a.Do_Not_Support_Sync__c == false) return;

		if (existingAccount != null &&
				a.Do_Not_Support_Sync__c == existingAccount.Do_Not_Support_Sync__c) return ;

		if (supportAndSyncCasesMap == null) supportAndSyncCasesMap = new Map<Id, Case>(CasesSelector.newInstance().selectSupportAndSyncCasesByAccounts((Account[]) Records));

		for (Case c : supportAndSyncCasesMap.values())
		{
			c.Status = 'Closed';
			c.Resolution__c = 'Wont Fix';
			String postId = c.Id;
            if(!System.Test.isRunningTest()) ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), postId, ConnectApi.FeedElementType.FeedItem, 'Case closed because \'Do Not Support Sync\' was checked');
            
			uow.registerDirty(c);

		}
	}
}