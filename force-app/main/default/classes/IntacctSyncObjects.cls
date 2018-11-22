/**
 * File:        IntacctSyncObjects.cls
 * Project:     Sererra 
 * Date:        January 8, 2013
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: This is the main controller of the integration.
 *              Handles the creation of the xml requests, sends them to intacct and updates the objects based on the received responses
 * *************************************************************************
 * History:
 */
public class IntacctSyncObjects 
{

    public static String testResult = '<?xml version="1.0" encoding="UTF-8"?><response></response>';
    
    /**
     *Constructor
    */
    public IntacctSyncObjects(){}
    
    private static List<IntacctObjectsInterface.IntacctObject> prepareIntacctObjects(List<Object> syncObjects)
    {
        List<IntacctObjectsInterface.IntacctObject> intacctObjects = new List<IntacctObjectsInterface.IntacctObject>();
        
        for(Object tmpObject : syncObjects) 
        {
            intacctObjects.add(new IntacctObjectsInterface.IntacctObject(tmpObject));
        }
        return intacctObjects;
    }
    
    /**
     * Get objects from Intacct
     * @param syncObjects
    */
    public static void getObjects(List<Object> syncObjects)
    {
        List<IntacctObjectsInterface.IntacctObject> intacctObjects = prepareIntacctObjects(syncObjects);
        Set<Id> objectsToUpdate = new Set<Id>();
        
        List<Dom.Document> results = new List<Dom.Document>();
        Map<String,List<DOM.xmlNode>> actionFunctionsGroupedByEntity = new Map<String,List<DOM.xmlNode>>();
        
        DOM.Document getActionResultDocument = new DOM.Document();
        
        IntacctFunctions intacctActions = new IntacctFunctions();
        IntacctResponses intacctResponse = new IntacctResponses();
        
        //all the objects will be included in a create request so we set the flag to true
        for(IntacctObjectsInterface.IntacctObject sObj : intacctObjects)
        {
            objectsToUpdate.add(sObj.salesforceId);
        }
        
        //generate the create functions
        actionFunctionsGroupedByEntity = intacctActions.getRecordRequest(intacctObjects);
        
        if(!actionFunctionsGroupedByEntity.isEmpty())
        {
            //send the request to Intacct and catch the response in a dom.document variable
            getActionResultDocument.load(sendRequest(actionFunctionsGroupedByEntity));
            
            //get the id of objects that failed to be integrated, map the boolean variable for each object an update the objects
            Map<Id, Boolean> errorRecordsId = intacctResponse.parseErrors(getActionResultDocument, objectsToUpdate, true);
            updateSObjects(objectsToUpdate, errorRecordsId);
        }
    }
    
    /**
     * Get objects data from Intacct
     * @param syncObjects
    */
    public static Dom.Document getObjectsData(List<Object> syncObjects)
    {
        List<IntacctObjectsInterface.IntacctObject> intacctObjects = prepareIntacctObjects(syncObjects);
        Set<Id> objectsToUpdate = new Set<Id>();
        
        List<Dom.Document> results = new List<Dom.Document>();
        Map<String,List<DOM.xmlNode>> actionFunctionsGroupedByEntity = new Map<String,List<DOM.xmlNode>>();
        
        DOM.Document getActionResultDocument = new DOM.Document();
        
        IntacctFunctions intacctActions = new IntacctFunctions();
        IntacctResponses intacctResponse = new IntacctResponses();
        
        //all the objects will be included in a create request so we set the flag to true
        for(IntacctObjectsInterface.IntacctObject sObj : intacctObjects)
        {
            objectsToUpdate.add(sObj.salesforceId);
        }
        
        //generate the create functions
        actionFunctionsGroupedByEntity = intacctActions.getRecordRequest(intacctObjects);
        
        if(!actionFunctionsGroupedByEntity.isEmpty())
        {
            //send the request to Intacct and catch the response in a dom.document variable
            getActionResultDocument.load(SendRequest(actionFunctionsGroupedByEntity));
            
            //get the id of objects that failed to be integrated, map the boolean variable for each object an update the objects
            //Map<Id, Boolean> errorRecordsId = intacctResponse.parseErrors(getActionResultDocument, objectsToUpdate);
        }
        
        return getActionResultDocument;
    }
    
