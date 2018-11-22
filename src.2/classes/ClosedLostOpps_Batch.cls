global class ClosedLostOpps_Batch implements Database.Batchable<sObject>, Schedulable 
{
	SR_Default_Values__c defaultROEValue = SR_Default_Values__c.getValues('Opportunity Closed Lost Days');
	SR_Default_Values__c defaultCreatedValue = SR_Default_Values__c.getValues('Opportunity Closed Lost Created Days');
	Integer cutOffDays = Integer.valueOf(defaultROEValue.Value__c);
	Integer createdCutOffDays = Integer.valueOf(defaultCreatedValue.Value__c);

	Date cutOff = Date.today().addDays(-cutOffDays);
	Date createdCutOff = Date.today().addDays(-createdCutOffDays);
	String query = 'SELECT Id, Account.Last_ROE_Date__c, Account.Parent.Last_ROE_Date__c, CreatedDate ' +
	'FROM Opportunity ' +
	'WHERE RecordType.Name = \'New Practice Business\' ' +
	'AND StageName NOT IN (\'Closed Lost\',\'Closed Won\',\'Not Qualified\') ' + 
	'AND Owner.Profile.Name NOT IN (\'Client Engagement Rep\',\'Client Engagement Manager\',\'Support\',\'Support Manager\') ' +
	'AND ((Account.ParentId = null ' +
		'AND ((Account.Last_ROE_Date__c < :cutOff OR Account.Last_ROE_Date__c = null) AND CreatedDate < :createdCutOff)) ' +
	'OR (Account.ParentId != null ' +
		'AND ((Account.Parent.Last_ROE_Date__c < :cutOff OR Account.Parent.Last_ROE_Date__c = null) AND CreatedDate < :createdCutOff))) ' +
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
			if(o.Account.ParentId != null && 
				((o.Account.Parent.Last_ROE_Date__c < cutOff || o.Account.Parent.Last_ROE_Date__c == null) && o.CreatedDate < createdCutOff))
			{
				o.StageName = 'Closed Lost';
				o.Reason_For_Closing__c = 'ROE Expired';
				o.Apex_Override_Validation__c = true;
				mapUpdateSObject.put(o.Id, o);
			}
			else if(o.Account.ParentId == null && 
				((o.Account.Last_ROE_Date__c < cutOff || o.Account.Last_ROE_Date__c == null) && o.CreatedDate < createdCutOff))
			{
				o.StageName = 'Closed Lost';
				o.Reason_For_Closing__c = 'ROE Expired';
				o.Apex_Override_Validation__c = true;
				mapUpdateSObject.put(o.Id, o);
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'ClosedLostOpps_Batch');
	}
			
	global void finish(Database.BatchableContext BC) 
	{
		Opportunity[] remaining = [SELECT Id, Account.Last_ROE_Date__c, CreatedDate 
			FROM Opportunity 
			WHERE RecordType.Name = 'New Practice Business' 
			AND StageName NOT IN ('Closed Lost','Closed Won','Not Qualified')  
			AND Owner.Profile.Name NOT IN ('Client Engagement Rep','Client Engagement Manager','Support','Support Manager')
			AND ((Account.ParentId = null
				AND ((Account.Last_ROE_Date__c < :cutOff OR Account.Last_ROE_Date__c = null) AND CreatedDate < :createdCutOff))
			OR (Account.ParentId != null
				AND ((Account.Parent.Last_ROE_Date__c < :cutOff OR Account.Parent.Last_ROE_Date__c = null) AND CreatedDate < :createdCutOff)))
			LIMIT 1000];

		if(remaining.size() > 100) 
		{
			ClosedLostOpps_Batch batch = new ClosedLostOpps_Batch();
			Database.executebatch(batch, 50);
		}
	}

	global void execute(SchedulableContext sc) 
	{
		ClosedLostOpps_Batch batch = new ClosedLostOpps_Batch();
		Database.executebatch(batch, 50);
	}
}