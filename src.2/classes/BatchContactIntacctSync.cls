global without sharing class BatchContactIntacctSync implements Database.Batchable<sObject>, Database.AllowsCallouts
{
	private static final String INTACCT_INTEGRATION_CONSTRUCTOR_LOG_ENTRY = 'IntacctIntegrationContactToContact.IntacctIntegrationContactToContact';
    private static final String INTACCT_INTEGRATION_SYNC_CONTACT_LOG_ENTRY = 'IntacctIntegrationContactToContact.syncContact';
    private static final String INTACCT_INTEGRATION_ADD_CONTACT_ID_LOG_ENTRY = 'IntacctIntegrationContactToContact.addContactIntacctIds';
    private static final String INTACCT_INTEGRATION_VALIDATE_CONTACT_LOG_ENTRY = 'IntacctIntegrationContactToContact.validateContact';
    
    public static final String INVALID_CONTACT_PAGE_MESSAGE = '<br />The contact is not ready to be synchronized. <br /> Reasons :';
    public static final String INVALID_SYNCED_WITH_INTACCT_ERROR = '<br />&nbsp;&nbsp;Synced With Intacct is checked.';
    public static final String INVALID_NAME_ERROR = '<br />&nbsp;&nbsp;FirstName/LastName is wrong.';
    private static final String ACCOUNT_ID_MISSING_PAGE_MESSAGE = 'You first need to sync the associated account.';
    private static final String RECORD_PROCESSED_PAGE_MESSAGE = 'The record was processed.';
    private static final String RECORD_FAILED_PAGE_MESSAGE = 'The record processing has failed.<br /> Please check errors : <a target="_BLANK" href="/apex/IntacctErrorHandling">Errors page</a>';
    
    
    private static final String CONTACT_INTACCT_ID_PREFIX = 'B';
    private static final String UNDERSCORE_CHARACTER = '_';
    
    private Set<Id> contactIds;
    private Boolean isValid;
    private List<Contact> sfdcContacts;
    private List<Object> intacctContacts;
    private IntacctIntegrationMappingsHandler mappingController;
    public static Map<Id, Contact> contactsWithIntacctId;

	public BatchContactIntacctSync()
	{

	}

	public BatchContactIntacctSync(Set<Id> ids) 
	{
		IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_CONSTRUCTOR_LOG_ENTRY);
        try
        {
            init();
            contactIds.addAll(ids);
            sfdcContacts = GenerateSFDCObjectQueries.retrieveContacts(contactIds);
            validateContact(sfdcContacts);
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
    * @description Start the contact sync
    */
    public void syncContact()
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_SYNC_CONTACT_LOG_ENTRY);
        try
        {
            if(isValid)
            {
                addContactIntacctIds();
                intacctContacts = mappingController.mapContactsToContacts(sfdcContacts);
                IntacctSyncObjects.upsertObjects(intacctContacts, true);
                if(recheckContacts()){
                    System.debug(RECORD_PROCESSED_PAGE_MESSAGE);
                }else{
                    System.debug(RECORD_FAILED_PAGE_MESSAGE);
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
    * @date May 15, 2014
    * @description Initialize controller state and variables
    */
    private void init() 
    {
        contactIds = new Set<Id>();
        sfdcContacts = new List<Contact>();
        intacctContacts = new List<Object>();
        mappingController = new IntacctIntegrationMappingsHandler();
        isValid = true;
        contactsWithIntacctId = new Map<Id, Contact>();
    }
    
    /**
    * @author Roman Bychko
    * @date June 12, 2014
    * @description check if RecurSoft__Synced_With_Intacct__c is checked or not
    * @return boolean
    */
    private Boolean recheckContacts() 
    {
        Boolean isOk = true;
        List<Contact> contactsToCheck = GenerateSFDCObjectQueries.retrieveContacts(contactIds);
        for(Contact con : contactsToCheck){
            if(!con.RecurSoft__Synced_With_Intacct__c){
                isOk = false;
            }
        }
        return isOk;
    }
    /**
    * @author Roman Bychko
    * @date June 05, 2014
    * @description Check if the contact is ready to sync
    * @param currentContacts The contacts that are being processed
    */
    private void validateContact(List<Contact> currentContacts) 
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_VALIDATE_CONTACT_LOG_ENTRY);
        try
        {
            for(Contact tempContact :currentContacts)
            {
                String error = '';
                if(tempContact.RecurSoft__Synced_With_Intacct__c)
                {
                    isValid = false;
                    error+= INVALID_SYNCED_WITH_INTACCT_ERROR;
                }
                if(String.isBlank(tempContact.LastName) && String.isBlank(tempContact.FirstName))
                {
                    isValid = false;
                    error+= INVALID_NAME_ERROR;
                }
                if(!isValid){
                    System.debug(INVALID_CONTACT_PAGE_MESSAGE+error);
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
    * @date May 15, 2014
    * @description Look at the related account and construct the intacct contact id
    */
    private void addContactIntacctIds() 
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_ADD_CONTACT_ID_LOG_ENTRY);
        try
        {
            List<Contact> tempList = new List<Contact>();
            tempList.addAll(sfdcContacts);
            sfdcContacts.clear();
            for(Integer i = 0; i < tempList.size(); i++)
            {
                if(String.isBlank(tempList[i].Account.RecurSoft__IntacctID__c))
                {
                    System.debug(ACCOUNT_ID_MISSING_PAGE_MESSAGE);
                }
                else
                {
                    tempList[i].RecurSoft__Intacct_Contact_ID__c = CONTACT_INTACCT_ID_PREFIX + UNDERSCORE_CHARACTER + tempList[i].Account.RecurSoft__IntacctID__c + UNDERSCORE_CHARACTER + tempList[i].Id;
                    sfdcContacts.add(tempList[i]);
                    IntacctIntegrationContactToContact.contactsWithIntacctId = new Map<Id, Contact>();
                    IntacctIntegrationContactToContact.contactsWithIntacctId.put(tempList[i].Id, tempList[i]);
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
    
    SR_Default_Values__c defaultValues = SR_Default_Values__c.getValues('BatchQueryString');

    global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(defaultValues.Value__c);
	}

	global void execute(Database.BatchableContext BC, List<Contact> scope) 
	{
		for(Contact c : scope)
		{
			Set<Id> ids = new Set<Id>{c.Id};

			BatchContactIntacctSync contactSync = new BatchContactIntacctSync(ids);
			contactSync.syncContact();
		}
	}
			
	global void finish(Database.BatchableContext BC) 
	{

	}
}