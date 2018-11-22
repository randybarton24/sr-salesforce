/**
 * File:        IntacctErrorHandling_Test.cls
 * Project:     Sererra 
 * Date:        March 6, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Error Handling Test Class
 * *************************************************************************
 * History:
 */
 @isTest
public with sharing class IntacctErrorHandling_Test 
{
    /**
     * Test Method
    */
    public static testmethod void myTestMethod()
    {
    	//set current vf page
        PageReference testVfReference = Page.IntacctErrorHandling;
        Test.setCurrentPage(testVfReference);
        
    	//create test data
    	List<Intacct_Error__c> testIntacctErrors = CRUDSalesforceTestData.createIntacctErrors(15);
    	Intacct_Error__c testIntacctError = CRUDSalesforceTestData.createIntacctError(true);// test coverage for the CRUD class
    	testIntacctErrors.add(testIntacctError);
    	
    	//instantiate the controller
    	IntacctErrorHandling testInstance = new IntacctErrorHandling();
    	
    	//test the controller methods
    	testInstance.selectedObject = testIntacctError.getSObjectType().getDescribe().getName();
    	
    	Component.Apex.PageBlock testPageBlock = testInstance.getDynamicHeaderPageBlock();
    	System.assertEquals(testPageBlock.tabStyle, 'Contract');
    	
    	testPageBlock = null;
    	testPageBlock = testInstance.getDynamicBodyPageBlock();
        System.assertEquals(testPageBlock.tabStyle, 'Contract');
        
        testPageBlock = null;
        testPageBlock = testInstance.getDynamicDeletePageBlock();
        System.assertEquals(testPageBlock.tabStyle, 'Contract');
        
        Component.Apex.PanelGrid testPanelGrid = testInstance.getDynamicFooterPanelGrid();
        System.assertEquals(testPanelGrid.id, 'intacctFooterPanelGrid');
        
        testInstance.populateErrorSet();
        System.assertNotEquals(testInstance.errorRecordsSet, null);
        
        //test StandardSetControllerMethods - next, previous etc. - initial state
        Boolean testBoolean = testInstance.hasPrevious;
        System.assertEquals(testBoolean, false);
        testBoolean = testInstance.hasNext;
//        System.assertEquals(testBoolean, true);
        testInstance.first();
        testInstance.next();
        testInstance.previous();
        testInstance.last();
        
        //test the delete functionality
        testInstance.dateField.Date_Picker__c = System.now();
        testInstance.deleteIntacctErrors();
        testIntacctErrors = [SELECT Id FROM Intacct_Error__c];
        System.assertEquals(testIntacctErrors.size(), 0);
        
        //test StandardSetControllerMethods - next, previous - no records state
        testInstance.errorRecordsSet = null;
        testBoolean = testInstance.hasPrevious;
        System.assertEquals(testBoolean, false);
        testBoolean = testInstance.hasNext;
        System.assertEquals(testBoolean, false);
    }
}