public class ProductsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Product2.Id,
			Product2.AppAdmin_API_Name__c,
			Product2.AppAdminProductKey__c, 
			Product2.Contract_Display_Name__c,
			Product2.Default_Contract_Term__c,
			Product2.Default_Co_Terminate__c,
			Product2.Default_Renewal_Rule__c,
			Product2.Family,
			Product2.IsEvergreen__c,
			Product2.Name,
	    	Product2.ProductCode, 
	    	Product2.RecurSoft__Billing_Frequency__c };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Product2.SObjectType;
	}

	public static ProductsSelector newInstance()
	{
		return (ProductsSelector) Application.Selector.newInstance(Product2.SObjectType);
	}

	public Product2[] selectByOpportunityLineItems(OpportunityLineItem[] opportunityLineItems)
	{
		Set<Id> ids = new Set<Id>();
		
		for(OpportunityLineItem oppLi : opportunityLineItems) 
		{	
			ids.add(oppLi.Product2Id);
		}

		fflib_QueryFactory productQueryFactory = newQueryFactory();

		return (Product2[]) Database.query(
			productQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}
}