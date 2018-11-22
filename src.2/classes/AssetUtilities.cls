public with sharing class AssetUtilities {

	public static Map<Id, Product2> getRelatedProducts() {
		
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

	public static Map<Id, Asset> getRelatedSubscriptions(Map<Id, Asset> assetMap) {

		Map<Id, Asset> results = new Map<Id, Asset>(
			[SELECT Id,
			(SELECT Id
				FROM Product_Subscriptions__r 
				WHERE RecurSoft__Billing_Status__c = 'Regular Invoicing'
				ORDER BY RecurSoft__Contract_Term_End_Date__c DESC
				LIMIT 1)
			FROM Asset
			WHERE Id IN :assetMap.keySet()]);

		return results;
	}

	public static Map<Id, Provider__c> getProviderData(Set<Id> providerIds) {

        Map<Id, Provider__c> results = new Map<Id, Provider__c>([SELECT Id,
        Name,
        Bill_to_Account__c,
        Related_Contact__c,
        Healthgrades_ID__c,
        Premium_Member__c,
        NPI__c
        FROM Provider__c
        WHERE Id IN :providerIds]);

        return results;
    }

	public static void setCurrentSubscription(Asset[] updatedAssets, Map<Id, Asset> assetMap) {

		Map<Id, Asset> currentSubscriptionMap = getRelatedSubscriptions(assetMap);

		for(Asset ast : updatedAssets) {

			Asset ast2 = currentSubscriptionMap.get(ast.Id);

			if(ast2.Product_Subscriptions__r.isEmpty()) {

				ast.Current_Product_Subscription__c = null;
				ast.Active__c = false;

			} else {

				ast.Current_Product_Subscription__c = ast2.Product_Subscriptions__r[0].Id;
				ast.Active__c = true;
			}
		}
	}

	public static void scheduleAssetSync(Asset[] updatedAssets, Map<Id, Asset> oldAssetMap, Boolean isUpdate) {

		Set<Id> idsToProcess = new Set<Id>();

		for(Asset ast : updatedAssets) {

			if(!isUpdate && ast.Provider__c == null) {

				idsToProcess.add(ast.Id);
			
			} else if(ast.Active__c != oldAssetMap.get(ast.Id).Active__c && ast.Provider__c == null) {

				idsToProcess.add(ast.Id);
			}
		}

		if(idsToProcess.size() == 0) return;

		AsyncRequest__c[] newRequests = new List<AsyncRequest__c>();
		Id[] idsForRequest = new List<Id>();

		for(Id i : idsToProcess) {

			idsForRequest.add(i);

			if(idsForRequest.size() == 10) {

				newRequests.add(new AsyncRequest__c(AsyncType__c = AsyncMain.TYPE_APPADMIN_ASSETSYNC, 
					Params__c = String.join(idsForRequest, ',')));
				idsForRequest.clear();
			}
		}

		if(idsForRequest.size() > 0) {

			newRequests.add(new AsyncRequest__c(AsyncType__c = AsyncMain.TYPE_APPADMIN_ASSETSYNC, 
				Params__c = String.join(idsForRequest, ',')));
		}

		insert newRequests;
	}

	public static void scheduleHGSync(Asset[] updatedAssets, Map<Id, Asset> oldAssetMap, Boolean isUpdate) {

		Set<Id> idsToProcess = new Set<Id>();

		for(Asset ast : updatedAssets) {

			if(!isUpdate && ast.Provider__c != null) {

				idsToProcess.add(ast.Provider__c);
			
			} else if(ast.Active__c != oldAssetMap.get(ast.Id).Active__c && ast.Provider__c != null) {

				idsToProcess.add(ast.Provider__c);
			}
		}

		if(idsToProcess.size() == 0) return;

		AsyncRequest__c[] newRequests = new List<AsyncRequest__c>();
		Id[] idsForRequest = new List<Id>();

		for(Id i : idsToProcess) {

			idsForRequest.add(i);

			if(idsForRequest.size() == 10) {

				newRequests.add(new AsyncRequest__c(AsyncType__c = AsyncMain.TYPE_APPADMIN_HGSYNC, 
					Params__c = String.join(idsForRequest, ',')));
				idsForRequest.clear();
			}
		}

		if(idsForRequest.size() > 0) {

			newRequests.add(new AsyncRequest__c(AsyncType__c = AsyncMain.TYPE_APPADMIN_HGSYNC, 
				Params__c = String.join(idsForRequest, ',')));
		}

		insert newRequests;
	}

	public static void setProviderStatus(Map<Id, Asset> oldAssetMap, Asset[] updatedAssets) {

		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
      	Set<Id> providerIds = new Set<Id>();
      	Map<Id, Provider__c> providerMap = new Map<Id, Provider__c>();

      	for(Asset ast : updatedAssets) {

      		if(ast.Provider__c != null) providerIds.add(ast.Provider__c);
      	}

      	if(!providerIds.isEmpty()) {

      		providerMap = getProviderData(providerIds);

	      	for(Asset ast : updatedAssets) {

	      		if(ast.Provider__c == null || !providerMap.containsKey(ast.Provider__c)) continue;

	      		Provider__c p = providerMap.get(ast.Provider__c);
	      		
	      		if(ast.Active__c != p.Premium_Member__c) {

	      			p.Premium_Member__c = ast.Active__c;
	      			mapUpdateSObject.put(p.Id, p);
	      		}
	      	}
	    }

	    SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'AssetUtilities.setProviderStatus');
	}

	/*public static void newAssetCase(Map<Id, Asset> oldAssetMap, Asset[] updatedAssets) {

		String LL_QUEUE_ID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Limelight Onboarding Queue'].Id;
		Map<Id, Product2> productMap = getRelatedProducts();
		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

		for(Asset ast : updatedAssets) {

			Product2 relatedProduct = productMap.get(ast.Product2Id);

			if(oldAssetMap.get(ast.Id).Active__c == false && ast.Active__c == true && relatedProduct.Family == 'Limelight') {

				Case newCase = new Case(Subject = 'Limelight Implementation',
					AccountId = ast.AccountId,
					RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId(),
					Product__c = 'Limelight',
					Origin = 'Web',
					Category__c = 'Training',
					Topics__c = 'General Training',
					OwnerId = LL_QUEUE_ID);

				mapInsertSObject.put(ast.Id, newCase);
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'AssetUtilities.newAssetCase');
	}*/
}