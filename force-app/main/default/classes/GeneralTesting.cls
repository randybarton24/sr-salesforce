public with sharing class GeneralTesting {
    /*Denisa Vlasceanu*/
    
    /**
	* test if the account's record type was updated according to converted Lead Type (Enterprise)
	* expected result: Account RecordType Name = Enterprise
	* *************************************************************************
	* History:
	* Date:                Modified By:            Description: 
	* February 6, 2015     Randy Barton			   Updated createLead() Method to include Sub_Industry__c in order to pass conversion validation on LeadConvert Trigger.
	*/
    /*public static testMethod void checkAccountUpdateOnLeadConvert1() {
        Lead newLead = createLead(); 
        newLead.Lead_Type__c = 'Enterprise';
        insert newLead;
        convertLead(newLead);
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
        
        Account acc = [SELECT ID, RecordTypeId FROM Account WHERE ID = :tempLead2.ConvertedAccountId];
        RecordType accRecordType = [SELECT ID, Name FROM RecordType WHERE Name = 'Major Account' AND SobjectType = 'Account' LIMIT 1];
        
        System.assertEquals(acc.RecordTypeId, accRecordType.Id);
    }
    
    /**
     * test if the account's record type was updated according to converted Lead Type (Practice)
     * expected result: Account RecordType Name = Practice
     */
    /*public static testMethod void checkAccountUpdateOnLeadConvert2() {
        Lead newLead = createLead(); 
        newLead.Lead_Type__c = 'Practice';
        insert newLead;
        convertLead(newLead);
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
        
        Account acc = [SELECT ID, RecordTypeId FROM Account WHERE ID = :tempLead2.ConvertedAccountId];
        RecordType oppRecordType = [SELECT ID, Name FROM RecordType WHERE ID = :acc.RecordTypeId];
        
        System.assertEquals('Account', oppRecordType.Name);
    }

    /**
     * test if the account's record type was updated according to converted Lead Type (Partner)
     * expected result: Account RecordType Name = Partner
     */
    /*public static testMethod void checkAccountUpdateOnLeadConvert3() {
        Lead newLead = createLead(); 
        newLead.Lead_Type__c = 'Partner';
        insert newLead;
        convertLead(newLead);
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
        
        Account acc = [SELECT ID, RecordTypeId FROM Account WHERE ID = :tempLead2.ConvertedAccountId];
        //RecordType oppRecordType = [SELECT ID, Name FROM RecordType WHERE Name = 'Partner' AND SobjectType = 'Account' LIMIT 1]; //Partner
        
        //System.assertEquals(acc.RecordTypeId, oppRecordType.Id);
    }
    
    /**
     * test if the account's record type was updated according to converted Lead Type (Affiliate)
     * expected result: Account RecordType Name = Affiliate
     */
    /*public static testMethod void checkAccountUpdateOnLeadConvert4() {
        Lead newLead = createLead(); 
        newLead.Lead_Type__c = 'Affiliate';
        insert newLead;
        convertLead(newLead);
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
        
        Account acc = [SELECT ID, RecordTypeId FROM Account WHERE ID = :tempLead2.ConvertedAccountId];
        RecordType oppRecordType = [SELECT ID, Name FROM RecordType WHERE Name = 'Affiliate/KOL' AND SobjectType = 'Account' LIMIT 1];//Affiliate
        
        System.assertEquals(acc.RecordTypeId, oppRecordType.Id);
    }*/
    
    /**
     * test if the account's record type was updated according to converted Lead Type (Group Practice)
     * expected result: Account RecordType Name = Group Practice
     */
    /*public static testMethod void checkAccountUpdateOnLeadConvert5() {
        Lead newLead = createLead(); 
        newLead.Lead_Type__c = 'Practice';
        insert newLead;
        convertLead(newLead);
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
        
        Account acc = [SELECT ID, RecordTypeId FROM Account WHERE ID = :tempLead2.ConvertedAccountId];
        RecordType accRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Account' AND SobjectType = 'Account' LIMIT 1];
        
        System.assertEquals(acc.RecordTypeId, accRecordType.Id);
    }
    
    /**
     * check of the main contact was updated as a Primary Contact
     * test if Contact Role was created
     */
    /*public static testMethod void checkContactCreationOnLeadConvert() {
        Lead newLead = createLead(); 
        insert newLead;
        convertLead(newLead);
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
        
        Account acc = [SELECT ID FROM Account WHERE ID = :tempLead2.ConvertedAccountId];
        Contact cont = [SELECT ID FROM Contact WHERE ID = :tempLead2.ConvertedContactId];
        //AccountContactRole contactRole = [SELECT Id, IsPrimary FROM AccountContactRole WHERE AccountId = :acc.Id AND ContactId = :cont.Id];
        
        System.assertNotEquals(acc, null);
        System.assertNotEquals(cont, null);
        //System.assertNotEquals(contactRole, null);
        //System.assertEquals(contactRole.IsPrimary, true);
    }
    
    /**
     * check if a business contact and related contact role were created
     */
    /*public static testMethod void checkBusinessContactCreationOnLeadConvert() {
        Lead newLead = createLead();
        insert newLead;
        convertLead(newLead);
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :newLead.Id];
        
        Account acc = [SELECT ID FROM Account WHERE ID = :tempLead2.ConvertedAccountId];
        Contact cont = [SELECT ID FROM Contact WHERE AccountID = :acc.Id AND Primary_Contact__c = false];
        AccountContactRole contactRole = [SELECT Id, IsPrimary FROM AccountContactRole WHERE AccountId = :acc.Id AND ContactId = :cont.Id];
        
        System.assertNotEquals(acc, null);
        System.assertNotEquals(cont, null);
        System.assertNotEquals(contactRole, null);
        System.assertEquals(contactRole.IsPrimary, false);
    }*/
    
    /**
     * test if:
     *    - pricebook was assigned to opportunity based on Lead Type
     *    - opportunity record type was properly set
     * expected result: 
     *    - if LeadType = Enterprise => Opportunity RecordType = Enterprise New Business
     *                               => Opportunity Price Book = Enterprise Price Book
     */
    /*public static testMethod void checkOpportunityCreationOnLeadConvert() {
        Lead newLead = createLead();
        newLead.Lead_Type__c = 'Enterprise';
        insert newLead;
        
        Pricebook2 newPb = new Pricebook2(Name = 'Enterprise Price Book', IsActive = true);
        insert newPb;
        
        convertLead(newLead);
        
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId FROM Lead WHERE Id = :newLead.Id];
        
        Account acc = [SELECT ID FROM Account WHERE ID = :tempLead2.ConvertedAccountId];
        Contact cont = [SELECT ID FROM Contact WHERE ID = :tempLead2.ConvertedContactId];
        List<Contact> additionalContact = [SELECT Id, Created_From_Lead_Convertion__c FROM Contact WHERE AccountId = :acc.Id];
        Opportunity opp = [SELECT Id, Name, Pricebook2Id, RecordTypeId, StageName FROM Opportunity WHERE ID = :tempLead2.ConvertedOpportunityId];
        
        RecordType oppRecordType = [SELECT ID, Name FROM RecordType WHERE Name = 'Enterprise New Business' AND SobjectType = 'Opportunity' LIMIT 1];
        
        System.assertNotEquals(acc, null);
        System.assertNotEquals(cont, null);
        for(Contact c : additionalContact) {
            System.assertEquals(c.Created_From_Lead_Convertion__c, true);
        }
        System.assertNotEquals(opp.RecordTypeId, NULL);  
    }
    
    /**
     * if Lead DemoDate is not filled in, then Opportunity StageName should be Qualified
     */
    /*public static testMethod void checkOpportunityStageName1() {
        Lead newLead = createLead();
        insert newLead;
        convertLead(newLead);
        
        Lead tempLead2 = [SELECT Id, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId FROM Lead WHERE Id = :newLead.Id];
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE ID = :tempLead2.ConvertedOpportunityId];
        
        System.assertEquals(opp.StageName, 'Qualified');
    }*/
    
    /**
     * Update Account Active Date with Opportunity Contract Signed Date when the Opportunity is set to Closed Won (on opp insert)
     */
    /** public static testMethod void checkAccountActiveDateDateOnOppInsert() {
        Account acc = insertTestAccount();
        Opportunity opp1 = insertTestOpp(acc.Id, System.today() + 1, System.today());
        Opportunity opp2 = insertTestOpp(acc.Id, System.today() + 2, System.today() + 2);
        opp2.StageName = 'Closed Won';
        try {
            update opp2;
        } catch(Exception ex) {}
        Account tempAcc = [SELECT Id, RecurSoft__Customer_Active_Date__c FROM Account WHERE Id = :acc.Id];
        //System.assertEquals(tempAcc.RecurSoft__Customer_Active_Date__c, opp2.RecurSoft__Contract_Signed_Date__c);
     }*/
     
     /**
     * Update Account Anniversary Date 
     */
     /*public static testMethod void checkAccountAnniversaryDateDateForMultipleOpps() {
        Account acc = insertTestAccount();
        Opportunity opp1 = insertTestOpp(acc.id, System.today() + 1, System.today() + 3);
        Opportunity tempOpp1 = [SELECT Id, RecurSoft__Contract_Term_End_Date__c FROM Opportunity WHERE Id = :opp1.Id];
        Account tempAcc1 = [SELECT Id, RecurSoft__Anniversary_Date__c FROM Account WHERE Id = :acc.Id];
        //System.assertEquals(tempAcc1.RecurSoft__Anniversary_Date__c, tempOpp1.RecurSoft__Contract_Term_End_Date__c + 1);
        
        Opportunity opp2 = insertTestOpp(acc.Id, System.today() + 1, System.today());
        Opportunity tempOpp2 = [SELECT Id, RecurSoft__Contract_Term_End_Date__c FROM Opportunity WHERE Id = :opp2.Id];
        Account tempAcc2 = [SELECT Id, RecurSoft__Anniversary_Date__c FROM Account WHERE Id = :acc.Id];
        //System.assertEquals(tempAcc2.RecurSoft__Anniversary_Date__c, tempAcc1.RecurSoft__Anniversary_Date__c);
     }*/
    /**
    public static Lead createLead() {
        Management_System__c ms = new Management_System__c(Name = 'Test Management System');
        insert ms;
        Lead newLead = new Lead(Firstname = 'TestFirstname', 
                                Lastname = 'TestLastname', 
                                Company = 'Test Company', 
                                Phone = '123456789', 
                                Email = 'testEmail@testemail.com',
                                Lead_Type__c = 'Enterprise', 
                                Industry = 'Dental',
                                Sub_Industry__c = 'General Dentistry',
                                LeadSource = 'Cold Call',
                                Status = 'New/Assigned',
                                Competitor__c = 'None',
                                Practice_Software__c = ms.Id
                        );
        return newLead; 
    }*/
    /**
    public static User createUser(String username) {
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = username.substring(0,7), email = username,
                          emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                          localesidkey = 'en_US', profileid = p.Id,
                          timezonesidkey = 'America/Los_Angeles', username = username);
        return u;
    }*/
    /**
    public static void convertLead(Lead newLead) {
        User u = createUser('bumbumtest1@bumbumtest.com');
        insert u;
        FlowControl.isLeadConvert = true;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(newLead.id);
        Account acc = insertTestAccount();
        lc.accountId = acc.Id;
        lc.setDoNotCreateOpportunity(false);
        lc.setOwnerId(u.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        try {
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
        } catch(Exception ex) {}
        FlowControl.isLeadConvert = false;
    }*/
    /**
    public static testMethod void testUpdateFreeMonthsOppTrigger(){
        Account acc = insertTestAccount();
        Opportunity opp = insertTestOpp(acc.Id, System.today(), System.today());
        
        Campaign camp = new Campaign(Name ='TestCampName', free_months__c = '2', Free_Months_Setting__c = 'Extend Contract - At the Beginning', IsActive = true, StartDate = opp.CloseDate.addMonths(-2), EndDate = opp.CloseDate.addMonths(+2));
        insert camp;
        System.assertEquals('2', camp.free_months__c);
        
        opp.CampaignId = camp.Id;
        update opp;
        camp.free_months__c = '3';
        update camp;
        Opportunity oppTest = [SELECT Id, Name, RecurSoft__Number_of_Free_Months__c FROM Opportunity WHERE Id =:opp.Id];
        
        // [CV May 5th] System.assertEquals('3', oppTest.RecurSoft__Number_of_Free_Months__c);
    }*/
    

   /**
    * @author Cristina Verestiuc
    * @date April 22, 2014
    * @description Method used to insert test account
    * @return acc Inserted Account
    */
    
    /**
    public static Account insertTestAccount() {
        Management_System__c ms = new Management_System__c(Name = 'Test MS Record');
        insert ms;
        RecurSoft__Intacct_Entity__c entity = new RecurSoft__Intacct_Entity__c(Name = 'SR001');
        insert entity;
        Account acc = new Account(Name = 'Test Company', Phone = '123456789', Industry = 'Dental', Practice_Management_Software__c = ms.Id, RecurSoft__Customer_Active_Date__c = null,
                                  RecurSoft__Payment_Term__c = 'Due Upon Receipt', RecurSoft__Intacct_Entity__c = entity.Id
                                  );
        try{
            insert acc;
        } catch(DmlException ex) {System.debug('ACCOUNT CRASHED: ' + ex);}
        return acc;
    }*/
    
    /**
    * @author Cristina Verestiuc
    * @date April 22, 2014
    * @description Method used to insert test account
    * @param closeDate Opportunity closed date
    * @param accId ID of the related account
    * @return acc Inserted Account
    */
    /**
    public static Opportunity insertTestOpp(Id accId, Date closeDate, Date contractSignedDate) {
        Opportunity opp = new Opportunity(Name = 'Test Order', StageName = 'Qualified', Competitor__c = 'None', 
                                          AccountId = accId, 
                                          RecurSoft__Bill_to_Account__c = accId,
                                          CloseDate = closeDate, RecurSoft__Contract_Signed_Date__c = contractSignedDate,  
                                          RecurSoft__Initial_Contract_Term__c = 12);
        try{
            insert opp;
        } catch(DmlException ex) {System.debug('OPPORTUNITY CRASHED: ' + ex);}
        return opp;
    }*/
    
}