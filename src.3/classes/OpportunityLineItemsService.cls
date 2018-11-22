public class OpportunityLineItemsService 
{
    public static void resetApprovals(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
         
        OpportunityLineItem[] oppLis = OpportunityLineItemsSelector.newInstance().selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(ids);
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(oppLis);
        
        for(OpportunityLineItem oppLi : oppLis)
        {
            oppLi.Approved_Free_Months__c = 0;
            oppLi.Approved_Price_Discount__c = 0;
            oppLi.Approved_Trial__c = 0;
            opportunityLineItems.updateApprovalLevelRequired(oppLi, null);
            uow.registerDirty(oppLi);
        }   
    }

    public static void setApprovals(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        OpportunityLineItem[] oppLis = OpportunityLineItemsSelector.newInstance().selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(ids);

        for(OpportunityLineItem oppLi : oppLis)
        {
            oppLi.Approved_Free_Months__c = oppLi.Number_of_Free_Months__c;
            oppLi.Approved_Price_Discount__c = oppLi.PricebookEntry.UnitPrice == 0 ? 0 : (((oppLi.PricebookEntry.UnitPrice - oppLi.UnitPrice) / oppLi.PricebookEntry.UnitPrice) + 0.00001) * 100;
            oppLi.Approved_Trial__c = oppLi.Trial__c == null ? 0 : Decimal.valueOf(oppLi.Trial__c);
            oppLi.Last_Approved_Date__c = Datetime.now();
            uow.registerDirty(oppLi);
        }   
    }

    public static void updateProductTermsRollup(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        OpportunityLineItem[] oppLis = OpportunityLineItemsSelector.newInstance().selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(ids);
        Map<Id, String> opportunityIdToProductTermsMap;

        for(OpportunityLineItem oppLi : oppLis)
        {
            if(opportunityIdToProductTermsMap == null) opportunityIdToProductTermsMap = new Map<Id, String>();
            String productTerms = opportunityIdToProductTermsMap.containsKey(oppLi.OpportunityId) ? 
                opportunityIdToProductTermsMap.get(oppLi.OpportunityId) + '\n\n' + oppLi.Product_Terms__c : oppLi.Product_Terms__c;
            opportunityIdToProductTermsMap.put(oppLi.OpportunityId, productTerms);
        }
        
        for(Id i : opportunityIdToProductTermsMap.keySet())
        {
            Opportunity o = new Opportunity(Id = i, Product_Terms__c = opportunityIdToProductTermsMap.get(i).replaceAll('<br>', '\n'));
            uow.registerDirty(o);
        }
    }


    @future
	public static void setModifiedSubscription(Set<Id> ids) 
	{
		Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(ids);
		Map<String, Id> currentSubscriptionMap;// = AssetsSelector.newInstance().selectCurrentSubscriptionsByOpportunityLineItems(opps);
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Opportunity o : opps) 
        {
            if(!o.HasOpportunityLineItem) continue;
            if(o.StageName == 'Closed Won') continue;
            if(o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId()) continue;

            for(OpportunityLineItem oppLi : o.OpportunityLineItems) 
            {
            	if(oppLi.Override_Modified_Subscription__c) continue;
				
				if(currentSubscriptionMap.containsKey(oppLi.Opportunity.AccountId + oppLi.Product2.Family + oppLi.Provider__c)
					&& oppLi.Modified_Subscription__c != currentSubscriptionMap.get(oppLi.Opportunity.AccountId + oppLi.Product2.Family + oppLi.Provider__c)) 
				{
					oppLi.Modified_Subscription__c = currentSubscriptionMap.get(oppLi.Opportunity.AccountId + oppLi.Product2.Family + oppLi.Provider__c);
					uow.registerDirty(oppLi);
				}

				if(currentSubscriptionMap.containsKey(oppLi.Opportunity.AccountId)
					&& oppLi.Current_SR_Subscription__c != currentSubscriptionMap.get(oppLi.Opportunity.AccountId)) 
				{
					oppLi.Current_SR_Subscription__c = currentSubscriptionMap.get(oppLi.Opportunity.AccountId);
					uow.registerDirty(oppLi);
				}
			}
		}
		uow.commitWork();
	}

	@future
    public static void setProductApprovals(Set<Id> ids)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(ids);
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Opportunity o : opps) 
        {
            if(!o.HasOpportunityLineItem) continue;

            for(OpportunityLineItem oppLi : o.OpportunityLineItems) 
            {
                oppLi.Approved_Free_Months__c = oppLi.Number_of_Free_Months__c;
                oppLi.Approved_Price_Discount__c = oppLi.PricebookEntry.UnitPrice == 0 ? 0 : (((oppLi.PricebookEntry.UnitPrice - oppLi.UnitPrice) / oppLi.PricebookEntry.UnitPrice) + 0.00001) * 100;
                oppLi.Approved_Term__c = o.RecurSoft__Initial_Contract_Term__c;
                oppLi.Approved_Trial__c = oppLi.Trial__c == null ? 0 : Decimal.valueOf(oppLi.Trial__c);
                oppLi.Last_Approved_Date__c = Datetime.now();
                uow.registerDirty(oppLi);
            }
        }
        uow.commitWork();
    }
}