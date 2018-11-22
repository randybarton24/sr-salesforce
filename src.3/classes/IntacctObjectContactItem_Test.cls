/**
 * File:        IntacctObjectContactItem_Test.cls
 * Project:     Sererra 
 * Date:        February 27, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Contact Item Test Class
 * *************************************************************************
 * History:
 * Date:         Modified By:       Description: 
 * 
*/
@isTest
public class IntacctObjectContactItem_Test 
{
    /**
     *Test method
    */
    public static testmethod void myTestMethod()
    {
        //instantiate the controller
        IntacctObjectContactItem testInstance = new IntacctObjectContactItem();
            
        //create a DOM.xmlNode variable
        DOM.Document testDocument = new DOM.Document();
        DOM.xmlNode testNode = testDocument.createRootElement(IntacctGlobalVariables.TEST_VALUE, '', '');
            
        //createContactItemNode method
        testNode = testInstance.createContactItemNode(testNode);
        System.assertEquals(testNode.getChildren().size(), 1);
        
    }
}