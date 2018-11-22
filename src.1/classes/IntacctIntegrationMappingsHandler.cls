/**
 * File:        IntacctIntegrationMappingsHandler.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        March 26, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description:  Contains methods to map the SFDC objects to the Intacct objects<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
public with sharing class IntacctIntegrationMappingsHandler 
{
    private static final String MAILING_STREET_API_NAME = 'MailingStreet';
    private static final String MAILING_CITY_API_NAME = 'MailingCity';
    private static final String MAILING_STATE_API_NAME = 'MailingState';
    private static final String MAILING_COUNTRY_API_NAME = 'MailingCountry';
    private static final String MAILING_POSTAL_CODE_API_NAME = 'MailingPostalCode';
    private static final String BILLING_STREET_API_NAME = 'BillingStreet';
    private static final String BILLING_CITY_API_NAME = 'BillingCity';
    private static final String BILLING_STATE_API_NAME = 'BillingState';
    private static final String BILLING_COUNTRY_API_NAME = 'BillingCountry';
    private static final String BILLING_POSTAL_CODE_API_NAME = 'BillingPostalCode';
    
    private static final String CUSTOMER_STATUS_ACTIVE = 'active';
    private static final String CUSTOMER_DELIVERY_OPTION_EMAIL = 'email';
    
    private static final String CUSTOMER_DEFAULT_PAYMENT_TYPE_FIELD = 'DEFAULT_PAYMENT_TYPE';
    private static final String CUSTOMER_CUSTOMERID_FIELD = 'customerid';
    private static final String CONTACT_CONTACTNAME_FIELD = 'contactname';
    
    private static final String EQUAL_OPERATOR = '=';
    private static final String SPACE_SEPARATOR = ' ';
    private static final String CUTOMER_SETTING = 'Customer';
    private static final String CONTACT_SETTING = 'Contact';
    
    private static final Map<String, String> CONTACT_PREFIXES = new Map<String, String>{'billto'=>'B_', 'primary'=>'P_'};
    private static final String PRIMARY_CONTACT_TYPE = 'primary';
    
    /**
    * @author Ionut Boghean
    * @date March 27, 2014
    * @description Constructor
    */
    public IntacctIntegrationMappingsHandler()
    {
        
    }
    
    /**
    * @author Ionut Boghean
    * @date March 27, 2014
    * @description Map a list of salesforce contact records to a list of intacct contact objects
    * @param contactSobjectRecords The salesforce contact records
    * @return intacctContactObjects The intacct contact objects
    * @see IntacctIntegrationMappingsHandler.mapContactFields
    */
    public List<Object> mapContactsToContacts(List<Contact> contactSobjectRecords)
    {
        List<Object> intacctContactObjects = new List<Object>();
        for(Contact tempContact :contactSobjectRecords)
        {
            intacctContactObjects.add(mapContactFields(tempContact));
        }
        return intacctContactObjects;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 27, 2014
    * @description Map salesforce contact fields to intacct contact object properties
    * @param currentSobjectRecord The salesforce contact record
    * @return intacctContactObject The intacct contact object
    * @see IntacctIntegrationMappingsHandler.createMailingAddressObject
    */
    private Object mapContactFields(Contact currentSobjectRecord)
    {
        IntacctObjectContact intacctContactObject = new IntacctObjectContact();
        intacctContactObject.salesforceId = currentSobjectRecord.Id;
        intacctContactObject.printAs = currentSobjectRecord.Account.Name;
        intacctContactObject.contactName = currentSobjectRecord.RecurSoft__Intacct_Contact_ID__c;
        intacctContactObject.externalId = currentSobjectRecord.Id;
        intacctContactObject.mailAddress = createMailingAddressObject(currentSobjectRecord);
        
        intacctContactObject.companyname = currentSobjectRecord.Account.Name;
        intacctContactObject.prefix = currentSobjectRecord.Salutation;
        intacctContactObject.firstname = currentSobjectRecord.FirstName;
        intacctContactObject.lastname = currentSobjectRecord.LastName;
        intacctContactObject.phone1 = currentSobjectRecord.Phone;
        intacctContactObject.cellphone = currentSobjectRecord.MobilePhone;
        intacctContactObject.fax = currentSobjectRecord.Fax;
        intacctContactObject.email1 = currentSobjectRecord.Email;
        intacctContactObject.logicalExpression = createLogicalExpression(CONTACT_CONTACTNAME_FIELD, EQUAL_OPERATOR, currentSobjectRecord.RecurSoft__Intacct_Contact_ID__c);
        
        String entity = (checkEntityMappingSettings(CONTACT_SETTING) && !currentSobjectRecord.Account.RecurSoft__Intacct_Entity__r.Entity_root__c)? currentSobjectRecord.Account.RecurSoft__Intacct_Entity__r.Name : '';
        intacctContactObject.intacctEntity = entity;
        
        return intacctContactObject;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Map a list of salesforce account records to a list of intacct customer objects
    * @param accountSobjectRecords The salesforce account records
    * @return intacctCustomerObjects The intacct account objects
    * @see IntacctIntegrationMappingsHandler.mapAccountFields
    */
    public List<Object> mapAccountsToCustomers(List<Account> accountSobjectRecords)
    {
        List<Object> intacctCustomerObjects = new List<Object>();
        for(Account tempAccount :accountSobjectRecords)
        {
            intacctCustomerObjects.add(mapAccountFields(tempAccount));
        }
        return intacctCustomerObjects;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Map salesforce account fields to intacct customer object properties
    * @param currentSobjectRecord The salesforce account record
    * @return intacctCustomerObject The intacct customer object
    */
    private Object mapAccountFields(Account currentSobjectRecord)
    {
        IntacctObjectCustomer intacctCustomerObject = new IntacctObjectCustomer();
        intacctCustomerObject.salesforceId = currentSobjectRecord.Id;
        intacctCustomerObject.customerId = currentSobjectRecord.RecurSoft__IntacctID__c;
        if(IntacctIntegrationSyncHandler.checkEnableResellerProcessSetting() && !String.isBlank(currentSobjectRecord.Parent.RecurSoft__IntacctID__c)){
            intacctCustomerObject.parentId = currentSobjectRecord.Parent.RecurSoft__IntacctID__c;
        }
        intacctCustomerObject.name = currentSobjectRecord.Name;
        intacctCustomerObject.termName = currentSobjectRecord.RecurSoft__Payment_Term__c;
        intacctCustomerObject.status = CUSTOMER_STATUS_ACTIVE;
        intacctCustomerObject.externalId = currentSobjectRecord.Id;
        intacctCustomerObject.contactInfo = createContactInfoObject(currentSobjectRecord);
        intacctCustomerObject.createContactInfo = true;
        intacctCustomerObject.primary = createContactObject(currentSobjectRecord, PRIMARY_CONTACT_TYPE);
        intacctCustomerObject.createPrimaryContact = true;
        intacctCustomerObject.deliveryOptions = new List<String>{CUSTOMER_DELIVERY_OPTION_EMAIL};
        String entity = (checkEntityMappingSettings(CUTOMER_SETTING) && !currentSobjectRecord.RecurSoft__Intacct_Entity__r.Entity_root__c)? currentSobjectRecord.RecurSoft__Intacct_Entity__r.Name : '';
        intacctCustomerObject.intacctEntity = entity;
        intacctCustomerObject.logicalExpression = createLogicalExpression(CUSTOMER_CUSTOMERID_FIELD, EQUAL_OPERATOR, currentSobjectRecord.RecurSoft__IntacctID__c);
        
        if(currentSobjectRecord.Verisign_Profile_ID__c != null || currentSobjectRecord.RecurSoft__Default_Payment_Type__c != null) 
        {
            intacctCustomerObject.customFields = new List<IntacctObjectsInterface.CustomField>();
            
            if(currentSobjectRecord.Verisign_Profile_ID__c != null) 
                intacctCustomerObject.customFields.add(createCustomField('CF_CUSTOMER_TEXT_VERISIGNPROFILEID', currentSobjectRecord.Verisign_Profile_ID__c));
            if(currentSobjectRecord.RecurSoft__Default_Payment_Type__c != null)
                intacctCustomerObject.customFields.add(createCustomField('DEFAULT_PAYMENT_TYPE', currentSobjectRecord.RecurSoft__Default_Payment_Type__c));
        }
        return intacctCustomerObject;
    }
    
    /**
    * @author Ionut Boghean
    * @date June 3, 2014
    * @description Create a get list logical expression 
    * @param filterName The name of the filed used as filter
    * @param operator The operator for the filter
    * @param filterValue The filter value
    * @return intacctExpression The intacct contact object
    */
    private static IntacctGetListExpression createLogicalExpression(String filterName, String operator, String filterValue)
    {
        IntacctObjectsInterface.ExpressionFilter firstFilter = new IntacctObjectsInterface.ExpressionFilter();
        firstFilter.fieldName = filterName; 
        firstFilter.operator = operator; 
        firstFilter.value = filterValue;
        
        IntacctGetListExpression intacctExpression = (new IntacctGetListFilterVariable('firstFilter')).set('firstFilter', firstFilter);
            
        return intacctExpression;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Create an intacct contact child object 
    * @param currentSobjectRecord The salesforce account record
    * @param customerId The customer id used for the contact name
    * @return intacctContactObject The intacct contact object
    */
    private IntacctObjectContact createContactInfoObject(Account currentSobjectRecord)
    {
        IntacctObjectContact intacctContactObject = new IntacctObjectContact();
        intacctContactObject.salesforceId = currentSobjectRecord.Id;
        intacctContactObject.printAs = currentSobjectRecord.Name;
        intacctContactObject.contactName = currentSobjectRecord.RecurSoft__IntacctID__c + SPACE_SEPARATOR + currentSobjectRecord.Name;
        intacctContactObject.phone1 = checkFieldValue(currentSobjectRecord.Phone);
        intacctContactObject.email1 = checkFieldValue(currentSobjectRecord.RecurSoft__Billing_Email__c);
        intacctContactObject.email2 = checkFieldValue(currentSobjectRecord.RecurSoft__Billing_Email_CC__c);
        intacctContactObject.mailAddress = createBillingAddressObject(currentSobjectRecord);
        return intacctContactObject;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Create an intacct mailing address object
    * @param currentSobjectRecord The salesforce contact record
    * @return intacctMailAddressObject The intacct contact object
    */
    private IntacctObjectsInterface.Address createBillingAddressObject(sObject currentSobjectRecord)
    {
        IntacctObjectsInterface.Address intacctMailAddressObject = new IntacctObjectsInterface.Address();
        if(currentSobjectRecord.get(BILLING_STREET_API_NAME) != NULL){
            String [] streetaddr = String.valueOf(currentSobjectRecord.get(BILLING_STREET_API_NAME)).split('\n', 2);
            intacctMailAddressObject.address1 = streetaddr[0];
            if(streetaddr.size() == 2){
                intacctMailAddressObject.address2 = streetaddr[1];
            }else{
                intacctMailAddressObject.address2 = '';
            }
        }else{
            intacctMailAddressObject.address1 = '';
            intacctMailAddressObject.address2 = '';
        }
        
        intacctMailAddressObject.city = String.valueOf(currentSobjectRecord.get(BILLING_CITY_API_NAME));
        intacctMailAddressObject.state = String.valueOf(currentSobjectRecord.get(BILLING_STATE_API_NAME));
        intacctMailAddressObject.country = String.valueOf(currentSobjectRecord.get(BILLING_COUNTRY_API_NAME));
        intacctMailAddressObject.zip = String.valueOf(currentSobjectRecord.get(BILLING_POSTAL_CODE_API_NAME));
        return intacctMailAddressObject;
    }
    
    /**
    * @author Ionut Boghean
    * @date June 30, 2014
    * @description Create an intacct contact child object 
    * @param currentSobjectRecord The salesforce account record
    * @param contactType The type of the contact object being created. Used to set the contact name prefix
    * @return intacctContactObject The intacct contact object
    */
    private IntacctObjectContact createContactObject(Account currentSobjectRecord, String contactType)
    {
        IntacctObjectContact intacctContactObject = new IntacctObjectContact();
        intacctContactObject.salesforceId = currentSobjectRecord.Id;
        intacctContactObject.printAs = currentSobjectRecord.Name;
        intacctContactObject.contactName = CONTACT_PREFIXES.get(contactType) + currentSobjectRecord.Name + '_' + currentSobjectRecord.RecurSoft__IntacctID__c;
        intacctContactObject.phone1 = checkFieldValue(currentSobjectRecord.Phone);
        intacctContactObject.email1 = checkFieldValue(currentSobjectRecord.RecurSoft__Billing_Email__c);
        intacctContactObject.email2 = checkFieldValue(currentSobjectRecord.RecurSoft__Billing_Email_CC__c);
        intacctContactObject.mailAddress = createBillingAddressObject(currentSobjectRecord);
        return intacctContactObject;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 28, 2014
    * @description Create an intacct mailing address object
    * @param currentSobjectRecord The salesforce contact record
    * @return intacctMailAddressObject The intacct contact object
    */
    private IntacctObjectsInterface.Address createMailingAddressObject(sObject currentSobjectRecord)
    {
        IntacctObjectsInterface.Address intacctMailAddressObject = new IntacctObjectsInterface.Address();
        intacctMailAddressObject.address1 = String.valueOf(currentSobjectRecord.get(MAILING_STREET_API_NAME));
        intacctMailAddressObject.city = String.valueOf(currentSobjectRecord.get(MAILING_CITY_API_NAME));
        intacctMailAddressObject.state = String.valueOf(currentSobjectRecord.get(MAILING_STATE_API_NAME));
        intacctMailAddressObject.country = String.valueOf(currentSobjectRecord.get(MAILING_COUNTRY_API_NAME));
        intacctMailAddressObject.zip = String.valueOf(currentSobjectRecord.get(MAILING_POSTAL_CODE_API_NAME));
        return intacctMailAddressObject;
    }
    
    /**
    * @author Anca Comaneciu
    * @date April 17, 2014
    * @description Create an intacct custom field
    * @param name The Intacct field name
    * @param value The Intacct field value
    * @return intacctCustomField The intacct contact object
    */
    private IntacctObjectsInterface.CustomField createCustomField(String name, String value)
    {
        IntacctObjectsInterface.CustomField intacctCustomField = new IntacctObjectsInterface.CustomField();
        intacctCustomField.customFieldName = name;
        intacctCustomField.customFieldValue = value;
        return intacctCustomField;
    }
    
    /**
    * @author Ionut Boghean
    * @date April 11, 2014
    * @description Check if a string is empty(null) and return an empty character if it is
    * @param fieldValue The record field value
    * @return newValue The new value for the field
    */
    private String checkFieldValue(String fieldValue)
    {
        String newValue = '';
        if(!String.isBlank(fieldValue))
        {
            newValue = fieldValue;
        }
        return newValue;
    }
    
    /**
    * @author Ionut Boghean
    * @date May 30, 2014
    * @description Check if the entity mapping is enabled for the given name
    * @param settingName The name of the setting entry
    * @return isEntityMappingEnabled Flag for entity mapping
    */
    private Boolean checkEntityMappingSettings(String settingName)
    {
        Boolean isEntityMappingEnabled = false;
        Entity_Mapping_Settings__c entityMappingSetting = Entity_Mapping_Settings__c.getValues(settingName);
        if(entityMappingSetting != null && entityMappingSetting.Active__c)
        {
            isEntityMappingEnabled = true;
        }
        return isEntityMappingEnabled;
    }
    
}