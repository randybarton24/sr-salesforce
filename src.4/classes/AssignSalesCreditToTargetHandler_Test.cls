@isTest
private class AssignSalesCreditToTargetHandler_Test {
    
    @testSetup static void testData() 
    {
        TestUtilities.insertCustomSettings();
    }
    
    public static Management_System__c createManagementSystem() {
        return(new Management_System__c(Name = 'test'));
    }
    
    
    public static Account createAccount(Management_System__c management) {
        
        RecurSoft__Intacct_Entity__c intacctEntity = new RecurSoft__Intacct_Entity__c(Name = 'test');
        database.insert(intacctEntity);
        
        return (new Account(Name = 'testAccount',
                            Practice_Management_Software__c = management.Id,
                            Industry = 'Vision',
                            RecurSoft__Intacct_Entity__c = intacctEntity.Id,
                            RecurSoft__Channel__c = '100',
                            RecurSoft__Intacct_Vertical__c = 'E001',
                            RecurSoft__Payment_Term__c = 'Net 30'));
    }

    public static Profile createProfile() {
        return [SELECT Id FROM Profile WHERE Name='Standard User'];
    }
    
    public static Opportunity createOpportunity(Account acct) {
        
        return (new Opportunity(Name = 'testOpp', 
                                StageName = 'Qualified',
                                CloseDate = System.today() + 30,
                                AccountId = acct.Id,
                                RecurSoft__Contract_Signed_Date__c = Date.newInstance(2014, 11, 12)));
    }
    
    
    public static User createUser1(Profile p) {
        return (new User(Alias = 'standt1',
                         Email='standarduser1@testorg.com',
                         EmailEncodingKey='UTF-8',
                         LastName='Testing1',
                         LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US',
                         ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName='hfiekd@test.com'));
    }
    
    public static User createUser2(Profile p) {
        return (new User(Alias = 'standt2',
                         Email='standarduser2@testorg.com',
                         EmailEncodingKey='UTF-8',
                         LastName='Testing2',
                         LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US',
                         ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName='aisuherb@test.com'));
    }
    
    public static User createUser3(Profile p) {
        return (new User(Alias = 'standt3',
                         Email='standarduser3@testorg.com',
                         EmailEncodingKey='UTF-8',
                         LastName='Testing3',
                         LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US',
                         ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName='nzvxlihdf@test.com'));
    }
    
    public static User createUser4(Profile p) {
        return (new User(Alias = 'standt4',
                         Email='standarduser4@testorg.com',
                         EmailEncodingKey='UTF-8',
                         LastName='Testing4',
                         LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US',
                         ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName='uvdhoke@test.com'));
    }
    
    public static User createUser5(Profile p) {
        return (new User(Alias = 'standt5',
                         Email='standarduser5@testorg.com',
                         EmailEncodingKey='UTF-8',
                         LastName='Testing5',
                         LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US',
                         ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName='mnbvcxz@test.com'));
    }
    
    public static User createUser6(Profile p) {
        return (new User(Alias = 'standt6',
                         Email='standarduser6@testorg.com',
                         EmailEncodingKey='UTF-8',
                         LastName='Testing6',
                         LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US',
                         ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName='zxcvbnm@test.com'));
    }

    public static Sales_Target__c createTarget(User usr) {
        Date firstOfMonth = Date.today().toStartOfMonth();
        return (new Sales_Target__c(Owner__c = usr.Id,
                                    Target_Date__c = firstOfMonth));
    }
    
    public static Sales_Credit__c createSalesCredit(Opportunity opp, User usr1, User usr2, User usr3) {
        return (new Sales_Credit__c(Opportunity__c = opp.Id,
                                   Sales_Rep__c = usr1.Id,
                                   Manager__c = usr2.Id,
                                   VP__c = usr3.Id,
                                   Individual_Credit_Portion__c = 0.500,
                                   Team_Credit_Portion__c = 0.500));
    }
    
    static testMethod void createSalesCreditsTest() {
        Management_System__c management = createManagementSystem();
        database.insert(management);
        
        Account acct = createAccount(management);
        database.insert(acct);

        Account acct2 = createAccount(management);
        database.insert(acct2);
        
        Opportunity opp1 = createOpportunity(acct);
        database.insert(opp1);
        
        Opportunity opp2 = createOpportunity(acct2);
        database.insert(opp2);

        Profile p = createProfile();
        
        User usr1 = createUser1(p);
        database.insert(usr1);
        
        User usr2 = createUser2(p);
        database.insert(usr2);
        
        User usr3 = createUser3(p);
        database.insert(usr3);
        
        User usr4 = createUser4(p);
        database.insert(usr4);
        
        User usr5 = createUser5(p);
        database.insert(usr5);
        
        User usr6 = createUser6(p);
        database.insert(usr6);

        Sales_Target__c st = createTarget(usr2);
        database.insert(st);
        
        Test.startTest();
        Sales_Credit__c sc1 = createSalesCredit(opp1, usr1, usr2, usr3);
        database.insert(sc1);

        Sales_Credit__c sc2 = createSalesCredit(opp2, usr1, usr5, usr6);
        database.insert(sc2);

        List<Sales_Target__c> targets = [SELECT Id, Owner__c, Actual_Credits__c, Target_Date__c
                                        FROM Sales_Target__c];

        Sales_Target__c newTarget;
        for (Sales_Target__c t : targets) {
            if (t.Owner__c == usr1.Id) {
                newTarget = t;
            }
        }
        //System.assertEquals(1.0000, newTarget.Actual_Credits__c);
        
        System.assertEquals(6, targets.size());
        Test.stopTest();
    }


    static testMethod void updateSalesCreditTest() {
        Management_System__c management = createManagementSystem();
        database.insert(management);
        
        Account acct = createAccount(management);
        database.insert(acct);
        
        Opportunity opp = createOpportunity(acct);
        database.insert(opp);

        Profile p = createProfile();
        
        User usr1 = createUser1(p);
        database.insert(usr1);
        
        User usr2 = createUser2(p);
        database.insert(usr2);
        
        User usr3 = createUser3(p);
        database.insert(usr3);
        
        User usr4 = createUser4(p);
        database.insert(usr4);

        Sales_Credit__c sc = createSalesCredit(opp, usr1, usr2, usr3);
        database.insert(sc);

        sc.VP__c = usr4.Id;
        database.update(sc);

        List<Sales_Target__c> targets = [SELECT Id, Owner__c
                                        FROM Sales_Target__c];

        Sales_Target__c newTarget;
        for (Sales_Target__c t : targets) {
            if (t.Owner__c == usr4.Id) {
                newTarget = t;
            }
        }
        System.assertEquals(usr4.Id, newTarget.Owner__c);
    }
}