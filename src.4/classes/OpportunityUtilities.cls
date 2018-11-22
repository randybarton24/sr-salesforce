public class OpportunityUtilities {

	private static String MSFProduct = '3000'; // 'Monthly Service Fee';
    private static String SFProduct = '4000'; // 'Setup Fee';
    private static String APProduct = '3001'; // 'Additional Providers';
    private static String PRTProduct = '1002';
    public static RecordTypeInfo ADDENDUM_RECORD_TYPE = OpportunityTriggerHandler.recordTypeMap.get('Add-On Business');
    public static RecordTypeInfo RENEWALS_RECORD_TYPE = OpportunityTriggerHandler.recordTypeMap.get('Renewal');
    public static RecordTypeInfo HEALTHGRADES_RECORD_TYPE = OpportunityTriggerHandler.recordTypeMap.get('Healthgrades');
    public static RecordTypeInfo ADD_PRODUCT_RECORD_TYPE = OpportunityTriggerHandler.recordTypeMap.get('Add Product');
  
    public static Map<Id, PriceBook2> getPricebookData() {

    	Map<Id, Pricebook2> results = new Map<Id, Pricebook2>([SELECT Id,
    	Name,
    	Number_of_Providers_Included__c,
        Number_of_PRT_Included__c,
        Default_Term__c,
    	(SELECT Id,
	    	Pricebook2Id,
	    	Pricebook2.Name,
	    	Product2Id,
	    	Product2.Name,
	    	Product2.ProductCode,
	    	Product2.Family,
	    	UnitPrice,
	    	ProductCode,
	    	Auto_Add_Quantity__c,
            Auto_Add_Price__c,
	    	Auto_Add_Trial__c,
	    	Auto_Add_Free_Months__c,
	    	Auto_Add_Free_Month_Setting__c,
	    	Auto_Add__c
	    	FROM PriceBookEntries)
		FROM Pricebook2]);

    	return results;
    }

    /**
     * Query used to populate the OpportunityTriggerHandler.oppDataMap static variable. Data is cached to prevent repeated SOQL queries
     * @param  newOpportunityMap - Trigger.newMap or previously cached map
     * @return  Opportunity map for static variable cache
     * @see OpportunityTriggerHandler.OnAfterInsert, OpportunityTriggerHandler.OnAfterUpdate
     * @see this.addStandardProducts, this.updatePricingForCampaignChange, this.updateAPProductForNumberOfProvidersChange
     */
    public static Map<Id, Opportunity> getOppData(Set<Id> idsToProcess) {

    	Map<Id, Opportunity> results = new Map<Id, Opportunity>(
		[SELECT Id, 
		AccountId, 
		Account.Subscriber_Id__c, 
		Account.RecurSoft__Billing_Email__c,
		Account.Name,
		Account.Practice_Management_Software__r.Limelight_Available__c,
		RecurSoft__Billing_Contact__r.Email, 
		RecordTypeId, 
		RecordType.Name, 
		Contract_Signed__c,
		Number_of_Providers__c, 
        Number_of_PRT__c,
		RecurSoft__Contract_Signed_Date__c, 
		RecurSoft__Contract_Term_Start_Date__c, 
		RecurSoft__Contract_Term_End_Date__c, 
		RecurSoft__Trial_End_Date1__c, 
        Name, 
        RecurSoft__Initial_Contract_Term__c, 
        RecurSoft__Number_of_Free_Months__c, 
        RecurSoft__Free_Months_Setting__c,
        RecurSoft__Trial__c, 
        HasOpportunityLineItem, 
        IsLegacy__c,
        CampaignId,
        	Campaign.Product_1_Name1__c,
	    	Campaign.Product_2_Name_2__c,
	    	Campaign.Name,
	    	Campaign.Type,
	    	Campaign.Trial_Period__c,
	    	Campaign.Free_Months__c,
	    	Campaign.Free_Months_Setting__c,
	    	Campaign.Promo_Product1__c,
	    	Campaign.Product_1_Sales_Price__c,
	    	Campaign.Product_2_Sale_Price__c, 
	    Pricebook2Id,
    		Pricebook2.Name,
    		Pricebook2.IsStandard,
		(SELECT Id,
	    	Is_Promo_Item__c,
	    	ListPrice,
	    	UnitPrice,
	    	TotalPrice,
	    	Approval_Details__c,
            Competitor_Buyout__c,
	    	Quantity,
	    	OpportunityId, 
	    	Opportunity.RecordType.Name,
	    	Opportunity.AccountId,
	    	Override_Modified_Subscription__c,
	    	Modified_Subscription__c,
	    	Base_Contract_Term__c, 
	    	Trial__c,
            Trial_End_Date__c,
	    	Co_Terminate__c,
	    	Provider__c, 
	    	Provider__r.NPI__c, 
	    	Provider__r.Healthgrades_Id__c, 
	    	PricebookEntryId,
	    	PriceBookEntry.Name,
	    	PriceBookEntry.UnitPrice,
	    	PricebookEntry.Product2Id, 
	    	PricebookEntry.Product2.Name,
	    	PricebookEntry.Product2.ProductCode,
	    	PricebookEntry.Product2.Family, 
	    	PricebookEntry.Product2.RecurSoft__Billing_Frequency__c,
	    	PricebookEntry.Pricebook2Id
	    	FROM OpportunityLineItems)
        FROM Opportunity 
        WHERE Id IN :idsToProcess]);

        return results;
    }

    public static Map<Id, Account> getRelatedAccounts(Opportunity[] oppList) {

    	Set<Id> acctIds = new Set<Id>();

    	for(Opportunity o : oppList) {

    		acctIds.add(o.AccountId);
    	}

    	Map<Id, Account> results = new Map<Id, Account>(
    		[SELECT Id,
    		(SELECT Id,
    			Product2.Family, 
    			Provider__r.Healthgrades_Id__c
    			FROM Assets) 
    		FROM Account 
    		WHERE Id IN: acctIds]);

    	return results;
    }

    public static Map<Id, Provider__c> getProviderData(Set<Id> providerIds) {

        Map<Id, Provider__c> results = new Map<Id, Provider__c>([SELECT Id,
        Name,
        Bill_to_Account__c,
        Related_Contact__c,
        Healthgrades_ID__c,
        NPI__c
        FROM Provider__c
        WHERE Id IN :providerIds]);

        return results;
    }
   
    /**
     * Utility method to add an OpportunityLineItem
     * @param  Opportunity o - The Opportunity to receive the OpportunityLineItem
     * @param  PricebookEntry pbEntry - The related PricebookEntry, which contains the Product and pricing details
     * @param  Decimal q - The OpportunityLineItem quantity
     * @return OpportunityLineItem for insert
     * @see addStandardProducts, updatePricingForCampaignChange, updateAPProductForNumberOfProvidersChange
     */
    public static OpportunityLineItem addOpportunityLineItem(Opportunity o, PriceBookEntry pbEntry, Decimal q) {

    	OpportunityLineItem results = new OpportunityLineItem(OpportunityId = o.Id,
    															PricebookEntryId = pbEntry.Id,
    															Quantity = q,
    															UnitPrice = pbEntry.UnitPrice);

    	return results;
    }

    /**
     * If a pricebook isn't selected on Opportunity creation or is null on update, this method will set the Standard Pricebook.
     * @param updatedOpps - Trigger.new passed from TriggerHandler
     * @see OpportunityTriggerHandler.OnBeforeInsert, OpportunityTriggerHandler.OnBeforeUpdate
     */
    /*public static void setDefaultPricebook(Opportunity[] updatedOpps) {
	    	
    	Map<Id, Pricebook2> pBookMap = getPricebookData();
    	Id defaultPb;

    	for(PriceBook2 pb : pBookMap.values()) {

    		if(pb.Name == '1.1 SR Platform') defaultPb = pb.Id;
    	}

    	for(Opportunity o : updatedOpps) {

    		if(o.RecordTypeId != RENEWALS_RECORD_TYPE.getRecordTypeId()){

	    		if(o.Pricebook2Id == null && defaultPb != null) {
	    			
	    			o.Pricebook2Id = defaultPb;
	    		}
	    	}
    	}
    }

    public static void setIncludedProviders(Opportunity[] updatedOpps) {
	    	
    	Map<Id, Pricebook2> pBookMap = getPricebookData();

    	for(Opportunity o : updatedOpps) {

    		if(o.RecordTypeId == RENEWALS_RECORD_TYPE.getRecordTypeId()) continue;
    		if(o.Pricebook2Id == null) continue;
    		if(!pBookMap.containsKey(o.PriceBook2Id)) continue;

	    	if(pBookMap.get(o.PriceBook2Id).Number_of_Providers_Included__c > 0) o.Number_of_Providers__c = pBookMap.get(o.PriceBook2Id).Number_of_Providers_Included__c;
            if(pBookMap.get(o.PriceBook2Id).Number_of_PRT_Included__c > 0) o.Number_of_PRT__c = pBookMap.get(o.PriceBook2Id).Number_of_PRT_Included__c;
            if(pBookMap.get(o.PriceBook2Id).Default_Term__c != null) o.RecurSoft__Initial_Contract_Term__c = pBookMap.get(o.PriceBook2Id).Default_Term__c;
    	}
    }*/

    /**
     * Adds, updates, or deletes the Additional Provider product as necessary based on the Number_of_Providers__c field change.
     * Three providers are included in a standard contract and do not require the Additional Provider product.
     * The Additional Provider OpportunityLineItem quantity is the number of providers above the standard 3.
     * @param updatedOpps - Trigger.new
     * @param oldOpportunityMap - Trigger.oldMap
     * @param newOppDataMap - The map results from this.getOppData()
     * @see OpportunityTriggerHandler.OnAfterUpdate
     */
    /*public static void updateAPProductForNumberOfProvidersChange(Opportunity[] updatedOpps, Map<ID, Opportunity> oldOpportunityMap, Map<ID, Opportunity> newOppDataMap) {

    	Boolean hasAdditionalProviderLineItem = false;
    	Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
    	Map<Id, Pricebook2> pBookMap = getPricebookData();

    	if(!FlowControl.inClass1) {

    		FlowControl.inClass1 = true;
	    	
	    	for(Opportunity o : updatedOpps) {

	    		if(o.RecordTypeId == RENEWALS_RECORD_TYPE.getRecordTypeId()) continue;
    			if(!pBookMap.containsKey(o.PriceBook2Id)) continue;
    			if(pBookMap.get(o.Pricebook2Id).PricebookEntries.isEmpty()) continue;
    			
    			PriceBook2 pb = pBookMap.get(o.Pricebook2Id);
    			Decimal includedProviders = pb.Number_of_Providers_Included__c == null ? 0 : pb.Number_of_Providers_Included__c;

    			if(o.HasOpportunityLineItem) {

	    			for(OpportunityLineItem oppLi : newOppDataMap.get(o.Id).OpportunityLineItems) {

	    				if(oppLi.PricebookEntry.Product2.ProductCode == APProduct) {
	    					
	    					oppLi.Quantity = o.Number_of_Providers__c > includedProviders ? o.Number_of_Providers__c - includedProviders : 0;
	    					oppLi.UnitPrice = oppLi.PricebookEntry.UnitPrice;
	    					hasAdditionalProviderLineItem = true;

	    					if(oppLi.Quantity == 0) {
	    						
	    						mapDeleteSObject.put(oppLi.Id, oppLi);

	    					} else {
	    						mapUpdateSObject.put(oppLi.Id, oppLi);
	    					} 
	    				}
	    			}

	    			if(!hasAdditionalProviderLineItem && o.Number_of_Providers__c > includedProviders) {

	    				for(PriceBookEntry pbEntry : pb.PriceBookEntries) {

	    					if(pbEntry.Product2.ProductCode == APProduct) {
	    						
	    						OpportunityLineItem newOppLi = OpportunityUtilities.addOpportunityLineItem(o, pbEntry, o.Number_of_Providers__c - includedProviders);
	    						mapInsertSObject.put(pbEntry.Id, newOppLi);
	    					}
	    				}
	    			}

	    		} else if(o.Number_of_Providers__c > includedProviders) {
	    			
	    			for(PriceBookEntry pbEntry : pb.PricebookEntries) {

	    				if(pbEntry.Product2.ProductCode == APProduct) {
	    					
	    					OpportunityLineItem newOppLi = OpportunityUtilities.addOpportunityLineItem(o, pbEntry, o.Number_of_Providers__c - includedProviders);
	    					mapInsertSObject.put(pbEntry.Id, newOppLi);
	    				}
	    			}
	    		}
	    		
	    	}

	    	SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.updateAPProductForNumberOfProvidersChange');
        	if(!mapUpdateSObject.isEmpty() || !mapInsertSObject.isEmpty() || !mapDeleteSObject.isEmpty()) OpportunityTriggerHandler.oppDataMap = OpportunityUtilities.getOppData(newOppDataMap.keySet());
        	FlowControl.inClass1 = false;
        }
    }

    public static void updatePRTProductForNumberOfPRTChange(Opportunity[] updatedOpps, Map<ID, Opportunity> oldOpportunityMap, Map<ID, Opportunity> newOppDataMap) {

        Boolean hasPRTLineItem = false;
        Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
        Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
        Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
        Map<Id, Pricebook2> pBookMap = getPricebookData();

        if(!FlowControl.inClass1) {

            FlowControl.inClass1 = true;
            
            for(Opportunity o : updatedOpps) {

                if(o.RecordTypeId == RENEWALS_RECORD_TYPE.getRecordTypeId()) continue;
                if(!pBookMap.containsKey(o.PriceBook2Id)) continue;
                if(pBookMap.get(o.Pricebook2Id).PricebookEntries.isEmpty()) continue;
                
                PriceBook2 pb = pBookMap.get(o.Pricebook2Id);
                Decimal includedPRT = pb.Number_of_PRT_Included__c == null ? 0 : pb.Number_of_PRT_Included__c;

                if(o.HasOpportunityLineItem) {

                    for(OpportunityLineItem oppLi : newOppDataMap.get(o.Id).OpportunityLineItems) {

                        if(oppLi.PricebookEntry.Product2.ProductCode == PRTProduct) {
                            
                            oppLi.Quantity = o.Number_of_PRT__c > includedPRT ? o.Number_of_PRT__c - includedPRT : 0;
                            oppLi.UnitPrice = oppLi.PricebookEntry.UnitPrice;
                            hasPRTLineItem = true;

                            if(oppLi.Quantity == 0) {
                                
                                mapDeleteSObject.put(oppLi.Id, oppLi);

                            } else {
                                mapUpdateSObject.put(oppLi.Id, oppLi);
                            } 
                        }
                    }

                    if(!hasPRTLineItem && o.Number_of_PRT__c > includedPRT) {

                        for(PriceBookEntry pbEntry : pb.PriceBookEntries) {

                            if(pbEntry.Product2.ProductCode == PRTProduct) {
                                
                                OpportunityLineItem newOppLi = OpportunityUtilities.addOpportunityLineItem(o, pbEntry, o.Number_of_PRT__c - includedPRT);
                                mapInsertSObject.put(pbEntry.Id, newOppLi);
                            }
                        }
                    }

                } else if(o.Number_of_PRT__c > includedPRT) {
                    
                    for(PriceBookEntry pbEntry : pb.PricebookEntries) {

                        if(pbEntry.Product2.ProductCode == PRTProduct) {
                            
                            OpportunityLineItem newOppLi = OpportunityUtilities.addOpportunityLineItem(o, pbEntry, o.Number_of_PRT__c - includedPRT);
                            mapInsertSObject.put(pbEntry.Id, newOppLi);
                        }
                    }
                }
                
            }

            SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.updatePRTProductForNumberOfPRTChange');
            if(!mapUpdateSObject.isEmpty() || !mapInsertSObject.isEmpty() || !mapDeleteSObject.isEmpty()) OpportunityTriggerHandler.oppDataMap = OpportunityUtilities.getOppData(newOppDataMap.keySet());
            FlowControl.inClass1 = false;
        }
    }*/

    public static void updateOppLiContractDates(Map<ID, Opportunity> newOppDataMap) {

    	Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

    	for(Opportunity o : newOppDataMap.values()) {

    		for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

    			oppLi.RecurSoft__Contract_Term_Start_Date_New__c = o.RecurSoft__Contract_Term_Start_Date__c;
    			oppLi.RecurSoft__Contract_Term_End_Date_Editable__c = o.RecurSoft__Contract_Term_End_Date__c;
    			mapUpdateSObject.put(oppLi.Id, oppLi);
    		}
    	}

    	SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.updateOppLiContractStartDate');
    }

    /*public static void createAssetForClosedOpps(Map<ID, Opportunity> newOppDataMap, Map<Id, Account> relatedAccountsMap) {

    	Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
    	Set<String> currentAssets = new Set<String>();
    	Set<String> eligibleAssets = new Set<String>{'SR Platform','Healthgrades','Limelight','SR Conversations','SR Smart Reviews'};
    	String currentAssetName = '';
    	String assetFamilyName = '';

    	for(Opportunity o : newOppDataMap.values()) {

    		if(o.RecordType.Name != 'New Practice Business' &&
                o.RecordType.Name != 'Enterprise New Business' &&
    			o.RecordType.Name != 'Healthgrades' &&
    			o.RecordType.Name != 'Add Product' &&
                o.RecordType.Name != 'Add-On Business') continue;

    		Account acct = relatedAccountsMap.get(o.AccountId);
    		currentAssets.clear();

    		if(acct.Assets.size() > 0) {

    			for(Asset a2 : acct.Assets) {

    				currentAssetName = a2.Product2.Family == 'Healthgrades' ? 'Healthgrades - ' + 
    					a2.Provider__r.Healthgrades_Id__c.replaceAll('(https?:\\/\\/)?(www\\.healthgrades\\.com\\/(\\w)+\\/)', '') : 
    					a2.Product2.Family;
    				currentAssets.add(currentAssetName);
    			}
    		}

    		for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

    			if(oppLi.PricebookEntry.Product2.Family == null || !eligibleAssets.contains(oppLi.PricebookEntry.Product2.Family)) continue;

    			assetFamilyName = oppLi.PricebookEntry.Product2.Family == 'Healthgrades' ? 'Healthgrades - ' + 
    				oppLi.Provider__r.Healthgrades_Id__c.replaceAll('(https?:\\/\\/)?(www\\.healthgrades\\.com\\/(\\w)+\\/)', '') : 
    				oppLi.PricebookEntry.Product2.Family;

    			if(!currentAssets.contains(assetFamilyName)) {

    				Asset a = new Asset(AccountId = o.AccountId,
    					Name = o.Account.Subscriber_Id__c + ': ' + assetFamilyName,
                        Most_Recent_Pricebook__c = o.Pricebook2Id,
    					Price = oppLi.UnitPrice,
    					Product2Id = oppLi.PricebookEntry.Product2Id,
    					Quantity = oppLi.Quantity,
                        Original_Contract_Signed_Date__c = o.RecurSoft__Contract_Signed_Date__c,
                        Trial_End_Date__c = oppLi.Trial_End_Date__c,
    					Status = 'Active',
    					Provider__c = oppLi.Provider__c == null ? null : oppLi.Provider__c);

    				mapInsertSObject.put(oppLi.Id, a);
    			}
    		}
    	}

    	SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.createAssetForClosedOpps');
    }

    public static void setOppLiFreeMonths(Map<Id, Opportunity> oppDataMap) {

    	Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
    	Integer oppFreeMonths;

    	for(Opportunity o : oppDataMap.values()) {

    		oppFreeMonths = o.RecurSoft__Number_of_Free_Months__c == null ? 0 : Integer.valueOf(o.RecurSoft__Number_of_Free_Months__c);

    		for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

				if(oppLi.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c != 'One-Time') {
					
					if(oppLi.Base_Contract_Term__c != null &&
						oppLi.Base_Contract_Term__c <= oppFreeMonths &&
						o.RecurSoft__Free_Months_Setting__c != 'Extend Contract - At the Beginning') continue;

					oppLi.Number_of_Free_Months__c = oppFreeMonths;
					oppLi.Free_Month_Setting__c = o.RecurSoft__Free_Months_Setting__c;
					mapUpdateSObject.put(oppLi.Id, oppLi);
				}
			}
    	}

    	SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.setOppLiFreeMonths');
    }

    public static void setOppLiTrial(Map<Id, Opportunity> oppDataMap) {

    	Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

    	for(Opportunity o : oppDataMap.values()) {

    		for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

				if(oppLi.PricebookEntry.Product2.ProductCode == '3000') {

					oppLi.Trial__c = o.RecurSoft__Trial__c;
					mapUpdateSObject.put(oppLi.Id, oppLi);
				}
			}
    	}

    	SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.setOppLiFreeMonths');
    }*/

    public static void setOppLiBaseTerm(Map<Id, Opportunity> oppDataMap) {

    	Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

    	for(Opportunity o : oppDataMap.values()) {

    		for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

				oppLi.Base_Contract_Term__c = oppLi.Co_Terminate__c ? o.RecurSoft__Initial_Contract_Term__c : oppLi.Base_Contract_Term__c;
				mapUpdateSObject.put(oppLi.Id, oppLi);
			}
    	}

    	SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.setOppLiFreeMonths');
    }

    public static void setModifiedSubscription(Opportunity[] updatedOpps) {

    	Map<Id, OpportunityLineItem> oppLiDataMap = new Map<Id, OpportunityLineItem>();

    	for(Opportunity o : updatedOpps) {

    		if(o.RecordType.Name == 'Retention' || o.RecordType.Name == 'Add-On Business') {

    			for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

    				oppLiDataMap.put(oppLi.Id, oppLi);
    			}
    		}
    	}

    	if(!oppLiDataMap.isEmpty()) OppLineItemUtilities.setModifiedSubscription(oppLiDataMap.values(), oppLiDataMap, true);
    }

    /*public static void setBillingEmailFromBillToContact(Map<Id, Opportunity> oppDataMap, Map<Id, Account> relatedAccountsMap) {

    	Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
    	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

    	for(Opportunity o : oppDataMap.values()) {

    		if(!relatedAccountsMap.containsKey(o.AccountId)) continue;

    		if(o.RecurSoft__Billing_Contact__r.Email != null) {

    			Account a = relatedAccountsMap.get(o.AccountId);
    			a.RecurSoft__Billing_Email__c = o.RecurSoft__Billing_Contact__r.Email;
    			mapUpdateSObject.put(a.Id, a);
    		}
    	}

    	SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.setBillingEmailFromBillToContact');
    }

    public static void scheduleOpportunitySync(Opportunity[] updatedOpps, Map<Id, Opportunity> oldOppMap, Boolean isUpdate) {

		Set<Id> idsToProcess = new Set<Id>();

		for(Opportunity o : updatedOpps) {

			if(!isUpdate 
				&& o.Contract_Signed__c != null
				&& o.Contract_Signed__c 
				&& o.RecordType.Name != 'Healthgrades') {

				idsToProcess.add(o.Id);
			
			} else if(o.Contract_Signed__c != null 
				&& !oldOppMap.get(o.Id).Contract_Signed__c 
				&& o.Contract_Signed__c
				&& o.RecordType.Name != 'Healthgrades') {

				idsToProcess.add(o.Id);
			}
		}

		if(idsToProcess.size() > 0 && !System.isBatch() && !System.isFuture() && !FlowControl.opportunityAppAdminSyncRecursion) {

	        FlowControl.opportunityAppAdminSyncRecursion = true;
	        AppAdminAPIClass.syncOpportunityAppAdmin(idsToProcess);
	    }
	}

    public static void newActivationCase(Map<Id, Opportunity> oldOppMap, Opportunity[] updatedOpps) {

        Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
        Map<Id, Opportunity> oppDataMap = getOppData(oldOppMap.keySet());
        String LL_QUEUE_ID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Limelight Onboarding Queue'].Id;
        Boolean hasSR = false;
        Boolean hasLL = false;
        Boolean hasHG = false;
        Set<Id> providerIds = new Set<Id>();

		for(Opportunity o : updatedOpps) {

            if(!oppDataMap.containsKey(o.Id)) continue;

            Opportunity o2 = oppDataMap.get(o.Id);
            hasSR = false;
            hasLL = false;
            hasHG = false;

            if(oldOppMap.get(o.Id).Contract_Signed__c == false 
                    && o.Contract_Signed__c == true) {
                
                for(OpportunityLineItem oppLi : o2.OpportunityLineItems) {

                    if(oppLi.PricebookEntry.Product2.Family == 'SR Platform') hasSR = true;
                    if(oppLi.PricebookEntry.Product2.Family == 'Limelight') hasLL = true;
                    if(oppLi.PricebookEntry.Product2.Family == 'Healthgrades') providerIds.add(oppLi.Provider__c);
                }

                if(hasSR) {

    				Case newCase = new Case(Subject = 'Activation case for ' + o.Account.Name,
    					AccountId = o.AccountId,
    					Related_Opportunity__c = o.Id,
    					ContactId = o.RecurSoft__Billing_Contact__c,
    					RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Activation').getRecordTypeId(),
    					Status = 'New',
    					Priority = 'Medium',
    					Origin = 'Web',
    					OwnerId = Label.ActivationCaseOwner);

    				mapInsertSObject.put(o.Id, newCase);
    			
                } 

                if(hasLL) {

                    Case newCase = new Case(Subject = 'Limelight Implementation',
                        AccountId = o.AccountId,
                        RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId(),
                        Product__c = 'Limelight',
                        Origin = 'Web',
                        Category__c = 'Training',
                        Features_Options__c = 'Limelight',
                        Main_Issue__c = 'Install',
                        Topics__c = 'General Training',
                        OwnerId = LL_QUEUE_ID);

                    mapInsertSObject.put(LL_QUEUE_ID, newCase);
                }
            }
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.newOpportunityCase');
        if(!providerIds.isEmpty()) newHealthgradesCase(providerIds);
	}

    public static void newHealthgradesCase(Set<Id> providerIds) {

        String HG_QUEUE_ID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Healthgrades Onboarding Queue'].Id;
        Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
        Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
        Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
        Map<Id, Provider__c> providerMap = getProviderData(providerIds);

        for(Provider__c p : providerMap.values()) {

            Case newCase = new Case(Subject = 'Healthgrades Implementation: ' + p.Name,
                AccountId = p.Bill_to_Account__c,
                ContactId = p.Related_Contact__c,
                Provider__c = p.Id,
                RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId(),
                Product__c = 'Healthgrades',
                Origin = 'Web',
                Category__c = 'Training',
                Features_Options__c = 'Healthgrades',
                Main_Issue__c = 'Need help with Implementation',
                Topics__c = 'General Training',
                Description = 'Healthgrades URL: ' + p.Healthgrades_ID__c + '\n' + 'Provider NPI: ' + p.NPI__c,
                OwnerId = HG_QUEUE_ID);

            mapInsertSObject.put(p.Id, newCase);
        }

        SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'ProviderUtilities.newHealthgradesCase');
    }*/

	/*public static void addPackageProducts(Set<Id> idsToProcess) {

		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

		Map<Id, Opportunity> oppDataMap = getOppData(idsToProcess);
		Map<Id, Pricebook2> pBookMap = new Map<Id, Pricebook2>(PricebooksSelector.newInstance().selectAllWithPricebookEntries());

		for(Opportunity o : oppDataMap.values()) {

			if(o.RecordType.Name != 'New Practice Business') continue;
			if(o.Pricebook2Id == null) continue;
			if(o.HasOpportunityLineItem) continue;
			if(!pBookMap.containsKey(o.PriceBook2Id)) continue;

			Pricebook2 pb = pBookMap.get(o.Pricebook2Id);

			for(PriceBookEntry pbEntry : pb.PriceBookEntries) {

				if(pbEntry.Auto_Add__c) {

					if(pbEntry.Product2.Family == 'Limelight') {

						if(o.Account.Practice_Management_Software__r.Limelight_Available__c) {

							OpportunityLineItem newOppLi = OpportunitiesService.addOpportunityLineItem(o, pbEntry, pbEntry.Auto_Add_Quantity__c);
	    					
	    					if(pbEntry.Auto_Add_Free_Months__c > 0) {
	    						newOppLi.Number_of_Free_Months__c = pbEntry.Auto_Add_Free_Months__c;
	    						newOppLi.Free_Month_Setting__c = pbEntry.Auto_Add_Free_Month_Setting__c;
	    					}

	    					if(pbEntry.Auto_Add_Trial__c != null) newOppLi.Trial__c = pbEntry.Auto_Add_Trial__c;
                            if(pbEntry.Auto_Add_Price__c != null) newOppLi.UnitPrice = pbEntry.Auto_Add_Price__c;
	    					mapInsertSObject.put(pbEntry.Id, newOppLi);
	    				}
					
					} else {

						OpportunityLineItem newOppLi = OpportunitiesService.addOpportunityLineItem(o, pbEntry, pbEntry.Auto_Add_Quantity__c);
	    				
	    				if(pbEntry.PriceBook2.Name == '2. SR Elite' && pbEntry.Product2.ProductCode == '3100' && o.Account.Practice_Management_Software__r.Limelight_Available__c) {
	    					newOppLi.UnitPrice += (80 * -1);
	    					newOppLi.List_Price_Override__c = newOppLi.UnitPrice;
	    				}

	    				if(pbEntry.Auto_Add_Free_Months__c > 0) {
	    					newOppLi.Number_of_Free_Months__c = pbEntry.Auto_Add_Free_Months__c;
	    					newOppLi.Free_Month_Setting__c = pbEntry.Auto_Add_Free_Month_Setting__c;
	    				} 

	    				if(pbEntry.Auto_Add_Trial__c != null) newOppLi.Trial__c = pbEntry.Auto_Add_Trial__c;
                        if(pbEntry.Auto_Add_Price__c != null) newOppLi.UnitPrice = pbEntry.Auto_Add_Price__c;
	    				mapInsertSObject.put(pbEntry.Id, newOppLi);
					}	
				}
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'OpportunityUtilities.addPackageProducts');
	}*/

	@InvocableMethod(label='insertOpps' description='Insert Opportunities passed from a flow')
    public static Id[] flowCreateOpp(Opportunity[] opps) {

    	for(Opportunity o : opps) {
    		
    		o.Id = null;
    		o.StageName = 'Qualified';
    		o.RecurSoft__Trial__c = null;
    		o.RecurSoft__Number_of_Free_Months__c = '0';
    		o.RecurSoft__Free_Months_Setting__c = null;
    	}

    	Database.SaveResult[] results = Database.insert(opps);
    	Id[] oppIds = new List<Id>();
    	
    	for(Database.SaveResult result : results) {
    		
    		if(result.isSuccess()) {
    			
    			oppIds.add(result.getId());
    		}
    	}

    	return oppIds;
    }
}