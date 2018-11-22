/**
 * File:        IntacctEncryptionManager_Test.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        September 3, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description: Test class for IntacctEncryptionManager.<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
@isTest
public class IntacctEncryptionManager_Test 
{
    private static final String VALUE_TO_ENCRYPT = 'Encryption string';
    
    /**
    * @author Ionut Boghean
    * @date September 4, 2014
    * @description Test happy flow
    */
    private static testMethod void testHappyFlow()
    {
        String encryptedString = '';
        String decryptedString = '';
        Test.startTest();
        IntacctEncryptionManager.setPrivateEncryptionKey();
        IntacctEncryptionManager.upsertEncryptionObject();
        encryptedString = IntacctEncryptionManager.encryptValue(Blob.valueOf(VALUE_TO_ENCRYPT));
        decryptedString = IntacctEncryptionManager.decryptValue(EncodingUtil.base64Decode(encryptedString));
        Test.stopTest();
        System.assertEquals(decryptedString, VALUE_TO_ENCRYPT);
    }
}