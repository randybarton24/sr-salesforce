public with sharing class CancelRequest_Controller extends WebFormsUtilityClass {
	
	public Opportunity opp { get; set; }
	public Asset[] listAssets { get; set; }
	public Cancel_Request__c[] listCancelRequests { get; set; }
	public Boolean renderAddRemove { get; set; }
	public Boolean error { get; set; }
	public Id acctId { get; set; }
	public WrappedAsset[] wrapAssetOptions { get; set; }
	public WrappedAsset[] wrapAssetSelections { get; set; }
	public WrappedCancelRequest[] wrapCancelRequestOptions { get; set; }
	public WrappedCancelRequest[] wrapCancelRequestSelections { get; set; }
	Set<Id> assetIds = new Set<Id>();
	Map<Id, Account> acctMap;
	
	public CancelRequest_Controller(ApexPages.StandardController stdController) {
		
		this.opp = (Opportunity)stdController.getRecord();
		renderAddRemove = false;
		error = false;
		
        try{

	    acctId = [SELECT Accountid FROM Opportunity WHERE Id = :opp.Id].Accountid;
	    
	    listAssets = [SELECT Id,
	    	Name,
	    	AccountId,
	    	Product2.Family,
	    	Current_Product_Subscription__c
	    	FROM Asset
			WHERE AccountId = :acctId];

		listCancelRequests = [SELECT Id,
	    	Asset__r.Name,
	    	Asset__r.Product2.Family
	    	FROM Cancel_Request__c
			WHERE Opportunity__c = :opp.Id];

		acctMap = new Map<Id, Account>(
			[SELECT Id,
			(SELECT Id, 
				Product2.Family, 
				Current_Product_Subscription__c
				FROM Assets
				WHERE Product2.Family = 'SR Platform')
			FROM Account
			WHERE Id = :acctId]);

		for(Cancel_Request__c cr : listCancelRequests) {

			assetIds.add(cr.Asset__c);
		}

		} catch(Exception e) {

			System.debug(e);
		}
	}

	public PageReference addRemove() {

		wrapAssetOptions = getWrapAssetOptions();
		wrapCancelRequestOptions = getWrapCancelRequestOptions();
		renderAddRemove = true;
		return null;
	}

	public PageReference cancel() {

		renderAddRemove = false;
		return null;
	}

	public PageReference saveAddRemove() {

		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
		Boolean hasError = false;

		wrapAssetSelections = getWrapAssetSelections();
		wrapCancelRequestSelections = getWrapCancelRequestSelections();
		System.debug(wrapAssetSelections);
		System.debug(wrapCancelRequestSelections);

		if(!hasError) {

			if(!wrapAssetSelections.isEmpty()) {

				for(WrappedAsset wa : wrapAssetSelections) {

					Id recordTypeId = SRUtilities.getRecordTypeMap('Cancel_Request__c').containsKey(wa.asset.Product2.Family) ? 
						SRUtilities.getRecordTypeMap('Cancel_Request__c').get(wa.asset.Product2.Family).getRecordTypeId() :
						SRUtilities.getRecordTypeMap('Cancel_Request__c').get('SR Platform').getRecordTypeId();

					Id currentSR = acctMap.get(wa.asset.AccountId).Assets.isEmpty() ? null : acctMap.get(wa.asset.AccountId).Assets[0].Current_Product_Subscription__c;

					Cancel_Request__c cr = new Cancel_Request__c(Asset__c = wa.asset.Id,
						Opportunity__c = opp.Id,
						RecordTypeId = recordTypeId,
						Modified_Subscription__c = wa.asset.Current_Product_Subscription__c,
						Current_SR_Subscription__c = currentSR);
					mapInsertSObject.put(wa.asset.Id, cr);
				}
			}

			if(!wrapCancelRequestSelections.isEmpty()) {

				for(WrappedCancelRequest wcr : wrapCancelRequestSelections) {

					mapDeleteSObject.put(wcr.CancelRequest.Id, wcr.CancelRequest);
				}
			}

			SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'CancelRequest_Controller');
			return null;

		} else {

			error = true;
			renderAddRemove = true;
			return null;
		}
	}

	public WrappedAsset[] getWrapAssetOptions() {

		wrapAssetOptions = new List<WrappedAsset>();

		for(Asset ast : listAssets) {

			if(assetIds.contains(ast.Id)) continue;

			wrapAssetOptions.add(new WrappedAsset(ast));
		}
		
		return wrapAssetOptions;
	}

	public WrappedCancelRequest[] getWrapCancelRequestOptions() {

		wrapCancelRequestOptions = new List<WrappedCancelRequest>();

		for(Cancel_Request__c cr : listCancelRequests) {

			wrapCancelRequestOptions.add(new WrappedCancelRequest(cr));
		}
		
		return wrapCancelRequestOptions;
	}

	public WrappedAsset[] getWrapAssetSelections() {

		wrapAssetSelections = new List<WrappedAsset>();

		for(WrappedAsset wrapAsset : wrapAssetOptions) {

			System.debug(wrapAsset);
			if(wrapAsset.isChecked) {

				wrapAssetSelections.add(wrapAsset);
			}
		}
		
		return wrapAssetSelections;
	}

	public WrappedCancelRequest[] getWrapCancelRequestSelections() {

		wrapCancelRequestSelections = new List<WrappedCancelRequest>();

		for(WrappedCancelRequest wrapCancelRequest : wrapCancelRequestOptions) {

			if(wrapCancelRequest.isChecked) {

				wrapCancelRequestSelections.add(wrapCancelRequest);
			}
		}
		
		return wrapCancelRequestSelections;
	}

	public class WrappedAsset {

		public Asset asset { get; set; }
		public Boolean isChecked { get; set; }

		public WrappedAsset(Asset ast) {

			asset = ast;	
			isChecked = false;
		}
	}

	public class WrappedCancelRequest {

		public Cancel_Request__c cancelRequest { get; set; }
		public Boolean isChecked { get; set; }

		public WrappedCancelRequest(Cancel_Request__c cr) {

			cancelRequest = cr;	
			isChecked = false;
		}
	}
}