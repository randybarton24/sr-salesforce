public class OppLineItemUtilities {

	private static String HEALTHGRADES_PRODUCT_CODE = '3005';

	/**
	 * Query used to populate the OppLineItemsTriggerHandler.relatedOpportunitiesMap static variable. Data is cached to prevent repeated SOQL queries
	 * @param newOppLis - Trigger.new
	 * @return Opportunity map for static variable cache
	 * @see OppLineItemTriggerHandler.OnBeforeInsert
	 */
	public static Map<Id, Opportunity> getRelatedOpps(OpportunityLineItem[] newOppLis) {

		Set<ID> newOppIds = new Set<ID>();
		
		for(OpportunityLineItem oppLi : newOppLis) {
			newOppIds.add(oppLi.OpportunityId);
		}
		
		Map<ID, Opportunity> results = new Map<ID, Opportunity> (
			[SELECT Id, 
			RecordType.Name,
			AccountId,
			StageName, 
			RecurSoft__Initial_Contract_Term__c, 
			RecurSoft__Contract_Term_Start_Date__c, 
			RecurSoft__Contract_Signed_Date__c,
			RecurSoft__Contract_Term_End_Date__c, 
			HasOpportunityLineItem,
			CreatedBy.Name,
			(SELECT Id,
		    	Is_Promo_Item__c,
		    	ListPrice,
		    	UnitPrice,
		    	TotalPrice,
		    	Quantity,
		    	Number_of_Free_Months__c,
		    	Free_Month_Setting__c,
		    	Co_Terminate__c,
		    	Base_Contract_Term__c,
		    	RecurSoft__Contract_Term_End_Date_Editable__c,
		    	RecurSoft__Contract_Term_Start_Date_New__c,
		    	RecurSoft__Contract_Term1__c,
		    	RecurSoft__Contract_Term_Setting__c,
		    	RecurSoft__Renewal_Rule__c,
		    	OpportunityId,
		    	PricebookEntryId,
		    	PriceBookEntry.Name,
		    	PriceBookEntry.UnitPrice,
		    	PricebookEntry.Product2Id, 
		    	PricebookEntry.Product2.Name,
		    	PricebookEntry.Product2.ProductCode,
		    	PricebookEntry.Pricebook2Id, 
		    	Product2.Default_Renewal_Rule__c, 
		    	Product2.Family, 
		    	Product2.Default_Contract_Term__c, 
		    	Product2.Default_Co_Terminate__c, 
		    	Product2.RecurSoft__Billing_Frequency__c 
		    	FROM OpportunityLineItems 
		    	ORDER BY RecurSoft__Contract_Term_End_Date_Editable__c ASC)
			FROM Opportunity
			WHERE Id IN :newOppIds]);

		return results;
	}

	public static Map<Id, Product2> getRelatedProducts(OpportunityLineItem[] newOppLis) {

		Set<ID> productIds = new Set<ID>();
		
		for(OpportunityLineItem oppLi : newOppLis) {
			productIds.add(oppLi.Product2Id);
		}
		
		Map<ID, Product2> results = new Map<ID, Product2> (
			[SELECT Id, 
			Family, 
			Default_Renewal_Rule__c, 
		    Default_Contract_Term__c, 
		    Default_Co_Terminate__c, 
		    RecurSoft__Billing_Frequency__c 
			FROM Product2]);

		return results;
	}

	public static Map<Id, Account> getRelatedAccounts(Opportunity[] listOpps) {

		Set<ID> acctIds = new Set<ID>();
		
		for(Opportunity o : listOpps) {
			acctIds.add(o.AccountId);
		}
		
		Map<ID, Account> results = new Map<ID, Account> (
			[SELECT Id,
			(SELECT Id, 
				Next_Invoice_Date__c, 
				Contract_End_Date__c,
				Active__c
				FROM Assets
				WHERE Product2.Family = 'SR Platform'
				AND Active__c = true) 
			FROM Account
			WHERE Id IN :acctIds]);

		return results;
	}

	public static Map<String, Id> getRelatedAcccountAssets(OpportunityLineItem[] listOppLis) {

		Set<ID> acctIds = new Set<ID>();
		Map<String, Id> currentSubscriptionMap = new Map<String, Id>();
		
		for(OpportunityLineItem oppLi : listOppLis) {
			
			acctIds.add(oppLi.Opportunity.AccountId);
		}
		
		Account[] acctList = [SELECT Id,
			(SELECT Id,
				Product2.Family,
				Provider__c,
				Current_Product_Subscription__c 
				FROM Assets)
			FROM Account
			WHERE Id IN :acctIds];

		for(Account a : acctList) {

			if(a.Assets.isEmpty()) continue;

			for(Asset ast : a.Assets) {

				currentSubscriptionMap.put(String.valueOf(a.Id) + ast.Product2.Family + ast.Provider__c, ast.Current_Product_Subscription__c);

				if(ast.Product2.Family == 'SR Platform') currentSubscriptionMap.put(String.valueOf(a.Id), ast.Current_Product_Subscription__c);
			}
		}

		return currentSubscriptionMap;
	}

	public static Map<Id, OpportunityLineItem> getOppLiData(Set<Id> oppLiIds) {

		Map<Id, OpportunityLineItem> results = new Map<Id, OpportunityLineItem>([SELECT Id,
		Opportunity.RecurSoft__Trial__c,
		Product2.Name,
		Product2.ProductCode,
		Product2.Family,
		Provider__c,
		OpportunityId,
		Opportunity.AccountId,
		Opportunity.RecordType.Name,
		Opportunity.StageName,
		Override_Modified_Subscription__c,
		Modified_Subscription__c,
		Override_Current_SR_Subscription__c,
		Current_SR_Subscription__c,
		Trial__c
		FROM OpportunityLineItem
		WHERE Id IN :oppLiIds]);

		return results;
	}

	/**
	 * A Healthgrades product should always be alone on an Opportunity. 
	 * Validation to prevent adding a Healthgrades product to an Opportunity with existing products.
	 * Validation to prevent adding additional products to an Opportunity with an existing Healthgrades product.
	 * @param updatedOppLis - Trigger.new
	 * @param relatedOppMap - previously cached map with related Opportunities
	 * @see OppLineItemTriggerHandler.OnBeforeInsert
	 */
	public static void validateNoMixedProducts(OpportunityLineItem[] updatedOppLis, Map<Id, Opportunity> relatedOppMap) {

		for(OpportunityLineItem oppLi : updatedOppLis) {

			if(relatedOppMap.containsKey(oppLi.OpportunityId) && relatedOppMap.get(oppLi.OpportunityId).HasOpportunityLineItem) {
			
				if(oppLi.Product_Code__c == HEALTHGRADES_PRODUCT_CODE) {

					oppLi.Quantity.addError(Label.Error_Healthgrades_Mix_Products);

				} else {

					for(OpportunityLineItem relatedOppLi : relatedOppMap.get(oppLi.OpportunityId).OpportunityLineItems) {

						if(relatedOppLi.PricebookEntry.Product2.ProductCode == HEALTHGRADES_PRODUCT_CODE) {
							
							oppLi.Quantity.addError(Label.Error_Healthgrades_Mix_Products2);
						}
					}
				}
			}
		}
	}

	public static void validateHealthgradesProvider(OpportunityLineItem[] updatedOppLis) {

		String errorMsg = 'You must add a Provider with the Healthgrades Premium Profile';

		for(OpportunityLineItem oppLi : updatedOppLis) {
			
			if(oppLi.Product_Code__c == HEALTHGRADES_PRODUCT_CODE && oppLi.Provider__c == null) {

				oppLi.Quantity.addError(errorMsg);
			}
		}
	}

	public static void validateNoDuplicateProducts(OpportunityLineItem[] updatedOppLis, Map<Id, Opportunity> relatedOppMap, Map<Id, Product2> relatedProductMap) {

		Map<Id, Set<String>> productFamily = new Map<Id, Set<String>>();
		String errorMsg = 'There can only be one Product from each Product Family';

		for(OpportunityLineItem oppLi : updatedOppLis) {

			productFamily.put(oppLi.OpportunityId, null);
		}

		for(OpportunityLineItem oppLi : updatedOppLis) {

			Opportunity o = relatedOppMap.get(oppLi.OpportunityId);
			if(o == null) continue;
			if(o.RecordType.Name == 'Renewal' || o.RecordType.Name == 'Add-On Business') continue;
			Product2 p = relatedProductMap.get(oppLi.Product2Id);
			Set<String> oppProductFamily = productFamily.get(o.Id) == null ? new Set<String>() : productFamily.get(o.Id);

			if(o.OpportunityLineItems.size() > 0) {

				for(OpportunityLineItem oppLi2 : o.OpportunityLineItems) {

					Product2 p2 = relatedProductMap.get(oppLi2.Product2Id);

					if(p2.Family == null) continue;
					
					oppProductFamily.add(p2.Family);
				}

				productFamily.put(o.Id, oppProductFamily);
			}

			if(p.Family == null) continue;

			if(oppProductFamily.contains(p.Family)) {

				oppLi.addError(errorMsg);
			
			} else {

				oppProductFamily.add(p.Family);
				productFamily.put(o.Id, oppProductFamily);
			}
		}
	}

	/*@future public static void setOppTrialPeriod(Set<Id> oppLiIds) {

		Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();
		Map<Id, OpportunityLineItem> oppLiDataMap = getOppLiData(oppLiIds);

		for(OpportunityLineItem oppLi : oppLiDataMap.values()) {

			if(oppLi.Product2.ProductCode == '3000' && oppLi.Trial__c != oppLi.Opportunity.RecurSoft__Trial__c) {

				Opportunity o = new Opportunity();
				o.Id = oppLi.OpportunityId;
				o.RecurSoft__Trial__c = oppLi.Trial__c;
				mapUpdateSObject.put(o.Id, o);
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OppLineItemUtilities.setOppTrialPeriod');
	}*/

	//Defaults set on insert... will be overwritten for Add Product/Healthgrade Opps
	public static void setContractDefaults(OpportunityLineItem[] updatedOppLis, Map<Id, Product2> relatedProductMap, Map<Id, Opportunity> relatedOppMap) {

		for(OpportunityLineItem oppLi : updatedOppLis) {

			if(!relatedProductMap.containsKey(oppLi.Product2Id)) return;
			if(!relatedOppMap.containsKey(oppLi.OpportunityId)) return;

			Product2 product = relatedProductMap.get(oppLi.Product2Id);
			Opportunity opp = relatedOppMap.get(oppLi.OpportunityId);

			//Co-Terminate flag will determine if contract end date is forced to coterminate or go with product defaults
			oppLi.Co_Terminate__c = product.Default_Co_Terminate__c;

			//Base contract term is set on the product for non-coterminating products(month-to-month), otherwise, it's set on the Opp
			oppLi.Base_Contract_Term__c = !product.Default_Co_Terminate__c ? Integer.valueOf(product.Default_Contract_Term__c) :
				opp.RecurSoft__Initial_Contract_Term__c == null ? 24 : Integer.valueOf(opp.RecurSoft__Initial_Contract_Term__c);

			//Free month setting cleared if no free months added
			oppLi.Free_Month_Setting__c = oppLi.Number_of_Free_Months__c == null || oppLi.Number_of_Free_Months__c == 0 ? null : oppLi.Free_Month_Setting__c;
			
			//RecurSoft contract term field is calculated based on free months and setting
			oppLi.RecurSoft__Contract_Term1__c = oppLi.Free_Month_Setting__c == 'Extend Contract - At the Beginning' ?
					String.valueOf(oppLi.Base_Contract_Term__c + oppLi.Number_of_Free_Months__c) + ' Months' : 
					String.valueOf(oppLi.Base_Contract_Term__c) + ' Months';

			//Always calculated in months
			oppLi.RecurSoft__Contract_Term_Setting__c = 'Months';

			//Set the default renewal rule if blank
			if(oppLi.RecurSoft__Renewal_Rule__c == null) {

				System.debug('renewal rule here');
				System.debug(product.Default_Renewal_Rule__c);
				oppLi.RecurSoft__Renewal_Rule__c = product.Default_Renewal_Rule__c;
			}
		}
	}

	//On insert overwrites defaults, updates if either contract start or end date is edited
	public static void setAddProductDates(OpportunityLineItem[] updatedOppLis) {

		if(FlowControl.hgContractDatesSet) return;

		Map<Id, Opportunity> relatedOppMap = getRelatedOpps(updatedOppLis);
		Map<Id, Account> relatedAccountMap = getRelatedAccounts(relatedOppMap.values());

		for(OpportunityLineItem oppLi : updatedOppLis) {

			Opportunity o = relatedOppMap.get(oppLi.OpportunityId);
			Account a = relatedAccountMap.get(o.AccountId);

			//Exit if not an Add Product or Healthgrades opp, or if opp is closed
			if(o.RecordType.Name != 'Healthgrades' && o.RecordType.Name != 'Add Product') continue;
			if(o.StageName == 'Closed Won' || o.StageName == 'Closed Lost') continue;
			if(o.CreatedBy.Name == 'API User') continue;

			Integer freeMonths;
			Integer contractTerm;

			if(a.Assets.isEmpty()) {

				oppLi.RecurSoft__Contract_Term_Start_Date_New__c = null;
				oppLi.RecurSoft__Contract_Term_End_Date_Editable__c = null;

			} else {

				freeMonths = oppLi.Number_of_Free_Months__c == null ? 0 : Integer.valueOf(oppLi.Number_of_Free_Months__c);
				contractTerm = Integer.valueOf(oppLi.Base_Contract_Term__c);

				System.debug(a.Assets[0].Contract_End_Date__c);

				//Set contract start to next invoice date on SR Platform asset
				oppLi.RecurSoft__Contract_Term_Start_Date_New__c = o.RecurSoft__Contract_Signed_Date__c == null ? Date.today() : o.RecurSoft__Contract_Signed_Date__c;
				//If coterminate set, contract end date set to SR Platform asset end date, otherwise, calculated
				if(a.Assets[0].Contract_End_Date__c != null && oppLi.Co_Terminate__c)
				{
					oppLi.RecurSoft__Contract_Term_End_Date_Editable__c = oppLi.RecurSoft__Contract_Term_Start_Date_New__c
						.addMonths(oppLi.RecurSoft__Contract_Term_Start_Date_New__c.monthsBetween(a.Assets[0].Contract_End_Date__c))
						.addDays(-1);
				}
				else
				{
					oppLi.RecurSoft__Contract_Term_End_Date_Editable__c = oppLi.Free_Month_Setting__c == 'Extend Contract - At the Beginning' ?
						oppLi.RecurSoft__Contract_Term_Start_Date_New__c.addMonths(contractTerm + freeMonths).addDays(-1) : 
						oppLi.RecurSoft__Contract_Term_Start_Date_New__c.addMonths(contractTerm).addDays(-1);
				}
			}
		}
	}

	@future public static void setCoTerminationDates(Set<Id> oppLiIds) {

		Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();

		OpportunityLineItem[] listOppLi = [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE Id IN :oppLiIds];
		Map<Id, Opportunity> relatedOppMap = getRelatedOpps(listOppLi);

		for(Opportunity o : relatedOppMap.values()) {

			if(o.StageName == 'Closed Won' || o.StageName == 'Closed Lost') continue;

			Integer contractTerm;
			Integer freeMonths;
			Date contractEndDate;
			Date maxContractEndDate;

			//Find the max contract end date of all OppLineItems, in order to match all co-terminating products
			for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

				if(oppLi.RecurSoft__Contract_Term_Start_Date_New__c == null) continue;

				//If the product is co-terminating, use the Opportunity base contract term, otherwise use the OppLineItem base contract term
				contractTerm = !oppLi.Co_Terminate__c ? Integer.valueOf(oppLi.Base_Contract_Term__c) :
					o.RecurSoft__Initial_Contract_Term__c == null ? 24 : Integer.valueOf(o.RecurSoft__Initial_Contract_Term__c);
				
				freeMonths = oppLi.Number_of_Free_Months__c == null ? 0 : Integer.valueOf(oppLi.Number_of_Free_Months__c);
				
				contractEndDate = oppLi.Free_Month_Setting__c == 'Extend Contract - At the Beginning' ?
					oppLi.RecurSoft__Contract_Term_Start_Date_New__c.addMonths(contractTerm + freeMonths).addDays(-1) : 
					oppLi.RecurSoft__Contract_Term_Start_Date_New__c.addMonths(contractTerm).addDays(-1);
				
				maxContractEndDate = maxContractEndDate == null ? contractEndDate :
					contractEndDate > maxContractEndDate ? contractEndDate : maxContractEndDate;

				//If the product is not co-terminating, set the contract end date
				if(!oppLi.Co_Terminate__c && oppLi.RecurSoft__Contract_Term_End_Date_Editable__c != contractEndDate) {

					oppLi.RecurSoft__Contract_Term_End_Date_Editable__c = contractEndDate;
					oppLi.Free_Month_Setting__c = oppLi.Number_of_Free_Months__c == null || oppLi.Number_of_Free_Months__c == 0 ? null : oppLi.Free_Month_Setting__c;
					mapUpdateSObject.put(oppLi.Id, oppLi);
				}
			}

			//Set contract end date on all co-terminating products to the max contract end date
			for(OpportunityLineItem oppLi2 : o.OpportunityLineItems) {

				if(oppLi2.Co_Terminate__c) { 

					if(oppLi2.RecurSoft__Contract_Term_End_Date_Editable__c != maxContractEndDate) {

						oppLi2.RecurSoft__Contract_Term_End_Date_Editable__c = maxContractEndDate;
						oppLi2.Free_Month_Setting__c = oppLi2.Number_of_Free_Months__c == null || oppLi2.Number_of_Free_Months__c == 0 ? null : oppLi2.Free_Month_Setting__c;
						mapUpdateSObject.put(oppLi2.Id, oppLi2);
					}
				}
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OppLineItemUtilities.setCoTerminationDates');
	}

	public static void setModifiedSubscription(OpportunityLineItem[] newList, Map<Id, OpportunityLineItem> updatedOppLis, Boolean doDML) {

		Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();

		Set<Id> acctIds = new Set<Id>();

		Map<Id, OpportunityLineItem> oppLiDataMap = getOppLiData(updatedOppLis.keySet());
		Map<String, Id> currentSubscriptionMap = getRelatedAcccountAssets(oppLiDataMap.values());
		System.debug(currentSubscriptionMap);


		for(OpportunityLineItem oppLi : newList) {

			OpportunityLineItem oppLi2 = oppLiDataMap.get(oppLi.Id);

			if((!doDML && oppLi2.Opportunity.StageName != 'Closed Won')
				&& !oppLi.Override_Modified_Subscription__c 
				&& oppLi2.Opportunity.RecordType.Name == 'Add-On Business'
				&& currentSubscriptionMap.containsKey(oppLi2.Opportunity.AccountId + oppLi2.Product2.Family + oppLi2.Provider__c)
				&& oppLi.Modified_Subscription__c != currentSubscriptionMap.get(oppLi2.Opportunity.AccountId + oppLi2.Product2.Family + oppLi2.Provider__c)) {

				oppLi.Modified_Subscription__c = currentSubscriptionMap.get(oppLi2.Opportunity.AccountId + oppLi2.Product2.Family + oppLi2.Provider__c);
				mapUpdateSObject.put(oppLi.Id, oppLi);
			}

			if((!doDML && oppLi2.Opportunity.StageName != 'Closed Won')
				&& !oppLi.Override_Current_SR_Subscription__c
				&& oppLi2.Opportunity.RecordType.Name == 'Add-On Business'
				&& currentSubscriptionMap.containsKey(oppLi2.Opportunity.AccountId)
				&& oppLi.Current_SR_Subscription__c != currentSubscriptionMap.get(oppLi2.Opportunity.AccountId)) {

				oppLi.Current_SR_Subscription__c = currentSubscriptionMap.get(oppLi2.Opportunity.AccountId);
				mapUpdateSObject.put(oppLi.Id, oppLi);
			}
		}

		if(doDML) SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OppLineItemUtilities.setModifiedSubscription');
	}
}