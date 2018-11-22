@isTest
private class Accounts_Test {

    @isTest static void test_onApplyDefaults()
    {
        sfab_FabricatedSObject aFab = TestUtilities2.newAccount();

        Account ac = (Account) aFab.toSObject();

        Account existingAc = (Account) testUtilities2.existingAccount(aFab).toSObject();

        Accounts accounts = new Accounts(new List<Account>{ ac });
        accounts.onApplyDefaults();
    }

    @isTest static void test_onBeforeUpdate()
    {
        sfab_FabricatedSObject aFab = TestUtilities2.newAccount();

        Account ac = (Account) aFab.toSObject();

        Account existingAc = (Account) TestUtilities2.existingAccount(aFab).toSObject();

        Accounts accounts = new Accounts(new List<Account>{ ac });
        accounts.onBeforeUpdate(new Map<Id, SObject>{ac.Id =>  aFab.toSObject()});
    }

    @isTest static void test_checkForSyncOwners()
    {
        User user = (User) TestUtilities2.newUser().toSObject();

        User user2 = (User) TestUtilities2.newUser().toSObject();

        sfab_FabricatedSObject aFab = TestUtilities2.newAccount()
                .setField(Account.OwnerId, user.Id);

        Account ac = (Account) aFab.toSObject();

        Account existingAc = (Account) TestUtilities2.existingAccount(aFab)
                .setField(Account.OwnerId, user2.Id)
                .toSObject();

        Accounts accounts = new Accounts(new List<Account>{ ac });
        accounts.checkForSyncOwners(ac, existingAc);

        System.assertEquals(1, Accounts.syncOwners.size());
        System.assert(Accounts.syncOwners.contains(ac.Id + ':' + ac.OwnerId));
    }

    @isTest static void test_processParentChildUpdates()
    {
        Parent_Child_Mapping__c parent = (Parent_Child_Mapping__c) testUtilities2.newParentChildMapping()
                .setField(Parent_Child_Mapping__c.Parent_Object__c, 'Account')
                .setField(Parent_Child_Mapping__c.Parent_Field_Name__c, 'OwnerId')
                .setField(Parent_Child_Mapping__c.Active__c, true)
                .toSObject();

        User user = (User) TestUtilities2.newUser().toSObject();

        User user2 = (User) TestUtilities2.newUser().toSObject();

        sfab_FabricatedSObject aFab = TestUtilities2.newAccount()
                .setField(Account.OwnerId, user.Id);

        Account ac = (Account) aFab.toSObject();

        Account existingAc = (Account) TestUtilities2.existingAccount(aFab)
                .setField(Account.OwnerId, user2.Id)
                .toSObject();

        Accounts accounts = new Accounts(new List<Account>{ ac });
        accounts.mappings = new List<Parent_Child_Mapping__c>{ parent };
        accounts.processParentChildUpdates(ac, existingAc);

        System.assertEquals(1, Accounts.parentChildUpdates.size());
        System.assert(accounts.parentChildUpdates.keySet().contains(ac.Id));
    }

    @isTest static void test_processStampUpdates()
    {
        User user = (User) TestUtilities2.newUser().toSObject();

        User user2 = (User) TestUtilities2.newUser().toSObject();

        Stamp_Field_Mapping__c stamp1 = (Stamp_Field_Mapping__c) testUtilities2.newStampFieldMapping()
                .setField(Stamp_Field_Mapping__c.Stamp_To_Object__c, 'Account')
                .setField(Stamp_Field_Mapping__c.Active__c, true)
                .setField(Stamp_Field_Mapping__c.Field_Changed__c, 'OwnerId')
                .setField(Stamp_Field_Mapping__c.Field_Changed_Value__c, String.valueOf(user.Id))
                .toSObject();

        sfab_FabricatedSObject aFab = TestUtilities2.newAccount()
                .setField(Account.OwnerId, user.Id);

        Account ac = (Account) aFab.toSObject();

        Account existingAc = (Account) TestUtilities2.existingAccount(aFab)
                .setField(Account.OwnerId, user2.Id)
                .toSObject();

        Accounts accounts = new Accounts(new List<Account>{ ac });
        accounts.stampMappings = new List<Stamp_Field_Mapping__c>{ stamp1 };
        accounts.processStampUpdates(ac, existingAc);

        System.assertEquals(1, accounts.stampUpdates.size());
        System.assert(accounts.stampUpdates.contains(ac.Id + '::' + stamp1.Id));
    }

