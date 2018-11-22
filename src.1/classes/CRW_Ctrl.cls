public with sharing class CRW_Ctrl {
    public String currentPrefix{get; private set;}

    public Id recordId{get; private set;}
    public Boolean hasIdParam{get{return recordId != null;}}

    public class CRW_Exception extends Exception {}

    public CRW_Ctrl(){
        initURLParams();
        initPrefix();
    }

    private void initURLParams(){
        recordId = null;
        Map<String, String> urlParamsMap = ApexPages.currentPage().getParameters();
        if(urlParamsMap != null && !String.isBlank(urlParamsMap.get('id'))){
            recordId = urlParamsMap.get('id');
        }
    }

    private void initPrefix(){
        currentPrefix = CRW_Ctrl.getCurrentNamespace();
    }

    private static String getCurrentNamespace(){
        String prefix = CRW_Ctrl.class.getName().substringBefore('CRW_Ctrl');
        prefix = String.isBlank(prefix) ? 'c' : prefix.substringBefore('.');
        return prefix;
    }

    @AuraEnabled
    public static Map<String,String> updateRecord(String updatedRecordId, Map<String,String> valuesMap){
        //NOTE: We only expect case ids

        //CRUD/FLS checks and collect field metadata
		Boolean success = true;
		String errorMsg = '';
        Set<String> invalidFields = new Set<String>();
        Map<String, Schema.DisplayType> fieldsType = new Map<String, Schema.DisplayType>();

        Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
        for(String fieldToCheck : valuesMap.keySet()){
            if(!sObjectFieldsMap.containsKey(fieldToCheck)){
                invalidFields.add(fieldToCheck);
            }
            Schema.DescribeFieldResult fieldResult = sObjectFieldsMap.get(fieldToCheck).getDescribe();
            if(!fieldResult.isUpdateable()){
                invalidFields.add(fieldToCheck);
            }
            fieldsType.put(fieldToCheck, fieldResult.getType());
        }

        if(invalidFields.size() > 0){

			system.debug('\n exception INVALID_FIELDS : '+JSON.serialize(invalidFields));
            throw new CRW_Exception('INVALID_FIELDS : '+JSON.serialize(invalidFields));
        }

        Case caseToUpdate = new Case(id = updatedRecordId);

        for(String fieldName : valuesMap.keySet()){
            Object valueObject = valuesMap.get(fieldName);
            if(fieldsType.get(fieldName) == Schema.DisplayType.Boolean){
                valueObject = ((String)valueObject).equalsIgnoreCase('true');
            }
			system.debug('\n n update ['+fieldName+']='+valueObject);
            caseToUpdate.put(fieldName, valueObject);
        }

		try {
			update caseToUpdate;

			system.debug('\n update ok');
		}catch (DmlException de){
			success = false;
			Integer numErrors = de.getNumDml();
			    System.debug('getNumDml=' + numErrors);
				Schema.DescribeFieldResult fieldResult;
				String fieldName='';
			    for(Integer i=0;i<numErrors;i++) {
                    if (de.getDmlFieldNames(i) != null && de.getDmlFieldNames(i).size() > 0) {
                        fieldName = de.getDmlFieldNames(i)[0];
                		errorMsg += ' on field ';

                		if (sObjectFieldsMap.containsKey(fieldName))
                        	errorMsg += sObjectFieldsMap.get(fieldName).getDescribe().getLabel();
                		else
                			errorMsg += fieldName;
                		errorMsg += ', '+de.getDmlMessage(i);

                        if (i< ( numErrors - 1))
                			errorMsg += ',';
                    }
                }
			system.debug('\n update not OK '+errorMsg);
		}catch(Exception e){
			success = false;
			errorMsg = e.getMessage();

			system.debug('\n update not OK '+errorMsg);
		}

        //Return a result map, this is mostly needed to detect the current namespace
        //so that we don't have to hard-code any namespace values
        Map<String, String> results = new Map<String,String>();
        results.put('success', String.valueOf(success));
        results.put('recordId', updatedRecordId);
        results.put('errorMsg', errorMsg);
        results.put('namespace', CRW_Ctrl.getCurrentNamespace());
        return results;
    }


    public static  Map<String,String> getFieldLabels(List<String> fieldsToSolve){
        //CRUD/FLS checks and collect field metadata
		Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
		Map<String,String> result = new Map<String,String>();
		String fieldLabel;
		Schema.DescribeFieldResult fieldResult;

		for(String fieldN : fieldsToSolve){
			if (sObjectFieldsMap.containsKey(fieldN)){
				fieldLabel = sObjectFieldsMap.get(fieldN).getDescribe().getLabel();
				result.put(fieldN.toLowerCase(),fieldLabel);
			}
		}
        return result;
    }



	public static  Map<String,String> getFieldTypes(List<String> fieldsToSolve){
        //CRUD/FLS checks and collect field metadata
		Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
		Map<String,String> result = new Map<String,String>();
		String fieldType;
		Schema.DescribeFieldResult fieldResult;

		for(String fieldN : fieldsToSolve){
			if (sObjectFieldsMap.containsKey(fieldN)){
				fieldType = ''+sObjectFieldsMap.get(fieldN).getDescribe().getType();
				result.put(fieldN.toLowerCase(),fieldType);
			}
		}
        return result;
    }

    /****
    Params: fields of the case to be solved
    Return: final list of the fields ordered by dependency and also alphabetically
    ****/
    @AuraEnabled
    public static List<String> fieldNamesOrderedValues(List<String> fieldsToSolve)
    {
        Set<String> setFieldsToSolve = new Set<String>();
        for(String actualFTS : fieldsToSolve)
        {
            setFieldsToSolve.add(actualFTS.toLowerCase());
        }
        Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
        Map<String,String> preResult = new Map<String,String>();
        String fieldLabel;
        Schema.DescribeFieldResult fieldResult;
        List<String> result = new List<String>();
        for(String fieldN : sObjectFieldsMap.keySet()) {
            fieldLabel = sObjectFieldsMap.get(fieldN).getDescribe().getLabel();
            if(setFieldsToSolve.contains(fieldN)){
                preResult.put(fieldLabel+'_'+fieldN,fieldN);
            }
        }
        List<String> keys = new List<String>();
        for(String actualKey : preResult.keySet()) { keys.add(actualKey); }
        keys.sort();
        for(String sortedKey : keys) { result.add(preResult.get(sortedKey)); }
        //------------------------------------------------------CREATE LIST BY FIELDNAME WITHOUT LOWERCASE----------------------------------------//
        List<String> parameterForDependency = new List<String>();
        for(String actualStrFromSet : result){ parameterForDependency.add(sObjectFieldsMap.get(actualStrFromSet).getDescribe().getName()); }
        //----------------------------------GET DEPENDENCY MAP (Controller -> List Dependents)----------------------------------------------------//
        Map<String,List<String>> listOfControllerAndDependants = getPickListDependencyFromCustomSettings(parameterForDependency);
        system.debug('listOfControllerAndDependants are: '+ listOfControllerAndDependants);
        //----------------------------------------------------------------------------------------------------------------------------------------//
        result = returnFinalOrdListFromMapOrdByDepAndAlph(listOfControllerAndDependants,result);
        return result;
    }

    /****
    Param: list of sorted api name string by label
    Return: Map<String,List<String>> map of the (unique) controllers with their dependent fields in the correct order (do not change this logic)
    ****/
   public static Map<String,List<String>> getPickListDependencyFromCustomSettings(List<String> fieldsToSolveSortedByLabel)
   {
       Map<String,list<String>> dependencyFromHandler = CRW_SettingsHandler.getFieldControllingMap(null);
       Map<String,List<String>> result = new Map<String,List<String>>();
       Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
       for(String actualField : fieldsToSolveSortedByLabel)
       {
           if(dependencyFromHandler.containsKey(actualField.toLowerCase())){
               String controllerFieldName = dependencyFromHandler.get(actualField.toLowerCase())[0];
               String actualFieldName = sObjectFieldsMap.get(actualField).getDescribe().getName();
               if(result.containsKey(controllerFieldName)){
                   Set<String> actualDependentFieldsForController = new Set<String>(result.get(controllerFieldName));
                   if(!actualDependentFieldsForController.contains(actualFieldName))
                   {
                       List<String> listToBeUpdated = result.get(controllerFieldName);
                       listToBeUpdated.add(actualFieldName);
                       result.put(controllerFieldName,listToBeUpdated);
                   }
               }
               else {
                       List<String> newListToInsert = new List<String>();
                       newListToInsert.add(actualFieldName);
                       result.put(controllerFieldName,newListToInsert);
                }
            }
       }
       result = orderControllersMapByDepenedency(result);

       return result;
   }

    public static List<String> returnFinalOrdListFromMapOrdByDepAndAlph(Map<String,List<String>> listOfControllerAndDependants, List<String> result)
    {
        for(String actualController : listOfControllerAndDependants.keySet()) {
            // this will iterate only over the fields that are controllers of dependent fields
            Set<String> dependentFieldsOfActualController = new Set<String>();
            Boolean actualDepToRemove = false;
            for (String actualStringDependent : listOfControllerAndDependants.get(actualController)) {
                dependentFieldsOfActualController.add(actualStringDependent.toLowerCase());
            }
            List<String> preFinalResult = new List<String>();
            for(String actualFieldFromSortedList : result){
                if(actualFieldFromSortedList == actualController){
                    preFinalResult.add(actualFieldFromSortedList);
                    for(String nextValue : dependentFieldsOfActualController){
                        preFinalResult.add(nextValue);
                    }
                }
                else{
                    if(!dependentFieldsOfActualController.contains(actualFieldFromSortedList.toLowerCase())){
                        preFinalResult.add(actualFieldFromSortedList);
                    }
                }
            }
			if (preFinalResult != null && preFinalResult.size() > 0)
               result = preFinalResult;
        }
        system.debug(result);
        return result;
    }

	@AuraEnabled
	public static Map<String,List<String>> getPickListOptionsDependency(String fieldApiName) {
        Map<String,List<String>> result = CRW_SettingsHandler.getPickListOptionsDependency(fieldApiName);

        return result;
    }

	public static Map<String,Map<String,String>> getFieldsAllValues(List<String> fieldsToSolve) {
		//CRUD/FLS checks and collect field metadata
		Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
		Map<String,Map<String,String>> result = new Map<String,Map<String,String>>();
		String fieldLabel;
		Schema.DescribeFieldResult fieldResult;
		List<Schema.PicklistEntry> ple;
		Map<String,String> options;

		for(String fieldN : fieldsToSolve){
			if (sObjectFieldsMap.containsKey(fieldN)){
				fieldResult = sObjectFieldsMap.get(fieldN).getDescribe();
				ple = fieldResult.getPicklistValues();
				options = new Map<String,String>();
				for( Schema.PicklistEntry f : ple){
					options.put(f.getValue(), f.getLabel());
				}
				result.put(fieldN.toLowerCase(),options);
			}
		}
	    return result;
	}

    @TestVisible
	private static list<String> getAllFields(List<String> fieldsToSolve) {
		Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
		list<String> result = new list<String>();
		String fieldLabel;
		Schema.DescribeFieldResult fieldResult;

		for(String fieldN : fieldsToSolve){
			if (sObjectFieldsMap.containsKey(fieldN)){
				result.add('Case.'+fieldN);
			}
		}
		return result;
	}


	@AuraEnabled
	public static Map<String,String> resolveLabelsAndDependencies(String recordId, String recommendationsMap){
		Map<String,String> result = new Map<String,String> ();
		List<RecommendationSettings__c> rec = RecommendationSettings__c.getall().values();

		List<String> fieldApiNameList = new List<String>();
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(recommendationsMap);
		fieldApiNameList.addAll(m.keySet());

        // Map of fieldNames to recommendationId
        Map<String,Boolean> valueToRecommendationId = new Map<String,Boolean>();
        for (String key : m.keySet()) {
            Map<String,Boolean> recommendationsIds = new Map<String,Boolean>();

            // Get field values
            List<Object> fieldRec = (List<Object>)m.get(key);

            // Get recommendations
            for (Object thisField : fieldRec) {
                Map<String, Object> allRec = (Map<String, Object>)thisField;
                // Get first recommendationId
                String recId = (String)allRec.get('recordRecommendationId');

                valueToRecommendationId.put(recId, false);
            }
        }

        System.debug('valueToRecommendationId: ' + valueToRecommendationId);

		List<String> filtered = filterFieldsByAccessPermissions(fieldApiNameList);

        Map<String,list<String>> depToContr = CRW_SettingsHandler.getFieldControllingMap(filtered);//fieldsAndControllers(filtered);
		filtered = filterOrphanDependants(filtered,depToContr);


		if (!rec.isEmpty())
			result.put('recommendationCustomSettings',JSON.serialize(rec[0]));
		else
			result.put('recommendationCustomSettings','{}');

		if (filtered.isEmpty()){
			result.put('fieldNames','{}');
	        result.put('fieldTypes','{}');
			result.put('fieldControllingMap','{}');
	        result.put('actualValuesByField','{}');
			result.put('fieldSortedByKey','{}');
			result.put('fieldsAllValues','{}');
			result.put('allPickListOptions','{}');
            result.put('valueToRecommendationId','{}');
		}else{
			result.put('fieldNames',JSON.serialize(getFieldLabels(filtered)));
	        result.put('fieldTypes',JSON.serialize(getFieldTypes(filtered)));
			result.put('fieldControllingMap',JSON.serialize(depToContr));

	        Map<String,Map<String,List<String>>> allPickListOptions = new Map<String, Map<String,List<String>>>();

	        for (String key : depToContr.keySet()) {
	            Map<String,List<String>> pickListOptions = getPickListOptionsDependency(key);
	            allPickListOptions.put(key, pickListOptions);
	        }

	        result.put('actualValuesByField',JSON.serialize(getActualValueForNextFieldOnCase(recordId,filtered)));
			result.put('fieldSortedByKey',JSON.serialize(fieldNamesOrderedValues(filtered)));
			result.put('fieldsAllValues',JSON.serialize(getFieldsAllValues(filtered)));
			result.put('allPickListOptions',JSON.serialize(allPickListOptions));
    		result.put('valueToRecommendationId',JSON.serialize(valueToRecommendationId));
		}

        System.debug('result:'+ result);
		return result;
	}

    @AuraEnabled
    public static Map<String,String> getActualValueForNextFieldOnCase(String recordId, List<String> fieldNames)
    {
        Map<String,String> returnMap = new Map<String,String>();
        String queryAdd = '';
        for(String actFN : fieldNames) {
            queryAdd = queryAdd + ' '+ actFN + ' ,';
        }
        queryAdd = queryAdd.removeEnd(',');
        List<Case> actualCase =  Database.query('SELECT '+queryAdd+' FROM Case WHERE Id = \'' + recordId + '\' ');
        if(actualCase.size() > 0){
            Case returnedCase = actualCase[0];
            for(String actField : fieldNames) {
                system.debug('actField is : '  + actField);
                String fieldValue = String.valueOf(returnedCase.get(actField));
                returnMap.put(actField,fieldValue);
            }
        }
        return returnMap;
    }

	public static List<String> filterFieldsByAccessPermissions(List<String>  initialList){
		List<String>  result = new List<String> ();

		Map<String, Schema.DisplayType> fieldsType = new Map<String, Schema.DisplayType>();

		Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
		Schema.DescribeFieldResult fieldResult;

		for(String fieldToCheck : initialList){
			if(sObjectFieldsMap.containsKey(fieldToCheck)){
				fieldResult = sObjectFieldsMap.get(fieldToCheck).getDescribe();
				if(fieldResult.isUpdateable() && fieldResult.isAccessible()){
					result.add(fieldToCheck);
				}
			}
		}
		return result;
	}

    /****
    Param: Map<String,List<String>> map of the controllers with their dependent fields
    Return: Map<String,List<String>> map of the (unique) controllers with their dependent field in the correct order, removing
    the controllers of the map that were dependent of other controller and also their dependents fields, all this in the correct alphabetical
    order.
    ****/
    public static Map<String,List<String>> orderControllersMapByDepenedency(Map<String,List<String>> result)
    {
        Set<String> listOfController = result.keySet();
        for(String actualController : listOfController)
        {
            Boolean continueWithActualController = true;
            Boolean foundOneDepCtrlOnList = false;
            List<String> dependentOfActualController = result.get(actualController);
            List<String> newListOfDep = new List<String>();
            if(dependentOfActualController != null){
                for ( String actualDependentOfActualController : dependentOfActualController)
                {
                    if(listOfController.contains(actualDependentOfActualController))
                    {
                        newListOfDep.add(actualDependentOfActualController); //insert of ctrl
                        List<String> listOfDepsOfCtlrOnDepOfCtrl = result.get(actualDependentOfActualController);
                        for (String depsOfActualOfCtrlOnDepOfCtrl : listOfDepsOfCtlrOnDepOfCtrl)
                        {
                            newListOfDep.add(depsOfActualOfCtrlOnDepOfCtrl); //insert of deps of ctrl inside deps of ctrl
                            if(listOfController.contains(depsOfActualOfCtrlOnDepOfCtrl))
                            {
                                foundOneDepCtrlOnList = true;
                            }
                        }
                        result.remove(actualDependentOfActualController);

                    }
                    else
                    {
                        newListOfDep.add(actualDependentOfActualController);
                    }
                }

                continueWithActualController = continueWithActualController && foundOneDepCtrlOnList;
                result.put(actualController, newListOfDep);
            }

            if(continueWithActualController){
                orderControllersMapByDepenedency(result);
            }

        }
        return result;
    }

	/****
    Param: Map<String,List<String>> map of the dependent fields and their controllers
	Param: List<String> list of all recomended fields
    Return: List<String> filtered list of recommended fields, for each element we check that
							if they have a controlling field it also has recomendations
    ****/
	public static List<String> filterOrphanDependants(List<String> filtered, Map<String,List<String>> depToContr){

		List<String> result = new List<String>();
		Set<String> allFields = new Set<String>();
		allFields.addAll(filtered);
		system.debug('\n==== filterOrphanDependants fields incoming  '+allFields);

		Set<String> keysToRemove = new Set<String>();
		for(String k : depToContr.keySet()){
			for(String ctrField :depToContr.get(k) ){
				if(!allFields.contains(ctrField)){
					keysToRemove.add(k);
					allFields.remove(k);
				}
			}
		}

		for(String original : filtered){
			String tmp = original.toLowerCase();
			if (depToContr.containsKey(tmp)) {
				if (! keysToRemove.contains(tmp))
					result.add(original);
			}else
				result.add(original);
		}
		system.debug('\n==== filterOrphanDependants fields result '+result);

		return result;
	}
}