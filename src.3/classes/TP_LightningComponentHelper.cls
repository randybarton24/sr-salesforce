public without sharing class TP_LightningComponentHelper {
    
    public static string getCommunityId(){
        String communityName = Label.New_Community_Name;
        return [SELECT Id,name FROM Network where name = :communityName].Id;         
    }
    
    @AuraEnabled
    public static ConnectApi.KnowledgeArticleVersionCollection getTrendingArticles(){        
        String netwrkId = getCommunityId();
        SR_Default_Values__c removeFromTrending = SR_Default_Values__c.getValues('Remove From Trending');
        String[] articleIds = removeFromTrending.Value__c.split(',');
        ConnectApi.KnowledgeArticleVersionCollection trendingArticles = ConnectApi.Knowledge.getTrendingArticles(netwrkId,articleIds.size() + 5);
		Integer j = 0;
        while (j < trendingArticles.items.size()){
            if(articleIds.contains(trendingArticles.items.get(j).knowledgeArticleId)) {
                trendingArticles.items.remove(j);
            }
            else if(trendingArticles.items.size() >= 4 && j > 4 ) {
                    trendingArticles.items.remove(j);
            }
            else{
                    j++;
            }
        }
        return trendingArticles;
    }
    
    @AuraEnabled
    public static list<Topic> getTopSixTopics(){
        String netwrkId = getCommunityId();        
        return [Select id,Name,TalkingAbout,NetworkId,Description from Topic where NetworkId = :netwrkId limit 6];
    }
    
    @AuraEnabled
    public static Webinar__kav getSelectedWebinar(string webinarId){
        Webinar__kav webinarIns = new Webinar__kav();
        webinarIns = [Select Id,Title,Summary,Video_link__c from Webinar__kav where id =: webinarId];
        return webinarIns;
    }
    
    @AuraEnabled
    public static list<FeedItem> getAllFeedItems(){
        String netwrkId = getCommunityId();
        return [SELECT CommentCount,Id,LikeCount,ParentId,Title,Type,Visibility 
                FROM FeedItem WHERE NetworkScope = :netwrkId and Type='QuestionPost' order by CommentCount DESC, LikeCount DESC];
       
    }
    
    @AuraEnabled
    public static Contact getContact(Id contactId){
        Contact conObj =null;
        User usr = [Select ContactId from User where Id=: UserInfo.getUserId()];
        if(usr.ContactId !=null){
            conObj = [
                    SELECT Id, Name, Email, Phone
                    FROM Contact
                    WHERE Id =:usr.ContactId
                ];
        }else{
            conObj = new Contact(FirstName='she');
        }
        return conObj;
    }
    
    @AuraEnabled
    public static list<Webinar__kav> getWebinars(){
        return [select id,Title,UrlName,Thumbnail_Rich__c,Video_link__c,Summary from Webinar__kav];
    }
    
    @AuraEnabled
    public static String getUserProfile(){
        string profileName = [select name from profile where id =: userinfo.getProfileId()].name;
        return profileName;
    }
    
    @AuraEnabled
    public static list<User> getUsers() 
    {        
        list<Id> setOfUsersId= new list<Id>();
        map<id,user> myMap1= new map<id,user>();
        map<integer,id> myMap2= new map<integer,id>();
        map<id,user> mapOfUserId = new Map<Id,User>();
        list<user> userListToQuery = new list<user>();
        
        string curntUserProfileId = userinfo.getProfileId();
        string profileName = label.Profile_Name;
        string guestUserProfileId = [select id from profile where name = :profileName].Id;
        string systemAminProfileId = [select id from profile where name = 'System Administrator'].Id;
        
        integer temp = 0;
        for(NetworkMember nm_User : [SELECT MemberId,ReputationPoints from NetworkMember WHERE Member.Profile.Name = 'Customer Community KB User' ORDER BY ReputationPoints DESC NULLS LAST limit 10]){            
            temp++;
            myMap1.put(nm_User.MemberId,null);
            myMap2.put(temp,nm_User.MemberId);                        
            setOfUsersId.add(nm_User.MemberId);            
        }        
        
        if(curntUserProfileId != guestUserProfileId && curntUserProfileId != systemAminProfileId){
            userListToQuery = [SELECT Id,FirstName,LastName,SmallPhotoUrl, Email, Phone From User WHERE profileId = :curntUserProfileId and ID IN :setOfUsersId];
        }else{
            userListToQuery = [SELECT Id,FirstName,LastName,SmallPhotoUrl, Email, Phone From User WHERE ID IN :setOfUsersId];
        }
        for(user u : userListToQuery){
            mapOfUserId.put(u.id,u);
        }
        list<user> userlist = new list<user>();
        for(Integer i = 1;i <= myMap2.size();i++)
        {                        
            userlist.add(mapOfUserId.get(myMap2.get(i)));
        }
        return userlist;
    }
    
    @AuraEnabled
    public static list<FeedItem> getFeedItems() 
    {
        String netwrkId = getCommunityId();
        return [SELECT CommentCount,Id,LikeCount,ParentId,Title,Type,Visibility 
                FROM FeedItem WHERE NetworkScope = :netwrkId and Type='QuestionPost' and Visibility = 'AllUsers' order by CommentCount DESC, LikeCount DESC limit 5];       
    }
    
    @AuraEnabled
    public static string getAccountTypeInformation(){        
        string accType = ''; 
        string userId = userinfo.getUserId();
//        string accId = [select id,accountid from contact where name =: userName limit 1].accountId;  
        string accId = [SELECT AccountId FROM User WHERE Id = : userId].AccountId;
        if(accId != null){
            accType = [SELECT Id,RecordType.Name FROM Account WHERE Id = : accId].RecordType.Name;
        }        
        return accType;
    }
    
    @AuraEnabled
    public static String getUserName() {  
        return userinfo.getName();
    }        
    
    @AuraEnabled
    public static list<PopularTopics> getTopics(){        
        map<String,PopularTopics> pTopicsMap = new map<String,PopularTopics>();        
        set<string> topicsList = new set<string>();        
        String netwrkId = getCommunityId();       
        BusinessHours bh = [select Id from BusinessHours where IsDefault=true];
        Date dDate = BusinessHours.add(bh.Id, Datetime.Now(), -172800000).Date();                
        for(Topic tp : [Select id,Name,TalkingAbout,NetworkId,Description from Topic where NetworkId = :netwrkId]){
            PopularTopics pTopicIns = new PopularTopics();
            topicsList.add(tp.Id);
            pTopicIns.topicInstance = tp;
            pTopicIns.totalDiscussions = 0;
            pTopicIns.activeDiscussions = 0;
            pTopicsMap.put(tp.Id,pTopicIns);
        }                    
                
        map<string,string> feedItemVsTopic = new map<string,string>();
        for(TopicAssignment tAsnmt : [select EntityId,TopicId from TopicAssignment where EntityType = 'feeditem' and TopicId IN :topicsList and networkId = :netwrkId ]){       
            feedItemVsTopic.put(tAsnmt.EntityId,tAsnmt.TopicId);
                                    
            PopularTopics pTopicInst = new PopularTopics();            
            integer totalDiscsn = 0;
            
            pTopicInst = pTopicsMap.get(tAsnmt.TopicId);
            totalDiscsn = pTopicInst.totalDiscussions;
            totalDiscsn++; 
            pTopicInst.totalDiscussions = totalDiscsn;                        
            
            pTopicsMap.put(tAsnmt.TopicId,pTopicInst);
        }
        for(FeedItem fItem : [select id,LastEditDate,CreatedDate from FeedItem where type = 'QuestionPost' and ID IN :feedItemVsTopic.keySet()]){
            PopularTopics pTopic = new PopularTopics();
            pTopic = pTopicsMap.get(feedItemVsTopic.get(fItem.Id));
            integer activeDiscsn = 0;
            
            if(dDate < fItem.CreatedDate){
                activeDiscsn = pTopic.activeDiscussions;
                activeDiscsn++;
            }            
            pTopic.activeDiscussions = activeDiscsn;
            pTopicsMap.put(feedItemVsTopic.get(fItem.Id),pTopic);
        }        
        list<PopularTopics> finalPopularTopicList = new list<PopularTopics>();           
        list<PopularTopics> tempList = new list<PopularTopics>();
        tempList = pTopicsMap.values();
        system.debug('tempList1>>>'+tempList);
        tempList.sort();
        system.debug('tempList2>>>'+tempList);
        integer z = pTopicsMap.values().size()-1;        
        for(integer y=0;y<pTopicsMap.values().size();y++){
            finalPopularTopicList.add(tempList.get(z));
            z--;
        }        
        system.debug('finalPopularTopicList>>>>>'+finalPopularTopicList);
        //system.debug('finalPopularTopicList.sort()>>>+'+finalPopularTopicList.sort());
        return finalPopularTopicList;
    }
    
    public class PopularTopics implements Comparable{
        @AuraEnabled
        public topic topicInstance{get;set;}
        @AuraEnabled
        public integer activeDiscussions{get;set;}
        @AuraEnabled
        public integer totalDiscussions{get;set;}
        
        public Integer compareTo(Object objToCompare) {            
            return Integer.valueOf(activeDiscussions - ((PopularTopics)objToCompare).totalDiscussions);           
        }
    }
}