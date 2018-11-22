@isTest
private class CRW_SettingsHandlerTest {
	@testSetup
	static void startData() {
		RecommendationSettings__c classObj =  CRW_SettingsHandler.getAppSettings();
		upsert classObj;
	}

	@isTest
	static void test_caseFieldsToProcess() {
		// Implement test code
		System.Test.startTest();
		List<String> allFields = CRW_SettingsHandler.caseFieldsToProcess();
		System.Test.stopTest();
		System.assert(allFields != null);
	}

	@isTest
	static void test_updateCaseFieldControllingMap() {
		// Implement test code
		System.Test.startTest();
		// call getFieldControlling when there's no values on custom settings
		Map<String,list<String>> initMP = CRW_SettingsHandler.getFieldControllingMap(null);

		// retrieve data from Dummy field
		Map<String,list<String>> mp = CRW_SettingsHandler.retrieveCaseFieldControllingData();
		CRW_SettingsHandler.updateCaseFieldControllingMap();

		System.Test.stopTest();
		// call getFieldControlling when there should be one record for the dummy field
		Map<String,list<String>> finalMP = CRW_SettingsHandler.getFieldControllingMap(null);

		System.assertEquals(initMP.size(),0);
		System.assertEquals(finalMP.size(),1);
	}

	@isTest
	static void test_updateCaseFieldValueControllingMap() {
		// Implement test code
		System.Test.startTest();
		// call getAllPickListOptionsDependency when there's no values on custom settings
		Map<String,List<Map<String,List<String>>>> initMP = CRW_SettingsHandler.getAllPickListOptionsDependency();
		// retrieve data from Dummy field values
		Map<String,list<Map<String,list<String>>>> mp = CRW_SettingsHandler.retrieveCaseFieldValuesControllingData();
		CRW_SettingsHandler.updateCaseFieldValueControllingMap();

		System.Test.stopTest();
		// call getAllPickListOptionsDependency when there should be one record for the dummy field value
		Map<String,List<Map<String,List<String>>>> finalMP = CRW_SettingsHandler.getAllPickListOptionsDependency();

		System.assertEquals(initMP.size(),0);
		System.assertEquals(finalMP.size(),1);
	}

	@isTest
	static void test_getPickListOptionsDependency() {
		CaseFieldControllingValuesMap__c caseMap = new CaseFieldControllingValuesMap__c(
			Name = 'Type_Structural',
			FieldAPIName__c = 'Type',
			ControllingFieldValue__c = 'Structural',
			DependentFields__c = 'Structural 1.1'
		);

		insert caseMap;

		// Implement test code
		System.Test.startTest();
		String fieldApiName = 'Type';
		Map<String,List<String>> result = CRW_SettingsHandler.getPickListOptionsDependency(fieldApiName);
		System.Test.stopTest();

		System.assertNotEquals(0, result.size(), 'List size should be above 0.');
	}
}