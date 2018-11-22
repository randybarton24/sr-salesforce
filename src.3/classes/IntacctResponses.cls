/**
 * File:        IntacctResponses.cls
 * Project:     Sererra 
 * Date:        January 8, 2013
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: Contains methods to parse the xml responses
 * *************************************************************************
 * History:
 */
public with sharing class IntacctResponses extends IntacctFunctionsHelper 
{

    /**
     *Gets the action type to be performed: create/update
     *@params responseDom
     *@return ids 
    */
    public Map<String, String> getActionType(DOM.Document responseDom)
    {
        Map<String, String> ids = new Map<String, String>();
        
        for(dom.XmlNode responseLevelNode : responseDom.getRootElement().getChildElements())
        {
            if(responseLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_OPERATION)
            {
                for(Dom.XmlNode resultLevelNode : responseLevelNode.getChildElements())
                {
                    if(resultLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_RESULT)
                    {
                        for(Dom.XmlNode listTypeLevelNode : resultLevelNode.getChildElements())
                        {
                            for(Dom.XmlNode controlId : resultLevelNode.getChildElements())
                            {
                                if(listTypeLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_LISTTYPE && controlId.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_CONTROLID)
                                {
                                    if(listTypeLevelNode.getAttributeValue(IntacctGlobalVariables.GET_NAME_ATTRIBUTE_END, null) != '-1')
                                    {
                                        ids.put(controlId.getText().substringAfterLast(IntacctGlobalVariables.CONTROLID_SEPARATOR).substring(0, 18), IntacctGlobalVariables.actionType_Update);
                                    }
                                    else
                                    {
                                        ids.put(controlId.getText().substringAfterLast(IntacctGlobalVariables.CONTROLID_SEPARATOR).substring(0, 18), IntacctGlobalVariables.actionType_Create);
                                    }
                                }
                            }
                        }
                    } 
                }
            }
        }
        return ids;
    }

    /**
     * Parses the error messages from the HttpResponse
     * Designed to be called after an HttpRequest was sent
     * @param responseDOM, ids, doInsert
     * @return objectIds
    */
    public Map<Id, Boolean> parseErrors(Dom.Document responseDOM, Set<Id> ids, Boolean doInsert)
    {
        String requestControlID;
        String currentFunctionControlID = '';
        String currentFunction;
        Map<Id, Boolean> objectIds = new Map<Id, Boolean>();
        String currentId;
        String context = '';
        Boolean hasErrors = false;
        Boolean isSuccess = false;
        SR_Feature_Flags__c featureFlag = SR_Feature_Flags__c.getInstance();
        
        List<Intacct_Error__c> sfErrorMessageList = new List<Intacct_Error__c>();
       
        for(dom.XmlNode responseLevelNode : responseDOM.getRootElement().getChildElements())
        {
            if(responseLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_CONTROL)
            {
                for(dom.XmlNode controlLevelNode : responseLevelNode.getChildElements())
                {
                    if(controlLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_CONTROLID)
                    {
                        requestControlID = controlLevelNode.getText();  
                    }                   
                }
            }
            if(responseLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_ERRORMESSAGE)
            {
                sfErrorMessageList.add(getErrorMessage('Error at control level.\nControl ID: ' + requestControlID, requestControlID, responseLevelNode));
            }
            if(responseLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_OPERATION)
            {
                for(dom.XmlNode operationLevelNode : responseLevelNode.getChildElements())
                {
                    if(operationLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_ERRORMESSAGE)
                    {
                    	hasErrors = true;
                        sfErrorMessageList.add(getErrorMessage('Error at operation level.\nControl ID: ' + requestControlID, requestControlID, operationLevelNode));
                    }
                    if(operationLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_RESULT)
                    {
                        for(dom.XmlNode functionLevelNode : operationLevelNode.getChildElements())
                        { 
                        	if(functionLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_STATUS)
                            { 
                                if(functionLevelNode.getText() == 'success')
                                {
                                	isSuccess = true;
                                }
                            }
                            if(functionLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_FUNCTION)
                            { 
                                currentFunction = functionLevelNode.getText();
                            }
                            if(functionLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_CONTROLID)
                            {
                                currentFunctionControlID = functionLevelNode.getText();
                                if(isSuccess && !String.isBlank(functionLevelNode.getText().toLowerCase()))
                            	{
                            		hasErrors = false;
                            		currentId = currentFunctionControlID.substringAfterLast(IntacctGlobalVariables.CONTROLID_SEPARATOR).substring(0, 18);
                            		if(!String.isBlank(currentId) && objectIds.get((Id)currentId) == null)
                            			objectIds.put((Id)currentId, hasErrors);
                            	}
                            }
                            if(functionLevelNode.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_ERRORMESSAGE)
                            {
                                if(featureFlag.Feature2__c) hasErrors = getErrors(functionLevelNode).contains('update a root level customer') ? false : true;
                                if(!featureFlag.Feature2__c) hasErrors = true;
                                context = 'Error at function level.\nControl ID: ' + requestControlID + ',\nFunction: ' + currentFunction + ',\nFunction Control ID: ' + currentFunctionControlID;
                                currentId = currentFunctionControlID.substringAfterLast(IntacctGlobalVariables.CONTROLID_SEPARATOR).substring(0, 18);
                                if(currentId != null) {
                                    objectIds.put((Id)currentId, hasErrors);
                                }
                                sfErrorMessageList.add(getErrorMessage(context, currentFunctionControlID, functionLevelNode));
                            }
                        }
                    }
                }
            }
        }
        
        if(sfErrorMessageList.size() > 0) 
        {
        	system.debug('SIZE: ' + sfErrorMessageList.size());
            try 
            {
                if(doInsert)
                {
                    insert sfErrorMessageList;
                }
            } 
            catch(DMLException ex) 
            {
                System.debug('DmlException from IntacctGateway: ' + ex.getMessage());
            }
        }       
        for(Id id : ids)
        {
        	if(objectIds.isEmpty())
        	{
        		objectIds.put(id, true);
        	}
        	else
        	{
        		if(objectIds.get(id) == null)
        		{
        			objectIds.put(id, true);
        		}
        	}
        }
        return objectIds;
    }
    
    /**
     * Fills in the lookup fields for Intacct Error Message Object 
     * @param context, id
     * @return sfErrorMessage
    */
    private Intacct_Error__c getErrorMessage(String context, String controlId, DOM.Xmlnode errorMessage)
    {
        Intacct_Error__c sfErrorMessage;
        
        sfErrorMessage = new Intacct_Error__c();
        sfErrorMessage.Description__c = context;
        
        if(!controlId.contains('intacct_operation') )
        {
            sfErrorMessage.Parent_Id__c = controlId.substringAfterLast(IntacctGlobalVariables.CONTROLID_SEPARATOR).substring(0, 18);
        }
        sfErrorMessage.Errors__c = getErrors(errorMessage);
        
        return sfErrorMessage;
    } 
    
    /**
     * Fills in the fields for Intacct Error Object with error messages from the HttpResponse
     * @param errorMessage node
     * @return sfError
    */
    private String getErrors(DOM.Xmlnode errorMessage)
    {
        String sfError = '';
        
        for(dom.XmlNode error : errorMessage.getChildElements()) 
        {
            if(error.getName().toLowerCase() == IntacctGlobalVariables.GET_NAME_ERROR) 
            {
                for(dom.Xmlnode node : error.getChildElements()) 
                {
                    sfError += getNodeValue(node, IntacctGlobalVariables.GET_NAME_ERRORNO, 'Intacct Error Number: ', ' ');
                    sfError += getNodeValue(node, IntacctGlobalVariables.GET_NAME_DESCRIPTION, '<br/>', '');
                    sfError += getNodeValue(node, IntacctGlobalVariables.GET_NAME_DESCRIPTION2, '<br/>', '');
                    sfError += getNodeValue(node, IntacctGlobalVariables.GET_NAME_CORRECTION, '<br/> Correction: ', '');
                    sfError += '<br/>';
                }
            }
        }       
        return sfError;
    }
    
    /**
     * Gets node values
     * @param node, nodeName, prefix, sufix
     * @return nodeValue
    */
    private String getNodeValue(dom.Xmlnode node, String nodeName, String prefix, String sufix) 
    {
        String nodeValue = '';
        
        if(node.getName().toLowerCase() == nodeName.toLowerCase()) 
        {
            if(node.getText().length() > 0) 
            {
                nodeValue = prefix +  node.getText() + sufix;
            }
        }
        
        return nodeValue;
    }


}