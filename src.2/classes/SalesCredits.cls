public class SalesCredits extends fflib_SObjectDomain 
{
	public SalesCredits(Sales_Credit__c[] salesCredits) 
	{
		super(salesCredits);
		Configuration.disableTriggerCRUDSecurity();
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new SalesCredits(sObjectList);
		}
	}

	public override void onBeforeInsert()
	{
		SalesCreditsService.assignSalesCreditToSalesTarget((Sales_Credit__c[]) Records);
	}

	public override void onAfterInsert()
	{
		SalesCreditsService.createBonusCommissionCredit((Sales_Credit__c[]) Records);
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		SalesCreditsService.assignSalesCreditToSalesTarget((Sales_Credit__c[]) Records);
	}
}