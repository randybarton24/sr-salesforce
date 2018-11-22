/**
 * File:        IntacctIntegrationMappingsHandler_Test.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        April 4, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************
 * Description: Test IntacctIntegrationMappingsHandler controller<br/>
 * *************************************************************************
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
 
@isTest
public with sharing class IntacctIntegrationMappingsHandler_Test{
    
    private static final String CONTACT_MAILING_STREET = 'Test Street';
    private static final String CONTACT_MAILING_CITY = 'Test City';
    private static final String CONTACT_MAILING_STATE = 'Alabama';
    private static final String CONTACT_MAILING_ZIP = '12345';
    private static final String CONTACT_MAILING_COUNTRY = 'United States';
    private static final String CONTACT_INTACCT_ID = 'Test Intacct Id';
    private static final String CONTACT_EMAIL = 'test@email.com';
    private static final String CONTACT_PHONE = '123124124';
    private static final String TEST_NAME = 'Test Name';
    private static final String ACCOUNT_CUSTOMER_ID = 'C-999999';
    private static final String ACCOUNT_INDUSTRY = 'Dental';
    private static final String ACCOUNT_EMAIL = 'test@test.com';
    private static final String ACCOUNT_PHONE = '123456789';
    private static final String ACCOUNT_PAYMENT_TERM = 'Test Payment Term';
    private static final String ACCOUNT_STATUS = 'Active';
    private static final String ENTITY_NAME = 'SR001';
    private static final String MANAGEMENT_SYSTEM_NAME = 'TEST MANAGEMENT SYSTEM';
    private static final Schema.sObjectType ACCOUNT_TYPE = Account.sObjectType;
    private static final Schema.sObjectType CONTACT_TYPE = Contact.sObjectType;
    private static IntacctIntegrationMappingsHandler handler;
    private static List<Contact> contacts;
    private static List<Account> accounts;
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Test mapContactsToContacts with a single record
    */
    public static testmethod void testMapContactsToContactsSingle()
    {
        initTestingState();
        Integer numberOfContacts = 1;
        contacts = new List<Contact>();
        createTestData(numberOfContacts, CONTACT_TYPE);
        Test.startTest();
        List<Object> intacctObjects = handler.mapContactsToContacts(contacts);
        Test.stopTest();
        
        System.assertEquals(numberOfContacts, intacctObjects.size());
        
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Test mapAccountsToCustomers with a single record
    */
    public static testmethod void testMapAccountsToCustomersSingle()
    {
        initTestingState();
        Integer numberOfAccounts = 1;
        accounts = new List<Account>();
        createIntactEntity();
        createTestData(numberOfAccounts, ACCOUNT_TYPE);
        Test.startTest();
        List<Object> intacctObjects = handler.mapAccountsToCustomers(accounts);
        Test.stopTest();
        
        System.assertEquals(numberOfAccounts, intacctObjects.size());
        
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Initialize testing state
    */
    private static void initTestingState()
    {
        handler = new IntacctIntegrationMappingsHandler();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 4, 2014
    * @description Create the data required to test the controller
    * @param numberOfRecords The number of contacts to create
    * @param objectType The sObject type
    */
    private static void createTestData(Integer numberOfRecords, Schema.sObjectType objectType)
    {
        if(objectType == CONTACT_TYPE)
        {
            contacts.addAll(createContacts(numberOfRecords));
        }
        if(objectType == ACCOUNT_TYPE)
        {
            accounts.addAll(createAccounts(numberOfRecords));
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
            tempAccount.RecurSoft__IntacctID__c = ACCOUNT_CUSTOMER_ID;
            tempAccount.RecurSoft__Payment_Term__c = ACCOUNT_PAYMENT_TERM;
            tempAccount.Practice_Management_Software__c = tempManagementSystem.Id;
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
        }
        return newAccounts;
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
    
}