    @isTest static void test_validateAccountOwnerChange()
    {
        User user = (User) TestUtilities2.newUser().toSObject();

        User user2 = (User) TestUtilities2.newUser().toSObject();

        Stamp_Field_Mapping__c stamp1 = (Stamp_Field_Mapping__c) testUtilities2.newStampFieldMapping()
                .setField(Stamp_Field_Mapping__c.Stamp_To_Object__c, 'Account')
                .setField(Stamp_Field_Mapping__c.Active__c, true)
                .setField(Stamp_Field_Mapping__c.Field_Changed__c, 'OwnerId')
                .setField(Stamp_Field_Mapping__c.Field_Changed_Value__c, String.valueOf(user.Id))
                .toSObject();

        sfab_FabricatedSObject aFab = TestUtilities2.newAccount()
                .setField(Account.OwnerId, user.Id);

        Account ac = (Account) aFab.toSObject();

        Account existingAc = (Account) TestUtilities2.existingAccount(aFab)
                .setField(Account.OwnerId, user2.Id)
                .toSObject();

        insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
                Description__c = 'jennyPoolUserId',
                Value__c = ac.OwnerId);

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
                Description__c = 'noStealingProfiles',
                Value__c = '00ei0000001247zAAA');

        insert new SR_Default_Values__c(Name = 'acctChangeOwnerErrorMessage',
                Description__c = 'acctChangeOwnerErrorMessage',
                Value__c = 'Adderror Message');

        Accounts accounts = new Accounts(new List<Account>{ ac });
        accounts.validateAccountOwnerChange(ac, existingAc);
    }

    @IsTest static void test_CloseOpenSupportAndSyncCases()
    {
        Account a = TestUtilities.insertBasicAccount(true);
        a.Do_Not_Support_Sync__c  = true;
        a.Do_Not_Support_Reason__c = 'Cancelled';


        Id syncCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sync List Case').getRecordTypeId();
        Id supportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Id accountingCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Accounting').getRecordTypeId();

        List<Case> caseList = new List<Case>();
        Case syncCase = new Case(AccountId = a.Id,
                RecordTypeId = syncCaseRecordTypeId,
                Subject = 'Sync Down',
                Status = 'New',
                Resolution__c = null);
        caseList.add(syncCase);

        Case supportCase = new Case(AccountId = a.Id,
                RecordTypeId = supportCaseRecordTypeId,
                Subject = 'Support Case',
                Status = 'New',
                Resolution__c = null);
        caseList.add(supportCase);

        Case accountingCase = new Case(AccountId = a.Id,
                RecordTypeId = accountingCaseRecordTypeId,
                Subject = 'Accounting Case',
                Status = 'New',
                Resolution__c = null);
        caseList.add(accountingCase);

        insert caseList;

        Test.startTest();
            update a;
        Test.stopTest();


        Map<Id, Case> updatedCases = new Map<Id, Case>([SELECT Id, Status, Resolution__c, RecordTypeId FROM Case]);

        for (Case c : updatedCases.values())
        {
            if(c.RecordTypeId == accountingCaseRecordTypeId)
            {
                System.assertEquals('New', c.Status);
                System.assertEquals(null,c.Resolution__c);
            }
            else
            {
                System.assertEquals('Closed', c.Status);
                System.assertEquals('Wont Fix', c.Resolution__c);
            }

        }
    }

}