/**
 * File:        IntacctIntegrationSyncHandler_Test.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        April 4, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************
 * Description: Test IntacctIntegrationSyncHandler controller<br/>
 * *************************************************************************
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
 
@isTest
public with sharing class IntacctIntegrationSyncHandler_Test{
    
    private static final String CONTACT_MAILING_STREET = 'Test Street';
    private static final String CONTACT_MAILING_CITY = 'Test City';
    private static final String CONTACT_MAILING_STATE = 'Alabama';
    private static final String CONTACT_MAILING_ZIP = '12345';
    private static final String CONTACT_MAILING_COUNTRY = 'United States';
    private static final String CONTACT_INTACCT_ID = 'Test Intacct Id';
    private static final String CONTACT_EMAIL = 'test@email.com';
    private static final String CONTACT_PHONE = '123124124';
    private static final String TEST_NAME = 'Test Name';
    private static final String ACCOUNT_CUSTOMER_ID = '99999';
    private static final String ACCOUNT_INDUSTRY = 'Dental';
    private static final String ACCOUNT_EMAIL = 'test@test.com';
    private static final String ACCOUNT_PHONE = '123456789';
    private static final String ACCOUNT_PAYMENT_TERM = 'Test Payment Term';
    private static final String ACCOUNT_STATUS = 'Active';
    private static final String OPPORUNTITY_NAME = 'Test Opportunity ';
    private static final Date OPPORUNTITY_CLOSE_DATE = System.today();
    private static final String OPPORUNTITY_STAGE_NAME = 'Test Stage';
    private static final String JOB_ID = '12345678901234567';
    private static final String INTACCT_COMPANY = 'Test COmpany';
    private static final String INTACCT_URL = 'Test Url';
    private static final String INTACCT_USER_PASSWORD = 'Test User Password';
    private static final String INTACCT_USER = 'Test User';
    private static final String INTACCT_SENDER = 'Test Sender';
    private static final String INTACCT_SENDER_PASSWORD = 'Test Sender Password';
    private static final String INTACCT_SETTING_NAME = 'Intacct Gateway';
    private static final String LAST_CUSTOMER_ID_SETTING_NAME = 'Last Customer Id';
    private static final String LAST_CUSTOMER_ID = '999999';
    private static final String ENTITY_NAME = 'SR001';
    private static final String MANAGEMENT_SYSTEM_NAME = 'TEST MANAGEMENT SYSTEM';
    private static Map<Id, Opportunity> newOpportunityMap; 
    private static Map<Id, Opportunity> oldOpportunityMap;
    private static final String OPPORTUNITY_CLOSED_WON_SETTING = 'Opportunity Closed Won Stage Name';
    private static final String CONFIGURATION_SETTINGS_ENABLE_RESELLER_PROCESS = 'Reseller Process';
    private static IntacctIntegrationSyncHandler handlerInstance;
    
    @testSetup static void testData() 
    {
       TestUtilities.insertCustomSettings();
    }

    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Test happy flow
    */
    public static testmethod void testHappyFlow(){
    	Test.startTest();
        List<Opportunity> oppsRecs = new List<Opportunity>();
        createOpportunityClosedWonStageNameSetting();
        initTestingState();
        Integer numberOfRecords = 1;
        createIntactEntity();
        createTestData(numberOfRecords);
        Set<Id> filteredOpportunities;
        IntacctIntegrationSyncHandler handler = new IntacctIntegrationSyncHandler(JOB_ID);
        handler.startIntegration();
        oppsRecs = [SELECT Id FROM Opportunity];
        system.assertEquals(oppsRecs.size(),1);
        Test.stopTest();
    }
    
    /**
    * @author Daniel Savu
    * @date December 22, 2015
    * @description Test reseller process
    */
    public static testmethod void testResellerFlow()
    {
    	Test.startTest();
    	List<Opportunity> oppsRecs = new List<Opportunity>();
        createOpportunityClosedWonStageNameSetting();
        initTestingState();
        Integer numberOfRecords = 1;
        createIntactEntity();
        createTestData(numberOfRecords);
        createResselerProcessSetting();
        Set<Id> filteredOpportunities;
        IntacctIntegrationSyncHandler handler = new IntacctIntegrationSyncHandler(JOB_ID);
        handler.startIntegration();
        oppsRecs = [SELECT Id FROM Opportunity];
        system.assertEquals(oppsRecs.size(),1);
        Test.stopTest();
    }
    
    /**
    * @author Daniel Savu
    * @date December 22, 2015
    * @description Test reseller process
    */
    public static testmethod void testResellerFlow2()
    {
    	Test.startTest();
    	Opportunity testOpportunity = new Opportunity();
        createOpportunityClosedWonStageNameSetting();
        initTestingState();
        Integer numberOfRecords = 1;
        createIntactEntity();
        createTestData(numberOfRecords);
        createResselerProcessSetting();
        testOpportunity = [SELECT Id FROM Opportunity WHERE Name = :(OPPORUNTITY_NAME + String.valueOf(0)) LIMIT 1];
        initializePageState(testOpportunity);
        //handlerInstance.filteredOpportunities.add(testOpportunity.id);
        handlerInstance.startIntegration();
        List<Opportunity> oppsRecs = [SELECT Id FROM Opportunity];
        system.assertEquals(oppsRecs.size(),1);
        Test.stopTest();
        
    }
    
    /**
    * @author Daniel Savu
    * @date December 22, 2015
    * @description Initialize page state
    */
    private static void initializePageState(Opportunity testOpp)
    {
        ApexPages.Standardcontroller oppController = new ApexPages.Standardcontroller(testOpp);
        Test.setCurrentPage(Page.CustomerContactSync);
        handlerInstance = new IntacctIntegrationSyncHandler(oppController);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Initialize testing state
    */
    private static void initTestingState()
    {
        newOpportunityMap = new Map<Id, Opportunity>();
        oldOpportunityMap = new Map<Id, Opportunity>();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Create the data required to test the controller
    * @param numberOfRecords The number of contacts to create
    * @param objectType The sObject type
    */
    private static void createTestData(Integer numberOfRecords)
    {
        List<Opportunity> newOpportunities = new List<Opportunity>();
        newOpportunities.addAll(createOpportunities(numberOfRecords));
        populateOpportunityMaps(newOpportunities.clone());
        createIntacctIntegrationSetting();
        createIntacctIdsSetting();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Populate old opportunity map
    * @param newOpportunities The list of test opportunities
    */
    private static void populateOpportunityMaps(List<Opportunity> newOpportunities)
    {
        for(Opportunity tempOpportunity :newOpportunities)
        {
            newOpportunityMap.put(tempOpportunity.Id, tempOpportunity);
            Opportunity clonedOpp = tempOpportunity.clone();
            oldOpportunityMap.put(tempOpportunity.Id, clonedOpp);
        }
        
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Create a list of contacts
    * @param prefix Contact name prefix
    * @param numberOfRecords The number of contacts to create
    * @return newContacts A list of test contacts
    */
    private static List<Contact> createContacts(Integer numberOfRecords)
    {
        List<Contact> newContacts = new List<Contact>();
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Contact tempContact = new Contact();
            tempContact.FirstName = TEST_NAME;
            tempContact.LastName = TEST_NAME + String.valueOf(i + 1);
            tempContact.MailingStreet = CONTACT_MAILING_STREET;
            tempContact.MailingCity = CONTACT_MAILING_CITY;
            tempContact.MailingState = CONTACT_MAILING_STATE;
            tempContact.MailingPostalCode = CONTACT_MAILING_ZIP;
            tempContact.MailingCountry = CONTACT_MAILING_COUNTRY;
            tempContact.RecurSoft__Intacct_Contact_ID__c = CONTACT_INTACCT_ID;
            tempContact.Email = CONTACT_EMAIL;
            tempContact.Phone = CONTACT_PHONE;
            newContacts.add(tempContact);
        }
        try
        {
            if(!newContacts.isEmpty())
            {
                insert newContacts;
            }
            System.debug(LoggingLevel.ERROR, 'createContacts:' + newContacts);
            return newContacts;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            newContacts = new List<Contact>();
        }
        return newContacts;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Create a list of account
    * @param numberOfRecords The number of records to create
    * @return newAccounts A list account records
    */
    private static List<Account> createAccounts(Integer numberOfRecords)
    {
        List<Account> newAccounts = new List<Account>();
        Management_System__c tempManagementSystem = createManagementSystem();
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Account tempAccount = new Account();
            tempAccount.Name = TEST_NAME + String.valueOf(i);
            tempAccount.Industry = ACCOUNT_INDUSTRY;
            tempAccount.RecurSoft__Billing_Email__c = ACCOUNT_EMAIL;
            tempAccount.RecurSoft__Billing_Email_CC__c = ACCOUNT_EMAIL;
            tempAccount.Phone = ACCOUNT_PHONE;
            tempAccount.RecurSoft__Status__c = ACCOUNT_STATUS;
            tempAccount.RecurSoft__IntacctID__c = ACCOUNT_CUSTOMER_ID + i;
            tempAccount.RecurSoft__Payment_Term__c = ACCOUNT_PAYMENT_TERM;
            //tempAccount.Practice_Management_Software__c = tempManagementSystem.Id;
            newAccounts.add(tempAccount);
        }
        try
        {
            if(!newAccounts.isEmpty())
            {
                insert newAccounts;
            }
            return newAccounts;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            newAccounts = new List<Account>();
        }
        return newAccounts;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Create a list of opportunities
    * @param numberOfRecords The number of records to create
    * @return newOpportunities A list account records
    */
    private static List<Opportunity> createOpportunities(Integer numberOfRecords)
    {
        List<Opportunity> newOpportunities = new List<Opportunity>();
        List<Account> tempAccounts = createAccounts(2);
        tempAccounts[1].ParentId = tempAccounts[0].Id;
        tempAccounts[1].RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Child Account');
        update tempAccounts[1];
        List<Contact> tempContacts = createContacts(1);
        tempContacts[0].AccountId = tempAccounts[0].Id;
        update tempContacts;
        //System.debug(LoggingLevel.ERROR, 'createOpportunities:' + tempContacts);
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Opportunity tempOpportunity = new Opportunity();
            tempOpportunity.Name = OPPORUNTITY_NAME + String.valueOf(i);
            tempOpportunity.CloseDate = OPPORUNTITY_CLOSE_DATE;
            tempOpportunity.StageName = OPPORUNTITY_STAGE_NAME;
            tempOpportunity.AccountId = tempAccounts[1].Id;
            tempOpportunity.RecurSoft__Bill_to_Account__c = tempAccounts[0].Id;
            tempOpportunity.RecurSoft__Billing_Contact__c = tempContacts[0].Id;
            tempOpportunity.RecurSoft__Shipping_Contact__c = tempContacts[0].Id;
            //tempOpportunity.Ok_to_Sync_to_Intacct__c = JOB_ID.substring(0,15);
            newOpportunities.add(tempOpportunity);
        }
        try{
            if(!newOpportunities.isEmpty()){
                insert newOpportunities;
            }
            return newOpportunities;
        }catch(Exception ex){
            newOpportunities = new List<Opportunity>();
        }
        return newOpportunities;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the custom intacct integration setting
    */
    
    private static void createIntacctIntegrationSetting()
    {
        Intacct_Integration_Settings__c newIntacctSetting = new Intacct_Integration_Settings__c();
        newIntacctSetting.Name = INTACCT_SETTING_NAME;
        newIntacctSetting.Intacct_Company_ID__c = INTACCT_COMPANY;
        newIntacctSetting.Intacct_Gateway_URL__c = INTACCT_URL;
        newIntacctSetting.Intacct_Password__c = INTACCT_USER_PASSWORD;
        newIntacctSetting.Intacct_User_ID__c = INTACCT_USER;
        newIntacctSetting.Intacct_Sender_ID__c = INTACCT_SENDER;
        newIntacctSetting.Intacct_Sender_Password__c = INTACCT_SENDER_PASSWORD;
        try
        {
            insert newIntacctSetting;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            newIntacctSetting = new Intacct_Integration_Settings__c();
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the custom intacct integration setting
    */
    private static void createIntacctIdsSetting()
    {
        Intacct_Ids__c newIntacctSetting = new Intacct_Ids__c();
        newIntacctSetting.Name = LAST_CUSTOMER_ID_SETTING_NAME;
        newIntacctSetting.Id_Value__c = LAST_CUSTOMER_ID;
        try
        {
            insert newIntacctSetting;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            newIntacctSetting = new Intacct_Ids__c();
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a Intacct Entity
    * @return newIntacctEntity A new intacct entity record
    */
    private static RecurSoft__Intacct_Entity__c createIntactEntity()
    {
        RecurSoft__Intacct_Entity__c newIntacctEntity = new RecurSoft__Intacct_Entity__c();
        newIntacctEntity.Name = ENTITY_NAME;
        newIntacctEntity.Entity_root__c = true;
        try
        {
            insert newIntacctEntity;
            return newIntacctEntity;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            newIntacctEntity = new RecurSoft__Intacct_Entity__c();
        }
        return newIntacctEntity;
    }
    
 	/**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a Management System
    * @return newManagementSystem A new management system record
    */
    
    private static Management_System__c createManagementSystem()
    {
        Management_System__c newManagementSystem = new Management_System__c();
        newManagementSystem.Name = MANAGEMENT_SYSTEM_NAME;
        try
        {
            insert newManagementSystem;
            return newManagementSystem;
        }
        catch(Exception ex)
        {
            newManagementSystem = new Management_System__c();
        }
        return newManagementSystem;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a Management System
    * @return newManagementSystem A new management system record
    */
    /*
    private static Management_System__c createManagementSystem()
    {
        Management_System__c newManagementSystem = new Management_System__c();
        newManagementSystem.Name = MANAGEMENT_SYSTEM_NAME;
        try
        {
            insert newManagementSystem;
            return newManagementSystem;
        }
        catch(Exception ex)
        {
            newManagementSystem = new Management_System__c();
        }
        return newManagementSystem;
    }
    */
    
    /**
    * @author Daniel Savu
    * @date April 20, 2015
    * @description method to insert Opportunity Closed Won Stage Name setting
    */
    private static RecurSoft__Default_Values__c createOpportunityClosedWonStageNameSetting()
    {
        RecurSoft__Default_Values__c testSetting = new RecurSoft__Default_Values__c();
        testSetting.Name = OPPORTUNITY_CLOSED_WON_SETTING;
        testSetting.RecurSoft__Value__c = 'Closed Won';
        insert testSetting;
        return testSetting;
    }
    
    /**
    * @author Daniel Savu
    * @date December 22, 2015
    * @description method to insert ResselerProcess setting
    */
    private static RecurSoft__TempConfigurationSettings__c createResselerProcessSetting()
    {
        RecurSoft__TempConfigurationSettings__c enableResselerProcess = new RecurSoft__TempConfigurationSettings__c();
        enableResselerProcess.Name = CONFIGURATION_SETTINGS_ENABLE_RESELLER_PROCESS;
        enableResselerProcess.RecurSoft__Is_Active__c = true;
        insert enableResselerProcess;
        return enableResselerProcess;
    }
    
}