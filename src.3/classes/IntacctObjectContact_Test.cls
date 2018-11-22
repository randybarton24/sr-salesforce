/**
 * File:        IntacctObjectContact_Test.cls
 * Project:     Sererra 
 * Date:        February 27, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Contact Test Class
 * *************************************************************************
 * History:
 * Date:         Modified By:       Description: 
 * 
*/
@isTest
public class IntacctObjectContact_Test 
{
    /**
     *Test method
    */
    public static testmethod void myTestMethod()
    {
        //instantiate the controller
        IntacctObjectContact testInstance = new IntacctObjectContact();
            
        //set required properties
        IntacctObjectsInterface.Address testAddress = new IntacctObjectsInterface.Address();
        testInstance.mailAddress = testAddress;
        testInstance.contactName = IntacctGlobalVariables.TEST_VALUE;
        testInstance.ignoreDuplicates = IntacctGlobalVariables.TEST_VALUE;
        testInstance.intacctFieldListForGetCall = new List<String>{IntacctGlobalVariables.TEST_VALUE};
        testInstance.logicalExpression = CRUDSalesforceTestData.createLogicalExpression();
        
        //create a DOM.xmlNode variable
        DOM.xmlNode testNode = null;
            
        //getRecordRequest method
        testNode = testInstance.getRecordRequest();
        System.assertEquals(String.isBlank(testNode.getName()), false);
        
        //setRecordRequest method
        testNode = null;
        testNode = testInstance.setRecordRequest(true, IntacctGlobalVariables.actionType_Create);
        System.assertEquals(String.isBlank(testNode.getName()), false);
        
        //deleteRecordRequest method
        testNode = null;
        testNode = testInstance.deleteRecordRequest();
        System.assertEquals(String.isBlank(testNode.getName()), false);
            
    }
}