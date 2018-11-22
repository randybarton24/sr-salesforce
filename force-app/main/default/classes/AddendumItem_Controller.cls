public with sharing class AddendumItem_Controller extends WebFormsUtilityClass {
	
	private ApexPages.StandardController stdController;
	public Addendum__c addm { get; set; }
	public Asset[] listAssets { get; set; }
	public Addendum_Line_Item__c[] listAddmItems { get; set; }
	public Boolean renderAddRemove { get; set; }
	public Boolean error { get; set; }
	public Id acctId { get; set; }
	public WrappedAsset[] wrapAssetOptions { get; set; }
	public WrappedAsset[] wrapAssetSelections { get; set; }
	public WrappedAddendumItem[] wrapAddmItemOptions { get; set; }
	public WrappedAddendumItem[] wrapAddmItemSelections { get; set; }
	Set<Id> assetIds = new Set<Id>();
	Map<Id, Account> acctMap;
	
	public AddendumItem_Controller(ApexPages.StandardController stdController) {
		
		this.stdController = stdController;
		this.addm = (Addendum__c)stdController.getRecord();
		renderAddRemove = false;
		error = false;
		
        try{

	    acctId = [SELECT Account__c FROM Addendum__c WHERE Id = :addm.Id].Account__c;
	    
	    listAssets = [SELECT Id,
	    	Name,
	    	AccountId,
	    	Product2.Family,
	    	Current_Product_Subscription__c
	    	FROM Asset
			WHERE Current_Product_Subscription__c != null 
			AND AccountId = :acctId];

		listAddmItems = [SELECT Id,
	    	Asset__r.Name,
	    	Asset__r.Product2.Family
	    	FROM Addendum_Line_Item__c
			WHERE Addendum__c = :addm.Id];

		acctMap = new Map<Id, Account>(
			[SELECT Id,
			(SELECT Id, 
				Product2.Family, 
				Current_Product_Subscription__c
				FROM Assets
				WHERE Product2.Family = 'SR Platform')
			FROM Account
			WHERE Id = :acctId]);

		for(Addendum_Line_Item__c ali : listAddmItems) {

			assetIds.add(ali.Asset__c);
		}

		} catch(Exception e) {

			System.debug(e);
		}
	}

	public PageReference addRemove() {

		wrapAssetOptions = getWrapAssetOptions();
		wrapAddmItemOptions = getwrapAddmItemOptions();
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
		wrapAddmItemSelections = getwrapAddmItemSelections();
		System.debug(wrapAssetSelections);
		System.debug(wrapAddmItemSelections);

		if(!hasError) {

			if(!wrapAssetSelections.isEmpty()) {

				for(WrappedAsset wa : wrapAssetSelections) {

					Addendum_Line_Item__c ali = new Addendum_Line_Item__c(Asset__c = wa.asset.Id,
						Addendum__c = addm.Id);
					mapInsertSObject.put(wa.asset.Id, ali);
				}
			}

			if(!wrapAddmItemSelections.isEmpty()) {

				for(WrappedAddendumItem wcr : wrapAddmItemSelections) {

					mapDeleteSObject.put(wcr.AddendumLineItem.Id, wcr.AddendumLineItem);
				}
			}

			SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'AddendumItem_Controller');
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

	public WrappedAddendumItem[] getwrapAddmItemOptions() {

		wrapAddmItemOptions = new List<WrappedAddendumItem>();

		for(Addendum_Line_Item__c ali : listAddmItems) {

			wrapAddmItemOptions.add(new WrappedAddendumItem(ali));
		}
		
		return wrapAddmItemOptions;
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

	public WrappedAddendumItem[] getwrapAddmItemSelections() {

		wrapAddmItemSelections = new List<WrappedAddendumItem>();

		for(WrappedAddendumItem wrapAddendumLineItem : wrapAddmItemOptions) {

			if(wrapAddendumLineItem.isChecked) {

				wrapAddmItemSelections.add(wrapAddendumLineItem);
			}
		}
		
		return wrapAddmItemSelections;
	}

	public class WrappedAsset {

		public Asset asset { get; set; }
		public Boolean isChecked { get; set; }

		public WrappedAsset(Asset ast) {

			asset = ast;	
			isChecked = false;
		}
	}

	public class WrappedAddendumItem {

		public Addendum_Line_Item__c addendumLineItem { get; set; }
		public Boolean isChecked { get; set; }

		public WrappedAddendumItem(Addendum_Line_Item__c ali) {

			addendumLineItem = ali;	
			isChecked = false;
		}
	}
}