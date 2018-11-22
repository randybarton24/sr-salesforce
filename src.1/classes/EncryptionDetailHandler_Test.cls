/**
 * File:        EncryptionDetailHandler_Test.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        September 4, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description: Test class for EncryptionDetailHandler.<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
@isTest
public class EncryptionDetailHandler_Test 
{
    private static final String ENCRYPTION_RECORD_NAME = 'Test encryption record';
    /**
    * @author Ionut Boghean
    * @date September 4, 2014
    * @description Test happy flow
    */
    private static testMethod void testHappyFlow()
    {
        Encryption_Detail__c testEncryptionRecord1 = createEncryptionRecord();
        Encryption_Detail__c testEncryptionRecord2 = createEncryptionRecord();
        Test.startTest();
        EncryptionDetailHandler testInstance = new EncryptionDetailHandler();
        testInstance.checkIfInsertIsAllowed(new List<Encryption_Detail__c>{testEncryptionRecord1, testEncryptionRecord2});
        List<Encryption_Detail__c> testRec = [SELECT Id FROM Encryption_Detail__c];
        System.assertEquals(testRec.size(),0);
        Test.stopTest();
    }
    
    /**
    * @author Ionut Boghean
    * @date September 4, 2014
    * @description Create an encryption record
    */
    private static Encryption_Detail__c createEncryptionRecord()
    {
        Encryption_Detail__c newRecord = new Encryption_Detail__c();
        newRecord.Name = ENCRYPTION_RECORD_NAME;
        return newRecord;
    }
    
}