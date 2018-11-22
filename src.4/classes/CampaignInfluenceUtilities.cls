public class CampaignInfluenceUtilities {

	public static Map<ID, Campaign> getRelatedCampaignsMap(Campaign_Influence__c[] newCampaignInfluences) {

		Set<ID> campaignIds = new Set<ID>();
		
		for(Campaign_Influence__c ci : newCampaignInfluences) {
			
			campaignIds.add(ci.Campaign__c);
		}
		
		Map<ID, Campaign> results = new Map<ID, Campaign> ([SELECT Id,
			Type, 
			List__c, 
			ADR_Set__c, 
			Default_CI_Type__c,
			StartDate 
			FROM Campaign 
			WHERE Id IN :campaignIds]);

		return results;
	}

	public static Map<ID, Lead> getRelatedLeadsMap(Campaign_Influence__c[] newCampaignInfluences, String ciType) {

		Set<ID> leadIds = new Set<ID>();
		Set<String> typeSet = new Set<String>();
		
		typeSet.add(ciType);
		
		for(Campaign_Influence__c ci : newCampaignInfluences) {

			Boolean isType = false;

			if((ci.Campaign_Influence_Type__c == null || ci.Campaign_Influence_Type__c == 'SR') && (ciType == 'SR' || ciType == null)) {
				
				isType = true;
				typeSet.add('');
			}

			if(ci.Campaign_Influence_Type__c != null && ci.Campaign_Influence_Type__c == 'HG' && ciType == 'HG') isType = true;
			
			if(ci.Campaign_Influence_Type__c != null && ci.Campaign_Influence_Type__c == 'LL' && ciType == 'LL') isType = true;
			
			if(ci.Account__c == null && isType) {
				
				leadIds.add(ci.Lead__c);
			}
		}
		
		Map<ID, Lead> results = new Map<ID, Lead> ([SELECT Id,
			isConverted,
			Number_of_Active_CI__c,
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
				WHERE Campaign_Influence_Type__c IN :typeSet
				ORDER BY Campaign_Add_Date__c ASC)
			FROM Lead 
			WHERE Id IN :leadIds]);

		return results;
	}

	public static Map<ID, Contact> getRelatedContactsMap(Campaign_Influence__c[] newCampaignInfluences) {

		Set<ID> contactIds = new Set<ID>();
		
		for(Campaign_Influence__c ci : newCampaignInfluences) {
				
			contactIds.add(ci.Contact__c);
		}
		
		Map<ID, Contact> results = new Map<ID, Contact> ([SELECT Id,
			AccountId, 
			Account.Lead_Contacts_Parent_Account__c 
			FROM Contact 
			WHERE Id IN :contactIds]);

		return results;
	}

	public static Map<ID, Opportunity> getRelatedOppsMap(Campaign_Influence__c[] newCampaignInfluences) {

		Set<ID> oppIds = new Set<ID>();
		
		for(Campaign_Influence__c ci : newCampaignInfluences) {
		
			oppIds.add(ci.Opportunity__c);
		}
		
		Map<ID, Opportunity> results = new Map<ID, Opportunity> ([SELECT Id,
			AccountId,
			RecordType.Name,
			(SELECT Id,
				Product2.Family
				FROM OpportunityLineItems)
			FROM Opportunity 
			WHERE Id IN :oppIds]);

		return results;
	}

	public static Map<ID, Account> getRelatedAccountsMap(Campaign_Influence__c[] newCampaignInfluences, String ciType) {

		Set<ID> accountIds = new Set<ID>();
		Set<String> typeSet = new Set<String>();
		
		typeSet.add(ciType);

		for(Campaign_Influence__c ci : newCampaignInfluences) {

			Boolean isType = false;

			if((ci.Campaign_Influence_Type__c == null || ci.Campaign_Influence_Type__c == 'SR') && ciType == 'SR') {
				
				isType = true;
				typeSet.add('');
			}

			if(ci.Campaign_Influence_Type__c != null && ci.Campaign_Influence_Type__c == 'HG' && ciType == 'HG') isType = true;
			
			if(ci.Campaign_Influence_Type__c != null && ci.Campaign_Influence_Type__c == 'LL' && ciType == 'LL') isType = true;
			
			if(isType) accountIds.add(ci.Account__c);
		}
		
		Map<ID, Account> results = new Map<ID, Account> ([SELECT Id,
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
				WHERE Campaign_Influence_Type__c IN :typeSet
				ORDER BY Campaign_Add_Date__c ASC)
			FROM Account 
			WHERE Lead_Contacts_Parent_Account__c = false 
			AND Id IN :accountIds]);

		return results;
	}

	public static Campaign_Influence__c createNewCampaignInfluence(Id campaignId, Id contactId, Id leadId, Id oppId, Id acctId, Id userId, Id createdFromId) {

		Campaign_Influence__c result = new Campaign_Influence__c(Campaign__c = campaignId,
			Contact__c = contactId,
			Lead__c = leadId,
			Opportunity__c = oppId,
			Account__c = acctId,
			Associated_Rep__c = userId,
			CreatedFromId__c = createdFromId);

		return result;
	}

	public static Campaign_Influence__c createNewCampaignInfluence(Id campaignId, Id contactId, Id leadId, Id oppId, Id acctId, Id userId, Id createdFromId, Date addDate) 
	{
		Campaign_Influence__c result = new Campaign_Influence__c(Campaign__c = campaignId,
			Contact__c = contactId,
			Lead__c = leadId,
			Opportunity__c = oppId,
			Account__c = acctId,
			Associated_Rep__c = userId,
			CreatedFromId__c = createdFromId,
			Campaign_Add_Date__c = addDate);

		return result;
	}

	public static void setCampaignAddDate(Campaign_Influence__c[] updatedCampaignInfluences, Map<Id, Campaign> relatedCampaignDataMap) {

		for(Campaign_Influence__c ci : updatedCampaignInfluences) {

			if(ci.Campaign_Add_Date__c == null && relatedCampaignDataMap.get(ci.Campaign__c) != null) {
			
				if(relatedCampaignDataMap.get(ci.Campaign__c).Type == 'Trade Show/Event') {

					ci.Campaign_Add_Date__c = relatedCampaignDataMap.get(ci.Campaign__c).StartDate;

				} else {

					ci.Campaign_Add_Date__c = Datetime.now();
				}
			}
		}
	}

	public static void addRelatedRecords(Campaign_Influence__c[] updatedCampaignInfluences, Map<Id, Contact> relatedContactDataMap, Map<Id, Opportunity> relatedOppDataMap) {

		for(Campaign_Influence__c ci : updatedCampaignInfluences) {

			if(ci.Opportunity__c != null && ci.Account__c == null) {

				ci.Account__c = relatedOppDataMap.get(ci.Opportunity__c).AccountId;
			}

			if(ci.Contact__c != null && ci.Account__c == null && !relatedContactDataMap.get(ci.Contact__c).Account.Lead_Contacts_Parent_Account__c) {

				ci.Account__c = relatedContactDataMap.get(ci.Contact__c).AccountId;
			}
		}
	}

	public static void resetLeadCIRequired(Campaign_Influence__c[] newList) {

		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
		Map<Id, Lead> leadMap = getRelatedLeadsMap(newList, 'SR');

		for(Lead l : leadMap.values()) {

			System.debug(l.Campaign_Influence__r);

			Boolean activeCi = false;

			for(Campaign_Influence__c ci : l.Campaign_Influence__r) {

				if((ci.New_Lead_Created__c || ci.Lead_Re_warmed__c) && !ci.Orphaned__c && !l.isConverted) {

					activeCi = true;
				}
			}

			if(activeCi && l.Number_of_Active_CI__c == 0) {

				l.Number_of_Active_CI__c = 1;
				mapUpdateSObject.put(l.Id, l);
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'CampaignInfluenceUtilities.resetLeadCIRequired');
	}

	public static void setCIType(Campaign_Influence__c[] newList, Boolean doDml) {

		Map<Id, Opportunity> oppMap = getRelatedOppsMap(newList);
		Map<Id, Campaign> campaignMap = getRelatedCampaignsMap(newList);

		for(Campaign_Influence__c ci : newList) {

			Campaign c = campaignMap.get(ci.Campaign__c);
			Boolean hasHG = false;
			Boolean hasSRS = false;

			if(ci.Lead__c != null && ci.Account__c == null) {

				ci.Campaign_Influence_Type__c = 'SR';
			
			} else if(ci.Opportunity__c != null) {

				Opportunity o = oppMap.get(ci.Opportunity__c);

				if(o.RecordType.Name == 'New Practice Business') {

					ci.Campaign_Influence_Type__c = 'SR';

				} else if(o.RecordType.Name == 'Healthgrades') {

					ci.Campaign_Influence_Type__c = 'HG';

				} else if(o.RecordType.Name == 'Add Product') {

					for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

						if(oppLi.Product2.Family == 'SR Schedule') hasSRS = true;
						if(oppLi.Product2.Family == 'Healthgrades') hasHG = true;
					}

					if(hasSRS && !hasHG) {
					
						ci.Campaign_Influence_Type__c = 'LL';
					
					} else if(hasHG && !hasSRS) {

						ci.Campaign_Influence_Type__c = 'HG';
					} else {

						ci.Campaign_Influence_Type__c = c.Default_CI_Type__c;
					}
				}
			} else {

				ci.Campaign_Influence_Type__c = c.Default_CI_Type__c;
			}
		}

		if(doDml) {

			try{

				update newList;

			} catch(Exception e){

				System.debug(e);
			} 
		}
	}

	public static void calculateNewRewarmByType(Campaign_Influence__c[] newList) {

		Map<Id, Lead> srLeadMap = getRelatedLeadsMap(newList, 'SR');
		Map<Id, Lead> hgLeadMap = getRelatedLeadsMap(newList, 'HG');
		Map<Id, Lead> llLeadMap = getRelatedLeadsMap(newList, 'LL');
		Map<Id, Account> srAcctMap = getRelatedAccountsMap(newList, 'SR');
		Map<Id, Account> hgAcctMap = getRelatedAccountsMap(newList, 'HG');
		Map<Id, Account> llAcctMap = getRelatedAccountsMap(newList, 'LL');

		if(srLeadMap != null && !srLeadMap.isEmpty()) calculateNewRewarm(srLeadMap, new Map<Id, Account>());
		if(hgLeadMap != null && !hgLeadMap.isEmpty()) calculateNewRewarm(hgLeadMap, new Map<Id, Account>());
		if(llLeadMap != null && !llLeadMap.isEmpty()) calculateNewRewarm(llLeadMap, new Map<Id, Account>());
		if(srAcctMap != null && !srAcctMap.isEmpty()) calculateNewRewarm(new Map<Id, Lead>(), srAcctMap);
		if(hgAcctMap != null && !hgAcctMap.isEmpty()) calculateNewRewarm(new Map<Id, Lead>(), hgAcctMap);
		if(llAcctMap != null && !llAcctMap.isEmpty()) calculateNewRewarm(new Map<Id, Lead>(), llAcctMap);

		CampaignInfluenceUtilities.resetLeadCIRequired(newList);

	}

	public static void calculateNewRewarm(Map<Id, Lead> leadMap, Map<Id, Account> acctMap) {

		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
		Campaign_Influence__c[] listCi = new List<Campaign_Influence__c>();

		if(!leadMap.isEmpty()) {
			
			for(Lead l : leadMap.values()) {
				
				if(l.Campaign_Influence__r.isEmpty() || l.Campaign_Influence__r == null) continue;

				listCi = l.Campaign_Influence__r;
				mapUpdateSObject.putAll(CampaignInfluenceUtilities.setNewRewarm(listCi));
			}
		}

		if(!acctMap.isEmpty()) {
			
			for(Account a : acctMap.values()) {
				
				if(a.Campaign_Influence__r.isEmpty() || a.Campaign_Influence__r == null) continue;

				listCi = a.Campaign_Influence__r;
				mapUpdateSObject.putAll(CampaignInfluenceUtilities.setNewRewarm(listCi));
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'CampaignInfluenceUtilities.calculateNewRewarm');
	}
	
	public static Map<Id, SObject> setNewRewarm(Campaign_Influence__c[] listCi) {

		Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
		Campaign_Influence__c activeCi = null;

		for(Campaign_Influence__c ci : listCi) {

			if(eligibleNewRewarm(ci)) {
				
				if(activeCi == null) {
				
					ci = CampaignInfluenceUtilities.setNewLeadCreated(ci);
					activeCi = ci;
					mapUpdateSObject.put(ci.Id, ci);
				
				} else {

					if(eligibleToOverwrite(ci) && eligibleToBeOverwritten(activeCi, ci)) {

						Campaign_Influence__c overwriteCi = new Campaign_Influence__c();
						overwriteCi.Id = activeCi.Id;
						overwriteCi = CampaignInfluenceUtilities.clearNewRewarmed(overwriteCi);
						mapUpdateSObject.put(overwriteCi.Id, overwriteCi);

						ci = activeCi.New_Lead_Created__c ? CampaignInfluenceUtilities.setNewLeadCreated(ci) : CampaignInfluenceUtilities.setLeadRewarmed(ci);
						activeCi = ci;
						mapUpdateSObject.put(ci.Id, ci);
				
					} else if(activeCi.Orphaned_Date__c != null && ci.Campaign_Add_Date__c > activeCi.Orphaned_Date__c) {
				
						ci = CampaignInfluenceUtilities.setLeadRewarmed(ci);
						activeCi = ci;
						mapUpdateSObject.put(ci.Id, ci);

					} else {
				
						ci = CampaignInfluenceUtilities.clearNewRewarmed(ci);
						mapUpdateSObject.put(ci.Id, ci);
					}
				}

			} else {
			
				ci = CampaignInfluenceUtilities.clearNewRewarmed(ci);
				mapUpdateSObject.put(ci.Id, ci);
			}
		}

		return mapUpdateSObject;
	}	

	public static Boolean eligibleNewRewarm(Campaign_Influence__c ci) {

		Boolean result = (ci.Campaign__r.Type != 'List Upload' && 
			ci.Campaign__r.Type != 'Other' &&
			ci.Campaign__r.Type != 'Pricing' &&
			!ci.Campaign__r.List__c &&
			!ci.Campaign__r.ADR_Set__c);

		return result;
	}

	public static Boolean eligibleToOverwrite(Campaign_Influence__c ci) {

		Boolean result = (ci.Campaign__r.Type == 'Cold Call' ||
			ci.Campaign__r.Type == 'Trade Show/Event');

		return result;
	}

	public static Boolean eligibleToBeOverwritten(Campaign_Influence__c ci, Campaign_Influence__c overwritingCi) {

		Integer gracePeriod = overwritingCi.Campaign__r.Type == 'Cold Call' ? 24 : 168;

		Boolean result = (ci.Campaign_Add_Date__c != null && 
			ci.Campaign__r.Type != 'Cold Call' &&
			ci.Campaign__r.Type != 'Trade Show/Event' &&
			ci.Campaign_Add_Date__c.addHours(gracePeriod) > overwritingCi.Campaign_Add_Date__c);

		return result;
	}

	public static Campaign_Influence__c setNewLeadCreated(Campaign_Influence__c ci) {

		ci.New_Lead_Created__c = true;
		ci.Lead_Re_warmed__c = false;

		return ci;
	}
	
	public static Campaign_Influence__c setLeadRewarmed(Campaign_Influence__c ci) {

		ci.New_Lead_Created__c = false;
		ci.Lead_Re_warmed__c = true;

		return ci;
	}

	public static Campaign_Influence__c clearNewRewarmed(Campaign_Influence__c ci) {

		ci.New_Lead_Created__c = false;
		ci.Lead_Re_warmed__c = false;

		return ci;
	}

	/*public static void blockDuplicateCampaignInfluence(Campaign_Influence__c[] updatedCampaignInfluences) {

		Campaign_Influence__c[] listCi = new List<Campaign_Influence__c>();
		String errorMsg = 'There is already a Campaign with matching status';

		for(Campaign_Influence__c ci : updatedCampaignInfluences) {

			if(!relatedLeadDataMap.isEmpty()) {
				
				for(Lead l : relatedLeadDataMap.values()) {
					
					listCi = l.Campaign_Influence__r;
					
					if(CampaignInfluenceUtilities.hasDuplicateCampaignInfluence(listCi, ci)) {

						ci.addError(errorMsg);
					}
				}
			}

			if(!relatedAccountDataMap.isEmpty()) {
				
				for(Account a : relatedAccountDataMap.values()) {
					
					listCi = a.Campaign_Influence__r;
					
					if(CampaignInfluenceUtilities.hasDuplicateCampaignInfluence(listCi, ci)) {

						ci.addError(errorMsg);
					}
				}
			}
		}
	}

	public static Boolean hasDuplicateCampaignInfluence(Campaign_Influence__c[] listCi, Campaign_Influence__c updatedCi) {

		Boolean result = false;
		Set<String> dupeCheck = new Set<String>();
		String dupeString;

		for(Campaign_Influence__c ci : listCi) {

			if(ci.Id != updatedCi.Id) {

				dupeString = String.valueOf(ci.Campaign__c) + 
				String.valueOf(ci.New_Lead_Created__c) + 
				String.valueOf(ci.Lead_Re_warmed__c) + 
				String.valueOf(ci.Orphaned__c) + 
				String.valueOf(ci.Orphaned_Date__c) +
				String.valueOf(ci.Associated_Rep__c) + 
				String.valueOf(ci.Account__c) + 
				String.valueOf(ci.Lead__c) + 
				String.valueOf(ci.Contact__c) + 
				String.valueOf(ci.Opportunity__c);

				dupeCheck.add(dupeString);
			}
		}

		dupeString = String.valueOf(updatedCi.Campaign__c) + 
		String.valueOf(updatedCi.New_Lead_Created__c) + 
		String.valueOf(updatedCi.Lead_Re_warmed__c) + 
		String.valueOf(updatedCi.Orphaned__c) + 
		String.valueOf(updatedCi.Orphaned_Date__c) +
		String.valueOf(updatedCi.Associated_Rep__c) + 
		String.valueOf(updatedCi.Account__c) + 
		String.valueOf(updatedCi.Lead__c) + 
		String.valueOf(updatedCi.Contact__c) + 
		String.valueOf(updatedCi.Opportunity__c);

		if(dupeCheck.contains(dupeString)) {

			result = true;
		}

		return result;
	}*/

	public static Boolean hasOpenCampaignInfluence(Campaign_Influence__c[] listCi, Id campaignId, Id userId) {

		Boolean result = false;

		for(Campaign_Influence__c ci : listCi) {

			if(!ci.Orphaned__c &&
				ci.Campaign__c == campaignId &&
				ci.Associated_Rep__c == userId) {

				result = true;
			}
		}

		return result;
	}
}