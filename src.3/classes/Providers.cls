public class Providers extends fflib_SObjectDomain 
{
	public Providers(Provider__c[] providers) 
	{
		super(providers);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Providers(sObjectList);
		}
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Map<Id, Provider__c> providersMap = new Map<Id, Provider__c>(ProvidersSelector.newInstance().selectByIdWithCases(existingRecords.keySet()));

		for(Provider__c p : (Provider__c[]) Records)
		{
			p.Specialties__c = ProvidersService.getSpecialties(p);
			p.Conditions__c = ProvidersService.getConditions(p);
			p.Procedures__c = ProvidersService.getProcedures(p);

			for(Case c : providersMap.get(p.Id).Cases__r)
			{
				c.HG_Specialties__c = p.Specialties__c;
				c.HG_Conditions__c = p.Conditions__c;
				c.HG_Procedures__c = p.Procedures__c;
			}

			uow.registerDirty(providersMap.get(p.Id).Cases__r);
		}

		uow.commitWork();
	}
}