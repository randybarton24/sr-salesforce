/**
 * File:        IntacctObjectCustomer.cls
 * Project:     Sererra 
 * Date:        January 6, 2013
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: Intacct Customer Object Definition
 * *************************************************************************
 * History:
 * Date:         February 8, 2013       Modified By:  Alexandru Boghean       Description: Worked on the 'setRecordRequest' method
 * Date:         February 11, 2013      Modified By:  Alexandru Boghean       Description: Finished the 'setRecordRequest' method
 */
public with sharing class IntacctObjectCustomer  extends IntacctFunctionsHelper 
{
    
    public Id salesforceId; //this is required on all objects
    public String intacctEntity; //this is required on all objects
    public String uniqueIdentifier; //this is required when the same SFDC object is mapped to multiple Intacct objects
    public String customerId;
    public String name;
    public String parentId;
    public String termName;
    public String custrepId;
    public String shippingMethod;
    public String custType;
    public String taxId;
    public String creditLimit;
    public String territoryId;
    public String resaleNo;
    public List<String> deliveryOptions;//not very clear about this//please recheck
    public String accountLabel;
    public String glAccountNo;
    public String glGroup;
    public String onHold;
    public String comments;
    public String status;
    public String currencyName;
    public String externalId;
    public IntacctObjectContact primary;
    public Boolean createPrimaryContact = false;
    public IntacctObjectContact billTo;
    public Boolean createBillToContact = false;
    public IntacctObjectContact shipTo;
    public Boolean createShipToContact = false;
    public IntacctObjectContact contactInfo;
    public Boolean createContactInfo = false;
    public List<IntacctObjectContactItem> contactList;
    public String vsoePriceList;
    public List<IntacctObjectsInterface.CustomField> customFields;
    public IntacctObjectVisibility visibility;
    public String supDocId;
    public String ignoreDuplicates;
    public List<String> intacctFieldListForGetCall;
    public IntacctGetListExpression logicalExpression;
    
    /**
     *Creates body for the http request that checks if the object exists in Intacct
     *@params salesforceId
     *@return function
    */
    public DOM.xmlNode getRecordRequest()
    {
        String uniqueControlIdPart = (String.isBlank(uniqueIdentifier)) ? '' : uniqueIdentifier + IntacctGlobalVariables.CONTROLID_SEPARATOR;
        DOM.xmlNode function = createFunction('get_customer' + IntacctGlobalVariables.CONTROLID_SEPARATOR + uniqueControlIdPart + salesforceId);
        
        DOM.xmlNode functionElement = function.addChildElement('get_list', null ,null);
        functionElement.setAttribute('object', 'customer');
        functionElement.setAttribute('maxitems', '1');
        
        if(logicalExpression != null)
        {
            DOM.xmlNode filter = functionElement.addChildElement('filter', null, null);
            logicalExpression.evaluate(filter);
        }
        
        if(intacctFieldListForGetCall != null && !intacctFieldListForGetCall.isEmpty())
        {
            DOM.xmlNode fieldsNode = functionElement.addChildElement('fields', null, null);
            fieldsNode = createFieldList(fieldsNode, intacctFieldListForGetCall);
        }
        
        return function;
    }

    /**
     * Builds the function block that describes the business function to be executed for the Intacct Customer record
     * @param isCreate (true for insert, false for update), actionType
     * @return function
    */
    public DOM.xmlNode setRecordRequest(Boolean isCreate, String actionType)
    {
    	String uniqueControlIdPart = (String.isBlank(uniqueIdentifier)) ? '' : uniqueIdentifier + IntacctGlobalVariables.CONTROLID_SEPARATOR;
        String action = actionType + '_customer';
        String controlId = action + IntacctGlobalVariables.CONTROLID_SEPARATOR + uniqueControlIdPart + salesforceId;
        
        DOM.xmlNode function = createFunction(controlId);
        DOM.xmlNode customerNode = createActionNode(function, action, isCreate, 'customerid', customerId, true);
        
        if(!String.isBlank(ignoreDuplicates))
        {
            customerNode.setAttribute('ignoreduplicates', ignoreDuplicates);
        }
        
        customerNode = fullCustomerNode(customerNode, isCreate);
        
        return function;
    }
    
    /**
     * Builds the function sub-blocks that describes the business function to be executed for the Intacct Customer record
     * @params customerNode, isCreate
     * @return customerNode
    */
    public DOM.xmlNode fullCustomerNode(DOM.xmlNode customerNode, Boolean isCreate) 
    {
        customerNode = checkIfEmpty(name) ? createBlankNode(customerNode, 'name') : createNode(customerNode, 'name', name);
        customerNode = checkIfEmpty(parentId) ? createBlankNode(customerNode, 'parentid') : createNode(customerNode, 'parentid', parentId);
        customerNode = checkIfEmpty(termName) ? createBlankNode(customerNode, 'termname') : createNode(customerNode, 'termname', termName);
        customerNode = checkIfEmpty(custrepId) ? createBlankNode(customerNode, 'custrepid') : createNode(customerNode, 'custrepid', custrepId);
        customerNode = checkIfEmpty(shippingMethod) ? createBlankNode(customerNode, 'shippingmethod') : createNode(customerNode, 'shippingmethod', shippingMethod);
        customerNode = checkIfEmpty(custType) ? createBlankNode(customerNode, 'custtype') : createNode(customerNode, 'custtype', custType);
        customerNode = checkIfEmpty(taxId) ? createBlankNode(customerNode, 'taxid') : createNode(customerNode, 'taxid', taxId);
        customerNode = checkIfEmpty(creditLimit) ? createBlankNode(customerNode, 'creditlimit') : createNode(customerNode, 'creditlimit', creditLimit);
        customerNode = checkIfEmpty(territoryId) ? createBlankNode(customerNode, 'territoryid') : createNode(customerNode, 'territoryid', territoryId);
        customerNode = checkIfEmpty(resaleNo) ? createBlankNode(customerNode, 'resaleno') : createNode(customerNode, 'resaleno', resaleNo);
        customerNode = createDeliveryOptionsNode(customerNode, deliveryOptions);
        customerNode = checkIfEmpty(accountLabel) ? createBlankNode(customerNode, 'accountlabel') : createNode(customerNode, 'accountlabel', accountLabel);
        customerNode = checkIfEmpty(glAccountNo) ? createBlankNode(customerNode, 'glaccountno') : createNode(customerNode, 'glaccountno', glAccountNo);
        customerNode = checkIfEmpty(glGroup) ? createBlankNode(customerNode, 'glgroup') : createNode(customerNode, 'glgroup', glGroup);
        customerNode = checkIfEmpty(onHold) ? createBlankNode(customerNode, 'onhold') : createNode(customerNode, 'onhold', onHold);
        customerNode = checkIfEmpty(comments) ? createBlankNode(customerNode, 'comments') : createNode(customerNode, 'comments', comments);
        customerNode = checkIfEmpty(status) ? createBlankNode(customerNode, 'status') : createNode(customerNode, 'status', status);
        customerNode = checkIfEmpty(currencyName) ? createBlankNode(customerNode, 'currency') : createNode(customerNode, 'currency', currencyName); 
        if(isCreate)
        {
            customerNode = createNode(customerNode, 'externalid', externalId);
        }
        customerNode = createContactNode(customerNode, createPrimaryContact, primary, 'primary');
        customerNode = createContactNode(customerNode, createBillToContact, billTo, 'billto');
        customerNode = createContactNode(customerNode, createShipToContact, shipTo, 'shipto');
        customerNode = createContactNode(customerNode, createContactInfo, contactInfo, 'contactinfo');
        customerNode = createContactList(customerNode, contactList);
        customerNode = checkIfEmpty(vsoePriceList) ? createBlankNode(customerNode, 'vsoepricelist') : createNode(customerNode, 'vsoepricelist', vsoePriceList);
        customerNode = createCustomFieldsNode(customerNode, customFields);
        customerNode = createVisibilityXMLNode(customerNode, visibility);
        customerNode = checkIfEmpty(supDocId) ? createBlankNode(customerNode, 'supdocid') : createNode(customerNode, 'supdocid', supDocId);
        
        return customerNode;
    }
    
    /**
     *Creates body for the http request that deletes the object from Intacct
     *@params salesforceId
     *@return function
    */
    public DOM.xmlNode deleteRecordRequest()
    {
    	String uniqueControlIdPart = (String.isBlank(uniqueIdentifier)) ? '' : uniqueIdentifier + IntacctGlobalVariables.CONTROLID_SEPARATOR;
        DOM.xmlNode function = CreateFunction('delete_customer' + IntacctGlobalVariables.CONTROLID_SEPARATOR + uniqueControlIdPart + salesforceId);
        
        DOM.xmlNode functionElement = function.addChildElement('delete_customer', null ,null);
        
        if(!String.isBlank(customerId))
        {
            functionElement.setAttribute('customerid', customerId);
        }
        
        return function;
    }
}