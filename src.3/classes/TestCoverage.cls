@isTest
private class TestCoverage {
	
	@isTest static void testAddProductOpp_Controller() {
		
		Account a = TestUtilities.insertBasicAccount(true);
		Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);
		Product2 p = [SELECT Id FROM Product2 WHERE Family = 'SR Platform'];
		Asset ast = new Asset(Name = 'Test Asset',
    		AccountId = a.Id,
    		Product2Id = p.Id,
    		Active__c = false);
		insert ast;

		PageReference pageRef = Page.AddProductOpp;

		pageRef.getParameters().put('id', a.Id);
		
		Test.setCurrentPage(pageRef);

		AddProductOpp_Controller controller = new AddProductOpp_Controller();
	}	

	@isTest static void testViewTaskHistory_Controller() {
		
		Account a = TestUtilities.insertBasicAccount(true);
		Task t = TestUtilities.createScheduledTask(null, a.Id);
		insert t;

		t.Status = 'Completed';
		update t;

		PageReference pageRef = Page.ViewTaskFieldHistory;

		pageRef.getParameters().put('id', t.Id);
		
		Test.setCurrentPage(pageRef);
	}

	@isTest static void testAddenda() {
		
		Account a = TestUtilities.insertBasicAccount(true);
		Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);
		Product2 p = [SELECT Id FROM Product2 WHERE Family = 'SR Platform'];
		Asset ast = new Asset(Name = 'Test Asset',
    		AccountId = a.Id,
    		Product2Id = p.Id,
    		Active__c = false);
		insert ast;

		Test.startTest();

		Addendum__c add = new Addendum__c(Name = 'name', Account__c = a.Id);
		insert add;

		Addendum_Line_Item__c ali = new Addendum_Line_Item__c(Asset__c = ast.Id, Addendum__c = add.Id);

		Test.stopTest();
	}

	@isTest static void testHelperClasses() {
		
		AccountDecorator ad = new AccountDecorator();
		ad.AccountID = '1';
		ad.BillingEmail = '2';
		ad.BusinessName = '3';
		ad.OfficeContactID = '4';
		ad.OfficeEmail = '5';
		ad.OfficeFax = '6';
		ad.OfficePhone = '7';
		ad.OfficephoneAreaCode = '8';
		ad.OfficephoneCode = '9';
		ad.OfficephoneCountryCode = '10';
		ad.PracticeSoftware = '11';
		ad.PracticeSoftwareVersion = '12';
		ad.PractivceSoftware = '13';
		ad.PractivceSoftwareVersoin = '14';
		ad.TotalAmount = '15';
		ad.address1 = '16';
		ad.address2 = '17';
		ad.city = '18';
		ad.country = '19';
		ad.state = '20';
		ad.website = '21';
		ad.zip = '22';
		ContactDecorator cd = new ContactDecorator();
		cd.DirectPhone = '1';
		cd.Email = '2';
		cd.FirstName = '3';
		cd.LastName = '4';
		cd.ReferedBY = '5';
		cd.Salutation = '6';
		cd.Title = '7';
		cd.street = '16';
		cd.city = '18';
		cd.country = '19';
		cd.state = '20';
		cd.zip = '22';
		CreditCardValidation ccv = new CreditCardValidation();
		CRUDTestData ctd = new CRUDTestData();
		//ProductEditController pec = new ProductEditController();
		WebFormsUtilityClass wfu = new WebFormsUtilityClass();
		wfu.getMonths();
		wfu.getYear();
		wfu.getCardType();
		wfu.getPreFix();
		wfu.getStates('United States');
		wfu.getURParameter('id');
		wfu.IsEmptyOrNull('id');
		wfu.returnFailure('failure');
		wfu.returnSucess('success');
		wfu.validateEmail('test@test.com');
	}	

	@isTest static void testSelectors()
	{
		Account a = TestUtilities.insertBasicAccount(true);
		Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);

		Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Set<Id>{o.Id});
		Opportunity[] opps1 = OpportunitiesSelector.newInstance().selectByIdWithManagerAndVP(new Set<Id>{o.Id});
		Opportunity[] opps2 = OpportunitiesSelector.newInstance().selectByIdWithAccountsContactsAndProducts(new Set<Id>{o.Id});
		Opportunity[] opps3 = OpportunitiesSelector.newInstance().selectByIdWithAddenda(new Set<Id>{o.Id});
		Opportunity[] opps4 = OpportunitiesSelector.newInstance().selectActiveOpportunitiessByAccountId(new Set<Id>{a.Id});
	}
}