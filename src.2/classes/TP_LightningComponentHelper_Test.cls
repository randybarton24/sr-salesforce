@isTest
public class TP_LightningComponentHelper_Test {
    @isTest
    static void LightningComponentHelper_Test1(){
        String communityName = Label.New_Community_Name;        
        String netwrkId = [SELECT Id,name FROM Network where name = :communityName].Id;
        
        Topic top = new Topic();
        top.Name ='test';
        top.NetworkId = netwrkId;
        insert top;
                
        Webinar__kav webinarIns = new Webinar__kav();
        webinarIns.Title = 'test';
        webinarIns.UrlName = 'test';
        insert webinarIns;
        
        Contact con = new Contact();
        con.LastName = 'test';
        insert con;
        
        String id = webinarIns.id;
        FeedItem fI = new FeedItem();
        fI.Type = 'QuestionPost';
        fI.Title = 'test';
        fI.ParentId = con.Id;
        insert fI;
        
        TopicAssignment topassignment = new TopicAssignment();
        topassignment.EntityId = fI.id;
        topassignment.NetworkId = netwrkId;
        topassignment.TopicId = top.Id;
        insert  topassignment;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        
        
        String id1 = con.Id;
        User us = new user();
        // us.ContactId = id1;
        us.LastName = 'test';
        us.Username = 'singhal@acme.com';
        us.Email = 'singhal@acme.com';
        us.TimeZoneSidKey = 'America/Denver';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'ISO-8859-1';
        us.LanguageLocaleKey = 'en_US';
        us.ProfileId = p.id;
        us.Alias = 'test';
        insert us;
        
        String name  = 'test';
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Account acct = new Account();
        acct.Type ='Prospect';
        acct.Name = 'test';
        acct.RecordTypeId = RecordTypeIdAccount;
        insert acct;
        
        con.AccountId = acct.Id;
        update con;
        
        //insert us;
        
        Test.startTest();
        TP_LightningComponentHelper.getTopSixTopics();
        TP_LightningComponentHelper.getSelectedWebinar(id);
        TP_LightningComponentHelper.getAllFeedItems();
        TP_LightningComponentHelper.getContact(id1);
        TP_LightningComponentHelper.getWebinars();
        TP_LightningComponentHelper.getFeedItems();
        TP_LightningComponentHelper.getAccountTypeInformation();
        TP_LightningComponentHelper.getUsers();
        TP_LightningComponentHelper.getUserName();
        TP_LightningComponentHelper.getTopics();
        TP_LightningComponentHelper.getUserProfile();
        //TP_LightningComponentHelper.PopularTopics popularTopics = new TP_LightningComponentHelper.PopularTopics();
        Test.stopTest();
        
    }
    
    
    
}