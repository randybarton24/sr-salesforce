@isTest
private class AppAdminAPIClassNew_Test {
	
	@isTest static void test_providerAPICall() {

		Set<Id> providerIds = new Set<Id>();
		Account a = TestUtilities.insertBasicAccount(true);

		for(Integer i = 0; i < 5; i++) {
			Contact c = TestUtilities.insertBasicContact(a.Id);
			Provider__c p = TestUtilities.insertProvider(a.Id, c.Id, String.valueOf(i));
			providerIds.add(p.Id);
		}

		AppAdminAPIClassNew.postHealthgradesStatus(providerIds);
	}

	@isTest static void test_syncOpportunityAppAdmin() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		Set<Id> oppIds = new Set<Id>();
		Map<String, OpportunityContactRole> oppContactR = new Map<String, OpportunityContactRole>();

		OpportunityContactRole oppContactRole = (OpportunityContactRole) TestUtilities2.newOpportunityContactRole()
			.setField(OpportunityContactRole.Role, 'Billing Contact')
			.toSObject();

		OpportunityContactRole oppContactRole2 = (OpportunityContactRole) TestUtilities2.newOpportunityContactRole()
			.setField(OpportunityContactRole.Role, 'Business Contact')
			.toSObject();

		oppContactR.put('Billing Contact', oppContactRole);
		oppContactR.put('Business Contact', oppContactRole2);

		sfab_FabricatedSObject acFab = TestUtilities2.newAccount()
			.setField(Account.Subscriber_Id__c, 'test')
			.setField(Account.Name, 'testName');
		
		Account ac = (Account) acFab.toSObject();			

		sfab_FabricatedSObject pr = TestUtilities2.newProduct()
			.setField(Product2.Family, 'SR Platform');  

		sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
			.setField(PricebookEntry.UnitPrice, 1)
			.setParent('Product2', pr);

		sfab_FabricatedSObject pbe2 = TestUtilities2.newPricebookEntry();

		Pricebook2 pb = (Pricebook2) TestUtilities2.newPricebook2()
			.setField(Pricebook2.Number_of_PRT_Included__c, 20)
			.setChildren('PricebookEntries', new List<sfab_FabricatedSObject> { pbe, pbe2 })
			.toSObject();
		
		sfab_FabricatedSObject oppLi = TestUtilities2.newOpportunityLineItem()			
        	.setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe2.toSObject()).Id)
        	.setParent('PricebookEntry', pbe); 
      
		sfab_FabricatedSObject opFab = TestUtilities2.newOpportunity() 
			.setField(Opportunity.AccountId, ac.Id)    
			.setParent('Account', acFab)       
            .setChildren('OpportunityLineItems', new List<sfab_FabricatedSObject> {oppLi});               

        insert new AppAdminAPI_Settings__c(Name = 'APISettings',
            isProduction__c = false,
            successStatusCode__c = '201',
            practiceNameLength__c = 33,
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/applications',
            sandboxTargetUrl__c = 'https://salesforce.solutionreach.com/admin/applications',
            productionRequestUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/',
            sandboxRequestUrl__c = 'https://salesforce.solutionreach.com/admin/subscribers',
            requestType__c = 'POST');

        Opportunity opp = (Opportunity) opFab.toSObject();    

        oppIds.add(opp.Id);  

  		OpportunitiesSelector mockSelector1 = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector1.getSObjectType2())
        	.thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector1.selectByIdWithAccountsContactsAndProducts(oppIds))
        	.thenReturn(new List<Opportunity> { opp });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector1);

        OpportunityContactRolesSelector mockSelector2 = (OpportunityContactRolesSelector) mocks.mock(OpportunityContactRolesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector2.getSObjectType2())
        	.thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(mockSelector2.selectRoleMapByOpportunityIdWithContact(oppIds))
        	.thenReturn(oppContactR);
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector2);

		AppAdminAPIClassNew.syncOpportunityAppAdmin(oppIds, false, false, uow);		
	}
	
	
}