public class RevenueSchedulesSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			RecurSoft__Revenue_Schedule__c.Id,
			RecurSoft__Revenue_Schedule__c.CreatedDate,
			RecurSoft__Revenue_Schedule__c.RecurSoft__Accrued_Revenue_Amount__c, 
			RecurSoft__Revenue_Schedule__c.RecurSoft__Date__c,
    		RecurSoft__Revenue_Schedule__c.RecurSoft__Expected_Invoice_Amount__c, 
    		RecurSoft__Revenue_Schedule__c.RecurSoft__Period_Number__c,
    		RecurSoft__Revenue_Schedule__c.RecurSoft__Revenue_Entry_Status__c
			 };
	}

	public override String getOrderBy()
	{
		return 'CreatedDate ASC, RecurSoft__Date__c ASC';
	}

	public Schema.SObjectType getSObjectType()
	{
		return RecurSoft__Revenue_Schedule__c.SObjectType;
	}

	public static RevenueSchedulesSelector newInstance()
	{
		return (RevenueSchedulesSelector) Application.Selector.newInstance(RecurSoft__Revenue_Schedule__c.SObjectType);
	}
}