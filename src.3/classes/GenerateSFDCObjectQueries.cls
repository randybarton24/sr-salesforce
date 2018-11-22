/**
 * File:        GenerateSFDCObjectQueries.cls
 * Project:     Sererra 
 * Date:        February 11, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Contains methods to generate the queries for each object included in the integration package.
 *              Ex.: Intacct Error query
 * *************************************************************************
 * History:
 */
global class GenerateSFDCObjectQueries 
{

    private static final String ACCOUNT_ID_VARIABLE_NAME = 'accountIds';
    private static final String CONTACT_ID_VARIABLE_NAME = 'contactIds';
    private static final String OPPORTUNITY_ID_VARIABLE_NAME = 'opportunityIds';
    private static final String ACCOUNT_METHOD_LOG_ENTRY = 'GenerateSFDCObjectQueries.retrieveAccounts';
    private static final String CONTACT_METHOD_LOG_ENTRY = 'GenerateSFDCObjectQueries.retrieveContacts';
    private static final String OPPORTUNITY_METHOD_LOG_ENTRY = 'GenerateSFDCObjectQueries.retrieveOpportunities';
    
    /**
     * Generates the query for the intacct error object.
     * Used by the intacct error handling page.
     * @params actionType
     * @return intacctErrorQuery
    */
    public static String generateIntacctErrorQuery(String actionType)
    {
        String intacctErrorQuery = '';
        intacctErrorQuery = 'SELECT Name, SFDC_Id_Prefix_Text__c, Parent_Id__c, Description__c, Id, Errors__c, ' +
           ' CreatedDate FROM Intacct_Error__c';
        if(!String.isBlank(actionType))
        {
            if(actionType.equals(IntacctGlobalVariables.ACTION_TYPE_GROUP_BY))
            {
                intacctErrorQuery = 'SELECT Id FROM Intacct_Error__c LIMIT 1';
            }
            if(actionType.contains(IntacctGlobalVariables.ACTION_TYPE_PREFIX))
            {
                if(actionType.split(IntacctGlobalVariables.CONTROLID_SEPARATOR).size() > 1)
                {
                    system.debug('QUERY PART: ' + actionType.split(IntacctGlobalVariables.CONTROLID_SEPARATOR)[1]);
                    intacctErrorQuery += ' WHERE SFDC_Id_Prefix_Text__c=\'' + actionType.split(IntacctGlobalVariables.CONTROLID_SEPARATOR)[1] + '\' ';
                    intacctErrorQuery += ' ORDER BY CreatedDate DESC LIMIT 1000';
                }
                else
                {
                    intacctErrorQuery += ' WHERE SFDC_Id_Prefix_Text__c=\'\' ORDER BY CreatedDate DESC limit 1000';
                }
            }
            if(actionType.contains(IntacctGlobalVariables.ACTION_TYPE_DELETE))
            {
                if(actionType.split(IntacctGlobalVariables.CONTROLID_SEPARATOR).size() > 1)
                {
                    intacctErrorQuery += ' WHERE CreatedDate <= ' + actionType.split(IntacctGlobalVariables.CONTROLID_SEPARATOR)[1];
                }
                intacctErrorQuery += ' ORDER BY CreatedDate ASC LIMIT 50000';
            }
        }
        if(!intacctErrorQuery.toLowerCase().contains('limit'))
        {
            intacctErrorQuery += ' LIMIT 1000';
        }
        system.debug('QUERY: ' + intacctErrorQuery);
        return intacctErrorQuery;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014 
    * @description Query the account object 
    * @param accountIds Set of account ids to filter the query result
    * @return accounts List of account records
    */
    
    public static List<Account> retrieveAccounts(Set<Id> accountIds) {
        IntacctIntegrationLoggingHandler.pushEntry(ACCOUNT_METHOD_LOG_ENTRY);
        String query = buildAccountQueryString(ACCOUNT_ID_VARIABLE_NAME);
        List<Account> accounts;
        try
        {
            accounts = Database.query(query);
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            accounts = new List<Account>();
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
        return accounts;
    }
    
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014 
    * @description Generate a query string for the account object
    * @param idVariableName The name of the variable used to filter query results
    * @return queryString The query string for the account object
    */
    
    private static String buildAccountQueryString(String idVariableName) {
        String queryString = 'SELECT Id, RecurSoft__IntacctID__c, Name, RecurSoft__Intacct_Entity__r.Name, RecurSoft__Synced_With_Intacct__c, RecurSoft__Payment_Term__c, RecurSoft__Status__c, Phone, RecurSoft__Billing_Email__c, RecurSoft__Billing_Email_CC__c, RecurSoft__Default_Payment_Type__c, ' + //Verisign_Profile_ID__c ' +
            'BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, RecurSoft__Ready_to_sync_with_Intacct__c, RecurSoft__Intacct_Entity__r.Entity_root__c, ' +
            ' Parent.RecurSoft__IntacctID__c, Parent.RecurSoft__Synced_With_Intacct__c, Verisign_Profile_ID__c '  +
            'FROM Account';// WHERE Synced_With_Intacct__c = false';
        if(!String.isBlank(idVariableName)){
            queryString += ' WHERE Id IN :' + idVariableName;
        }
        return queryString;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014 
    * @description Query the account object 
    * @param contactIds Set of contact ids to filter the query result
    * @return contacts List of contact records
    */
    
    public static List<Contact> retrieveContacts(Set<Id> contactIds) {
        IntacctIntegrationLoggingHandler.pushEntry(CONTACT_METHOD_LOG_ENTRY);
        String query = buildContactQueryString(CONTACT_ID_VARIABLE_NAME);
        List<Contact> contacts;
        try
        {
            contacts = Database.query(query);
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            contacts = new List<Contact>();
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
        return contacts;
    }
    
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014 
    * @description Generate a query string for the contact object
    * @param idVariableName The name of the variable used to filter query results
    * @return queryString The query string for the contact object
    */
    
    private static String buildContactQueryString(String idVariableName) {
        String queryString = 'SELECT Id, FirstName, LastName, Salutation, Phone, MobilePhone, Fax, Email, Account.RecurSoft__Intacct_Entity__r.Name, Account.Name, Account.RecurSoft__IntacctID__c, RecurSoft__Synced_With_Intacct__c, RecurSoft__Intacct_Contact_ID__c, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,' +
            ' Account.RecurSoft__Intacct_Entity__r.Entity_root__c FROM Contact';//WHERE RecurSoft__Synced_With_Intacct__c = false';
        if(!String.isBlank(idVariableName)){
            queryString += ' WHERE Id IN :' + idVariableName;
        }
        return queryString;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014 
    * @description Query the account object 
    * @param contactIds Set of contact ids to filter the query result
    * @return contacts List of contact records
    */
    
    public static List<Opportunity> retrieveOpporutnities(Set<Id> opportunityIds) {
        IntacctIntegrationLoggingHandler.pushEntry(OPPORTUNITY_METHOD_LOG_ENTRY);
        String query = buildOpportunityQueryString(OPPORTUNITY_ID_VARIABLE_NAME);
        List<Opportunity> opportunities;
        try
        {
            opportunities = Database.query(query);
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            opportunities = new List<Opportunity>();
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
        return opportunities;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014 
    * @description Query the account object 
    * @param contactIds Set of contact ids to filter the query result
    * @return contacts List of contact records
    */
    
    public static List<Opportunity> retrieveScheduledOpps(String jobId) {
        IntacctIntegrationLoggingHandler.pushEntry(OPPORTUNITY_METHOD_LOG_ENTRY);
        List<Opportunity> opportunities;
        try
        {
            opportunities = [SELECT Id,Account.ParentId,AccountId,RecurSoft__Bill_to_Account__r.Id, StageName, Ok_to_Sync_to_Intacct__c, RecurSoft__Bill_to_Account__c, RecurSoft__Billing_Contact__c, 
                RecurSoft__Shipping_Contact__c,RecurSoft__Bill_to_Account__r.RecurSoft__IntacctID__c,RecurSoft__Bill_to_Account__r.RecurSoft__Synced_With_Intacct__c FROM Opportunity WHERE Ok_to_Sync_to_Intacct__c = :jobId];
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex)
        {
            opportunities = new List<Opportunity>();
            IntacctIntegrationLoggingHandler.debugException(ex);
            IntacctIntegrationLoggingHandler.popAll();
        }
        return opportunities;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014 
    * @description Generate a query string for the contact object
    * @param idVariableName The name of the variable used to filter query results
    * @return queryString The query string for the contact object
    */
    
    private static String buildOpportunityQueryString(String idVariableName) {
        String queryString = 'SELECT Id, RecurSoft__Bill_to_Account__c, RecurSoft__Billing_Contact__c, RecurSoft__Shipping_Contact__c, Contract_Signed__c, ' +
            'RecurSoft__Initial_Contract_Term__c, RecurSoft__Contract_Signed_Date__c, RecurSoft__Contract_Term_Start_Date1__c, RecurSoft__Intacct_Entity__c,' +
            'RecurSoft__Billing_Contact__r.RecurSoft__Intacct_Contact_ID__c, RecurSoft__Billing_Contact__r.RecurSoft__Synced_With_Intacct__c, RecurSoft__Bill_to_Account__r.RecurSoft__IntacctID__c,' +
            'RecurSoft__Bill_to_Account__r.RecurSoft__Synced_With_Intacct__c, Account.RecurSoft__Intacct_Entity__c, RecurSoft__Shipping_Contact__r.RecurSoft__Synced_With_Intacct__c,' +
            'RecurSoft__Shipping_Contact__r.RecurSoft__Intacct_Contact_ID__c, Account.RecurSoft__Channel__c, Account.Industry, RecurSoft__Contract_Term_Start_Date__c, RecurSoft__Count_Aggregated_Monthly_Min__c, Account.RecurSoft__No_of_Aggregated_Opp_Products__c, ' +
            ' RecurSoft__Bill_to_Account__r.Id, Account.ParentId, Account.RecurSoft__IntacctID__c, Account.RecurSoft__Synced_With_Intacct__c, StageName ' +
            ' FROM Opportunity';
        if(!String.isBlank(idVariableName)){
            queryString += ' WHERE Id IN :' + idVariableName;
        }
        return queryString;
    }
    
}