/**
 * File:        IntacctIntegrationAccountToCustomer.cls
 * Project:     Sererra - Subscription Billing
 * Date:        May 15, 2014
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description:  Contains methods to synchronize a salesforce account record to a intacct customer record.
 * *************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */
public with sharing class IntacctIntegrationAccountToCustomer 
{
    private static final String INTACCT_INTEGRATION_CONSTRUCTOR_LOG_ENTRY = 'IntacctIntegrationAccountToCustomer.IntacctIntegrationAccountToCustomer';
    private static final String INTACCT_INTEGRATION_SYNC_ACCOUNT_LOG_ENTRY = 'IntacctIntegrationAccountToCustomer.syncAccount';
    private static final String INTACCT_INTEGRATION_SYNC_ACCOUNT_WITH_INTACCT_LOG_ENTRY = 'IntacctIntegrationAccountToCustomer.syncAccountWithIntacct';
    private static final String INTACCT_INTEGRATION_RECHECKED_ACCOUNT_ENTRY = 'IntacctIntegrationAccountToCustomer.recheckAccounts';    
    private static final String INTACCT_INTEGRATION_VALIDATE_ACCOUNT_LOG_ENTRY = 'IntacctIntegrationContactToContact.validateAccount';
    private static final String INTACCT_INTEGRATION_UPDATE1_LOG_ENTRY = 'IntacctIntegrationAccountToCustomer.updateCustomSetting';
    
    public static final String INVALID_ACCOUNT_PAGE_MESSAGE = 'The account is not ready to be synchronized.<br /> Reasons :';
    public static final String INVALID_ACCOUNT_PAGE_MESSAGE_SHORT = 'The account is not ready to be synchronized.';
    public static final String INVALID_SYNCED_WITH_INTACCT_ERROR = '<br />&nbsp;&nbsp;Synced With Intacct is checked.';
    public static final String INVALID_NAME_ERROR = '<br />&nbsp;&nbsp;Name is wrong.';
    private static final String RECORD_PROCESSED_PAGE_MESSAGE = 'The record was processed.';
    private static final String RECORD_FAILED_PAGE_MESSAGE = 'The record processing has failed.<br /> Please check errors : <a target="_BLANK" href="/apex/IntacctErrorHandling">Errors page</a>';
    public static final String STRING_RED = 'red';
    private static final String LAST_CUSTOMER_ID_SETTING_NAME = 'Last Customer Id';
    
    private Set<Id> accountIds;
    private Boolean isValid;
    private CustomerSyncHandler customerIntegration;
    private List<Account> accounts;
    
    public static Map<Id, Account> accountsWithCustomerId;
    
    /**
    * @author Ionut Boghean
    * @date May 15, 2014
    * @description Constructor
    * @param controller The standard controller used for visualforce custom controllers
    */
    public IntacctIntegrationAccountToCustomer(ApexPages.StandardController controller) 
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_CONSTRUCTOR_LOG_ENTRY);
        try
        {
            init();
            accountIds.add(controller.getId());
            //accounts = GenerateSFDCObjectQueries.retrieveAccounts(accountIds);
            //validateAccount(accounts);
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
    }

    public IntacctIntegrationAccountToCustomer(Id accountId) 
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_CONSTRUCTOR_LOG_ENTRY);
        try
        {
            init();
            accountIds.add(accountId);            
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date May 15, 2014
    * @description Start the account sync
    */
    public void syncAccount()
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_SYNC_ACCOUNT_LOG_ENTRY);
        try
        {
            //if(isValid)
            //{
                customerIntegration.startCustomerIntegration(accountIds, true);
                if(customerIntegration.isValid){
                    updateCustomSetting();
                    recheckAccounts(true);
                }else{
                    displayPageMessage(ApexPages.Severity.WARNING, customerIntegration.errorMessage);
                }
            //}
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date May 15, 2014
    * @description Initialize controller state and variables
    */
    private void init() 
    {
        accountIds = new Set<Id>();
        customerIntegration = new CustomerSyncHandler();
        isValid = true;
        accounts = new List<Account>();
        accountsWithCustomerId = new Map<Id, Account>();
    }
    
    /**
    * @author Roman Bychko
    * @date June 12, 2014
    * @description check if RecurSoft__Synced_With_Intacct__c is checked or not
    */
    private void recheckAccounts(Boolean visualforce) 
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_RECHECKED_ACCOUNT_ENTRY);
        
        Boolean isOk = true;
        List<Account> accToCheck = GenerateSFDCObjectQueries.retrieveAccounts(accountIds);
        for(Account acc : accToCheck){
            if(!acc.RecurSoft__Synced_With_Intacct__c){
                isOk = false;
                break;
            }
        }
        if(isOk){
            if(!visualforce) IntacctIntegrationLoggingHandler.debug(RECORD_PROCESSED_PAGE_MESSAGE);
            if(visualforce) displayPageMessage(ApexPages.Severity.CONFIRM, RECORD_PROCESSED_PAGE_MESSAGE);
        }else{
            if(!visualforce) IntacctIntegrationLoggingHandler.debug(RECORD_FAILED_PAGE_MESSAGE);
            if(visualforce) displayPageMessage(ApexPages.Severity.WARNING, RECORD_FAILED_PAGE_MESSAGE);
        }
        IntacctIntegrationLoggingHandler.popEntry();
    }
    
    /**
    * @author Ionut Boghean
    * @date May 15, 2014
    * @description Check if the account is ready to sync
    * @param currentAccounts The accounts that are being processed
    */
    /*
    private void validateAccount(List<Account> currentAccounts) 
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_VALIDATE_ACCOUNT_LOG_ENTRY);
        try
        {
            for(Account tempAccount :currentAccounts)
            {
                if(tempAccount.RecurSoft__Ready_to_sync_with_Intacct__c.contains(STRING_RED)){
                    displayPageMessage(ApexPages.Severity.ERROR, INVALID_ACCOUNT_PAGE_MESSAGE_SHORT);
                    if(!System.test.isRunningTest()){
                        isValid = false;
                        continue;
                    }
                }
                String error = '';
                if(String.isBlank(tempAccount.Name))
                {
                    isValid = false;
                    error+= INVALID_NAME_ERROR;
                }
                if(!isValid){
                    displayPageMessage(ApexPages.Severity.ERROR, INVALID_ACCOUNT_PAGE_MESSAGE+error);
                }
            }
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
    }
    */
    /**
    * @author Ionut Boghean
    * @date May 15, 2014
    * @description Add a message to the visualforce page
    */
    private void displayPageMessage(ApexPages.severity severity, String messageSummary)
    {
        if(!ApexPages.hasMessages())
        {
            ApexPages.addMessage(new ApexPages.Message(severity, messageSummary));
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Update the last customer id used
    */
    private void updateCustomSetting()
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_UPDATE1_LOG_ENTRY);
        try
        {
            Intacct_Ids__c lastCustomerId = Intacct_Ids__c.getValues(LAST_CUSTOMER_ID_SETTING_NAME);
            List<Account> customerIds = IntacctIntegrationAccountToCustomer.accountsWithCustomerId.values();
            Account lastAccount = customerIds.get(customerIds.size() - 1);
            if(!String.isBlank(lastAccount.RecurSoft__IntacctID__c) && Integer.valueOf(lastAccount.RecurSoft__IntacctID__c) > Integer.valueOf(lastCustomerId.Id_Value__c))
            {
                lastCustomerId.Id_Value__c = lastAccount.RecurSoft__IntacctID__c;
                update lastCustomerId;
            }
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
    }

    public Boolean syncAccountWithIntacct()
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_SYNC_ACCOUNT_WITH_INTACCT_LOG_ENTRY);
                    
        customerIntegration.startCustomerIntegration(accountIds, true);
        if(customerIntegration.isValid)
        {
            //recheckAccounts has ApexPage message
            recheckAccounts(false);
        }
        else
        {
            IntacctIntegrationLoggingHandler.debug(customerIntegration.errorMessage);
        }
                        
        return customerIntegration.isValid;        
    }

    public Boolean syncAccountWithIntacct2()
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_SYNC_ACCOUNT_WITH_INTACCT_LOG_ENTRY);
                    
        customerIntegration.startCustomerIntegration(accountIds, false);                        
        return customerIntegration.isValid;        
    }
}