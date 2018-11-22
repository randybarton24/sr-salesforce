@isTest
private class CampaignInfluenceUtilities_Test {
	
	/*@testSetup static void testData1() {

        Account a = TestUtilities.insertBasicAccount(true);
        Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);
        Lead l = TestUtilities.insertLeadForConversion(false);
        Contact c = TestUtilities.insertBasicContact(a.Id);
        Campaign campEmail = TestUtilities.insertBasicMarketingCampaign('Email', false, false, 'Test');
        Campaign campColdCall = TestUtilities.insertBasicMarketingCampaign('Cold Call', false, false, 'Test');
        Campaign campOther = TestUtilities.insertBasicMarketingCampaign('Other', false, false, 'Test');
        Campaign campPartner = TestUtilities.insertBasicMarketingCampaign('Partner', true, false, 'Test');
        Campaign campSetter = TestUtilities.insertBasicMarketingCampaign('Setter', false, true, 'Test');
        Campaign campListUpload = TestUtilities.insertBasicMarketingCampaign('List Upload', false, false, 'Test');
        Campaign campPricing = TestUtilities.insertBasicPricingCampaign(359, 99, false, false);
        Campaign campTradeShow = TestUtilities.insertBasicMarketingCampaign('Trade Show/Event', false, false, 'Test');
        campTradeShow.StartDate = Date.today().addDays(-1);
        update campTradeShow; 
    }

	@isTest static void testCampaignAddDate() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];
		Account a = [SELECT Id FROM Account LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id, StartDate FROM Campaign WHERE Type = 'Trade Show/Event' LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id);
		mapInsert.put(l.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Opportunity__c = o.Id);
		mapInsert.put(o.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Contact__c = c.Id);
		mapInsert.put(c.Id, ci2);

		Campaign_Influence__c ci3 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Account__c = a.Id);
		mapInsert.put(camp.Id, ci3);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci4 = [SELECT Id, Campaign_Add_Date__c FROM Campaign_Influence__c WHERE Lead__c = :l.Id LIMIT 1];
		Campaign_Influence__c ci5 = [SELECT Id, Campaign_Add_Date__c FROM Campaign_Influence__c WHERE Opportunity__c = :o.Id LIMIT 1];
		Campaign_Influence__c ci6 = [SELECT Id, Campaign_Add_Date__c FROM Campaign_Influence__c WHERE Contact__c = :c.Id LIMIT 1];
		Campaign_Influence__c ci7 = [SELECT Id, Campaign_Add_Date__c FROM Campaign_Influence__c WHERE Account__c = :a.Id LIMIT 1];

		System.assertEquals(Date.today(), ci4.Campaign_Add_Date__c.date(), 'The Campaign Add Date is incorrect');
		System.assertEquals(camp2.StartDate, Date.valueOf(ci5.Campaign_Add_Date__c), 'The Campaign Add Date is incorrect');
		System.assertEquals(Date.today(), ci6.Campaign_Add_Date__c.date(), 'The Campaign Add Date is incorrect');
		System.assertEquals(camp2.StartDate, Date.valueOf(ci7.Campaign_Add_Date__c), 'The Campaign Add Date is incorrect');
	}

	@isTest static void createCampaignInfluenceOnOpportunityNoAccount() {
		
		Opportunity o = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type != 'Pricing' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Opportunity__c = o.Id);

		Test.startTest();

		insert ci;

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, Account__c FROM Campaign_Influence__c LIMIT 1];

		System.assertEquals(o.AccountId, ci2.Account__c, 'The Account wasn\'t set');
	}	

	@isTest static void createCampaignInfluenceOnContactNoAccount() {
		
		Contact c = [SELECT Id, AccountId FROM Contact LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type != 'Pricing' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Contact__c = c.Id);

		Test.startTest();

		insert ci;

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, Account__c FROM Campaign_Influence__c LIMIT 1];

		System.assertEquals(c.AccountId, ci2.Account__c, 'The Account wasn\'t set');
	}

	@isTest static void newLeadOnLead() {

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id);

		Test.startTest();

		insert ci;

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c LIMIT 1];

		System.assertEquals(true, ci2.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci2.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void newLeadOnOpp() {

		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Opportunity__c = o.Id);

		Test.startTest();

		insert ci;

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c LIMIT 1];

		System.assertEquals(true, ci2.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci2.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void newLeadOnContact() {

		Contact c = [SELECT Id FROM Contact LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Contact__c = c.Id);

		Test.startTest();

		insert ci;

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c LIMIT 1];

		System.assertEquals(true, ci2.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci2.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void newLeadOnAccount() {
		
		Account a = [SELECT Id FROM Account LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id);

		Test.startTest();

		insert ci;

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c LIMIT 1];

		System.assertEquals(true, ci2.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci2.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void newLeadOverwriteOnLead() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'Cold Call' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id,
			Campaign_Add_Date__c = Datetime.now().addHours(-10));
		mapInsert.put(camp.Id, ci);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Lead__c = l.Id,
			Campaign_Add_Date__c = Datetime.now());
		mapInsert.put(camp2.Id, ci1);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Cold Call' LIMIT 1];
		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' LIMIT 1];

		System.assertEquals(true, ci2.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci2.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci3.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void newLeadOverwriteOnAccount() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Account a = [SELECT Id FROM Account LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'Trade Show/Event' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now().addHours(-100));
		mapInsert.put(camp.Id, ci);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Account__c = a.Id);
		mapInsert.put(camp2.Id, ci1);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Trade Show/Event' LIMIT 1];
		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' LIMIT 1];

		System.assertEquals(true, ci2.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci2.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci3.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void rewarmOnLead() {

		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-100),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-10));
		mapInsert.put(camp.Id, ci);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id,
			Campaign_Add_Date__c = Datetime.now());
		mapInsert.put(l.Id, ci1);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned__c = false LIMIT 1];
		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned__c = true LIMIT 1];

		System.assertEquals(false, ci2.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci2.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
		System.assertEquals(true, ci3.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void rewarmOnAccount() {

		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Account a = [SELECT Id FROM Account LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];

		Campaign_Influence__c ci = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-100),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-10));
		mapInsert.put(camp.Id, ci);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now());
		mapInsert.put(a.Id, ci1);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci2 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned__c = false LIMIT 1];
		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned__c = true LIMIT 1];

		System.assertEquals(false, ci2.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci2.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
		System.assertEquals(true, ci3.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void rewarmOverwriteOnLead() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'Trade Show/Event' LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-100),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-10));
		mapInsert.put(camp.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id,
			Campaign_Add_Date__c = Datetime.now().addHours(-165));
		mapInsert.put(l.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Lead__c = l.Id);
		mapInsert.put(camp2.Id, ci2);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned__c = true LIMIT 1];
		Campaign_Influence__c ci4 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned__c = false LIMIT 1];
		Campaign_Influence__c ci5 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Trade Show/Event' LIMIT 1];

		System.assertEquals(true, ci3.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci4.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci4.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci5.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci5.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
	}

	@isTest static void rewarmOverwriteOnAccount() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Account a = [SELECT Id FROM Account LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'Cold Call' LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-100),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-10));
		mapInsert.put(camp.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now().addHours(-22));
		mapInsert.put(a.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Account__c = a.Id);
		mapInsert.put(camp2.Id, ci2);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned__c = true LIMIT 1];
		Campaign_Influence__c ci4 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned__c = false LIMIT 1];
		Campaign_Influence__c ci5 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Cold Call' LIMIT 1];

		System.assertEquals(true, ci3.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci4.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci4.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci5.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci5.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
	}

	@isTest static void rewarmSecondOnLead() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'Trade Show/Event' LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-100),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-51));
		mapInsert.put(camp.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-50),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-5));
		mapInsert.put(l.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Lead__c = l.Id);
		mapInsert.put(camp2.Id, ci2);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned_Date__c = :ci0.Orphaned_Date__c LIMIT 1];
		Campaign_Influence__c ci4 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned_Date__c = :ci1.Orphaned_Date__c LIMIT 1];
		Campaign_Influence__c ci5 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Trade Show/Event' LIMIT 1];

		System.assertEquals(true, ci3.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci4.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci4.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
		System.assertEquals(false, ci5.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci5.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
	}

	@isTest static void rewarmSecondOnOpp() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Account a = [SELECT Id FROM Account LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];
		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'Trade Show/Event' LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-100),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-51));
		mapInsert.put(a.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Contact__c = c.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-50),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-5));
		mapInsert.put(c.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Opportunity__c = o.Id);
		mapInsert.put(o.Id, ci2);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned_Date__c = :ci0.Orphaned_Date__c LIMIT 1];
		Campaign_Influence__c ci4 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned_Date__c = :ci1.Orphaned_Date__c LIMIT 1];
		Campaign_Influence__c ci5 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Trade Show/Event' LIMIT 1];

		System.assertEquals(true, ci3.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci4.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci4.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
		System.assertEquals(false, ci5.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci5.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
	}

	@isTest static void rewarmSecondOnContact() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Account a = [SELECT Id FROM Account LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];
		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'Trade Show/Event' LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Opportunity__c = o.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-100),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-51));
		mapInsert.put(o.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-50),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-5));
		mapInsert.put(a.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Contact__c = c.Id);
		mapInsert.put(c.Id, ci2);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned_Date__c = :ci0.Orphaned_Date__c LIMIT 1];
		Campaign_Influence__c ci4 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned_Date__c = :ci1.Orphaned_Date__c LIMIT 1];
		Campaign_Influence__c ci5 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Trade Show/Event' LIMIT 1];

		System.assertEquals(true, ci3.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci4.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci4.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
		System.assertEquals(false, ci5.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci5.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
	}

	@isTest static void rewarmSecondOnAccount() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Account a = [SELECT Id FROM Account LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Email' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'Cold Call' LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-100),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-51));
		mapInsert.put(camp.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id,
			Campaign_Add_Date__c = Datetime.now().addDays(-50),
			Orphaned__c = true,
			Orphaned_Date__c = Date.today().addDays(-5));
		mapInsert.put(a.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Account__c = a.Id);
		mapInsert.put(camp2.Id, ci2);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci3 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned_Date__c = :ci0.Orphaned_Date__c LIMIT 1];
		Campaign_Influence__c ci4 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Email' AND Orphaned_Date__c = :ci1.Orphaned_Date__c LIMIT 1];
		Campaign_Influence__c ci5 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Cold Call' LIMIT 1];

		System.assertEquals(true, ci3.New_Lead_Created__c, 'The Campaign Influence should be New Lead');
		System.assertEquals(false, ci3.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci4.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci4.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
		System.assertEquals(false, ci5.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(true, ci5.Lead_Re_Warmed__c, 'The Campaign Influence should be Rewarmed');
	}

	@isTest static void negativesOnLead() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Lead l = [SELECT Id FROM Lead LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Other' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'List Upload' LIMIT 1];
		Campaign camp3 = [SELECT Id FROM Campaign WHERE Type = 'Pricing' LIMIT 1];
		Campaign camp4 = [SELECT Id FROM Campaign WHERE List__c = true LIMIT 1];
		Campaign camp5 = [SELECT Id FROM Campaign WHERE ADR_Set__c = true LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Lead__c = l.Id);
		mapInsert.put(camp.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Lead__c = l.Id);
		mapInsert.put(camp2.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp3.Id,
			Lead__c = l.Id);
		mapInsert.put(camp3.Id, ci2);

		Campaign_Influence__c ci3 = new Campaign_Influence__c(Campaign__c = camp4.Id,
			Lead__c = l.Id);
		mapInsert.put(camp4.Id, ci3);

		Campaign_Influence__c ci4 = new Campaign_Influence__c(Campaign__c = camp5.Id,
			Lead__c = l.Id);
		mapInsert.put(camp5.Id, ci4);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci6 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Other' LIMIT 1];
		Campaign_Influence__c ci7 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'List Upload' LIMIT 1];
		Campaign_Influence__c ci8 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Pricing' LIMIT 1];
		Campaign_Influence__c ci9 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.List__c = true LIMIT 1];
		Campaign_Influence__c ci10 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.ADR_Set__c = true LIMIT 1];

		System.assertEquals(false, ci6.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci6.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci7.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci7.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci8.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci8.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci9.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci9.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci10.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci10.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}

	@isTest static void negativesOnAccount() {
		
		Map<Id, SObject> mapInsert = new Map<Id, SObject>();

		Account a = [SELECT Id FROM Account LIMIT 1];
		Campaign camp = [SELECT Id FROM Campaign WHERE Type = 'Other' LIMIT 1];
		Campaign camp2 = [SELECT Id FROM Campaign WHERE Type = 'List Upload' LIMIT 1];
		Campaign camp3 = [SELECT Id FROM Campaign WHERE Type = 'Pricing' LIMIT 1];
		Campaign camp4 = [SELECT Id FROM Campaign WHERE List__c = true LIMIT 1];
		Campaign camp5 = [SELECT Id FROM Campaign WHERE ADR_Set__c = true LIMIT 1];

		Campaign_Influence__c ci0 = new Campaign_Influence__c(Campaign__c = camp.Id,
			Account__c = a.Id);
		mapInsert.put(camp.Id, ci0);

		Campaign_Influence__c ci1 = new Campaign_Influence__c(Campaign__c = camp2.Id,
			Account__c = a.Id);
		mapInsert.put(camp2.Id, ci1);

		Campaign_Influence__c ci2 = new Campaign_Influence__c(Campaign__c = camp3.Id,
			Account__c = a.Id);
		mapInsert.put(camp3.Id, ci2);

		Campaign_Influence__c ci3 = new Campaign_Influence__c(Campaign__c = camp4.Id,
			Account__c = a.Id);
		mapInsert.put(camp4.Id, ci3);

		Campaign_Influence__c ci4 = new Campaign_Influence__c(Campaign__c = camp5.Id,
			Account__c = a.Id);
		mapInsert.put(camp5.Id, ci4);

		Test.startTest();

		insert mapInsert.values();

		Test.stopTest();

		Campaign_Influence__c ci6 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Other' LIMIT 1];
		Campaign_Influence__c ci7 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'List Upload' LIMIT 1];
		Campaign_Influence__c ci8 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.Type = 'Pricing' LIMIT 1];
		Campaign_Influence__c ci9 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.List__c = true LIMIT 1];
		Campaign_Influence__c ci10 = [SELECT Id, New_Lead_Created__c, Lead_Re_Warmed__c FROM Campaign_Influence__c WHERE Campaign__r.ADR_Set__c = true LIMIT 1];

		System.assertEquals(false, ci6.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci6.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci7.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci7.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci8.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci8.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci9.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci9.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
		System.assertEquals(false, ci10.New_Lead_Created__c, 'The Campaign Influence shouldn\'t be New Lead');
		System.assertEquals(false, ci10.Lead_Re_Warmed__c, 'The Campaign Influence shouldn\'t be Rewarmed');
	}*/
}