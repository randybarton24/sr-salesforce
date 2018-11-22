@isTest
private class NF_TestSetFirstRecognitionResult {
    
    @isTest static void TestFirstRecognitionResult() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__Session_Id__c = 'abc';
        log.nfchat__AI_Config_Name__c = 'test';
        
        nfchat__Chat_Log_Detail__c detail = new nfchat__Chat_Log_Detail__c();
        detail.nfchat__Request__c = 'this is a test';
        detail.nfchat__Input_Mode__c = 'Text';
        detail.nfchat__Is_Event_Request__c = false;
        
        // Perform test
        Test.startTest();
        insert log;
        detail.nfchat__Chat_Log__c = log.id;
        insert detail;
        Test.stopTest();
        
        nfchat__Chat_Log_Detail__c inserted = [Select id, nfchat__First_Recognition_Result__c from nfchat__Chat_Log_Detail__c where id =: detail.id];
        // Verify 
        // In this case the first recognition result should have been set
        System.assertEquals(true, inserted.nfchat__First_Recognition_Result__c);
    }
    
}