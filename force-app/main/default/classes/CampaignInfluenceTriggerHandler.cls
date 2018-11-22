public with sharing class CampaignInfluenceTriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	//private static final Map<String, Id> StaticCampaignInfluenceRecordTypes = RecordTypes.GetRecordTypeIdDevMap('Campaign_Influence__c');
	public static Map<Id, Campaign> relatedCampaignDataMap;
	public static Map<Id, Lead> relatedLeadDataMap;
	public static Map<Id, Contact> relatedContactDataMap;
	public static Map<Id, Opportunity> relatedOppDataMap;
	public static Map<Id, Account> relatedAccountDataMap;

	public CampaignInfluenceTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnBeforeInsert(Campaign_Influence__c[] newCampaignInfluences){
		
		if(!FlowControl.campaignInfluenceBeforeInsertRecursion) {
			FlowControl.campaignInfluenceBeforeInsertRecursion = true;
			relatedContactDataMap = CampaignInfluenceUtilities.getRelatedContactsMap(newCampaignInfluences);
			relatedOppDataMap = CampaignInfluenceUtilities.getRelatedOppsMap(newCampaignInfluences);
			CampaignInfluenceUtilities.addRelatedRecords(newCampaignInfluences, relatedContactDataMap, relatedOppDataMap);
			CampaignInfluenceUtilities.setCIType(newCampaignInfluences, false);
		}
	}

	public void OnAfterInsert(Campaign_Influence__c[] newCampaignInfluences, Map<Id, Campaign_Influence__c> newCampaignInfluenceMap) {
		
		FlowControl.inCampaignInfluenceAfterInsert = true;

		if(!FlowControl.campaignInfluenceAfterInsertRecursion) {
			FlowControl.campaignInfluenceAfterInsertRecursion = true;
			CampaignInfluenceUtilities.calculateNewRewarmByType(newCampaignInfluences);
			if(!System.isBatch() && !System.isFuture()) CampaignInfluenceTriggerHandler.OnAfterInsertAsync(newCampaignInfluenceMap.keySet());
		}

		FlowControl.inCampaignInfluenceAfterInsert = false;
	}

	@future public static void OnAfterInsertAsync(Set<ID> newCampaignInfluenceIDs){

		if(!System.isBatch() && !System.isFuture()) {

			Campaign_Influence__c[] newList = [SELECT Id FROM Campaign_Influence__c WHERE Id IN :newCampaignInfluenceIDs];
			CampaignInfluenceUtilities.resetLeadCIRequired(newList);
		}
	}

	public void OnBeforeUpdate(Campaign_Influence__c[] oldCampaignInfluences, Campaign_Influence__c[] updatedCampaignInfluences, Map<ID, Campaign_Influence__c> oldCampaignInfluenceMap, Map<ID, Campaign_Influence__c> newCampaignInfluenceMap){
		
		if(FlowControl.isLeadConvert) {

			if(!FlowControl.campaignInfluenceBeforeUpdateRecursion) {
				FlowControl.campaignInfluenceBeforeUpdateRecursion = true;

			}

		} else {

			if(!FlowControl.campaignInfluenceBeforeUpdateRecursion) {
				FlowControl.campaignInfluenceBeforeUpdateRecursion = true;
				relatedContactDataMap = CampaignInfluenceUtilities.getRelatedContactsMap(updatedCampaignInfluences);
				relatedOppDataMap = CampaignInfluenceUtilities.getRelatedOppsMap(updatedCampaignInfluences);
				CampaignInfluenceUtilities.addRelatedRecords(updatedCampaignInfluences, relatedContactDataMap, relatedOppDataMap);
				CampaignInfluenceUtilities.setCIType(updatedCampaignInfluences, false);
			}
		}
	}

	public void OnAfterUpdate(Campaign_Influence__c[] oldCampaignInfluences, Campaign_Influence__c[] updatedCampaignInfluences, Map<ID, Campaign_Influence__c> oldCampaignInfluenceMap, Map<ID, Campaign_Influence__c> newCampaignInfluenceMap){

		if(FlowControl.isLeadConvert) {

			if(!FlowControl.campaignInfluenceAfterUpdateRecursion && !FlowControl.inCampaignInfluenceAfterInsert) {
				FlowControl.campaignInfluenceAfterUpdateRecursion = true;
				
			}

		} else {

			if(!FlowControl.campaignInfluenceAfterUpdateRecursion && !FlowControl.inCampaignInfluenceAfterInsert) {
				FlowControl.campaignInfluenceAfterUpdateRecursion = true;
				CampaignInfluenceUtilities.calculateNewRewarmByType(updatedCampaignInfluences);
				CampaignInfluenceUtilities.resetLeadCIRequired(updatedCampaignInfluences);
			}
		}

		
	}

	/*@future public static void OnAfterUpdateAsync(Set<ID> updatedCampaignInfluenceIDs){

		if(!System.isBatch() && !System.isFuture()) {

		}
	}*/

	//public void OnBeforeDelete(Campaign_Influence__c[] CampaignInfluencesToDelete, Map<ID, Campaign_Influence__c> CampaignInfluenceMap){}

	//public void OnAfterDelete(Campaign_Influence__c[] deletedCampaignInfluences, Map<ID, Campaign_Influence__c> CampaignInfluenceMap){}

	//@future public static void OnAfterDeleteAsync(Set<ID> deletedCampaignInfluenceIDs){}

	//public void OnUndelete(Campaign_Influence__c[] restoredCampaignInfluences){}

	//public boolean IsTriggerContext{
	//	get{ return m_isExecuting;}
	//}

	//public boolean IsVisualforcePageContext{
	//	get{ return !IsTriggerContext;}
	//}

	//public boolean IsWebServiceContext{
	//	get{ return !IsTriggerContext;}
	//}

	//public boolean IsExecuteAnonymousContext{
	//	get{ return !IsTriggerContext;}
	//}

}