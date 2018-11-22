/**
 * File:        ContactSyncHandler.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        March 26, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description:  Contains methods to call to the query handler for the integration, the mapping handler and start the contact integration process.<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 * 06.06.14             Roman Bychko            Added validation of contacts sync
 */
public with sharing class ContactSyncHandler 
{
    
    private static final String CONTACT_INTEGRATION_LOG_ENTRY = 'ContactSyncHandler.startContactIntegration';
    private static final String CONTACT_INTEGRATION_VALIDATE_CONTACT_LOG_ENTRY = 'ContactSyncHandler.validateContact';
    private static final String BILL_TO_PREFIX = 'B';
    private static final String SHIP_TO_PREFIX = 'S';
    private static final String UNDERSCORE_CHARACTER = '_';
    private static final String INVALID_CONTACT_PAGE_MESSAGE = '<br />The contact is not ready to be synchronized. <br /> Reasons :';
    private static final String INVALID_SYNCED_WITH_INTACCT_ERROR = '<br />&nbsp;&nbsp;Synced With Intacct is checked.';
    private static final String INVALID_NAME_ERROR = '<br />&nbsp;&nbsp;FirstName/LastName is wrong.';
    private List<Contact> sfdcContacts;
    private List<Object> intacctContacts;
    private IntacctIntegrationMappingsHandler mappingController;
    public boolean isValid;
    public Boolean isOpportunityAction;
    public String errorMessage;
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Constructor
    */
    public ContactSyncHandler()
    {
        init();
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Start the customer integration
    */
    public void startContactIntegration(Map<Id, Id> billToContacts, Map<Id, Id> shipToContacts)
    {
        IntacctIntegrationLoggingHandler.pushEntry(CONTACT_INTEGRATION_LOG_ENTRY);
        try
        {
            Set<Id> contactIds = constructContactIdList(billToContacts.keySet(), shipToContacts.keySet());
            sfdcContacts = GenerateSFDCObjectQueries.retrieveContacts(contactIds);
            validateContact(sfdcContacts);
            if(isValid){
                addContactIntacctIds(billToContacts, shipToContacts);
                intacctContacts = mappingController.mapContactsToContacts(sfdcContacts);
                
                IntacctSyncObjects.upsertObjects(intacctContacts, true);
            }
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
    * @date March 26, 2014
    * @description Initialize variable and controller state
    */
    private void init()
    {
        sfdcContacts = new List<Contact>();
        intacctContacts = new List<Object>();
        mappingController = new IntacctIntegrationMappingsHandler();
        isValid = true;
        errorMessage = '';
    }
    /**
    * @author Roman Bychko
    * @date June 06, 2014
    * @description Check if the contact is ready to sync
    * @param currentContacts The contacts that are being processed
    */
    private void validateContact(List<Contact> currentContacts) 
    {
        IntacctIntegrationLoggingHandler.pushEntry(CONTACT_INTEGRATION_VALIDATE_CONTACT_LOG_ENTRY);
        try
        {
            for(Contact tempContact :currentContacts)
            {
                String tmpError = '';
                if(String.isBlank(tempContact.LastName) && String.isBlank(tempContact.FirstName))
                {
                    this.isValid = false;
                    tmpError+= INVALID_NAME_ERROR;
                }
                if(!isValid){
                    this.errorMessage = INVALID_CONTACT_PAGE_MESSAGE+tmpError;
                    break;
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
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Merge the bill to and ship to contact ids into one list
    * @param billToContactIds Set of bill to contact ids
    * @param shipToContactIds Set of ship to contact ids
    * @return allContactIds All the ids from the bill to and ship to contacts put together
    */
    private Set<Id> constructContactIdList(Set<Id> billToContactIds, Set<Id> shipToContactIds)
    {
        Set<Id> allContactIds = new Set<Id>();
        allContactIds.addAll(billToContactIds);
        allContactIds.addAll(shipToContactIds);
        return allContactIds;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Add the contact intacct id to the contact records
    */
    private void addContactIntacctIds(Map<Id, Id> billToContacts, Map<Id, Id> shipToContacts)
    {
        String currentPrefix = '';
        Id currentAccountId;
        Account currentAccount;
        for(Contact tempContact :sfdcContacts)
        {
            if(String.isBlank(tempContact.RecurSoft__Intacct_Contact_ID__c))
            {
                currentPrefix = addBillToPrefix(tempContact.Id, billToContacts);
                currentAccountId = retrieveBillToAccountId(tempContact.Id, billToContacts);
                if(String.isBlank(currentPrefix))
                {
                    currentPrefix = addShipToPrefix(tempContact.Id, shipToContacts);
                    currentAccountId = retrieveShipToAccountId(tempContact.Id, shipToContacts);
                }
                currentAccount = IntacctIntegrationSyncHandler.accountsWithCustomerId.get(currentAccountId);
                tempContact.RecurSoft__Intacct_Contact_ID__c = currentPrefix + UNDERSCORE_CHARACTER + currentAccount.RecurSoft__IntacctID__c + UNDERSCORE_CHARACTER + tempContact.Id;
            }
            IntacctIntegrationSyncHandler.contactsWithIntacctId.put(tempContact.Id, tempContact);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Set the prefix to bill to if the contact is a bill to contact
    * @param currentContactId The current contact id
    * @param billToContacts The map with the bill to contacts
    * @return prefix The value for the contact intacct id prefix
    */
    private String addBillToPrefix(Id currentContactId, Map<Id, Id> billToContacts)
    {
        String prefix = '';
        if(billToContacts.containsKey(currentContactId))
        {
            prefix = BILL_TO_PREFIX;
        }
        return prefix;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Set the prefix to ship to if the contact is a ship to contact
    * @param currentContactId The current contact id
    * @param billToContacts The map with the ship to contacts
    * @return prefix The value for the contact intacct id prefix
    */
    private String addShipToPrefix(Id currentContactId, Map<Id, Id> shipToContacts)
    {
        String prefix = '';
        if(shipToContacts.containsKey(currentContactId))
        {
            prefix = SHIP_TO_PREFIX;
        }
        return prefix;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 31, 2014
    * @description Retrieve the account id related to the bill to contact
    * @param currentContactId The current contact id
    * @param billToContacts The map with the bill to contacts
    * @return accountId The value for the account id
    */
    private Id retrieveBillToAccountId(Id currentContactId, Map<Id, Id> billToContacts)
    {
        Id accountId;
        if(billToContacts.containsKey(currentContactId))
        {
            accountId = billToContacts.get(currentContactId);
        }
        return accountId;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 31, 2014
    * @description Retrieve the account id related to the ship to contact
    * @param currentContactId The current contact id
    * @param shipToContacts The map with the ship to contacts
    * @return accountId The value for the account id
    */
    private Id retrieveShipToAccountId(Id currentContactId, Map<Id, Id> shipToContacts)
    {
        Id accountId;
        if(shipToContacts.containsKey(currentContactId))
        {
            accountId = shipToContacts.get(currentContactId);
        }
        return accountId;
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