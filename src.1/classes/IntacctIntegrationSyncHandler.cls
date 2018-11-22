/**
 * File:        IntacctIntegrationSyncHandler.cls
 * Project:     Sererra - Subscription Billing
 * Date:        March 26, 2014
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description:  Contains methods for dispatching the integration to the correct controller, exclude the data that does not match the filter criteria.
 * *************************************************************************
 * History:
 * Date:                Modified By:            Description:
 * 06.06.14             Roman Bychko            Added validation of account and contact sync
 */
public without sharing class IntacctIntegrationSyncHandler 
{
    private static final String INTACCT_INTEGRATION_START_LOG_ENTRY = 'IntacctIntegrationSyncHandler.startIntegration';
    private static final String INTACCT_INTEGRATION_UPDATE1_LOG_ENTRY = 'IntacctIntegrationSyncHandler.updateCustomSetting';
    private static final String INTACCT_INTEGRATION_UPDATE2_LOG_ENTRY = 'IntacctIntegrationSyncHandler.updateOpportunities';
    private static final String CONFIGURATION_SETTINGS_ENABLE_RESELLER_PROCESS = 'Reseller Process';
    private static final String LOG_ENTRY_CHECK_ENABLE_RESELLER_PROCESS = 'IntacctIntegrationSyncHandler.checkEnableResellerProcessSetting';
    private static final String LAST_CUSTOMER_ID_SETTING_NAME = 'Last Customer Id';
    public static final String INVALID_CONTACT_PAGE_MESSAGE = '<br />The opportunity is not ready to be closed. <br /> Reasons :';
    private static final String RECORDS_PROCESSED = 'The records were processed!';
    private static final String STAGE_CLOSED_WON = 'Closed Won';
    private static final String STAGE_CLOSED_WON_NON_BILLING = 'Closed Won - Non-Billing';
    private static final String OPPORTUNITY_CLOSED_WON_ENTRY_NAME = 'Opportunity Closed Won Stage Name';
    private static final String SEMICOLON_SEPARATOR = ';';
    public static Map<String, Set<ID>> intacctResponseAndObjectIds;
    public static Map<String, Set<Id>> intacctResponseAndObjectIdsContact;
    public static Map<Id, Account> accountsWithCustomerId;
    public static Map<Id, Contact> contactsWithIntacctId;
    /** The ids of the records that failed to sync*/
    public static Set<Id> failedIds;    
    
    private Set<Id> billToAccountIds;
    private Map<Id, Id> billToContactIds;
    private Map<Id, Id> shipToContactIds;
    private Map<String, Opportunity> syncIdsWithOpporunities;
    public Set<Id> filteredOpportunities;
    private CustomerSyncHandler customerIntegration;
    private ContactSyncHandler contactIntegration;
    private IntacctResponses intacctResponse;
    private Boolean isVisualforce;
    private String executionContext;
    private String scheduledJobId;
    private String pageMessage;
    private Boolean isWon = false;
    public static Boolean closeOpp = false;
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Constructor
    */
    public IntacctIntegrationSyncHandler(String jobId)
    {
        init();
        scheduledJobId = jobId.substring(0, 15);
        executionContext = 'scheduled';
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Constructor
    */
    /*
    public IntacctIntegrationSyncHandler(Set<Id> opportunities)
    {
        init();
        filteredOpportunities = opportunities;
        executionContext = 'future';
    }
    */
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Constructor
    * @param newMap The trigger opportunities with the new values
    * @param oldMap The trigger opportunities with the old values
    */
    /*
    public IntacctIntegrationSyncHandler(Map<Id, Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap)
    {
        init();
        filteredOpportunities = filterOpportunities(newOpportunityMap, oldOpportunityMap);
        executionContext = 'schedule';
    }
    */
    
    /**
    * @author Ionut Boghean
    * @date April 11, 2014
    * @description Constructor
    * @param controller The standard controller used for visualforce custom controllers
    */
    public IntacctIntegrationSyncHandler(ApexPages.StandardController controller) 
    {
        init();
        filteredOpportunities.add(controller.getId());
        isVisualforce = true;
        customerIntegration.isOpportunityAction = true;
        contactIntegration.isOpportunityAction = true;
        executionContext = 'visualforce';
    }

    public IntacctIntegrationSyncHandler(Id opportunityId) 
    {
        init();
        filteredOpportunities.add(opportunityId);
        isVisualforce = false;
        customerIntegration.isOpportunityAction = true;
        contactIntegration.isOpportunityAction = true;
        executionContext = 'scheduled';
    }

    public IntacctIntegrationSyncHandler(Set<Id> opportunityIds) 
    {
        init();
        filteredOpportunities = opportunityIds;
        isVisualforce = false;
        customerIntegration.isOpportunityAction = true;
        contactIntegration.isOpportunityAction = true;
        executionContext = 'scheduled';
    }

    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Start the intacct integration asynchronously 
    *//*
    @future (callout=true)
    public static void startAsynchronousIntegration(Set<Id> opportunities)
    {
        IntacctIntegrationSyncHandler intacctIntegration = new IntacctIntegrationSyncHandler(opportunities);
        intacctIntegration.startIntegration();
    }*/
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Start the intacct integration asynchronously 
    */
    @future (callout=true)
    public static void startAsynchronousIntegration(String jobId)
    {IntacctIntegrationSyncHandler intacctIntegration = new IntacctIntegrationSyncHandler(jobId);intacctIntegration.startIntegration();}
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Forward the account and contact id lists to the coresponding handlers.
    */
    public void startIntegration()
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_START_LOG_ENTRY);
        try
        {
            List<Opportunity> opportunityData;
            System.debug('JOB ID: ' + scheduledJobId);
            if(executionContext.equals('scheduled'))
            {
                opportunityData = GenerateSFDCObjectQueries.retrieveScheduledOpps(scheduledJobId);
            }
            else
            {
                opportunityData = GenerateSFDCObjectQueries.retrieveOpporutnities(filteredOpportunities);
            }
            if(checkEnableResellerProcessSetting()){
                opportunityData = validateOpportunityForResellerProcess(opportunityData);
            }
            for(Opportunity opp : opportunityData){
                if(opp.StageName == STAGE_CLOSED_WON && isVisualforce){ isWon = true;}
            }
            if(!isWon){
            populateIntegrationIds(opportunityData);
            //start customer sync handler
            customerIntegration.startCustomerIntegration(billToAccountIds, false);
            System.debug('CUSTOMER IDs: ' + accountsWithCustomerId);
            if(customerIntegration.isValid){
                //start contact sync hanler
                contactIntegration.startContactIntegration(billToContactIds, shipToContactIds);
                if(contactIntegration.isValid){
                    //update accounts
                    updateAccounts();
                    //update custom setting
                    if(!System.Test.isRunningTest()){
                        updateCustomSetting();
                    }
                    //update opportunities
                    updateOpportunities();
                    //addSuccessMessage();
                    //add a success message on the page if this is executed in a visualforce context
                }else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, contactIntegration.errorMessage));}
            }else{ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, customerIntegration.errorMessage));}
            }else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This opportunity has already been closed.'));}
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex) {IntacctIntegrationLoggingHandler.debugException(ex);IntacctIntegrationLoggingHandler.popAll();}
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Initialize variable and controller state
    */
    private void init()
    {
        executionContext = '';
        scheduledJobId = '';
        billToAccountIds = new Set<Id>();
        billToContactIds = new Map<Id, Id>();
        shipToContactIds = new Map<Id, Id>();
        filteredOpportunities = new Set<Id>();
        intacctResponseAndObjectIds = new Map<String, Set<ID>>();
        intacctResponseAndObjectIdsContact = new Map<String, Set<ID>>();
        failedIds = new Set<Id>();
        customerIntegration = new CustomerSyncHandler();
        contactIntegration = new ContactSyncHandler();
        intacctResponse = new IntacctResponses();
        accountsWithCustomerId = new Map<Id, Account>();
        contactsWithIntacctId = new Map<Id, Contact>();        
        syncIdsWithOpporunities = new Map<String, Opportunity>();
        isVisualforce = false;
        pageMessage = '';
    } 
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Initialize variable and controller state
    * @param newMap The trigger opportunities with the new values
    * @param oldMap The trigger opportunities with the old values
    * @return filteredOpportunities The opportunities ids that matched the filter criteria for the intacct integration
    */
    /*
    private Set<Id> filterOpportunities(Map<Id, Opportunity> newOpportunityMap, Map<Id, Opportunity> oldOpportunityMap)
    {
        Set<Id> filteredOpportunitiesIds = new Set<Id>();
        Opportunity newOpportunity;
        Opportunity oldOpportunity;
        for(Id opportunityId :newOpportunityMap.keySet())
        {
            newOpportunity = newOpportunityMap.get(opportunityId);
            oldOpportunity = oldOpportunityMap.get(opportunityId);
            if(newOpportunity.Contract_Signed__c && !oldOpportunity.Contract_Signed__c)
            {
                filteredOpportunitiesIds.add(opportunityId);
            }
        }
        return filteredOpportunitiesIds;
    }
    */
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Populate the account and contact id lists used by the integration
    */
    private void populateIntegrationIds(List<Opportunity> opportunities)
    {
        String opporunityKey = '';
        for(Opportunity temporaryOpportunity :opportunities)
        {
            billToAccountIds.add(temporaryOpportunity.RecurSoft__Bill_to_Account__c);
            if(checkEnableResellerProcessSetting())
            {
                billToAccountIds.add(temporaryOpportunity.AccountId);
            }
            accountsWithCustomerId.put(temporaryOpportunity.RecurSoft__Bill_to_Account__c, new Account());
            if(checkEnableResellerProcessSetting())
            {
                accountsWithCustomerId.put(temporaryOpportunity.AccountId, new Account());
            }
            billToContactIds.put(temporaryOpportunity.RecurSoft__Billing_Contact__c, temporaryOpportunity.RecurSoft__Bill_to_Account__c);
            shipToContactIds.put(temporaryOpportunity.RecurSoft__Shipping_Contact__c, temporaryOpportunity.RecurSoft__Bill_to_Account__c);
            opporunityKey = String.valueOf(temporaryOpportunity.Id) + SEMICOLON_SEPARATOR + String.valueOf(temporaryOpportunity.RecurSoft__Bill_to_Account__c) + SEMICOLON_SEPARATOR + String.valueOf(temporaryOpportunity.RecurSoft__Billing_Contact__c) + SEMICOLON_SEPARATOR + String.valueOf(temporaryOpportunity.RecurSoft__Shipping_Contact__c);
            syncIdsWithOpporunities.put(opporunityKey, temporaryOpportunity);
            filteredOpportunities.add(temporaryOpportunity.Id);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Update the accounts after the integration is complete
    */
    private void updateAccounts()
    {
        Set<String> getActionResultDocumentSet = IntacctIntegrationSyncHandler.intacctResponseAndObjectIds.keySet();
        List<Set<ID>> objectsToUpdate = IntacctIntegrationSyncHandler.intacctResponseAndObjectIds.values();
        for(String getActionResultDocument :getActionResultDocumentSet)
        {
            DOM.Document getActionResultDocumentDom = new DOM.Document();
            getActionResultDocumentDom.load(getActionResultDocument);
            processDomDocument(getActionResultDocumentDom, objectsToUpdate);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Process a dom document: parse errors and call the update method
    * @param domDocument The intacct response
    * @param objectsToUpdate The list of objects that need to be updated
    */
    private void processDomDocument(DOM.Document domDocument, List<Set<ID>> objectsToUpdate)
    {
        Map<Id, Boolean> errorRecordsId;
        for(Set<ID> objectIds :objectsToUpdate)
        {
            errorRecordsId = intacctResponse.ParseErrors(domDocument, objectIds, true);
            IntacctSyncObjects.updateSObjectsMask(objectIds, errorRecordsId);
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date March 26, 2014
    * @description Update the last customer id used
    */
    private void updateCustomSetting(){
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_UPDATE1_LOG_ENTRY);
        try{
            Intacct_Ids__c lastCustomerId = Intacct_Ids__c.getValues(LAST_CUSTOMER_ID_SETTING_NAME);
            List<Account> customerIds = IntacctIntegrationSyncHandler.accountsWithCustomerId.values();
            Account lastAccount = customerIds.get(customerIds.size() - 1);
            if(!String.isBlank(lastAccount.RecurSoft__IntacctID__c) && Integer.valueOf(lastAccount.RecurSoft__IntacctID__c) > Integer.valueOf(lastCustomerId.Id_Value__c))
            {lastCustomerId.Id_Value__c = lastAccount.RecurSoft__IntacctID__c;update lastCustomerId;}
            IntacctIntegrationLoggingHandler.popEntry();
        }catch(Exception ex){IntacctIntegrationLoggingHandler.debugException(ex);IntacctIntegrationLoggingHandler.popAll();}
    }
    
    /**
    * @author Ionut Boghean
    * @date April 11, 2014
    * @description Update the opportunities to closed won stage
    */
    private void updateOpportunities()
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_UPDATE2_LOG_ENTRY);
        List<Opportunity> updatedOpportunities;
        List<Opportunity> opportunitiesValuesAfterSync;
        RecurSoft__Default_Values__c stageNameDefaultValue = RecurSoft__Default_Values__c.getValues(OPPORTUNITY_CLOSED_WON_ENTRY_NAME);
        //Boolean isInList;
        Boolean isValid;
        //Opportunity tempOpportunity;
        
        try{
            updatedOpportunities = new List<Opportunity>();
            opportunitiesValuesAfterSync = GenerateSFDCObjectQueries.retrieveOpporutnities(filteredOpportunities);
            //for(String tempOpportunityId :syncIdsWithOpporunities.keySet())
            for(Opportunity tempOpportunity :opportunitiesValuesAfterSync)
            {
                isValid = validateOpportunity(tempOpportunity);
                //isInList = searchId(tempOpportunityId);
                //if(!isInList)
                if(isValid)
                {
                    //tempOpportunity = new Opportunity(Id = syncIdsWithOpporunities.get(tempOpportunityId).Id);
                    tempOpportunity.StageName = stageNameDefaultValue.RecurSoft__Value__c;
                    //tempOpportunity.Ok_to_Sync_to_Intacct__c = '';
                    updatedOpportunities.add(tempOpportunity);
                }
                else
                {
                    if(isVisualforce)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, INVALID_CONTACT_PAGE_MESSAGE + pageMessage));
                    }
                }
            }
            if(!updatedOpportunities.isEmpty())
            {update updatedOpportunities;addSuccessMessage();}
            IntacctIntegrationLoggingHandler.popEntry();
        }
        catch(Exception ex) {IntacctIntegrationLoggingHandler.debugException(ex);IntacctIntegrationLoggingHandler.popAll();}
    }
    
    /**
    * @author Ionut Boghean
    * @date April 11, 2014
    * @description Search the id in the failed ids set
    * @param cuurentId
    * @return isInList
    
    private Boolean searchId(String currentId)
    {
        Boolean isInList = false;
        for(Id tempId :failedIds)
        {
            isInList = false;
            if(currentId.contains(String.valueOf(tempId)))
            {
                isInList = true;
                return isInList;
            }
        }
        return isInList;
    }
    */
    /**
    * @author Ionut Boghean
    * @date June 11, 2014
    * @description Validate all the information required for an opportunity to be closed won
    * @param cuurentId
    * @return isValid
    */
    private Boolean validateOpportunity(Opportunity opportunityValuesAfterSync)
    {
        Boolean isValid = true;
        //pageMessage
        //should be split into several methods
        //it was implemented fast so the client could test
        if(opportunityValuesAfterSync.RecurSoft__Bill_to_Account__c == null){pageMessage += '<br />&nbsp;&nbsp;"Bill to Account" is not populated.';isValid = false;}
        else
        {
            if(opportunityValuesAfterSync.RecurSoft__Bill_to_Account__r.RecurSoft__IntacctID__c == null){pageMessage += '<br />&nbsp;&nbsp;"Bill to Account" does not have an Intacct Customer Id.';isValid = false;}
            if(!opportunityValuesAfterSync.RecurSoft__Bill_to_Account__r.RecurSoft__Synced_With_Intacct__c)
            {
                pageMessage += '<br />&nbsp;&nbsp;"Bill to Account" is not synchronized with Intacct.';
                isValid = false;
            }
        }
        if(opportunityValuesAfterSync.RecurSoft__Billing_Contact__c == null){ pageMessage += '<br />&nbsp;&nbsp;"Bill to Contact" is not populated.';isValid = false;}
        else
        {
            if(opportunityValuesAfterSync.RecurSoft__Billing_Contact__r.RecurSoft__Intacct_Contact_ID__c == null){pageMessage += '<br />&nbsp;&nbsp;"Bill to Contact" does not have an Intacct Contact Id.';isValid = false;}
            if(!opportunityValuesAfterSync.RecurSoft__Billing_Contact__r.RecurSoft__Synced_With_Intacct__c)
            {
                pageMessage += '<br />&nbsp;&nbsp;"Bill to Contact" is not synchronized with Intacct.';
                isValid = false;
            }
        }
        if(opportunityValuesAfterSync.RecurSoft__Shipping_Contact__c == null){pageMessage += '<br />&nbsp;&nbsp;"Ship to Contact" is not populated.';isValid = false;}
        else
        {
            if(opportunityValuesAfterSync.RecurSoft__Shipping_Contact__r.RecurSoft__Intacct_Contact_ID__c == null)
            {
                pageMessage += '<br />&nbsp;&nbsp;"Ship to Contact" does not have an Intacct Contact Id.';
                isValid = false;
            }
            if(!opportunityValuesAfterSync.RecurSoft__Shipping_Contact__r.RecurSoft__Synced_With_Intacct__c)
            {
                pageMessage += '<br />&nbsp;&nbsp;"Ship to Contact" is not synchronized with Intacct.';
                isValid = false;
            }
        }
        if(opportunityValuesAfterSync.Account != null)
        {
            if(opportunityValuesAfterSync.Account.RecurSoft__Intacct_Entity__c == null){pageMessage += '<br />&nbsp;&nbsp;"Account->Intacct Entity" is not populated.';isValid = false;}
            /*if(String.isBlank(opportunityValuesAfterSync.Account.RecurSoft__Channel__c))
            {
                pageMessage += '<br />&nbsp;&nbsp;"Account->Channel" is not populated.';
                isValid = false;
            }
            if(String.isBlank(opportunityValuesAfterSync.Account.Industry))
            {
                pageMessage += '<br />&nbsp;&nbsp;"Account->Industry" is not populated.';
                isValid = false;
            }*/
        }
        if(opportunityValuesAfterSync.RecurSoft__Intacct_Entity__c == null){pageMessage += '<br />&nbsp;&nbsp;"Intacct Entity" is not populated.';isValid = false;}
        if(opportunityValuesAfterSync.RecurSoft__Initial_Contract_Term__c == null){pageMessage += '<br />&nbsp;&nbsp;"Contract Term (Months)" is not populated.';isValid = false;}
        if(opportunityValuesAfterSync.RecurSoft__Contract_Signed_Date__c == null){pageMessage += '<br />&nbsp;&nbsp;"Contract Signed Date" is not populated.';isValid = false;}
        if(opportunityValuesAfterSync.RecurSoft__Contract_Term_Start_Date__c == null)
        {pageMessage += '<br />&nbsp;&nbsp;"Contract Term Start Date" is not populated.';isValid = false;}
        /*if(opportunityValuesAfterSync.RecurSoft__Count_Aggregated_Monthly_Min__c > 1 
            || opportunityValuesAfterSync.Account.RecurSoft__No_of_Aggregated_Opp_Products__c > 0
        )
        {
            pageMessage += '<br />&nbsp;&nbsp;Count Aggregated Monthly Min must not be greater than 1 and No of Aggregated Opp Products per Account must not be greater than 1.';
            isValid = false;
        }*/
        if(checkEnableResellerProcessSetting()){
            if(checkRelationshipBetweenAccounts(opportunityValuesAfterSync)){
                if(opportunityValuesAfterSync.Account.ParentId == null){pageMessage += '<br />&nbsp;&nbsp;"Account.Parent Account" is not populated.';isValid = false;}
                if(!checkParentRelationship(opportunityValuesAfterSync)){pageMessage += '<br />&nbsp;&nbsp; Missing relationship between the Account and Bill to Account. ';isValid = false;}
                if(
                //opportunityValuesAfterSync.Account.RecurSoft__IntacctID__c == NULL || !opportunityValuesAfterSync.Account.RecurSoft__Synced_With_Intacct__c 
                    //||
                     opportunityValuesAfterSync.RecurSoft__Bill_to_Account__r.RecurSoft__IntacctID__c== null || !opportunityValuesAfterSync.RecurSoft__Bill_to_Account__r.RecurSoft__Synced_With_Intacct__c){
                    pageMessage += '<br />&nbsp;&nbsp; Parent Account is required to be sync before "Closed Won" opportunity.';
                    isValid = false;
                }
            }
        }
        if(isValid == false) {
            pageMessage += '<br /><br />&nbsp;Please check errors: <a target="_BLANK" href="/apex/IntacctErrorHandling">Errors page</a>';
        }
        return isValid;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 11, 2014
    * @description Add a success message on the visualforce page
    */
    private void addSuccessMessage()
    {
        if(isVisualforce) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'This opportunity has been successfully closed-won.'));}
    }
    
    
    /**
    * @author Daniel Savu
    * @date December 21, 2015  
    * @description Check the 'Reseller process' setting from the configuration settings
    * @return isEnabled Flag to control the package usage
    */
    public static Boolean checkEnableResellerProcessSetting()
    {
        IntacctIntegrationLoggingHandler.pushEntry(LOG_ENTRY_CHECK_ENABLE_RESELLER_PROCESS);
        Boolean isEnabled = false;
        try 
        {
            RecurSoft__TempConfigurationSettings__c enableResselerProcess = RecurSoft__TempConfigurationSettings__c.getValues(CONFIGURATION_SETTINGS_ENABLE_RESELLER_PROCESS);
            if(enableResselerProcess != null && enableResselerProcess.RecurSoft__Is_Active__c)
            {
                isEnabled = true;
            }
            IntacctIntegrationLoggingHandler.popEntry();
        }catch(Exception ex){IntacctIntegrationLoggingHandler.debugException(ex);IntacctIntegrationLoggingHandler.popAll();}
        return isEnabled;
    }
    
    /**
    * @author Daniel Savu
    * @date December 21, 2015  
    * @description method to check if account id and bill to account id are different
    * @param oppToValidate opportunity to check
    * @return checkRelationship- true if are different 
    */
    private Boolean checkRelationshipBetweenAccounts(Opportunity oppToValidate){
        Boolean checkRelationship = false;
        if(oppToValidate.AccountId != oppToValidate.RecurSoft__Bill_to_Account__r.Id ){
            checkRelationship = true;
        }
        return checkRelationship;
    }
    
    /**
    * @author Daniel Savu
    * @date December 21, 2015  
    * @description method to check if bill to account is parent for account
    * @param oppToValidate opportunity to check
    * @return checkParent- true if is parent 
    */
    private Boolean checkParentRelationship(Opportunity oppToValidate){
        Boolean checkParent = false;
        if(oppToValidate.Account.ParentId == oppToValidate.RecurSoft__Bill_to_Account__r.Id){
            checkParent = true;
        }
        return checkParent;
    }
    
    private List<Opportunity> validateOpportunityForResellerProcess(List<Opportunity> oppList){
        List<Opportunity> validOpportunites = new List<Opportunity>();
        Boolean isValid;
        for(Opportunity opp: oppList){
            isValid = true;
            if(checkRelationshipBetweenAccounts(opp)){
                if(opp.Account.ParentId == null){isValid = false; }
                if(!checkParentRelationship(opp)){isValid = false;}
                if(//opp.Account.RecurSoft__IntacctID__c == NULL || !opp.Account.RecurSoft__Synced_With_Intacct__c 
                    //|| 
                    opp.RecurSoft__Bill_to_Account__r.RecurSoft__IntacctID__c== null || !opp.RecurSoft__Bill_to_Account__r.RecurSoft__Synced_With_Intacct__c){
                    isValid = false;
                }
                if(isValid){validOpportunites.add(opp);}
            }else{validOpportunites.add(opp);}
        }
        return validOpportunites;
    }

    @future(callout=true)
    public static void syncWithIntacctAndClose(Set<Id> ids)
    {
        IntacctIntegrationSyncHandler intacctSyncHandler = new IntacctIntegrationSyncHandler(ids);
        intacctSyncHandler.startIntegrationSR();
    }

    public void startIntegrationSR()
    {
        IntacctIntegrationLoggingHandler.pushEntry(INTACCT_INTEGRATION_START_LOG_ENTRY);

        List<Opportunity> opportunityData;
        opportunityData = GenerateSFDCObjectQueries.retrieveOpporutnities(filteredOpportunities);

        for(Opportunity opp : opportunityData)
        {
            if(opp.StageName == STAGE_CLOSED_WON || opp.StageName == STAGE_CLOSED_WON_NON_BILLING)
            { 
                throw new SRUtilities.SRException('This opportunity has already been closed.');
            }
            else
            {
                populateIntegrationIds(opportunityData);
                customerIntegration.startCustomerIntegration(billToAccountIds, false);
                if(customerIntegration.isValid)
                {
                    System.debug(billToContactIds);
                    System.debug(shipToContactIds);
                    contactIntegration.startContactIntegration(billToContactIds, shipToContactIds);
                    if(contactIntegration.isValid)
                    {
                        updateAccounts();
                        opp.StageName = closeOpp ? STAGE_CLOSED_WON : STAGE_CLOSED_WON_NON_BILLING;
                        update opp;
                    }
                    else
                    {
                        throw new SRUtilities.SRException(contactIntegration.errorMessage);
                    }
                }
                else
                { 
                    throw new SRUtilities.SRException(customerIntegration.errorMessage);
                }
            }   
        }

        IntacctIntegrationLoggingHandler.popEntry();    
    }

    public void syncOpportunityWithIntacct(Id opportunityId)
    {                
        /*Opportunity o = [SELECT 
                        Id, 
                        Bill_to_Account_ID__c, 
                        RecurSoft__Billing_Contact__c, 
                        RecurSoft__Shipping_Contact__c 
                        FROM Opportunity 
                        WHERE Id = :opportunityId];
        Boolean syncAccountResult = syncAccountWithIntacct(o.Bill_to_Account_ID__c);
        Boolean syncContactResult = syncContactWithIntacct(o.RecurSoft__Billing_Contact__c);
        Boolean syncShippingContactResult = syncContactWithIntacct(o.RecurSoft__Shipping_Contact__c);    

        //check for successful sync first
        if(syncAccountResult && syncContactResult && syncShippingContactResult)
        {
            
            for(Id id : accountsWithCustomerId.keySet())
            {           
                Account a = accountsWithCustomerId.get(id);
                update a;
            }

            for(Id id : contactsWithIntacctId.keySet())
            {          
                Contact c = contactsWithIntacctId.get(id);
                update c;
            } 

            o.StageName = 'Closed Won';
            update o;
        }      */  
    }

    private Boolean syncAccountWithIntacct(Id accountId)
    {        
        /*IntacctIntegrationAccountToCustomer intacctAccountToCustomer = new IntacctIntegrationAccountToCustomer(accountId);
        Boolean isValid = intacctAccountToCustomer.syncAccountWithIntacct2();*/
        return false;
    }

    private Boolean syncContactWithIntacct(Id contactId)
    {            
        /*IntacctIntegrationContactToContact intacctContactToContact = new IntacctIntegrationContactToContact(contactId);
        Boolean isValid = intacctContactToContact.syncContactWithIntacct2(); */
        return false;
    }
}