    /**
     * Creates objects in Intacct
     * @param syncObjects, doSobjectUpdate
    */
    public static Map<String, Set<Id>> createObjects(List<Object> syncObjects, Boolean doSobjectUpdate)
    {
        Map<String, Set<Id>> responseAndObjectIds = new Map<String, Set<Id>>();
        List<IntacctObjectsInterface.IntacctObject> intacctObjects = prepareIntacctObjects(syncObjects);
        Set<Id> objectsToUpdate = new Set<Id>();
        
        List<Dom.Document> results = new List<Dom.Document>();
        Map<String,List<DOM.xmlNode>> actionFunctionsGroupedByEntity = new Map<String,List<DOM.xmlNode>>();
        
        DOM.Document getActionResultDocument = new DOM.Document();
        
        IntacctFunctions intacctActions = new IntacctFunctions();
        IntacctResponses intacctResponse = new IntacctResponses();
        
        //all the objects will be included in a create request so we set the flag to true
        for(IntacctObjectsInterface.IntacctObject sObj : intacctObjects)
        {
            objectsToUpdate.add(sObj.salesforceId);
            sObj.isCreate = true;
        }
        System.debug('OBJECT LIST:' + objectsToUpdate);
        //generate the create functions
        actionFunctionsGroupedByEntity = intacctActions.setRecordRequest(intacctObjects);
        System.debug('INTACCT OBJECT LIST: ' + intacctObjects);
        if(!actionFunctionsGroupedByEntity.isEmpty())
        {
            //send the request to Intacct and catch the response in a dom.document variable
            getActionResultDocument.load(SendRequest(actionFunctionsGroupedByEntity));
            
            if(doSobjectUpdate)
            {
                //get the id of objects that failed to be integrated, map the boolean variable for each object an update the objects
                Map<Id, Boolean> errorRecordsId = intacctResponse.parseErrors(getActionResultDocument, objectsToUpdate, true);
                updateSObjects(objectsToUpdate, errorRecordsId);
            }
            responseAndObjectIds.put(getActionResultDocument.toXMLString(), objectsToUpdate);
        }
        return responseAndObjectIds;
    }
    
    /**
     * Updates objects in Intacct
     * @param syncObjects, doSobjectUpdate
    */
    public static Map<String, Set<Id>> updateObjects(List<Object> syncObjects, Boolean doSobjectUpdate)
    {
        Map<String, Set<Id>> responseAndObjectIds = new Map<String, Set<Id>>();
        List<IntacctObjectsInterface.IntacctObject> intacctObjects = prepareIntacctObjects(syncObjects);
        Set<Id> objectsToUpdate = new Set<Id>();
        
        List<Dom.Document> results = new List<Dom.Document>();
        Map<String,List<DOM.xmlNode>> actionFunctionsGroupedByEntity = new Map<String,List<DOM.xmlNode>>();
        
        DOM.Document getActionResultDocument = new DOM.Document();
        
        IntacctFunctions intacctActions = new IntacctFunctions();
        IntacctResponses intacctResponse = new IntacctResponses();
        
        //all the objects will be included in an update request so we set the flag to false
        for(IntacctObjectsInterface.IntacctObject sObj : intacctObjects)
        {
            objectsToUpdate.add(sObj.salesforceId);
            sObj.isCreate = false;
        }
        
        //generate the update functions
        actionFunctionsGroupedByEntity = intacctActions.setRecordRequest(intacctObjects);
        
        if(!actionFunctionsGroupedByEntity.isEmpty())
        {
            //send the request to Intacct and catch the response in a dom.document variable
            getActionResultDocument.load(SendRequest(actionFunctionsGroupedByEntity));
            
            //get the id of objects that failed to be integrated, map the boolean variable for each object an update the objects
            if(doSobjectUpdate)
            {
                Map<Id, Boolean> errorRecordsId = intacctResponse.ParseErrors(getActionResultDocument, objectsToUpdate, true);
                updateSObjects(objectsToUpdate, errorRecordsId);
            }
            responseAndObjectIds.put(getActionResultDocument.toXMLString(), objectsToUpdate);
        }
        return responseAndObjectIds;
    }

