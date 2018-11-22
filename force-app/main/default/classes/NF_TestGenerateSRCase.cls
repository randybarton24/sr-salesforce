/**
 * Created by mcasella on 3/7/18.
 */

@IsTest
private class NF_TestGenerateSRCase {
    static {
        //Test_Data.runInstall();
    }

    @IsTest
    static void testCreateCase() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__First_Name__c = 'sandeep';
        log.nfchat__Last_Name__c = 'Peddireddy';
        log.nfchat__Email__c = 'gfhj@gfhjh.com';
        log.nfchat__Phone__c = '703-470-9927';
        log.nfchat__AI_Config_Name__c = 'gfh';
        log.nfchat__Session_Id__c = 'fghjk';
        insert log;

        Test.startTest();

        String chatId = log.Id;
        new NF_GenerateSRCase().doInvoke(chatId);
        Test.stopTest();
        Case[] cases = [SELECT Id from Case];
        system.assertNotEquals(null,cases);
        System.assertEquals(1, cases.size());
    }


    @IsTest
    static void testCaseType() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__First_Name__c = 'sandeep';
        log.nfchat__Last_Name__c = 'Peddireddy';
        log.nfchat__Email__c = 'gfhj@gfhjh.com';
        log.nfchat__Phone__c = '703-470-9927';
        log.nfchat__AI_Config_Name__c = 'gfh';
        log.nfchat__Session_Id__c = 'fghjk';
        insert log;

        Test.startTest();

        String chatId = log.Id;
        new NF_GenerateSRCase().doInvoke(chatId);
        Test.stopTest();
        Case[] cases = [SELECT Id, RecordTypeId from Case];
        system.assertNotEquals(null,cases);
        System.assertEquals(1, cases.size());
        //System.assertEquals('012800000007PCT', cases[0].RecordTypeId);
    }

    @IsTest
    static void testCaseOrigin() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__First_Name__c = 'sandeep';
        log.nfchat__Last_Name__c = 'Peddireddy';
        log.nfchat__Email__c = 'gfhj@gfhjh.com';
        log.nfchat__Phone__c = '703-470-9927';
        log.nfchat__AI_Config_Name__c = 'gfh';
        log.nfchat__Session_Id__c = 'fghjk';
        insert log;

        Test.startTest();

        String chatId = log.Id;
        new NF_GenerateSRCase().doInvoke(chatId);
        Test.stopTest();
        Case[] cases = [SELECT Id, Origin from Case];
        system.assertNotEquals(null,cases);
        System.assertEquals(1, cases.size());
        System.assertEquals('Chatbot', cases[0].Origin);
    }

    public static testMethod void testRunAsLoggedIn(){

        // Setup test data
        // Create a unique UserName
        // This code runs as the system user
        //User u = [SELECT Id, IsActive FROM User WHERE alias = 'mcase' AND IsActive = true];

        //System.runAs(communityuser)

        //System.runAs(u) {
        // The following code runs as user 'u'
        System.debug('Community User: ' + UserInfo.getUserName());
        System.debug('Community Profile: ' + UserInfo.getProfileId());
    }

    @IsTest
    static void testBusinessIntent() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__First_Name__c = 'sandeep';
        log.nfchat__Last_Name__c = 'Peddireddy';
        log.nfchat__Email__c = 'gfhj@gfhjh.com';
        log.nfchat__Phone__c = '703-470-9927';
        log.nfchat__AI_Config_Name__c = 'gfh';
        log.nfchat__Session_Id__c = 'fghjk';
        insert log;

        nfchat__Chat_Log_Detail__c d1 = new nfchat__Chat_Log_Detail__c();
        d1.nfchat__request__c = 'test';
        d1.nfchat__response__c = 'test';
        d1.nfchat__Intent_Name__c = 'business.test';
        d1.nfchat__Chat_Log__c = log.Id;
        insert d1;

        Test.startTest();

        String chatId = log.Id;
        new NF_GenerateSRCase().doInvoke(chatId);
        Test.stopTest();
        Case[] cases = [SELECT Id, Origin from Case];
        system.assertNotEquals(null,cases);
        System.assertEquals(1, cases.size());
        System.assertEquals('Chatbot', cases[0].Origin);
    }
    
    @IsTest
    static void testCaseTypes1() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__First_Name__c = 'Matt';
        log.nfchat__Last_Name__c = 'Casella';
        log.nfchat__Email__c = 'matt.casella@neuraflash.com';
        log.nfchat__Phone__c = '201-555-1212';
        log.nfchat__AI_Config_Name__c = 'gfh';
        log.nfchat__Session_Id__c = 'fghjk';
       
        Test.startTest();
        
        insert log;
        String[] intents = new String[]{ 'business.groups.how_to', 'business.sync.t', 'business.notification.how_to', 'business.notifications.newsletters' };
        
        for(String intent : intents){
        
            nfchat__Chat_Log_Detail__c d1 = new nfchat__Chat_Log_Detail__c();
            d1.nfchat__request__c = 'test';
            d1.nfchat__response__c = 'test';
            d1.nfchat__Intent_Name__c = intent;
            d1.nfchat__Chat_Log__c = log.Id;
            insert d1;
            
            String chatId = log.Id;
            new NF_GenerateSRCase().doInvoke(chatId);
        }
        
        Test.stopTest();
        
        Case[] cases = [SELECT Id, Origin from Case];
        System.assertNotEquals(null,cases);
        System.assertEquals('Chatbot', cases[0].Origin);
    }
    
    @IsTest
    static void testCaseTypes2() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__First_Name__c = 'Matt';
        log.nfchat__Last_Name__c = 'Casella';
        log.nfchat__Email__c = 'matt.casella@neuraflash.com';
        log.nfchat__Phone__c = '201-555-1212';
        log.nfchat__AI_Config_Name__c = 'gfh';
        log.nfchat__Session_Id__c = 'fghjk';
       
        Test.startTest();
        
        insert log;
        String[] intents = new String[]{ 'business.account.cancel', 'business.reviews.facebook', 'business.account.login', 'business.account.action_list' };
        
        for(String intent : intents){
        
            nfchat__Chat_Log_Detail__c d1 = new nfchat__Chat_Log_Detail__c();
            d1.nfchat__request__c = 'test';
            d1.nfchat__response__c = 'test';
            d1.nfchat__Intent_Name__c = intent;
            d1.nfchat__Chat_Log__c = log.Id;
            insert d1;
            
            String chatId = log.Id;
            new NF_GenerateSRCase().doInvoke(chatId);
        }
        
        Test.stopTest();
        
        Case[] cases = [SELECT Id, Origin from Case];
        System.assertNotEquals(null,cases);
        System.assertEquals('Chatbot', cases[0].Origin);
    }
    
    @IsTest
    static void testCaseTypes3() {
        nfchat__Chat_Log__c log = new nfchat__Chat_Log__c();
        log.nfchat__First_Name__c = 'Matt';
        log.nfchat__Last_Name__c = 'Casella';
        log.nfchat__Email__c = 'matt.casella@neuraflash.com';
        log.nfchat__Phone__c = '201-555-1212';
        log.nfchat__AI_Config_Name__c = 'gfh';
        log.nfchat__Session_Id__c = 'fghjk';
       
        Test.startTest();
        
        insert log;
        String[] intents = new String[]{ 'business.notification.token', 'business.account.update', 'business.sync.last_time', 'business.legal.hipaa' };
        
        for(String intent : intents){
        
            nfchat__Chat_Log_Detail__c d1 = new nfchat__Chat_Log_Detail__c();
            d1.nfchat__request__c = 'test';
            d1.nfchat__response__c = 'test';
            d1.nfchat__Intent_Name__c = intent;
            d1.nfchat__Chat_Log__c = log.Id;
            insert d1;
            
            String chatId = log.Id;
            new NF_GenerateSRCase().doInvoke(chatId);
        }
        
        Test.stopTest();
        
        Case[] cases = [SELECT Id, Origin from Case];
        System.assertNotEquals(null,cases);
        System.assertEquals('Chatbot', cases[0].Origin);
    }
}