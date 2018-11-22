@isTest
private class OpportunitiesService_Test {
	
	@testSetup static void testData() 
	{
	    TestUtilities.insertCustomSettings();
	}

	@isTest static void test_sendContractEmail() 
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();	

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()	
			.toSObject();	

		AsyncRequest__c ar = (AsyncRequest__c) TestUtilities2.newAsyncRequest()
			.setField(AsyncRequest__c.Params__c, opp.Id)
			.toSObject();

		Set<Id> ids = new Set<Id>();	
		ids.Add(opp.Id);

		OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccountAndProducts(ids))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
		OpportunitiesService.sendContractEmail(ar);
	}

	@isTest static void test_addRevenueToADRSetTask() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		fflib_ApexMocks mocks = new fflib_ApexMocks();			
		
		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

		Task t = (Task) TestUtilities2.newTask()
			.setField(Task.CreatedDate, Date.today())
			.setField(Task.ADR_Set__c, true)
			.setField(Task.Activity_Results__c, 'Spoke with-')
			.toSObject(); 		

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
			.setField(Opportunity.AccountId, ac.Id)
			.setField(Opportunity.RecurSoft__Contract_Signed_Date__c, Date.today())
			.setField(Opportunity.SR_Monthly_Revenue__c, 10)
			.setField(Opportunity.Monthly_Revenue__c, 20)		
			.toSObject();		

		Set<Id> ids = new Set<Id>();	
		ids.Add(opp.Id);

		OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccountAndProducts(ids))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        TasksSelector mockSelector2 = (TasksSelector) mocks.mock(TasksSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector2.getSObjectType2())
        	.thenReturn(Task.SObjectType);
        mocks.when(mockSelector2.selectByOpportunityAccountId(new List<Opportunity> { opp }))
        	.thenReturn(new Map<Id, Task>{ac.Id => t});
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector2);
		
		OpportunitiesService.addRevenueToADRSetTask(ids, uow);			
				
		System.assertEquals(1, uow.m_dirtyMapByType.get('Task').size());	
		System.assertEquals(opp.Monthly_Revenue__c, t.ADR_Set_SR_Revenue__c);	
	}

	@isTest static void test_addRevenueToADRSetTask2() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		fflib_ApexMocks mocks = new fflib_ApexMocks();			
		
		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

		Task t = (Task) TestUtilities2.newTask()
			.setField(Task.CreatedDate, Date.today())
			.setField(Task.ADR_Set__c, true)
			.setField(Task.Activity_Results__c, 'Spoke with-')
			.toSObject(); 		

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
			.setField(Opportunity.AccountId, ac.Id)
			.setField(Opportunity.RecurSoft__Contract_Signed_Date__c, Date.today())
			.setField(Opportunity.SR_Monthly_Revenue__c, 10)
			.setField(Opportunity.Monthly_Revenue__c, 20)		
			.toSObject();		
		
		OpportunitiesService.addRevenueToADRSetTask(opp, t, uow);			
				
		System.assertEquals(1, uow.m_dirtyMapByType.get('Task').size());	
		System.assertEquals(opp.Monthly_Revenue__c, t.ADR_Set_SR_Revenue__c);	
	}
	
	@isTest static void test_closeAddendum() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		fflib_ApexMocks mocks = new fflib_ApexMocks();			
		
		sfab_FabricatedSObject adFab = TestUtilities2.newAddendum();

		Addendum__c ad = (Addendum__c) adFab.toSObject();

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()			
			.setChildren('Addenda__r', new List<sfab_FabricatedSObject> { adFab })	
			.toSObject();		

		Set<Id> ids = new Set<Id>();	
		ids.Add(opp.Id);

		OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithAddenda(ids))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
        
		OpportunitiesService.closeAddendum(ids, uow);			
				
		System.assertEquals(1, uow.m_dirtyMapByType.get('Addendum__c').size());	
		System.assertEquals('Closed', opp.Addenda__r[0].Status__c);
	}

	@isTest static void test_closeAddendum2() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		fflib_ApexMocks mocks = new fflib_ApexMocks();			
		
		sfab_FabricatedSObject adFab = TestUtilities2.newAddendum();

		Addendum__c ad = (Addendum__c) adFab.toSObject();

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()			
			.setChildren('Addenda__r', new List<sfab_FabricatedSObject> { adFab })	
			.toSObject();		

		OpportunitiesService.closeAddendum(opp, uow);			
				
		System.assertEquals(1, uow.m_dirtyMapByType.get('Addendum__c').size());	
		System.assertEquals('Closed', opp.Addenda__r[0].Status__c);
	}

	@isTest static void test_createAssetForClosedOpps() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		fflib_ApexMocks mocks = new fflib_ApexMocks();		

		sfab_FabricatedSObject pr = TestUtilities2.newProduct()
			.setField(Product2.Family, 'SR Platform');

		sfab_FabricatedSObject pr2 = TestUtilities2.newProduct()
			.setField(Product2.Family, 'SR Reminders');

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
			.setField(PricebookEntry.Product2Id, ((Product2) pr2.toSObject()).Id)
			.setParent('Product2', pr2); 	

		sfab_FabricatedSObject ast = TestUtilities2.newAsset()
			.setField(Asset.Product2Id, ((Product2) pr.toSObject()).Id)
			.setParent('Product2', pr);

		sfab_FabricatedSObject acFab =  TestUtilities2.newAccount()
			.setField(Account.Subscriber_Id__c, 'Test')
			.setChildren('Assets', new List<sfab_FabricatedSObject> {ast});			

		Provider__c prov = (Provider__c) TestUtilities2.newProvider().toSObject();

		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2().toSObject();

		sfab_FabricatedSObject oppLi = TestUtilities2.newOpportunityLineItem()			
        	.setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
        	.setField(OpportunityLineItem.UnitPrice, 50)
        	.setField(OpportunityLineItem.Quantity, 40)
        	.setField(OpportunityLineItem.Trial_End_Date__c, Date.today())
        	.setField(OpportunityLineItem.Provider__c, prov.Id)
        	.setParent('PricebookEntry', pbe);  

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()			
			.setField(Opportunity.AccountId, ((Account) acFab.toSObject()).Id)	
			.setField(Opportunity.Pricebook2Id, pb.Id)
			.setField(Opportunity.RecurSoft__Contract_Signed_Date__c, Date.today())
			.setParent('Account', acFab)
			.setChildren('OpportunityLineItems', new List<sfab_FabricatedSObject> {oppLi})
			.toSObject();		

		Set<Id> ids = new Set<Id>();	
		ids.Add(opp.Id);

		OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccountAndProducts(ids))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        AccountsSelector mockSelector2 = (AccountsSelector) mocks.mock(AccountsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector2.getSObjectType2())
        	.thenReturn(Account.SObjectType);
        mocks.when(mockSelector2.selectAccountByOpportunityWithAssets(new List<Opportunity> { opp }))
        	.thenReturn(new Map<Id, Account> { ((Account) acFab.toSObject()).Id => (Account) acFab.toSObject() });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector2);
        
		OpportunitiesService.createAssetForClosedOpps(ids, uow);			
		List<Asset> asset = (List<Asset>)(uow.m_newListByType.get('Asset'));

		System.assertEquals(1, uow.m_newListByType.get('Asset').size());	
		System.assertEquals(((Account) acFab.toSObject()).Id, asset[0].AccountId);
		System.assertEquals(opp.Account.Subscriber_Id__c + ': ' + opp.OpportunityLineItems[0].PricebookEntry.Product2.Family, asset[0].Name);
		System.assertEquals(opp.Pricebook2Id, asset[0].Most_Recent_Pricebook__c);
		System.assertEquals(opp.OpportunityLineItems[0].UnitPrice, asset[0].Price);
		System.assertEquals(opp.OpportunityLineItems[0].PricebookEntry.Product2Id, asset[0].Product2Id);
		System.assertEquals(opp.OpportunityLineItems[0].Quantity, asset[0].Quantity);
		System.assertEquals(opp.RecurSoft__Contract_Signed_Date__c, asset[0].Original_Contract_Signed_Date__c);
		System.assertEquals(opp.OpportunityLineItems[0].Trial_End_Date__c, asset[0].Trial_End_Date__c);
		System.assertEquals('Active', asset[0].Status);
		System.assertEquals(opp.OpportunityLineItems[0].Provider__c, asset[0].Provider__c);
	}

	@isTest static void test_createAssetForClosedOpps2() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			
		sfab_FabricatedSObject pr = TestUtilities2.newProduct()
			.setField(Product2.Family, 'SR Platform');

		sfab_FabricatedSObject pr2 = TestUtilities2.newProduct()
			.setField(Product2.Family, 'SR Reminders');

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
			.setField(PricebookEntry.Product2Id, ((Product2) pr2.toSObject()).Id)
			.setParent('Product2', pr2); 	

		sfab_FabricatedSObject ast = TestUtilities2.newAsset()
			.setField(Asset.Product2Id, ((Product2) pr.toSObject()).Id)
			.setParent('Product2', pr);

		sfab_FabricatedSObject acFab =  TestUtilities2.newAccount()
			.setField(Account.Subscriber_Id__c, 'Test')
			.setChildren('Assets', new List<sfab_FabricatedSObject> {ast});			

		Provider__c prov = (Provider__c) TestUtilities2.newProvider().toSObject();

		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2().toSObject();

		sfab_FabricatedSObject oppLi = TestUtilities2.newOpportunityLineItem()			
        	.setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
        	.setField(OpportunityLineItem.UnitPrice, 50)
        	.setField(OpportunityLineItem.Quantity, 40)
        	.setField(OpportunityLineItem.Trial_End_Date__c, Date.today())
        	.setField(OpportunityLineItem.Provider__c, prov.Id)
        	.setParent('PricebookEntry', pbe);  

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()			
			.setField(Opportunity.AccountId, ((Account) acFab.toSObject()).Id)	
			.setField(Opportunity.Pricebook2Id, pb.Id)
			.setField(Opportunity.RecurSoft__Contract_Signed_Date__c, Date.today())
			.setParent('Account', acFab)
			.setChildren('OpportunityLineItems', new List<sfab_FabricatedSObject> {oppLi})
			.toSObject();		
		 
		OpportunitiesService.createAssetForClosedOpps(opp, (Account) acFab.toSObject(), uow);			
		List<Asset> asset = (List<Asset>)(uow.m_newListByType.get('Asset'));

		System.assertEquals(1, uow.m_newListByType.get('Asset').size());	
		System.assertEquals(((Account) acFab.toSObject()).Id, asset[0].AccountId);
		System.assertEquals(opp.Account.Subscriber_Id__c + ': ' + opp.OpportunityLineItems[0].PricebookEntry.Product2.Family, asset[0].Name);
		System.assertEquals(opp.Pricebook2Id, asset[0].Most_Recent_Pricebook__c);
		System.assertEquals(opp.OpportunityLineItems[0].UnitPrice, asset[0].Price);
		System.assertEquals(opp.OpportunityLineItems[0].PricebookEntry.Product2Id, asset[0].Product2Id);
		System.assertEquals(opp.OpportunityLineItems[0].Quantity, asset[0].Quantity);
		System.assertEquals(opp.RecurSoft__Contract_Signed_Date__c, asset[0].Original_Contract_Signed_Date__c);
		System.assertEquals(opp.OpportunityLineItems[0].Trial_End_Date__c, asset[0].Trial_End_Date__c);
		System.assertEquals('Active', asset[0].Status);
		System.assertEquals(opp.OpportunityLineItems[0].Provider__c, asset[0].Provider__c);
	}

	@isTest static void test_newActivationCase() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		fflib_ApexMocks mocks = new fflib_ApexMocks();	
				
		sfab_FabricatedSObject pr2 = TestUtilities2.newProduct()
			.setField(Product2.Family, 'SR Reminders');

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
			.setField(PricebookEntry.Product2Id, ((Product2) pr2.toSObject()).Id)
			.setParent('Product2', pr2); 

		sfab_FabricatedSObject ca = TestUtilities2.newCases()
			.setField(Case.Subject, 'SR Schedule Implementation')
			.setField(Case.RecordTypeId, SRUtilities.getRecordTypeId('Case','Activation'))
			.setField(Case.Status, 'New');	

		sfab_FabricatedSObject acFab =  TestUtilities2.newAccount()
			.setField(Account.RecordTypeId, SRUtilities.getRecordTypeId('Account', 'Major Account'))
			.setChildren('Cases', new List<sfab_FabricatedSObject> {ca});			
		
		Contact con = (Contact) TestUtilities2.newContact().toSObject();

		User user = (User) TestUtilities2.newUser().toSObject();

		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2().toSObject();

		sfab_FabricatedSObject oppLi = TestUtilities2.newOpportunityLineItem()			
        	.setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)       
        	.setParent('PricebookEntry', pbe);  

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()			
			.setField(Opportunity.AccountId, ((Account) acFab.toSObject()).Id)	
			.setField(Opportunity.Pricebook2Id, pb.Id)
			.setField(Opportunity.RecurSoft__Billing_Contact__c, con.Id)
			.setField(Opportunity.OwnerId, user.Id)
			.setField(Opportunity.Contract_Signed__c, true)
			.setParent('Account', acFab)
			.setChildren('OpportunityLineItems', new List<sfab_FabricatedSObject> {oppLi})
			.toSObject();	

		insert new SR_Default_Values__c(Name = 'SRC Onboarding Queue',
			Description__c = 'SRC Onboarding Queue',
            Value__c = '1');
		insert new SR_Default_Values__c(Name = 'SRSR Onboarding Queue',
			Description__c = 'SRSR Onboarding Queue',
            Value__c = '2');
		insert new SR_Default_Values__c(Name = 'SRS Onboarding Queue',
			Description__c = 'SRS Onboarding Queue',
            Value__c = '3');
		insert new SR_Default_Values__c(Name = 'Case Round Robin Owner ID',
			Description__c = 'Case Round Robin Owner ID',
            Value__c = '4');

		Set<Id> ids = new Set<Id>();	
		ids.Add(opp.Id);

		OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccountAndProducts(ids))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        AccountsSelector mockSelector2 = (AccountsSelector) mocks.mock(AccountsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector2.getSObjectType2())
        	.thenReturn(Account.SObjectType);
        mocks.when(mockSelector2.selectByOpportunityWithCases(new List<Opportunity> { opp }))
        	.thenReturn(new Map<Id, Account> { ((Account) acFab.toSObject()).Id => (Account) acFab.toSObject() });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector2);
        
		OpportunitiesService.newActivationCase(ids, uow);								
		List<Case> caseList = (List<Case>)(uow.m_newListByType.get('Case'));
		
		System.assertEquals(1, uow.m_newListByType.get('Case').size());	
		System.assertEquals('SRC + Reminders Implementation', caseList[0].Subject);
		System.assertEquals(opp.AccountId, caseList[0].AccountId);
		System.assertEquals(opp.Id, caseList[0].Related_Opportunity__c);
		System.assertEquals(opp.RecurSoft__Billing_Contact__c, caseList[0].ContactId);
		System.assertEquals(SRUtilities.getRecordTypeId('Case','Activation'), caseList[0].RecordTypeId);
		System.assertEquals('SRC + Reminders', caseList[0].Product__c);
		System.assertEquals('Web', caseList[0].Origin);
		System.assertEquals('New', caseList[0].Status);
		System.assertEquals('Medium', caseList[0].Priority);
		System.assertEquals('Training', caseList[0].Category__c);
		System.assertEquals('General Training', caseList[0].Topics__c);
		System.assertEquals(opp.OwnerId, caseList[0].OwnerId);
	}

	@isTest static void test_newActivationCase2() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();		
	
		sfab_FabricatedSObject pr2 = TestUtilities2.newProduct()
			.setField(Product2.Family, 'SR Reminders');

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
			.setField(PricebookEntry.Product2Id, ((Product2) pr2.toSObject()).Id)
			.setParent('Product2', pr2); 

		sfab_FabricatedSObject ca = TestUtilities2.newCases()
			.setField(Case.Subject, 'SR Schedule Implementation')
			.setField(Case.RecordTypeId, SRUtilities.getRecordTypeId('Case','Activation'))
			.setField(Case.Status, 'New');	

		sfab_FabricatedSObject acFab =  TestUtilities2.newAccount()
			.setField(Account.RecordTypeId, SRUtilities.getRecordTypeId('Account', 'Major Account'))
			.setChildren('Cases', new List<sfab_FabricatedSObject> {ca});			
		
		Contact con = (Contact) TestUtilities2.newContact().toSObject();

		User user = (User) TestUtilities2.newUser().toSObject();

		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2().toSObject();

		sfab_FabricatedSObject oppLi = TestUtilities2.newOpportunityLineItem()			
        	.setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)       
        	.setParent('PricebookEntry', pbe);  

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()			
			.setField(Opportunity.AccountId, ((Account) acFab.toSObject()).Id)	
			.setField(Opportunity.Pricebook2Id, pb.Id)
			.setField(Opportunity.RecurSoft__Billing_Contact__c, con.Id)
			.setField(Opportunity.OwnerId, user.Id)
			.setField(Opportunity.Contract_Signed__c, true)
			.setParent('Account', acFab)
			.setChildren('OpportunityLineItems', new List<sfab_FabricatedSObject> {oppLi})
			.toSObject();	

		insert new SR_Default_Values__c(Name = 'SRC Onboarding Queue',
			Description__c = 'SRC Onboarding Queue',
            Value__c = '1');
		insert new SR_Default_Values__c(Name = 'SRSR Onboarding Queue',
			Description__c = 'SRSR Onboarding Queue',
            Value__c = '2');
		insert new SR_Default_Values__c(Name = 'SRS Onboarding Queue',
			Description__c = 'SRS Onboarding Queue',
            Value__c = '3');
		insert new SR_Default_Values__c(Name = 'Case Round Robin Owner ID',
			Description__c = 'Case Round Robin Owner ID',
            Value__c = '4');
		 
		OpportunitiesService.newActivationCase(opp, ((Account) acFab.toSObject()), uow);								
		List<Case> caseList = (List<Case>)(uow.m_newListByType.get('Case'));
		
		System.assertEquals(1, uow.m_newListByType.get('Case').size());	
		System.assertEquals('SRC + Reminders Implementation', caseList[0].Subject);
		System.assertEquals(opp.AccountId, caseList[0].AccountId);
		System.assertEquals(opp.Id, caseList[0].Related_Opportunity__c);
		System.assertEquals(opp.RecurSoft__Billing_Contact__c, caseList[0].ContactId);
		System.assertEquals(SRUtilities.getRecordTypeId('Case','Activation'), caseList[0].RecordTypeId);
		System.assertEquals('SRC + Reminders', caseList[0].Product__c);
		System.assertEquals('Web', caseList[0].Origin);
		System.assertEquals('New', caseList[0].Status);
		System.assertEquals('Medium', caseList[0].Priority);
		System.assertEquals('Training', caseList[0].Category__c);
		System.assertEquals('General Training', caseList[0].Topics__c);
		System.assertEquals(opp.OwnerId, caseList[0].OwnerId);
	}

	@isTest static void test_setAccountBillingEmailFromBillToContact() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		fflib_ApexMocks mocks = new fflib_ApexMocks();					

		sfab_FabricatedSObject cFab = TestUtilities2.newContact()
			.setField(Contact.Email, 'salesforce@email.com');

		Contact c = (Contact) cFab.toSObject();					

		Account ac = (Account) TestUtilities2.newAccount().toSObject();

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()			
			.setField(Opportunity.AccountId, ac.Id)
			.setField(Opportunity.RecurSoft__Billing_Contact__c, c.Id)	
			.setParent('RecurSoft__Billing_Contact__r', cFab)
			.toSObject();	

		Set<Id> ids = new Set<Id>();	
		ids.Add(opp.Id);

		OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccountAndProducts(ids))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
        
		OpportunitiesService.setAccountBillingEmailFromBillToContact(ids, uow);
	
		System.assertEquals(1, uow.m_dirtyMapByType.get('Account').size());	
		System.assertEquals(opp.AccountId, uow.m_dirtyMapByType.get('Account').get(ac.Id).get('Id'));	
		System.assertEquals(opp.RecurSoft__Billing_Contact__r.Email, uow.m_dirtyMapByType.get('Account').get(ac.Id).get('RecurSoft__Billing_Email__c'));							
	}

	@isTest static void test_setAccountBillingEmailFromBillToContact2() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();				

		sfab_FabricatedSObject cFab = TestUtilities2.newContact()
			.setField(Contact.Email, 'salesforce@email.com');

		Contact c = (Contact) cFab.toSObject();					

		Account ac = (Account) TestUtilities2.newAccount().toSObject();

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()			
			.setField(Opportunity.AccountId, ac.Id)
			.setField(Opportunity.RecurSoft__Billing_Contact__c, c.Id)	
			.setParent('RecurSoft__Billing_Contact__r', cFab)
			.toSObject();	

		OpportunitiesService.setAccountBillingEmailFromBillToContact(opp, uow);
	
		System.assertEquals(1, uow.m_dirtyMapByType.get('Account').size());	
		System.assertEquals(opp.AccountId, uow.m_dirtyMapByType.get('Account').get(ac.Id).get('Id'));	
		System.assertEquals(opp.RecurSoft__Billing_Contact__r.Email, uow.m_dirtyMapByType.get('Account').get(ac.Id).get('RecurSoft__Billing_Email__c'));							
	}	
}