    /**
     * Upserts (checks if they exist in intacct: if true we run an update, if false we create the object) objects in Intacct
     * @param syncObjects, doErrorHandlingAndUpdate
    */
    public static Map<String, Set<Id>> upsertObjects(List<Object> syncObjects, Boolean doErrorHandlingAndUpdate)
    {
        Map<String, Set<Id>> responseAndObjectIds = new Map<String, Set<Id>>();
        List<IntacctObjectsInterface.IntacctObject> intacctObjects = prepareIntacctObjects(syncObjects);
        Set<Id> objectsToUpdate = new Set<Id>();
        
        List<Dom.Document> results = new List<Dom.Document>();
        Map<String,List<DOM.xmlNode>> getFunctions = new Map<String,List<DOM.xmlNode>>();
        Map<String,List<DOM.xmlNode>> actionFunctionsGroupedByEntity = new Map<String,List<DOM.xmlNode>>();
        
        DOM.Document getListDocument = new DOM.Document();
        DOM.Document getActionResultDocument = new DOM.Document();
        
        IntacctFunctions intacctActions = new IntacctFunctions();
        IntacctResponses intacctResponse = new IntacctResponses();
        
        //send get_list request
        getFunctions = intacctActions.getRecordRequest(intacctObjects);
        getListDocument.load(SendRequest(getFunctions));
        system.debug('GET RESPONSE: ' + getListDocument.toXMLString());
        Map<String, String> actionTypes = intacctResponse.getActionType(getListDocument);
        
        for(IntacctObjectsInterface.IntacctObject sObj : intacctObjects)
        {
            objectsToUpdate.add(sObj.salesforceId);
            String actionType = actionTypes.get(String.valueOf(sObj.salesforceId));
            system.debug('ACTION TYPE: ' + actionType + '--IDENTIFIER: ' + sObj.uniqueIdentifier);
            system.debug('GET RESPONSE: ' + getListDocument.toXMLString());
            if(actionType != null && actionType == IntacctGlobalVariables.actionType_Update) 
            {
                sObj.isCreate =  false;
            }
        }
        //geenerate the create/update functions
        actionFunctionsGroupedByEntity = intacctActions.setRecordRequest(intacctObjects);
        
        if(!actionFunctionsGroupedByEntity.isEmpty())
        {
            //send the request to Intacct and catch the response in a dom.document variable
            getActionResultDocument.load(SendRequest(actionFunctionsGroupedByEntity));
            
            if(doErrorHandlingAndUpdate)
            {
                //get the id of objects that failed to be integrated, map the boolean variable for each object an update the objects
                Map<Id, Boolean> errorRecordsId = intacctResponse.ParseErrors(getActionResultDocument, objectsToUpdate, true);
                updateSObjects(objectsToUpdate, errorRecordsId);
            }
            responseAndObjectIds.put(getActionResultDocument.toXMLString(), objectsToUpdate);
        }
        return responseAndObjectIds;
    }
    
    /**
     * Deletes objects from Intacct
     * @param syncObjects
    */
    public static void deleteObjects(List<Object> syncObjects)
    {
        List<IntacctObjectsInterface.IntacctObject> intacctObjects = prepareIntacctObjects(syncObjects);
        Set<Id> objectsToUpdate = new Set<Id>();
        
        List<Dom.Document> results = new List<Dom.Document>();
        Map<String,List<DOM.xmlNode>> actionFunctionsGroupedByEntity = new Map<String,List<DOM.xmlNode>>();
        
        DOM.Document getActionResultDocument = new DOM.Document();
        
        IntacctFunctions intacctActions = new IntacctFunctions();
        IntacctResponses intacctResponse = new IntacctResponses();
        
        for(IntacctObjectsInterface.IntacctObject sObj : intacctObjects)
        {
            objectsToUpdate.add(sObj.salesforceId);
        }
        
        //generate the delete functions
        actionFunctionsGroupedByEntity = intacctActions.deleteRecordRequest(intacctObjects);
        
        if(!actionFunctionsGroupedByEntity.isEmpty())
        {
            //send the request to Intacct and catch the response in a dom.document variable
            getActionResultDocument.load(sendRequest(actionFunctionsGroupedByEntity));
            
            //get the id of objects that failed to be integrated, map the boolean variable for each object an update the objects
            Map<Id, Boolean> errorRecordsId = intacctResponse.ParseErrors(getActionResultDocument, objectsToUpdate, true);
            updateSObjects(objectsToUpdate, errorRecordsId);
        }
    }

    /**
     * Public method - calls the private updateSObjects method explicitly
     * @param objects, idsWithErrors
    */
    public static void updateSObjectsMask(Set<Id> objects, Map<Id, Boolean> idsWithErrors)
    {
        updateSObjects(objects, idsWithErrors);
    }
    
    /**
     * Sends requests to Intacct
     * @param functionsGroupedByEntity
     * @return result
    */
    private static String sendRequest(Map<String,List<DOM.xmlNode>> functionsGroupedByEntity)
    {
        String result = '';
        
        System.debug(functionsGroupedByEntity);
        
        if(!functionsGroupedByEntity.isEmpty()) 
        {
            DOM.Document doc = IntacctGateway.BuildRequestDocument(functionsGroupedByEntity); 
            IntacctIntegrationLoggingHandler.pushEntry('Request:' + doc.toXmlString());
            IntacctIntegrationLoggingHandler.popAll();
            HttpRequest req = IntacctGateway.BuildHttpRequest(doc);
            
            Http http = new Http();
            HTTPResponse response = new HTTPResponse();
            if(!System.Test.isRunningTest()) 
            {
                response = http.send(req);
                result = response.getBody();
            }
            else 
            {
                result = testResult;
            }
        }
        else
        {
            if(System.Test.isRunningTest()) 
            {
                result = testResult;
            }
        }
        System.debug('RESPONSE: ' + result);
        IntacctIntegrationLoggingHandler.pushEntry('RESPONSE: ' + result);
        IntacctIntegrationLoggingHandler.popAll();
        return result;  
    }
    
