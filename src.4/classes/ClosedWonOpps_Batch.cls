global class ClosedWonOpps_Batch implements Database.Batchable<sObject>, Schedulable 
{
	String query = 'SELECT Id, StageName, Auto_Closed_Won_Date__c ' +
	'FROM Opportunity ' +
	'WHERE StageName NOT IN (\'Closed Lost\',\'Closed Won\',\'Not Qualified\') ' + 
	'AND Auto_Closed_Won_Date__c <= today ' +
	'LIMIT 1000';

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Opportunity> scope) 
	{
		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

		for(Opportunity o : scope) 
		{
			o.StageName = 'Closed Won';
			o.Apex_Override_Validation__c = true;
			mapUpdateSObject.put(o.Id, o);
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'ClosedWonOpps_Batch');
	}
			
	global void finish(Database.BatchableContext BC) 
	{
		Opportunity[] remaining = [SELECT Id, StageName, Auto_Closed_Won_Date__c
			FROM Opportunity 
			WHERE StageName NOT IN ('Closed Lost','Closed Won','Not Qualified')  
			AND Auto_Closed_Won_Date__c <= today
			LIMIT 1000];

		if(remaining.size() > 100) 
		{
			ClosedWonOpps_Batch batch = new ClosedWonOpps_Batch();
			Database.executebatch(batch, 50);
		}
	}

	global void execute(SchedulableContext sc) 
	{
		ClosedWonOpps_Batch batch = new ClosedWonOpps_Batch();
		Database.executebatch(batch, 50);
	}
}