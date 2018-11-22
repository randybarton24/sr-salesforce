/*
Approvals
 - Need to rollup the MAX Approval Level Required to the Opp
 - Need to recalculate and rollup the MAX Approval Level Required if approval-related terms change
 - Need to set the Approved Values and rollup the MAX Approval Level Required to the Opp(should be 0) when approval is received
 - Need to reset any approvals that were received when the Opp owner changes

Contract Terms
 - Need to set contract start/end dates and term length before going closed won for prod subs creation
 - Need to calculate and set contract term for Add Product opps to end in the same month as SR subscription

*/
public class OpportunityLineItems extends fflib_SObjectDomain 
{
	public Map<Id, OpportunityLineItem> withRelatedObjects;
	public Map<Id, Product2> productMap;
	public static Map<String, Id> currentSubscriptionMap;
	public Map<Id, Date> accountIdToSRContractEndDateMap;
	public Map<Id, Date> opportunityIdToContractEndDateMap;
	public Set<Id> updateAllOppLisOnOpp;
	public Set<Id> productTermsRollup;
	public Set<Id> updateAllOpplisOnOppContractDates;
	public Set<Id> updateAllOpplisOnOppModifiedSubscriptions;
	public static Map<String, String> productFamilyToRevenueFieldMap = new Map<String, String>{
			'SR Platform' => 'SR_Monthly_Revenue__c',
			'SR Conversations' => 'SRC_Monthly_Revenue__c',
			'SR Smart Reviews' => 'SRSR_Monthly_Revenue__c',
			'SR Schedule' => 'LL_Monthly_Revenue__c',
			'Healthgrades' => 'HG_Monthly_Revenue__c'
		};
	public Set<Id> resetApoprovals;

