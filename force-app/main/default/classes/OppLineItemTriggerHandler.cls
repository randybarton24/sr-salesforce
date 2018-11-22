public with sharing class OppLineItemTriggerHandler {
	
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	//private static final Map<String, Id> StaticOppLineItemRecordTypes = RecordTypes.GetRecordTypeIdDevMap('OpportunityLineItem');
	public static Map<ID, Opportunity> relatedOpportunitiesMap;
	public static Map<Id, Product2> relatedProductsMap;

	public OppLineItemTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	@future
	public static void DoRollup() {

		dlrs.RollupService.triggerHandler();
	}

	public void OnBeforeInsert(OpportunityLineItem[] newOppLineItems){
		
		if(!FlowControl.oppLineItemBeforeInsertRecursion) {
			
			relatedOpportunitiesMap = OppLineItemUtilities.getRelatedOpps(newOppLineItems);
			relatedProductsMap = OppLineItemUtilities.getRelatedProducts(newOppLineItems);
			//OppLineItemUtilities.validateNoMixedProducts(newOppLineItems, relatedOpportunitiesMap);
			OppLineItemUtilities.validateNoDuplicateProducts(newOppLineItems, relatedOpportunitiesMap, relatedProductsMap);
			OppLineItemUtilities.setContractDefaults(newOppLineItems, relatedProductsMap, relatedOpportunitiesMap);
			OppLineItemUtilities.setAddProductDates(newOppLineItems);
			//FlowControl.oppLineItemBeforeInsertRecursion = true;
		}
	}

	public void OnAfterInsert(OpportunityLineItem[] newOppLineItems, Map<Id, OpportunityLineItem> newOppLineItemMap){
		
		

		if(!FlowControl.oppLineItemAfterInsertRecursion) {
			FlowControl.oppLineItemAfterInsertRecursion = true;
			OppLineItemUtilities.setModifiedSubscription(newOppLineItems, newOppLineItemMap, true);
		}

		//Async
		if(!FlowControl.oppLineItemInsertAsyncRecursion && !System.isFuture() && !System.isBatch()){
			FlowControl.oppLineItemInsertAsyncRecursion = true;
			OppLineItemUtilities.setCoTerminationDates(newOppLineItemMap.keySet());
			//OppLineItemUtilities.setOppTrialPeriod(newOppLineItemMap.keySet());
		}
	}

	public void OnBeforeUpdate(OpportunityLineItem[] oldOppLineItems, OpportunityLineItem[] updatedOppLineItems, Map<ID, OpportunityLineItem> oldOppLineItemMap, Map<Id, OpportunityLineItem> newOppLineItemMap){
		
		FlowControl.checkOppLineItemFieldChanges(updatedOppLineItems, oldOppLineItemMap);

		if(FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemRecurSoft__Contract_Term_End_Date_Editable__c') ||
			FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemRecurSoft__Contract_Term_Start_Date_New__c')) {

			OppLineItemUtilities.setAddProductDates(updatedOppLineItems);
		}

		if(!FlowControl.oppLineItemBeforeUpdateRecursion) {
			FlowControl.oppLineItemBeforeUpdateRecursion = true;
			OppLineItemUtilities.setModifiedSubscription(updatedOppLineItems, newOppLineItemMap, false);
		}
	}

	public void OnAfterUpdate(OpportunityLineItem[] oldOppLineItems, OpportunityLineItem[] updatedOppLineItems, Map<ID, OpportunityLineItem> oldOppLineItemMap, Map<ID, OpportunityLineItem> newOppLineItemMap){

		//if(!FlowControl.oppLineItemAfterUpdateRecursion) {
		//	FlowControl.oppLineItemAfterUpdateRecursion = true;	
		//}

		if(FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemUnitPrice') ||
			FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemNumber_of_Free_Months__c') ||
			FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemTrial__c') ||
			FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemBase_Contract_Term__c') ||
			FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemApproval_Level_Required__c')) {

			if(!FlowControl.suppressRollup) dlrs.RollupService.rollup(oldOppLineItemMap, newOppLineItemMap, OpportunityLineItem.SObjectType);
		}

		if(FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemNumber_of_Free_Months__c') ||
			FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemFree_Month_Setting__c') ||
			FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemBase_Contract_Term__c') ||
			FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemRecurSoft__Contract_Term_End_Date_Editable__c')) {

			//Async
			if(!FlowControl.oppLineItemUpdateAsyncRecursion && !System.isFuture() && !System.isBatch()){
				FlowControl.oppLineItemUpdateAsyncRecursion = true;
				OppLineItemUtilities.setCoTerminationDates(newOppLineItemMap.keySet());
			}
		}

		/*if(FlowControl.fieldChangeIdMap.containsKey('OpportunityLineItemTrial__c')) {

			//Async
			if(!FlowControl.oppLineItemUpdateAsyncRecursion && !System.isFuture() && !System.isBatch()){
				FlowControl.oppLineItemUpdateAsyncRecursion = true;
				OppLineItemUtilities.setOppTrialPeriod(FlowControl.fieldChangeIdMap.get('OpportunityLineItemTrial__c'));
			}
		}*/
	}

	//public void OnBeforeDelete(OpportunityLineItem[] OppLineItemsToDelete, Map<ID, OpportunityLineItem> OppLineItemMap){}

	public void OnAfterDelete(OpportunityLineItem[] deletedOppLineItems, Map<ID, OpportunityLineItem> deletedOppLineItemMap){

		dlrs.RollupService.rollup(deletedOppLineItemMap, null, OpportunityLineItem.SObjectType);
	}

	//@future public static void OnAfterDeleteAsync(Set<ID> deletedOppLineItemIDs){}

	//public void OnUndelete(OpportunityLineItem[] restoredOppLineItems){}

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