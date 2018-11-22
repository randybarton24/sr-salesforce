global class UpdatePricebooks implements Database.Batchable<sObject>, Schedulable 
{	
	String query = 'SELECT Id, Pricebook2Id, (SELECT Id FROM OpportunityLineItems) ' +
		'FROM Opportunity ' +
		'WHERE Pricebook2Id NOT IN (\'01s0Z000003qlhyQAA\',\'01s0Z000003qldXQAQ\',\'01s0Z000003qldcQAA\',\'01s0Z000003qldhQAA\',\'01s0Z000003qldmQAA\',\'01s0Z000003qle6QAA\',\'01s0Z000003qljpQAA\',' +
		'\'01s0Z000003qleBQAQ\',\'01s0Z000003qleGQAQ\',\'01s0Z000003qleLQAQ\',\'01s31000003wn8CAAQ\',\'01s310000044ahuAAA\',\'01s31000004GythAAC\',\'01s31000004GzflAAC\',\'01s0Z000003qlk9QAA\',' +
		'\'01si00000048VpoAAE\',\'01si00000048VptAAE\',\'01si00000048VpyAAE\',\'01si0000001UiumAAC\') ' + 
		'AND IsClosed = false ';
		
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Opportunity> scope) 
	{
		for(Opportunity o : scope)
		{
			if(o.OpportunityLineItems.size() > 0)
			{
				delete o.OpportunityLineItems;
			}
			o.Pricebook2Id = '01s0Z000003qlhyQAA';
		}

		update scope;
	}
			
	global void finish(Database.BatchableContext BC) 
	{

	}

	global void execute(SchedulableContext sc) 
	{	
		UpdatePricebooks batch = new UpdatePricebooks();
		Database.executebatch(batch, 1);
	}
}