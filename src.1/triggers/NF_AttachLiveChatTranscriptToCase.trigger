/**
 * Created by mcasella on 4/15/18.
 */

trigger NF_AttachLiveChatTranscriptToCase on LiveChatTranscript (after insert) {
    Set<String> chatKeys = new Set<String>();

    for(LiveChatTranscript transcript : Trigger.new) {
        if((String.isBlank(transcript.caseId) || String.isBlank(transcript.leadId)) && String.isNotBlank(transcript.chatKey)) {
            chatKeys.add(transcript.chatKey);
        }
    }

    if(chatKeys.size() > 0) {
        list<nfchat__Chat_Log__c> logs = [select id, nfchat__chat_key__c,
        (select id from nfchat__cases__r order by createdDate desc limit 1),
        (select id from nfchat__leads__r order by createdDate desc limit 1)
        from nfchat__Chat_Log__c where nfchat__chat_key__c in :chatKeys];
        Map<String, Case> chatKeyCasesMap = new Map<String, Case>();
        Map<String, Lead> chatKeyLeadsMap = new Map<String, Lead>();
        for(nfchat__Chat_Log__c log : logs) {
            for(Case cs : log.nfchat__cases__r){
                chatKeyCasesMap.put(log.nfchat__chat_key__c, cs);
            }
            for(Lead ld : log.nfchat__leads__r){
                chatKeyLeadsMap.put(log.nfchat__chat_key__c, ld);
            }
        }
        List<LiveChatTranscript> transcriptsToUpdate = new List<LiveChatTranscript>();
        for(LiveChatTranscript transcript : Trigger.new) {
            if((String.isBlank(transcript.caseId) || String.isBlank(transcript.leadId)) && String.isNotBlank(transcript.chatKey)) {
                Case cs = chatKeyCasesMap.get(transcript.chatKey);
                Lead ld = chatKeyLeadsMap.get(transcript.chatKey);
                if(cs != null) {
                    transcriptsToUpdate.add( new LiveChatTranscript(
                            id = transcript.id,
                            caseId = cs.id
                    ));
                }
                if(ld != null) {
                    transcriptsToUpdate.add( new LiveChatTranscript(
                            id = transcript.id,
                            leadId = ld.id
                    ));
                }
            }
        }
        if (transcriptsToUpdate.size() > 0) {
            update transcriptsToUpdate;
        }
    }
}