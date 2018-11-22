public class CampaignMemberUtilities {

	public static Map<ID, Contact> getRelatedContactsMap(CampaignMember[] newCampaignMembers) {

		Set<ID> contactIds = new Set<ID>();
		
		for(CampaignMember cm : newCampaignMembers) {
			
			contactIds.add(cm.ContactId);
		}
		
		Map<ID, Contact> results = new Map<ID, Contact> ([SELECT Id,
			Associated_Opp__c,
			Lead__c,
			AccountId, 
			Account.Lead_Contacts_Parent_Account__c 
			FROM Contact 
			WHERE Id IN :contactIds]);

		return results;
	}

	public static void createCampaignInfluenceFromCampaignMember(CampaignMember[] newCampaignMembers) {

		
		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

      	Id contactId;
      	Id oppId;
      	Id leadId;
      	Id accountId;
      	Id campaignId;
      	Id userId;

		for(CampaignMember cm : newCampaignMembers) {

			campaignId = cm.CampaignId;
			userId = null;

			if(cm.LeadId != null && cm.ContactId == null) {
				
				leadId = cm.LeadId;

			} else if(cm.LeadId == null && cm.ContactId != null) {
				
				contactId = cm.ContactId;
				leadId = CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).Lead__c != null ? CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).Lead__c : null;
				//oppId = CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).Associated_Opp__c != null ? CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).Associated_Opp__c : null;
				accountId = CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).Account.Lead_Contacts_Parent_Account__c ? null : CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).AccountId;
			
			} else if(cm.LeadId != null && cm.ContactId != null) {

				contactId = cm.ContactId;
				leadId = cm.LeadId;
				//oppId = CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).Associated_Opp__c != null ? CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).Associated_Opp__c : null;
				accountId = CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).Account.Lead_Contacts_Parent_Account__c ? null : CampaignMemberTriggerHandler.contactDataMap.get(cm.ContactId).AccountId;
			}

			Campaign_Influence__c newCampaignInfluence = CampaignInfluenceUtilities.createNewCampaignInfluence(campaignId, contactId, leadId, oppId, accountId, userId, cm.Id, Date.valueOf(cm.CreatedDate));
			mapInsertSObject.put(cm.Id, newCampaignInfluence);
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'createCampaignInfluenceFromCampaignMember');
	}
}