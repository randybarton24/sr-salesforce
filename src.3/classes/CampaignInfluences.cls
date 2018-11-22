public class CampaignInfluences extends fflib_SObjectDomain 
{
	public Set<Id> setDemoRequestReason;
	public Set<String> stampUpdates;
	public Stamp_Field_Mapping__c[] stampMappings;

	public CampaignInfluences(Campaign_Influence__c[] campaignInfluences) 
	{
		super(campaignInfluences);	
		Configuration.disableTriggerCRUDSecurity();
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new CampaignInfluences(sObjectList);
		}
	}

	public override void onAfterInsert()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();

		for(Campaign_Influence__c ci : (Campaign_Influence__c[]) Records) 
    	{
    		this.setDemoRequestReason(ci, null);
    		this.processStampUpdates(ci, null);
    	}

    	if(setDemoRequestReason != null && 
    		!setDemoRequestReason.isEmpty()) SRUtilities.scheduleAsync(setDemoRequestReason, 'Demo_Request_Reason', uow);

    	if(stampUpdates != null && 
    		!stampUpdates.isEmpty()) SRUtilities.scheduleAsync(stampUpdates, 'Stamp_Updates', uow);

    	uow.registerWork(sruow);
        uow.commitWork();
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();

		for(Campaign_Influence__c ci : (Campaign_Influence__c[]) Records) 
    	{
    		Campaign_Influence__c existingCampaignInfluence = (Campaign_Influence__c) existingRecords.get(ci.Id);

            this.setDemoRequestReason(ci, existingCampaignInfluence);
            this.processStampUpdates(ci, existingCampaignInfluence);
    	}

    	if(setDemoRequestReason != null && 
    		!setDemoRequestReason.isEmpty()) SRUtilities.scheduleAsync(setDemoRequestReason, 'Demo_Request_Reason', uow);

    	if(stampUpdates != null && 
    		!stampUpdates.isEmpty()) SRUtilities.scheduleAsync(stampUpdates, 'Stamp_Updates', uow);

    	uow.registerWork(sruow);
        uow.commitWork();
	}

	public override void onBeforeDelete()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();

		for(Campaign_Influence__c ci : (Campaign_Influence__c[]) Records) 
    	{
            this.setDemoRequestReason(ci, null);
    	}

    	if(setDemoRequestReason != null && 
    		!setDemoRequestReason.isEmpty()) SRUtilities.scheduleAsync(setDemoRequestReason, 'Demo_Request_Reason', uow);

    	uow.registerWork(sruow);
        uow.commitWork();
	}

	public void processStampUpdates(Campaign_Influence__c ci, Campaign_Influence__c existingCampaignInfluence)
	{
		if(stampMappings == null) stampMappings = [SELECT Id, Field_Changed__c, Field_Changed_Value__c
			FROM Stamp_Field_Mapping__c 
			WHERE Stamp_To_Object__c = 'Campaign_Influence__c'
			AND Active__c = true];
		
		String stampUpdateString = SRUtilities.processStampUpdates(ci, existingCampaignInfluence, stampMappings);

		if(stampUpdateString == null) return;
		if(stampUpdates == null) stampUpdates = new Set<String>(); 
		stampUpdates.add(stampUpdateString);
	}

	public void setDemoRequestReason(Campaign_Influence__c ci, Campaign_Influence__c existingCampaignInfluence)
	{
		if(ci.Opportunity__c == null) return;
		if(existingCampaignInfluence != null &&
			existingCampaignInfluence.Opportunity__c == ci.Opportunity__c) return;

		if(setDemoRequestReason == null) setDemoRequestReason = new Set<Id>();
		setDemoRequestReason.add(ci.Opportunity__c);
	}
}