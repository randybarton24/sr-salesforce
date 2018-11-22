@isTest
private class AccountsSelector_Test 
{	
	@isTest static void test_Selector() 
	{	
		Account acct = (Account) TestUtilities2.newAccount().toSObject();	
		Opportunity opp = (Opportunity) TestUtilities2.newOpportunity().toSObject();
		Contact contact = (Contact) TestUtilities2.newContact().toSObject();

		AccountsSelector selector = AccountsSelector.newInstance();
		selector.selectAccountByContactWithParentAccount(new List<Contact>{ contact });
		selector.selectParentAccountByAccount(new List<Account>{ acct });
		selector.selectByIdWithAssets(new Set<Id>{ acct.Id });
		selector.selectByIdWithContacts(new Set<Id>{ acct.Id });
		selector.selectByIdWithContactsAndOpportunities(new Set<Id>{ acct.Id });
		selector.selectByIdWithManagerAndVP(new Set<Id>{ acct.Id });
		selector.selectByIdWithDemoRequestReason(new Set<Id>{ acct.Id });
		selector.selectByBillToContact(new Set<Id>{ acct.Id });
		selector.selectAccountByOpportunityWithAssets(new List<Opportunity>{ opp });
		selector.selectByOpportunityWithCases(new List<Opportunity>{ opp });
	}
}