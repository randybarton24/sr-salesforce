/**
 * Created by mcasella on 3/7/18.
 */

public with sharing class NF_ChatLogUtils {

    public static String getChatConversationAString(String chatLogOrSessionId, Boolean isSessionId) {
        String chatConversation = '';
        String soql = 'Select Id, nfchat__Chat_Log__c, nfchat__Request__c, nfchat__Response__c from nfchat__Chat_Log_Detail__c';
        if (isSessionId)
            soql += ' where Chat_Log__r.Session_Id__c = :chatLogOrSessionId order by CreatedDate';
        else
                soql += ' where nfchat__Chat_Log__c = :chatLogOrSessionId order by CreatedDate';
        for (nfchat__Chat_Log_Detail__c cld : Database.query(soql)) {
            chatConversation += '[guest] '+removeHTML(cld.nfchat__Request__c) + ':[bot] ' + cld.nfchat__Response__c + '\n';
        }
        return chatConversation;
    }

    public static String removeHTML(String html){

        html = html.unescapeHtml4();
        //first replace all <BR> tags with \n to support new lines
        string result = html.replaceAll('<br/>', '\n');
        result = result.replaceAll('<br />', '\n');

        //regular expression to match all HTML/XML tags
        string HTML_TAG_PATTERN = '<.*?>';

        // compile the pattern
        pattern myPattern = pattern.compile(HTML_TAG_PATTERN);

        // get your matcher instance
        matcher myMatcher = myPattern.matcher(result);

        //remove the tags
        result = myMatcher.replaceAll('');

        //remove the brackets and special chars
        result = result.replace('["','');
        result = result.replace('"]','');

        return result.unescapeHtml4();
    }
}