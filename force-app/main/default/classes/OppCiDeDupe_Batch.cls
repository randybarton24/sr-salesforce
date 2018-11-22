global class OppCiDeDupe_Batch implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id FROM Opportunity';

	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Opportunity> scope) {

		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
      	Set<String> dupeCheck = new Set<String>();
      	String dupeString = '';

      	Opportunity[] thisList = [SELECT Id, Last_Roe_Task_Date__c, SR_Date_Created__c, isGroup__c, 
      	(SELECT Id, Campaign__c, Campaign__r.Name, New_Lead_Created__c, Lead_Re_Warmed__c, Associated_Rep__c, Account__c, 
		Lead__c, Contact__c, Opportunity__c, Orphaned__c, Orphaned_Date__c, Campaign_Add_Date__c 
		FROM Campaign_Influence__r ORDER BY Campaign_Add_Date__c ASC) FROM Opportunity WHERE Id IN :scope];

		for(Opportunity o : thisList) {

			if(o.Campaign_Influence__r.size() == 0) continue;

			dupeCheck.clear();
			dupeString = '';

			for(Campaign_Influence__c ci : o.Campaign_Influence__r) {

				if(ci.Campaign__r.Name == 'Other - : Existing Lead 9/16') {

					dupeString = String.valueOf(ci.Campaign__c) + 
					String.valueOf(ci.Opportunity__c);
				
				} else {

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
				}
				

				if(!dupeCheck.contains(dupeString)) {
					
					dupeCheck.add(dupeString);

				} else {

					mapDeleteSObject.put(ci.Id, ci);
				}
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OppCiDeDupe_Batch');
	}
			
	global void finish(Database.BatchableContext BC) {
		
	}
}