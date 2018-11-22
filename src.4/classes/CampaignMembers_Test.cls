@isTest
private class CampaignMembers_Test 
{
	@testSetup static void testData() 
    {
        TestUtilities.insertCustomSettings();
    }

    @isTest static void test_beforeInsert() 
	{		
		Campaign camp1 = (Campaign) TestUtilities2.newCampaign()					
			.toSObject();
		CampaignMember cm1 = (CampaignMember) TestUtilities2.newCampaignMember()
			.setField(CampaignMember.CampaignId, camp1.Id)
			.toSObject();
		
		CampaignMembers campMember = new CampaignMembers(new List<CampaignMember>{ cm1 });
		campMember.onBeforeInsert();
	}

	@isTest static void test_createCampaignInfluence1() 
	{			
		Campaign camp1 = (Campaign) TestUtilities2.newCampaign()					
			.toSObject();
		CampaignMember cm1 = (CampaignMember) TestUtilities2.newCampaignMember()
			.setField(CampaignMember.CampaignId, camp1.Id)
			.toSObject();
		
		CampaignMembers campMember = new CampaignMembers(new List<CampaignMember>{ cm1 });
		
		campMember.createCampaignInfluence(cm1);		
		
		System.assertEquals(null, campMember.createCI);
	}

	@isTest static void test_createCampaignInfluence2() 
	{		
		Contact c1 = (Contact) TestUtilities2.newContact()					
			.toSObject();
		Campaign camp1 = (Campaign) TestUtilities2.newCampaign()					
			.toSObject();
		CampaignMember cm1 = (CampaignMember) TestUtilities2.newCampaignMember()
			.setField(CampaignMember.ContactId, c1.Id)
			.setField(CampaignMember.CampaignId, camp1.Id)
			.toSObject();	
		
		CampaignMembers campMember = new CampaignMembers(new List<CampaignMember>{ cm1 });		
		campMember.createCampaignInfluence(cm1);		
				
		System.assertEquals(1, campMember.createCI.size());
		System.assert(campMember.createCI.contains(cm1.ContactId + '::' + cm1.CampaignId + ':' + UserInfo.getUserId()));
	}
}