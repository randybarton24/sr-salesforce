/**
 * File:        IntacctObjectsInterface_Test.cls
 * Project:     Sererra 
 * Date:        March 7, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Objects Interface Test Class
 * *************************************************************************
 * History:
 */
@isTest
public with sharing class IntacctObjectsInterface_Test 
{
	/**
	 * Test method
	*/
    public static testmethod void myTestMethod()
    {
    	//instantiate controller
        IntacctObjectsInterface testInstance = new IntacctObjectsInterface();
        
        //create test data
        IntacctObjectContact testContactObject = new IntacctObjectContact();
        IntacctObjectCustomer testCustomerObject = new IntacctObjectCustomer();
        Date testDate = System.today();
        
        //instantiate Intacct Object for all types of objects
        IntacctObjectsInterface.IntacctObject testIntacctObject = new IntacctObjectsInterface.IntacctObject(testContactObject);
        System.assertNotEquals(testIntacctObject.intacctObject, null);
        System.assertNotEquals(testIntacctObject.objectType, '');
        
        testIntacctObject = new IntacctObjectsInterface.IntacctObject(testCustomerObject);
        System.assertNotEquals(testIntacctObject.intacctObject, null);
        System.assertNotEquals(testIntacctObject.objectType, '');
                
        //instantiate Address
        IntacctObjectsInterface.Address testAddress = new IntacctObjectsInterface.Address();
        System.assertNotEquals(testAddress, null);
        
        //instantiate CustomField
        IntacctObjectsInterface.CustomField testCustomField = new IntacctObjectsInterface.CustomField();
        System.assertNotEquals(testCustomField, null);
        
        //instantiate ExpiryDate
        IntacctObjectsInterface.ExpiryDate testExpiryDate = new IntacctObjectsInterface.ExpiryDate(testDate);
        System.assertEquals(testExpiryDate.expMonth, String.valueOf(System.today().month()));
        System.assertEquals(testExpiryDate.expYear, String.valueOf(System.today().year()));
        
        //instantiate IntacctDate
        IntacctObjectsInterface.IntacctDate testIntacctDate = new IntacctObjectsInterface.IntacctDate(testDate);
        System.assertEquals(testIntacctDate.year, String.valueOf(System.today().year()));
        System.assertEquals(testIntacctDate.month, String.valueOf(System.today().month()));
        System.assertEquals(testIntacctDate.day, String.valueOf(System.today().day()));
    }
}