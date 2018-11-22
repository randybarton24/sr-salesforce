public with sharing class AssetTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    //private static final Map<String, Id> StaticAssetRecordTypes = RecordTypes.GetRecordTypeIdDevMap('Asset');

    public AssetTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    //public void OnBeforeInsert(Asset[] newAssets){

        
    //    if(!FlowControl.assetBeforeInsertRecursion) {
    //        FlowControl.assetBeforeInsertRecursion = true;
    //    }
    //}

    //public void OnAfterInsert(Asset[] newAssets, Map<Id, Asset> newAssetMap){

    //    FlowControl.inAssetAfterInsert = true;

    //    if(!FlowControl.assetAfterInsertRecursion) {
    //        FlowControl.assetAfterInsertRecursion = true;
    //    }

    //    FlowControl.inAssetAfterInsert = false;
    //}

    //@future public static void OnAfterInsertAsync(Set<ID> newAssetIDs){}

    public void OnBeforeUpdate(Asset[] oldAssets, Asset[] updatedAssets, Map<ID, Asset> oldAssetMap, Map<ID, Asset> newAssetMap){

    	FlowControl.checkAssetFieldChanges(updatedAssets, oldAssetMap);

        if(FlowControl.fieldChangeIdMap.containsKey('AssetSubscription_Last_Modified_Date__c')) {

            AssetUtilities.setCurrentSubscription(updatedAssets, newAssetMap);
        }

        FlowControl.checkAssetFieldChanges(updatedAssets, oldAssetMap);

        if(FlowControl.fieldChangeIdMap.containsKey('AssetActive__c')) {

            //AssetUtilities.newAssetCase(oldAssetMap, updatedAssets);
            AssetUtilities.setProviderStatus(oldAssetMap, updatedAssets);
            AssetUtilities.scheduleAssetSync(updatedAssets, oldAssetMap, true);
            AssetUtilities.scheduleHGSync(updatedAssets, oldAssetMap, true);
        }

    //    if(!FlowControl.assetBeforeUpdateRecursion) {
    //        FlowControl.assetBeforeUpdateRecursion = true;
    //    }
    }

    //public void OnAfterUpdate(Asset[] oldAssets, Asset[] updatedAssets, Map<ID, Asset> oldAssetMap, Map<ID, Asset> newAssetMap){

    	
        //if(!FlowControl.assetAfterUpdateRecursion && !FlowControl.inAssetAfterInsert) {
        //    FlowControl.assetAfterUpdateRecursion = true;
        //}
    //}

    //@future public static void OnAfterUpdateAsync(Set<ID> updatedAssetIDs){}

    //public void OnBeforeDelete(Asset[] AssetsToDelete, Map<ID, Asset> oldAssetMap){
        
    //    AssetUtilities.blockAssetDelete(AssetsToDelete);
    //}

    //public void OnAfterDelete(Asset[] deletedAssets, Map<ID, Asset> oldAssetMap){}

    //@future public static void OnAfterDeleteAsync(Set<ID> deletedAssetIDs){}

    //public void OnUndelete(Asset[] restoredAssets){}

    //public boolean IsTriggerContext{
    //    get{ return m_isExecuting;}
    //}

    //public boolean IsVisualforcePageContext{
    //    get{ return !IsTriggerContext;}
    //}

    //public boolean IsWebServiceContext{
    //    get{ return !IsTriggerContext;}
    //}

    //public boolean IsExecuteAnonymousContext{
    //    get{ return !IsTriggerContext;}
    //}

}