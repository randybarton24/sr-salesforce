/**
 * File:        IntacctGlobalVariables_Test.cls
 * Project:     Sererra 
 * Date:        March 5, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Global Variables Test Class
 * *************************************************************************
 * History:
 */
 @isTest
public with sharing class IntacctGlobalVariables_Test 
{   
	/*
     *Test method
    */
    public static testmethod void myTestMethod()
    {
	    //instantiate the controller
	    Test.startTest();
	    IntacctGlobalVariables testInstance = new IntacctGlobalVariables();
	    System.assertNotEquals(testInstance, null);    
	    Test.stopTest();
    }
}