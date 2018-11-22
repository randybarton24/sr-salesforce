/**
 * File:        IntacctObjectVisibility_Test.cls
 * Project:     Sererra 
 * Date:        March 1, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Visibility Test Class
 * *************************************************************************
 * History:
 * Date:         Modified By:       Description: 
 * 
*/
@isTest
public class IntacctObjectVisibility_Test 
{
    /**
     *Test method
    */
    public static testmethod void myTestMethod()
    {
        //instantiate the controller
        IntacctObjectVisibility testInstance = new IntacctObjectVisibility();
        
        //set required properties
        testInstance.restrictedDepartmentIds = new List<String>();
        testInstance.restrictedLocationIds = new List<String>();
        
        //create a DOM.xmlNode variable
        DOM.Document testDocument = new DOM.Document();
        DOM.xmlNode testNode = testDocument.createRootElement('test name', '', '');
            
        //createEndingNode method
        testNode = testInstance.createVisibilityNode(testNode);
        System.assertEquals(testNode.getChildren().size(), 1);
        
    }
}