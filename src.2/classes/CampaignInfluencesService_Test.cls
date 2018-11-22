@isTest
private class CampaignInfluencesService_Test 
{	
	@isTest static void test_createCIs() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
			.toSObject();
		sfab_FabricatedSObject acct = TestUtilities2.newAccount()
			.setField(Account.Active_Opportunity__c, opp.Id);
		Campaign camp1 = (Campaign) TestUtilities2.newCampaign()
			.toSObject();
		Contact c1 = (Contact) TestUtilities2.newContact()	
			.setField(Contact.CampaignId__c, camp1.Id)
			.setField(Contact.AccountId, ((Account) acct.toSObject()).Id)
			.setParent('Account', acct)				
			.toSObject();
		User user = (User) TestUtilities2.newUser()
			.toSObject();	
		AsyncRequest__c async = (AsyncRequest__c) TestUtilities2.newAsyncRequest()
			.setField(AsyncRequest__c.CreatedDate, Datetime.now())
			.toSObject();	

		Map<Id, Id> contactIdToCampaignId = new Map<Id, Id>{ c1.Id => camp1.Id };
		Map<Id, Id> contactIdToUserId = new Map<Id, Id>{ c1.Id => user.Id };

		ContactsSelector mockSelector = (ContactsSelector) mocks.mock(ContactsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Contact.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccount(contactIdToCampaignId.keySet()))
        	.thenReturn(new List<Contact>{ c1 });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

		CampaignInfluencesService.createCIs(contactIdToCampaignId, contactIdToUserId, async, uow);	
		List<Campaign_Influence__c> campInfluenceResult = (List<Campaign_Influence__c>)(uow.m_newListByType.get('Campaign_Influence__c'));

		System.assertEquals(1, uow.m_newListByType.get('Campaign_Influence__c').size());
		System.assertEquals(1, uow.m_dirtyMapByType.get('Contact').size());		
		System.assertEquals(null, uow.m_dirtyMapByType.get('Contact').get(c1.Id).get('CampaignId__c'));		
		System.assertEquals(camp1.Id, campInfluenceResult[0].Campaign__c);
		System.assertEquals(c1.Id, campInfluenceResult[0].Contact__c);
		System.assertEquals(((Account) acct.toSObject()).Id, campInfluenceResult[0].Account__c);
		System.assertEquals(opp.Id, campInfluenceResult[0].Opportunity__c);
		System.assertEquals(user.Id, campInfluenceResult[0].Source_User__c);
		System.assertEquals(async.CreatedDate, campInfluenceResult[0].Campaign_Add_Date__c);
	}

	@isTest static void test_createCIsFromOpps1() 
	{
		fflib_SObjectUnitOfWork uow1 = Application.UnitOfWork.newInstance();
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		
		Account ac1 = (Account) TestUtilities2.newAccount().toSObject();
		Opportunity op1 = (Opportunity) TestUtilities2.newOpportunity()
			.setField(Opportunity.AccountId, ac1.Id)
			.toSObject();
		Campaign  cp1 = (Campaign) TestUtilities2.newCampaign().toSObject();
		User  usr1 = (User) TestUtilities2.newUser().toSObject();
		AsyncRequest__c as1 = (AsyncRequest__c) TestUtilities2.newAsyncRequest()
			.setField(AsyncRequest__c.CreatedDate, Datetime.now())
			.toSObject();
		
		Map<Id,Id> oppIdToCampaignId = new Map<Id, Id>{ op1.Id => cp1.Id };
		Map<Id,Id> oppIdToUserId  = new Map<Id, Id>{ op1.Id => usr1.Id };

		OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

		mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccountAndProducts(oppIdToCampaignId.keySet()))
        	.thenReturn(new List<Opportunity>{ op1 });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

		CampaignInfluencesService.createCIsFromOpps(oppIdToCampaignId, oppIdToUserId, as1, uow1);
		List<Campaign_Influence__c> campInfluenceResult = (List<Campaign_Influence__c>)(uow1.m_newListByType.get('Campaign_Influence__c'));

		System.assertEquals(1, uow1.m_newListByType.get('Campaign_Influence__c').size());
		System.assertEquals(cp1.Id, campInfluenceResult[0].Campaign__c);		
		System.assertEquals(ac1.Id, campInfluenceResult[0].Account__c);
		System.assertEquals(op1.Id, campInfluenceResult[0].Opportunity__c);
		System.assertEquals(usr1.Id, campInfluenceResult[0].Source_User__c);
		System.assertEquals(as1.CreatedDate, campInfluenceResult[0].Campaign_Add_Date__c);
	}


	@isTest static void test_linkOppOnCIs() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		
		insert new SR_Default_Values__c(Name = 'opportunityCiLookback',
			Description__c = 'opportunityCiLookback',
            Value__c = '90');
		
		sfab_FabricatedSObject oppFab =  TestUtilities2.newOpportunity()
			.setField(Opportunity.CreatedDate, Date.newInstance(2017, 01, 20));

		Opportunity opp = (Opportunity) oppFab.toSObject();

		sfab_FabricatedSObject acFab =  TestUtilities2.newAccount()
			.setField(Account.Active_Opportunity__c, opp.Id)
			.setParent('Active_Opportunity__r', oppFab);	
		
		Account ac = (Account) acFab.toSObject();

		Campaign_Influence__c cis = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence()			
			.setField(Campaign_Influence__c.Campaign_Add_Date__c, Date.newInstance(2018, 06, 20))
			.setField(Campaign_Influence__c.Account__c, ac.Id)
			.setParent('Account__r', acFab)							
			.toSObject();

		Set<Id> ids = new Set<Id>();
		ids.add(ac.Id);		

		CampaignInfluencesSelector mockSelector = (CampaignInfluencesSelector) mocks.mock(CampaignInfluencesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Campaign_Influence__c.SObjectType);
        mocks.when(mockSelector.selectCisByAccountId(ids))
        	.thenReturn(new List<Campaign_Influence__c>{ cis });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

		CampaignInfluencesService.linkOppOnCIs(ids, uow);	
		
		System.assertEquals(1, uow.m_dirtyMapByType.get('Campaign_Influence__c').size());
		System.assertEquals(opp.Id, cis.Opportunity__c);
	}

	@isTest static void test_setDemoRequestReason() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		fflib_ApexMocks mocks = new fflib_ApexMocks();			

		sfab_FabricatedSObject c = TestUtilities2.newCampaign()
			.setField(Campaign.Sub_Type__c, 'Demo');

		sfab_FabricatedSObject ci = TestUtilities2.newCampaignInfluence()			
			.setField(Campaign_Influence__c.Demo_Request_Reason__c, true)
			.setField(Campaign_Influence__c.Campaign_Add_Date__c, Date.today())			
			.setParent('Campaign__r', c);
			
		Campaign_Influence__c cis = (Campaign_Influence__c) ci.toSObject();

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
			.setChildren('Campaign_Influence__r', new List<sfab_FabricatedSObject> { ci })
			.toSObject();			
		
		CampaignInfluencesService.setDemoRequestReason(new List<Opportunity> {opp}, uow);			
		
		System.assertEquals(1, uow.m_dirtyMapByType.get('Campaign_Influence__c').size());				
		System.assertEquals(1, uow.m_dirtyMapByType.get('Opportunity').size());				
		System.assertEquals(cis.Id, opp.Demo_Request_Reason__c);
		System.assertEquals(true, cis.Demo_Request_Reason__c);
	}
}