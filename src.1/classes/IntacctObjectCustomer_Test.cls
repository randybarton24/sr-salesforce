/**
 * File:        IntacctObjectCustomer_Test.cls
 * Project:     Sererra 
 * Date:        February 28, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Customer Test Class
 * *************************************************************************
 * History:
 * Date:         Modified By:       Description: 
 * 
*/
@isTest
public class IntacctObjectCustomer_Test 
{
    /**
     *Test method
    */
    public static testmethod void myTestMethod()
    {
        //instantiate the controller
        IntacctObjectCustomer testInstance = new IntacctObjectCustomer();
            
        //add required properties
        List<String> testDeliveryOptionList = new List<String>{IntacctGlobalVariables.TEST_VALUE};
        IntacctObjectContactItem testContactItem = new IntacctObjectContactItem();
        List<IntacctObjectContactItem> testContactItemList = new List<IntacctObjectContactItem>{testContactItem};
        IntacctObjectContact testContact = new IntacctObjectContact();
        IntacctObjectVisibility testVisibility = new IntacctObjectVisibility();
        testVisibility.restrictedDepartmentIds = new List<String>{IntacctGlobalVariables.TEST_VALUE};
        testVisibility.restrictedLocationIds = new List<String>{IntacctGlobalVariables.TEST_VALUE};
        testInstance.visibility = testVisibility;
        testInstance.contactList = testContactItemList;
        testInstance.deliveryOptions = testDeliveryOptionList;
        testInstance.ignoreDuplicates = IntacctGlobalVariables.TEST_VALUE;
        testInstance.customerId = IntacctGlobalVariables.TEST_VALUE;
        testInstance.primary = testContact;
        testInstance.billTo = testContact;
        testInstance.shipTo = testContact;
        testInstance.contactInfo = testContact;
        IntacctObjectsInterface.CustomField testCustomField = new IntacctObjectsInterface.CustomField();
        testCustomField.customFieldName = IntacctGlobalVariables.TEST_VALUE;
        testCustomField.customFieldValue = IntacctGlobalVariables.TEST_VALUE;
        List<IntacctObjectsInterface.CustomField> testCustomFields = new List<IntacctObjectsInterface.CustomField>{testCustomField};
        testInstance.customFields = testCustomFields;
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