/**
 * File:        IntacctSyncObjects_Test.cls
 * Project:     Sererra 
 * Date:        March 4, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Sync Objects Test Class
 * *************************************************************************
 * History:
 * Date:         Modified By:       Description: 
 * 
*/
@isTest
public with sharing class IntacctSyncObjects_Test 
{
    private static final String INTACCT_SETTING_NAME = 'Intacct Gateway';
    private static final String INTACCT_COMPANY = 'Test COmpany';
    private static final String INTACCT_URL = 'Test Url';
    private static final String INTACCT_USER_PASSWORD = 'Test User Password';
    private static final String INTACCT_USER = 'Test User';
    private static final String INTACCT_SENDER = 'Test Sender';
    private static final String INTACCT_SENDER_PASSWORD = 'Test Sender Password';
	/*
     *Test method
    */
    public static testmethod void myTestMethod()
    {
        //instantiate the controller
        IntacctSyncObjects testInstance = new IntacctSyncObjects();
        
        //create test data
        String customerId = 'Test Customer Id';
        Intacct_Error__c testObject = new Intacct_Error__c();
        insert testObject;
        createIntacctSetting();
        List<Object> testObjectList = new List<Object>();
        IntacctObjectCustomer testCustomer = new IntacctObjectCustomer();
        testCustomer.customerId = customerId;
        testCustomer.salesforceId = testObject.Id;
        testObjectList.add(testCustomer);
        
        //call the controller methods
        IntacctSyncObjects.getObjects(testObjectList);
        IntacctSyncObjects.createObjects(testObjectList, true);
        IntacctSyncObjects.updateObjects(testObjectList, true);
        IntacctSyncObjects.upsertObjects(testObjectList, true);
        IntacctSyncObjects.deleteObjects(testObjectList);
        system.assertEquals(testObjectList.size(), 1);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the custom intacct setting
    */
    private static void createIntacctSetting()
    {
        Intacct_Integration_Settings__c newIntacctSetting = new Intacct_Integration_Settings__c();
        newIntacctSetting.Name = INTACCT_SETTING_NAME;
        newIntacctSetting.Intacct_Company_ID__c = INTACCT_COMPANY;
        newIntacctSetting.Intacct_Gateway_URL__c = INTACCT_URL;
        newIntacctSetting.Intacct_Password__c = INTACCT_USER_PASSWORD;
        newIntacctSetting.Intacct_User_ID__c = INTACCT_USER;
        newIntacctSetting.Intacct_Sender_ID__c = INTACCT_SENDER;
        newIntacctSetting.Intacct_Sender_Password__c = INTACCT_SENDER_PASSWORD;
        try
        {
            insert newIntacctSetting;
        }
        catch(Exception ex)
        {
            newIntacctSetting = new Intacct_Integration_Settings__c();
        }
    }
}