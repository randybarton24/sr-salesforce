@isTest
private class CampaignInfluences_Test 
{	
	@isTest static void test_setDemoRequestReason1() 
	{					
		Opportunity op1 = (Opportunity) TestUtilities2.newOpportunity()
			.toSObject();
		Campaign_Influence__c ci1 = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence()
			.setField(Campaign_Influence__c.Opportunity__c, op1.Id)
            .toSObject();		
		CampaignInfluences campInfluence = new CampaignInfluences(new List<Campaign_Influence__c>{ ci1 });
		campInfluence.setDemoRequestReason(ci1, null);		
				
		System.assertEquals(1, campInfluence.setDemoRequestReason.size());
		System.assert(campInfluence.setDemoRequestReason.contains(op1.Id));
	}

	@isTest static void test_setDemoRequestReason2() 
	{					
		Opportunity op1 = (Opportunity) TestUtilities2.newOpportunity().toSObject();
		Opportunity op2 = (Opportunity) TestUtilities2.newOpportunity().toSObject();
		Campaign_Influence__c ci1 = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence()
			.setField(Campaign_Influence__c.Opportunity__c, op1.Id).toSObject();	
		Campaign_Influence__c existingCampaignInfluence = (Campaign_Influence__c) TestUtilities2.existingCampaignInfluence(ci1)
			.setField(Campaign_Influence__c.Opportunity__c, op2.Id).toSObject();		
		CampaignInfluences campInfluence = new CampaignInfluences(new List<Campaign_Influence__c>{ ci1 });		
		campInfluence.setDemoRequestReason(ci1, existingCampaignInfluence);		
		
		System.assertEquals(1, campInfluence.setDemoRequestReason.size());
		System.assert(campInfluence.setDemoRequestReason.contains(op1.Id));
	}
	
	@isTest static void test_processStampUpdates1() 
	{					
		User user1 = (User) TestUtilities2.newUser()
            .toSObject();
		Campaign_Influence__c ci1 = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence()                   
            .setField(Campaign_Influence__c.Source_User__c, user1.Id)
            .toSObject();
        Stamp_Field_Mapping__c stamp1 = (Stamp_Field_Mapping__c) new sfab_FabricatedSObject(Stamp_Field_Mapping__c.class)
            .setField(Stamp_Field_Mapping__c.Id, fflib_IDGenerator.generate(Stamp_Field_Mapping__c.SObjectType))
            .setField(Stamp_Field_Mapping__c.Field_Changed__c, 'Source_User__c')
            .setField(Stamp_Field_Mapping__c.Stamp_To_Object__c, 'Campaign_Influence__c')
            .setField(Stamp_Field_Mapping__c.Active__c, true)                    
            .toSObject();            
		
		CampaignInfluences campInfluence = new CampaignInfluences(new List<Campaign_Influence__c>{ ci1 });	
		campInfluence.stampMappings = new List<Stamp_Field_Mapping__c>{ stamp1 };
		campInfluence.processStampUpdates(ci1, null);		
		
		System.assertEquals(1, campInfluence.stampUpdates.size());
		System.assert(campInfluence.stampUpdates.contains(ci1.Id + '::' + stamp1.Id));
	}

	@isTest static void test_processStampUpdates2() 
	{					
		User user1 = (User) TestUtilities2.newUser()
            .toSObject();
        User user2 = (User) TestUtilities2.newUser()
            .toSObject();
		Campaign_Influence__c ci1 = (Campaign_Influence__c) TestUtilities2.newCampaignInfluence()                   
            .setField(Campaign_Influence__c.Source_User__c, user1.Id)
            .toSObject();
        Campaign_Influence__c existingCampaignInfluence = (Campaign_Influence__c) TestUtilities2.existingCampaignInfluence(ci1)                   
            .setField(Campaign_Influence__c.Source_User__c, user2.Id)
            .toSObject();
        Stamp_Field_Mapping__c stamp1 = (Stamp_Field_Mapping__c) new sfab_FabricatedSObject(Stamp_Field_Mapping__c.class)
            .setField(Stamp_Field_Mapping__c.Id, fflib_IDGenerator.generate(Stamp_Field_Mapping__c.SObjectType))
            .setField(Stamp_Field_Mapping__c.Field_Changed__c, 'Source_User__c')
            .setField(Stamp_Field_Mapping__c.Stamp_To_Object__c, 'Campaign_Influence__c')
            .setField(Stamp_Field_Mapping__c.Active__c, true)                    
            .toSObject();            
		
		CampaignInfluences campInfluence = new CampaignInfluences(new List<Campaign_Influence__c>{ ci1 });	
		campInfluence.stampMappings = new List<Stamp_Field_Mapping__c>{ stamp1 };
		campInfluence.processStampUpdates(ci1, existingCampaignInfluence);		
		
		System.assertEquals(1, campInfluence.stampUpdates.size());
		System.assert(campInfluence.stampUpdates.contains(ci1.Id + '::' + stamp1.Id));
	}
}