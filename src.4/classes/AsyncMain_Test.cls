@isTest
private class AsyncMain_Test {
    
    @testSetup static void testData() 
    {
        TestUtilities.insertCustomSettings();
    }

    @isTest static void test_startBatch() 
    {                
        AsyncMain.startBatch();          
    }

    @isTest static void getSchedulerExpression1() 
    {
        Datetime dt = Date.today();
        String result = AsyncMain.getSchedulerExpression(dt);
        System.assertEquals('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(), result);
    }

    @isTest static void setup_Execute1() 
    {   
        Product2 prod2 = new Product2(
            Name = 'Product 2', 
            RecurSoft__Billing_Frequency__c ='Monthly',
            Default_Co_Terminate__c = true,
            ProductCode = '00123');        
        insert prod2;
      
        PricebookEntry  pbEntryStandard = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),                                                
            Product2Id = prod2.Id,
            UnitPrice = 379,
            IsActive = true,
            Auto_Add__c = true,
            Auto_Add_Quantity__c = 1); 
        insert pbEntryStandard; 

        Pricebook2 pb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pb;

        PricebookEntry pbEntryCustom = new PricebookEntry(
            Pricebook2Id = pb.Id,                                                
            Product2Id = prod2.Id,
            UnitPrice = 379,
            IsActive = true,
            Auto_Add__c = true,
            Auto_Add_Quantity__c = 1); 
        insert pbEntryCustom;  

        RecurSoft__Intacct_Entity__c intacct = new RecurSoft__Intacct_Entity__c(Name = 'TestAccount2');
        insert intacct;
                       
        Account a = new Account(
            Name = 'TestAccount2',
            RecurSoft__Intacct_Entity__c = intacct.id,
            Industry = 'Dental');                    
        insert a;

        Task t = new Task(
            WhatId  = a.Id,
            CreatedDate = Date.today(), 
            ADR_Set__c = true,
            Activity_Results__c = 'Spoke with-');
        insert t;
                                    
        insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

         insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c='defaultPricebookId',
            Value__c = pb.Id); 

        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = String.valueOf(UserInfo.getProfileId()));
  
        Opportunity o = new Opportunity(
            AccountId = a.Id,
            StageName = 'Qualified',
            Name = 'Test Opportunity',
            CloseDate = Date.today(),                
            RecurSoft__Contract_Signed_Date__c = Date.newInstance(2018,1,1));
        insert o;                  
                    
        OpportunityLineItem oppLi = new OpportunityLineItem(
            Total_Monthly_Revenue__c = 50,
            OpportunityId = o.Id,
            PricebookEntryId = pbEntryCustom.Id,
            UnitPrice = 10,
            Invoiced_Price__c = 2,
            Quantity = 4);              
        insert oppLi;                

        AsyncRequest__c async = new AsyncRequest__c(
                CreatedDate = Date.today(), 
                AsyncType__c = AsyncMain.TYPE_ADR_TASK_REVENUE, 
                Params__c = o.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id', 
                RequestedEmail__c = true); 
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();

        System.assertEquals(1, [select count() from task where ADR_Set_SR_Revenue__c != null]);
    }  

    @isTest static void setup_Execute2() 
    {   
        User u;
        Account a;           
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (thisUser) 
        {
            a = new Account(
                Name = 'TestAccount2',
                Industry = 'Dental');                    
            insert a;

            String profileName = 'System Administrator';
            String roleName = 'CSR Enterprise';
            Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            UserRole r = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1];
            u = new User(Username = profileName.deleteWhitespace() + '@solutionreach.com',
                            Alias = profileName.deleteWhitespace().substring(0,7),
                            LastName = 'TestUserLast',
                            Email = profileName.deleteWhitespace() + '@solutionreach.com',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            TimeZoneSidKey = 'America/Denver',
                            ProfileId = p.Id,
                            UserRoleId = r.Id);                   
            insert u;
        }
               
        AsyncRequest__c  async = new AsyncRequest__c(                
                AsyncType__c = AsyncMain.TYPE_SYNC_RECORD_OWNERS, 
                Params__c = a.Id + ':' + u.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id', 
                RequestedEmail__c = true);                
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();

        System.assertEquals(1, [select count() from account where OwnerId != null]);
    } 

    @isTest static void setup_Execute3() 
    {   
        User u;
        Account a;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (thisUser) 
        {            
            String profileName = 'System Administrator';
            String roleName = 'CSR Enterprise';
            Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            UserRole r = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1];
            u = new User(Username = profileName.deleteWhitespace() + '@solutionreach.com',
                            Alias = profileName.deleteWhitespace().substring(0,7),
                            LastName = 'TestUserLast',
                            Email = profileName.deleteWhitespace() + '@solutionreach.com',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            TimeZoneSidKey = 'America/Denver',
                            ProfileId = p.Id,
                            UserRoleId = r.Id);                   
            insert u;

            a = new Account(
                Name = 'TestAccount2',
                OwnerId = u.Id);                    
            insert a;
        }

        Stamp_Field_Mapping__c st = new Stamp_Field_Mapping__c(
            Stamp_To_Object__c = 'Account',
            Stamp_From_Object__c = 'Account',
            Stamp_From_Field__c = 'Name',
            Active__c = true,
            Field_Changed__c = 'OwnerId',
            Stamp_To_Field__c = 'AccountNumber',
            Field_Changed_Value__c = String.valueOf(u.Id));
        insert st;
    
        AsyncRequest__c async = new AsyncRequest__c(                
                AsyncType__c = AsyncMain.TYPE_STAMP_UPDATES, 
                Params__c = a.Id + '::' + st.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id', 
                RequestedEmail__c = true);
                
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();

        System.assertEquals(1, [select count() from account where AccountNumber = 'TestAccount2']);
    } 

    @isTest static void setup_Execute4() 
    {           

        User u;
        Account a;        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        RecurSoft__Intacct_Entity__c intacct = new RecurSoft__Intacct_Entity__c(Name = 'TestAccount2');
        insert intacct;
        
        System.runAs (thisUser) 
        {            
            String profileName = 'System Administrator';
            String roleName = 'CSR Enterprise';
            Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            UserRole r = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1];
            u = new User(
                Username = profileName.deleteWhitespace() + '@solutionreach.com',
                Alias = profileName.deleteWhitespace().substring(0,7),
                LastName = 'TestUserLast',
                Email = profileName.deleteWhitespace() + '@solutionreach.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Denver',
                ProfileId = p.Id,
                UserRoleId = r.Id);                   
            insert u;

            a = new Account(
                Name = 'TestAccount2',
                RecurSoft__Intacct_Entity__c = intacct.id,
                Industry = 'Dental',
                OwnerId = u.Id);                    
            insert a;
        }

        Pricebook2 pb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pb;
        
        insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

         insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c='defaultPricebookId',
            Value__c = pb.Id); 

        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = String.valueOf(UserInfo.getProfileId()));
  
        Opportunity o = new Opportunity(            
            Name = 'Test Opportunity',
            StageName = 'No Sale',
            CloseDate = Date.today(),
            AccountId = a.Id,
            OwnerId = u.Id,
            Cancel_Month__c = Date.today().toStartofMonth());
        insert o;  

        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'email@solutionreach.com',
            Phone = '8013317150',
            AccountId = a.Id);        
        insert c;

        Campaign camp = new Campaign(
            Name = 'Test Pricing Campaign',
            IsActive = true,
            StartDate = Date.today(),
            EndDate = Date.today().addDays(90),
            Type = 'Pricing',
            Status = 'In Progress',
            Free_Months__c ='2',
            Free_Months_Setting__c = 'Extend Contract - At the Beginning',                       
            Trial_Period__c = '90');
        insert camp;
       
        AsyncRequest__c async = new AsyncRequest__c(                
                AsyncType__c = AsyncMain.TYPE_CREATE_CI, 
                Params__c = c.Id + '::' + camp.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id',
                CreatedDate = Date.today(), 
                RequestedEmail__c = true);
                
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();

        System.assertEquals(1, [select count() from Campaign_Influence__c ]);
    } 

    @isTest static void setup_Execute5() 
    {           
        User u;
        Account a;        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        RecurSoft__Intacct_Entity__c intacct = new RecurSoft__Intacct_Entity__c(Name = 'TestAccount2');
        insert intacct;
        
        System.runAs (thisUser) 
        {            
            String profileName = 'System Administrator';
            String roleName = 'CSR Enterprise';
            Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            UserRole r = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1];
            u = new User(
                Username = profileName.deleteWhitespace() + '@solutionreach.com',
                Alias = profileName.deleteWhitespace().substring(0,7),
                LastName = 'TestUserLast',
                Email = profileName.deleteWhitespace() + '@solutionreach.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Denver',
                ProfileId = p.Id,
                UserRoleId = r.Id);                   
            insert u;

            a = new Account(
                Name = 'TestAccount2',
                RecurSoft__Intacct_Entity__c = intacct.id,
                Industry = 'Dental',
                OwnerId = u.Id);                    
            insert a;
        }

        Pricebook2 pb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pb;
        
        insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

         insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c='defaultPricebookId',
            Value__c = pb.Id); 

        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = String.valueOf(UserInfo.getProfileId()));
  
        Opportunity o = new Opportunity(            
            Name = 'Test Opportunity',
            StageName = 'Demo Scheduled',
            CloseDate = Date.today(),
            AccountId = a.Id,
            OwnerId = u.Id,
            Cancel_Month__c = Date.today().toStartofMonth());
        insert o;  

        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'email@solutionreach.com',
            Phone = '8013317150',
            AccountId = a.Id);        
        insert c;

        Campaign camp = new Campaign(
            Name = 'Test Pricing Campaign',
            IsActive = true,
            StartDate = Date.today(),
            EndDate = Date.today().addDays(90),
            Type = 'Pricing',
            Status = 'In Progress',
            Sub_Type__c = null,
            Free_Months__c ='2',
            Free_Months_Setting__c = 'Extend Contract - At the Beginning',                       
            Trial_Period__c = '90');
        insert camp;

        Campaign_Influence__c campInfluence = new Campaign_Influence__c(
            Campaign__c = camp.Id,
            Contact__c = c.Id,
            Lead__c = null,
            Opportunity__c = o.Id,
            Account__c = a.Id,
            Associated_Rep__c = u.Id,
            Demo_Request_Reason__c = true);
        insert campInfluence;
       
        AsyncRequest__c async = new AsyncRequest__c(                
                AsyncType__c = AsyncMain.TYPE_DEMO_REQUEST_REASON, 
                Params__c = o.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id',
                CreatedDate = Date.today(), 
                RequestedEmail__c = true);
                
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();

        System.assertEquals(1, [select count() from Campaign_Influence__c where Demo_Request_Reason__c=false]);
    } 

    @isTest static void setup_Execute6() 
    {           
        Product2 prod2 = new Product2(
            Name = 'Product 2', 
            RecurSoft__Billing_Frequency__c ='Monthly',
            Default_Co_Terminate__c = true,
            ProductCode = '00123');        
        insert prod2;
      
        PricebookEntry  pbEntryStandard = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),                                                
            Product2Id = prod2.Id,
            UnitPrice = 379,
            IsActive = true,
            Auto_Add__c = true,
            Auto_Add_Quantity__c = 1); 
        insert pbEntryStandard; 

        Pricebook2 pb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pb;

        PricebookEntry pbEntryCustom = new PricebookEntry(
            Pricebook2Id = pb.Id,                                                
            Product2Id = prod2.Id,
            UnitPrice = 379,
            IsActive = true,
            Auto_Add__c = true,
            Auto_Add_Quantity__c = 1); 
        insert pbEntryCustom;   

        RecurSoft__Intacct_Entity__c intacct = new RecurSoft__Intacct_Entity__c(Name = 'TestAccount2');
        insert intacct;
                       
        Account a = new Account(
            Name = 'TestAccount2',
            RecurSoft__Intacct_Entity__c = intacct.id,
            Industry = 'Dental');                    
        insert a;

                        
        insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

        insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c='defaultPricebookId',
            Value__c = pb.Id); 

        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = String.valueOf(UserInfo.getProfileId()));
  
  
        Opportunity o = new Opportunity(            
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            AccountId = a.Id,
            StageName = 'Qualified');
        insert o;                  
                    
        OpportunityLineItem oppLi = new OpportunityLineItem(            
            OpportunityId = o.Id,
            List_Price_Override__c = 0,
            UnitPrice = 3,
            Number_of_Free_Months__c = 1,
            Promotional_Price__c = 50,
            PricebookEntryId = pbEntryCustom.Id,
            Invoiced_Price__c = 2,
            Quantity = 4,
            Total_Monthly_Revenue__c = 50,
            Free_Month_Setting__c = 'Extend Contract - At the Beginning', 
            Trial__c = '0');              
        insert oppLi;                

        List<AsyncRequest__c> asyncRequest = new List<AsyncRequest__c>();        
       
        AsyncRequest__c async = new AsyncRequest__c(                
                AsyncType__c = AsyncMain.TYPE_PRODUCT_TERMS_ROLLUP, 
                Params__c = o.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id', 
                RequestedEmail__c = true);             
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();

        System.assertEquals(1, [select count() from opportunity]);
    } 

    
    @isTest static void setup_Execute7() 
    {             

        Pricebook2 pb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pb;

        RecurSoft__Intacct_Entity__c intacct = new RecurSoft__Intacct_Entity__c(Name = 'TestAccount2');
        insert intacct;
                       
        Account a = new Account(
            Name = 'TestAccount2',
            RecurSoft__Intacct_Entity__c = intacct.id,
            Industry = 'Dental');                    
        insert a;

                        
        insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

        insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c='defaultPricebookId',
            Value__c = pb.Id); 

        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = String.valueOf(UserInfo.getProfileId()));
  
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'email@solutionreach.com',
            Phone = '8013317150',
            AccountId = a.Id);        
        insert c;

        Opportunity o = new Opportunity(            
            Name = 'Test Opportunity',
            RecurSoft__Billing_Contact__c = c.Id,           
            CloseDate = Date.today(),
            AccountId = a.Id,
            StageName = 'Qualified');
        insert o;                  
                                        
        AsyncRequest__c async = new AsyncRequest__c(                
                AsyncType__c = AsyncMain.TYPE_ACCOUNT_BILLING_EMAIL, 
                Params__c = o.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id', 
                RequestedEmail__c = true);             
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();
    } 

    @isTest static void setup_Execute8() 
    {   
       
        Pricebook2 pb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pb;

        RecurSoft__Intacct_Entity__c intacct = new RecurSoft__Intacct_Entity__c(Name = 'TestAccount2');
        insert intacct;
                       
        Account a = new Account(
            Name = 'TestAccount2',
            RecurSoft__Intacct_Entity__c = intacct.id,
            Industry = 'Dental');                    
        insert a;

                        
        insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

        insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c='defaultPricebookId',
            Value__c = pb.Id); 

        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = String.valueOf(UserInfo.getProfileId()));
  
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'email@solutionreach.com',
            Phone = '8013317150',
            AccountId = a.Id);        
        insert c;

        Opportunity o = new Opportunity(            
            Name = 'Test Opportunity',
            RecurSoft__Billing_Contact__c = c.Id,           
            CloseDate = Date.today(),
            AccountId = a.Id,
            StageName = 'Qualified');
        insert o;         
    
        AsyncRequest__c async = new AsyncRequest__c(                
                AsyncType__c = AsyncMain.TYPE_AMBASSADOR_CREATE, 
                Params__c = o.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id', 
                RequestedEmail__c = true);
                
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();       
    } 

    @isTest static void setup_Execute9() 
    {   
        Pricebook2 pb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pb;

        RecurSoft__Intacct_Entity__c intacct = new RecurSoft__Intacct_Entity__c(Name = 'TestAccount2');
        insert intacct;
                       
        Account a = new Account(
            Name = 'TestAccount2',
            RecurSoft__Intacct_Entity__c = intacct.id,
            Industry = 'Dental');                    
        insert a;

                        
        insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

        insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c='defaultPricebookId',
            Value__c = pb.Id); 

        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = String.valueOf(UserInfo.getProfileId()));
  
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'email@solutionreach.com',
            Phone = '8013317150',
            AccountId = a.Id);        
        insert c;

        Opportunity o = new Opportunity(            
            Name = 'Test Opportunity',
            RecurSoft__Billing_Contact__c = c.Id,           
            CloseDate = Date.today(),
            AccountId = a.Id,
            StageName = 'Qualified');
        insert o;           
    
        AsyncRequest__c async = new AsyncRequest__c(                
                AsyncType__c = AsyncMain.TYPE_AMBASSADOR_COMPLETE, 
                Params__c = o.Id,
                Number_of_Attempts__c = 2, 
                Error__c = 'Error', 
                Attachment_Id__c = 'Id', 
                RequestedEmail__c = true);
                
        insert async;
            
        Test.startTest();
        AsyncMain asyncMain = new AsyncMain();
        Id batchId = Database.executeBatch(asyncMain);
        Test.stopTest();       
    } 


    

    
    /*@testSetup static void testData1() {

        Account a = TestUtilities.insertBasicAccount(true);
        Asset ast = new Asset(AccountId = a.Id, Name = 'Test');
        insert ast;
        RecurSoft__Product_Subscription__c ps = new RecurSoft__Product_Subscription__c(RecurSoft__Account__c = a.Id);
        insert ps;
    }

    @isTest static void prodSubsInsertTest() {

        Test.startTest();

        AsyncMain.StartScheduler();

        Test.stopTest();

        AsyncRequest__c[] afterList = [SELECT Id, Number_of_Attempts__c FROM AsyncRequest__c];
    }

    @isTest static void appAdminSyncTest() {

        Asset ast = [SELECT Id FROM Asset LIMIT 1];
        AsyncRequest__c[] ar = [SELECT Id FROM AsyncRequest__c];
        delete ar;

        AsyncRequest__c ar1 = new AsyncRequest__c(AsyncType__c = AsyncMain.TYPE_APPADMIN_ASSETSYNC, Params__c = ast.Id);
        insert ar1;

        Test.startTest();

        AsyncMain.StartScheduler();

        Test.stopTest();

        AsyncRequest__c[] afterList = [SELECT Id, Number_of_Attempts__c FROM AsyncRequest__c];
    }

    @isTest static void prodSubsInsertTestError() {

        RecurSoft__Product_Subscription__c ps = [SELECT Id FROM RecurSoft__Product_Subscription__c LIMIT 1];
        AsyncRequest__c[] ar = [SELECT Id FROM AsyncRequest__c];
        delete ar;

        AsyncRequest__c ar1 = new AsyncRequest__c(AsyncType__c = AsyncMain.TYPE_PRODSUB_AFTERINSERT, Params__c = '123');
        insert ar1;

        Test.startTest();

        AsyncMain.StartScheduler();

        Test.stopTest();

        AsyncRequest__c[] afterList = [SELECT Id, Number_of_Attempts__c FROM AsyncRequest__c];
    }

    @isTest static void appAdminSyncTestError() {

        Asset ast = [SELECT Id FROM Asset LIMIT 1];
        AsyncRequest__c[] ar = [SELECT Id FROM AsyncRequest__c];
        delete ar;

        AsyncRequest__c ar1 = new AsyncRequest__c(AsyncType__c = AsyncMain.TYPE_APPADMIN_ASSETSYNC, Params__c = '123');
        insert ar1;

        Test.startTest();

        AsyncMain.StartScheduler();

        Test.stopTest();

        AsyncRequest__c[] afterList = [SELECT Id, Number_of_Attempts__c FROM AsyncRequest__c];
    }

    @isTest static void skipCustomerStatusParent12() 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<Campaign_Influence__c, Campaign_Influence__c> ciMap = new Map<Campaign_Influence__c, Campaign_Influence__c>();

        for(Integer i = 0; i < 15; i++)
        {
            Opportunity o = new Opportunity(Id = fflib_IDGenerator.generate(Opportunity.SObjectType));
            Campaign c = new Campaign(Id = fflib_IDGenerator.generate(Campaign.SObjectType),
                Sub_Type__c = 'Demo');
            Campaign_Influence__c ci = new Campaign_Influence__c(Id = fflib_IDGenerator.generate(Campaign_Influence__c.SObjectType),
                Opportunity__c = o.Id,
                Campaign__c = c.Id);
            Campaign_Influence__c existingCampaignInfluence = new Campaign_Influence__c(Id = ci.Id,
                Opportunity__c = null,
                Campaign__c = c.Id);
            ciMap.put(ci, existingCampaignInfluence);
        }

        CampaignInfluences campaignInfluences = new CampaignInfluences(new List<Campaign_Influence__c>(ciMap.keySet()));
        for(Campaign_Influence__c ci : ciMap.keySet())
        {
            campaignInfluences.setDemoRequestReason(ci, ciMap.get(ci));
        }
        
        SRUtilities.scheduleAsync(campaignInfluences.setDemoRequestReason, 'Demo_Request_Reason', uow);
        System.assertEquals(15, campaignInfluences.setDemoRequestReason.size());
        System.assertEquals(null, campaignInfluences.stampUpdates);
        System.debug(uow.m_newListByType.get('AsyncRequest__c'));
    }

    @isTest static void skipCustomerStatusParent1() 
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        // Given - Create mocks
        //fflib_SObjectUnitOfWork mockUow = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        

        

        //fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        sfab_FabricatedSObject campaign = new sfab_FabricatedSObject(Campaign.class)
            .setField(Campaign.Id, fflib_IDGenerator.generate(Campaign.SObjectType))
            .setField(Campaign.Sub_Type__c, 'Demo');

        sfab_FabricatedSObject ci1 = new sfab_FabricatedSObject(Campaign_Influence__c.class)
                    .setField(Campaign_Influence__c.Id, fflib_IDGenerator.generate(Campaign_Influence__c.SObjectType))
                    .setField(Campaign_Influence__c.Campaign_Add_Date__c, Datetime.now().addDays(-5))
                    .setParent('Campaign__r', campaign);

        sfab_FabricatedSObject ci2 = new sfab_FabricatedSObject(Campaign_Influence__c.class)
                    .setField(Campaign_Influence__c.Id, fflib_IDGenerator.generate(Campaign_Influence__c.SObjectType))
                    .setField(Campaign_Influence__c.Campaign_Add_Date__c, Datetime.now().addDays(-10))
                    .setParent('Campaign__r', campaign);

        Opportunity opp = (Opportunity) new sfab_FabricatedSObject(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setChildren('Campaign_Influence__r', new List<sfab_FabricatedSObject> { ci1, ci2 })
            .toSObject();

        System.debug(new Map<Id, Opportunity>(new List<Opportunity>{ opp }));

        OpportunitiesSelector mockSelector = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2()).
            thenReturn(Opportunity.SObjectType);
        mocks.when(mockSelector.selectByIdWithCIs(
            (Set<Id>)fflib_match.anyObject())).
                thenReturn(new Map<Id, Opportunity>(new List<Opportunity>{ opp }));
        mocks.stopStubbing();

        // Given - Inject mocks
        //Application.UnitOfWork.setMock(mockUow);
        Application.Selector.setMock(mockSelector);

        System.debug(opp);
        System.debug(opp.Campaign_Influence__r[0].Campaign__r.Sub_Type__c);
        System.debug(OpportunitiesSelector.newInstance());
        //CampaignInfluencesService.setDemoRequestReason(new List<Opportunity>{ opp }, muow);
        CampaignInfluencesService.setDemoRequestReason(new Set<Id>{ opp.Id }, mockUow);

        ((OpportunitiesSelector) mocks.verify(mockSelector, 1)).
            selectByIdWithCIs(new Set<Id> { opp.Id });
        ((fflib_SobjectUnitOfWork) mocks.verify(mockUow, mocks
                          .times(2)
                          .description('only CI should be updated'))
            )
            .registerDirty(fflib_Match.sObjectOfType(Campaign_Influence__c.SObjectType));

        ((fflib_SobjectUnitOfWork) 
            mocks.verify(mockUow, mocks
                          .times(1)
                          .description('ci2 should be demo request reason'))
            )
           .registerDirty(fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                Campaign_Influence__c.Id => ci2.toSObject().Id,                                                                               
                Campaign_Influence__c.Demo_Request_Reason__c => true}));
        //System.assertEquals(uow.m_dirtyMapByType.get('Opportunity').get(opp.Id).get('Demo_Request_Reason__c'), 
        //    ci2.toSObject().Id);
        //System.debug(uow.m_dirtyMapByType.get('Campaign_Influence__c'));
        //System.debug(uow.m_dirtyMapByType.get('Opportunity'));
    }

    /*@isTest static void testMocks() 
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        // Given - Create mocks
        fflib_SObjectUnitOfWork mockUow = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        AccountsSelector mockSelector = (AccountsSelector) mocks.mock(AccountsSelector.class);
        Opportunities mockDomain = (Opportunities) mocks.mock(Opportunities.class);

        // Given - Configure mock responses
        Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id testOppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Account> testAcctsAndOpportunities = (List<Account>) fflib_ApexMocksUtils.makeRelationship(
            List<Account>.class,
            new List<Account> { new Account ( Id = testAccountId) },
            Opportunity.AccountId,
            new List<List<Opportunity>> {
            new List<Opportunity> {
            new Opportunity (Id = testOppId) } });

        mocks.startStubbing();
        mocks.when(mockSelector.SObjectType()).
            thenReturn(Account.SObjectType);
        mocks.when(mockSelector.selectByIdWithDemoRequestReason(
            new Set<Id> { testAccountId })).
                thenReturn(testAcctsAndOpportunities);
        mocks.when(mockDomain.SObjectType()).
            thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();

        // Given - Inject mocks
        Application.UnitOfWork.setMock(mockUow);
        Application.Selector.setMock(mockSelector);
        //Application.Domain.setMock(mockDomain);

        /*
        // When
        RaceService.awardChampionshipPoints(
            new Set<Id> { testAccountId });

        // Then
        ((AccountsSelector) mocks.verify(mockSelector, 1)).
            selectByIdWithOpportunities(new Set<Id> { testAccountId });
        ((Opportunities) mocks.verify(mockDomain, 1)).
            awardChampionshipPoints(mockUow);
        ((fflib_SObjectUnitOfWork) mocks.verify(mockUow, 1)).
            commitWork();
    }*/	
}