public with sharing class HealthgradesSyncButtonController {

    private final Provider__c p;
    public Set<Id> providerIds = new Set<Id>();

    public HealthgradesSyncButtonController(ApexPages.StandardController stdController) {
        
        p = (Provider__c)stdController.getRecord();
        providerIds.add(p.Id);
    }
     
    public PageReference autoRun() {
 
        String providerId = ApexPages.currentPage().getParameters().get('id');

        if(!providerIds.isEmpty() && providerId != null) {
            
            AppAdminAPIClass.postHealthgradesStatus(providerIds);

         	PageReference pageRef = new PageReference('/' + providerId);
	        pageRef.setRedirect(true);
	        return pageRef;

        } else {

        	return null;
        }
    }
}