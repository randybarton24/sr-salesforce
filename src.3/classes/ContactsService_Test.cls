@isTest
private class ContactsService_Test 
{
    @isTest static void skipTimedDistGroup1() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Name = 'Skip Timed Account',
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Timed_Distribution_Group_Date__c = null);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Name = 'Timed DistGroup',
            Timed_Distribution_Group_Hours__c = null);

        Boolean isSkipped = ContactsService.skipTimedDistGroup(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
        System.assertEquals(a.Timed_Distribution_Group_Date__c, null);
    }

    @isTest static void skipTimedDistGroup2() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Name = 'Skip Timed Account',
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Timed_Distribution_Group_Date__c = Datetime.now().addHours(-4));
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Name = 'Timed DistGroup',
            Timed_Distribution_Group_Hours__c = 5);

        Boolean isSkipped = ContactsService.skipTimedDistGroup(a, null, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipTimedDistGroup3() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Name = 'Skip Timed Account Parent',
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Timed_Distribution_Group_Date__c = Datetime.now().addHours(-4));
        Account a = new Account(Name = 'Skip Timed Account Child',
            ParentId = parent.Id,
            Id = fflib_IDGenerator.generate(Account.SObjectType));
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Name = 'Timed DistGroup',
            Timed_Distribution_Group_Hours__c = 5);

        Boolean isSkipped = ContactsService.skipTimedDistGroup(a, parent, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipTimedDistGroup4() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Name = 'Skip Timed Account',
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Timed_Distribution_Group_Date__c = null);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Name = 'Timed DistGroup',
            Timed_Distribution_Group_Hours__c = 5);

        Boolean isSkipped = ContactsService.skipTimedDistGroup(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
        System.assertNotEquals(a.Timed_Distribution_Group_Date__c, null);
    }

    @isTest static void skipTimedDistGroup5() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Name = 'Skip Timed Account Parent',
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Timed_Distribution_Group_Date__c = null);
        Account a = new Account(Name = 'Skip Timed Account Child',
            ParentId = parent.Id,
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Timed_Distribution_Group_Date__c = null);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Name = 'Timed DistGroup',
            Timed_Distribution_Group_Hours__c = 5);

        Boolean isSkipped = ContactsService.skipTimedDistGroup(a, parent, c, distGroup, uow);
        System.assert(!isSkipped);
        System.assertNotEquals(a.Timed_Distribution_Group_Date__c, null);
        System.assertNotEquals(parent.Timed_Distribution_Group_Date__c, null);
    }

    @isTest static void skipTimedDistGroup6() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Name = 'Skip Timed Account',
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Timed_Distribution_Group_Date__c = Datetime.now().addHours(-6));
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Name = 'Timed DistGroup',
            Timed_Distribution_Group_Hours__c = 5);

        Boolean isSkipped = ContactsService.skipTimedDistGroup(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipTimedDistGroup7() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Name = 'Skip Timed Account Parent',
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Timed_Distribution_Group_Date__c = Datetime.now().addHours(-6));
        Account a = new Account(Name = 'Skip Timed Account Child',
            ParentId = parent.Id,
            Id = fflib_IDGenerator.generate(Account.SObjectType));
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Name = 'Timed DistGroup',
            Timed_Distribution_Group_Hours__c = 5);

        Boolean isSkipped = ContactsService.skipTimedDistGroup(a, parent, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatus1() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Active');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatus2() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Prospect');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatus3() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Cancelled');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatus4() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Ineligible');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatus5() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Active');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Customers Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatus6() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Prospect');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Customers Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatus7() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Cancelled');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Customers Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatus8() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Ineligible');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Customers Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatus9() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Active');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects and Customers');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatus10() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Prospect');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects and Customers');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatus11() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Cancelled');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects and Customers');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatus12() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Ineligible');
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects and Customers');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, null, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatusParent1() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Active');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatusParent2() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Prospect');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatusParent3() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Cancelled');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatusParent4() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Ineligible');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatusParent5() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Active');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Customers Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatusParent6() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Prospect');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Customers Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatusParent7() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Cancelled');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Customers Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatusParent8() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Ineligible');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Customers Only');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void skipCustomerStatusParent9() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Active');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects and Customers');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatusParent10() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Prospect');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects and Customers');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatusParent11() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Cancelled');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects and Customers');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(!isSkipped);
    }

    @isTest static void skipCustomerStatusParent12() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecurSoft__Status__c = 'Ineligible');
        Account a = new Account(ParentId = parent.Id);
        Contact c = new Contact();
        Distribution_Group__c distGroup = new Distribution_Group__c(Customer_Setting__c = 'Prospects and Customers');

        Boolean isSkipped = ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        System.assert(isSkipped);
    }

    @isTest static void createHistory1() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();             
        Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup()
            .setField(Distribution_Group__c.Name, 'Group Name')
            .toSObject();           
        User user = (User) TestUtilities2.newUser()
            .setField(User.AboutMe, 'AboutMe')
            .toSObject();
        Account parent = (Account) TestUtilities2.newAccount().toSObject(); 
        Account a = (Account) TestUtilities2.newAccount().toSObject();
        Contact c = (Contact) TestUtilities2.newContact().toSObject();                        

        ContactsService.createHistory(distGroup, user, c, a, parent, uow);      
        List<Distribution_Group_History__c> distGroupHistoryResult = (List<Distribution_Group_History__c>)(uow.m_newListByType.get('Distribution_Group_History__c'));

        System.assertEquals(1, uow.m_newListByType.get('Distribution_Group_History__c').size());  
        System.assertEquals(distGroup.Name + String.valueOf(Datetime.now()), distGroupHistoryResult[0].Name);
        System.assertEquals(user.AboutMe, distGroupHistoryResult[0].Description__c);
        System.assertEquals(c.Id, distGroupHistoryResult[0].Contact__c);
        System.assertEquals(parent.Id, distGroupHistoryResult[0].Account__c);
        System.assertEquals(distGroup.Id, distGroupHistoryResult[0].Distribution_Group__c);
        System.assertEquals(user.Id, distGroupHistoryResult[0].User__c);
    }

    @isTest static void createNewOpp1() 
    {       
        Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup()
            .setField(Distribution_Group__c.Major_Accounts__c, true)
            .toSObject();           
        User user = (User) TestUtilities2.newUser().toSObject();
        Account a = (Account) TestUtilities2.newAccount()
            .setField(Account.Name, 'AccountName')
            .toSObject();
    
        Opportunity oppResult = ContactsService.createNewOpp(user.Id, user.Id, distGroup, a, null);       
        
        System.assertEquals(a.Name + '-', oppResult.Name);  
        System.assertEquals(a.Id, oppResult.AccountId);
        System.assertEquals('Demo Scheduled', oppResult.StageName);
        System.assertEquals(SRUtilities.getRecordTypeMap('Opportunity').get('Enterprise New Business').getRecordTypeId(), oppResult.RecordTypeId);
        System.assertEquals('None', oppResult.RecurSoft__Trial__c);
        System.assertEquals(true, oppResult.Apex_Override_Validation__c);
        System.assertEquals(Date.today().addDays(30), oppResult.CloseDate);     
        System.assertEquals(a.Id, oppResult.RecurSoft__Bill_to_Account__c);
    }

    @isTest static void getDistGroup1() 
    {       
        Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup().toSObject();  
        Contact c = (Contact) TestUtilities2.newContact()
            .setField(Contact.DistGroup__c, 'DistGroup__c')
            .setField(Contact.Distribution_Group__c, distGroup.Id)
            .toSObject();
    
        Id distGroupResult = ContactsService.getDistGroup(c);       
        
        System.assertEquals(distGroup.Id, distGroupResult);         
    }

    @isTest static void syncContactOwners1() 
    {       
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account a = (Account) TestUtilities2.newAccount()
            .setField(Account.Name, 'AccountName')
            .toSObject();
        User user = (User) TestUtilities2.newUser().toSObject();
        User user2 = (User) TestUtilities2.newUser().toSObject();
        Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup().toSObject();  
        Contact c = (Contact) TestUtilities2.newContact()
            .setField(Contact.OwnerId, user2.Id)
            .setField(Contact.AccountId, a.Id)
            .setField(Contact.Distribution_Group__c, distGroup.Id)
            .toSObject();
    
        ContactsService.syncContactOwners(new Map<Id, Id>{ a.Id => user.Id }, new List<Contact>{c}, uow);      
        Contact contactResult =  (Contact) uow.m_dirtyMapByType.get('Contact').get(c.Id);

        System.assertEquals(1, uow.m_dirtyMapByType.get('Contact').size());     
        System.assertEquals(user.Id, contactResult.OwnerId);
    }

    //TODO - Fix tests below to pass
    /*@isTest static void processDistributionGroup1() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        fflib_ApexMocks mocks = new fflib_ApexMocks();   
        sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity(); 
        Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup()
            .setField(Distribution_Group__c.Customer_Setting__c, 'Prospects Only')
            .setField(Distribution_Group__c.Name, 'Name')
            .toSObject();           
        User user = (User) TestUtilities2.newUser()
            .setField(User.AboutMe, 'AboutMe')
            .toSObject();
        Account parent = (Account) TestUtilities2.newAccount()
            .setField(Account.RecurSoft__Status__c, 'Active')       
            .setField(Account.OwnerId, user.Id) 
            .setChildren('Opportunities', new List<sfab_FabricatedSObject> {oppFab} )
            .toSObject();   
        Account a = (Account) TestUtilities2.newAccount()
            .setField(Account.ParentId, parent.Id)
            .setField(Account.RecurSoft__Status__c, 'Active')            
            .toSObject();
        Contact c = (Contact) TestUtilities2.newContact()
            .setField(Contact.DistGroup__c, 'DistGroup__c')
            .setField(Contact.Distribution_Group__c, distGroup.Id)
            .setField(Contact.AccountId, a.Id)
            .toSObject();   
         insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = user.Id);                   

        Map<Id, Id> contactIdToDistGroupId = new Map<Id, Id>();
        contactIdToDistGroupId.put(c.Id, distGroup.Id);     
        Map<Id, Id> contactIdToUserId = new Map<Id, Id>();      
        
        ContactsSelector mockSelector = (ContactsSelector) mocks.mock(ContactsSelector.class);
        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
            .thenReturn(Contact.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccount(contactIdToDistGroupId.keySet()))
            .thenReturn(new List<Contact> { c });
        mocks.stopStubbing();
        Application.Selector.setMock(mockSelector);

        AccountsSelector mockSelector2 = (AccountsSelector) mocks.mock(AccountsSelector.class);
        mocks.startStubbing();
        mocks.when(mockSelector2.getSObjectType2())
            .thenReturn(Account.SObjectType);
        mocks.when(mockSelector2.selectAccountByContactWithParentAccount(new List<Contact> { c }))
            .thenReturn(new Map<Id, Account> { a.Id => a });
        mocks.stopStubbing();
        Application.Selector.setMock(mockSelector2);

        AccountsSelector mockSelector3 = (AccountsSelector) mocks.mock(AccountsSelector.class);
        mocks.startStubbing();
        mocks.when(mockSelector3.getSObjectType2())
            .thenReturn(Account.SObjectType);
        mocks.when(mockSelector3.selectParentAccountByAccount(new List<Account> { a }))
            .thenReturn(new Map<Id, Account> { parent.Id => parent });
        mocks.stopStubbing();
        Application.Selector.setMock(mockSelector3);

        //ContactsService.skipCustomerStatus(a, parent, c, distGroup, uow);
        ContactsService.processDistributionGroup(contactIdToDistGroupId, contactIdToUserId, uow);       
        System.assertEquals(1, uow.m_dirtyMapByType.get('Contact').size()); 
    }

    @isTest static void getUserWithoutROE() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime roeCutoff = Datetime.now().addDays(-30);
        Account a = new Account(RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Account'),
            Last_ROE_Date__c = Datetime.now().addDays(-31));
        User user1 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        User user2 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        Distribution_Group__c distGroup = new Distribution_Group__c(Id = fflib_IDGenerator.generate(Distribution_Group__c.SObjectType));
        Distribution_Group_Member__c distGroupMember1 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user1.Id,
            Next_Up__c = true);
        Distribution_Group_Member__c distGroupMember2 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user2.Id,
            Next_Up__c = false);
        Distribution_Group__c distGroupWithRelationships = ((List<Distribution_Group__c>)fflib_ApexMocksUtils.makeRelationship(
            List<Distribution_Group__c>.class,
            new List<Distribution_Group__c> { distGroup },
            Distribution_Group_Member__c.Distribution_Group__c,
            new List<List<Distribution_Group_Member__c>> { new List<Distribution_Group_Member__c> { distGroupMember1, distGroupMember2 }}
        ))[0];

        User userReturned = ContactsService.getUser(a, null, distGroupWithRelationships, roeCutoff, uow);
        System.assertEquals(userReturned.Id, user1.Id);
        if(distGroupWithRelationships.Distribution_Group_Members__r[0].Id == distGroupMember1.Id)
        {
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
        else
        {
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
    }

    @isTest static void getUserWithROE() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime roeCutoff = Datetime.now().addDays(-30);
        User user1 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        User user2 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        Account a = new Account(RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Account'),
            OwnerId = user2.Id,
            Last_ROE_Date__c = Datetime.now().addDays(-29));
        Distribution_Group__c distGroup = new Distribution_Group__c(Id = fflib_IDGenerator.generate(Distribution_Group__c.SObjectType));
        Distribution_Group_Member__c distGroupMember1 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user1.Id,
            Next_Up__c = true);
        Distribution_Group_Member__c distGroupMember2 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user2.Id,
            Next_Up__c = false);
        Distribution_Group__c distGroupWithRelationships = ((List<Distribution_Group__c>)fflib_ApexMocksUtils.makeRelationship(
            List<Distribution_Group__c>.class,
            new List<Distribution_Group__c> { distGroup },
            Distribution_Group_Member__c.Distribution_Group__c,
            new List<List<Distribution_Group_Member__c>> { new List<Distribution_Group_Member__c> { distGroupMember1, distGroupMember2 }}
        ))[0];

        User userReturned = ContactsService.getUser(a, null, distGroupWithRelationships, roeCutoff, uow);
        System.assertEquals(userReturned.Id, user2.Id);
        if(distGroupWithRelationships.Distribution_Group_Members__r[0].Id == distGroupMember1.Id)
        {
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
        else
        {
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
    }

    @isTest static void getUserMajorAccount() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime roeCutoff = Datetime.now().addDays(-30);
        User user1 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        User user2 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        Account a = new Account(RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Major Account'),
            OwnerId = user2.Id);
        Distribution_Group__c distGroup = new Distribution_Group__c(Id = fflib_IDGenerator.generate(Distribution_Group__c.SObjectType));
        Distribution_Group_Member__c distGroupMember1 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user1.Id,
            Next_Up__c = true);
        Distribution_Group_Member__c distGroupMember2 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user2.Id,
            Next_Up__c = false);
        Distribution_Group__c distGroupWithRelationships = ((List<Distribution_Group__c>)fflib_ApexMocksUtils.makeRelationship(
            List<Distribution_Group__c>.class,
            new List<Distribution_Group__c> { distGroup },
            Distribution_Group_Member__c.Distribution_Group__c,
            new List<List<Distribution_Group_Member__c>> { new List<Distribution_Group_Member__c> { distGroupMember1, distGroupMember2 }}
        ))[0];

        User userReturned = ContactsService.getUser(a, null, distGroupWithRelationships, roeCutoff, uow);
        System.assertEquals(userReturned.Id, user2.Id);
        if(distGroupWithRelationships.Distribution_Group_Members__r[0].Id == distGroupMember1.Id)
        {
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
        else
        {
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
    }

    @isTest static void getUserChildMajorAccount() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime roeCutoff = Datetime.now().addDays(-30);
        User user1 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        User user2 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        Account a = new Account(RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Child Major Account'),
            OwnerId = user2.Id,
            Last_ROE_Date__c = Datetime.now().addDays(-29));
        Distribution_Group__c distGroup = new Distribution_Group__c(Id = fflib_IDGenerator.generate(Distribution_Group__c.SObjectType));
        Distribution_Group_Member__c distGroupMember1 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user1.Id,
            Next_Up__c = true);
        Distribution_Group_Member__c distGroupMember2 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user2.Id,
            Next_Up__c = false);
        Distribution_Group__c distGroupWithRelationships = ((List<Distribution_Group__c>)fflib_ApexMocksUtils.makeRelationship(
            List<Distribution_Group__c>.class,
            new List<Distribution_Group__c> { distGroup },
            Distribution_Group_Member__c.Distribution_Group__c,
            new List<List<Distribution_Group_Member__c>> { new List<Distribution_Group_Member__c> { distGroupMember1, distGroupMember2 }}
        ))[0];

        User userReturned = ContactsService.getUser(a, null, distGroupWithRelationships, roeCutoff, uow);
        System.assertEquals(userReturned.Id, user2.Id);
        if(distGroupWithRelationships.Distribution_Group_Members__r[0].Id == distGroupMember1.Id)
        {
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
        else
        {
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
    }

    @isTest static void getUserWithoutROEParent() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime roeCutoff = Datetime.now().addDays(-30);
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Account'),
            Last_ROE_Date__c = Datetime.now().addDays(-31));
        Account a = new Account(ParentId = parent.Id,
            RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Child Account'));
        User user1 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        User user2 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        Distribution_Group__c distGroup = new Distribution_Group__c(Id = fflib_IDGenerator.generate(Distribution_Group__c.SObjectType));
        Distribution_Group_Member__c distGroupMember1 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user1.Id,
            Next_Up__c = true);
        Distribution_Group_Member__c distGroupMember2 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user2.Id,
            Next_Up__c = false);
        Distribution_Group__c distGroupWithRelationships = ((List<Distribution_Group__c>)fflib_ApexMocksUtils.makeRelationship(
            List<Distribution_Group__c>.class,
            new List<Distribution_Group__c> { distGroup },
            Distribution_Group_Member__c.Distribution_Group__c,
            new List<List<Distribution_Group_Member__c>> { new List<Distribution_Group_Member__c> { distGroupMember1, distGroupMember2 }}
        ))[0];

        User userReturned = ContactsService.getUser(a, parent, distGroupWithRelationships, roeCutoff, uow);
        System.assertEquals(userReturned.Id, user1.Id);
        if(distGroupWithRelationships.Distribution_Group_Members__r[0].Id == distGroupMember1.Id)
        {
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
        else
        {
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
    }

    @isTest static void getUserWithROEParent() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime roeCutoff = Datetime.now().addDays(-30);
        User user1 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        User user2 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Account'),
            OwnerId = user2.Id,
            Last_ROE_Date__c = Datetime.now().addDays(-29));
        Account a = new Account(ParentId = parent.Id,
            RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Child Account'));
        Distribution_Group__c distGroup = new Distribution_Group__c(Id = fflib_IDGenerator.generate(Distribution_Group__c.SObjectType));
        Distribution_Group_Member__c distGroupMember1 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user1.Id,
            Next_Up__c = true);
        Distribution_Group_Member__c distGroupMember2 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user2.Id,
            Next_Up__c = false);
        Distribution_Group__c distGroupWithRelationships = ((List<Distribution_Group__c>)fflib_ApexMocksUtils.makeRelationship(
            List<Distribution_Group__c>.class,
            new List<Distribution_Group__c> { distGroup },
            Distribution_Group_Member__c.Distribution_Group__c,
            new List<List<Distribution_Group_Member__c>> { new List<Distribution_Group_Member__c> { distGroupMember1, distGroupMember2 }}
        ))[0];

        User userReturned = ContactsService.getUser(a, parent, distGroupWithRelationships, roeCutoff, uow);
        System.assertEquals(userReturned.Id, user2.Id);
        if(distGroupWithRelationships.Distribution_Group_Members__r[0].Id == distGroupMember1.Id)
        {
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
        else
        {
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
    }

    @isTest static void getUserMajorAccountParent() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime roeCutoff = Datetime.now().addDays(-30);
        User user1 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        User user2 = new User(Id = fflib_IDGenerator.generate(User.SObjectType));
        Account parent = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Major Account'),
            OwnerId = user2.Id);
        Account a = new Account(ParentId = parent.Id,
            RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Child Account'));
        Distribution_Group__c distGroup = new Distribution_Group__c(Id = fflib_IDGenerator.generate(Distribution_Group__c.SObjectType));
        Distribution_Group_Member__c distGroupMember1 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user1.Id,
            Next_Up__c = true);
        Distribution_Group_Member__c distGroupMember2 = new Distribution_Group_Member__c(Id = fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType),
            Distribution_Group__c = distGroup.Id, 
            User__c = user2.Id,
            Next_Up__c = false);
        Distribution_Group__c distGroupWithRelationships = ((List<Distribution_Group__c>)fflib_ApexMocksUtils.makeRelationship(
            List<Distribution_Group__c>.class,
            new List<Distribution_Group__c> { distGroup },
            Distribution_Group_Member__c.Distribution_Group__c,
            new List<List<Distribution_Group_Member__c>> { new List<Distribution_Group_Member__c> { distGroupMember1, distGroupMember2 }}
        ))[0];

        User userReturned = ContactsService.getUser(a, parent, distGroupWithRelationships, roeCutoff, uow);
        System.assertEquals(userReturned.Id, user2.Id);
        if(distGroupWithRelationships.Distribution_Group_Members__r[0].Id == distGroupMember1.Id)
        {
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
        else
        {
            System.assert(!distGroupWithRelationships.Distribution_Group_Members__r[0].Next_Up__c);
            System.assert(distGroupWithRelationships.Distribution_Group_Members__r[1].Next_Up__c);
        }
    }*/
}