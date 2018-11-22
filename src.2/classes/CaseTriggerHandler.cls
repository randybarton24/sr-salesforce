public with sharing class CaseTriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	//private static final Map<String, Id> StaticCaseRecordTypes = RecordTypes.GetRecordTypeIdDevMap('Case');

	public CaseTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	//public void OnBeforeInsert(Case[] newCases){}

	//public void OnAfterInsert(Case[] newCases, Map<Id, Case> newCaseMap)

	//}

	//@future public static void OnAfterInsertAsync(Set<ID> newCaseIDs){}

	public void OnBeforeUpdate(Case[] oldCases, Case[] updatedCases, Map<ID, Case> oldCaseMap, Map<ID, Case> newCaseMap){
		CaseUtilities.validateHealthgradesStatusBeforeClose(updatedCases);
	}

	//public void OnAfterUpdate(Case[] oldCases, Case[] updatedCases, Map<ID, Case> oldCaseMap, Map<ID, Case> newCaseMap){

	//}

	//@future public static void OnAfterUpdateAsync(Set<ID> updatedCaseIDs){}

	//public void OnBeforeDelete(Case[] CasesToDelete, Map<ID, Case> CaseMap){}

	//public void OnAfterDelete(Case[] deletedCases, Map<ID, Case> CaseMap){}

	//@future public static void OnAfterDeleteAsync(Set<ID> deletedCaseIDs){}

	//public void OnUndelete(Case[] restoredCases){}

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