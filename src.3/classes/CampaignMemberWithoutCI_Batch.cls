global class CampaignMemberWithoutCI_Batch implements Database.Batchable<sObject>, Schedulable 
{		
	String dateRange;

	public CampaignMemberWithoutCI_Batch(String dateRange)
	{
		this.dateRange = dateRange;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		if(this.dateRange == null) this.dateRange = 'today';
		return CampaignMembersSelector.newInstance().queryLocatorCampaignMemberWithoutCI(dateRange);
	}

	global void execute(Database.BatchableContext BC, List<CampaignMember> scope) 
	{
      	update scope;
	}
			
	global void finish(Database.BatchableContext BC) 
	{	

	}

	global void execute(SchedulableContext sc) 
	{	
		CampaignMemberWithoutCI_Batch batch = new CampaignMemberWithoutCI_Batch(dateRange);
		Database.executebatch(batch, 1);
	}
}