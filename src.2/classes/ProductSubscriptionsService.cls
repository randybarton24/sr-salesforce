public class ProductSubscriptionsService 
{
	public static void processNewScorecards(Set<String> puids, fflib_SObjectUnitOfWork uow)
	{
		Provider__c[] providers = ProvidersSelector.newInstance().selectByPuidWithBillingAccount(puids);
		Set<Id> acctIds = new Set<Id>();

		for(Provider__c p : providers)
		{
			acctIds.add(p.Bill_to_Account__r.Id);
			p.Last_Scorecard_Date__c = Datetime.now();
			uow.registerDirty(p);
		}

		AccountsService.processNewScorecards(acctIds, uow);
	}

	public static void linkHGRenewalToAsset(Set<Id> ids, fflib_SObjectUnitOfWork uow)
	{
		RecurSoft__Product_Subscription__c[] prodSubscriptions = ProductSubscriptionsSelector.newInstance().selectByIdWithRenewedSubscriptions(ids);
		
		for(RecurSoft__Product_Subscription__c ps : prodSubscriptions)
		{
			if(ps.RecurSoft__Renewed_Subscription__c != null && ps.RecurSoft__Renewed_Subscription__r.Asset__c != null)
			{
				ps.Asset__c = ps.RecurSoft__Renewed_Subscription__r.Asset__c;
				uow.registerDirty(ps);
			}
		}
	}

	public static void syncSubscriptionWithAsset(Set<Id> ids, fflib_SObjectUnitOfWork uow, SRUtilities.SRUnitOfWork sruow) 
	{
		RecurSoft__Product_Subscription__c[] subscriptions = ProductSubscriptionsSelector.newInstance().selectByIdWithOpportunityProductsSchedules(ids);
		Map<Id, Account> accountMap = new Map<Id, Account>(AccountsSelector.newInstance().selectBySubscriptionsWithAssets(subscriptions));

		for(RecurSoft__Product_Subscription__c subscription : subscriptions) 
		{
			if(subscription.RecurSoft__Product__r.IsEvergreen__c) 
			{
				subscription.RecordTypeId = SRUtilities.getRecordTypeMap('RecurSoft__Product_Subscription__c').get('Evergreen').getRecordTypeId();
				sruow.registerDirtyWithCatch(subscription);
			}

			Account a = accountMap.get(subscription.RecurSoft__Account__c);
			Asset matchingAsset = getMatchingAsset(subscription, a);

			if(matchingAsset == null) continue;
			if(subscription.Asset__c != null) continue;

			subscription.Asset__c = matchingAsset.Id;
			sruow.registerDirtyWithCatch(subscription);

			matchingAsset.Next_Invoice_Date__c = subscription.Next_Invoice_Date__c;
			matchingAsset.Contract_End_Date__c = subscription.RecurSoft__Contract_Term_End_Date__c;
			matchingAsset.Most_Recent_Contract_Signed_Date__c = subscription.RecurSoft__Contract_Signed_Date__c;
			sruow.registerDirtyWithCatch(matchingAsset);
		}
	}

	public static Asset getMatchingAsset(RecurSoft__Product_Subscription__c subscription, Account account) 
	{
		Asset result = null;

		if(account.Assets.size() > 0) 
		{
			for(Asset asset : account.Assets) 
			{
				if(subscription.RecurSoft__Product__r.Family == 'Healthgrades') 
				{
					if(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r.size() > 0 && 
						asset.Provider__r.Healthgrades_Id__c == subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Provider__r.Healthgrades_Id__c) 
					{
						result = asset;
						break;
					}
				} 

				else if(asset.Product2.Family == subscription.RecurSoft__Product__r.Family) 
				{
					result = asset;
					break;
				}
			}
		}
		
		return result;
	}

	public static void processRevSchedules(Set<Id> ids, fflib_SObjectUnitOfWork uow, SRUtilities.SRUnitOfWork sruow) 
	{
		RecurSoft__Product_Subscription__c[] subscriptions = ProductSubscriptionsSelector.newInstance().selectByIdWithOpportunityProductsSchedules(ids);

		RecurSoft__Product_Subscription__c[] subscriptionsInAdvance = new List<RecurSoft__Product_Subscription__c>();
		RecurSoft__Product_Subscription__c[] subscriptionsInArrears = new List<RecurSoft__Product_Subscription__c>();

		for(RecurSoft__Product_Subscription__c subscription : subscriptions) 
		{
			if(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r.isEmpty()) continue;

			//Ignore if neither Opp nor OppLineItem have Free Months
			if((subscription.RecurSoft__Related_Opportunity__r.RecurSoft__Number_of_Free_Months__c == null ||
					subscription.RecurSoft__Related_Opportunity__r.RecurSoft__Number_of_Free_Months__c == '0') &&
				(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Number_of_Free_Months__c == null ||
					subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Number_of_Free_Months__c == 0)) continue;

			//Ignore if Opp free months match OppLineItem free months, and billing in arrears
			if(subscription.RecurSoft__Related_Opportunity__r.RecurSoft__Number_of_Free_Months__c == 
					String.valueOf(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Number_of_Free_Months__c) &&
				subscription.RecurSoft__Related_Opportunity__r.RecurSoft__Free_Months_Setting__c ==
					subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c &&
				subscription.RecurSoft__Rev_Rec_Template_Name__c == null) continue;

			if(subscription.RecurSoft__Rev_Rec_Template_Name__c != null) 
			{
				subscriptionsInAdvance.add(subscription);
			} 

			else 
			{
				subscriptionsInArrears.add(subscription);
			}
		}

		if(!subscriptionsInAdvance.isEmpty()) 
		{
			processRevSchedulesInAdvance(subscriptionsInAdvance, uow, sruow);
		}

		if(!subscriptionsInArrears.isEmpty()) 
		{
			processRevSchedulesInArrears(subscriptionsInArrears, uow, sruow);
		}
	}

	public static void processRevSchedulesInAdvance(RecurSoft__Product_Subscription__c[] subscriptions, fflib_SObjectUnitOfWork uow, SRUtilities.SRUnitOfWork sruow) 
	{
		Decimal quantity = 1;
		Decimal numberOfPeriods = 0;
		Decimal numberOfPromotionalMonths = 0;
		Decimal promotionalMonthAmount = 0;
		Decimal expectedInvoiceAmountMonthly = 0;
		Date contractStart = Date.today();
		Date contractEnd = Date.today();
		
		for(RecurSoft__Product_Subscription__c subscription : subscriptions) 
		{
			contractStart = subscription.RecurSoft__Contract_Term_Start_Date__c;
			contractEnd = subscription.RecurSoft__Contract_Term_End_Date__c;
			numberOfPeriods = contractStart.day() == 1 ? contractStart.monthsBetween(contractEnd) + 1 : contractStart.monthsBetween(contractEnd);
			quantity = subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Quantity;
			numberOfPromotionalMonths = Integer.valueOf(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Number_of_Free_Months__c);
			promotionalMonthAmount = subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Promotional_Price__c == null ? 0 : 
				subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Promotional_Price__c * quantity;
			expectedInvoiceAmountMonthly = subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].UnitPrice * quantity;

			for(RecurSoft__Revenue_Schedule__c rs : subscription.RecurSoft__RecurSoft_Revenue_Schedules__r) 
			{
				if(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c == 'Include in Contract Period - At the Beginning' ||
					subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c == 'Extend Contract - At the Beginning' ||
					subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c == null) 
				{
					if(rs.RecurSoft__Period_Number__c <= numberOfPromotionalMonths) 
					{	
						rs.RecurSoft__Expected_Invoice_Amount__c = promotionalMonthAmount;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = promotionalMonthAmount;
						uow.registerDirty(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c > numberOfPeriods) 
					{
						uow.registerDeleted(rs);
					} 

					else 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						uow.registerDirty(rs);
					}
				} 

				else if(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c == 'Include in Contract Period - At the End') 
				{
					if(rs.RecurSoft__Period_Number__c > numberOfPeriods - numberOfPromotionalMonths) 
					{	
						rs.RecurSoft__Expected_Invoice_Amount__c = promotionalMonthAmount;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = promotionalMonthAmount;
						uow.registerDirty(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c > numberOfPeriods) 
					{
						uow.registerDeleted(rs);
					} 

					else 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						uow.registerDirty(rs);
					}
				}
			}
		}
	}

	public static void processRevSchedulesInArrears(RecurSoft__Product_Subscription__c[] subscriptions, fflib_SObjectUnitOfWork uow, SRUtilities.SRUnitOfWork sruow) 
	{
		Decimal quantity = 1;
		Decimal numberOfPeriods = 0;
		Decimal numberOfPromotionalMonths = 0;
		Decimal promotionalMonthAmount = 0;
		Decimal accruedRevenueFull = 0;
		Decimal expectedInvoiceAmountMonthly = 0;
		Decimal expectedInvoiceAmountTotal = 0;
		Decimal partialPeriodDays1 = 0;
		Decimal accruedRevenuePartial1 = 0;
		Decimal partialPeriodDays2 = 0;
		Decimal accruedRevenuePartial2 = 0;
		Decimal month1Days = 0;
		Date contractStart = Date.today();
		Date contractEnd = Date.today();
		Date beginningOfContractStartMonth = Date.today();
		Date endOfContractEndMonth = Date.today();
		
		for(RecurSoft__Product_Subscription__c subscription : subscriptions) 
		{
			contractStart = subscription.RecurSoft__Contract_Term_Start_Date__c;
			contractEnd = subscription.RecurSoft__Contract_Term_End_Date__c;
			numberOfPeriods = contractStart.day() == 1 ? contractStart.monthsBetween(contractEnd) + 1 : contractStart.monthsBetween(contractEnd);
			quantity = subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Quantity;
			numberOfPromotionalMonths = Integer.valueOf(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Number_of_Free_Months__c);
			promotionalMonthAmount = subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Promotional_Price__c == null ? 0 :
				subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Promotional_Price__c * quantity;
			beginningOfContractStartMonth = Date.newInstance(contractStart.addMonths(1).year(), contractStart.addMonths(1).month(), 1);
			endOfContractEndMonth = Date.newInstance(contractEnd.year(), contractEnd.month(), 1).addDays(-1);
			expectedInvoiceAmountMonthly = subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].UnitPrice * quantity;
			expectedInvoiceAmountTotal = (expectedInvoiceAmountMonthly * (numberOfPeriods - numberOfPromotionalMonths)) + (numberOfPromotionalMonths * promotionalMonthAmount * quantity);
			accruedRevenueFull = expectedInvoiceAmountTotal / numberOfPeriods;
			partialPeriodDays1 = contractStart.daysBetween(beginningOfContractStartMonth);
			partialPeriodDays2 = endOfContractEndMonth.daysBetween(contractEnd);
			month1Days = Date.daysInMonth(contractStart.year(), contractStart.month());
			accruedRevenuePartial1 = partialPeriodDays1 == month1Days ? accruedRevenueFull :
				(partialPeriodDays1 / (partialPeriodDays1 + partialPeriodDays2)) * accruedRevenueFull;
			accruedRevenuePartial2 = accruedRevenueFull - accruedRevenuePartial1;

			for(RecurSoft__Revenue_Schedule__c rs : subscription.RecurSoft__RecurSoft_Revenue_Schedules__r) 
			{
				if(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c == 'Include in Contract Period - At the Beginning' ||
					subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c == 'Extend Contract - At the Beginning' ||
					subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c == null) 
				{
					if(rs.RecurSoft__Period_Number__c == 1) 
					{	
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenuePartial1;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenuePartial1;
						uow.registerDirty(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c > numberOfPeriods + 1) 
					{
						uow.registerDeleted(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c <= numberOfPromotionalMonths + 1) 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = promotionalMonthAmount;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = promotionalMonthAmount;
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenueFull;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenueFull;
						uow.registerDirty(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c == numberOfPeriods + 1) 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenuePartial2;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenuePartial2;
						uow.registerDirty(rs);
					} 

					else 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenueFull;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenueFull;
						uow.registerDirty(rs);
					}
				} 

				else if(subscription.RecurSoft__RecurSoft_Opportunity_Product3__r[0].Free_Month_Setting__c == 'Include in Contract Period - At the End') 
				{
					if(rs.RecurSoft__Period_Number__c == 1) 
					{
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenuePartial1;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenuePartial1;
						uow.registerDirty(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c > numberOfPeriods + 1) 
					{
						uow.registerDeleted(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c >= (numberOfPeriods + 1) - (numberOfPromotionalMonths -1) &&
						rs.RecurSoft__Period_Number__c != numberOfPeriods + 1) 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = promotionalMonthAmount;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = promotionalMonthAmount;
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenueFull;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenueFull;
						uow.registerDirty(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c == numberOfPeriods + 1 &&
						numberOfPromotionalMonths > 0) 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = promotionalMonthAmount;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = promotionalMonthAmount;
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenuePartial2;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenuePartial2;
						uow.registerDirty(rs);
					} 

					else if(rs.RecurSoft__Period_Number__c == numberOfPeriods + 1 &&
						numberOfPromotionalMonths == 0) 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenuePartial2;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenuePartial2;
						uow.registerDirty(rs);
					} 

					else 
					{
						rs.RecurSoft__Expected_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Expected_Base_Invoice_Amount__c = expectedInvoiceAmountMonthly;
						rs.RecurSoft__Accrued_Revenue_Amount__c = accruedRevenueFull;
						rs.RecurSoft__Expected_Base_Accrued_Amount__c = accruedRevenueFull;
						uow.registerDirty(rs);
					}
				}
			}
		}
	}
}