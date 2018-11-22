@isTest
private class CampaignMemberUtilities_Test {
	
	@testSetup static void testData1() {

        Account a = TestUtilities.insertBasicAccount(true);
        Contact c = TestUtilities.insertBasicContact(a.Id);
    }

    @testSetup static void testData2() {

        Account a2 = TestUtilities.insertBasicAccount(false);
        a2.Lead_Contacts_Parent_Account__c = true;
        update a2;
        Contact c = TestUtilities.insertBasicContact(a2.Id);
        update c;
        Campaign camp = TestUtilities.insertBasicMarketingCampaign('Email', false, false, 'Test');
        Campaign camp2 = TestUtilities.insertBasicMarketingCampaign('Email', false, false, 'Test2');
    }

	@isTest static void campaignMemberOnContactNoConvert() {
		
		Contact c = [SELECT Id, AccountId FROM Contact WHERE Lead__c = null LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

		CampaignMember cm = new CampaignMember(CampaignId = camp.Id,
			ContactId = c.Id);

		Test.startTest();
		Limits.getQueries();

		insert cm;

		Test.stopTest();
	}
	
	/*@isTest static void campaignMemberOnContactConvert() {

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

		Test.startTest();
		Limits.getQueries();

		Map<String, Id> convertedObjects = TestUtilities.convertLead(l);

		CampaignMember cm = new CampaignMember(CampaignId = camp.Id,
			ContactId = convertedObjects.get('ContactId'));

		insert cm;

		Test.stopTest();

		Campaign_Influence__c ci = [SELECT Id, Lead__c, Contact__c, Account__c, Opportunity__c, Campaign__c FROM Campaign_Influence__c];

		System.assertEquals(null, ci.Lead__c, 'There shouldn\'t be a Lead associated to this Campaign Influence');
		//System.assertEquals(convertedObjects.get('OpportunityId'), ci.Opportunity__c, 'The Campaign Influence isn\'t associated to the right Opportunity');
		System.assertEquals(convertedObjects.get('ContactId'), ci.Contact__c, 'The Campaign Influence isn\'t associated to the right Contact');
		System.assertEquals(convertedObjects.get('AccountId'), ci.Account__c, 'The Campaign Influence isn\'t associated to the right Account');
		System.assertEquals(camp.Id, ci.Campaign__c, 'The Campaign Influence isn\'t associated to the right Campaign');
	}

	@isTest static void campaignMemberOnLeadNoConvert() {

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

		CampaignMember cm = new CampaignMember(CampaignId = camp.Id,
			LeadId = l.Id);

		Test.startTest();
		Limits.getQueries();

		insert cm;

		Test.stopTest();

		Campaign_Influence__c ci = [SELECT Id, Lead__c, Contact__c, Account__c, Opportunity__c, Campaign__c FROM Campaign_Influence__c];

		System.assertEquals(l.Id, ci.Lead__c, 'The Campaign Influence isn\'t associated to the right Lead');
		System.assertEquals(null, ci.Opportunity__c, 'There shouldn\'t be an Opportunity associated to this Campaign Influence');
		System.assertEquals(null, ci.Contact__c, 'There shouldn\'t be a Contact associated to this Campaign Influence');
		System.assertEquals(null, ci.Account__c, 'There shouldn\'t be an Account associated to this Campaign Influence');
		System.assertEquals(camp.Id, ci.Campaign__c, 'The Campaign Influence isn\'t associated to the right Campaign');
	}

	@isTest static void campaignMemberOnLeadConvert() {

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

		CampaignMember cm = new CampaignMember(CampaignId = camp.Id,
			LeadId = l.Id);

		insert cm;

		Test.startTest();
		Limits.getQueries();

		Map<String, Id> convertedObjects = TestUtilities.convertLead(l);

		Test.stopTest();

		Campaign_Influence__c ci = [SELECT Id, Lead__c, Contact__c, Account__c, Opportunity__c, Campaign__c FROM Campaign_Influence__c];

		System.assertEquals(l.Id, ci.Lead__c, 'The Campaign Influence isn\'t associated to the right Lead');
		//System.assertEquals(convertedObjects.get('OpportunityId'), ci.Opportunity__c, 'The Campaign Influence isn\'t associated to the right Opportunity');
		//System.assertEquals(convertedObjects.get('ContactId'), ci.Contact__c, 'The Campaign Influence isn\'t associated to the right Contact');
		System.assertEquals(convertedObjects.get('AccountId'), ci.Account__c, 'The Campaign Influence isn\'t associated to the right Account');
		System.assertEquals(camp.Id, ci.Campaign__c, 'The Campaign Influence isn\'t associated to the right Campaign');
	}

	@isTest static void campaignMemberOnLeadContactNoConvert() {
		
		Contact c = [SELECT Id, AccountId, Lead__c FROM Contact WHERE Lead__c != null LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

		CampaignMember cm = new CampaignMember(CampaignId = camp.Id,
			ContactId = c.Id);

		Test.startTest();
		Limits.getQueries();

		insert cm;

		Test.stopTest();

		Campaign_Influence__c ci = [SELECT Id, Lead__c, Contact__c, Account__c, Opportunity__c, Campaign__c FROM Campaign_Influence__c];

		System.assertEquals(c.Lead__c, ci.Lead__c, 'The Campaign Influence isn\'t associated to the right Lead');
		System.assertEquals(null, ci.Opportunity__c, 'There shouldn\'t be an Opportunity associated to this Campaign Influence');
		System.assertEquals(c.Id, ci.Contact__c, 'The Campaign Influence isn\'t associated to the right Contact');
		System.assertEquals(null, ci.Account__c, 'There shouldn\'t be an Account associated to this Campaign Influence');
		System.assertEquals(camp.Id, ci.Campaign__c, 'The Campaign Influence isn\'t associated to the right Campaign');
	}

	@isTest static void campaignMemberOnLeadContactConvert() {
		
		Contact c = [SELECT Id, AccountId, Lead__c FROM Contact WHERE Lead__c != null LIMIT 1];
		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

		CampaignMember cm = new CampaignMember(CampaignId = camp.Id,
			ContactId = c.Id);

		insert cm;

		Test.startTest();
		Limits.getQueries();

		Map<String, Id> convertedObjects = TestUtilities.convertLead(l);

		Test.stopTest();

		Campaign_Influence__c ci = [SELECT Id, Lead__c, Contact__c, Account__c, Opportunity__c, Campaign__c FROM Campaign_Influence__c];

		System.assertEquals(c.Lead__c, ci.Lead__c, 'The Campaign Influence isn\'t associated to the right Lead');
		//System.assertEquals(convertedObjects.get('OpportunityId'), ci.Opportunity__c, 'The Campaign Influence isn\'t associated to the right Opportunity');
		//System.assertEquals(convertedObjects.get('ContactId'), ci.Contact__c, 'The Campaign Influence isn\'t associated to the right Contact');
		System.assertEquals(convertedObjects.get('AccountId'), ci.Account__c, 'The Campaign Influence isn\'t associated to the right Account');
		System.assertEquals(camp.Id, ci.Campaign__c, 'The Campaign Influence isn\'t associated to the right Campaign');
	}*/
}