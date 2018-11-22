public with sharing class CRW_SettingsHandler {

    public static String CONFIG_NAME = 'default';
	public static String SESSION_ID = '';

	public static RecommendationSettings__c  getAppSettings(){

	        RecommendationSettings__c res = RecommendationSettings__c.getInstance(CONFIG_NAME);

	        if (res == null){
	            res = new RecommendationSettings__c();
	            res.Name = CONFIG_NAME;
	        }
	        return res;

	    }

	private static CRW_MetadataService.MetadataPort service = null;

	public static CRW_MetadataService.MetadataPort returnService() {
		if(service == null) {
			service = new CRW_MetadataService.MetadataPort();
			service.SessionHeader = new CRW_MetadataService.SessionHeader_element();
			if (String.isNotBlank(SESSION_ID))
				service.SessionHeader.sessionId = SESSION_ID;
			else
				service.SessionHeader.sessionId = UserInfo.getSessionId();
		}
		return service;
	}

	public static List<String> caseFieldsToProcess(){

		Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.SObjectType.Case.fields.getMap();
		List<String> result = new List<String>();
		Schema.DescribeFieldResult fieldResult;

		for(String fieldN : sObjectFieldsMap.keySet()){
			fieldResult = sObjectFieldsMap.get(fieldN).getDescribe();
			if ((fieldResult.getType() == Schema.DisplayType.Boolean) ||
				(fieldResult.getType() == Schema.DisplayType.Picklist) ){

					result.add('Case.'+fieldN.toLowerCase());
			}
		}
		return result;
	}

	// ******************************************************************************//
	// ** 	METHODS USED BY SCHEDULED JOB TO UPDATE CaseFieldControllingMap__c	*****//

	/*
		calls soapAPI to retrieve details on all case fields that are controlled by other fields
	*/
	public static void updateCaseFieldControllingMap(){
system.debug('\n=== codez ');
		List<String> controllingFields = new List<String>();
		Map<String,list<String>> currentObjectData = retrieveCaseFieldControllingData();
		Set<String> currentObjectDataFields = currentObjectData.keySet();
		system.debug('\n=== currentObjectDataFields '+currentObjectDataFields.size());
		//check stored values on Custom setting
        List<CaseFieldControllingMap__c> recToDel = new List<CaseFieldControllingMap__c>();
		// 	- update existing key
		List<CaseFieldControllingMap__c> rec = CaseFieldControllingMap__c.getall().values();
		String tmpList ;
		for(CaseFieldControllingMap__c r : rec){
			tmpList = r.ControllerFields__c;
			if (currentObjectData.containsKey(r.Name)){
				r.ControllerFields__c = String.join(currentObjectData.get(r.Name),',');
				system.debug('\n UPDATE values for '+r.Name +'\n \t r.ControllerFields__c : '+r.ControllerFields__c);
				currentObjectDataFields.remove(r.Name);
			}
            else
            {
                // adding the current custom setting that dont exist on the org to the delete list
                recToDel.add(r);
            }
		}
		//	- create new records for non existing keys
		for(String newKey : currentObjectDataFields){
			rec.add(new CaseFieldControllingMap__c (Name =newKey, ControllerFields__c = String.join(currentObjectData.get(newKey),',')));
			system.debug('\n ADD values for '+newKey +'\n \t r.ControllerFields__c : '+String.join(currentObjectData.get(newKey),','));
			currentObjectDataFields.remove(newKey);
		}
		// upsert custom setting
		upsert rec;
        // delete custom setting that currently not exist on the org
        delete recToDel;

		//delete values settins
		delete [Select id from CaseFieldControllingValuesMap__c];

	}

	/*
		calls soapAPI to retrieve details on all case fields that are controlled by other fields
	*/
	public static Map<String,list<String>> retrieveCaseFieldControllingData(){
		Map<String,list<String>> fieldControllers = new Map<String,list<String>>();
		Map<String,list<String>>  partial;
		CRW_MetadataService.MetadataPort service = returnService();

		// build a list with all picklist and checkbox fields
		String [] allFields = caseFieldsToProcess();

		String [] tmpFields = new List<String>();
		for (Integer i = 0; i<allFields.size(); i ++ ){
			tmpFields.add(allFields.get(i));
			system.debug('\n retrieveCaseFieldControllingData : '+allFields.get(i));

			if ( i>0 && ( math.mod(tmpFields.size(), 10) == 0 ) ){
				partial = fieldsAndControllersLimited(tmpFields, service);
				fieldControllers.putAll(partial);
				tmpFields= new List<String>();
			}
		}

		if (!tmpFields.isEmpty()){
			partial = fieldsAndControllersLimited(tmpFields, service);
			fieldControllers.putAll(partial);
		}


		return fieldControllers;
	}

	public static Map<String,list<String>> fieldsAndControllersLimited(String[] allFields, CRW_MetadataService.MetadataPort service){

		Map<String,list<String>> fieldControllers = new Map<String,list<String>>();
		List<String> controllingFields = new List<String>();

		CRW_MetadataService.CustomField[] customFieldActual;
		if (!Test.isRunningTest() ){
			customFieldActual = (CRW_MetadataService.CustomField[]) service.readMetadata(
					'CustomField', allFields
					).getRecords();
		}else{
			CRW_MetadataService.ValueSet dVal = new CRW_MetadataService.ValueSet();
			dVal.controllingField = 'Type';
			CRW_MetadataService.CustomField dummyCField = new CRW_MetadataService.CustomField();
			dummyCField.ValueSet = dVal;
			dummyCField.fullName = 'Case.Dummy_Controlled__c';

			customFieldActual = new List<CRW_MetadataService.CustomField>{dummyCField};
		}

		String dbug='';
		for( CRW_MetadataService.CustomField cc : customFieldActual){

			if(cc.ValueSet != null){

				String controllerFieldName = cc.ValueSet.controllingField;
				if (String.isNotBlank(controllerFieldName)){
					if (fieldControllers.containsKey(cc.fullName)){
						controllingFields = fieldControllers.get(cc.fullName);
					}else{
						controllingFields = new List<String>();
					}
					controllingFields.add(controllerFieldName);
					fieldControllers.put(cc.fullName.replace('Case.','').toLowerCase(),controllingFields);

				}
			}
		}
		return fieldControllers;
	}


	/*
		calls soapAPI to retrieve details on case fields depencency for each value on controlling picklists
	*/
	public static void updateCaseFieldValueControllingMap() {
        List<String> controllingFields = new List<String>();
		Map<String,List<Map<String,List<String>>>> currentObjectData = retrieveCaseFieldValuesControllingData();
		Set<String> currentObjectDataFields = currentObjectData.keySet();
		// check stored values on Custom setting

        List<CaseFieldControllingValuesMap__c> recToInsert = new List<CaseFieldControllingValuesMap__c> ();


		//	- create new records for non existing keys
		for (String newKey : currentObjectData.keySet()) {
			for (Map<String,List<String>> mp : currentObjectData.get(newKey)) {
				for (String ctrFieldVal : mp.keySet()) {
                    // Check if value exists.
                    recToInsert.add( new CaseFieldControllingValuesMap__c (
						Name = newKey + '_' + ctrFieldVal,
						FieldAPIName__c = newKey,
						ControllingFieldValue__c = ctrFieldVal,
						DependentFields__c = String.join(mp.get(ctrFieldVal),',')
					));
				}
			}
		}

		insert recToInsert;

	}

	/** for each field on case retrieves dependent values **/
	public static Map<String,list<Map<String,list<String>>>> retrieveCaseFieldValuesControllingData() {


		Map<String,list<Map<String,list<String>>>> result = new Map<String,list<Map<String,list<String>>>>();
		Map<String,list<Map<String,list<String>>>>  partial;
		CRW_MetadataService.MetadataPort service = returnService();

		// build a list with all picklist and checkbox fields
		String [] allFields = caseFieldsToProcess();//new List<String>{'Case.Subtype_1__c','Case.Sub_Sub_Type__c'};//

		String [] tmpFields = new List<String>();
		for (Integer i = 0; i<allFields.size(); i ++ ){
			tmpFields.add(allFields.get(i));

			if ( i>0 && ( math.mod(tmpFields.size(), 10) == 0 ) ){
				partial = retrieveCaseFieldValuesControllingDataLimited(tmpFields, service);
				result.putAll(partial);
				tmpFields= new List<String>();
			}
		}

		if (!tmpFields.isEmpty()){
			partial = retrieveCaseFieldValuesControllingDataLimited(tmpFields, service);
			result.putAll(partial);
		}

		return result;


    }

	public static Map<String,list<Map<String,list<String>>>> retrieveCaseFieldValuesControllingDataLimited(String[] allFields, CRW_MetadataService.MetadataPort service){

		Map<String,list<String>> controllingValues = new Map<String,list<String>>();
		Map<String,list<Map<String,list<String>>>> controllingFieldValues = new Map<String,list<Map<String,list<String>>>>();
		List<String> controllingFields = new List<String>();


		CRW_MetadataService.CustomField[] customFieldActual;
		if (!Test.isRunningTest() ){
			customFieldActual = (CRW_MetadataService.CustomField[]) service.readMetadata(
								'CustomField', allFields
								).getRecords();
		}else{
			CRW_MetadataService.ValueSettings oneVS  = new CRW_MetadataService.ValueSettings();
			oneVS.controllingFieldValue = new List<String>{'CTR_1__c','CTR_2__c'};
			oneVS.valueName ='CONTROL';
			List<CRW_MetadataService.ValueSettings> lvS = new List<CRW_MetadataService.ValueSettings>{oneVS};

			CRW_MetadataService.ValueSet dVal = new CRW_MetadataService.ValueSet();
			dVal.controllingField = 'Type';
			dVal.valueSettings = lvS;
			CRW_MetadataService.CustomField dummyCField = new CRW_MetadataService.CustomField();
			dummyCField.ValueSet = dVal;
			dummyCField.fullName = 'Case.Dummy_Controlled__c';

			customFieldActual = new List<CRW_MetadataService.CustomField>{dummyCField};
		}

		String dbug='\n===retrieveCaseFieldValuesControllingDataLimited X 10 ===\n fields are :\n\t\t '+allFields;
		list<Map<String,list<String>>> tmpFieldMap;
		for( CRW_MetadataService.CustomField cc : customFieldActual){

			if(cc.ValueSet != null){

				List<CRW_MetadataService.ValueSettings> controllerFieldName = cc.ValueSet.valueSettings;
				List<String> currentOptions;
				if (controllerFieldName != null) {
					for (CRW_MetadataService.ValueSettings vs : controllerFieldName) {

						for (String controllingOption : vs.controllingFieldValue) {

							if (controllingValues.containsKey(controllingOption)) {
								currentOptions = controllingValues.get(controllingOption);
							} else {
								currentOptions = new List<String>();
							}
							currentOptions.add(vs.valueName);
							controllingValues.put(controllingOption, currentOptions);
							dbug +='\n \t controllingOption :'+controllingOption +' currentOptions : '+currentOptions;
						}
					}
					if (controllingFieldValues.containsKey(cc.fullName)){
						tmpFieldMap = controllingFieldValues.get(cc.fullName);
					}else{
						tmpFieldMap = new list<Map<String,list<String>>>();
					}
					tmpFieldMap.add(controllingValues);
					controllingValues = new Map<String,list<String>>();
					controllingFieldValues.put(cc.fullName.replace('Case.','').toLowerCase(),tmpFieldMap);
					dbug += '\n  \t  result  ['+cc.fullName +'] =  '+tmpFieldMap +'\n';
				}
			}
		}
		system.debug(dbug+'\n========\n');
		return controllingFieldValues;
	}


	// **********************************************************************************//
	// ** 	METHODS USED BY LIGHTNING COMPONENT CONTROLLER	FieldRecommendationsCtrl ****//

    /****
    Params: list of fields api name
    Return: Map<String,List<String>> map of controller and dependents without any specific order sortered by field or if
    the param is null must return all controllers and dependents from custom setting
    ****/
	public static Map<String,list<String>> getFieldControllingMap(List<String> fieldApiNameList) {
		Map<String,list<String>> result = new Map<String,list<String>>();
		Set<String> fields = new Set<String>();
		String tmpList ;

		if (fieldApiNameList != null){
			for(String fn : fieldApiNameList){
				fields.add(fn.toLowerCase());
			}
		}
		List<CaseFieldControllingMap__c> rec = CaseFieldControllingMap__c.getall().values();
		for(CaseFieldControllingMap__c r : rec){
			if (	( !fields.isEmpty() && fields.contains(r.Name) ) ||
					fields.isEmpty() ){
				tmpList = r.ControllerFields__c;
				result.put(r.Name,tmpList.split(','));
			}
		}

		return result;
	}

	public static Map<String,List<Map<String,List<String>>>> getAllPickListOptionsDependency() {

		Map<String,List<Map<String,List<String>>>> resultTotal = new Map<String,List<Map<String,List<String>>>>();

		List<CaseFieldControllingValuesMap__c> rec = [SELECT ControllingFieldValue__c,DependentFields__c,FieldAPIName__c
														FROM CaseFieldControllingValuesMap__c
														Order By FieldAPIName__c ];
		String valueName, fieldName ;
		List<Map<String,List<String>>> tmpField;

		for(CaseFieldControllingValuesMap__c r : rec){
			//for the field
			fieldName = r.FieldAPIName__c;
			if (resultTotal.containsKey(fieldName)){
				tmpField = resultTotal.get(fieldName);
			}else{
				tmpField = new List<Map<String,List<String>>>();
			}
			//for the values
			valueName = r.ControllingFieldValue__c;
			tmpField.add(new Map<String,list<String>>{valueName=>r.DependentFields__c.split(',')});
			resultTotal.put(fieldName, tmpField);

		}

		return resultTotal;
	}

	public static Map<String,List<String>> getPickListOptionsDependency(String fieldApiName) {
		Map<String,list<String>> result = new Map<String,list<String>>();

		List<CaseFieldControllingValuesMap__c> rec = [SELECT ControllingFieldValue__c,DependentFields__c
												FROM CaseFieldControllingValuesMap__c
												WHERE FieldAPIName__c =: fieldApiName];

		String valueName ;
		List<String> tmpL;
		for(CaseFieldControllingValuesMap__c r : rec){
			valueName = r.ControllingFieldValue__c;
			if (result.containsKey(valueName))
				tmpL = result.get(valueName);
			else
				tmpL = new List<String>();
			tmpl.addAll(r.DependentFields__c.split(','));
			result.put(valueName,tmpl);
		}

		return result;
	}

}