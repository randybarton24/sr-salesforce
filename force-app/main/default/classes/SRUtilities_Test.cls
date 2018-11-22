@isTest
private class SRUtilities_Test 
{
	@isTest static void test_getStdPricebookId()
	{
        SRUtilities.getStdPricebookId();
        SRUtilities.getStdPriceBook();
	}

	@isTest static void test_getRecordType()
	{
        SRUtilities.getRecordTypeId('Account', 'Account');
        SRUtilities.getRecordTypeName('Account', SRUtilities.getRecordTypeId('Account', 'Account'));
	}

	@isTest static void test_scheduleAsync()
	{
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        SRUtilities.scheduleAsync(new Set<Id>{ TestUtilities2.newAccount().toSObject().Id }, 'Test');
        SRUtilities.scheduleAsync(new Set<Id>{ TestUtilities2.newAccount().toSObject().Id }, 'Test', uow);
        SRUtilities.scheduleAsync(new Set<String>{ TestUtilities2.newAccount().toSObject().Id }, 'Test', uow);
	}

	@isTest static void test_runDMLInsert()
	{
        SObject a = TestUtilities2.newAccount().toSObject();
        Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>{ a.Id => a };
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();
        SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'Test');
        SRUtilities.runDmlNoLock(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'Test');
	}

	@isTest static void test_runDMLUpdate()
	{
        SObject a = TestUtilities2.newAccount().toSObject();
        Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>{ a.Id => a };
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();
        SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'Test');
        SRUtilities.runDmlNoLock(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'Test');
	}

	@isTest static void test_runDMLDelete()
	{
        SObject a = TestUtilities2.newAccount().toSObject();
        Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>{ a.Id => a };
        SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'Test');
        SRUtilities.runDmlNoLock(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'Test');
	}


	@isTest static void test_SRUnitOfWorkInsert()
	{
        SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();
        Opportunity o = new Opportunity();
        Opportunity o1 = new Opportunity();
        sruow.registerNewWithCatch(o);
        sruow.registerNewWithCatch(o1);
        sruow.doWork();
	}

	@isTest static void test_SRUnitOfWorkUpdate()
	{
        SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();
        Account a = (Account) TestUtilities2.newAccount().toSObject();
        Account a1 = (Account) TestUtilities2.newAccount().toSObject();
        sruow.registerDirtyWithCatch(a);
        sruow.registerDirtyWithCatch(a1);
        sruow.doWork();
	}

	@isTest static void test_processStampUpdates() 
	{					
		User user1 = (User) TestUtilities2.newUser()
            .toSObject();
		Campaign_Influence__c ci1 = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence()                   
            .setField(Campaign_Influence__c.Source_User__c, user1.Id)
            .toSObject();
        Stamp_Field_Mapping__c stamp1 = (Stamp_Field_Mapping__c) new sfab_FabricatedSObject(Stamp_Field_Mapping__c.class)
            .setField(Stamp_Field_Mapping__c.Id, fflib_IDGenerator.generate(Stamp_Field_Mapping__c.SObjectType))
            .setField(Stamp_Field_Mapping__c.Field_Changed__c, 'Source_User__c')
            .setField(Stamp_Field_Mapping__c.Stamp_To_Object__c, 'Campaign_Influence__c')
            .setField(Stamp_Field_Mapping__c.Active__c, true)                    
            .toSObject();            
		
		SRUtilities.processStampUpdates(ci1, null, new List<Stamp_Field_Mapping__c>{ stamp1 });		
	}

	@isTest static void test_processStampUpdates2() 
	{					
		User user1 = (User) TestUtilities2.newUser()
            .toSObject();
        User user2 = (User) TestUtilities2.newUser()
            .toSObject();
		Campaign_Influence__c ci1 = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence()                   
            .setField(Campaign_Influence__c.Source_User__c, user1.Id)
            .toSObject();
        Campaign_Influence__c existingCampaignInfluence = (Campaign_Influence__c) TestUtilities2.existingCampaignInfluence(ci1)                   
            .setField(Campaign_Influence__c.Source_User__c, user2.Id)
            .toSObject();
        Stamp_Field_Mapping__c stamp1 = (Stamp_Field_Mapping__c) new sfab_FabricatedSObject(Stamp_Field_Mapping__c.class)
            .setField(Stamp_Field_Mapping__c.Id, fflib_IDGenerator.generate(Stamp_Field_Mapping__c.SObjectType))
            .setField(Stamp_Field_Mapping__c.Field_Changed__c, 'Source_User__c')
            .setField(Stamp_Field_Mapping__c.Stamp_To_Object__c, 'Campaign_Influence__c')
            .setField(Stamp_Field_Mapping__c.Active__c, true)                    
            .toSObject();            
		
		SRUtilities.processStampUpdates(ci1, existingCampaignInfluence, new List<Stamp_Field_Mapping__c>{ stamp1 });		
	}

	@isTest static void test_processStampUpdates3() 
	{					
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Stamp_Field_Mapping__c stamp1 = new Stamp_Field_Mapping__c(Stamp_From_Object__c = 'Source_User__r:Manager',
			Stamp_To_Field__c = 'Source_User_Manager__c',
			Stamp_From_Field__c = 'ManagerId',
			Field_Changed__c = 'Source_User__c',
			Stamp_To_Object__c = 'Campaign_Influence__c',
			Active__c = true);
		insert stamp1;

		sfab_FabricatedSObject vp1 = TestUtilities2.newUser();
        sfab_FabricatedSObject mgr1 = TestUtilities2.newUser()
            .setField(User.ManagerId, vp1.toSObject().Id);
        sfab_FabricatedSObject user1 = TestUtilities2.newUser()
            .setField(User.ManagerId, mgr1.toSObject().Id)
            .setParent('Manager', mgr1);
        sfab_FabricatedSObject user2 = TestUtilities2.newUser()
            .setField(User.ManagerId, mgr1.toSObject().Id)
            .setParent('Manager', mgr1);
		Campaign_Influence__c ci1 = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence()                   
            .setField(Campaign_Influence__c.Source_User__c, user1.toSObject().Id)
            .setParent('Source_User__r', user1)
            .toSObject();
        Campaign_Influence__c existingCampaignInfluence = (Campaign_Influence__c) TestUtilities2.existingCampaignInfluence(ci1)                   
            .setField(Campaign_Influence__c.Source_User__c, user2.toSObject().Id)
            .setParent('Source_User__r', user2)
            .toSObject();        
			
		SRUtilities.processStampUpdates(new Map<Id, Set<String>>{ ci1.Id => new Set<String>{ stamp1.Id }}, new List<SObject>{ ci1 }, uow);
	}

	@isTest static void test_Other()
	{
        SRUtilities.titleCase('String phrase');
        SRUtilities.scrubPhone('801.331.7100');
        SRUtilities.sendErrorEmail(new SRUtilities.SRException(), 'Test');
	}
}