/**
 * Created by mcasella on 5/1/18.
 */

global with sharing class NF_SendUserInfo implements nfchat.AIProcessor {
    public Map<String, String> buildContext()
    {
        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('visitorId', UserInfo.getUserId());
        resultMap.put('isMultiUser', 'false');

        try {
            User user = [Select Id, ContactId, username from User WHERE Id = :UserInfo.getUserId()];
            if (String.isNotEmpty(user.ContactId)) {
                resultMap.put('contactId', user.ContactId);

                Contact[] contacts = [select id, accountId from Contact where id = :user.ContactId];

                if (contacts.size() > 0) {
                    resultMap.put('accountId', contacts[0].accountId);

                    Account[] accounts = [select id, name from account where id = :contacts[0].accountId and RecordType.Name IN ('Child Multi-Location Account', 'Multi-Location Account')];
                    if (accounts.size() > 0) {
                        resultMap.put('isMultiUser', 'true');
                    }

                }
            }
        }
        catch(Exception e){
            System.debug('NF_GenerateSRCase: Error sending user info:'+e.getMessage());
        }


        return resultMap;
    }
}