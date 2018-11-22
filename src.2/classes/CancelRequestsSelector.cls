public class CancelRequestsSelector extends fflib_SObjectSelector 
{	
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Cancel_Request__c.Id,
            Cancel_Request__c.Cancel_Month__c,
            Cancel_Request__c.Stage__c,
            Cancel_Request__c.Opportunity__c,
            Cancel_Request__c.RecordTypeId 
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Cancel_Request__c.SObjectType;
	}

	public static CancelRequestsSelector newInstance()
	{
		return (CancelRequestsSelector) Application.Selector.newInstance(Cancel_Request__c.SObjectType);
	}
	
	public Database.QueryLocator queryLocatorCancelledAccounts()
	{
		//String conditionTest = 'Id IN (\'0010Z00001sr1Wy\',\'0010Z00001sr3om\',\'0010Z00001srAIJ\',\'0010Z00001srAvX\' 
		//,\'0010Z00001srM4H\',\'0010Z00001srWw3\',\'0010Z00001srbea\',\'0010Z00001srcZa\',\'0010Z00001srdvY\',\'0010Z00001srfLG\')';
		String condition = 'Stage__c = \'Cancelled\' AND ' +
            'Opportunity__r.Account.RecurSoft__Status__c = \'Active\' AND ' +
            'RecordType.Name = \'SR Platform\' AND ' +
            '(Cancel_Month__c = LAST_N_Months:2 OR Cancel_Month__c = This_Month)';
        
		fflib_QueryFactory cancelRequestQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(cancelRequestQueryFactory, 'Opportunity__r.Account');
		
		new ProductSubscriptionsSelector().configureQueryFactoryFields(cancelRequestQueryFactory, 'Asset__r.Current_Product_Subscription__r');
		
		return Database.getQueryLocator(
			cancelRequestQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).
				setCondition(condition).
				toSOQL());
	}
}