public class PaymentRecordsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			RecurSoft__Payment_Record__c.Id,
			RecurSoft__Payment_Record__c.RecurSoft__Card_Type__c,
			RecurSoft__Payment_Record__c.RecurSoft__Expiration_Month__c,
			RecurSoft__Payment_Record__c.RecurSoft__Expiration_Year__c,
			RecurSoft__Payment_Record__c.RecurSoft__Last_4_Text__c,
			RecurSoft__Payment_Record__c.RecurSoft__Name_On_Card__c
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return RecurSoft__Payment_Record__c.SObjectType;
	}

	public static PaymentRecordsSelector newInstance()
	{
		return (PaymentRecordsSelector) Application.Selector.newInstance(RecurSoft__Payment_Record__c.SObjectType);
	}
}