/**
 * File:        ContactSyncHandler_Test.cls<br/>
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
public with sharing class ContactSyncHandler_Test{
    
    private static final String BILL_TO_PREFIX = 'Bill to';
    private static final String SHIP_TO_PREFIX = 'Ship to';
    private static final String CONTACT_MAILING_STREET = 'Test Street';
    private static final String CONTACT_MAILING_CITY = 'Glendale';
    private static final String CONTACT_MAILING_STATE = 'California';
    private static final String CONTACT_MAILING_ZIP = 'Test Zip';
    private static final String CONTACT_MAILING_COUNTRY = 'United States';
    private static final String ACCOUNT_NAME = 'Billing Account';
    private static final String ACCOUNT_CUSTOMER_ID = '999999';
    private static final String ACCOUNT_INDUSTRY = 'E001';
    private static final String ACCOUNT_EMAIL = 'test@test.com';
    private static final String ACCOUNT_PHONE = '123456789';
    private static final String DEFAULT_PAYMENT_TERM = 'Due Upon Receipt';
    private static final String INTACCT_COMPANY = 'Test COmpany';
    private static final String INTACCT_URL = 'Test Url';
    private static final String INTACCT_USER_PASSWORD = 'Test User Password';
    private static final String INTACCT_USER = 'Test User';
    private static final String INTACCT_SENDER = 'Test Sender';
    private static final String INTACCT_SENDER_PASSWORD = 'Test Sender Password';
    private static final String INTACCT_SETTING_NAME = 'Intacct Gateway';
    private static Map<Id, Id> billToContacts;
    private static Map<Id, Id> shipToContacts;
    private static Boolean doBillEqualShipFlag;
    private static Integer numberOfContacts;
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test happy flow
    */
    public static testmethod void testHappyFlow()
    {
        initTestingState();
        createTestData(doBillEqualShipFlag, numberOfContacts,true);
        ContactSyncHandler handler = new ContactSyncHandler();
        Test.startTest();
        handler.startContactIntegration(billToContacts, shipToContacts);
        Test.stopTest();
        
        Set<Id> contactIds = new Set<Id>();
        contactIds.addAll(billToContacts.keySet());
        contactIds.addAll(shipToContacts.keySet());
        List<Contact> updatedContacts = new List<Contact>();
        try
        {
            updatedContacts.addAll([SELECT Id, RecurSoft__Intacct_Contact_ID__c FROM Contact WHERE Id IN: contactIds]);
        }
        catch(Exception ex)
        {
            updatedContacts = new List<Contact>();
        }
        for(Contact tempContact :updatedContacts)
        {
            System.assertNotEquals(tempContact.RecurSoft__Intacct_Contact_ID__c, null);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test happy flow
    */
    public static testmethod void testNegativeFlow()
    {
        initTestingState();
        createTestData(doBillEqualShipFlag, numberOfContacts, true);
        ContactSyncHandler handler = new ContactSyncHandler();
        Test.startTest();
        handler.startContactIntegration(Null, shipToContacts);
        Test.stopTest();
        
        Set<Id> contactIds = new Set<Id>();
        contactIds.addAll(billToContacts.keySet());
        contactIds.addAll(shipToContacts.keySet());
        List<Contact> updatedContacts = new List<Contact>();
        try
        {
            updatedContacts.addAll([SELECT Id, RecurSoft__Intacct_Contact_ID__c FROM Contact WHERE Id IN: contactIds]);
        }
        catch(Exception ex)
        {
            updatedContacts = new List<Contact>();
        }
        for(Contact tempContact :updatedContacts)
        {
            //System.assertNotEquals(tempContact.RecurSoft__Intacct_Contact_ID__c, null);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test happy flow
    */
    public static testmethod void testNegativeFlow2()
    {
        initTestingState();
        createTestData(doBillEqualShipFlag, numberOfContacts,false);
        ContactSyncHandler handler = new ContactSyncHandler();
        Test.startTest();
        handler.startContactIntegration(billToContacts, shipToContacts);
        Test.stopTest();
        
        Set<Id> contactIds = new Set<Id>();
        contactIds.addAll(billToContacts.keySet());
        contactIds.addAll(shipToContacts.keySet());
        List<Contact> updatedContacts = new List<Contact>();
        try
        {
            updatedContacts.addAll([SELECT Id, RecurSoft__Intacct_Contact_ID__c FROM Contact WHERE Id IN: contactIds]);
        }
        catch(Exception ex)
        {
            updatedContacts = new List<Contact>();
        }
        for(Contact tempContact :updatedContacts)
        {
            System.assertNotEquals(tempContact.RecurSoft__Intacct_Contact_ID__c, null);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Initialize testing state
    */
    private static void initTestingState()
    {
        doBillEqualShipFlag = false;
        numberOfContacts = 1;
        billToContacts = new Map<Id, Id>();
        shipToContacts = new Map<Id, Id>();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the data required to test the controller
    * @param doBillEqualShip Flag for setting different contacts for bill to and ship to
    * @param numberOfRecords The number of contacts to create
    */
    private static void createTestData(Boolean doBillEqualShip, Integer numberOfRecords,Boolean isValid)
    {
        List<Contact> billToContactList = new List<Contact>();
        List<Contact> shipToContactList = new List<Contact>();
        Account testAccount;
        //create contacts
        billToContactList.addAll(createContacts(BILL_TO_PREFIX, numberOfRecords,isValid));
        if(!doBillEqualShip)
        {
            shipToContactList.addAll(createContacts(SHIP_TO_PREFIX, numberOfRecords,isValid));
        }
        else
        {
            shipToContactList.addAll(billToContactList);
        }
        //create account
        testAccount = createAccount(isValid);
        //create intacct custom setting
        createIntacctSetting();
        //populate contact maps
        billToContacts.putAll(populateContactMap(billToContactList, testAccount));
        shipToContacts.putAll(populateContactMap(shipToContactList, testAccount));
        //poulate account map
        populateAccountMap(testAccount);
        IntacctIntegrationSyncHandler.contactsWithIntacctId = new Map<Id, Contact>();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a list of contacts
    * @param prefix Contact name prefix
    * @param numberOfRecords The number of contacts to create
    * @return contacts A list of test contacts
    */
    private static List<Contact> createContacts(String prefix, Integer numberOfRecords,Boolean isValid)
    {
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Contact tempContact = new Contact();
            if(isValid){
            	tempContact.FirstName = prefix;
            }
            tempContact.LastName = String.valueOf(i + 1);
            tempContact.MailingStreet = CONTACT_MAILING_STREET;
            tempContact.MailingCity = CONTACT_MAILING_CITY;
            tempContact.MailingState = CONTACT_MAILING_STATE;
            tempContact.MailingPostalCode = CONTACT_MAILING_ZIP;
            tempContact.MailingCountry = CONTACT_MAILING_COUNTRY;
            tempContact.Email = ACCOUNT_EMAIL;
            tempContact.Phone = ACCOUNT_PHONE;
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
    private static Account createAccount(Boolean isValid)
    {
        Account newAccount = new Account();
        newAccount.Name = ACCOUNT_NAME;
        if(isValid){
        	newAccount.RecurSoft__IntacctID__c = ACCOUNT_CUSTOMER_ID;
        }
        newAccount.Industry = ACCOUNT_INDUSTRY;
        newAccount.RecurSoft__Billing_Email__c = ACCOUNT_EMAIL;
        newAccount.RecurSoft__Billing_Email_CC__c = ACCOUNT_EMAIL;
        newAccount.Phone = ACCOUNT_PHONE;
        newAccount.RecurSoft__Payment_Term__c = DEFAULT_PAYMENT_TERM;
        
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
    * @date April 2, 2014
    * @description Populate the 'IntacctIntegrationSyncHandler.accountsWithCustomerId' with the test account 
    * @param customer The customer account used by the test methods
    */
    private static void populateAccountMap(Account customerAccount)
    {
        IntacctIntegrationSyncHandler.accountsWithCustomerId = new Map<Id, Account>();
        IntacctIntegrationSyncHandler.accountsWithCustomerId.put(customerAccount.Id, customerAccount);
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Populate the contact map with contact ids and account id
    * @param contactList A list of contacts
    * @param customerAccount The customer account used by the test methods
    * @return contactMap A map of contact ids and the related customer account
    */
    private static Map<Id, Id> populateContactMap(List<Contact> contactList, Account customerAccount)
    {
        Map<Id, Id> contactMap = new Map<Id, Id>();
        for(Contact tempContact :contactList)
        {
            contactMap.put(tempContact.Id, customerAccount.Id);
        }
        return contactMap;
    }
}