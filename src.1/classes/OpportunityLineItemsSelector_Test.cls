@isTest
private class OpportunityLineItemsSelector_Test 
{	
	@isTest static void test_beforeInsert() 
	{	
		OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem().toSObject();	
		RecurSoft__Product_Subscription__c subscription = (RecurSoft__Product_Subscription__c) TestUtilities2.newRecurSoftProductSubscription().toSObject();

		OpportunityLineItemsSelector selector = OpportunityLineItemsSelector.newInstance();
		selector.selectByIdWithAccountOpportunityProductPricebookEntry(new Set<Id>{ oppLi.Id });
		selector.selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(new Set<Id>{ oppLi.Id });
		selector.getAccountIdToSRContractEndDateMap(new List<OpportunityLineItem>{ oppLi });
		selector.selectByProductSubscriptions(new List<RecurSoft__Product_Subscription__c>{ subscription });
	}
}