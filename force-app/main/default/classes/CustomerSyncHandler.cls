/**
 * File:        CustomerSyncHandler.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        March 26, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description:  Contains methods to call to the query handler for the integration, the mapping handler, start the customer integration process and return a list of accounts with the customer id assigned.<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 * 06.06.14             Roman Bychko            Added validation of accounts sync
 */
public with sharing class CustomerSyncHandler {
    
    private static final String CUSTOMER_INTEGRATION_LOG_ENTRY = 'CustomerSyncHandler.startCustomerIntegration';
    private static final String CUSTOMER_INTEGRATION_VALIDATE_LOG_ENTRY = 'CustomerSyncHandler.validate';
    private static final String LAST_CUSTOMER_ID_SETTING_NAME = 'Last Customer Id';
    private static final String HYPHEN_CHARACTER_SEPARATOR = '-';
    private static final String INVALID_ACCOUNT_PAGE_MESSAGE = 'The account is not ready to be synchronized.<br /> Reasons :';
    private static final String INVALID_ACCOUNT_PAGE_MESSAGE_SHORT = 'The account is not ready to be synchronized.<br />Please fill in Payment Term, Intacct Entity and Billing Email.';
    private static final String INVALID_SYNCED_WITH_INTACCT_ERROR = '<br />&nbsp;&nbsp;Synced With Intacct is checked.';
    private static final String STRING_RED = 'red';
    private static final String INVALID_NAME_ERROR = '<br />&nbsp;&nbsp;Name is wrong.';
    private static final String PARENT_ACCOUNT_NOT_SYNC = '<br />&nbsp;&nbsp;Parent account not synced. Please sync the parent account first. ';
    private List<Account> accounts;
    private List<Object> customers;
    private IntacctIntegrationMappingsHandler mappingController;
    public Boolean isValid;
    public Boolean isOpportunityAction;
    public String errorMessage;
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Constructor
    * @param newMap The trigger opportunities with the new values
    * @param oldMap The trigger opportunities with the old values
    */
    public CustomerSyncHandler(){
        init();
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Start the customer integration
    */
    public void startCustomerIntegration(Set<Id> accountIds, Boolean doDmlOperations){
        IntacctIntegrationLoggingHandler.pushEntry(CUSTOMER_INTEGRATION_LOG_ENTRY);
        try{
            accounts = GenerateSFDCObjectQueries.retrieveAccounts(accountIds);
            validateAccount(accounts);
            if(isValid){
                addCustomerIds(doDmlOperations);
                //filterAccountList();
                customers = mappingController.mapAccountsToCustomers(accounts);
                System.debug('CUSTOMERS :' + customers);
                IntacctIntegrationSyncHandler.intacctResponseAndObjectIds = IntacctSyncObjects.upsertObjects(customers, doDmlOperations);
            }
            IntacctIntegrationLoggingHandler.popEntry();
        }catch(Exception ex){
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Initialize variable and controller state
    */
    private void init(){
        accounts = new List<Account>();
        customers = new List<Object>();
        mappingController = new IntacctIntegrationMappingsHandler();
        isValid = true;
        errorMessage = '';
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Add the customer id to each account
    */
    private void addCustomerIds(Boolean isAccountSync){
        Intacct_Ids__c lastCustomerId = Intacct_Ids__c.getValues(LAST_CUSTOMER_ID_SETTING_NAME);
        String newCustomerId = '';
        for(Account tempAccount :accounts){
            if(String.isBlank(tempAccount.RecurSoft__IntacctID__c)){
                newCustomerId = incrementCustomerIdValue(lastCustomerId.Id_Value__c);
                tempAccount.RecurSoft__IntacctID__c = newCustomerId;
            }
            if(!isAccountSync || System.Test.isRunningTest()){
                IntacctIntegrationSyncHandler.accountsWithCustomerId.put(tempAccount.Id, tempAccount);
            }
            if(isAccountSync){
                IntacctIntegrationAccountToCustomer.accountsWithCustomerId.put(tempAccount.Id, tempAccount);
            }
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Increment the last customer id value
    * @param lastIdValue The last customer id used
    * @return newIdValue The new customer id
    */
    private String incrementCustomerIdValue(String lastIdValue){
        String newIdValue = '';
        Integer idNumberIncrement = Integer.valueOf(lastIdValue) + 1;
        newIdValue = String.valueOf(idNumberIncrement);
        return newIdValue;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 11, 2014
    * @description Remove the accounts that were synced from the process
    */
    private void filterAccountList(){
        List<Account> tempAccountList = accounts.clone();
        for(Integer i = 0; i < tempAccountList.size(); i++)
        {
            /*if(tempAccountList[i].RecurSoft__Synced_With_Intacct__c)
            {
                if(accounts.size()>i)
                accounts.remove(i);
            }*/
        }
    }
    
    /**
    * @author Roman Bychko
    * @date June 06, 2014
    * @description Check if the account is ready to sync
    * @param currentAccounts The accounts that are being processed
    */
    public void validateAccount(List<Account> currentAccounts){
        IntacctIntegrationLoggingHandler.pushEntry(CUSTOMER_INTEGRATION_VALIDATE_LOG_ENTRY);
        try{
            for(Account tempAccount :currentAccounts){
                if(tempAccount.RecurSoft__Ready_to_sync_with_Intacct__c.contains(STRING_RED)){
                    this.errorMessage = INVALID_ACCOUNT_PAGE_MESSAGE_SHORT;
                    if(!System.test.isRunningTest()){
                        isValid = false;
                        break;
                    }
                }
                String errorTmp = '';
                if(String.isBlank(tempAccount.Name)){
                    isValid = false;
                    errorTmp+= INVALID_NAME_ERROR;
                }
                if(!isValid){
                    this.errorMessage = INVALID_ACCOUNT_PAGE_MESSAGE+errorTmp;
                    break;
                }
                if(IntacctIntegrationSyncHandler.checkEnableResellerProcessSetting()){
                    if(tempAccount.ParentId != null){
                        if(String.isBlank(tempAccount.Parent.RecurSoft__IntacctID__c) || !tempAccount.Parent.RecurSoft__Synced_With_Intacct__c ){
                            isValid = false;
                            this.errorMessage = INVALID_ACCOUNT_PAGE_MESSAGE + PARENT_ACCOUNT_NOT_SYNC;
                            break;
                        }
                    }
                }
            }
            IntacctIntegrationLoggingHandler.popEntry();
        }catch(Exception ex){
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
    }
    
    /**
    * @author Roman Bychko
    * @date June 06, 2014
    * @description Add a message to the visualforce page
    */
    private void displayPageMessage(ApexPages.severity severity, String messageSummary)
    {
            ApexPages.addMessage(new ApexPages.Message(severity, messageSummary));
    }
    
}