    /**
     * Updates sObjects with appropriate flgas in this case -> 'Synced with Intacct'
     * Designed to be called from 'SyncObjects' method
     * @param objects, idsWithErrors
    */
    private static void updateSObjects(Set<Id> objects, Map<Id, Boolean> idsWithErrors)
    {
        Map<String, List<sObject>> orderedObjectsToUpdate = new Map<String, List<sObject>>();
        Boolean isFailed;
        for(Id id : objects)
        {
            String prefix = String.valueOf(id).substring(0, 3);
            
            sObject sObj = createCustomObject(prefix, id);
            if(sObj != null) 
            {
                if(!System.Test.isRunningTest())
                {
                   System.debug('UPDATE DETAILS: ' + idsWithErrors.get(id) + '---' + id);
                   isFailed = idsWithErrors.get(id);
                   //if(isFailed)
                   //{
                       //IntacctIntegrationSyncHandler.failedIds.add(id);
                   //}
                   sObj.put('RecurSoft__Synced_With_Intacct__c', !isFailed);
                   sObj.put('RecurSoft__Synced_With_Intacct_Date__c', System.now());
                }
                if(sObj.getSObjectType() == Account.sObjectType)
                {
                    Account currentAccount;
                    if(IntacctIntegrationSyncHandler.accountsWithCustomerId != null)
                    {
                        currentAccount = IntacctIntegrationSyncHandler.accountsWithCustomerId.get(id);
                        //here - convert sobject to an account
                        //add the account to the IntacctIntegrationSyncHandler.accountsWithCustomerId using the same id
                    }
                    if(IntacctIntegrationAccountToCustomer.accountsWithCustomerId != null)
                    {
                        currentAccount = IntacctIntegrationAccountToCustomer.accountsWithCustomerId.get(id);
                    }
                    sObj.put('RecurSoft__IntacctID__c', currentAccount.RecurSoft__IntacctID__c);
                }
                if(sObj.getSObjectType() == Contact.sObjectType)
                {
                    Contact currentContact;
                    if(IntacctIntegrationSyncHandler.contactsWithIntacctId != null)
                    {
                        currentContact = IntacctIntegrationSyncHandler.contactsWithIntacctId.get(id);
                        //here - convert sobject to an contact
                        //add the contact to the IntacctIntegrationSyncHandler.contactsWithIntacctId using the same id
                    }
                    if(IntacctIntegrationContactToContact.contactsWithIntacctId != null)
                    {
                        currentContact = IntacctIntegrationContactToContact.contactsWithIntacctId.get(id);
                    }
                    sObj.put('RecurSoft__Intacct_Contact_ID__c', currentContact.RecurSoft__Intacct_Contact_ID__c);
                }
                if(orderedObjectsToUpdate.get(prefix) == null) 
                {
                    orderedObjectsToUpdate.put(prefix, new List<sObject>());
                }
                orderedObjectsToUpdate.get(prefix).add(sObj);
            }
        }
        
        List<sObject> objectsToUpdate = new List<sObject>();
        for(String prefix : orderedObjectsToUpdate.keySet()) 
        {
            try
            {
                System.debug('Objets to Update Size: ' + objectsToUpdate.size() + objectsToUpdate);
                if(orderedObjectsToUpdate.get(prefix).size() > 0) 
                {
                    update(orderedObjectsToUpdate.get(prefix));
                }
            }
            catch(DMLException ex)
            {
                System.Debug('DMLException from UpdateSObjects: ' + ex.getMessage());
            } 
        }
        
    }
    
    /**
     * Create a dynamic sObject based on the object prefix
     * Designed to be called from 'UpdateSObjects' method
     * @param prefix, objectId
     * @return new sObject
    */
    private static sObject createCustomObject(String prefix, Id objectId) 
    {
        ObjectPrefixes objectPrefixes = new ObjectPrefixes();
        String typeName = objectPrefixes.getObjectNameByPrefix(prefix);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) 
        {
            return null;
        }
    
        return targetType.newSObject(objectId); 
    }
}