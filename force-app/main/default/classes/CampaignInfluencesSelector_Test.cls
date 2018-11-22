@isTest
private class CampaignInfluencesSelector_Test 
{	
	@isTest static void test_Selector() 
	{	
		Account acct = (Account) TestUtilities2.newAccount().toSObject();	
		Campaign_Influence__c ci = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence().toSObject();

		CampaignInfluencesSelector selector = CampaignInfluencesSelector.newInstance();
		selector.selectCisByCreatedById(new Set<Id>{ ci.Id });
		selector.selectByIdWithManagerAndVP(new Set<Id>{ ci.Id });
		selector.selectCisByAccountId(new Set<Id>{ acct.Id });
		selector.queryLocatorContactCIWithoutAccount();
	}
}