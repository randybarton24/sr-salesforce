trigger EncryptionDetailTrigger on Encryption_Detail__c (before insert) 
{
    EncryptionDetailHandler handlerInstance = new EncryptionDetailHandler();
    handlerInstance.checkIfInsertIsAllowed(Trigger.new);
}