@isTest
private class Opportunities_Test 
{	
	@testSetup static void testData() 
	{
	    TestUtilities.insertCustomSettings();
	}

	@isTest static void test_beforeInsert() 
	{		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity();			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.onBeforeInsert();
	}

	@isTest static void test_afterInsert() 
	{		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.OwnerId, UserInfo.getUserId());			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.onAfterInsert();
	}

	@isTest static void test_beforeUpdate() 
	{		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity();			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.onBeforeUpdate(new Map<Id, SObject>(new List<Opportunity> {opp}));
	}

	@isTest static void test_afterUpdate() 
	{		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.OwnerId, UserInfo.getUserId());			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.onAfterUpdate(new Map<Id, SObject>(new List<Opportunity> {opp}));
	}

	@isTest static void test_addRevenueToADRSetTask() 
	{		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'))
			.setField(Opportunity.Monthly_Revenue__c, 1)			
			.setField(Opportunity.StageName, 'Closed Won');			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)
			.setField(Opportunity.Monthly_Revenue__c, 2)
			.setField(Opportunity.StageName, 'Test')
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.addRevenueToADRSetTask(opp, existingOpp);
		
		System.assertEquals(1, opportunities.addRevenueToADRSetTask.size());
		System.assert(opportunities.addRevenueToADRSetTask.contains(opp.Id));
	}

	@isTest static void test_checkApprovalCommentsRequired() 
	{	
		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
			.setField(Opportunity.Approval_Comment_Check__c, 'Requested')			
			.toSObject();
				
		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkApprovalCommentsRequired(opp);
		
		System.assertEquals(null, opp.Approval_Comment_Check__c);
	}

	@isTest static void test_checkForResetApprovals1() 
	{	
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId())
			.setField(Opportunity.OwnerId, 1);			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)
			.setField(Opportunity.OwnerId, 2)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkForResetApprovals(opp, existingOpp);
		
		System.assertEquals(1, opportunities.resetApprovals.size());
		System.assert(opportunities.resetApprovals.contains(opp.Id));
	} 

	@isTest static void test_checkForResetApprovals2() 
	{	
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId())
			.setField(Opportunity.OwnerId, 1);			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)
			.setField(Opportunity.OwnerId, 2)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkForResetApprovals(opp, existingOpp);
		
		System.assertEquals(1, opportunities.resetApprovals.size());
		System.assert(opportunities.resetApprovals.contains(opp.Id));
	}

	@isTest static void test_checkForSetApprovals1() 
	{	
		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
			.setField(Opportunity.Set_Product_Approvals__c, false)			
			.toSObject();
		
		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkForSetApprovals(opp);
		
		System.assertEquals(null, opportunities.setApprovals);
	}

	@isTest static void test_checkForSetApprovals2() 
	{		
		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
			.setField(Opportunity.Set_Product_Approvals__c, true)			
			.toSObject();
		
		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkForSetApprovals(opp);
		
		System.assertEquals(1, opportunities.setApprovals.size());	
		System.assert(opportunities.setApprovals.contains(opp.Id));
		System.assertEquals(false, opp.Set_Product_Approvals__c);
	}

	@isTest static void test_checkForOppLiUpdateNeededContractDates1() 
	{		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.RecurSoft__Contract_Signed_Date__c, null);			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkForOppLiUpdateNeededContractDates(opp, existingOpp);
		
		System.assertEquals(null, opportunities.updateAllOppLisOnOpp);
	}

	@isTest static void test_checkForOppLiUpdateNeededContractDates2() 
	{		
		Date signedDate = Date.newInstance(2018, 06, 20);

		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.RecurSoft__Contract_Signed_Date__c, signedDate)
			.setField(Opportunity.RecurSoft__Initial_Contract_Term__c, 1);			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkForOppLiUpdateNeededContractDates(opp, existingOpp);
		
		System.assertEquals(1, opportunities.updateAllOppLisOnOpp.size());
		System.assertEquals(1, opportunities.updateAllOpplisOnOppContractDates.size());
		System.assert(opportunities.updateAllOppLisOnOpp.contains(opp.Id));
		System.assert(opportunities.updateAllOpplisOnOppContractDates.contains(opp.Id));
	}

	@isTest static void test_checkForOppLiUpdateNeededModifiedSubscription1() 
	{		
		Date signedDate = Date.newInstance(2018, 06, 20);

		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.IsClosed, false);			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkForOppLiUpdateNeededModifiedSubscription(opp, existingOpp);
		
		System.assertEquals(null, opportunities.updateAllOppLisOnOpp);
	}

	@isTest static void test_checkForOppLiUpdateNeededModifiedSubscription2() 
	{		
		Date signedDate = Date.newInstance(2018, 06, 20);

		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.IsClosed, true)
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId());			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.setField(Opportunity.IsClosed, false)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.checkForOppLiUpdateNeededModifiedSubscription(opp, existingOpp);
		
		System.assertEquals(1, opportunities.updateAllOppLisOnOpp.size());
		System.assertEquals(1, opportunities.updateAllOpplisOnOppModifiedSubscriptions.size());
		System.assert(opportunities.updateAllOppLisOnOpp.contains(opp.Id));
		System.assert(opportunities.updateAllOpplisOnOppModifiedSubscriptions.contains(opp.Id));
	}

	@isTest static void test_closeAddendum() 
	{				
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.StageName, 'Closed Won')
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'Add-On Business'));			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.setField(Opportunity.StageName, 'Test')
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.closeAddendum(opp, existingOpp);
		
		System.assertEquals(1, opportunities.closeAddendum.size());
		System.assert(opportunities.closeAddendum.contains(opp.Id));
	}

	@isTest static void test_createAssetForClosedOpps() 
	{		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.StageName, 'Closed Won')
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'Add-On Business'));			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.setField(Opportunity.StageName, 'Test')
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.createAssetForClosedOpps(opp, existingOpp);
		
		System.assertEquals(1, opportunities.createAssetForClosedOpps.size());
		System.assert(opportunities.createAssetForClosedOpps.contains(opp.Id));
	}

	@isTest static void test_createCampaignInfluence() 
	{        		
		insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
			Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

		User user = (User) TestUtilities2.newUser().toSObject();

		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
		  	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'))
		  	.setField(Opportunity.LeadSource, 'ADR Set')
		  	.setField(Opportunity.CreatedById, user.Id)
		  	.toSObject();
		 		       
		Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});
		opportunities.createCampaignInfluence(opp);

		String first = new List<String> (opportunities.createCI).get(0);
		System.assertEquals(1, opportunities.createCI.size());	
		System.assertEquals(opp.Id + '::' + opportunities.leadSourceToCampaignIdMap.get(opp.LeadSource) + ':' + opp.CreatedById,first); 		    
    }

    @isTest static void test_newActivationCase() 
    {		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.Contract_Signed__c, true)
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'));			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.setField(Opportunity.Contract_Signed__c, false)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.newActivationCase(opp, existingOpp);
		
		System.assertEquals(1, opportunities.newActivationCase.size());
		System.assert(opportunities.newActivationCase.contains(opp.Id));
	}

	@isTest static void test_scheduleOpportunitySync() 
	{		
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.StageName, 'Closed Won - Pending Billing')
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'));			
		
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.setField(Opportunity.StageName, 'Negotiation Review')
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.getSubscriberId(opp, existingOpp);
		
		System.assertEquals(1, opportunities.getSubscriberId.size());
		System.assert(opportunities.getSubscriberId.contains(opp.Id));
	}

	@isTest static void test_setAccountBillingEmailFromBillToContact() 
	{		
		Contact c1 = (Contact) TestUtilities2.newContact().toSObject();

		Contact c2 = (Contact) TestUtilities2.newContact().toSObject();

		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.RecurSoft__Billing_Contact__c, c1.Id);
						
		Opportunity opp = (Opportunity) oppFab.toSObject();
		
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(oppFab)			
			.setField(Opportunity.RecurSoft__Billing_Contact__c, c2.Id)
			.toSObject();

		Opportunities opportunities = new Opportunities(new List<Opportunity> {opp});		
		opportunities.setAccountBillingEmailFromBillToContact(opp, existingOpp);
		
		System.assertEquals(1, opportunities.accountBillingEmail.size());
		System.assert(opportunities.accountBillingEmail.contains(opp.Id));	
	}

	@isTest static void test_updatePRTProductForNumberOfPRT() 
	{     
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		sfab_FabricatedSObject pr = TestUtilities2.newProduct()
			.setField(Product2.ProductCode, '3062');  

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
			.setParent('Product2', pr);

		sfab_FabricatedSObject pbe2 = TestUtilities2.newPricebookEntry();

		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2()
			.setField(Pricebook2.Number_of_PRT_Included__c, 20)
			.setChildren('PricebookEntries', new List<sfab_FabricatedSObject> { pbe, pbe2 })
			.toSObject();
		
		sfab_FabricatedSObject oppLi = TestUtilities2.newOpportunityLineItem()			
        	.setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
        	.setParent('PricebookEntry', pbe); 
        
		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
		 	.setField(Opportunity.Number_of_PRT__c, 1000)		 	
		 	.setField(Opportunity.HasOpportunityLineItem, true)	
		 	.setField(Opportunity.Pricebook2Id, pb.Id)
		 	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'))
		 	.setChildren('OpportunityLineItems', new List<sfab_FabricatedSObject> {oppLi})
		 	.toSObject();

		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(opp)	
		 	.setField(Opportunity.Number_of_PRT__c, 100)	 		
		 	.toSObject();
		
		PricebooksSelector mockSelector = (PricebooksSelector) mocks.mock(PricebooksSelector.class);

		mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Pricebook2.SObjectType);
        mocks.when(mockSelector.selectAllWithPricebookEntries())
        	.thenReturn(new List<Pricebook2> { pb });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
       
        Set<Id> ids = new Set<Id>();
        ids.Add(opp.Id);

		OpportunitiesSelector mockSelector2 = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector2.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector2.selectByIdWithAccountAndProducts(ids))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector2);

		Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});
		opportunities.updatePRTProductForNumberOfPRT(opp, existingOpp, uow);
		  		
		List<OpportunityLineItem> oppLisResult = (List<OpportunityLineItem>)(uow.m_newListByType.get('OpportunityLineItem'));

  		System.assertEquals(1, uow.m_newListByType.get('OpportunityLineItem').size());  
  		System.assertEquals(opp.Id, oppLisResult[0].OpportunityId);		
  		System.assertEquals(opp.Number_of_PRT__c - pb.Number_of_PRT_Included__c, oppLisResult[0].Quantity);		
  		System.assertEquals(pb.PricebookEntries[0].UnitPrice, oppLisResult[0].UnitPrice);		
    }

    @isTest static void test_updateAPProductForNumberOfProviders() 
    {       
    	fflib_ApexMocks mocks = new fflib_ApexMocks(); 

		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		sfab_FabricatedSObject pr = TestUtilities2.newProduct()
			.setField(Product2.ProductCode, '3052'); 

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
			.setParent('Product2', pr);

		sfab_FabricatedSObject pbe2 = TestUtilities2.newPricebookEntry();

		sfab_FabricatedSObject oppLi = TestUtilities2.newOpportunityLineItem()			
        	.setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
        	.setParent('PricebookEntry', pbe); 

		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2()
			.setField(Pricebook2.Number_of_PRT_Included__c, 20)
			.setField(Pricebook2.Number_of_Providers_Included__c, 12)
			.setChildren('PricebookEntries', new List<sfab_FabricatedSObject> { pbe, pbe2 })
			.toSObject();
		
		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
		  	.setField(Opportunity.Number_of_Providers__c, 100)
		  	.setField(Opportunity.Pricebook2Id, pb.Id)
		  	.setField(Opportunity.HasOpportunityLineItem, true)
		  	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'))
		  	.setChildren('OpportunityLineItems', new List<sfab_FabricatedSObject> {oppLi})
		  	.toSObject();
		 
		Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(opp)
			.setField(Opportunity.Number_of_Providers__c, 5)
		  	.setField(Opportunity.Number_of_PRT__c, opp.Number_of_Providers__c)
		  	.toSObject();
		 
		
		PricebooksSelector mockSelector = (PricebooksSelector) mocks.mock(PricebooksSelector.class);

		mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Pricebook2.SObjectType);
        mocks.when(mockSelector.selectAllWithPricebookEntries())
        	.thenReturn(new List<Pricebook2> { pb });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        Set<Id> ids = new Set<Id>();
        ids.Add(opp.Id);

        OpportunitiesSelector mockSelector2 = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector2.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector2.selectByIdWithAccountAndProducts(ids))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector2);

		Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});
		opportunities.updateAPProductForNumberOfProviders(opp, existingOpp, uow);

		List<OpportunityLineItem> oppLisResult = (List<OpportunityLineItem>)(uow.m_newListByType.get('OpportunityLineItem'));

		System.assertEquals(1, uow.m_newListByType.get('OpportunityLineItem').size());
		System.assertEquals(opp.Id, oppLisResult[0].OpportunityId);		
  		System.assertEquals(opp.Number_of_Providers__c - pb.Number_of_Providers_Included__c, oppLisResult[0].Quantity);		
  		System.assertEquals(pb.PricebookEntries[0].UnitPrice, oppLisResult[0].UnitPrice);	
    }

    @isTest static void test_setSRDateCreated1() 
    {   
   		Date createdDate = Date.newInstance(2018, 06, 20);

    	Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
            .setField(Opportunity.SR_Date_Created__c, createdDate)
    		.toSObject();

    	Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});
		opportunities.setSRDateCreated(opp);

    	System.assertEquals(createdDate, opp.SR_Date_Created__c);
    }

    @isTest static void test_setSRDateCreated2() 
    {   
    	Opportunity opp = (Opportunity) TestUtilities2.newOpportunity()
    		.toSObject();

    	Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});
		opportunities.setSRDateCreated(opp);

    	System.assertNotEquals(null, opp.SR_Date_Created__c);
    }

    @isTest static void test_setPricebookDefaultValues() 
    {
    	fflib_ApexMocks mocks = new fflib_ApexMocks();

    	Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2()
			.setField(Pricebook2.Number_of_Providers_Included__c, 20)
			.setField(Pricebook2.Number_of_PRT_Included__c, 10)
			.setField(Pricebook2.Default_Term__c, 5)			
			.toSObject();

		Pricebook2 pb2 = (Pricebook2) TestUtilities2.newPricebook2().toSObject();

    	sfab_FabricatedSObject op1 =  TestUtilities2.newOpportunity()
          	.setField(Opportunity.Pricebook2Id, pb.Id) 
          	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'));
	    		
        
        Opportunity opp = (Opportunity) op1.toSObject();

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)
            .setField(Opportunity.Pricebook2Id, pb2.Id)
            .toSObject();

        PricebooksSelector mockSelector = (PricebooksSelector) mocks.mock(PricebooksSelector.class);

		mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Pricebook2.SObjectType);
        mocks.when(mockSelector.selectAllWithPricebookEntries())
        	.thenReturn(new List<Pricebook2> { pb });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});
        opportunities.setPricebookDefaultValues(opp, existingOpp);

        System.assertEquals(pb.Number_of_Providers_Included__c, opp.Number_of_Providers__c);
        System.assertEquals(pb.Number_of_PRT_Included__c, opp.Number_of_PRT__c);
        System.assertEquals(pb.Default_Term__c, opp.RecurSoft__Initial_Contract_Term__c);
	}

	@isTest static void test_setDefaultPricebook() 
	{
		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2().toSObject();	

		insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
			Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

		insert new SR_Default_Values__c(Name = 'defaultPricebookId',
			Description__c='defaultPricebookId',
            Value__c = pb.Id);		

    	sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
    		.setField(Opportunity.Pricebook2Id, null) 
    		.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'))
            .setField(Opportunity.StageName, 'Demo Scheduled');

        Opportunity opp = (Opportunity) op1.toSObject();
        
        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)
            .setField(Opportunity.StageName, 'Qualified')
            .toSObject();

        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});
        opportunities.setDefaultPricebook(opp, existingOpp);
           
        System.assertEquals(SR_Default_Values__c.getValues('defaultPricebookId').Value__c, opp.Pricebook2Id);        
	}

	@isTest static void test_setActiveOpportunityOnAccount() 
	{
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'))
            .setField(Opportunity.AccountId, ac.Id)
            .setField(Opportunity.IsClosed, false);
                 
        Opportunity opp = (Opportunity) op1.toSObject();

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)    
            .setField(Opportunity.IsClosed, true)             
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});        
        opportunities.setActiveOpportunityOnAccount(opp, existingOpp, uow);
        Account accountResult = (Account) uow.m_dirtyMapByType.get('Account').get(opp.AccountId);

        System.assertEquals(1, uow.m_dirtyMapByType.get('Account').size());
        System.assertEquals(opp.AccountId, accountResult.Id);
		System.assertEquals(opp.Id, accountResult.Active_Opportunity__c);	
    }

    @isTest static void test_addPackageProducts() 
    {      
    	fflib_ApexMocks mocks = new fflib_ApexMocks();  	

		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		sfab_FabricatedSObject pr = TestUtilities2.newProduct()
			.setField(Product2.Family, 'Test');  

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
			.setField(PricebookEntry.Auto_Add__c, true)
			.setField(PricebookEntry.Auto_Add_Trial__c, true)
			.setField(PricebookEntry.Auto_Add_Price__c, 120)
			.setField(PricebookEntry.Auto_Add_Quantity__c, 12)
			.setField(PricebookEntry.Auto_Add_Free_Months__c, 5)
			.setField(PricebookEntry.Auto_Add_Free_Month_Setting__c, 6)
			.setField(PricebookEntry.UnitPrice, 1)
			.setParent('Product2', pr);

		sfab_FabricatedSObject pbe2 = TestUtilities2.newPricebookEntry();

		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2()
			.setField(Pricebook2.Number_of_PRT_Included__c, 20)
			.setChildren('PricebookEntries', new List<sfab_FabricatedSObject> { pbe, pbe2 })
			.toSObject();
		
		sfab_FabricatedSObject opFab = TestUtilities2.newOpportunity()
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId())
            .setField(Opportunity.HasOpportunityLineItem, false)
            .setField(Opportunity.Pricebook2Id, pb.Id);               

        Opportunity opp = (Opportunity) opFab.toSObject();      

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(opFab)  
        	.setField(Opportunity.Pricebook2Id, null)                   
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

        PricebooksSelector mockSelector2 = (PricebooksSelector) mocks.mock(PricebooksSelector.class);

		mocks.startStubbing();
        mocks.when(mockSelector2.getSObjectType2())
        	.thenReturn(Pricebook2.SObjectType);
        mocks.when(mockSelector2.selectAllWithPricebookEntries())
        	.thenReturn(new List<Pricebook2> { pb });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector2);		
		Opportunities opportunities=new Opportunities(new List<Opportunity>{opp});
		opportunities.addPackageProducts(opp, existingOpp, uow);
		OpportunityLineItem[] opportunityLineItemResult = (List<OpportunityLineItem>)(uow.m_newListByType.get('OpportunityLineItem'));

		System.assertEquals(1, uow.m_newListByType.get('OpportunityLineItem').size());
		System.assertEquals(pb.PricebookEntries[0].Auto_Add_Trial__c, opportunityLineItemResult[0].Trial__c);
		System.assertEquals(pb.PricebookEntries[0].Auto_Add_Price__c, opportunityLineItemResult[0].UnitPrice);
		System.assertEquals(pb.PricebookEntries[0].Auto_Add_Free_Months__c, opportunityLineItemResult[0].Number_of_Free_Months__c);
		System.assertEquals(pb.PricebookEntries[0].Auto_Add_Free_Month_Setting__c, opportunityLineItemResult[0].Free_Month_Setting__c);
    }   

    @isTest static void test_stampDemoScheduledStageDate() 
	{        
        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.Demo_Scheduled_Stage_Date__c, null)
            .setField(Opportunity.StageName, 'Negotiation Review')
            .setField(Opportunity.IsClosed, false);
                 
        Opportunity opp = (Opportunity) op1.toSObject();

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)    
            .setField(Opportunity.StageName, 'Qualified')             
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});        
        opportunities.stampDemoScheduledStageDate(opp, existingOpp);       

        System.assertEquals(Datetime.now(), opp.Demo_Scheduled_Stage_Date__c);
    }	

    @isTest static void test_stampDemoCompletedStageDate() 
	{        
        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.Demo_Completed_Stage_Date__c, null)
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.IsClosed, false);
                 
        Opportunity opp = (Opportunity) op1.toSObject();

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)    
            .setField(Opportunity.StageName, 'Qualified')             
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});        
        opportunities.stampDemoCompletedStageDate(opp, existingOpp);       

        System.assertEquals(Datetime.now(), opp.Demo_Completed_Stage_Date__c);
    }

    @isTest static void test_stampStageBeforeClose() 
	{        
        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.StageName, 'Closed Lost')
            .setField(Opportunity.IsClosed, true);
                 
        Opportunity opp = (Opportunity) op1.toSObject();

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)    
            .setField(Opportunity.StageName, 'Qualified') 
            .setField(Opportunity.IsClosed, false)       
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});        
        opportunities.stampStageBeforeClose(opp, existingOpp);       

        System.assertEquals(existingOpp.StageName, opp.Stage_Before_Close__c);
    }

    @isTest static void test_processStampUpdates() 
	{        
		User user1 = (User) TestUtilities2.newUser().toSObject();

		User user2 = (User) TestUtilities2.newUser().toSObject();
		
        Stamp_Field_Mapping__c stamp1 = (Stamp_Field_Mapping__c) TestUtilities2.newStampFieldMapping()                   
            .setField(Stamp_Field_Mapping__c.Field_Changed__c, 'Source_User__c')
            .setField(Stamp_Field_Mapping__c.Field_Changed_Value__c, null)             
            .setField(Stamp_Field_Mapping__c.Stamp_To_Object__c, 'Opportunity')
            .setField(Stamp_Field_Mapping__c.Active__c, true)                    
            .toSObject();   

        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
         	.setField(Opportunity.Source_User__c, user1.Id)
            .setField(Opportunity.IsClosed, true);
                 
        Opportunity opp = (Opportunity) op1.toSObject();

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)     
            .setField(Opportunity.Source_User__c, null)       
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});
        opportunities.stampMappings = new List<Stamp_Field_Mapping__c> {stamp1};        
        opportunities.processStampUpdates(opp, existingOpp);       

        System.assertEquals(1, opportunities.stampUpdates.size());
		System.assert(opportunities.stampUpdates.contains(opp.Id + '::' + stamp1.Id));
    }

    @isTest static void test_updateAllOppLisOnOpp()
	{  		
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();  

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
       		.setField(PricebookEntry.UnitPrice, 0);
	
		sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
			.setField(Opportunity.IsClosed, false)
			.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId())
			.setField(Opportunity.RecurSoft__Initial_Contract_Term__c, 5);		

		Opportunity opp = (Opportunity) oppFab.toSObject();

		OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
        	.setField(OpportunityLineItem.OpportunityId, opp.Id) 
        	.setField(OpportunityLineItem.Approval_Level_Required_Price_Discount__c, 1)    
        	.setField(OpportunityLineItem.Approval_Level_Required_Free_Months__c, 2)    
        	.setField(OpportunityLineItem.Approval_Level_Required_Term__c, 3)  
        	.setField(OpportunityLineItem.Approval_Level_Required_Trial__c, 4)          	
        	.setField(OpportunityLineItem.Number_of_Free_Months__c, 10)         	
        	.setField(OpportunityLineItem.Trial__c, 4) 
        	.setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.newInstance(2018, 01, 20)) 
        	.setField(OpportunityLineItem.RecurSoft__Contract_Term_End_Date_Editable__c, Date.today())         	
        	.setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
        	.setField(OpportunityLineItem.Override_Modified_Subscription__c, true) 
        	.setField(OpportunityLineItem.Override_Current_SR_Subscription__c, true) 
        	.setParent('Opportunity', oppFab)      	
        	.setParent('PricebookEntry', pbe)  
        	.toSObject();  

        OpportunityLineItemsSelector mockSelector = (OpportunityLineItemsSelector) mocks.mock(OpportunityLineItemsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(OpportunityLineItem.SObjectType);
        mocks.when(mockSelector.selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(new Set<Id>{ opp.Id }))
        	.thenReturn(new List<OpportunityLineItem>{ oppLi });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
        
        Set<Id> ids = new Set<Id>();
        ids.Add(opp.Id);

        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});      
        /*opportunities.updateAllOpplisOnOppResetApprovals = new Set<Id>();       
        opportunities.updateAllOpplisOnOppResetApprovals.Add(opp.Id);
        opportunities.updateAllOpplisOnOppSetApprovals = new Set<Id>();       
        opportunities.updateAllOpplisOnOppSetApprovals.Add(opp.Id);*/
        opportunities.updateAllOpplisOnOppContractDates = new Set<Id>();       
        opportunities.updateAllOpplisOnOppContractDates.Add(opp.Id);        
        opportunities.updateAllOpplisOnOppModifiedSubscriptions = new Set<Id>();       
        opportunities.updateAllOpplisOnOppModifiedSubscriptions.Add(opp.Id);                
        opportunities.updateAllOppLisOnOpp(ids, uow);

        //System.assertEquals(1, uow.m_dirtyMapByType.get('OpportunityLineItem').size());          
	}

	@isTest static void test_checkForOwnerToGeneralPool() 
	{    
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		User user1 = (User) TestUtilities2.newUser().toSObject();

		User user2 = (User) TestUtilities2.newUser().toSObject();

		insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = user1.Id);
		
		sfab_FabricatedSObject acFab = TestUtilities2.newAccount()
			.setField(Account.RecurSoft__Status__c, 'Prospect');

		Account ac = (Account) acFab.toSObject(); 

        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.AccountId, ac.Id)
        	.setField(Opportunity.OwnerId, user2.Id)
        	.setField(Opportunity.StageName, 'Not Qualified')    
        	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'Add Product'))
        	.setParent('Account', acFab);
                 
        Opportunity opp = (Opportunity) op1.toSObject();        	

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)                    
            .toSObject();

        OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithAccountAndProducts(new Set<Id>{ opp.Id }))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});               
        opportunities.checkForOwnerToGeneralPool(opp, existingOpp);       

        System.assertEquals(1, opportunities.syncOwnersGeneralPool.size());
		System.assert(opportunities.syncOwnersGeneralPool.contains(opp.AccountId + ':' + SR_Default_Values__c.getInstance('jennyPoolUserId').Value__c));
    }

    @isTest static void test_checkForOwnerToGeneralPool2() 
	{    
		User user1 = (User) TestUtilities2.newUser().toSObject();

		User user2 = (User) TestUtilities2.newUser().toSObject();

		insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = user1.Id);
		
		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.AccountId, ac.Id)
        	.setField(Opportunity.OwnerId, user2.Id)
        	.setField(Opportunity.StageName, 'Close Won')  
        	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'Add Product'));
                 
        Opportunity opp = (Opportunity) op1.toSObject();        	

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)                    
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});               
        opportunities.checkForOwnerToGeneralPool(opp, existingOpp);       

        System.assertEquals(null, opportunities.syncOwnersGeneralPool);		
    }

    @isTest static void test_checkForAmbassadorCommissionCreate() 
	{    
		User user1 = (User) TestUtilities2.newUser().toSObject();

		User user2 = (User) TestUtilities2.newUser().toSObject();

		insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = user1.Id);

		Contact c1 = (Contact) TestUtilities2.newContact().toSObject();
		
		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.AccountId, ac.Id)
        	.setField(Opportunity.Referred_Contact__c, c1.Id)
        	.setField(Opportunity.OwnerId, user2.Id)
        	.setField(Opportunity.Ambassador_Commission_Created__c, false)        	
        	.setField(Opportunity.StageName, 'Demo Scheduled')    
        	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'Add Product'));
                 
        Opportunity opp = (Opportunity) op1.toSObject();        	

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)  
        	.setField(Opportunity.Referred_Contact__c, null)
        	.setField(Opportunity.StageName, 'Qualified') 
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});               
        opportunities.checkForAmbassadorCommissionCreate(opp, existingOpp);       

        System.assertEquals(1, opportunities.ambassadorCommissionCreate.size());
		System.assert(opportunities.ambassadorCommissionCreate.contains(opp.Id));
    }

    @isTest static void test_checkForAmbassadorCommissionCreate2() 
	{    
		User user1 = (User) TestUtilities2.newUser().toSObject();

		User user2 = (User) TestUtilities2.newUser().toSObject();

		insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = user1.Id);

		Contact c1 = (Contact) TestUtilities2.newContact().toSObject();
		
		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.AccountId, ac.Id)
        	.setField(Opportunity.Referred_Contact__c, c1.Id)
        	.setField(Opportunity.OwnerId, user2.Id)
        	.setField(Opportunity.Ambassador_Commission_Created__c, false)        	
        	.setField(Opportunity.StageName, 'Qualified')    
        	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'Add Product'));
                 
        Opportunity opp = (Opportunity) op1.toSObject();        	

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)  
        	.setField(Opportunity.StageName, 'Qualified')                  
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});               
        opportunities.checkForAmbassadorCommissionCreate(opp, existingOpp);       

        System.assertEquals(null, opportunities.ambassadorCommissionCreate);		
    }

    @isTest static void test_checkForAmbassadorCommissionComplete() 
	{    
		User user1 = (User) TestUtilities2.newUser().toSObject();

		User user2 = (User) TestUtilities2.newUser().toSObject();

		insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = user1.Id);

		Contact c1 = (Contact) TestUtilities2.newContact().toSObject();
		
		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.AccountId, ac.Id)
        	.setField(Opportunity.Referred_Contact__c, c1.Id)
        	.setField(Opportunity.OwnerId, user2.Id)
        	.setField(Opportunity.Ambassador_Commission_Created__c, false)        	
        	.setField(Opportunity.StageName, 'Demo Completed')    
        	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'Add Product'));
                 
        Opportunity opp = (Opportunity) op1.toSObject();        	

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)  
        	.setField(Opportunity.Referred_Contact__c, null)
        	.setField(Opportunity.StageName, 'Qualified') 
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});               
        opportunities.checkForAmbassadorCommissionComplete(opp, existingOpp);       

        System.assertEquals(1, opportunities.ambassadorCommissionComplete.size());
		System.assert(opportunities.ambassadorCommissionComplete.contains(opp.Id));
    }

    @isTest static void test_checkForAmbassadorCommissionComplete2() 
	{    
		User user1 = (User) TestUtilities2.newUser().toSObject();

		User user2 = (User) TestUtilities2.newUser().toSObject();

		insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = user1.Id);

		Contact c1 = (Contact) TestUtilities2.newContact().toSObject();
		
		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject op1 = TestUtilities2.newOpportunity()
        	.setField(Opportunity.AccountId, ac.Id)
        	.setField(Opportunity.Referred_Contact__c, c1.Id)
        	.setField(Opportunity.OwnerId, user2.Id)
        	.setField(Opportunity.Ambassador_Commission_Created__c, false)        	
        	.setField(Opportunity.StageName, 'Qualified')    
        	.setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeId('Opportunity', 'Add Product'));
                 
        Opportunity opp = (Opportunity) op1.toSObject();        	

        Opportunity existingOpp = (Opportunity) TestUtilities2.existingOpportunity(op1)  
        	.setField(Opportunity.StageName, 'Qualified')                  
            .toSObject();
       
        Opportunities opportunities = new Opportunities(new List<Opportunity>{opp});               
        opportunities.checkForAmbassadorCommissionComplete(opp, existingOpp);       

        System.assertEquals(null, opportunities.ambassadorCommissionComplete);		
    }
}