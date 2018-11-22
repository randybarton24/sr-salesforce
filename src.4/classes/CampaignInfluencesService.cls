public class CampaignInfluencesService 
{
	public static void createCIs(Map<Id, Id> contactIdToCampaignId, Map<Id, Id> contactIdToUserId, AsyncRequest__c ar, fflib_SObjectUnitOfWork uow)
	{
		Contact[] contacts = ContactsSelector.newInstance().selectByIdWithAccount(contactIdToCampaignId.keySet());

		for(Contact contact : contacts)
		{
			uow.registerNew(createCI(contactIdToCampaignId.get(contact.Id), contact.Id, contact.AccountId, contact.Account.Active_Opportunity__c, contactIdToUserId.get(contact.Id), ar.CreatedDate));
			if(contact.CampaignId__c != null) 
			{
				contact.CampaignId__c = null;
				uow.registerDirty(contact);
			}
		}
	}

	public static void createCIsFromOpps(Map<Id, Id> oppIdToCampaignId, Map<Id, Id> oppIdToUserId, AsyncRequest__c ar, fflib_SObjectUnitOfWork uow)
	{
		Opportunity[] opportunities = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(oppIdToCampaignId.keySet());

		for(Opportunity opportunity : opportunities)
		{
			if(opportunity.IsClosed) continue;
			if(opportunity.Account.ParentId != null) continue;
			uow.registerNew(createCI(oppIdToCampaignId.get(opportunity.Id), null, opportunity.AccountId, opportunity.Id, oppIdToUserId.get(opportunity.Id), ar.CreatedDate));
		}
	}

	public static Campaign_Influence__c createCI(Id campaignId, Id contactId, Id accountId, Id opportunityId, Id userId, Datetime addDate)
	{
		return new Campaign_Influence__c(Campaign__c = campaignId,
			Contact__c = contactId,
			Account__c = accountId,
			Opportunity__c = opportunityId,
			Source_User__c = userId,
			Campaign_Add_Date__c = addDate);
	}

	public static void linkOppOnCIs(Set<Id> ids, fflib_SObjectUnitOfWork uow)
	{
		Campaign_Influence__c[] cis = CampaignInfluencesSelector.newInstance().selectCisByAccountId(ids);
		Integer opportunityCiLookback = Integer.valueOf(SR_Default_Values__c.getValues('opportunityCiLookback').Value__c);

		for(Campaign_Influence__c ci : cis)
		{
			if(ci.Opportunity__c != null) continue;
			if(ci.Account__r.Active_Opportunity__c == null) continue;
			if(opportunityCiLookback != null && 
				ci.Campaign_Add_Date__c < ci.Account__r.Active_Opportunity__r.CreatedDate.addDays(-opportunityCiLookback)) continue;
			
			ci.Opportunity__c = ci.Account__r.Active_Opportunity__c;
			uow.registerDirty(ci);
		}
	}

	public static void setDemoRequestReason(Opportunity[] opps, fflib_SObjectUnitOfWork uow)
	{
		for(Opportunity o : opps)
		{
			if(o.Campaign_Influence__r.size() == 0) continue;
			Campaign_Influence__c demoRequestReason = null;
			Map<Datetime, Campaign_Influence__c> dateMap = new Map<Datetime, Campaign_Influence__c>();
			Datetime[] sortedCampaignAddDates = new List<Datetime>();

			for(Campaign_Influence__c ci : o.Campaign_Influence__r)
			{
				if(ci.Demo_Request_Reason__c)
				{
					ci.Demo_Request_Reason__c = false;
					uow.registerDirty(ci);
				} 
				if(ci.Campaign__r.Sub_Type__c == 'Demo') dateMap.put(ci.Campaign_Add_Date__c, ci);
			}

			if(dateMap.isEmpty()) 
			{
				if(o.Demo_Request_Reason__c != null)
				{
					o.Demo_Request_Reason__c = null;
					uow.registerDirty(o);
				}
				continue;
			}
			
			sortedCampaignAddDates.addAll(dateMap.keySet());
			sortedCampaignAddDates.sort();

			demoRequestReason = dateMap.get(sortedCampaignAddDates[0]);
			demoRequestReason.Demo_Request_Reason__c = true;
			uow.registerDirty(demoRequestReason);

			if(o.Demo_Request_Reason__c == null || o.Demo_Request_Reason__c != demoRequestReason.Id)
			{
				o.Demo_Request_Reason__c = demoRequestReason.Id;
				uow.registerDirty(o);
			}
		}
	}

	public static void setDemoRequestReason(Set<Id> ids, fflib_SObjectUnitOfWork uow)
	{
		Map<Id, Opportunity> oppMap = OpportunitiesSelector.newInstance().selectByIdWithCIs(ids);
		setDemoRequestReason(oppMap.values(), uow);
	}
}