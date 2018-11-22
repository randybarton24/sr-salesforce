trigger NF_SetFirstRecognitionResult on nfchat__Chat_Log_Detail__c (before insert) {
    try{
        List<nfchat__Chat_Log_Detail__c> userRequests = new List<nfchat__Chat_Log_Detail__c>();
        List<Id> chatLogIds = new List<Id>();
      
        //find all chat log details that are in consideration to be NLP user requests
        //by DEFAULT this is if the user typed a request AND it is not an event sent by the Chatbot
        for(nfchat__Chat_Log_Detail__c detail : Trigger.new){
            if(String.isNotEmpty(detail.nfchat__Request__c) && detail.nfchat__Request__c.length() > 5 && 'Text'.equals(detail.nfchat__Input_Mode__c) && detail.nfchat__Is_Event_Request__c == false){
                userRequests.add(detail);
                chatLogIds.add(detail.nfchat__Chat_Log__c);
                System.debug('NF_SetFirstRecognitionResult: added userRequest='+detail);
                System.debug('NF_SetFirstRecognitionResult: userRequest log.id='+detail.nfchat__Chat_Log__c);
            }
        }  
        System.debug('NF_SetFirstRecognitionResult: eligible userRequests='+userRequests);
        
        //if we have eligible user requests
        if(userRequests.size() > 0){
            List<nfchat__Chat_Log_Detail__c> results = [SELECT Id, nfchat__Chat_Log__c FROM nfchat__Chat_Log_Detail__c WHERE nfchat__Chat_Log__c IN :chatLogIds AND nfchat__First_Recognition_Result__c = true];
            System.debug('NF_SetFirstRecognitionResult: results='+results);
            
            Map<Id, nfchat__Chat_Log_Detail__c> resultsMap = new Map<Id, nfchat__Chat_Log_Detail__c>();
            for(nfchat__Chat_Log_Detail__c d : results)
            {
                 resultsMap.put(d.nfchat__Chat_Log__c, d);
            }
            System.debug('NF_SetFirstRecognitionResult: resultsMap='+resultsMap);
            
            //now look at each request
            for(nfchat__Chat_Log_Detail__c userRequest : userRequests){
                System.debug('NF_SetFirstRecognitionResult: userRequest '+userRequest);
                
                //check if we already have a recognition result in our map
                boolean hasFirstRecogntion = resultsMap.containsKey(userRequest.nfchat__Chat_Log__c);
                System.debug('NF_SetFirstRecognitionResult: hasFirstRecogntion='+hasFirstRecogntion);
                
                //if we don't, this details is the first recognition result
                if(hasFirstRecogntion == false){
                    userRequest.nfchat__First_Recognition_Result__c = true;
                    System.debug('NF_SetFirstRecognitionResult: set First_Recognition_Result__c for nfchat__Chat_Log__c='+userRequest.nfchat__Chat_Log__c);
                }
                else{
                    System.debug('NF_SetFirstRecognitionResult: already have a first recognition result for for nfchat__Chat_Log__c'+userRequest.nfchat__Chat_Log__c);
                }
            }
        }
        else{
            System.debug('NF_SetFirstRecognitionResult: no user requests to consider');
        }
    }
    catch(Exception e){
        System.debug('NF_SetFirstRecognitionResult: ERROR setting First_Recognition_Result__c: '+e.getMessage());
    }
}