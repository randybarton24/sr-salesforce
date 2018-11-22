public with sharing class ProviderTriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	//private static final Map<String, Id> StaticProviderRecordTypes = RecordTypes.GetRecordTypeIdDevMap('Provider__c');
	public static Map<ID, Account> relatedAccountMap = new Map<ID, Account>();

	public ProviderTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnBeforeInsert(Provider__c[] newProviders){

		if(!FlowControl.providerBeforeInsertRecursion) {
			FlowControl.providerBeforeInsertRecursion = true;
			relatedAccountMap = ProviderUtilities.getRelatedAccounts(newProviders);
			ProviderUtilities.setRecordType(newProviders, relatedAccountMap);
			ProviderUtilities.cleanHealthgradesUrl(newProviders);
		}
	}

	//public void OnAfterInsert(Provider__c[] newProviders, Map<Id, Provider__c> newProviderMap)

	//}

	//@future public static void OnAfterInsertAsync(Set<ID> newProviderIDs){}

	public void OnBeforeUpdate(Provider__c[] oldProviders, Provider__c[] updatedProviders, Map<ID, Provider__c> oldProviderMap, Map<ID, Provider__c> newProviderMap){
		
		FlowControl.checkProviderFieldChanges(updatedProviders, oldProviderMap);

		if(FlowControl.fieldChangeIdMap.containsKey('Provider__cPremium_Member__c')) {

			//ProviderUtilities.newHealthgradesCase(oldProviderMap, updatedProviders);
			//ProviderUtilities.syncOnPremiumChange(oldProviderMap, updatedProviders);
		}

		if(!FlowControl.providerBeforeUpdateRecursion) {
			FlowControl.providerBeforeUpdateRecursion = true;
			relatedAccountMap = ProviderUtilities.getRelatedAccounts(updatedProviders);
			ProviderUtilities.setRecordType(updatedProviders, relatedAccountMap);
			ProviderUtilities.cleanHealthgradesUrl(updatedProviders);
		}
	}

	//public void OnAfterUpdate(Provider__c[] oldProviders, Provider__c[] updatedProviders, Map<ID, Provider__c> oldProviderMap, Map<ID, Provider__c> newProviderMap){

	//}

	//@future public static void OnAfterUpdateAsync(Set<ID> updatedProviderIDs){}

	//public void OnBeforeDelete(Provider__c[] ProvidersToDelete, Map<ID, Provider__c> ProviderMap){}

	//public void OnAfterDelete(Provider__c[] deletedProviders, Map<ID, Provider__c> ProviderMap){}

	//@future public static void OnAfterDeleteAsync(Set<ID> deletedProviderIDs){}

	//public void OnUndelete(Provider__c[] restoredProviders){}

	//public boolean IsTriggerContext{
	//	get{ return m_isExecuting;}
	//}

	//public boolean IsVisualforcePageContext{
	//	get{ return !IsTriggerContext;}
	//}

	//public boolean IsWebServiceContext{
	//	get{ return !IsTriggerContext;}
	//}

	//public boolean IsExecuteAnonymousContext{
	//	get{ return !IsTriggerContext;}
	//}

}