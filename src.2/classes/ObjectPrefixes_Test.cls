/**
 * File:        ObjectPrefixes_Test.cls
 * Project:     Sererra 
 * Date:        January 8, 2013
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: Test class for ObjectPrefixes
 * *************************************************************************
 * History:
 */
@isTest
private class ObjectPrefixes_Test 
{

    static testMethod void myUnitTest() 
    {
        ObjectPrefixes prefixes = new ObjectPrefixes();
        String leadPrefix = prefixes.getPrefixByObjectName('Lead');
        String leadObjectName = prefixes.getObjectNameByPrefix(leadPrefix);
        String tmpPrefix = prefixes.getPrefixByObjectName(leadObjectName);
        String leadObjectLabel = prefixes.getObjectLabelByPrefix(leadPrefix);
        
        System.assertEquals(leadPrefix, tmpPrefix);
        System.assertEquals(leadObjectName, 'Lead');
        System.assertEquals(leadObjectLabel, 'Lead');
        
    }
}