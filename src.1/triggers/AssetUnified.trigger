trigger AssetUnified on Asset (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {

	dlrs.RollupService.triggerHandler();
	//if(RecursionCheck.preventGenericTrigger){ return; }

	//if(TriggerControl__c.getInstance().preventGenericTrigger__c) { return; }

	AssetTriggerHandler handler = new AssetTriggerHandler(Trigger.isExecuting, Trigger.size);

	if(Trigger.isInsert && Trigger.isBefore){
		//handler.OnBeforeInsert(Trigger.new);
	}
	
	//else if(Trigger.isInsert && Trigger.isAfter){
	//	handler.OnAfterInsert(Trigger.new, Trigger.newMap);
		//if(!RecursionCheck.GenericInsertRecursion && !System.isFuture && !System.isBatch){
		//RecursionCheck.GenericInsertRecursion = true;
		//	GenericTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
		//}
	//}

	else if(Trigger.isUpdate && Trigger.isBefore){
		handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.OldMap, Trigger.newMap);
	}
	
	//else if(Trigger.isUpdate && Trigger.isAfter){
		//handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
		//if(!RecursionCheck.GenericUpdateRecursion && !System.isFuture && !System.isBatch){
		//	RecursionCheck.GenericUpdateRecursion = true;
		//	GenericTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
		//}
	//}

	//else if(Trigger.isDelete && Trigger.isBefore){
		//handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	//}
	
	//else if(Trigger.isDelete && Trigger.isAfter){
		//handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
		//if(!RecursionCheck.GenericDeleteRecursion && !System.isFuture && !System.isBatch)
		//	GenericDeleteRecursion = true;
		//	GenericTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
		//}
	//}

	//else if(Trigger.isUnDelete){
		//handler.OnUndelete(Trigger.new);
	//}

}