/**
 * File:        IntacctFunctionsHelper.cls
 * Project:     Sererra 
 * Date:        December 20, 2012
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: Contains helper methods for the create/update/delete requests
 * *************************************************************************
 * History:
 */
public virtual class IntacctFunctionsHelper 
{
    
    /**
     *Creates an function node
     *@params controlId
     *@return function
    */
    public virtual DOM.xmlNode createFunction(String controlId)
    {
        DOM.Document XML = new DOM.Document();
        XML.load('<function></function>');
        DOM.xmlNode function = XML.getRootElement();
        
        function.setAttribute('controlid', controlId);
        return function;
    }

    /**
     *Creates an XML node - main node for add/update intacct object
     *@params node, action, isCreate, nodeName, nodeValue, isFieldIncludedInCreateCall
     *@return node
    */
    public virtual DOM.xmlNode createActionNode(DOM.xmlNode node, String action, Boolean isCreate, String nodeName, String nodeValue, Boolean isFieldIncludedInCreateCall)
    {
        DOM.xmlNode objectNode = node.addChildElement(action, null, null);
        
        if(isCreate && isFieldIncludedInCreateCall) 
        { 
            objectNode = createNode(objectNode, nodeName, nodeValue); 
        } 
        if(!isCreate) 
        { 
            objectNode.setAttribute(nodeName, nodeValue); 
        }
        
        return objectNode;
    }
    
    /**
     *Creates an XML node
     *@params node, nodeName, nodeValue
     *@return node
    */
    public virtual DOM.xmlNode createNode(DOM.xmlNode node, String nodeName, String nodeValue)
    {
        if(!String.isBlank(nodeValue))
        {
            node.addChildElement(nodeName, null, null).addTextNode(nodeValue);
        }
        return node;
    }
    
        
    /**
     *Creates an XML node
     *@params node, nodeName, nodeValue
     *@return node
    */
    public virtual DOM.xmlNode createBlankNode(DOM.xmlNode node, String nodeName)
    {
        node.addChildElement(nodeName, null, null).addTextNode('');
        return node;
    }
    /**
     *Creates an empty XML node
     *@params node, nodeName
     *@return node
    */
    public virtual DOM.xmlNode createEmptyNode(DOM.xmlNode node, String nodeName)
    {
        return node.addChildElement(nodeName, null, null);
    }

    /**
     * Create a list of child nodes for the fields node (represents the information the user wants to return from intacct)
     * @params node, fieldList
     * @return node
    */
    public virtual DOM.xmlNode createFieldList(DOM.xmlNode node, List<String> fieldList)
    {
        for(String field : fieldList) 
        {
            DOM.xmlNode tmpNode = createNode(node, 'field', field);
        }
        return node;
    }
    
    /**
     *Creates child nodes for an XML node named 'customfields'
     *@params node, List<CustomField>
     *@return node
    */
    public virtual DOM.xmlNode createCustomFieldsNode(DOM.xmlNode node, List<IntacctObjectsInterface.CustomField> customFields)
    {       
        if(customFields != null && customFields.size() > 0 ) 
        { 
            DOM.xmlNode customFieldsNode = createEmptyNode(node, 'customfields');
            for(IntacctObjectsInterface.CustomField customField : customFields) 
            {
                DOM.xmlNode tmpNode = createEmptyNode(customFieldsNode, 'customfield');
                tmpNode = createCustomFieldNode(tmpNode, customField);
            }
        }
        return node;
    }
    
    /**
     *Creates child nodes for an XML node named 'customfield'
     *@params node, fieldName, fieldValue
     *@return node
    */
    public virtual DOM.xmlNode createCustomFieldNode(DOM.xmlNode node, IntacctObjectsInterface.CustomField customField)
    {       
        node = createNode(node, 'customfieldname', customField.customFieldName);
        if(!String.isBlank(customField.customFieldValue))
        {
            node = createNode(node, 'customfieldvalue', customField.customFieldValue);
        }
        else
        {
            node = createNode(node, 'customfieldvalue', '');
        }
        return node;
    }
    
    /**
     *Creates address node
     *@params node, nodeName, address
     *@return node
    */
    public virtual DOM.xmlNode createAddressNode(DOM.xmlNode node, String nodeName, IntacctObjectsInterface.Address address)
    {       
        if(address != null) 
        {
            Dom.xmlNode addrNode = createEmptyNode(node, nodeName);
            addrNode = createNode(addrNode, 'address1', address.address1);
            addrNode = (String.isBlank(address.address2)) ? createBlankNode(addrNode, 'address2') : createNode(addrNode, 'address2', address.address2);
            addrNode = createNode(addrNode, 'city', address.city);
            addrNode = createNode(addrNode, 'state', address.state);
            addrNode = createNode(addrNode, 'zip', address.zip);
            addrNode = createNode(addrNode, 'country', address.country);
            addrNode = createNode(addrNode, 'isocountrycode', address.isoCountryCode);
        }
        return node;
    }

    /**
     *Creates child nodes for an XML node named 'deliveryoptions'
     *@params node, fieldValues
     *@return node
    */
    public virtual DOM.xmlNode createDeliveryOptionsNode(DOM.xmlNode node, List<String> fieldValues)
    {       
        if(fieldValues != null && !fieldValues.isEmpty())
        {
            DOM.xmlNode deliveryOptionsNode = createEmptyNode(node, 'deliveryoptions');
            for(String deliveryOption : fieldValues)
            {
                DOM.xmlNode tmpNode = createNode(deliveryOptionsNode, 'deliveryoption', deliveryOption);
            }
        }
        return node;
    }

    /**
     *Creates an XML node named 'visibility'
     *@params node, visibility
     *@return node
    */
    public virtual DOM.xmlNode createVisibilityXMLNode(DOM.xmlNode node, IntacctObjectVisibility visibility)
    {       
        if(visibility != null)
        {
            visibility.createVisibilityNode(node); 
        }
        return node;
    }
    
    /**
     *Creates child nodes for an XML node named 'visibility'
     *@params node, visibility
     *@return node
    */
    public virtual DOM.xmlNode createVisibilityChildNode(DOM.xmlNode node, String nodeName, String childName, List<String> values)
    { 
        DOM.xmlNode visibilityElementnode = createEmptyNode(node, nodeName);
        for(String tmpValue : values)
        {
            visibilityElementnode = createNode(visibilityElementnode, childName, tmpValue);
        }
        return node;
    }
    
    /**
     *Creates contact nodes
     *@params node, isNew, contact, contactType
     *@return node
    */
    public virtual DOM.xmlNode createContactNode(DOM.xmlNode node, Boolean createContact, IntacctObjectContact contact, String contactType)
    {
        if(contact != null)
        {
            Dom.xmlNode contactName = createEmptyNode(node, contactType);
            if(!createContact) 
            { 
                contactName = createNode(contactName, 'contactname', contact.contactName);
            } 
            else
            {
                contactName = createEmptyNode(contactName, 'contact');
                contactName = createNode(contactName, 'contactname', contact.contactName);
                contactName = contact.fullContactNode(contactName, true, true);
            }    
        }
        return node;
    }
    
     /**
     *Checks if node value is null or empty
     *@params nodeValue
     *@return true if nodeValue is null or empty
    */
    public virtual Boolean checkIfEmpty(String nodeValue){
        return String.isEmpty(nodeValue);
    }
    /**
     *Creates contactlist node
     *@params node, contactItemList
     *@return node
    */
    public virtual DOM.xmlNode createContactList(DOM.xmlNode node, List<IntacctObjectContactItem> contactItemList)
    {
        if(contactItemList != null && contactItemList.size() > 0 ) 
        {  
            DOM.xmlNode contactListNode = createEmptyNode(node, 'contactlist');
            for(IntacctObjectContactItem contactItem : contactItemList) 
            {
                contactItem.createContactItemNode(contactListNode);
            }
        }
        return node;
    }
    
    /**
     *Creates child nodes for an XML node named 'expression'
     *@params node, exprFilter
     *@return node
    */
    public virtual DOM.xmlNode createExpressionNode(DOM.xmlNode node, IntacctObjectsInterface.ExpressionFilter exprFilter)
    {   
        DOM.xmlNode exprNode = createEmptyNode(node, 'expression');    
        if(exprFilter != null) 
        { 
            exprNode = createNode(exprNode, 'field', exprFilter.fieldName);
            exprNode = createNode(exprNode, 'operator', exprFilter.operator);
            exprNode = createNode(exprNode, 'value', exprFilter.value);
        }
        return node;
    }
}