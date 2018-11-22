global class PardotTaskCleanup_Batch implements Database.Batchable<sObject>, Schedulable {
	
	Date cutOff = Date.today().addDays(-5);
	String query = 'SELECT Id, CreatedDate FROM Task WHERE Subject LIKE \'Pardot%Email:%\' AND CreatedBy.Profile.Name = \'Marketing User SR\' AND CreatedDate < :cutOff LIMIT 5000';

	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Task> scope) {

		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

		for(Task t : scope) {

			if(t.CreatedDate < cutOff || Test.isRunningTest()) {

				mapDeleteSObject.put(t.Id, t);
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'PardotTaskCleanup_Batch');
	}
			
	global void finish(Database.BatchableContext BC) {
		
		Task[] remaining = [SELECT Id FROM Task WHERE Subject LIKE 'Pardot%Email:%' AND CreatedBy.Profile.Name = 'Marketing User SR' AND CreatedDate < :cutOff LIMIT 1];

		if(!remaining.isEmpty()) {

			PardotTaskCleanup_Batch batch = new PardotTaskCleanup_Batch();
			Database.executebatch(batch);
		}
	}

	global void execute(SchedulableContext sc) {
		
		PardotTaskCleanup_Batch batch = new PardotTaskCleanup_Batch();
		Database.executebatch(batch);
	}
}