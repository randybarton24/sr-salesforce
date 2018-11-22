public with sharing class CaseUtilities {

	public static void validateHealthgradesStatusBeforeClose(Case[] updatedCases) {

		Set<Id> acctIds = new Set<Id>();
		Map<Id, Case> mapHGCases = new Map<Id, Case>();

		for(Case c : updatedCases) {

			acctIds.add(c.AccountId);
		}

		Case[] listHGCases = [SELECT 
		AccountId, 
		Id, 
		Product__c, 
		Status, 
		OwnerId 
		FROM Case 
		WHERE Status != 'Closed' 
		AND Product__c = 'Healthgrades' 
		AND AccountId IN : acctIds];
		
		for(Case c : listHGCases) {
			
			mapHGCases.put(c.AccountId, c);
		}

		for(Case c : updatedCases) {

			if(c.RecordTypeId == SRUtilities.getRecordTypeMap('Case').get('Activation').getRecordTypeId() && 
				c.Healthgrades_Status__c != 'Setup Required' && 
				mapHGCases.containsKey(c.AccountId)) {

				c.Healthgrades_Status__c.addError(Label.Error_Open_Healthgrades_Case);
			}
		}
	}
}