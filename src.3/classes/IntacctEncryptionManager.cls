/**
 * File:        IntacctEncryptionManager.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        September 3, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description: Contains methods to encrypt and decrypt intacct credentials.<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
public class IntacctEncryptionManager 
{
    private static final String ENCRYPTION_ALGORITHM = 'AES256';
    private static final Integer KEY_SIZE = 256;
    private static final String KEY_WRAPPER_NAME = 'Intacct credentials private key';
    private static Blob privateKey;
    private static Encryption_Detail__c privateKeyWrapper;
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Encrypt a value
    */
    public static String encryptValue(Blob valueToEncrypt)
    {
        String encryptedValue = '';
        Blob encryptionData = Crypto.encryptWithManagedIV(ENCRYPTION_ALGORITHM, privateKey, valueToEncrypt);
        encryptedValue = EncodingUtil.base64Encode(encryptionData);
        return encryptedValue;
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Decrypt a value
    */
    public static String decryptValue(Blob valueToDecrypt)
    {
        String decryptedValue = '';
        Blob decryptionData = Crypto.decryptWithManagedIV(ENCRYPTION_ALGORITHM, privateKey, valueToDecrypt);
        decryptedValue = decryptionData.toString();
        return decryptedValue;
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Set the private key used for the encryption process
    */
    public static void setPrivateEncryptionKey()
    {
        privateKeyWrapper = retrievePrivateKeyWrapper();
        if(privateKeyWrapper == null)
        {
            generateEncryptionKey();
            privateKeyWrapper = new Encryption_Detail__c();
        }
        else
        {
            privateKey = EncodingUtil.base64Decode(privateKeyWrapper.Value__c);
        }
        System.debug('PRIVATE KEY: ' + privateKeyWrapper.Value__c);
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Set the private key used for the encryption process
    */
    public static void upsertEncryptionObject()
    {
        if(privateKeyWrapper != null)
        {
            privateKeyWrapper.Name = KEY_WRAPPER_NAME;
            privateKeyWrapper.Value__c = EncodingUtil.base64Encode(privateKey);
            upsert privateKeyWrapper;
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Generate a new encryption key
    */
    private static void generateEncryptionKey()
    {
        privateKey = Crypto.generateAesKey(KEY_SIZE);
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Retrieve the encryption object
    */
    private static Encryption_Detail__c retrievePrivateKeyWrapper()
    {
        Encryption_Detail__c intacctPrivateKey;
        try
        {
            intacctPrivateKey = [SELECT Id, Name, Value__c FROM Encryption_Detail__c WHERE Name = :KEY_WRAPPER_NAME LIMIT 1];
        }
        catch(QueryException queryEx)
        {
            
        }
        return intacctPrivateKey;
    }
    
}