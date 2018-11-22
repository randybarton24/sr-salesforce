/**
 * Created by mcasella on 3/7/18.
 */
@IsTest
public with sharing class NF_TestChatLogUtils {

    @IsTest
    static void testRemoveHtml() {
        string html = '<br/>blah<br/>';
        html = NF_ChatLogUtils.removeHTML(html);
        System.assertEquals('\nblah\n', html);
    }

    @IsTest
    static void testGetChatConversationAStringNotFound(){
        string conversation = NF_ChatLogUtils.getChatConversationAString('blah', false);
        System.assertEquals('', conversation);
    }
}