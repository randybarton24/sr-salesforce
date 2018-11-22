/**
 * File:        GenerateSFDCObjectQueries_Test.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        April 2,2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************
 * Description: Test GenerateSFDCObjectQueries controller<br/>
 * *************************************************************************
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
 
@isTest
public with sharing class GenerateSFDCObjectQueries_Test{
    
    @testSetup static void testData() 
    {
       TestUtilities.insertCustomSettings();
    }
    
    private static final Schema.sObjectType ACCOUNT_TYPE = Account.sObjectType;
    private static final Schema.sObjectType CONTACT_TYPE = Contact.sObjectType;
    private static final Schema.sObjectType OPPORTUNITY_TYPE = Opportunity.sObjectType;
    private static final String ID_FIELD_NAME = 'Id';
    private static final String ACCOUNT_NAME = 'Test Account ';
    private static final String ACCOUNT_INDUSTRY = 'Dental';
    private static final String CONTACT_LAST_NAME = 'Test Contact ';
    private static final String CONTACT_EMAIL = 'test@email.com';
    private static final String CONTACT_PHONE = '123124124';
    private static final String OPPORUNTITY_NAME = 'Test Opportunity ';
    private static final Date OPPORUNTITY_CLOSE_DATE = System.today();
    private static final String OPPORUNTITY_STAGE_NAME = 'Qualified';
    private static final Integer OPPORTUNITY_INITIAL_CONTRACT_TERM = 12;
    private static final String GROUP_BY_QUERY = 'SELECT Id FROM Intacct_Error__c LIMIT 1';
    private static final String PREFIX_QUERY = 'SELECT Name, SFDC_Id_Prefix_Text__c, Parent_Id__c, Description__c, Id, Errors__c,  CreatedDate FROM Intacct_Error__c WHERE SFDC_Id_Prefix_Text__c=\'\' ORDER BY CreatedDate DESC limit 1000';
    private static final String DELETE_QUERY = 'SELECT Name, SFDC_Id_Prefix_Text__c, Parent_Id__c, Description__c, Id, Errors__c,  CreatedDate FROM Intacct_Error__c ORDER BY CreatedDate ASC LIMIT 50000';
    private static Integer numberOfTestRecords;
    private static final Boolean accountSyncedWithIntacct = true;
    private static final String accountPaymentTerm = 'Due Upon Receipt';
    private static final String accStreet = 'Test Street';
    private static final String accCity = 'Irvine';
    private static final String accDescription = 'Test Description';
    private static final String accCountry = 'United States';
    private static final String accState = 'California';
    private static final String ENTITY_NAME = 'SR001';
    private static final String MANAGEMENT_SYSTEM_NAME = 'TEST MANAGEMENT SYSTEM';
    private static final String JOB_ID = '006f0000005KjON';
    private static Set<Id> accountIds;
    private static Set<Id> contactIds;
    private static Set<Id> opportunityIds;
    private static final String OPPORTUNITY_CLOSED_WON_SETTING = 'Opportunity Closed Won Stage Name';
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test the happy flow for the 'retrieveAccounts' method
    */
    public static testmethod void testAccountQueryMethodHappyFlow()
    {
        initializeTestingState();
        createIntactEntity();
        createTestData(numberOfTestRecords, ACCOUNT_TYPE);
        List<Account> testAccounts;
        Test.startTest();
        testAccounts = GenerateSFDCObjectQueries.retrieveAccounts(accountIds);
        Test.stopTest();
        
        System.assertEquals(testAccounts.size(), 1);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test the happy flow for the 'retrieveContacts' method
    */
    public static testmethod void testContactQueryMethodHappyFlow()
    {
        initializeTestingState();
        createTestData(numberOfTestRecords, CONTACT_TYPE);
        List<Contact> testContacts;
        Test.startTest();
        testContacts = GenerateSFDCObjectQueries.retrieveContacts(contactIds);
        Test.stopTest();
        
        System.assertEquals(testContacts.size(), 1);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test the happy flow for the 'retrieveOpporutnities' method
    */
    public static testmethod void testOpportunityQueryMethodHappyFlow()
    {
    	createOpportunityClosedWonStageNameSetting();
        initializeTestingState();
        createIntactEntity();
        createTestData(numberOfTestRecords, OPPORTUNITY_TYPE);
        List<Opportunity> testOpportunities;
        Test.startTest();
        testOpportunities = GenerateSFDCObjectQueries.retrieveOpporutnities(opportunityIds);
        Test.stopTest();
        
        System.assertEquals(testOpportunities.size(), 1);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Test the 'generateIntacctErrorQuery' method with group by action type
    */
    public static testmethod void testGenerateIntacctErrorQueryGroupBy()
    {
        //IntacctGlobalVariables.ACTION_TYPE_GROUP_BY
        String queryString = '';
        Test.startTest();
        queryString = GenerateSFDCObjectQueries.generateIntacctErrorQuery(IntacctGlobalVariables.ACTION_TYPE_GROUP_BY);
        Test.stopTest();
        
        System.assertEquals(queryString, GROUP_BY_QUERY);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Test the 'generateIntacctErrorQuery' method with action type prefix
    */
    public static testmethod void testGenerateIntacctErrorQueryPrefix()
    {
        //IntacctGlobalVariables.ACTION_TYPE_PREFIX
        String queryString = '';
        Test.startTest();
        queryString = GenerateSFDCObjectQueries.generateIntacctErrorQuery(IntacctGlobalVariables.ACTION_TYPE_PREFIX);
        Test.stopTest();
        
        System.assertEquals(queryString, PREFIX_QUERY);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Test the 'generateIntacctErrorQuery' method with action type delete
    */
    public static testmethod void testGenerateIntacctErrorQueryDelete()
    {
        //IntacctGlobalVariables.ACTION_TYPE_DELETE
        String queryString = '';
        Test.startTest();
        queryString = GenerateSFDCObjectQueries.generateIntacctErrorQuery(IntacctGlobalVariables.ACTION_TYPE_DELETE);
        Test.stopTest();
        
        System.assertEquals(queryString, DELETE_QUERY);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Initialize testing state
    */
    private static void initializeTestingState()
    {
        numberOfTestRecords = 1;
        accountIds = new Set<Id>();
        opportunityIds = new Set<Id>();
        contactIds = new Set<Id>();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the data required to test the controller
    * @param numberOfRecords The number of contacts to create
    * @param objectType The type of object that will be created
    */
    private static void createTestData(Integer numberOfRecords, Schema.sObjectType objectType)
    {
        List<Account> newAccounts;
        List<Opportunity> newOpportunities;
        List<Contact> newContacts;
        List<Intacct_Error__c> newIntacctErrors;
        if(objectType == ACCOUNT_TYPE)
        {
            newAccounts = new List<Account>();
            newAccounts.addAll(createAccounts(numberOfRecords));
            accountIds = populateIdSet(newAccounts);
        }
        if(objectType == CONTACT_TYPE)
        {
            newContacts = new List<Contact>();
            newContacts.addAll(createContacts(numberOfRecords));
            contactIds = populateIdSet(newContacts);
        }
        if(objectType == OPPORTUNITY_TYPE)
        {
            newOpportunities = new List<Opportunity>();
            newOpportunities.addAll(createOpportunities(numberOfRecords));
            opportunityIds = populateIdSet(newOpportunities);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a list of accounts
    * @param numberOfRecords The number of records to create
    * @return newAccounts A list account records
    */
    private static List<Account> createAccounts(Integer numberOfRecords)
    {
        List<Account> newAccounts = new List<Account>();
        //Management_System__c tempManagementSystem = createManagementSystem();
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Account tempAccount = new Account();
            tempAccount.Name = ACCOUNT_NAME + String.valueOf(i);
            tempAccount.Industry = ACCOUNT_INDUSTRY;
            tempAccount.RecurSoft__Payment_Term__c = accountPaymentTerm;
            tempAccount.RecurSoft__Synced_With_Intacct__c = accountSyncedWithIntacct;
            //tempAccount.Practice_Management_Software__c = tempManagementSystem.Id;
            tempAccount.BillingStreet = accStreet;
            tempAccount.BillingCity = accCity;
            tempAccount.Description = accDescription;
            tempAccount.BillingCountry = accCountry;
            tempAccount.BillingState = accState;
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
            newAccounts = new List<Account>();
            System.debug('Exception at insert');
            System.debug(ex);
        }
        return newAccounts;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a list of contacts
    * @param numberOfRecords The number of records to create
    * @return newContacts A list account records
    */
    private static List<Contact> createContacts(Integer numberOfRecords)
    {
        List<Contact> newContacts = new List<Contact>();
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Contact tempContact = new Contact();
            tempContact.LastName = CONTACT_LAST_NAME + String.valueOf(i);
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
            return newContacts;
        }
        catch(Exception ex)
        {
            newContacts = new List<Contact>();
        }
        return newContacts;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a list of opportunities
    * @param numberOfRecords The number of records to create
    * @return newOpportunities A list account records
    */
    private static List<Opportunity> createOpportunities(Integer numberOfRecords)
    {
        List<Opportunity> newOpportunities = new List<Opportunity>();
        List<Account> tempAccounts = createAccounts(1);
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Opportunity tempOpportunity = new Opportunity();
            tempOpportunity.Name = OPPORUNTITY_NAME + String.valueOf(i);
            tempOpportunity.CloseDate = OPPORUNTITY_CLOSE_DATE;
            tempOpportunity.StageName = OPPORUNTITY_STAGE_NAME;
            tempOpportunity.AccountId = tempAccounts[0].Id;
            tempOpportunity.RecurSoft__Bill_to_Account__c = tempAccounts[0].Id;
            tempOpportunity.RecurSoft__Contract_Signed_Date__c = OPPORUNTITY_CLOSE_DATE;
            tempOpportunity.RecurSoft__Initial_Contract_Term__c = OPPORTUNITY_INITIAL_CONTRACT_TERM;
            newOpportunities.add(tempOpportunity);
        }
        //try
        //{
            if(!newOpportunities.isEmpty())
            {
                insert newOpportunities;
            }
            return newOpportunities;
        //}
        //catch(Exception ex)
        //{
        //    newOpportunities = new List<Opportunity>();
        //}
        //return newOpportunities;
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
        try
        {
            insert newIntacctEntity;
            return newIntacctEntity;
        }
        catch(Exception ex)
        {
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
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Populate the set of ids for the corresponding object
    * @param newObjects A list of sObjects
    * @return idSet A set of sObject ids
    */
    private static Set<Id> populateIdSet(List<sObject> newObjects)
    {
        Set<Id> idSet = new Set<Id>();
        for(sObject tempSobject :newObjects)
        {
            idSet.add((Id)tempSobject.get(ID_FIELD_NAME));
        }
        return idSet;
    }
    
    /**
    * @author Cristina Verestiuc
    * @date June 2nd, 2014
    * @description Test the happy flow for the 'retrieveScheduledOpps' method
    */
    public static testmethod void testScheduledOppsMethodHappyFlow()
    {
        initializeTestingState();
        createIntactEntity();
        createTestData(numberOfTestRecords, OPPORTUNITY_TYPE);
        List<Opportunity> testOpportunities;
        Test.startTest();
        testOpportunities = GenerateSFDCObjectQueries.retrieveScheduledOpps(JOB_ID);
        Test.stopTest();
        
        System.assertEquals(testOpportunities.size(), 0);
    }
    
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
}