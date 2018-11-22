@isTest
private class CRW_SettingsCtrlTest {
	@testSetup
	static void startData() {
		RecommendationSettings__c classObj =  CRW_SettingsHandler.getAppSettings();
		upsert classObj;
	}


	@isTest
	static void test_checkMetadataAPIConnection()
	{
		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		Boolean metadataApiConectionTest = CRW_SettingsCtrl.checkMetadataAPIConnection();
		if(metadataApiConectionTest)
		{
			System.assertEquals(ctrl.remoteSiteUrlString,'','An issue with the url that we get on remoteSiteUrlString, must be empty if the conection to the metadata success');
		}
		else
		{
			System.assertNotEquals(ctrl.remoteSiteUrlString,'','An issue with the url that we get on remoteSiteUrlString, must be distinct from empty');
		}
		System.Test.stopTest();
	}

	@isTest
	static void test_CRW_Settings() {
		// Implement test code
		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		RecommendationSettings__c ctrlSetting = ctrl.setupObj;
		//set values
		ctrlSetting.Recommend_if_aggregate_score_above__c = 10;
		ctrl.save();
		System.assertNotEquals(ctrl.getUrl(), null);
		System.assertEquals(ctrl.remoteSiteUrlNeedBoolean, null);
		System.Test.stopTest();
		System.assertEquals(ctrlSetting.Name, CRW_SettingsHandler.CONFIG_NAME);
		RecommendationSettings__c updated = [SELECT Id,Recommend_if_aggregate_score_above__c
											 FROM RecommendationSettings__c
											 WHERE name =:CRW_SettingsHandler.CONFIG_NAME];
		System.assertEquals(updated.Recommend_if_aggregate_score_above__c, 10);
	}

	@isTest
	static void test_saveDataException() {
		// Implement test code
		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		RecommendationSettings__c ctrlSetting = ctrl.setupObj;
		//set values
		ctrlSetting.Id = null;
		ctrlSetting.Name = null;
		ctrlSetting.Recommend_if_aggregate_score_above__c = 10;
		ctrl.save();
		System.Test.stopTest();

		List<RecommendationSettings__c> updated = [SELECT Id,Recommend_if_aggregate_score_above__c
											 	   FROM RecommendationSettings__c
											 	   WHERE name =:CRW_SettingsHandler.CONFIG_NAME];
		System.debug('updated.size(): ' + updated.size());
		System.assertNotEquals(updated[0].Recommend_if_aggregate_score_above__c, 10, 'Score should not be the same if it was not saved.');
	}

	/** TESTS for FIELDS SETTING **/
	@isTest static void test_fieldControllingMap() {
		// Implement test code
		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		Map<String,list<String>> ctrlFields = ctrl.fieldControllingMap;
		System.Test.stopTest();
		System.assertNotEquals(ctrlFields, null);
		System.assertEquals(ctrlFields.size(),0);
	}

	@isTest static void test_refreshFields_insertNEW() {
		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		Map<String,list<String>> ctrlFields = ctrl.fieldControllingMap;

		System.assertNotEquals(ctrlFields, null);
		System.assertEquals(ctrlFields.size(),0);
		ctrl.refreshFields();
		System.Test.stopTest();

		System.assertNotEquals(ctrl.fieldControllingMap, null);
	}

	@isTest
	static void test_refreshFields_update() {
		List<CaseFieldControllingMap__c> csList = new List<CaseFieldControllingMap__c>();
		csList.add (new CaseFieldControllingMap__c (Name ='TEST_NAM1', 	ControllerFields__c = 'ONE__c,TWO__c'));
		csList.add (new CaseFieldControllingMap__c (Name ='TEST_NAM2', 	ControllerFields__c = 'ONE__c,TWO__c'));
		csList.add (new CaseFieldControllingMap__c (Name ='TEST_NAM3', 	ControllerFields__c = 'ONE__c,TWO__c'));
		insert csList;

		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		Map<String,list<String>> ctrlFields = ctrl.fieldControllingMap;
		System.assertNotEquals(ctrlFields, null);
		System.assertEquals(ctrlFields.size(),3);
		ctrl.updateSyncFields();
		System.Test.stopTest();
		System.assertNotEquals(ctrl.fieldControllingMap, null);
		System.assertEquals(ctrl.fieldControllingMap.size(),1);
	}

	/** TESTS for VALUES SETTING **/
	@isTest
	static void test_fieldValuesControllingMap() {
		// Implement test code
		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		Map<String,List<Map<String,List<String>>>> ctrlVals = ctrl.fieldValuesControllingMap;
		System.Test.stopTest();
		System.assertNotEquals(ctrlVals, null);
		System.assertEquals(ctrlVals.size(),0);
	}

	@isTest
	static void test_refreshValues() {
		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		Map<String,List<Map<String,List<String>>>> ctrlVals = ctrl.fieldValuesControllingMap;

		ctrl.refreshValues();
		System.Test.stopTest();

		System.assertNotEquals(ctrlVals, null);
		System.assertEquals(ctrlVals.size(),0);
	}

	@isTest
	static void test_refreshValues_insertNEW() {
		System.Test.startTest();
		CRW_SettingsCtrl ctrl = new CRW_SettingsCtrl();
		Map<String,List<Map<String,List<String>>>> ctrlVals = ctrl.fieldValuesControllingMap;

		System.assertNotEquals(ctrlVals, null);
		System.assertEquals(ctrlVals.size(),0);
		CRW_SettingsCtrl.updateAsyncValues(UserInfo.getSessionId());
		System.Test.stopTest();

		System.assertNotEquals(ctrl.fieldValuesControllingMap, null);
		System.assertEquals(ctrl.fieldValuesControllingMap.size(),0);
	}
}