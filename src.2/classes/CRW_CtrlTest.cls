@isTest
private with sharing class CRW_CtrlTest {

    @isTest
    private static void testPrefixInformation(){
        PageReference pageRef = Page.CRW_Landing;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        CRW_Ctrl ctrl = new CRW_Ctrl();
        String prefix = ctrl.currentPrefix;
        Test.stopTest();

        System.assert(prefix != null, 'Invalid prefix information');
    }

    @isTest
    private static void testURLParams(){
        PageReference pageRef = Page.CRW_Landing;
        pageRef.getParameters().put('id', '50046000001zx0eAAA');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        CRW_Ctrl ctrl = new CRW_Ctrl();
        Id recordId = ctrl.recordId;
        Test.stopTest();

        System.assert(recordId == '50046000001zx0eAAA', 'Invalid record id');
        System.assert(ctrl.hasIdParam, 'Page does not have id param');
    }

    @isTest
    private static void testRecommendationCustomSettings(){
        List<RecommendationSettings__c> listToUpdate = new List<RecommendationSettings__c>();
        RecommendationSettings__c actualSettingToCheck = new RecommendationSettings__c();
        actualSettingToCheck.Name = 'Test_custom_settings';
        actualSettingToCheck.Recommend_if_aggregate_score_above__c = 40;
        actualSettingToCheck.Recommend_if_single_score_above__c = 50;
        actualSettingToCheck.Top_value_badge_if_score_above__c = 60;
        listToUpdate.add(actualSettingToCheck);
        upsert listToUpdate;

        Test.startTest();
        RecommendationSettings__c b = RecommendationSettings__c.getall().values();

        System.assert(b.Recommend_if_aggregate_score_above__c == actualSettingToCheck.Recommend_if_aggregate_score_above__c, 'Issue setting up custom setting');
        System.assert(b.Top_value_badge_if_score_above__c == actualSettingToCheck.Top_value_badge_if_score_above__c, 'Issue setting up custom setting');
        System.assert(b.Recommend_if_single_score_above__c == actualSettingToCheck.Recommend_if_single_score_above__c, 'Issue setting up custom setting');
        Test.stopTest();
    }

    @isTest
    private static void testReturnFinalOrdListFromMapOrdByDepAndAlph() {
        Map<String, List<String>> paramToReturnFinalOrdListFromMapOrdByDepAndAlph = new Map<String, List<String>>();
        List<String> listA = new List<String>{'Example1.1','Example1.2','Example1.3'};
        List<String> listB = new List<String>{'Example2.1','Example2.2','Example2.3'};
        List<String> listC = new List<String>{'Example3.1','Example3.2','Example3.3'};
        paramToReturnFinalOrdListFromMapOrdByDepAndAlph.put('Example1',listA);
        paramToReturnFinalOrdListFromMapOrdByDepAndAlph.put('Example2',listB);
        paramToReturnFinalOrdListFromMapOrdByDepAndAlph.put('Example3',listC);
        List<String> resultParam = new List<String>{'Example1','This move after 1.3','Example1.1','Example1.2','Example1.3','Example2','This move after 2.3','Example2.1','Example2.2','Example2.3','Example3','Example3.1','This move after 3.3','Example3.2','Example3.3'};
        List<String> expectedListToBeReturned = new List<String>{'Example1','Example1.1','Example1.2','Example1.3','This move after 1.3','Example2','Example2.1','Example2.2','Example2.3','This move after 2.3','Example3','Example3.1','Example3.2','Example3.3','This move after 3.3'};
        List<String> receivedList = CRW_Ctrl.returnFinalOrdListFromMapOrdByDepAndAlph(paramToReturnFinalOrdListFromMapOrdByDepAndAlph,resultParam);

        Test.startTest();
        Integer actualIndex = 0;
        for(String actualExpected : expectedListToBeReturned)
        {
            System.assert(actualExpected == receivedList.get(actualIndex) , 'An issue with the returned list and expected list - each element must be in the same order than expected');
            actualIndex++;
        }
        Test.stopTest();
    }

    @isTest
    private static void testOrderControllersMapByDepenedency() {
        Map<String, List<String>> paramToOrderControllersMapByDependency = new Map<String, List<String>>();
        Map<String, List<String>> expectedResultFromTheController = new Map<String, List<String>>();

        List<String> listA = new List<String>{'Example1.1','Example1.2','Example2'};
        List<String> listB = new List<String>{'Example2.1','Example2.2','Example3'};
        List<String> listC = new List<String>{'Example3.1','Example3.2','Example3.3'};
        paramToOrderControllersMapByDependency.put('Example1',listA);
        paramToOrderControllersMapByDependency.put('Example2',listB);
        paramToOrderControllersMapByDependency.put('Example3',listC);
        List<String> listWithExpectedValues = new List<String>{'Example1.1','Example1.2','Example2','Example2.1','Example2.2','Example3','Example3.1','Example3.2','Example3.3'};
        expectedResultFromTheController.put('Example1',listWithExpectedValues);

        Test.startTest();
        Map<String, List<String>> paramReceived = CRW_Ctrl.orderControllersMapByDepenedency(paramToOrderControllersMapByDependency);
        System.assert(paramReceived.keySet().size() == expectedResultFromTheController.keySet().size() ,'An issue occurred.');
        for (String key : expectedResultFromTheController.keySet())
        {
            System.assert(expectedResultFromTheController.get(key) == paramReceived.get(key),'An issue with the expected and received map, value with same key is not equals');
        }
        Test.stopTest();
    }

    @isTest
    private static void testCaseUpdate() {
        Map<String,String> valuesMap = new Map<String, String>{
            'Origin' => 'Web',
            'Status' => 'Closed'
        };

        Case mockCase = new Case();
        mockCase.Status = 'New';
        mockCase.Origin = 'Phone';
        mockCase.Subject = 'TestEinsteinService';
        insert mockCase;

        Test.startTest();
        Map<String, String> response = CRW_Ctrl.updateRecord(mockCase.Id, valuesMap);
        Test.stopTest();

        System.assert(response.get('recordId') == mockCase.Id, 'Invalid record id');
    }

    @isTest
    private static void testCaseUpdateException() {
        Map<String,String> valuesMap = new Map<String, String>{
            'Origin' => 'Web',
            'Status' => 'Closed'
        };

        Case mockCase = new Case();
        mockCase.Status = 'New';
        mockCase.Origin = 'Phone';
        mockCase.Subject = 'TestEinsteinService';
        insert mockCase;

        // Store id
        Id mockCaseId = mockCase.Id;

        // Delete the case to cause an exception
        delete mockCase;

        Test.startTest();
        Map<String, String> response = CRW_Ctrl.updateRecord(mockCaseId, valuesMap);
        Test.stopTest();

        System.assertEquals('false', response.get('success'), 'Success should be false.');
    }

    @isTest
    private static void testGetFieldLabels() {
        List<String> fieldsToSolve = new List<String>();
        fieldsToSolve.add('Type');

        Test.startTest();
        Map<String,String> result = CRW_Ctrl.getFieldLabels(fieldsToSolve);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'List size should be above 0.');
    }

    @isTest
    private static void testGetFieldTypes() {
        List<String> fieldsToSolve = new List<String>();
        fieldsToSolve.add('Type');

        Test.startTest();
        Map<String,String> result = CRW_Ctrl.getFieldTypes(fieldsToSolve);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'List size should be above 0.');
    }

    @isTest
    private static void testFieldNamesOrderedValues() {
        List<String> fieldsToSort = new List<String>();
        fieldsToSort.add('Type');
        fieldsToSort.add('CaseNumber');

        Test.startTest();
        List<String> result = CRW_Ctrl.fieldNamesOrderedValues(fieldsToSort);
        Test.stopTest();

        List<String> expectedList = new List<String>();
        expectedList.add('casenumber');
        expectedList.add('type');

        System.assertEquals(expectedList, result, 'The lists should be equal in order.');
    }

    // Test for unexisting field because there is no way to know if a relationship between fields exists in unit testing.
    @isTest
    private static void testNullGetPickListDependencyFromCustomSettings() {
        List<String> depFields = new List<String>();
        depFields.add('UnexistingField');

        Test.startTest();
        Map<String,List<String>> result = CRW_Ctrl.getPickListDependencyFromCustomSettings(depFields);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'List size should be 0.');
    }

    @isTest
    private static void testNullGetPickListOptionsDependency() {
        Test.startTest();
        Map<String,List<String>> result = CRW_Ctrl.getPickListOptionsDependency('UnexistingField');
        Test.stopTest();

        System.assertEquals(0, result.size(), 'List size should be 0.');
    }

    @isTest
    private static void testGetFieldsAllValues() {
        List<String> allFields = new List<String>();
        allFields.add('Type');

        Test.startTest();
        Map<String,Map<String,String>> result = CRW_Ctrl.getFieldsAllValues(allFields);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'List size should be above 0.');
    }

    @isTest
    private static void testGetAllFields() {
        List<String> allFields = new List<String>();
        allFields.add('Type');

        Test.startTest();
        List<String> result = CRW_Ctrl.getAllFields(allFields);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'List size should be above 0.');
    }

    @isTest
    private static void testResolveLabelsAndDependencies() {
        String recommendationsMap = '{'+
         	'\"Type\":[{'+
        		'\"value\":\"Mechanical\",'+
        		'\"score\":91.0,'+
        		'\"recordRecommendationId\":\"0RRf4000000CaStGAK\"'+
                '},{'+
                '\"value\":\"Electrical\",'+
        		'\"score\":92.0,'+
        		'\"recordRecommendationId\":\"0RRf4000000CaStGAK\"'+
        		 '},{'+
                '\"value\":\"Electronic\",'+
        		'\"score\":93.0,'+
        		'\"recordRecommendationId\":\"0RRf4000000CaStGAK\"'+
        		 '},{'+
                '\"value\":\"Structural\",'+
        		'\"score\":94.0,'+
        		'\"recordRecommendationId\":\"0RRf4000000CaStGAK\"'+
        		 '},{'+
                '\"value\":\"Other\",'+
        		'\"score\":91.0,'+
        		'\"recordRecommendationId\":\"0RRf4000000CaStGAK\"}'+
    		']'+
        '}';

        Case c = new Case();
        insert c;

        Test.startTest();
        Map<String,String> result = CRW_Ctrl.resolveLabelsAndDependencies(c.Id + '', recommendationsMap);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'List size should be above 0.');
    }

    @isTest
    private static void testGetActualValueForNextFieldOnCase() {
        Case c = new Case();
        insert c;

        List<String> allFields = new List<String>();
        allFields.add('Type');

        Test.startTest();
        Map<String,String> result = CRW_Ctrl.getActualValueForNextFieldOnCase(c.Id + '', allFields);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'List size should be above 0.');
    }

    @isTest
    private static void testFilterFieldsByAccessPermissions() {
        Case c = new Case();
        insert c;

        List<String> allFields = new List<String>();
        allFields.add('Type');

        Test.startTest();
        List<String> result = CRW_Ctrl.filterFieldsByAccessPermissions(allFields);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'List size should be above 0.');
    }

    /*@isTest
    private static void testGetPickListDependencyFromCustomSettings(){
        List<String> depFields = new List<String>();
        depFields.add('Type');

        CaseFieldControllingValuesMap__c newCaseMap = new CaseFieldControllingValuesMap__c (
            Name =  'Type_Structural',
            FieldAPIName__c = 'Type',
            ControllingFieldValue__c = 'Structural',
            DependentFields__c = 'Structural 1.1'
        );

        Test.startTest();
        insert newCaseMap;

        Map<String,List<String>> result = CRW_Ctrl.getPickListDependencyFromCustomSettings(depFields);
        System.debug('result here: ' + result);
        Test.stopTest();

        System.assertNotEquals(0, result.size());
    }*/

}