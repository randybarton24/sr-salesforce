/**
 * Created by mcasella on 4/15/18.
 */

@IsTest
private class NF_TestAttachLiveChatTranscriptToCase {

    @IsTest
    static void testLinkTranscriptTOCase() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__Session_Id__c = '123';
        log.nfchat__AI_Config_Name__c = 'Name';
        log.nfchat__chat_key__c = '123';
        insert log;

        case cs = new case();
        cs.nfchat__chat_log__c = log.id;
        insert cs;

        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        Test.startTest();
        LiveChatTranscript tx = new LiveChatTranscript(
                chatKey = '123',
                liveChatVisitorId = visitor.id
        );
        insert tx;
        Test.stopTest();
        tx = [ SELECT id, caseId, chatKey FROM LiveChatTranscript WHERE id = :tx.id ];
        System.assertEquals( log.nfchat__chat_key__c, tx.chatKey );
        System.assertEquals( cs.id, tx.caseId );
    }
}