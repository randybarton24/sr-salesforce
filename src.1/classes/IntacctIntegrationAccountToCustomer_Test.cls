/**
 * File:        IntacctIntegrationAccountToCustomer_Test.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        April 2,2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************
 * Description: Test CustomerSyncHandler controller<br/>
 * *************************************************************************
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
 
@isTest
public with sharing class IntacctIntegrationAccountToCustomer_Test{
    private static final String ACCOUNT_NAME = 'Billing Account ';
    private static final String ACCOUNT_INDUSTRY = 'Dental';
    private static final String ACCOUNT_EMAIL = 'test@test.com';
    private static final String ACCOUNT_PHONE = '123456789';
    private static final String ACCOUNT_STATUS = 'Test Status';
    private static final String TEST_PAYMENT_TERM = 'Test payment term';
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
    private static Integer numberOfAccounts;
    private static IntacctIntegrationAccountToCustomer handlerInstance;
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test happy flow
    */
    public static testmethod void testHappyFlow()
    {
        initializeTestingState();
        createTestData(numberOfAccounts);
        Account testAccount = [SELECT Id FROM Account WHERE Name = :(ACCOUNT_NAME + String.valueOf(numberOfAccounts-1)) LIMIT 1];
        initializePageState(testAccount);
        Test.startTest();
        handlerInstance.syncAccount();
        Account testAccountUpdated = [SELECT Id, RecurSoft__Synced_With_Intacct__c FROM Account WHERE Id =:testAccount.Id];
        System.assertEquals(testAccountUpdated.RecurSoft__Synced_With_Intacct__c, false);
        Test.stopTest();
        
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Initialize testing state
    */
    private static void initializeTestingState()
    {
        numberOfAccounts = 1;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create the data required to test the controller
    * @param numberOfRecords The number of contacts to create
    */
    private static void createTestData(Integer numberOfRecords)
    {
        List<Account> accountList = new List<Account>();
        //create accounts
        accountList.addAll(createAccounts(numberOfRecords));
        //create custom settings
        createIntacctIntegrationSetting();
        createIntacctIdsSetting();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Create a list of account
    * @param numberOfRecords The number of records to create
    * @return newAccounts A list account records
    */
    private static List<Account> createAccounts(Integer numberOfRecords)
    {
        List<Account> newAccounts = new List<Account>();
        for(Integer i = 0; i < numberOfRecords; i++)
        {
            Account tempAccount = new Account();
            tempAccount.Name = ACCOUNT_NAME + String.valueOf(i);
            tempAccount.Industry = ACCOUNT_INDUSTRY;
            tempAccount.RecurSoft__Billing_Email__c = ACCOUNT_EMAIL;
            tempAccount.RecurSoft__Billing_Email_CC__c = ACCOUNT_EMAIL;
            tempAccount.RecurSoft__Payment_Term__c = TEST_PAYMENT_TERM;
            tempAccount.Phone = ACCOUNT_PHONE;
            tempAccount.RecurSoft__Status__c = ACCOUNT_STATUS;
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
            newIntacctSetting = new Intacct_Ids__c();
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date May 16, 2014
    * @description Create the custom intacct setting
    */
    private static void initializePageState(Account testAccount)
    {
        ApexPages.Standardcontroller contactController = new ApexPages.Standardcontroller(testAccount);
        Test.setCurrentPage(Page.IntacctIntegrationAccountToCustomer);
        handlerInstance = new IntacctIntegrationAccountToCustomer(contactController);
    }
    
}