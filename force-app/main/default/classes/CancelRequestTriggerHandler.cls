public with sharing class CancelRequestTriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	//private static final Map<String, Id> StaticCancelRequestRecordTypes = RecordTypes.GetRecordTypeIdDevMap('Cancel_Request__c');

	public CancelRequestTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnBeforeInsert(Cancel_Request__c[] newCancelRequests){

		//CancelRequestUtilities.createAssetTransaction(newCancelRequests);
		CancelRequestUtilities.setModifiedSubscription(newCancelRequests, new Map<Id, Cancel_Request__c>());
	}

	public void OnAfterInsert(Cancel_Request__c[] newCancelRequests, Map<Id, Cancel_Request__c> newCancelRequestMap){

		//CancelRequestUtilities.setCrRecordType(newCancelRequests);
	}

	//public static void OnAfterInsertAsync(Set<ID> newCancelRequestIDs){}

	public void OnBeforeUpdate(Cancel_Request__c[] oldCancelRequests, Cancel_Request__c[] updatedCancelRequests, Map<ID, Cancel_Request__c> oldCancelRequestMap, Map<Id, Cancel_Request__c> newCancelRequestMap){

		FlowControl.checkCancelRequestFieldChanges(updatedCancelRequests, oldCancelRequestMap);

		CancelRequestUtilities.setModifiedSubscription(updatedCancelRequests, oldCancelRequestMap);

		if(FlowControl.fieldChangeIdMap.containsKey('Cancel_Request__cStage__cSave')) {

			CancelRequestUtilities.createAddendumOpp(updatedCancelRequests);
		}

		if(FlowControl.fieldChangeIdMap.containsKey('Cancel_Request__cStage__cCancelled') ||
			FlowControl.fieldChangeIdMap.containsKey('Cancel_Request__cStage__cNo Sale')) {

			CancelRequestUtilities.createCancelCase(updatedCancelRequests);
		}
	}

	//public void OnAfterUpdate(Cancel_Request__c[] oldCancelRequests, Cancel_Request__c[] updatedCancelRequests, Map<ID, Cancel_Request__c> oldCancelRequestMap, Map<ID, Cancel_Request__c> newCancelRequestMap){}

	//public static void OnAfterUpdateAsync(Set<ID> updatedCancelRequestIDs){}

	//public void OnBeforeDelete(Cancel_Request__c[] CancelRequestsToDelete, Map<ID, Cancel_Request__c> CancelRequestMap){}

	//public void OnAfterDelete(Cancel_Request__c[] deletedCancelRequests, Map<ID, Cancel_Request__c> CancelRequestMap){}

	//@future public static void OnAfterDeleteAsync(Set<ID> deletedCancelRequestIDs){}

	//public void OnUndelete(Cancel_Request__c[] restoredCancelRequests){}

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