	public OpportunityLineItems(OpportunityLineItem[] opportunityLineItems) 
	{
		super(opportunityLineItems);
		Configuration.disableTriggerCRUDSecurity();
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new OpportunityLineItems(sObjectList);
		}
	}

	public override void onBeforeInsert()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(OpportunityLineItem oppLi : (OpportunityLineItem[]) Records) 
    	{
			this.setDefaultsFromProduct(oppLi);
			this.setMonthlyRevenue(oppLi, null);
			this.updateApprovalLevelRequired(oppLi, null);
			this.checkForProductTermsRollupUpdateNeeded(oppLi, null);
    	}

    	if(productTermsRollup != null && 
            !productTermsRollup.isEmpty()) SRUtilities.scheduleAsync(productTermsRollup, 'Product_Terms_Rollup', uow);

        uow.commitWork();
	}

	public override void onAfterInsert()
	{
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(OpportunityLineItem oppLi : (OpportunityLineItem[]) Records) 
    	{
    		this.validateProductFamily(oppLi);
			this.checkForContractDatesUpdateNeeded(oppLi, null);
    	}

    	if(updateAllOppLisOnOpp != null &&
            updateAllOppLisOnOpp.size() > 0) this.updateAllOppLisOnOpp(updateAllOppLisOnOpp, uow);

        uow.commitWork();
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(OpportunityLineItem oppLi : (OpportunityLineItem[]) Records) 
    	{
    		OpportunityLineItem existingOppLi = (OpportunityLineItem) existingRecords.get(oppLi.Id);
			this.setMonthlyRevenue(oppLi, existingOppLi);
			this.updateApprovalLevelRequired(oppLi, existingOppLi);
			this.checkForProductTermsRollupUpdateNeeded(oppLi, existingOppLi);
			this.checkApprovalReset(oppLi, existingOppLi);
    	}

    	if(productTermsRollup != null && 
            !productTermsRollup.isEmpty()) SRUtilities.scheduleAsync(productTermsRollup, 'Product_Terms_Rollup', uow);

    	if(updateAllOppLisOnOpp != null &&
            updateAllOppLisOnOpp.size() > 0) this.updateAllOppLisOnOpp(updateAllOppLisOnOpp, uow);

		if(resetApoprovals != null &&
				resetApoprovals.size() > 0) SRUtilities.scheduleAsync(resetApoprovals, 'Reset_Approvals', uow);

        uow.commitWork();
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
		for(OpportunityLineItem oppLi : (OpportunityLineItem[]) Records) 
    	{
    		OpportunityLineItem existingOppLi = (OpportunityLineItem) existingRecords.get(oppLi.Id);
    		this.checkForContractDatesUpdateNeeded(oppLi, existingOppLi);
    	}

    	if(updateAllOppLisOnOpp != null &&
            updateAllOppLisOnOpp.size() > 0) this.updateAllOppLisOnOpp(updateAllOppLisOnOpp, uow);

        uow.commitWork();
	}
	
	public void checkForProductTermsRollupUpdateNeeded(OpportunityLineItem oppLi, OpportunityLineItem existingOppLi)
    {
    	if(existingOppLi != null && 
			existingOppLi.UnitPrice == oppLi.UnitPrice &&
			existingOppLi.Number_of_Free_Months__c == oppLi.Number_of_Free_Months__c &&
			existingOppLi.Trial__c == oppLi.Trial__c) return;

		if(productTermsRollup == null) productTermsRollup = new Set<Id>();
        productTermsRollup.add(oppLi.OpportunityId);
    }

	public void checkForContractDatesUpdateNeeded(OpportunityLineItem oppLi, OpportunityLineItem existingOppLi)
    {
		if(existingOppLi != null && 
			existingOppLi.Number_of_Free_Months__c == oppLi.Number_of_Free_Months__c &&
			existingOppLi.Free_Month_Setting__c == oppLi.Free_Month_Setting__c &&
			existingOppLi.RecurSoft__Contract_Term_Start_Date_New__c == oppLi.RecurSoft__Contract_Term_Start_Date_New__c) return;

        if(updateAllOppLisOnOpp == null) updateAllOppLisOnOpp = new Set<Id>();
        updateAllOppLisOnOpp.add(oppLi.OpportunityId);

		if(updateAllOpplisOnOppContractDates == null) updateAllOpplisOnOppContractDates = new Set<Id>();
        updateAllOpplisOnOppContractDates.add(oppLi.OpportunityId);
    }

	public void setDefaultsFromProduct(OpportunityLineItem oppLi)
	{
		if(productMap == null) productMap = new Map<Id, Product2>(ProductsSelector.newInstance().selectByOpportunityLineItems((OpportunityLineItem[]) Records));
        Product2 product = productMap.get(oppLi.Product2Id);

		oppLi.Is_Monthly__c = product.RecurSoft__Billing_Frequency__c == 'Monthly' ? true : false;
		oppLi.Product_Code_Formula__c = product.ProductCode;
		if(product.Family != null && product.Family != 'Healthgrades') oppLi.Product_Family_Duplicate__c = product.Family == 'Professional Services' ? oppLi.OpportunityId + product.Family + product.Contract_Display_Name__c : oppLi.OpportunityId + product.Family;
		oppLi.Co_Terminate__c = product.Default_Co_Terminate__c;
		oppLi.Free_Month_Setting__c = oppLi.Number_of_Free_Months__c == null || oppLi.Number_of_Free_Months__c == 0 ? null : oppLi.Free_Month_Setting__c;
		oppLi.RecurSoft__Contract_Term_Setting__c = 'Months';
		if(oppLi.RecurSoft__Renewal_Rule__c == null) oppLi.RecurSoft__Renewal_Rule__c = product.Default_Renewal_Rule__c;
	}

	//Called by updateAllOppLisOnOpp()
	public void setModifiedSubscriptions(OpportunityLineItem[] oppLis, fflib_SObjectUnitOfWork uow)
	{
		for(OpportunityLineItem oppLi : oppLis)
		{
			if(!updateAllOpplisOnOppModifiedSubscriptions.contains(oppLi.OpportunityId)) continue;
			setModifiedSubscriptions(oppLi, 'Modified_Subscription__c', uow);
			setModifiedSubscriptions(oppLi, 'Current_SR_Subscription__c', uow);
		}	
	}

	//Called by setModifiedSubscriptions()
	public void setModifiedSubscriptions(OpportunityLineItem oppLi, String fieldName, fflib_SObjectUnitOfWork uow) 
	{
		if((Boolean) oppLi.get('Override_' + fieldName)) return;
		if(oppLi.Opportunity.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId() &&
			oppLi.Opportunity.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Retention').getRecordTypeId()) return;
		
		if(currentSubscriptionMap == null) currentSubscriptionMap = AssetsSelector.newInstance().selectCurrentSubscriptionsByOpportunityLineItems((OpportunityLineItem[]) Records);
		String productName = fieldName == 'Current_SR_Subscription__c' ? 'SR Platform' : oppLi.Product2.Family;

		if(!currentSubscriptionMap.containsKey(oppLi.Opportunity.AccountId + productName + oppLi.Provider__c)) return;
		if(oppLi.get(fieldName) == currentSubscriptionMap.get(oppLi.Opportunity.AccountId + productName + oppLi.Provider__c)) return;

		oppLi.put(fieldName, currentSubscriptionMap.get(oppLi.Opportunity.AccountId + productName + oppLi.Provider__c));
		uow.registerDirty(oppLi);
	}

	public void setMonthlyRevenue(OpportunityLineItem oppLi, OpportunityLineItem existingOppLi)
	{
		if(existingOppLi != null && 
			existingOppLi.UnitPrice == oppLi.UnitPrice &&
			existingOppLi.Quantity == oppLi.Quantity &&
			existingOppLi.Invoiced_Price__c == oppLi.Invoiced_Price__c) return;

		if(productMap == null) productMap = new Map<Id, Product2>(ProductsSelector.newInstance().selectByOpportunityLineItems((OpportunityLineItem[]) Records));
        Product2 product = productMap.get(oppLi.Product2Id);

		if(product.RecurSoft__Billing_Frequency__c != 'Monthly') return;

		Decimal productPrice = oppLi.Invoiced_Price__c != null && 
			oppLi.Invoiced_Price__c > 0 ? 
			oppLi.Invoiced_Price__c * oppLi.Quantity : oppLi.UnitPrice == null ? 0 : oppLi.UnitPrice * oppLi.Quantity;
		oppLi.Total_Monthly_Revenue__c = productPrice;

		if(productFamilyToRevenueFieldMap.containsKey(product.Family))
		{
			oppLi.put(productFamilyToRevenueFieldMap.get(product.Family), productPrice);
			return;
		}
		else
		{
			oppLi.Other_Monthly_Revenue__c = productPrice;
		}
	}

	public void updateAllOppLisOnOpp(Set<Id> ids, fflib_SObjectUnitOfWork uow)
	{
		OpportunityLineItem[] oppLis = OpportunityLineItemsSelector.newInstance().selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(ids);
		this.updateAllOppLisOnOpp(oppLis, uow);
	}

	//Called by updateAllOppLisOnOpp()
	public void updateAllOppLisOnOpp(OpportunityLineItem[] oppLis, fflib_SObjectUnitOfWork uow)
	{
		if(updateAllOpplisOnOppContractDates != null && !updateAllOpplisOnOppContractDates.isEmpty()) this.updateContractDates(oppLis, uow);
		if(updateAllOpplisOnOppModifiedSubscriptions != null && !updateAllOpplisOnOppModifiedSubscriptions.isEmpty()) this.setModifiedSubscriptions(oppLis, uow);
	}

	public void updateApprovalLevelRequired(OpportunityLineItem oppLi, OpportunityLineItem existingOppLi)
	{
		if(existingOppLi != null && 
			existingOppLi.UnitPrice == oppLi.UnitPrice &&
			existingOppLi.Number_of_Free_Months__c == oppLi.Number_of_Free_Months__c &&
			existingOppLi.Trial__c == oppLi.Trial__c &&
			existingOppLi.Approved_Price_Discount__c == oppLi.Approved_Price_Discount__c &&
			existingOppLi.Approved_Free_Months__c == oppLi.Approved_Free_Months__c &&
			existingOppLi.Approved_Trial__c == oppLi.Approved_Trial__c) return;

		oppLi.Approval_Level_Required__c = Math.max(Math.max(oppLi.Approval_Level_Required_Price_Discount__c,
			oppLi.Approval_Level_Required_Free_Months__c),
			oppLi.Approval_Level_Required_Trial__c);
	}
	
	//Called by updateAllOppLisOnOpp()
	public void updateContractDates(OpportunityLineItem[] oppLis, fflib_SObjectUnitOfWork uow)
	{
		for(OpportunityLineItem oppLi : oppLis)
		{
			if(oppLi.Opportunity.IsClosed) continue;
			if(oppLi.Opportunity.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product') &&
            	oppLi.Opportunity.RecurSoft__Contract_Signed_Date__c == null) continue;
			if(!updateAllOpplisOnOppContractDates.contains(oppLi.OpportunityId)) continue;
			this.setContractStartDate(oppLi);
			this.setContractEndDate(oppLi);
		}

		for(OpportunityLineItem oppLi : oppLis)
		{
			if(oppLi.Opportunity.IsClosed) continue;
			if(oppLi.Opportunity.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product') &&
            	oppLi.Opportunity.RecurSoft__Contract_Signed_Date__c == null) continue;
			if(!updateAllOpplisOnOppContractDates.contains(oppLi.OpportunityId)) continue;

			if(oppLi.RecurSoft__Contract_Term_End_Date_Editable__c != opportunityIdToContractEndDateMap.get(oppLi.OpportunityId) &&
				oppLi.Product2.Default_Contract_Term__c != 1)
			{
				oppLi.RecurSoft__Contract_Term_End_Date_Editable__c = opportunityIdToContractEndDateMap.get(oppLi.OpportunityId);
			}
			oppLi.RecurSoft__Contract_Term1__c = String.valueOf(oppLi.RecurSoft__Contract_Term_Start_Date_New__c.monthsBetween(oppLi.RecurSoft__Contract_Term_End_Date_Editable__c));
			oppLi.RecurSoft__Contract_Term_Setting__c = 'Months';
			uow.registerDirty(oppLi);
		}
	}

	//Called by updateContractDates()
	public void setContractStartDate(OpportunityLineItem oppLi)
	{
        if(oppLi.Opportunity.RecordTypeId == SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId()) return;
		if(oppLi.Opportunity.RecordTypeId == SRUtilities.getRecordTypeMap('Opportunity').get('Renewal').getRecordTypeId()) return;
		
		Decimal offsetDays = oppLi.PricebookEntry.Pricebook2.Contract_Start_Date_Offset__c == null ? 0 : oppLi.PricebookEntry.Pricebook2.Contract_Start_Date_Offset__c;
		
		oppLi.RecurSoft__Contract_Term_Start_Date_New__c = oppLi.Opportunity.RecurSoft__Contract_Signed_Date__c == null ? 
			Date.today() : oppLi.Opportunity.RecurSoft__Contract_Signed_Date__c.addDays(Integer.valueOf(offsetDays)); 
	}

	//Called by updateContractDates()
	public void setContractEndDate(OpportunityLineItem oppLi)
	{
		if(oppLi.RecurSoft__Contract_Term_Start_Date_New__c == null) return;
        
		Integer contractTerm = getContractTerm(oppLi);
		
		oppLi.RecurSoft__Contract_Term_End_Date_Editable__c = oppLi.RecurSoft__Contract_Term_Start_Date_New__c.addMonths(contractTerm).addDays(-1);
			
		if(opportunityIdToContractEndDateMap == null) opportunityIdToContractEndDateMap = new Map<Id, Date>();
		if(!opportunityIdToContractEndDateMap.containsKey(oppLi.OpportunityId) ||
			opportunityIdToContractEndDateMap.get(oppLi.OpportunityId) < oppLi.RecurSoft__Contract_Term_End_Date_Editable__c) 
		{
			opportunityIdToContractEndDateMap.put(oppLi.OpportunityId, oppLi.RecurSoft__Contract_Term_End_Date_Editable__c);
		}
	}

	//Called from setContractEndDate()
	public Integer getContractTerm(OpportunityLineItem oppLi)
	{
		Integer contractTerm;
		Integer freeMonths = oppLi.Number_of_Free_Months__c == null ? 0 : Integer.valueOf(oppLi.Number_of_Free_Months__c);
		
		if(oppLi.Opportunity.RecordTypeId == SRUtilities.getRecordTypeMap('Opportunity').get('Add Product').getRecordTypeId() ||
			oppLi.Opportunity.RecordTypeId == SRUtilities.getRecordTypeMap('Opportunity').get('Healthgrades').getRecordTypeId())
		{
			if(accountIdToSRContractEndDateMap == null) accountIdToSRContractEndDateMap = OpportunityLineItemsSelector.newInstance().getAccountIdToSRContractEndDateMap((OpportunityLineItem[]) Records);
			if(accountIdToSRContractEndDateMap.containsKey(oppLi.Opportunity.AccountId)) 
			{
				Date endDate = accountIdToSRContractEndDateMap.get(oppLi.Opportunity.AccountId);
				Integer monthsLeft = oppLi.RecurSoft__Contract_Term_Start_Date_New__c.monthsBetween(endDate);
				contractTerm = oppLi.Product2.Default_Contract_Term__c == 1 ? 1 : monthsLeft > 0 ? monthsLeft : monthsLeft + 12;
			}
			else
			{
				throw new SRUtilities.SRException('This Account does not have a current SR Platform subscription, you cannot Add Products');
			}
		}
		else
		{
			contractTerm = oppLi.Product2.Default_Contract_Term__c == 1 ? 1 : Integer.valueOf(oppLi.Opportunity.RecurSoft__Initial_Contract_Term__c);
		}	

		if(contractTerm != null && oppLi.Free_Month_Setting__c == 'Extend Contract - At the Beginning') contractTerm = contractTerm + freeMonths;
		return contractTerm;
	}

	public void validateProductFamily(OpportunityLineItem oppLi)
	{
		if(withRelatedObjects == null) withRelatedObjects = new Map<Id, OpportunityLineItem>(OpportunityLineItemsSelector.newInstance().selectByIdWithAccountOpportunityProductPricebookEntry(new Map<Id, OpportunityLineItem>((OpportunityLineItem[]) Records).keySet()));
        OpportunityLineItem oppLiWithRelatedObjects = withRelatedObjects.get(oppLi.Id);

		if(oppLiWithRelatedObjects.Product2.Family == null) return;

		if(currentSubscriptionMap == null) currentSubscriptionMap = AssetsSelector.newInstance().selectCurrentSubscriptionsByOpportunityLineItems((OpportunityLineItem[]) Records);
		if(!currentSubscriptionMap.containsKey(oppLiWithRelatedObjects.Opportunity.AccountId + oppLiWithRelatedObjects.Product2.Family + oppLiWithRelatedObjects.Provider__c) ||
			currentSubscriptionMap.get(oppLiWithRelatedObjects.Opportunity.AccountId + oppLiWithRelatedObjects.Product2.Family + oppLiWithRelatedObjects.Provider__c) == null) return;
		
		throw new SRUtilities.SRException('There is already an active subscription for this product family');
	}

	public void checkApprovalReset(OpportunityLineItem oppLi, OpportunityLineItem existingOppLi)
	{
		 if(existingOppLi != null &&
            existingOppLi.Free_Month_Setting__c == oppLi.Free_Month_Setting__c) return;

        if(resetApoprovals == null) resetApoprovals = new Set<Id>();
		resetApoprovals.add(oppLi.OpportunityId);
	}
}