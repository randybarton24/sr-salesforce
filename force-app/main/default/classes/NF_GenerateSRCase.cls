/**
 * Created by mcasella on 3/7/18.
 */

global without sharing class NF_GenerateSRCase implements nfchat.AIMethodService{
    global void doInvoke(String chatId) {
        String source = 'Chatbot';

        nfchat__Chat_Log__c log = [SELECT Id, Name, nfchat__First_Name__c, nfchat__Last_Name__c, nfchat__Email__c, nfchat__Company__c, (Select Id, nfchat__Request__c, nfchat__Response__c, nfchat__Intent_Name__c from nfchat__Chat_Log_Details__r) FROM nfchat__Chat_Log__c WHERE Id = :chatId];

        Case case1 = new Case();

        User user = [Select Id, ContactId, username from User WHERE Id = :UserInfo.getUserId()];
        case1.contactId = user.ContactId;

        String contactEmail = '';
        Contact[] contacts = [Select Id, email from Contact where id = :user.ContactId];
        if (!contacts.isEmpty()) {
            try {
                contactEmail = contacts[0].email;
                log.nfchat__Email__c = contacts[0].email;
                upsert log;
            } catch (DmlException e) {
               System.debug('NF_GenerateSRCase: Failed to update chat log:'+e.getMessage());
            }
        }

        case1.Origin = 'Chatbot';
        case1.Subject = 'SARA Chatbot Case';
//      case1.Category__c = 'Training';
        case1.Features_Options__c = 'Determine Need';
        case1.Main_Issue__c = 'Initial Interaction';
        case1.nfchat__Chat_Log__c = chatId;

        case1.RecordTypeId = [Select Id from RecordType where Name = 'Support'].Id;

        //if no auto-assign flag is returned, assign the case to the Support queue
        Group g = [select Id, name from Group where name = 'Chat Bot Case Queue'];
        if (g != null) {
            case1.OwnerId = g.Id;
        }

        //get the last business intent
        String intentName = 'no_intent';
        List<nfchat__Chat_Log_Detail__c> details = log.nfchat__Chat_Log_Details__r;
        for(Integer i = details.size() - 1; i >= 0; i--){
            if(String.isNotEmpty(details[i].nfchat__Intent_Name__c) && details[i].nfchat__Intent_Name__c.indexOf('business.') == 0){
                intentName = details[i].nfchat__Intent_Name__c;
                break;
            }
        }

        //this parameter returned takes precedence over the last business intent
        if(String.isNotEmpty(log.nfchat__Company__c)){
            //for some reason, if we generate a case directly from an intent, we're not getting the intent name back
            //so I set up a temporary variable with the intent name, assigned to company, so we can retrieve it
            intentName = log.nfchat__Company__c;
        }

        //Case field assignment
        if('business.groups.how_to' == intentName){
            case1.Features_Options__c = 'Groups';
            case1.Main_Issue__c = 'Create Group';
        }
        else if('business.notification.how_to' == intentName){
            case1.Features_Options__c = 'SR Notify';
            case1.Main_Issue__c = 'Notifications';
        }
        else if('business.notifications.newsletters' == intentName) {
            case1.Features_Options__c = 'Groups';
            case1.Main_Issue__c = 'Newsletter Adjustment';
        }
        else if(intentName.indexOf('business.sync.t') == 0) {
            case1.RecordTypeId = [Select Id from RecordType where Name = 'Sync List Case'].Id;
            case1.Features_Options__c = 'Sync';
            case1.Main_Issue__c = 'Database Connection';
//          case1.Category__c = 'Technical';
        }
        else if('business.account.cancel' == intentName) {
            case1.Features_Options__c = 'Contract';
//          case1.Category__c = 'Administrative';
            case1.Main_Issue__c = 'General Questions/Renewal Date';
        }
        else if('business.reviews.facebook' == intentName) {
            case1.Features_Options__c = 'Online Presence';
            case1.Main_Issue__c = 'Linking Social Media';
        }
        else if('business.account.login' == intentName) {
            case1.Features_Options__c = 'Password';
//          case1.Category__c = 'Administrative';
            case1.Main_Issue__c = 'Reset';
        }
        else if('business.account.action_list' == intentName) {
            case1.Features_Options__c = 'Action List';
            case1.Main_Issue__c = 'Check In';
        }
        else if('business.notification.token' == intentName) {
            case1.Features_Options__c = 'Groups';
            case1.Main_Issue__c = 'Adjust Templates';
        }
        else if('business.account.update' == intentName) {
            case1.Features_Options__c = 'Information';
            case1.Main_Issue__c = 'Update Information';
        }
        else if('business.sync.last_time' == intentName) {
            case1.Features_Options__c = 'Action List';
            case1.Main_Issue__c = 'Practice Stats';
        }
        else if('business.legal.hipaa' == intentName) {
            case1.Features_Options__c = 'Legal';
//          case1.Category__c = 'Administrative';
            case1.Main_Issue__c = 'HIPAA Questions';
        }
        else if('business.reviews.google_place_id' == intentName) {
            case1.Features_Options__c = 'Online Presence';
            case1.Main_Issue__c = '3rd Party Settings';
        }
        else if('business.legal.contract' == intentName) {
            case1.Features_Options__c = 'Contract';
//          case1.Category__c = 'Administrative';
            case1.Main_Issue__c = 'Copy of contract';
        }
        else if('business.general.webinars' == intentName) {
            case1.Features_Options__c = 'Information';
            case1.Main_Issue__c = 'Update Information';
        }
        else if('business.general.sr_huddle' == intentName) {
            case1.Features_Options__c = 'Conversations';
            case1.Main_Issue__c = 'More information';
        }
        else if('business.general.sr_conversations' == intentName) {
            case1.Features_Options__c = 'Conversations';
            case1.Main_Issue__c = 'More information';
        }

        insert case1;
    }
}