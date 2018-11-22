public with sharing class AssetSyncButton_Controller {

    private final Asset a;
    public Set<Id> assetIds = new Set<Id>();

    public AssetSyncButton_Controller(ApexPages.StandardController stdController) {
        
        a = (Asset)stdController.getRecord();
        assetIds.add(a.Id);
    }
     
    public PageReference autoRun() {
 
        String assetId = ApexPages.currentPage().getParameters().get('id');

        if(!assetIds.isEmpty() && assetId != null) {

			AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c = AsyncMain.TYPE_APPADMIN_ASSETSYNC, 
				Params__c = assetId);
			insert ar;

         	PageReference pageRef = new PageReference('/' + assetId);
	        pageRef.setRedirect(true);
	        return pageRef;

        } else {

        	return null;
        }
    }
}