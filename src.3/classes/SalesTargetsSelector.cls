public class SalesTargetsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Sales_Target__c.Id,
			Sales_Target__c.Comp_Plan__c,
			Sales_Target__c.Multiplier__c,
			Sales_Target__c.Revenue_of_Target__c,
			Sales_Target__c.Sales_Rep_Revenue_Credit__c,
			Sales_Target__c.Sales_Rep_Tier_Qualify_Sales_Credit__c,
			Sales_Target__c.Commission_Qualified_Sales__c,
			Sales_Target__c.Available_Commission__c
			 };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Sales_Target__c.SObjectType;
	}

	public static SalesTargetsSelector newInstance()
	{
		return (SalesTargetsSelector) Application.Selector.newInstance(Sales_Target__c.SObjectType);
	}
}