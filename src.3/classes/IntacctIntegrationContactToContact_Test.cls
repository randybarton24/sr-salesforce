/**
 * File:        IntacctIntegrationContactToContact_Test.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        April 2,2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************
 * Description: Test ContactSyncHandler controller<br/>
 * *************************************************************************
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
 
@isTest
public with sharing class IntacctIntegrationContactToContact_Test{
    
    private static final String BILL_TO_PREFIX = 'B_';
    private static final String CONTACT_MAILING_STREET = 'Wall Street';
    private static final String CONTACT_MAILING_CITY = 'Lehi';
    private static final String CONTACT_MAILING_STATE = 'California';
    private static final String CONTACT_MAILING_ZIP = '84043';
    private static final String CONTACT_MAILING_COUNTRY = 'United States';
    private static final String ACCOUNT_NAME = 'Billing Account';
    private static final String ACCOUNT_CUSTOMER_ID = '999999';
    private static final String ACCOUNT_INDUSTRY = 'Dental';
    private static final String ACCOUNT_EMAIL = 'test@test.com';
    private static final String ACCOUNT_PHONE = '123456789';
    private static final String TEST_PAYMENT_TERM = 'Test payment term';
    
    private static final String INTACCT_COMPANY = 'Test COmpany';
    private static final String INTACCT_URL = 'Test Url';
    private static final String INTACCT_USER_PASSWORD = 'Test User Password';
    private static final String INTACCT_USER = 'Test User';
    private static final String INTACCT_SENDER = 'Test Sender';
    private static final String INTACCT_SENDER_PASSWORD = 'Test Sender Password';
    private static final String INTACCT_SETTING_NAME = 'Intacct Gateway';
    private static final String UNDERSCORE_CHARACTER = '_';
    private static final String ENTITY_NAME = 'SR001';
    private static final String MANAGEMENT_SYSTEM_NAME = 'TEST MANAGEMENT SYSTEM';
    private static Integer numberOfContacts;
    private static IntacctIntegrationContactToContact handlerInstance;
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test happy flow
    */
    public static testmethod void testVisualforceContextHappyFlow()
    {
        initTestingState();
        createTestData(numberOfContacts);
        Contact testContact = [SELECT Id FROM Contact WHERE LastName =:String.valueOf(numberOfContacts) AND FirstName =:BILL_TO_PREFIX LIMIT 1];
        initializePageState(testContact);
        Test.startTest();
        handlerInstance.syncContact();
        Test.stopTest();
        
        testContact = [SELECT Id, RecurSoft__Intacct_Contact_ID__c FROM Contact WHERE LastName =:String.valueOf(numberOfContacts) AND FirstName =:BILL_TO_PREFIX LIMIT 1];
        System.assertEquals(testContact.RecurSoft__Intacct_Contact_ID__c, BILL_TO_PREFIX + ACCOUNT_CUSTOMER_ID + UNDERSCORE_CHARACTER + testContact.Id);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Initialize testing state
    */
    private static void initTestingState()
    {
        numberOfContacts = 1;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the data required to test the controller
    * @param numberOfRecords The number of contacts to create
    */
    private static void createTestData(Integer numberOfRecords)
    {
        List<Contact> contactList = new List<Contact>();
        createIntactEntity();
        //create contacts
        contactList.addAll(createContacts(BILL_TO_PREFIX, numberOfRecords));
        //create intacct custom setting
        createIntacctSetting();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a list of contacts
    * @param prefix Contact name prefix
    * @param numberOfRecords The number of contacts to create
    * @return contacts A list of test contacts
    */
    private static List<Contact> createContacts(String prefix, Integer numberOfRecords)
    {
        List<Contact> contacts = new List<Contact>();
        Account parentAccount = createAccount();
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Contact tempContact = new Contact();
            tempContact.FirstName = prefix;
            tempContact.LastName = String.valueOf(i + 1);
            tempContact.MailingStreet = CONTACT_MAILING_STREET;
            tempContact.MailingCity = CONTACT_MAILING_CITY;
            tempContact.MailingState = CONTACT_MAILING_STATE;
            tempContact.MailingPostalCode = CONTACT_MAILING_ZIP;
            tempContact.MailingCountry = CONTACT_MAILING_COUNTRY;
            tempContact.AccountId = parentAccount.Id;
            tempContact.Phone = ACCOUNT_PHONE;
            tempContact.Email = ACCOUNT_EMAIL;
            contacts.add(tempContact);
        }
        try
        {
            if(!contacts.isEmpty())
            {
                insert contacts;
            }
            return contacts;
        }
        catch(Exception ex)
        {
            contacts = new List<Contact>();
        }
        return contacts;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the data required to test the controller
    * @return newAccount A account record
    */
    private static Account createAccount()
    {
        Account newAccount = new Account();
        newAccount.Name = ACCOUNT_NAME;
        newAccount.RecurSoft__IntacctID__c = ACCOUNT_CUSTOMER_ID;
        newAccount.Industry = ACCOUNT_INDUSTRY;
        newAccount.RecurSoft__Billing_Email__c = ACCOUNT_EMAIL;
        newAccount.RecurSoft__Billing_Email_CC__c = ACCOUNT_EMAIL;
        newAccount.Phone = ACCOUNT_PHONE;
        newAccount.RecurSoft__Synced_With_Intacct__c = true;
        newAccount.RecurSoft__Payment_Term__c = TEST_PAYMENT_TERM; 
        try
        {
            if(!String.isBlank(newAccount.Industry) && !String.isBlank(newAccount.Name))
            {
                insert newAccount;
            }
            return newAccount;
        }
        catch(Exception ex)
        {
            newAccount = new Account();
        }
        return newAccount;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the custom intacct setting
    */
    private static void createIntacctSetting()
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
            newIntacctSetting = new Intacct_Integration_Settings__c();
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date May 16, 2014
    * @description Create the custom intacct setting
    */
    private static void initializePageState(Contact testContact)
    {
        ApexPages.Standardcontroller contactController = new ApexPages.Standardcontroller(testContact);
        Test.setCurrentPage(Page.IntacctIntegrationContactToContact);
        handlerInstance = new IntacctIntegrationContactToContact(contactController);
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
    
}