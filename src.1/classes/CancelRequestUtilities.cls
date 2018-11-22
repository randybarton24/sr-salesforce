public with sharing class CancelRequestUtilities {

	public static Map<Id, Asset> getRelatedAssetMap(Cancel_Request__c[] newList) {

		Set<Id> assetIds = new Set<Id>();

    	for(Cancel_Request__c cr : newList) {

    		assetIds.add(cr.Asset__c);
    	}

    	Map<Id, Asset> results = new Map<Id, Asset>(
    		[SELECT Id,
    		Name,
    		AccountId,
			Product2.Family, 
			Provider__r.Healthgrades_Id__c
    		FROM Asset 
    		WHERE Id IN: assetIds]);

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

	public static Map<Id, Opportunity> getRelatedOpps(Set<Id> idsToProcess) {
		
		Map<ID, Opportunity> results = new Map<ID, Opportunity> (
			[SELECT Id,
			(SELECT Id, 
				Stage__c
				FROM OpportunityAssets__r) 
			FROM Opportunity
			WHERE Id IN :idsToProcess]);

		return results;
	}

	public static Map<Id, Account> getRelatedAcctMap(Asset[] relatedAssetsList) {

		Set<Id> acctIds = new Set<Id>();

		for(Asset ast : relatedAssetsList) {

			acctIds.add(ast.AccountId);
		} 

		Map<Id, Account> results = new Map<Id, Account>(
			[SELECT Id,
			RecurSoft__Status__c,
			Subscriber_Id__c,
			(SELECT Id, 
				Product2.Family, 
				Current_Product_Subscription__c
				FROM Assets
				WHERE Product2.Family = 'SR Platform'),
			(SELECT Id,
				RecordType.Name,
				StageName
				FROM
				Opportunities 
				WHERE RecordType.Name = 'Add-On Business'
				AND StageName != 'Closed Won')
			FROM Account
			WHERE Id IN :acctIds]);

		return results;
	}

	public static Map<Id, Cancel_Request__c> getCrData(Cancel_Request__c[] updatedCR) {

		Set<Id> crIds = new Set<Id>();

		for(Cancel_Request__c cr : updatedCR) {

			crIds.add(cr.Id);
		}

		Map<Id, Cancel_Request__c> results = new Map<Id, Cancel_Request__c>(
			[SELECT Id,
			Asset__c,
			Asset__r.Product2.Family,
			Asset__r.AccountId,
			Asset__r.Current_Product_Subscription__c
			FROM Cancel_Request__c
			WHERE Id IN :crIds]);

		return results;
	}

	public static void setCrRecordType(Cancel_Request__c[] updatedCR) {

		Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();

		Map<Id, Cancel_Request__c> crDataMap = getCrData(updatedCR);

		for(Cancel_Request__c cr : updatedCR) {

			Cancel_Request__c cr2 = crDataMap.get(cr.Id);

			if(SRUtilities.getRecordTypeMap('Cancel_Request__c').containsKey(cr2.Asset__r.Product2.Family)) {

				cr.RecordTypeId = SRUtilities.getRecordTypeMap('Cancel_Request__c').get(cr2.Asset__r.Product2.Family).getRecordTypeId();
				mapUpdateSObject.put(cr.Id, cr);
			
			} else {

				cr.RecordTypeId = SRUtilities.getRecordTypeMap('Cancel_Request__c').get('SR Platform').getRecordTypeId();
				mapUpdateSObject.put(cr.Id, cr);
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'CancelRequestUtilities.setCrRecordType');
	}

	public static void setModifiedSubscription(Cancel_Request__c[] updatedCR, Map<Id, Cancel_Request__c> oldMap) {

		Map<Id, Cancel_Request__c> crDataMap = getCrData(updatedCR);
		Map<Id, Asset> relatedAssetsMap = getRelatedAssetMap(updatedCR);
		Map<Id, Account> relatedAcctMap = getRelatedAcctMap(relatedAssetsMap.values());

		for(Cancel_Request__c cr : updatedCR) {

			if(!crDataMap.containsKey(cr.Id)) continue;
			Cancel_Request__c cr3 = oldMap.containsKey(cr.Id) ? oldMap.get(cr.Id) : new Cancel_Request__c();

			Cancel_Request__c cr2 = crDataMap.get(cr.Id);
			Account a = relatedAcctMap.get(cr2.Asset__r.AccountId);

			
			if(cr3.Stage__c != 'Save' 
				&& cr3.Stage__c != 'Cancelled'
				&& cr3.Stage__c != 'No Sale'
				&& cr3.Stage__c != 'Resume - No Change'
				&& !cr.Override_Modified_Subscription__c
				&& cr.Modified_Subscription__c != cr2.Asset__r.Current_Product_Subscription__c
				&& cr2.Asset__r.Current_Product_Subscription__c != null) {

				cr.Modified_Subscription__c = cr2.Asset__r.Current_Product_Subscription__c;
			}

			if(cr3.Stage__c != 'Save' 
				&& cr3.Stage__c != 'Cancelled'
				&& cr3.Stage__c != 'No Sale'
				&& cr3.Stage__c != 'Resume - No Change'
				&& !cr.Override_Current_SR_Subscription__c 
				&& !a.Assets.isEmpty()
				&& cr.Current_SR_Subscription__c != a.Assets[0].Current_Product_Subscription__c
				&& a.Assets[0].Current_Product_Subscription__c != null) {

				cr.Current_SR_Subscription__c = a.Assets[0].Current_Product_Subscription__c;
			}
		}
	}

	/*public static void createAssetTransaction(Cancel_Request__c[] newList) {

		Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();
		Map<Id, Asset> relatedAssetsMap = getRelatedAssetMap(newList);

		for(Cancel_Request__c cr : newList) {

			Asset ast = relatedAssetsMap.get(cr.Asset__c);

			if(ast.Number_of_Cancel_Requests__c > ast.Number_of_Cancel_Resolutions__c) continue;

			Transaction__c t = new Transaction__c(Asset__c = ast.Id,
				Transaction_Date__c = Date.today(),
				Type__c = 'Cancel Request');
			mapInsertSObject.put(ast.Id, t);
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'CancelRequestUtilities.createAssetTransaction');
	}*/

	public static void createAddendumOpp(Cancel_Request__c[] newList) {

		Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();
		Map<Id, Asset> relatedAssetsMap = getRelatedAssetMap(newList);
		Map<Id, Account> relatedAcctMap = getRelatedAcctMap(relatedAssetsMap.values());

		for(Cancel_Request__c cr : newList) {

			if(cr.Stage__c != 'Save') continue;

			Asset ast = relatedAssetsMap.get(cr.Asset__c);
			Account a = relatedAcctMap.get(ast.AccountId);

			Opportunity o = new Opportunity(RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId(),
				AccountId = ast.AccountId,
				Description = cr.Notes_for_Accounting__c,
				CloseDate = Date.today(),
				StageName = 'Qualified',
				Name = ast.Name + ' - ' + cr.Cancel_Request_Type__c + ' Save',
				OwnerId = '005i0000002gn9T');
			
			if(!FlowControl.recordsCreated.contains(cr.Id + 'Opportunity')) {

				FlowControl.recordsCreated.add(cr.Id + 'Opportunity');
				mapInsertSObject.put(a.Id, o);
			}
		}

		SRUtilities.runDmlNoLock(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'CancelRequestUtilities.createAddendumOpp');
	}

	public static void createCancelCase(Cancel_Request__c[] newList) {

		Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();
		Map<Id, Asset> relatedAssetsMap = getRelatedAssetMap(newList);
		Map<Id, Account> relatedAcctMap = getRelatedAcctMap(relatedAssetsMap.values());
		Map<Id, String> closeAllCancelRequestsIdMap = new Map<Id, String>();

		for(Cancel_Request__c cr : newList) {

			if(cr.Stage__c != 'Cancelled' && cr.Stage__c != 'No Sale') continue;

			Asset ast = relatedAssetsMap.get(cr.Asset__c);
			Account a = relatedAcctMap.get(ast.AccountId);

//  This is being handled by a batch process after the Cancel Month
//			if(ast.Product2.Family == 'SR Platform') {
//
//				//closeAllCancelRequestsIdMap.put(cr.Opportunity__c, cr.Stage__c);
//				a.RecurSoft__Status__c = cr.Stage__c;
//
//				mapUpdateSObject.put(a.Id, a);
//			}


			String type = cr.Stage__c == 'Cancelled' ? cr.Cancel_Request_Type__c + ' Cancel' : 'No Sale';
			String subject = type == 'Annual Cancel' ? 'Turn off any Renewals' : type == 'Trial Cancel' ? '' : 'Refund MSF and Setup';

			Case c = new Case(RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Accounting').getRecordTypeId(),
				AccountId = ast.AccountId,
				Description = cr.Notes_for_Accounting__c,
				Origin = 'Phone',
				OwnerId = '00Gi00000034JUX',
				Reason = type,
				Related_Opportunity__c = cr.Opportunity__c,
				Subject = ast.Name + ' - ' + type + ' - ' + subject);

			if(!FlowControl.recordsCreated.contains(cr.Id + 'Case')) {

				FlowControl.recordsCreated.add(cr.Id + 'Case');
				mapInsertSObject.put(ast.Id, c);
			}	
		}

		//if(!System.isBatch() && !System.isFuture() && !closeAllCancelRequestsIdMap.isEmpty()) closeAllCancelRequests(closeAllCancelRequestsIdMap);

		SRUtilities.runDmlNoLock(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'CancelRequestUtilities.createCancelCase');
	}

	@future
	public static void closeAllCancelRequests(Map<Id, String> mapToProcess) {

		Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
		Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();
		Map<Id, Opportunity> relatedOppMap = getRelatedOpps(mapToProcess.keySet());

		for(Opportunity o : relatedOppMap.values()) {

			String stageName = mapToProcess.get(o.Id);

			for(Cancel_Request__c cr : o.OpportunityAssets__r) {

				if(cr.Stage__c != stageName) {

					cr.Stage__c = stageName;
					mapUpdateSObject.put(cr.Id, cr);
				}
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'CancelRequestUtilities.closeAllCancelRequests');
	}
}