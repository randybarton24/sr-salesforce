/**
 * File:        EncryptionDetailHandler.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        September 4, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description: Contains methods to process the dml events for the Encryption_Detail__c object.<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
public class EncryptionDetailHandler 
{
    private static final String ERROR_MESSAGE_ONLY_ONE_RECORD = 'Only one record is allowed on the Encryption Detail object.';
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Constructor
    */
    public EncryptionDetailHandler()
    {
        
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Check if there is a record inserted
    */
    public void checkIfInsertIsAllowed(List<Encryption_Detail__c> newRecords)
    {
        List<Encryption_Detail__c> existingRecords = retrieveEncryptionDetailRecords();
        if(!existingRecords.isEmpty())
        {
            addErrors(newRecords);
        }
        else
        {
            insertOneRecord(newRecords);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Retrieve the records from the encryption object
    */
    private List<Encryption_Detail__c> retrieveEncryptionDetailRecords()
    {
        List<Encryption_Detail__c> existingRecords;
        try
        {
            existingRecords = [SELECT Id FROM Encryption_Detail__c LIMIT 1];
        }
        catch(QueryException queryEx)
        {
            existingRecords = new List<Encryption_Detail__c>();
        }
        return existingRecords;
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Remove the first entry and add errors to the rest
    */
    private void insertOneRecord(List<Encryption_Detail__c> newRecords)
    {
        List<Encryption_Detail__c> allRecordsMinusOne = new List<Encryption_Detail__c>();
        allRecordsMinusOne.addAll(newRecords);
        allRecordsMinusOne.remove(0);
        addErrors(allRecordsMinusOne);
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Add errors to the other entries
    */
    private void addErrors(List<Encryption_Detail__c> newRecords)
    {
        for(Encryption_Detail__c currentRecord :newRecords)
        {
            currentRecord.addError(ERROR_MESSAGE_ONLY_ONE_RECORD);
        }
    }
    
}