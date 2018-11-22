/**
 * File:        IntacctObjectContact.cls
 * Project:     Sererra 
 * Date:        December 24, 2012
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: Intacct Contact Object Definition
 * *************************************************************************
 * History:
 * Date:         February 14, 2013       Modified By:  Ionut Boghean       Description: Added externalId to the definition
 */
public with sharing class IntacctObjectContact extends IntacctFunctionsHelper 
{
    public Id salesforceId; //this is required on all objects
    public String intacctEntity; //this is required on all objects
    public String uniqueIdentifier; //this is required when the same SFDC object is mapped to multiple Intacct objects
    public String contactName;
    public String printAs;
    public String companyName;
    public String taxable;
    public String taxGroup;
    public String prefix;
    public String firstName;
    public String lastName;
    public String initial;
    public String phone1;
    public String phone2;
    public String cellPhone;
    public String pager;
    public String fax;
    public String email1;
    public String email2;
    public String url1;
    public String url2;
    public String status;
    public IntacctObjectsInterface.Address mailAddress;
    public String externalId;
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
        DOM.xmlNode function = createFunction('get_contact' + IntacctGlobalVariables.CONTROLID_SEPARATOR + uniqueControlIdPart + salesforceId);
        
        DOM.xmlNode functionElement = function.addChildElement('get_list', null ,null);
        functionElement.setAttribute('object', 'contact');
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
     * Builds the function block that describes the business function to be executed for the Intacct Contact record
     * @param isCreate (true for insert, false for update), actionType
     * @return function
    */
    public DOM.xmlNode setRecordRequest(Boolean isCreate, String actionType)
    {
    	String uniqueControlIdPart = (String.isBlank(uniqueIdentifier)) ? '' : uniqueIdentifier + IntacctGlobalVariables.CONTROLID_SEPARATOR;
        String action = actionType + '_contact';
        String controlId = action + IntacctGlobalVariables.CONTROLID_SEPARATOR + uniqueControlIdPart + salesforceId;
        
        DOM.xmlNode function = createFunction(controlId);
        DOM.xmlNode contactNode = createActionNode(function, action, isCreate, 'contactname', contactName, true);
        
        if(ignoreDuplicates != null)
        {
            contactNode.setAttribute('ignoreduplicates', ignoreDuplicates);
        }
        
        contactNode = fullContactNode(contactNode, isCreate, false);

        return function;
    }
     
    /**
     * Builds the function sub-blocks that describes the business function to be executed for the Intacct Contact record
     * @params contactNode, isCreate
     * @return contactNode
    */
    public DOM.xmlNode fullContactNode(DOM.xmlNode contactNode, Boolean isCreate, Boolean isCustomerSync) 
    {
        contactNode = createNode(contactNode, 'printas', printAs);
        if(isCustomerSync){
            contactNode = checkIfEmpty(taxable) ? createBlankNode(contactNode, 'taxable') : createNode(contactNode, 'taxable', taxable);
            contactNode = checkIfEmpty(companyName) ? createBlankNode(contactNode, 'companyname') : createNode(contactNode, 'companyname', companyName);
        }else{
            contactNode = checkIfEmpty(companyName) ? createBlankNode(contactNode, 'companyname') : createNode(contactNode, 'companyname', companyName);
            contactNode = checkIfEmpty(taxable) ? createBlankNode(contactNode, 'taxable') : createNode(contactNode, 'taxable', taxable);
        }
        contactNode = checkIfEmpty(taxGroup) ? createBlankNode(contactNode, 'taxgroup') : createNode(contactNode, 'taxgroup', taxGroup);
        contactNode = checkIfEmpty(prefix) ? createBlankNode(contactNode, 'prefix') : createNode(contactNode, 'prefix', prefix);
        contactNode = checkIfEmpty(firstName) ? createBlankNode(contactNode, 'firstname') : createNode(contactNode, 'firstname', firstName);
        contactNode = checkIfEmpty(lastName) ? createBlankNode(contactNode, 'lastname') : createNode(contactNode, 'lastname', lastName);
        contactNode = checkIfEmpty(initial) ? createBlankNode(contactNode, 'initial') : createNode(contactNode, 'initial', initial);
        contactNode = checkIfEmpty(phone1) ? createBlankNode(contactNode, 'phone1') : createNode(contactNode, 'phone1', phone1);
        contactNode = checkIfEmpty(phone2) ? createBlankNode(contactNode, 'phone2') : createNode(contactNode, 'phone2', phone2);
        contactNode = checkIfEmpty(cellPhone) ? createBlankNode(contactNode, 'cellphone') : createNode(contactNode, 'cellphone', cellPhone);
        contactNode = checkIfEmpty(pager) ? createBlankNode(contactNode, 'pager') : createNode(contactNode, 'pager', pager);
        contactNode = checkIfEmpty(fax) ? createBlankNode(contactNode, 'fax') : createNode(contactNode, 'fax', fax);
        contactNode = checkIfEmpty(email1) ? createBlankNode(contactNode, 'email1') : createNode(contactNode, 'email1', email1);
        contactNode = checkIfEmpty(email2) ? createBlankNode(contactNode, 'email2') : createNode(contactNode, 'email2', email2);
        contactNode = checkIfEmpty(url1) ? createBlankNode(contactNode, 'url1') : createNode(contactNode, 'url1', url1);
        contactNode = checkIfEmpty(url2) ? createBlankNode(contactNode, 'url2') : createNode(contactNode, 'url2', url2);
        contactNode = checkIfEmpty(status) ? createBlankNode(contactNode, 'status') : createNode(contactNode, 'status', status);
        contactNode = createAddressNode(contactNode, 'mailaddress', mailAddress);
        if(isCreate)
        {
            contactNode = createNode(contactNode, 'externalid', externalId);
        }
        
        return contactNode;
    }
    
    /**
     *Creates body for the http request that deletes the object from Intacct
     *@params salesforceId
     *@return function
    */
    public DOM.xmlNode deleteRecordRequest()
    {
    	String uniqueControlIdPart = (String.isBlank(uniqueIdentifier)) ? '' : uniqueIdentifier + IntacctGlobalVariables.CONTROLID_SEPARATOR;
        DOM.xmlNode function = createFunction('delete_contact' + IntacctGlobalVariables.CONTROLID_SEPARATOR + uniqueControlIdPart + salesforceId);
        
        DOM.xmlNode functionElement = function.addChildElement('delete_contact', null ,null);
        
        if(!String.isBlank(contactName))
        {
            functionElement.setAttribute('contactname', contactName);
        }
        
        return function;
    }
}