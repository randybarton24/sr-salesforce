global class CIRecalculateAcct_Batch implements Database.Batchable<sObject> {
	
	Datetime dateFilter = Datetime.now().addHours(-23);
	String query = 'SELECT Id FROM Account';

	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {

      	Campaign_Influence__c[] blankCiType = [SELECT Id,
      	Lead__c,
		Account__c, 
		Opportunity__c, 
		Opportunity__r.AccountId, 
		Contact__c, 
		Contact__r.Associated_Opp__c,
		Contact__r.Lead__c,
		Contact__r.AccountId, 
		Contact__r.Account.Lead_Contacts_Parent_Account__c, 
		Campaign__c, 
		Campaign__r.Type, 
		Campaign__r.List__c, 
		Campaign__r.ADR_Set__c, 
		Campaign__r.StartDate, 
		Campaign_Add_Date__c, 
		New_Lead_Created__c, 
		Lead_Re_warmed__c, 
		Orphaned__c, 
		Orphaned_Date__c, 
		Associated_Rep__c 
		FROM Campaign_Influence__c 
		WHERE Campaign_Influence_Type__c = null
		AND Account__c IN :scope];

		CampaignInfluenceUtilities.setCIType(blankCiType, true);

      	Map<ID, Account> srAccts = new Map<ID, Account> ([SELECT Id,
			(SELECT Id,
				Lead__c,
				Account__c, 
				Opportunity__c, 
				Opportunity__r.AccountId, 
				Contact__c, 
				Contact__r.Associated_Opp__c,
				Contact__r.Lead__c,
				Contact__r.AccountId, 
				Contact__r.Account.Lead_Contacts_Parent_Account__c, 
				Campaign__c, 
				Campaign__r.Type, 
				Campaign__r.List__c, 
				Campaign__r.ADR_Set__c, 
				Campaign__r.StartDate, 
				Campaign_Add_Date__c, 
				New_Lead_Created__c, 
				Lead_Re_warmed__c, 
				Orphaned__c, 
				Orphaned_Date__c, 
				Associated_Rep__c 
				FROM Campaign_Influence__r 
				WHERE Campaign_Influence_Type__c IN ('SR','')
				ORDER BY Campaign_Add_Date__c ASC)
			FROM Account 
			WHERE Lead_Contacts_Parent_Account__c = false 
			AND Id IN :scope]);

		CampaignInfluenceUtilities.calculateNewRewarm(new Map<Id, Lead>(), srAccts);

		Map<ID, Account> hgAccts = new Map<ID, Account> ([SELECT Id,
			(SELECT Id,
				Lead__c,
				Account__c, 
				Opportunity__c, 
				Opportunity__r.AccountId, 
				Contact__c, 
				Contact__r.Associated_Opp__c,
				Contact__r.Lead__c,
				Contact__r.AccountId, 
				Contact__r.Account.Lead_Contacts_Parent_Account__c, 
				Campaign__c, 
				Campaign__r.Type, 
				Campaign__r.List__c, 
				Campaign__r.ADR_Set__c, 
				Campaign__r.StartDate, 
				Campaign_Add_Date__c, 
				New_Lead_Created__c, 
				Lead_Re_warmed__c, 
				Orphaned__c, 
				Orphaned_Date__c, 
				Associated_Rep__c 
				FROM Campaign_Influence__r 
				WHERE Campaign_Influence_Type__c = 'HG'
				ORDER BY Campaign_Add_Date__c ASC)
			FROM Account 
			WHERE Lead_Contacts_Parent_Account__c = false 
			AND Id IN :scope]);

		CampaignInfluenceUtilities.calculateNewRewarm(new Map<Id, Lead>(), hgAccts);

		Map<ID, Account> llAccts = new Map<ID, Account> ([SELECT Id,
			(SELECT Id,
				Lead__c,
				Account__c, 
				Opportunity__c, 
				Opportunity__r.AccountId, 
				Contact__c, 
				Contact__r.Associated_Opp__c,
				Contact__r.Lead__c,
				Contact__r.AccountId, 
				Contact__r.Account.Lead_Contacts_Parent_Account__c, 
				Campaign__c, 
				Campaign__r.Type, 
				Campaign__r.List__c, 
				Campaign__r.ADR_Set__c, 
				Campaign__r.StartDate, 
				Campaign_Add_Date__c, 
				New_Lead_Created__c, 
				Lead_Re_warmed__c, 
				Orphaned__c, 
				Orphaned_Date__c, 
				Associated_Rep__c 
				FROM Campaign_Influence__r 
				WHERE Campaign_Influence_Type__c = 'LL'
				ORDER BY Campaign_Add_Date__c ASC)
			FROM Account 
			WHERE Lead_Contacts_Parent_Account__c = false 
			AND Id IN :scope]);

		CampaignInfluenceUtilities.calculateNewRewarm(new Map<Id, Lead>(), llAccts);
	}
			
	global void finish(Database.BatchableContext BC) {
		
	}

	global void execute(SchedulableContext sc) {
		
		CIRecalculateAcct_Batch batch = new CIRecalculateAcct_Batch();
		Database.executebatch(batch);
	}
}