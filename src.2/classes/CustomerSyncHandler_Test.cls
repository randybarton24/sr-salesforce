/**
 * File:        CustomerSyncHandler_Test.cls<br/>
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
public with sharing class CustomerSyncHandler_Test{
    private static final String ACCOUNT_NAME = 'Billing Account ';
    private static final String ACCOUNT_INDUSTRY = 'Dental';
    private static final String ACCOUNT_EMAIL = 'test@test.com';
    private static final String ACCOUNT_PHONE = '123456789';
    private static final String ACCOUNT_STATUS = 'Test Status';
    private static final String DEFAULT_PAYMENT_TERM = 'Due Upon Receipt';
    private static final String INTACCT_COMPANY = 'Test COmpany';
    private static final String INTACCT_URL = 'Test Url';
    private static final String INTACCT_USER_PASSWORD = 'Test User Password';
    private static final String INTACCT_USER = 'Test User';
    private static final String INTACCT_SENDER = 'Test Sender';
    private static final String INTACCT_SENDER_PASSWORD = 'Test Sender Password';
    private static final String INTACCT_SETTING_NAME = 'Intacct Gateway';
    private static final String LAST_CUSTOMER_ID_SETTING_NAME = 'Last Customer Id';
    private static final String LAST_CUSTOMER_ID = '999999';
    private static Set<Id> accounts;
    private static Integer numberOfAccounts;
    private static final String CONFIGURATION_SETTINGS_ENABLE_RESELLER_PROCESS = 'Reseller Process';
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Test happy flow
    */
    public static testmethod void testHappyFlow()
    {
        initializeTestingState();
        createTestData(numberOfAccounts);
        CustomerSyncHandler handler = new CustomerSyncHandler();
        Test.startTest();
        handler.startCustomerIntegration(accounts, false);
        Test.stopTest();
        
        Account tempAccount;
        for(Id accountId :accounts)
        {
            tempAccount = IntacctIntegrationSyncHandler.accountsWithCustomerId.get(accountId);
            System.assertNotEquals(tempAccount.RecurSoft__IntacctID__c, null);
        }
    }
    
    /**
    * @author Daniel Savu
    * @date December 23, 2015
    * @description Test negative flow
    */
    public static testmethod void testNegativeFlow()
    {
        initializeTestingState();
        createTestData(numberOfAccounts);
        createResselerProcessSetting();
        CustomerSyncHandler handler = new CustomerSyncHandler();
        Test.startTest();
        handler.startCustomerIntegration(accounts, false);
        Test.stopTest();
    }
    
    /**
    * @author Ionut Boghean
    * @date April 2, 2014
    * @description Initialize testing state
    */
    private static void initializeTestingState()
    {
        numberOfAccounts = 2;
        accounts = new Set<Id>();
        IntacctIntegrationSyncHandler.accountsWithCustomerId = new Map<Id, Account>();
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
        accountList[1].ParentId = accountList[0].Id;
        accountList[1].RecordTypeId = SRUtilities.getRecordTypeId('Account', 'Child Account');
        update accountList[1];
        //create custom settings
        createIntacctIntegrationSetting();
        createIntacctIdsSetting();
        //populate account id set
        accounts = populateAccountSet(accountList);
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
            tempAccount.Phone = ACCOUNT_PHONE;
            tempAccount.RecurSoft__Status__c = ACCOUNT_STATUS;
            tempAccount.RecurSoft__Payment_Term__c = DEFAULT_PAYMENT_TERM;
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
    * @date April 2, 2014
    * @description Populate the account set with the new records id
    * @param newAccounts A list of accounts
    * @return accountIdSet A map of contact ids and the related customer account
    */
    private static Set<Id> populateAccountSet(List<Account> newAccounts)
    {
        Set<Id> accountIdSet = new Set<Id>();
        for(Account tempAccount :newAccounts)
        {
            accountIdSet.add(tempAccount.Id);
        }
        return accountIdSet;
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