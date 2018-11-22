public class CampaignMembers extends fflib_SObjectDomain 
{
	public Set<String> createCI;

	public CampaignMembers(CampaignMember[] campaignMembers) 
	{
		super(campaignMembers);	
		Configuration.disableTriggerCRUDSecurity();
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new CampaignMembers(sObjectList);
		}
	}

	public override void onBeforeInsert()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(CampaignMember cm : (CampaignMember[]) Records) 
    	{
    		this.createCampaignInfluence(cm);
    	}

    	if(createCI != null && 
    		!createCI.isEmpty()) SRUtilities.scheduleAsync(createCI, 'Create_CI', uow);

        uow.commitWork();
	}

	public void createCampaignInfluence(CampaignMember cm)
	{
		if(SR_Default_Values__c.getInstance('noCiCampaignIds').Value__c.contains(cm.CampaignId)) return;
		if(cm.ContactId == null) return;
		if(createCI == null) createCI = new Set<String>();
		createCI.add(cm.ContactId + '::' + cm.CampaignId + ':' + UserInfo.getUserId());
	}
}