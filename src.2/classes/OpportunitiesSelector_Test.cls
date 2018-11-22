@isTest
private class OpportunitiesSelector_Test 
{	
	@isTest static void test_Selector() 
	{	
		Account acct = (Account) TestUtilities2.newAccount().toSObject();	
		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity().toSObject();
		OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem().toSObject();
		Task task = (Task) TestUtilities2.newTask().toSObject();

		OpportunitiesSelector selector = OpportunitiesSelector.newInstance();
		selector.selectByIdWithAccountAndProducts(new Set<Id>{ opp.Id });
		selector.selectByIdWithManagerAndVP(new Set<Id>{ opp.Id });
		selector.selectByIdWithAccountsContactsAndProducts(new Set<Id>{ opp.Id });
		selector.selectByIdWithAddenda(new Set<Id>{ opp.Id });
		selector.selectByTaskList(new List<Task>{ task });
		selector.selectByOpportunityLineItemsWithProducts(new List<OpportunityLineItem>{ oppLi });
		selector.selectActiveOpportunitiessByAccountId(new Set<Id>{ acct.Id });
		selector.selectByIdWithCIs(new Set<Id>{ opp.Id });
	}
}